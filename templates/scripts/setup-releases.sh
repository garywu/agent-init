#!/bin/bash
# Setup script for multi-stage release management

set -e

echo "🚀 Multi-Stage Release Setup"
echo "==========================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo -e "${RED}Error: Not in a git repository${NC}"
  exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &>/dev/null; then
  echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
  echo "Please install it from: https://cli.github.com/"
  exit 1
fi

# Function to check if branch exists
branch_exists() {
  git show-ref --verify --quiet refs/heads/$1 || git show-ref --verify --quiet refs/remotes/origin/$1
}

# Function to create branch if it doesn't exist
create_branch() {
  local branch=$1
  local from_branch=${2:-main}

  if branch_exists $branch; then
    echo -e "${YELLOW}Branch '$branch' already exists${NC}"
  else
    echo -e "${GREEN}Creating branch '$branch' from '$from_branch'${NC}"
    git checkout -b $branch $from_branch
    git push -u origin $branch
  fi
}

echo "📋 Current Setup Status"
echo "---------------------"

# Check main branch
MAIN_BRANCH="main"
if git show-ref --verify --quiet refs/heads/master; then
  MAIN_BRANCH="master"
fi
echo "Main branch: $MAIN_BRANCH"

# Check for existing release branches
echo ""
echo "Checking for release branches..."
for branch in beta stable; do
  if branch_exists $branch; then
    echo -e "  ✅ $branch branch exists"
  else
    echo -e "  ❌ $branch branch missing"
  fi
done

# Check for workflow files
echo ""
echo "Checking for workflow files..."
for workflow in release-beta.yml release-stable.yml release-hotfix.yml sync-branches.yml; do
  if [ -f ".github/workflows/$workflow" ]; then
    echo -e "  ✅ $workflow exists"
  else
    echo -e "  ❌ $workflow missing"
  fi
done

echo ""
read -p "Do you want to set up multi-stage releases? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Setup cancelled"
  exit 0
fi

echo ""
echo "🔧 Setting Up Release Management"
echo "-------------------------------"

# Create release branches
echo ""
echo "Creating release branches..."
git checkout $MAIN_BRANCH
create_branch beta $MAIN_BRANCH
create_branch stable $MAIN_BRANCH

# Copy workflow files if they don't exist
echo ""
echo "Setting up workflow files..."
mkdir -p .github/workflows

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"

for workflow in release-beta.yml release-stable.yml release-hotfix.yml sync-branches.yml; do
  if [ ! -f ".github/workflows/$workflow" ]; then
    if [ -f "$TEMPLATE_DIR/.github/workflows/$workflow" ]; then
      cp "$TEMPLATE_DIR/.github/workflows/$workflow" ".github/workflows/"
      echo -e "  ${GREEN}✅ Copied $workflow${NC}"
    else
      echo -e "  ${YELLOW}⚠️  Template for $workflow not found${NC}"
    fi
  fi
done

# Copy release configuration
if [ ! -f ".github/release.yml" ] && [ -f "$TEMPLATE_DIR/.github/release.yml" ]; then
  cp "$TEMPLATE_DIR/.github/release.yml" ".github/"
  echo -e "  ${GREEN}✅ Copied release.yml configuration${NC}"
fi

# Copy RELEASES.md if it doesn't exist
if [ ! -f "RELEASES.md" ] && [ -f "$TEMPLATE_DIR/RELEASES.md" ]; then
  cp "$TEMPLATE_DIR/RELEASES.md" .
  echo -e "  ${GREEN}✅ Copied RELEASES.md documentation${NC}"
fi

# Create VERSION file if it doesn't exist
if [ ! -f "VERSION" ]; then
  echo "v0.0.1" >VERSION
  echo -e "  ${GREEN}✅ Created VERSION file${NC}"
fi

# Update .gitignore if needed
if [ -f ".gitignore" ]; then
  if ! grep -q "^# Release artifacts" .gitignore; then
    echo "" >>.gitignore
    echo "# Release artifacts" >>.gitignore
    echo "RELEASE_NOTES.md" >>.gitignore
    echo -e "  ${GREEN}✅ Updated .gitignore${NC}"
  fi
fi

echo ""
echo "📝 Configuring Branch Protection"
echo "-------------------------------"
echo ""
echo "Please configure branch protection rules in GitHub:"
echo ""
echo "1. Go to Settings → Branches"
echo "2. Add protection rules for:"
echo "   - ${YELLOW}stable${NC}: Require admin approval, no direct pushes"
echo "   - ${YELLOW}beta${NC}: Require status checks, no direct pushes"
echo "   - ${YELLOW}$MAIN_BRANCH${NC}: Require PR reviews, status checks"
echo ""

# Commit changes if any
if [[ -n $(git status -s) ]]; then
  echo "Committing setup changes..."
  git add .
  git commit -m "chore: add multi-stage release management"
  echo -e "${GREEN}✅ Changes committed${NC}"
  echo ""
  echo "Don't forget to push your changes:"
  echo "  git push"
else
  echo "No changes to commit"
fi

echo ""
echo "✨ Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Push any local changes"
echo "2. Configure branch protection rules in GitHub"
echo "3. Set up any required secrets (if using custom tokens)"
echo "4. Test the workflows:"
echo "   - Trigger a manual beta release"
echo "   - Promote a beta to stable"
echo ""
echo "For more information, see RELEASES.md"
