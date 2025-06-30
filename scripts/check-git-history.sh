#!/usr/bin/env bash
# Check git history for sensitive data using git's built-in search

echo "[SCRIPT START] Running from: $(pwd)"

set -euo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "=== Git History Security Check ==="
echo ""

# Load environment to check for specific values
if [[ -f .env.local ]]; then
    source .env.local
fi

# Function to check for pattern in git history
check_history() {
    local pattern="$1"
    local description="$2"
    
    echo "Checking for $description..."
    
    # Use git log to find commits with the pattern
    if commits=$(git log --all -S"$pattern" --oneline 2>/dev/null); then
        if [[ -n "$commits" ]]; then
            echo -e "${RED}Found in commits:${NC}"
            echo "$commits"
            return 1
        fi
    fi
    
    return 0
}

FOUND_ISSUES=0

# Check for specific known sensitive data
echo "Checking for known sensitive data..."

# Check for the specific IP that was exposed
if check_history "100.107.60.12" "IP address 100.107.60.12"; then
    echo -e "${GREEN}✓ Not found${NC}"
else
    ((FOUND_ISSUES++))
fi

echo ""

# Check for the specific username that was exposed
if check_history "edgek@" "username edgek"; then
    echo -e "${GREEN}✓ Not found${NC}"
else
    ((FOUND_ISSUES++))
fi

echo ""

# Check for current environment values if they exist
if [[ -n "${WINDOWS_HOST_IP:-}" ]] && [[ "$WINDOWS_HOST_IP" != "10.0.0.2" ]]; then
    if check_history "$WINDOWS_HOST_IP" "current Windows host IP"; then
        echo -e "${GREEN}✓ Not found${NC}"
    else
        ((FOUND_ISSUES++))
    fi
    echo ""
fi

if [[ -n "${WINDOWS_HOST_USER:-}" ]] && [[ "$WINDOWS_HOST_USER" != "windows_user" ]]; then
    if check_history "${WINDOWS_HOST_USER}@" "current Windows username"; then
        echo -e "${GREEN}✓ Not found${NC}"
    else
        ((FOUND_ISSUES++))
    fi
    echo ""
fi

# Quick check for other patterns
echo "Quick scan for other sensitive patterns..."

# Tailscale keys
if git log --all -S"tskey-" --oneline | head -1 | grep -q .; then
    echo -e "${YELLOW}[WARN]${NC} Found Tailscale keys in history"
    ((FOUND_ISSUES++))
fi

# GitHub tokens
if git log --all -S"ghp_" --oneline | head -1 | grep -q .; then
    echo -e "${YELLOW}[WARN]${NC} Found GitHub tokens in history"
    ((FOUND_ISSUES++))
fi

echo ""
echo "=== Summary ==="

if [[ $FOUND_ISSUES -eq 0 ]]; then
    echo -e "${GREEN}✓ No sensitive data found in git history${NC}"
else
    echo -e "${RED}✗ Found $FOUND_ISSUES issues in git history${NC}"
    echo ""
    echo "To clean git history:"
    echo "1. Make a backup of your repository first!"
    echo "2. Run: ./scripts/scrub-sensitive-data.sh"
    echo ""
    echo "For GitHub issues:"
    echo "- Edit history is permanent on GitHub"
    echo "- Contact GitHub Support to remove sensitive data from issue history"
    echo "- Or delete and recreate the repository (loses stars/forks/issues)"
fi

exit $((FOUND_ISSUES > 0 ? 1 : 0))