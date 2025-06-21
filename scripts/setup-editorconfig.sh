#!/bin/bash
# Smart EditorConfig setup based on project type detection

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_INIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$CLAUDE_INIT_ROOT/templates/editorconfig-variants"

# Project detection
detect_project_type() {
    local project_dir="$1"
    
    # Check for web indicators
    if [[ -f "$project_dir/package.json" ]] || [[ -f "$project_dir/yarn.lock" ]] || [[ -f "$project_dir/pnpm-lock.yaml" ]]; then
        # Check if it's a full-stack project
        if find "$project_dir" -name "*.py" -o -name "*.sh" -o -name "*.go" -o -name "*.rs" | head -1 | grep -q .; then
            echo "fullstack"
        else
            echo "web"
        fi
        return
    fi
    
    # Check for infrastructure indicators
    if [[ -f "$project_dir/Dockerfile" ]] || [[ -f "$project_dir/docker-compose.yml" ]] || 
       [[ -d "$project_dir/scripts" ]] || [[ -f "$project_dir/Makefile" ]]; then
        local has_shell_scripts=false
        if find "$project_dir" -name "*.sh" | head -1 | grep -q .; then
            has_shell_scripts=true
        fi
        
        if [[ "$has_shell_scripts" == "true" ]] || [[ -f "$project_dir/requirements.txt" ]]; then
            echo "infrastructure"
            return
        fi
    fi
    
    # Check for Python projects
    if [[ -f "$project_dir/pyproject.toml" ]] || [[ -f "$project_dir/requirements.txt" ]] || [[ -f "$project_dir/setup.py" ]]; then
        echo "infrastructure"
        return
    fi
    
    # Check for Go projects
    if [[ -f "$project_dir/go.mod" ]]; then
        echo "infrastructure" 
        return
    fi
    
    # Default to fullstack for mixed projects
    echo "fullstack"
}

# Setup EditorConfig
setup_editorconfig() {
    local project_dir="${1:-.}"
    local force_type="${2:-}"
    
    # Resolve absolute path
    project_dir="$(cd "$project_dir" && pwd)"
    
    echo -e "${BLUE}Setting up EditorConfig for project at: $project_dir${NC}"
    
    # Detect or use forced type
    local project_type
    if [[ -n "$force_type" ]]; then
        project_type="$force_type"
        echo -e "${YELLOW}Using forced project type: $project_type${NC}"
    else
        project_type="$(detect_project_type "$project_dir")"
        echo -e "${GREEN}Detected project type: $project_type${NC}"
    fi
    
    # Copy appropriate template
    local template_file="$TEMPLATES_DIR/.editorconfig-$project_type"
    local target_file="$project_dir/.editorconfig"
    
    if [[ ! -f "$template_file" ]]; then
        echo -e "${YELLOW}Warning: Template for '$project_type' not found, using fullstack template${NC}"
        template_file="$TEMPLATES_DIR/.editorconfig-fullstack"
    fi
    
    # Check if EditorConfig already exists
    if [[ -f "$target_file" ]]; then
        echo -e "${YELLOW}EditorConfig already exists. Backing up to .editorconfig.backup${NC}"
        cp "$target_file" "$target_file.backup"
    fi
    
    # Copy template
    cp "$template_file" "$target_file"
    echo -e "${GREEN}✓ EditorConfig configured for $project_type project${NC}"
    
    # Show what was applied
    echo -e "${BLUE}Applied configuration:${NC}"
    echo "  - Project type: $project_type"
    echo "  - Template: $(basename "$template_file")"
    echo "  - Target: $target_file"
}

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [PROJECT_DIR]

Setup appropriate EditorConfig based on project type detection.

Arguments:
    PROJECT_DIR    Project directory (default: current directory)

Options:
    -t, --type TYPE    Force specific project type (web|infrastructure|fullstack)
    -l, --list         List available project types
    -h, --help         Show this help

Examples:
    $(basename "$0")                          # Auto-detect project type in current dir
    $(basename "$0") /path/to/project         # Auto-detect for specific directory
    $(basename "$0") -t infrastructure       # Force infrastructure setup
    $(basename "$0") -t web /path/to/webapp  # Force web setup for specific dir

Project Types:
    web            - Frontend/web projects (2-space default)
    infrastructure - Systems/DevOps projects (4-space shells/Python)
    fullstack      - Mixed projects (language-specific rules)
EOF
}

# Parse arguments
project_dir="."
force_type=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            force_type="$2"
            shift 2
            ;;
        -l|--list)
            echo "Available project types:"
            echo "  web            - Frontend/web projects"
            echo "  infrastructure - Systems/DevOps projects" 
            echo "  fullstack      - Mixed language projects"
            exit 0
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            project_dir="$1"
            shift
            ;;
    esac
done

# Validate force type if provided
if [[ -n "$force_type" ]] && [[ ! "$force_type" =~ ^(web|infrastructure|fullstack)$ ]]; then
    echo "Error: Invalid project type '$force_type'"
    echo "Valid types: web, infrastructure, fullstack"
    exit 1
fi

# Run setup
setup_editorconfig "$project_dir" "$force_type"