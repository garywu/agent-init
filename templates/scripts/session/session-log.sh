#!/usr/bin/env bash
# Add an entry to the current session log

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_DIR="${PROJECT_ROOT}/.claude"
SESSION_FILE="${CLAUDE_DIR}/session.json"
HISTORY_DIR="${CLAUDE_DIR}/history"
TODAY=$(date +%Y-%m-%d)
NOW=$(date +%H:%M:%S)

# Check if session is active
if [[  ! -f "$SESSION_FILE"  ]]; then
  echo -e "${RED}✗ No active session found${NC}"
  echo "Start a session first with: ./scripts/session/session-start.sh"
  exit 1
fi

STATUS=$(jq -r '.status // "unknown"' "$SESSION_FILE")
if [[  "$STATUS" != "active"  ]]; then
  echo -e "${RED}✗ No active session${NC}"
  echo "Start a session first with: ./scripts/session/session-start.sh"
  exit 1
fi

# Get log message
if [[  $# -eq 0  ]]; then
  echo "Usage: $0 <log message>"
  echo "Example: $0 \"Fixed CI test failures\""
  exit 1
fi

LOG_MESSAGE="$*"

# Add to history file
HISTORY_FILE="${HISTORY_DIR}/${TODAY}.md"
if [[  -f "$HISTORY_FILE"  ]]; then
  echo "- **${NOW}**: ${LOG_MESSAGE}" >>"$HISTORY_FILE"
  echo -e "${GREEN}✓ Logged to session history${NC}"
else
  echo -e "${RED}✗ No history file for today${NC}"
  exit 1
fi

# Update session file last_updated
jq --arg now "$(date +%Y-%m-%d_%H:%M:%S)" '.last_updated = $now' "$SESSION_FILE" >"${SESSION_FILE}.tmp"
mv "${SESSION_FILE}.tmp" "$SESSION_FILE"

echo "Entry added: ${LOG_MESSAGE}"
