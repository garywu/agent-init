# Smart EditorConfig System

This directory contains project-type-specific EditorConfig templates that solve the **global vs project-specific indentation conflict**.

## The Problem We Solve

**Multi-language developers** face this dilemma:
- **Global dotfiles**: Optimized for primary work (usually web = 2-space)
- **Project needs**: Different projects need different indentation (systems = 4-space)
- **Multi-language projects**: Need both standards in one project

## The Solution: Hierarchical Configuration

```
1. Global Dotfiles (~/.dotfiles/.editorconfig)
   ↓ Provides sensible defaults for your primary work
2. Claude-init Templates (project-type-specific)
   ↓ Override global settings based on project type
3. Manual Overrides (.editorconfig in specific projects)
   ↓ Handle unique project requirements
```

## Available Templates

### `.editorconfig-web`
**For**: Frontend/web projects  
**Indentation**: 2-space default  
**Use when**: JavaScript, TypeScript, CSS, HTML projects

### `.editorconfig-infrastructure` 
**For**: Systems/DevOps projects  
**Indentation**: 4-space for shells/Python, 2-space for configs  
**Use when**: Shell scripts, Python tools, Docker, CI/CD

### `.editorconfig-fullstack`
**For**: Multi-language projects  
**Indentation**: Language-specific rules  
**Use when**: Web + backend, mixed technology stacks

## Usage

### Automatic Setup
```bash
# Auto-detect project type and apply appropriate config
./scripts/setup-editorconfig.sh

# Force specific project type
./scripts/setup-editorconfig.sh -t infrastructure

# Setup for different directory
./scripts/setup-editorconfig.sh /path/to/project
```

### Manual Setup
```bash
# Copy the appropriate template
cp templates/editorconfig-variants/.editorconfig-web .editorconfig
```

## Project Type Detection

The setup script automatically detects:

**Web Projects**:
- Has `package.json`, `yarn.lock`, or `pnpm-lock.yaml`
- Primarily frontend technologies

**Infrastructure Projects**:
- Has `Dockerfile`, `docker-compose.yml`, or `Makefile`
- Contains shell scripts or Python files
- Has `requirements.txt` or `pyproject.toml`

**Fullstack Projects**:
- Has web indicators + backend languages
- Mixed technology stack

## Multi-Language Project Strategy

For projects with **multiple technologies**, the fullstack template uses **language-specific rules**:

```ini
# Frontend gets web standards
[*.{js,ts,css,html}]
indent_size = 2

# Backend gets systems standards  
[*.{py,sh,bash}]
indent_size = 4

# Configs get readability standards
[*.{json,yaml}]
indent_size = 2
```

## Integration with Your Workflow

### 1. Keep Your Global Dotfiles
Your `~/.dotfiles/.editorconfig` stays optimized for your primary work (web development with 2-space).

### 2. Use Claude-init for New Projects
When initializing projects:
```bash
# Setup new project
claude-init setup my-new-project
cd my-new-project

# Smart EditorConfig setup
../claude-init/scripts/setup-editorconfig.sh
```

### 3. Existing Projects
For existing projects with conflicts:
```bash
# Backup existing config
cp .editorconfig .editorconfig.backup

# Apply smart config
/path/to/claude-init/scripts/setup-editorconfig.sh
```

## Examples

### Web Project
```ini
# Result: .editorconfig-web applied
[*]
indent_size = 2  # Perfect for React/Vue/etc

[*.{js,ts,css}]
indent_size = 2  # Web standards
```

### Infrastructure Project  
```ini
# Result: .editorconfig-infrastructure applied
[*]
indent_size = 4  # Better for systems work

[*.{sh,py}]
indent_size = 4  # Clear hierarchy in scripts

[*.{json,yaml}]
indent_size = 2  # Readable configs
```

### Fullstack Project
```ini
# Result: .editorconfig-fullstack applied
[*.{js,ts,css}]
indent_size = 2  # Frontend web standards

[*.{py,sh}]
indent_size = 4  # Backend systems standards

[*.go]
indent_style = tab  # Language convention
```

## Benefits

✅ **No more global conflicts** - Each project gets appropriate settings  
✅ **Language-aware** - Respects ecosystem standards  
✅ **Automatic detection** - No manual decision making  
✅ **Backward compatible** - Works with existing projects  
✅ **Override friendly** - Can still manually customize  

## Future Enhancements

- [ ] Integration with `claude-init setup` command
- [ ] Support for more project types (mobile, data science, etc.)
- [ ] Team-specific templates
- [ ] IDE integration helpers