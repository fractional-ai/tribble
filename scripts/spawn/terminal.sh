#!/usr/bin/env bash
# Terminal.app spawn implementation
# Creates a new Terminal.app tab/window using AppleScript
#
# Attempts tab creation via Cmd+T keystroke (requires accessibility
# permissions). Falls back to a new window via native `do script`
# if keystroke fails.
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

TTY_PATH=$(osascript - "$FULL_COMMAND" "$DIRECTORY" "$TAB_NAME" 2>&1 <<'APPLESCRIPT'
on run argv
    set theCommand to item 1 of argv
    set theDir to item 2 of argv
    set theName to item 3 of argv

    tell application "Terminal"
        activate
        delay 0.3

        set newTab to missing value

        -- Try to create a tab via keystroke (requires accessibility + existing window)
        if (count of windows) > 0 then
            set oldTTY to tty of selected tab of front window
            try
                tell application "System Events"
                    keystroke "t" using command down
                end tell
                -- Wait for tab to appear (retry up to 2s)
                repeat 10 times
                    delay 0.2
                    if tty of selected tab of front window is not oldTTY then
                        set newTab to selected tab of front window
                        exit repeat
                    end if
                end repeat
            end try
        end if

        -- Fallback: create a new window via native do script
        if newTab is missing value then
            set newTab to do script ""
            delay 0.3
        end if

        set ttyPath to tty of newTab

        -- Note: Terminal.app does not support tab bar coloring.
        -- Tab colors are only available in iTerm2.

        -- Run commands in the new session
        do script "cd \"" & theDir & "\"" in newTab
        -- Set window title using escape sequence
        do script "printf '\\033]0;" & theName & "\\007'" in newTab
        do script theCommand in newTab

        return ttyPath
    end tell
end run
APPLESCRIPT
)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ] && [ -n "$TTY_PATH" ]; then
    # Output session ID (TTY path) to stdout
    echo "$TTY_PATH"
    success_message "$TAB_NAME" "Terminal.app" >&2
    exit 0
else
    print_error_header "Terminal.app" "$TAB_NAME" "$TTY_PATH" >&2
    echo "" >&2
    echo "Common causes:" >&2
    echo "  - Terminal.app is not running" >&2
    echo "  - AppleScript automation permissions not granted" >&2
    echo "" >&2
    echo "To grant automation permissions:" >&2
    echo "  1. Open System Settings > Privacy & Security > Automation" >&2
    echo "  2. Find your terminal/app and enable control of Terminal" >&2
    print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT" >&2
    exit 3
fi
