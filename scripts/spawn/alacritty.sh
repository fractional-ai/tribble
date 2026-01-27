#!/usr/bin/env bash
# Alacritty spawn implementation
# Creates a new Alacritty window (Alacritty doesn't support tabs)
#
# Note: Alacritty has limited API - only spawn is supported

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

COMMAND_ESCAPED="${COMMAND//\'/\'\\\'\'}"
ALACRITTY_FULL_COMMAND="bash -c 'echo -ne \"\\033]0;${TAB_NAME}\\007\"; cd \"${DIRECTORY}\" && ${COMMAND}; exec bash'"

if [ -n "$PROMPT" ]; then
    PROMPT_ESCAPED=$(printf '%q' "$PROMPT")
    ALACRITTY_FULL_COMMAND="bash -c 'echo ${PROMPT_ESCAPED} | (cd \"${DIRECTORY}\" && ${COMMAND}); exec bash'"
fi

if ! command -v alacritty &>/dev/null; then
    echo "[ERROR] Alacritty not found in PATH" >&2
    echo "" >&2
    echo "Please manually open a new terminal window and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 3
fi

if alacritty msg create-window --working-directory "$DIRECTORY" --title "$TAB_NAME" -e bash -c "cd '$DIRECTORY' && $COMMAND; exec bash" 2>/dev/null; then
    # Alacritty msg doesn't return a session ID
    echo ""
    echo "Created window '$TAB_NAME' in Alacritty" >&2
    exit 0
else
    # Fallback: spawn completely new instance
    if alacritty --working-directory "$DIRECTORY" --title "$TAB_NAME" -e bash -c "cd '$DIRECTORY' && $COMMAND; exec bash" &>/dev/null &
    then
        echo ""
        echo "Created window '$TAB_NAME' in Alacritty (new instance)" >&2
        exit 0
    fi
fi

echo "[ERROR] Failed to create window in Alacritty" >&2
echo "" >&2
echo "Common causes:" >&2
echo "  - Alacritty not installed or not in PATH" >&2
echo "  - No Alacritty instance running (needed for 'msg' command)" >&2
echo "" >&2
echo "Please manually open a new terminal window and run:" >&2
echo "  cd \"$DIRECTORY\"" >&2
echo "  $COMMAND" >&2
exit 3
