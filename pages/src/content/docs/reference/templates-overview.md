---
title: Templates Overview
description: Overview of all templates provided by agent-init for different project types
sidebar:
  order: 5
---

# Agent Init Templates Overview

Agent Init provides a comprehensive set of templates to quickly set up professional development standards for any project. These templates embody best practices learned from real-world projects.

## Core Templates

### Configuration Templates

| Template | Purpose | Key Features |
|----------|---------|--------------|
| `CLAUDE.md` | AI session tracking | Session management, issue tracking, workflow procedures |
| `CLAUDE-api.md` | API development variant | API-specific documentation, endpoint tracking |
| `CLAUDE-web-app.md` | Web app development | Frontend/backend organization, component tracking |
| `Makefile` | Task automation | Standardized commands across project types |
| `README.md` | Project documentation | Professional project presentation |

### Development Standards

| Template | Purpose | Key Features |
|----------|---------|--------------|
| `.gitignore` | Version control | Comprehensive patterns for all languages |
| `.editorconfig` | Code formatting | Consistent editor settings |
| `.pre-commit-config.yaml` | Code quality | Automated checks before commits |
| `.yamllint` | YAML validation | Strict YAML formatting rules |

### Documentation Templates

| Template | Purpose | Key Features |
|----------|---------|--------------|
| `CONTRIBUTING.md` | Contribution guidelines | Clear process for contributors |
| `CODE_OF_CONDUCT.md` | Community standards | Professional community management |
| `SECURITY.md` | Security policy | Vulnerability reporting process |
| `RELEASES.md` | Release documentation | Multi-stage release management |

### GitHub Integration

| Template | Purpose | Key Features |
|----------|---------|--------------|
| `.github/workflows/ci.yml` | Continuous integration | Multi-platform testing |
| `.github/workflows/release-beta.yml` | Beta releases | Automated beta deployment |
| `.github/workflows/release-stable.yml` | Stable releases | Production release process |
| `.github/ISSUE_TEMPLATE/` | Issue templates | Structured issue reporting |
| `.github/pull_request_template.md` | PR template | Consistent pull request format |

## Template Categories

### 1. Project Initialization
Templates for setting up new projects from scratch.

**Includes:**
- Basic project structure
- Development environment setup
- Initial documentation
- Git configuration

**Best for:** New projects, converting existing projects to agent-init standards

### 2. AI-Assisted Development
Templates specifically designed for effective AI collaboration.

**Includes:**
- CLAUDE.md variants for different project types
- Session tracking systems
- Context preservation patterns
- Issue-driven development workflows

**Best for:** Projects where AI assistance is primary development approach

### 3. Quality Assurance
Templates ensuring code quality and consistency.

**Includes:**
- Linting configurations for multiple languages
- Pre-commit hooks
- Testing framework setup
- Code formatting standards

**Best for:** Team projects, open source projects, production systems

### 4. Release Management
Templates for sophisticated release workflows.

**Includes:**
- Multi-stage release process (beta → stable)
- Automated changelog generation
- Semantic versioning
- Branch synchronization

**Best for:** Projects with formal release cycles, public packages

### 5. Documentation
Templates for comprehensive project documentation.

**Includes:**
- README templates
- Contributing guidelines
- Security policies
- Community standards

**Best for:** Open source projects, team collaboration, project handoffs

## Usage Patterns

### Quick Start (Minimal Setup)
For rapid prototyping or personal projects:

```bash
# Copy essential templates
cp templates/CLAUDE.md ./
cp templates/Makefile ./
cp templates/.gitignore ./
```

### Professional Setup (Recommended)
For team projects or production systems:

```bash
# Use the full template set
./scripts/init-project.sh --type=professional
```

### Specialized Setup
For specific project types:

```bash
# API project
./scripts/init-project.sh --type=api

# Web application
./scripts/init-project.sh --type=webapp

# CLI tool
./scripts/init-project.sh --type=cli
```

## Template Customization

### 1. Project-Specific Variables
Most templates include variables that should be replaced:

- `{{PROJECT_NAME}}` - Your project name
- `{{GITHUB_USERNAME}}` - Your GitHub username
- `{{REPOSITORY_NAME}}` - Repository name
- `{{PROJECT_DESCRIPTION}}` - Project description

### 2. Optional Sections
Templates include optional sections that can be:
- Removed if not needed
- Customized for specific requirements
- Extended with additional content

### 3. Integration Points
Templates are designed to work together:
- Makefile references scripts and configurations
- CLAUDE.md documents project structure
- GitHub workflows use configuration files
- Documentation templates cross-reference each other

## Maintenance

### Keeping Templates Updated
Templates evolve based on:
- Real-world usage experience
- New tool releases
- Community feedback
- Security updates

### Template Versioning
Templates follow semantic versioning:
- **Major**: Breaking changes requiring project updates
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes, security updates

### Migration Guides
When templates change significantly:
- Migration guides are provided
- Automated migration scripts when possible
- Changelog documents all changes
- Support for multiple template versions

## Contributing to Templates

### Adding New Templates
When contributing new templates:

1. Follow existing naming conventions
2. Include comprehensive documentation
3. Test with real projects
4. Provide usage examples
5. Update this overview

### Improving Existing Templates
When enhancing templates:

1. Maintain backward compatibility when possible
2. Document breaking changes clearly
3. Provide migration path for existing users
4. Include rationale for changes

### Template Guidelines
All templates should:
- Be well-documented
- Include clear customization instructions
- Work across different environments
- Follow security best practices
- Support automation where possible

The agent-init template system provides a solid foundation for professional development practices while remaining flexible enough to adapt to any project's specific needs.
