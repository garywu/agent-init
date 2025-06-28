# Automated Shell Script Fixing Guide

## Overview

This guide provides a comprehensive approach to automated shell script fixing using industry-standard tools. Instead of manually addressing ShellCheck issues, use configuration and automation to prevent problems and fix them automatically.

## Philosophy: Prevention Over Reaction

The key insight is to **prevent issues through configuration** rather than manually fixing them after the fact:

1. **Configure tools** to suppress non-critical warnings
2. **Automate fixes** using reliable tooling
3. **Integrate into workflow** via Makefile/CI/CD
4. **Focus on real issues** vs style preferences

## Three-Tool Pipeline

### 1. shellharden - Security Hardening
**Purpose**: Fix security vulnerabilities and quoting issues
**Focus**: Variable quoting, command injection prevention

```bash
# Install
cargo install shellharden
# or: brew install shellharden

# Usage
shellharden --transform script.sh
```

**What it fixes**:
- Unquoted variables (`$var` → `"$var"`)
- Command substitution security issues
- Word splitting vulnerabilities
- Glob expansion problems

### 2. shellcheck - Static Analysis
**Purpose**: Detect bugs, portability issues, and code smells
**Focus**: Logic errors, deprecated syntax, best practices

```bash
# Install
brew install shellcheck

# Auto-fix usage
shellcheck -f diff script.sh | patch script.sh -
```

**What it fixes**:
- Syntax errors and typos
- Logic errors in conditionals
- Deprecated command usage
- Portability issues

### 3. shfmt - Code Formatting
**Purpose**: Consistent code style and formatting
**Focus**: Indentation, spacing, code structure

```bash
# Install
brew install shfmt

# Usage with configuration
shfmt -w script.sh  # respects .shfmt file
```

**What it fixes**:
- Inconsistent indentation
- Code structure and spacing
- Case statement formatting
- Function declaration style

## Configuration Files

### .shellcheckrc - Suppress Non-Critical Warnings

Create this file in your project root:

```bash
# ShellCheck configuration for professional development
shell=bash
enable=all

# Disable non-functional warnings
disable=SC1091,SC2001,SC2034,SC2053,SC2154,SC2155,SC2207,SC2248,SC2249,SC2250,SC2312
```

**Disabled warnings explained**:
- `SC2034`: Unused variables (often intentional for future use)
- `SC2312`: Command substitution in echo (safe and readable)
- `SC2154`: Variables from sourced files (external dependencies)
- `SC2249`: Default case in switch (not always needed)
- `SC2001`: sed vs parameter expansion (sed often clearer)
- `SC2248`: Quoting return values (style preference)
- `SC2053`: Variable comparison quoting (safe in [[ ]])
- `SC2207`: Array from command output (functional pattern)
- `SC2155`: Declare and assign separately (common idiom)

### .shfmt - Formatting Configuration

```bash
# 2-space indentation
-i 2
# Indent case statement cases
-ci
# Simplify code where possible
-s
# Keep padding for alignment
-kp
```

## Automated Workflow

### Option 1: Enhanced Script (Recommended)

Use the provided `fix-shell-issues-enhanced.sh`:

```bash
# Run comprehensive fixing
./scripts/fix-shell-issues-enhanced.sh

# Preview changes without applying
./scripts/fix-shell-issues-enhanced.sh --dry-run

# Verbose output for debugging
./scripts/fix-shell-issues-enhanced.sh --verbose
```

### Option 2: Makefile Integration

Add to your Makefile:

```makefile
# Shell script fixing
fix-shell:
	@echo "🔧 Fixing shell script issues..."
	@find . -type f -name "*.sh" -not -path "./node_modules/*" | xargs -I {} shellharden --transform {} 2>/dev/null || true
	@find . -type f -name "*.sh" -not -path "./node_modules/*" | xargs shfmt -w 2>/dev/null || true
	@echo "✅ Shell script fixes applied!"

lint-shell:
	@echo "🔍 Linting shell scripts..."
	@find . -type f -name "*.sh" -not -path "./node_modules/*" | xargs shellcheck

.PHONY: fix-shell lint-shell
```

### Option 3: Manual Pipeline

```bash
# 1. Security fixes first
find . -name "*.sh" | xargs -I {} shellharden --transform {}

# 2. Auto-fixable issues
find . -name "*.sh" | xargs -I {} sh -c 'shellcheck -f diff "$1" | patch "$1" -' _ {}

# 3. Formatting last
find . -name "*.sh" | xargs shfmt -w -i 2 -ci -s
```

## CI/CD Integration

### GitHub Actions

Add to `.github/workflows/lint.yml`:

