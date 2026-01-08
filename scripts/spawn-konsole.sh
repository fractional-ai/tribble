#!/usr/bin/env bash
# Spawns a new tab in Konsole with a given command
# Usage: spawn-konsole.sh <tab_name> <command> <directory> [prompt]
#
# IMPORTANT: This requires Konsole to be configured with:
# Settings > Configure Konsole > General > "Run all Konsole windows in a single process"

set -e

# Parse arguments
TAB_NAME="$1"
COMMAND="$2"
DIRECTORY="${3:-.}"
PROMPT="${4:-}"

# Validate required arguments
if [ -z "$TAB_NAME" ] || [ -z "$COMMAND" ]; then
    echo "[ERROR] Usage: spawn-konsole.sh <tab_name> <command> <directory> [prompt]" >&2
    exit 1
fi

# Validate directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "[ERROR] Directory '$DIRECTORY' does not exist" >&2
    exit 2
fi

# Build the full command
# We need to:
# 1. Change to the directory
# 2. Set the tab title using ANSI escape sequence
# 3. Execute the command
# 4. Keep the shell open after command completes

# Escape single quotes in the command
COMMAND_ESCAPED="${COMMAND//\'/\'\\\'\'}"

# Build full command that changes directory, sets title, and runs command
FULL_COMMAND="cd '${DIRECTORY}' && echo -ne '\\033]0;${TAB_NAME}\\007' && ${COMMAND}"

# If prompt is provided, pipe it to the command
if [ -n "$PROMPT" ]; then
    PROMPT_ESCAPED=$(printf '%q' "$PROMPT")
    FULL_COMMAND="echo ${PROMPT_ESCAPED} | (${FULL_COMMAND})"
fi

# Spawn new tab in Konsole
# Using --new-tab creates a tab in the existing window (requires single process mode)
# Using -e runs the command, appending ; exec bash keeps the shell open
if konsole --new-tab -e bash -c "$FULL_COMMAND; exec bash" 2>/dev/null; then
    echo "✓ Created tab '$TAB_NAME' in Konsole"
else
    ERROR_CODE=$?
    # Fallback: provide manual instructions
    echo "✗ Failed to create tab in Konsole" >&2
    echo "" >&2

    if [ $ERROR_CODE -eq 127 ]; then
        echo "Konsole doesn't appear to be installed." >&2
    else
        echo "Common causes:" >&2
        echo "  - Konsole not configured for single process mode" >&2
        echo "  - Go to: Settings > Configure Konsole > General" >&2
        echo "  - Enable: 'Run all Konsole windows in a single process'" >&2
    fi

    echo "" >&2
    echo "Please manually open a new terminal tab and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 3
fi
