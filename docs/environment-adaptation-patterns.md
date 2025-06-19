# Environment Adaptation Patterns

This guide documents patterns for making projects work seamlessly across different environments, platforms, and execution contexts.

## CI/Non-Interactive Handling

### Environment Detection

```bash
# Comprehensive CI detection
detect_ci_environment() {
    # Check common CI environment variables
    if [[ -n "${CI:-}" ]] || \
       [[ -n "${CONTINUOUS_INTEGRATION:-}" ]] || \
       [[ -n "${GITHUB_ACTIONS:-}" ]] || \
       [[ -n "${GITLAB_CI:-}" ]] || \
       [[ -n "${JENKINS_HOME:-}" ]] || \
       [[ -n "${CIRCLECI:-}" ]] || \
       [[ -n "${TRAVIS:-}" ]] || \
       [[ -n "${BUILDKITE:-}" ]] || \
       [[ -n "${DRONE:-}" ]]; then
        return 0  # In CI
    else
        return 1  # Not in CI
    fi
}

# Set appropriate flags
setup_environment() {
    if detect_ci_environment; then
        export CI_MODE=true
        export NONINTERACTIVE=1
        export DEBIAN_FRONTEND=noninteractive  # For apt-get
        export TERM=dumb  # Disable color/formatting that might break logs
        echo "🤖 CI environment detected - running in non-interactive mode"
    else
        export CI_MODE=false
        export INTERACTIVE=1
    fi
}
```

### Smart User Interaction

```bash
# Universal prompt function
prompt_user() {
    local prompt=$1
    local default=$2
    local options=${3:-}  # Optional: "yes/no", "1-5", etc.
    
    # In CI, always use defaults
    if [[ "${CI_MODE:-false}" == "true" ]]; then
        echo "$prompt"
        echo "→ Auto-selected (CI mode): $default"
        echo "$default"
        return
    fi
    
    # In interactive mode, actually prompt
    local response
    if [[ -n "$options" ]]; then
        read -p "$prompt [$options] (default: $default): " response
    else
        read -p "$prompt [$default]: " response
    fi
    
    echo "${response:-$default}"
}

# Confirmation with CI handling
confirm() {
    local prompt=$1
    local default=${2:-"n"}  # Default to "no" for safety
    
    if [[ "${CI_MODE:-false}" == "true" ]]; then
        echo "$prompt [Auto-confirming: $default]"
        [[ "$default" =~ ^[Yy]$ ]]
        return $?
    fi
    
    local response
    read -p "$prompt [y/N]: " response
    [[ "${response:-$default}" =~ ^[Yy]$ ]]
}

# Multi-choice selection
select_option() {
    local prompt=$1
    shift
    local options=("$@")
    
    if [[ "${CI_MODE:-false}" == "true" ]]; then
        echo "$prompt"
        echo "→ Auto-selected (CI mode): ${options[0]}"
        echo "${options[0]}"
        return
    fi
    
    echo "$prompt"
    select opt in "${options[@]}"; do
        if [[ -n "$opt" ]]; then
            echo "$opt"
            return
        fi
    done
}
```

### Progress and Output Management

```bash
# Adaptive progress indicator
show_progress() {
    local task=$1
    local current=${2:-}
    local total=${3:-}
    
    if [[ "${CI_MODE:-false}" == "true" ]]; then
        # Simple output for CI logs
        if [[ -n "$current" && -n "$total" ]]; then
            echo "[$current/$total] $task"
        else
            echo "→ $task"
        fi
    else
        # Interactive progress bar
        if [[ -n "$current" && -n "$total" ]]; then
            local percentage=$((current * 100 / total))
            local filled=$((percentage / 2))
            local empty=$((50 - filled))
            
            printf "\r[%s%s] %3d%% %s" \
                "$(printf '=%.0s' $(seq 1 $filled))" \
                "$(printf ' %.0s' $(seq 1 $empty))" \
                "$percentage" \
                "$task"
            
            if [[ $current -eq $total ]]; then
                echo " ✓"
            fi
        else
            echo "→ $task..."
        fi
    fi
}

# Conditional verbose output
debug_log() {
    local message=$1
    
    if [[ "${DEBUG:-false}" == "true" ]] || \
       [[ "${VERBOSE:-false}" == "true" ]] || \
       [[ "${CI_MODE:-false}" == "true" && "${CI_DEBUG:-false}" == "true" ]]; then
        echo "[DEBUG] $message" >&2
    fi
}
```

