#!/usr/bin/env bash
# Core Health Assessment Script
# Provides comprehensive project health evaluation across multiple dimensions
# Compatible with bash 3.2+ for macOS compatibility

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
OUTPUT_FORMAT="${2:-human}" # human, json, markdown

# Health scores (using simple variables instead of associative arrays)
SCORE_CODE_QUALITY=0
SCORE_TEST_COVERAGE=0
SCORE_SECURITY=0
SCORE_PERFORMANCE=0
SCORE_MAINTENANCE=0
SCORE_DOCUMENTATION=0
SCORE_DATABASE=0
SCORE_UI_CONSISTENCY=0

# Weights
WEIGHT_CODE_QUALITY=20
WEIGHT_TEST_COVERAGE=15
WEIGHT_SECURITY=20
WEIGHT_PERFORMANCE=15
WEIGHT_MAINTENANCE=10
WEIGHT_DOCUMENTATION=10
WEIGHT_DATABASE=5
WEIGHT_UI_CONSISTENCY=5

# Issues arrays
CRITICAL_ISSUES=()
WARNINGS=()
INFO_ITEMS=()

# Utility functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1" >&2
}

# Analyze code quality
analyze_code_quality() {
  local score=100

  # Check for linting configuration
  if [[ -f "$PROJECT_ROOT/.eslintrc.json" ]] || [[ -f "$PROJECT_ROOT/.eslintrc.js" ]] || [[ -f "$PROJECT_ROOT/biome.json" ]]; then
    log_info "✓ Linting configuration found"
  else
    WARNINGS+=("No JavaScript/TypeScript linting configuration found")
    score=$((score - 10))
  fi

  # Check for TypeScript
  if [[ -f "$PROJECT_ROOT/tsconfig.json" ]]; then
    log_info "✓ TypeScript configuration found"

    # Check for strict mode
    if grep -q '"strict": true' "$PROJECT_ROOT/tsconfig.json" 2>/dev/null; then
      log_info "✓ TypeScript strict mode enabled"
    else
      WARNINGS+=("TypeScript strict mode not enabled")
      score=$((score - 5))
    fi
  fi

  # Check for formatting
  if [[ -f "$PROJECT_ROOT/.prettierrc" ]] || [[ -f "$PROJECT_ROOT/.prettierrc.json" ]] || [[ -f "$PROJECT_ROOT/biome.json" ]]; then
    log_info "✓ Code formatting configuration found"
  else
    WARNINGS+=("No code formatting configuration found")
    score=$((score - 5))
  fi

  # Check for pre-commit hooks
  if [[ -f "$PROJECT_ROOT/.pre-commit-config.yaml" ]]; then
    log_info "✓ Pre-commit hooks configured"
  else
    WARNINGS+=("No pre-commit hooks configured")
    score=$((score - 10))
  fi

  SCORE_CODE_QUALITY=$score
}

