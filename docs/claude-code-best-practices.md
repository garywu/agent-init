# Claude Code Best Practices

This guide consolidates official best practices from Anthropic's engineering team for using Claude Code effectively.

## Table of Contents

1. [Setup and Configuration](#setup-and-configuration)
2. [CLAUDE.md Files](#claudemd-files)
3. [Workflow Strategies](#workflow-strategies)
4. [Advanced Techniques](#advanced-techniques)
5. [Safety and Security](#safety-and-security)
6. [Practical Tips](#practical-tips)

## Setup and Configuration

### Essential Setup Steps

1. **Install GitHub CLI** for enhanced repository interactions:
   ```bash
   # macOS
   brew install gh
   
   # Linux
   sudo apt install gh
   
   # Windows
   winget install --id GitHub.cli
   ```

2. **Configure Claude Code settings** at `~/.claude/settings.json`:
   ```json
   {
     "defaultTools": ["bash", "git", "gh"],
     "editor": "vim",
     "theme": "dark"
   }
   ```

3. **Customize permissions** using `/permissions` command to:
   - Enable/disable specific tools
   - Set file system boundaries
   - Configure network access

## CLAUDE.md Files

### Purpose and Benefits

`CLAUDE.md` files act as persistent context for Claude, helping maintain consistency across sessions. Place them at your project root.

### Essential Sections

```markdown
# Claude Development Instructions

## Project Overview
Brief description of the project's purpose and architecture.

## Environment Setup
```bash
# Installation commands
npm install
pip install -r requirements.txt
```

## Code Style Guidelines
- Use 2 spaces for indentation
- Follow ESLint/Prettier configurations
- Prefer functional components in React

## Common Commands
```bash
# Development
npm run dev

# Testing
npm test

# Build
npm run build
```

## Repository Etiquette
- Always run tests before committing
- Use conventional commit messages
- Create feature branches for new work

## Project-Specific Context
- API endpoints are in `/api`
- Database schemas in `/db/schema`
- Components use TypeScript strict mode
```

## Workflow Strategies

### 1. Explore-Plan-Code-Commit Workflow

**Best for:** New features and bug fixes

```
1. Explore: Read relevant files and understand context
2. Plan: Have Claude create a detailed implementation plan
3. Code: Implement the solution incrementally
4. Commit: Document changes with clear commit messages
```

Example:
```
User: "Add user authentication to the app"
Claude: [Reads auth-related files]
Claude: "I'll implement authentication by:
1. Creating auth middleware
2. Adding login/logout endpoints
3. Protecting routes
4. Adding session management"
User: "Proceed with the plan"
Claude: [Implements each step]
```

### 2. Test-Driven Development (TDD)

**Best for:** Complex logic and API development

```
1. Write failing tests first
2. Implement minimal code to pass tests
3. Refactor and optimize
4. Verify with subagents
```

Example workflow:
```bash
# Step 1: Write test
claude "Write tests for user validation function"

# Step 2: Run test (should fail)
claude "Run the user validation tests"

# Step 3: Implement
claude "Implement user validation to pass tests"

# Step 4: Verify
claude "Run tests again and confirm they pass"
```

### 3. Visual Iteration Approach

**Best for:** UI development and design implementation

```
1. Provide screenshot or mockup
2. Claude implements initial version
3. Claude screenshots the result
4. Iterate until design matches
```

Tips:
- Use high-quality screenshots
- Be specific about spacing, colors, and interactions
- Ask Claude to highlight differences

## Advanced Techniques

### Using Subagents

Launch subagents for complex or parallel tasks:

```bash
# Research task
claude "Research best practices for React performance optimization"

# Testing task
claude "Run all tests and fix any failures"

# Documentation task
claude "Update API documentation based on recent changes"
```

### Think Mode for Complex Problems

Use extended thinking for architecture decisions:

```
claude --think "Design a scalable microservices architecture for our e-commerce platform"
```

### Custom Slash Commands

Create project-specific commands in `CLAUDE.md`:

```markdown
## Custom Commands

/test-all - Run full test suite with coverage
/deploy-staging - Deploy to staging environment
/db-migrate - Run database migrations
```

### Headless Mode for Automation

Use in CI/CD pipelines:

```bash
# Automated code review
claude --headless "Review PR changes and suggest improvements"

# Documentation generation
claude --headless "Generate API docs from code comments"
```

### Multiple Instances

Run parallel Claude instances for different tasks:

```bash
# Terminal 1: Frontend development
claude "Implement new dashboard components"

# Terminal 2: Backend API
claude "Add REST endpoints for user management"

# Terminal 3: Testing
claude "Write integration tests for the new features"
```

## Safety and Security

### Permission Management

1. **Default to restricted permissions**
   - Start with minimal permissions
   - Add as needed

2. **Use containerized environments**
   - Docker/Podman for isolation
   - Virtual machines for sensitive work

3. **Avoid dangerous flags**
   - Use `--dangerously-skip-permissions` only when absolutely necessary
   - Always in isolated environments

### Code Review Practices

1. **Always review Claude's changes**
   ```bash
   git diff  # Review changes
   git add -p  # Stage selectively
   ```

2. **Use version control effectively**
   - Commit frequently
   - Use descriptive commit messages
   - Create feature branches

## Practical Tips

### Communication Strategies

1. **Be Specific**
   - ❌ "Fix the bug"
   - ✅ "Fix the authentication bug where users can't log in with email addresses containing '+'"

2. **Provide Context**
   - Include error messages
   - Share relevant code snippets
   - Describe expected behavior

3. **Course-Correct Early**
   - If Claude misunderstands, clarify immediately
   - Use `/clear` to reset context when needed

### Context Management

1. **Use `/clear` strategically**
   - When switching between unrelated tasks
   - After completing major features
   - When context becomes cluttered

2. **Maintain focused sessions**
   - One feature per session
   - Clear separation of concerns

### Visual References

1. **Screenshots for UI work**
   - Current state vs desired state
   - Annotate important elements
   - Include browser developer tools when relevant

2. **Diagrams for architecture**
   - System diagrams
   - Flow charts
   - Database schemas

### Experimentation

1. **Try different approaches**
   - Test various prompting styles
   - Experiment with tool combinations
   - Find what works for your workflow

2. **Adapt and iterate**
   - Refine your CLAUDE.md over time
   - Update based on project needs
   - Share successful patterns with team

## Quick Reference Card

### Essential Commands
```bash
# Project setup
claude init

# Permissions
/permissions

# Context management
/clear

# Help
/help

# Exit
/exit
```

### Workflow Checklist
- [ ] Create/update CLAUDE.md
- [ ] Configure permissions appropriately
- [ ] Use version control
- [ ] Review all changes
- [ ] Commit with clear messages
- [ ] Document important decisions

### Red Flags to Avoid
- 🚫 Running unknown scripts without review
- 🚫 Using dangerous permission flags in production
- 🚫 Ignoring error messages
- 🚫 Skipping code review
- 🚫 Working without version control

## References

- [Official Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Anthropic Engineering Blog](https://www.anthropic.com/engineering)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)