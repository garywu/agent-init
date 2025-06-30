# Security Scanning System

Agent-init includes a comprehensive security scanning system to prevent accidental commits of sensitive data like passwords, API keys, and private information.

## Quick Start

```bash
# Run from your repository root
./scripts/setup-security.sh
```

This will:
- Install Git hooks for pre-commit and pre-push checks
- Create configuration files for custom patterns
- Update .gitignore with security patterns
- Set up GitHub Actions workflow

## Features

### 🔒 Multi-Stage Protection

1. **Pre-commit Hook**: Scans staged files before commit
2. **Pre-push Hook**: Validates commit history before push
3. **Full Repository Scan**: Comprehensive security audit
4. **CI/CD Integration**: Automated scanning in GitHub Actions

### 🎯 Detects Common Secrets

- API keys and tokens
- AWS credentials
- GitHub personal access tokens
- SSH private keys
- Passwords in configuration files
- Email addresses
- IP addresses
- JWT tokens
- Database connection strings
- And more...

## Configuration

### Custom Patterns

Add project-specific patterns to `.security-patterns`:

```bash
# Custom API key pattern
SENSITIVE_PATTERNS["my_api"]='MY_API_KEY_[A-Z0-9]{32}'

# Custom token format
SENSITIVE_PATTERNS["app_token"]='app_token_[a-zA-Z0-9]{40}'
```

### Whitelisting

Add false positives to `.security-whitelist`:

```txt
# Safe domains
example.mycompany.com
staging.myapp.com

# Environment variable references
${MY_APP_*}
process.env.API_*

# Documentation examples
docs/examples/*
```

## Usage

### Manual Scanning

```bash
# Scan staged files (pre-commit)
./scripts/security-guard.sh pre-commit

# Scan commits before push
./scripts/security-guard.sh pre-push origin main

# Full repository scan
./scripts/security-guard.sh full-scan
```

### Bypassing Checks (Emergency Only)

```bash
# Skip pre-commit hook
git commit --no-verify -m "Emergency fix"

# Note: Pre-push hooks cannot be bypassed
```

## Best Practices

### 1. Use Environment Variables

Instead of hardcoding:
```bash
# ❌ Bad
API_KEY="sk_live_abcd1234"

# ✅ Good
API_KEY="${MY_API_KEY}"
```

### 2. Create .env.example Files

```bash
# .env.example
DATABASE_URL=postgresql://user:pass@localhost/dbname
API_KEY=your_api_key_here
SECRET_TOKEN=your_secret_here
```

### 3. Never Commit .env Files

The security system automatically adds these to .gitignore:
- `.env`
- `.env.*` (except .env.example)
- `*.key`
- `*.pem`
- `credentials.json`

## Troubleshooting

### False Positives

If the scanner blocks legitimate code:

1. Add the pattern to `.security-whitelist`
2. Use environment variable references
3. Modify the regex in `.security-patterns`

### Cleaning Git History

If secrets were already committed:

```bash
# Install BFG Repo-Cleaner
brew install bfg

# Remove secrets from history
bfg --replace-text passwords.txt
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### Custom Pattern Examples

```bash
# Slack tokens
SENSITIVE_PATTERNS["slack"]='xox[baprs]-[0-9a-zA-Z-]+'

# Stripe keys
SENSITIVE_PATTERNS["stripe"]='(sk|pk)_(test|live)_[0-9a-zA-Z]{24,}'

# Custom database URLs
SENSITIVE_PATTERNS["db_url"]='(mysql|postgres)://[^:]+:[^@]+@[^/]+/[^\\s]+'
```

## Integration with CI/CD

The included GitHub Actions workflow runs on:
- Every push to main branches
- All pull requests
- Weekly scheduled scans

To customize, edit `.github/workflows/security-scan.yml`.

## Advanced Usage

### Exclude Specific Files

```bash
# In your security-guard.sh call
EXCLUDE_PATHS="vendor/,node_modules/,test/fixtures/" ./scripts/security-guard.sh full-scan
```

### Integration with Other Tools

The security system works well with:
- [Gitleaks](https://github.com/gitleaks/gitleaks)
- [TruffleHog](https://github.com/trufflesecurity/trufflehog)
- [detect-secrets](https://github.com/Yelp/detect-secrets)

## Support

For issues or contributions:
1. Check existing patterns in `scripts/security-guard.sh`
2. Submit PRs with new pattern types
3. Report false positives as issues