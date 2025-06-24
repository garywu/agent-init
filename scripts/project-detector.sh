#!/usr/bin/env bash
# Project Detection Script - Intelligent Project Analysis
# Part of claude-init enhancement for intelligent template selection

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
PROJECT_ROOT="${1:-.}"
OUTPUT_FORMAT="${2:-human}" # human, json, yaml
VERBOSE="${VERBOSE:-false}"

# Analysis results - Initialize associative array properly
declare -A PROJECT_ANALYSIS=()

# Initialize default values
PROJECT_ANALYSIS[primary_language]=""
PROJECT_ANALYSIS[languages]=""
PROJECT_ANALYSIS[total_source_files]="0"
PROJECT_ANALYSIS[package_managers]=""
PROJECT_ANALYSIS[build_tools]=""
PROJECT_ANALYSIS[frameworks]=""
PROJECT_ANALYSIS[project_type]="unknown"
PROJECT_ANALYSIS[confidence]="low"
PROJECT_ANALYSIS[module_type]=""
PROJECT_ANALYSIS[is_git_repo]="false"
PROJECT_ANALYSIS[commit_count]="0"
PROJECT_ANALYSIS[current_branch]=""
PROJECT_ANALYSIS[has_uncommitted_changes]="false"
PROJECT_ANALYSIS[has_remote]="false"
PROJECT_ANALYSIS[remote_url]=""
PROJECT_ANALYSIS[total_files]="0"
PROJECT_ANALYSIS[total_directories]="0"
PROJECT_ANALYSIS[project_files]=""
PROJECT_ANALYSIS[maturity_score]="0"
PROJECT_ANALYSIS[recommendations]=""

# Utility functions
log_info() {
  if [[  "$VERBOSE" == "true" || "$OUTPUT_FORMAT" == "human"  ]]; then
    echo -e "${BLUE}[INFO]${NC} $1" >&2
  fi
}

log_success() {
  if [[  "$OUTPUT_FORMAT" == "human"  ]]; then
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
  fi
}

