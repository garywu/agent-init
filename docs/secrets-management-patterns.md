# Secrets Management Patterns

Comprehensive patterns for managing secrets, credentials, and sensitive configuration in development projects.

## Overview

Secrets management is critical for:
- API keys and tokens
- Database credentials
- Encryption keys
- Service account credentials
- Environment-specific configuration

## SOPS + age Pattern

### Why SOPS + age?

- **SOPS**: Encrypts values, not keys (readable structure)
- **age**: Modern, simple encryption without GPG complexity
- **Git-friendly**: Only values change when encrypted
- **Selective encryption**: Choose which values to encrypt

### Basic Setup

```bash
#!/usr/bin/env bash
# setup-secrets.sh

# Install tools
install_secrets_tools() {
    # macOS
    brew install sops age
    
    # Linux
    # Download from GitHub releases
    # Or use package manager
}

# Generate age key
setup_age_keys() {
    # Generate personal key
    age-keygen -o ~/.config/sops/age/keys.txt
    
    # Extract public key
    age-keygen -y ~/.config/sops/age/keys.txt > ~/.config/sops/age/public.txt
    
    echo "Public key for team sharing:"
    cat ~/.config/sops/age/public.txt
}

# Configure SOPS
setup_sops_config() {
    cat > .sops.yaml << 'EOF'
creation_rules:
  - path_regex: secrets/.*\.yaml$
    age: |
      age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p,
      age1another_team_member_public_key
      
  - path_regex: secrets/.*\.json$
    age: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
    
  - path_regex: .*\.env\.encrypted$
    age: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
EOF
}
```

### Environment-Specific Secrets

```bash
# Create environment secrets
create_env_secrets() {
    local env="$1"  # dev, staging, prod
    
    # Create secrets file
    cat > "secrets/${env}.yaml" << EOF
# ${env} environment secrets
api:
  key: "your-api-key-here"
  secret: "your-api-secret-here"
  
database:
  host: "${env}.db.example.com"
  username: "app_user"
  password: "strong-password-here"
  
services:
  redis:
    url: "redis://:password@${env}.redis.example.com:6379"
  s3:
    access_key: "AWS_ACCESS_KEY"
    secret_key: "AWS_SECRET_KEY"
    bucket: "myapp-${env}"
EOF
    
    # Encrypt the file
    sops -e -i "secrets/${env}.yaml"
}

# Decrypt for use
use_secrets() {
    local env="$1"
    
    # Decrypt to stdout
    sops -d "secrets/${env}.yaml"
    
    # Export as environment variables
    eval $(sops -d "secrets/${env}.yaml" | yq eval -o=shell)
}
```

### Integration with direnv

```bash
# .envrc
# Automatically load decrypted secrets

load_secrets() {
    local env="${APP_ENV:-development}"
    local secrets_file="secrets/${env}.yaml"
    
    if [[ -f "$secrets_file" ]]; then
        # Export each secret as env var
        eval $(sops -d "$secrets_file" | yq eval -o=shell)
    fi
}

# Load secrets if SOPS is available
if command -v sops &> /dev/null; then
    load_secrets
fi
```

## .env File Patterns

### Secure .env Management

```bash
# .env.template (checked into git)
API_KEY=your_api_key_here
API_SECRET=your_api_secret_here
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
REDIS_URL=redis://localhost:6379
SECRET_KEY=generate_a_secure_key_here

# .env.encrypted (checked into git)
# Encrypted version of actual .env file

# .env (git ignored)
# Actual secrets
```

### Encryption Workflow

```bash
#!/usr/bin/env bash
# env-crypt.sh

encrypt_env() {
    if [[ ! -f .env ]]; then
        echo "No .env file found"
        return 1
    fi
    
    # Encrypt .env to .env.encrypted
    sops -e .env > .env.encrypted
    echo "✅ Encrypted .env to .env.encrypted"
}

decrypt_env() {
    if [[ ! -f .env.encrypted ]]; then
        echo "No .env.encrypted file found"
        return 1
    fi
    
    # Decrypt .env.encrypted to .env
    sops -d .env.encrypted > .env
    echo "✅ Decrypted .env.encrypted to .env"
}

# Validate before committing
validate_no_secrets() {
    # Check that .env is not being committed
    if git diff --cached --name-only | grep -q '^.env$'; then
        echo "❌ ERROR: .env file staged for commit!"
        echo "Run: git reset HEAD .env"
        return 1
    fi
}
```

## Secret Rotation

### Automated Rotation Script

