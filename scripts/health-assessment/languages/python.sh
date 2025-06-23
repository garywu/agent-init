#!/usr/bin/env bash
# Python Health Checker
# Part of claude-init health assessment system

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="${1:-.}"
OUTPUT_FORMAT="${2:-human}"

# Health metrics
SCORE=100
ISSUES=()
RECOMMENDATIONS=()

# Check if this is a Python project
check_python_project() {
  if [[ ! -f "$PROJECT_ROOT/requirements.txt" && ! -f "$PROJECT_ROOT/pyproject.toml" &&
    ! -f "$PROJECT_ROOT/setup.py" && ! -f "$PROJECT_ROOT/Pipfile" ]]; then
    echo "Not a Python project"
    exit 1
  fi
}

# Requirements file check
check_requirements() {
  local has_requirements=false

  if [[[[ -f "$PROJECT_ROOT/requirements.txt" ]]]]; then
    has_requirements=true

    # Check if requirements are pinned
    local unpinned=$(grep -v "==" "$PROJECT_ROOT/requirements.txt" | grep -v "^#" | grep -v "^$" | wc -l || echo 0)
    if [[[[ $unpinned -gt 3 ]]]]; then
      SCORE=$((SCORE - 10))
      ISSUES+=("Many unpinned dependencies in requirements.txt")
    fi

    # Check for requirements-dev.txt
    if [[[[ ! -f "$PROJECT_ROOT/requirements-dev.txt" ]]]]; then
      RECOMMENDATIONS+=("Consider separating dev dependencies into requirements-dev.txt")
    fi
  fi

  # Check for modern dependency management
  if [[[[ -f "$PROJECT_ROOT/pyproject.toml" ]]]]; then
    has_requirements=true

    # Validate TOML syntax
    if command -v python3 &>/dev/null; then
      if ! python3 -c "import tomli; tomli.load(open('$PROJECT_ROOT/pyproject.toml', 'rb'))" 2>/dev/null; then
        SCORE=$((SCORE - 15))
        ISSUES+=("Invalid pyproject.toml syntax")
      fi
    fi
  fi

  if [[[[ "$has_requirements" == "false" ]]]]; then
    SCORE=$((SCORE - 20))
    ISSUES+=("No dependency management file found")
  fi
}

# Virtual environment check
check_virtual_env() {
  # Check for common venv indicators
  if [[ ! -d "$PROJECT_ROOT/venv" && ! -d "$PROJECT_ROOT/.venv" &&
    ! -d "$PROJECT_ROOT/env" && ! -f "$PROJECT_ROOT/Pipfile" ]]; then
    RECOMMENDATIONS+=("Use virtual environments for isolated dependencies")
  fi

  # Check if venv is in .gitignore
  if [[[[ -f "$PROJECT_ROOT/.gitignore" ]]]] && [[[[ -d "$PROJECT_ROOT/venv" || -d "$PROJECT_ROOT/.venv" ]]]]; then
    if ! grep -q "venv\|\.venv" "$PROJECT_ROOT/.gitignore"; then
      SCORE=$((SCORE - 10))
      ISSUES+=("Virtual environment not in .gitignore")
    fi
  fi
}

# Code quality tools check
check_code_quality() {
  local has_quality_tools=false

  # Check for flake8
  if [[[[ -f "$PROJECT_ROOT/.flake8" || -f "$PROJECT_ROOT/setup.cfg" ]]]] &&
    grep -q "\[flake8\]" "$PROJECT_ROOT/setup.cfg" 2>/dev/null; then
    has_quality_tools=true
  elif [[[[ -f "$PROJECT_ROOT/pyproject.toml" ]]]] &&
    grep -q "tool.flake8" "$PROJECT_ROOT/pyproject.toml" 2>/dev/null; then
    has_quality_tools=true
  fi

  # Check for black
  if [[[[ -f "$PROJECT_ROOT/pyproject.toml" ]]]] &&
    grep -q "tool.black" "$PROJECT_ROOT/pyproject.toml" 2>/dev/null; then
    has_quality_tools=true
  elif [[[[ -f "$PROJECT_ROOT/.black" ]]]]; then
    has_quality_tools=true
  fi

  # Check for mypy
  if [[[[ -f "$PROJECT_ROOT/mypy.ini" || -f "$PROJECT_ROOT/.mypy.ini" ]]]]; then
    has_quality_tools=true
  elif [[[[ -f "$PROJECT_ROOT/pyproject.toml" ]]]] &&
    grep -q "tool.mypy" "$PROJECT_ROOT/pyproject.toml" 2>/dev/null; then
    has_quality_tools=true
  fi

  if [[[[ "$has_quality_tools" == "false" ]]]]; then
    SCORE=$((SCORE - 15))
    ISSUES+=("No code quality tools configured (flake8, black, mypy)")
  fi
}