log_warning() {
  if [[  "$OUTPUT_FORMAT" == "human"  ]]; then
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
  fi
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if file exists in project
file_exists() {
  [[  -f "$PROJECT_ROOT/$1"  ]]
}

# Check if directory exists in project
dir_exists() {
  [[  -d "$PROJECT_ROOT/$1"  ]]
}

# Count files matching pattern
count_files() {
  local pattern="$1"
  find "$PROJECT_ROOT" -name "$pattern" -type f 2>/dev/null | wc -l | tr -d ' '
}

# Get file content safely
get_file_content() {
  local file="$1"
  if file_exists "$file"; then
    cat "$PROJECT_ROOT/$file" 2>/dev/null || echo ""
  else
    echo ""
  fi
}

# Detect programming languages
detect_languages() {
  log_info "Detecting programming languages..."

  local -A lang_counts
  local -a detected_languages

  # Count files by extension
  lang_counts[javascript]=$(count_files "*.js")
  lang_counts[typescript]=$(count_files "*.ts")
  lang_counts[typescript_jsx]=$(count_files "*.tsx")
  lang_counts[python]=$(count_files "*.py")
  lang_counts[go]=$(count_files "*.go")
  lang_counts[rust]=$(count_files "*.rs")
  lang_counts[java]=$(count_files "*.java")
  lang_counts[csharp]=$(count_files "*.cs")
  lang_counts[cpp]=$(count_files "*.cpp")
  lang_counts[c]=$(count_files "*.c")
  lang_counts[php]=$(count_files "*.php")
  lang_counts[ruby]=$(count_files "*.rb")
  lang_counts[shell]=$(count_files "*.sh")
  lang_counts[yaml]=$(count_files "*.yml")
  lang_counts[json]=$(count_files "*.json")
  lang_counts[markdown]=$(count_files "*.md")

  # Determine primary and secondary languages
  local primary_lang=""
  local max_count=0

  for lang in "${!lang_counts[@]}"; do
    local count=${lang_counts[$lang]}
    if [[  $count -gt 0  ]]; then
      detected_languages+=("$lang:$count")
      if [[  $count -gt $max_count  ]]; then
        max_count=$count
        primary_lang="$lang"
      fi
    fi
  done

  PROJECT_ANALYSIS[primary_language]="$primary_lang"
  PROJECT_ANALYSIS[languages]=$(
    IFS=','
    echo "${detected_languages[*]}"
  )
  PROJECT_ANALYSIS[total_source_files]=$((${lang_counts[javascript]} + ${lang_counts[typescript]} + ${lang_counts[python]} + ${lang_counts[go]} + ${lang_counts[rust]} + ${lang_counts[java]}))
}

# Detect package managers and build tools
detect_package_managers() {
  log_info "Detecting package managers and build tools..."

  local -a package_managers
  local -a build_tools

  # Package managers
  file_exists "package.json" && package_managers+=("npm")
  file_exists "yarn.lock" && package_managers+=("yarn")
  file_exists "pnpm-lock.yaml" && package_managers+=("pnpm")
  file_exists "requirements.txt" && package_managers+=("pip")
  file_exists "pyproject.toml" && package_managers+=("poetry")
  file_exists "Pipfile" && package_managers+=("pipenv")
  file_exists "go.mod" && package_managers+=("go-modules")
  file_exists "Cargo.toml" && package_managers+=("cargo")
  file_exists "composer.json" && package_managers+=("composer")
  file_exists "Gemfile" && package_managers+=("bundler")

  # Build tools and bundlers
  file_exists "webpack.config.js" && build_tools+=("webpack")
  file_exists "vite.config.js" && build_tools+=("vite")
  file_exists "vite.config.ts" && build_tools+=("vite")
  file_exists "rollup.config.js" && build_tools+=("rollup")
  file_exists "esbuild.config.js" && build_tools+=("esbuild")
  file_exists "parcel.config.js" && build_tools+=("parcel")
  file_exists "turbo.json" && build_tools+=("turborepo")
  file_exists "lerna.json" && build_tools+=("lerna")
  file_exists "nx.json" && build_tools+=("nx")
  file_exists "Makefile" && build_tools+=("make")
  file_exists "Dockerfile" && build_tools+=("docker")
  file_exists "docker-compose.yml" && build_tools+=("docker-compose")

  PROJECT_ANALYSIS[package_managers]=$(
    IFS=','
    echo "${package_managers[*]}"
  )
  PROJECT_ANALYSIS[build_tools]=$(
    IFS=','
    echo "${build_tools[*]}"
  )
}

# Detect frameworks and libraries
detect_frameworks() {
  log_info "Detecting frameworks and libraries..."

  local -a frameworks
  local package_json_content=""

  if file_exists "package.json"; then
    package_json_content=$(get_file_content "package.json")
  fi

  # Frontend frameworks
  if echo "$package_json_content" | grep -q '"react"'; then
    frameworks+=("react")
    file_exists "next.config.js" && frameworks+=("nextjs")
    file_exists "next.config.ts" && frameworks+=("nextjs")
  fi

  if echo "$package_json_content" | grep -q '"vue"'; then
    frameworks+=("vue")
    file_exists "nuxt.config.js" && frameworks+=("nuxtjs")
  fi

  if echo "$package_json_content" | grep -q '"@angular/core"'; then
    frameworks+=("angular")
  fi

  if echo "$package_json_content" | grep -q '"svelte"'; then
    frameworks+=("svelte")
    file_exists "svelte.config.js" && frameworks+=("sveltekit")
  fi

  # Backend frameworks
  if echo "$package_json_content" | grep -q '"express"'; then
    frameworks+=("express")
  fi

  if echo "$package_json_content" | grep -q '"fastify"'; then
    frameworks+=("fastify")
  fi

  if echo "$package_json_content" | grep -q '"@nestjs/core"'; then
    frameworks+=("nestjs")
  fi

  # Python frameworks
  if file_exists "requirements.txt" || file_exists "pyproject.toml"; then
    local py_deps=$(get_file_content "requirements.txt")$(get_file_content "pyproject.toml")
    echo "$py_deps" | grep -q "django" && frameworks+=("django")
    echo "$py_deps" | grep -q "flask" && frameworks+=("flask")
    echo "$py_deps" | grep -q "fastapi" && frameworks+=("fastapi")
    echo "$py_deps" | grep -q "streamlit" && frameworks+=("streamlit")
  fi

  # Static site generators
  file_exists "astro.config.mjs" && frameworks+=("astro")
  file_exists "gatsby-config.js" && frameworks+=("gatsby")
  file_exists "_config.yml" && frameworks+=("jekyll")
  file_exists "hugo.toml" && frameworks+=("hugo")

  PROJECT_ANALYSIS[frameworks]=$(
    IFS=','
    echo "${frameworks[*]}"
  )
}

# Detect project type
detect_project_type() {
  log_info "Determining project type..."

  local project_type="unknown"
  local confidence="low"

  # Check for specific project type indicators
  if file_exists "package.json"; then
    local package_json=$(get_file_content "package.json")

    # Check package.json for type hints
    if echo "$package_json" | grep -q '"type": "module"'; then
      PROJECT_ANALYSIS[module_type]="esm"
    else
      PROJECT_ANALYSIS[module_type]="commonjs"
    fi

    # Mobile app
    if echo "$package_json" | grep -q '"react-native"' || file_exists "metro.config.js"; then
      project_type="mobile-app"
      confidence="high"
    # Next.js app
    elif file_exists "next.config.js" || file_exists "next.config.ts"; then
      project_type="web-app"
      confidence="high"
    # React app
    elif echo "$package_json" | grep -q '"react"' && dir_exists "src"; then
      project_type="web-app"
      confidence="high"
    # Node.js API
    elif echo "$package_json" | grep -q '"express"\|"fastify"\|"@nestjs/core"'; then
      project_type="api"
      confidence="high"
    # CLI tool
    elif echo "$package_json" | grep -q '"bin"'; then
      project_type="cli"
      confidence="high"
    # Library/package
    elif echo "$package_json" | grep -q '"main"\|"exports"' && ! dir_exists "src/pages"; then
      project_type="library"
      confidence="medium"
    # Generic Node.js app
    else
      project_type="web-app"
      confidence="medium"
    fi

  # Python projects
  elif file_exists "requirements.txt" || file_exists "pyproject.toml"; then
    local py_content=$(get_file_content "requirements.txt")$(get_file_content "pyproject.toml")

    if echo "$py_content" | grep -q "django\|flask\|fastapi"; then
      project_type="api"
      confidence="high"
    elif echo "$py_content" | grep -q "streamlit\|dash\|gradio"; then
      project_type="web-app"
      confidence="high"
    elif file_exists "setup.py" || echo "$py_content" | grep -q "build-system"; then
      project_type="library"
      confidence="medium"
    else
      project_type="script"
      confidence="medium"
    fi

  # Go projects
  elif file_exists "go.mod"; then
    if file_exists "main.go"; then
      local main_content=$(get_file_content "main.go")
      if echo "$main_content" | grep -q "http\|gin\|echo\|fiber"; then
        project_type="api"
        confidence="high"
      else
        project_type="cli"
        confidence="medium"
      fi
    else
      project_type="library"
      confidence="medium"
    fi

  # Rust projects
  elif file_exists "Cargo.toml"; then
    local cargo_content=$(get_file_content "Cargo.toml")
    if echo "$cargo_content" | grep -q '\[\[bin\]\]'; then
      project_type="cli"
      confidence="high"
    elif echo "$cargo_content" | grep -q 'crate-type.*"cdylib"'; then
      project_type="library"
      confidence="high"
    else
      project_type="library"
      confidence="medium"
    fi

  # Documentation site
  elif file_exists "_config.yml" || file_exists "astro.config.mjs" || dir_exists "docs"; then
    project_type="documentation"
    confidence="high"

  # Generic repository
  elif file_exists "README.md"; then
    project_type="repository"
    confidence="low"
  fi

  PROJECT_ANALYSIS[project_type]="$project_type"
  PROJECT_ANALYSIS[confidence]="$confidence"
}

# Analyze repository characteristics
analyze_repository() {
  log_info "Analyzing repository characteristics..."

  # Git information
  if dir_exists ".git"; then
    PROJECT_ANALYSIS[is_git_repo]="true"

    # Get commit count
    local commit_count=$(git -C "$PROJECT_ROOT" rev-list --count HEAD 2>/dev/null || echo "0")
    PROJECT_ANALYSIS[commit_count]="$commit_count"

    # Get current branch
    local current_branch=$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo "unknown")
    PROJECT_ANALYSIS[current_branch]="$current_branch"

    # Check for uncommitted changes
    local has_changes="false"
    if [[  -n $(git -C "$PROJECT_ROOT" status --porcelain 2>/dev/null)  ]]; then
      has_changes="true"
    fi
    PROJECT_ANALYSIS[has_uncommitted_changes]="$has_changes"

    # Check for remote
    local has_remote="false"
    if git -C "$PROJECT_ROOT" remote 2>/dev/null | grep -q .; then
      has_remote="true"
      PROJECT_ANALYSIS[remote_url]=$(git -C "$PROJECT_ROOT" remote get-url origin 2>/dev/null || echo "unknown")
    fi
    PROJECT_ANALYSIS[has_remote]="$has_remote"
  else
    PROJECT_ANALYSIS[is_git_repo]="false"
  fi

  # Directory structure analysis
  local total_files=$(find "$PROJECT_ROOT" -type f 2>/dev/null | wc -l | tr -d ' ')
  local total_dirs=$(find "$PROJECT_ROOT" -type d 2>/dev/null | wc -l | tr -d ' ')

  PROJECT_ANALYSIS[total_files]="$total_files"
  PROJECT_ANALYSIS[total_directories]="$total_dirs"

  # Check for common project files
  local -a project_files
  file_exists "README.md" && project_files+=("README.md")
  file_exists "LICENSE" && project_files+=("LICENSE")
  file_exists ".gitignore" && project_files+=(".gitignore")
  file_exists "CHANGELOG.md" && project_files+=("CHANGELOG.md")
  file_exists "CONTRIBUTING.md" && project_files+=("CONTRIBUTING.md")
  file_exists "CODE_OF_CONDUCT.md" && project_files+=("CODE_OF_CONDUCT.md")

  PROJECT_ANALYSIS[project_files]=$(
    IFS=','
    echo "${project_files[*]}"
  )

  # Calculate project maturity score
  local maturity_score=0
  [[ "${PROJECT_ANALYSIS[is_git_repo]}" == "true" ]] && ((maturity_score += 20))
  [[ "${PROJECT_ANALYSIS[commit_count]}" -gt 10 ]] && ((maturity_score += 20))
  [[ "${PROJECT_ANALYSIS[has_remote]}" == "true" ]] && ((maturity_score += 20))
  [[ "${PROJECT_ANALYSIS[project_files]}" == *"README.md"* ]] && ((maturity_score += 10))
  [[ "${PROJECT_ANALYSIS[project_files]}" == *"LICENSE"* ]] && ((maturity_score += 10))
  [[ "${PROJECT_ANALYSIS[project_files]}" == *".gitignore"* ]] && ((maturity_score += 10))
  [[ "${PROJECT_ANALYSIS[project_files]}" == *"CONTRIBUTING.md"* ]] && ((maturity_score += 5))
  [[ "${PROJECT_ANALYSIS[project_files]}" == *"CHANGELOG.md"* ]] && ((maturity_score += 5))

  PROJECT_ANALYSIS[maturity_score]="$maturity_score"
}

