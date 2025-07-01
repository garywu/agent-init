# GitAttributes Setup Guide

## Overview

The `.gitattributes` file is essential for maintaining consistent line endings across different operating systems and preventing common Git issues. This guide explains how to set up proper line ending handling for any project.

## Why GitAttributes is Essential

### The Problem
- **Windows** uses CRLF (`\r\n`) line endings
- **Unix/Linux/macOS** uses LF (`\n`) line endings
- **Git** can automatically convert between them, causing issues
- **Shell scripts** must use LF to work properly on Unix systems
- **PowerShell scripts** should use CRLF for Windows compatibility

### The Solution
A properly configured `.gitattributes` file tells Git exactly how to handle each file type, ensuring:
- Consistent line endings across all platforms
- Proper script execution regardless of OS
- No accidental binary file corruption
- Cross-platform collaboration without issues

## Quick Setup

### 1. Copy the Template
```bash
# Copy the comprehensive template
cp templates/.gitattributes .gitattributes

# Or create it manually using the content below
```

### 2. Customize for Your Project
Review and modify the `.gitattributes` file based on your project's specific needs:
- Add language-specific file extensions
- Remove unused file types
- Add project-specific binary files

### 3. Commit and Share
```bash
git add .gitattributes
git commit -m "feat: add .gitattributes for consistent line endings"
```

## Template Breakdown

### Core Configuration
```gitattributes
# Set default behavior to automatically normalize line endings
* text=auto
```
This tells Git to automatically detect and normalize line endings for all text files.

### Text Files (Auto-normalized)
```gitattributes
*.md text
*.txt text
*.yml text
*.yaml text
*.json text
# ... more file types
```
These files will be automatically converted to the platform's native line endings.

### Platform-Specific Files
```gitattributes
# Windows files (CRLF)
*.bat text eol=crlf
*.cmd text eol=crlf
*.ps1 text eol=crlf

# Unix files (LF)
*.sh text eol=lf
*.bash text eol=lf
*.zsh text eol=lf
*.fish text eol=lf
Makefile text eol=lf
Dockerfile text eol=lf
```
These files will always use the specified line endings regardless of platform.

### Binary Files
```gitattributes
*.png binary
*.jpg binary
*.zip binary
# ... more binary types
```
These files will never have their line endings modified.

## Language-Specific Additions

### Python Projects
```gitattributes
*.py text
*.pyi text
*.pyx text
*.pxd text
*.pyc binary
*.pyo binary
```

### JavaScript/TypeScript Projects
```gitattributes
*.js text
*.ts text
*.jsx text
*.tsx text
*.vue text
*.json text
*.jsonc text
```

### Go Projects
```gitattributes
*.go text
*.mod text
*.sum text
```

### Rust Projects
```gitattributes
*.rs text
*.toml text
```

### Docker Projects
```gitattributes
Dockerfile text eol=lf
*.dockerfile text eol=lf
docker-compose*.yml text
```

## Common Issues and Solutions

### Issue: Shell Scripts Not Executing
**Problem**: Shell scripts have CRLF line endings and fail with "bad interpreter" errors.
**Solution**: Ensure `.sh` files are marked with `text eol=lf`.

### Issue: PowerShell Scripts Not Working
**Problem**: PowerShell scripts have LF line endings and don't execute properly on Windows.
**Solution**: Ensure `.ps1` files are marked with `text eol=crlf`.

### Issue: Binary Files Corrupted
**Problem**: Binary files are being modified by Git's line ending conversion.
**Solution**: Mark binary files with the `binary` attribute.

### Issue: Mixed Line Endings in Repository
**Problem**: Repository has inconsistent line endings.
**Solution**: 
1. Add `.gitattributes` file
2. Normalize existing files: `git add --renormalize .`
3. Commit the changes

## Best Practices

### 1. Always Include .gitattributes
Every repository should have a `.gitattributes` file, even if it's minimal.

### 2. Be Specific About Line Endings
Don't rely on Git's auto-detection for critical files like scripts.

### 3. Mark Binary Files Explicitly
Prevent accidental corruption of binary files.

### 4. Test on Multiple Platforms
Verify that your `.gitattributes` works correctly on Windows, macOS, and Linux.

### 5. Document Custom Rules
Add comments explaining why specific rules are needed for your project.

## Integration with Agent-Init

When using agent-init to set up a new project:

1. **Automatic Setup**: The setup script will copy the `.gitattributes` template
2. **Customization**: Review and modify based on project needs
3. **Validation**: The health check script can verify line ending consistency

## Validation Commands

### Check Current Line Endings
```bash
# Check line endings in working directory
git ls-files --eol

# Check specific file
file -L filename.sh
```

### Normalize Existing Files
```bash
# Normalize all files according to .gitattributes
git add --renormalize .

# Check what would change
git diff --name-only
```

### Verify Binary Files
```bash
# Check if any binary files are being treated as text
git ls-files | xargs file | grep "text"
```

## Troubleshooting

### Git Still Converting Line Endings
1. Check your Git configuration: `git config --get core.autocrlf`
2. Ensure `.gitattributes` is committed and up to date
3. Re-normalize files: `git add --renormalize .`

### Files Not Respecting .gitattributes
1. Verify the file pattern matches exactly
2. Check for typos in file extensions
3. Ensure `.gitattributes` is in the repository root

### Cross-Platform Issues
1. Test on all target platforms
2. Use CI/CD to validate line endings
3. Consider using pre-commit hooks to enforce consistency

## Example Minimal .gitattributes

For simple projects, you can start with this minimal version:

```gitattributes
* text=auto
*.sh text eol=lf
*.ps1 text eol=crlf
*.bat text eol=crlf
*.png binary
*.jpg binary
*.zip binary
```

## Conclusion

A properly configured `.gitattributes` file is essential for any project that will be used across different platforms. It prevents line ending issues, ensures scripts work correctly, and maintains file integrity. Always include this file when setting up new repositories or when encountering line ending problems in existing projects. 