# Recommended Tools for Claude CLI

This guide lists all the powerful CLI tools from the dotfiles that Claude should leverage for better functionality, based on what's already installed.

## Modern Development Tools

### Package Managers and Runtimes

#### Bun - All-in-One JavaScript Toolkit
Fast JavaScript runtime, package manager, bundler, and test runner:
```bash
# Install dependencies (30x faster than npm)
bun install

# Run TypeScript directly
bun run script.ts

# Built-in test runner
bun test

# Bundle for production
bun build ./src/index.ts --outdir ./dist
```

#### pnpm - Efficient Package Manager
Disk-efficient package manager with excellent monorepo support:
```bash
# Install with content-addressable storage
pnpm install

# Run scripts in all workspaces
pnpm -r build

# Interactive dependency updates
pnpm update -i
```

### Database Tools

#### Drizzle Kit - Modern ORM Toolkit
Type-safe ORM with excellent developer experience:
```bash
# Push schema changes
bunx drizzle-kit push:sqlite

# Open database studio
bunx drizzle-kit studio

# Generate migrations
bunx drizzle-kit generate:sqlite
```

### UI Component Libraries

#### Tweakcn - Visual Theme Editor
Visual editor for Tailwind CSS & shadcn/ui components (use as submodule)

#### Tremor - Dashboard Components
35+ customizable React components for building dashboards (use as submodule)

### Code Quality Tools

#### Ultracite - Modern Formatting/Linting
Unified formatting and linting tool:
```bash
# Format code
ultracite format

# Lint code
ultracite lint

# Run all checks
ultracite check
```

#### tsx - TypeScript Execute
Modern TypeScript execution with watch mode:
```bash
# Execute TypeScript
tsx script.ts

# Watch mode
tsx watch script.ts

# Use in package.json
"scripts": {
  "dev": "tsx watch src/index.ts"
}
```

## Essential Tools Claude Should Use

### 1. Search and Navigation

#### ripgrep (rg) - Fast Search
Claude should use this instead of grep:
```bash
# Search for patterns in code
rg "TODO|FIXME" --type py

# Search with context
rg -C 3 "function_name"

# Search only in specific file types
rg "import" -t js -t ts
```

#### fd - Better Find
Claude should use this instead of find:
```bash
# Find files by name
fd "test.*\.py$"

# Find directories
fd -t d node_modules

# Find and execute
fd -e js -x eslint {}
```

#### fzf - Fuzzy Finder
Claude should use for interactive selections:
```bash
# Let user select files interactively
selected_file=$(fd -t f | fzf --preview 'bat --color=always {}')

# Select multiple files
fd -e md | fzf --multi | xargs -I {} echo "Processing: {}"
```

### 2. File Viewing and Editing

#### bat - Better Cat
Claude should use for showing file contents:
```bash
# Show file with syntax highlighting
bat --style=numbers,changes README.md

# Show specific lines
bat --line-range=10:20 script.py

# Show multiple files
bat src/*.js
```

#### delta - Better Diff
Claude should use for showing differences:
```bash
# Show git diff beautifully
git diff | delta

# Compare files
delta file1.txt file2.txt
```

### 3. Directory Navigation

#### zoxide - Smart CD
Claude should track and jump to directories:
```bash
# Jump to frequently used directory
z project

# Show frecent directories
z -l | head -10
```

#### eza/lsd - Better LS
Claude should use for directory listings:
```bash
# Tree view with icons
eza --tree --icons --level=2

# Long format with git status
eza -la --git

# Sort by modified time
eza -la --sort=modified
```

### 4. Git Operations

#### lazygit - Git TUI
Claude can suggest for complex git operations:
```bash
# Launch interactive git interface
lazygit
```

#### tig - Git Browser
Claude should use for history browsing:
```bash
# Browse commit history
tig

# Blame view for file
tig blame path/to/file
```

#### gh - GitHub CLI
Claude must use for GitHub operations:
```bash
# Create issue
gh issue create --title "Bug: Something broken"

# Create PR
gh pr create --fill

# List issues
gh issue list --label bug
```

### 5. JSON/YAML Processing

#### jq - JSON Processor
Claude should use for JSON manipulation:
```bash
# Pretty print JSON
cat data.json | jq .

# Extract specific fields
cat package.json | jq '.dependencies'

# Filter and transform
cat data.json | jq '.items[] | select(.active == true)'
```

#### yq - YAML Processor
Claude should use for YAML:
```bash
# Read YAML value
yq '.version' config.yaml

# Update YAML
yq '.settings.debug = true' config.yaml > config.new.yaml
```