# Generate recommendations
generate_recommendations() {
  log_info "Generating recommendations..."

  local -a recommendations
  local project_type="${PROJECT_ANALYSIS[project_type]}"
  local maturity_score="${PROJECT_ANALYSIS[maturity_score]}"

  # Template recommendations based on project type
  case "$project_type" in
  "web-app")
    recommendations+=("Use CLAUDE-web-app.md template for frontend development")
    recommendations+=("Consider setting up Lighthouse CI for performance monitoring")
    ;;
  "api")
    recommendations+=("Use CLAUDE-api.md template for backend development")
    recommendations+=("Set up API documentation with OpenAPI/Swagger")
    ;;
  "library")
    recommendations+=("Focus on comprehensive documentation and examples")
    recommendations+=("Set up automated testing and CI/CD")
    ;;
  "cli")
    recommendations+=("Include usage examples and help documentation")
    recommendations+=("Consider adding shell completion scripts")
    ;;
  esac

  # Maturity-based recommendations
  if [[  $maturity_score -lt 50  ]]; then
    recommendations+=("Add basic project documentation (README.md)")
    recommendations+=("Initialize Git repository and add .gitignore")
    recommendations+=("Add LICENSE file for open source projects")
  elif [[  $maturity_score -lt 80  ]]; then
    recommendations+=("Add CONTRIBUTING.md for collaboration guidelines")
    recommendations+=("Set up continuous integration")
    recommendations+=("Consider adding CHANGELOG.md for release tracking")
  fi

  # Framework-specific recommendations
  local frameworks="${PROJECT_ANALYSIS[frameworks]}"
  if [[  "$frameworks" == *"react"*  ]]; then
    recommendations+=("Set up React DevTools and debugging")
    recommendations+=("Consider adding Storybook for component development")
  fi

  if [[  "$frameworks" == *"nextjs"*  ]]; then
    recommendations+=("Configure Next.js performance monitoring")
    recommendations+=("Set up SEO optimization")
  fi

  PROJECT_ANALYSIS[recommendations]=$(
    IFS='|'
    echo "${recommendations[*]}"
  )
}

