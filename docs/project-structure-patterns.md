# Project Structure and Organization Patterns

This guide documents proven patterns for organizing projects, configuration files, and development artifacts.

## Directory Structure Philosophy

### Separation of Concerns

Based on real experience managing dotfiles and development projects:

```
project/
├── src/                    # Source code
├── tests/                  # Test files, mirroring src/ structure
├── docs/                   # Documentation
├── scripts/                # Development and utility scripts
│   ├── setup/             # Installation/setup scripts
│   ├── ci/                # CI-specific scripts
│   └── utils/             # General utilities
├── config/                 # Configuration files
│   ├── dev/               # Development configs
│   ├── test/              # Test configs
│   └── prod/              # Production configs
├── external/               # Git submodules and external dependencies
├── .github/                # GitHub-specific files
└── .vscode/                # IDE configurations (gitignored by default)
```

### Key Principles

1. **Predictable locations** - Developers should know where to find things
2. **Separation by purpose** - Don't mix source, tests, and configs
3. **Environment isolation** - Separate dev/test/prod configurations
4. **External dependencies** - Clear boundary for third-party code

## Configuration File Organization

### The .gitignore Strategy

Organize .gitignore by category for maintainability:

```gitignore
# === Operating System ===
## macOS
.DS_Store
.AppleDouble
.LSOverride
._*

## Windows
Thumbs.db
ehthumbs.db
Desktop.ini

## Linux
*~
.directory

# === Languages and Frameworks ===
## Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv
pip-log.txt
.pytest_cache/
.coverage
htmlcov/
.mypy_cache/
.ruff_cache/

## Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
.yarn-integrity
.next/
out/
dist/

## Rust
target/
Cargo.lock
**/*.rs.bk

# === IDEs and Editors ===
## Visual Studio Code
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

## JetBrains
.idea/
*.iml
*.iws
*.ipr

# === Build Artifacts ===
build/
dist/
out/
*.egg-info/

# === Environment and Secrets ===
.env
.env.*
!.env.example
secrets/
*.key
*.pem

# === Project Specific ===
# Session management
.session/
.session_history/

# Local development
.local/
tmp/
temp/

# Logs
logs/
*.log
```

### EditorConfig for Consistency

A comprehensive .editorconfig ensures consistent formatting across all editors:

```ini
# EditorConfig is awesome: https://EditorConfig.org
root = true

# === Universal Settings ===
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

# === Language Specific ===
# Python - PEP 8
[*.py]
indent_size = 4
max_line_length = 88  # Black's default

# Go - gofmt
[*.go]
indent_style = tab

# Makefiles require tabs
[Makefile]
indent_style = tab

# Markdown
[*.{md,markdown}]
trim_trailing_whitespace = false  # Trailing spaces are significant
max_line_length = 80

# YAML
[*.{yml,yaml}]
indent_size = 2

# JSON
[*.json]
indent_size = 2

# Shell scripts
[*.{sh,bash}]
indent_size = 2

# === Web Development ===
[*.{html,css,scss,js,jsx,ts,tsx}]
indent_size = 2

# === Configuration Files ===
[.{gitconfig,gitignore,gitattributes}]
indent_size = 2

# === Special Files ===
[*.csv]
trim_trailing_whitespace = false
insert_final_newline = false
```

## Script Organization Patterns

### Modular Script Structure

Organize scripts by function, not by language:

```
scripts/
├── setup/
│   ├── install.sh          # Main installation
│   ├── install-deps.sh     # Dependency installation
│   ├── configure.sh        # Configuration setup
│   └── verify.sh           # Post-install verification
├── development/
│   ├── dev-server.sh       # Start development environment
│   ├── watch.sh            # File watching and rebuilding
│   └── clean.sh            # Clean development artifacts
├── testing/
│   ├── run-tests.sh        # Test runner
│   ├── coverage.sh         # Coverage reporting
│   └── e2e.sh              # End-to-end tests
├── deployment/
│   ├── build.sh            # Build for production
│   ├── deploy.sh           # Deployment script
│   └── rollback.sh         # Rollback mechanism
└── utils/
    ├── check-deps.sh       # Dependency checking
    ├── update-deps.sh      # Dependency updates
    └── generate-docs.sh    # Documentation generation
```

### Script Naming Conventions

1. **Use descriptive names** - `install-dependencies.sh` not `deps.sh`
2. **Include action verbs** - `check-`, `install-`, `update-`, `generate-`
3. **Suffix with purpose** - `-dev.sh`, `-prod.sh`, `-ci.sh`
4. **Consistent extension** - Always `.sh` for shell scripts

## External Dependencies

### Git Submodules Pattern

Organize external dependencies clearly:

```bash
# Adding external dependencies
git submodule add https://github.com/org/repo.git external/repo
git submodule add -b stable https://github.com/org/tool.git external/tool

# Directory structure
external/
├── .gitkeep               # Ensure directory exists
├── README.md              # Document what each submodule is for
├── library-name/          # Third-party library
├── tool-name/             # Development tool
└── internal-shared/       # Shared internal code
```

### External Directory README

