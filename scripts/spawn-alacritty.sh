#!/usr/bin/env bash
# Spawns a new window in Alacritty with a given command
# Usage: spawn-alacritty.sh <tab_name> <command> <directory> [prompt]
#
# Note: Alacritty doesn't support tabs, so this creates a new window instance

set -e

# Parse arguments
TAB_NAME="$1"
COMMAND="$2"
DIRECTORY="${3:-.}"
PROMPT="${4:-}"

# Validate required arguments
if [ -z "$TAB_NAME" ] || [ -z "$COMMAND" ]; then
    echo "[ERROR] Usage: spawn-alacritty.sh <tab_name> <command> <directory> [prompt]" >&2
    exit 1
fi

# Validate directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "[ERROR] Directory '$DIRECTORY' does not exist" >&2
    exit 2
fi

# Build the full command
# Alacritty msg create-window can use --working-directory and -e to execute commands
# We'll set the window title and execute the command

# Escape single quotes in the command
COMMAND_ESCAPED="${COMMAND//\'/\'\\\'\'}"

# Build full command that runs the task and keeps shell open
FULL_COMMAND="bash -c 'echo -ne \"\\033]0;${TAB_NAME}\\007\"; cd \"${DIRECTORY}\" && ${COMMAND}; exec bash'"

# If prompt is provided, pipe it to the command
if [ -n "$PROMPT" ]; then
    PROMPT_ESCAPED=$(printf '%q' "$PROMPT")
    FULL_COMMAND="bash -c 'echo ${PROMPT_ESCAPED} | (cd \"${DIRECTORY}\" && ${COMMAND}); exec bash'"
fi

# Try to create window using alacritty msg (faster, uses existing instance)
if command -v alacritty &>/dev/null; then
    if alacritty msg create-window --working-directory "$DIRECTORY" --title "$TAB_NAME" -e bash -c "cd '$DIRECTORY' && $COMMAND; exec bash" 2>/dev/null; then
        echo "✓ Created window '$TAB_NAME' in Alacritty"
        exit 0
    else
        # Fallback: spawn completely new instance
        if alacritty --working-directory "$DIRECTORY" --title "$TAB_NAME" -e bash -c "cd '$DIRECTORY' && $COMMAND; exec bash" &>/dev/null &
        then
            echo "✓ Created window '$TAB_NAME' in Alacritty (new instance)"
            exit 0
        fi
    fi
fi

# Fallback: provide manual instructions
echo "✗ Failed to create window in Alacritty" >&2
echo "" >&2
echo "Common causes:" >&2
echo "  - Alacritty not installed or not in PATH" >&2
echo "  - No Alacritty instance running (needed for 'msg' command)" >&2
echo "" >&2
echo "Please manually open a new terminal window and run:" >&2
echo "  cd \"$DIRECTORY\"" >&2
echo "  $COMMAND" >&2
exit 3
