# Claude Error Prevention and Self-Reflection Guide

This guide contains battle-tested patterns for preventing common AI assistant errors and improving development efficiency.

## Self-Reflection Protocol

### Before Starting Any Task

1. **Review Recent History**
   - Re-read the last 10-20 messages in the conversation
   - Identify any patterns of errors or corrections
   - Note specific instructions that were given and may have been forgotten

2. **Check for Common Self-Induced Errors**
   - **Path errors**: Verify file paths before using them
   - **Assumption errors**: Don't assume file contents or structure - always check
   - **Instruction drift**: Re-read the original request to ensure staying on track
   - **Context loss**: Review what was already tried to avoid repeating failures

3. **Memory Checkpoint Questions**
   - What was the user's original request?
   - What specific constraints or preferences were mentioned?
   - Have I made this type of error before in this session?
   - Am I following the established patterns in this codebase?

## Common Error Patterns to Avoid

### 1. Working Directory Confusion

**Problem**: Misinterpreting pwd output in error messages
```bash
# This "Error" actually shows the current directory!
pwd && ls -la | grep -E "(pattern)"
⎿  Error: /path/to/current/directory
```

**Solution**: Read error messages carefully - "Error:" prefix doesn't always mean failure

### 2. File Operation Errors

**Problem**: Writing to files without reading them first
```bash
# ❌ Wrong
Write file.txt with new content

# ✅ Correct
Read file.txt
Edit file.txt with specific changes
```

**Solution**: Always read before writing, use Edit for existing files

### 3. Command Efficiency

**Problem**: Multiple round trips for simple checks
```bash
# ❌ Inefficient
cd directory
pwd
ls
cd ..
pwd

# ✅ Efficient
cd directory && pwd && ls && cd .. && pwd
```

**Solution**: Use compound commands with && to reduce round trips

### 4. Git Submodule Confusion

**Problem**: Not understanding submodule reference updates
```bash
modified:   external/submodule (new commits)
```

**Solution**: This means the submodule has changes. Update with:
```bash
git add external/submodule
git commit -m "chore: update submodule reference"
```

## Pre-Commit Hook Management

### Quick Fix Workflow

```bash
# 1. Always run before committing
make pre-commit-fix

# 2. Stage and commit
git add -u
git commit -m "feat: description (#issue)"
```

### Common Pre-Commit Issues

1. **Trailing whitespace**: Auto-fixed by `make pre-commit-fix`
2. **End-of-file newline**: Auto-fixed by `make pre-commit-fix`
3. **Shell script issues**: Run `make fix-shell`
4. **Markdown linting**: Review or use `--no-verify` if too strict

## Verification Patterns

### Before File Operations
```bash
# Check file exists
ls -la path/to/file

# Check directory structure
find . -type f -name "pattern"

# Verify assumptions
grep -n "expected content" file.txt
```

### Before Complex Operations
```bash
# Dry run first
command --dry-run

# Check what will change
git diff --staged

# Verify current state
git status
```

## Memory Aids

### Track Working Directory
- Always know where you are
- Use `pwd` in compound commands when changing directories
- Remember that subshells don't change parent directory

### Track Modified Files
- Run `git status` frequently
- Use `git diff` to see actual changes
- Stage incrementally with `git add -p`

### Track Issue Context
- Reference issue numbers in commits
- Update issues immediately after commits
- Cross-reference related issues

## Error Recovery

When errors occur:

1. **Don't retry blindly** - Read the error message
2. **Check assumptions** - Verify paths, permissions, state
3. **Review recent commands** - What changed?
4. **Consult documentation** - Is this a known issue?
5. **Document the solution** - Help future sessions

## Session Efficiency Tips

1. **Batch related operations** - Plan command sequences
2. **Use tool capabilities fully** - Read multiple files at once
3. **Leverage shell features** - Pipes, redirects, compound commands
4. **Remember previous solutions** - Check CLAUDE.md and issues
5. **Document while working** - Update issues in real-time

## Key Principles

- **Verify before acting** - Check assumptions
- **Read error messages carefully** - They often contain solutions
- **Use atomic commits** - One logical change per commit
- **Document immediately** - Don't wait until the end
- **Learn from mistakes** - Update this guide with new patterns