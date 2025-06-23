#!/bin/bash
# Script to migrate documentation from docs/ to the Starlight documentation site
# This automates the conversion process for multiple documentation files

set -euo pipefail

# Configuration
DOCS_SOURCE_DIR="docs"
PAGES_TARGET_DIR="pages/src/content/docs"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Logging functions
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Function to generate frontmatter based on filename
generate_frontmatter() {
  local filename="$1"
  local title="$2"
  local category="$3"
  local order="${4:-999}"

  cat <<EOF
---
title: ${title}
description: ${title} - Comprehensive guide from agent-init
sidebar:
  order: ${order}
---

EOF
}

# Function to convert filename to title
filename_to_title() {
  local filename="$1"
  # Remove .md extension and convert hyphens to spaces
  local base="${filename%.md}"
  # Convert to title case
  echo "$base" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1'
}

# Function to determine target category and path
get_target_path() {
  local source_file="$1"
  local basename=$(basename "$source_file")

  case "$basename" in
  *project-structure* | *scaffolding*)
    echo "guides/project-setup/$(basename "$source_file")"
    ;;
  *git-* | *release-* | *context-preservation*)
    echo "guides/workflow/$(basename "$source_file")"
    ;;
  *test* | *lint* | *format* | *debug*)
    echo "guides/development/$(basename "$source_file")"
    ;;
  *cli-tools* | *interactive* | *recommended-tools*)
    echo "guides/tools/$(basename "$source_file")"
    ;;
  *security* | *secrets* | *email-privacy*)
    echo "guides/security/$(basename "$source_file")"
    ;;
  *ci-* | *github-* | *environment* | *monitoring*)
    echo "guides/deployment/$(basename "$source_file")"
    ;;
  *error-* | *troubleshoot* | *mistakes*)
    echo "guides/troubleshooting/$(basename "$source_file")"
    ;;
  *)
    echo "reference/$(basename "$source_file")"
    ;;
  esac
}

# Function to fix internal links
fix_internal_links() {
  local content="$1"
  # Update relative links to other docs
  echo "$content" | sed -E 's|\(([^)]+)\.md\)|(../\1/)|g'
}

# Function to migrate a single file
migrate_file() {
  local source_file="$1"
  local target_path="$2"
  local title="$3"
  local category="$4"
  local order="${5:-999}"

  log_info "Migrating: $source_file -> $target_path"

  # Create target directory
  local target_dir=$(dirname "$target_path")
  mkdir -p "$target_dir"

  # Read source content
  local content=$(cat "$source_file")

  # Check if file already has frontmatter
  if [[ "$content" =~ ^---[[:space:]]*$ ]]; then
    log_warn "File already has frontmatter, preserving it: $source_file"
    # Fix internal links
    content=$(fix_internal_links "$content")
  else
    # Generate frontmatter
    local frontmatter=$(generate_frontmatter "$(basename "$source_file")" "$title" "$category" "$order")
    # Fix internal links and prepend frontmatter
    content=$(fix_internal_links "$content")
    content="${frontmatter}${content}"
  fi

  # Write to target
  echo "$content" >"$target_path"
  log_info "Successfully migrated: $(basename "$source_file")"
}

