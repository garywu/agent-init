# Claude Templates Reference

This document provides templates and examples for common development tasks that Claude can help with. These templates are designed to work across different project types and build systems.

## Linting and Formatting

When working with Claude, you can ask it to set up linting and formatting for your project. Claude can:

1. **Detect your project type** and suggest appropriate linters
2. **Create configuration files** for the tools
3. **Add linting commands** to your existing build system
4. **Set up pre-commit hooks** for automatic checking

### Example Requests

```
"Set up linting for this Python project"
"Add shellcheck to my bash scripts"
"Configure prettier for my JavaScript files"
"Create a pre-commit configuration for this repo"
```

### What Claude Will Do

1. **Analyze your project** to determine:
   - Programming languages used
   - Existing build tools (npm, pip, cargo, etc.)
   - Current linting setup (if any)

2. **Suggest appropriate tools**:
   - For shell: shellcheck, shfmt
   - For Python: black, ruff, flake8, mypy
   - For JavaScript: eslint, prettier
   - For YAML: yamllint
   - For Markdown: markdownlint

3. **Create configuration files**:
   - `.shellcheckrc` for shell linting rules
   - `.prettierrc` for code formatting
   - `.eslintrc.json` for JavaScript linting
   - `.pre-commit-config.yaml` for git hooks

4. **Integrate with your workflow**:
   - Add to package.json scripts
   - Create Makefile targets
   - Set up GitHub Actions
   - Configure VS Code settings

### Configuration Templates

Claude has access to best-practice configurations for common tools:

#### Pre-commit Configuration
```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```

#### ESLint Configuration
```json
{
  "extends": ["eslint:recommended"],
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module"
  },
  "env": {
    "node": true,
    "es2022": true
  }
}
```

#### ShellCheck Configuration
```ini
# .shellcheckrc
disable=SC2086  # Double quote to prevent globbing
external-sources=true
```

### Project-Agnostic Approach

Claude's linting setup works with any project structure:

- **No Makefile required** - Commands work standalone
- **Build system agnostic** - Integrates with npm, cargo, make, etc.
- **CI-friendly** - Proper exit codes for automation
- **Progressive enhancement** - Start simple, add tools as needed

## Session Management

Claude can help set up session tracking for development workflows:

### Example Requests

```
"Add session tracking to this project"
"Set up development session management"
"Create a session log for tracking work"
```

### What Claude Will Provide

1. **Session tracking scripts** that:
   - Record session start/end times
   - Capture git status and branch info
   - Track work completed
   - Generate session summaries

2. **Integration options**:
   - Shell aliases for quick access
   - Git hooks for automatic tracking
   - IDE integration suggestions

## Documentation Sites

Claude can help set up documentation for your project:

### Example Requests

```
"Set up a documentation site for this project"
"Add Astro/Starlight docs"
"Create a GitHub Pages site"
```

### What Claude Will Create

1. **Documentation structure**:
   ```
   docs/
   ├── astro.config.mjs
   ├── package.json
   ├── src/
   │   ├── content/
   │   │   └── docs/
   │   └── env.d.ts
   ```

2. **Deployment configuration**:
   - GitHub Actions for automatic deployment
   - Proper base URL configuration
   - Build optimization settings

## CI/CD Workflows

Claude can create GitHub Actions workflows tailored to your project:

### Example Requests

```
"Set up CI for this Python project"
"Add automated testing to GitHub Actions"
"Create a release workflow"
```

### What Claude Will Configure

1. **Test workflows** that:
   - Run on push and pull requests
   - Use appropriate language versions
   - Cache dependencies
   - Run linting and tests

2. **Release workflows** that:
   - Create tags and releases
   - Build artifacts
   - Publish to package registries
   - Update documentation

## Best Practices

When asking Claude to set up development tools:

1. **Be specific about your needs**:
   - "I need linting for Python and shell scripts"
   - "Set up formatting that works with VS Code"

2. **Mention existing tools**:
   - "Add linting to my existing npm scripts"
   - "Integrate with my current Makefile"

3. **Specify constraints**:
   - "Must work in CI/CD"
   - "Should not require additional dependencies"

4. **Ask for explanations**:
   - "Explain what each linter does"
   - "Show me how to run these manually"

## Common Patterns

### Multi-language Projects

For projects with multiple languages, Claude will:
- Set up linters for each language
- Create unified commands to run all checks
- Configure pre-commit to handle everything

### Gradual Adoption

Claude can help you adopt linting gradually:
1. Start with basic checks (syntax errors)
2. Add style formatting
3. Enable more strict rules
4. Add type checking

### Team Workflows

For team projects, Claude will consider:
- Editor-agnostic configurations
- Clear documentation
- Automated fixes where possible
- CI integration for enforcement