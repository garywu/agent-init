# Claude AI Session Tracking - Enhanced

This file provides intelligent session tracking with automated project analysis and GitHub integration.

## 🔍 Current Session (Auto-managed)
- **Session ID**: [Auto-generated: session-YYYYMMDD-HHMMSS-PID]
- **Started**: [ISO timestamp]
- **Status**: [active/paused/completed]
- **Duration**: [Calculated from start]
- **Previous Session**: [Link to previous session if available]

## 📊 Project Intelligence
**Auto-detected project information updated on session start**

- **Type**: [Auto-detected: web-app/library/cli/api/mobile/documentation]
- **Languages**: [Detected from codebase analysis]
- **Framework**: [React/Vue/Angular/Express/FastAPI/Django/etc.]
- **Package Manager**: [npm/yarn/pnpm/pip/poetry/cargo/go mod]
- **Build Tools**: [webpack/vite/rollup/make/cargo/etc.]

### Health Metrics
- **Maturity Score**: [0-100 calculated score]
- **Code Quality**: [Based on linting and structure]
- **Documentation**: [Coverage percentage]
- **Test Coverage**: [If detectable]
- **Security Status**: [Based on dependency scan]
- **Last Health Check**: [Timestamp]

## 📁 Workspace Analysis
**Real-time workspace statistics**

- **Repository Count**: [Auto-detected in workspace]
- **Current Branch**: [Git branch name]
- **Clean Repos**: [Repos with no uncommitted changes]
- **Dirty Repos**: [Repos with uncommitted changes]
- **Total Uncommitted Files**: [Count across all repos]
- **Branch Sync Status**: [ahead/behind remote]

## 🎯 Session Activities (Auto-tracked)

### Recent Activities
<!-- Automatically populated by session management -->
- [Timestamp]: [Activity description] [Type: feature/bug-fix/testing/etc.]

### Files Modified
<!-- Automatically tracked when using session tools -->
- [File path] - [Number of changes]

### Commands Executed
<!-- Key development commands are logged -->
- [Timestamp]: [Command]

### GitHub Integration
- **Linked Issues**: [Auto-detected from file changes and commits]
  - #[Issue Number]: [Issue Title] [Status]
- **Related PRs**: [Associated pull requests]
- **Commits This Session**: [Count with links]

## 📈 Development Metrics

### Session Progress
- **Activities Logged**: [Count]
- **Files Modified**: [Count]
- **Issues Addressed**: [Count]
- **Commits Made**: [Count]
- **Tests Run**: [Count with pass/fail]

### Code Changes
- **Lines Added**: [Count]
- **Lines Removed**: [Count]
- **Files Created**: [List]
- **Files Deleted**: [List]

### Performance Impact
- **Build Time Change**: [If measurable]
- **Bundle Size Change**: [For web projects]
- **Test Duration Change**: [If applicable]

## 🧠 AI Context & Assistance

### Session Context for Claude
Based on the current session analysis, Claude should:
- **Focus on**: [Primary development area based on activity]
- **Use patterns from**: [Detected frameworks and libraries]
- **Apply conventions**: [Project-specific coding standards]
- **Prioritize**: [Current session goals and issues]

### Best Practices from Anthropic Engineering

#### Workflow Strategy
- **Use EPCC Workflow**: Explore → Plan → Code → Commit
- **Apply TDD**: Write tests first for complex logic
- **Visual Iteration**: Use screenshots for UI development
- **Parallel Development**: Use multiple Claude instances when beneficial

#### Essential Setup
- **CLAUDE.md**: Maintain comprehensive project context
- **GitHub CLI**: Use `gh` for all GitHub interactions
- **Permissions**: Configure with `/permissions` command
- **Clear Context**: Use `/clear` when switching tasks

#### Communication Principles
- **Be Specific**: Provide exact requirements and constraints
- **Course-Correct Early**: Address misunderstandings immediately
- **Visual References**: Include screenshots for UI work
- **Atomic Commits**: Make small, focused changes

