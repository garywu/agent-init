#!/usr/bin/env bash
# agent-init setup script with project type detection

set -e

echo "🚀 Agent-Init Setup"
echo "===================="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to detect project type
detect_project_type() {
  if [[ -f "package.json" ]]; then
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
  elif [[ -f "Cargo.toml" ]]; then
    echo "rust"
  elif [[ -f "go.mod" ]]; then
    echo "golang"
  elif [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]]; then
    echo "python"
  elif [[ -f "Gemfile" ]]; then
    echo "ruby"
  else
    echo "generic"
  fi
}

# Function to create .claude directory structure
setup_claude_dirs() {
  echo "📁 Creating .claude directory structure..."
  mkdir -p .claude/history/sessions

  # Copy README if template exists
  if [[ -f "$SCRIPT_DIR/templates/.claude/README.md" ]]; then
    cp "$SCRIPT_DIR/templates/.claude/README.md" .claude/
  fi

  # Initialize with no active session
  cat >.claude/session.json <<EOF
{
  "status": "no_active_session"
}
EOF

  echo "✅ Session management initialized"
  echo "   Run 'make session-start' to begin your first session"
}

# Main setup flow
PROJECT_TYPE=$(detect_project_type)
echo "🔍 Detected project type: $PROJECT_TYPE"

# Copy appropriate CLAUDE.md template
if [[ -f "templates/CLAUDE-${PROJECT_TYPE}.md" ]]; then
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

# Set up .gitattributes for consistent line endings
echo "🔧 Setting up .gitattributes..."
if [[ -f "scripts/setup-gitattributes.sh" ]]; then
  echo "Running .gitattributes setup..."
  bash scripts/setup-gitattributes.sh
elif [[ -f "$SCRIPT_DIR/scripts/setup-gitattributes.sh" ]]; then
  echo "Copying and running .gitattributes setup..."
  mkdir -p scripts
  cp "$SCRIPT_DIR/scripts/setup-gitattributes.sh" scripts/
  chmod +x scripts/setup-gitattributes.sh
  bash scripts/setup-gitattributes.sh
else
  echo "Copying .gitattributes template..."
  cp templates/.gitattributes .gitattributes 2>/dev/null || true
fi

# Create aliases file if it doesn't exist
if [[ ! -f ".claude-aliases" ]]; then
  echo "🔧 Creating .claude-aliases..."
  cat >.claude-aliases <<'EOF'
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
if [[ ! -f "scripts/health-check.sh" ]]; then
  mkdir -p scripts
  echo "🏥 Creating health check script..."
  cat >scripts/health-check.sh <<'EOF'
#!/bin/bash
# Project Health Check

echo "🏥 Project Health Check"
echo "====================="

# Git status
echo "📝 Git Status:"
if [[  -n $(git status -s)  ]]; then
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

# Copy session management scripts
if [[ -d "$SCRIPT_DIR/templates/scripts/session" ]] && [[ ! -d "scripts/session" ]]; then
  echo "📊 Setting up session management scripts..."
  mkdir -p scripts
  cp -r "$SCRIPT_DIR/templates/scripts/session" scripts/
  chmod +x scripts/session/*.sh
  echo "✅ Session scripts installed"
fi

# Initialize git if needed
if [[ ! -d ".git" ]]; then
  echo "🔧 Initializing git repository..."
  git init
  git add -A
  git commit -m "Initial commit with claude-init setup"
fi

# Ask about release management setup
echo ""
read -p "Would you like to set up multi-stage release management? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [[ -f "scripts/setup-releases.sh" ]]; then
    echo "Running release setup..."
    bash scripts/setup-releases.sh
  elif [[ -f "$SCRIPT_DIR/templates/scripts/setup-releases.sh" ]]; then
    echo "Copying and running release setup..."
    mkdir -p scripts
    cp "$SCRIPT_DIR/templates/scripts/setup-releases.sh" scripts/
    chmod +x scripts/setup-releases.sh
    bash scripts/setup-releases.sh
  else
    echo "Release setup script not found, skipping..."
  fi
fi

# Ask about documentation site setup
echo ""
read -p "Would you like to set up a documentation site? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [[ -d "$SCRIPT_DIR/templates/docs" ]]; then
    echo "Setting up documentation site..."
    cp -r "$SCRIPT_DIR/templates/docs" .
    echo "✅ Documentation site created in ./docs"
    echo "   Run 'cd docs && npm install && npm run dev' to start"
  fi
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review and customize CLAUDE.md"
echo "2. Source aliases: source .claude-aliases"
echo "3. Create your first issue: gh issue create"
echo "4. Run health check: ./scripts/health-check.sh"
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "5. Configure branch protection rules in GitHub"
  echo "6. Test release workflows (see RELEASES.md)"
fi
echo ""
echo "Happy coding with Claude! 🚀"
