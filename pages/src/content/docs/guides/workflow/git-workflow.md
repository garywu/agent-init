---
title: Git Workflow Patterns
description: Git Workflow Patterns - Comprehensive guide from agent-init
sidebar:
  order: 10
---

# Git Workflow Patterns

Comprehensive patterns for Git configuration, hooks, and workflow automation that enhance development productivity and code quality.

## Advanced Git Configuration

### 1. Conditional Includes

Manage different identities and configurations based on directory:

```gitconfig
# ~/.gitconfig
[user]
    name = Default Name
    email = default@example.com

[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal

[includeIf "gitdir:~/opensource/"]
    path = ~/.gitconfig-oss

# ~/.gitconfig-work
[user]
    name = Work Name
    email = work@company.com
    signingkey = WORK_GPG_KEY

[commit]
    gpgsign = true

[url "git@github-work:"]
    insteadOf = git@github.com:
```

### 2. Useful Git Aliases

```gitconfig
[alias]
    # Status and information
    st = status -sb
    ll = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat
    last = log -1 HEAD --stat

    # Branch management
    br = branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative))'
    brd = branch -d
    brc = checkout -b

    # Staging helpers
    unstage = reset HEAD --
    staged = diff --cached

    # Commit helpers
    amend = commit --amend --no-edit
    fixup = commit --fixup

    # History rewriting
    rewrite = rebase -i
    squash-all = "!f(){ git reset $(git commit-tree HEAD^{tree} -m \"${1:-Initial commit}\");};f"

    # Workflow helpers
    wip = !git add -A && git commit -m "WIP: $(date +%Y-%m-%d_%H:%M:%S)"
    unwip = reset HEAD~1

    # Maintenance
    cleanup = !git branch --merged | grep -v '\*\|main\|master\|develop' | xargs -n 1 git branch -d
    prune-branches = !git remote prune origin && git cleanup
```

### 3. Git Hooks Architecture

```bash
#!/usr/bin/env bash
# .git-hooks/hook-runner.sh
# Central hook runner for all git hooks

HOOK_NAME=$(basename "$0")
HOOKS_DIR=".git-hooks"

# Run all scripts for this hook type
for script in "$HOOKS_DIR/$HOOK_NAME.d"/*; do
    if [[ -x "$script" ]]; then
        echo "Running $(basename "$script")..."
        if ! "$script" "$@"; then
            echo "Hook $(basename "$script") failed"
            exit 1
        fi
    fi
done
```

## Pre-commit Hooks

### 1. Code Quality Checks

```bash
#!/usr/bin/env bash
# .git-hooks/pre-commit.d/01-code-quality.sh

# Prevent commits to protected branches
PROTECTED_BRANCHES=("main" "master" "production")
CURRENT_BRANCH=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

for branch in "${PROTECTED_BRANCHES[@]}"; do
    if [[ "$CURRENT_BRANCH" == "$branch" ]]; then
        echo "❌ Direct commits to $branch branch are not allowed"
        echo "💡 Create a feature branch instead"
        exit 1
    fi
done

# Check for debugging code
DEBUG_PATTERNS=(
    "console.log"
    "debugger;"
    "import pdb; pdb.set_trace()"
    "binding.pry"
    "TODO:"
    "FIXME:"
    "HACK:"
)

for pattern in "${DEBUG_PATTERNS[@]}"; do
    if git diff --cached --name-only | xargs grep -l "$pattern" 2>/dev/null; then
        echo "⚠️  Found '$pattern' in staged files"
        echo "Remove debugging code before committing"
        exit 1
    fi
done
```

### 2. File Size Limits

```bash
#!/usr/bin/env bash
# .git-hooks/pre-commit.d/02-file-size.sh

MAX_FILE_SIZE=10485760  # 10MB
LFS_THRESHOLD=1048576   # 1MB

# Check for large files
while IFS= read -r file; do
    if [[ -f "$file" ]]; then
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)

        if [[ $size -gt $MAX_FILE_SIZE ]]; then
            echo "❌ File $file is too large ($(numfmt --to=iec-i --suffix=B $size))"
            exit 1
        elif [[ $size -gt $LFS_THRESHOLD ]]; then
            echo "⚠️  File $file is large ($(numfmt --to=iec-i --suffix=B $size))"
            echo "💡 Consider using Git LFS for this file"
        fi
    fi
done < <(git diff --cached --name-only --diff-filter=ACM)
```

### 3. Commit Message Validation

