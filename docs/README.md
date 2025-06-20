# Claude-Init Documentation

Welcome to the claude-init documentation. This collection of guides provides comprehensive information for Claude CLI to make intelligent decisions when setting up and maintaining projects.

## 📍 Quick Navigation

### By Task

- **Setting up a new project?** → Start with [Project Structure Patterns](project-structure-patterns.md)
- **Scaffolding projects quickly?** → Use [Project Scaffolding Patterns](project-scaffolding-patterns.md)
- **Supporting multiple environments?** → See [Environment Adaptation Patterns](environment-adaptation-patterns.md)
- **Making scripts work in CI?** → Follow [CI Environment Patterns](ci-environment-patterns.md)
- **Making CLIs interactive?** → Use [Interactive CLI Tools](interactive-cli-tools.md)
- **Preserving context across sessions?** → Read [Context Preservation Patterns](context-preservation-patterns.md)
- **Using modern CLI tools effectively?** → See [Recommended Tools for Claude](recommended-tools-for-claude.md)
- **Protecting email privacy?** → Check [Email Privacy Protection](email-privacy-protection.md)
- **Managing secrets securely?** → Follow [Secrets Management Patterns](secrets-management-patterns.md)
- **Setting up Git workflows?** → Use [Git Workflow Patterns](git-workflow-patterns.md)
- **Configuring shells?** → See [Shell Configuration Patterns](shell-configuration-patterns.md)
- **Adding monitoring?** → Implement [Monitoring and Observability Patterns](monitoring-observability-patterns.md)
- **Creating proper .gitignore?** → Reference [Gitignore Patterns](gitignore-patterns.md)
- **Consistent code style?** → Apply [EditorConfig Patterns](editorconfig-patterns.md)
- **Writing robust tests?** → Use [Test Helper Patterns](test-helper-patterns.md)
- **Adding linting/formatting?** → See [Linting and Formatting Guide](linting-and-formatting.md)
- **Creating tests?** → Check [Testing Framework Guide](testing-framework-guide.md)
- **Setting up CI/CD?** → Read [GitHub Actions Multi-Platform Guide](github-actions-multi-platform.md)
- **Building documentation site?** → Follow [Documentation Site Setup](documentation-site-setup.md)
- **Managing releases?** → Use [Release Management Patterns](release-management-patterns.md)
- **Handling errors gracefully?** → See [Error Handling Patterns](error-handling-patterns.md)
- **Debugging issues?** → Consult [Debugging and Troubleshooting](debugging-and-troubleshooting.md)
- **Learning from experience?** → Study [Learning from Mistakes](learning-from-mistakes.md)
- **Setting up Python projects?** → Follow [Python Environment Setup](python-environment-setup.md)
- **Configuring ShellCheck?** → See [ShellCheck Best Practices](shellcheck-best-practices.md)
- **Building validation systems?** → Use [Building Validation Systems](building-validation-systems.md)

### By Problem

