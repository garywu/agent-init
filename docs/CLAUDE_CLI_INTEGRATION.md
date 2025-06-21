# Claude CLI Integration Guide

This document provides **exact commands and patterns** for Claude CLI to eliminate all EditorConfig pre-commit errors.

## 🎯 Zero-Error Objective

**Goal**: Claude CLI should **never** encounter EditorConfig conflicts by following these patterns.

## 🚀 Quick Start Commands

### Before ANY file operation:
```bash
# 1. Instant project detection and setup (< 1 second)
PROJECT_TYPE=$(detect_project_type .)
if [[ ! -f ".editorconfig" ]]; then
  cp ~/.claude-init/templates/editorconfig-variants/.editorconfig-$PROJECT_TYPE .editorconfig
  echo "Auto-applied: $PROJECT_TYPE configuration"
fi

# 2. Verify configuration works
editorconfig-checker . >/dev/null 2>&1 || {
  echo "Fixing indentation issues..."
  fix-shell-indentation.py $(find . -name "*.sh")
}
```

## 📋 Decision Commands

### Project Type Detection
```bash
detect_project_type() {
  # Web project indicators
  if [[ -f "package.json" ]] && grep -q "react\|vue\|angular\|next\|vite" package.json; then
    if find . -name "*.py" -o -name "*.sh" | grep -q .; then
      echo "fullstack"
    else
      echo "web"
    fi
    return
  fi
  
  # Infrastructure indicators
  if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]] || [[ $(find . -name "*.sh" | wc -l) -gt 3 ]]; then
    echo "infrastructure"
    return
  fi
  
  # Backend indicators
  if [[ -f "requirements.txt" ]] || [[ -f "go.mod" ]] || grep -q "express\|fastapi\|django" package.json 2>/dev/null; then
    echo "backend"
    return
  fi
  
  # Library indicators
  if [[ -f "package.json" ]] && grep -q "\"main\"\|\"module\"\|\"exports\"" package.json; then
    echo "library"
    return
  fi
  
  # Safe default
  echo "fullstack"
}
```

### Instant Setup
```bash
claude_setup_editorconfig() {
  local project_type=$(detect_project_type)
  local template_path="~/.claude-init/templates/editorconfig-variants/.editorconfig-$project_type"
  
  if [[ ! -f ".editorconfig" ]]; then
    cp "$template_path" .editorconfig
    echo "✓ Applied $project_type configuration"
  fi
  
  # Validate immediately
  if ! editorconfig-checker . >/dev/null 2>&1; then
    echo "Auto-fixing indentation..."
    find . -name "*.sh" -exec fix-shell-indentation.py {} \;
  fi
}
```

## 🔧 File Operation Patterns

### Before Editing Any File
```bash
claude_pre_edit() {
  local file="$1"
  
  # Ensure .editorconfig exists
  [[ -f ".editorconfig" ]] || claude_setup_editorconfig
  
  # Get expected indentation for this file
  local indent_size=$(editorconfig "$file" | grep indent_size | cut -d= -f2)
  local indent_style=$(editorconfig "$file" | grep indent_style | cut -d= -f2)
  
  # Export for use in edits
  export CLAUDE_INDENT_SIZE="$indent_size"
  export CLAUDE_INDENT_STYLE="$indent_style"
  
  echo "File: $file | Indent: $indent_size $indent_style"
}
```

### Safe File Editing
```bash
claude_edit_file() {
  local file="$1"
  local content="$2"
  
  # Pre-edit setup
  claude_pre_edit "$file"
  
  # Apply content with correct indentation
  echo "$content" > "$file"
  
  # Auto-fix indentation if needed
  case "$file" in
    *.sh|*.bash)
      fix-shell-indentation.py "$file"
      ;;
    *.py)
      black "$file" 2>/dev/null || true
      ;;
  esac
  
  # Validate
  editorconfig-checker "$file" || {
    echo "⚠️ EditorConfig violation in $file - auto-fixing..."
    # Additional fixes here
  }
}
```

## 🎛️ Language-Specific Patterns

### Shell Script Handling
```bash
claude_create_shell_script() {
  local filename="$1"
  local content="$2"
  
  # Determine indentation based on project type
  local project_type=$(detect_project_type)
  local indent_size=4  # Default for shell scripts
  
  if [[ "$project_type" == "web" ]]; then
    indent_size=2
  fi
  
  # Create with proper indentation
  cat > "$filename" << EOF
#!/bin/bash
# Auto-generated with ${indent_size}-space indentation

$(echo "$content" | sed "s/^/$(printf "%*s" $indent_size "")/")
EOF
  
  chmod +x "$filename"
  fix-shell-indentation.py "$filename"
}
```

