#!/usr/bin/env bash
# Show current session status

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'

# Paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_DIR="${PROJECT_ROOT}/.claude"
SESSION_FILE="${CLAUDE_DIR}/session.json"
HISTORY_DIR="${CLAUDE_DIR}/history"
TODAY=$(date +%Y-%m-%d)

# Function to display time ago
time_ago() {
  local timestamp=$1
  local now=$(date +%s)
  local then

  # Cross-platform date parsing
  if [[  "$OSTYPE" == "darwin"*  ]]; then
    then=$(date -j -f "%Y-%m-%d_%H:%M:%S" "$timestamp" +%s 2>/dev/null)
  else
    then=$(date -d "${timestamp//_/ }" +%s)
  fi

  local diff=$((now - then))

  if [[  $diff -lt 60  ]]; then
    echo "${diff}s ago"
  elif [[  $diff -lt 3600  ]]; then
    echo "$((diff / 60))m ago"
  elif [[  $diff -lt 86400  ]]; then
    echo "$((diff / 3600))h $((diff % 3600 / 60))m ago"
  else
    echo "$((diff / 86400))d ago"
  fi
}

# Header
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Project Session Status           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if session exists
if [[  ! -f "$SESSION_FILE"  ]]; then
  echo -e "${RED}✗ No session file found${NC}"
  exit 1
fi

# Read session data
SESSION_DATA=$(cat "$SESSION_FILE")
STATUS=$(echo "$SESSION_DATA" | jq -r '.status // "unknown"')

if [[  "$STATUS" == "no_active_session"  ]]; then
  echo -e "${YELLOW}No active session${NC}"
  echo ""

  # Show recent sessions
  ARCHIVE_DIR="${CLAUDE_DIR}/history/sessions"
  if [[  -d "$ARCHIVE_DIR"  ]] && [[  -n "$(ls -A "$ARCHIVE_DIR" 2>/dev/null)"  ]]; then
    echo -e "${BLUE}Recent sessions:${NC}"
    ls -t "$ARCHIVE_DIR" | head -5 | while read session_file; do
      if [[  -f "$ARCHIVE_DIR/$session_file"  ]]; then
        SESSION=$(cat "$ARCHIVE_DIR/$session_file")
        ID=$(echo "$SESSION" | jq -r '.id // "unknown"')
        STARTED=$(echo "$SESSION" | jq -r '.started // "unknown"')
        DURATION=$(echo "$SESSION" | jq -r '.duration // "unknown"')
        echo -e "${GRAY}• $STARTED - Duration: $DURATION${NC}"
      fi
    done
  fi

  echo ""
  echo -e "${GRAY}Run 'session-start' to begin a new session${NC}"
  exit 0
fi

# Active session info
SESSION_ID=$(echo "$SESSION_DATA" | jq -r '.id // "unknown"')
SESSION_START=$(echo "$SESSION_DATA" | jq -r '.started // "unknown"')
LAST_UPDATE=$(echo "$SESSION_DATA" | jq -r '.last_updated // "unknown"')

echo -e "${GREEN}● Active Session${NC}"
echo -e "${GRAY}ID: $SESSION_ID${NC}"
echo -e "${GRAY}Started: $SESSION_START ($(time_ago "$SESSION_START"))${NC}"
echo ""

# Git status
echo -e "${BLUE}Git Status:${NC}"
cd "$PROJECT_ROOT"
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
COMMITS_TODAY=$(git log --oneline --since="$SESSION_START" 2>/dev/null | wc -l | tr -d ' ')

echo "• Branch: $BRANCH"
echo "• Changes: $CHANGES files ($STAGED staged)"
echo "• Commits this session: $COMMITS_TODAY"

# Show recent commits
if [[  $COMMITS_TODAY -gt 0  ]]; then
  echo ""
  echo -e "${BLUE}Recent commits:${NC}"
  git log --oneline --since="$SESSION_START" --pretty=format:"${GRAY}• %h %s${NC}" | head -5
fi

# Today's activity
echo ""
echo -e "${BLUE}Today's Activity:${NC}"
HISTORY_FILE="${HISTORY_DIR}/${TODAY}.md"
if [[  -f "$HISTORY_FILE"  ]]; then
  SESSIONS_TODAY=$(grep -c "### Session Started:" "$HISTORY_FILE" || echo "0")
  echo "• Sessions: $SESSIONS_TODAY"

  # Count activities
  ACTIVITIES=$(grep -c "^- " "$HISTORY_FILE" || echo "0")
  echo "• Activities logged: $ACTIVITIES"
fi

# Pending tasks
echo ""
echo -e "${BLUE}Pending Tasks:${NC}"
TASKS=$(echo "$SESSION_DATA" | jq -r '.tasks[]? // empty' | head -5)
if [[  -n "$TASKS"  ]]; then
  echo "$TASKS" | while read task; do
    echo "• $task"
  done
else
  echo -e "${GRAY}No tasks recorded${NC}"
fi

# Recent TODOs in code
if command -v rg &>/dev/null; then
  TODO_COUNT=$(rg -c "TODO|FIXME" . 2>/dev/null | wc -l | tr -d ' ')
  if [[  $TODO_COUNT -gt 0  ]]; then
    echo ""
    echo -e "${YELLOW}Code TODOs: $TODO_COUNT locations${NC}"
  fi
fi

echo ""
echo -e "${GRAY}Run 'session-end' to end this session${NC}"
