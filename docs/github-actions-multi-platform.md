# GitHub Actions Multi-Platform Guide

This guide provides battle-tested patterns for cross-platform CI/CD with GitHub Actions, including platform-specific gotchas and solutions.

## Multi-Platform Matrix Strategy

### Basic Setup

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Test on ${{ matrix.os }}
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false  # Don't cancel other jobs if one fails
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        # Can also specify versions
        include:
          - os: ubuntu-20.04
            name: "Ubuntu 20.04 LTS"
          - os: macos-13
            name: "macOS 13 (Intel)"
          - os: macos-14
            name: "macOS 14 (Apple Silicon)"
```

## Platform-Specific Issues and Solutions

### macOS Specific

#### APFS and System Integrity Protection

```yaml
- name: Cleanup Nix (macOS)
  if: runner.os == 'macOS'
  continue-on-error: true  # APFS removal often fails in CI
  run: |
    # Note: Full cleanup requires disabling SIP and reboot
    # In CI, we can only do partial cleanup
    
    # Stop services
    sudo launchctl bootout system/org.nixos.nix-daemon || true
    sudo launchctl bootout system/org.nixos.darwin-store || true
    
    # Remove what we can
    sudo rm -rf /etc/nix /var/root/.nix-*
    
    # /nix removal usually fails due to APFS
    echo "Note: /nix removal requires reboot on macOS"
```

#### Homebrew in CI

```yaml
- name: Setup Homebrew (macOS)
  if: runner.os == 'macOS'
  run: |
    # Homebrew is pre-installed but may need updates
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_INSTALL_CLEANUP=1
    
    # Fix permissions issues
    sudo chown -R "$(whoami)" $(brew --prefix)/*
    
    # Install dependencies
    brew install coreutils gnu-sed
    
    # Add GNU tools to PATH
    echo "$(brew --prefix)/opt/coreutils/libexec/gnubin" >> $GITHUB_PATH
    echo "$(brew --prefix)/opt/gnu-sed/libexec/gnubin" >> $GITHUB_PATH
```

### Linux Specific

#### Package Installation

```yaml
- name: Install Dependencies (Linux)
  if: runner.os == 'Linux'
  run: |
    sudo apt-get update
    # Use -y for non-interactive
    sudo apt-get install -y \
      build-essential \
      curl \
      git \
      jq
      
    # For newer packages, might need to add repositories
    # sudo add-apt-repository ppa:example/ppa
    # sudo apt-get update
```

#### Systemd in Containers

```yaml
- name: Check systemd availability
  if: runner.os == 'Linux'
  run: |
    if pidof systemd > /dev/null; then
      echo "SYSTEMD_AVAILABLE=true" >> $GITHUB_ENV
    else
      echo "SYSTEMD_AVAILABLE=false" >> $GITHUB_ENV
      echo "::warning::systemd not available in container"
    fi
```

### Windows Specific

#### Path and Shell Issues

```yaml
- name: Windows Setup
  if: runner.os == 'Windows'
  shell: bash  # Use bash even on Windows
  run: |
    # Convert Windows paths to Unix style
    UNIX_PATH=$(cygpath -u "$GITHUB_WORKSPACE")
    echo "UNIX_WORKSPACE=$UNIX_PATH" >> $GITHUB_ENV
    
    # Handle line endings
    git config --global core.autocrlf false
```

## Cross-Platform Node.js Setup

### The Package-Lock Problem

```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version-file: '.nvmrc'  # or specify version
    
- name: Install Dependencies
  run: |
    # Remove package-lock to avoid platform issues
    rm -f package-lock.json
    
    # Install fresh
    npm install
    
    # Or use npm ci if package-lock is committed
    # But be aware of platform-specific packages
```

### Better Solution with Cache

```yaml
- name: Get npm cache directory
  id: npm-cache-dir
  shell: bash
  run: echo "dir=$(npm config get cache)" >> ${GITHUB_OUTPUT}

- uses: actions/cache@v3
  with:
    path: ${{ steps.npm-cache-dir.outputs.dir }}
    key: ${{ runner.os }}-node-${{ hashFiles('**/package.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

## Shell Portability

### Cross-Platform Shell Scripts

```yaml
- name: Run Cross-Platform Script
  shell: bash
  run: |
    # Always use bash for consistency
    # Available on all GitHub runners
    
    # Platform detection
    case "$RUNNER_OS" in
      Linux)
        echo "Running on Linux"
        INSTALL_CMD="sudo apt-get install -y"
        ;;
      macOS)
        echo "Running on macOS"
        INSTALL_CMD="brew install"
        ;;
      Windows)
        echo "Running on Windows"
        INSTALL_CMD="choco install -y"
        ;;
    esac
```

### Environment Variable Handling

```yaml
- name: Set Environment Variables
  shell: bash
  run: |
    # Works across all platforms
    echo "MY_VAR=value" >> $GITHUB_ENV
    
    # Path additions (cross-platform)
    echo "$HOME/.local/bin" >> $GITHUB_PATH
    
    # Multi-line values
    {
      echo 'MULTI_LINE<<EOF'
      echo 'first line'
      echo 'second line'
      echo 'EOF'
    } >> $GITHUB_ENV
```