## Platform-Specific Adaptations

### Comprehensive Platform Detection

```bash
# Detect OS and architecture
detect_platform() {
    local os=""
    local arch=""
    local distro=""
    local version=""
    
    # Detect OS
    case "$(uname -s)" in
        Darwin*)
            os="macos"
            version=$(sw_vers -productVersion)
            # Detect macOS architecture
            if [[ "$(uname -m)" == "arm64" ]]; then
                arch="arm64"  # Apple Silicon
            else
                arch="amd64"  # Intel
            fi
            ;;
        Linux*)
            os="linux"
            arch=$(uname -m)
            # Detect Linux distribution
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                distro="$ID"
                version="$VERSION_ID"
            elif command -v lsb_release > /dev/null; then
                distro=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
                version=$(lsb_release -sr)
            fi
            # Check for WSL
            if grep -qi microsoft /proc/version 2>/dev/null; then
                os="wsl"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            os="windows"
            arch=$(uname -m)
            ;;
        *)
            os="unknown"
            arch=$(uname -m)
            ;;
    esac
    
    # Normalize architecture names
    case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        armv7l) arch="arm" ;;
    esac
    
    # Export results
    export OS="$os"
    export ARCH="$arch"
    export DISTRO="$distro"
    export VERSION="$version"
    
    debug_log "Platform: OS=$os, ARCH=$arch, DISTRO=$distro, VERSION=$version"
}
```

### Platform-Specific Commands

```bash
# Package manager abstraction
install_package() {
    local package=$1
    
    case "$OS" in
        macos)
            if command -v brew > /dev/null; then
                brew install "$package"
            else
                echo "Error: Homebrew not found. Install from https://brew.sh"
                return 1
            fi
            ;;
        linux|wsl)
            if command -v apt-get > /dev/null; then
                sudo apt-get update && sudo apt-get install -y "$package"
            elif command -v yum > /dev/null; then
                sudo yum install -y "$package"
            elif command -v pacman > /dev/null; then
                sudo pacman -S --noconfirm "$package"
            elif command -v zypper > /dev/null; then
                sudo zypper install -y "$package"
            elif command -v apk > /dev/null; then
                sudo apk add "$package"
            else
                echo "Error: No supported package manager found"
                return 1
            fi
            ;;
        windows)
            if command -v choco > /dev/null; then
                choco install -y "$package"
            elif command -v scoop > /dev/null; then
                scoop install "$package"
            else
                echo "Error: No package manager found. Install Chocolatey or Scoop"
                return 1
            fi
            ;;
    esac
}

# Command availability check with alternatives
ensure_command() {
    local primary_cmd=$1
    local package_name=${2:-$1}
    local alternatives=${3:-}
    
    # Check primary command
    if command -v "$primary_cmd" > /dev/null; then
        debug_log "Found command: $primary_cmd"
        return 0
    fi
    
    # Check alternatives
    if [[ -n "$alternatives" ]]; then
        for alt in $alternatives; do
            if command -v "$alt" > /dev/null; then
                debug_log "Using alternative: $alt (instead of $primary_cmd)"
                # Create alias
                alias "$primary_cmd"="$alt"
                return 0
            fi
        done
    fi
    
    # Try to install
    echo "Command '$primary_cmd' not found. Attempting to install..."
    if install_package "$package_name"; then
        return 0
    else
        echo "Error: Failed to install $package_name"
        return 1
    fi
}
```

