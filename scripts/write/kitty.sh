#!/usr/bin/env bash
# Kitty write implementation
# Sends text to a Kitty window
#
# Session ID format: window ID from kitty @ ls

set -e

SESSION_ID="${1:-$SESSION_ID}"
TEXT="${2:-$TEXT}"

if [ -z "$SESSION_ID" ]; then
    echo "[ERROR] Missing session_id argument" >&2
    exit 1
fi

if [ -z "$TEXT" ]; then
    echo "[ERROR] Missing text argument" >&2
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

# Send text to the window
OUTPUT=$(kitty @ $KITTY_OPTS send-text --match "id:$SESSION_ID" "$TEXT" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    if echo "$OUTPUT" | grep -qi "no matching"; then
        echo "[ERROR] Window not found: $SESSION_ID" >&2
        exit 2
    else
        echo "[ERROR] Failed to write to Kitty window: $OUTPUT" >&2
        exit 3
    fi
fi

# Send Enter if --enter flag was passed
if [ "$SEND_ENTER" = "true" ]; then
    kitty @ $KITTY_OPTS send-text --match "id:$SESSION_ID" $'\r' 2>/dev/null
fi
