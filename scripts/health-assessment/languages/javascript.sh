#!/usr/bin/env bash
# JavaScript/TypeScript Health Checker
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

# Check if this is a JavaScript/TypeScript project
check_js_project() {
  if [[ ! -f "$PROJECT_ROOT/package.json" ]]; then
    echo "Not a JavaScript/TypeScript project"
    exit 1
  fi
}

# Package.json validation
check_package_json() {
  local pkg_file="$PROJECT_ROOT/package.json"

  # Validate JSON syntax
  if ! jq empty "$pkg_file" 2>/dev/null; then
    SCORE=$((SCORE - 20))
    ISSUES+=("Invalid package.json syntax")
    return
  fi

  # Check for essential fields
  local name=$(jq -r '.name // empty' "$pkg_file")
  local version=$(jq -r '.version // empty' "$pkg_file")
  local description=$(jq -r '.description // empty' "$pkg_file")

  if [[ -z $name ]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("Missing 'name' field in package.json")
  fi

  if [[ -z $version ]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("Missing 'version' field in package.json")
  fi

  if [[ -z $description ]]; then
    SCORE=$((SCORE - 3))
    ISSUES+=("Missing 'description' field in package.json")
  fi

  # Check for scripts
  local has_test=$(jq -r '.scripts.test // empty' "$pkg_file")
  local has_build=$(jq -r '.scripts.build // empty' "$pkg_file")
  local has_lint=$(jq -r '.scripts.lint // empty' "$pkg_file")

  if [[ -z $has_test ]]; then
    SCORE=$((SCORE - 10))
    ISSUES+=("No test script defined")
  fi

  if [[ -z $has_build ]] && [[ -f "$PROJECT_ROOT/tsconfig.json" || -f "$PROJECT_ROOT/webpack.config.js" ]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("No build script for compiled project")
  fi

  if [[ -z $has_lint ]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("No lint script defined")
  fi
}

# Dependency health check
check_dependencies() {
  local pkg_file="$PROJECT_ROOT/package.json"

  # Check for outdated lock file
  if [[ -f "$PROJECT_ROOT/package-lock.json" ]]; then
    local lock_age=$(find "$PROJECT_ROOT/package-lock.json" -mtime +180 2>/dev/null | wc -l || echo 0)
    if [[ $lock_age -gt 0 ]]; then
      SCORE=$((SCORE - 10))
      ISSUES+=("package-lock.json not updated in 6+ months")
    fi
  fi

  # Check for security audit
  if command -v npm &>/dev/null && [[ -f "$PROJECT_ROOT/package-lock.json" ]]; then
    local vulnerabilities=$(cd "$PROJECT_ROOT" && npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities.total // 0' || echo 0)
    if [[ $vulnerabilities -gt 20 ]]; then
      SCORE=$((SCORE - 15))
      ISSUES+=("High number of vulnerabilities: $vulnerabilities")
    elif [[ $vulnerabilities -gt 5 ]]; then
      SCORE=$((SCORE - 8))
      ISSUES+=("$vulnerabilities vulnerabilities found")
    fi
  fi

  # Check for duplicate dependencies
  local deps=$(jq -r '.dependencies // {} | keys[]' "$pkg_file" 2>/dev/null | sort)
  local devDeps=$(jq -r '.devDependencies // {} | keys[]' "$pkg_file" 2>/dev/null | sort)
  local duplicates=$(comm -12 <(echo "$deps") <(echo "$devDeps") | wc -l)

  if [[ $duplicates -gt 0 ]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("$duplicates dependencies appear in both dependencies and devDependencies")
  fi
}

# TypeScript configuration check
check_typescript() {
  if [[ ! -f "$PROJECT_ROOT/tsconfig.json" ]]; then
    # Check if TypeScript is used
    if grep -q "typescript" "$PROJECT_ROOT/package.json" 2>/dev/null; then
      SCORE=$((SCORE - 10))
      ISSUES+=("TypeScript dependency found but no tsconfig.json")
    fi
    return
  fi

  # Validate tsconfig.json
  if ! jq empty "$PROJECT_ROOT/tsconfig.json" 2>/dev/null; then
    SCORE=$((SCORE - 10))
    ISSUES+=("Invalid tsconfig.json syntax")
    return
  fi

  # Check for strict mode
  local strict=$(jq -r '.compilerOptions.strict // false' "$PROJECT_ROOT/tsconfig.json")
  if [[ $strict != "true" ]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("TypeScript strict mode not enabled")
  fi
}

# ESLint configuration check
check_eslint() {
  local has_eslint=false

  # Check for ESLint config files
  if [[ -f "$PROJECT_ROOT/.eslintrc.js" || -f "$PROJECT_ROOT/.eslintrc.json" ||
    -f "$PROJECT_ROOT/.eslintrc.yml" || -f "$PROJECT_ROOT/.eslintrc.yaml" ||
    -f "$PROJECT_ROOT/eslint.config.js" ]]; then
    has_eslint=true
  fi

  # Check if ESLint is in dependencies
  if grep -q "eslint" "$PROJECT_ROOT/package.json" 2>/dev/null && [[ $has_eslint == "false" ]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("ESLint installed but not configured")
  fi

  if [[ $has_eslint == "false" ]]; then
    SCORE=$((SCORE - 10))
    ISSUES+=("No ESLint configuration found")
  fi
}

# Prettier configuration check
check_prettier() {
  local has_prettier_config=false

  # Check for Prettier config files
  if [[ -f "$PROJECT_ROOT/.prettierrc" || -f "$PROJECT_ROOT/.prettierrc.js" ||
    -f "$PROJECT_ROOT/.prettierrc.json" || -f "$PROJECT_ROOT/.prettierrc.yml" ||
    -f "$PROJECT_ROOT/prettier.config.js" ]]; then
    has_prettier_config=true
  fi

  # Check if Prettier is in dependencies
  if grep -q "prettier" "$PROJECT_ROOT/package.json" 2>/dev/null && [[ $has_prettier_config == "false" ]]; then
    SCORE=$((SCORE - 3))
    ISSUES+=("Prettier installed but not configured")
  fi
}

# Bundle size check
check_bundle_size() {
  # Check for bundle analysis tools
  local has_bundle_analyzer=false

  if grep -q "webpack-bundle-analyzer\|source-map-explorer\|size-limit" "$PROJECT_ROOT/package.json" 2>/dev/null; then
    has_bundle_analyzer=true
  fi

  # For production apps, bundle analysis is important
  if [[ -f "$PROJECT_ROOT/webpack.config.js" || -f "$PROJECT_ROOT/next.config.js" ||
    -f "$PROJECT_ROOT/vite.config.js" ]] && [[ $has_bundle_analyzer == "false" ]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("No bundle size analysis tools configured")
  fi
}

# Testing framework check
check_testing() {
  local has_test_framework=false

  # Check for test configuration
  if [[ -f "$PROJECT_ROOT/jest.config.js" || -f "$PROJECT_ROOT/jest.config.ts" ||
    -f "$PROJECT_ROOT/vitest.config.js" || -f "$PROJECT_ROOT/vitest.config.ts" ||
    -f "$PROJECT_ROOT/.mocharc.js" || -f "$PROJECT_ROOT/karma.conf.js" ]]; then
    has_test_framework=true
  fi

  # Check for test directory
  if [[ ! -d "$PROJECT_ROOT/test" && ! -d "$PROJECT_ROOT/tests" &&
    ! -d "$PROJECT_ROOT/__tests__" && ! -d "$PROJECT_ROOT/src/__tests__" ]]; then
    SCORE=$((SCORE - 10))
    ISSUES+=("No test directory found")
  fi

  if [[ $has_test_framework == "false" ]]; then
    SCORE=$((SCORE - 10))
    ISSUES+=("No test framework configured")
  fi

  # Check for coverage configuration
  if [[ $has_test_framework == "true" ]] && ! grep -q "coverage" "$PROJECT_ROOT/jest.config.js" "$PROJECT_ROOT/package.json" 2>/dev/null; then
    SCORE=$((SCORE - 5))
    ISSUES+=("Test coverage not configured")
  fi
}

# React/Vue/Angular specific checks
check_frameworks() {
  local pkg_file="$PROJECT_ROOT/package.json"

  # React checks
  if grep -q '"react"' "$pkg_file" 2>/dev/null; then
    # Check for React DevTools
    if ! grep -q "react-devtools" "$pkg_file" 2>/dev/null; then
      RECOMMENDATIONS+=("Consider adding React DevTools for development")
    fi

    # Check for proper React import style
    if find "$PROJECT_ROOT/src" -name "*.jsx" -o -name "*.tsx" 2>/dev/null | xargs grep -l "import React from 'react'" | head -1 >/dev/null; then
      local react_version=$(jq -r '.dependencies.react // .devDependencies.react // ""' "$pkg_file" | grep -oE '[0-9]+' | head -1)
      if [[ -n $react_version && $react_version -ge 17 ]]; then
        RECOMMENDATIONS+=("React 17+ doesn't require React imports for JSX")
      fi
    fi
  fi

  # Next.js checks
  if grep -q '"next"' "$pkg_file" 2>/dev/null; then
    if [[ ! -f "$PROJECT_ROOT/next.config.js" && ! -f "$PROJECT_ROOT/next.config.ts" ]]; then
      SCORE=$((SCORE - 3))
      ISSUES+=("Next.js project without configuration file")
    fi
  fi

  # Vue checks
  if grep -q '"vue"' "$pkg_file" 2>/dev/null; then
    if [[ ! -f "$PROJECT_ROOT/vue.config.js" && ! -f "$PROJECT_ROOT/vite.config.js" ]]; then
      RECOMMENDATIONS+=("Consider adding Vue configuration file")
    fi
  fi
}

# Generate recommendations
generate_recommendations() {
  if [[ $SCORE -lt 90 ]]; then
    RECOMMENDATIONS+=("Run 'npm audit fix' to fix vulnerabilities")
  fi

  if [[ $SCORE -lt 80 ]]; then
    RECOMMENDATIONS+=("Set up ESLint and Prettier for code quality")
    RECOMMENDATIONS+=("Add comprehensive test suite with coverage")
  fi

  if [[ $SCORE -lt 70 ]]; then
    RECOMMENDATIONS+=("Update dependencies regularly")
    RECOMMENDATIONS+=("Configure TypeScript strict mode")
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
  "language": "javascript",
  "score": $SCORE,
  "issues": $(printf '%s\n' "${ISSUES[@]}" | jq -R . | jq -s .),
  "recommendations": $(printf '%s\n' "${RECOMMENDATIONS[@]}" | jq -R . | jq -s .)
}
EOF
      ;;
    "human" | *)
      echo -e "${BLUE}JavaScript/TypeScript Health Check${NC}"
      echo "=================================="
      echo ""
      echo -e "Score: $(if [[ $SCORE -ge 80 ]]; then echo -e "${GREEN}$SCORE/100${NC}"; elif [[ $SCORE -ge 60 ]]; then echo -e "${YELLOW}$SCORE/100${NC}"; else echo -e "${RED}$SCORE/100${NC}"; fi)"
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
  check_js_project
  check_package_json
  check_dependencies
  check_typescript
  check_eslint
  check_prettier
  check_bundle_size
  check_testing
  check_frameworks
  generate_recommendations
  output_results
}

# Run main function
main "$@"
