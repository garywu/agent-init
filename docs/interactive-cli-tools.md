# Interactive CLI Tools Guide

This guide documents powerful command-line tools that enhance user interaction, search capabilities, and overall CLI experience. These tools can make Claude CLI interactions more intuitive and efficient.

## Interactive Selection Tools

### fzf - Fuzzy Finder

**What it does**: Provides interactive fuzzy searching and selection from any list.

**Installation**:
```bash
# macOS
brew install fzf

# Linux
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Or via package manager
sudo apt-get install fzf  # Debian/Ubuntu
sudo pacman -S fzf       # Arch
```

**Key Use Cases for Claude CLI**:

```bash
# Select files interactively
select_files() {
    fd -t f | fzf --multi --preview 'bat --color=always {}'
}

# Choose git branch
select_branch() {
    git branch -r | grep -v HEAD | sed 's/origin\///' | fzf
}

# Select from history
select_from_history() {
    history | fzf --tac --no-sort | sed 's/^[ ]*[0-9]*[ ]*//'
}

# Interactive project selection
select_project() {
    find ~/projects -maxdepth 2 -name '.git' -type d | \
        sed 's|/.git$||' | \
        fzf --preview 'ls -la {}' \
            --preview-window right:50%
}

# Multi-select with actions
select_and_act() {
    local selected=$(ls | fzf --multi --bind 'ctrl-a:select-all,ctrl-d:deselect-all')
    if [[ -n "$selected" ]]; then
        echo "$selected" | while read -r item; do
            process_item "$item"
        done
    fi
}
```

**Advanced fzf Integration**:
```bash
# Custom preview commands
export FZF_DEFAULT_OPTS="
--layout=reverse
--info=inline
--height=80%
--multi
--preview-window=:hidden
--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-y:execute-silent(echo {} | pbcopy)'
"

# fzf with ripgrep for content search
search_in_files() {
    local initial_query="${1:-}"
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$initial_query'" \
        fzf --bind "change:reload:$RG_PREFIX {q} || true" \
            --ansi --phony --query "$initial_query" \
            --preview 'bat --color=always $(echo {} | cut -d: -f1) --highlight-line $(echo {} | cut -d: -f2)'
}
```

### gum - Glamorous CLI Prompts

**What it does**: Beautiful and user-friendly CLI prompts and interactions.

**Installation**:
```bash
# macOS
brew install gum

# Linux
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install gum
```

**Use Cases**:
```bash
# Beautiful selection menus
select_option() {
    gum choose "Create new project" "Open existing" "Configure settings" "Exit"
}

# Styled input
get_project_name() {
    gum input --placeholder "Enter project name..."
}

# Confirmations
confirm_action() {
    gum confirm "Are you sure you want to proceed?" && echo "Proceeding..." || echo "Cancelled"
}

# Multi-select
select_features() {
    gum choose --no-limit \
        "TypeScript" \
        "ESLint" \
        "Prettier" \
        "Jest" \
        "GitHub Actions"
}

# Progress indication
show_progress() {
    gum spin --spinner dot --title "Setting up project..." -- sleep 5
}

# Formatted output
display_result() {
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        'Setup Complete!' 'Your project is ready.'
}
```

## Enhanced Search Tools

### ripgrep (rg) - Fast Pattern Search

**What it does**: Extremely fast searching through files with smart defaults.

**Why it's essential**:
- Respects .gitignore by default
- Automatically skips binary files
- Supports complex patterns
- Much faster than grep

**Use Cases**:
```bash
# Search with context
search_with_context() {
    local pattern="$1"
    rg "$pattern" -C 3 --pretty
}

# Search specific file types
search_code() {
    rg "$1" -t js -t ts -t py
}

# Interactive search and replace
interactive_replace() {
    local search="$1"
    local replace="$2"
    rg "$search" --files-with-matches | \
        fzf --preview "rg --color=always '$search' {}" | \
        xargs -I {} sed -i '' "s/$search/$replace/g" {}
}
```

### fd - Fast File Finder

**What it does**: User-friendly alternative to find with sensible defaults.

**Use Cases**:
```bash
# Find and select files
find_and_edit() {
    fd -e md -e txt | fzf --preview 'bat {}' | xargs -r $EDITOR
}

# Clean build artifacts
clean_artifacts() {
    fd -H '^(node_modules|__pycache__|\.pytest_cache|dist|build)$' -t d | \
        fzf --multi --preview 'tree -C {}' | \
        xargs -r rm -rf
}
```

## Code and File Viewers

### bat - Better Cat

**What it does**: Syntax highlighting and Git integration for file viewing.

**Use Cases**:
```bash
# Preview with syntax highlighting
preview_file() {
    bat --style=numbers,changes --color=always "$1"
}

# Diff viewing
show_diff() {
    git diff --name-only | fzf --preview 'git diff --color=always {}'
}
```

### delta - Better Git Diff

**What it does**: Beautiful, feature-rich git diff viewer.

**Configuration**:
```gitconfig
[core]
    pager = delta

[delta]
    navigate = true
    light = false
    side-by-side = true
    line-numbers = true
    
[interactive]
    diffFilter = delta --color-only
```

## Interactive Git Tools

### lazygit - Terminal UI for Git

**What it does**: Full-featured git GUI in the terminal.

**Why it's useful**:
- Visual branch management
- Interactive rebasing
- Easy conflict resolution
- File staging with hunks

### tig - Text-mode Git Interface

**What it does**: Browse git history and refs interactively.

**Use Cases**:
```bash
# Browse specific file history
tig blame file.txt

# View branch topology
tig --all
```

## JSON/YAML Processing

### jq - JSON Processor

