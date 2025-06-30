# Claude Development Instructions for agent-init

## Project Overview

agent-init is a repository initialization tool that sets up professional development standards and workflows for new projects. It provides templates and guidelines for AI-assisted development with Claude.

## Key Recommendations for Claude CLI

When using agent-init to set up a new project, follow these recommendations:

### 1. Start with Context Assessment
- Check if the directory is empty, has git initialized, or contains existing code
- Identify the primary programming language(s) from existing files
- Look for existing configuration files (package.json, Cargo.toml, etc.)
- Respect existing tooling choices unless explicitly asked to change them

### 2. Apply Templates Incrementally
- Begin with essential files: README.md, .gitignore, CLAUDE.md
- Add development tooling next: .editorconfig, .pre-commit-config.yaml
- Introduce CI/CD and advanced features only when the project has code
- Always explain what each addition provides

### 3. Use the GitHub Labels System
- Run `./scripts/setup-github-labels.sh` early in project setup
- This provides a professional issue tracking system immediately
- Add platform/tool-specific labels based on project type

### 4. Prioritize Developer Experience
- Set up linting and formatting early to prevent technical debt
- Use the smart EditorConfig system to prevent indentation conflicts
- Configure pre-commit hooks but keep them reasonable
- Document everything in CLAUDE.md for future sessions

### 5. Follow the Information Over Implementation Principle
- Don't make assumptions about project requirements
- Provide options and explain trade-offs
- Let the project context guide your decisions
- Document why you chose specific approaches

## Enhancements Implemented

### 1. Session Tracking System

Added comprehensive session tracking to help maintain context across development sessions:

- Current session goals tracking
- Session history with completed tasks
- Issue tracking integration
- Key decisions documentation

### 2. Professional Development Workflow

Enhanced the development process with:

- Session start/end checklists
- Quality assurance requirements
- Code review guidelines
- Problem-solving workflow documentation

### 3. External Repository Management

Established best practices for managing external dependencies:

- All external repos should be git submodules in `external/` directory
- Clear procedures for adding and updating submodules
- Version control for all dependencies

### 4. Changelog Management

Added semantic versioning and changelog procedures:

- CHANGELOG.md template following Keep a Changelog format
- Makefile commands for changelog management
- Release workflow documentation

## Shell Script Troubleshooting

### Bash Shebang Compatibility (Critical)

**Always use `#!/usr/bin/env bash`** instead of `#!/bin/bash`:

```bash
#!/usr/bin/env bash  # ✅ CORRECT - finds modern bash in PATH
#!/bin/bash          # ❌ WRONG - uses ancient macOS bash 3.2
```

This prevents errors like `declare: -A: invalid option` on macOS.

### Common ShellCheck Issues and Fixes

If you encounter shellcheck failures during commits, use the automated fix workflow:

```bash
# Quick fix for all shell scripts
make fix-shell

# Then retry your commit
git add -u && git commit
```

### Manual Fixes for Specific Issues

- **SC2086**: Quote variables: Use `"$var"` instead of `$var`
- **SC2292**: Use `[[ ]]` instead of `[ ]` for conditionals
- **SC2312**: Use `|| true` for commands that might fail in subshells

### Pre-commit Hook Workarounds

If shellcheck blocks your commit:
1. First try: `make fix-shell`
2. If critical: `git commit --no-verify` (use sparingly)
3. Fix issues in next commit

## Repository Templates

### CLAUDE.md Template

The enhanced CLAUDE.md template should include:

1. Session tracking section
2. Issue-driven development workflow
3. External repository management
4. Quality assurance checklists
5. Professional development practices

### CHANGELOG.md Template

Standard changelog format with:

1. Semantic versioning
2. Keep a Changelog format
3. Release management procedures
4. Makefile integration

### Makefile Template

Comprehensive automation including:

1. Development commands (dev, build, test, lint)
2. Session management (session-start, session-end)
3. Changelog operations (changelog-prepare, changelog-release)
4. Git workflow helpers (issue, pr)

## Usage Instructions

When initializing a new repository:

1. Copy template files from this repository
2. Customize for specific project needs
3. Set up external dependencies as submodules
4. Initialize changelog with version 0.0.1
5. Configure pre-commit hooks

## Best Practices

1. **Issue-Driven Development**: Always create issues before coding
2. **Session Management**: Use session tracking to maintain context
3. **External Dependencies**: Use git submodules in external/ directory
4. **Changelog Maintenance**: Update changelog with every significant change
5. **Quality Checks**: Run linters and type checks before committing

## Integration with Projects

This repository serves as a template source. Projects using claude-init should:

1. Clone templates during initialization
2. Maintain their own customized versions
3. Contribute improvements back via pull requests
4. Keep external dependencies properly versioned

## What Claude CLI Should Look For

When you (Claude CLI) encounter agent-init in a project, prioritize reading these resources in order:

### 1. Immediate Context Files
- **This file (CLAUDE.md)** - For specific instructions and recommendations
- **README.md** - For understanding available resources
- **docs/CLAUDE_DECISION_MATRIX.md** - For project type detection patterns

### 2. Template Selection
Based on project analysis, look for:
- **templates/** - Contains ready-to-use file templates
- **templates/editorconfig-variants/** - Project-specific EditorConfig files
- **templates/github-labels/** - Label system configurations
- **scripts/** - Automation tools to apply templates

### 3. Documentation for Complex Scenarios
When facing specific challenges, consult:
- **docs/claude-error-prevention.md** - Self-reflection and error prevention patterns
- **docs/workflow-efficiency.md** - Time-saving patterns and command optimization
- **docs/atomic-commits-guide.md** - Clean commits and issue management
- **docs/debugging-and-troubleshooting.md** - Common issues and solutions
- **docs/shellcheck-best-practices.md** - Shell script quality
- **docs/PROJECT_EVOLUTION_PATTERNS.md** - How to handle growing projects
- **docs/environment-adaptation-patterns.md** - CI/CD and platform handling

### 4. Key Principles to Remember
- **Never copy blindly** - Always adapt templates to project context
- **Start minimal** - Add complexity only when needed
- **Document decisions** - Update project's CLAUDE.md with your choices
- **Respect existing code** - Work with what's there, don't replace arbitrarily
- **Use available tools** - Leverage gh, rg, fd, and other CLI tools mentioned in README

---
Last Updated: 2025-06-19
Purpose: Provide professional development templates and workflows for AI-assisted projects
<!-- Session Info - Auto-updated by session management -->
<!-- Current Session ID: session-20250619-183646-35455 -->
<!-- Session Started: 2025-06-19T23:36:46Z -->
