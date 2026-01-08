#!/usr/bin/env bash
# Spawns a new tab in Kitty terminal with a given command
# Usage: spawn-kitty.sh <tab_name> <command> <directory> [prompt]
#
# IMPORTANT: Requires `allow_remote_control yes` in kitty.conf

set -e

# Parse arguments
TAB_NAME="$1"
COMMAND="$2"
DIRECTORY="${3:-.}"
PROMPT="${4:-}"

# Validate required arguments
if [ -z "$TAB_NAME" ] || [ -z "$COMMAND" ]; then
    echo "[ERROR] Usage: spawn-kitty.sh <tab_name> <command> <directory> [prompt]" >&2
    exit 1
fi

# Validate directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "[ERROR] Directory '$DIRECTORY' does not exist" >&2
    exit 2
fi

# Build the full command
# Escape single quotes in the command
COMMAND_ESCAPED="${COMMAND//\'/\'\\\'\'}"

# Build full command that changes directory, runs task, and keeps shell open
FULL_COMMAND="cd '${DIRECTORY}' && ${COMMAND}; exec bash"

# If prompt is provided, pipe it to the command
if [ -n "$PROMPT" ]; then
    PROMPT_ESCAPED=$(printf '%q' "$PROMPT")
    FULL_COMMAND="echo ${PROMPT_ESCAPED} | (cd '${DIRECTORY}' && ${COMMAND}); exec bash"
fi

# Use Kitty's remote control to launch a new tab
# kitty @ launch --type=tab creates a new tab in the current OS window
if command -v kitty &>/dev/null; then
    # Try using remote control
    if kitty @ launch --type=tab --tab-title "$TAB_NAME" --cwd "$DIRECTORY" bash -c "$FULL_COMMAND" 2>/dev/null; then
        echo "✓ Created tab '$TAB_NAME' in Kitty"
        exit 0
    else
        ERROR_CODE=$?
        # Fallback: provide manual instructions
        echo "✗ Failed to create tab in Kitty" >&2
        echo "" >&2
        echo "Common causes:" >&2
        echo "  - Remote control not enabled in kitty.conf" >&2
        echo "  - Add this line to your kitty.conf:" >&2
        echo "    allow_remote_control yes" >&2
        echo "  - Then restart Kitty" >&2
        echo "" >&2
        echo "  - Not running inside a Kitty window" >&2
        echo "  - Kitty not installed or not in PATH" >&2
        echo "" >&2
        echo "Please manually open a new terminal tab and run:" >&2
        echo "  cd \"$DIRECTORY\"" >&2
        echo "  $COMMAND" >&2
        exit 3
    fi
else
    echo "✗ Kitty not found in PATH" >&2
    echo "" >&2
    echo "Please manually open a new terminal tab and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 3
fi
