# PROJECT-MANAGEMENT.md - AI Assistant Project Management Template

This file should be placed in the root of your project to guide AI assistants in following best practices for project management, issue tracking, and development workflow.

## Project Management Workflow

### 0. Project Setup - Permanent Management Issues

For every new project, create these 9 permanent management issues that should **NEVER be closed**:

1. **📋 Project Roadmap & Planning** - Central planning and milestone tracking
2. **🔗 Issue Cross-Reference Index** - Master list of all issue relationships
3. **📚 Research & Discovery Log** - Document all findings and investigations
4. **🏗️ Architecture Decisions** - Track design choices and rationale
5. **🐛 Known Issues & Workarounds** - Catalog of ongoing challenges
6. **📖 Documentation Tasks** - Track what needs documenting
7. **🔧 Technical Debt Registry** - List of improvements needed
8. **💡 Ideas & Future Features** - Backlog of enhancements
9. **📊 Project Health & Metrics** - Performance and quality tracking

### 1. System Health Check

- **Start sessions with validation** - Run any project validation scripts
- **Fix any issues** before starting work
- **Check after major changes** to ensure system stays clean

### 2. Issue Management Best Practices

#### Creating Issues
- **Be specific and targeted** - One clear goal per issue
- **Use templates** - Bug, Feature, Documentation, Refactor
- **Add labels** - Priority, type, component affected
- **Link related issues** - Use "Related to #X", "Blocks #Y", "Blocked by #Z"
- **Assign milestones** - Group related work

#### Interlinking Issues
- **Reference parent issues**: "Part of #X"
- **Link dependencies**: "Requires #Y to be completed first"
- **Cross-reference**: "See also #Z for related discussion"
- **Use task lists** in parent issues:
  ```markdown
  - [ ] Sub-task 1 (#101)
  - [ ] Sub-task 2 (#102)
  - [ ] Sub-task 3 (#103)
  ```

#### Continuous Documentation
- **Comment when starting work**: "Beginning investigation of X"
- **Document findings immediately**:
  ```markdown
  Discovered that the issue is caused by:
  - Finding 1: [details]
  - Finding 2: [details]
  - Potential solution: [approach]
  ```
- **Update status regularly**: "Progress update: Completed X, working on Y"
- **Link to commits**: "Implemented in abc123"
- **Document blockers**: "Blocked by #X - waiting for resolution"

### 3. Atomic Commit Practices

#### Making Atomic Commits
- **One logical change per commit** - If you need "and" in your description, split it
- **Commit frequently** - Don't accumulate large changes
- **Complete but minimal** - Each commit should work independently
- **Test before committing** - Ensure each commit doesn't break the build

#### Commit Workflow
```bash
# After each logical change:
1. git add -p  # Stage specific changes interactively
2. git diff --staged  # Review what you're committing
3. git commit  # Write descriptive message

# Don't wait to accumulate changes!
```

#### Examples of Atomic Commits
```bash
# ✅ GOOD - Atomic commits
feat(validation): add check_nix_daemon function (#71)
feat(validation): add Nix daemon status to environment check (#71)
docs: add Nix daemon explanation to troubleshooting (#71)
fix(validation): remove set -e for better error handling (#71)

# ❌ BAD - Too many changes in one commit
feat: add validation and fix errors and update docs (#71)
```

### 4. Implementation Phase

- **Reference the issue** being worked on
- **Make atomic commits** after each logical change
- **Comment on progress** in the issue after each commit
- **Document problems** as you encounter them
- **Create new issues** for discovered problems
- **Run tests/linters** before committing
- **Test each commit** independently

## Committing Changes with Git

When creating commits, follow these practices for professional development:

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description (#issue-number)

[optional body]

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

#### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests
- `chore`: Maintain tasks, dependency updates

### Pre-Commit Hook Management

**IMPORTANT**: Always fix issues before committing to avoid frustration!

```bash
# Before EVERY commit, run:
make pre-commit-fix

# Or use smart commit:
git smart-commit "feat: add new feature (#123)"
```

### Commit Process

1. **Fix pre-commit issues first**:
   ```bash
   make pre-commit-fix
   ```

2. **Stage changes selectively**:
   ```bash
   git add -p  # Interactive staging
   # OR
   git add specific-file.sh  # Stage specific files
   ```

2. **Review staged changes**:
   ```bash
   git diff --staged
   ```

3. **Create atomic commit**:
   ```bash
   git commit -m "feat(tools): add act for local GitHub Actions testing (#64)

   - Added act to nix/home.nix for running GH Actions locally
   - Enables testing workflows without pushing to GitHub
   - Version 0.2.78 from nixpkgs

   🤖 Generated with [Claude Code](https://claude.ai/code)

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

4. **Update issue immediately**:
   ```bash
   gh issue comment 64 --body "Implemented in commit abc123:
   - Added act to nix/home.nix
   - Tool allows local GitHub Actions testing
   - Next: Update documentation"
   ```

### Multi-Commit Workflow Example

```bash
# Working on issue #64: Add container tools

# First atomic commit
git add nix/home.nix
git commit -m "feat(nix): add act for GitHub Actions local testing (#64)"
gh issue comment 64 --body "Added act to home.nix in commit abc123"

# Second atomic commit
git add nix/home.nix
git commit -m "feat(nix): add dive for Docker image analysis (#64)"
gh issue comment 64 --body "Added dive to home.nix in commit def456"

# Third atomic commit
git add nix/home.nix
git commit -m "feat(nix): add k9s for Kubernetes management (#64)"
gh issue comment 64 --body "Added k9s to home.nix in commit ghi789"

# Documentation commit
git add CLAUDE.md
git commit -m "docs: add usage examples for container tools (#64)"
gh issue comment 64 --body "Documented all three tools in commit jkl012"

# Validation commit
git add scripts/validation/validate-dev-tools.sh
git commit -m "feat(validation): add container tools validation (#64)"
gh issue comment 64 --body "Added validation in commit mno345. All tasks complete!"
```

## GitHub CLI Commands

Essential commands for issue management:

```bash
# List issues
gh issue list

# Create issue
gh issue create --title "Title" --body "Description" --label "label1,label2"

# Comment on issue
gh issue comment <number> --body "Comment"

# View issue
gh issue view <number>

# Close issue (only when truly complete!)
gh issue close <number>

# Create issue with template
gh issue create --template bug_report.md

# Link issues in comments
gh issue comment 101 --body "This issue is blocked by #99 and relates to #102"
```

## Project-Specific Instructions

Add your project-specific instructions below this line:

---

[Your project-specific workflow, commands, and guidelines go here]