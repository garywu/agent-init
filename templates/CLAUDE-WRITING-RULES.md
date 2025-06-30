# Claude Writing Rules - PREVENT Pre-commit Issues

## CRITICAL: Follow these rules when writing ANY file

### 1. NEVER add trailing whitespace
- ❌ `echo "hello"   ` (spaces at end)
- ✅ `echo "hello"`
- Check EVERY line before writing

### 2. ALWAYS end files with a newline
- The LAST line must have a newline character
- When using Write tool, ensure content ends with `\n`

### 3. Shell Scripts
- ✅ Use `#!/usr/bin/env bash` NOT `#!/bin/bash`
- ✅ Use `[[ ]]` NOT `[ ]` in bash scripts
- ✅ Use `read -r` NOT just `read`
- ✅ Add `# shellcheck disable=SC2029` before SSH commands with variables

### 4. Markdown
- Keep lines under 120 characters (break long lines)
- Add blank lines before/after headings
- Add blank lines before/after code blocks
- Specify language for ALL code blocks: ` ```bash` not ` ``` `

### 5. PowerShell
- No trailing whitespace (check EVERY line)
- End with newline

### 6. Before EVERY file write/edit:
1. Check for trailing spaces on each line
2. Verify file ends with newline
3. For shell scripts, use `[[ ]]` and `read -r`
4. For markdown, check line length and spacing

## Test Command
After creating files, ALWAYS run:
```bash
make fix-shell  # Or your project's fix command
```

## Quick Reference

### When you see these patterns, FIX IMMEDIATELY:
- `if [ ` → `if [[ `
- `read var` → `read -r var`
- `#!/bin/bash` → `#!/usr/bin/env bash`
- Lines ending with spaces → Remove spaces
- File not ending with newline → Add newline
- Markdown lines > 120 chars → Break into multiple lines