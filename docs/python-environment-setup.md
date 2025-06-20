# Python Environment Setup Guide

This guide provides best practices for setting up Python environments in a cross-platform, reproducible manner using Nix as the base Python provider.

## Overview

The canonical approach for Python development combines:
- **Nix**: Provides consistent Python base across all platforms
- **Virtual Environments**: Project-specific dependency isolation
- **pipx**: Global Python CLI tools in isolated environments

## System Setup

### 1. Base Python Installation (via Nix)

Ensure your `home.nix` includes:

```nix
home.packages = with pkgs; [
  python311        # Or your preferred Python version
  pipx            # For global Python tools
  # pre-commit    # Optional: if you use pre-commit hooks
];
```

### 2. Verify Clean Environment

```bash
# Check Python source (should be Nix)
which python    # → ~/.nix-profile/bin/python
which python3   # → ~/.nix-profile/bin/python3
python --version # → Python 3.11.x

# Ensure no conflicting installations
./scripts/validation/validate-packages.sh
```

## Project Setup

### 1. Virtual Environment Approach (Recommended)

For each Python project:

```bash
# Navigate to project
cd my-project

# Create virtual environment
python -m venv venv

# Activate (bash/zsh)
source venv/bin/activate

# Activate (fish shell)
source venv/bin/activate.fish

# Install dependencies
pip install -r requirements.txt

# When done, deactivate
deactivate
```

### 2. Project Structure

```
my-project/
├── .gitignore          # Must include: venv/
├── README.md           # Include setup instructions
├── requirements.txt    # Pin versions for reproducibility
├── venv/              # Virtual environment (not in git)
├── src/               # Source code
└── tests/             # Test files
```

### 3. .gitignore Essentials

```gitignore
# Python
venv/
__pycache__/
*.py[cod]
*$py.class
.Python
*.so
.coverage
.pytest_cache/
.mypy_cache/
```

### 4. README Template

```markdown
## Setup

```bash
# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run tests
pytest
```
```

## Global CLI Tools

Use `pipx` for Python CLI tools that should be available globally:

```bash
# Development tools
pipx install black
pipx install flake8
pipx install mypy
pipx install pytest
pipx install ipython

# Project management
pipx install poetry
pipx install hatch
pipx install pdm

# Utilities
pipx install httpie
pipx install litecli
pipx install cookiecutter
```

## Poetry Projects

For projects using Poetry:

```bash
# Install Poetry globally
pipx install poetry

# In your project
cd my-project
poetry install
poetry shell  # Activates the virtual environment
```

## IDE Configuration

### VS Code

Create `.vscode/settings.json`:

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/venv/bin/python",
  "python.terminal.activateEnvironment": true,
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": false,
  "python.linting.flake8Enabled": true,
  "python.formatting.provider": "black"
}
```

### PyCharm

1. File → Settings → Project → Python Interpreter
2. Click gear icon → Add
3. Select "Existing Environment"
4. Choose: `project/venv/bin/python`

## Common Issues and Solutions

### Issue: `pip: command not found`

```bash
# pip is included with venv, ensure it's activated
source venv/bin/activate
# Or use python -m pip
python -m pip install package-name
```

### Issue: Wrong Python Version

```bash
# Check which Python is being used
which python
# Should show: /path/to/project/venv/bin/python
# If not, reactivate venv
```

### Issue: Package conflicts between projects

This is why we use virtual environments! Each project has isolated dependencies.

## Best Practices

1. **Always use virtual environments** for projects
2. **Pin dependency versions** in requirements.txt
3. **Use pipx for global tools**, not pip install --user
4. **Document setup steps** in your README
5. **Include venv/ in .gitignore**
6. **Use the same Python base** (Nix) across machines

## Advanced: requirements.txt Management

```bash
# Generate requirements.txt from current environment
pip freeze > requirements.txt

# Better: use pip-tools for deterministic dependencies
pipx install pip-tools

# Create requirements.in with top-level deps
echo "django>=4.0" > requirements.in
echo "requests" >> requirements.in

# Generate locked requirements.txt
pip-compile requirements.in
```

## Testing Your Setup

Create a test script to verify environment:

```python
#!/usr/bin/env python
# test_environment.py
import sys
import os

print(f"Python: {sys.version}")
print(f"Executable: {sys.executable}")
print(f"Prefix: {sys.prefix}")
print(f"Virtual env: {hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix)}")
```

## Summary

This approach provides:
- **Consistency**: Same Python base (Nix) everywhere
- **Isolation**: Projects don't interfere with each other
- **Reproducibility**: Pinned dependencies via requirements.txt
- **Flexibility**: Use any Python packages without system conflicts
- **Cross-platform**: Works on macOS, Linux, and WSL

Remember: Nix provides the Python runtime, virtual environments provide the isolation!