#!/usr/bin/env bash
# Security Scanner - Comprehensive security assessment
# Part of claude-init health assessment system

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="${1:-.}"
OUTPUT_FORMAT="${2:-human}"
VERBOSE="${VERBOSE:-false}"

# Security findings
declare -a CRITICAL_ISSUES=()
declare -a HIGH_ISSUES=()
declare -a MEDIUM_ISSUES=()
declare -a LOW_ISSUES=()
declare -a INFO_ITEMS=()
SECURITY_SCORE=100

# Utility functions
log_info() {
    [[ "$VERBOSE" == "true" ]] && echo -e "${BLUE}[INFO]${NC} $1" >&2
}

add_finding() {
    local severity="$1"
    local message="$2"
    local score_impact="$3"
    
    case "$severity" in
        "CRITICAL")
            CRITICAL_ISSUES+=("$message")
            SECURITY_SCORE=$((SECURITY_SCORE - score_impact))
            ;;
        "HIGH")
            HIGH_ISSUES+=("$message")
            SECURITY_SCORE=$((SECURITY_SCORE - score_impact))
            ;;
        "MEDIUM")
            MEDIUM_ISSUES+=("$message")
            SECURITY_SCORE=$((SECURITY_SCORE - score_impact))
            ;;
        "LOW")
            LOW_ISSUES+=("$message")
            SECURITY_SCORE=$((SECURITY_SCORE - score_impact))
            ;;
        "INFO")
            INFO_ITEMS+=("$message")
            ;;
    esac
    
    # Ensure score doesn't go below 0
    [[ $SECURITY_SCORE -lt 0 ]] && SECURITY_SCORE=0
}

# Check for hardcoded secrets and credentials
check_secrets() {
    log_info "Scanning for hardcoded secrets..."
    
    # Common secret patterns
    local secret_patterns=(
        "password.*=.*[\"'][^\"']+[\"']"
        "passwd.*=.*[\"'][^\"']+[\"']"
        "pwd.*=.*[\"'][^\"']+[\"']"
        "secret.*=.*[\"'][^\"']+[\"']"
        "api_key.*=.*[\"'][^\"']+[\"']"
        "apikey.*=.*[\"'][^\"']+[\"']"
        "access_key.*=.*[\"'][^\"']+[\"']"
        "auth_token.*=.*[\"'][^\"']+[\"']"
        "private_key.*=.*[\"'][^\"']+[\"']"
        "client_secret.*=.*[\"'][^\"']+[\"']"
    )
    
    # AWS specific patterns
    local aws_patterns=(
        "AKIA[0-9A-Z]{16}"
        "aws_access_key_id.*=.*[\"'][^\"']+[\"']"
        "aws_secret_access_key.*=.*[\"'][^\"']+[\"']"
    )
    
    # Check for common secret patterns
    for pattern in "${secret_patterns[@]}"; do
        local matches=$(grep -r -E -i "$pattern" "$PROJECT_ROOT" \
            --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=venv \
            --exclude="*.md" --exclude="*.lock" --exclude="*.sum" 2>/dev/null | wc -l || echo 0)
        
        if [[ $matches -gt 0 ]]; then
            add_finding "CRITICAL" "Found $matches potential hardcoded secrets matching pattern: $pattern" 20
        fi
    done
    
    # Check for AWS credentials
    for pattern in "${aws_patterns[@]}"; do
        local matches=$(grep -r -E "$pattern" "$PROJECT_ROOT" \
            --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=venv \
            --exclude="*.md" 2>/dev/null | wc -l || echo 0)
        
        if [[ $matches -gt 0 ]]; then
            add_finding "CRITICAL" "Found $matches potential AWS credentials" 25
        fi
    done
    
    # Check for private keys
    local private_keys=$(find "$PROJECT_ROOT" -name "*.pem" -o -name "*.key" -o -name "id_rsa*" \
        -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l || echo 0)
    
    if [[ $private_keys -gt 0 ]]; then
        add_finding "HIGH" "Found $private_keys private key files in repository" 15
    fi
}

