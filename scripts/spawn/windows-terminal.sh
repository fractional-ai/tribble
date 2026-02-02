#!/usr/bin/env bash
# Windows Terminal spawn implementation
# Creates a new Windows Terminal tab using wt.exe

set -e

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"
source "$LIB_DIR/common.sh"

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
    print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT" >&2
    exit 4
fi

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
    echo ""
    echo "Created tab '$TAB_NAME' in Windows Terminal" >&2
    exit 0
else
    echo "[ERROR] Failed to create tab in Windows Terminal" >&2
    echo "  $ERROR_OUTPUT" >&2
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
    print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT" >&2
    exit 3
fi
