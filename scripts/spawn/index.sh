#!/usr/bin/env bash
# Spawn router - detects terminal and dispatches to appropriate implementation
#
# Usage:
#   spawn.sh "Your prompt here"              # Claude session (common case)
#   spawn.sh --cmd "npm test"                # Shell command
#
# Optional flags:
#   --name "Tab Name"    Tab name (auto-generated from prompt if not provided)
#   --dir /path          Working directory (defaults to current)
#   --color red          Tab color (auto-assigned if not provided)
#   --cmd "command"      Run shell command instead of Claude
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

# Defaults
COMMAND="claude"
DIRECTORY="$PWD"
TAB_NAME=""
TAB_COLOR=""
PROMPT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cmd|--command)
            COMMAND="$2"
            shift 2
            ;;
        --name)
            TAB_NAME="$2"
            shift 2
            ;;
        --dir|--directory)
            DIRECTORY="$2"
            shift 2
            ;;
        --color)
            TAB_COLOR="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: spawn.sh \"Your prompt here\"              # Claude session"
            echo "       spawn.sh --cmd \"npm test\"                 # Shell command"
            echo ""
            echo "Optional flags:"
            echo "  --name \"Tab Name\"    Tab name (auto-generated if not provided)"
            echo "  --dir /path          Working directory (defaults to current)"
            echo "  --color red          Tab color (auto-assigned if not provided)"
            echo "  --cmd \"command\"      Run shell command instead of Claude"
            exit 0
            ;;
        --*)
            echo "[ERROR] Unknown flag: $1" >&2
            echo "Run 'spawn.sh --help' for usage" >&2
            exit 1
            ;;
        *)
            # Positional argument = prompt (for Claude sessions)
            if [ -z "$PROMPT" ]; then
                PROMPT="$1"
            else
                echo "[ERROR] Unexpected argument: $1" >&2
                echo "Run 'spawn.sh --help' for usage" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate: need either a prompt (for Claude) or a command (for shell)
if [ -z "$PROMPT" ] && [ "$COMMAND" = "claude" ]; then
    echo "[ERROR] Missing prompt" >&2
    echo "" >&2
    echo "Usage: spawn.sh \"Your prompt here\"" >&2
    echo "       spawn.sh --cmd \"npm test\"" >&2
    exit 1
fi

# Auto-generate tab name from prompt or command if not provided
if [ -z "$TAB_NAME" ]; then
    if [ -n "$PROMPT" ]; then
        # Use first ~30 chars of prompt, cleaned up
        TAB_NAME=$(echo "$PROMPT" | head -c 30 | tr '\n' ' ' | sed 's/  */ /g' | sed 's/ *$//')
        [ ${#PROMPT} -gt 30 ] && TAB_NAME="${TAB_NAME}..."
    else
        # Use command as tab name
        TAB_NAME="$COMMAND"
    fi
fi

# Sanitize tab name
TAB_NAME=$(sanitize_tab_name "$TAB_NAME")

# Validate directory
validate_directory "$DIRECTORY" || exit $?

# Assign color if not provided
if [ -z "$TAB_COLOR" ]; then
    TAB_COLOR=$(get_next_color)
fi

# Detect terminal
TERMINAL_TYPE=$(detect_terminal)

# Check if terminal is supported
if ! is_terminal_supported "$TERMINAL_TYPE"; then
    show_unsupported_terminal_message "$TERMINAL_TYPE"
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