# Output results
output_results() {
  case "$OUTPUT_FORMAT" in
  "json")
    echo "{"
    local first=true
    for key in "${!PROJECT_ANALYSIS[@]}"; do
      if [[  "$first" == "true"  ]]; then
        first=false
      else
        echo ","
      fi
      printf "  \"%s\": \"%s\"" "$key" "${PROJECT_ANALYSIS[$key]}"
    done
    echo ""
    echo "}"
    ;;
  "yaml")
    for key in "${!PROJECT_ANALYSIS[@]}"; do
      echo "$key: ${PROJECT_ANALYSIS[$key]}"
    done
    ;;
  "human" | *)
    echo ""
    echo -e "${CYAN}🔍 PROJECT ANALYSIS RESULTS${NC}"
    echo "================================"
    echo ""

    echo -e "${PURPLE}📁 Project Information${NC}"
    echo "   Type: ${PROJECT_ANALYSIS[project_type]} (${PROJECT_ANALYSIS[confidence]} confidence)"
    echo "   Primary Language: ${PROJECT_ANALYSIS[primary_language]}"
    echo "   Frameworks: ${PROJECT_ANALYSIS[frameworks]:-none detected}"
    echo "   Package Managers: ${PROJECT_ANALYSIS[package_managers]:-none detected}"
    echo ""

    echo -e "${BLUE}📊 Repository Statistics${NC}"
    echo "   Total Files: ${PROJECT_ANALYSIS[total_files]}"
    echo "   Source Files: ${PROJECT_ANALYSIS[total_source_files]}"
    echo "   Git Repository: ${PROJECT_ANALYSIS[is_git_repo]}"
    if [[ "${PROJECT_ANALYSIS[is_git_repo]}" == "true" ]]; then
      echo "   Commits: ${PROJECT_ANALYSIS[commit_count]}"
      echo "   Current Branch: ${PROJECT_ANALYSIS[current_branch]}"
      echo "   Has Remote: ${PROJECT_ANALYSIS[has_remote]}"
    fi
    echo "   Maturity Score: ${PROJECT_ANALYSIS[maturity_score]}/100"
    echo ""

    echo -e "${GREEN}💡 Recommendations${NC}"
    local recommendations="${PROJECT_ANALYSIS[recommendations]}"
    if [[  -n "$recommendations"  ]]; then
      IFS='|' read -ra RECS <<<"$recommendations"
      for rec in "${RECS[@]}"; do
        echo "   • $rec"
      done
    else
      echo "   • No specific recommendations at this time"
    fi
    echo ""
    ;;
  esac
}

