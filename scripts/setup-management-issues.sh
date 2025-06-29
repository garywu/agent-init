#!/usr/bin/env bash
# setup-management-issues.sh - Create the 9 permanent management issues for a project

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) is not installed. Please install it first."
    echo "Visit: https://cli.github.com/"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please run this from your project root."
    exit 1
fi

# Check if logged into GitHub
if ! gh auth status > /dev/null 2>&1; then
    print_error "Not logged into GitHub. Please run: gh auth login"
    exit 1
fi

# Get repository info
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
    print_error "Could not determine repository. Make sure you're in a GitHub repository."
    exit 1
fi

print_info "Setting up permanent management issues for: $REPO"
echo ""

# Array of issue templates
declare -a ISSUES=(
    "01-project-roadmap.md|📋 Project Roadmap & Planning|management,roadmap,permanent"
    "02-issue-cross-reference.md|🔗 Issue Cross-Reference Index|management,index,permanent"
    "03-research-discovery-log.md|📚 Research & Discovery Log|management,research,permanent"
    "04-architecture-decisions.md|🏗️ Architecture Decisions|management,architecture,permanent"
    "05-known-issues-workarounds.md|🐛 Known Issues & Workarounds|management,known-issues,permanent"
    "06-documentation-tasks.md|📖 Documentation Tasks|management,documentation,permanent"
    "07-technical-debt-registry.md|🔧 Technical Debt Registry|management,tech-debt,permanent"
    "08-ideas-future-features.md|💡 Ideas & Future Features|management,ideas,permanent"
    "09-project-health-metrics.md|📊 Project Health & Metrics|management,metrics,permanent"
)

# Check if management issues already exist
print_info "Checking for existing management issues..."
EXISTING_COUNT=$(gh issue list --label "permanent" --limit 100 --state all --json number | jq '. | length')

if [[ $EXISTING_COUNT -gt 0 ]]; then
    print_warning "Found $EXISTING_COUNT existing permanent issues."
    echo "Do you want to continue and create additional ones? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Exiting without creating issues."
        exit 0
    fi
fi

# Create each issue
print_info "Creating permanent management issues..."
echo ""

for issue_data in "${ISSUES[@]}"; do
    IFS='|' read -r template title labels <<< "$issue_data"
    
    print_info "Creating: $title"
    
    # Check if this specific issue already exists
    existing=$(gh issue list --search "$title in:title" --json number,title --jq '.[] | select(.title == "'"$title"'") | .number' | head -n1)
    
    if [[ -n "$existing" ]]; then
        print_warning "Issue already exists: #$existing - $title"
        continue
    fi
    
    # Create the issue
    if gh issue create \
        --title "$title" \
        --body "$(cat <<EOF
# $title

**⚠️ PERMANENT ISSUE - DO NOT CLOSE**

This is one of the 9 permanent management issues for this project. It helps track and organize important project information over time.

## Purpose

This issue serves as a living document for project management. See the full template in your \`.github/ISSUE_TEMPLATE/\` directory for the complete structure.

## Quick Links

- Project Roadmap: #1
- Issue Index: #2
- Research Log: #3
- Architecture: #4
- Known Issues: #5
- Documentation: #6
- Tech Debt: #7
- Ideas: #8
- Metrics: #9

---

**Note**: Edit this issue to add your project-specific content following the template structure.
EOF
        )" \
        --label "$labels" > /dev/null 2>&1; then
        print_success "Created: $title"
    else
        print_error "Failed to create: $title"
    fi
    
    # Small delay to avoid rate limiting
    sleep 1
done

echo ""
print_success "Management issues setup complete!"
echo ""
print_info "Next steps:"
echo "  1. Visit each issue and customize the content for your project"
echo "  2. Pin the most important ones to your repository"
echo "  3. Link related issues as you create them"
echo "  4. Update these issues regularly as part of your workflow"
echo ""
print_info "Remember: These issues should NEVER be closed!"