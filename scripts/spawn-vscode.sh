#!/usr/bin/env bash
# Spawns a new tab in VS Code integrated terminal
# Usage: spawn-vscode.sh <tab_name> <command> <directory> [prompt]
#
# LIMITATION: VS Code has no external CLI API for creating terminal tabs
# This script provides guidance and recommendations

set -e

# Parse arguments
TAB_NAME="$1"
COMMAND="$2"
DIRECTORY="${3:-.}"
PROMPT="${4:-}"

# Validate required arguments
if [ -z "$TAB_NAME" ] || [ -z "$COMMAND" ]; then
    echo "[ERROR] Usage: spawn-vscode.sh <tab_name> <command> <directory> [prompt]" >&2
    exit 1
fi

# Validate directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "[ERROR] Directory '$DIRECTORY' does not exist" >&2
    exit 2
fi

# VS Code integrated terminal cannot be automated from external scripts
echo "✗ VS Code integrated terminal automation not supported" >&2
echo "" >&2
echo "VS Code's integrated terminal has no external CLI API for creating tabs." >&2
echo "" >&2
echo "Recommended Solutions:" >&2
echo "" >&2
echo "Option 1: Use tmux inside VS Code terminal" >&2
echo "  1. Start tmux in your VS Code terminal: tmux" >&2
echo "  2. Run pasta-maker from within tmux" >&2
echo "  3. pasta-maker will create tmux windows (Ctrl+B W to navigate)" >&2
echo "" >&2
echo "Option 2: Use an external terminal" >&2
echo "  - Run Claude Code in iTerm2, Terminal.app, or GNOME Terminal" >&2
echo "  - pasta-maker will work seamlessly with native terminal tabs" >&2
echo "" >&2
echo "Option 3: Manual execution" >&2
echo "  Open a new terminal tab manually (Ctrl+Shift+\` or Cmd+T) and run:" >&2
echo "  cd \"$DIRECTORY\"" >&2
echo "  $COMMAND" >&2
echo "" >&2
echo "For more information, see:" >&2
echo "  https://code.visualstudio.com/docs/terminal/basics" >&2

exit 4
