# Workflow Efficiency Guide

Patterns and techniques for efficient development workflows that reduce errors and save time.

## Command Efficiency

### Use Compound Commands

```bash
# ❌ Inefficient - Multiple round trips
cd directory
pwd
ls
cd ..

# ✅ Efficient - Single command
cd directory && pwd && ls && cd -
```

### Batch Operations

```bash
# ❌ Individual file reads
Read file1.txt
Read file2.txt
Read file3.txt

# ✅ Batch reading (if tool supports)
find . -name "*.txt" -exec cat {} \;

# ✅ Or use shell expansion
for f in *.txt; do echo "=== $f ==="; cat "$f"; done
```

## Git Workflow Optimization

### Status Checking

```bash
# ✅ Complete status in one command
git status && echo "---" && git diff --stat && echo "---" && git log --oneline -5
```

### Branch Operations

```bash
# ✅ Create branch and switch in one command
git checkout -b feature-branch

# ✅ Push with upstream in one command
git push -u origin feature-branch
```

### Commit Workflow

```bash
# ✅ Fix, stage, and commit in sequence
make pre-commit-fix && git add -u && git commit -m "feat: description (#123)"
```

## File Operations

### Safe File Editing

```bash
# ✅ Always verify before editing
ls -la file.txt && wc -l file.txt && head -5 file.txt

# ✅ Backup before major changes
cp important.conf important.conf.bak
```

### Efficient Searching

```bash
# ✅ Use the right tool for the job
rg "pattern" --type js           # Search only JavaScript files
fd -e yaml -e yml                # Find all YAML files
find . -mtime -7 -name "*.log"   # Files modified in last 7 days
```

## Issue Management Efficiency

### Quick Issue Creation

```bash
# ✅ Create issue with labels in one command
gh issue create -t "Title" -b "Body" -l "bug,priority-high"
```

### Bulk Operations

```bash
# ✅ List and filter efficiently
gh issue list --label "bug" --state open --limit 50

# ✅ Close multiple issues
for i in 10 20 30; do gh issue close $i; done
```

## Shell Productivity

### Aliases for Common Operations

```bash
# Add to shell config
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
```

### Directory Navigation

```bash
# ✅ Use pushd/popd for temporary directory changes
pushd /tmp
# do work
popd  # returns to original directory

# ✅ Or use subshells
(cd /tmp && perform_operation)  # Returns automatically
```

## Error Prevention

### Verify Before Destructive Operations

```bash
# ✅ Check before removing
ls -la file-to-delete.txt && rm -i file-to-delete.txt

# ✅ Dry run first
rsync -av --dry-run source/ dest/
```

### Safe Variable Usage

```bash
# ✅ Quote variables to handle spaces
cp "$SOURCE_FILE" "$DEST_DIR/"

# ✅ Use default values
FILE="${1:-default.txt}"
```

## Debugging Efficiency

### Quick Debugging

```bash
# ✅ Add debug output
set -x  # Enable debug mode
command
set +x  # Disable debug mode

# ✅ Or use conditional debug
[[ $DEBUG ]] && echo "Debug: variable = $var"
```

### Error Handling

```bash
# ✅ Exit on error
set -euo pipefail

# ✅ Or handle errors explicitly
command || { echo "Failed"; exit 1; }
```

## Documentation While Working

### Inline Documentation

```bash
# ✅ Document while implementing
git commit -m "feat: add feature (#123)" && \
gh issue comment 123 --body "Implemented in $(git rev-parse --short HEAD)"
```

### Progress Tracking

```bash
# ✅ Update todo lists immediately
echo "- [x] Complete task 1" >> progress.md
git add progress.md && git commit -m "docs: update progress"
```

## Tool-Specific Efficiency

### Make Effective Use of Available Tools

```bash
# ✅ Use gh for GitHub operations
gh pr create --fill
gh pr review --approve
gh pr merge --squash

# ✅ Use modern CLI tools
eza --tree --level=2    # Better than ls -R
bat --diff file1 file2  # Better than diff
delta file1 file2       # Even better diff
```

### Leverage Tool Features

```bash
# ✅ Use tool capabilities fully
rg -B2 -A2 "pattern"    # Show 2 lines before/after
fd -H -I                # Include hidden and ignored files
fzf --preview 'cat {}'  # Preview while selecting
```

## Time-Saving Patterns

### 1. Template Commands

```bash
# Create a template for common operations
alias new-issue='gh issue create -t "Bug: " -b "## Description\n\n## Steps to Reproduce\n\n## Expected Behavior\n"'
```

### 2. Smart Defaults

```bash
# Set up sensible defaults
export EDITOR=vim
export PAGER="less -R"
export FZF_DEFAULT_OPTS="--height 40% --reverse"
```

### 3. Batch Processing

```bash
# Process multiple files efficiently
for f in *.md; do
  echo "Processing $f"
  markdownlint "$f" --fix
done
```

## Quick Reference Card

```bash
# Navigation
cd -                    # Previous directory
pushd/popd             # Directory stack
z project              # Jump to project (with zoxide)

# Git shortcuts
git add -p             # Interactive staging
git commit --amend     # Modify last commit
git stash push -m "msg" # Named stash

# Efficiency commands
!! # Last command
!$ # Last argument
^old^new # Replace in last command

# File operations
{1..10}               # Brace expansion
*(om[1,10])          # Newest 10 files (zsh)
<(command)           # Process substitution
```