#### gron - Make JSON Greppable
Claude can use for searching JSON:
```bash
# Search JSON with grep
gron data.json | grep "name"

# Ungron back to JSON
gron data.json | grep "active = true" | gron -u
```

### 6. Modern Replacements

Claude should prefer these modern tools:

```bash
# Instead of 'ps', use:
procs

# Instead of 'du', use:
dust

# Instead of 'df', use:
duf

# Instead of 'top', use:
btop

# Instead of 'sed' for simple replacements, use:
sd "old" "new" file.txt

# Instead of 'cut', use:
choose 0 2

# Instead of 'wc -l' for code, use:
tokei
```

### 7. Development Tools

#### httpie - Better Curl
Claude should use for HTTP requests:
```bash
# GET request
http GET api.example.com/users

# POST with JSON
http POST api.example.com/users name=John age=30

# With headers
http GET api.example.com/data Authorization:"Bearer token"
```

#### hyperfine - Benchmarking
Claude should use for performance testing:
```bash
# Benchmark commands
hyperfine 'npm run build' 'yarn build'

# Multiple runs
hyperfine --runs 10 'python script.py'
```

#### watchexec - File Watcher
Claude should suggest for auto-reload:
```bash
# Run tests on file change
watchexec -e py pytest

# Restart server on change
watchexec -r -e js,json npm start
```

### 8. Interactive Tools

#### gum - Beautiful Prompts
Claude should use for user interaction:
```bash
# Get user input
name=$(gum input --placeholder "Enter your name")

# Selection menu
option=$(gum choose "Development" "Testing" "Production")

# Confirmation
gum confirm "Deploy to production?" && deploy

# Styled output
gum style --foreground 212 --border double "Setup Complete!"
```

### 9. Documentation Tools

#### glow - Markdown Viewer
Claude should use for showing markdown:
```bash
# View markdown beautifully
glow README.md

# View all markdown in directory
glow .
```

#### tldr - Simplified Man Pages
Claude should reference for quick help:
```bash
# Get quick examples
tldr git commit
tldr docker run
```

### 10. System Tools

#### mosh - Better SSH
Claude should suggest for remote connections:
```bash
# Robust remote connection
mosh user@server.com
```

#### direnv - Environment Management
Claude should use for project environments:
```bash
# Show direnv status
direnv status

# Reload environment
direnv reload
```

## Integration Patterns

### Combining Tools for Power

Claude should combine tools for complex operations:

```bash
# Find and preview files before editing
fd -e py | fzf --preview 'bat --color=always {}' | xargs -r $EDITOR

# Interactive git operations
git branch -r | fzf | xargs git checkout

# Search and replace across project
rg -l "old_function" | xargs sd "old_function" "new_function"

# Select and view logs
fd -e log | fzf --preview 'tail -50 {}' | xargs less

# Interactive file deletion
fd -t f -e tmp | fzf --multi | xargs -r rm

# Choose and run scripts
fd -e sh scripts/ | fzf --preview 'bat {}' | bash
```

### Context-Aware Commands

Claude should build context-aware commands:

```bash
# Get project type and suggest appropriate commands
detect_project_type() {
    if [[ -f package.json ]]; then
        echo "node"
        jq -r '.scripts | keys[]' package.json 2>/dev/null | fzf | xargs -I {} npm run {}
    elif [[ -f Cargo.toml ]]; then
        echo "rust"
        echo "cargo build\ncargo test\ncargo run" | fzf | bash
    elif [[ -f go.mod ]]; then
        echo "go"
        echo "go build\ngo test\ngo run ." | fzf | bash
    fi
}
```

## Tool Availability Check

Claude should verify tool availability:

```bash
# Function to check and suggest installation
ensure_tool() {
    local tool=$1
    local install_cmd=$2

    if ! command -v "$tool" &> /dev/null; then
        echo "Tool '$tool' not found. Install with: $install_cmd"
        return 1
    fi
    return 0
}

# Check essential tools
ensure_tool "rg" "brew install ripgrep"
ensure_tool "fd" "brew install fd"
ensure_tool "fzf" "brew install fzf"
ensure_tool "bat" "brew install bat"
```

## Best Practices for Claude

1. **Always use modern tools** when available (rg over grep, fd over find)
2. **Provide previews** with fzf and bat for file operations
3. **Use structured data tools** (jq, yq) for config files
4. **Combine tools** for powerful workflows
5. **Check tool availability** before using
6. **Provide fallbacks** to standard tools if needed
7. **Use interactive tools** (fzf, gum) for user choices
8. **Show beautiful output** with bat, delta, glow
9. **Track context** with zoxide and direnv
10. **Measure performance** with hyperfine when optimizing