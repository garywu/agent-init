#!/usr/bin/env bash
# Multi-stage security guard for any repository
# Part of agent-init - https://github.com/your-org/agent-init

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Stage of execution
STAGE="${1:-pre-commit}"

# Load custom patterns if available
CUSTOM_PATTERNS_FILE=".security-patterns"
if [[ -f "$CUSTOM_PATTERNS_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CUSTOM_PATTERNS_FILE"
fi

# Default sensitive patterns
declare -A SENSITIVE_PATTERNS
SENSITIVE_PATTERNS+=(
    ["ip_address"]='([0-9]{1,3}\.){3}[0-9]{1,3}'
    ["tailscale_key"]='tskey-[a-zA-Z0-9]+'
    ["github_token"]='gh[ps]_[a-zA-Z0-9]{36}'
    ["github_pat"]='github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}'
    ["aws_key"]='AKIA[0-9A-Z]{16}'
    ["aws_secret"]='[a-zA-Z0-9/+=]{40}'
    ["private_key"]='-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----'
    ["api_key"]='(api[_-]?key|apikey|api_secret)[[:space:]]*[=:][[:space:]]*["\047]?[a-zA-Z0-9_-]{20,}'
    ["jwt_token"]='eyJ[a-zA-Z0-9_-]+\.eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+'
    ["email"]='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    ["password_field"]='(password|passwd|pwd)[[:space:]]*[=:][[:space:]]*["\047]?[^"\047\s]+'
    ["slack_token"]='xox[baprs]-[0-9a-zA-Z]+'
    ["stripe_key"]='(sk|pk)_(test|live)_[0-9a-zA-Z]{24,}'
    ["ssh_host"]='[a-zA-Z0-9_-]+@[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
)

# Default whitelisted patterns
WHITELIST_PATTERNS=(
    "127.0.0.1"
    "0.0.0.0"
    "localhost"
    "192.168.*"
    "10.0.*"
    "172.16.*"
    "example.com"
    "test.com"
    "no-reply@"
    "noreply@"
    "YOUR_"
    "<your"
    "REPLACE_ME"
    "changeme"
    "placeholder"
    "TODO"
    "FIXME"
    "\${.*}"
    "\$ENV"
    "process.env"
)

# Load custom whitelist if available
if [[ -f ".security-whitelist" ]]; then
    while IFS= read -r pattern; do
        [[ -n "$pattern" && ! "$pattern" =~ ^# ]] && WHITELIST_PATTERNS+=("$pattern")
    done < ".security-whitelist"
fi

# Check if pattern is whitelisted
is_whitelisted() {
    local line="$1"
    for whitelist in "${WHITELIST_PATTERNS[@]}"; do
        if echo "$line" | grep -q "$whitelist"; then
            return 0
        fi
    done
    return 1
}

# Stage 1: Pre-commit check
stage_precommit() {
    echo "🔒 Security Guard - Pre-commit Stage"
    echo ""
    
    local issues=0
    local staged_files
    staged_files=$(git diff --cached --name-only --diff-filter=ACM)
    
    if [[ -z "$staged_files" ]]; then
        exit 0
    fi
    
    while IFS= read -r file; do
        [[ ! -f "$file" ]] && continue
        
        # Skip binary and irrelevant files
        if file "$file" | grep -q "binary" || [[ "$file" =~ \.(jpg|jpeg|png|gif|ico|pdf|zip|tar|gz)$ ]]; then
            continue
        fi
        
        # Check each pattern
        for pattern_name in "${!SENSITIVE_PATTERNS[@]}"; do
            pattern="${SENSITIVE_PATTERNS[$pattern_name]}"
            
            while IFS= read -r line_match; do
                if ! is_whitelisted "$line_match"; then
                    echo -e "${RED}[BLOCKED]${NC} $pattern_name found in $file"
                    echo "  Line: $line_match"
                    ((issues++))
                fi
            done < <(grep -E "$pattern" "$file" 2>/dev/null || true)
        done
    done <<< "$staged_files"
    
    if [[ $issues -gt 0 ]]; then
        echo ""
        echo -e "${RED}✗ Found $issues security issues${NC}"
        echo ""
        echo "To fix:"
        echo "1. Replace with environment variables"
        echo "2. Add to .security-whitelist if false positive"
        echo "3. Run auto-fix if available"
        exit 1
    else
        echo -e "${GREEN}✓ No security issues found${NC}"
    fi
}

# Stage 2: Pre-push check
stage_prepush() {
    echo "🔒 Security Guard - Pre-push Stage"
    echo ""
    
    local remote="$1"
    local url="$2"
    local issues=0
    
    while read -r local_ref local_sha remote_ref remote_sha; do
        [[ "$local_sha" = "0000000000000000000000000000000000000000" ]] && continue
        
        local commits
        if [[ "$remote_sha" = "0000000000000000000000000000000000000000" ]]; then
            commits=$(git rev-list "$local_sha" --not --remotes)
        else
            commits=$(git rev-list "$remote_sha..$local_sha")
        fi
        
        while IFS= read -r commit; do
            # Check commit message
            local msg
            msg=$(git log -1 --pretty=%B "$commit")
            
            for pattern_name in "${!SENSITIVE_PATTERNS[@]}"; do
                if echo "$msg" | grep -E "${SENSITIVE_PATTERNS[$pattern_name]}" | grep -q . && ! is_whitelisted "$msg"; then
                    echo -e "${RED}[BLOCKED]${NC} $pattern_name in commit message: $commit"
                    ((issues++))
                fi
            done
        done <<< "$commits"
    done
    
    [[ $issues -gt 0 ]] && exit 1
}

# Stage 3: Full repository scan
stage_full_scan() {
    echo "🔒 Security Guard - Full Repository Scan"
    echo ""
    
    local issues=0
    
    while IFS= read -r file; do
        [[ ! -f "$file" ]] && continue
        
        for pattern_name in "${!SENSITIVE_PATTERNS[@]}"; do
            pattern="${SENSITIVE_PATTERNS[$pattern_name]}"
            
            if grep -E "$pattern" "$file" 2>/dev/null | grep -v -E "$(IFS='|'; echo "${WHITELIST_PATTERNS[*]}")" | grep -q .; then
                echo -e "${YELLOW}[WARNING]${NC} $pattern_name found in $file"
                ((issues++))
            fi
        done
    done < <(git ls-files)
    
    echo ""
    echo "Total issues: $issues"
}

# Execute appropriate stage
case "$STAGE" in
    "pre-commit") stage_precommit ;;
    "pre-push") stage_prepush "$@" ;;
    "full-scan") stage_full_scan ;;
    *) echo "Usage: $0 [pre-commit|pre-push|full-scan]"; exit 1 ;;
esac