#!/usr/bin/env bash
# tmux spawn implementation
# Creates a new tmux window with the specified command
#
# Session ID format: session:window (e.g., "tribble:0")

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

# Verify we're in a tmux session
if [ -z "$TMUX" ]; then
    echo "[ERROR] tmux Spawn: Not in a tmux session" >&2
    echo "" >&2
    echo "Tribble requires an active tmux session for spawning." >&2
    echo "" >&2
    echo "To start tmux:" >&2
    echo "  tmux new-session -s tribble" >&2
    echo "" >&2
    echo "Or attach to existing:" >&2
    echo "  tmux attach -t tribble" >&2
    echo "" >&2
    echo "Then run Tribble again from within tmux." >&2
    exit 1
fi

# Get current tmux session name
SESSION_NAME=$(tmux display-message -p '#S')

if [ -z "$SESSION_NAME" ]; then
    echo "Error: Could not determine tmux session name" >&2
    exit 1
fi

# Check if window name exists
if tmux list-windows -t "$SESSION_NAME" -F '#{window_name}' | grep -q "^${TAB_NAME}$"; then
    echo "Warning: Window '$TAB_NAME' already exists in session '$SESSION_NAME'" >&2
    echo "Creating anyway (will have duplicate name)..." >&2
fi

# Convert color to hex for tmux
HEX_COLOR=$(color_to_hex "$TAB_COLOR")

# Create new window with name and directory
tmux new-window -t "$SESSION_NAME" -n "$TAB_NAME" -c "$DIRECTORY"

# Give tmux time to process window creation
sleep 0.1

# Get the window index for the session ID
WINDOW_INDEX=$(tmux display-message -t "$SESSION_NAME:$TAB_NAME" -p '#{window_index}')

# Set window pane border color to distinguish it
tmux set-window-option -t "$SESSION_NAME:$TAB_NAME" pane-border-style "fg=$HEX_COLOR" 2>/dev/null || true
tmux set-window-option -t "$SESSION_NAME:$TAB_NAME" pane-active-border-style "fg=$HEX_COLOR" 2>/dev/null || true

# Set window user option for status bar coloring
tmux set-option -w -t "$SESSION_NAME:$TAB_NAME" @tribble_color "$HEX_COLOR" 2>/dev/null || true

# Enable color-aware status format if not already configured
# This format applies per-window color from @tribble_color if set
CURRENT_FORMAT=$(tmux show-options -gv window-status-format 2>/dev/null || echo "")
if [[ "$CURRENT_FORMAT" != *"@tribble_color"* ]]; then
    # Format: if @tribble_color is set, use it as foreground color; otherwise use default
    TRIBBLE_FORMAT='#{?@tribble_color,#[fg=#{@tribble_color}],}#I:#W#{?@tribble_color,#[default],}'
    tmux set-option -g window-status-format "$TRIBBLE_FORMAT" 2>/dev/null || true
    tmux set-option -g window-status-current-format "$TRIBBLE_FORMAT" 2>/dev/null || true
fi

# Send the command to the new window
tmux send-keys -t "$SESSION_NAME:$TAB_NAME" "$FULL_COMMAND" C-m

if [ $? -eq 0 ]; then
    # Output session ID to stdout
    echo "$SESSION_NAME:$WINDOW_INDEX"
    success_message "$TAB_NAME" "tmux session '$SESSION_NAME'" >&2
    exit 0
else
    print_error_header "tmux" "$TAB_NAME" "" >&2
    print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT" >&2
    exit 1
fi
