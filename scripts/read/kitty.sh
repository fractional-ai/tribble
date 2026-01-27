#!/usr/bin/env bash
# Kitty read implementation
# Reads the buffer content from a Kitty window
#
# Session ID format: window ID from kitty @ ls

set -e

SESSION_ID="${1:-$SESSION_ID}"

if [ -z "$SESSION_ID" ]; then
    echo "[ERROR] Missing session_id argument" >&2
    exit 1
fi

if ! command -v kitty &>/dev/null; then
    echo "[ERROR] Kitty not found in PATH" >&2
    exit 3
fi

# Try socket connection first (works without TTY), then fall back to default
KITTY_SOCKET="/tmp/kitty-socket"
if [ -S "$KITTY_SOCKET" ]; then
    KITTY_OPTS="--to unix:$KITTY_SOCKET"
else
    KITTY_OPTS=""
fi

# Get text from the window
# --match filters to the specific window
# --extent all gets all text including scrollback
OUTPUT=$(kitty @ $KITTY_OPTS get-text --match "id:$SESSION_ID" --extent all 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "$OUTPUT"
else
    if echo "$OUTPUT" | grep -qi "no matching"; then
        echo "[ERROR] Window not found: $SESSION_ID" >&2
        exit 2
    else
        echo "[ERROR] Failed to read from Kitty window: $OUTPUT" >&2
        exit 3
    fi
fi
