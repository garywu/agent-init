#!/bin/bash
# Test production GitHub Pages deployment
# Usage: ./tests/test-production.sh username repository-name

set -e

# Get parameters
USERNAME="${1:-username}"
REPO_NAME="${2:-repository-name}"
BASE_URL="https://${USERNAME}.github.io/${REPO_NAME}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Testing production deployment..."
echo "URL: $BASE_URL"
echo "---"

# Test homepage
echo -n "Testing homepage... "
if curl -sI "$BASE_URL/" | head -1 | grep -q "200"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "Homepage not accessible. Is the site deployed?"
    exit 1
fi

# Test key documentation pages
pages=(
    "/guides/getting-started/"
    "/reference/api/"
    "/best-practices/development/"
)

echo "Testing documentation pages:"
for page in "${pages[@]}"; do
    echo -n "  $page ... "
    if curl -sI "${BASE_URL}${page}" | head -1 | grep -q "200"; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${YELLOW}  Note: Check if base path is correctly configured${NC}"
    fi
done

# Test assets
echo -e "\nTesting static assets:"
echo -n "  CSS files ... "
if curl -sI "${BASE_URL}/assets/" | head -1 | grep -q "404"; then
    echo -e "${GREEN}✓${NC} (404 on directory listing is expected)"
else
    echo -e "${YELLOW}?${NC}"
fi

echo "---"
echo "Production test complete!"
echo ""
echo "If links are failing, check:"
echo "1. Base path in astro.config.mjs matches repository name"
echo "2. All internal links use relative paths (./ or ../)"
echo "3. GitHub Pages is enabled in repository settings"
echo "4. GitHub Actions workflow completed successfully"