```markdown
# External Dependencies

This directory contains git submodules for external dependencies.

## Dependencies

### library-name
- **Purpose**: Core functionality for X
- **Version**: Tracking branch `main`
- **Documentation**: https://example.com/docs

### tool-name
- **Purpose**: Development tooling for Y
- **Version**: Locked to tag `v1.2.3`
- **Update policy**: Manual updates only after testing

## Management

Update all submodules:
\```bash
git submodule update --init --recursive
\```

Update specific submodule:
\```bash
cd external/library-name
git checkout main
git pull origin main
cd ../..
git add external/library-name
git commit -m "chore: update library-name to latest"
\```
```

## Documentation Organization

### Documentation Structure

```
docs/
├── README.md              # Documentation index
├── getting-started/       # New user guides
│   ├── README.md         # Getting started index
│   ├── installation.md   # Installation guide
│   └── first-steps.md    # Initial usage
├── guides/                # How-to guides
│   ├── development.md    # Development workflow
│   ├── testing.md        # Testing guide
│   └── deployment.md     # Deployment guide
├── reference/             # API/CLI reference
│   ├── api.md           # API documentation
│   ├── cli.md           # CLI documentation
│   └── configuration.md  # Config reference
├── architecture/          # Technical design
│   ├── README.md        # Architecture overview
│   ├── decisions/       # ADRs
│   └── diagrams/        # Architecture diagrams
└── contributing/          # Contribution guides
    ├── README.md        # Contribution overview
    ├── code-style.md    # Coding standards
    └── pull-requests.md # PR process
```

## Environment Configuration

### Environment File Pattern

Structure environment files for different contexts:

```
.env.example              # Template with all variables
.env.development         # Local development (gitignored)
.env.test               # Test environment (gitignored)
.env.production         # Production (gitignored)
.env.ci                 # CI environment (can be committed)
```

Example .env.example:

```bash
# Application Configuration
APP_NAME=myapp
APP_ENV=development
APP_DEBUG=true
APP_URL=http://localhost:3000

# Database Configuration
DB_CONNECTION=postgresql
DB_HOST=localhost
DB_PORT=5432
DB_DATABASE=myapp_dev
DB_USERNAME=
DB_PASSWORD=

# External Services
# Get your API key from https://service.com/dashboard
API_KEY=
API_SECRET=

# Feature Flags
FEATURE_NEW_UI=false
FEATURE_BETA_API=false

# Development Tools
# Set to true to enable additional logging
VERBOSE_LOGGING=false
```

## State and Cache Management

### Temporary File Organization

```
.local/                   # Local state (gitignored)
├── cache/               # Cache files
├── tmp/                 # Temporary files
├── state/               # Application state
└── logs/                # Local logs

.session/                 # Session management
├── current.json         # Current session state
├── history/             # Session history
└── locks/               # Lock files
```

## Security Patterns

### Secrets Management

Never commit secrets. Use this pattern:

```
secrets/                  # Always gitignored
├── README.md            # Instructions for obtaining secrets
├── .gitkeep             # Keep directory structure
└── development/         # Development secrets only
    └── .gitkeep

config/
├── secrets.example.yml   # Template showing structure
└── secrets.yml          # Actual secrets (gitignored)
```

### Security Documentation

SECURITY.md template structure:

```markdown
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 5.1.x   | :white_check_mark: |
| 5.0.x   | :x:                |
| 4.0.x   | :white_check_mark: |
| < 4.0   | :x:                |

## Reporting a Vulnerability

Please report security vulnerabilities to: security@example.com

**Do not** report security issues through public GitHub issues.

## Security Best Practices

1. Keep dependencies updated
2. Use environment variables for secrets
3. Enable 2FA for all team members
4. Review security advisories regularly
```

## Version Control Patterns

### Git Attributes

.gitattributes for consistent line endings and diff handling:

```
# Auto detect text files and perform LF normalization
* text=auto

# Files that should always be normalized
*.md text
*.txt text
*.yml text
*.yaml text
*.json text
*.xml text
*.sh text eol=lf
*.bash text eol=lf

# Files that should not be normalized
*.png binary
*.jpg binary
*.gif binary
*.ico binary
*.zip binary
*.tar binary
*.gz binary

# Language specific
*.py text diff=python
*.rb text diff=ruby
*.java text diff=java
*.html text diff=html
*.css text diff=css
*.js text diff=javascript
*.ts text diff=typescript
*.go text diff=golang

# Documentation
*.md text diff=markdown

# Exclude from archive
.gitignore export-ignore
.gitattributes export-ignore
.github/ export-ignore
tests/ export-ignore
docs/ export-ignore
```

## Build Artifact Management

### Clean Separation

Keep build artifacts separate and clearly marked:

```
# Development builds
build/
├── dev/
├── test/
└── debug/

# Production builds
dist/
├── latest/
├── v1.2.3/
└── archives/

# Platform specific
out/
├── darwin-amd64/
├── darwin-arm64/
├── linux-amd64/
└── windows-amd64/
```

These patterns ensure projects remain organized, maintainable, and collaborative-friendly across different environments and team sizes.