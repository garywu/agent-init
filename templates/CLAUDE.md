# Claude AI Session Tracking - Enhanced

This file tracks AI-assisted development sessions and provides intelligent project analysis for enhanced development assistance.

## 🧠 Self-Reflection and Error Prevention Protocol

### Before Starting Any Task

1. **Review Recent History**
   - Re-read the last 10-20 messages in the conversation
   - Identify any patterns of errors or corrections
   - Note specific instructions that were given and may have been forgotten

2. **Check for Common Self-Induced Errors**
   - **Path errors**: Verify file paths before using them
   - **Assumption errors**: Don't assume file contents or structure - always check
   - **Instruction drift**: Re-read the original request to ensure staying on track
   - **Context loss**: Review what was already tried to avoid repeating failures

3. **Memory Checkpoint Questions**
   - What was the user's original request?
   - What specific constraints or preferences were mentioned?
   - Have I made this type of error before in this session?
   - Am I following the established patterns in this codebase?

4. **Error Pattern Recognition**
   Common self-induced errors to watch for:
   - Forgetting to read a file before writing to it
   - Using wrong file paths or assuming directory structures
   - Ignoring user corrections and repeating the same mistake
   - Missing important context from earlier in the conversation
   - Making changes that contradict established patterns

5. **Verification Before Action**
   - Double-check file paths exist with `ls` or `find`
   - Verify assumptions about file contents with `Read` tool
   - Confirm understanding of requirements before implementing
   - Test commands in a safe way before executing destructive operations

### During Task Execution

- **Pause and reflect** when errors occur - don't just retry blindly
- **Read error messages carefully** - they often contain the solution
- **Check conversation history** when confused about requirements
- **Acknowledge patterns** - if making similar errors, adjust approach

### After Completing Tasks

- **Review what was done** against original requirements
- **Note any errors made** for future reference
- **Update relevant documentation** if patterns were discovered

## 🔍 Project Intelligence

**Last Analysis**: [Auto-generated timestamp]  
**Analysis Confidence**: [Auto-detected: low/medium/high]  
**Project Type**: [Auto-detected: web-app/api/library/cli/mobile/documentation/unknown]  
**Primary Language**: [Auto-detected programming language]  
**Frameworks**: [Auto-detected frameworks and libraries]  

### Quick Project Overview
- **Maturity Score**: [0-100, auto-calculated]
- **Total Files**: [Auto-counted]
- **Source Files**: [Auto-counted programming files]
- **Git Repository**: [Yes/No]
- **Health Status**: [Healthy/Warning/Critical]

### Smart Recommendations
Based on project analysis, Claude suggests:
- [Auto-generated recommendation 1]
- [Auto-generated recommendation 2]
- [Auto-generated recommendation 3]

## Current Session Information

- **Date**: [YYYY-MM-DD]
- **Session ID**: [Generated Session ID]
- **Session Type**: [Development/Debugging/Planning/Review]
- **Primary Goals**: 
  - [ ] Goal 1
  - [ ] Goal 2

### Session Context
- **Previous Session**: [Link to previous session if available]
- **Continuation From**: [Previous work context]
- **Focus Areas**: [Specific areas to concentrate on]

## 🛠️ Intelligent Commands

### Project Analysis & Intelligence
```bash
# Run project analysis
./scripts/project-detector.sh          # Analyze project characteristics
./scripts/setup-analyzer.sh           # Comprehensive setup analysis
make analyze                          # Quick project health check
make health                           # Full health assessment
```

### Smart Development Commands
```bash
# Context-aware development (adapts to project type)
make dev                # Start development server (auto-detected)
make test               # Run tests (framework-specific)
make build              # Build project (optimized for project type)
make lint               # Run linters (language-specific)
make format             # Format code (language-specific)

# Intelligent project management
make session-start      # Start tracked development session
make session-status     # Show current session status
make session-end        # End session with summary
make session-log MSG="description"  # Log session activity
```

### Git Workflow (Enhanced)
```bash
# Issue-driven development
gh issue list           # View all issues
gh issue create         # Create new issue with templates
gh pr create            # Create pull request with analysis

# Smart git operations
make git-status         # Multi-repo status (if applicable)
make git-cleanup        # Clean up branches and optimize
git tag -l              # List all versions
```