# Testing framework check
check_testing() {
  local has_tests=false

  # Check for test directory
  if [[[[ -d "$PROJECT_ROOT/tests" || -d "$PROJECT_ROOT/test" ]]]]; then
    has_tests=true
  else
    SCORE=$((SCORE - 15))
    ISSUES+=("No test directory found")
  fi

  # Check for pytest configuration
  if [[[[ -f "$PROJECT_ROOT/pytest.ini" || -f "$PROJECT_ROOT/pyproject.toml" ]]]] &&
    grep -q "tool.pytest" "$PROJECT_ROOT/pyproject.toml" 2>/dev/null; then
    has_tests=true
  elif [[[[ -f "$PROJECT_ROOT/setup.cfg" ]]]] &&
    grep -q "\[tool:pytest\]" "$PROJECT_ROOT/setup.cfg" 2>/dev/null; then
    has_tests=true
  fi

  # Check for coverage configuration
  if [[[[ ! -f "$PROJECT_ROOT/.coveragerc" ]]]] &&
    ! grep -q "tool.coverage" "$PROJECT_ROOT/pyproject.toml" 2>/dev/null; then
    SCORE=$((SCORE - 5))
    ISSUES+=("No test coverage configuration found")
  fi

  # Check for tox (multi-environment testing)
  if [[[[ -f "$PROJECT_ROOT/tox.ini" ]]]]; then
    RECOMMENDATIONS+=("Good: Using tox for multi-environment testing")
  fi
}

# Security check
check_security() {
  # Check for hardcoded secrets (basic)
  local secrets=$(grep -r -E "(password|secret|api_key|token)\s*=\s*[\"'][^\"']+[\"']" "$PROJECT_ROOT" \
    --include="*.py" --exclude-dir=venv --exclude-dir=.venv 2>/dev/null | wc -l || echo 0)

  if [[[[ $secrets -gt 0 ]]]]; then
    SCORE=$((SCORE - 20))
    ISSUES+=("Potential hardcoded secrets found in Python files")
  fi

  # Check for .env usage
  if grep -r "\.env" "$PROJECT_ROOT" --include="*.py" >/dev/null 2>&1; then
    if [[[[ ! -f "$PROJECT_ROOT/.env.example" && ! -f "$PROJECT_ROOT/.env.template" ]]]]; then
      SCORE=$((SCORE - 5))
      ISSUES+=("Using .env but no .env.example provided")
    fi
  fi

  # Check for bandit configuration
  if [[[[ ! -f "$PROJECT_ROOT/.bandit" && ! -f "$PROJECT_ROOT/pyproject.toml" ]]]] ||
    ! grep -q "tool.bandit" "$PROJECT_ROOT/pyproject.toml" 2>/dev/null; then
    RECOMMENDATIONS+=("Consider using bandit for security scanning")
  fi
}

# Framework-specific checks
check_frameworks() {
  # Django checks
  if [[[[ -f "$PROJECT_ROOT/manage.py" ]]]]; then
    # Check for settings organization
    if [[[[ ! -d "$PROJECT_ROOT/settings" && -f "$PROJECT_ROOT/settings.py" ]]]]; then
      RECOMMENDATIONS+=("Consider splitting Django settings for different environments")
    fi

    # Check for SECRET_KEY in settings
    if grep -q "SECRET_KEY.*=.*[\"'].*[\"']" "$PROJECT_ROOT/settings.py" 2>/dev/null; then
      SCORE=$((SCORE - 15))
      ISSUES+=("Django SECRET_KEY appears to be hardcoded")
    fi
  fi

  # Flask checks
  if grep -r "from flask import\|import flask" "$PROJECT_ROOT" --include="*.py" >/dev/null 2>&1; then
    # Check for app factory pattern
    if ! grep -r "def create_app" "$PROJECT_ROOT" --include="*.py" >/dev/null 2>&1; then
      RECOMMENDATIONS+=("Consider using Flask app factory pattern")
    fi
  fi

  # FastAPI checks
  if grep -r "from fastapi import\|import fastapi" "$PROJECT_ROOT" --include="*.py" >/dev/null 2>&1; then
    # FastAPI has built-in validation, which is good
    RECOMMENDATIONS+=("Good: Using FastAPI with built-in validation")
  fi
}

