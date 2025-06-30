# GitHub Labels Setup

This directory contains scripts and configurations for setting up standardized GitHub labels across projects.

## Quick Start

```bash
# Basic labels for any project
../../scripts/setup-github-labels.sh

# With platform-specific labels
./setup-with-platforms.sh

# For dotfiles projects
./setup-dotfiles-labels.sh
```

## Label Categories

### Core Labels (Project-Agnostic)
These are included in the main script and suitable for any project:

- **Issue Types**: bug, enhancement, documentation, question, chore, refactor
- **Priority**: critical, high, medium, low
- **Status**: blocked, in-progress, needs-review, help wanted, good first issue
- **Resolution**: duplicate, invalid, wontfix
- **Categories**: security, performance, testing, ci-cd, dependencies, breaking-change
- **Size**: xs, s, m, l, xl (for PRs)

### Optional Platform Labels
For projects that need platform-specific tracking:

- platform-macos
- platform-linux
- platform-windows
- platform-wsl
- platform-android
- platform-ios

### Optional Tool Labels
For projects using specific tools:

- tool-docker
- tool-kubernetes
- tool-terraform
- tool-ansible
- tool-npm
- tool-pip
- tool-cargo

### Optional Language Labels
For multi-language projects:

- lang-javascript
- lang-typescript
- lang-python
- lang-go
- lang-rust
- lang-shell

## Customization

1. Copy the base script
2. Add your project-specific labels
3. Adjust colors to match your project's theme

## Color Guidelines

- **Red shades** (#d73a4a): Bugs, critical issues, security
- **Green shades** (#0e8a16): Ready, approved, success
- **Yellow shades** (#fbca04): Warnings, medium priority, in-progress
- **Blue shades** (#0075ca): Information, documentation, enhancement
- **Purple shades** (#d876e3): Questions, discussions
- **Gray shades** (#cfd3d7): Duplicates, wontfix, invalid

## Best Practices

1. Keep label names short and clear
2. Use consistent naming patterns (noun or verb-noun)
3. Avoid too many labels (20-30 is usually enough)
4. Group related labels with common prefixes
5. Use colors meaningfully and consistently