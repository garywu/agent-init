#!/bin/bash
# Enhanced claude-init setup script with project type detection

set -e

echo "🚀 Claude-Init Enhanced Setup"
echo "============================"

# Function to detect project type
detect_project_type() {
    if [ -f "package.json" ]; then
        # Node.js project detected
        if grep -q '"next"' package.json 2>/dev/null; then
            echo "nextjs"
        elif grep -q '"react"' package.json 2>/dev/null; then
            echo "react"
        elif grep -q '"vue"' package.json 2>/dev/null; then
            echo "vue"
        elif grep -q '"express"' package.json 2>/dev/null || grep -q '"koa"' package.json 2>/dev/null; then
            echo "api"
        else
            echo "node"
        fi
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif [ -f "go.mod" ]; then
        echo "golang"
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
        echo "python"
    elif [ -f "Gemfile" ]; then
        echo "ruby"
    else
        echo "generic"
    fi
}

# Function to create .claude directory structure
setup_claude_dirs() {
    echo "📁 Creating .claude directory structure..."
    mkdir -p .claude/history .claude/snippets .claude/context
    
    # Create session.json
    cat > .claude/session.json << EOF
{
  "current_session": {
    "date": "$(date +%Y-%m-%d)",
    "start_time": "$(date +%H:%M:%S)",
    "project_type": "$1",
    "primary_focus": "",
    "active_issues": [],
    "context": {
      "working_directory": "$(pwd)"
    }
  }
}
EOF
    
    # Create today's history file
    cat > .claude/history/$(date +%Y-%m-%d).md << EOF
# Session Log: $(date +%Y-%m-%d)

## Session Summary
- **Start Time**: $(date +%H:%M:%S)
- **Project Type**: $1
- **Initial Setup**: claude-init enhanced

## Tasks
- [ ] Review project structure
- [ ] Set up development environment
- [ ] Create initial GitHub issues

## Notes
Project initialized with claude-init enhanced setup.
EOF
}

# Main setup flow
PROJECT_TYPE=$(detect_project_type)
echo "🔍 Detected project type: $PROJECT_TYPE"

# Copy appropriate CLAUDE.md template
if [ -f "templates/CLAUDE-${PROJECT_TYPE}.md" ]; then
    echo "📄 Using specialized template for $PROJECT_TYPE"
    cp "templates/CLAUDE-${PROJECT_TYPE}.md" CLAUDE.md
else
    echo "📄 Using generic template"
    cp templates/CLAUDE.md CLAUDE.md
fi

# Set up .claude directory
setup_claude_dirs $PROJECT_TYPE

# Copy other template files
echo "📋 Copying template files..."
cp -r templates/.github .github 2>/dev/null || true
cp templates/.gitignore .gitignore 2>/dev/null || true
cp templates/CONTRIBUTING.md CONTRIBUTING.md 2>/dev/null || true

# Create aliases file if it doesn't exist
if [ ! -f ".claude-aliases" ]; then
    echo "🔧 Creating .claude-aliases..."
    cat > .claude-aliases << 'EOF'
#!/bin/bash
# Claude Development Aliases
# Source this file: source .claude-aliases

# GitHub shortcuts
alias ci="gh issue create"
alias cil="gh issue list --state open"
alias cic="gh issue comment"
alias cpr="gh pr create"

# Development shortcuts (customize based on project)
alias cdev="npm run dev 2>/dev/null || make dev 2>/dev/null || cargo run 2>/dev/null"
alias ctest="npm test 2>/dev/null || make test 2>/dev/null || cargo test 2>/dev/null"
alias cbuild="npm run build 2>/dev/null || make build 2>/dev/null || cargo build 2>/dev/null"

echo "✅ Claude aliases loaded!"
EOF
    chmod +x .claude-aliases
fi

# Create health check script
if [ ! -f "scripts/health-check.sh" ]; then
    mkdir -p scripts
    echo "🏥 Creating health check script..."
    cat > scripts/health-check.sh << 'EOF'
#!/bin/bash
# Project Health Check

echo "🏥 Project Health Check"
echo "====================="

# Git status
echo "📝 Git Status:"
if [[ -n $(git status -s) ]]; then
    echo "⚠️  Uncommitted changes found"
else
    echo "✅ Working directory clean"
fi

# More checks can be added based on project type
echo ""
echo "Health check complete!"
EOF
    chmod +x scripts/health-check.sh
fi

# Initialize git if needed
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
    git add -A
    git commit -m "Initial commit with claude-init enhanced setup"
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review and customize CLAUDE.md"
echo "2. Source aliases: source .claude-aliases"
echo "3. Create your first issue: gh issue create"
echo "4. Run health check: ./scripts/health-check.sh"
echo ""
echo "Happy coding with Claude! 🚀"