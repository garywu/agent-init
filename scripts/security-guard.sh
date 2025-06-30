#!/usr/bin/env bash
# Multi-stage security guard - runs automatically at different stages

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Stage of execution
STAGE="${1:-pre-commit}"

# Sensitive patterns to check
declare -A SENSITIVE_PATTERNS=(
    ["ip_address"]='([0-9]{1,3}\.){3}[0-9]{1,3}'
    ["tailscale_key"]='tskey-[a-zA-Z0-9]+'
    ["github_token"]='gh[ps]_[a-zA-Z0-9]{36}'
    ["github_pat"]='github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}'
    ["aws_key"]='AKIA[0-9A-Z]{16}'
    ["private_key"]='-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----'
    ["api_key"]='(api[_-]?key|apikey|api_secret)[[:space:]]*[=:][[:space:]]*["\047]?[a-zA-Z0-9_-]{20,}'
    ["email"]='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    ["username_at"]='[a-zA-Z0-9_-]+@[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
)

# Whitelisted patterns (safe to commit)
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
    "\$WINDOWS_HOST"
    "\${WINDOWS_HOST}"
    "YOUR_"
    "<your"
    "REPLACE_ME"
    "changeme"
    "placeholder"
)

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

# Stage 1: Pre-commit check (fast, only staged files)
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
        if [[ ! -f "$file" ]]; then
            continue
        fi

        # Skip binary files
        if file "$file" | grep -q "binary"; then
            continue
        fi

        # Skip specific file types
        if [[ "$file" =~ \.(jpg|jpeg|png|gif|ico|pdf|zip|tar|gz|exe|dll)$ ]]; then
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
        echo "Options:"
        echo "1. Fix the issues manually"
        echo "2. Run: ./scripts/auto-fix-sensitive.sh"
        echo "3. Use environment variables (see .env.example)"
        echo ""
        echo "To bypass (NOT RECOMMENDED):"
        echo "  git commit --no-verify"
        exit 1
    else
        echo -e "${GREEN}✓ No security issues found${NC}"
    fi
}

# Stage 2: Pre-push check (thorough, all commits being pushed)
stage_prepush() {
    echo "🔒 Security Guard - Pre-push Stage"
    echo ""

    local remote="$1"
    local url="$2"

    # Get the commits being pushed
    while read -r local_ref local_sha remote_ref remote_sha; do
        if [[ "$local_sha" = "0000000000000000000000000000000000000000" ]]; then
            # Delete ref, skip
            continue
        fi

        # Check all files in commits being pushed
        local commits
        if [[ "$remote_sha" = "0000000000000000000000000000000000000000" ]]; then
            # New branch, check all commits
            commits=$(git rev-list "$local_sha" --not --remotes)
        else
            # Existing branch, check new commits
            commits=$(git rev-list "$remote_sha..$local_sha")
        fi

        local issues=0
        while IFS= read -r commit; do
            # Check commit message
            local msg
            msg=$(git log -1 --pretty=%B "$commit")

            for pattern_name in "${!SENSITIVE_PATTERNS[@]}"; do
                pattern="${SENSITIVE_PATTERNS[$pattern_name]}"
                if echo "$msg" | grep -E "$pattern" | grep -q . && ! is_whitelisted "$msg"; then
                    echo -e "${RED}[BLOCKED]${NC} $pattern_name in commit message: $commit"
                    ((issues++))
                fi
            done

            # Check files in commit
            local files
            files=$(git diff-tree --no-commit-id --name-only -r "$commit")

            while IFS= read -r file; do
                local content
                content=$(git show "$commit:$file" 2>/dev/null || true)

                for pattern_name in "${!SENSITIVE_PATTERNS[@]}"; do
                    pattern="${SENSITIVE_PATTERNS[$pattern_name]}"
                    if echo "$content" | grep -E "$pattern" | grep -q .; then
                        local matches
                        matches=$(echo "$content" | grep -E "$pattern")
                        if ! is_whitelisted "$matches"; then
                            echo -e "${RED}[BLOCKED]${NC} $pattern_name in $file (commit: ${commit:0:7})"
                            ((issues++))
                        fi
                    fi
                done
            done <<< "$files"
        done <<< "$commits"

        if [[ $issues -gt 0 ]]; then
            echo ""
            echo -e "${RED}✗ Found $issues security issues in commits${NC}"
            echo ""
            echo "You need to clean the history before pushing!"
            echo "Run: ./scripts/clean-git-history.sh"
            exit 1
        fi
    done
}

# Stage 3: Continuous monitoring (for CI/CD)
stage_continuous() {
    echo "🔒 Security Guard - Continuous Monitoring"
    echo ""

    # Full repository scan (using fast ripgrep version)
    ./scripts/security-scan-fast.sh

    # Check for exposed secrets in git history
    if command -v gitleaks &> /dev/null; then
        echo "Running gitleaks scan on git history..."
        # Run gitleaks on git history (not working tree)
        if ! gitleaks detect --log-opts="--all" --exit-code=1 --verbose=false; then
            echo -e "${RED}Gitleaks found exposed secrets in git history!${NC}"
            echo "Run: gitleaks detect --log-opts=\"--all\" --verbose for details"
            exit 1
        fi
        echo -e "${GREEN}✓ Gitleaks scan passed${NC}"
    fi
}

# Stage 4: GitHub Actions check
stage_github_actions() {
    echo "🔒 Security Guard - GitHub Actions"
    echo ""

    # This would run in CI/CD
    # Check PR for sensitive data
    stage_continuous
}

# Execute appropriate stage
case "$STAGE" in
    "pre-commit")
        stage_precommit
        ;;
    "pre-push")
        stage_prepush "$@"
        ;;
    "continuous")
        stage_continuous
        ;;
    "github")
        stage_github_actions
        ;;
    *)
        echo "Unknown stage: $STAGE"
        echo "Valid stages: pre-commit, pre-push, continuous, github"
        exit 1
        ;;
esac
