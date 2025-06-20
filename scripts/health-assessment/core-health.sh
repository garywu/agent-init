#!/usr/bin/env bash
# Core Health Assessment Framework
# Part of claude-init - Comprehensive project health evaluation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-.}"
OUTPUT_FORMAT="${2:-human}" # human, json, markdown
VERBOSE="${VERBOSE:-false}"

# Health dimensions and weights
declare -A HEALTH_SCORES=(
    [code_quality]=0
    [test_coverage]=0
    [security]=0
    [performance]=0
    [maintenance]=0
    [documentation]=0
)

declare -A HEALTH_WEIGHTS=(
    [code_quality]=25
    [test_coverage]=20
    [security]=25
    [performance]=15
    [maintenance]=10
    [documentation]=5
)

# Analysis results
declare -A ISSUES_FOUND=()
declare -A RECOMMENDATIONS=()
declare -a CRITICAL_ISSUES=()
declare -a WARNINGS=()
declare -a INFO_ITEMS=()

# Utility functions
log_info() {
    [[ "$VERBOSE" == "true" ]] && echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_success() {
    [[ "$OUTPUT_FORMAT" == "human" ]] && echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
    WARNINGS+=("$1")
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    CRITICAL_ISSUES+=("$1")
}

# Score calculation
calculate_weighted_score() {
    local total_score=0
    local total_weight=0
    
    for dimension in "${!HEALTH_SCORES[@]}"; do
        local score=${HEALTH_SCORES[$dimension]}
        local weight=${HEALTH_WEIGHTS[$dimension]}
        total_score=$((total_score + (score * weight)))
        total_weight=$((total_weight + weight))
    done
    
    if [[ $total_weight -gt 0 ]]; then
        echo $((total_score / total_weight))
    else
        echo 0
    fi
}

# Get health status from score
get_health_status() {
    local score=$1
    
    if [[ $score -ge 90 ]]; then
        echo "Excellent"
    elif [[ $score -ge 70 ]]; then
        echo "Good"
    elif [[ $score -ge 50 ]]; then
        echo "Fair"
    elif [[ $score -ge 30 ]]; then
        echo "Poor"
    else
        echo "Critical"
    fi
}

# Get status color
get_status_color() {
    local score=$1
    
    if [[ $score -ge 90 ]]; then
        echo "$GREEN"
    elif [[ $score -ge 70 ]]; then
        echo "$BLUE"
    elif [[ $score -ge 50 ]]; then
        echo "$YELLOW"
    else
        echo "$RED"
    fi
}

# Code quality assessment
assess_code_quality() {
    log_info "Assessing code quality..."
    
    local score=100
    local issues=0
    
    # Check for linting configuration
    if [[ ! -f "$PROJECT_ROOT/.eslintrc.js" && ! -f "$PROJECT_ROOT/.eslintrc.json" && 
          ! -f "$PROJECT_ROOT/.flake8" && ! -f "$PROJECT_ROOT/.golangci.yml" ]]; then
        score=$((score - 10))
        ISSUES_FOUND[code_quality]+="No linting configuration found. "
        ((issues++))
    fi
    
    # Check for formatting configuration
    if [[ ! -f "$PROJECT_ROOT/.prettierrc" && ! -f "$PROJECT_ROOT/.prettierrc.js" && 
          ! -f "$PROJECT_ROOT/pyproject.toml" && ! -f "$PROJECT_ROOT/.rustfmt.toml" ]]; then
        score=$((score - 10))
        ISSUES_FOUND[code_quality]+="No code formatting configuration found. "
        ((issues++))
    fi
    
    # Check for TODO/FIXME items
    local todo_count=$(grep -r "TODO\|FIXME\|HACK\|XXX" "$PROJECT_ROOT" --exclude-dir=node_modules --exclude-dir=.git 2>/dev/null | wc -l || echo 0)
    if [[ $todo_count -gt 20 ]]; then
        score=$((score - 15))
        ISSUES_FOUND[code_quality]+="High number of TODO/FIXME items ($todo_count). "
        ((issues++))
    elif [[ $todo_count -gt 10 ]]; then
        score=$((score - 5))
        ((issues++))
    fi
    
    # Check for code complexity (simplified check)
    local long_files=$(find "$PROJECT_ROOT" -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" | 
                       xargs wc -l 2>/dev/null | grep -E "^[[:space:]]*[0-9]{4,}" | wc -l || echo 0)
    if [[ $long_files -gt 5 ]]; then
        score=$((score - 10))
        ISSUES_FOUND[code_quality]+="Multiple files with 1000+ lines. Consider refactoring. "
        ((issues++))
    fi
    
    # Set recommendations
    if [[ $issues -gt 0 ]]; then
        RECOMMENDATIONS[code_quality]="Set up linting and formatting tools. Refactor large files. Address TODO items."
    fi
    
    HEALTH_SCORES[code_quality]=$score
    log_info "Code quality score: $score/100"
}

# Test coverage assessment
assess_test_coverage() {
    log_info "Assessing test coverage..."
    
    local score=100
    local has_tests=false
    
    # Check for test directories
    if [[ -d "$PROJECT_ROOT/test" || -d "$PROJECT_ROOT/tests" || -d "$PROJECT_ROOT/__tests__" || 
          -d "$PROJECT_ROOT/spec" || -f "$PROJECT_ROOT/pytest.ini" ]]; then
        has_tests=true
    else
        score=30
        ISSUES_FOUND[test_coverage]="No test directory found. "
    fi
    
    # Check for test configuration
    if [[ ! -f "$PROJECT_ROOT/jest.config.js" && ! -f "$PROJECT_ROOT/pytest.ini" && 
          ! -f "$PROJECT_ROOT/.rspec" && ! -f "$PROJECT_ROOT/go.mod" ]]; then
        score=$((score - 20))
        ISSUES_FOUND[test_coverage]+="No test configuration found. "
    fi
    
    # Check for CI test configuration
    if [[ -f "$PROJECT_ROOT/.github/workflows/"*.yml ]]; then
        local has_test_step=$(grep -l "test\|pytest\|jest\|go test" "$PROJECT_ROOT/.github/workflows/"*.yml 2>/dev/null | wc -l || echo 0)
        if [[ $has_test_step -eq 0 ]]; then
            score=$((score - 10))
            ISSUES_FOUND[test_coverage]+="No test execution in CI/CD. "
        fi
    fi
    
    # Check for coverage configuration
    if [[ ! -f "$PROJECT_ROOT/.coveragerc" && ! -f "$PROJECT_ROOT/jest.config.js" ]]; then
        score=$((score - 10))
        ISSUES_FOUND[test_coverage]+="No coverage configuration found. "
    fi
    
    # Set recommendations
    if [[ $score -lt 70 ]]; then
        RECOMMENDATIONS[test_coverage]="Add comprehensive test suite. Configure test coverage reporting. Add tests to CI/CD pipeline."
    fi
    
    HEALTH_SCORES[test_coverage]=$score
    log_info "Test coverage score: $score/100"
}

# Security assessment
assess_security() {
    log_info "Assessing security..."
    
    local score=100
    local critical_issues=0
    
    # Check for sensitive data patterns
    local sensitive_patterns=$(grep -r -E "(password|secret|key|token|api_key)\s*=\s*[\"'][^\"']+[\"']" "$PROJECT_ROOT" \
                               --exclude-dir=node_modules --exclude-dir=.git --exclude="*.md" 2>/dev/null | wc -l || echo 0)
    if [[ $sensitive_patterns -gt 0 ]]; then
        score=$((score - 30))
        CRITICAL_ISSUES+=("Potential hardcoded secrets found!")
        ISSUES_FOUND[security]="Hardcoded secrets detected ($sensitive_patterns occurrences). "
        ((critical_issues++))
    fi
    
    # Check for .env in .gitignore
    if [[ -f "$PROJECT_ROOT/.env" && -f "$PROJECT_ROOT/.gitignore" ]]; then
        if ! grep -q "^\.env$" "$PROJECT_ROOT/.gitignore"; then
            score=$((score - 20))
            ISSUES_FOUND[security]+=".env file not in .gitignore. "
            ((critical_issues++))
        fi
    fi
    
    # Check for dependency vulnerabilities (simplified)
    if [[ -f "$PROJECT_ROOT/package-lock.json" ]]; then
        local audit_available=$(cd "$PROJECT_ROOT" && npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities.total // 0' || echo 0)
        if [[ $audit_available -gt 10 ]]; then
            score=$((score - 20))
            ISSUES_FOUND[security]+="High number of npm vulnerabilities. "
        elif [[ $audit_available -gt 0 ]]; then
            score=$((score - 10))
            ISSUES_FOUND[security]+="Some npm vulnerabilities found. "
        fi
    fi
    
    # Check for security headers configuration (for web apps)
    if [[ -f "$PROJECT_ROOT/package.json" ]] && grep -q "express\|koa\|fastify" "$PROJECT_ROOT/package.json"; then
        if ! grep -r "helmet\|cors" "$PROJECT_ROOT" --include="*.js" --include="*.ts" >/dev/null 2>&1; then
            score=$((score - 10))
            ISSUES_FOUND[security]+="No security headers middleware detected. "
        fi
    fi
    
    # Set recommendations
    if [[ $critical_issues -gt 0 ]]; then
        RECOMMENDATIONS[security]="URGENT: Remove hardcoded secrets. Use environment variables. Add security scanning to CI/CD."
    elif [[ $score -lt 80 ]]; then
        RECOMMENDATIONS[security]="Run security audit. Update vulnerable dependencies. Configure security headers."
    fi
    
    HEALTH_SCORES[security]=$score
    log_info "Security score: $score/100"
}

# Performance assessment
assess_performance() {
    log_info "Assessing performance..."
    
    local score=100
    
    # Check for build optimization (web projects)
    if [[ -f "$PROJECT_ROOT/package.json" ]]; then
        # Check for production build configuration
        if ! grep -q "\"build\"" "$PROJECT_ROOT/package.json"; then
            score=$((score - 15))
            ISSUES_FOUND[performance]="No build script configured. "
        fi
        
        # Check for bundle analysis tools
        if ! grep -q "webpack-bundle-analyzer\|source-map-explorer\|size-limit" "$PROJECT_ROOT/package.json"; then
            score=$((score - 10))
            ISSUES_FOUND[performance]+="No bundle analysis tools found. "
        fi
    fi
    
    # Check for caching configuration
    if [[ -d "$PROJECT_ROOT/.github/workflows" ]]; then
        local has_cache=$(grep -l "cache:" "$PROJECT_ROOT/.github/workflows/"*.yml 2>/dev/null | wc -l || echo 0)
        if [[ $has_cache -eq 0 ]]; then
            score=$((score - 10))
            ISSUES_FOUND[performance]+="No caching in CI/CD workflows. "
        fi
    fi
    
    # Check for image optimization (web projects)
    local large_images=$(find "$PROJECT_ROOT" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -size +500k 2>/dev/null | wc -l || echo 0)
    if [[ $large_images -gt 10 ]]; then
        score=$((score - 15))
        ISSUES_FOUND[performance]+="Multiple large image files (>500KB). "
    fi
    
    # Set recommendations
    if [[ $score -lt 80 ]]; then
        RECOMMENDATIONS[performance]="Optimize build configuration. Add bundle analysis. Implement caching. Optimize assets."
    fi
    
    HEALTH_SCORES[performance]=$score
    log_info "Performance score: $score/100"
}

# Maintenance assessment
assess_maintenance() {
    log_info "Assessing maintenance..."
    
    local score=100
    
    # Check for outdated dependencies indicator
    if [[ -f "$PROJECT_ROOT/package.json" ]]; then
        local pkg_age=$(find "$PROJECT_ROOT/package-lock.json" -mtime +180 2>/dev/null | wc -l || echo 0)
        if [[ $pkg_age -gt 0 ]]; then
            score=$((score - 20))
            ISSUES_FOUND[maintenance]="Dependencies not updated in 6+ months. "
        fi
    fi
    
    # Check for CI/CD configuration
    if [[ ! -d "$PROJECT_ROOT/.github/workflows" && ! -f "$PROJECT_ROOT/.gitlab-ci.yml" && 
          ! -f "$PROJECT_ROOT/.circleci/config.yml" ]]; then
        score=$((score - 20))
        ISSUES_FOUND[maintenance]+="No CI/CD configuration found. "
    fi
    
    # Check for pre-commit hooks
    if [[ ! -f "$PROJECT_ROOT/.pre-commit-config.yaml" && ! -f "$PROJECT_ROOT/.husky" ]]; then
        score=$((score - 15))
        ISSUES_FOUND[maintenance]+="No pre-commit hooks configured. "
    fi
    
    # Check for issue templates
    if [[ ! -d "$PROJECT_ROOT/.github/ISSUE_TEMPLATE" ]]; then
        score=$((score - 10))
        ISSUES_FOUND[maintenance]+="No issue templates found. "
    fi
    
    # Check last commit age
    if [[ -d "$PROJECT_ROOT/.git" ]]; then
        local last_commit_days=$(cd "$PROJECT_ROOT" && git log -1 --format=%ct 2>/dev/null | xargs -I {} date -d @{} +%s 2>/dev/null | xargs -I {} echo $(( ($(date +%s) - {}) / 86400 )) || echo 0)
        if [[ $last_commit_days -gt 180 ]]; then
            score=$((score - 20))
            ISSUES_FOUND[maintenance]+="No commits in 6+ months. "
        fi
    fi
    
    # Set recommendations
    if [[ $score -lt 70 ]]; then
        RECOMMENDATIONS[maintenance]="Update dependencies regularly. Set up CI/CD. Configure pre-commit hooks. Add issue templates."
    fi
    
    HEALTH_SCORES[maintenance]=$score
    log_info "Maintenance score: $score/100"
}

# Documentation assessment
assess_documentation() {
    log_info "Assessing documentation..."
    
    local score=100
    
    # Check for README
    if [[ ! -f "$PROJECT_ROOT/README.md" && ! -f "$PROJECT_ROOT/README.rst" ]]; then
        score=$((score - 30))
        ISSUES_FOUND[documentation]="No README file found. "
    else
        # Check README content quality (basic)
        local readme_size=$(wc -l "$PROJECT_ROOT/README.md" 2>/dev/null | awk '{print $1}' || echo 0)
        if [[ $readme_size -lt 20 ]]; then
            score=$((score - 15))
            ISSUES_FOUND[documentation]+="README is too brief (<20 lines). "
        fi
    fi
    
    # Check for CONTRIBUTING guide
    if [[ ! -f "$PROJECT_ROOT/CONTRIBUTING.md" ]]; then
        score=$((score - 10))
        ISSUES_FOUND[documentation]+="No CONTRIBUTING.md found. "
    fi
    
    # Check for LICENSE
    if [[ ! -f "$PROJECT_ROOT/LICENSE" && ! -f "$PROJECT_ROOT/LICENSE.md" ]]; then
        score=$((score - 15))
        ISSUES_FOUND[documentation]+="No LICENSE file found. "
    fi
    
    # Check for API documentation
    if [[ -f "$PROJECT_ROOT/package.json" ]] && grep -q "express\|fastify\|koa" "$PROJECT_ROOT/package.json"; then
        if [[ ! -d "$PROJECT_ROOT/docs" && ! -f "$PROJECT_ROOT/openapi.yml" && ! -f "$PROJECT_ROOT/swagger.yml" ]]; then
            score=$((score - 10))
            ISSUES_FOUND[documentation]+="No API documentation found. "
        fi
    fi
    
    # Check for code comments (simplified)
    local code_files=$(find "$PROJECT_ROOT" -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" 2>/dev/null | head -20)
    if [[ -n "$code_files" ]]; then
        local comment_ratio=$(echo "$code_files" | xargs grep -E "^[[:space:]]*(//|#|/\*)" 2>/dev/null | wc -l || echo 0)
        local code_lines=$(echo "$code_files" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo 1)
        if [[ $code_lines -gt 0 && $((comment_ratio * 100 / code_lines)) -lt 5 ]]; then
            score=$((score - 10))
            ISSUES_FOUND[documentation]+="Low code comment ratio. "
        fi
    fi
    
    # Set recommendations  
    if [[ $score -lt 70 ]]; then
        RECOMMENDATIONS[documentation]="Add comprehensive README. Create CONTRIBUTING guide. Add LICENSE. Document APIs."
    fi
    
    HEALTH_SCORES[documentation]=$score
    log_info "Documentation score: $score/100"
}

# Run all assessments
run_all_assessments() {
    assess_code_quality
    assess_test_coverage
    assess_security
    assess_performance
    assess_maintenance
    assess_documentation
}

# Generate human-readable output
generate_human_output() {
    local overall_score=$(calculate_weighted_score)
    local health_status=$(get_health_status $overall_score)
    local status_color=$(get_status_color $overall_score)
    
    echo ""
    echo -e "${CYAN}🏥 PROJECT HEALTH ASSESSMENT${NC}"
    echo "============================"
    echo ""
    echo -e "Overall Health Score: ${status_color}$overall_score/100${NC} - $health_status"
    echo ""
    
    # Critical issues
    if [[ ${#CRITICAL_ISSUES[@]} -gt 0 ]]; then
        echo -e "${RED}🚨 CRITICAL ISSUES${NC}"
        for issue in "${CRITICAL_ISSUES[@]}"; do
            echo "  • $issue"
        done
        echo ""
    fi
    
    # Detailed scores
    echo -e "${BLUE}📊 Detailed Scores${NC}"
    echo "─────────────────"
    for dimension in code_quality test_coverage security performance maintenance documentation; do
        local score=${HEALTH_SCORES[$dimension]}
        local weight=${HEALTH_WEIGHTS[$dimension]}
        local color=$(get_status_color $score)
        local label=$(echo "$dimension" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
        printf "%-15s ${color}%3d/100${NC} (weight: %d%%)\n" "$label:" "$score" "$weight"
    done
    echo ""
    
    # Issues by category
    local has_issues=false
    for dimension in "${!ISSUES_FOUND[@]}"; do
        if [[ -n "${ISSUES_FOUND[$dimension]}" ]]; then
            has_issues=true
            break
        fi
    done
    
    if [[ "$has_issues" == "true" ]]; then
        echo -e "${YELLOW}⚠️  Issues Found${NC}"
        echo "──────────────"
        for dimension in "${!ISSUES_FOUND[@]}"; do
            if [[ -n "${ISSUES_FOUND[$dimension]}" ]]; then
                local label=$(echo "$dimension" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
                echo -e "${YELLOW}$label:${NC}"
                echo "  ${ISSUES_FOUND[$dimension]}"
            fi
        done
        echo ""
    fi
    
    # Recommendations
    local has_recommendations=false
    for dimension in "${!RECOMMENDATIONS[@]}"; do
        if [[ -n "${RECOMMENDATIONS[$dimension]}" ]]; then
            has_recommendations=true
            break
        fi
    done
    
    if [[ "$has_recommendations" == "true" ]]; then
        echo -e "${GREEN}💡 Recommendations${NC}"
        echo "────────────────"
        for dimension in "${!RECOMMENDATIONS[@]}"; do
            if [[ -n "${RECOMMENDATIONS[$dimension]}" ]]; then
                local label=$(echo "$dimension" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
                echo -e "${GREEN}$label:${NC}"
                echo "  ${RECOMMENDATIONS[$dimension]}"
            fi
        done
        echo ""
    fi
    
    # Summary
    echo -e "${CYAN}📋 Summary${NC}"
    echo "────────"
    echo "• Project health is $health_status"
    echo "• ${#CRITICAL_ISSUES[@]} critical issues found"
    echo "• ${#WARNINGS[@]} warnings generated"
    echo "• Focus on $(get_lowest_scoring_dimension) for maximum improvement"
    echo ""
}

# Get lowest scoring dimension
get_lowest_scoring_dimension() {
    local lowest_dimension=""
    local lowest_score=100
    
    for dimension in "${!HEALTH_SCORES[@]}"; do
        if [[ ${HEALTH_SCORES[$dimension]} -lt $lowest_score ]]; then
            lowest_score=${HEALTH_SCORES[$dimension]}
            lowest_dimension=$dimension
        fi
    done
    
    echo "$lowest_dimension" | tr '_' ' '
}

# Generate JSON output
generate_json_output() {
    local overall_score=$(calculate_weighted_score)
    local health_status=$(get_health_status $overall_score)
    
    cat <<EOF
{
  "overall_score": $overall_score,
  "health_status": "$health_status",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "detailed_scores": {
    "code_quality": ${HEALTH_SCORES[code_quality]},
    "test_coverage": ${HEALTH_SCORES[test_coverage]},
    "security": ${HEALTH_SCORES[security]},
    "performance": ${HEALTH_SCORES[performance]},
    "maintenance": ${HEALTH_SCORES[maintenance]},
    "documentation": ${HEALTH_SCORES[documentation]}
  },
  "critical_issues": $(printf '%s\n' "${CRITICAL_ISSUES[@]}" | jq -R . | jq -s .),
  "warnings": $(printf '%s\n' "${WARNINGS[@]}" | jq -R . | jq -s .),
  "issues": $(for dim in "${!ISSUES_FOUND[@]}"; do echo "\"$dim\": \"${ISSUES_FOUND[$dim]}\""; done | jq -s 'add // {}'),
  "recommendations": $(for dim in "${!RECOMMENDATIONS[@]}"; do echo "\"$dim\": \"${RECOMMENDATIONS[$dim]}\""; done | jq -s 'add // {}')
}
EOF
}

# Generate Markdown output
generate_markdown_output() {
    local overall_score=$(calculate_weighted_score)
    local health_status=$(get_health_status $overall_score)
    local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    
    cat <<EOF
# Project Health Assessment Report

**Generated**: $timestamp  
**Overall Score**: $overall_score/100  
**Status**: $health_status

## Executive Summary

The project has an overall health score of **$overall_score/100**, which is considered **$health_status**.

EOF
    
    if [[ ${#CRITICAL_ISSUES[@]} -gt 0 ]]; then
        echo "### 🚨 Critical Issues"
        echo ""
        for issue in "${CRITICAL_ISSUES[@]}"; do
            echo "- $issue"
        done
        echo ""
    fi
    
    cat <<EOF
## Detailed Analysis

| Category | Score | Weight | Status |
|----------|-------|--------|--------|
| Code Quality | ${HEALTH_SCORES[code_quality]}/100 | ${HEALTH_WEIGHTS[code_quality]}% | $(get_health_status ${HEALTH_SCORES[code_quality]}) |
| Test Coverage | ${HEALTH_SCORES[test_coverage]}/100 | ${HEALTH_WEIGHTS[test_coverage]}% | $(get_health_status ${HEALTH_SCORES[test_coverage]}) |
| Security | ${HEALTH_SCORES[security]}/100 | ${HEALTH_WEIGHTS[security]}% | $(get_health_status ${HEALTH_SCORES[security]}) |
| Performance | ${HEALTH_SCORES[performance]}/100 | ${HEALTH_WEIGHTS[performance]}% | $(get_health_status ${HEALTH_SCORES[performance]}) |
| Maintenance | ${HEALTH_SCORES[maintenance]}/100 | ${HEALTH_WEIGHTS[maintenance]}% | $(get_health_status ${HEALTH_SCORES[maintenance]}) |
| Documentation | ${HEALTH_SCORES[documentation]}/100 | ${HEALTH_WEIGHTS[documentation]}% | $(get_health_status ${HEALTH_SCORES[documentation]}) |

## Issues Identified

EOF
    
    for dimension in "${!ISSUES_FOUND[@]}"; do
        if [[ -n "${ISSUES_FOUND[$dimension]}" ]]; then
            local label=$(echo "$dimension" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            echo "### $label"
            echo "${ISSUES_FOUND[$dimension]}"
            echo ""
        fi
    done
    
    echo "## Recommendations"
    echo ""
    
    for dimension in "${!RECOMMENDATIONS[@]}"; do
        if [[ -n "${RECOMMENDATIONS[$dimension]}" ]]; then
            local label=$(echo "$dimension" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            echo "### $label"
            echo "${RECOMMENDATIONS[$dimension]}"
            echo ""
        fi
    done
    
    cat <<EOF
## Next Steps

1. Address critical security issues immediately
2. Focus on improving $(get_lowest_scoring_dimension) (lowest score)
3. Set up automated health monitoring in CI/CD
4. Review and implement recommendations
5. Re-run assessment after improvements

---

*Generated by claude-init health assessment system*
EOF
}

# Main execution
main() {
    log_info "Starting project health assessment for: $PROJECT_ROOT"
    
    # Change to project directory
    if [[ ! -d "$PROJECT_ROOT" ]]; then
        log_error "Project directory not found: $PROJECT_ROOT"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    
    # Run assessments
    run_all_assessments
    
    # Generate output based on format
    case "$OUTPUT_FORMAT" in
        "json")
            generate_json_output
            ;;
        "markdown"|"md")
            generate_markdown_output
            ;;
        "human"|*)
            generate_human_output
            ;;
    esac
    
    # Return appropriate exit code
    local overall_score=$(calculate_weighted_score)
    if [[ $overall_score -lt 50 ]]; then
        exit 1  # Poor health
    elif [[ ${#CRITICAL_ISSUES[@]} -gt 0 ]]; then
        exit 2  # Critical issues found
    else
        exit 0  # Acceptable health
    fi
}

# Script usage
usage() {
    echo "Usage: $0 [PROJECT_PATH] [OUTPUT_FORMAT]"
    echo ""
    echo "PROJECT_PATH: Path to project directory (default: current directory)"
    echo "OUTPUT_FORMAT: Output format - human, json, markdown (default: human)"
    echo ""
    echo "Environment variables:"
    echo "  VERBOSE=true    Enable verbose logging"
    echo ""
    echo "Examples:"
    echo "  $0                              # Assess current directory"
    echo "  $0 /path/to/project json        # JSON output"
    echo "  $0 . markdown > health.md       # Save as markdown"
}

# Handle command line arguments
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

# Run main function
main "$@"