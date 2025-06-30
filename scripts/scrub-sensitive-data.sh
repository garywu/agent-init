#!/usr/bin/env bash
# Comprehensive script to remove sensitive data from repository and history

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "=== Sensitive Data Scrubbing Tool ==="
echo ""
echo -e "${YELLOW}WARNING: This will rewrite git history!${NC}"
echo "Make sure you have a backup before proceeding."
echo ""
read -r -p "Continue? (yes/no): " response
if [[ "$response" != "yes" ]]; then
    echo "Aborted."
    exit 0
fi

# Load environment to get actual sensitive values
if [[ -f .env.local ]]; then
    source .env.local
fi

# Build patterns from environment
SENSITIVE_PATTERNS=()

# Add patterns from environment if they exist
[[ -n "${WINDOWS_HOST_IP:-}" ]] && SENSITIVE_PATTERNS+=("$WINDOWS_HOST_IP")
[[ -n "${WINDOWS_HOST_USER:-}" ]] && SENSITIVE_PATTERNS+=("${WINDOWS_HOST_USER}@")
[[ -n "${WINDOWS_HOST:-}" ]] && SENSITIVE_PATTERNS+=("$WINDOWS_HOST")

# Add generic patterns
SENSITIVE_PATTERNS+=(
    "tskey-"             # Tailscale keys
    "ghp_"               # GitHub tokens
    "gho_"               # GitHub OAuth tokens
    "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"  # IP addresses
)

# Step 1: Find files with sensitive data
echo ""
echo "Step 1: Scanning current files for sensitive data..."
AFFECTED_FILES=()

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    while IFS= read -r file; do
        if grep -E "$pattern" "$file" 2>/dev/null | grep -q .; then
            AFFECTED_FILES+=("$file")
            echo -e "${RED}Found sensitive data in:${NC} $file"
        fi
    done < <(git ls-files)
done

# Remove duplicates
AFFECTED_FILES=($(printf "%s\n" "${AFFECTED_FILES[@]}" | sort -u))

