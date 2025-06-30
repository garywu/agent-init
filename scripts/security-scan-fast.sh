#!/usr/bin/env bash
# Fast security scanner using ripgrep for maximum performance

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Counter for issues found
ISSUES_FOUND=0

echo "=== Fast Security Scan (ripgrep) ==="
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Check if ripgrep is available
if ! command -v rg &> /dev/null; then
    echo "Error: ripgrep (rg) not found. Please install it first."
    exit 1
fi

echo "Scanning repository: $(pwd)"
echo ""

# Function to scan and report
scan_pattern() {
    local pattern="$1"
    local severity="$2"
    local description="$3"
    local extra_args="${4:-}"
    
    if results=$(rg "$pattern" --glob '!.git/**' --glob '!node_modules/**' --glob '!*.log' -l $extra_args 2>/dev/null); then
        while IFS= read -r file; do
            echo -e "${severity}${NC} $description in: $file"
            ((ISSUES_FOUND++))
        done <<< "$results"
    fi
}

# Run all scans
echo "Checking for private keys..."
scan_pattern "BEGIN.*PRIVATE KEY" "${RED}[HIGH]" "Private key detected"

echo "Checking for SSH keys..."
scan_pattern "(ssh-rsa|ssh-ed25519|ecdsa-sha2)" "${RED}[HIGH]" "SSH key detected" "--glob '!*.pub'"

echo "Checking for API tokens..."
scan_pattern "(api[_-]?key|api[_-]?secret|access[_-]?token)[[:space:]]*[=:][[:space:]]*['\"]?[a-zA-Z0-9]{20,}" "${YELLOW}[WARN]" "API token pattern"

echo "Checking for AWS credentials..."
scan_pattern "(AKIA[0-9A-Z]{16}|aws[_-]?access[_-]?key[_-]?id|aws[_-]?secret[_-]?access[_-]?key)" "${RED}[HIGH]" "AWS credentials pattern"

echo "Checking for GitHub tokens..."
scan_pattern "(ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}|github[_-]?token)" "${RED}[HIGH]" "GitHub token pattern"

echo "Checking for Tailscale keys..."
scan_pattern "tskey-[a-zA-Z0-9]+" "${RED}[HIGH]" "Tailscale key"

echo "Checking for hardcoded passwords..."
# This one needs special handling to exclude common false positives
if results=$(rg "password[[:space:]]*[=:][[:space:]]*['\"]?[^'\"\n]{8,}" --glob '!.git/**' --glob '!node_modules/**' -l 2>/dev/null | rg -v "(example|change.*me|placeholder|dummy)"); then
    while IFS= read -r file; do
        [[ -n "$file" ]] && echo -e "${YELLOW}[WARN]${NC} Hardcoded password pattern in: $file" && ((ISSUES_FOUND++))
    done <<< "$results"
fi

echo "Checking for non-private IP addresses..."
# Exclude private IPs and common public IPs
if results=$(rg "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" --glob '!.git/**' --glob '!node_modules/**' -l 2>/dev/null); then
    while IFS= read -r file; do
        # Check if file contains non-private IPs
        if rg -q "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$file" | rg -v "(127\.0\.0\.|192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|0\.0\.0\.0|255\.255|8\.8\.8\.8|1\.1\.1\.1|localhost|example\.com)" 2>/dev/null; then
            echo -e "${YELLOW}[WARN]${NC} Public IP address in: $file"
            ((ISSUES_FOUND++))
        fi
    done <<< "$results"
fi

# Check for specific sensitive data from environment
echo "Checking for environment-specific sensitive data..."
if [[ -f .env.local ]]; then
    source .env.local
    
    # Check for Windows host IP if set
    if [[ -n "${WINDOWS_HOST_IP:-}" ]]; then
        scan_pattern "$WINDOWS_HOST_IP" "${RED}[HIGH]" "Windows host IP ($WINDOWS_HOST_IP)"
    fi
    
    # Check for Windows username if set
    if [[ -n "${WINDOWS_HOST_USER:-}" ]]; then
        scan_pattern "${WINDOWS_HOST_USER}@" "${RED}[HIGH]" "Windows username (${WINDOWS_HOST_USER})"
    fi
fi

echo ""
echo "=== Scan Summary ==="
if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}✓ No sensitive data found in current files${NC}"
else
    echo -e "${RED}✗ Found $ISSUES_FOUND potential security issues${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review the findings above"
    echo "2. Move sensitive data to .env files"
    echo "3. Run: ./scripts/auto-fix-sensitive.sh"
    echo "4. To clean git history: ./scripts/scrub-sensitive-data.sh"
fi

# Return non-zero if issues found
exit $((ISSUES_FOUND > 0 ? 1 : 0))