# Function to create category index files
create_category_index() {
  local category_path="$1"
  local category_name="$2"
  local description="$3"

  if [[[[ ! -f "$category_path/index.md" ]]]]; then
    cat <<EOF >"$category_path/index.md"
---
title: ${category_name}
description: ${description}
sidebar:
  order: 1
---

# ${category_name}

${description}

## Guides in this section

import { LinkCard, CardGrid } from '@astrojs/starlight/components';

<CardGrid>
EOF

    # Add links to all docs in this category
    for doc in "$category_path"/*.md; do
      if [[[[ -f "$doc" && "$(basename "$doc")" != "index.md" ]]]]; then
        local doc_title=$(grep -m1 "^title:" "$doc" | sed 's/title: //')
        local doc_name=$(basename "$doc" .md)
        echo "  <LinkCard title=\"$doc_title\" href=\"./$doc_name/\" />" >>"$category_path/index.md"
      fi
    done

    echo "</CardGrid>" >>"$category_path/index.md"
    log_info "Created category index: $category_path/index.md"
  fi
}

# Main migration logic
main() {
  cd "$PROJECT_ROOT"

  log_info "Starting documentation migration..."
  log_info "Source: $DOCS_SOURCE_DIR"
  log_info "Target: $PAGES_TARGET_DIR"

  # Define migration mappings with order
  declare -A migrations=(
    # Project Setup
    ["project-structure-patterns.md"]="guides/project-setup|10|Project Structure Patterns"
    ["project-scaffolding-patterns.md"]="guides/project-setup|20|Project Scaffolding Patterns"

    # Workflow
    ["git-workflow-patterns.md"]="guides/workflow|10|Git Workflow Patterns"
    ["release-management-patterns.md"]="guides/workflow|20|Release Management Patterns"
    ["context-preservation-patterns.md"]="guides/workflow|30|Context Preservation Patterns"

    # Development
    ["testing-framework-guide.md"]="guides/development|10|Testing Framework Guide"
    ["test-helper-patterns.md"]="guides/development|15|Test Helper Patterns"
    ["linting-and-formatting.md"]="guides/development|20|Linting and Formatting"
    ["debugging-and-troubleshooting.md"]="guides/development|30|Debugging and Troubleshooting"

    # Tools
    ["interactive-cli-tools.md"]="guides/tools|10|Interactive CLI Tools"
    ["recommended-tools-for-claude.md"]="guides/tools|20|Recommended Tools for Claude"

    # Security
    ["email-privacy-protection.md"]="guides/security|10|Email Privacy Protection"
    ["secrets-management-patterns.md"]="guides/security|20|Secrets Management Patterns"

    # Deployment
    ["ci-environment-patterns.md"]="guides/deployment|10|CI Environment Patterns"
    ["github-actions-multi-platform.md"]="guides/deployment|20|GitHub Actions Multi-Platform"
    ["environment-adaptation-patterns.md"]="guides/deployment|30|Environment Adaptation Patterns"
    ["monitoring-observability-patterns.md"]="guides/deployment|40|Monitoring & Observability Patterns"

    # Documentation
    ["documentation-site-setup.md"]="guides/documentation|10|Documentation Site Setup"
    ["github-pages-astro-troubleshooting.md"]="guides/documentation|20|GitHub Pages + Astro Troubleshooting"

    # Reference
    ["editorconfig-patterns.md"]="reference|10|EditorConfig Patterns"
    ["gitignore-patterns.md"]="reference|20|Gitignore Patterns"
    ["shell-configuration-patterns.md"]="reference|30|Shell Configuration Patterns"
    ["error-handling-patterns.md"]="reference|40|Error Handling Patterns"
    ["learning-from-mistakes.md"]="reference|50|Learning from Mistakes"
  )

  # Create base directories
  local categories=(
    "guides/project-setup|Project Setup|Setting up new projects with agent-init"
    "guides/workflow|Development Workflow|Git, releases, and session management"
    "guides/development|Development Practices|Testing, linting, and code quality"
    "guides/tools|Development Tools|Modern CLI tools and utilities"
    "guides/security|Security|Protecting credentials and privacy"
    "guides/deployment|Deployment & CI/CD|Continuous integration and deployment"
    "guides/documentation|Documentation|Creating and maintaining documentation"
    "guides/troubleshooting|Troubleshooting|Solving common problems"
    "reference|Reference|Technical references and patterns"
  )

  for category_info in "${categories[@]}"; do
    IFS='|' read -r path name desc <<<"$category_info"
    mkdir -p "$PAGES_TARGET_DIR/$path"
  done

  # Process files
  local migrated=0
  local skipped=0

  for source_file in "$DOCS_SOURCE_DIR"/*.md; do
    if [[[[ -f "$source_file" ]]]]; then
      local basename=$(basename "$source_file")

      # Skip certain files
      if [[[[ "$basename" == "README.md" || "$basename" == "CLAUDE_TEMPLATES.md" ]]]]; then
        log_warn "Skipping: $basename"
        ((skipped++))
        continue
      fi

      if [[ -n "${migrations[$basename]:-}" ]]; then
        IFS='|' read -r target_dir order title <<<"${migrations[$basename]}"
        local target_path="$PAGES_TARGET_DIR/$target_dir/$basename"
        migrate_file "$source_file" "$target_path" "$title" "$target_dir" "$order"
        ((migrated++))
      else
        log_warn "No mapping defined for: $basename"
        ((skipped++))
      fi
    fi
  done

  # Create category index files
  for category_info in "${categories[@]}"; do
    IFS='|' read -r path name desc <<<"$category_info"
    create_category_index "$PAGES_TARGET_DIR/$path" "$name" "$desc"
  done

  # Create main guides index
  cat <<'EOF' >"$PAGES_TARGET_DIR/guides/index.md"
---
title: Guides
description: Comprehensive guides for using agent-init effectively
sidebar:
  order: 1
---

# Agent Init Guides

Learn how to use agent-init to set up professional development standards and workflows for your AI-assisted projects.

import { LinkCard, CardGrid } from '@astrojs/starlight/components';

## Getting Started

<CardGrid>
  <LinkCard 
    title="Project Setup" 
    description="Setting up new projects with agent-init"
    href="./project-setup/" 
  />
  <LinkCard 
    title="Development Workflow" 
    description="Git, releases, and session management"
    href="./workflow/" 
  />
</CardGrid>

## Core Practices

<CardGrid>
  <LinkCard 
    title="Development Practices" 
    description="Testing, linting, and code quality"
    href="./development/" 
  />
  <LinkCard 
    title="Development Tools" 
    description="Modern CLI tools and utilities"
    href="./tools/" 
  />
</CardGrid>

## Advanced Topics

<CardGrid>
  <LinkCard 
    title="Security" 
    description="Protecting credentials and privacy"
    href="./security/" 
  />
  <LinkCard 
    title="Deployment & CI/CD" 
    description="Continuous integration and deployment"
    href="./deployment/" 
  />
  <LinkCard 
    title="Documentation" 
    description="Creating and maintaining documentation"
    href="./documentation/" 
  />
  <LinkCard 
    title="Troubleshooting" 
    description="Solving common problems"
    href="./troubleshooting/" 
  />
</CardGrid>
EOF

  log_info "Migration complete!"
  log_info "Migrated: $migrated files"
  log_info "Skipped: $skipped files"
  log_info ""
  log_info "Next steps:"
  log_info "1. Review the migrated content in $PAGES_TARGET_DIR"
  log_info "2. Run 'cd pages && npm run dev' to preview"
  log_info "3. Commit and push the changes"
}

# Run main function
main "$@"
