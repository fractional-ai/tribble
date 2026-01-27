#!/usr/bin/env bash
# Write router - detects terminal and dispatches to appropriate implementation
# Usage: write/index.sh <session_id> <text>
#
# Arguments:
#   session_id - The session identifier (format varies by terminal)
#   text       - The text to write/send to the session
#
# Exit codes:
#   0 - Success
#   1 - Missing required arguments
#   2 - Invalid session
#   3 - Operation failed
#   4 - Terminal not supported for this operation
#
# Output:
#   Empty on success

set -e

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"
source "$LIB_DIR/common.sh"
source "$LIB_DIR/detect.sh"

# Parse arguments
SEND_ENTER=true
SESSION_ID=""
TEXT=""

while [ $# -gt 0 ]; do
    case "$1" in
        --no-enter|-n)
            SEND_ENTER=false
            shift
            ;;
        *)
            if [ -z "$SESSION_ID" ]; then
                SESSION_ID="$1"
            elif [ -z "$TEXT" ]; then
                TEXT="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$SESSION_ID" ] || [ -z "$TEXT" ]; then
    echo "[ERROR] Missing required arguments" >&2
    echo "" >&2
    echo "Usage: $(basename "$0") [--no-enter|-n] <session_id> <text>" >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  session_id - Target session (format varies by terminal)" >&2
    echo "  text       - Text to send to the session" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --no-enter, -n  Don't send Enter/Return after the text" >&2
    echo "" >&2
    echo "Session ID formats by terminal:" >&2
    echo "  tmux:     session:window (e.g., tribble:0)" >&2
    echo "  kitty:    window ID (e.g., 1)" >&2
    echo "  iTerm2:   session GUID" >&2
    echo "  Terminal: TTY path (e.g., /dev/ttys017)" >&2
    exit 1
fi

# Detect terminal
TERMINAL_TYPE=$(detect_terminal)

# Check if terminal is supported
if ! supports_primitive "$TERMINAL_TYPE" "write"; then
    show_unsupported_terminal_message "$TERMINAL_TYPE"
    exit 4
fi

# Export variables for terminal-specific scripts
export SESSION_ID TEXT SEND_ENTER

# Dispatch to terminal-specific implementation
TERMINAL_SCRIPT="$SCRIPT_DIR/$TERMINAL_TYPE.sh"

if [ -f "$TERMINAL_SCRIPT" ]; then
    exec "$TERMINAL_SCRIPT" "$SESSION_ID" "$TEXT"
else
    echo "[ERROR] No write implementation for terminal: $TERMINAL_TYPE" >&2
    exit 4
fi
