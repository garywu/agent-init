#!/usr/bin/env bash
# Setup Analyzer - Repository Structure Analysis and Intelligent Setup
# Part of claude-init enhancement for intelligent template selection and setup

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-.}"
CLAUDE_INIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERBOSE="${VERBOSE:-false}"
DRY_RUN="${DRY_RUN:-false}"

# Analysis results
declare -A ANALYSIS=()
declare -a RECOMMENDED_TEMPLATES=()
declare -a SETUP_ACTIONS=()
declare -a REQUIRED_FILES=()

# Utility functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_action() {
  if [[  "$DRY_RUN" == "true"  ]]; then
    echo -e "${CYAN}[DRY RUN]${NC} Would: $1"
  else
    echo -e "${PURPLE}[ACTION]${NC} $1"
  fi
}

# Check if file exists
file_exists() {
  [[  -f "$PROJECT_ROOT/$1"  ]]
}

# Check if directory exists
dir_exists() {
  [[  -d "$PROJECT_ROOT/$1"  ]]
}

# Copy file from templates with substitution
copy_template() {
  local template_file="$1"
  local target_file="$2"
  local template_path="$CLAUDE_INIT_ROOT/templates/$template_file"
  local target_path="$PROJECT_ROOT/$target_file"

  if [[  ! -f "$template_path"  ]]; then
    log_error "Template not found: $template_path"
    return 1
  fi

  if file_exists "$target_file" && [[  "$DRY_RUN" != "true"  ]]; then
    log_warning "File already exists: $target_file (skipping)"
    return 0
  fi

  log_action "Copy template $template_file → $target_file"

  if [[  "$DRY_RUN" != "true"  ]]; then
    # Create target directory if needed
    local target_dir=$(dirname "$target_path")
    mkdir -p "$target_dir"

    # Copy template with basic substitutions
    local project_name=$(basename "$PROJECT_ROOT")
    sed -e "s/\[PROJECT_NAME\]/$project_name/g" \
      -e "s/\[DATE\]/$(date +%Y-%m-%d)/g" \
      -e "s/\[TIMESTAMP\]/$(date -u +%Y-%m-%dT%H:%M:%SZ)/g" \
      "$template_path" >"$target_path"
  fi
}

# Run project detection and get analysis
run_project_detection() {
  log_info "Running project detection analysis..."

  local detector_script="$SCRIPT_DIR/project-detector.sh"
  if [[  ! -f "$detector_script"  ]]; then
    log_error "Project detector script not found: $detector_script"
    return 1
  fi

  # Run project detector and capture JSON output
  local analysis_json
  analysis_json=$("$detector_script" "$PROJECT_ROOT" "json" 2>/dev/null)

  if [[  $? -ne 0 || -z "$analysis_json"  ]]; then
    log_error "Failed to run project detection"
    return 1
  fi

  # Parse JSON results (basic parsing since we control the format)
  while IFS=': ' read -r key value; do
    # Remove quotes and whitespace
    key=$(echo "$key" | tr -d '"' | xargs)
    value=$(echo "$value" | tr -d '",' | xargs)
    if [[  -n "$key" && -n "$value"  ]]; then
      ANALYSIS["$key"]="$value"
    fi
  done <<<"$analysis_json"

  log_success "Project analysis completed"
}

# Determine recommended templates based on analysis
determine_templates() {
  log_info "Determining recommended templates..."

  local project_type="${ANALYSIS[project_type]:-unknown}"
  local frameworks="${ANALYSIS[frameworks]:-}"
  local primary_language="${ANALYSIS[primary_language]:-}"

  # Core CLAUDE.md template (always recommended)
  RECOMMENDED_TEMPLATES+=("CLAUDE.md")

  # Project-type specific templates
  case "$project_type" in
  "web-app")
    RECOMMENDED_TEMPLATES+=("CLAUDE-web-app.md")
    if [[  "$frameworks" == *"react"*  ]] || [[  "$frameworks" == *"nextjs"*  ]]; then
      REQUIRED_FILES+=("package.json")
      SETUP_ACTIONS+=("setup_frontend_development")
    fi
    ;;
  "api")
    RECOMMENDED_TEMPLATES+=("CLAUDE-api.md")
    SETUP_ACTIONS+=("setup_api_development")
    ;;
  "library")
    SETUP_ACTIONS+=("setup_library_development")
    ;;
  "cli")
    SETUP_ACTIONS+=("setup_cli_development")
    ;;
  "documentation")
    SETUP_ACTIONS+=("setup_documentation_site")
    ;;
  esac

  # Language-specific additions
  case "$primary_language" in
  "typescript" | "javascript")
    REQUIRED_FILES+=("package.json" ".gitignore")
    SETUP_ACTIONS+=("setup_javascript_tooling")
    ;;
  "python")
    REQUIRED_FILES+=("requirements.txt" ".gitignore")
    SETUP_ACTIONS+=("setup_python_tooling")
    ;;
  "go")
    REQUIRED_FILES+=("go.mod" ".gitignore")
    SETUP_ACTIONS+=("setup_go_tooling")
    ;;
  "rust")
    REQUIRED_FILES+=("Cargo.toml" ".gitignore")
    SETUP_ACTIONS+=("setup_rust_tooling")
    ;;
  esac

  # Universal recommendations
  REQUIRED_FILES+=("README.md" "CONTRIBUTING.md" "Makefile")

  # Check maturity and add professional development files
  local maturity_score="${ANALYSIS[maturity_score]:-0}"
  if [[  $maturity_score -lt 80  ]]; then
    REQUIRED_FILES+=("CODE_OF_CONDUCT.md" "SECURITY.md")
    SETUP_ACTIONS+=("setup_professional_standards")
  fi

  log_success "Template recommendations determined"
}

