# Claude-Init Documentation

Welcome to the claude-init documentation. This collection of guides provides comprehensive information for Claude CLI to make intelligent decisions when setting up and maintaining projects.

## 📍 Quick Navigation

### By Task

- **Setting up a new project?** → Start with [Project Structure Patterns](project-structure-patterns.md)
- **Supporting multiple environments?** → See [Environment Adaptation Patterns](environment-adaptation-patterns.md)
- **Making CLIs interactive?** → Use [Interactive CLI Tools](interactive-cli-tools.md)
- **Adding linting/formatting?** → See [Linting and Formatting Guide](linting-and-formatting.md)
- **Creating tests?** → Check [Testing Framework Guide](testing-framework-guide.md)
- **Setting up CI/CD?** → Read [GitHub Actions Multi-Platform Guide](github-actions-multi-platform.md)
- **Building documentation site?** → Follow [Documentation Site Setup](documentation-site-setup.md)
- **Managing releases?** → Use [Release Management Patterns](release-management-patterns.md)
- **Handling errors gracefully?** → See [Error Handling Patterns](error-handling-patterns.md)
- **Debugging issues?** → Consult [Debugging and Troubleshooting](debugging-and-troubleshooting.md)
- **Learning from experience?** → Study [Learning from Mistakes](learning-from-mistakes.md)

### By Problem

- **"My docs site only builds 2 pages"** → [Documentation Site Setup](documentation-site-setup.md#critical-knowledge-the-content-collection-sync-issue)
- **"CI works locally but fails on GitHub"** → [Platform-Specific Issues](github-actions-multi-platform.md#platform-specific-issues-and-solutions)
- **"How do I test shell scripts?"** → [Testing Framework Guide](testing-framework-guide.md)
- **"Package-lock.json causing CI failures"** → [Cross-Platform Node.js Setup](github-actions-multi-platform.md#cross-platform-nodejs-setup)

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
- [Environment Adaptation Patterns](environment-adaptation-patterns.md) - CI, platform, and context handling
- [Interactive CLI Tools](interactive-cli-tools.md) - fzf, gum, and other UX enhancers
- [Linting and Formatting Guide](linting-and-formatting.md) - All major languages and tools
- [Testing Framework Guide](testing-framework-guide.md) - Building robust test suites
- [GitHub Actions Multi-Platform Guide](github-actions-multi-platform.md) - CI/CD across OS
- [Release Management Patterns](release-management-patterns.md) - Versioning and changelog automation
- [Error Handling Patterns](error-handling-patterns.md) - Recovery and rollback strategies

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
2. Apply relevant templates from `/templates`
3. Set up linting using [Linting and Formatting Guide](linting-and-formatting.md)
4. Configure CI using [GitHub Actions Guide](github-actions-multi-platform.md)
5. Add tests following [Testing Framework Guide](testing-framework-guide.md)

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