---
title: Error Handling Patterns
description: Error Handling Patterns - Comprehensive guide from agent-init
sidebar:
  order: 20
---

# Error Handling and Recovery Patterns

This guide documents robust patterns for handling errors, recovering from failures, and implementing rollback mechanisms in any project.

## Error Handling Fundamentals

### Shell Script Error Handling

```bash
#!/bin/bash
# Essential error handling setup

# Exit on error, undefined variable, pipe failure
set -euo pipefail

# Set error trap
trap 'error_handler $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]:-})' ERR

# Universal error handler
error_handler() {
    local exit_code=$1
    local line_number=$2
    local bash_lineno=$3
    local last_command=$4
    local func_stack=$5
    
    echo "❌ Error occurred:" >&2
    echo "  Exit code: $exit_code" >&2
    echo "  Line: $line_number" >&2
    echo "  Command: $last_command" >&2
    echo "  Function stack: $func_stack" >&2
    
    # Call cleanup if defined
    if declare -f cleanup > /dev/null; then
        echo "🧹 Running cleanup..." >&2
        cleanup
    fi
    
    exit "$exit_code"
}

# Cleanup function (to be defined per script)
cleanup() {
    # Remove temporary files
    [[ -n "${TEMP_DIR:-}" ]] && rm -rf "$TEMP_DIR"
    
    # Kill background processes
    [[ -n "${BG_PID:-}" ]] && kill "$BG_PID" 2>/dev/null || true
    
    # Custom cleanup actions
    return 0
}
```

### Try-Catch Pattern for Shell

```bash
# Try-catch implementation
try() {
    [[ $- = *e* ]]; SAVED_OPT_E=$?
    set +e
}

catch() {
    export exception_code=$?
    (( SAVED_OPT_E )) && set +e
    return $exception_code
}

# Usage example
try
(
    # Commands that might fail
    risky_operation
    another_risky_operation
)
catch || {
    case $exception_code in
        1)
            echo "General error occurred"
            ;;
        2)
            echo "Misuse of shell command"
            ;;
        126)
            echo "Command cannot execute"
            ;;
        127)
            echo "Command not found"
            ;;
        *)
            echo "Unknown error: $exception_code"
            ;;
    esac
    
    # Handle the error
    handle_error $exception_code
}
```

## State Management and Rollback

### Transaction-Style Operations

```bash
# State snapshot before changes
create_state_snapshot() {
    local snapshot_name=$1
    local snapshot_dir="$HOME/.local/state/snapshots/$snapshot_name"
    
    mkdir -p "$snapshot_dir"
    
    # Capture current state
    cat > "$snapshot_dir/manifest.json" << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "version": "$(get_current_version)",
    "files": $(find_modified_files | jq -R . | jq -s .),
    "environment": $(env | grep "^APP_" | jq -R . | jq -s .),
    "services": $(list_running_services | jq -R . | jq -s .)
}
EOF
    
    # Backup critical files
    while IFS= read -r file; do
        local backup_path="$snapshot_dir/files/$(dirname "$file")"
        mkdir -p "$backup_path"
        cp -p "$file" "$backup_path/" 2>/dev/null || true
    done < <(get_critical_files)
    
    echo "$snapshot_dir"
}

# Rollback to previous state
rollback_to_snapshot() {
    local snapshot_name=$1
    local snapshot_dir="$HOME/.local/state/snapshots/$snapshot_name"
    
    if [[ ! -d "$snapshot_dir" ]]; then
        echo "Error: Snapshot '$snapshot_name' not found"
        return 1
    fi
    
    echo "🔄 Rolling back to snapshot: $snapshot_name"
    
    # Restore files
    if [[ -d "$snapshot_dir/files" ]]; then
        cd "$snapshot_dir/files"
        find . -type f | while read -r file; do
            local dest="/$file"  # Adjust path as needed
            echo "  Restoring: $dest"
            cp -p "$file" "$dest"
        done
    fi
    
    # Restore environment (if applicable)
    if command -v jq > /dev/null; then
        jq -r '.environment[]' "$snapshot_dir/manifest.json" | while IFS='=' read -r key value; do
            export "$key=$value"
        done
    fi
    
    echo "✅ Rollback complete"
}
```

### Atomic Operations

```bash
# Atomic file replacement
atomic_file_replace() {
    local target_file=$1
    local new_content=$2
    local temp_file
    
    # Create temporary file in same directory (for same filesystem)
    temp_file=$(mktemp "${target_file}.XXXXXX")
    
    # Write new content
    echo "$new_content" > "$temp_file"
    
    # Set permissions to match original
    if [[ -f "$target_file" ]]; then
        chmod --reference="$target_file" "$temp_file"
        chown --reference="$target_file" "$temp_file" 2>/dev/null || true
    fi
    
    # Atomic rename
    mv -f "$temp_file" "$target_file"
}

# Atomic directory replacement
atomic_dir_replace() {
    local target_dir=$1
    local source_dir=$2
    local backup_dir="${target_dir}.backup.$$"
    
    # Verify source exists
    if [[ ! -d "$source_dir" ]]; then
        echo "Error: Source directory does not exist: $source_dir"
        return 1
    fi
    
    # If target exists, move it to backup
    if [[ -d "$target_dir" ]]; then
        mv "$target_dir" "$backup_dir"
    fi
    
    # Move new directory into place
    if mv "$source_dir" "$target_dir"; then
        # Success - remove backup
        [[ -d "$backup_dir" ]] && rm -rf "$backup_dir"
        return 0
    else
        # Failed - restore backup
        echo "Error: Failed to move directory, restoring backup"
        [[ -d "$backup_dir" ]] && mv "$backup_dir" "$target_dir"
        return 1
    fi
}
```