# Check .env and .gitignore configuration
check_env_files() {
    log_info "Checking environment file security..."
    
    # Check for .env files
    local env_files=$(find "$PROJECT_ROOT" -name ".env*" -not -name ".env.example" -not -name ".env.template" \
        -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null)
    
    if [[ -n "$env_files" ]]; then
        # Check if .gitignore exists
        if [[ ! -f "$PROJECT_ROOT/.gitignore" ]]; then
            add_finding "CRITICAL" "Found .env files but no .gitignore" 20
        else
            # Check if .env is in .gitignore
            while IFS= read -r env_file; do
                local env_basename=$(basename "$env_file")
                if ! grep -q "^${env_basename}$" "$PROJECT_ROOT/.gitignore" && \
                   ! grep -q "^\.env" "$PROJECT_ROOT/.gitignore"; then
                    add_finding "HIGH" "$env_basename is not in .gitignore" 15
                fi
            done <<< "$env_files"
        fi
    fi
    
    # Check for .env.example
    if [[ -n "$env_files" ]] && [[ ! -f "$PROJECT_ROOT/.env.example" && ! -f "$PROJECT_ROOT/.env.template" ]]; then
        add_finding "MEDIUM" "No .env.example or .env.template found" 5
    fi
}

# Check dependency vulnerabilities
check_dependencies() {
    log_info "Checking dependency vulnerabilities..."
    
    # Node.js/npm
    if [[ -f "$PROJECT_ROOT/package-lock.json" ]]; then
        if command -v npm &>/dev/null; then
            local npm_audit=$(cd "$PROJECT_ROOT" && npm audit --json 2>/dev/null || echo "{}")
            local total_vulns=$(echo "$npm_audit" | jq '.metadata.vulnerabilities.total // 0' 2>/dev/null || echo 0)
            local critical_vulns=$(echo "$npm_audit" | jq '.metadata.vulnerabilities.critical // 0' 2>/dev/null || echo 0)
            local high_vulns=$(echo "$npm_audit" | jq '.metadata.vulnerabilities.high // 0' 2>/dev/null || echo 0)
            
            if [[ $critical_vulns -gt 0 ]]; then
                add_finding "CRITICAL" "Found $critical_vulns critical npm vulnerabilities" 20
            fi
            if [[ $high_vulns -gt 0 ]]; then
                add_finding "HIGH" "Found $high_vulns high npm vulnerabilities" 10
            fi
            if [[ $total_vulns -gt 10 ]]; then
                add_finding "MEDIUM" "Total $total_vulns npm vulnerabilities found" 5
            fi
        else
            add_finding "INFO" "npm not available for vulnerability scanning"
        fi
    fi
    
    # Python
    if [[ -f "$PROJECT_ROOT/requirements.txt" ]]; then
        # Check for outdated packages (basic check)
        local requirements_age=$(find "$PROJECT_ROOT/requirements.txt" -mtime +365 2>/dev/null | wc -l || echo 0)
        if [[ $requirements_age -gt 0 ]]; then
            add_finding "MEDIUM" "requirements.txt not updated in over a year" 5
        fi
        
        # Note about Python security scanning
        add_finding "INFO" "Run 'safety check' or 'pip-audit' for Python vulnerability scanning"
    fi
    
    # Go
    if [[ -f "$PROJECT_ROOT/go.mod" ]]; then
        if command -v go &>/dev/null; then
            # Check for known vulnerabilities
            add_finding "INFO" "Run 'govulncheck ./...' for Go vulnerability scanning"
        fi
    fi
}

