# Claude Error Prevention Rules

This document contains specific rules derived from error analysis to prevent common mistakes.

## Critical Rules (Must Follow)

### 1. Path Verification Protocol

```bash
# RULE: Always verify paths before use
# ❌ WRONG
cd /some/path
cat file.txt

# ✅ CORRECT
test -d /some/path && cd /some/path
test -f file.txt && cat file.txt
```

### 2. Working Directory Awareness

```bash
# RULE: Track directory changes in compound commands
# ❌ WRONG
cd subdir
ls
cd ..

# ✅ CORRECT
(cd subdir && ls)  # Subshell returns automatically
# OR
cd subdir && ls && cd -
```

### 3. File Editing Protocol

```bash
# RULE: Never edit without reading first
# ❌ WRONG
Edit file.txt "new content"

# ✅ CORRECT
Read file.txt
Edit file.txt "old content" "new content"
```

### 4. Error Message Interpretation

```bash
# RULE: "Error:" prefix doesn't always mean failure
# Example: pwd shows current directory in error output
pwd && ls
# Error: /current/directory  <- This is the pwd output!
```

### 5. Git Submodule Awareness

```bash
# RULE: Understand submodule status
modified: external/module (new commits)
# This means: submodule has changes, need to:
git add external/module
git commit -m "chore: update submodule"
```

## Efficiency Rules

### 6. Command Batching

```bash
# RULE: Combine related operations
# ❌ INEFFICIENT
git status
git diff
git log

# ✅ EFFICIENT
git status && echo "---" && git diff --stat && echo "---" && git log --oneline -5
```

### 7. Pre-commit Automation

```bash
# RULE: Always fix before committing
# ✅ CORRECT WORKFLOW
make pre-commit-fix && git add -u && git commit -m "feat: description (#123)"
```

### 8. Tool Selection

```bash
# RULE: Use the right tool
# Finding files: fd > find
# Searching content: rg > grep
# Viewing files: bat > cat
# Listing files: eza > ls
```

## Context Preservation Rules

### 9. Issue Reference

```bash
# RULE: Always reference issues in commits
git commit -m "type(scope): description (#issue-number)"
```

### 10. Progress Documentation

```bash
# RULE: Update issues immediately after commits
gh issue comment 123 --body "Completed in $(git rev-parse --short HEAD)"
```

## Verification Checklist

Before any operation, ask:

1. [ ] Have I verified the path exists?
2. [ ] Do I know my current working directory?
3. [ ] Have I read the file before editing?
4. [ ] Am I using the most efficient approach?
5. [ ] Have I referenced the relevant issue?

## Common Error Patterns to Avoid

### Pattern 1: Multiple Directory Checks
```bash
# ❌ AVOID
cd dir1
pwd
ls
cd ..
pwd

# ✅ USE
pwd && cd dir1 && ls && cd - && pwd
```

### Pattern 2: Blind File Operations
```bash
# ❌ AVOID
echo "content" > file.txt  # Might overwrite!

# ✅ USE
test -f file.txt && cp file.txt file.txt.bak
echo "content" > file.txt
```

### Pattern 3: Ignoring Pre-commit
```bash
# ❌ AVOID
git commit -m "quick fix"  # Might fail!

# ✅ USE
make pre-commit-fix || make fix-shell
git add -u && git commit -m "fix: description (#123)"
```

## Memory Aids

### Quick Checks
- `pwd` - Where am I?
- `ls -la` - What's here?
- `git status` - What changed?
- `git diff --staged` - What will commit?

### Safe Operations
- `cp file file.bak` - Backup first
- `git stash` - Save work before risky operations
- `--dry-run` - Test commands safely
- `-i` - Interactive mode for safety

## Integration with Self-Reflection

Add these checks to your self-reflection protocol:

1. **Before starting**: Review these rules
2. **On errors**: Check which rule was violated
3. **After tasks**: Note any new patterns discovered
4. **Update this document**: Add new rules as learned