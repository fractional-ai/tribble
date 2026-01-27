#!/usr/bin/env bash
# Spawn router - detects terminal and dispatches to appropriate implementation
# Usage: spawn/index.sh <tab_name> <command> <directory> [prompt] [color]
#
# Arguments:
#   tab_name   - Descriptive name for the tab
#   command    - Command to execute in the tab
#   directory  - Working directory (absolute path)
#   prompt     - Optional: Initial prompt/input to pipe into the command
#   color      - Optional: Tab color (auto-assigned if not specified)
#
# Exit codes:
#   0 - Success
#   1 - Missing arguments or general error
#   2 - Invalid directory
#   3 - Spawn failure
#   4 - Terminal not supported

set -e

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"
source "$LIB_DIR/common.sh"
source "$LIB_DIR/detect.sh"
source "$LIB_DIR/colors.sh"

# Parse arguments
TAB_NAME="$1"
COMMAND="$2"
DIRECTORY="${3:-$PWD}"
PROMPT="${4:-}"
TAB_COLOR="${5:-}"

# Validate arguments
validate_arguments "$TAB_NAME" "$COMMAND" || exit $?
validate_directory "$DIRECTORY" || exit $?

# Assign color if not provided
if [ -z "$TAB_COLOR" ]; then
    TAB_COLOR=$(get_next_color)
fi

# Detect terminal
TERMINAL_TYPE=$(detect_terminal)

# Check if terminal supports spawn
if ! supports_primitive "$TERMINAL_TYPE" "spawn"; then
    echo "[ERROR] Terminal '$TERMINAL_TYPE' does not support spawn" >&2
    echo "" >&2
    echo "Supported terminals for spawn:" >&2
    list_supported_terminals "spawn" | tr ' ' '\n' | sed 's/^/  - /' >&2
    exit 4
fi

# Prepare command with prompt
FULL_COMMAND=$(prepare_command_with_prompt "$PROMPT" "$COMMAND")

# Export variables for terminal-specific scripts
export TAB_NAME COMMAND DIRECTORY PROMPT TAB_COLOR FULL_COMMAND

# Dispatch to terminal-specific implementation
TERMINAL_SCRIPT="$SCRIPT_DIR/$TERMINAL_TYPE.sh"

if [ -f "$TERMINAL_SCRIPT" ]; then
    exec "$TERMINAL_SCRIPT" "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT" "$TAB_COLOR" "$FULL_COMMAND"
else
    echo "[ERROR] No spawn implementation for terminal: $TERMINAL_TYPE" >&2
    echo "" >&2
    echo "Please manually open a new tab and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 4
fi
