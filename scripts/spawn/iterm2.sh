#!/usr/bin/env bash
# iTerm2 spawn implementation
# Creates a new iTerm2 tab using AppleScript
#
# Session ID format: session GUID from iTerm2

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

# Parse color values to 0-255 range
parse_color_255 "$TAB_COLOR"
RED_255=$COLOR_R
GREEN_255=$COLOR_G
BLUE_255=$COLOR_B

SESSION_ID=$(osascript - "$FULL_COMMAND" "$DIRECTORY" "$TAB_NAME" "$RED_255" "$GREEN_255" "$BLUE_255" 2>&1 <<'APPLESCRIPT'
on run argv
    set theCommand to item 1 of argv
    set theDir to item 2 of argv
    set theName to item 3 of argv
    set tabRed to item 4 of argv as number
    set tabGreen to item 5 of argv as number
    set tabBlue to item 6 of argv as number

    tell application "iTerm2"
        # Check if window exists, create if not
        if (count of windows) = 0 then
            create window with default profile
        end if

        tell current window
            # Store tab count before creating new tab
            set tabCount to count of tabs

            set newTab to (create tab with default profile)
            delay 0.2

            # Verify new tab was created
            if (count of tabs) <= tabCount then
                error "Failed to create tab"
            end if

            tell current session of newTab
                # Get the session ID
                set sessionId to id

                # Set session name and title (both for better persistence)
                set name to theName
                # Set tab color using iTerm2 proprietary escape sequences
                write text "printf '\\e]6;1;bg;red;brightness;" & tabRed & "\\a'"
                write text "printf '\\e]6;1;bg;green;brightness;" & tabGreen & "\\a'"
                write text "printf '\\e]6;1;bg;blue;brightness;" & tabBlue & "\\a'"
                # Set title using escape sequence (persists across commands)
                write text "printf '\\e]0;" & theName & "\\a'"
                write text "clear"
                write text "cd \"" & theDir & "\""
                write text theCommand

                return sessionId
            end tell
        end tell
    end tell
end run
APPLESCRIPT
)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ] && [ -n "$SESSION_ID" ]; then
    # Output session ID to stdout
    echo "$SESSION_ID"
    success_message "$TAB_NAME" "iTerm2" >&2
    exit 0
else
    print_error_header "iTerm2" "$TAB_NAME" "$SESSION_ID" >&2
    echo "" >&2
    echo "Common causes:" >&2
    echo "  - iTerm2 is not running" >&2
    echo "  - Automation permissions not granted" >&2
    echo "  - iTerm2 version incompatible (requires iTerm2 3.0+)" >&2
    echo "" >&2
    echo "To grant automation permissions:" >&2
    echo "  1. Open System Preferences > Security & Privacy > Privacy > Automation" >&2
    echo "  2. Find your terminal application and enable control of iTerm2" >&2
    print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT" >&2
    exit 3
fi
