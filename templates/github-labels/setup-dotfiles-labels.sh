#!/usr/bin/env bash
# Setup GitHub labels specifically for dotfiles projects
# Includes base labels + platform + shell + tool labels

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# First, run the platform setup (which includes base)
echo "Setting up base and platform labels..."
"${SCRIPT_DIR}/setup-with-platforms.sh"

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

print_status() { echo -e "${GREEN}==>${NC} $1"; }

echo ""
print_status "Adding dotfiles-specific labels..."

# Shell-specific labels
declare -a SHELL_LABELS=(
  "shell-bash|Bash shell related|89E051"
  "shell-zsh|Zsh shell related|F15A24"
  "shell-fish|Fish shell related|4AAE46"
  "shell-powershell|PowerShell related|012456"
  "shell-nushell|Nushell related|4E9A06"
)

# Package manager labels
declare -a TOOL_LABELS=(
  "tool-nix|Nix package manager related|5277C3"
  "tool-homebrew|Homebrew package manager related|FBB040"
  "tool-chezmoi|Chezmoi dotfiles manager related|1793D1"
  "tool-scoop|Scoop package manager related|59B3D1"
  "tool-apt|APT package manager related|A80030"
  "tool-chocolatey|Chocolatey package manager|80B5E3"
)

# Dotfiles-specific categories
declare -a DOTFILES_LABELS=(
  "config-git|Git configuration|F05032"
  "config-vim|Vim/Neovim configuration|019733"
  "config-terminal|Terminal configuration|4D4D4D"
  "config-ssh|SSH configuration|231F20"
  "bootstrap|Bootstrap script related|5319E7"
  "symlinks|Symlink management|0E8A16"
)

# Create all additional labels
for label_data in "${SHELL_LABELS[@]}" "${TOOL_LABELS[@]}" "${DOTFILES_LABELS[@]}"; do
  IFS='|' read -r name description color <<<"$label_data"

  if gh label create "$name" --description "$description" --color "$color" --force 2>/dev/null; then
    print_status "Added label: $name"
  fi
done

print_status "Dotfiles labels setup complete!"
echo ""
echo "Your repository now has a comprehensive label system for dotfiles management."
