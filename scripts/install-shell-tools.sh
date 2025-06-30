#!/usr/bin/env bash
# install-shell-tools.sh - Cross-platform shell toolchain installation
#
# Installs shellcheck, shfmt, and shellharden across different platforms
# Supports: macOS (Homebrew), Linux (package managers), Windows (Chocolatey/winget)
#
# Usage: ./install-shell-tools.sh [--help] [--verbose]

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Configuration
VERBOSE=false

# Print functions
print_status() {
  local status=$1
  local message=$2
  case $status in
  "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
  "PASS") echo -e "${GREEN}[✓]${NC} $message" ;;
  "INSTALL") echo -e "${YELLOW}[INSTALL]${NC} $message" ;;
  "ERROR") echo -e "${RED}[✗]${NC} $message" ;;
  "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ;;
  esac
}

print_header() {
  echo ""
  echo -e "${BOLD}${BLUE}================================================================${NC}"
  echo -e "${BOLD}${BLUE}  $1${NC}"
  echo -e "${BOLD}${BLUE}================================================================${NC}"
  echo ""
}

# Detect operating system
detect_os() {
  case "$(uname -s)" in
  Linux*) echo "linux" ;;
  Darwin*) echo "macos" ;;
  MINGW* | MSYS* | CYGWIN*) echo "windows" ;;
  *) echo "unknown" ;;
  esac
}

# Detect Linux distribution
detect_linux_distro() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    echo "${ID:-unknown}"
  elif command -v lsb_release >/dev/null 2>&1; then
    lsb_release -si | tr '[:upper:]' '[:lower:]'
  else
    echo "unknown"
  fi
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if tool is already installed
check_tool_installed() {
  local tool=$1
  if command_exists "$tool"; then
    local version
    case $tool in
    shellcheck) version=$(shellcheck --version | grep "version:" | awk '{print $2}') ;;
    shfmt) version=$(shfmt --version 2>/dev/null || echo "unknown") ;;
    shellharden) version=$(shellharden --version 2>/dev/null | head -1 || echo "unknown") ;;
    *) version="unknown" ;;
    esac
    print_status "PASS" "$tool is already installed (version: $version)"
    return 0
  fi
  return 1
}

# Install tools on macOS
install_macos() {
  print_header "Installing Shell Tools on macOS"

  # Check if Homebrew is available
  if ! command_exists brew; then
    print_status "ERROR" "Homebrew not found. Please install Homebrew first:"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    return 1
  fi

  # Install shellcheck
  if ! check_tool_installed shellcheck; then
    print_status "INSTALL" "Installing shellcheck via Homebrew..."
    brew install shellcheck
  fi

  # Install shfmt
  if ! check_tool_installed shfmt; then
    print_status "INSTALL" "Installing shfmt via Homebrew..."
    brew install shfmt
  fi

  # Install shellharden via cargo if available, otherwise suggest manual installation
  if ! check_tool_installed shellharden; then
    if command_exists cargo; then
      print_status "INSTALL" "Installing shellharden via Cargo..."
      cargo install shellharden
    else
      print_status "WARN" "Cargo not found. To install shellharden:"
      echo "  1. Install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
      echo "  2. Then run: cargo install shellharden"
      echo "  3. Or use precompiled binary from: https://github.com/anordal/shellharden/releases"
    fi
  fi
}

