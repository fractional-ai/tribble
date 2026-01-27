#!/usr/bin/env bash
# Terminal detection and capability checking
# This library identifies the running terminal and checks primitive support.

# Detect the current terminal type
# Outputs: Terminal identifier string (tmux, kitty, iterm2, terminal, ghostty, etc.)
# Returns: 0 always (outputs "unknown" for unrecognized terminals)
detect_terminal() {
    # Debug mode - set TRIBBLE_DEBUG=1 to enable
    if [ "$TRIBBLE_DEBUG" = "1" ]; then
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
        echo "DEBUG: GHOSTTY_RESOURCES_DIR=$GHOSTTY_RESOURCES_DIR" >&2
    fi

    # Check for tmux first (can be inside other terminals)
    if [ -n "$TMUX" ]; then
        echo "tmux"
        return 0
    fi

    # Check for Ghostty
    if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
        echo "ghostty"
        return 0
    fi

    # Check for Alacritty
    if [ "$TERM" = "alacritty" ]; then
        echo "alacritty"
        return 0
    fi

    # Check for Kitty
    if [ -n "$KITTY_WINDOW_ID" ]; then
        echo "kitty"
        return 0
    fi

    # Check for VS Code integrated terminal
    if [ "$TERM_PROGRAM" = "vscode" ]; then
        echo "vscode"
        return 0
    fi

    # Check for Warp
    if [ "$WARP_IS_TERMINAL" = "1" ] || [ "$TERM_PROGRAM" = "WarpTerminal" ]; then
        echo "warp"
        return 0
    fi

    # Check for Hyper
    if [ "$TERM_PROGRAM" = "Hyper" ]; then
        echo "hyper"
        return 0
    fi

    # Check for GNOME Terminal (Linux)
    if [ -n "$GNOME_TERMINAL_SERVICE" ] || [ -n "$GNOME_TERMINAL_SCREEN" ]; then
        echo "gnome-terminal"
        return 0
    fi

    # Check for Konsole (KDE)
    if [ -n "$KONSOLE_VERSION" ] || [ -n "$KONSOLE_DBUS_SERVICE" ] || [ -n "$KONSOLE_DBUS_SESSION" ]; then
        echo "konsole"
        return 0
    fi

    # Check for iTerm2
    if [ -n "$ITERM_SESSION_ID" ] || [ "$TERM_PROGRAM" = "iTerm.app" ]; then
        echo "iterm2"
        return 0
    fi

    # Check for Terminal.app
    if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
        echo "terminal"
        return 0
    fi

    # Check for Windows Terminal
    if [ -n "$WT_SESSION" ] || [ -n "$WT_PROFILE_ID" ]; then
        echo "windows-terminal"
        return 0
    fi

    # Check if running on macOS (for AppleScript compatibility)
    if [ "$(uname)" = "Darwin" ]; then
        # Try to detect via process name as fallback
        PARENT_PROCESS=$(ps -o comm= -p $PPID 2>/dev/null || echo "")

        if echo "$PARENT_PROCESS" | grep -qi "iterm"; then
            echo "iterm2"
            return 0
        elif echo "$PARENT_PROCESS" | grep -qi "terminal"; then
            echo "terminal"
            return 0
        fi
    fi

    # Unknown terminal
    echo "unknown"
    return 0
}

# Check if a terminal supports a specific primitive
# Arguments:
#   $1 - terminal type (from detect_terminal)
#   $2 - primitive name (spawn, read, write, list)
# Returns:
#   0 - Supported
#   1 - Not supported
supports_primitive() {
    local terminal="$1"
    local primitive="$2"

    case "$terminal" in
        tmux)
            # tmux supports all primitives
            return 0
            ;;
        kitty)
            # kitty supports all primitives via `kitty @` commands
            return 0
            ;;
        iterm2)
            # iTerm2 supports all primitives via AppleScript
            return 0
            ;;
        terminal)
            # Terminal.app supports all primitives via AppleScript
            return 0
            ;;
        ghostty|gnome-terminal|alacritty)
            # These only support spawn
            if [ "$primitive" = "spawn" ]; then
                return 0
            fi
            return 1
            ;;
        konsole|warp|hyper|vscode|windows-terminal)
            # Limited or no support
            if [ "$primitive" = "spawn" ]; then
                # Some have partial spawn support
                case "$terminal" in
                    gnome-terminal|alacritty)
                        return 0
                        ;;
                esac
            fi
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

# Get list of terminals that support a primitive
# Arguments:
#   $1 - primitive name (spawn, read, write, list)
# Outputs: Space-separated list of terminal names
list_supported_terminals() {
    local primitive="$1"

    case "$primitive" in
        spawn)
            echo "tmux kitty iterm2 terminal ghostty gnome-terminal alacritty"
            ;;
        read|write|list)
            echo "tmux kitty iterm2 terminal"
            ;;
        *)
            echo ""
            ;;
    esac
}
