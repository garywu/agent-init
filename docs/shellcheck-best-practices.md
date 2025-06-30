# ShellCheck Best Practices Guide

## Overview

ShellCheck is an essential tool for writing reliable shell scripts. This guide captures real-world experience from the dotfiles project, where we systematically fixed ShellCheck issues across dozens of scripts in a large codebase.

## Critical: Bash Shebang Compatibility

Before diving into ShellCheck issues, ensure your scripts use the correct shebang:

```bash
#!/usr/bin/env bash  # ✅ CORRECT - finds bash in PATH
#!/bin/bash          # ❌ WRONG - hardcoded to system bash
```

**Why this matters on macOS:**
- macOS ships with bash 3.2 (from 2007) at `/bin/bash`
- Modern bash 5.2+ features like `declare -A` will fail
- Using `env bash` finds the modern version installed via Homebrew/Nix

See [Bash Shebang Compatibility Guide](bash-shebang-compatibility.md) for enforcement strategies.

## Quick Start

### Installation

```bash
# Complete shell script toolchain (recommended)
brew install shellcheck shfmt
cargo install shellharden

# Individual tools
# macOS with Homebrew
brew install shellcheck

# Ubuntu/Debian
apt-get install shellcheck

# Via Nix
nix-env -iA nixpkgs.shellcheck
```

### Basic Usage

```bash
# Check a single script
shellcheck script.sh

# Check all shell scripts in project
find . -name "*.sh" -type f -exec shellcheck {} \;

# Use configuration file (recommended)
# Create .shellcheckrc with project standards
shellcheck script.sh  # respects .shellcheckrc automatically
```

### Automated Fixing (Recommended Approach)

Instead of manual fixes, use automated tooling:

```bash
# One-command comprehensive fixing
./scripts/fix-shell-issues-enhanced.sh

# Or use the three-tool pipeline:
shellharden --transform script.sh    # Security fixes
shellcheck -f diff script.sh | patch # Auto-fixes
shfmt -w -i 2 -ci script.sh          # Formatting
```

# Check with specific shell dialect
shellcheck -s bash script.sh

# Format output for CI/CD
shellcheck -f gcc script.sh
```

## Project Configuration

### The .shellcheckrc File

Create a `.shellcheckrc` in your project root to establish consistent rules:

```bash
# ShellCheck configuration for dotfiles project

# Disable specific warnings globally
# Style checks
disable=SC2001  # See if you can use ${variable//search/replace} instead of sed
disable=SC2116  # Useless echo? Instead of 'cmd $(echo foo)', just use 'cmd foo'
disable=SC2126  # Consider using 'grep -c' instead of 'grep|wc -l'
disable=SC2250  # Prefer putting braces around variable references
disable=SC2312  # Consider invoking this command separately (for pipelines)

# Info level checks that are not always applicable
disable=SC1090  # Can't follow non-constant source
disable=SC1091  # Not following: was not specified as input
disable=SC2016  # Expressions don't expand in single quotes
disable=SC2162  # read without -r will mangle backslashes

# Shell dialect
shell=bash

# Set minimum severity level (error, warning, info, style)
# We focus on errors and warnings
severity=warning

# External sources - Tell ShellCheck about our sourced files
# This helps with cross-file variable detection
source-path=SCRIPTDIR
source-path=scripts
```

### Configuration Philosophy

Based on our experience with the dotfiles project:

1. **Focus on real issues**: Disable style suggestions that don't improve reliability
2. **Be pragmatic**: Some warnings are context-dependent (like SC2016 for single quotes)
3. **Start strict**: Begin with all checks, then selectively disable after review
4. **Document decisions**: Always explain why a check is disabled

## Common Issues and Fixes

### 1. Array Handling (SC2207, SC2199)

**Problem**: Improper array assignment and checking

```bash
# Bad: Command substitution splits on whitespace
locations=($(find /usr/bin -name "git*"))

# Bad: Array element checking with regex
if [[ " ${PACKAGES[@]} " =~ " ${package} " ]]; then
```

**Solution**:

```bash
# Good: Use mapfile/readarray for safe array assignment
mapfile -t locations < <(find /usr/bin -name "git*")

