#!/usr/bin/env bash
# Automatically fix sensitive data in staged files

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔧 Auto-fixing sensitive data in staged files..."
echo ""

# Load environment if available
if [[ -f .env.local ]]; then
    set -a
    source .env.local
    set +a
fi

# Get staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [[ -z "$STAGED_FILES" ]]; then
    echo "No staged files to check."
    exit 0
fi

FIXED_COUNT=0

# Build replacements from environment
declare -A REPLACEMENTS=()

# Add specific values from environment if they exist
if [[ -n "${WINDOWS_HOST_IP:-}" ]]; then
    # Escape dots for regex
    escaped_ip="${WINDOWS_HOST_IP//./\\.}"
    REPLACEMENTS["$escaped_ip"]="\${WINDOWS_HOST_IP}"
fi

if [[ -n "${WINDOWS_HOST_USER:-}" ]]; then
    REPLACEMENTS["${WINDOWS_HOST_USER}"]='${WINDOWS_HOST_USER}'

    if [[ -n "${WINDOWS_HOST_IP:-}" ]]; then
        # User@IP pattern
        REPLACEMENTS["${WINDOWS_HOST_USER}@${WINDOWS_HOST_IP//./\\.}"]='${WINDOWS_HOST}'
    fi
fi

# Generic patterns
REPLACEMENTS+=(
    # Any other IP addresses
    ['([0-9]{1,3}\.){3}[0-9]{1,3}']='${SOME_IP}'

    # Any other username@IP patterns
    ['[a-zA-Z0-9_-]+@[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}']='${SOME_HOST}'
)

# Process each staged file
while IFS= read -r file; do
    if [[ ! -f "$file" ]]; then
        continue
    fi

    # Skip binary files
    if file "$file" | grep -q "binary"; then
        continue
    fi

    # Skip certain file types
    if [[ "$file" =~ \.(jpg|jpeg|png|gif|ico|pdf|zip|tar|gz|exe|dll)$ ]]; then
        continue
    fi

    # Skip documentation that might have example IPs
    if [[ "$file" =~ (README|CHANGELOG|\.md$) ]]; then
        continue
    fi

    FILE_MODIFIED=false

    # Apply replacements
    for pattern in "${!REPLACEMENTS[@]}"; do
        replacement="${REPLACEMENTS[$pattern]}"

        # Check if pattern exists (excluding safe IPs)
        if grep -E "$pattern" "$file" 2>/dev/null | grep -v "127.0.0.1\|0.0.0.0\|localhost\|192.168\|10.0\|172.16" | grep -q .; then
            echo "Fixing $file: replacing sensitive pattern"

            # Create backup
            cp "$file" "$file.bak"

            # Perform replacement (platform-specific sed)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                sed -i '' -E "s/$pattern/$replacement/g" "$file"
            else
                # Linux
                sed -i -E "s/$pattern/$replacement/g" "$file"
            fi

            # Remove backup if successful
            rm -f "$file.bak"

            FILE_MODIFIED=true
            ((FIXED_COUNT++))
        fi
    done

    # Re-stage the file if it was modified
    if [[ "$FILE_MODIFIED" == true ]]; then
        git add "$file"
        echo -e "${GREEN}✓ Fixed and re-staged: $file${NC}"
    fi
done <<< "$STAGED_FILES"

# Summary
echo ""
if [[ $FIXED_COUNT -gt 0 ]]; then
    echo -e "${GREEN}✓ Fixed $FIXED_COUNT files${NC}"
    echo ""
    echo "Changes made:"
    echo "- Replaced IP addresses with \${WINDOWS_HOST_IP}"
    echo "- Replaced user@host with \${WINDOWS_HOST}"
    echo ""
    echo -e "${YELLOW}Important:${NC}"
    echo "1. Review the changes: git diff --cached"
    echo "2. Ensure .env.local is configured"
    echo "3. Commit when ready"
else
    echo -e "${GREEN}✓ No sensitive data found to fix${NC}"
fi

# Run security check again
echo ""
echo "Running security check..."
./scripts/security-guard.sh pre-commit || {
    echo ""
    echo -e "${RED}Security check still failing!${NC}"
    echo "Please fix remaining issues manually."
    exit 1
}

echo ""
echo -e "${GREEN}✓ All security checks passed!${NC}"