# Install tools on Linux
install_linux() {
  local distro
  distro=$(detect_linux_distro)
  print_header "Installing Shell Tools on Linux ($distro)"

  case $distro in
  ubuntu | debian)
    # Update package list
    print_status "INFO" "Updating package list..."
    sudo apt-get update -qq

    # Install shellcheck
    if ! check_tool_installed shellcheck; then
      print_status "INSTALL" "Installing shellcheck via apt..."
      sudo apt-get install -y shellcheck
    fi

    # Install shfmt (may need to use go install or download binary)
    if ! check_tool_installed shfmt; then
      if command_exists go; then
        print_status "INSTALL" "Installing shfmt via Go..."
        go install mvdan.cc/sh/v3/cmd/shfmt@latest
      else
        print_status "INSTALL" "Downloading shfmt binary..."
        local shfmt_version="v3.7.0"
        local arch
        arch=$(uname -m)
        case $arch in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *) arch="amd64" ;; # Default fallback
        esac

        wget -O /tmp/shfmt "https://github.com/mvdan/sh/releases/download/${shfmt_version}/shfmt_${shfmt_version}_linux_${arch}"
        chmod +x /tmp/shfmt
        sudo mv /tmp/shfmt /usr/local/bin/shfmt
      fi
    fi
    ;;

  fedora | rhel | centos)
    # Install shellcheck
    if ! check_tool_installed shellcheck; then
      print_status "INSTALL" "Installing shellcheck via dnf/yum..."
      if command_exists dnf; then
        sudo dnf install -y ShellCheck
      elif command_exists yum; then
        sudo yum install -y ShellCheck
      fi
    fi

    # Install shfmt via Go or binary download
    if ! check_tool_installed shfmt; then
      if command_exists go; then
        print_status "INSTALL" "Installing shfmt via Go..."
        go install mvdan.cc/sh/v3/cmd/shfmt@latest
      else
        print_status "INSTALL" "Downloading shfmt binary..."
        local shfmt_version="v3.7.0"
        local arch
        arch=$(uname -m)
        case $arch in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *) arch="amd64" ;;
        esac

        curl -sSfL "https://github.com/mvdan/sh/releases/download/${shfmt_version}/shfmt_${shfmt_version}_linux_${arch}" -o /tmp/shfmt
        chmod +x /tmp/shfmt
        sudo mv /tmp/shfmt /usr/local/bin/shfmt
      fi
    fi
    ;;

  arch)
    # Install shellcheck
    if ! check_tool_installed shellcheck; then
      print_status "INSTALL" "Installing shellcheck via pacman..."
      sudo pacman -S --noconfirm shellcheck
    fi

    # Install shfmt
    if ! check_tool_installed shfmt; then
      print_status "INSTALL" "Installing shfmt via pacman..."
      sudo pacman -S --noconfirm shfmt
    fi
    ;;

  alpine)
    # Install shellcheck
    if ! check_tool_installed shellcheck; then
      print_status "INSTALL" "Installing shellcheck via apk..."
      sudo apk add --no-cache shellcheck
    fi

    # Install shfmt via Go or binary
    if ! check_tool_installed shfmt; then
      if command_exists go; then
        print_status "INSTALL" "Installing shfmt via Go..."
        go install mvdan.cc/sh/v3/cmd/shfmt@latest
      else
        print_status "WARN" "Go not available. Please install Go or download shfmt manually:"
        echo "  https://github.com/mvdan/sh/releases"
      fi
    fi
    ;;

  *)
    print_status "WARN" "Unsupported Linux distribution: $distro"
    print_status "INFO" "Try installing manually:"
    echo "  - shellcheck: https://github.com/koalaman/shellcheck#installing"
    echo "  - shfmt: https://github.com/mvdan/sh#shfmt"
    echo "  - shellharden: cargo install shellharden"
    ;;
  esac

  # Install shellharden via cargo
  if ! check_tool_installed shellharden; then
    if command_exists cargo; then
      print_status "INSTALL" "Installing shellharden via Cargo..."
      cargo install shellharden
    else
      print_status "WARN" "Cargo not found. To install shellharden:"
      echo "  1. Install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
      echo "  2. Then run: cargo install shellharden"
    fi
  fi
}

# Install tools on Windows
install_windows() {
  print_header "Installing Shell Tools on Windows"

  # Try Chocolatey first, then winget
  if command_exists choco; then
    print_status "INFO" "Using Chocolatey for installation..."

    if ! check_tool_installed shellcheck; then
      print_status "INSTALL" "Installing shellcheck via Chocolatey..."
      choco install shellcheck -y
    fi

    # Note: shfmt and shellharden may not be available via Chocolatey
    print_status "WARN" "shfmt and shellharden may need manual installation on Windows"

  elif command_exists winget; then
    print_status "INFO" "Using winget for installation..."

    if ! check_tool_installed shellcheck; then
      print_status "INSTALL" "Installing shellcheck via winget..."
      winget install koalaman.shellcheck
    fi

  else
    print_status "ERROR" "Neither Chocolatey nor winget found."
    print_status "INFO" "Please install tools manually:"
    echo "  - shellcheck: https://github.com/koalaman/shellcheck#installing"
    echo "  - shfmt: https://github.com/mvdan/sh#shfmt"
    echo "  - shellharden: cargo install shellharden (requires Rust)"
  fi
}

