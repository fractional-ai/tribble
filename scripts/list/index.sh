#!/usr/bin/env bash
# List router - detects terminal and dispatches to appropriate implementation
# Usage: list/index.sh
#
# Arguments:
#   (none)
#
# Exit codes:
#   0 - Success
#   3 - Operation failed
#   4 - Terminal not supported for this operation
#
# Output:
#   JSON array of sessions on stdout

set -e

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"
source "$LIB_DIR/common.sh"
source "$LIB_DIR/detect.sh"

# Detect terminal
TERMINAL_TYPE=$(detect_terminal)

# Check if terminal is supported
if ! supports_primitive "$TERMINAL_TYPE" "list"; then
    show_unsupported_terminal_message "$TERMINAL_TYPE"
    exit 4
fi

# Dispatch to terminal-specific implementation
TERMINAL_SCRIPT="$SCRIPT_DIR/$TERMINAL_TYPE.sh"

if [ -f "$TERMINAL_SCRIPT" ]; then
    exec "$TERMINAL_SCRIPT"
else
    echo "[ERROR] No list implementation for terminal: $TERMINAL_TYPE" >&2
    exit 4
fi
