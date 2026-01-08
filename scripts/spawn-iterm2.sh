#!/usr/bin/env bash
# Spawns a new iTerm2 tab with a given name and command
# Usage: spawn-iterm2.sh <tab_name> <command> <directory> [prompt]
#
# Arguments:
#   tab_name   - Descriptive name for the tab
#   command    - Command to execute in the tab
#   directory  - Working directory (absolute path)
#   prompt     - Optional: Initial prompt/input to pipe into the command
#
# Exit codes:
#   0 - Success
#   1 - Missing arguments
#   2 - Invalid directory
#   3 - AppleScript failure
#   4 - iTerm2 not running

set -e

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

TAB_NAME="$1"
COMMAND="$2"
DIRECTORY="${3:-$PWD}"
PROMPT="${4:-}"

# Validate arguments using shared function
validate_arguments "$TAB_NAME" "$COMMAND" || exit $?

# Validate directory using shared function
validate_directory "$DIRECTORY" || exit $?

# Prepare command with prompt using shared function
FULL_COMMAND=$(prepare_command_with_prompt "$PROMPT" "$COMMAND")

# Create the AppleScript to spawn tab with improved error handling
# Note: Using AppleScript's argv for proper escaping instead of string interpolation
ERROR_OUTPUT=$(osascript - "$FULL_COMMAND" "$DIRECTORY" "$TAB_NAME" 2>&1 <<'APPLESCRIPT'
on run argv
    set theCommand to item 1 of argv
    set theDir to item 2 of argv
    set theName to item 3 of argv

    tell application "iTerm2"
        # Check if window exists, create if not
        if (count of windows) = 0 then
            create window with default profile
        end if

        tell current window
            # Store tab count before creating new tab
            set tabCount to count of tabs

            create tab with default profile
            delay 0.2

            # Verify new tab was created
            if (count of tabs) ≤ tabCount then
                error "Failed to create tab"
            end if

            tell current session
                set name to theName
                write text "cd \"" & theDir & "\""
                write text theCommand
            end tell
        end tell
    end tell
end run
APPLESCRIPT
)
EXIT_CODE=$?

# Check if spawn was successful
if [ $EXIT_CODE -eq 0 ]; then
    success_message "$TAB_NAME" "iTerm2"
    exit 0
else
    print_error_header "iTerm2" "$TAB_NAME" "$ERROR_OUTPUT"
    echo "" >&2
    echo "Common causes:" >&2
    echo "  - iTerm2 is not running" >&2
    echo "  - Automation permissions not granted" >&2
    echo "  - iTerm2 version incompatible (requires iTerm2 3.0+)" >&2
    echo "" >&2
    echo "To grant automation permissions:" >&2
    echo "  1. Open System Preferences > Security & Privacy > Privacy > Automation" >&2
    echo "  2. Find your terminal application and enable control of iTerm2" >&2
    print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT"
    exit 3
fi
