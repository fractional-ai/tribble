#!/usr/bin/env bash
# Spawns a new tab in Warp terminal with a given command
# Usage: spawn-warp.sh <tab_name> <command> <directory> [prompt]
#
# Note: Uses AppleScript on macOS as Warp's CLI automation is limited

set -e

# Parse arguments
TAB_NAME="$1"
COMMAND="$2"
DIRECTORY="${3:-.}"
PROMPT="${4:-}"

# Validate required arguments
if [ -z "$TAB_NAME" ] || [ -z "$COMMAND" ]; then
    echo "[ERROR] Usage: spawn-warp.sh <tab_name> <command> <directory> [prompt]" >&2
    exit 1
fi

# Validate directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "[ERROR] Directory '$DIRECTORY' does not exist" >&2
    exit 2
fi

# Build the full command
COMMAND_ESCAPED="${COMMAND//\'/\'\\\'\'}"
FULL_COMMAND="cd '${DIRECTORY}' && ${COMMAND}"

# If prompt is provided, pipe it to the command
if [ -n "$PROMPT" ]; then
    PROMPT_ESCAPED=$(printf '%q' "$PROMPT")
    FULL_COMMAND="echo ${PROMPT_ESCAPED} | (${FULL_COMMAND})"
fi

# Check if we're on macOS
if [ "$(uname)" = "Darwin" ]; then
    # Method 1: Try URI scheme (opens tab in current directory, but limited command execution)
    # This is experimental and may not work well
    # open "warp://action/new_tab?path=${DIRECTORY}"

    # Method 2: Use AppleScript to automate Warp (more reliable)
    # Warp doesn't have as robust AppleScript support as iTerm2/Terminal.app
    # So we use System Events to simulate keystrokes

    if osascript <<EOF 2>/dev/null
tell application "Warp"
    activate
end tell

delay 0.3

tell application "System Events"
    tell process "Warp"
        # Open new tab with Cmd+T
        keystroke "t" using command down
        delay 0.5

        # Type the cd command
        keystroke "cd '${DIRECTORY}'"
        key code 36  # Enter key
        delay 0.2

        # Type the actual command
        keystroke "${COMMAND}"
        key code 36  # Enter key
    end tell
end tell
EOF
    then
        echo "✓ Created tab '$TAB_NAME' in Warp"
        exit 0
    else
        # Fallback: provide manual instructions
        echo "✗ Failed to create tab in Warp" >&2
        echo "" >&2
        echo "Common causes:" >&2
        echo "  - Warp not running" >&2
        echo "  - Accessibility permissions not granted" >&2
        echo "  - System Preferences > Security & Privacy > Privacy > Accessibility" >&2
        echo "" >&2
        echo "Please manually open a new terminal tab and run:" >&2
        echo "  cd \"$DIRECTORY\"" >&2
        echo "  $COMMAND" >&2
        exit 3
    fi
else
    # Linux: Warp is primarily macOS, but if on Linux, provide instructions
    echo "✗ Warp automation not supported on this platform" >&2
    echo "" >&2
    echo "Please manually open a new terminal tab and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 3
fi