### Intelligent Suggestions
<!-- Auto-generated based on project state -->
- **Next Actions**: [Recommended based on current progress]
- **Potential Issues**: [Warnings based on analysis]
- **Optimization Opportunities**: [Performance or quality improvements]
- **Security Concerns**: [If any detected]

### Learning from Session
- **Patterns Identified**: [Recurring development patterns]
- **Common Issues**: [Frequently encountered problems]
- **Successful Approaches**: [What worked well]

## 📝 Session Notes & Documentation

### Manual Notes
<!-- Add your own observations and decisions -->
- [Your notes here]

### Key Decisions
<!-- Document important architectural or implementation decisions -->
- [Decision]: [Rationale]

### Blockers & Challenges
<!-- Track impediments for future reference -->
- [Issue]: [Status/Resolution]

### Future Considerations
<!-- Items to address in next session -->
- [ ] [Task or consideration]

## 🔄 Session Management Commands

### Quick Reference
```bash
# Session Control
make session-start      # Start new session with analysis
make session-status     # View current session details
make session-end        # End session with summary
make session-log MSG="activity description"  # Log activity

# Claude Code Commands
/permissions           # Configure tool permissions
/clear                # Clear context when switching tasks
/help                 # Get command help

# Development Workflows
make epcc             # Use Explore-Plan-Code-Commit workflow
make tdd              # Start Test-Driven Development
make visual           # Visual iteration workflow

# Health & Analysis
make session-health     # Update project health score
make analyze           # Run project analysis
make health            # Comprehensive health check

# GitHub Integration
make github-link       # Link session to GitHub issues
make github-sync       # Sync with recent commits
make pr-gen           # Generate PR from session

# Quick Actions
make commit-session    # Commit with session context
make issue-session     # Create issue from session
```

### Session Workflow
1. **Start**: `make session-start` - Initializes tracking with project analysis
2. **Configure**: Set permissions and tools based on project needs
3. **Work**: Follow EPCC workflow (Explore → Plan → Code → Commit)
4. **Log**: `make session-log MSG="..."` - Add specific activities
5. **Context**: Use `/clear` when switching between unrelated tasks
6. **Review**: `make session-status` - Check progress
7. **End**: `make session-end` - Generate comprehensive summary

### Advanced Techniques

#### Using Subagents
Launch subagents for complex tasks:
```bash
# Research subagent
claude "Research best practices for React performance"

# Testing subagent
claude "Run all tests and fix failures"

# Documentation subagent
claude "Update API documentation"
```

#### Think Mode
For complex architectural decisions:
```bash
claude --think "Design scalable architecture for feature X"
```

#### Headless Mode
For automation and CI/CD:
```bash
claude --headless "Review PR and suggest improvements"
```

## 🔗 External Integrations

### GitHub
- **Repository**: [Auto-detected from git remote]
- **Open Issues**: [Count with priority markers]
- **Active PRs**: [List with status]
- **Project Board**: [If configured]

### CI/CD Status
- **Last Build**: [Status and timestamp]
- **Test Results**: [Pass/fail summary]
- **Coverage Trend**: [Improving/stable/declining]
- **Deploy Status**: [If applicable]

### Monitoring & Analytics
- **Error Rate**: [If monitoring configured]
- **Performance Metrics**: [If available]
- **User Analytics**: [If applicable]

## 📊 Historical Context

### Previous Sessions Summary
| Date | Session ID | Duration | Activities | Health Change |
|------|------------|----------|------------|---------------|
| [Date] | [ID] | [Duration] | [Count] | [Change] |

### Trend Analysis
- **Productivity Trend**: [Improving/Stable/Declining]
- **Code Quality Trend**: [Based on health scores]
- **Velocity**: [Average activities per session]

---

## 🚀 Enhanced by Claude-Init Session Intelligence

This enhanced session tracking provides:
- **Persistent Context**: Sessions survive restarts
- **Intelligent Analysis**: Automated project understanding
- **GitHub Integration**: Seamless issue and PR workflow
- **Health Monitoring**: Continuous quality tracking
- **AI Optimization**: Better Claude assistance through context

Remember: Let the session tracking handle the mundane so you can focus on creating!