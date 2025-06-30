---
title: API Reference
description: Complete API reference for agent-init commands and configuration
sidebar:
  order: 1
---

# API Reference

This reference provides comprehensive documentation for all agent-init commands, configuration options, and templates.

## Makefile Commands

The Makefile provides automation for common development tasks. All commands should be run from the project root.

### Development Commands

#### `make dev`
Starts the development environment.

**Usage:**
```bash
make dev
```

**Environment Variables:**
- `PORT`: Server port (default: 3000)
- `ENV`: Environment mode (default: development)

---

#### `make build`
Builds the project for production.

**Usage:**
```bash
make build
```

**Options:**
- `TARGET`: Build target (default: dist)
- `MINIFY`: Enable minification (default: true)

---

#### `make test`
Runs the test suite.

**Usage:**
```bash
make test [ARGS]
```

**Arguments:**
- `ARGS`: Additional test runner arguments
- `--coverage`: Generate coverage report
- `--watch`: Run tests in watch mode

---

#### `make lint`
Runs code quality checks.

**Usage:**
```bash
make lint
```

**Checks:**
- Code formatting
- Type checking (if applicable)
- Style guide compliance

### Session Management

#### `make session-start`
Begins a new development session.

**Usage:**
```bash
make session-start
```

**Actions:**
1. Creates session entry in CLAUDE.md
2. Prompts for session goals
3. Initializes development environment
4. Creates session branch (optional)

---

#### `make session-end`
Ends the current development session.

**Usage:**
```bash
make session-end
```

**Actions:**
1. Updates session tracking
2. Runs quality checks
3. Creates session summary
4. Commits session notes

### Changelog Management

#### `make changelog-prepare`
Prepares changelog for a new release.

**Usage:**
```bash
make changelog-prepare VERSION=x.y.z
```

**Parameters:**
- `VERSION`: Target version number (required)

**Example:**
```bash
make changelog-prepare VERSION=1.2.0
```

---

#### `make changelog-release`
Finalizes changelog for release.

**Usage:**
```bash
make changelog-release
```

**Actions:**
1. Updates version in CHANGELOG.md
2. Sets release date
3. Creates git tag
4. Commits changes

### Git Workflow

#### `make issue`
Creates a new GitHub issue.

**Usage:**
```bash
make issue
```

**Interactive prompts for:**
- Issue title
- Issue type (bug, feature, chore)
- Description
- Labels

---

#### `make pr`
Creates a pull request.

**Usage:**
```bash
make pr
```

**Requirements:**
- Clean working directory
- Current branch != main
- All tests passing

## Configuration Files

### CLAUDE.md Structure

The CLAUDE.md file uses the following structure:

```markdown
# Project Name

## Overview
[Project description and context]

## Current Session
- **Date**: YYYY-MM-DD
- **Goals**:
  - [ ] Goal 1
  - [ ] Goal 2
- **Branch**: feature/description

## Session History
[Previous sessions documentation]

## Issues
- [ ] #123: Issue description
- [x] #122: Completed issue

## Key Decisions
[Architecture and design decisions]

## External Repositories
[Git submodules documentation]
```

### .gitignore Patterns

Standard patterns included:

```gitignore
# Dependencies
node_modules/
vendor/
external/*/

# Build outputs
dist/
build/
*.o
*.so

# IDE files
.vscode/
.idea/
*.swp

# Environment
.env
.env.local

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Testing
coverage/
.coverage
```

### Makefile Variables

Common variables you can override:

```makefile
# Development
PORT ?= 3000
ENV ?= development

# Build
BUILD_DIR ?= dist
SOURCE_DIR ?= src

# Testing
TEST_DIR ?= tests
COVERAGE_DIR ?= coverage

# Tools
PYTHON ?= python3
NODE ?= node
```

## Template Files

### Issue Template

```markdown
## Description
[Clear description of the issue]

## Expected Behavior
[What should happen]

## Current Behavior
[What actually happens]

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Environment
- OS: [e.g., macOS 12.0]
- Version: [e.g., 1.0.0]
```

### PR Template

```markdown
## Description
[Summary of changes]

## Related Issues
Fixes #123

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## Environment Variables

### Required Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PROJECT_NAME` | Project identifier | (required) |
| `GIT_REMOTE` | Git remote URL | (required) |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CLAUDE_SESSION` | Current session ID | (auto-generated) |
| `DEBUG` | Enable debug output | false |
| `CI` | Continuous integration mode | false |
| `COVERAGE_THRESHOLD` | Minimum test coverage | 80 |

## Error Codes

| Code | Description | Resolution |
|------|-------------|------------|
| 1 | General error | Check error message |
| 2 | Missing dependency | Install required tools |
| 3 | Test failure | Fix failing tests |
| 4 | Lint error | Fix code style issues |
| 5 | Build failure | Check build configuration |
| 10 | Git error | Check git status |
| 11 | No active session | Run `make session-start` |
| 12 | Uncommitted changes | Commit or stash changes |

## Advanced Usage

### Custom Hooks

Create custom pre/post hooks for commands:

```makefile
# .make/hooks.mk
pre-test:
	@echo "Running pre-test setup..."

post-build:
	@echo "Running post-build cleanup..."
```

### Extending Commands

Add project-specific commands:

```makefile
# Custom command
.PHONY: deploy
deploy: build test
	@echo "Deploying to production..."
	# Your deployment logic
```

## See Also

- [Getting Started Guide](../guides/getting-started.md)
- [Development Best Practices](../best-practices/development.md)
- [Example Guide](../guides/example.md)