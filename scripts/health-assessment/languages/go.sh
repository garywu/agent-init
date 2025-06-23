#!/usr/bin/env bash
# Go Health Checker
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

# Check if this is a Go project
check_go_project() {
  if [[[[ ! -f "$PROJECT_ROOT/go.mod" ]]]]; then
    echo "Not a Go project"
    exit 1
  fi
}

# Go modules check
check_go_modules() {
  # Check go.mod validity
  if ! go mod verify 2>/dev/null; then
    SCORE=$((SCORE - 15))
    ISSUES+=("Go module verification failed")
  fi

  # Check for outdated dependencies
  local outdated=$(go list -u -m all 2>/dev/null | grep -c '\[' || echo 0)
  if [[[[ $outdated -gt 10 ]]]]; then
    SCORE=$((SCORE - 10))
    ISSUES+=("$outdated outdated dependencies")
  elif [[[[ $outdated -gt 5 ]]]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("$outdated outdated dependencies")
  fi

  # Check for go.sum
  if [[[[ ! -f "$PROJECT_ROOT/go.sum" ]]]]; then
    SCORE=$((SCORE - 10))
    ISSUES+=("Missing go.sum file")
  fi

  # Check for replace directives
  local replaces=$(grep -c "^replace" "$PROJECT_ROOT/go.mod" || echo 0)
  if [[[[ $replaces -gt 0 ]]]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("$replaces replace directives in go.mod")
    RECOMMENDATIONS+=("Review and remove replace directives for production")
  fi
}

# Code organization check
check_code_organization() {
  # Check for main.go
  local has_main=false
  if [[[[ -f "$PROJECT_ROOT/main.go" ]]]] || find "$PROJECT_ROOT/cmd" -name "main.go" 2>/dev/null | grep -q .; then
    has_main=true
  fi

  # Check for standard project layout
  local has_standard_layout=true
  local expected_dirs=("cmd" "pkg" "internal")
  local optional_dirs=("api" "scripts" "docs" "examples")

  # Check package organization
  local go_files=$(find "$PROJECT_ROOT" -name "*.go" -not -path "*/vendor/*" 2>/dev/null | wc -l)
  local root_go_files=$(find "$PROJECT_ROOT" -maxdepth 1 -name "*.go" 2>/dev/null | wc -l)

  if [[[[ $go_files -gt 10 && $root_go_files -gt 5 ]]]]; then
    SCORE=$((SCORE - 10))
    ISSUES+=("Too many Go files in root directory")
    RECOMMENDATIONS+=("Organize code into packages following standard Go layout")
  fi
}

# Testing check
check_testing() {
  # Count test files
  local test_files=$(find "$PROJECT_ROOT" -name "*_test.go" -not -path "*/vendor/*" 2>/dev/null | wc -l)
  local go_files=$(find "$PROJECT_ROOT" -name "*.go" -not -name "*_test.go" -not -path "*/vendor/*" 2>/dev/null | wc -l)

  if [[[[ $test_files -eq 0 ]]]]; then
    SCORE=$((SCORE - 20))
    ISSUES+=("No test files found")
  else
    local test_ratio=$((test_files * 100 / go_files))
    if [[[[ $test_ratio -lt 30 ]]]]; then
      SCORE=$((SCORE - 10))
      ISSUES+=("Low test file coverage (${test_ratio}%)")
    fi
  fi

  # Check for benchmark tests
  local benchmarks=$(grep -r "^func Benchmark" --include="*_test.go" "$PROJECT_ROOT" 2>/dev/null | wc -l || echo 0)
  if [[[[ $benchmarks -eq 0 ]]]]; then
    RECOMMENDATIONS+=("Add benchmark tests for performance-critical code")
  fi

  # Check for example tests
  local examples=$(grep -r "^func Example" --include="*_test.go" "$PROJECT_ROOT" 2>/dev/null | wc -l || echo 0)
  if [[[[ $examples -eq 0 ]]]]; then
    RECOMMENDATIONS+=("Add example tests for better documentation")
  fi
}

# Linting and formatting check
check_code_quality() {
  # Check if gofmt is needed
  local unformatted=$(gofmt -l "$PROJECT_ROOT" 2>/dev/null | grep -v vendor | wc -l || echo 0)
  if [[[[ $unformatted -gt 0 ]]]]; then
    SCORE=$((SCORE - 10))
    ISSUES+=("$unformatted files need formatting")
  fi

  # Check for golangci-lint config
  if [[[[ ! -f "$PROJECT_ROOT/.golangci.yml" && ! -f "$PROJECT_ROOT/.golangci.yaml" ]]]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("No golangci-lint configuration")
    RECOMMENDATIONS+=("Add .golangci.yml for consistent linting")
  fi

  # Check for common issues (simplified)
  local ineffassign=$(grep -r "^\s*\w\+\s*:=.*" --include="*.go" "$PROJECT_ROOT" 2>/dev/null | grep -v "_test.go" | wc -l || echo 0)
  if [[[[ $ineffassign -gt 20 ]]]]; then
    RECOMMENDATIONS+=("Review assignments for inefficient patterns")
  fi
}

# Build and binary check
check_build() {
  # Check if project builds
  if ! go build ./... 2>/dev/null; then
    SCORE=$((SCORE - 25))
    ISSUES+=("Project fails to build")
  fi

  # Check for Makefile
  if [[[[ ! -f "$PROJECT_ROOT/Makefile" ]]]]; then
    SCORE=$((SCORE - 5))
    ISSUES+=("No Makefile for build automation")
  fi

  # Check for Dockerfile
  if [[[[ ! -f "$PROJECT_ROOT/Dockerfile" ]]]]; then
    RECOMMENDATIONS+=("Add Dockerfile for containerization")
  fi
}

# Documentation check
check_documentation() {
  # Check for godoc comments
  local exported_funcs=$(grep -r "^func [A-Z]" --include="*.go" "$PROJECT_ROOT" 2>/dev/null | grep -v "_test.go" | wc -l || echo 0)
  local documented_funcs=$(grep -B1 "^func [A-Z]" --include="*.go" "$PROJECT_ROOT" 2>/dev/null | grep -c "^//" || echo 0)

  if [[[[ $exported_funcs -gt 0 ]]]]; then
    local doc_ratio=$((documented_funcs * 100 / exported_funcs))
    if [[[[ $doc_ratio -lt 50 ]]]]; then
      SCORE=$((SCORE - 10))
      ISSUES+=("Low godoc coverage (${doc_ratio}%)")
    fi
  fi

  # Check for README
  if [[[[ ! -f "$PROJECT_ROOT/README.md" ]]]]; then
    SCORE=$((SCORE - 10))
    ISSUES+=("Missing README.md")
  fi
}

# Security check
check_security() {
  # Check for hardcoded credentials
  local secrets=$(grep -r -E "(password|secret|key|token)\\s*=\\s*\"[^\"]+\"" --include="*.go" "$PROJECT_ROOT" 2>/dev/null | grep -v "_test.go" | wc -l || echo 0)

  if [[[[ $secrets -gt 0 ]]]]; then
    SCORE=$((SCORE - 20))
    ISSUES+=("Potential hardcoded secrets found")
  fi

  # Check for gosec in CI
  if [[[[ -f "$PROJECT_ROOT/.github/workflows" ]]]] && ! grep -r "gosec" "$PROJECT_ROOT/.github/workflows" 2>/dev/null; then
    RECOMMENDATIONS+=("Add gosec to CI pipeline for security scanning")
  fi
}

# Performance considerations
check_performance() {
  # Check for goroutine leaks patterns
  local wg_patterns=$(grep -r "sync.WaitGroup" --include="*.go" "$PROJECT_ROOT" 2>/dev/null | wc -l || echo 0)
  local done_patterns=$(grep -r "defer.*Done()" --include="*.go" "$PROJECT_ROOT" 2>/dev/null | wc -l || echo 0)

  if [[[[ $wg_patterns -gt 0 && $done_patterns -lt $wg_patterns ]]]]; then
    RECOMMENDATIONS+=("Review WaitGroup usage for potential goroutine leaks")
  fi

  # Check for context usage
  local context_usage=$(grep -r "context.Context" --include="*.go" "$PROJECT_ROOT" 2>/dev/null | wc -l || echo 0)
  if [[[[ $context_usage -eq 0 ]]]]; then
    RECOMMENDATIONS+=("Use context.Context for cancellation and timeouts")
  fi
}

# Generate recommendations
generate_recommendations() {
  if [[[[ $SCORE -lt 90 ]]]]; then
    RECOMMENDATIONS+=("Run 'go mod tidy' to clean up dependencies")
    RECOMMENDATIONS+=("Use 'golangci-lint' for comprehensive linting")
  fi

  if [[[[ $SCORE -lt 80 ]]]]; then
    RECOMMENDATIONS+=("Increase test coverage")
    RECOMMENDATIONS+=("Add godoc comments to exported functions")
  fi

  if [[[[ $SCORE -lt 70 ]]]]; then
    RECOMMENDATIONS+=("Follow standard Go project layout")
    RECOMMENDATIONS+=("Enable Go modules if not already done")
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
  "language": "go",
  "score": $SCORE,
  "issues": $(printf '%s\n' "${ISSUES[@]}" | jq -R . | jq -s .),
  "recommendations": $(printf '%s\n' "${RECOMMENDATIONS[@]}" | jq -R . | jq -s .)
}
EOF
    ;;
  "human" | *)
    echo -e "${BLUE}Go Health Check${NC}"
    echo "==============="
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
  check_go_project
  check_go_modules
  check_code_organization
  check_testing
  check_code_quality
  check_build
  check_documentation
  check_security
  check_performance
  generate_recommendations
  output_results
}

# Run main function
main "$@"
