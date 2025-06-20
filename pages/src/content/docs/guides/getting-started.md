---
title: Getting Started
description: A comprehensive guide to getting started with agent-init for AI-assisted development
sidebar:
  order: 1
---

# Getting Started with Agent-Init

Welcome to agent-init! This guide will help you set up your development environment for AI-assisted development with Claude.

## Prerequisites

Before you begin, ensure you have the following installed:

- Git (2.0 or higher)
- Your preferred text editor with syntax highlighting
- Basic familiarity with command-line operations

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/agent-init.git
cd agent-init
```

### 2. Initialize Your Project

Run the initialization script to set up your project with agent-init templates:

```bash
./init.sh your-project-name
```

This will:
- Create essential configuration files
- Set up development workflows
- Initialize git with proper `.gitignore`
- Create documentation templates

## Project Structure

After initialization, your project will have the following structure:

```
your-project/
├── CLAUDE.md          # AI assistant instructions
├── CHANGELOG.md       # Project changelog
├── Makefile          # Automation commands
├── README.md         # Project documentation
├── .gitignore        # Git ignore patterns
├── external/         # External dependencies (git submodules)
└── src/              # Your source code
```

## Key Components

### CLAUDE.md

The `CLAUDE.md` file contains instructions for AI assistants. It includes:

- Project overview and context
- Development standards and conventions
- Session tracking information
- Quality assurance checklists

See the [development best practices](../best-practices/development.md) for more details on maintaining this file.

### Makefile

The Makefile provides automation for common tasks:

```bash
make dev              # Start development environment
make test             # Run tests
make lint             # Run linters
make session-start    # Begin a new development session
make session-end      # End current session
```

### External Dependencies

All external repositories should be added as git submodules in the `external/` directory:

```bash
git submodule add https://github.com/example/repo.git external/repo
git submodule update --init --recursive
```

## Your First Session

### 1. Start a Development Session

```bash
make session-start
```

This will:
- Create a session entry in CLAUDE.md
- Prompt for session goals
- Set up your development environment

### 2. Create an Issue

Before writing code, create an issue to track your work:

```bash
make issue
```

### 3. Work on Your Feature

Follow the issue-driven development workflow:

1. Create a feature branch: `git checkout -b feature/issue-number-description`
2. Make your changes
3. Run quality checks: `make lint test`
4. Commit with meaningful messages

### 4. End Your Session

```bash
make session-end
```

This will:
- Update session tracking
- Run final quality checks
- Create a session summary

## Next Steps

- Read the [API Reference](../reference/api.md) to understand available commands
- Review [Development Best Practices](../best-practices/development.md)
- Explore the [example templates](./example.md) included with agent-init

## Getting Help

If you encounter issues:

1. Check the troubleshooting section in the README
2. Review the session history in CLAUDE.md
3. Create an issue with detailed context

## Additional Resources

- [Semantic Versioning Guide](https://semver.org/)
- [Keep a Changelog Format](https://keepachangelog.com/)
- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)