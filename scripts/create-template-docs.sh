#!/bin/bash
# Script to create documentation for templates
# This generates reference documentation for all templates in the templates/ directory

set -euo pipefail

# Configuration
TEMPLATES_DIR="templates"
PAGES_TARGET_DIR="pages/src/content/docs/reference"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create CLAUDE.md template documentation
create_claude_templates_doc() {
    local target_file="$PAGES_TARGET_DIR/claude-templates.md"
    
    log_info "Creating CLAUDE.md templates documentation"
    
    cat << 'EOF' > "$target_file"
---
title: CLAUDE.md Templates
description: Documentation for CLAUDE.md templates that enable effective AI-assisted development
sidebar:
  order: 10
---

# CLAUDE.md Templates

Agent Init provides several CLAUDE.md templates to help you set up effective AI-assisted development workflows. These templates serve as the foundation for maintaining context and continuity across Claude sessions.

## Template Variants

### Base Template (`CLAUDE.md`)

The standard CLAUDE.md template suitable for most projects.

**Key Features:**
- Session tracking with goals and progress
- Issue-driven development workflow
- Available CLI tools documentation
- Project structure overview
- Development environment setup

**Best for:** General projects, libraries, CLI tools

### API Development Template (`CLAUDE-api.md`)

Specialized template for API development projects.

**Additional Features:**
- API endpoint documentation structure
- Request/response examples
- Authentication and authorization patterns
- OpenAPI/Swagger integration
- Database schema tracking

**Best for:** REST APIs, GraphQL APIs, microservices

### Web Application Template (`CLAUDE-web-app.md`)

Template optimized for web application development.

**Additional Features:**
- Frontend/backend architecture overview
- Component structure documentation
- State management patterns
- Build and deployment configuration
- User authentication flows

**Best for:** Single-page applications, full-stack web apps

## Template Structure

All CLAUDE.md templates follow a consistent structure:

### 1. Session Information
Track current development session with:
- Date and session ID
- Primary goals and objectives
- Progress checkboxes

### 2. Important Commands
Quick reference for essential commands:
- Linting and formatting
- Git workflow (issues, PRs)
- Development (test, build)
- Release management

### 3. Workflow Procedure
Step-by-step development process:
- Planning phase requirements
- Issue creation guidelines
- Development process
- Pull request guidelines
- Release management

### 4. Active Issues Tracking
Tables for managing:
- Active issues with status
- Completed issues with PRs
- Issue priorities

### 5. Project Structure
Clear overview of:
- Directory organization
- Key files and their purposes
- Configuration locations

### 6. Development Environment
Documentation of:
- Available CLI tools
- Key configurations
- Version information
- Release channels

### 7. Session Notes
Space for:
- Notes for next session
- Session history
- Key accomplishments

## Customization Guidelines

### Adding Project-Specific Sections

You can extend templates with:

```markdown
## Project-Specific Information

### Architecture Decisions
- [Decision 1]: Rationale and alternatives considered
- [Decision 2]: Implementation details

### External Dependencies
- Service A: Purpose and integration details
- Library B: Version and usage patterns

### Environment Variables
| Variable | Purpose | Example |
|----------|---------|---------|
| API_KEY  | Authentication | `sk-...` |
```

### Integration with Tools

Templates can be enhanced with tool-specific sections:

```markdown
## Tool Integration

### Docker
- Container configuration in `docker-compose.yml`
- Development: `docker-compose up -d`
- Production: See deployment guide

### Database
- Migrations: `npm run migrate`
- Seed data: `npm run seed`
- Schema: See `docs/schema.md`
```

## Best Practices

### 1. Keep Templates Updated
- Review and update templates regularly
- Add new commands as you discover them
- Update project structure as it evolves

### 2. Use Consistent Formatting
- Follow the established markdown structure
- Use tables for structured data
- Include code blocks with syntax highlighting

### 3. Maintain Context
- Update session information at start/end of sessions
- Log key decisions and their rationales
- Track issue progress consistently

### 4. Customize for Team
- Add team-specific workflows
- Include deployment procedures
- Document code review processes

## Template Selection Guide

Choose the right template based on your project type:

| Project Type | Template | Key Benefits |
|--------------|----------|--------------|
| Library/Package | `CLAUDE.md` | Simple, focused on code quality |
| REST API | `CLAUDE-api.md` | API-specific documentation structure |
| Web App | `CLAUDE-web-app.md` | Frontend/backend organization |
| CLI Tool | `CLAUDE.md` | Standard structure with tool focus |
| Documentation Site | `CLAUDE.md` | Content and publishing workflow |

## Integration with Agent Init

CLAUDE.md templates integrate seamlessly with other agent-init components:

- **Makefile**: Commands referenced in templates
- **GitHub Actions**: Release workflows documented
- **Session Scripts**: Automated session management
- **Issue Templates**: Consistent issue creation

## Advanced Usage

### Multiple CLAUDE Files

For complex projects, you can use multiple CLAUDE files:

```
CLAUDE.md              # Main project context
CLAUDE-frontend.md     # Frontend-specific context
CLAUDE-backend.md      # Backend-specific context
CLAUDE-infra.md        # Infrastructure context
```

### Template Inheritance

Create project-specific templates that extend base templates:

```markdown
<!-- Include base template content -->
<!-- Add project-specific sections -->

## Project: MyApp Specific

### Custom Workflows
- Deployment to staging: `make deploy-staging`
- Database migration: `make db-migrate`
```

Remember: The goal is to provide Claude with comprehensive context about your project, enabling more effective assistance throughout your development workflow.
EOF
    
    log_info "Created: $target_file"
}

