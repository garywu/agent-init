# Claude Automatic Notification Rules

## MANDATORY Notification Triggers

### 1. Before ANY User Input Request
```bash
# WRONG ❌
read -r -p "Enter choice: " choice

# RIGHT ✅
say "Awaiting your input" && afplay /System/Library/Sounds/Glass.aiff
read -r -p "Enter choice: " choice
```

### 2. Before Long-Running Commands (>5 seconds)
```bash
# WRONG ❌
ssh user@host 'long-running-command'

# RIGHT ✅
say "Starting long operation" && afplay /System/Library/Sounds/Submarine.aiff
ssh user@host 'long-running-command'
say "Operation complete" && afplay /System/Library/Sounds/Glass.aiff
```

### 3. Task Completion
```bash
# WRONG ❌
echo "Setup complete!"

# RIGHT ✅
echo "Setup complete!"
say "Task complete. Awaiting orders." && afplay /System/Library/Sounds/Hero.aiff
```

### 4. Error Conditions
```bash
# WRONG ❌
echo "Error: Command failed"

# RIGHT ✅
echo "Error: Command failed"
say "Error detected" && afplay /System/Library/Sounds/Basso.aiff
```

## Implementation Patterns

### Pattern 1: Wrapper Functions
```bash
# Add to all scripts
notify_and_wait() {
    local message="${1:-Awaiting input}"
    say "$message" && afplay /System/Library/Sounds/Glass.aiff
    shift
    "$@"  # Execute the actual command
}

# Usage
notify_and_wait "Select an option" read -r -p "Choice: " choice
```

### Pattern 2: Pre-execution Hooks
```bash
# For interactive scripts
set_notification_trap() {
    trap 'say "Waiting for input" && afplay /System/Library/Sounds/Ping.aiff' DEBUG
}
```

### Pattern 3: Command Decorators
```bash
# Decorator for any command
with_notification() {
    say "Starting: $1" && afplay /System/Library/Sounds/Pop.aiff
    "${@:2}"
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        say "Complete" && afplay /System/Library/Sounds/Glass.aiff
    else
        say "Failed" && afplay /System/Library/Sounds/Basso.aiff
    fi
    return $exit_code
}
```

## Claude CLI Integration

### Auto-notification for Common Patterns
When Claude detects these patterns in scripts, automatically add notifications:

1. **User Input Patterns**:
   - `read -r`
   - `read -p`
   - `select ... in`
   - `$Host.UI.RawUI.ReadKey`
   - `Read-Host`

2. **Wait Patterns**:
   - `sleep [5-9]|[0-9]{2,}`
   - `wait`
   - SSH/remote commands
   - Long downloads/installations

3. **Completion Patterns**:
   - End of main script
   - After test suites
   - After installations
   - After file operations

## Automatic Script Enhancement

### Template for All New Scripts
```bash
#!/usr/bin/env bash
# Notification-enabled script

# Source notification helpers
source "${HOME}/.dotfiles/scripts/notification-helpers.sh" 2>/dev/null || {
    # Fallback definitions if helpers not found
    notify() { say "$1" 2>/dev/null || echo "🔔 $1"; }
    notify_wait() { notify "$1" && sleep 0.5; }
}

# Enable notification on script exit
trap 'notify "Script complete"' EXIT

# Main script content
main() {
    notify_wait "Starting task"

    # Before any user input
    notify_wait "Need your input"
    read -r -p "Enter value: " value

    # Long operations
    notify_wait "Processing, this may take a while"
    long_running_command

    notify "Task successful"
}

main "$@"
```

## Enforcement Rules for Claude

1. **Never create a script with user input without notification**
2. **Add notifications to existing scripts when modifying them**
3. **Use different sounds for different events**:
   - Input needed: Glass.aiff or Ping.aiff
   - Success: Hero.aiff or Glass.aiff
   - Error: Basso.aiff or Funk.aiff
   - Warning: Sosumi.aiff
   - Long operation: Submarine.aiff

4. **Test notification before first use**:
   ```bash
   # At script start
   if ! command -v say &>/dev/null; then
       echo "Warning: Audio notifications not available"
   fi
   ```

## Memory Aid for Claude

**ACRONYM: W.A.I.T.**
- **W**ait points need notification
- **A**sk for input needs notification
- **I**mportant completions need notification
- **T**imeouts/errors need notification

## Example Transformation

### Before (No Notifications):
```bash
echo "Installing packages..."
apt-get install -y package1 package2
echo "Done"
read -r -p "Continue? " answer
```

### After (Foolproof Notifications):
```bash
notify "Installing packages"
apt-get install -y package1 package2
notify "Installation complete"
notify "Need your decision"
read -r -p "Continue? " answer
```