# Check security headers and configurations
check_security_configs() {
    log_info "Checking security configurations..."
    
    # Web application checks
    if [[ -f "$PROJECT_ROOT/package.json" ]]; then
        local pkg_content=$(cat "$PROJECT_ROOT/package.json")
        
        # Check for security middleware (Express/Node.js)
        if echo "$pkg_content" | grep -q "express"; then
            if ! echo "$pkg_content" | grep -q "helmet"; then
                add_finding "MEDIUM" "Express app without helmet security middleware" 8
            fi
            if ! echo "$pkg_content" | grep -q "cors"; then
                add_finding "LOW" "Express app without CORS configuration" 3
            fi
        fi
        
        # Check for HTTPS enforcement
        if grep -r "http://" "$PROJECT_ROOT" --include="*.js" --include="*.ts" \
            --exclude-dir=node_modules --exclude-dir=test 2>/dev/null | grep -v "localhost" | grep -q .; then
            add_finding "MEDIUM" "Found non-HTTPS URLs in code" 5
        fi
    fi
    
    # Docker security
    if [[ -f "$PROJECT_ROOT/Dockerfile" ]]; then
        # Check for running as root
        if ! grep -q "USER" "$PROJECT_ROOT/Dockerfile"; then
            add_finding "MEDIUM" "Dockerfile doesn't specify non-root USER" 8
        fi
        
        # Check for latest tags
        if grep -E "FROM.*:latest" "$PROJECT_ROOT/Dockerfile"; then
            add_finding "LOW" "Dockerfile uses :latest tag (not reproducible)" 3
        fi
    fi
}

# Check authentication and authorization patterns
check_auth_patterns() {
    log_info "Checking authentication patterns..."
    
    # Check for JWT secret configuration
    if grep -r "jwt\|jsonwebtoken" "$PROJECT_ROOT" --include="*.js" --include="*.ts" --include="*.py" \
        --exclude-dir=node_modules 2>/dev/null | grep -q .; then
        
        # Check for hardcoded JWT secrets
        if grep -r -E "(jwt|token).*secret.*=.*[\"'][^\"']+[\"']" "$PROJECT_ROOT" \
            --include="*.js" --include="*.ts" --include="*.py" \
            --exclude-dir=node_modules 2>/dev/null | grep -q .; then
            add_finding "HIGH" "Potential hardcoded JWT secret found" 15
        fi
    fi
    
    # Check for basic auth patterns
    if grep -r "Authorization.*Basic" "$PROJECT_ROOT" \
        --include="*.js" --include="*.ts" --include="*.py" \
        --exclude-dir=node_modules 2>/dev/null | grep -q .; then
        add_finding "INFO" "Basic authentication pattern detected - ensure HTTPS is used"
    fi
}

# Check input validation
check_input_validation() {
    log_info "Checking input validation patterns..."
    
    # SQL injection patterns (basic check)
    local sql_concat=$(grep -r -E "(query|execute).*\+.*[\"']|[\"'].*\+.*WHERE" "$PROJECT_ROOT" \
        --include="*.js" --include="*.ts" --include="*.py" --include="*.php" \
        --exclude-dir=node_modules 2>/dev/null | wc -l || echo 0)
    
    if [[ $sql_concat -gt 0 ]]; then
        add_finding "HIGH" "Found $sql_concat potential SQL injection patterns (string concatenation in queries)" 10
    fi
    
    # Check for parameterized queries (good practice)
    if grep -r -E "\?|:\w+|\$[0-9]" "$PROJECT_ROOT" \
        --include="*.js" --include="*.ts" --include="*.py" \
        --exclude-dir=node_modules 2>/dev/null | grep -i "query\|execute" | grep -q .; then
        add_finding "INFO" "Good: Found parameterized query patterns"
    fi
}

# Check CI/CD security
check_cicd_security() {
    log_info "Checking CI/CD security..."
    
    # GitHub Actions
    if [[ -d "$PROJECT_ROOT/.github/workflows" ]]; then
        # Check for secret usage
        local exposed_secrets=$(grep -r "\${{ secrets\." "$PROJECT_ROOT/.github/workflows" | \
            grep -E "echo|print" | wc -l || echo 0)
        
        if [[ $exposed_secrets -gt 0 ]]; then
            add_finding "MEDIUM" "Found $exposed_secrets potential secret exposures in GitHub Actions" 8
        fi
        
        # Check for pin actions to commit SHA
        local unpinned_actions=$(grep -r "uses:" "$PROJECT_ROOT/.github/workflows" | \
            grep -v "@[a-f0-9]\{40\}" | grep -v "@v[0-9]" | wc -l || echo 0)
        
        if [[ $unpinned_actions -gt 5 ]]; then
            add_finding "LOW" "Multiple GitHub Actions not pinned to specific versions" 3
        fi
    fi
}

