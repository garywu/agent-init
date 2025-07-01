#!/usr/bin/env bash
# Setup GitAttributes for consistent line endings

set -e

echo "🔧 Setting up .gitattributes for consistent line endings"
echo "========================================================"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to detect project type and customize .gitattributes
detect_and_customize() {
    local project_type="generic"
    
    # Detect project type
    if [[ -f "package.json" ]]; then
        if grep -q '"next"' package.json 2>/dev/null; then
            project_type="nextjs"
        elif grep -q '"react"' package.json 2>/dev/null; then
            project_type="react"
        elif grep -q '"vue"' package.json 2>/dev/null; then
            project_type="vue"
        else
            project_type="node"
        fi
    elif [[ -f "Cargo.toml" ]]; then
        project_type="rust"
    elif [[ -f "go.mod" ]]; then
        project_type="golang"
    elif [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]]; then
        project_type="python"
    elif [[ -f "Gemfile" ]]; then
        project_type="ruby"
    fi
    
    echo "🔍 Detected project type: $project_type"
    return 0
}

# Function to create customized .gitattributes
create_gitattributes() {
    local project_type="$1"
    
    echo "📄 Creating .gitattributes for $project_type project..."
    
    # Start with the base template
    cat > .gitattributes << 'EOF'
# Set default behavior to automatically normalize line endings
* text=auto

# Explicitly declare text files you want to always be normalized and converted
# to native line endings on checkout
*.md text
*.txt text
*.yml text
*.yaml text
*.json text
*.xml text
*.html text
*.css text
*.gitignore text
*.gitattributes text
*.editorconfig text
*.pre-commit-config.yaml text
*.releaserc.json text
*.shellcheckrc text
*.shfmt text
*.yamllint text

# Declare files that will always have CRLF line endings on checkout
*.bat text eol=crlf
*.cmd text eol=crlf
*.ps1 text eol=crlf

# Declare files that will always have LF line endings on checkout
*.sh text eol=lf
*.bash text eol=lf
*.zsh text eol=lf
*.fish text eol=lf
Makefile text eol=lf
Dockerfile text eol=lf
*.dockerfile text eol=lf

# Denote all files that are truly binary and should not be modified
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.mov binary
*.mp4 binary
*.mp3 binary
*.flv binary
*.fla binary
*.swf binary
*.gz binary
*.zip binary
*.7z binary
*.ttf binary
*.eot binary
*.woff binary
*.woff2 binary
*.pyc binary
*.class binary
*.jar binary
*.war binary
*.ear binary
*.db binary
*.sqlite binary
*.sqlite3 binary
EOF

    # Add language-specific rules based on project type
    case "$project_type" in
        "node"|"react"|"nextjs"|"vue")
            echo "📝 Adding JavaScript/TypeScript rules..."
            cat >> .gitattributes << 'EOF'

# JavaScript/TypeScript specific
*.js text
*.ts text
*.jsx text
*.tsx text
*.vue text
*.jsonc text
*.mjs text
*.cjs text
EOF
            ;;
        "rust")
            echo "📝 Adding Rust rules..."
            cat >> .gitattributes << 'EOF'

# Rust specific
*.rs text
*.toml text
EOF
            ;;
        "golang")
            echo "📝 Adding Go rules..."
            cat >> .gitattributes << 'EOF'

# Go specific
*.go text
*.mod text
*.sum text
EOF
            ;;
        "python")
            echo "📝 Adding Python rules..."
            cat >> .gitattributes << 'EOF'

# Python specific
*.py text
*.pyi text
*.pyx text
*.pxd text
*.pyc binary
*.pyo binary
*.pyd binary
EOF
            ;;
        "ruby")
            echo "📝 Adding Ruby rules..."
            cat >> .gitattributes << 'EOF'

# Ruby specific
*.rb text
*.erb text
*.rake text
*.gemspec text
Gemfile text
Gemfile.lock text
EOF
            ;;
    esac
    
    # Add Docker rules if Dockerfile exists
    if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]]; then
        echo "📝 Adding Docker rules..."
        cat >> .gitattributes << 'EOF'

# Docker specific
docker-compose*.yml text
*.dockerignore text
EOF
    fi
    
    echo "✅ .gitattributes created successfully"
}

# Function to normalize existing files
normalize_files() {
    echo "🔄 Normalizing existing files..."
    
    # Check if there are any files to normalize
    if [[ -n "$(git ls-files)" ]]; then
        git add --renormalize .
        
        # Check if any files were changed
        if [[ -n "$(git diff --name-only)" ]]; then
            echo "⚠️  Some files were normalized. Review changes with: git diff"
            echo "   Commit changes with: git commit -m 'fix: normalize line endings'"
        else
            echo "✅ All files already have correct line endings"
        fi
    else
        echo "ℹ️  No files to normalize (empty repository)"
    fi
}

# Function to validate setup
validate_setup() {
    echo "🔍 Validating .gitattributes setup..."
    
    # Check if .gitattributes exists
    if [[ ! -f ".gitattributes" ]]; then
        echo "❌ .gitattributes file not found"
        return 1
    fi
    
    # Check for common patterns
    local has_text_auto=false
    local has_sh_lf=false
    local has_ps1_crlf=false
    
    while IFS= read -r line; do
        if [[ "$line" == "* text=auto" ]]; then
            has_text_auto=true
        elif [[ "$line" == "*.sh text eol=lf" ]]; then
            has_sh_lf=true
        elif [[ "$line" == "*.ps1 text eol=crlf" ]]; then
            has_ps1_crlf=true
        fi
    done < .gitattributes
    
    if [[ "$has_text_auto" == "true" ]]; then
        echo "✅ text=auto configured"
    else
        echo "❌ Missing text=auto configuration"
    fi
    
    if [[ "$has_sh_lf" == "true" ]]; then
        echo "✅ Shell scripts configured for LF"
    else
        echo "❌ Missing shell script configuration"
    fi
    
    if [[ "$has_ps1_crlf" == "true" ]]; then
        echo "✅ PowerShell scripts configured for CRLF"
    else
        echo "❌ Missing PowerShell script configuration"
    fi
    
    echo "✅ Validation complete"
}

# Main execution
main() {
    # Check if we're in a git repository
    if [[ ! -d ".git" ]]; then
        echo "⚠️  Not in a git repository. Initializing git..."
        git init
    fi
    
    # Detect project type
    detect_and_customize
    local project_type="$project_type"
    
    # Create .gitattributes
    create_gitattributes "$project_type"
    
    # Normalize existing files
    normalize_files
    
    # Validate setup
    validate_setup
    
    echo ""
    echo "🎉 .gitattributes setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Review the generated .gitattributes file"
    echo "2. Commit the file: git add .gitattributes && git commit -m 'feat: add .gitattributes'"
    echo "3. If files were normalized, commit those changes too"
    echo "4. Share with your team to ensure consistent line endings"
    echo ""
    echo "For more information, see: docs/gitattributes-setup.md"
}

# Run main function
main "$@" 