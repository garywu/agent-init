#!/usr/bin/env bash
# test-integration.sh - Integration test for shell script automation
#
# Tests the complete workflow from installation to automated fixing

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Test functions
print_test() {
  echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
  echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
  echo -e "${RED}[FAIL]${NC} $1"
}

print_info() {
  echo -e "${YELLOW}[INFO]${NC} $1"
}

# Test 1: Check tool availability
test_tools() {
  print_test "Checking tool availability..."

  local tools=("shellcheck" "shfmt" "shellharden")
  local available=0

  for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      print_pass "$tool is available"
      ((available++))
    else
      print_fail "$tool is not available"
    fi
  done

  if [[ $available -eq 3 ]]; then
    print_pass "All tools available"
    return 0
  else
    print_fail "Missing tools ($available/3 available)"
    return 1
  fi
}

# Test 2: Check configuration files
test_config() {
  print_test "Checking configuration files..."

  local configs=("templates/.shellcheckrc" "templates/.shfmt")
  local found=0

  for config in "${configs[@]}"; do
    if [[ -f $config ]]; then
      print_pass "Configuration file exists: $config"
      ((found++))
    else
      print_fail "Configuration file missing: $config"
    fi
  done

  if [[ $found -eq 2 ]]; then
    print_pass "All configuration files present"
    return 0
  else
    print_fail "Missing configuration files ($found/2 found)"
    return 1
  fi
}

# Test 3: Test automated fixing script
test_fixing_script() {
  print_test "Testing automated fixing script..."

  if [[ ! -x "scripts/fix-shell-issues-enhanced.sh" ]]; then
    print_fail "fix-shell-issues-enhanced.sh not found or not executable"
    return 1
  fi

  # Test dry-run mode
  if ./scripts/fix-shell-issues-enhanced.sh --dry-run >/dev/null 2>&1; then
    print_pass "Dry-run mode works"
  else
    print_fail "Dry-run mode failed"
    return 1
  fi

  print_pass "Automated fixing script works"
  return 0
}

# Test 4: Test installation script
test_installation_script() {
  print_test "Testing installation script..."

  if [[ ! -x "scripts/install-shell-tools.sh" ]]; then
    print_fail "install-shell-tools.sh not found or not executable"
    return 1
  fi

  # Test help function
  if ./scripts/install-shell-tools.sh --help >/dev/null 2>&1; then
    print_pass "Installation script help works"
  else
    print_fail "Installation script help failed"
    return 1
  fi

  print_pass "Installation script works"
  return 0
}

# Test 5: Create and test problematic script
test_end_to_end() {
  print_test "Testing end-to-end workflow..."

  # Create a test script with common issues
  local test_script="test-problematic.sh"
  cat >"$test_script" <<'EOF'
#!/bin/bash
# Test script with various shellcheck issues

unquoted_var="test value"
echo $unquoted_var

if [ condition ];then
echo "poorly formatted"
fi

array=( $(echo "item1 item2") )

for item in ${array[@]}; do
echo $item
done
EOF

  print_info "Created test script with common issues"

  # Copy configuration files to current directory
  cp templates/.shellcheckrc .
  cp templates/.shfmt .

  # Count issues before fixing
  local issues_before
  issues_before=$(shellcheck "$test_script" 2>&1 | grep -c "^In " || echo "0")
  print_info "Issues before fixing: $issues_before"

  # Apply fixes (dry-run first)
  if ./scripts/fix-shell-issues-enhanced.sh --dry-run >/dev/null 2>&1; then
    print_pass "Dry-run completed successfully"
  else
    print_fail "Dry-run failed"
    cleanup_test "$test_script"
    return 1
  fi

  # Apply actual fixes
  if ./scripts/fix-shell-issues-enhanced.sh >/dev/null 2>&1; then
    print_pass "Automated fixes applied"
  else
    print_fail "Automated fixes failed"
    cleanup_test "$test_script"
    return 1
  fi

  # Count issues after fixing
  local issues_after
  issues_after=$(shellcheck "$test_script" 2>&1 | grep -c "^In " || echo "0")
  print_info "Issues after fixing: $issues_after"

  if [[ $issues_after -lt $issues_before ]]; then
    print_pass "Issues reduced from $issues_before to $issues_after"
  else
    print_fail "Issues not reduced (before: $issues_before, after: $issues_after)"
    cleanup_test "$test_script"
    return 1
  fi

  cleanup_test "$test_script"
  print_pass "End-to-end workflow successful"
  return 0
}

# Cleanup function
cleanup_test() {
  local test_script="$1"
  rm -f "$test_script" .shellcheckrc .shfmt
  print_info "Cleaned up test files"
}

# Main test runner
main() {
  echo ""
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${BLUE}  Shell Script Automation Integration Test${NC}"
  echo -e "${BLUE}================================================================${NC}"
  echo ""

  local tests_passed=0
  local total_tests=5

  # Run all tests
  if test_tools; then ((tests_passed++)); fi
  echo ""

  if test_config; then ((tests_passed++)); fi
  echo ""

  if test_fixing_script; then ((tests_passed++)); fi
  echo ""

  if test_installation_script; then ((tests_passed++)); fi
  echo ""

  if test_end_to_end; then ((tests_passed++)); fi
  echo ""

  # Summary
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${BLUE}  Test Summary${NC}"
  echo -e "${BLUE}================================================================${NC}"

  if [[ $tests_passed -eq $total_tests ]]; then
    print_pass "All tests passed ($tests_passed/$total_tests)"
    echo ""
    echo -e "${GREEN}✅ Shell script automation is ready for production use!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Copy files to your project: cp templates/.* scripts/* ."
    echo "  2. Install tools: make shell-toolchain"
    echo "  3. Apply fixes: make fix-shell"
    echo ""
    return 0
  else
    print_fail "Some tests failed ($tests_passed/$total_tests passed)"
    echo ""
    echo -e "${RED}❌ Please fix the failing tests before using${NC}"
    echo ""
    return 1
  fi
}

# Only run if script is executed directly
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  main "$@"
fi