## Debugging CI Failures

### Enhanced Debugging Output

```yaml
- name: Debug Environment
  if: failure()  # Only run on failure
  run: |
    echo "=== Environment Variables ==="
    env | sort
    
    echo "=== System Information ==="
    uname -a
    
    echo "=== Directory Structure ==="
    ls -la
    
    echo "=== Process List ==="
    ps aux || ps -ef
    
    echo "=== Disk Usage ==="
    df -h
    
    echo "=== Memory Usage ==="
    free -h 2>/dev/null || vm_stat
```

### Conditional Debugging

```yaml
- name: Enable Debug Mode
  if: contains(github.event.head_commit.message, '[debug]')
  run: echo "ACTIONS_STEP_DEBUG=true" >> $GITHUB_ENV

- name: Verbose Test Run
  run: |
    if [[ "$ACTIONS_STEP_DEBUG" == "true" ]]; then
      ./test.sh --verbose --debug
    else
      ./test.sh
    fi
```

## Artifact Handling

### Platform-Aware Artifacts

```yaml
- name: Prepare Artifacts
  if: always()  # Run even if tests fail
  run: |
    mkdir -p artifacts/logs
    mkdir -p artifacts/coverage
    
    # Collect logs
    find . -name "*.log" -exec cp {} artifacts/logs/ \; 2>/dev/null || true
    
    # Platform-specific artifacts
    case "$RUNNER_OS" in
      macOS)
        # Collect crash reports
        cp -r ~/Library/Logs/DiagnosticReports/* artifacts/logs/ 2>/dev/null || true
        ;;
      Linux)
        # Collect system logs
        sudo journalctl -u myservice > artifacts/logs/system.log 2>/dev/null || true
        ;;
    esac

- name: Upload Artifacts
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: test-artifacts-${{ matrix.os }}-${{ github.run_number }}
    path: artifacts/
    retention-days: 7
```

## Performance Optimization

### Parallel Jobs with Dependencies

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    outputs:
      cache-key: ${{ steps.cache.outputs.cache-key }}
    steps:
      - id: cache
        run: echo "cache-key=${{ hashFiles('**/package-lock.json') }}" >> $GITHUB_OUTPUT

  test:
    needs: setup
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        node: [18, 20]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/cache@v3
        with:
          path: ~/.npm
          key: ${{ needs.setup.outputs.cache-key }}
```

### Conditional Job Execution

```yaml
jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      docs: ${{ steps.filter.outputs.docs }}
      code: ${{ steps.filter.outputs.code }}
    steps:
      - uses: dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            docs:
              - 'docs/**'
              - '*.md'
            code:
              - 'src/**'
              - 'tests/**'

  test:
    needs: changes
    if: needs.changes.outputs.code == 'true'
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  docs:
    needs: changes
    if: needs.changes.outputs.docs == 'true'
    runs-on: ubuntu-latest
    steps:
      - run: npm run build:docs
```

## Security Best Practices

### Handling Secrets

```yaml
- name: Use Secrets Safely
  env:
    API_KEY: ${{ secrets.API_KEY }}
  run: |
    # Never echo secrets
    if [[ -z "$API_KEY" ]]; then
      echo "::error::API_KEY secret not set"
      exit 1
    fi
    
    # Mask any accidental output
    echo "::add-mask::$API_KEY"
    
    # Use in a way that doesn't expose in logs
    curl -H "Authorization: Bearer $API_KEY" https://api.example.com
```

## Common Patterns

### Retry Logic for Flaky Operations

```yaml
- name: Install with Retry
  uses: nick-fields/retry@v2
  with:
    timeout_minutes: 10
    max_attempts: 3
    shell: bash
    command: |
      # Flaky network operation
      curl -fsSL https://example.com/install.sh | bash
```

### Conditional Continue on Error

```yaml
- name: Optional Cleanup
  continue-on-error: ${{ matrix.os == 'macos-latest' }}
  run: |
    # This might fail on macOS but that's OK
    sudo rm -rf /some/system/path
```

### Matrix Exclusions

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, windows-latest]
    node: [16, 18, 20]
    exclude:
      # Node 16 doesn't work well on latest macOS
      - os: macos-latest
        node: 16
    include:
      # But test it on an older macOS
      - os: macos-12
        node: 16
```

## Debugging Tips

1. **Use `tmate` for interactive debugging**:
   ```yaml
   - name: Debug via SSH
     if: failure()
     uses: mxschmitt/action-tmate@v3
     with:
       limit-access-to-actor: true
   ```

2. **Check runner specifications**:
   - Ubuntu: 2-core CPU, 7 GB RAM, 14 GB SSD
   - macOS: 3-core CPU, 14 GB RAM, 14 GB SSD
   - Windows: 2-core CPU, 7 GB RAM, 14 GB SSD

3. **Time limits**:
   - Job timeout: 6 hours
   - Step timeout: 360 minutes
   - Workflow timeout: 35 days

4. **Known limitations**:
   - No nested virtualization
   - No audio/video devices
   - Limited sudo on macOS
   - No systemd on Ubuntu containers