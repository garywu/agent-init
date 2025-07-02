# Claude Code Quick Reference

A concise guide to Claude Code best practices from Anthropic's engineering team.

## Essential Setup

```bash
# 1. Install GitHub CLI (required)
brew install gh          # macOS
sudo apt install gh      # Linux

# 2. Configure permissions
/permissions             # In Claude Code

# 3. Create CLAUDE.md at project root
cp path/to/template/CLAUDE.md .
```

## Core Workflows

### EPCC (Explore-Plan-Code-Commit)
```bash
make epcc                # Show workflow guide

# 1. Explore: Read files, understand context
# 2. Plan: Create detailed implementation plan
# 3. Code: Implement incrementally
# 4. Commit: Atomic commits with clear messages
```

### TDD (Test-Driven Development)
```bash
make tdd                 # Show TDD guide

# 1. Red: Write failing tests
# 2. Green: Minimal code to pass
# 3. Refactor: Improve while keeping tests green
```

### Visual Iteration (UI Development)
```bash
make visual              # Show visual workflow

# 1. Provide screenshot/mockup
# 2. Implement initial version
# 3. Screenshot and compare
# 4. Iterate until perfect
```

## Key Commands

### Claude Code Commands
```bash
/permissions             # Configure tool access
/clear                   # Clear context (use when switching tasks)
/help                    # Get command help
/exit                    # Exit Claude Code
```

### Session Management
```bash
make session-start       # Begin tracked session
make session-status      # Check progress
make session-log MSG="..." # Log activity
make session-end         # End with summary
```

### Development
```bash
make dev                 # Start development server
make test                # Run tests
make lint                # Check code quality
make build               # Build project
```

### Git Workflow
```bash
gh issue create          # Create issue first!
gh issue list            # View issues
gh pr create             # Create pull request
git add -p               # Stage changes interactively
```

## Best Practices Checklist

### Before Starting
- [ ] Read CLAUDE.md for project context
- [ ] Check existing issues with `gh issue list`
- [ ] Run `make analyze` to understand project
- [ ] Configure permissions appropriately

### During Development
- [ ] Create issue before coding
- [ ] Follow EPCC workflow
- [ ] Make atomic commits
- [ ] Use `/clear` when switching tasks
- [ ] Run tests frequently

### Communication
- [ ] Be specific in requests
- [ ] Include screenshots for UI work
- [ ] Course-correct early
- [ ] Document decisions in issues

### Safety
- [ ] Review all changes before committing
- [ ] Use containerized environments for sensitive work
- [ ] Never use `--dangerously-skip-permissions` in production
- [ ] Check for secrets before pushing

## Advanced Techniques

### Parallel Development
```bash
# Terminal 1: Frontend
claude "Implement dashboard UI"

# Terminal 2: Backend
claude "Create API endpoints"

# Terminal 3: Tests
claude "Write integration tests"
```

### Subagents
```bash
# Launch subagent for specific task
claude "Research performance optimization strategies"
```

### Think Mode
```bash
# Deep analysis
claude --think "Design scalable architecture"
```

### Headless Mode
```bash
# Automation
claude --headless "Generate API documentation"
```

## Common Patterns

### Issue-Driven Development
```bash
# 1. Create issue
gh issue create --title "Add user authentication"

# 2. Work on issue
git checkout -b feature/auth-45

# 3. Reference in commits
git commit -m "feat: add login endpoint (#45)"

# 4. Create PR
gh pr create --title "Add user authentication" --body "Closes #45"
```

### Atomic Commits
```bash
# After each logical change
git add -p                    # Stage selectively
git diff --staged             # Review
git commit -m "feat: add validation (#45)"
gh issue comment 45 --body "Added validation in abc123"
```

## Project Types

### Web Applications
- Use `make dev` for development server
- Follow component patterns
- Use visual iteration for UI

### APIs
- Start with TDD for endpoints
- Document with OpenAPI/Swagger
- Test with curl/httpie examples

### Libraries
- Focus on API design first
- Comprehensive test coverage
- Clear documentation with examples

## Troubleshooting

### Context Issues
```bash
/clear                   # Reset context
make session-status      # Check current state
```

### Permission Errors
```bash
/permissions             # Reconfigure access
```

### Git Problems
```bash
git status              # Check state
git diff                # Review changes
git reset --soft HEAD~1 # Undo last commit
```

## Resources

- [Full Best Practices Guide](./claude-code-best-practices.md)
- [Workflow Templates](../templates/workflows/)
- [CLAUDE.md Template](../templates/CLAUDE-enhanced.md)
- [Official Documentation](https://docs.anthropic.com/claude-code)