# CI Environment Patterns

Patterns for making scripts and tools work seamlessly in both interactive and CI environments. These patterns help avoid common CI failures.

## Overview

Scripts often fail in CI because:
- No TTY available
- No user interaction possible
- Different environment variables
- Missing tools or different versions
- No color support

## CI Detection Patterns

### Universal CI Detection

```bash
#!/usr/bin/env bash
# Detect if running in CI environment

is_ci() {
    # Check common CI environment variables
    if [[ -n "${CI:-}" ]] || \
       [[ -n "${CONTINUOUS_INTEGRATION:-}" ]] || \
       [[ -n "${GITHUB_ACTIONS:-}" ]] || \
       [[ -n "${GITLAB_CI:-}" ]] || \
       [[ -n "${CIRCLECI:-}" ]] || \
       [[ -n "${TRAVIS:-}" ]] || \
       [[ -n "${JENKINS_URL:-}" ]] || \
       [[ -n "${BUILDKITE:-}" ]] || \
       [[ -n "${DRONE:-}" ]] || \
       [[ -n "${CODEBUILD_BUILD_ID:-}" ]] || \
       [[ -n "${TF_BUILD:-}" ]]; then
        return 0
    fi
    return 1
}

# Detect specific CI platform
detect_ci_platform() {
    if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
        echo "github"
    elif [[ -n "${GITLAB_CI:-}" ]]; then
        echo "gitlab"
    elif [[ -n "${CIRCLECI:-}" ]]; then
        echo "circleci"
    elif [[ -n "${TRAVIS:-}" ]]; then
        echo "travis"
    elif [[ -n "${JENKINS_URL:-}" ]]; then
        echo "jenkins"
    elif [[ -n "${BUILDKITE:-}" ]]; then
        echo "buildkite"
    elif [[ -n "${CODEBUILD_BUILD_ID:-}" ]]; then
        echo "aws-codebuild"
    elif [[ -n "${TF_BUILD:-}" ]]; then
        echo "azure-devops"
    elif is_ci; then
        echo "unknown-ci"
    else
        echo "local"
    fi
}
```

### TTY Detection

```bash
# Check if running in interactive terminal
is_interactive() {
    [[ -t 0 && -t 1 && -t 2 ]]
}

# Check if stdout supports colors
supports_color() {
    # CI often sets these
    if [[ -n "${NO_COLOR:-}" ]]; then
        return 1
    fi

    if [[ -n "${FORCE_COLOR:-}" ]] || [[ -n "${CLICOLOR_FORCE:-}" ]]; then
        return 0
    fi

    # Check terminal capability
    if is_interactive && command -v tput &>/dev/null; then
        [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]
    else
        return 1
    fi
}
```

## Smart Function Wrappers

### Auto-Confirm in CI

```bash
# Smart confirmation that auto-confirms in CI
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"

    if is_ci; then
        echo "$prompt [Auto-confirmed in CI: $default]"
        [[ "$default" =~ ^[Yy]$ ]]
        return $?
    fi

    # Interactive mode
    local response
    read -r -p "$prompt [y/N]: " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Usage example
if confirm "Deploy to production?" "y"; then
    echo "Deploying..."
fi
```

### Smart Input Functions

```bash
# Get input with CI fallback
get_input() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"

    if is_ci; then
        # In CI, use default or environment variable
        local value="${!var_name:-$default}"
        echo "$prompt: $value [auto-selected in CI]"
        echo "$value"
    else
        # Interactive mode
        read -r -p "$prompt [$default]: " value
        echo "${value:-$default}"
    fi
}

# Usage
PROJECT_NAME=$(get_input "Enter project name" "my-project" "PROJECT_NAME")
```

### Progress Indicators

```bash
# CI-friendly progress indicator
show_progress() {
    local task="$1"

    if is_ci; then
        # Simple output for CI logs
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] $task..."
    else
        # Spinner for interactive mode
        local spin='-\|/'
        local i=0

        while kill -0 $! 2>/dev/null; do
            i=$(( (i+1) %4 ))
            printf "\r$task ${spin:$i:1}"
            sleep .1
        done
        printf "\r$task ✓\n"
    fi
}

# Usage
long_running_task &
show_progress "Processing"
wait
```

## Color Output Management

```bash
# Color variables that respect CI/terminal capabilities
setup_colors() {
    if supports_color; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[0;33m'
        BLUE='\033[0;34m'
        PURPLE='\033[0;35m'
        CYAN='\033[0;36m'
        WHITE='\033[0;37m'
        BOLD='\033[1m'
        RESET='\033[0m'
    else
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        PURPLE=''
        CYAN=''
        WHITE=''
        BOLD=''
        RESET=''
    fi
}

# Usage
setup_colors
echo -e "${GREEN}✓ Success${RESET}"
echo -e "${RED}✗ Error${RESET}"
echo -e "${YELLOW}⚠ Warning${RESET}"
```

## Logging Patterns

