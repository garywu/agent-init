#!/usr/bin/env bash
# Python specific health checks

analyze_python_health() {
  local project_root=$1
  local score=100
  local issues=()
  
  # Look for Python files
  local python_files=$(find "$project_root" -name "*.py" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
  
  if [[ $python_files -eq 0 ]]; then
    echo "0|INFO|No Python files found"
    return
  fi
  
  # Check for requirements.txt or pyproject.toml
  if [[ ! -f "$project_root/requirements.txt" ]] && \
     [[ ! -f "$project_root/pyproject.toml" ]] && \
     [[ ! -f "$project_root/setup.py" ]]; then
    issues+=("No Python dependency file found (requirements.txt, pyproject.toml, or setup.py)")
    score=$((score - 20))
  fi
  
  # Check for virtual environment
  if [[ ! -d "$project_root/venv" ]] && \
     [[ ! -d "$project_root/.venv" ]] && \
     [[ ! -d "$project_root/env" ]]; then
    issues+=("No Python virtual environment found")
    score=$((score - 10))
  fi
  
  # Check for linting configuration
  if [[ ! -f "$project_root/.flake8" ]] && \
     [[ ! -f "$project_root/.pylintrc" ]] && \
     [[ ! -f "$project_root/pyproject.toml" ]] && \
     [[ ! -f "$project_root/setup.cfg" ]]; then
    issues+=("No Python linting configuration found")
    score=$((score - 15))
  fi
  
  # Check for type hints (mypy configuration)
  if [[ ! -f "$project_root/mypy.ini" ]] && \
     ! grep -q "mypy" "$project_root/pyproject.toml" 2>/dev/null && \
     ! grep -q "mypy" "$project_root/setup.cfg" 2>/dev/null; then
    issues+=("No type checking configuration found (mypy)")
    score=$((score - 10))
  fi
  
  # Check for test files
  local test_files=$(find "$project_root" -name "test_*.py" -o -name "*_test.py" 2>/dev/null | wc -l | tr -d ' ')
  if [[ $test_files -eq 0 ]]; then
    issues+=("No Python test files found")
    score=$((score - 20))
  fi
  
  # Check for __init__.py files in packages
  local dirs_without_init=$(find "$project_root" -type d -name "*.py" -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/venv/*" -not -path "*/.venv/*" 2>/dev/null | while read -r dir; do
    if [[ ! -f "$dir/__init__.py" ]]; then
      echo "$dir"
    fi
  done | wc -l | tr -d ' ')
  
  if [[ $dirs_without_init -gt 0 ]]; then
    issues+=("$dirs_without_init Python directories missing __init__.py")
    score=$((score - 5))
  fi
  
  # Output results
  echo "$score"
  for issue in "${issues[@]}"; do
    echo "|WARNING|$issue"
  done
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  analyze_python_health "${1:-$(pwd)}"
fi