## Graceful Degradation

### Feature Detection and Fallbacks

```bash
# Execute with fallback options
execute_with_fallback() {
    local primary_cmd=$1
    local fallback_cmd=$2
    local args=("${@:3}")
    
    if command -v "$primary_cmd" > /dev/null; then
        "$primary_cmd" "${args[@]}"
    elif command -v "$fallback_cmd" > /dev/null; then
        echo "Note: Using fallback command '$fallback_cmd'" >&2
        "$fallback_cmd" "${args[@]}"
    else
        echo "Error: Neither '$primary_cmd' nor '$fallback_cmd' available" >&2
        return 1
    fi
}

# Progressive feature degradation
setup_features() {
    local features_enabled=()
    local features_disabled=()
    
    # Try to enable each feature
    if check_feature_available "advanced_mode"; then
        enable_advanced_mode && features_enabled+=("advanced_mode") || features_disabled+=("advanced_mode")
    fi
    
    if check_feature_available "color_output"; then
        enable_color_output && features_enabled+=("color_output") || features_disabled+=("color_output")
    fi
    
    if check_feature_available "parallel_processing"; then
        enable_parallel_processing && features_enabled+=("parallel_processing") || features_disabled+=("parallel_processing")
    fi
    
    # Report status
    echo "✅ Enabled features: ${features_enabled[*]:-none}"
    [[ ${#features_disabled[@]} -gt 0 ]] && echo "⚠️  Disabled features: ${features_disabled[*]}"
}
```

### Partial Success Handling

```bash
# Operation with partial success tracking
batch_operation() {
    local items=("$@")
    local succeeded=()
    local failed=()
    local exit_code=0
    
    for item in "${items[@]}"; do
        echo "Processing: $item"
        if process_item "$item"; then
            succeeded+=("$item")
        else
            failed+=("$item")
            exit_code=1
        fi
    done
    
    # Report results
    echo ""
    echo "Summary:"
    echo "  ✅ Succeeded: ${#succeeded[@]}"
    echo "  ❌ Failed: ${#failed[@]}"
    
    if [[ ${#failed[@]} -gt 0 ]]; then
        echo ""
        echo "Failed items:"
        printf '  - %s\n' "${failed[@]}"
    fi
    
    return $exit_code
}
```

## Timeout and Retry Mechanisms

### Command Timeout

```bash
# Run command with timeout
run_with_timeout() {
    local timeout=$1
    shift
    local command=("$@")
    
    if command -v timeout > /dev/null; then
        timeout "$timeout" "${command[@]}"
    else
        # Fallback implementation
        "${command[@]}" &
        local pid=$!
        
        # Wait for timeout
        local count=0
        while kill -0 $pid 2>/dev/null; do
            if [[ $count -ge $timeout ]]; then
                echo "Timeout: Command exceeded ${timeout}s" >&2
                kill -TERM $pid 2>/dev/null
                sleep 1
                kill -KILL $pid 2>/dev/null
                return 124  # timeout exit code
            fi
            sleep 1
            ((count++))
        done
        
        wait $pid
    fi
}
```

### Retry with Exponential Backoff

```bash
# Retry failed operations
retry_with_backoff() {
    local max_attempts=${MAX_ATTEMPTS:-5}
    local base_delay=${BASE_DELAY:-1}
    local max_delay=${MAX_DELAY:-60}
    local attempt=0
    local delay=$base_delay
    
    local command=("$@")
    
    while [[ $attempt -lt $max_attempts ]]; do
        attempt=$((attempt + 1))
        
        echo "Attempt $attempt/$max_attempts: ${command[*]}"
        
        if "${command[@]}"; then
            echo "✅ Success on attempt $attempt"
            return 0
        fi
        
        if [[ $attempt -lt $max_attempts ]]; then
            echo "⚠️  Failed, retrying in ${delay}s..."
            sleep "$delay"
            
            # Exponential backoff with jitter
            delay=$((delay * 2 + RANDOM % 3))
            [[ $delay -gt $max_delay ]] && delay=$max_delay
        fi
    done
    
    echo "❌ Failed after $max_attempts attempts"
    return 1
}

# Usage
retry_with_backoff curl -f https://example.com/api/data
```

## Logging and Debugging

### Structured Error Logging