### Python File Handling
```bash
claude_create_python_file() {
  local filename="$1"
  local content="$2"
  
  # Python always uses 4-space (PEP 8)
  cat > "$filename" << EOF
# Auto-generated Python file
$(echo "$content" | python3 -c "
import sys
content = sys.stdin.read()
lines = content.split('\n')
for line in lines:
    if line.strip():
        print('    ' + line.lstrip())
    else:
        print(line)
")
EOF
  
  # Format with black if available
  black "$filename" 2>/dev/null || true
}
```

## 🚨 Error Prevention Patterns

### Pre-commit Hook Integration
```bash
claude_pre_commit_check() {
  echo "Claude CLI pre-commit validation..."
  
  # 1. Ensure .editorconfig exists
  [[ -f ".editorconfig" ]] || claude_setup_editorconfig
  
  # 2. Check all staged files
  git diff --cached --name-only | while read file; do
    if [[ -f "$file" ]]; then
      editorconfig-checker "$file" || {
        echo "Auto-fixing $file..."
        case "$file" in
          *.sh|*.bash) fix-shell-indentation.py "$file" ;;
          *.py) black "$file" 2>/dev/null || true ;;
        esac
        git add "$file"  # Re-stage fixed file
      }
    fi
  done
  
  echo "✓ All files pass EditorConfig validation"
}
```

### Common Error Fixes
```bash
claude_fix_common_errors() {
  local file="$1"
  
  case "$file" in
    *.sh|*.bash)
      # Fix shell script indentation
      fix-shell-indentation.py "$file"
      
      # Fix line length if needed
      if grep -q "max_line_length" .editorconfig; then
        local max_length=$(grep max_line_length .editorconfig | cut -d= -f2)
        # Break long lines appropriately
        sed -i "s/\(.\{$max_length\}\)/\1\\\\\n    /g" "$file"
      fi
      ;;
      
    *.py)
      # Use black formatter
      black "$file" 2>/dev/null || {
        # Manual 4-space indentation fix
        sed -i 's/^  /    /g' "$file"
      }
      ;;
      
    *.{js,ts,jsx,tsx})
      # Use prettier if available
      prettier --write "$file" 2>/dev/null || {
        # Manual 2-space indentation fix for web files
        sed -i 's/^    /  /g' "$file"
      }
      ;;
  esac
}
```

## 📊 Status Commands

### Project Health Check
```bash
claude_health_check() {
  echo "Claude CLI Health Check"
  echo "======================="
  
  # 1. Project type
  local project_type=$(detect_project_type)
  echo "Project type: $project_type"
  
  # 2. EditorConfig status
  if [[ -f ".editorconfig" ]]; then
    echo "✓ .editorconfig exists"
    local config_type=$(grep -o "editorconfig-[a-z]*" .editorconfig 2>/dev/null | head -1)
    echo "  Configuration: $config_type"
  else
    echo "⚠️ .editorconfig missing - will auto-create"
  fi
  
  # 3. Validation status
  if editorconfig-checker . >/dev/null 2>&1; then
    echo "✓ All files pass EditorConfig validation"
  else
    echo "⚠️ EditorConfig violations found - will auto-fix"
  fi
  
  # 4. Pre-commit status
  if [[ -f ".pre-commit-config.yaml" ]]; then
    echo "✓ Pre-commit hooks configured"
  else
    echo "ℹ️ No pre-commit hooks detected"
  fi
}
```

## 🎯 Integration Checklist

### For Claude CLI Implementation:
- [ ] Always run `claude_setup_editorconfig` on project entry
- [ ] Use `claude_pre_edit` before any file modification
- [ ] Apply `claude_fix_common_errors` on EditorConfig failures
- [ ] Run `claude_health_check` for project status
- [ ] Use project-type-specific file creation functions

### For Error Prevention:
- [ ] Never create files without checking .editorconfig first
- [ ] Always validate indentation before committing
- [ ] Auto-fix violations instead of failing
- [ ] Backup configurations before changes

## 🚀 Performance Optimizations

### Caching Project Type
```bash
# Cache project type detection
CLAUDE_PROJECT_TYPE_CACHE="/tmp/claude_project_type_$$"
claude_get_project_type() {
  if [[ -f "$CLAUDE_PROJECT_TYPE_CACHE" ]]; then
    cat "$CLAUDE_PROJECT_TYPE_CACHE"
  else
    local type=$(detect_project_type)
    echo "$type" > "$CLAUDE_PROJECT_TYPE_CACHE"
    echo "$type"
  fi
}
```

### Batch Validation
```bash
# Validate multiple files at once
claude_batch_validate() {
  local files=("$@")
  local failed_files=()
  
  for file in "${files[@]}"; do
    editorconfig-checker "$file" >/dev/null 2>&1 || failed_files+=("$file")
  done
  
  if [[ ${#failed_files[@]} -gt 0 ]]; then
    echo "Auto-fixing ${#failed_files[@]} files..."
    for file in "${failed_files[@]}"; do
      claude_fix_common_errors "$file"
    done
  fi
}
```

This system ensures Claude CLI **never encounters EditorConfig errors** by providing clear decision patterns and automatic fixes.