# Linting and Formatting Guide

This guide provides reference commands for linting and formatting various file types without requiring a Makefile. These commands can be integrated into any build system or run standalone.

## Tool Documentation References

### Linters
- [ESLint Documentation](https://eslint.org/docs/latest/)
- [ShellCheck Documentation](https://www.shellcheck.net/)
- [markdownlint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [yamllint Documentation](https://yamllint.readthedocs.io/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)

### Formatters
- [Prettier Documentation](https://prettier.io/docs/en/)
- [Black Documentation](https://black.readthedocs.io/)
- [shfmt Documentation](https://github.com/mvdan/sh#shfmt)
- [nixpkgs-fmt](https://github.com/nix-community/nixpkgs-fmt)

## Quick Reference

### Shell Scripts

```bash
# Lint shell scripts with shellcheck
shellcheck **/*.sh

# Format shell scripts with shfmt (respects .shfmt config)
shfmt -w -i 2 .

# Security hardening with shellharden
shellharden --transform script.sh

# Check shell script syntax
bash -n script.sh

# Comprehensive automated fixing (recommended)
./scripts/fix-shell-issues-enhanced.sh

# Configuration files for consistent behavior:
# .shellcheckrc - Configure shellcheck warnings
# .shfmt - Configure formatting options
```

#### Advanced Shell Script Tooling

For comprehensive shell script quality, use this three-tool pipeline:

1. **shellharden** - Security-focused hardening (fixes quoting issues)
2. **shellcheck** - Static analysis with auto-fixes
3. **shfmt** - Consistent formatting

```bash
# Install the complete toolchain
brew install shellcheck shfmt
cargo install shellharden  # or: brew install shellharden

# One-command fixing (if using enhanced script)
make fix-shell

# Manual pipeline
find . -name "*.sh" | xargs -I {} shellharden --transform {}
find . -name "*.sh" | xargs shellcheck -f diff | patch
find . -name "*.sh" | xargs shfmt -w -i 2 -ci -s
```

#### Configuration-Based Prevention

Instead of manually fixing issues, prevent them with configuration:

**.shellcheckrc** (suppresses non-critical warnings):
```bash
shell=bash
enable=all
disable=SC2034,SC2312,SC2154,SC2249,SC2001,SC2248,SC2053
```

**.shfmt** (consistent formatting):
```bash
-i 2   # 2-space indentation
-ci    # indent case statements
-s     # simplify code
```

### Python

```bash
# Lint with flake8
flake8 .

# Lint with pylint
pylint **/*.py

# Format with black
black .

# Sort imports with isort
isort .

# Type checking with mypy
mypy .

# All-in-one with ruff
ruff check .
ruff format .
```

### JavaScript/TypeScript

```bash
# Lint with ESLint
eslint . --ext .js,.jsx,.ts,.tsx

# Format with Prettier
prettier --write .

# Type check TypeScript
tsc --noEmit

# Lint and fix
eslint . --fix
```

### YAML

```bash
# Lint YAML files
yamllint .

# With custom config
yamllint -c .yamllint.yml .
```

### JSON

```bash
# Validate JSON files
find . -name "*.json" -exec jq . {} \; > /dev/null

# Format JSON files
find . -name "*.json" -exec jq . {} \; -exec sponge {} \;

# Using prettier for JSON
prettier --write "**/*.json"
```

### Markdown

```bash
# Lint with markdownlint
markdownlint **/*.md

# Fix automatically
markdownlint --fix **/*.md

# Using markdownlint-cli2
markdownlint-cli2 "**/*.md"
```

### Go

```bash
# Format Go code
go fmt ./...

# Lint with golangci-lint
golangci-lint run

# Vet code
go vet ./...
```

### Rust

```bash
# Format Rust code
cargo fmt

# Lint with clippy
cargo clippy -- -D warnings

# Check without building
cargo check
```

### Nix

```bash
# Format Nix files
nixpkgs-fmt .

# Lint with statix
statix check

# Format with alejandra
alejandra .
```

## Integration Examples

### npm scripts (package.json)

```json
{
  "scripts": {
    "lint": "eslint . && prettier --check .",
    "lint:fix": "eslint . --fix && prettier --write .",
    "typecheck": "tsc --noEmit"
  }
}
```

### Pre-commit hooks (.pre-commit-config.yaml)

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json

  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.2
    hooks:
      - id: shellcheck

  - repo: https://github.com/psf/black
    rev: 23.1.0
    hooks:
      - id: black

  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
```

### GitHub Actions

```yaml
name: Lint

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run ShellCheck
        uses: ludeeus/action-shellcheck@master
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Lint Python
        run: |
          pip install flake8 black isort
          flake8 .
          black --check .
          isort --check-only .
```

### Generic CI-friendly commands

```bash
# Run all linters and exit on first failure
set -e
shellcheck **/*.sh || exit 1
yamllint . || exit 1
markdownlint **/*.md || exit 1

# Run all and collect results
FAILED=0
shellcheck **/*.sh || FAILED=1
yamllint . || FAILED=1
markdownlint **/*.md || FAILED=1
exit $FAILED
```

## Tool Installation

### macOS (Homebrew)

```bash
# Shell tools
brew install shellcheck shfmt

# Python tools
brew install black ruff
pip install flake8 mypy isort pylint

# JavaScript tools
npm install -g eslint prettier typescript

# Other tools
brew install yamllint
brew install markdownlint-cli
brew install jq
```

### Ubuntu/Debian

```bash
# Shell tools
apt-get install shellcheck
GO111MODULE=on go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Python tools
pip install black flake8 mypy isort pylint ruff

# JavaScript tools
npm install -g eslint prettier typescript

# Other tools
apt-get install yamllint
npm install -g markdownlint-cli
apt-get install jq
```

## Tips

1. **Check if tool exists before running:**
   ```bash
   command -v shellcheck >/dev/null 2>&1 && shellcheck *.sh
   ```

2. **Create wrapper function:**
   ```bash
   lint_if_available() {
     command -v "$1" >/dev/null 2>&1 && "$@"
   }
   lint_if_available shellcheck *.sh
   ```

3. **Ignore files with .ignore files:**
   - `.eslintignore`
   - `.prettierignore`
   - `.gitignore` (respected by many tools)

4. **Use configuration files:**
   - `.shellcheckrc`
   - `.flake8`
   - `.eslintrc.json`
   - `.prettierrc`
   - `.yamllint.yml`
   - `.markdownlint.json`