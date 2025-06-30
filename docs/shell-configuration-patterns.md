# Shell Configuration Patterns

Comprehensive patterns for configuring shells (Bash, Zsh, Fish) with productivity enhancements, cross-platform compatibility, and modern tooling.

## Shell-Agnostic Patterns

### 1. XDG Base Directory Structure

```bash
# Respect XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Application-specific
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/bash/history"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
```

### 2. Universal Aliases

```bash
# Core aliases that work across shells
alias_file="$XDG_CONFIG_HOME/shell/aliases"

cat > "$alias_file" << 'EOF'
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# Enhanced commands
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Modern replacements (if available)
command -v eza &>/dev/null && alias ls='eza'
command -v bat &>/dev/null && alias cat='bat'
command -v fd &>/dev/null && alias find='fd'
command -v rg &>/dev/null && alias grep='rg'

# Shortcuts
alias g='git'
alias d='docker'
alias k='kubectl'
alias tf='terraform'

# System info
alias ports='netstat -tulanp'
alias myip='curl -s https://api.ipify.org && echo'

# Development
alias serve='python -m http.server'
alias json='python -m json.tool'
alias timestamp='date +%Y%m%d_%H%M%S'
EOF
```

### 3. Environment Management

```bash
# Universal environment setup
setup_environment() {
    # Path management
    path_prepend() {
        case ":$PATH:" in
            *":$1:"*) ;;
            *) export PATH="$1:$PATH" ;;
        esac
    }

    path_append() {
        case ":$PATH:" in
            *":$1:"*) ;;
            *) export PATH="$PATH:$1" ;;
        esac
    }

    # Add common paths
    path_prepend "$HOME/.local/bin"
    path_prepend "$HOME/bin"
    path_prepend "/usr/local/bin"

    # Language-specific paths
    [[ -d "$HOME/.cargo/bin" ]] && path_prepend "$HOME/.cargo/bin"
    [[ -d "$HOME/.npm-global/bin" ]] && path_prepend "$HOME/.npm-global/bin"
    [[ -d "$HOME/go/bin" ]] && path_prepend "$HOME/go/bin"

    # Tool-specific
    command -v brew &>/dev/null && eval "$(brew shellenv)"
    command -v direnv &>/dev/null && eval "$(direnv hook $SHELL)"
    command -v zoxide &>/dev/null && eval "$(zoxide init $SHELL)"
    command -v starship &>/dev/null && eval "$(starship init $SHELL)"
}
```

## Bash-Specific Configuration

### 1. Enhanced .bashrc

```bash
# ~/.bashrc or ~/.config/bash/bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History configuration
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%F %T "

# Append to history, don't overwrite
shopt -s histappend

# Save multi-line commands as single entry
shopt -s cmdhist

# Update LINES and COLUMNS after each command
shopt -s checkwinsize

# Enable extended globbing
shopt -s extglob

# Case-insensitive globbing
shopt -s nocaseglob

# Autocorrect typos in path names
shopt -s cdspell

# Enable programmable completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Custom prompt with git info
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

PS1='\[\e[32m\]\u@\h\[\e[m\]:\[\e[34m\]\w\[\e[m\]\[\e[33m\]$(parse_git_branch)\[\e[m\]\$ '

# Load common configuration
[[ -f "$XDG_CONFIG_HOME/shell/aliases" ]] && source "$XDG_CONFIG_HOME/shell/aliases"
[[ -f "$XDG_CONFIG_HOME/shell/functions" ]] && source "$XDG_CONFIG_HOME/shell/functions"
```

### 2. Bash Functions

```bash
# ~/.config/shell/functions

# Extract archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Backup file with timestamp
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Find and replace in files
find_replace() {
    local find="$1"
    local replace="$2"
    local files="${3:-*}"

    if command -v rg &>/dev/null && command -v sd &>/dev/null; then
        rg -l "$find" $files | xargs sd "$find" "$replace"
    else
        find . -name "$files" -type f -exec sed -i '' "s/$find/$replace/g" {} +
    fi
}
```

## Zsh-Specific Configuration

### 1. Modular .zshrc

```bash
# ~/.config/zsh/.zshrc

# Zsh options
setopt EXTENDED_HISTORY          # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_SPACE         # Don't record commands starting with space
setopt HIST_VERIFY               # Show command with history expansion
setopt SHARE_HISTORY             # Share history between sessions
setopt APPEND_HISTORY            # Append to history file

# Completion system
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

# Completion options
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'

# Key bindings
bindkey -e  # Emacs mode
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Load modules
for config in "$ZDOTDIR"/configs/*.zsh; do
    source "$config"
done

# Plugin management with zinit
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
```

### 2. Zsh Productivity Features

```bash
# ~/.config/zsh/configs/productivity.zsh

# Directory navigation
setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # Push directories to stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_SILENT         # Don't print directory stack

# Global aliases
alias -g L='| less'
alias -g G='| grep'
alias -g H='| head'
alias -g T='| tail'
alias -g NE='2> /dev/null'
alias -g NUL='> /dev/null 2>&1'

# Suffix aliases
alias -s {md,markdown}=glow
alias -s {json,jsonl}=jq
alias -s {yaml,yml}=yq
alias -s {py,rb,js,ts,go,rs}=$EDITOR

# Directory hashes
hash -d config=$XDG_CONFIG_HOME
hash -d cache=$XDG_CACHE_HOME
hash -d data=$XDG_DATA_HOME
hash -d projects=~/Projects
```

## Fish-Specific Configuration

### 1. Fish Configuration

