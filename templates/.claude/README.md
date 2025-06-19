# Claude Session Management

This directory contains AI-assisted development session tracking data.

## Structure

```
.claude/
├── session.json         # Current session state
├── history/            # Historical session data
│   ├── YYYY-MM-DD.md   # Daily activity logs
│   └── sessions/       # Archived session JSON files
└── README.md           # This file
```

## Usage

### Starting a Session
```bash
make session-start
# or
./scripts/session/session-start.sh
```

### During Development
```bash
# Check status
make session-status

# Log an activity
make session-log MSG="Implemented user authentication"
```

### Ending a Session
```bash
make session-end
```

## Benefits

1. **Context Preservation**: Maintains context between AI sessions
2. **Activity Tracking**: Records what was done and when
3. **Git Integration**: Tracks commits and changes per session
4. **Progress Monitoring**: See what's been accomplished

## Files

- **session.json**: Current session metadata (auto-generated)
- **history/**: Markdown logs for human readability
- **history/sessions/**: JSON archives for programmatic access

## Privacy

The `.claude` directory is gitignored by default. Session data is local only.