# Good: Use proper array element checking
# For literal match (not regex):
# shellcheck disable=SC2076  # We want literal match
if [[ " ${PACKAGES[*]} " =~ " ${package} " ]]; then

# Or use a function for clarity:
array_contains() {
    local needle="$1"
    shift
    local element
    for element in "$@"; do
        [[ "$element" == "$needle" ]] && return 0
    done
    return 1
}

if array_contains "$package" "${PACKAGES[@]}"; then
```

### 2. Variable Scoping (SC2154)

**Problem**: Using variables from sourced files

```bash
# helpers.sh defines RED, GREEN, NC
source helpers.sh

# ShellCheck warns: RED appears unused
echo -e "${RED}Error${NC}"
```

**Solution**:

```bash
# Document where variables come from
# shellcheck disable=SC2154  # RED, NC defined in sourced helpers.sh
echo -e "${RED}Error${NC}"

# Or better: check if sourcing succeeded
if source helpers.sh 2>/dev/null; then
    echo -e "${RED}Error${NC}"
else
    echo "Error"  # Fallback without colors
fi
```

### 3. Command Substitution (SC2312)

**Problem**: Complex pipelines in command substitution

```bash
# ShellCheck suggests separating this
result=$(grep "pattern" file.txt | wc -l)
```

**Solution**:

```bash
# Option 1: If the pipeline is simple and clear, disable the warning
# shellcheck disable=SC2312  # Simple pipeline, error handling not needed
result=$(grep "pattern" file.txt | wc -l)

# Option 2: For critical operations, separate and check
if grep_output=$(grep "pattern" file.txt 2>/dev/null); then
    result=$(echo "$grep_output" | wc -l)
else
    result=0
fi

# Option 3: Use grep -c when counting matches
result=$(grep -c "pattern" file.txt || echo "0")
```

### 4. Quoting Issues (SC2086)

**Problem**: Unquoted variables can cause word splitting

```bash
# Bad: Unquoted variable
rm $file

# Bad: Unquoted command substitution
cd $(dirname $0)
```

**Solution**:

```bash
# Good: Always quote variables
rm "$file"

# Good: Quote command substitutions
cd "$(dirname "$0")"

# Good: Use quotes even in [[ ]] (for consistency)
if [[ -n "$var" ]]; then
```

### 5. Source Path Issues (SC1090, SC1091)

**Problem**: Dynamic or relative source paths

```bash
# ShellCheck can't follow dynamic paths
source "$SCRIPT_DIR/helpers.sh"

# ShellCheck can't find relative paths
source ../common/functions.sh
```

**Solution**:

```bash
# Option 1: Use shellcheck source directive
# shellcheck source=/dev/null
source "$SCRIPT_DIR/helpers.sh"

# Option 2: Provide explicit path hint
# shellcheck source=../common/functions.sh
source ../common/functions.sh

# Option 3: Make paths static when possible
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./helpers.sh
source "${SCRIPT_DIR}/helpers.sh"
```

## Best Practices from Real Experience

### 1. Consistent Script Structure

```bash
#!/usr/bin/env bash
# Script: validate-packages.sh
# Purpose: Validate package installations
# Usage: ./validate-packages.sh [--debug] [--verbose]

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Get script directory (portable method)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helpers with error checking
# shellcheck source=/dev/null
if ! source "${SCRIPT_DIR}/helpers.sh"; then
    echo "Error: Failed to source helpers.sh" >&2
    exit 1
fi

# Main function pattern
main() {
    # Parse arguments
    parse_args "$@"

    # Validate environment
    validate_prerequisites

    # Do the work
    perform_validation
}

# Only run main if script is executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### 2. Error Handling Patterns

```bash
# Function with explicit error handling
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Required command not found: $cmd"
        return 1
    fi
    return 0
}

# Trap errors with context
trap 'echo "Error on line $LINENO" >&2' ERR

# Safe temporary files
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Pipeline error handling
if ! result=$(complex_command 2>&1); then
    log_error "Command failed: $result"
    exit 1
fi
```

