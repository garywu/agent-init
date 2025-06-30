#!/usr/bin/env bash
# fix-shell-issues-enhanced.sh - Comprehensive automated shell script fixing
#
# This script provides a complete shell script fixing pipeline using industry-standard tools:
# - shellharden: Security-focused shell script hardening
# - shfmt: Shell script formatting
# - shellcheck: Static analysis with auto-fixes
#
# Usage: ./fix-shell-issues-enhanced.sh [--help] [--verbose] [--dry-run]

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Configuration
VERBOSE=false
DRY_RUN=false
SCRIPTS_PROCESSED=0
FIXES_APPLIED=0

# Print functions
print_header() {
  echo ""
  echo -e "${BOLD}${BLUE}================================================================${NC}"
  echo -e "${BOLD}${BLUE}  $1${NC}"
  echo -e "${BOLD}${BLUE}================================================================${NC}"
  echo ""
}

print_status() {
  local status=$1
  local message=$2
  case $status in
  "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
  "PASS") echo -e "${GREEN}[✓]${NC} $message" ;;
  "FIX")
    echo -e "${YELLOW}[FIX]${NC} $message"
    ((FIXES_APPLIED++))
    ;;
  "ERROR") echo -e "${RED}[✗]${NC} $message" ;;
  "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ;;
  esac
}

# Check tool availability
check_tool() {
  local tool=$1
  local install_cmd=$2

  if command -v "$tool" >/dev/null 2>&1; then
    print_status "PASS" "$tool is available"
    return 0
  else
    print_status "WARN" "$tool not found. Install with: $install_cmd"
    return 1
  fi
}

# Find shell scripts in the project
find_shell_scripts() {
  find . -type f \( -name "*.sh" -o -name "*.bash" \) \
    -not -path "./node_modules/*" \
    -not -path "./.git/*" \
    -not -path "./vendor/*" \
    -not -path "./external/*" \
    -not -path "./.next/*" \
    -print0
}

# Apply shellharden security fixes
apply_shellharden_fixes() {
  local script="$1"

  if ! command -v shellharden >/dev/null 2>&1; then
    return 1
  fi

  # Create backup for comparison
  local backup="${script}.backup"
  cp "$script" "$backup"

  if $DRY_RUN; then
    print_status "INFO" "Would apply shellharden fixes to $(basename "$script")"
  else
    if shellharden --transform "$script" 2>/dev/null; then
      # Check if file was actually modified
      if ! cmp -s "$backup" "$script" 2>/dev/null; then
        print_status "FIX" "Applied shellharden security fixes to $(basename "$script")"
      fi
    fi
  fi

  # Cleanup backup
  rm -f "$backup"
}

# Apply shfmt formatting
apply_formatting() {
  local script="$1"

  if ! command -v shfmt >/dev/null 2>&1; then
    return 1
  fi

  if $DRY_RUN; then
    print_status "INFO" "Would format $(basename "$script") with shfmt"
  else
    # Use configuration file if available, otherwise use sensible defaults
    local shfmt_args="-w -i 2 -ci -s"
    if [[ -f ".shfmt" ]]; then
      if shfmt -w "$script" 2>/dev/null; then
        print_status "FIX" "Formatted $(basename "$script") with shfmt"
      fi
    else
      if shfmt $shfmt_args "$script" >"${script}.tmp" 2>/dev/null; then
        mv "${script}.tmp" "$script"
        print_status "FIX" "Formatted $(basename "$script") with shfmt"
      else
        rm -f "${script}.tmp"
      fi
    fi
  fi
}

# Apply shellcheck auto-fixes
apply_shellcheck_fixes() {
  local script="$1"

  if ! command -v shellcheck >/dev/null 2>&1; then
    return 1
  fi

  if $DRY_RUN; then
    print_status "INFO" "Would apply shellcheck fixes to $(basename "$script")"
  else
    # Apply available shellcheck auto-fixes using diff format
    local diff_output
    if diff_output=$(shellcheck -f diff "$script" 2>/dev/null); then
      if [[ -n $diff_output ]]; then
        echo "$diff_output" | patch -s "$script" - 2>/dev/null || true
        print_status "FIX" "Applied shellcheck auto-fixes to $(basename "$script")"
      fi
    fi
  fi
}