### Framework-Specific Commands
Based on your project type, additional commands are available:

#### For Web Applications
```bash
make dev-web            # Start web development server
make build-web          # Build for production
make preview            # Preview production build
make lighthouse         # Run Lighthouse performance audit
```

#### For APIs
```bash
make dev-api            # Start API development server
make test-api           # Run API integration tests
make docs-api           # Generate API documentation
make db-migrate         # Run database migrations
```

#### For Libraries
```bash
make build-lib          # Build library for distribution
make publish            # Publish to package registry
make docs-lib           # Generate library documentation
```

## 🔄 Enhanced Workflow Procedure

### 1. Session Initialization
- **Start with analysis** - Run `make analyze` to understand current project state
- **Review project intelligence** - Check the Project Intelligence section above
- **Initialize session** - Use `make session-start` for tracked development
- **Set clear goals** - Define specific, measurable session objectives

### 2. Intelligent Planning Phase
- **Leverage project analysis** - Use detected project type for context-appropriate planning
- **Create GitHub issues** for all planned work with project-specific templates
- **Add analysis context** to issues (reference project type, frameworks, maturity score)
- **Get framework-specific guidance** from detected technologies
- **Wait for approval** before proceeding with implementation

### 3. Smart Issue Creation
- Use descriptive titles with appropriate prefixes and project context:
  - `[BUG]` for bug fixes (include affected framework/component)
  - `[FEAT]` for new features (specify if frontend/backend/fullstack)
  - `[DOCS]` for documentation (specify if API/user/developer docs)
  - `[REFACTOR]` for code refactoring (mention performance/maintainability)
  - `[TEST]` for test additions/modifications (unit/integration/e2e)
  - `[CHORE]` for maintenance tasks (dependency updates/tooling)
  - `[SECURITY]` for security-related changes
  - `[PERF]` for performance improvements

### 4. Context-Aware Development Process
1. **Select an issue** from the backlog with project type in mind
2. **Review project analysis** for relevant context and constraints
3. **Plan implementation** using framework-specific best practices
4. **Get approval** on approach with architectural considerations
5. **Implement solution** following detected project patterns
6. **Run health checks** - Use `make health` to verify changes
7. **Update session log** - Use `make session-log MSG="progress update"`
8. **Create PR** with analysis context and framework-specific testing

### 4. Context-Aware Development Process
1. **Select an issue** from the backlog with project type in mind
2. **Review project analysis** for relevant context and constraints
3. **Plan implementation** using framework-specific best practices
4. **Document approach** in issue before coding:
   ```markdown
   ## Implementation Plan
   Approaching this by:
   1. First, I'll...
   2. Then, I'll...
   3. Finally, I'll...
   
   Estimated commits: 4-5 atomic changes
   ```
5. **Get approval** on approach with architectural considerations
6. **Implement solution** with atomic commits
7. **Update issue** after each commit
8. **Run health checks** - Use `make health` to verify changes
9. **Create PR** with full context

### 5. Pull Request Excellence

#### PR Description Template
```markdown
## Summary
Brief description of changes

## Related Issues
Closes #X
Part of #Y
Related to #Z

## Changes Made
- [ ] Change 1 (commit abc123)
- [ ] Change 2 (commit def456)
- [ ] Change 3 (commit ghi789)

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots/Demo
[If applicable]

## Breaking Changes
[List any breaking changes]
```

#### PR Best Practices
- **One PR per issue** (with rare exceptions)
- **Keep PRs small** - Easier to review
- **Update issue** when PR is created
- **Link all related issues**
- **Request specific reviewers**
- **Respond to feedback quickly**

### 6. GitHub CLI Mastery

```bash
# Issue Management
gh issue create --title "Add validation" --body "Need to validate..." --label "enhancement,validation"
gh issue list --label "bug" --state open
gh issue view 45 --comments  # See all discussion
gh issue develop 45 --checkout  # Create branch for issue

# Advanced Issue Linking
gh issue comment 45 --body "This is blocked by #30 and relates to our discussion in #12"
gh issue edit 45 --add-label "blocked"
gh issue pin 45  # Pin important issues

# PR Management  
gh pr create --fill --assignee @me
gh pr checks  # Watch CI status
gh pr review --approve
gh pr merge --squash --delete-branch

# Cross-Repository References
gh issue comment 45 --body "See similar implementation in org/other-repo#123"
```

