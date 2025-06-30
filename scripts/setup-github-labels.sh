#!/usr/bin/env bash
# Setup standardized GitHub labels for any project
# This creates a sensible, project-agnostic label system

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() { echo -e "${GREEN}==>${NC} $1"; }
print_error() {
  echo -e "${RED}Error:${NC} $1"
  exit 1
}
print_warning() { echo -e "${YELLOW}Warning:${NC} $1"; }

# Check if gh CLI is installed
if ! command -v gh &>/dev/null; then
  print_error "GitHub CLI (gh) is not installed. Please install it first."
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  print_error "Not in a git repository. Please run this from within a git repository."
fi

# Check if authenticated
if ! gh auth status &>/dev/null; then
  print_error "Not authenticated with GitHub. Please run 'gh auth login' first."
fi

print_status "Setting up standardized GitHub labels..."

# Define labels with name, description, and color
# Format: "name|description|color"
declare -a LABELS=(
  # Issue Types
  "bug|Something isn't working|d73a4a"
  "enhancement|New feature or request|a2eeef"
  "documentation|Improvements or additions to documentation|0075ca"
  "question|Further information is requested|d876e3"
  "chore|Maintenance tasks|fef2c0"
  "refactor|Code improvement without feature change|d4c5f9"

  # Priority Levels
  "priority-critical|Urgent: Security or breaking issue|b60205"
  "priority-high|High priority|ff0000"
  "priority-medium|Medium priority|ff9900"
  "priority-low|Low priority|ffff00"

  # Status Labels
  "blocked|Cannot proceed|e4e669"
  "in-progress|Work has started|fbca04"
  "needs-review|Ready for review|7057ff"
  "help wanted|Extra attention is needed|008672"
  "good first issue|Good for newcomers|7057ff"

  # Resolution Labels
  "duplicate|This issue or pull request already exists|cfd3d7"
  "invalid|This doesn't seem right|e4e669"
  "wontfix|This will not be worked on|ffffff"

  # Categories
  "security|Security related issues|FF0000"
  "performance|Performance improvements|FFD700"
  "testing|Testing related|F9A825"
  "ci-cd|CI/CD pipeline related|2E8B57"
  "dependencies|Dependency updates|0366D6"
  "breaking-change|Breaking changes|d93f0b"

  # Platform Labels (common ones)
  "platform-agnostic|Works on all platforms|95a99e"
  "platform-specific|Platform-specific issue|e99695"

  # Size Labels (for PRs)
  "size-xs|Extra small change (< 10 lines)|00ff00"
  "size-s|Small change (10-50 lines)|00ff00"
  "size-m|Medium change (50-200 lines)|ffff00"
  "size-l|Large change (200-500 lines)|ff9900"
  "size-xl|Extra large change (> 500 lines)|ff0000"
)

# Create or update each label
created_count=0
updated_count=0
failed_count=0

for label_data in "${LABELS[@]}"; do
  IFS='|' read -r name description color <<<"$label_data"

  # Check if label exists
  if gh label list --limit 1000 | grep -q "^${name}[[:space:]]"; then
    # Update existing label
    if gh label create "$name" --description "$description" --color "$color" --force 2>/dev/null; then
      print_status "Updated label: $name"
      ((updated_count++))
    else
      print_warning "Failed to update label: $name"
      ((failed_count++))
    fi
  else
    # Create new label
    if gh label create "$name" --description "$description" --color "$color" 2>/dev/null; then
      print_status "Created label: $name"
      ((created_count++))
    else
      print_warning "Failed to create label: $name"
      ((failed_count++))
    fi
  fi
done

# Summary
echo ""
print_status "Label setup complete!"
echo "  Created: $created_count labels"
echo "  Updated: $updated_count labels"
if [[ $failed_count -gt 0 ]]; then
  echo "  Failed: $failed_count labels"
fi

# Optional: Remove default labels
echo ""
read -p "Remove default GitHub labels (bug, documentation, duplicate, etc.)? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # We don't want to remove these since we're using them
  print_warning "Skipping removal - our label set uses some default names"
fi

print_status "All done! Your repository now has a standardized label system."
