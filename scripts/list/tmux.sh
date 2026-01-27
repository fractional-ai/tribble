#!/usr/bin/env bash
# tmux list implementation
# Lists all tmux windows as JSON
#
# Output format:
# [
#   {"id": "session:0", "name": "window-name", "terminal": "tmux", "session": "session-name"},
#   ...
# ]

set -e

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"
source "$LIB_DIR/common.sh"

# Verify tmux is available
if [ -z "$TMUX" ] && ! tmux has-session 2>/dev/null; then
    echo "[]"
    exit 0
fi

# Get all windows across all sessions
WINDOWS=$(tmux list-windows -a -F '#{session_name}:#{window_index}	#{window_name}	#{session_name}' 2>/dev/null || echo "")

if [ -z "$WINDOWS" ]; then
    echo "[]"
    exit 0
fi

# Build JSON array
FIRST=true
echo -n "["

while IFS=$'\t' read -r id name session; do
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo -n ","
    fi

    # Escape values for JSON
    id_escaped=$(json_escape "$id")
    name_escaped=$(json_escape "$name")
    session_escaped=$(json_escape "$session")

    echo -n "{\"id\":\"$id_escaped\",\"name\":\"$name_escaped\",\"terminal\":\"tmux\",\"session\":\"$session_escaped\"}"
done <<< "$WINDOWS"

echo "]"
