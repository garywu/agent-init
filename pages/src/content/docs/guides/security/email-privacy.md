---
title: Email Privacy Protection
description: Email Privacy Protection - Comprehensive guide from agent-init
sidebar:
  order: 10
---

# Email Privacy Protection Pattern

Protect your email privacy by preventing accidental exposure in git commits. This pattern helps maintain email privacy while contributing to open source projects.

## The Problem

- Personal email addresses exposed in git history
- Email harvesters scraping public repositories
- Spam and unwanted contact
- Professional email accidentally used in personal projects
- Work email exposed in public contributions

## Solution: Pre-commit Email Check

### Implementation

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit or .pre-commit-config.yaml hook

# Configuration
ALLOWED_EMAILS=(
    "*@users.noreply.github.com"
    "noreply@company.com"
)

BLOCKED_PATTERNS=(
    "*@gmail.com"
    "*@yahoo.com"
    "*@hotmail.com"
    "*@company-internal.com"
)

# Check current commit email
check_commit_email() {
    local email=$(git config user.email)
    
    # Check if email is in allowed list
    for allowed in "${ALLOWED_EMAILS[@]}"; do
        if [[ "$email" == $allowed ]]; then
            return 0
        fi
    done
    
    # Check against blocked patterns
    for blocked in "${BLOCKED_PATTERNS[@]}"; do
        if [[ "$email" == $blocked ]]; then
            echo "❌ Blocked email detected: $email"
            echo "💡 Use your GitHub noreply email instead:"
            echo "   $(git config user.name | tr ' ' '-')-$(git config user.githubuser)@users.noreply.github.com"
            return 1
        fi
    done
}

# Check staged files for email patterns
check_staged_files() {
    local email_pattern='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    
    # Get staged files
    local files=$(git diff --cached --name-only --diff-filter=ACM)
    
    for file in $files; do
        if git show ":$file" | grep -E "$email_pattern" | grep -vE "noreply|example\.com"; then
            echo "⚠️  Possible email exposure in $file"
            echo "💡 Consider using noreply or example emails"
            return 1
        fi
    done
}
```

### GitHub Noreply Email Setup

```bash
# Get your GitHub noreply email
get_github_noreply() {
    local username="$1"
    local userid="$2"  # Found in GitHub settings
    
    echo "${userid}+${username}@users.noreply.github.com"
}

# Configure git to use noreply email
setup_noreply_email() {
    local noreply="12345678+yourusername@users.noreply.github.com"
    
    # Global config (for all repos)
    git config --global user.email "$noreply"
    
    # Or per-repository
    git config user.email "$noreply"
}
```

## Advanced Patterns

### 1. Per-Directory Email Configuration

```bash
# Using direnv (.envrc)
export GIT_AUTHOR_EMAIL="work@company.com"
export GIT_COMMITTER_EMAIL="work@company.com"

# Or git conditional includes
# ~/.gitconfig
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work
[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

### 2. Email Rotation for Privacy

```bash
# Generate project-specific emails
generate_project_email() {
    local project_name="$1"
    local hash=$(echo -n "$project_name" | sha256sum | cut -c1-8)
    
    echo "project-${hash}@users.noreply.github.com"
}
```

### 3. CI/CD Email Protection

```yaml
# GitHub Actions
- name: Configure Git
  run: |
    git config --global user.email "action@github.com"
    git config --global user.name "GitHub Action"

# GitLab CI
before_script:
  - git config --global user.email "gitlab-ci@example.com"
  - git config --global user.name "GitLab CI"
```

## Integration Options

### 1. Pre-commit Framework

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: check-email-privacy
        name: Check email privacy
        entry: scripts/check-email-privacy.sh
        language: script
        stages: [commit]
```

### 2. Git Hook Installation

```bash
# install-hooks.sh
#!/usr/bin/env bash

INSTALL_EMAIL_CHECK() {
    cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
# Email privacy check

email=$(git config user.email)
if [[ "$email" == *"@gmail.com"* ]] || [[ "$email" == *"@company.com"* ]]; then
    echo "❌ Personal/work email detected!"
    echo "💡 Use: git config user.email 'username@users.noreply.github.com'"
    exit 1
fi
EOF
    chmod +x .git/hooks/pre-commit
}
```

### 3. Makefile Integration

```makefile
# Email privacy setup
.PHONY: setup-privacy
setup-privacy:
	@echo "Setting up email privacy..."
	@./scripts/setup-email-privacy.sh

.PHONY: check-email
check-email:
	@echo "Current email: $$(git config user.email)"
	@./scripts/check-email-privacy.sh
```

## Best Practices

### 1. Organization-Wide Policy

```bash
# Organization email policy
ORG_EMAIL_POLICY={
    "allowed_domains": ["users.noreply.github.com", "company-oss.com"],
    "blocked_domains": ["company-internal.com", "personal-domain.com"],
    "require_noreply": true,
    "exceptions": ["security@company.com"]
}
```

### 2. Documentation Template

```markdown
# Contributing

## Email Privacy

To protect your privacy:

1. Use GitHub's noreply email:
   ```bash
   git config user.email "YOUR_GITHUB_ID+USERNAME@users.noreply.github.com"
   ```

2. Or use our project email:
   ```bash
   git config user.email "contrib@project.org"
   ```

3. Never use personal/work emails in commits
```

### 3. Multiple Identity Management

```bash
# git-identity script
#!/usr/bin/env bash

case "$1" in
    work)
        git config user.email "work-noreply@company.com"
        git config user.name "Work Name"
        ;;
    oss)
        git config user.email "12345+username@users.noreply.github.com"
        git config user.name "OSS Name"
        ;;
    personal)
        git config user.email "personal@users.noreply.github.com"
        git config user.name "Personal Name"
        ;;
    *)
        echo "Usage: git-identity [work|oss|personal]"
        exit 1
        ;;
esac
```

## Troubleshooting

### Common Issues

1. **Already committed with personal email**
   ```bash
   # Rewrite history (DANGEROUS - only for unpushed commits)
   git filter-branch --env-filter '
   OLD_EMAIL="personal@gmail.com"
   NEW_EMAIL="noreply@users.noreply.github.com"
   if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]; then
       export GIT_COMMITTER_EMAIL="$NEW_EMAIL"
   fi
   if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]; then
       export GIT_AUTHOR_EMAIL="$NEW_EMAIL"
   fi
   ' --tag-name-filter cat -- --branches --tags
   ```

2. **GitHub not recognizing commits**
   - Add noreply email to GitHub account settings
   - Use the exact format GitHub provides

3. **CI commits failing**
   - Configure CI with appropriate bot email
   - Use service-specific emails (e.g., `actions@github.com`)

## External References

- [GitHub: Setting your commit email](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address)
- [Git: Multiple Email Addresses](https://git-scm.com/docs/git-config#_conditional_includes)
- [Pre-commit: Custom Hooks](https://pre-commit.com/#new-hooks)