# Main execution
main() {
  log_info "Starting project analysis for: $PROJECT_ROOT"

  # Change to project directory
  if ! cd "$PROJECT_ROOT" 2>/dev/null; then
    log_error "Cannot access directory: $PROJECT_ROOT"
    exit 1
  fi

  # Run analysis functions
  detect_languages
  detect_package_managers
  detect_frameworks
  detect_project_type
  analyze_repository
  generate_recommendations

  # Output results
  output_results

  log_success "Project analysis completed!"
}

# Script usage
usage() {
  echo "Usage: $0 [PROJECT_PATH] [OUTPUT_FORMAT]"
  echo ""
  echo "PROJECT_PATH: Path to project directory (default: current directory)"
  echo "OUTPUT_FORMAT: Output format - human, json, yaml (default: human)"
  echo ""
  echo "Environment variables:"
  echo "  VERBOSE=true    Enable verbose logging"
  echo ""
  echo "Examples:"
  echo "  $0                          # Analyze current directory"
  echo "  $0 /path/to/project json    # Analyze project with JSON output"
  echo "  VERBOSE=true $0 .           # Analyze with verbose logging"
}

# Handle command line arguments
if [[  "${1:-}" == "--help" || "${1:-}" == "-h"  ]]; then
  usage
  exit 0
fi

# Run main function
main "$@"
