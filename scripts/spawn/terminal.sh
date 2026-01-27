#!/usr/bin/env bash
# Terminal.app spawn implementation
# Creates a new Terminal.app tab using AppleScript
#
# Session ID format: TTY path (e.g., "/dev/ttys017")

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

COMMAND_ESCAPED=$(echo "$FULL_COMMAND" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
TAB_NAME_ESCAPED=$(echo "$TAB_NAME" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')

# Create a colored indicator using the first letter of the tab name
TAB_INITIAL="${TAB_NAME:0:1}"

TTY_PATH=$(osascript <<EOF
-- Check accessibility permissions
tell application "System Events"
    if not UI elements enabled then
        display dialog "This script requires accessibility permissions. Please enable in System Preferences > Security & Privacy > Privacy > Accessibility"
        error "Accessibility permissions not enabled"
    end if
end tell

tell application "Terminal"
    -- Get current tab count to verify new tab creation
    set tabCount to count of tabs of front window

    activate
    tell application "System Events"
        keystroke "t" using command down
    end tell

    delay 0.5

    -- Verify new tab was created
    if (count of tabs of front window) <= tabCount then
        error "Failed to create new tab"
    end if

    -- Target specific tab instead of assuming front window
    tell tab (count of tabs of front window) of front window
        set ttyPath to tty

        do script "cd \"$DIRECTORY\""
        -- Set window title
        do script "printf '\\033]0;$TAB_NAME_ESCAPED\\007'"
        -- Set badge with tab initial (Terminal.app only shows this in some versions)
        do script "printf '\\033]1337;SetBadgeFormat=%s\\007' \$(echo -n '$TAB_INITIAL' | base64)"
        do script "$COMMAND_ESCAPED"

        return ttyPath
    end tell
end tell
EOF
)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ] && [ -n "$TTY_PATH" ]; then
    # Output session ID (TTY path) to stdout
    echo "$TTY_PATH"
    success_message "$TAB_NAME" "Terminal.app" >&2
    exit 0
else
    print_error_header "Terminal.app" "$TAB_NAME" "" >&2
    print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT" >&2
    exit 1
fi
