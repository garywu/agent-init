#!/usr/bin/env bash
# End the current Claude development session

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_DIR="${PROJECT_ROOT}/.claude"
SESSION_FILE="${CLAUDE_DIR}/session.json"
HISTORY_DIR="${CLAUDE_DIR}/history"
TODAY=$(date +%Y-%m-%d)
NOW=$(date +%Y-%m-%d_%H:%M:%S)

# Check if session exists
if [[  ! -f "$SESSION_FILE"  ]]; then
  echo -e "${RED}✗ No active session found${NC}"
  exit 1
fi

# Read session data
SESSION_DATA=$(cat "$SESSION_FILE")
SESSION_ID=$(echo "$SESSION_DATA" | jq -r '.id')
SESSION_START=$(echo "$SESSION_DATA" | jq -r '.started')

# Calculate session duration (cross-platform)
if [[  "$OSTYPE" == "darwin"*  ]]; then
  START_EPOCH=$(date -j -f "%Y-%m-%d_%H:%M:%S" "$SESSION_START" +%s 2>/dev/null)
else
  START_EPOCH=$(date -d "${SESSION_START//_/ }" +%s)
fi
END_EPOCH=$(date +%s)
DURATION_SECONDS=$((END_EPOCH - START_EPOCH))
DURATION_MINUTES=$((DURATION_SECONDS / 60))
DURATION_HOURS=$((DURATION_MINUTES / 60))
DURATION_DISPLAY="${DURATION_HOURS}h $((DURATION_MINUTES % 60))m"

# Get current git status
cd "$PROJECT_ROOT"
CHANGES_COUNT=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
COMMITS_COUNT=$(git log --oneline --since="$SESSION_START" 2>/dev/null | wc -l | tr -d ' ')

# Update session file with end time
UPDATED_SESSION=$(echo "$SESSION_DATA" | jq --arg end "$NOW" --arg duration "$DURATION_DISPLAY" \
  '.ended = $end | .duration = $duration | .status = "completed"')

# Archive the session
ARCHIVE_DIR="${CLAUDE_DIR}/history/sessions"
mkdir -p "$ARCHIVE_DIR"
echo "$UPDATED_SESSION" >"${ARCHIVE_DIR}/session_${SESSION_ID}.json"

# Update history log
HISTORY_FILE="${HISTORY_DIR}/${TODAY}.md"
if [[  -f "$HISTORY_FILE"  ]]; then
  cat >>"$HISTORY_FILE" <<EOF

### Session Ended: ${NOW}

- **Duration**: ${DURATION_DISPLAY}
- **Commits**: ${COMMITS_COUNT}
- **Changes**: ${CHANGES_COUNT} files pending

#### Summary

EOF

  # Add commit summary if any
  if [[  $COMMITS_COUNT -gt 0  ]]; then
    echo "**Commits made during session:**" >>"$HISTORY_FILE"
    git log --oneline --since="$SESSION_START" --pretty="- %h %s" >>"$HISTORY_FILE"
    echo "" >>"$HISTORY_FILE"
  fi

  # Add file changes summary if any
  if [[  $CHANGES_COUNT -gt 0  ]]; then
    echo "**Files with pending changes:**" >>"$HISTORY_FILE"
    git status --porcelain | awk '{print "- " $2}' >>"$HISTORY_FILE"
    echo "" >>"$HISTORY_FILE"
  fi
fi

# Clear active session
echo '{"status": "no_active_session"}' >"$SESSION_FILE"

# Print summary
echo -e "${GREEN}✓ Session ended${NC}"
echo -e "${BLUE}Session ID:${NC} $SESSION_ID"
echo -e "${BLUE}Duration:${NC} $DURATION_DISPLAY"
echo -e "${BLUE}Commits:${NC} $COMMITS_COUNT"
echo -e "${BLUE}Pending changes:${NC} $CHANGES_COUNT files"
echo ""

# Show pending changes if any
if [[  $CHANGES_COUNT -gt 0  ]]; then
  echo -e "${YELLOW}Pending changes:${NC}"
  git status -s
  echo ""
  echo -e "${YELLOW}Consider committing your changes before starting the next session${NC}"
fi

echo -e "${GREEN}Session archived to: ${ARCHIVE_DIR}/session_${SESSION_ID}.json${NC}"