# Install via Nix (cross-platform alternative)
install_nix() {
  print_header "Installing Shell Tools via Nix"

  if ! command_exists nix-env; then
    print_status "ERROR" "Nix not found. Install Nix package manager first:"
    echo "  curl -L https://nixos.org/nix/install | sh"
    return 1
  fi

  # Install all tools via Nix
  if ! check_tool_installed shellcheck; then
    print_status "INSTALL" "Installing shellcheck via Nix..."
    nix-env -iA nixpkgs.shellcheck
  fi

  if ! check_tool_installed shfmt; then
    print_status "INSTALL" "Installing shfmt via Nix..."
    nix-env -iA nixpkgs.shfmt
  fi

  # Note: shellharden is not in nixpkgs, still need cargo
  if ! check_tool_installed shellharden; then
    if command_exists cargo; then
      print_status "INSTALL" "Installing shellharden via Cargo..."
      cargo install shellharden
    else
      print_status "WARN" "shellharden requires Rust/Cargo installation"
    fi
  fi
}

# Verify installation
verify_installation() {
  print_header "Verifying Installation"

  local success=0

  # Check each tool
  for tool in shellcheck shfmt shellharden; do
    if check_tool_installed "$tool"; then
      success=$((success + 1))
    else
      print_status "ERROR" "$tool is not available"
    fi
  done

  if [[ $success -eq 3 ]]; then
    print_status "PASS" "All shell tools successfully installed!"

    # Show usage example
    echo ""
    echo -e "${BOLD}${GREEN}Quick Start:${NC}"
    echo "  1. Copy configuration files: cp templates/.shellcheckrc templates/.shfmt ."
    echo "  2. Run fixes: make fix-shell"
    echo "  3. Check scripts: make lint-shell"
    echo ""

    return 0
  else
    print_status "WARN" "Some tools could not be installed ($success/3 successful)"
    echo ""
    echo -e "${BOLD}${YELLOW}Manual Installation Options:${NC}"
    echo "  - Download precompiled binaries from GitHub releases"
    echo "  - Use language-specific package managers (cargo, go install)"
    echo "  - Install Nix package manager for universal solution"
    echo ""

    return 1
  fi
}

# Show help
show_help() {
  cat <<EOF
install-shell-tools.sh - Cross-platform shell toolchain installation

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --help, -h      Show this help message
    --verbose, -v   Enable verbose output
    --nix          Use Nix package manager (cross-platform)

TOOLS INSTALLED:
    shellcheck     Static analysis tool for shell scripts
    shfmt          Shell script formatter
    shellharden    Shell script security hardening tool

SUPPORTED PLATFORMS:
    macOS          Via Homebrew
    Linux          Via distribution package managers (apt, dnf, pacman, apk)
    Windows        Via Chocolatey or winget
    Universal      Via Nix package manager

EXAMPLES:
    $0                    # Install using platform-specific method
    $0 --nix             # Install using Nix (cross-platform)
    $0 --verbose         # Install with detailed output

AFTER INSTALLATION:
    1. Copy configuration files from templates/
    2. Run 'make fix-shell' to apply automated fixes
    3. Run 'make lint-shell' to check script quality

EOF
}

# Parse command line arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    --help | -h)
      show_help
      exit 0
      ;;
    --verbose | -v)
      VERBOSE=true
      shift
      ;;
    --nix)
      USE_NIX=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
    esac
  done
}

# Main installation function
main() {
  parse_args "$@"

  print_header "Shell Script Toolchain Installation"

  local os
  os=$(detect_os)
  print_status "INFO" "Detected OS: $os"

  # Use Nix if explicitly requested
  if [[ ${USE_NIX:-false} == "true" ]]; then
    install_nix
  else
    # Platform-specific installation
    case $os in
    macos)
      install_macos
      ;;
    linux)
      install_linux
      ;;
    windows)
      install_windows
      ;;
    *)
      print_status "ERROR" "Unsupported operating system: $os"
      print_status "INFO" "Try using --nix for universal installation"
      exit 1
      ;;
    esac
  fi

  # Verify everything worked
  verify_installation
}

# Only run main if script is executed directly
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  main "$@"
fi
