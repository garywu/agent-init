# EditorConfig Patterns

Patterns for maintaining consistent coding styles across different editors and IDEs using EditorConfig.

## Overview

EditorConfig helps maintain consistent coding styles for multiple developers working on the same project across various editors and IDEs. The `.editorconfig` file is a simple INI-format file that defines coding styles.

## Basic EditorConfig Structure

### Universal Settings

```ini
# .editorconfig
# EditorConfig is awesome: https://EditorConfig.org

# top-most EditorConfig file
root = true

# Universal settings for all files
[*]
# Use Unix-style line endings
end_of_line = lf
# Ensure file ends with a newline
insert_final_newline = true
# Remove trailing whitespace
trim_trailing_whitespace = true
# Use UTF-8 encoding
charset = utf-8
# Show whitespace characters (editor-specific)
indent_style = space
indent_size = 2
```

## Language-Specific Patterns

### Multi-Language Configuration

```ini
# .editorconfig
root = true

# Default for all files
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

# JavaScript/TypeScript
[*.{js,jsx,ts,tsx,mjs,cjs}]
indent_size = 2
quote_type = single

# Python
[*.py]
indent_size = 4
max_line_length = 88  # Black formatter default

# Go
[*.go]
indent_style = tab
indent_size = 4

# Rust
[*.rs]
indent_size = 4
max_line_length = 100

# Java/Kotlin
[*.{java,kt,kts}]
indent_size = 4
continuation_indent_size = 8

# C/C++
[*.{c,cpp,cc,cxx,h,hpp,hxx}]
indent_size = 4
indent_style = space

# Ruby
[*.{rb,rake}]
indent_size = 2

# PHP
[*.php]
indent_size = 4

# Shell scripts
[*.{sh,bash,zsh}]
indent_size = 2
# Keep shell scripts executable
keep_permissions = true

# PowerShell
[*.{ps1,psm1,psd1}]
indent_size = 4

# SQL
[*.sql]
indent_size = 2
# SQL often has long lines
max_line_length = off
```

### Web Development

```ini
# HTML/XML
[*.{html,htm,xml,svg}]
indent_size = 2
# Don't trim trailing whitespace in HTML (preserves spacing)
[*.{html,htm}]
trim_trailing_whitespace = false

# CSS/SCSS/SASS
[*.{css,scss,sass,less}]
indent_size = 2
quote_type = double

# JSON
[*.json]
indent_size = 2
# JSON doesn't support comments
insert_final_newline = false

# YAML
[*.{yml,yaml}]
indent_size = 2
# YAML requires spaces, not tabs
indent_style = space

# TOML
[*.toml]
indent_size = 2

# GraphQL
[*.{graphql,gql}]
indent_size = 2
```

### Configuration Files

```ini
# Dockerfile
[Dockerfile*]
indent_size = 2

# Makefile - requires tabs
[Makefile]
indent_style = tab
# Don't convert tabs to spaces
use_tabs = true

# .gitignore and similar
[*.{gitignore,gitattributes,dockerignore}]
indent_size = unset
trim_trailing_whitespace = true

# Environment files
[.env*]
indent_style = unset
quote_type = unset
# Preserve exact formatting
trim_trailing_whitespace = false

# nginx configuration
[*.{nginx,conf}]
indent_size = 4

# Apache configuration
[.htaccess]
indent_size = 2
```

### Documentation

```ini
# Markdown
[*.{md,markdown}]
trim_trailing_whitespace = false  # Preserve line breaks
max_line_length = 80

# reStructuredText
[*.rst]
indent_size = 3
max_line_length = 80

# AsciiDoc
[*.{adoc,asciidoc}]
indent_size = 2
max_line_length = 80

# LaTeX
[*.{tex,latex}]
indent_size = 2
max_line_length = 80
```

## Framework-Specific Patterns

### React/Next.js Project

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

# JavaScript/TypeScript/React
[*.{js,jsx,ts,tsx}]
indent_style = space
indent_size = 2
quote_type = single
max_line_length = 100

# Prettier configuration takes precedence
[*.{json,prettierrc}]
indent_size = 2

# Next.js specific
[next.config.{js,mjs}]
indent_size = 2

# Test files might have longer lines
[*.{test,spec}.{js,jsx,ts,tsx}]
max_line_length = 120
```

### Django Project

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

# Python - PEP 8
[*.py]
indent_style = space
indent_size = 4
max_line_length = 79

# Django templates
[*.{html,djhtml}]
indent_size = 2

# Static files
[static/**.{js,css}]
indent_size = 2

# Migrations - don't modify
[migrations/**.py]
indent_size = unset
trim_trailing_whitespace = false
insert_final_newline = false
```

### Ruby on Rails Project

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

# Ruby standard is 2 spaces
[*.{rb,rake,ru}]
indent_style = space
indent_size = 2

# ERB templates
[*.erb]
indent_size = 2

# Gemfile
[{Gemfile,Gemfile.lock}]
indent_size = 2

