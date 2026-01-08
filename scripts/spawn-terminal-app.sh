#!/usr/bin/env bash
# Spawns a new Terminal.app tab with a given name and command
# Usage: spawn-terminal-app.sh <tab_name> <command> <directory> [prompt]
#
# Arguments:
#   tab_name   - Descriptive name for the tab (shown as window title)
#   command    - Command to execute in the tab
#   directory  - Working directory (absolute path)
#   prompt     - Optional: Initial prompt/input to pipe into the command
#
# Exit codes:
#   0 - Success
#   1 - Error (missing arguments, spawn failed, etc.)
#
# Note: Terminal.app doesn't support tab names directly,
#       so we set the window title using ANSI escape sequences

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

# Properly escape for AppleScript by replacing backslash and quote
COMMAND_ESCAPED=$(echo "$FULL_COMMAND" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
TAB_NAME_ESCAPED=$(echo "$TAB_NAME" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')

# Create the AppleScript to spawn tab
# Terminal.app requires using System Events to send Cmd+T
osascript <<EOF
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
    if (count of tabs of front window) ≤ tabCount then
        error "Failed to create new tab"
    end if

    -- Target specific tab instead of assuming front window
    tell tab (count of tabs of front window) of front window
        do script "cd \"$DIRECTORY\""
        do script "printf '\\033]0;$TAB_NAME_ESCAPED\\007'"
        do script "$COMMAND_ESCAPED"
    end tell
end tell
EOF

# Check if spawn was successful
if [ $? -eq 0 ]; then
    success_message "$TAB_NAME" "Terminal.app"
    exit 0
else
    print_error_header "Terminal.app" "$TAB_NAME" ""
    print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT"
    exit 1
fi
