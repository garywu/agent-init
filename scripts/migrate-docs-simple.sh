#!/usr/bin/env bash
# Simplified script to migrate key documentation files
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$PROJECT_ROOT/docs"
TARGET_DIR="$PROJECT_ROOT/pages/src/content/docs"

GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

# Create directories
mkdir -p "$TARGET_DIR/guides/"{workflow,development,tools,security,deployment,documentation}
mkdir -p "$TARGET_DIR/reference"

# Function to add frontmatter and copy file
migrate_file() {
  local source="$1"
  local target="$2"
  local title="$3"
  local order="${4:-999}"

  log_info "Migrating $(basename "$source") -> $target"

  mkdir -p "$(dirname "$target")"

  cat <<EOF >"$target"
---
title: $title
description: $title - Comprehensive guide from agent-init
sidebar:
  order: $order
---

EOF
  cat "$source" >>"$target"
}

# Key migrations
log_info "Starting simplified migration..."

# Workflow guides
if [[ -f "$SOURCE_DIR/git-workflow-patterns.md" ]]; then
  migrate_file "$SOURCE_DIR/git-workflow-patterns.md" \
    "$TARGET_DIR/guides/workflow/git-workflow.md" \
    "Git Workflow Patterns" 10
fi

if [[ -f "$SOURCE_DIR/release-management-patterns.md" ]]; then
  migrate_file "$SOURCE_DIR/release-management-patterns.md" \
    "$TARGET_DIR/guides/workflow/release-management.md" \
    "Release Management Patterns" 20
fi

if [[ -f "$SOURCE_DIR/context-preservation-patterns.md" ]]; then
  migrate_file "$SOURCE_DIR/context-preservation-patterns.md" \
    "$TARGET_DIR/guides/workflow/context-preservation.md" \
    "Context Preservation Patterns" 30
fi

# Development guides
if [[ -f "$SOURCE_DIR/testing-framework-guide.md" ]]; then
  migrate_file "$SOURCE_DIR/testing-framework-guide.md" \
    "$TARGET_DIR/guides/development/testing-framework.md" \
    "Testing Framework Guide" 10
fi

if [[ -f "$SOURCE_DIR/linting-and-formatting.md" ]]; then
  migrate_file "$SOURCE_DIR/linting-and-formatting.md" \
    "$TARGET_DIR/guides/development/linting-formatting.md" \
    "Linting and Formatting" 20
fi

if [[ -f "$SOURCE_DIR/debugging-and-troubleshooting.md" ]]; then
  migrate_file "$SOURCE_DIR/debugging-and-troubleshooting.md" \
    "$TARGET_DIR/guides/development/debugging-troubleshooting.md" \
    "Debugging and Troubleshooting" 30
fi

# Tools guides
if [[ -f "$SOURCE_DIR/interactive-cli-tools.md" ]]; then
  migrate_file "$SOURCE_DIR/interactive-cli-tools.md" \
    "$TARGET_DIR/guides/tools/interactive-cli-tools.md" \
    "Interactive CLI Tools" 10
fi

if [[ -f "$SOURCE_DIR/recommended-tools-for-claude.md" ]]; then
  migrate_file "$SOURCE_DIR/recommended-tools-for-claude.md" \
    "$TARGET_DIR/guides/tools/recommended-tools.md" \
    "Recommended Tools for Claude" 20
fi

# Security guides
if [[ -f "$SOURCE_DIR/email-privacy-protection.md" ]]; then
  migrate_file "$SOURCE_DIR/email-privacy-protection.md" \
    "$TARGET_DIR/guides/security/email-privacy.md" \
    "Email Privacy Protection" 10
fi

if [[ -f "$SOURCE_DIR/secrets-management-patterns.md" ]]; then
  migrate_file "$SOURCE_DIR/secrets-management-patterns.md" \
    "$TARGET_DIR/guides/security/secrets-management.md" \
    "Secrets Management Patterns" 20
fi

# Deployment guides
if [[ -f "$SOURCE_DIR/github-actions-multi-platform.md" ]]; then
  migrate_file "$SOURCE_DIR/github-actions-multi-platform.md" \
    "$TARGET_DIR/guides/deployment/github-actions.md" \
    "GitHub Actions Multi-Platform" 10
fi

if [[ -f "$SOURCE_DIR/documentation-site-setup.md" ]]; then
  migrate_file "$SOURCE_DIR/documentation-site-setup.md" \
    "$TARGET_DIR/guides/documentation/site-setup.md" \
    "Documentation Site Setup" 10
fi

if [[ -f "$SOURCE_DIR/github-pages-astro-troubleshooting.md" ]]; then
  migrate_file "$SOURCE_DIR/github-pages-astro-troubleshooting.md" \
    "$TARGET_DIR/guides/documentation/github-pages-troubleshooting.md" \
    "GitHub Pages Astro Troubleshooting" 20
fi

# Reference docs
if [[ -f "$SOURCE_DIR/project-structure-patterns.md" ]]; then
  migrate_file "$SOURCE_DIR/project-structure-patterns.md" \
    "$TARGET_DIR/reference/project-structure.md" \
    "Project Structure Patterns" 10
fi

if [[ -f "$SOURCE_DIR/error-handling-patterns.md" ]]; then
  migrate_file "$SOURCE_DIR/error-handling-patterns.md" \
    "$TARGET_DIR/reference/error-handling.md" \
    "Error Handling Patterns" 20
fi

log_info "Migration completed!"
log_info "Next: cd pages && npm run dev to preview changes"
