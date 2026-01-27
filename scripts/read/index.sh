#!/usr/bin/env bash
# Read router - detects terminal and dispatches to appropriate implementation
# Usage: read/index.sh <session_id>
#
# Arguments:
#   session_id - The session identifier (format varies by terminal)
#
# Exit codes:
#   0 - Success
#   1 - Missing required arguments
#   2 - Invalid session
#   3 - Operation failed
#   4 - Terminal not supported for this operation
#
# Output:
#   Buffer content on stdout

set -e

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"
source "$LIB_DIR/common.sh"
source "$LIB_DIR/detect.sh"

# Parse arguments
SESSION_ID="$1"

if [ -z "$SESSION_ID" ]; then
    echo "[ERROR] Missing required argument: session_id" >&2
    echo "" >&2
    echo "Usage: $(basename "$0") <session_id>" >&2
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
if ! supports_primitive "$TERMINAL_TYPE" "read"; then
    show_unsupported_terminal_message "$TERMINAL_TYPE"
    exit 4
fi

# Export variables for terminal-specific scripts
export SESSION_ID

# Dispatch to terminal-specific implementation
TERMINAL_SCRIPT="$SCRIPT_DIR/$TERMINAL_TYPE.sh"

if [ -f "$TERMINAL_SCRIPT" ]; then
    exec "$TERMINAL_SCRIPT" "$SESSION_ID"
else
    echo "[ERROR] No read implementation for terminal: $TERMINAL_TYPE" >&2
    exit 4
fi