```bash
#!/usr/bin/env bash
# .git-hooks/commit-msg.d/01-conventional-commits.sh

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Conventional Commits regex
CONVENTIONAL_REGEX='^(feat|fix|docs|style|refactor|perf|test|chore|ci|build)(\(.+\))?!?: .{1,100}'

if ! echo "$COMMIT_MSG" | grep -qE "$CONVENTIONAL_REGEX"; then
    echo "❌ Commit message does not follow Conventional Commits format"
    echo ""
    echo "Format: <type>(<scope>): <subject>"
    echo ""
    echo "Types:"
    echo "  feat:     New feature"
    echo "  fix:      Bug fix"
    echo "  docs:     Documentation changes"
    echo "  style:    Code style changes (formatting, etc)"
    echo "  refactor: Code refactoring"
    echo "  perf:     Performance improvements"
    echo "  test:     Test additions or corrections"
    echo "  chore:    Maintenance tasks"
    echo "  ci:       CI/CD changes"
    echo "  build:    Build system changes"
    echo ""
    echo "Example: feat(auth): add OAuth2 authentication"
    exit 1
fi

# Check message length
SUBJECT_LINE=$(echo "$COMMIT_MSG" | head -n1)
if [[ ${#SUBJECT_LINE} -gt 100 ]]; then
    echo "⚠️  Commit subject line is too long (${#SUBJECT_LINE} chars, max 100)"
fi
```

## Git Workflow Automation

### 1. Branch Naming Enforcement

```bash
#!/usr/bin/env bash
# .git-hooks/pre-push.d/01-branch-naming.sh

# Enforce branch naming convention
VALID_BRANCH_REGEX='^(feature|bugfix|hotfix|release|chore)\/.+$'
BRANCH=$(git rev-parse --abbrev-ref HEAD)

if ! echo "$BRANCH" | grep -qE "$VALID_BRANCH_REGEX"; then
    echo "❌ Branch name '$BRANCH' does not follow naming convention"
    echo "💡 Use format: <type>/<description>"
    echo "   Examples:"
    echo "     feature/add-user-auth"
    echo "     bugfix/fix-login-error"
    echo "     hotfix/security-patch"
    exit 1
fi
```

### 2. Automated PR Creation

```bash
#!/usr/bin/env bash
# scripts/create-pr.sh

create_pr() {
    local title="$1"
    local draft="${2:-false}"

    # Get current branch
    local branch=$(git rev-parse --abbrev-ref HEAD)

    # Extract type and description from branch name
    local type=$(echo "$branch" | cut -d'/' -f1)
    local description=$(echo "$branch" | cut -d'/' -f2- | tr '-' ' ')

    # Generate PR body from commits
    local body=$(cat << EOF
## Summary

$description

## Changes

$(git log origin/main..HEAD --pretty=format:"- %s" --reverse)

## Type of change

- [x] $type

## Checklist

- [ ] Tests pass locally
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
EOF
)

    # Create PR
    if [[ "$draft" == "true" ]]; then
        gh pr create --draft --title "$title" --body "$body"
    else
        gh pr create --title "$title" --body "$body"
    fi
}

# Interactive PR creation
interactive_pr() {
    echo "Creating PR for branch: $(git rev-parse --abbrev-ref HEAD)"

    # Use gum for nice UI if available
    if command -v gum &> /dev/null; then
        title=$(gum input --placeholder "PR Title")
        draft=$(gum confirm "Create as draft?" && echo "true" || echo "false")
    else
        read -p "PR Title: " title
        read -p "Create as draft? (y/N): " draft_response
        draft=$([[ "$draft_response" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    fi

    create_pr "$title" "$draft"
}
```

### 3. Git Worktree Management

```bash
#!/usr/bin/env bash
# scripts/worktree-manager.sh

# Create worktree for feature
worktree_create() {
    local branch="$1"
    local worktree_dir="../worktrees/${branch//\//-}"

    # Create worktree
    git worktree add "$worktree_dir" -b "$branch"

    # Copy necessary files
    cp .env.example "$worktree_dir/.env" 2>/dev/null || true

    # Setup in worktree
    (
        cd "$worktree_dir"
        npm install 2>/dev/null || true
        echo "✅ Worktree ready at: $worktree_dir"
    )
}

# List worktrees with status
worktree_status() {
    git worktree list | while read -r line; do
        local path=$(echo "$line" | awk '{print $1}')
        local branch=$(echo "$line" | awk '{print $3}')

        if [[ -d "$path" ]]; then
            local status=$(cd "$path" && git status --porcelain | wc -l)
            echo "$branch: $status uncommitted changes"
        fi
    done
}

# Cleanup finished worktrees
worktree_cleanup() {
    git worktree list | while read -r line; do
        local path=$(echo "$line" | awk '{print $1}')
        local branch=$(echo "$line" | awk '{print $3}')

        # Check if branch is merged
        if git branch --merged | grep -q "$branch"; then
            echo "Removing merged worktree: $branch"
            git worktree remove "$path"
        fi
    done
}
```

