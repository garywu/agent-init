---
title: Testing Framework Guide
description: Testing Framework Guide - Comprehensive guide from agent-init
sidebar:
  order: 10
---

# Testing Framework Guide

This guide shows how to build a comprehensive testing framework for shell-based projects, based on real-world experience.

## Essential Documentation References

- [Bash Manual - Shell Functions](https://www.gnu.org/software/bash/manual/html_node/Shell-Functions.html)
- [ShellCheck Wiki](https://www.shellcheck.net/wiki/Home) - Common shell script issues
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)

## Framework Architecture

### Core Components

```
tests/
├── test_runner.sh          # Main orchestrator
├── test_helpers.sh         # Shared utilities
├── fixtures/               # Test data
└── suites/                 # Organized test groups
    ├── unit/              # Fast, isolated tests
    ├── integration/       # Full workflow tests
    └── smoke/            # Basic sanity checks
```

## Test Runner Design

### Command Line Interface

```bash
# test_runner.sh
usage() {
    cat << EOF
Usage: $0 [OPTIONS] [TEST_SUITE]

Options:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -q, --quiet     Suppress non-error output
    --ci            Run in CI mode (non-interactive)

Test Suites:
    all             Run all tests (default)
    smoke           Quick sanity checks
    unit            Fast isolated tests
    integration     Full system tests
    specific_test   Run single test file

Examples:
    $0                      # Run everything
    $0 smoke               # Quick check
    $0 --ci integration    # CI full tests
    $0 test_bootstrap.sh   # Single test
EOF
}
```

### Platform Detection

```bash
# Detect operating system and environment
detect_platform() {
    local platform="unknown"
    local version=""

    case "$(uname -s)" in
        Darwin*)
            platform="macos"
            version=$(sw_vers -productVersion)
            ;;
        Linux*)
            platform="linux"
            if [[ -f /etc/os-release ]]; then
                source /etc/os-release
                version="$ID $VERSION_ID"
            fi
            # Check for WSL
            if grep -q Microsoft /proc/version 2>/dev/null; then
                platform="wsl"
            fi
            ;;
    esac

    echo "$platform"
    [[ -n "$version" ]] && echo "Version: $version" >&2
}

# Check if running in CI
is_ci() {
    [[ -n "${CI:-}" ]] || \
    [[ -n "${GITHUB_ACTIONS:-}" ]] || \
    [[ -n "${JENKINS_HOME:-}" ]] || \
    [[ -n "${GITLAB_CI:-}" ]]
}
```

## Test Helper Functions

### Assertions Library

```bash
# test_helpers.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Core assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"

    if [[ "$expected" == "$actual" ]]; then
        pass "$message"
    else
        fail "$message\n  Expected: '$expected'\n  Actual:   '$actual'"
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should contain substring}"

    if [[ "$haystack" == *"$needle"* ]]; then
        pass "$message"
    else
        fail "$message\n  String: '$haystack'\n  Missing: '$needle'"
    fi
}

assert_command() {
    local cmd="$1"
    local message="${2:-Command should exist: $cmd}"

    if command -v "$cmd" >/dev/null 2>&1; then
        pass "$message"
    else
        fail "$message"
    fi
}

assert_file() {
    local file="$1"
    local message="${2:-File should exist: $file}"

    if [[ -f "$file" ]]; then
        pass "$message"
    else
        fail "$message"
    fi
}

assert_directory() {
    local dir="$1"
    local message="${2:-Directory should exist: $dir}"

    if [[ -d "$dir" ]]; then
        pass "$message"
    else
        fail "$message"
    fi
}

assert_symlink() {
    local link="$1"
    local message="${2:-Symlink should exist: $link}"

    if [[ -L "$link" ]]; then
        pass "$message"
    else
        fail "$message"
    fi
}
```

### Test Flow Control

```bash
# Setup and teardown
setup() {
    # Create temporary test directory
    TEST_DIR=$(mktemp -d)
    export TEST_DIR

    # Save original state
    ORIGINAL_PATH="$PATH"
    ORIGINAL_HOME="$HOME"

    # Set up test environment
    export HOME="$TEST_DIR/home"
    mkdir -p "$HOME"
}

teardown() {
    # Restore original state
    export PATH="$ORIGINAL_PATH"
    export HOME="$ORIGINAL_HOME"

    # Clean up test directory
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# Skip test with reason
skip_test() {
    local reason="$1"
    echo -e "${YELLOW}SKIPPED${NC}: $reason"
    ((TESTS_SKIPPED++))
    exit 0
}

# Mark test as passed
pass() {
    local message="$1"
    echo -e "${GREEN}✓${NC} $message"
    ((TESTS_PASSED++))
}

# Mark test as failed
fail() {
    local message="$1"
    echo -e "${RED}✗${NC} $message"
    ((TESTS_FAILED++))

    # Optionally exit on first failure
    if [[ "${FAIL_FAST:-}" == "true" ]]; then
        exit 1
    fi
}
```

## Writing Effective Tests

### Test Structure

```bash
#!/bin/bash
# test_example.sh

# Source test helpers
source "$(dirname "$0")/../test_helpers.sh"

# Test metadata
describe "Feature: User Authentication"

# Skip conditions
[[ "$(detect_platform)" == "wsl" ]] && skip_test "Not supported on WSL"
is_ci && [[ -z "$API_KEY" ]] && skip_test "API_KEY required in CI"

# Setup
setup() {
    # Test-specific setup
    mkdir -p "$TEST_DIR/config"
    echo "test_user" > "$TEST_DIR/config/user"
}

# Teardown
teardown() {
    # Test-specific cleanup
    rm -rf "$TEST_DIR/config"
}

# Actual tests
test_user_creation() {
    # Arrange
    local username="testuser"

    # Act
    ./create_user.sh "$username" > "$TEST_DIR/output.log" 2>&1
    local exit_code=$?

    # Assert
    assert_equals 0 "$exit_code" "User creation should succeed"
    assert_file "$HOME/.config/users/$username" "User file should exist"
    assert_contains "$(cat "$TEST_DIR/output.log")" "created successfully"
}

test_duplicate_user() {
    # Create user first
    ./create_user.sh "testuser"

    # Try to create again
    ./create_user.sh "testuser" 2>&1 | tee "$TEST_DIR/error.log"
    local exit_code=${PIPESTATUS[0]}

    assert_equals 1 "$exit_code" "Duplicate user should fail"
    assert_contains "$(cat "$TEST_DIR/error.log")" "already exists"
}

# Run tests
run_test test_user_creation
run_test test_duplicate_user

# Summary
print_summary
```

### Integration Tests

```bash
# test_integration.sh

test_full_workflow() {
    describe "Full installation and configuration workflow"

    # Install
    run_step "Installation" <<-'EOF'
        ./install.sh --prefix="$TEST_DIR/local"
        assert_directory "$TEST_DIR/local/bin"
        assert_file "$TEST_DIR/local/bin/myapp"
    EOF

    # Configure
    run_step "Configuration" <<-'EOF'
        export PATH="$TEST_DIR/local/bin:$PATH"
        myapp init
        assert_file "$HOME/.myapp/config.yml"
    EOF

    # Use
    run_step "Basic usage" <<-'EOF'
        output=$(myapp hello world)
        assert_contains "$output" "Hello, world!"
    EOF

    # Cleanup
    run_step "Uninstallation" <<-'EOF'
        ./uninstall.sh --prefix="$TEST_DIR/local"
        assert_not_exists "$TEST_DIR/local/bin/myapp"
    EOF
}
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        test-suite: [smoke, unit, integration]

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4

      - name: Setup test environment
        run: |
          # Install test dependencies
          if [[ "$RUNNER_OS" == "Linux" ]]; then
            sudo apt-get update
            sudo apt-get install -y bc jq
          elif [[ "$RUNNER_OS" == "macOS" ]]; then
            brew install coreutils jq
          fi

      - name: Run tests
        run: |
          ./tests/test_runner.sh --ci ${{ matrix.test-suite }}
        env:
          CI: true

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results-${{ matrix.os }}-${{ matrix.test-suite }}
          path: |
            tests/results/
            tests/*.log
```

### Handling CI-Specific Issues

```bash
# In test files
if is_ci; then
    # CI-specific behavior
    export NONINTERACTIVE=1
    export DEBIAN_FRONTEND=noninteractive

    # Skip tests that can't run in CI
    [[ "$TEST_NAME" == "test_gui" ]] && skip_test "GUI not available in CI"

    # Adjust timeouts
    TIMEOUT=60  # Longer timeout in CI
else
    # Local development
    TIMEOUT=10
fi

# Platform + CI combinations
if is_ci && [[ "$(detect_platform)" == "macos" ]]; then
    # macOS CI specific workarounds
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_INSTALL_CLEANUP=1
fi
```

## Best Practices

### 1. Test Organization

- **Smoke tests**: 5-10 seconds, basic sanity
- **Unit tests**: < 1 minute, specific functions
- **Integration tests**: < 5 minutes, full workflows

### 2. Test Independence

```bash
# Each test should be independent
test_one() {
    setup_test_one
    # test code
    cleanup_test_one
}

# Don't rely on test order
TESTS=$(find tests -name "test_*.sh" | sort)
for test in $TESTS; do
    bash "$test" || echo "Failed: $test"
done
```

### 3. Helpful Error Messages

```bash
# Bad
assert_file "$config"

# Good
assert_file "$config" "Config file missing. Run 'myapp init' first?"

# Better
assert_file "$config" || {
    echo "Debug info:"
    echo "  PWD: $PWD"
    echo "  HOME: $HOME"
    echo "  Looking for: $config"
    ls -la "$(dirname "$config")" 2>/dev/null || echo "  Parent dir missing"
    fail "Config file not found"
}
```

### 4. Test Data Management

```bash
# Use fixtures for test data
FIXTURES_DIR="$(dirname "$0")/fixtures"

# Copy fixtures to test directory
cp -r "$FIXTURES_DIR/sample_config" "$TEST_DIR/"

# Generate test data programmatically
generate_test_file() {
    local size=$1
    local file=$2
    dd if=/dev/urandom of="$file" bs=1024 count="$size" 2>/dev/null
}
```

### 5. Performance Testing

```bash
# Simple performance assertions
test_performance() {
    local start=$(date +%s)

    # Run operation
    ./slow_operation.sh

    local end=$(date +%s)
    local duration=$((end - start))

    assert_less_than "$duration" 5 "Operation should complete within 5 seconds"
}

# More sophisticated with hyperfine
test_benchmark() {
    if command -v hyperfine >/dev/null; then
        hyperfine --export-json "$TEST_DIR/benchmark.json" \
            './operation.sh' \
            './optimized_operation.sh'

        # Analyze results
        jq '.results[1].median < .results[0].median' "$TEST_DIR/benchmark.json" \
            || fail "Optimized version is not faster"
    else
        skip_test "hyperfine not available"
    fi
}
```

## Debugging Test Failures

### Enable Debug Mode

```bash
# test_runner.sh additions
if [[ "${DEBUG:-}" == "true" ]]; then
    set -x  # Print all commands
    export PS4='+ ${BASH_SOURCE##*/}:${LINENO} '  # Better trace output
fi

# Usage
DEBUG=true ./test_runner.sh failing_test
```

### Capture Detailed Output

```bash
# Run test with full output capture
run_test_with_output() {
    local test_name="$1"
    local log_file="$TEST_DIR/${test_name}.log"

    {
        echo "=== Test: $test_name ==="
        echo "Date: $(date)"
        echo "Platform: $(detect_platform)"
        echo "PWD: $PWD"
        echo "Environment:"
        env | sort
        echo "=== Test Output ==="

        # Run test
        "$test_name" 2>&1

    } | tee "$log_file"

    return ${PIPESTATUS[0]}
}
```

This framework provides a solid foundation for testing shell-based projects with proper error handling, CI/CD support, and debugging capabilities.