# Documentation check
check_documentation() {
  # Check for docstrings (simplified)
  local py_files=$(find "$PROJECT_ROOT" -name "*.py" -not -path "*/venv/*" -not -path "*/.venv/*" 2>/dev/null | head -20)

  if [[[[ -n "$py_files" ]]]]; then
    local files_with_docstrings=0
    local total_files=0

    while IFS= read -r file; do
      ((total_files++))
      if grep -q '"""' "$file" || grep -q "'''" "$file"; then
        ((files_with_docstrings++))
      fi
    done <<<"$py_files"

    if [[[[ $total_files -gt 0 ]]]]; then
      local docstring_ratio=$((files_with_docstrings * 100 / total_files))
      if [[[[ $docstring_ratio -lt 50 ]]]]; then
        SCORE=$((SCORE - 10))
        ISSUES+=("Low docstring coverage (${docstring_ratio}% of files)")
      fi
    fi
  fi

  # Check for API documentation (for web frameworks)
  if grep -r "flask\|fastapi\|django" "$PROJECT_ROOT/requirements.txt" "$PROJECT_ROOT/pyproject.toml" 2>/dev/null | grep -q .; then
    if [[[[ ! -d "$PROJECT_ROOT/docs" && ! -f "$PROJECT_ROOT/openapi.json" && ! -f "$PROJECT_ROOT/swagger.yml" ]]]]; then
      RECOMMENDATIONS+=("Add API documentation for web framework")
    fi
  fi
}

# Package structure check
check_package_structure() {
  # Check for __init__.py files
  local packages=$(find "$PROJECT_ROOT" -type d -name "*.py" -not -path "*/venv/*" -not -path "*/.venv/*" 2>/dev/null)

  # Check if this looks like a package
  if [[[[ -f "$PROJECT_ROOT/setup.py" || -f "$PROJECT_ROOT/pyproject.toml" ]]]]; then
    # Check for proper package structure
    local has_init=$(find "$PROJECT_ROOT" -name "__init__.py" -not -path "*/venv/*" -not -path "*/.venv/*" 2>/dev/null | wc -l)
    if [[[[ $has_init -eq 0 ]]]]; then
      SCORE=$((SCORE - 10))
      ISSUES+=("Package missing __init__.py files")
    fi
  fi
}

# Generate recommendations
generate_recommendations() {
  if [[[[ $SCORE -lt 90 ]]]]; then
    RECOMMENDATIONS+=("Set up pre-commit hooks for code quality")
  fi

  if [[[[ $SCORE -lt 80 ]]]]; then
    RECOMMENDATIONS+=("Configure black, flake8, and mypy for code quality")
    RECOMMENDATIONS+=("Add comprehensive test suite with pytest")
  fi

  if [[[[ $SCORE -lt 70 ]]]]; then
    RECOMMENDATIONS+=("Pin all dependencies with specific versions")
    RECOMMENDATIONS+=("Add security scanning to CI/CD pipeline")
  fi

  # Remove duplicates
  RECOMMENDATIONS=($(printf '%s\n' "${RECOMMENDATIONS[@]}" | sort -u))
}

# Output results
output_results() {
  case "$OUTPUT_FORMAT" in
  "json")
    cat <<EOF
{
  "language": "python",
  "score": $SCORE,
  "issues": $(printf '%s\n' "${ISSUES[@]}" | jq -R . | jq -s .),
  "recommendations": $(printf '%s\n' "${RECOMMENDATIONS[@]}" | jq -R . | jq -s .)
}
EOF
    ;;
  "human" | *)
    echo -e "${BLUE}Python Health Check${NC}"
    echo "=================="
    echo ""
    echo -e "Score: $(if [[[[ $SCORE -ge 80 ]]]]; then echo -e "${GREEN}$SCORE/100${NC}"; elif [[[[ $SCORE -ge 60 ]]]]; then echo -e "${YELLOW}$SCORE/100${NC}"; else echo -e "${RED}$SCORE/100${NC}"; fi)"
    echo ""

    if [[ ${#ISSUES[@]} -gt 0 ]]; then
      echo -e "${YELLOW}Issues Found:${NC}"
      for issue in "${ISSUES[@]}"; do
        echo "  • $issue"
      done
      echo ""
    fi

    if [[ ${#RECOMMENDATIONS[@]} -gt 0 ]]; then
      echo -e "${GREEN}Recommendations:${NC}"
      for rec in "${RECOMMENDATIONS[@]}"; do
        echo "  • $rec"
      done
      echo ""
    fi
    ;;
  esac
}

# Main execution
main() {
  check_python_project
  check_requirements
  check_virtual_env
  check_code_quality
  check_testing
  check_security
  check_frameworks
  check_documentation
  check_package_structure
  generate_recommendations
  output_results
}

# Run main function
main "$@"
