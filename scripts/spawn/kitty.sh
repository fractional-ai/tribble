#!/usr/bin/env bash
# Kitty spawn implementation
# Creates a new Kitty tab using `kitty @` remote control
#
# Session ID format: window ID from kitty @ ls (e.g., "1")

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

COMMAND_ESCAPED="${COMMAND//\'/\'\\\'\'}"
# Use user's default shell for proper PATH
USER_SHELL="${SHELL:-/bin/bash}"
USER_SHELL_NAME=$(basename "$USER_SHELL")
KITTY_FULL_COMMAND="cd '${DIRECTORY}' && ${COMMAND}; exec $USER_SHELL_NAME"

if [ -n "$PROMPT" ]; then
    PROMPT_ESCAPED=$(printf '%q' "$PROMPT")
    KITTY_FULL_COMMAND="echo ${PROMPT_ESCAPED} | (cd '${DIRECTORY}' && ${COMMAND}); exec $USER_SHELL_NAME"
fi

# Convert color to hex for Kitty
KITTY_COLOR=$(color_to_hex "$TAB_COLOR")

if ! command -v kitty &>/dev/null; then
    echo "[ERROR] Kitty not found in PATH" >&2
    echo "" >&2
    echo "Please manually open a new terminal tab and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 3
fi

# Try socket connection first (works without TTY), then fall back to default
KITTY_SOCKET="/tmp/kitty-socket"
if [ -S "$KITTY_SOCKET" ]; then
    KITTY_OPTS="--to unix:$KITTY_SOCKET"
else
    KITTY_OPTS=""
fi

# Launch tab and capture the window ID
WINDOW_ID=$(kitty @ $KITTY_OPTS launch --type=tab --tab-title "$TAB_NAME" --cwd "$DIRECTORY" "$USER_SHELL" -i -c "$KITTY_FULL_COMMAND" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$WINDOW_ID" ]; then
    # Set tab color using set-tab-color (match most recently created tab)
    kitty @ $KITTY_OPTS set-tab-color -m recent:0 active_fg="$KITTY_COLOR" inactive_fg="$KITTY_COLOR" 2>/dev/null || true

    # Output session ID to stdout
    echo "$WINDOW_ID"
    echo "Created tab '$TAB_NAME' in Kitty" >&2
    exit 0
else
    echo "[ERROR] Failed to create tab in Kitty" >&2
    echo "" >&2
    echo "Common causes:" >&2
    echo "  - Remote control not enabled in kitty.conf" >&2
    echo "  - Add this line to your kitty.conf:" >&2
    echo "    allow_remote_control yes" >&2
    echo "  - Then restart Kitty" >&2
    echo "" >&2
    echo "  - Not running inside a Kitty window" >&2
    echo "  - Kitty not installed or not in PATH" >&2
    echo "" >&2
    echo "Please manually open a new terminal tab and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 3
fi
