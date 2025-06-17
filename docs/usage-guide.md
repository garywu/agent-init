# Claude Init Usage Guide

This guide explains how to use Claude Init templates to set up professional development standards in any repository.

## For Users

When you want Claude to set up professional development practices in your repository, simply tell Claude:

> "Initialize this repository with professional development standards using claude-init"

Or more specifically:

> "Set up GitHub issue templates, pre-commit hooks, and CI/CD using claude-init templates"

## For Claude

### Decision Tree

```
Is the directory empty?
├─ Yes → Copy all templates, initialize git, create initial commit
└─ No → Does .git exist?
    ├─ No → Ask if it should be a git repo, then proceed accordingly
    └─ Yes → Is it a new repo (no commits)?
        ├─ Yes → Copy templates, respect existing files, create initial commit
        └─ No → Analyze existing structure, add missing elements
```

### Step-by-Step Process

#### 1. Initial Assessment

First, check the current state:

```bash
# Check if git repo exists
ls -la .git 2>/dev/null || echo "Not a git repository"

# Check for existing files
ls -la

# If it's a git repo, check status
git status 2>/dev/null || true
```

#### 2. Create CLAUDE.md First

Always create CLAUDE.md to document your findings and plan:

```bash
# Copy CLAUDE.md template and customize with current date and goals
```

#### 3. For Empty Directory

```bash
# Copy all templates
# Initialize git
git init

# Create comprehensive .gitignore
# Add all files
git add .

# Create initial commit
git commit -m "chore: initialize repository with professional standards"
```

#### 4. For Existing Repository

Analyze what's already there:

```bash
# Check for existing professional elements
ls .github/ISSUE_TEMPLATE 2>/dev/null || echo "No issue templates"
ls .pre-commit-config.yaml 2>/dev/null || echo "No pre-commit config"
ls CONTRIBUTING.md 2>/dev/null || echo "No contributing guide"
```

Then selectively add missing elements:

```bash
# Only copy files that don't exist
# Create issues for any problems found
gh issue create --title "[SETUP] Add missing development standards"
```

#### 5. Set Up GitHub Features

If the repository has a remote:

```bash
# Create standard labels
gh label create "bug" --color "d73a4a" --description "Something isn't working"
gh label create "enhancement" --color "a2eeef" --description "New feature or request"
# ... etc

# Set up branch protection (if permissions allow)
gh api repos/:owner/:repo/branches/main/protection --method PUT ...
```

#### 6. Install and Test

```bash
# Install pre-commit hooks
pre-commit install
pre-commit install --hook-type commit-msg

# Run initial tests
pre-commit run --all-files

# Show user the available commands
make help
```

### Common Scenarios

#### Scenario 1: Brand New Project

User says: "I just created a new directory for my Python project"

Claude should:
1. Copy all templates
2. Customize for Python (update Makefile, .gitignore)
3. Create virtual environment setup in README
4. Add Python-specific linting to pre-commit

#### Scenario 2: Existing Project Without Standards

User says: "My repository needs better development practices"

Claude should:
1. Analyze current structure
2. Create CLAUDE.md with findings
3. Create issues for each improvement
4. Gradually add missing pieces
5. Don't break existing workflows

#### Scenario 3: Empty GitHub Repository

User says: "I just created a new repo on GitHub and cloned it"

Claude should:
1. Check for README, LICENSE, .gitignore from GitHub
2. Add all professional templates
3. Set up GitHub-specific features
4. Push the initial setup

### Important Notes

1. **Always preserve existing work** - Never overwrite without asking
2. **Document everything in CLAUDE.md** - Track what you did and why
3. **Create issues for problems** - Don't just fix, track the work
4. **Explain what you're doing** - Users should understand the setup
5. **Test before committing** - Run linters to ensure quality

### Customization by Language

After copying templates, customize based on the project type:

**Python**:
- Ensure `black`, `isort`, `flake8`, `mypy` in pre-commit
- Add `requirements.txt` handling to Makefile
- Include Python-specific .gitignore entries

**JavaScript/TypeScript**:
- Add `eslint`, `prettier` to pre-commit
- Update Makefile for npm/yarn commands
- Include node_modules in .gitignore

**Go**:
- Add `gofmt`, `golangci-lint` to pre-commit
- Update Makefile for go commands
- Include Go-specific .gitignore entries

**Rust**:
- Add `rustfmt`, `clippy` to pre-commit
- Update Makefile for cargo commands
- Include target/ in .gitignore