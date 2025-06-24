#!/usr/bin/env bash
# Start a new Claude development session

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_DIR="${PROJECT_ROOT}/.claude"
SESSION_FILE="${CLAUDE_DIR}/session.json"
HISTORY_DIR="${CLAUDE_DIR}/history"
TODAY=$(date +%Y-%m-%d)
NOW=$(date +%Y-%m-%d_%H:%M:%S)

# Ensure directories exist
mkdir -p "${HISTORY_DIR}"

# Function to get git status summary
get_git_status() {
  cd "$PROJECT_ROOT"
  local branch=$(git branch --show-current 2>/dev/null || echo "main")
  local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  local ahead_behind=$(git status -sb 2>/dev/null | grep -oE '(ahead|behind) [0-9]+' || echo "up to date")
  echo "{\"branch\": \"$branch\", \"changes\": $changes, \"sync\": \"$ahead_behind\"}"
}

# Function to get system info
get_system_info() {
  local os=$(uname -s)
  local arch=$(uname -m)
  local shell=$(basename "$SHELL")
  local node_version=$(node --version 2>/dev/null || echo "not installed")
  local python_version=$(python3 --version 2>/dev/null | cut -d' ' -f2 || echo "not installed")
  echo "{\"os\": \"$os\", \"arch\": \"$arch\", \"shell\": \"$shell\", \"node\": \"$node_version\", \"python\": \"$python_version\"}"
}

# Initialize or update session file
if [[  -f "$SESSION_FILE"  ]]; then
  # Read existing session
  EXISTING_SESSION=$(cat "$SESSION_FILE")
  EXISTING_ID=$(echo "$EXISTING_SESSION" | jq -r '.id // empty' 2>/dev/null || echo "")
else
  EXISTING_ID=""
fi

# Generate new session ID
SESSION_ID="${NOW}_$$"

# Create session data
SESSION_DATA=$(
  cat <<EOF
{
  "id": "$SESSION_ID",
  "started": "$NOW",
  "last_updated": "$NOW",
  "status": "active",
  "git": $(get_git_status),
  "system": $(get_system_info),
  "previous_session": $(if [[  -n "$EXISTING_ID"  ]]; then echo "\"$EXISTING_ID\""; else echo "null"; fi),
  "tasks": [],
  "notes": []
}
EOF
)

# Write session file
echo "$SESSION_DATA" | jq '.' >"$SESSION_FILE"

# Create or append to daily history log
HISTORY_FILE="${HISTORY_DIR}/${TODAY}.md"

if [[  ! -f "$HISTORY_FILE"  ]]; then
  cat >"$HISTORY_FILE" <<EOF
# Session Log - ${TODAY}

## Sessions

EOF
fi

# Append session start to history
cat >>"$HISTORY_FILE" <<EOF

### Session Started: ${NOW}

- **Session ID**: ${SESSION_ID}
- **Branch**: $(git branch --show-current 2>/dev/null || echo "main")
- **Status**: $(git status -s 2>/dev/null | wc -l | tr -d ' ') uncommitted changes

#### Activities

EOF

# Print session info
echo -e "${GREEN}✓ Session started${NC}"
echo -e "${BLUE}Session ID:${NC} $SESSION_ID"
echo -e "${BLUE}History log:${NC} $HISTORY_FILE"
echo -e "${BLUE}Session file:${NC} $SESSION_FILE"
echo ""

# Show current status
echo -e "${YELLOW}Current Status:${NC}"
echo "• Branch: $(git branch --show-current 2>/dev/null || echo "main")"
echo "• Changes: $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') files"
echo "• Last commit: $(git log -1 --pretty=format:'%h %s' 2>/dev/null || echo 'No commits')"

# Show recent todos if any
if command -v rg &>/dev/null && rg -q "TODO|FIXME" . 2>/dev/null; then
  echo ""
  echo -e "${YELLOW}Recent TODOs:${NC}"
  rg "TODO|FIXME" . -m 3 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}Session tracking active. Happy coding!${NC}"