```bash
# Initialize logging
setup_logging() {
    export LOG_DIR="${LOG_DIR:-$HOME/.local/log}"
    export LOG_FILE="${LOG_FILE:-$LOG_DIR/$(basename "$0").log}"
    export ERROR_LOG="${ERROR_LOG:-$LOG_DIR/$(basename "$0").error.log}"
    
    mkdir -p "$LOG_DIR"
    
    # Redirect stdout and stderr while preserving originals
    exec 3>&1 4>&2
    exec 1> >(tee -a "$LOG_FILE")
    exec 2> >(tee -a "$ERROR_LOG" >&2)
}

# Structured log entry
log_error() {
    local level=$1
    local message=$2
    local context=${3:-}
    
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # JSON format for parsing
    if command -v jq > /dev/null; then
        jq -n \
            --arg ts "$timestamp" \
            --arg level "$level" \
            --arg msg "$message" \
            --arg ctx "$context" \
            --arg script "$0" \
            --arg pid "$$" \
            '{timestamp: $ts, level: $level, message: $msg, context: $ctx, script: $script, pid: $pid}' >> "$ERROR_LOG.json"
    fi
    
    # Human-readable format
    echo "[$timestamp] [$level] $message${context:+ ($context)}" >&2
}
```

### Debug Mode

```bash
# Enhanced debug mode
enable_debug() {
    export DEBUG=true
    export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:-}: '
    set -x
    
    # Trap for detailed error info
    trap 'debug_error $? $LINENO' ERR
}

debug_error() {
    local exit_code=$1
    local line_number=$2
    
    echo "=== DEBUG ERROR INFO ===" >&2
    echo "Exit code: $exit_code" >&2
    echo "Line: $line_number" >&2
    echo "Function stack:" >&2
    for i in "${!FUNCNAME[@]}"; do
        echo "  $i: ${FUNCNAME[$i]} (${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]})" >&2
    done
    echo "Variables:" >&2
    (set -o posix; set) | grep -E "^[A-Z_]+=" | head -20 >&2
    echo "======================" >&2
}
```

## Recovery Strategies

### Health Checks and Self-Healing

```bash
# System health check
perform_health_check() {
    local checks_passed=0
    local checks_failed=0
    
    # Define health checks
    local checks=(
        "check_disk_space:90"
        "check_memory_usage:80"
        "check_service_status:app"
        "check_config_validity"
        "check_connectivity"
    )
    
    for check in "${checks[@]}"; do
        IFS=: read -r check_func check_arg <<< "$check"
        
        if $check_func "${check_arg:-}"; then
            ((checks_passed++))
            echo "✅ $check_func: OK"
        else
            ((checks_failed++))
            echo "❌ $check_func: FAILED"
            
            # Try to self-heal
            if declare -f "heal_$check_func" > /dev/null; then
                echo "  🔧 Attempting to heal..."
                if "heal_$check_func" "${check_arg:-}"; then
                    echo "  ✅ Healed successfully"
                else
                    echo "  ❌ Healing failed"
                fi
            fi
        fi
    done
    
    echo ""
    echo "Health Check Summary:"
    echo "  Passed: $checks_passed"
    echo "  Failed: $checks_failed"
    
    [[ $checks_failed -eq 0 ]]
}

# Example self-healing function
heal_check_disk_space() {
    local threshold=$1
    
    # Clear caches
    if [[ -d "$HOME/.cache" ]]; then
        find "$HOME/.cache" -type f -mtime +7 -delete
    fi
    
    # Clear old logs
    find "${LOG_DIR:-/var/log}" -name "*.log" -mtime +30 -delete 2>/dev/null || true
    
    # Re-check
    check_disk_space "$threshold"
}
```

### Checkpoint and Resume

```bash
# Checkpoint-based operations
run_with_checkpoints() {
    local operation_id=$1
    local checkpoint_dir="$HOME/.local/checkpoints/$operation_id"
    mkdir -p "$checkpoint_dir"
    
    # Define steps
    local steps=(
        "download_data"
        "validate_data"
        "process_data"
        "generate_output"
        "cleanup"
    )
    
    # Find last completed step
    local start_from=0
    for i in "${!steps[@]}"; do
        if [[ -f "$checkpoint_dir/${steps[$i]}.done" ]]; then
            start_from=$((i + 1))
        else
            break
        fi
    done
    
    # Resume from checkpoint
    echo "Starting from step $((start_from + 1)) of ${#steps[@]}"
    
    for i in $(seq $start_from $((${#steps[@]} - 1))); do
        local step="${steps[$i]}"
        echo "Executing: $step"
        
        if $step; then
            touch "$checkpoint_dir/$step.done"
            echo "✅ Completed: $step"
        else
            echo "❌ Failed at: $step"
            return 1
        fi
    done
    
    # Cleanup checkpoints on success
    rm -rf "$checkpoint_dir"
    echo "✅ Operation completed successfully"
}
```

## Best Practices

1. **Always plan for failure** - Assume operations will fail
2. **Use transactions** - Make operations atomic when possible
3. **Create rollback points** - Before making significant changes
4. **Log everything** - You'll need it for debugging
5. **Fail fast** - Detect problems early
6. **Provide context** - Error messages should be helpful
7. **Clean up on failure** - Don't leave system in bad state
8. **Test error paths** - Error handling code needs testing too
9. **Document recovery** - Users need to know how to recover
10. **Monitor and alert** - Know when things go wrong