```fish
# ~/.config/fish/config.fish

# Disable greeting
set -g fish_greeting

# Environment variables
set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx PAGER less

# XDG directories
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state
set -gx XDG_CACHE_HOME $HOME/.cache

# Path management
fish_add_path $HOME/.local/bin
fish_add_path $HOME/bin
fish_add_path /usr/local/bin

# Abbreviations (better than aliases in fish)
abbr -a g git
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gco 'git checkout'
abbr -a gd 'git diff'
abbr -a gl 'git log'
abbr -a gp 'git push'
abbr -a gs 'git status'

# Functions autoload from ~/.config/fish/functions/

# Load integrations
if command -q starship
    starship init fish | source
end

if command -q zoxide
    zoxide init fish | source
end

if command -q direnv
    direnv hook fish | source
end
```

### 2. Fish Functions

```fish
# ~/.config/fish/functions/mkcd.fish
function mkcd -d "Create directory and enter it"
    mkdir -p $argv[1] && cd $argv[1]
end

# ~/.config/fish/functions/backup.fish
function backup -d "Backup file with timestamp"
    cp $argv[1] "$argv[1].backup."(date +%Y%m%d_%H%M%S)
end

# ~/.config/fish/functions/fish_user_key_bindings.fish
function fish_user_key_bindings
    # Ctrl+R for history search
    bind \cr 'commandline -f history-search-backward'

    # Ctrl+F for file search with fzf
    bind \cf 'fzf | read -l result; and commandline -a $result'

    # Alt+C for cd with fzf
    bind \ec '__fzf_cd'
end
```

## Cross-Shell Integration

### 1. Starship Prompt Configuration

```toml
# ~/.config/starship.toml

# Minimal prompt with maximum information
format = """
[┌─$username@$hostname](bold green) in $directory$git_branch$git_status
[└─$character](bold green) """

[username]
style_user = "bold green"
style_root = "bold red"
format = "[$user]($style)"
disabled = false
show_always = true

[hostname]
ssh_only = false
format = "[$hostname]($style)"
style = "bold green"

[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold blue"

[git_branch]
format = " on [$symbol$branch]($style)"
style = "bold purple"

[git_status]
format = "([\\[$all_status$ahead_behind\\]]($style))"
style = "bold red"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

[cmd_duration]
min_time = 500
format = " took [$duration]($style)"

[jobs]
format = "[$symbol$number]($style) "
style = "bold blue"
symbol = "✦ "

[battery]
full_symbol = "🔋"
charging_symbol = "⚡️"
discharging_symbol = "💀"

[[battery.display]]
threshold = 20
style = "bold red"
```

### 2. Direnv Configuration

```bash
# ~/.config/direnv/direnvrc

# Python virtual environment
layout_python() {
    local python=${1:-python3}
    [[ $# -gt 0 ]] && shift
    local old_env=$(direnv_layout_dir)/virtualenv
    unset PYTHONHOME
    if [[ -d $old_env ]]; then
        VIRTUAL_ENV=$old_env
    else
        VIRTUAL_ENV=$(direnv_layout_dir)/python-$python_version
        $python -m venv "$@" "$VIRTUAL_ENV"
    fi
    export VIRTUAL_ENV
    PATH_add "$VIRTUAL_ENV/bin"
}

# Node.js version management
use_node() {
    local version=${1:-$(cat .nvmrc 2>/dev/null)}
    local node_path=$(find_up .node-version)

    if [[ -z $version ]] && [[ -n $node_path ]]; then
        version=$(cat "$node_path")
    fi

    if [[ -n $version ]]; then
        local node_dir=$HOME/.nvm/versions/node/v$version
        if [[ -d $node_dir ]]; then
            PATH_add "$node_dir/bin"
            export NODE_PATH="$node_dir/lib/node_modules"
        fi
    fi
}

# Ruby version management
use_ruby() {
    local version=${1:-$(cat .ruby-version 2>/dev/null)}
    if [[ -n $version ]]; then
        local ruby_dir=$HOME/.rbenv/versions/$version
        if [[ -d $ruby_dir ]]; then
            PATH_add "$ruby_dir/bin"
            export GEM_HOME="$ruby_dir"
        fi
    fi
}
```

### 3. Universal Tool Integration

```bash
# ~/.config/shell/integrations.sh
# Source from any shell

# FZF configuration
if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_DEFAULT_OPTS="
        --height 40%
        --layout=reverse
        --border
        --preview 'bat --style=numbers --color=always --line-range :500 {}'
        --bind 'ctrl-/:toggle-preview'
    "

    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Zoxide configuration
if command -v zoxide &>/dev/null; then
    export _ZO_ECHO=1
    export _ZO_RESOLVE_SYMLINKS=1
fi

# Bat configuration
if command -v bat &>/dev/null; then
    export BAT_THEME="OneHalfDark"
    export BAT_STYLE="numbers,changes,header"
fi

# Ripgrep configuration
if command -v rg &>/dev/null; then
    export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
fi
```

## Best Practices

1. **Modular Configuration**
   - Split configuration into logical modules
   - Use XDG directories for organization
   - Keep shell-specific and universal configs separate

2. **Performance**
   - Lazy load heavy configurations
   - Use command existence checks
   - Profile shell startup time

3. **Portability**
   - Test for command availability
   - Provide fallbacks for missing tools
   - Use POSIX-compliant scripts where possible

4. **Version Control**
   - Track configurations in git
   - Use symbolic links or a dotfile manager
   - Document custom configurations

## External References

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Zsh Documentation](http://zsh.sourceforge.net/Doc/)
- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)