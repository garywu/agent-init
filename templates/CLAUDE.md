# Claude AI Session Tracking

This file tracks AI-assisted development sessions and important information for continuity between sessions.

## Current Session Information

- **Date**: [YYYY-MM-DD]
- **Session ID**: [Generated Session ID]
- **Primary Goals**: 
  - [ ] Goal 1
  - [ ] Goal 2

## Important Commands

```bash
# Linting and formatting
make lint                # Run all linters
make format             # Format all code

# Git workflow
gh issue list           # View all issues
gh issue create         # Create new issue
gh pr create            # Create pull request

# Development
make test               # Run tests
make build              # Build project
```

## Workflow Procedure

### 1. Planning Phase
- **Always start with planning** - Never modify code without a clear plan
- **Create GitHub issues** for all planned work
- **Add comments** to issues for clarifications and questions
- **Wait for approval** before proceeding with implementation

### 2. Issue Creation
- Use descriptive titles with appropriate prefixes:
  - `[BUG]` for bug fixes
  - `[FEAT]` for new features
  - `[DOCS]` for documentation
  - `[REFACTOR]` for code refactoring
  - `[TEST]` for test additions/modifications
  - `[CHORE]` for maintenance tasks

### 3. Development Process
1. **Select an issue** from the backlog
2. **Plan the implementation** in issue comments
3. **Get approval** on the approach
4. **Implement the solution**
5. **Update issue** with progress
6. **Create PR** when complete

### 4. Pull Request Guidelines
- Reference the issue number in PR description
- Include test results
- Ensure all checks pass
- Request review when ready

## Active Issues

| Issue # | Title | Status | Priority |
|---------|-------|--------|----------|
| #1      | [Example] | Planning | High |

## Completed Issues

| Issue # | Title | PR # | Date Completed |
|---------|-------|------|----------------|
| -       | -     | -    | -              |

## Project Structure

```
.
├── src/                 # Source code
├── tests/              # Test files
├── docs/               # Documentation
├── scripts/            # Utility scripts
├── .github/            # GitHub configuration
│   ├── workflows/      # CI/CD workflows
│   └── ISSUE_TEMPLATE/ # Issue templates
├── CLAUDE.md           # This file
├── README.md           # Project documentation
├── CONTRIBUTING.md     # Contribution guidelines
├── CODE_OF_CONDUCT.md  # Code of conduct
└── SECURITY.md         # Security policy
```

## Development Environment

### Available Tools
The following CLI tools are available and should be used:

- **Search & Navigation**: `rg`, `fd`, `ag`, `fzf`, `broot`
- **File Operations**: `eza`, `bat`, `sd`, `lsd`
- **Git Operations**: `gh`, `lazygit`, `delta`, `tig`, `gitui`
- **Development**: `tokei`, `hyperfine`, `watchexec`
- **Data Processing**: `jq`, `yq`, `gron`, `jless`

### Key Configurations
- **Linting**: ShellCheck, YAML lint, Markdown lint, Python (flake8, black)
- **Pre-commit hooks**: Configured in `.pre-commit-config.yaml`
- **CI/CD**: GitHub Actions workflows for testing and deployment
- **Version**: Following Semantic Versioning (starting at 0.0.1)

## Notes for Next Session

- [ ] Review any pending issues
- [ ] Check CI/CD pipeline status
- [ ] Update documentation if needed

## Session History

### Previous Sessions
| Date | Session ID | Key Accomplishments |
|------|------------|-------------------|
| -    | -          | Initial setup     |

---

Remember: Always plan ahead, create issues, and document everything!