# Setup functions for different project types
setup_frontend_development() {
  log_info "Setting up frontend development environment..."

  # Add frontend-specific files
  REQUIRED_FILES+=("tsconfig.json" "vite.config.ts" ".env.example")

  # Check if package.json needs updating
  if file_exists "package.json"; then
    log_action "Package.json exists, checking for required scripts"
    # TODO: Add script validation logic
  else
    log_action "Create package.json for frontend project"
  fi
}

setup_api_development() {
  log_info "Setting up API development environment..."

  # Add API-specific files
  REQUIRED_FILES+=("tsconfig.json" ".env.example" "jest.config.js")

  log_action "Configure API development tools"
}

setup_library_development() {
  log_info "Setting up library development environment..."

  # Add library-specific files
  REQUIRED_FILES+=("tsconfig.json" "jest.config.js")

  log_action "Configure library build and distribution tools"
}

setup_cli_development() {
  log_info "Setting up CLI development environment..."

  # Add CLI-specific files
  REQUIRED_FILES+=("tsconfig.json" "jest.config.js")

  log_action "Configure CLI development and distribution tools"
}

setup_documentation_site() {
  log_info "Setting up documentation site..."

  # Check if Astro/Starlight is already configured
  if dir_exists "docs" && file_exists "docs/astro.config.mjs"; then
    log_action "Astro documentation site detected, enhancing configuration"
  else
    log_action "Set up new documentation site structure"
    REQUIRED_FILES+=("docs/astro.config.mjs" "docs/package.json")
  fi
}

setup_javascript_tooling() {
  log_info "Setting up JavaScript/TypeScript tooling..."

  REQUIRED_FILES+=("eslint.config.js" "prettier.config.js")
  log_action "Configure ESLint and Prettier"
}

setup_python_tooling() {
  log_info "Setting up Python tooling..."

  REQUIRED_FILES+=("pyproject.toml" ".flake8" "mypy.ini")
  log_action "Configure Python linting and type checking"
}

setup_go_tooling() {
  log_info "Setting up Go tooling..."

  log_action "Configure Go module and tools"
}

setup_rust_tooling() {
  log_info "Setting up Rust tooling..."

  REQUIRED_FILES+=("rustfmt.toml" "clippy.toml")
  log_action "Configure Rust formatting and linting"
}

setup_professional_standards() {
  log_info "Setting up professional development standards..."

  REQUIRED_FILES+=(".github/ISSUE_TEMPLATE/bug_report.md"
    ".github/ISSUE_TEMPLATE/feature_request.md"
    ".github/workflows/ci.yml"
    ".pre-commit-config.yaml")

  log_action "Configure GitHub templates and CI/CD"
}

# Execute setup actions
execute_setup_actions() {
  log_info "Executing setup actions..."

  for action in "${SETUP_ACTIONS[@]}"; do
    if declare -f "$action" >/dev/null; then
      "$action"
    else
      log_warning "Setup action not implemented: $action"
    fi
  done
}

# Copy required templates and files
copy_required_files() {
  log_info "Copying required templates and files..."

  # Copy recommended templates
  for template in "${RECOMMENDED_TEMPLATES[@]}"; do
    copy_template "$template" "$template"
  done

  # Copy other required files
  for file in "${REQUIRED_FILES[@]}"; do
    # Check if template exists for this file
    local template_file="$file"
    local template_path="$CLAUDE_INIT_ROOT/templates/$template_file"

    if [[  -f "$template_path"  ]]; then
      copy_template "$template_file" "$file"
    else
      log_warning "No template found for required file: $file"
    fi
  done
}