if [[ ${#AFFECTED_FILES[@]} -eq 0 ]]; then
    echo -e "${GREEN}No sensitive data found in current files.${NC}"
else
    echo ""
    echo "Step 2: Fixing current files..."

    # Create placeholder values
    for file in "${AFFECTED_FILES[@]}"; do
        echo "Fixing: $file"

        # Replace specific patterns
        # Replace with environment variable references
        if [[ -n "${WINDOWS_HOST_IP:-}" ]]; then
            sed -i.bak "s/${WINDOWS_HOST_IP//./\\.}/\$WINDOWS_HOST_IP/g" "$file"
        fi
        if [[ -n "${WINDOWS_HOST_USER:-}" ]]; then
            sed -i.bak "s/${WINDOWS_HOST_USER}@/\$WINDOWS_HOST_USER@/g" "$file"
        fi
        if [[ -n "${WINDOWS_HOST:-}" ]]; then
            sed -i.bak "s/${WINDOWS_HOST//./\\.}/\$WINDOWS_HOST/g" "$file"
        fi

        # Remove backup
        rm -f "${file}.bak"
    done

    echo -e "${GREEN}Files updated with placeholders.${NC}"
fi

# Step 3: Check git history
echo ""
echo "Step 3: Checking git history for sensitive data..."

# Create a list of commits with sensitive data
COMMITS_WITH_SENSITIVE=()
for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    while IFS= read -r commit; do
        if [[ -n "$commit" ]]; then
            COMMITS_WITH_SENSITIVE+=("$commit")
        fi
    done < <(git log --all --grep="$pattern" --pretty=format:"%H" 2>/dev/null || true)
done

# Also check file contents in history
for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    while IFS= read -r result; do
        if [[ -n "$result" ]]; then
            commit=$(echo "$result" | cut -d: -f1)
            COMMITS_WITH_SENSITIVE+=("$commit")
        fi
    done < <(git grep -E "$pattern" $(git rev-list --all) 2>/dev/null || true)
done

# Remove duplicates
COMMITS_WITH_SENSITIVE=($(printf "%s\n" "${COMMITS_WITH_SENSITIVE[@]}" | sort -u))

if [[ ${#COMMITS_WITH_SENSITIVE[@]} -gt 0 ]]; then
    echo -e "${RED}Found ${#COMMITS_WITH_SENSITIVE[@]} commits with sensitive data${NC}"
    echo ""
    echo "Options to clean history:"
    echo "1. Use BFG Repo-Cleaner (recommended)"
    echo "2. Use git filter-branch (slower)"
    echo "3. Manual review"
    echo ""

    # Create BFG commands
    cat > bfg-clean-commands.txt << EOF
# BFG Repo-Cleaner Commands
# Install: brew install bfg

# Replace sensitive text
bfg --replace-text sensitive-strings.txt

# After BFG, run:
git reflog expire --expire=now --all && git gc --prune=now --aggressive
EOF

    # Create sensitive strings file for BFG
    cat > sensitive-strings.txt << EOF
# Environment-based replacements
EOF

    # Add actual values from environment
    [[ -n "${WINDOWS_HOST_IP:-}" ]] && echo "${WINDOWS_HOST_IP}==>REDACTED_IP" >> sensitive-strings.txt
    [[ -n "${WINDOWS_HOST_USER:-}" ]] && echo "${WINDOWS_HOST_USER}==>REDACTED_USER" >> sensitive-strings.txt
    [[ -n "${WINDOWS_HOST:-}" ]] && echo "${WINDOWS_HOST}==>REDACTED_HOST" >> sensitive-strings.txt

    echo "Created: bfg-clean-commands.txt and sensitive-strings.txt"
else
    echo -e "${GREEN}No sensitive data found in git history.${NC}"
fi

# Step 4: Check GitHub issues
echo ""
echo "Step 4: GitHub Issues Check"
echo ""
echo "Please manually review GitHub issues for sensitive data:"
echo "1. Go to: https://github.com/yourusername/yourrepo/issues"
echo "2. Search for: IP addresses, usernames, keys"
echo "3. Edit any issues containing sensitive data"
echo ""

# Step 5: Create gitignore entries
echo "Step 5: Updating .gitignore..."
GITIGNORE_ENTRIES=(
    ".env.local"
    ".env"
    "*.pem"
    "*.key"
    "*_rsa"
    "*_dsa"
    "*_ecdsa"
    "*_ed25519"
    "!*.pub"
    ".secrets*"
    "credentials.json"
    "sensitive-strings.txt"
    "bfg-clean-commands.txt"
)

for entry in "${GITIGNORE_ENTRIES[@]}"; do
    if ! grep -q "^${entry}$" .gitignore 2>/dev/null; then
        echo "$entry" >> .gitignore
    fi
done

echo -e "${GREEN}✓ Updated .gitignore${NC}"

# Summary
echo ""
echo "=== Summary ==="
echo ""
if [[ ${#AFFECTED_FILES[@]} -gt 0 ]]; then
    echo "1. Fixed ${#AFFECTED_FILES[@]} files with sensitive data"
    echo "2. Commit these changes: git add -A && git commit -m 'fix: remove sensitive data'"
fi

if [[ ${#COMMITS_WITH_SENSITIVE[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}IMPORTANT: Git history contains sensitive data!${NC}"
    echo "Follow the instructions in bfg-clean-commands.txt to clean history"
    echo ""
    echo "After cleaning history:"
    echo "1. Force push: git push --force-with-lease"
    echo "2. Notify all collaborators to re-clone"
    echo "3. Rotate any exposed credentials"
fi

echo ""
echo "Remember to:"
echo "- Use .env.local for sensitive configuration"
echo "- Never commit .env.local"
echo "- Review GitHub issues manually"
