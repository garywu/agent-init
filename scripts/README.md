# Agent Init Scripts

This directory contains automation scripts for managing the agent-init repository and its documentation.

## Documentation Migration Scripts

### `migrate-docs-simple.sh`
Migrates key documentation files from `docs/` to the Starlight documentation site.

**Usage:**
```bash
./scripts/migrate-docs-simple.sh
```

**What it does:**
- Migrates 15+ essential documentation files
- Adds proper Starlight frontmatter
- Organizes content into logical categories
- Creates proper directory structure

### `create-template-docs.sh`
Creates comprehensive documentation for all templates in the repository.

**Usage:**
```bash
./scripts/create-template-docs.sh
```

**What it does:**
- Creates CLAUDE.md templates documentation
- Documents all Makefile commands
- Creates templates overview
- Adds to reference section

## Migration Results

After running both scripts, the documentation site contains:

### Workflow Guides
- Git Workflow Patterns
- Release Management Patterns
- Context Preservation Patterns

### Development Guides
- Testing Framework Guide
- Linting and Formatting
- Debugging and Troubleshooting

### Tools Guides
- Interactive CLI Tools
- Recommended Tools for Claude

### Security Guides
- Email Privacy Protection
- Secrets Management Patterns

### Deployment Guides
- GitHub Actions Multi-Platform
- Documentation Site Setup
- GitHub Pages Troubleshooting

### Reference Documentation
- Project Structure Patterns
- Error Handling Patterns
- CLAUDE.md Templates
- Makefile Commands
- Templates Overview

## Usage

1. **Run template documentation first:**
   ```bash
   ./scripts/create-template-docs.sh
   ```

2. **Run documentation migration:**
   ```bash
   ./scripts/migrate-docs-simple.sh
   ```

3. **Preview the results:**
   ```bash
   cd pages && npm run dev
   ```

4. **Commit the changes:**
   ```bash
   git add pages/
   git commit -m "docs: migrate comprehensive documentation to Starlight site"
   ```

## Script Features

- **Error handling**: Scripts fail fast on errors
- **Logging**: Clear progress indication
- **Safety**: Creates directories as needed
- **Idempotent**: Safe to run multiple times
- **Frontmatter**: Adds proper Starlight metadata

## Future Scripts

Additional scripts could include:
- Update checker for templates
- Link validator for documentation
- Automated issue closing for completed migrations
- Template customization generator