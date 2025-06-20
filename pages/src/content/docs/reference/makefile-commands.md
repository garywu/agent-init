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
