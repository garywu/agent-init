# Manual Release Management Strategy

## Overview

This document describes a manual-only release management approach for projects that want full control over their versioning and release timing.

## Why Manual Releases?

1. **Full Control**: No unexpected version bumps from automated processes
2. **Deliberate Releases**: Each release is intentional and meaningful
3. **Clean History**: Avoid clutter from automated release commits
4. **Flexibility**: Release when ready, not on a schedule

## Implementation

### 1. Disable Automated Triggers

In your release workflow (`.github/workflows/release.yml`), comment out or remove automated triggers:

```yaml
name: Release Management

on:
  # Manual trigger only
  workflow_dispatch:
    inputs:
      release_type:
        description: 'Release type'
        required: true
        default: 'patch'
        type: choice
        options:
          - patch
          - minor
          - major
          - prerelease
          - custom
      custom_version:
        description: 'Custom version (only used if release_type is custom)'
        required: false
        type: string

  # DISABLE automated releases for manual control
  # schedule:
  #   - cron: '0 9 * * 1'  # Weekly releases

  # push:
  #   branches:
  #     - main
```

### 2. Version Management

Start your project at `v0.0.1` and increment manually:

```bash
# Reset to initial version if needed
git tag -d $(git tag -l | grep -v "v0.0.1")  # Delete local tags
git push origin --delete $(git tag -l | grep -v "v0.0.1")  # Delete remote tags
```

### 3. Changelog Management

Maintain a clean, minimal CHANGELOG.md:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup

## [0.0.1] - YYYY-MM-DD

### Added
- Initial release

[Unreleased]: https://github.com/username/repo/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/username/repo/releases/tag/v0.0.1
```

### 4. Release Process

When ready to create a release:

1. Update CHANGELOG.md with changes
2. Commit changes
3. Go to Actions → Release Management → Run workflow
4. Select release type or provide custom version
5. Workflow creates tag, release, and updates changelog

### 5. Benefits

- **No Release Spam**: No automated release issues or notifications
- **Meaningful Versions**: Each version represents significant changes
- **Clean Git History**: No automated commit noise
- **Full Control**: Release exactly when and how you want

## Example Projects Using This Strategy

Projects that benefit from manual releases:
- Internal tools
- Early-stage projects
- Projects with irregular release cycles
- Projects requiring approval before releases

## Migration from Automated Releases

If you have existing automated releases:

1. Close all release notification issues
2. Delete unnecessary tags and releases
3. Update workflow to remove automated triggers
4. Reset to desired starting version
5. Document the change for contributors

## Best Practices

1. **Document Changes**: Keep CHANGELOG.md updated with unreleased changes
2. **Semantic Versioning**: Follow semver principles when choosing versions
3. **Release Notes**: Write meaningful release notes for each version
4. **Tag Protection**: Consider protecting release tags from deletion
5. **Communication**: Inform contributors about the manual release process

## Conclusion

Manual release management provides maximum control and flexibility. It's ideal for projects that value deliberate, meaningful releases over automated frequency.