#!/usr/bin/env bash
# Detects the current terminal environment
# Outputs: iterm2, terminal, tmux, alacritty, kitty, vscode, warp, hyper, gnome-terminal, konsole, or unknown
# Always exits with code 0 (errors handled by caller)

set -e

# Debug mode - set PASTA_MAKER_DEBUG=1 to enable
if [ "$PASTA_MAKER_DEBUG" = "1" ]; then
    echo "DEBUG: TERM=$TERM" >&2
    echo "DEBUG: TERM_PROGRAM=$TERM_PROGRAM" >&2
    echo "DEBUG: TMUX=$TMUX" >&2
    echo "DEBUG: PPID=$PPID" >&2
    echo "DEBUG: ITERM_SESSION_ID=$ITERM_SESSION_ID" >&2
    echo "DEBUG: KITTY_WINDOW_ID=$KITTY_WINDOW_ID" >&2
    echo "DEBUG: WARP_IS_TERMINAL=$WARP_IS_TERMINAL" >&2
    echo "DEBUG: GNOME_TERMINAL_SERVICE=$GNOME_TERMINAL_SERVICE" >&2
    echo "DEBUG: VTE_VERSION=$VTE_VERSION" >&2
    echo "DEBUG: KONSOLE_VERSION=$KONSOLE_VERSION" >&2
    echo "DEBUG: KONSOLE_DBUS_SERVICE=$KONSOLE_DBUS_SERVICE" >&2
fi

# Check for tmux first (can be inside other terminals)
if [ -n "$TMUX" ]; then
    echo "tmux"
    exit 0
fi

# Check for Alacritty
if [ "$TERM" = "alacritty" ]; then
    echo "alacritty"
    exit 0
fi

# Check for Kitty
if [ -n "$KITTY_WINDOW_ID" ]; then
    echo "kitty"
    exit 0
fi

# Check for VS Code integrated terminal
if [ "$TERM_PROGRAM" = "vscode" ]; then
    echo "vscode"
    exit 0
fi

# Check for Warp
if [ "$WARP_IS_TERMINAL" = "1" ] || [ "$TERM_PROGRAM" = "WarpTerminal" ]; then
    echo "warp"
    exit 0
fi

# Check for Hyper
if [ "$TERM_PROGRAM" = "Hyper" ]; then
    echo "hyper"
    exit 0
fi

# Check for GNOME Terminal (Linux)
if [ -n "$GNOME_TERMINAL_SERVICE" ] || [ -n "$GNOME_TERMINAL_SCREEN" ]; then
    echo "gnome-terminal"
    exit 0
fi

# Check for Konsole (KDE)
if [ -n "$KONSOLE_VERSION" ] || [ -n "$KONSOLE_DBUS_SERVICE" ] || [ -n "$KONSOLE_DBUS_SESSION" ]; then
    echo "konsole"
    exit 0
fi

# Check for iTerm2
if [ -n "$ITERM_SESSION_ID" ] || [ "$TERM_PROGRAM" = "iTerm.app" ]; then
    echo "iterm2"
    exit 0
fi

# Check for Terminal.app
if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
    echo "terminal"
    exit 0
fi

# Check if running on macOS (for AppleScript compatibility)
if [ "$(uname)" = "Darwin" ]; then
    # Try to detect via process name as fallback
    PARENT_PROCESS=$(ps -o comm= -p $PPID 2>/dev/null || echo "")

    if echo "$PARENT_PROCESS" | grep -qi "iterm"; then
        echo "iterm2"
        exit 0
    elif echo "$PARENT_PROCESS" | grep -qi "terminal"; then
        echo "terminal"
        exit 0
    fi
fi

# Unknown terminal
echo "unknown"
exit 0