```bash
# Structured logging for CI
log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')

    case "$level" in
        ERROR)
            echo -e "${timestamp} [${RED}ERROR${RESET}] $message" >&2
            ;;
        WARN)
            echo -e "${timestamp} [${YELLOW}WARN${RESET}] $message" >&2
            ;;
        INFO)
            echo -e "${timestamp} [${GREEN}INFO${RESET}] $message"
            ;;
        DEBUG)
            [[ -n "${DEBUG:-}" ]] && echo -e "${timestamp} [${BLUE}DEBUG${RESET}] $message"
            ;;
    esac

    # Also log to file if specified
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "${timestamp} [$level] $message" >> "$LOG_FILE"
    fi
}

# CI-specific logging with groups
log_group() {
    local group_name="$1"

    case "$(detect_ci_platform)" in
        github)
            echo "::group::$group_name"
            ;;
        gitlab)
            echo -e "\e[0Ksection_start:$(date +%s):${group_name}\r\e[0K$group_name"
            ;;
        travis)
            echo "travis_fold:start:$group_name"
            ;;
        *)
            echo "=== $group_name ==="
            ;;
    esac
}

log_group_end() {
    local group_name="$1"

    case "$(detect_ci_platform)" in
        github)
            echo "::endgroup::"
            ;;
        gitlab)
            echo -e "\e[0Ksection_end:$(date +%s):${group_name}\r\e[0K"
            ;;
        travis)
            echo "travis_fold:end:$group_name"
            ;;
        *)
            echo ""
            ;;
    esac
}
```

## CI-Specific Features

### GitHub Actions Annotations

```bash
# GitHub Actions specific annotations
github_annotation() {
    local type="$1"  # error, warning, notice
    local message="$2"
    local file="${3:-}"
    local line="${4:-}"

    if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
        if [[ -n "$file" && -n "$line" ]]; then
            echo "::$type file=$file,line=$line::$message"
        else
            echo "::$type::$message"
        fi
    else
        # Fallback for local
        case "$type" in
            error) log ERROR "$message" ;;
            warning) log WARN "$message" ;;
            notice) log INFO "$message" ;;
        esac
    fi
}

# Set output variables
set_ci_output() {
    local name="$1"
    local value="$2"

    case "$(detect_ci_platform)" in
        github)
            echo "$name=$value" >> "$GITHUB_OUTPUT"
            ;;
        gitlab)
            echo "$name=$value" >> .env
            ;;
        *)
            export "$name=$value"
            ;;
    esac
}
```

### Tool Installation

```bash
# Install tool only if missing
ensure_tool() {
    local tool="$1"
    local install_cmd="$2"

    if ! command -v "$tool" &>/dev/null; then
        if is_ci; then
            log INFO "Installing $tool in CI..."
            eval "$install_cmd"
        else
            log ERROR "$tool is required but not installed"
            log INFO "Install with: $install_cmd"
            return 1
        fi
    fi
}

# Examples
ensure_tool "jq" "apt-get update && apt-get install -y jq"
ensure_tool "yq" "wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && chmod +x /usr/local/bin/yq"
```

## Complete CI Helper Library

```bash
#!/usr/bin/env bash
# ci-helpers.sh - Complete CI helper library

set -euo pipefail

# Source this file in your scripts:
# source "$(dirname "$0")/ci-helpers.sh"

# Initialize
setup_colors
CI_PLATFORM=$(detect_ci_platform)
export CI_HELPERS_LOADED=1

# Convenience functions
ci_echo() {
    if is_ci; then
        echo "[CI/$CI_PLATFORM] $*"
    else
        echo "$*"
    fi
}

ci_run() {
    local cmd="$*"

    if is_ci; then
        log INFO "Running: $cmd"
        eval "$cmd"
    else
        if confirm "Run: $cmd?"; then
            eval "$cmd"
        fi
    fi
}

# Error handling
on_error() {
    local exit_code=$?
    local line_number=${1:-}

    if [[ $exit_code -ne 0 ]]; then
        github_annotation error "Script failed with exit code $exit_code" "${BASH_SOURCE[0]}" "$line_number"
        log ERROR "Script failed at line $line_number with exit code $exit_code"
    fi

    exit $exit_code
}

trap 'on_error ${LINENO}' ERR

# Export all functions
export -f is_ci is_interactive supports_color confirm get_input
export -f log log_group log_group_end github_annotation
export -f ensure_tool ci_echo ci_run
```

## Usage Example

```bash
#!/usr/bin/env bash
# deploy.sh - Example script using CI helpers

source "./ci-helpers.sh"

log_group "Deployment Setup"
log INFO "Starting deployment process"

# Get deployment target
TARGET=$(get_input "Deployment target" "staging" "DEPLOY_TARGET")
log INFO "Deploying to: $TARGET"

# Confirm deployment
if confirm "Deploy to $TARGET?" "y"; then
    log_group "Building Application"
    ci_run "npm install"
    ci_run "npm run build"
    log_group_end "Building Application"

    log_group "Running Tests"
    ci_run "npm test"
    log_group_end "Running Tests"

    log_group "Deploying"
    if [[ "$TARGET" == "production" ]]; then
        github_annotation warning "Deploying to production!"
    fi

    ci_run "./scripts/deploy-to-$TARGET.sh"
    log_group_end "Deploying"

    log INFO "Deployment completed successfully!"
    set_ci_output "deployment_url" "https://$TARGET.example.com"
else
    log WARN "Deployment cancelled"
    exit 1
fi

log_group_end "Deployment Setup"
```

## Best Practices

1. **Always Test Locally**
   - Set `CI=true` locally to test CI behavior
   - Use `--ci` flags in your scripts

2. **Fail Fast**
   - Use `set -euo pipefail`
   - Add proper error handling

3. **Be Verbose in CI**
   - CI logs are your only debugging tool
   - Log commands before running them

4. **Handle Timeouts**
   - CI environments have time limits
   - Add progress indicators for long tasks

5. **Cache Dependencies**
   - Use CI-specific caching
   - Check cache before installing

## External References

- [GitHub Actions Environment Variables](https://docs.github.com/en/actions/learn-github-actions/environment-variables)
- [GitLab CI Variables](https://docs.gitlab.com/ee/ci/variables/)
- [CircleCI Environment Variables](https://circleci.com/docs/env-vars/)
- [Jenkins Environment Variables](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#using-environment-variables)