# Building Comprehensive Validation Systems

This guide documents how to build robust validation systems based on the architecture used in the dotfiles validation framework. This approach provides a scalable, maintainable way to validate complex environments and configurations.

## Overview

A comprehensive validation system consists of:
- **Master orchestrator** - Runs all validation scripts and aggregates results
- **Helper functions** - Shared utilities for consistent logging and error handling
- **Specialized validators** - Focused scripts for specific validation domains
- **Reporting system** - Structured output with fix suggestions
- **Fix mode** - Automated remediation capabilities

## Architecture Pattern

### 1. Master Orchestrator (`validate-all.sh`)

The master script coordinates all validation activities:

```bash
#!/bin/bash
set -euo pipefail

# Source helpers
source "$SCRIPT_DIR/helpers/validation-helpers.sh"

# Define validation scripts to run
VALIDATION_SCRIPTS=(
    "validation/validate-packages.sh"
    "validation/validate-environment.sh"
    "validation/validate-security.sh"
    "validation/validate-performance.sh"
)

# Track overall results
TOTAL_ERRORS=0
TOTAL_WARNINGS=0
TOTAL_FIXED=0
FAILED_SCRIPTS=()
PASSED_SCRIPTS=()

# Run each validation script
for script in "${VALIDATION_SCRIPTS[@]}"; do
    run_validation "$script" "$@" || true
done

# Generate and save report
save_report
```

Key features:
- Runs validators in sequence
- Captures exit codes and output
- Aggregates statistics
- Continues even if individual validators fail
- Generates comprehensive reports

### 2. Helper Functions Library

Create a shared library for consistent behavior across all validators:

```bash
# validation-helpers.sh

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Log levels
readonly LOG_ERROR=0
readonly LOG_WARN=1
readonly LOG_INFO=2
readonly LOG_DEBUG=3

# Counters
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0
VALIDATION_FIXED=0

# Logging functions
log_error() {
    [[ $LOG_LEVEL -ge $LOG_ERROR ]] && echo -e "${RED}[ERROR]${NC} $*" >&2
    ((VALIDATION_ERRORS++))
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*"
}

# Check if running in fix mode
is_fix_mode() {
    [[ "${FIX_MODE:-false}" == "true" ]]
}

# Safe command execution
safe_run() {
    local cmd="$1"
    local error_msg="${2:-Command failed: $cmd}"
    
    log_debug "Running: $cmd"
    if ! eval "$cmd"; then
        log_error "$error_msg"
        return 1
    fi
    return 0
}
```

### 3. Specialized Validators

Each validator focuses on a specific domain:

#### Package Validation Example

```bash
#!/bin/bash
# validate-packages.sh - Detect package conflicts

source "$SCRIPT_DIR/../helpers/validation-helpers.sh"

# Define package rules
CRITICAL_PACKAGES=(
    "python"
    "node"
    "git"
)

NIX_PREFERRED=(
    "ripgrep"
    "fd"
    "bat"
)

# Validation function
validate_package() {
    local package="$1"
    local preferred_location="$2"
    local locations=()
    
    # Check all package managers
    check_package_location "$package"
    
    # Detect conflicts
    if [[ ${#locations[@]} -gt 1 ]]; then
        log_error "$package: DUPLICATE - Found in multiple locations"
        
        if is_fix_mode; then
            fix_duplicate_package "$package" "$preferred_location"
        fi
    fi
}

# Main validation loop
for package in "${CRITICAL_PACKAGES[@]}"; do
    validate_package "$package" "nix"
done

print_summary
```

#### Environment Validation Example

```bash
#!/bin/bash
# validate-environment.sh - Validate shell environment

source "$SCRIPT_DIR/../helpers/validation-helpers.sh"

# Check PATH order
check_path_order() {
    local nix_position=-1
    local homebrew_position=-1
    local position=0
    
    IFS=':' read -ra PATH_ARRAY <<< "$PATH"
    
    for path in "${PATH_ARRAY[@]}"; do
        if [[ "$path" =~ \.nix-profile ]]; then
            nix_position=$position
        elif [[ "$path" =~ /opt/homebrew ]]; then
            homebrew_position=$position
        fi
        ((position++))
    done
    
    if [[ $homebrew_position -lt $nix_position ]]; then
        log_warn "Homebrew comes before Nix in PATH"
        return 1
    fi
    
    log_success "PATH order is correct"
}

# Run checks
check_path_order
check_shell_config
check_git_config

print_summary
```