### 7. Release Management

#### Manual Release Strategy (Recommended)
For full control over versioning, use manual-only releases:
- Start at `v0.0.1` and increment deliberately
- No automated version bumps or scheduled releases
- Create releases only when significant changes are ready
- See [Release Management Guide](https://github.com/garywu/claude-init/blob/main/docs/release-management-manual.md)

#### Automated Release Strategy (Alternative)
For projects preferring automation:
- **main**: Active development
- **beta**: Beta releases (manual trigger)
- **stable**: Stable releases (manual trigger)

#### Conventional Commits
Use these prefixes for semantic versioning:
- `feat:` New feature (minor version bump)
- `fix:` Bug fix (patch version bump)
- `feat!:` or `BREAKING CHANGE:` (major version bump)
- `docs:`, `style:`, `refactor:`, `test:`, `chore:` (no release)

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
- **Release Channels**: main (dev), beta (weekly), stable (monthly)

## 📊 Project Health & Intelligence Tracking

### Health Indicators
- **Last Health Check**: [Timestamp]
- **Overall Health Score**: [0-100]
- **Critical Issues**: [Count of critical issues]
- **Security Status**: [Secure/Warning/Critical]
- **Performance Status**: [Optimal/Warning/Needs Attention]
- **Documentation Coverage**: [Complete/Partial/Missing]

### Intelligence Updates
- **Project Type Changes**: [Track evolution]
- **Framework Additions**: [New technologies adopted]
- **Complexity Growth**: [Monitor codebase growth]
- **Dependency Health**: [Track security and updates]

## 📋 Project Management Best Practices

### Permanent Management Issues

For every project, create these 9 permanent management issues that **NEVER get closed**:

1. **📋 Project Roadmap & Planning** (#1) - Central planning and milestone tracking
2. **🔗 Issue Cross-Reference Index** (#2) - Master list of all issue relationships  
3. **📚 Research & Discovery Log** (#3) - Document all findings and investigations
4. **🏗️ Architecture Decisions** (#4) - Track design choices and rationale
5. **🐛 Known Issues & Workarounds** (#5) - Catalog of ongoing challenges
6. **📖 Documentation Tasks** (#6) - Track what needs documenting
7. **🔧 Technical Debt Registry** (#7) - List of improvements needed
8. **💡 Ideas & Future Features** (#8) - Backlog of enhancements
9. **📊 Project Health & Metrics** (#9) - Performance and quality tracking

### Issue Management Excellence

#### Creating Targeted Issues
- **One clear goal per issue** - Split complex tasks
- **Use issue templates** - Consistency matters
- **Add multiple labels** - Type, priority, component, status
- **Set milestones** - Group related work
- **Assign to project boards** - Visual tracking

#### Interlinking Issues (Critical!)
- **Always link related issues** - Creates knowledge graph
- **Use GitHub keywords**:
  - "Closes #X" - Auto-closes when PR merges
  - "Fixes #X" - Same as closes
  - "Resolves #X" - Same as closes
  - "Related to #X" - Creates reference
  - "Part of #X" - Shows hierarchy
  - "Blocks #X" - Shows dependency
  - "Blocked by #X" - Shows dependency
- **Create task lists** in parent issues:
  ```markdown
  ## Subtasks
  - [ ] Implement validation (#101)
  - [ ] Add tests (#102) 
  - [ ] Update documentation (#103)
  ```

#### Continuous Issue Documentation
- **Comment when starting**: "Starting work on this issue"
- **Document discoveries immediately**:
  ```markdown
  ## Investigation Results
  Found that the issue is caused by:
  1. **Root cause**: [detailed explanation]
  2. **Impact**: [what this affects]
  3. **Proposed solution**: [approach with tradeoffs]
  
  Related findings documented in #3 (Research Log)
  ```
- **Update progress regularly**: 
  ```markdown
  Progress update:
  - ✅ Completed initial analysis
  - ✅ Implemented core functionality 
  - 🔄 Working on tests
  - ⏳ Documentation pending
  ```
- **Link every commit**: "Implemented validation in abc123def"
- **Document blockers**: "Blocked by #45 - waiting for API changes"

### Atomic Commit Excellence

#### The Atomic Commit Mindset
- **Think in smallest complete changes**
- **If you type "and" in description, split it**
- **Each commit should be revertable**
- **Each commit should pass tests**

#### Atomic Commit Workflow
```bash
# After EACH logical change (don't accumulate!):

# 1. Review what changed
git status
git diff

# 2. Stage selectively 
git add -p  # Interactive staging
# OR for specific files
git add src/validation.js

# 3. Verify staged changes
git diff --staged

# 4. Commit with issue reference
git commit -m "feat(validation): add email format check (#45)"

# 5. Update issue immediately
gh issue comment 45 --body "Added email validation in commit abc123"
```

#### Real Atomic Commit Example
```bash
# Working on #64: Add container tools

# First change: Add act
vim nix/home.nix  # Add act package
git add -p nix/home.nix
git commit -m "feat(nix): add act for GitHub Actions testing (#64)"
gh issue comment 64 --body "✅ Added act package (commit abc123)"

# Second change: Add dive  
vim nix/home.nix  # Add dive package
git add -p nix/home.nix
git commit -m "feat(nix): add dive for Docker layer analysis (#64)"
gh issue comment 64 --body "✅ Added dive package (commit def456)"

# Third change: Documentation
vim README.md  # Document both tools
git add README.md
git commit -m "docs: add container tools usage examples (#64)"
gh issue comment 64 --body "✅ Documented tools (commit ghi789)"

# Fourth change: Validation
vim scripts/validate.sh  # Add validation
git add scripts/validate.sh
git commit -m "test: add container tools validation (#64)"
gh issue comment 64 --body "✅ Added validation (commit jkl012)\n\nAll tasks complete! Ready for review."
```

## 🎯 Session Management & Analytics

### Current Session Metrics
- **Session Duration**: [Auto-tracked]
- **Files Modified**: [Auto-counted]
- **Commands Executed**: [Track development commands]
- **Issues Worked**: [Link to GitHub issues]
- **Health Score Change**: [Before/after comparison]

### Notes for Next Session
- [ ] Review project intelligence changes
- [ ] Check health score improvements/degradations
- [ ] Review any pending issues with priority context
- [ ] Check CI/CD pipeline status
- [ ] Update documentation based on project maturity
- [ ] Run analysis if significant changes made

### Continuous Improvement Tracking
- **Code Quality Trend**: [Improving/Stable/Declining]
- **Test Coverage Trend**: [Improving/Stable/Declining]
- **Security Posture Trend**: [Improving/Stable/Declining]
- **Performance Trend**: [Improving/Stable/Declining]

## 📈 Session History & Intelligence Evolution

### Previous Sessions
| Date | Session ID | Project Type | Health Score | Key Accomplishments |
|------|------------|--------------|--------------|-------------------|
| -    | -          | -            | -            | Initial setup     |

### Project Evolution Timeline
| Date | Change Type | Description | Impact |
|------|-------------|-------------|--------|
| -    | -           | -           | -      |

## 🧠 Claude AI Assistant Configuration

### Project-Specific AI Guidance
Based on detected project characteristics, Claude will:
- **Prioritize suggestions** for [detected project type] development
- **Use framework patterns** from [detected frameworks]
- **Apply security practices** appropriate for [detected technologies]
- **Suggest performance optimizations** for [detected architecture]

### Adaptive Assistance Level
- **Beginner**: Detailed explanations and step-by-step guidance
- **Intermediate**: Balanced guidance with code examples
- **Advanced**: High-level architectural guidance and best practices
- **Expert**: Code review and optimization suggestions

*Current Level*: [Auto-detected based on project maturity and complexity]

---

**🚀 Enhanced by Claude-Init Intelligence System**

Remember: Leverage project analysis, maintain session tracking, and let intelligence guide your development decisions!