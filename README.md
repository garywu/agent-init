# Claude Init - Professional Repository Setup

This repository provides templates and instructions for Claude to initialize professional development standards in any repository.

## Purpose

When you ask Claude to set up professional development practices, Claude will use these templates to establish:

1. **Issue-driven development workflow** - All work tracked through GitHub issues
2. **Professional standards** - Linting, testing, CI/CD, security policies
3. **AI-assisted development** - CLAUDE.md for session continuity
4. **Comprehensive documentation** - Contributing guidelines, code of conduct
5. **Automation** - Pre-commit hooks, GitHub Actions, semantic versioning

## Instructions for Claude

### When encountering an EMPTY DIRECTORY:

1. First, check if it should be a git repository
2. Copy all templates from this repository
3. Initialize git and create initial commit
4. Set up pre-commit hooks
5. Customize README.md for the specific project
6. Create CLAUDE.md to track the session

### When encountering an EMPTY REPOSITORY (already has .git):

1. Check for any existing files (README, LICENSE, .gitignore)
2. Copy templates but don't overwrite existing files
3. Set up GitHub-specific features (labels, issue templates)
4. Install pre-commit hooks
5. Create initial commit with professional structure
6. Create CLAUDE.md to track ongoing work

### When encountering an EXISTING REPOSITORY:

1. Analyze current structure and tooling
2. Create CLAUDE.md first to document findings
3. Selectively add missing professional elements:
   - Add .github/ templates if missing
   - Add pre-commit configuration if missing
   - Add Makefile if it would be helpful
   - Add CONTRIBUTING.md and SECURITY.md if missing
4. Create issues for any problems found
5. Don't overwrite existing configurations without asking

## Available Templates

```
templates/
├── .github/
│   ├── ISSUE_TEMPLATE/        # Bug report, feature request, etc.
│   ├── workflows/ci.yml       # GitHub Actions CI/CD
│   └── pull_request_template.md
├── CLAUDE.md                  # AI session tracking
├── CONTRIBUTING.md            # Contribution guidelines  
├── SECURITY.md               # Security policy
├── Makefile                  # Common development tasks
├── .pre-commit-config.yaml   # Code quality hooks
├── .editorconfig            # Editor configuration
├── .gitignore               # Comprehensive ignore patterns
├── .yamllint                # YAML linting rules
├── .releaserc.json          # Semantic release config
└── README.md                # Project template
```

## Available CLI Tools

These tools are pre-installed on the system:

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