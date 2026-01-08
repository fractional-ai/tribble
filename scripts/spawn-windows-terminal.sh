#!/usr/bin/env bash
# Spawns a new Windows Terminal tab with a given name and command
# Usage: spawn-windows-terminal.sh <tab_name> <command> <directory> [prompt]
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
#   3 - Windows Terminal command failure
#   4 - Not running on Windows or wt.exe not found

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

# Check if wt.exe is available
if ! command -v wt.exe &> /dev/null; then
    echo "[ERROR] Windows Terminal: wt.exe command not found" >&2
    echo "" >&2
    echo "Windows Terminal is not installed or not in PATH." >&2
    echo "" >&2
    echo "To install Windows Terminal:" >&2
    echo "  1. Open Microsoft Store" >&2
    echo "  2. Search for 'Windows Terminal'" >&2
    echo "  3. Install the app" >&2
    echo "" >&2
    echo "Or download from: https://aka.ms/terminal" >&2
    print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT"
    exit 4
fi

# Prepare command with prompt using shared function
FULL_COMMAND=$(prepare_command_with_prompt "$PROMPT" "$COMMAND")

# Convert WSL path to Windows path if needed
if command -v wslpath &> /dev/null; then
    WIN_DIR=$(wslpath -w "$DIRECTORY" 2>/dev/null || echo "$DIRECTORY")
else
    WIN_DIR="$DIRECTORY"
fi

# Spawn new tab using wt.exe
# Format: wt.exe -w 0 new-tab --title "Tab Name" --startingDirectory "C:\path" bash -c "command"
ERROR_OUTPUT=$(wt.exe -w 0 new-tab --title "$TAB_NAME" --startingDirectory "$WIN_DIR" bash -c "cd \"$DIRECTORY\" && $FULL_COMMAND; exec bash" 2>&1)
EXIT_CODE=$?

# Check if spawn was successful
if [ $EXIT_CODE -eq 0 ]; then
    success_message "$TAB_NAME" "Windows Terminal"
    exit 0
else
    print_error_header "Windows Terminal" "$TAB_NAME" "$ERROR_OUTPUT"
    echo "" >&2
    echo "Common causes:" >&2
    echo "  - Windows Terminal is not running or not installed" >&2
    echo "  - Invalid directory path" >&2
    echo "  - Path conversion issue (WSL to Windows)" >&2
    echo "" >&2
    echo "Troubleshooting:" >&2
    echo "  - Ensure Windows Terminal is installed and in PATH" >&2
    echo "  - Try using a Windows-style path (C:\\Users\\...)" >&2
    echo "  - Check that the directory exists in both WSL and Windows contexts" >&2
    print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT"
    exit 3
fi