```yaml
name: Lint

on: [push, pull_request]

jobs:
  shell-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install shell tools
        run: |
          sudo apt-get update
          sudo apt-get install -y shellcheck
          curl -sSfL https://github.com/mvdan/sh/releases/latest/download/shfmt_v3.7.0_linux_amd64 -o shfmt
          chmod +x shfmt && sudo mv shfmt /usr/local/bin/
          
      - name: Run shell linting
        run: |
          find . -name "*.sh" | xargs shellcheck
          find . -name "*.sh" | xargs shfmt -d
```

### Pre-commit Hooks

Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.6
    hooks:
      - id: shellcheck
        
  - repo: https://github.com/pre-commit/mirrors-shfmt
    rev: v3.7.0
    hooks:
      - id: shfmt
        args: [-w, -i, '2', -ci, -s]
```

## Editor Integration

### VS Code

Install extensions:
- **ShellCheck** by Timon Wong
- **shell-format** by foxundermoon

Settings in `.vscode/settings.json`:
```json
{
  "shellcheck.enableQuickFix": true,
  "shellformat.effectLanguages": ["shellscript"],
  "shellformat.flag": "-i 2 -ci -s"
}
```

### Vim/Neovim

Using ALE plugin:
```vim
let g:ale_linters = {'sh': ['shellcheck']}
let g:ale_fixers = {'sh': ['shfmt']}
let g:ale_sh_shfmt_options = '-i 2 -ci -s'
```

## Troubleshooting

### Common Issues

**"shellharden not found"**
```bash
# Install via Cargo
cargo install shellharden

# or via Homebrew (if available)
brew install shellharden
```

**"Too many warnings from shellcheck"**
- Copy the provided `.shellcheckrc` configuration
- Customize disabled warnings for your project

**"Scripts break after shellharden"**
- Review changes with `git diff`
- Some scripts rely on unquoted expansion (rare but possible)
- Use `--dry-run` first to preview changes

**"Formatting conflicts with project style"**
- Customize `.shfmt` configuration
- Use project-specific formatting rules

### Rollback Changes

If automated fixes break something:
```bash
# Rollback all changes
git checkout -- **/*.sh

# Rollback specific file
git checkout -- path/to/script.sh

# Review changes before committing
git diff --cached
```

## Best Practices

### 1. Start with Configuration
- Always create `.shellcheckrc` and `.shfmt` first
- Test configuration on a few scripts before bulk application

### 2. Use Staging
- Apply fixes to a staging branch first
- Test functionality after automated fixes
- Review changes before merging

### 3. Gradual Adoption
- Fix scripts in small batches
- Prioritize critical/frequently-used scripts
- Build confidence with the toolchain

### 4. Documentation
- Document any project-specific exceptions
- Update team workflows to include automated fixing
- Share configuration files across projects

## Benefits

### For Developers
- **No manual fixing** of style issues
- **Focus on logic** vs formatting
- **Consistent code quality** across team
- **Automated security improvements**

### For Projects
- **Reduced review overhead** (fewer style comments)
- **Improved security posture** (shellharden fixes)
- **Better maintainability** (consistent formatting)
- **Faster development cycle** (automated tooling)

### For Teams
- **Standardized workflows** across projects
- **Onboarding simplification** (tools handle style)
- **Quality gate automation** (CI/CD integration)
- **Knowledge sharing** (documented standards)

## Real-World Results

From the dotfiles project implementation:
- **Reduced shellcheck issues from 20+ to 0** in one pass
- **Eliminated manual fixing** through configuration
- **Improved security** with automated quoting fixes
- **Consistent formatting** across 80+ shell scripts

The key insight: **Prevention through configuration beats manual fixing every time**.

## Getting Started

1. **Copy template files** from this project:
   - `.shellcheckrc`
   - `.shfmt`
   - `scripts/fix-shell-issues-enhanced.sh`
   - `scripts/install-shell-tools.sh`

2. **Install tools (cross-platform)**:
   ```bash
   # Automated cross-platform installation
   ./scripts/install-shell-tools.sh
   
   # Or use Makefile
   make shell-toolchain
   
   # Or platform-specific:
   # macOS:
   brew install shellcheck shfmt && cargo install shellharden
   
   # Ubuntu/Debian:
   sudo apt-get install shellcheck
   go install mvdan.cc/sh/v3/cmd/shfmt@latest
   cargo install shellharden
   
   # Via Nix (universal):
   nix-env -iA nixpkgs.shellcheck nixpkgs.shfmt
   cargo install shellharden
   ```

3. **Test on a few scripts**:
   ```bash
   ./scripts/fix-shell-issues-enhanced.sh --dry-run
   ```

4. **Apply fixes**:
   ```bash
   ./scripts/fix-shell-issues-enhanced.sh
   ```

5. **Review and commit**:
   ```bash
   git diff
   git add -u && git commit -m "feat: apply automated shell script fixes"
   ```

This approach transforms shell script maintenance from a manual chore into an automated, reliable process.