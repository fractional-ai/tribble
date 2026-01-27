#!/usr/bin/env bash
# Kitty list implementation
# Lists all Kitty windows/tabs as JSON
#
# Output format:
# [
#   {"id": "1", "name": "tab-title", "terminal": "kitty", "tab_id": "1"},
#   ...
# ]

set -e

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"
source "$LIB_DIR/common.sh"

if ! command -v kitty &>/dev/null; then
    echo "[]"
    exit 0
fi

# Try socket connection first (works without TTY), then fall back to default
KITTY_SOCKET="/tmp/kitty-socket"
if [ -S "$KITTY_SOCKET" ]; then
    KITTY_OPTS="--to unix:$KITTY_SOCKET"
else
    KITTY_OPTS=""
fi

# Get Kitty's native JSON output
KITTY_JSON=$(kitty @ $KITTY_OPTS ls 2>/dev/null || echo "[]")

if [ "$KITTY_JSON" = "[]" ] || [ -z "$KITTY_JSON" ]; then
    echo "[]"
    exit 0
fi

# Transform Kitty's JSON to our format using a simple approach
# Kitty ls returns nested structure: os_windows -> tabs -> windows
# We want to extract window IDs and tab titles

# Use Python if available for reliable JSON parsing, otherwise use basic extraction
if command -v python3 &>/dev/null; then
    python3 << PYTHON_EOF
import json
import sys

try:
    data = json.loads('''$KITTY_JSON''')
    result = []

    for os_window in data:
        for tab in os_window.get('tabs', []):
            tab_id = str(tab.get('id', ''))
            tab_title = tab.get('title', '')

            for window in tab.get('windows', []):
                window_id = str(window.get('id', ''))
                window_title = window.get('title', '') or tab_title

                result.append({
                    'id': window_id,
                    'name': window_title,
                    'terminal': 'kitty',
                    'tab_id': tab_id
                })

    print(json.dumps(result))
except Exception as e:
    print('[]')
PYTHON_EOF
else
    # Fallback: just output empty array if no Python
    echo "[]"
fi
