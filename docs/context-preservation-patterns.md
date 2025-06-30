# Context Preservation Patterns

This guide addresses the common problem of losing working directory context and provides patterns to maintain state across Claude CLI interactions.

## The PWD Problem

Claude CLI often loses track of:
- Current working directory
- Environment variables
- Active virtual environments
- Git branch context
- Session state

## Solutions and Patterns

### 1. Explicit Context in Prompts

Always include context in your commands:

```bash
# Bad - assumes Claude knows where you are
"Run the tests"

# Good - explicit context
"In /home/user/myproject, run npm test"

# Better - with verification
"pwd is $(pwd). Run npm test"
```

### 2. Context Preservation Tools

#### direnv - Automatic Environment Loading

**What it does**: Automatically loads/unloads environment variables when entering/leaving directories.

**Setup**:
```bash
# Install (already in dotfiles)
brew install direnv  # or nix-env -i direnv

# Hook into shell (.bashrc/.zshrc)
eval "$(direnv hook bash)"

# Create .envrc in project
echo 'export PROJECT_ROOT=$(pwd)' > .envrc
echo 'export NODE_ENV=development' >> .envrc
direnv allow
```

**Use with Claude**:
```bash
# .envrc file that preserves context
export CLAUDE_PROJECT_ROOT=$(pwd)
export CLAUDE_PROJECT_NAME=$(basename $(pwd))
export CLAUDE_GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "no-git")

# Custom prompt that includes context
export PS1="[\$CLAUDE_PROJECT_NAME:\$CLAUDE_GIT_BRANCH] \w $ "
```

#### zoxide - Smart Directory Navigation

**What it does**: Remembers your frequently used directories and jumps to them intelligently.

**Usage**:
```bash
# Instead of: cd /very/long/path/to/project
z project

# Show current directory in prompt
z query -l | head -5  # Show top 5 directories
```

### 3. Session State Files

Create a session state file that Claude can read:

```bash
# Create .claude-context in project root
create_claude_context() {
    cat > .claude-context << EOF
PROJECT_ROOT: $(pwd)
PROJECT_NAME: $(basename $(pwd))
GIT_BRANCH: $(git branch --show-current 2>/dev/null || echo "none")
VIRTUAL_ENV: ${VIRTUAL_ENV:-none}
NODE_VERSION: $(node --version 2>/dev/null || echo "none")
PYTHON_VERSION: $(python --version 2>/dev/null || echo "none")
LAST_UPDATED: $(date)
EOF
}

# Update on directory change
cd() {
    builtin cd "$@" && create_claude_context
}
```

### 4. Shell Integration Patterns

#### Starship Prompt with Context

Configure Starship to show full context:

```toml
# ~/.config/starship.toml
[directory]
truncation_length = 8
truncate_to_repo = false
format = "[$path]($style) "
style = "blue bold"

[git_branch]
format = "on [$symbol$branch]($style) "

[python]
format = 'via [${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'

[nodejs]
format = "via [⬢ $version](bold green) "

[custom.claude_pwd]
command = "pwd"
when = true
format = "[\\[PWD: $output\\]]($style) "
style = "dimmed white"
```

#### PROMPT_COMMAND for Bash

```bash
# Add to .bashrc
update_claude_context() {
    echo "$(pwd)" > ~/.claude_pwd
    echo "$(git branch --show-current 2>/dev/null || echo 'no-git')" > ~/.claude_git_branch
}

PROMPT_COMMAND="update_claude_context"

# Claude can read these files
alias claude-where='echo "PWD: $(cat ~/.claude_pwd), Branch: $(cat ~/.claude_git_branch)"'
```

### 5. Project Markers

Use marker files to help Claude understand project context:

```bash
# .claude-project.yml in project root
project:
  name: "My Amazing Project"
  type: "node"
  root: "."
  main_branch: "main"

commands:
  test: "npm test"
  build: "npm run build"
  dev: "npm run dev"

paths:
  source: "./src"
  tests: "./tests"
  docs: "./docs"
```

### 6. Integration with tmux

Preserve context across terminal sessions:

```bash
# .tmux.conf
# Show current directory in status bar
set -g status-left '#[fg=blue]#(pwd) #[default]'

# Save pane's current directory
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
```

### 7. VS Code Integration

If using VS Code with Claude:

```json
// .vscode/settings.json
{
    "terminal.integrated.env.osx": {
        "CLAUDE_PROJECT_ROOT": "${workspaceFolder}",
        "CLAUDE_PROJECT_NAME": "${workspaceFolderBasename}"
    },
    "terminal.integrated.cwd": "${workspaceFolder}"
}
```

## Best Practices

### 1. Always Verify Context

Start conversations with context verification:

```bash
"Current directory is $(pwd), on git branch $(git branch --show-current).
Please help me..."
```

### 2. Use Absolute Paths

When referencing files:

```bash
# Bad
"Edit config.js"

# Good
"Edit /home/user/project/src/config.js"

# Better - with verification
"Edit $(pwd)/src/config.js"
```

### 3. Create Context Aliases

```bash
# ~/.bashrc or ~/.zshrc
alias claude-context='echo "PWD: $(pwd), Git: $(git branch --show-current 2>/dev/null || echo none), Node: $(node -v 2>/dev/null || echo none), Python: $(python --version 2>/dev/null || echo none)"'

# Use before Claude commands
claude-context && claude "your request here"
```

### 4. Use Named Workspaces

```bash
# Create workspace markers
mkdir -p ~/.claude-workspaces
echo "$(pwd)" > ~/.claude-workspaces/myproject

# Quick jump to workspace
claude-go() {
    cd "$(cat ~/.claude-workspaces/$1)"
}
```

## Tool Recommendations

Essential tools for context preservation (already in dotfiles):

1. **direnv** - Automatic environment variables
2. **zoxide** - Smart cd that remembers
3. **starship** - Context-aware prompt
4. **tmux** - Session preservation
5. **fzf** - Quick directory jumping
6. **bat** - Shows file paths clearly
7. **eza/lsd** - Shows full paths in listings

## Quick Setup Script

```bash
#!/bin/bash
# setup-claude-context.sh

# Create context preservation
cat >> ~/.bashrc << 'EOF'
# Claude Context Preservation
update_claude_context() {
    mkdir -p ~/.claude
    echo "$(pwd)" > ~/.claude/pwd
    echo "$(date)" > ~/.claude/last_update
    env | grep -E "^(VIRTUAL_ENV|NODE_ENV|CLAUDE_)" > ~/.claude/env
}

PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }update_claude_context"

# Helper function
claude_where() {
    echo "=== Claude Context ==="
    echo "PWD: $(cat ~/.claude/pwd 2>/dev/null || pwd)"
    echo "Last Update: $(cat ~/.claude/last_update 2>/dev/null || echo 'Never')"
    echo "Branch: $(git branch --show-current 2>/dev/null || echo 'Not in git repo')"
    echo "=================="
}

alias cw=claude_where
EOF

echo "Claude context preservation setup complete!"
echo "Run 'source ~/.bashrc' to activate"
```

## The Ultimate Solution: Project-Aware Claude

Create a wrapper that always provides context:

```bash
#!/bin/bash
# claude-aware - A context-aware Claude wrapper

claude_with_context() {
    local context_file="/tmp/claude_context_$$.txt"

    # Gather context
    cat > "$context_file" << EOF
=== Current Context ===
Working Directory: $(pwd)
Git Branch: $(git branch --show-current 2>/dev/null || echo "Not in git repo")
Git Status: $(git status --porcelain 2>/dev/null | wc -l) changes
Virtual Env: ${VIRTUAL_ENV:-None active}
Node Version: $(node --version 2>/dev/null || echo "Not installed")
Python Version: $(python --version 2>/dev/null || echo "Not installed")
Time: $(date)
===================

EOF

    # Prepend context to Claude input
    echo "Context:" >&2
    cat "$context_file" >&2
    echo "" >&2

    # Call Claude with context
    claude "$@" --context-file "$context_file"

    rm -f "$context_file"
}

alias claude=claude_with_context
```

This comprehensive approach ensures Claude always knows where you are and what you're working on.