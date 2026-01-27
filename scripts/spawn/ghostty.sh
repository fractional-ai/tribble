#!/usr/bin/env bash
# Ghostty spawn implementation
# Creates a new Ghostty tab using AppleScript (macOS only)
#
# Note: Ghostty has limited API - only spawn is supported, not read/write/list

set -e

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"
source "$LIB_DIR/common.sh"
source "$LIB_DIR/colors.sh"

# Arguments passed from router or directly
TAB_NAME="${1:-$TAB_NAME}"
COMMAND="${2:-$COMMAND}"
DIRECTORY="${3:-$DIRECTORY}"
PROMPT="${4:-$PROMPT}"
TAB_COLOR="${5:-$TAB_COLOR}"
FULL_COMMAND="${6:-$FULL_COMMAND}"

# If FULL_COMMAND not set, prepare it
if [ -z "$FULL_COMMAND" ]; then
    FULL_COMMAND=$(prepare_command_with_prompt "$PROMPT" "$COMMAND")
fi

if [ "$(uname)" = "Darwin" ]; then
    # macOS: Use AppleScript to create a new tab
    COMMAND_ESCAPED=$(echo "$FULL_COMMAND" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')

    ERROR_OUTPUT=$(osascript - "$COMMAND_ESCAPED" "$DIRECTORY" "$TAB_NAME" 2>&1 <<'APPLESCRIPT'
on run argv
    set theCommand to item 1 of argv
    set theDir to item 2 of argv
    set theName to item 3 of argv

    tell application "Ghostty"
        activate
        set fullCmd to "cd \"" & theDir & "\" && " & theCommand
        create tab command fullCmd
    end tell
end run
APPLESCRIPT
    )
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        # Ghostty doesn't return a session ID, output empty string
        echo ""
        success_message "$TAB_NAME" "Ghostty" >&2
        exit 0
    else
        print_error_header "Ghostty" "$TAB_NAME" "$ERROR_OUTPUT" >&2
        echo "" >&2
        echo "Common causes:" >&2
        echo "  - Ghostty is not running" >&2
        echo "  - Automation permissions not granted" >&2
        echo "  - AppleScript support not available (requires recent Ghostty build)" >&2
        echo "" >&2
        echo "To grant automation permissions:" >&2
        echo "  1. Open System Preferences > Security & Privacy > Privacy > Automation" >&2
        echo "  2. Find your terminal application and enable control of Ghostty" >&2
        print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT" >&2
        exit 3
    fi
else
    # Linux/other: No CLI API for creating tabs yet
    echo "Ghostty tab automation not yet supported on Linux" >&2
    echo "" >&2
    echo "Ghostty on Linux does not currently provide a CLI API for creating tabs." >&2
    echo "A +new-window action exists but +new-tab is not yet available." >&2
    echo "" >&2
    echo "Please manually open a new terminal tab (Ctrl+Shift+T) and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 4
fi