```bash
#!/usr/bin/env bash
# rotate-secrets.sh

rotate_api_keys() {
    local service="$1"
    local env="$2"
    
    echo "Rotating API keys for $service in $env..."
    
    # Decrypt current secrets
    local current=$(sops -d "secrets/${env}.yaml")
    
    # Generate new keys (service-specific)
    case "$service" in
        "stripe")
            # Use Stripe CLI to rotate
            new_key=$(stripe api_keys create --name "rotated-$(date +%Y%m%d)")
            ;;
        "github")
            # Use GitHub API to rotate
            new_key=$(gh api /user/keys --method POST --field title="rotated-$(date +%Y%m%d)" --field key="$(cat ~/.ssh/id_rsa.pub)")
            ;;
        *)
            # Generic rotation
            new_key=$(openssl rand -hex 32)
            ;;
    esac
    
    # Update secrets file
    echo "$current" | yq eval ".services.${service}.key = \"$new_key\"" - > "secrets/${env}.yaml.tmp"
    
    # Re-encrypt
    sops -e "secrets/${env}.yaml.tmp" > "secrets/${env}.yaml"
    rm "secrets/${env}.yaml.tmp"
    
    echo "✅ Rotated $service keys for $env"
}

# Schedule rotation
schedule_rotation() {
    cat > .github/workflows/rotate-secrets.yml << 'EOF'
name: Rotate Secrets
on:
  schedule:
    - cron: '0 0 1 * *'  # Monthly
  workflow_dispatch:

jobs:
  rotate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup SOPS
        run: |
          curl -LO https://github.com/getsops/sops/releases/latest/download/sops-linux
          chmod +x sops-linux
          sudo mv sops-linux /usr/local/bin/sops
      
      - name: Rotate Dev Secrets
        run: ./scripts/rotate-secrets.sh all dev
        env:
          SOPS_AGE_KEY: ${{ secrets.SOPS_AGE_KEY }}
EOF
}
```

## Team Collaboration

### Key Sharing Patterns

```bash
# Share public keys via git
mkdir -p .keys/team

# Each team member adds their public key
age-keygen -y ~/.config/sops/age/keys.txt > ".keys/team/$(git config user.email).pub"

# Update .sops.yaml with all team keys
update_team_keys() {
    local keys=()
    
    # Collect all public keys
    for keyfile in .keys/team/*.pub; do
        keys+=($(cat "$keyfile"))
    done
    
    # Update .sops.yaml
    yq eval ".creation_rules[0].age = \"${keys[*]}\"" -i .sops.yaml
}
```

### CI/CD Integration

```yaml
# GitHub Actions
- name: Setup SOPS
  run: |
    # Install SOPS
    curl -LO https://github.com/getsops/sops/releases/latest/download/sops-linux
    chmod +x sops-linux
    sudo mv sops-linux /usr/local/bin/sops
    
    # Setup age key from secrets
    mkdir -p ~/.config/sops/age
    echo "${{ secrets.SOPS_AGE_KEY }}" > ~/.config/sops/age/keys.txt

- name: Decrypt secrets
  run: |
    sops -d secrets/production.yaml > .env
    # Or export directly
    eval $(sops -d secrets/production.yaml | yq eval -o=shell)
```

## Alternative Patterns

### 1. Git-crypt

```bash
# Initialize git-crypt
git-crypt init

# Add users
git-crypt add-gpg-user user@example.com

# Specify files to encrypt
echo "secrets/* filter=git-crypt diff=git-crypt" >> .gitattributes
echo ".env filter=git-crypt diff=git-crypt" >> .gitattributes

# Lock/unlock
git-crypt lock
git-crypt unlock
```

### 2. Sealed Secrets (Kubernetes)

```yaml
# Create a sealed secret
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: mysecret
  namespace: default
spec:
  encryptedData:
    password: AgA...
```

### 3. Vault Integration

```bash
# Read from Vault
read_vault_secret() {
    vault kv get -format=json secret/myapp/prod | jq -r '.data.data'
}

# Write to Vault
write_vault_secret() {
    vault kv put secret/myapp/prod @secrets.json
}
```

## Best Practices

### 1. Secret Hygiene

```bash
# Pre-commit hook
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
```

### 2. Audit Trail

```bash
# Log secret access
log_secret_access() {
    local secret_name="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    echo "${timestamp} - ${USER} accessed ${secret_name}" >> .secret-access.log
}
```

### 3. Emergency Access

```bash
# Break-glass procedure
Create a separate emergency key that's:
1. Stored offline (printed, safe)
2. Has access to all secrets
3. Monitored for any use
4. Rotated after emergency use
```

## Common Pitfalls

1. **Committing decrypted files**
   - Always check `git status` before committing
   - Use pre-commit hooks

2. **Losing encryption keys**
   - Backup age keys securely
   - Use key escrow for teams

3. **Over-sharing secrets**
   - Use least privilege principle
   - Separate by environment and service

4. **Not rotating secrets**
   - Implement regular rotation
   - Automate where possible

## External References

- [SOPS Documentation](https://github.com/getsops/sops)
- [age Encryption](https://github.com/FiloSottile/age)
- [Git-crypt](https://github.com/AGWA/git-crypt)
- [Detect Secrets](https://github.com/Yelp/detect-secrets)