# Generate analysis report
generate_analysis_report() {
  log_info "Generating analysis report..."

  local report_file="$PROJECT_ROOT/.claude-init-analysis.md"

  if [[  "$DRY_RUN" == "true"  ]]; then
    log_action "Would generate analysis report: $report_file"
    return 0
  fi

  cat >"$report_file" <<EOF
# Claude-Init Setup Analysis Report

**Generated**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Project**: $(basename "$PROJECT_ROOT")
**Analysis Version**: 1.0

## Project Analysis Results

- **Type**: ${ANALYSIS[project_type]:-unknown}
- **Primary Language**: ${ANALYSIS[primary_language]:-unknown}
- **Frameworks**: ${ANALYSIS[frameworks]:-none detected}
- **Package Managers**: ${ANALYSIS[package_managers]:-none detected}
- **Maturity Score**: ${ANALYSIS[maturity_score]:-0}/100
- **Confidence**: ${ANALYSIS[confidence]:-low}

## Recommended Templates

$(printf '- %s\n' "${RECOMMENDED_TEMPLATES[@]}")

## Setup Actions Performed

$(printf '- %s\n' "${SETUP_ACTIONS[@]}")

## Required Files

$(printf '- %s\n' "${REQUIRED_FILES[@]}")

## Next Steps

1. Review and customize the copied templates
2. Update project-specific information in CLAUDE.md
3. Configure development tools according to your preferences
4. Set up CI/CD workflows if needed
5. Initialize Git repository if not already done

## Manual Customization Needed

- Update project description and goals in README.md
- Configure specific dependencies in package.json/requirements.txt
- Set up environment variables in .env.example
- Customize linting and formatting rules
- Add project-specific documentation

---

*This report was generated by claude-init setup analyzer. You can safely delete this file after review.*
EOF

  log_success "Analysis report generated: $report_file"
}

# Interactive confirmation for actions
confirm_actions() {
  if [[  "$DRY_RUN" == "true"  ]]; then
    return 0
  fi

  echo ""
  echo -e "${CYAN}📋 SETUP ANALYSIS SUMMARY${NC}"
  echo "================================"
  echo ""
  echo -e "${PURPLE}Project Type:${NC} ${ANALYSIS[project_type]:-unknown}"
  echo -e "${PURPLE}Primary Language:${NC} ${ANALYSIS[primary_language]:-unknown}"
  echo -e "${PURPLE}Frameworks:${NC} ${ANALYSIS[frameworks]:-none detected}"
  echo ""
  echo -e "${BLUE}Recommended Templates:${NC}"
  printf '  • %s\n' "${RECOMMENDED_TEMPLATES[@]}"
  echo ""
  echo -e "${BLUE}Setup Actions:${NC}"
  printf '  • %s\n' "${SETUP_ACTIONS[@]}"
  echo ""
  echo -e "${BLUE}Required Files:${NC}"
  printf '  • %s\n' "${REQUIRED_FILES[@]}"
  echo ""

  read -p "Proceed with setup? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Setup cancelled by user"
    exit 0
  fi
}

# Main execution
main() {
  echo -e "${CYAN}🔧 CLAUDE-INIT SETUP ANALYZER${NC}"
  echo "================================"
  echo ""

  log_info "Analyzing project: $PROJECT_ROOT"

  # Change to project directory
  if ! cd "$PROJECT_ROOT" 2>/dev/null; then
    log_error "Cannot access directory: $PROJECT_ROOT"
    exit 1
  fi

  # Run analysis steps
  run_project_detection
  determine_templates
  execute_setup_actions

  # Show summary and get confirmation
  confirm_actions

  # Execute the setup
  copy_required_files
  generate_analysis_report

  echo ""
  log_success "Claude-init setup analysis completed!"
  echo ""
  echo -e "${GREEN}🚀 Next Steps:${NC}"
  echo "  1. Review the generated templates and customize as needed"
  echo "  2. Check .claude-init-analysis.md for detailed analysis"
  echo "  3. Initialize your development workflow"
  echo "  4. Start using Claude with the enhanced CLAUDE.md template"
  echo ""
}

# Script usage
usage() {
  echo "Usage: $0 [PROJECT_PATH]"
  echo ""
  echo "PROJECT_PATH: Path to project directory (default: current directory)"
  echo ""
  echo "Environment variables:"
  echo "  VERBOSE=true    Enable verbose logging"
  echo "  DRY_RUN=true    Show what would be done without making changes"
  echo ""
  echo "Examples:"
  echo "  $0                          # Analyze and setup current directory"
  echo "  $0 /path/to/project         # Analyze and setup specific project"
  echo "  DRY_RUN=true $0 .           # Preview what would be done"
  echo "  VERBOSE=true $0 .           # Run with verbose logging"
}

# Handle command line arguments
if [[  "${1:-}" == "--help" || "${1:-}" == "-h"  ]]; then
  usage
  exit 0
fi

# Validate claude-init root
if [[  ! -f "$CLAUDE_INIT_ROOT/templates/CLAUDE.md"  ]]; then
  log_error "Claude-init templates not found. Please run from claude-init directory or check installation."
  exit 1
fi

# Run main function
main "$@"
