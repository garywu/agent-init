# Atomic Commits and Issue Management Guide

This guide provides patterns for making clean, atomic commits and managing issues effectively.

## Atomic Commit Principles

### What Makes a Commit Atomic?

1. **Single Purpose** - One logical change per commit
2. **Complete** - The change is fully functional
3. **Tested** - Doesn't break existing functionality
4. **Documented** - Clear commit message explaining why

### Commit Workflow

```bash
# 1. Make your changes
vim file.sh

# 2. Pre-commit fix (ALWAYS DO THIS!)
make pre-commit-fix

# 3. Stage selectively
git add -p  # Interactive staging
# OR
git add specific-file.sh

# 4. Review staged changes
git diff --staged

# 5. Create atomic commit with issue reference
git commit -m "feat(scope): description (#123)"
```

## Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description (#issue-number)

[optional body]
[optional footer]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting (no code change)
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks
- `perf`: Performance improvement
- `ci`: CI/CD changes

### Examples

```bash
# Simple feature
git commit -m "feat: add container debugging tools (#64)"

# Bug fix with details
git commit -m "fix(shell): correct bash shebang for macOS compatibility (#52)

- Change #!/bin/bash to #!/usr/bin/env bash
- Prevents 'declare -A' errors on macOS
- Ensures modern bash is used from PATH"

# Breaking change
git commit -m "feat!: migrate to new config format (#100)

BREAKING CHANGE: Config files must be updated to v2 format"
```

## Multi-Commit Strategy

When working on a larger feature, break it into logical commits:

```bash
# Issue #64: Add container tools

# Commit 1: Add basic tools
git add nix/home.nix
git commit -m "feat(nix): add dive for Docker image inspection (#64)"

# Commit 2: Add Kubernetes tools
git add nix/home.nix
git commit -m "feat(nix): add k9s for Kubernetes management (#64)"

# Commit 3: Documentation
git add README.md docs/
git commit -m "docs: add container tools usage guide (#64)"

# Commit 4: Validation
git add scripts/validation/
git commit -m "test: add validation for container tools (#64)"
```

## Issue Management

### Creating Effective Issues

```bash
# Create issue with all details
gh issue create \
  --title "Add container debugging tools" \
  --body "## Description
We need tools for debugging containers and Kubernetes.

## Tasks
- [ ] Add dive for Docker layer analysis
- [ ] Add k9s for Kubernetes debugging
- [ ] Add act for local GitHub Actions
- [ ] Update documentation
- [ ] Add validation tests

## Acceptance Criteria
- Tools available via nix-shell
- Documentation updated
- Validation passes" \
  --label "enhancement,tools"
```

### Linking Issues

```bash
# In commit messages
git commit -m "feat: implement feature (#123)"

# In issue comments
gh issue comment 123 --body "Related to #124 and blocks #125"

# In PR descriptions
Fixes #123
Related to #124
Part of #125
```

### Issue Updates

Update immediately after each commit:

```bash
# After making a commit
gh issue comment 64 --body "## Progress Update

Completed in commit abc123:
- ✅ Added dive to nix/home.nix
- ✅ Tool enables Docker layer inspection

Next steps:
- Add k9s for Kubernetes
- Update documentation"
```

## Best Practices

### 1. Plan Before Committing

```bash
# See what changed
git status

# Review all changes
git diff

# Plan your commits
# - Group related changes
# - Separate concerns
# - Order logically
```

### 2. Stage Incrementally

```bash
# Stage by hunk
git add -p

# Stage specific files
git add src/feature.js tests/feature.test.js

# Unstage if needed
git reset HEAD file.txt
```

### 3. Write Clear Messages

- First line: What and why (not how)
- Body: Additional context if needed
- Footer: Breaking changes, issue refs

### 4. Keep History Clean

```bash
# Amend last commit (before pushing)
git commit --amend

# Interactive rebase (before pushing)
git rebase -i HEAD~3

# Squash related commits
# mark commits with 's' in rebase
```

## Common Patterns

### Feature Addition
```bash
git commit -m "feat(tools): add ripgrep for fast searching (#45)

- Replaces standard grep with Rust-based rg
- 10x faster for large codebases
- Respects .gitignore by default"
```

### Bug Fix
```bash
git commit -m "fix(bootstrap): handle spaces in directory names (#78)

- Quote all path variables
- Add tests for paths with spaces
- Fixes installation failure on 'My Documents'"
```

### Refactoring
```bash
git commit -m "refactor(validation): extract common functions (#92)

- Move shared logic to utils.sh
- Reduce code duplication by 40%
- No functional changes"
```

### Documentation
```bash
git commit -m "docs(readme): add troubleshooting section (#103)

- Add common issues and solutions
- Include debug commands
- Link to detailed guides"
```

## Quick Reference

```bash
# Check what will be committed
git status -s
git diff --staged

# Commit with issue reference
git commit -m "type: description (#123)"

# Update issue
gh issue comment 123 --body "Completed in commit: $(git rev-parse --short HEAD)"

# Push and link
git push origin feature-branch
gh pr create --fill
```