# Check file permissions and sensitive files
check_file_security() {
    log_info "Checking file security..."
    
    # Check for sensitive file patterns
    local sensitive_files=(
        "*.pem" "*.key" "*.p12" "*.pfx"
        "id_rsa" "id_dsa" "id_ecdsa" "id_ed25519"
        "*.sqlite" "*.db"
        "credentials.json" "service-account*.json"
    )
    
    for pattern in "${sensitive_files[@]}"; do
        local found=$(find "$PROJECT_ROOT" -name "$pattern" \
            -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l || echo 0)
        
        if [[ $found -gt 0 ]]; then
            add_finding "HIGH" "Found $found files matching sensitive pattern: $pattern" 10
        fi
    done
    
    # Check for backup files
    local backup_files=$(find "$PROJECT_ROOT" -name "*.bak" -o -name "*.backup" -o -name "*.old" \
        -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l || echo 0)
    
    if [[ $backup_files -gt 0 ]]; then
        add_finding "MEDIUM" "Found $backup_files backup files that might contain sensitive data" 5
    fi
}

# Generate recommendations
generate_recommendations() {
    local recommendations=()
    
    if [[ ${#CRITICAL_ISSUES[@]} -gt 0 ]]; then
        recommendations+=("URGENT: Address all critical security issues immediately")
        recommendations+=("Remove all hardcoded secrets and use environment variables")
        recommendations+=("Add sensitive files to .gitignore")
    fi
    
    if [[ ${#HIGH_ISSUES[@]} -gt 0 ]]; then
        recommendations+=("Update vulnerable dependencies")
        recommendations+=("Implement proper secret management")
        recommendations+=("Review and fix authentication implementations")
    fi
    
    if [[ $SECURITY_SCORE -lt 80 ]]; then
        recommendations+=("Implement automated security scanning in CI/CD")
        recommendations+=("Use tools like: npm audit, safety (Python), gosec (Go)")
        recommendations+=("Consider using pre-commit hooks for security checks")
        recommendations+=("Implement dependency update automation (Dependabot, Renovate)")
    fi
    
    recommendations+=("Regular security audits and penetration testing")
    recommendations+=("Security training for development team")
    
    printf '%s\n' "${recommendations[@]}"
}

# Output results
output_results() {
    case "$OUTPUT_FORMAT" in
        "json")
            cat <<EOF
{
  "security_score": $SECURITY_SCORE,
  "findings": {
    "critical": $(printf '%s\n' "${CRITICAL_ISSUES[@]}" | jq -R . | jq -s .),
    "high": $(printf '%s\n' "${HIGH_ISSUES[@]}" | jq -R . | jq -s .),
    "medium": $(printf '%s\n' "${MEDIUM_ISSUES[@]}" | jq -R . | jq -s .),
    "low": $(printf '%s\n' "${LOW_ISSUES[@]}" | jq -R . | jq -s .),
    "info": $(printf '%s\n' "${INFO_ITEMS[@]}" | jq -R . | jq -s .)
  },
  "summary": {
    "total_critical": ${#CRITICAL_ISSUES[@]},
    "total_high": ${#HIGH_ISSUES[@]},
    "total_medium": ${#MEDIUM_ISSUES[@]},
    "total_low": ${#LOW_ISSUES[@]}
  },
  "recommendations": $(generate_recommendations | jq -R . | jq -s .)
}
EOF
            ;;
        "human"|*)
            echo -e "${BLUE}🔒 SECURITY ASSESSMENT${NC}"
            echo "===================="
            echo ""
            
            # Score with color
            local score_color="$GREEN"
            [[ $SECURITY_SCORE -lt 80 ]] && score_color="$YELLOW"
            [[ $SECURITY_SCORE -lt 60 ]] && score_color="$RED"
            
            echo -e "Security Score: ${score_color}${SECURITY_SCORE}/100${NC}"
            echo ""
            
            # Summary
            echo -e "${CYAN}Summary:${NC}"
            echo "• Critical Issues: ${#CRITICAL_ISSUES[@]}"
            echo "• High Issues: ${#HIGH_ISSUES[@]}"
            echo "• Medium Issues: ${#MEDIUM_ISSUES[@]}"
            echo "• Low Issues: ${#LOW_ISSUES[@]}"
            echo ""
            
            # Critical findings
            if [[ ${#CRITICAL_ISSUES[@]} -gt 0 ]]; then
                echo -e "${RED}🚨 CRITICAL FINDINGS:${NC}"
                for issue in "${CRITICAL_ISSUES[@]}"; do
                    echo "  ⚠️  $issue"
                done
                echo ""
            fi
            
            # High findings
            if [[ ${#HIGH_ISSUES[@]} -gt 0 ]]; then
                echo -e "${RED}❗ HIGH SEVERITY:${NC}"
                for issue in "${HIGH_ISSUES[@]}"; do
                    echo "  • $issue"
                done
                echo ""
            fi
            
            # Medium findings
            if [[ ${#MEDIUM_ISSUES[@]} -gt 0 ]]; then
                echo -e "${YELLOW}⚠️  MEDIUM SEVERITY:${NC}"
                for issue in "${MEDIUM_ISSUES[@]}"; do
                    echo "  • $issue"
                done
                echo ""
            fi
            
            # Low findings
            if [[ ${#LOW_ISSUES[@]} -gt 0 ]]; then
                echo -e "${BLUE}ℹ️  LOW SEVERITY:${NC}"
                for issue in "${LOW_ISSUES[@]}"; do
                    echo "  • $issue"
                done
                echo ""
            fi
            
            # Info items
            if [[ ${#INFO_ITEMS[@]} -gt 0 ]]; then
                echo -e "${GREEN}📋 INFORMATIONAL:${NC}"
                for item in "${INFO_ITEMS[@]}"; do
                    echo "  • $item"
                done
                echo ""
            fi
            
            # Recommendations
            echo -e "${GREEN}💡 RECOMMENDATIONS:${NC}"
            generate_recommendations | while IFS= read -r rec; do
                echo "  • $rec"
            done
            echo ""
            ;;
    esac
}

# Main execution
main() {
    log_info "Starting security assessment for: $PROJECT_ROOT"
    
    if [[ ! -d "$PROJECT_ROOT" ]]; then
        echo "Error: Directory not found: $PROJECT_ROOT" >&2
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    
    # Run all security checks
    check_secrets
    check_env_files
    check_dependencies
    check_security_configs
    check_auth_patterns
    check_input_validation
    check_cicd_security
    check_file_security
    
    # Output results
    output_results
    
    # Exit with appropriate code
    if [[ ${#CRITICAL_ISSUES[@]} -gt 0 ]]; then
        exit 2  # Critical security issues
    elif [[ ${#HIGH_ISSUES[@]} -gt 0 ]]; then
        exit 1  # High security issues
    else
        exit 0  # Acceptable security
    fi
}

# Script usage
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [PROJECT_PATH] [OUTPUT_FORMAT]"
    echo ""
    echo "Comprehensive security assessment for projects"
    echo ""
    echo "Arguments:"
    echo "  PROJECT_PATH   Path to project (default: current directory)"
    echo "  OUTPUT_FORMAT  Output format: human, json (default: human)"
    echo ""
    echo "Environment:"
    echo "  VERBOSE=true   Enable verbose logging"
    exit 0
fi

# Run main function
main "$@"