### Path and Filesystem Handling

```bash
# Cross-platform path handling
normalize_path() {
    local path=$1
    
    case "$OS" in
        windows)
            # Convert Unix paths to Windows paths
            echo "$path" | sed 's|/|\\|g'
            ;;
        *)
            # Ensure forward slashes
            echo "$path" | sed 's|\\|/|g'
            ;;
    esac
}

# Platform-specific directory locations
get_config_dir() {
    case "$OS" in
        macos)
            echo "$HOME/Library/Application Support/${APP_NAME:-myapp}"
            ;;
        linux|wsl)
            echo "${XDG_CONFIG_HOME:-$HOME/.config}/${APP_NAME:-myapp}"
            ;;
        windows)
            echo "${APPDATA:-$HOME/AppData/Roaming}/${APP_NAME:-myapp}"
            ;;
    esac
}

get_cache_dir() {
    case "$OS" in
        macos)
            echo "$HOME/Library/Caches/${APP_NAME:-myapp}"
            ;;
        linux|wsl)
            echo "${XDG_CACHE_HOME:-$HOME/.cache}/${APP_NAME:-myapp}"
            ;;
        windows)
            echo "${LOCALAPPDATA:-$HOME/AppData/Local}/${APP_NAME:-myapp}/cache"
            ;;
    esac
}

# Safe temp directory creation
create_temp_dir() {
    local prefix=${1:-"tmp"}
    local temp_dir
    
    case "$OS" in
        macos|linux|wsl)
            temp_dir=$(mktemp -d "/tmp/${prefix}.XXXXXX")
            ;;
        windows)
            temp_dir=$(mktemp -d "${TEMP}/${prefix}.XXXXXX")
            ;;
    esac
    
    echo "$temp_dir"
}
```

### Shell and Terminal Handling

```bash
# Shell detection and configuration
configure_shell() {
    local shell_name=$(basename "${SHELL:-/bin/sh}")
    local config_file=""
    
    case "$shell_name" in
        bash)
            if [[ "$OS" == "macos" ]]; then
                config_file="$HOME/.bash_profile"
            else
                config_file="$HOME/.bashrc"
            fi
            ;;
        zsh)
            config_file="$HOME/.zshrc"
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            ;;
        *)
            echo "Warning: Unknown shell: $shell_name"
            config_file="$HOME/.profile"
            ;;
    esac
    
    echo "$config_file"
}

# Terminal capabilities
setup_terminal() {
    # Detect terminal capabilities
    if [[ -t 1 ]] && [[ "${TERM:-dumb}" != "dumb" ]]; then
        # Terminal supports colors
        export COLOR_SUPPORT=true
        export RED='\033[0;31m'
        export GREEN='\033[0;32m'
        export YELLOW='\033[1;33m'
        export BLUE='\033[0;34m'
        export NC='\033[0m'  # No Color
    else
        # No color support
        export COLOR_SUPPORT=false
        export RED=''
        export GREEN=''
        export YELLOW=''
        export BLUE=''
        export NC=''
    fi
    
    # Unicode support detection
    if locale -a 2>/dev/null | grep -qi utf-8; then
        export UNICODE_SUPPORT=true
        export CHECK_MARK="✓"
        export CROSS_MARK="✗"
        export ARROW="→"
    else
        export UNICODE_SUPPORT=false
        export CHECK_MARK="[OK]"
        export CROSS_MARK="[FAIL]"
        export ARROW="->"
    fi
}
```

## Docker and Container Detection