## Building Your Own Validation System

### Step 1: Create the Structure

```bash
validation-system/
├── validate-all.sh           # Master orchestrator
├── helpers/
│   └── validation-helpers.sh # Shared functions
├── validation/
│   ├── validate-syntax.sh    # Code syntax validation
│   ├── validate-security.sh  # Security checks
│   ├── validate-deps.sh      # Dependency validation
│   └── validate-config.sh    # Configuration checks
└── logs/
    └── validation/           # Report storage
```

### Step 2: Define Helper Functions

Create reusable functions for common tasks:

```bash
# Print formatted section headers
print_section() {
    echo
    echo "════════════════════════════════════════"
    echo "  $1"
    echo "════════════════════════════════════════"
    echo
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# JSON output support
json_output() {
    local type="$1"
    local status="$2"
    local message="$3"
    
    if [[ "${JSON_OUTPUT:-false}" == "true" ]]; then
        jq -n \
            --arg type "$type" \
            --arg status "$status" \
            --arg message "$message" \
            '{type: $type, status: $status, message: $message}'
    fi
}
```

### Step 3: Implement Validators

Each validator should:
1. Source the helper library
2. Define what to validate
3. Implement validation logic
4. Support fix mode
5. Return appropriate exit codes

```bash
#!/bin/bash
# validate-security.sh

source "$SCRIPT_DIR/../helpers/validation-helpers.sh"

# Security checks
check_ssh_permissions() {
    if [[ -d "$HOME/.ssh" ]]; then
        local perms
        perms=$(stat -f "%OLp" "$HOME/.ssh" 2>/dev/null || stat -c "%a" "$HOME/.ssh")
        
        if [[ "$perms" != "700" ]]; then
            log_error "SSH directory has incorrect permissions: $perms"
            
            if is_fix_mode; then
                chmod 700 "$HOME/.ssh"
                log_fix "Fixed SSH directory permissions"
            fi
        else
            log_success "SSH directory permissions are correct"
        fi
    fi
}

# Run checks
check_ssh_permissions
check_git_credentials
check_env_secrets

print_summary
```

### Step 4: Add Reporting

Implement comprehensive reporting:

```bash
generate_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    print_section "VALIDATION SUMMARY REPORT"
    
    echo "Timestamp: $timestamp"
    echo "Host: $(hostname)"
    echo "User: $USER"
    echo
    
    echo "Scripts Run: ${#VALIDATION_SCRIPTS[@]}"
    echo "Passed: ${#PASSED_SCRIPTS[@]}"
    echo "Failed: ${#FAILED_SCRIPTS[@]}"
    echo
    
    echo "Total Issues Found:"
    echo "   Errors:   $TOTAL_ERRORS"
    echo "   Warnings: $TOTAL_WARNINGS"
    echo "   Fixed:    $TOTAL_FIXED"
    
    # Save to file
    local report_file="logs/validation/validation-$(date +%Y%m%d-%H%M%S).log"
    mkdir -p "$(dirname "$report_file")"
    {
        generate_report
    } | tee "$report_file"
}
```

## Advanced Features

### 1. Extensible Validation Framework

Make it easy to add new validators:

```bash
# Auto-discover validation scripts
VALIDATION_SCRIPTS=()
for script in validation/validate-*.sh; do
    if [[ -x "$script" ]]; then
        VALIDATION_SCRIPTS+=("$script")
    fi
done
```

### 2. Package Conflict Detection

Implement sophisticated conflict detection:

```bash
check_package_conflicts() {
    local package="$1"
    local managers=()
    
    # Check multiple package managers
    for manager in nix homebrew apt yum; do
        if package_installed_via "$package" "$manager"; then
            managers+=("$manager")
        fi
    done
    
    # Report conflicts
    if [[ ${#managers[@]} -gt 1 ]]; then
        log_error "$package installed via: ${managers[*]}"
        suggest_resolution "$package" "${managers[@]}"
    fi
}
```

### 3. Fix Mode with Rollback

Implement safe automated fixes:

```bash
fix_with_rollback() {
    local fix_function="$1"
    local rollback_function="$2"
    
    # Create backup
    create_backup
    
    # Attempt fix
    if ! $fix_function; then
        log_error "Fix failed, rolling back..."
        $rollback_function
        restore_backup
        return 1
    fi
    
    log_fix "Successfully applied fix"
    cleanup_backup
}
```

### 4. Parallel Validation

Run validators in parallel for large systems:

```bash
run_parallel_validation() {
    local pids=()
    
    for script in "${VALIDATION_SCRIPTS[@]}"; do
        "$script" "$@" &
        pids+=($!)
    done
    
    # Wait for all validators
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}
```

## Best Practices

### 1. Consistent Exit Codes

- 0: All validations passed
- 1: Validation errors found
- 2: Validator script error
- 3: Fix mode failure

### 2. Structured Output

```bash
# Use consistent output format
log_validation_result() {
    local component="$1"
    local status="$2"
    local details="$3"
    
    printf "%-30s %-10s %s\n" "$component" "[$status]" "$details"
}
```

### 3. Idempotent Fixes

Ensure fixes can be run multiple times safely:

```bash
fix_permission() {
    local file="$1"
    local expected="$2"
    
    # Check if already correct
    local current
    current=$(stat -f "%OLp" "$file" 2>/dev/null)
    
    if [[ "$current" == "$expected" ]]; then
        log_debug "Permissions already correct for $file"
        return 0
    fi
    
    # Apply fix
    chmod "$expected" "$file"
    log_fix "Fixed permissions for $file"
}
```

### 4. Environment Detection

Adapt validation to the environment:

```bash
detect_environment() {
    if [[ -n "${CI:-}" ]]; then
        echo "ci"
    elif [[ -n "${CODESPACES:-}" ]]; then
        echo "codespaces"
    elif [[ "$(uname)" == "Darwin" ]]; then
        echo "macos"
    else
        echo "linux"
    fi
}

# Run environment-specific validations
case $(detect_environment) in
    ci)
        VALIDATION_SCRIPTS+=("validation/validate-ci.sh")
        ;;
    macos)
        VALIDATION_SCRIPTS+=("validation/validate-homebrew.sh")
        ;;
esac
```

## Example Implementation

Here's a complete example for validating a Python project:

```bash
#!/bin/bash
# validate-python-project.sh

set -euo pipefail

source "helpers/validation-helpers.sh"

# Python-specific validations
validate_python_version() {
    local required_version="3.11"
    local current_version
    
    if ! command_exists python3; then
        log_error "Python 3 not installed"
        return 1
    fi
    
    current_version=$(python3 --version | cut -d' ' -f2)
    if [[ ! "$current_version" =~ ^$required_version ]]; then
        log_warn "Python version $current_version (expected $required_version.x)"
    else
        log_success "Python version $current_version"
    fi
}

validate_virtual_env() {
    if [[ -z "${VIRTUAL_ENV:-}" ]]; then
        log_warn "No virtual environment activated"
        
        if is_fix_mode && [[ -f "requirements.txt" ]]; then
            log_info "Creating virtual environment..."
            python3 -m venv venv
            source venv/bin/activate
            pip install -r requirements.txt
            log_fix "Created and activated virtual environment"
        fi
    else
        log_success "Virtual environment active: $VIRTUAL_ENV"
    fi
}

validate_dependencies() {
    if [[ ! -f "requirements.txt" ]]; then
        log_error "No requirements.txt found"
        return 1
    fi
    
    # Check for security vulnerabilities
    if command_exists safety; then
        if ! safety check --json; then
            log_warn "Security vulnerabilities found in dependencies"
        else
            log_success "No security vulnerabilities found"
        fi
    fi
}

# Run validations
print_section "Python Project Validation"
validate_python_version
validate_virtual_env
validate_dependencies
validate_code_quality
validate_tests

print_summary
```

## Conclusion

Building a comprehensive validation system provides:
- **Consistency**: Standardized checks across your entire system
- **Automation**: Fix common issues automatically
- **Visibility**: Clear reporting of system state
- **Extensibility**: Easy to add new validations
- **Maintainability**: Modular architecture

The key is to start simple and grow the system organically based on the issues you encounter. Focus on the validations that provide the most value and automate the fixes that are safe and repeatable.