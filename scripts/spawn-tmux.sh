#!/usr/bin/env bash
# Spawns a new tmux window with a given name and command
# Usage: spawn-tmux.sh <window_name> <command> <directory> [prompt]
#
# Arguments:
#   window_name - Descriptive name for the window
#   command     - Command to execute in the window
#   directory   - Working directory (absolute path)
#   prompt      - Optional: Initial prompt/input to pipe into the command
#
# Exit codes:
#   0 - Success
#   1 - Error (not in tmux, missing arguments, spawn failed, etc.)

set -e

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

WINDOW_NAME="$1"
COMMAND="$2"
DIRECTORY="${3:-$PWD}"
PROMPT="${4:-}"

# Validate arguments using shared function
validate_arguments "$WINDOW_NAME" "$COMMAND" || exit $?

# Verify we're in a tmux session
if [ -z "$TMUX" ]; then
    echo "Error: Not in a tmux session" >&2
    echo "Please run this from within tmux, or use a different terminal" >&2
    exit 1
fi

# Validate directory using shared function
validate_directory "$DIRECTORY" || exit $?

# Get current tmux session name
SESSION_NAME=$(tmux display-message -p '#S')

if [ -z "$SESSION_NAME" ]; then
    echo "Error: Could not determine tmux session name" >&2
    exit 1
fi

# Check if window name exists
if tmux list-windows -t "$SESSION_NAME" -F '#{window_name}' | grep -q "^${WINDOW_NAME}$"; then
    echo "Warning: Window '$WINDOW_NAME' already exists in session '$SESSION_NAME'" >&2
    echo "Creating anyway (will have duplicate name)..." >&2
fi

# Create new window with name and directory
tmux new-window -t "$SESSION_NAME" -n "$WINDOW_NAME" -c "$DIRECTORY"

# Prepare command with prompt using shared function
FULL_COMMAND=$(prepare_command_with_prompt "$PROMPT" "$COMMAND")

# Give tmux time to process window creation
sleep 0.1

# Send the command to the new window
# C-m sends a carriage return (Enter key)
tmux send-keys -t "$SESSION_NAME:$WINDOW_NAME" "$FULL_COMMAND" C-m

# Check if spawn was successful
if [ $? -eq 0 ]; then
    success_message "$WINDOW_NAME" "tmux session '$SESSION_NAME'"
    exit 0
else
    print_error_header "tmux" "$WINDOW_NAME" ""
    print_manual_instructions "$WINDOW_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT"
    exit 1
fi