# Process a single shell script
process_script() {
  local script="$1"

  if [[ ! -r $script ]]; then
    print_status "ERROR" "Cannot read $script"
    return 1
  fi

  if $VERBOSE; then
    print_status "INFO" "Processing $(basename "$script")"
  fi
  ((SCRIPTS_PROCESSED++))

  # Apply fixes in order of importance
  # 1. Security fixes first (shellharden)
  apply_shellharden_fixes "$script"

  # 2. Auto-fixable issues (shellcheck)
  apply_shellcheck_fixes "$script"

  # 3. Formatting last (shfmt)
  apply_formatting "$script"
}

# Main execution
main() {
  print_header "Shell Script Automated Fixing Pipeline"

  if $DRY_RUN; then
    print_status "INFO" "Running in dry-run mode (no changes will be made)"
  fi

  # Check tool availability
  print_status "INFO" "Checking tool availability..."
  local tools_available=true

  if ! check_tool "shellcheck" "brew install shellcheck || apt install shellcheck"; then
    tools_available=false
  fi

  if ! check_tool "shfmt" "brew install shfmt || go install mvdan.cc/sh/v3/cmd/shfmt@latest"; then
    tools_available=false
  fi

  check_tool "shellharden" "cargo install shellharden || brew install shellharden"

  if ! $tools_available; then
    print_status "ERROR" "Essential tools missing. Please install shellcheck and shfmt."
    return 1
  fi

  echo ""

  # Find and process shell scripts
  local scripts=()
  while IFS= read -r -d '' script; do
    scripts+=("$script")
  done < <(find_shell_scripts)

  if [[ ${#scripts[@]} -eq 0 ]]; then
    print_status "INFO" "No shell scripts found to process"
    return 0
  fi

  print_status "INFO" "Found ${#scripts[@]} shell script(s) to process"
  echo ""

  # Process each script
  for script in "${scripts[@]}"; do
    process_script "$script"
  done

  # Summary
  echo ""
  print_header "SUMMARY"
  print_status "INFO" "Scripts processed: $SCRIPTS_PROCESSED"
  print_status "INFO" "Fixes applied: $FIXES_APPLIED"

  if [[ $FIXES_APPLIED -gt 0 ]] && ! $DRY_RUN; then
    echo ""
    print_status "INFO" "Run 'git diff' to review changes"
    print_status "INFO" "Run 'git add -u && git commit' to commit fixes"
  fi

  if $DRY_RUN; then
    echo ""
    print_status "INFO" "Re-run without --dry-run to apply fixes"
  fi
}

# Show usage information
show_usage() {
  cat <<'EOF'
Shell Script Automated Fixing Pipeline

USAGE:
    fix-shell-issues-enhanced.sh [OPTIONS]

OPTIONS:
    --help, -h      Show this help message
    --verbose, -v   Enable verbose output
    --dry-run, -n   Show what would be done without making changes

DESCRIPTION:
    This script provides comprehensive automated fixing for shell scripts using:

    • shellharden  - Security-focused shell script hardening
    • shellcheck   - Static analysis with auto-fixes
    • shfmt        - Consistent code formatting

    The script will:
    1. Find all shell scripts in the project
    2. Apply security fixes with shellharden
    3. Apply shellcheck auto-fixes
    4. Format code with shfmt

CONFIGURATION:
    Place .shellcheckrc and .shfmt files in your project root for custom settings.

INSTALLATION:
    Required tools:
    • shellcheck: brew install shellcheck
    • shfmt: brew install shfmt
    • shellharden: cargo install shellharden (optional but recommended)

EXAMPLES:
    ./fix-shell-issues-enhanced.sh              # Fix all shell scripts
    ./fix-shell-issues-enhanced.sh --verbose    # Show detailed progress
    ./fix-shell-issues-enhanced.sh --dry-run    # Preview changes only

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --help | -h)
    show_usage
    exit 0
    ;;
  --verbose | -v)
    VERBOSE=true
    shift
    ;;
  --dry-run | -n)
    DRY_RUN=true
    shift
    ;;
  *)
    echo "Unknown option: $1"
    echo "Use --help for usage information"
    exit 1
    ;;
  esac
done

# Execute main function
main "$@"