**Essential patterns**:
```bash
# Interactive JSON exploration
explore_json() {
    cat "$1" | jq . | less
}

# Extract and select values
select_json_value() {
    cat data.json | jq -r '.items[].name' | fzf
}
```

### yq - YAML Processor

**Use Cases**:
```bash
# Select from YAML config
select_config_value() {
    yq eval '.services | keys | .[]' docker-compose.yml | fzf
}
```

## Integration Patterns

### Combining Tools for Power

```bash
# Git interactive rebase with preview
interactive_rebase() {
    local commit=$(git log --oneline | fzf --preview 'git show --color=always {1}' | cut -d' ' -f1)
    [[ -n "$commit" ]] && git rebase -i "$commit^"
}

# Find and replace across project
project_replace() {
    local old_text=$(gum input --placeholder "Text to find...")
    local new_text=$(gum input --placeholder "Replace with...")
    
    rg -l "$old_text" | \
        fzf --multi --preview "rg --color=always '$old_text' {}" | \
        xargs -I {} sd "$old_text" "$new_text" {}
}

# Interactive docker management
docker_exec() {
    local container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --header-lines=1 | awk '{print $1}')
    [[ -n "$container" ]] && docker exec -it "$container" /bin/bash
}

# Project template selection
create_from_template() {
    local template=$(ls ~/.templates | gum choose)
    local name=$(gum input --placeholder "Project name...")
    
    cp -r ~/.templates/"$template" "./$name"
    cd "$name" && git init
}
```

### Tool Detection and Graceful Degradation

```bash
# Wrapper functions that fall back gracefully
safe_select() {
    if command -v fzf > /dev/null; then
        fzf "$@"
    elif command -v gum > /dev/null; then
        gum choose $(cat)
    else
        select item in $(cat); do
            echo "$item"
            break
        done
    fi
}

safe_preview() {
    local file="$1"
    if command -v bat > /dev/null; then
        bat --color=always "$file"
    elif command -v highlight > /dev/null; then
        highlight -O ansi "$file"
    else
        cat "$file"
    fi
}

safe_search() {
    local pattern="$1"
    if command -v rg > /dev/null; then
        rg "$pattern"
    elif command -v ag > /dev/null; then
        ag "$pattern"
    else
        grep -r "$pattern" .
    fi
}
```

## Installation Script

```bash
# Install interactive CLI tools
install_cli_tools() {
    echo "Installing interactive CLI tools..."
    
    local tools=(
        "fzf:junegunn/fzf"
        "bat:sharkdp/bat"
        "fd:sharkdp/fd"
        "ripgrep:BurntSushi/ripgrep"
        "delta:dandavison/delta"
        "gum:charmbracelet/gum"
        "sd:chmln/sd"
        "jq:stedolan/jq"
        "yq:mikefarah/yq"
        "lazygit:jesseduffield/lazygit"
        "tig:jonas/tig"
    )
    
    for tool_info in "${tools[@]}"; do
        IFS=: read -r tool repo <<< "$tool_info"
        
        if ! command -v "$tool" > /dev/null; then
            echo "Installing $tool..."
            
            case "$OS" in
                macos)
                    brew install "$tool"
                    ;;
                linux)
                    # Try various methods
                    if command -v apt-get > /dev/null; then
                        sudo apt-get install -y "$tool" 2>/dev/null || install_from_source "$tool" "$repo"
                    else
                        install_from_source "$tool" "$repo"
                    fi
                    ;;
            esac
        else
            echo "✓ $tool already installed"
        fi
    done
}
```

## Configuration Files

### ~/.config/fzf/config
```bash
# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Preview options
export FZF_CTRL_T_OPTS="
--preview 'bat --color=always --style=numbers --line-range=:500 {}'
--bind 'ctrl-/:change-preview-window(down|hidden|)'"

export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
```

## Additional Powerful Tools

### borgbackup - Deduplicating Backup

**What it does**: Creates space-efficient backups with deduplication, encryption, and compression.

**Use Cases**:
```bash
# Initialize backup repository
borg init --encryption=repokey ~/backups/myproject

# Create backup with progress
backup_project() {
    borg create --progress --stats \
        ~/backups/myproject::{hostname}-{now} \
        ~/projects/myproject \
        --exclude '*/node_modules' \
        --exclude '*/__pycache__' \
        --exclude '*/target'
}

# Interactive restore
restore_file() {
    local archive=$(borg list ~/backups/myproject | fzf | cut -d' ' -f1)
    local file=$(borg list --short "~/backups/myproject::$archive" | fzf)
    borg extract "~/backups/myproject::$archive" "$file"
}
```

### fswatch - File System Monitor

**What it does**: Monitors file system changes and triggers actions.

**Use Cases**:
```bash
# Auto-run tests on file change
fswatch -o src/ tests/ | xargs -n1 -I{} npm test

# Live reload development
fswatch_and_reload() {
    fswatch -o . -e ".*" -i "\\.js$" -i "\\.css$" | \
        xargs -n1 -I{} browser-sync reload
}

# Sync changes to remote
auto_sync() {
    fswatch -0 . | while read -d "" event; do
        rsync -avz --exclude='.git' . remote:/path/to/project/
    done
}
```

## Benefits for Claude CLI

1. **Better User Experience**: Interactive selections instead of typing full paths
2. **Error Prevention**: Visual confirmation before actions
3. **Efficiency**: Fuzzy search saves time finding files/options
4. **Discovery**: Preview capabilities help users understand options
5. **Power Features**: Complex operations become simple
6. **Cross-platform**: Most tools work on macOS, Linux, and WSL
7. **Backup Integration**: Automated backups with borgbackup
8. **File Watching**: Automated workflows with fswatch

These tools transform CLI interactions from memorizing commands to intuitive selection and exploration.