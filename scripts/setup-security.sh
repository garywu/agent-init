#!/usr/bin/env bash
# Setup security scanning for any repository
# Part of agent-init - https://github.com/your-org/agent-init

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Agent-Init Security Setup ===${NC}"
echo ""

# Create security configuration files
create_security_patterns() {
    if [[ ! -f ".security-patterns" ]]; then
        cat > .security-patterns << 'EOF'
# Custom sensitive patterns for this repository
# Add patterns as: ["pattern_name"]='regex_pattern'

# Example custom patterns:
# SENSITIVE_PATTERNS["my_api"]='MY_API_KEY_[A-Z0-9]{32}'
# SENSITIVE_PATTERNS["custom_token"]='token_[a-zA-Z0-9]{40}'
EOF
        echo -e "${GREEN}✓ Created .security-patterns${NC}"
    fi
}

create_security_whitelist() {
    if [[ ! -f ".security-whitelist" ]]; then
        cat > .security-whitelist << 'EOF'
# Patterns to exclude from security scanning
# One pattern per line, regex supported

# Project-specific safe patterns
# my-safe-domain.com
# PROJECT_*
EOF
        echo -e "${GREEN}✓ Created .security-whitelist${NC}"
    fi
}

setup_git_hooks() {
    echo "Setting up Git hooks..."
    
    # Create hooks directory
    mkdir -p .git/hooks
    
    # Pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
# Security pre-commit hook

# Find the security guard script
if [[ -f "scripts/security-guard.sh" ]]; then
    GUARD_SCRIPT="scripts/security-guard.sh"
elif [[ -f "../scripts/security-guard.sh" ]]; then
    GUARD_SCRIPT="../scripts/security-guard.sh"
else
    echo "Warning: security-guard.sh not found"
    exit 0
fi

$GUARD_SCRIPT pre-commit
EOF
    
    # Pre-push hook
    cat > .git/hooks/pre-push << 'EOF'
#!/usr/bin/env bash
# Security pre-push hook

# Find the security guard script
if [[ -f "scripts/security-guard.sh" ]]; then
    GUARD_SCRIPT="scripts/security-guard.sh"
elif [[ -f "../scripts/security-guard.sh" ]]; then
    GUARD_SCRIPT="../scripts/security-guard.sh"
else
    echo "Warning: security-guard.sh not found"
    exit 0
fi

remote="$1"
url="$2"
$GUARD_SCRIPT pre-push "$remote" "$url"
EOF
    
    chmod +x .git/hooks/pre-commit .git/hooks/pre-push
    echo -e "${GREEN}✓ Git hooks installed${NC}"
}

update_gitignore() {
    echo "Updating .gitignore..."
    
    local patterns=(
        "# Security files"
        ".env"
        ".env.*"
        "!.env.example"
        "*.pem"
        "*.key"
        "*_rsa"
        "*_dsa"
        "*_ecdsa"
        "*_ed25519"
        "!*.pub"
        ".secrets*"
        "credentials.json"
        "*.pfx"
        "*.p12"
    )
    
    for pattern in "${patterns[@]}"; do
        if ! grep -Fxq "$pattern" .gitignore 2>/dev/null; then
            echo "$pattern" >> .gitignore
        fi
    done
    
    echo -e "${GREEN}✓ Updated .gitignore${NC}"
}

create_github_workflow() {
    mkdir -p .github/workflows
    
    if [[ ! -f ".github/workflows/security-scan.yml" ]]; then
        cat > .github/workflows/security-scan.yml << 'EOF'
name: Security Scan

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master ]
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Run Security Guard
      run: |
        chmod +x scripts/security-guard.sh
        scripts/security-guard.sh full-scan || true
    
    - name: Run Gitleaks
      uses: gitleaks/gitleaks-action@v2
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOF
        echo -e "${GREEN}✓ Created GitHub workflow${NC}"
    fi
}

# Main setup
echo "1. Creating configuration files..."
create_security_patterns
create_security_whitelist

echo ""
echo "2. Setting up Git hooks..."
setup_git_hooks

echo ""
echo "3. Updating .gitignore..."
update_gitignore

echo ""
echo "4. Creating GitHub workflow..."
create_github_workflow

# Make scripts executable
chmod +x scripts/security-guard.sh 2>/dev/null || true

echo ""
echo -e "${GREEN}=== Security Setup Complete! ===${NC}"
echo ""
echo "Next steps:"
echo "1. Review and customize .security-patterns"
echo "2. Add false positives to .security-whitelist"
echo "3. Run full scan: ./scripts/security-guard.sh full-scan"
echo "4. Commit the security configuration"
echo ""
echo -e "${YELLOW}Remember: Always use environment variables for sensitive data!${NC}"