```bash
# Detect if running in a container
detect_container() {
    if [[ -f /.dockerenv ]]; then
        echo "docker"
    elif [[ -f /run/.containerenv ]]; then
        echo "podman"
    elif grep -q '/lxc/' /proc/1/cgroup 2>/dev/null; then
        echo "lxc"
    elif [[ -n "${KUBERNETES_SERVICE_HOST:-}" ]]; then
        echo "kubernetes"
    elif [[ -f /proc/1/environ ]] && grep -q "container=lxc" /proc/1/environ 2>/dev/null; then
        echo "lxc"
    else
        echo "none"
    fi
}

# Adjust behavior for containers
setup_container_environment() {
    local container_type=$(detect_container)
    
    if [[ "$container_type" != "none" ]]; then
        export IN_CONTAINER=true
        export CONTAINER_TYPE="$container_type"
        
        # Disable features that don't work in containers
        export NO_SYSTEMD=true
        export NO_SUDO_PROMPT=true
        
        # Use non-interactive package installation
        export DEBIAN_FRONTEND=noninteractive
        
        debug_log "Running in $container_type container"
    fi
}
```

## Network and Proxy Detection

```bash
# Detect and configure proxy settings
setup_proxy() {
    # Check for proxy environment variables
    if [[ -n "${HTTP_PROXY:-}" ]] || [[ -n "${http_proxy:-}" ]]; then
        export http_proxy="${http_proxy:-$HTTP_PROXY}"
        export https_proxy="${https_proxy:-$HTTPS_PROXY}"
        export no_proxy="${no_proxy:-$NO_PROXY}"
        
        # Configure tools to use proxy
        if command -v git > /dev/null; then
            git config --global http.proxy "$http_proxy"
            git config --global https.proxy "$https_proxy"
        fi
        
        if command -v npm > /dev/null; then
            npm config set proxy "$http_proxy"
            npm config set https-proxy "$https_proxy"
        fi
        
        debug_log "Proxy configured: $http_proxy"
    fi
}

# Check network connectivity
check_connectivity() {
    local test_urls=(
        "https://github.com"
        "https://google.com"
        "https://cloudflare.com"
    )
    
    for url in "${test_urls[@]}"; do
        if curl -s --head --max-time 5 "$url" > /dev/null; then
            debug_log "Network connectivity confirmed via $url"
            return 0
        fi
    done
    
    echo "Warning: No network connectivity detected"
    return 1
}
```

## Privilege and Permission Handling

```bash
# Smart sudo handling
run_with_privileges() {
    local command=$1
    shift
    local args=("$@")
    
    # If already root, just run the command
    if [[ $EUID -eq 0 ]]; then
        "$command" "${args[@]}"
        return $?
    fi
    
    # In CI or non-interactive, fail if not root
    if [[ "${CI_MODE:-false}" == "true" ]] || [[ "${NO_SUDO_PROMPT:-false}" == "true" ]]; then
        echo "Error: This operation requires root privileges"
        return 1
    fi
    
    # Check if user has sudo access
    if sudo -n true 2>/dev/null; then
        sudo "$command" "${args[@]}"
    elif command -v sudo > /dev/null; then
        echo "This operation requires administrator privileges."
        sudo "$command" "${args[@]}"
    else
        echo "Error: sudo not available and not running as root"
        return 1
    fi
}

# Check write permissions
ensure_writable() {
    local path=$1
    
    if [[ -w "$path" ]]; then
        return 0
    fi
    
    if [[ "${CI_MODE:-false}" == "true" ]]; then
        echo "Error: No write permission for $path"
        return 1
    fi
    
    echo "Need write permission for $path"
    if confirm "Attempt to fix permissions?"; then
        run_with_privileges chmod u+w "$path"
    else
        return 1
    fi
}
```

## Best Practices

1. **Always detect before assuming** - Check environment before using features
2. **Provide fallbacks** - Have alternatives when primary methods fail
3. **Fail gracefully** - Give helpful error messages
4. **Respect CI environments** - Never prompt or wait in CI
5. **Handle permissions carefully** - Don't assume sudo access
6. **Test across platforms** - Verify behavior on different OS/environments
7. **Document requirements** - Be clear about what's needed
8. **Use feature detection** - Check capabilities, not versions
9. **Minimize dependencies** - Use built-in tools when possible
10. **Provide escape hatches** - Let users override auto-detection