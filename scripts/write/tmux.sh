#!/usr/bin/env bash
# tmux write implementation
# Sends text to a tmux pane
#
# Session ID format: session:window or session:window.pane

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

# Verify we're in a tmux session or can connect to tmux
if [ -z "$TMUX" ] && ! tmux has-session 2>/dev/null; then
    echo "[ERROR] Not in a tmux session and no tmux server running" >&2
    exit 3
fi

# Check if the target exists
if ! tmux has-session -t "$SESSION_ID" 2>/dev/null; then
    # Try as window target
    if ! tmux list-windows -a -F '#{session_name}:#{window_index}' | grep -q "^${SESSION_ID}$"; then
        echo "[ERROR] Session/window not found: $SESSION_ID" >&2
        exit 2
    fi
fi

# Send text to the pane
# This sends the text literally, without executing it
tmux send-keys -t "$SESSION_ID" "$TEXT"

# Send Enter if --enter flag was passed
if [ "$SEND_ENTER" = "true" ]; then
    tmux send-keys -t "$SESSION_ID" C-m
fi