# Rails database files
[db/**.rb]
indent_size = 2

# Keep schema.rb consistent
[db/schema.rb]
insert_final_newline = true
trim_trailing_whitespace = true
```

## Advanced Patterns

### Monorepo Configuration

```ini
root = true

# Global defaults
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

# Backend services (Go)
[services/**.go]
indent_style = tab
indent_size = 4

# Frontend apps (TypeScript/React)
[apps/**.{ts,tsx,js,jsx}]
indent_size = 2
quote_type = single

# Shared libraries
[packages/**.{ts,js}]
indent_size = 2

# Infrastructure as Code
[infrastructure/**.{tf,tfvars}]
indent_size = 2

# Different service, different rules
[services/legacy-api/**.py]
indent_size = 4
max_line_length = 120

# Preserve generated files
[**generated**]
indent_style = unset
trim_trailing_whitespace = false
insert_final_newline = false
```

### Platform-Specific Settings

```ini
# Windows-specific files
[*.{bat,cmd,ps1}]
end_of_line = crlf

# Unix scripts
[*.sh]
end_of_line = lf
# Ensure scripts remain executable
keep_permissions = true

# Cross-platform compatibility
[*.{sln,csproj,vbproj}]
end_of_line = crlf
indent_size = 2
```

## Special Considerations

### Binary Files

```ini
# Don't apply text transformations to binary files
[*.{ico,png,jpg,jpeg,gif,webp,svg,ttf,woff,woff2,eot,pdf,mp4,mp3}]
indent_style = unset
indent_size = unset
end_of_line = unset
trim_trailing_whitespace = false
charset = unset
insert_final_newline = false
```

### Generated Files

```ini
# Package manager lock files
[{package-lock.json,yarn.lock,pnpm-lock.yaml,Gemfile.lock,Cargo.lock}]
indent_style = unset
indent_size = unset
trim_trailing_whitespace = false
insert_final_newline = unset

# Generated documentation
[docs/api/**]
indent_style = unset
trim_trailing_whitespace = false

# Build outputs
[{dist,build,out}/**]
indent_style = unset
trim_trailing_whitespace = false
```

### Handling Conflicts

```ini
# When using Prettier
# .editorconfig - basic settings
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true

# Let Prettier handle the rest
[*.{js,jsx,ts,tsx,json,css,scss,md}]
# Prettier will override these anyway
indent_style = space
# But keep them for editors without Prettier
indent_size = 2
```

## Integration Tips

### 1. Editor Plugins

Most modern editors support EditorConfig natively or through plugins:

- **VS Code**: EditorConfig for VS Code extension
- **IntelliJ IDEA**: Built-in support
- **Sublime Text**: EditorConfig plugin
- **Vim**: editorconfig-vim plugin
- **Emacs**: editorconfig-emacs package
- **Atom**: editorconfig package

### 2. CI/CD Integration

```yaml
# GitHub Actions example
- name: EditorConfig Checker
  uses: editorconfig-checker/action-editorconfig-checker@main

# Or using npm package
- name: Check EditorConfig
  run: |
    npm install -g editorconfig-checker
    editorconfig-checker
```

### 3. Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/editorconfig-checker/editorconfig-checker.python
    rev: 2.7.2
    hooks:
      - id: editorconfig-checker
        exclude: '^(vendor/|node_modules/|.git/)'
```

### 4. Team Onboarding

Create a setup script:

```bash
#!/bin/bash
# setup-editor.sh

echo "Checking EditorConfig support..."

# Check if .editorconfig exists
if [[ ! -f .editorconfig ]]; then
    echo "⚠️  No .editorconfig found in project root"
    exit 1
fi

# Check common editors
if command -v code &> /dev/null; then
    echo "💻 VS Code detected"
    code --install-extension EditorConfig.EditorConfig
fi

if [[ -d "$HOME/.vim" ]] || [[ -d "$HOME/.config/nvim" ]]; then
    echo "📝 Vim/Neovim detected"
    echo "Install editorconfig-vim: https://github.com/editorconfig/editorconfig-vim"
fi

echo "✅ EditorConfig setup complete!"
```

## Common Patterns by Project Type

### Minimal Web Project

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

### Enterprise Java Project

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{java,groovy,kt,kts}]
indent_style = space
indent_size = 4
continuation_indent_size = 8
max_line_length = 120

[*.xml]
indent_size = 2

[*.{yml,yaml}]
indent_size = 2

[*.properties]
indent_style = unset
max_line_length = unset
```

### Data Science Project

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

# Python - following Black formatter
[*.py]
indent_style = space
indent_size = 4
max_line_length = 88

# Jupyter Notebooks
[*.ipynb]
indent_size = 1
indent_style = space

# R files
[*.{r,R,Rmd}]
indent_size = 2

# Data files - preserve exact format
[*.{csv,tsv,json,jsonl}]
trim_trailing_whitespace = false
insert_final_newline = false
```

## Best Practices

1. **Start Simple**: Begin with basic settings and add specific rules as needed
2. **Document Decisions**: Add comments explaining non-obvious choices
3. **Test Thoroughly**: Verify settings work across team members' editors
4. **Version Control**: Always commit .editorconfig to your repository
5. **Regular Reviews**: Update settings as project conventions evolve

## External References

- [EditorConfig Official Site](https://editorconfig.org/)
- [EditorConfig Properties](https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties)
- [EditorConfig Specification](https://spec.editorconfig.org/)
- [Editor Plugins List](https://editorconfig.org/#download)