## Advanced Git Patterns

### 1. Semantic Release Automation

```javascript
// .releaserc.js
module.exports = {
  branches: ['main', 'next', {name: 'beta', prerelease: true}],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    [
      '@semantic-release/changelog',
      {
        changelogFile: 'CHANGELOG.md',
      },
    ],
    '@semantic-release/npm',
    [
      '@semantic-release/git',
      {
        assets: ['CHANGELOG.md', 'package.json', 'package-lock.json'],
        message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}',
      },
    ],
    '@semantic-release/github',
  ],
};
```

### 2. Git Bisect Automation

```bash
#!/usr/bin/env bash
# scripts/bisect-helper.sh

# Automated bisect for test failures
bisect_test_failure() {
    local test_command="$1"
    local good_commit="$2"
    local bad_commit="${3:-HEAD}"

    # Start bisect
    git bisect start "$bad_commit" "$good_commit"

    # Run automated bisect
    git bisect run bash -c "
        # Build project
        npm install --silent || exit 125
        npm run build --silent || exit 125

        # Run test
        if $test_command; then
            exit 0  # Good
        else
            exit 1  # Bad
        fi
    "

    # Show result
    echo "First bad commit:"
    git bisect view --oneline

    # Cleanup
    git bisect reset
}
```

### 3. Git Subtree Management

```bash
#!/usr/bin/env bash
# scripts/subtree-sync.sh

# Sync shared code via subtrees
subtree_pull() {
    local prefix="$1"
    local repo="$2"
    local branch="${3:-main}"

    git subtree pull --prefix="$prefix" "$repo" "$branch" --squash
}

subtree_push() {
    local prefix="$1"
    local repo="$2"
    local branch="${3:-main}"

    git subtree push --prefix="$prefix" "$repo" "$branch"
}

# Update all subtrees
update_all_subtrees() {
    # Define subtrees in .gittrees
    while IFS='|' read -r prefix repo branch; do
        echo "Updating $prefix from $repo..."
        subtree_pull "$prefix" "$repo" "$branch"
    done < .gittrees
}
```

## Git Security Patterns

### 1. Signed Commits

```bash
# Setup GPG signing
setup_gpg_signing() {
    # Generate GPG key
    gpg --full-generate-key

    # List keys
    gpg --list-secret-keys --keyid-format=long

    # Configure git
    git config --global user.signingkey YOUR_KEY_ID
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true
}

# Setup SSH signing (Git 2.34+)
setup_ssh_signing() {
    # Configure git to use SSH for signing
    git config --global gpg.format ssh
    git config --global user.signingkey ~/.ssh/id_ed25519.pub

    # Create allowed signers file
    echo "$(git config user.email) $(cat ~/.ssh/id_ed25519.pub)" >> ~/.config/git/allowed_signers
    git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
}
```

### 2. Security Scanning

```bash
#!/usr/bin/env bash
# .git-hooks/pre-commit.d/03-security-scan.sh

# Scan for secrets
if command -v gitleaks &> /dev/null; then
    gitleaks detect --source . --verbose
fi

# Scan dependencies
if [[ -f package.json ]] && command -v npm &> /dev/null; then
    npm audit --production
fi

if [[ -f Gemfile ]] && command -v bundle &> /dev/null; then
    bundle audit check
fi
```

## Best Practices

1. **Hook Installation**
   ```bash
   # Install hooks on clone
   git config core.hooksPath .git-hooks
   ```

2. **Team Consistency**
   - Share git configuration templates
   - Use .gitmessage for commit templates
   - Document workflow in CONTRIBUTING.md

3. **Performance**
   - Use git maintenance for large repos
   - Configure git gc settings
   - Enable commit-graph and pack bitmaps

## External References

- [Pro Git Book](https://git-scm.com/book)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Hooks Documentation](https://git-scm.com/docs/githooks)
- [GitHub Flow](https://guides.github.com/introduction/flow/)