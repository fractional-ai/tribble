#!/usr/bin/env bash
# Spawns a new tab in GNOME Terminal with a given command
# Usage: spawn-gnome-terminal.sh <tab_name> <command> <directory> [prompt]

set -e

# Parse arguments
TAB_NAME="$1"
COMMAND="$2"
DIRECTORY="${3:-.}"
PROMPT="${4:-}"

# Validate required arguments
if [ -z "$TAB_NAME" ] || [ -z "$COMMAND" ]; then
    echo "[ERROR] Usage: spawn-gnome-terminal.sh <tab_name> <command> <directory> [prompt]" >&2
    exit 1
fi

# Validate directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "[ERROR] Directory '$DIRECTORY' does not exist" >&2
    exit 2
fi

# Build the full command with proper escaping
# We need to:
# 1. Set the tab title using ANSI escape sequence
# 2. Change to the directory
# 3. Execute the command
# 4. Keep the shell open after command completes

# Escape single quotes in the command
COMMAND_ESCAPED="${COMMAND//\'/\'\\\'\'}"

# Build full command that sets title, changes directory, and runs command
FULL_COMMAND="echo -ne '\\033]0;${TAB_NAME}\\007'; cd '${DIRECTORY}' && ${COMMAND}"

# If prompt is provided, pipe it to the command
if [ -n "$PROMPT" ]; then
    PROMPT_ESCAPED=$(printf '%q' "$PROMPT")
    FULL_COMMAND="echo ${PROMPT_ESCAPED} | (${FULL_COMMAND})"
fi

# Spawn new tab in GNOME Terminal
# Using --tab opens a new tab in the existing window
# Using -- followed by bash -c allows us to run our command and keep shell open
if gnome-terminal --tab --working-directory="$DIRECTORY" -- bash -c "$FULL_COMMAND; exec bash" 2>/dev/null; then
    echo "✓ Created tab '$TAB_NAME' in GNOME Terminal"
else
    # Fallback: provide manual instructions
    echo "✗ Failed to create tab in GNOME Terminal" >&2
    echo "" >&2
    echo "Please manually open a new terminal tab and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 3
fi
