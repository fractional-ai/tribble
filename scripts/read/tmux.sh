#!/usr/bin/env bash
# tmux read implementation
# Reads the buffer content from a tmux pane
#
# Session ID format: session:window or session:window.pane

set -e

SESSION_ID="${1:-$SESSION_ID}"

if [ -z "$SESSION_ID" ]; then
    echo "[ERROR] Missing session_id argument" >&2
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

# Capture pane content
# -p prints to stdout
# -S -32768 captures from the very start of the scrollback buffer
tmux capture-pane -t "$SESSION_ID" -p -S -32768
