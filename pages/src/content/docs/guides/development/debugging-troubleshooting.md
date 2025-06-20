---
title: Debugging and Troubleshooting
description: Debugging and Troubleshooting - Comprehensive guide from agent-init
sidebar:
  order: 30
---

# Debugging and Troubleshooting Guide

This guide captures hard-won debugging knowledge from real projects. Learn from these experiences to avoid common pitfalls.

## Debugging Resources

- [How to Debug Bash Scripts](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html) - Official Bash debugging options
- [GitHub Actions Debugging](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/enabling-debug-logging)
- [Node.js Debugging Guide](https://nodejs.org/en/docs/guides/debugging-getting-started/)
- [Git Bisect Documentation](https://git-scm.com/docs/git-bisect) - Finding when bugs were introduced

## Documentation Site Issues

### The "Missing Pages" Problem

**Symptoms**: Astro/Starlight site builds successfully but only shows homepage and 404 page. All content pages are missing in production build.

**Root Cause**: Astro content collections require explicit syncing before build.

**Solution**:
```json
// package.json
{
  "scripts": {
    "build": "astro sync && astro check && astro build"
  }
}
```

**Prevention**:
1. Always run `astro sync` before building
2. Test production build locally: `npm run build && npm run preview`
3. If pages work in dev but not build, it's likely a sync issue

### Cross-Platform CI/CD Issues

**Problem**: Package-lock.json created on macOS causes build failures on Linux CI.

**Solution for GitHub Actions**:
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '18'

# Remove and regenerate package-lock.json
- name: Install dependencies
  run: |
    rm -f package-lock.json
    npm install
```

**Better Long-term Solution**:
- Use exact versions in package.json
- Consider using pnpm which handles cross-platform better
- Document platform requirements

## Testing Framework Design

### Comprehensive Test Structure

**Directory Layout**:
```
tests/
├── test_runner.sh          # Main test orchestrator
├── test_helpers.sh         # Shared assertion functions
├── bootstrap/              # Installation tests
│   └── test_*.sh
├── cleanup/                # Uninstallation tests
│   └── test_*.sh
└── integration/            # End-to-end tests
    └── test_*.sh
```

### Essential Test Helpers

```bash
# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  
            if grep -q Microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        *) echo "unknown" ;;
    esac
}

# CI detection
is_ci() {
    [[ -n "${CI:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]]
}

# Skip test with reason
skip_test() {
    local reason="$1"
    echo "SKIPPED: $reason"
    ((TESTS_SKIPPED++))
    exit 0
}
```

### Assertion Functions

```bash
# Check command exists and works
assert_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        fail "Command '$cmd' not found"
    fi
    if ! "$cmd" --version >/dev/null 2>&1; then
        fail "Command '$cmd' exists but fails to run"
    fi
}

# Check file/directory with helpful errors
assert_file() {
    local file="$1"
    [[ -f "$file" ]] || fail "File not found: $file"
}

assert_directory() {
    local dir="$1"
    [[ -d "$dir" ]] || fail "Directory not found: $dir"
}
```

## CI/CD Platform-Specific Issues

### macOS CI Limitations

**APFS Volume Removal**:
```yaml
# Often fails in CI - handle gracefully
- name: Cleanup
  continue-on-error: true
  run: |
    # APFS removal requires sudo and often times out
    # Better to document as "requires manual cleanup"
```

**Nix on macOS**:
- Daemon persists after uninstall
- /nix directory requires reboot to remove
- Exit code 138 = killed by system

**Best Practice**: Document these as known limitations rather than test failures.

### Linux CI Considerations

**Systemd in Containers**:
```bash
# Check if systemd is available
if pidof systemd >/dev/null; then
    # Full systemd available
else
    # Container environment - skip systemd tests
fi
```

## Common Debugging Patterns

### Environment Variable Debugging

```bash
# Debug PATH issues
debug_path() {
    echo "=== PATH Debug ==="
    echo "PATH=$PATH"
    echo "Components:"
    echo "$PATH" | tr ':' '\n' | nl
    echo "================="
}

# Debug sourcing issues
debug_env() {
    echo "=== Environment ==="
    echo "SHELL=$SHELL"
    echo "HOME=$HOME"
    echo "USER=$USER"
    printenv | grep -E "NIX|HOMEBREW" | sort
    echo "=================="
}
```

### Test Output Best Practices

```bash
# Verbose mode for debugging
if [[ "$VERBOSE" == "true" ]]; then
    set -x  # Print commands
fi

# Capture both stdout and stderr
output=$(command 2>&1) || {
    echo "Command failed with exit code $?"
    echo "Output: $output"
    exit 1
}
```

## Issue Tracking and Documentation

### Commit Message Patterns for Debugging

```bash
# When debugging, use descriptive commits
git commit -m "debug: add verbose output to installation test

- Add set -x to trace command execution
- Capture stderr for npm install failures
- Print environment variables before test

Related to #15"
```

### Document Failed Attempts

Always document what didn't work:

```markdown
## Attempted Solutions That Failed

1. **Manual sidebar configuration** - Too brittle, missed pages
2. **CSS theme overrides** - Caused more problems than solved
3. **Caching node_modules in CI** - Platform differences
```

## Testing Best Practices

### Progressive Test Development

1. **Start with smoke tests** - Basic functionality
2. **Add verification tests** - Detailed checks
3. **Include cleanup tests** - Ensure reversibility
4. **Add edge case tests** - Platform-specific issues

### Handle Known Failures

```bash
# Example: APFS removal on macOS CI
cleanup_nix() {
    if is_ci && [[ "$(detect_platform)" == "macos" ]]; then
        echo "WARNING: /nix removal requires reboot on macOS"
        echo "This is expected in CI environment"
        return 0
    fi
    # Actual cleanup for local environment
}
```

## Debugging Workflows

### When Tests Pass Locally but Fail in CI

1. **Check for environment differences**:
   ```bash
   # Add to test
   env | sort > local-env.txt
   # Add to CI
   env | sort > ci-env.txt
   # Compare
   ```

2. **Check for timing issues**:
   ```bash
   # Add waits for async operations
   sleep 2  # Give services time to start
   ```

3. **Check for missing dependencies**:
   ```bash
   # List all commands used
   grep -h "command\|which\|type" *.sh | sort -u
   ```

### Debugging Build Failures

1. **Enable verbose output**:
   ```json
   "build": "npm run build -- --verbose"
   ```

2. **Check intermediate steps**:
   ```bash
   # Run build steps individually
   npm run step1
   echo "Step 1 exit code: $?"
   ls -la output/
   ```

3. **Compare working vs broken**:
   ```bash
   # On working system
   find . -type f -name "*.json" | sort > working.txt
   # On broken system  
   find . -type f -name "*.json" | sort > broken.txt
   diff working.txt broken.txt
   ```

## Key Learnings

1. **Test the full lifecycle** - Install, use, and uninstall
2. **Document platform differences** - Don't hide them
3. **Fail fast with clear messages** - Help future debuggers
4. **Keep debugging artifacts** - Comments, failed attempts
5. **Use warnings for known issues** - Don't fail on unfixable
6. **Test in CI early and often** - Catch issues before merge