# Analyze test coverage
analyze_test_coverage() {
  local score=0

  # Count test files
  local test_files=$(find "$PROJECT_ROOT" -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.ts" -o -name "*.spec.tsx" 2>/dev/null | wc -l | tr -d ' ')
  local src_files=$(find "$PROJECT_ROOT/hub/src" -name "*.ts" -o -name "*.tsx" 2>/dev/null | grep -v ".test\|.spec" | wc -l | tr -d ' ')

  if [[ $src_files -gt 0 ]]; then
    local coverage_ratio=$(((test_files * 100) / src_files))
    score=$coverage_ratio

    if [[ $coverage_ratio -lt 20 ]]; then
      CRITICAL_ISSUES+=("Very low test coverage: ${test_files} test files for ${src_files} source files")
    elif [[ $coverage_ratio -lt 50 ]]; then
      WARNINGS+=("Low test coverage: ${test_files} test files for ${src_files} source files")
    else
      log_info "✓ Test coverage ratio: ${coverage_ratio}%"
    fi
  fi

  # Check for test configuration
  if [[ -f "$PROJECT_ROOT/vitest.config.ts" ]] || [[ -f "$PROJECT_ROOT/jest.config.js" ]]; then
    log_info "✓ Test framework configured"
    score=$((score + 20))
  else
    WARNINGS+=("No test framework configuration found")
  fi

  [[ $score -gt 100 ]] && score=100
  SCORE_TEST_COVERAGE=$score
}

# Analyze security
analyze_security() {
  local score=100

  # Check for exposed secrets (look for actual API key patterns)
  if grep -rE "(sk-proj-|sk-ant-|OPENAI_API_KEY|ANTHROPIC_API_KEY|SECRET_KEY|PRIVATE_KEY).*[a-zA-Z0-9]{20,}" "$PROJECT_ROOT" --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=external --exclude-dir=.next 2>/dev/null | grep -v ".env.example" >/dev/null 2>&1; then
    CRITICAL_ISSUES+=("Potential exposed API keys found")
    score=$((score - 50))
  fi

  # Check for environment variables
  if [[ -f "$PROJECT_ROOT/.env" ]]; then
    WARNINGS+=(".env file exists - ensure it's not committed")
    score=$((score - 10))
  fi

  SCORE_SECURITY=$score
}

# Analyze performance
analyze_performance() {
  local score=100

  # Check for bundle size optimization
  if [[ -f "$PROJECT_ROOT/hub/next.config.ts" ]]; then
    if ! grep -q "swcMinify\|compress" "$PROJECT_ROOT/hub/next.config.ts" 2>/dev/null; then
      WARNINGS+=("Bundle minification not configured")
      score=$((score - 20))
    fi
  fi

  # Check for image optimization
  local unoptimized_images=$(find "$PROJECT_ROOT/hub/public" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" 2>/dev/null | wc -l | tr -d ' ')
  if [[ $unoptimized_images -gt 10 ]]; then
    WARNINGS+=("Many unoptimized images found: $unoptimized_images")
    score=$((score - 15))
  fi

  SCORE_PERFORMANCE=$score
}

# Analyze maintenance
analyze_maintenance() {
  local score=100

  # Check for documentation
  if [[ -f "$PROJECT_ROOT/README.md" ]]; then
    log_info "✓ README.md exists"
  else
    WARNINGS+=("No README.md found")
    score=$((score - 20))
  fi

  # Check for CONTRIBUTING guide
  if [[ -f "$PROJECT_ROOT/CONTRIBUTING.md" ]]; then
    log_info "✓ Contributing guide exists"
  else
    INFO_ITEMS+=("Consider adding CONTRIBUTING.md")
    score=$((score - 10))
  fi

  # Check for consistent file structure
  if [[ -d "$PROJECT_ROOT/hub/src/components" ]] && [[ -d "$PROJECT_ROOT/hub/src/lib" ]] && [[ -d "$PROJECT_ROOT/hub/src/stores" ]]; then
    log_info "✓ Consistent project structure"
  else
    WARNINGS+=("Inconsistent project structure detected")
    score=$((score - 15))
  fi

  SCORE_MAINTENANCE=$score
}

# Analyze documentation
analyze_documentation() {
  local score=50 # Start at 50 since we have some docs

  # Check for API documentation
  local doc_files=$(find "$PROJECT_ROOT/hub/docs" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  if [[ $doc_files -gt 10 ]]; then
    log_info "✓ Rich documentation found: $doc_files files"
    score=$((score + 30))
  elif [[ $doc_files -gt 5 ]]; then
    log_info "✓ Documentation found: $doc_files files"
    score=$((score + 20))
  else
    WARNINGS+=("Limited documentation: only $doc_files files")
  fi

  [[ $score -gt 100 ]] && score=100
  SCORE_DOCUMENTATION=$score
}

# Analyze database health
analyze_database() {
  local score=100

  # Check for migrations
  if [[ -d "$PROJECT_ROOT/hub/drizzle" ]] || [[ -d "$PROJECT_ROOT/hub/prisma/migrations" ]]; then
    log_info "✓ Database migrations found"
  else
    WARNINGS+=("No database migrations found")
    score=$((score - 30))
  fi

  # Check for schema
  if [[ -f "$PROJECT_ROOT/hub/src/db/schema/index.ts" ]]; then
    log_info "✓ Database schema defined"
  else
    CRITICAL_ISSUES+=("No database schema found")
    score=$((score - 50))
  fi

  # Check for seed data
  if [[ -d "$PROJECT_ROOT/hub/scripts" ]] && ls "$PROJECT_ROOT/hub/scripts"/seed*.ts >/dev/null 2>&1; then
    log_info "✓ Database seed scripts found"
  else
    INFO_ITEMS+=("Consider adding database seed scripts")
    score=$((score - 10))
  fi

  SCORE_DATABASE=$score
}

# Analyze UI consistency
analyze_ui_consistency() {
  local score=100

  # Check for component library
  if [[ -d "$PROJECT_ROOT/hub/src/components/ui" ]]; then
    log_info "✓ UI component library found"
  else
    WARNINGS+=("No centralized UI component library")
    score=$((score - 30))
  fi

  # Check for design tokens
  if [[ -f "$PROJECT_ROOT/hub/src/lib/utils.ts" ]] || grep -r "GAPS\|SPACING" "$PROJECT_ROOT/hub/src" 2>/dev/null | grep -q "const"; then
    log_info "✓ Design tokens/constants found"
  else
    WARNINGS+=("No design tokens or spacing constants found")
    score=$((score - 20))
  fi

  # Check for consistent styling approach
  # Note: Tailwind CSS v4 doesn't use config files - configuration is in CSS
  if [[ -f "$PROJECT_ROOT/tailwind.config.ts" ]] || [[ -f "$PROJECT_ROOT/tailwind.config.js" ]]; then
    log_info "✓ Tailwind CSS configured (v3 or earlier)"
  elif grep -r "@import.*tailwindcss" "$PROJECT_ROOT" 2>/dev/null | grep -q "\.css" || grep -r "@tailwind" "$PROJECT_ROOT" 2>/dev/null | grep -q "\.css"; then
    log_info "✓ Tailwind CSS v4 configured (CSS-based)"
  else
    INFO_ITEMS+=("Consider using a consistent styling solution")
    score=$((score - 10))
  fi

  SCORE_UI_CONSISTENCY=$score
}

# Calculate overall health score
calculate_overall_score() {
  local total_score=0
  local total_weight=0

  total_score=$((\
    SCORE_CODE_QUALITY * WEIGHT_CODE_QUALITY + \
    SCORE_TEST_COVERAGE * WEIGHT_TEST_COVERAGE + \
    SCORE_SECURITY * WEIGHT_SECURITY + \
    SCORE_PERFORMANCE * WEIGHT_PERFORMANCE + \
    SCORE_MAINTENANCE * WEIGHT_MAINTENANCE + \
    SCORE_DOCUMENTATION * WEIGHT_DOCUMENTATION + \
    SCORE_DATABASE * WEIGHT_DATABASE + \
    SCORE_UI_CONSISTENCY * WEIGHT_UI_CONSISTENCY))

  total_weight=$((\
    WEIGHT_CODE_QUALITY + \
    WEIGHT_TEST_COVERAGE + \
    WEIGHT_SECURITY + \
    WEIGHT_PERFORMANCE + \
    WEIGHT_MAINTENANCE + \
    WEIGHT_DOCUMENTATION + \
    WEIGHT_DATABASE + \
    WEIGHT_UI_CONSISTENCY))

  echo $((total_score / total_weight))
}

# Output results
output_human() {
  local overall_score=$1

  echo
  echo "════════════════════════════════════════════════════════════════"
  echo "                    PROJECT HEALTH REPORT                        "
  echo "════════════════════════════════════════════════════════════════"
  echo
  echo "Project: $(basename "$PROJECT_ROOT")"
  echo "Date: $(date)"
  echo "Overall Health Score: ${overall_score}%"
  echo
  echo "Breakdown by Category:"
  echo "──────────────────────────────────────────────────────────────"

  printf "%-20s %3d%%  (weight: %2d%%)\n" "code_quality" "$SCORE_CODE_QUALITY" "$WEIGHT_CODE_QUALITY"
  printf "%-20s %3d%%  (weight: %2d%%)\n" "test_coverage" "$SCORE_TEST_COVERAGE" "$WEIGHT_TEST_COVERAGE"
  printf "%-20s %3d%%  (weight: %2d%%)\n" "security" "$SCORE_SECURITY" "$WEIGHT_SECURITY"
  printf "%-20s %3d%%  (weight: %2d%%)\n" "performance" "$SCORE_PERFORMANCE" "$WEIGHT_PERFORMANCE"
  printf "%-20s %3d%%  (weight: %2d%%)\n" "maintenance" "$SCORE_MAINTENANCE" "$WEIGHT_MAINTENANCE"
  printf "%-20s %3d%%  (weight: %2d%%)\n" "documentation" "$SCORE_DOCUMENTATION" "$WEIGHT_DOCUMENTATION"
  printf "%-20s %3d%%  (weight: %2d%%)\n" "database" "$SCORE_DATABASE" "$WEIGHT_DATABASE"
  printf "%-20s %3d%%  (weight: %2d%%)\n" "ui_consistency" "$SCORE_UI_CONSISTENCY" "$WEIGHT_UI_CONSISTENCY"

  echo

  if [[ ${#CRITICAL_ISSUES[@]} -gt 0 ]]; then
    echo -e "${RED}Critical Issues:${NC}"
    for issue in "${CRITICAL_ISSUES[@]}"; do
      echo "  ✗ $issue"
    done
    echo
  fi

  if [[ ${#WARNINGS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Warnings:${NC}"
    for warning in "${WARNINGS[@]}"; do
      echo "  ⚠ $warning"
    done
    echo
  fi

  if [[ ${#INFO_ITEMS[@]} -gt 0 ]]; then
    echo -e "${BLUE}Suggestions:${NC}"
    for info in "${INFO_ITEMS[@]}"; do
      echo "  ℹ $info"
    done
    echo
  fi

  echo "Recommendations:"
  echo "──────────────────────────────────────────────────────────────"

  if [[ $overall_score -lt 50 ]]; then
    echo "• CRITICAL: Major improvements needed"
  elif [[ $overall_score -lt 70 ]]; then
    echo "• MODERATE: Several areas need attention"
  elif [[ $overall_score -lt 85 ]]; then
    echo "• GOOD: Minor improvements recommended"
  else
    echo "• EXCELLENT: Maintain current standards"
  fi

  # Specific recommendations based on low scores
  [[ $SCORE_CODE_QUALITY -lt 50 ]] && echo "• Set up linting, formatting, and pre-commit hooks"
  [[ $SCORE_TEST_COVERAGE -lt 50 ]] && echo "• Increase test coverage to at least 50%"
  [[ $SCORE_SECURITY -lt 50 ]] && echo "• Review security practices and remove exposed secrets"
  [[ $SCORE_PERFORMANCE -lt 50 ]] && echo "• Optimize bundle size and implement lazy loading"
  [[ $SCORE_DOCUMENTATION -lt 50 ]] && echo "• Add comprehensive documentation and inline comments"
  [[ $SCORE_DATABASE -lt 50 ]] && echo "• Implement proper migration strategy"
  [[ $SCORE_UI_CONSISTENCY -lt 50 ]] && echo "• Create a consistent design system"

  echo
}

# Main execution
main() {
  echo -e "${BLUE}Running health assessment...${NC}"

  # Run all analyses
  analyze_code_quality
  analyze_test_coverage
  analyze_security
  analyze_performance
  analyze_maintenance
  analyze_documentation
  analyze_database
  analyze_ui_consistency

  # Calculate overall score
  local overall_score=$(calculate_overall_score)

  # Output results
  case $OUTPUT_FORMAT in
  json)
    echo "JSON output not implemented in simplified version"
    ;;
  markdown)
    echo "Markdown output not implemented in simplified version"
    ;;
  *)
    output_human "$overall_score"
    ;;
  esac

  # Exit with appropriate code
  if [[ $overall_score -lt 50 ]]; then
    exit 2 # Critical
  elif [[ $overall_score -lt 70 ]]; then
    exit 1 # Warning
  else
    exit 0 # Success
  fi
}

# Run main function
main "$@"