### 3. Cross-Platform Compatibility

```bash
# Detect OS for platform-specific code
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

# Use portable commands
# Bad: seq is not universal
for i in $(seq 1 10); do

# Good: Use bash built-ins
for i in {1..10}; do

# Good: Or POSIX arithmetic
i=1
while [ $i -le 10 ]; do
    echo $i
    i=$((i + 1))
done
```

### 4. Testing and Validation

```bash
# Make scripts testable
validate_input() {
    local input="$1"
    [[ -z "$input" ]] && return 1
    [[ "$input" =~ ^[a-zA-Z0-9_-]+$ ]] || return 1
    return 0
}

# Test mode support
if [[ "${TEST_MODE:-false}" == "true" ]]; then
    # Don't execute destructive operations
    DRY_RUN=true
fi

# Verbose/debug support
[[ "${VERBOSE:-false}" == "true" ]] && set -x
[[ "${DEBUG:-false}" == "true" ]] && PS4='+ ${FUNCNAME[0]:-main}:${LINENO}: '
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: ShellCheck

on:
  push:
    paths:
      - '**.sh'
  pull_request:
    paths:
      - '**.sh'

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run ShellCheck
        uses: ludeeus/action-shellcheck@master
        with:
          severity: warning
          check_together: 'yes'

      # Alternative: Direct shellcheck
      - name: Run ShellCheck (Alternative)
        run: |
          find . -name "*.sh" -type f -print0 | \
            xargs -0 shellcheck -x -s bash
```

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.6
    hooks:
      - id: shellcheck
        args: [-x]  # Follow source files
```

## Gradual Adoption Strategy

Based on our experience fixing ShellCheck issues in the dotfiles project:

1. **Audit Current State**
   ```bash
   # Count total issues
   find . -name "*.sh" -exec shellcheck {} \; 2>&1 | grep -c "^In"

   # Group by severity
   find . -name "*.sh" -exec shellcheck -f json {} \; | \
     jq -r '.[] | .level' | sort | uniq -c
   ```

2. **Fix Critical Issues First**
   - Start with error-level issues
   - Fix security problems (unquoted variables, injections)
   - Address logic errors (incorrect conditionals)

3. **Create Standards**
   - Add `.shellcheckrc` configuration
   - Document which warnings to ignore and why
   - Create script templates

4. **Incremental Improvement**
   - Fix one script at a time
   - Add inline disables with explanations
   - Update CI/CD to enforce standards

5. **Maintain Quality**
   - Run ShellCheck in CI/CD
   - Use pre-commit hooks
   - Regular audits for new scripts

## Common Disable Patterns

When you must disable a check, always explain why:

```bash
# Disable for legitimate dynamic sourcing
# shellcheck disable=SC1090  # Path computed at runtime
source "$dynamic_path"

# Disable for intentional unquoted expansion
# shellcheck disable=SC2086  # Word splitting is intentional
command $FLAGS file.txt

# Disable for variables from includes
# shellcheck disable=SC2154  # Variables defined in sourced common.sh
echo "$EXTERNAL_VAR"

# Disable for literal regex matching
# shellcheck disable=SC2076  # Want literal match, not regex
[[ " ${array[*]} " =~ " $item " ]]
```

## Resources

- [ShellCheck Wiki](https://www.shellcheck.net/wiki/): Detailed explanations of each warning
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html): Comprehensive style guide
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls): Common bash programming mistakes
- [shellharden](https://github.com/anordal/shellharden): Automatic shell script hardening

## Summary

ShellCheck is invaluable for writing reliable shell scripts. Our experience in the dotfiles project showed that:

1. Most warnings point to real issues that can cause bugs
2. Some style warnings can be safely ignored with proper documentation
3. Consistent configuration across the project is essential
4. Gradual adoption with clear standards works best
5. Integration with CI/CD prevents regression

Start strict, document exceptions, and maintain consistency. Your future self (and your team) will thank you.