# Function to create Makefile documentation
create_makefile_doc() {
    local target_file="$PAGES_TARGET_DIR/makefile-commands.md"
    
    log_info "Creating Makefile commands documentation"
    
    cat << 'EOF' > "$target_file"
---
title: Makefile Commands
description: Complete reference for agent-init Makefile automation commands
sidebar:
  order: 20
---

# Makefile Commands Reference

Agent Init provides a comprehensive Makefile template that automates common development tasks. This reference documents all available commands and their usage.

## Quick Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `make help` | Show all available commands | `make help` |
| `make dev` | Start development server | `make dev` |
| `make test` | Run all tests | `make test` |
| `make lint` | Run all linters | `make lint` |
| `make build` | Build project | `make build` |

## Development Commands

### `make dev`
Start the development server or development environment.

**Behavior varies by project type:**
- **Web apps**: Starts development server (usually `npm run dev`)
- **APIs**: Starts server with hot reload
- **CLIs**: Enters development shell with tool available

### `make build`
Build the project for production.

**Examples:**
```bash
make build              # Standard build
make build PROD=1       # Production build with optimizations
```

### `make test`
Run the complete test suite.

**Options:**
```bash
make test               # Run all tests
make test VERBOSE=1     # Verbose output
make test COVERAGE=1    # With coverage report
```

### `make test-watch`
Run tests in watch mode (if supported by framework).

## Code Quality Commands

### `make lint`
Run all configured linters.

**Typically includes:**
- Language-specific linters (eslint, flake8, etc.)
- Shell script linting (shellcheck)
- YAML linting (yamllint)
- Markdown linting (markdownlint)

### `make format`
Format all code using configured formatters.

**Examples:**
```bash
make format             # Format all files
make format-check       # Check formatting without changing
```

### `make check`
Run all checks (lint + test + type checking).

```bash
make check              # Full check suite
make check-ci           # CI-optimized checks
```

## Git Workflow Commands

### `make issue`
Create a new GitHub issue.

**Usage:**
```bash
make issue TITLE="Fix bug in authentication"
make issue TITLE="Add new feature" LABELS="enhancement,priority-high"
```

### `make pr`
Create a pull request for current branch.

**Prerequisites:**
- Changes committed to feature branch
- Issue exists for the work

**Usage:**
```bash
make pr                 # Create PR with default template
make pr DRAFT=1         # Create draft PR
```

### `make sync`
Synchronize with remote repository.

```bash
make sync               # Sync current branch
make sync-main          # Sync main branch specifically
```

## Session Management Commands

### `make session-start`
Start a new development session.

**Actions:**
- Creates session log entry
- Updates CLAUDE.md with session info
- Checks for pending issues
- Verifies environment setup

### `make session-end`
End the current development session.

**Actions:**
- Updates session log with accomplishments
- Commits any pending documentation changes
- Creates session summary

### `make session-log`
View session history and current status.

```bash
make session-log        # Show recent sessions
make session-log FULL=1 # Show complete history
```

### `make session-status`
Show current session status and pending work.

## Release Management Commands

### `make release-beta`
Create a beta release.

**Process:**
- Runs full test suite
- Updates version number
- Creates release commit
- Triggers beta release workflow

### `make release-stable`
Promote beta to stable release.

**Prerequisites:**
- Beta version exists and is tested
- All checks pass

### `make changelog`
Generate or update changelog.

```bash
make changelog          # Generate changelog
make changelog-view     # View recent changes
```

## Maintenance Commands

### `make clean`
Clean build artifacts and temporary files.

```bash
make clean              # Standard cleanup
make clean-all          # Deep cleanup including dependencies
```

### `make install`
Install project dependencies.

```bash
make install            # Install standard dependencies
make install-dev        # Install with development dependencies
```

### `make update`
Update dependencies to latest versions.

```bash
make update             # Update all dependencies
make update-check       # Check for available updates
```

## Environment Commands

### `make env-check`
Verify development environment setup.

**Checks:**
- Required tools are installed
- Configuration files are present
- Environment variables are set
- Dependencies are up to date

### `make env-setup`
Set up development environment.

**Actions:**
- Install required tools
- Create configuration files
- Set up git hooks
- Initialize database (if applicable)

## Deployment Commands

### `make deploy-staging`
Deploy to staging environment.

**Prerequisites:**
- All tests pass
- Changes are in deployable branch

### `make deploy-prod`
Deploy to production environment.

**Prerequisites:**
- Staging deployment successful
- All checks pass
- Release approved

## Debugging Commands

### `make debug`
Start debugging environment.

**Options:**
```bash
make debug              # Start standard debugger
make debug-test         # Debug failing tests
make debug-build        # Debug build issues
```

### `make logs`
View application logs.

```bash
make logs               # Recent logs
make logs FOLLOW=1      # Follow logs in real-time
make logs ERROR=1       # Error logs only
```

## Customization

### Adding Custom Commands

Add project-specific commands to your Makefile:

```makefile
# Add after including the base template

.PHONY: custom-task
custom-task: ## Run custom project task
	@echo "Running custom task..."
	./scripts/custom-task.sh

.PHONY: deploy-docs
deploy-docs: build ## Deploy documentation
	@echo "Deploying documentation..."
	cd docs && npm run deploy
```

### Environment Variables

Control behavior with environment variables:

```bash
# Development vs production builds
ENVIRONMENT=production make build

# Verbose output
VERBOSE=1 make test

# Skip certain checks
SKIP_LINT=1 make check
```

### Configuration Files

Commands can be configured via:
- `.makerc` - Local Makefile configuration
- `Makefile.local` - Local overrides (git-ignored)
- Environment variables
- Command-line parameters

## Best Practices

### 1. Always Use Make Commands
Instead of remembering complex npm/poetry/cargo commands, use standardized make commands.

### 2. Check Available Commands
Run `make help` to see all available commands for the current project.

### 3. Use Session Management
Start and end sessions with `make session-start` and `make session-end` for better tracking.

### 4. Customize for Your Project
Add project-specific commands while maintaining the standard interface.

### 5. Document Custom Commands
Use the `## Description` format for custom commands to appear in `make help`.

The Makefile serves as the central automation hub for agent-init projects, providing a consistent interface across different project types and languages.
EOF
    
    log_info "Created: $target_file"
}

# Function to create templates overview
create_templates_overview() {
    local target_file="$PAGES_TARGET_DIR/templates-overview.md"
    
    log_info "Creating templates overview documentation"
    
    cat << 'EOF' > "$target_file"
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
EOF
    
    log_info "Created: $target_file"
}

# Main function
main() {
    cd "$PROJECT_ROOT"
    
    log_info "Creating template documentation..."
    
    # Create target directory
    mkdir -p "$PAGES_TARGET_DIR"
    
    # Create documentation files
    create_claude_templates_doc
    create_makefile_doc
    create_templates_overview
    
    log_info "Template documentation created successfully!"
    log_info ""
    log_info "Created files:"
    log_info "- $PAGES_TARGET_DIR/claude-templates.md"
    log_info "- $PAGES_TARGET_DIR/makefile-commands.md"
    log_info "- $PAGES_TARGET_DIR/templates-overview.md"
}

# Run main function
main "$@"