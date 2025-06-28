#!/usr/bin/env bash
# Test internal links in documentation site
# Usage: ./tests/test-links.sh [base_url]

set -e

# Configuration
BASE_URL="${1:-http://localhost:4321}"
SITE_BASE="/repository-name" # Update this to match your base path

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Counter for failed tests
FAILED=0

# Function to test a link
test_link() {
  local path="$1"
  local url="${BASE_URL}${SITE_BASE}${path}"

  echo -n "Testing: $url ... "

  # Use curl to check if page exists
  if curl -sI "$url" | head -1 | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✓${NC}"
    return 0
  else
    echo -e "${RED}✗${NC}"
    echo "  Failed URL: $url"
    ((FAILED++))
    return 1
  fi
}

echo "Starting link validation..."
echo "Base URL: ${BASE_URL}${SITE_BASE}"
echo "---"

# Test critical pages
echo "Testing main pages:"
test_link "/"
test_link "/guides/getting-started/"
test_link "/reference/api/"
test_link "/best-practices/development/"

# Test sidebar navigation links
echo -e "\nTesting navigation structure:"
test_link "/guides/"
test_link "/reference/"
test_link "/best-practices/"

# Summary
echo "---"
if [[ $FAILED -eq 0 ]]; then
  echo -e "${GREEN}All links passed!${NC}"
  exit 0
else
  echo -e "${RED}$FAILED links failed${NC}"
  exit 1
fi
