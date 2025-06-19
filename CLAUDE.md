# Claude Development Instructions for claude-init

## Project Overview

claude-init is a repository initialization tool that sets up professional development standards and workflows for new projects. It provides templates and guidelines for AI-assisted development with Claude.

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

---
Last Updated: 2024-12-18
Purpose: Provide professional development templates and workflows for AI-assisted projects
