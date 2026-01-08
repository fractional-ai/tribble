#!/usr/bin/env bash
# Spawns a new tab in Hyper terminal with a given command
# Usage: spawn-hyper.sh <tab_name> <command> <directory> [prompt]
#
# Note: Uses AppleScript as Hyper has no CLI automation API

set -e

# Parse arguments
TAB_NAME="$1"
COMMAND="$2"
DIRECTORY="${3:-.}"
PROMPT="${4:-}"

# Validate required arguments
if [ -z "$TAB_NAME" ] || [ -z "$COMMAND" ]; then
    echo "[ERROR] Usage: spawn-hyper.sh <tab_name> <command> <directory> [prompt]" >&2
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
    # Use AppleScript with System Events to automate Hyper
    # Hyper has no native CLI or AppleScript support, so we simulate keystrokes

    if osascript <<EOF 2>/dev/null
tell application "Hyper"
    activate
end tell

delay 0.3

tell application "System Events"
    tell process "Hyper"
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
        echo "✓ Created tab '$TAB_NAME' in Hyper"
        exit 0
    else
        # Fallback: provide manual instructions
        echo "✗ Failed to create tab in Hyper" >&2
        echo "" >&2
        echo "Common causes:" >&2
        echo "  - Hyper not running" >&2
        echo "  - Accessibility permissions not granted" >&2
        echo "  - System Preferences > Security & Privacy > Privacy > Accessibility" >&2
        echo "" >&2
        echo "Please manually open a new terminal tab and run:" >&2
        echo "  cd \"$DIRECTORY\"" >&2
        echo "  $COMMAND" >&2
        exit 3
    fi
elif [ "$(uname)" = "Linux" ]; then
    # Linux: Hyper is cross-platform but has no automation API
    # We'd need xdotool or similar, but that's fragile
    echo "✗ Hyper automation not supported on Linux" >&2
    echo "" >&2
    echo "Hyper does not provide CLI automation on any platform." >&2
    echo "Consider using a terminal with better automation support:" >&2
    echo "  - Kitty (kitty @ launch)" >&2
    echo "  - GNOME Terminal (gnome-terminal --tab)" >&2
    echo "  - Konsole (konsole --new-tab)" >&2
    echo "" >&2
    echo "Please manually open a new terminal tab and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 3
else
    echo "✗ Unsupported platform: $(uname)" >&2
    exit 3
fi
