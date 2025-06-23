#!/usr/bin/env bash
# fix-shell-issues.sh - Automatically fix common shell script issues before commit
#
# This script runs both formatting and attempts to fix common shellcheck issues

set -euo pipefail

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

print_status() {
  echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}Warning:${NC} $1"
}

print_error() {
  echo -e "${RED}Error:${NC} $1"
}

# Find all shell scripts
find_shell_scripts() {
  find . -type f \( -name "*.sh" -o -name "*.bash" \) \
    -not -path "./node_modules/*" \
    -not -path "./.git/*" \
    -not -path "./external/*"
}

# Run shfmt to fix formatting issues
fix_formatting() {
  print_status "Running shfmt to fix formatting issues..."

  if ! command -v shfmt &>/dev/null; then
    print_warning "shfmt not found. Install with: brew install shfmt"
    return 1
  fi

  find_shell_scripts | while read -r file; do
    if shfmt -w "$file" 2>/dev/null; then
      print_status "Formatted: $file"
    fi
  done

  # Also format bootstrap.sh specifically
  if [[ -f "bootstrap.sh" ]]; then
    shfmt -w bootstrap.sh
  fi
}

# Fix common shellcheck issues automatically
fix_common_issues() {
  print_status "Fixing common shellcheck issues..."

  find_shell_scripts | while read -r file; do
    # Create a temporary file
    local tmp_file="${file}.tmp"

    # Fix SC2292: Prefer [[ ]] over [ ]
    if grep -q '\[ ' "$file"; then
      sed -E 's/\[ ([^]]+) \]/[[ \1 ]]/g' "$file" >"$tmp_file"
      if ! diff -q "$file" "$tmp_file" >/dev/null; then
        mv "$tmp_file" "$file"
        print_status "Fixed [ ] to [[ ]] in: $file"
      else
        rm -f "$tmp_file"
      fi
    fi

    # Fix SC2086: Double quote variables
    # This is more complex and risky to auto-fix, so we'll just warn
    if shellcheck "$file" 2>/dev/null | grep -q "SC2086"; then
      print_warning "Manual fix needed for unquoted variables in: $file"
    fi

    # Fix SC2155: Declare and assign separately
    if shellcheck "$file" 2>/dev/null | grep -q "SC2155"; then
      print_warning "Manual fix needed for declare/assign issues in: $file"
    fi
  done
}

# Run shellcheck and show remaining issues
check_remaining() {
  print_status "Checking for remaining issues..."

  local has_issues=false

  find_shell_scripts | while read -r file; do
    if ! shellcheck "$file" >/dev/null 2>&1; then
      has_issues=true
      print_warning "Issues remain in: $file"
      shellcheck "$file" || true
    fi
  done

  if [[ "$has_issues" == "false" ]]; then
    print_status "All shell scripts pass shellcheck!"
  fi
}

# Main execution
main() {
  print_status "Starting shell script issue fixer..."

  # First, format all scripts
  fix_formatting

  # Then fix common issues
  fix_common_issues

  # Finally, check what's left
  check_remaining

  print_status "Done! Run 'git add -u' to stage the fixes."
}

# Run main function
main "$@"