- **"My docs site only builds 2 pages"** → [Documentation Site Setup](documentation-site-setup.md#critical-knowledge-the-content-collection-sync-issue)
- **"CI works locally but fails on GitHub"** → [Platform-Specific Issues](github-actions-multi-platform.md#platform-specific-issues-and-solutions)
- **"Claude keeps forgetting my pwd"** → [Context Preservation Patterns](context-preservation-patterns.md#the-pwd-problem)
- **"How do I test shell scripts?"** → [Testing Framework Guide](testing-framework-guide.md)
- **"Package-lock.json causing CI failures"** → [Cross-Platform Node.js Setup](github-actions-multi-platform.md#cross-platform-nodejs-setup)
- **"How do I prevent email exposure?"** → [Email Privacy Protection](email-privacy-protection.md)
- **"How do I manage secrets safely?"** → [Secrets Management Patterns](secrets-management-patterns.md)
- **"How do I configure git hooks?"** → [Git Workflow Patterns](git-workflow-patterns.md)
- **"What should I put in .gitignore?"** → [Gitignore Patterns](gitignore-patterns.md)
- **"How do I make scripts work in CI?"** → [CI Environment Patterns](ci-environment-patterns.md)
- **"How do I ensure consistent code style?"** → [EditorConfig Patterns](editorconfig-patterns.md)
- **"Python conflicts between Homebrew/Nix?"** → [Python Environment Setup](python-environment-setup.md)
- **"How do I fix ShellCheck warnings?"** → [ShellCheck Best Practices](shellcheck-best-practices.md)
- **"How do I validate my environment?"** → [Building Validation Systems](building-validation-systems.md)

## 🎯 Core Principles

### Information Over Implementation

We provide comprehensive documentation rather than prescriptive scripts because:

1. **Context Matters** - Every project is different
2. **Flexibility Required** - Multiple valid approaches exist
3. **Learning Enabled** - Understanding > blind copying
4. **Future Proof** - Concepts outlast specific implementations

### What We Document

✅ **Multiple Approaches** - Different ways to solve problems
✅ **Trade-offs** - When to use which approach
✅ **Common Pitfalls** - What doesn't work and why
✅ **Debugging Steps** - How to investigate issues
✅ **Best Practices** - Proven patterns that work

❌ **Not Prescriptive Scripts** - No one-size-fits-all solutions
❌ **Not Opinions** - We present options, not mandates
❌ **Not Exhaustive** - We focus on common, important cases

## 📚 Documentation Structure

### Reference Guides
Comprehensive information about specific topics:
- [Project Structure Patterns](project-structure-patterns.md) - Organization best practices
- [Project Scaffolding Patterns](project-scaffolding-patterns.md) - Quick project initialization templates
- [Environment Adaptation Patterns](environment-adaptation-patterns.md) - CI, platform, and context handling
- [CI Environment Patterns](ci-environment-patterns.md) - Making scripts work in both interactive and CI environments
- [Interactive CLI Tools](interactive-cli-tools.md) - fzf, gum, and other UX enhancers
- [Context Preservation Patterns](context-preservation-patterns.md) - Maintaining state across sessions
- [Recommended Tools for Claude](recommended-tools-for-claude.md) - Modern CLI tools to leverage
- [Linting and Formatting Guide](linting-and-formatting.md) - All major languages and tools
- [Testing Framework Guide](testing-framework-guide.md) - Building robust test suites
- [Test Helper Patterns](test-helper-patterns.md) - Reusable test utilities and helpers
- [GitHub Actions Multi-Platform Guide](github-actions-multi-platform.md) - CI/CD across OS
- [Release Management Patterns](release-management-patterns.md) - Versioning and changelog automation
- [Error Handling Patterns](error-handling-patterns.md) - Recovery and rollback strategies

### Security and Privacy Guides
- [Email Privacy Protection](email-privacy-protection.md) - Preventing email exposure in commits
- [Secrets Management Patterns](secrets-management-patterns.md) - Secure credential handling

### Development Environment Guides
- [Git Workflow Patterns](git-workflow-patterns.md) - Advanced git configuration and hooks
- [Gitignore Patterns](gitignore-patterns.md) - Comprehensive .gitignore templates
- [EditorConfig Patterns](editorconfig-patterns.md) - Consistent code style across editors
- [Shell Configuration Patterns](shell-configuration-patterns.md) - Bash, Zsh, Fish setup
- [Python Environment Setup](python-environment-setup.md) - Virtual environments and pipx
- [Monitoring and Observability Patterns](monitoring-observability-patterns.md) - Metrics, logs, and traces
- [ShellCheck Best Practices](shellcheck-best-practices.md) - Shell script static analysis configuration
- [Building Validation Systems](building-validation-systems.md) - Environment and dependency validation

### Problem-Solution Guides
Based on real debugging experiences:
- [Debugging and Troubleshooting](debugging-and-troubleshooting.md) - Common issues and fixes
- [Documentation Site Setup](documentation-site-setup.md) - Astro/Starlight specifics

### Meta Guides
How to use and contribute to this knowledge base:
- [Claude Templates Reference](CLAUDE_TEMPLATES.md) - How Claude should use these docs
- [Learning from Mistakes](learning-from-mistakes.md) - Contributing debugging knowledge

## 🔍 How to Use This Documentation

### For Claude CLI

When setting up a project:

1. **Assess the project** - Language, existing tools, team size
2. **Find relevant guides** - Use the navigation above
3. **Consider options** - Each guide presents multiple approaches
4. **Make informed decisions** - Based on project context
5. **Document choices** - In CLAUDE.md for continuity

### For Contributors

When adding documentation:

1. **Document real experiences** - Not theoretical knowledge
2. **Include failed attempts** - Save others from dead ends
3. **Provide context** - When/why to use each approach
4. **Add examples** - Concrete > abstract
5. **Update navigation** - Make it findable

## 🚀 Common Workflows

### Setting Up a New Project

1. Review [Claude Templates Reference](CLAUDE_TEMPLATES.md)
2. Consider using [Project Scaffolding Patterns](project-scaffolding-patterns.md) for quick setup
3. Apply relevant templates from `/templates`
4. Add appropriate [.gitignore](gitignore-patterns.md) and [.editorconfig](editorconfig-patterns.md)
5. Set up linting using [Linting and Formatting Guide](linting-and-formatting.md)
6. Configure CI using [GitHub Actions Guide](github-actions-multi-platform.md) and [CI Environment Patterns](ci-environment-patterns.md)
7. Add tests following [Testing Framework Guide](testing-framework-guide.md) with [Test Helper Patterns](test-helper-patterns.md)

### Debugging an Issue

1. Check [Debugging and Troubleshooting](debugging-and-troubleshooting.md) for known issues
2. Look for platform-specific issues in [GitHub Actions Guide](github-actions-multi-platform.md)
3. Review topic-specific troubleshooting sections
4. Document new findings using [Learning from Mistakes](learning-from-mistakes.md) template

### Adding New Features

1. Research options in relevant guides
2. Consider trade-offs documented
3. Test across platforms using CI patterns
4. Document decisions and reasoning
5. Update guides if you learn something new

## 💡 Key Insights

### From Our Experience

1. **Always run `astro sync`** before building Astro sites
2. **Test in CI early** - Don't assume local = CI behavior
3. **Document failed attempts** - They're as valuable as solutions
4. **Platform differences matter** - Especially macOS vs Linux
5. **Simple often wins** - Complex solutions often create more problems

### Time Savers

- **3.5 hours debugging** → 30 min documenting → **5 min for next person**
- **Cross-platform testing** prevents most CI failures
- **Diagnostic scripts** make debugging much faster
- **Clear error messages** prevent confusion

## 🔗 External Resources

### Documentation That Made a Difference

These are the specific documentation pages that helped us solve real problems:

#### The Astro Sync Discovery
- [Astro CLI Reference - astro sync](https://docs.astro.build/en/reference/cli-reference/#astro-sync) - The page that saved 3.5 hours
- [Astro Content Collections](https://docs.astro.build/en/guides/content-collections/) - Critical for understanding the sync requirement

#### Platform-Specific Solutions
- [npm package-lock.json docs](https://docs.npmjs.com/cli/v9/configuring-npm/package-lock-json) - Explains cross-platform issues
- [GitHub-hosted runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners) - Runner specifications and limitations

### Official Documentation
- [Astro Docs](https://docs.astro.build)
- [Starlight Docs](https://starlight.astro.build)
- [GitHub Actions Docs](https://docs.github.com/actions)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

### Tools Referenced
- [ShellCheck](https://www.shellcheck.net/) - Shell script linting
- [Prettier](https://prettier.io/) - Code formatting
- [ESLint](https://eslint.org/) - JavaScript linting
- [Ruff](https://docs.astral.sh/ruff/) - Fast Python linting

## 📝 Contributing

See [Learning from Mistakes](learning-from-mistakes.md) for how to contribute your debugging experiences back to this documentation.

Remember: **Every hour you spent debugging is worth documenting to save others that time.**

---

*This documentation is maintained as part of claude-init to help Claude CLI make intelligent, context-aware decisions when setting up and maintaining projects.*