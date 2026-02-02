#!/usr/bin/env bash
# GNOME Terminal spawn implementation
# Creates a new GNOME Terminal tab

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
GNOME_FULL_COMMAND="echo -ne '\\033]0;${TAB_NAME}\\007'; cd '${DIRECTORY}' && ${COMMAND}"

if [ -n "$PROMPT" ]; then
    PROMPT_ESCAPED=$(printf '%q' "$PROMPT")
    GNOME_FULL_COMMAND="echo ${PROMPT_ESCAPED} | (${GNOME_FULL_COMMAND})"
fi

if gnome-terminal --tab --working-directory="$DIRECTORY" -- bash -c "$GNOME_FULL_COMMAND; exec bash" 2>/dev/null; then
    # GNOME Terminal doesn't return a session ID
    echo ""
    echo "Created tab '$TAB_NAME' in GNOME Terminal" >&2
    exit 0
else
    echo "[ERROR] Failed to create tab in GNOME Terminal" >&2
    echo "" >&2
    echo "Please manually open a new terminal tab and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 3
fi
