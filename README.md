# Agent Init - Professional Repository Setup

[![Release](https://img.shields.io/github/v/release/garywu/agent-init?include_prereleases&sort=semver&display_name=tag&style=flat-square)](https://github.com/garywu/agent-init/releases/latest)
[![Stable](https://img.shields.io/badge/channel-stable-green?style=flat-square)](https://github.com/garywu/agent-init/tree/stable)
[![Beta](https://img.shields.io/badge/channel-beta-orange?style=flat-square)](https://github.com/garywu/agent-init/tree/beta)
[![Development](https://img.shields.io/badge/channel-main-red?style=flat-square)](https://github.com/garywu/agent-init/tree/main)

This repository provides templates and instructions for Claude to initialize professional development standards in any repository.

## Core Design Principle

**Agent-init is an information resource, not a decision-making tool.**

This repository provides comprehensive documentation and reference materials for Claude CLI to use when setting up projects. Key principles:

1. **Information over Implementation** - We provide extensive documentation about tools, patterns, and best practices rather than executable scripts that make assumptions.

2. **Context-Aware Application** - The Claude CLI applying these templates has no prior knowledge about the specific repository. By providing information rather than rigid scripts, Claude can make intelligent decisions based on the actual project context.

3. **Maximum Flexibility** - Every project is different. We document multiple approaches, tools, and patterns so Claude can choose the most appropriate ones for each situation.

4. **Deferred Decision Making** - We don't make decisions now about things we can't know. Instead, we provide the information needed to make those decisions when the context is available.

### For Claude CLI
When applying these templates, use the documentation to understand available options and make context-appropriate choices based on:
- The project's existing structure and tools
- The programming languages in use
- The team's stated preferences
- The project's specific requirements

### For Contributors
When adding to agent-init, focus on:
- Documenting multiple approaches rather than prescribing one
- Explaining when and why to use different tools
- Providing examples and patterns, not rigid implementations
- Teaching concepts that Claude can adapt to any situation

## Installation

### Stable Channel (Recommended)
```bash
git submodule add -b stable https://github.com/garywu/agent-init.git external/agent-init
```

### Beta Channel (Early Access)
```bash
git submodule add -b beta https://github.com/garywu/agent-init.git external/agent-init
```

### Development Channel (Latest)
```bash
git submodule add https://github.com/garywu/claude-init.git external/claude-init
```

See [RELEASES.md](RELEASES.md) for detailed release management information.

## Purpose

When you ask Claude to set up professional development practices, Claude will use these templates to establish:

1. **Issue-driven development workflow** - All work tracked through GitHub issues
2. **Professional standards** - Linting, testing, CI/CD, security policies
3. **AI-assisted development** - CLAUDE.md for session continuity
4. **Comprehensive documentation** - Contributing guidelines, code of conduct
5. **Automation** - Pre-commit hooks, GitHub Actions, semantic versioning
6. **Multi-stage releases** - Beta testing before stable releases

## Guidelines for Claude CLI

Use the information in this repository to make intelligent decisions based on project context. Here's what to consider:

### Project Assessment

First, understand what you're working with:
- **Empty directory**: May need complete initialization including git setup
- **Empty repository**: Already has git but may lack professional structure
- **Existing repository**: Has code and possibly some tooling already

### Available Resources

This repository provides:
- **Templates**: Starting points that should be customized for each project
- **Documentation**: Explanations of tools, patterns, and best practices
- **Examples**: Multiple approaches to common problems
- **Guidelines**: When and why to use different solutions

### Decision Making

Consider these factors when applying templates:
- **Language ecosystem**: Different languages have different conventions (npm for JS, pip for Python, cargo for Rust)
- **Existing tools**: Work with what's already there rather than replacing
- **Project size**: Solo projects need different processes than team projects
- **Domain requirements**: Web apps, CLI tools, libraries all have different needs

### Key Principles

1. **CLAUDE.md is essential**: Always create this for session continuity
2. **Issues before implementation**: Track work properly
3. **Respect existing choices**: Don't override without good reason
4. **Document decisions**: Explain why you chose specific approaches
5. **Progressive enhancement**: Start simple, add complexity as needed

## Available Templates

```
templates/
├── .github/
│   ├── ISSUE_TEMPLATE/           # Bug report, feature request, etc.
│   ├── workflows/                # GitHub Actions CI/CD
│   │   ├── ci.yml               # Continuous integration
│   │   ├── release-beta.yml     # Beta release workflow
│   │   └── release-stable.yml   # Stable release workflow
│   └── pull_request_template.md
├── scripts/
│   └── session/                  # Session management tools
│       ├── session-start.sh
│       ├── session-end.sh
│       ├── session-status.sh
│       └── session-log.sh
├── docs/                         # Documentation templates
│   ├── astro.config.mjs         # Astro documentation site
│   └── package.json             # Docs dependencies
├── CLAUDE.md                     # AI session tracking
├── CONTRIBUTING.md               # Contribution guidelines  
├── SECURITY.md                  # Security policy
├── Makefile                     # Common development tasks
├── .pre-commit-config.yaml      # Code quality hooks
├── .editorconfig               # Editor configuration
├── .gitignore                  # Comprehensive ignore patterns
├── .yamllint                   # YAML linting rules
├── .releaserc.json             # Semantic release config
└── README.md                   # Project template
```

## Smart EditorConfig System

Claude-init includes an intelligent EditorConfig system that eliminates indentation conflicts across different project types:

### 🎯 Zero-Error Configuration

The system provides project-type-specific EditorConfig templates that prevent all pre-commit hook failures:

```
templates/editorconfig-variants/
├── .editorconfig-web           # 2-space for frontend projects
├── .editorconfig-infrastructure # 4-space for systems/DevOps
├── .editorconfig-backend       # 4-space for server applications
├── .editorconfig-fullstack     # Language-specific rules
└── .editorconfig-library       # Ecosystem-appropriate standards
```

### 📊 Intelligent Project Detection

Claude CLI can automatically detect project type and apply the correct configuration:

- **Web Projects**: React, Vue, Angular → 2-space indentation
- **Infrastructure**: Docker, Terraform, shell scripts → 4-space for scripts
- **Backend**: Python, Go servers → 4-space following language standards
- **Full-Stack**: Mixed rules based on file location and type
- **Libraries**: Follows ecosystem conventions

### 🔧 Key Features

1. **Automatic Detection**: `scripts/setup-editorconfig.sh` analyzes project and applies correct template
2. **Evolution Support**: Handles project growth (e.g., web → full-stack)
3. **Conflict Resolution**: Eliminates global vs project-specific indentation conflicts
4. **Claude CLI Integration**: Provides exact commands for zero-error operation

### 📚 Documentation

- **[Claude Decision Matrix](docs/CLAUDE_DECISION_MATRIX.md)** - Instant patterns for project type detection
- **[Project Evolution Patterns](docs/PROJECT_EVOLUTION_PATTERNS.md)** - Handles growing complexity
- **[Claude CLI Integration](docs/CLAUDE_CLI_INTEGRATION.md)** - Zero-error commands and patterns
- **[Master Config](claude-config.yaml)** - YAML-based rules for quick reference

## Documentation Resources

Our documentation captures real-world debugging experiences and hard-won knowledge:

### 📚 Core Guides
- **[Documentation Index](docs/README.md)** - Start here for navigation and overview
- **[Project Structure Patterns](docs/project-structure-patterns.md)** - Organization best practices
- **[Environment Adaptation Patterns](docs/environment-adaptation-patterns.md)** - CI, platform, and context handling
- **[Interactive CLI Tools](docs/interactive-cli-tools.md)** - fzf, gum, and UX enhancement tools
- **[Linting and Formatting Guide](docs/linting-and-formatting.md)** - Multi-language reference
- **[Testing Framework Guide](docs/testing-framework-guide.md)** - Comprehensive testing patterns
- **[GitHub Actions Multi-Platform](docs/github-actions-multi-platform.md)** - CI/CD across OS platforms
- **[Documentation Site Setup](docs/documentation-site-setup.md)** - Astro/Starlight lessons learned
- **[Release Management Patterns](docs/release-management-patterns.md)** - Semantic versioning automation
- **[Error Handling Patterns](docs/error-handling-patterns.md)** - Recovery and rollback strategies
- **[ShellCheck Best Practices](docs/shellcheck-best-practices.md)** - Shell script static analysis
- **[Building Validation Systems](docs/building-validation-systems.md)** - Environment validation frameworks
- **[Python Environment Setup](docs/python-environment-setup.md)** - Virtual environments and pipx

### 🔍 Problem-Solving Guides
- **[Debugging and Troubleshooting](docs/debugging-and-troubleshooting.md)** - Common issues and solutions
- **[Learning from Mistakes](docs/learning-from-mistakes.md)** - How we capture debugging knowledge
- **[Claude Templates Reference](docs/CLAUDE_TEMPLATES.md)** - Examples and patterns for Claude

### 💡 Key Learnings
- **3.5 hours debugging Astro** → Documented → **5 minutes for you**
- **Platform-specific CI failures** → Documented → **Avoid completely**
- **Complex test frameworks** → Documented → **Copy proven patterns**

## Available CLI Tools

These tools are pre-installed on the system and can greatly enhance Claude CLI's capabilities:

### Search & Navigation
- `rg` (ripgrep) - Ultra-fast search
- `fd` - User-friendly find
- `ag` - Silver searcher
- `fzf` - Fuzzy finder
- `broot` - Interactive tree navigation

### File Operations  
- `bat` - Better cat with syntax highlighting
- `eza` - Better ls with colors/icons
- `sd` - Better sed for find/replace
- `jq`/`yq` - JSON/YAML processing

### Git Tools
- `gh` - GitHub CLI (ESSENTIAL for issue/PR management)
- `lazygit` - Terminal UI for git
- `delta` - Better git diff
- `tig`/`gitui` - Git interfaces

### Development
- `tokei` - Count lines of code
- `hyperfine` - Benchmarking tool
- `watchexec` - Run commands on file change
- `pre-commit` - Git hook framework

## Key Principles

1. **Always start with CLAUDE.md** - Document the session and plan
2. **Create issues before code changes** - Track all work
3. **Use GitHub CLI (`gh`)** - For issue and PR management  
4. **Run linters before committing** - Maintain code quality
5. **Document as you go** - Keep everything up to date

## Contributing to Claude-Init

When contributing to this repository, remember our core principle: **provide information, not prescriptions**.

### What to Contribute

- **Multiple approaches**: Document different ways to solve problems
- **Context guides**: Explain when to use which approach
- **Tool documentation**: How tools work, not just commands
- **Pattern libraries**: Common patterns with explanations
- **Decision trees**: Help Claude make intelligent choices

### What to Avoid

- **Rigid scripts**: That assume one way is right
- **Hardcoded values**: That won't work everywhere  
- **Single solutions**: Without alternatives
- **Assumptions**: About project structure or preferences

### Example Contribution

Instead of:
```bash
# Bad: Prescriptive script
npm install -g eslint prettier
echo '{"extends": "airbnb"}' > .eslintrc
```

Provide:
```markdown
## JavaScript Linting Options

1. **ESLint** - Highly configurable, many presets available
   - Popular configs: airbnb, standard, recommended
   - When to use: Most JavaScript projects
   - Considerations: Some teams have strong preferences

2. **Biome** - Fast, all-in-one formatter and linter
   - When to use: New projects wanting simplicity
   - Considerations: Less ecosystem support

[Include examples, trade-offs, and integration guides]
```

This empowers Claude to make appropriate choices based on actual project context.

## Learning from Debugging

This repository embodies a key principle: **Every debugging session is a learning opportunity**.

### Our Process

1. **Experience Problems** - We hit real issues in real projects
2. **Solve Through Debugging** - Sometimes taking hours to find solutions
3. **Document Everything** - Including what didn't work and why
4. **Share the Knowledge** - So you can avoid our pain

### Real Examples

- **Astro Documentation Build** (Issue #15)
  - 3.5 hours debugging missing pages
  - Root cause: `astro sync` requirement not documented
  - Solution documented in [Documentation Site Setup](docs/documentation-site-setup.md)
  
- **Cross-Platform CI Failures**
  - Multiple hours debugging package-lock.json issues
  - Platform-specific behaviors on macOS vs Linux
  - Solutions in [GitHub Actions Guide](docs/github-actions-multi-platform.md)

- **Test Framework Development**
  - Iterative refinement over many projects
  - Patterns for handling CI limitations
  - Complete framework in [Testing Guide](docs/testing-framework-guide.md)

### The Value Proposition

**Without claude-init**: Spend hours debugging common problems
**With claude-init**: Find solutions in minutes

Every guide represents hours of debugging condensed into minutes of reading.