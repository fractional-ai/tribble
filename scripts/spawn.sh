#!/usr/bin/env bash
# Unified spawn script - detects terminal and spawns tab in one call
# Usage: spawn.sh <tab_name> <command> <directory> [prompt] [color]
#
# Arguments:
#   tab_name   - Descriptive name for the tab
#   command    - Command to execute in the tab
#   directory  - Working directory (absolute path)
#   prompt     - Optional: Initial prompt/input to pipe into the command
#   color      - Optional: Tab color (auto-assigned if not specified)
#
# Exit codes:
#   0 - Success
#   1 - Missing arguments or general error
#   2 - Invalid directory
#   3 - Spawn failure
#   4 - Terminal not supported

set -e

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Parse arguments
TAB_NAME="$1"
COMMAND="$2"
DIRECTORY="${3:-$PWD}"
PROMPT="${4:-}"
TAB_COLOR="${5:-}"

# Validate arguments using shared function
validate_arguments "$TAB_NAME" "$COMMAND" || exit $?

# Validate directory using shared function
validate_directory "$DIRECTORY" || exit $?

# ============================================================================
# COLOR PALETTE & ASSIGNMENT
# ============================================================================

# Predefined color palette (RGB values 0-65535 for iTerm2)
# Colors are chosen to be visually distinct and pleasant
declare -a COLOR_PALETTE=(
    "50000,20000,20000"   # Red
    "20000,50000,20000"   # Green
    "20000,20000,50000"   # Blue
    "50000,40000,0"       # Orange
    "40000,0,50000"       # Purple
    "0,45000,50000"       # Cyan
    "50000,20000,40000"   # Pink
    "30000,50000,0"       # Lime
    "0,30000,50000"       # Teal
    "50000,30000,0"       # Amber
)

# State file for tracking current color index
COLOR_STATE_FILE="${TMPDIR:-/tmp}/tribble_color_index"

# Get next color in sequential order (loops through palette)
get_next_color() {
    local current_index=0

    # Read current index from state file if it exists
    if [ -f "$COLOR_STATE_FILE" ]; then
        current_index=$(cat "$COLOR_STATE_FILE" 2>/dev/null || echo "0")
        # Validate it's a number
        if ! [[ "$current_index" =~ ^[0-9]+$ ]]; then
            current_index=0
        fi
    fi

    # Get the color at current index
    local color="${COLOR_PALETTE[$current_index]}"

    # Increment index for next call (loop back to 0 at end)
    local next_index=$(( (current_index + 1) % ${#COLOR_PALETTE[@]} ))

    # Save next index to state file
    echo "$next_index" > "$COLOR_STATE_FILE"

    echo "$color"
}

# Assign color if not provided
if [ -z "$TAB_COLOR" ]; then
    TAB_COLOR=$(get_next_color)
fi

# ============================================================================
# TERMINAL DETECTION
# ============================================================================

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

# Detect the terminal type
TERMINAL_TYPE=$(detect_terminal)

# Prepare command with prompt using shared function
FULL_COMMAND=$(prepare_command_with_prompt "$PROMPT" "$COMMAND")

# ============================================================================
# TERMINAL-SPECIFIC SPAWN LOGIC
# ============================================================================

case "$TERMINAL_TYPE" in

# ----------------------------------------------------------------------------
# iTerm2
# ----------------------------------------------------------------------------
iterm2)
    # Parse color values (format: "r,g,b")
    IFS=',' read -r RED GREEN BLUE <<< "$TAB_COLOR"

    # Convert RGB from 0-65535 to 0-255 for escape sequences
    RED_255=$((RED * 255 / 65535))
    GREEN_255=$((GREEN * 255 / 65535))
    BLUE_255=$((BLUE * 255 / 65535))

    ERROR_OUTPUT=$(osascript - "$FULL_COMMAND" "$DIRECTORY" "$TAB_NAME" "$RED_255" "$GREEN_255" "$BLUE_255" 2>&1 <<'APPLESCRIPT'
on run argv
    set theCommand to item 1 of argv
    set theDir to item 2 of argv
    set theName to item 3 of argv
    set tabRed to item 4 of argv as number
    set tabGreen to item 5 of argv as number
    set tabBlue to item 6 of argv as number

    tell application "iTerm2"
        # Check if window exists, create if not
        if (count of windows) = 0 then
            create window with default profile
        end if

        tell current window
            # Store tab count before creating new tab
            set tabCount to count of tabs

            set newTab to (create tab with default profile)
            delay 0.2

            # Verify new tab was created
            if (count of tabs) ≤ tabCount then
                error "Failed to create tab"
            end if

            tell current session of newTab
                # Set session name and title (both for better persistence)
                set name to theName
                # Set tab color using iTerm2 proprietary escape sequences
                write text "printf '\\e]6;1;bg;red;brightness;" & tabRed & "\\a'"
                write text "printf '\\e]6;1;bg;green;brightness;" & tabGreen & "\\a'"
                write text "printf '\\e]6;1;bg;blue;brightness;" & tabBlue & "\\a'"
                # Set title using escape sequence (persists across commands)
                write text "printf '\\e]0;" & theName & "\\a'"
                write text "clear"
                write text "cd \"" & theDir & "\""
                write text theCommand
            end tell
        end tell
    end tell
end run
APPLESCRIPT
    )
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        success_message "$TAB_NAME" "iTerm2"
        exit 0
    else
        print_error_header "iTerm2" "$TAB_NAME" "$ERROR_OUTPUT"
        echo "" >&2
        echo "Common causes:" >&2
        echo "  - iTerm2 is not running" >&2
        echo "  - Automation permissions not granted" >&2
        echo "  - iTerm2 version incompatible (requires iTerm2 3.0+)" >&2
        echo "" >&2
        echo "To grant automation permissions:" >&2
        echo "  1. Open System Preferences > Security & Privacy > Privacy > Automation" >&2
        echo "  2. Find your terminal application and enable control of iTerm2" >&2
        print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT"
        exit 3
    fi
    ;;

# ----------------------------------------------------------------------------
# Terminal.app
# ----------------------------------------------------------------------------
terminal)
    COMMAND_ESCAPED=$(echo "$FULL_COMMAND" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
    TAB_NAME_ESCAPED=$(echo "$TAB_NAME" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')

    # Create a colored indicator using the first letter of the tab name
    TAB_INITIAL="${TAB_NAME:0:1}"

    osascript <<EOF
-- Check accessibility permissions
tell application "System Events"
    if not UI elements enabled then
        display dialog "This script requires accessibility permissions. Please enable in System Preferences > Security & Privacy > Privacy > Accessibility"
        error "Accessibility permissions not enabled"
    end if
end tell

tell application "Terminal"
    -- Get current tab count to verify new tab creation
    set tabCount to count of tabs of front window

    activate
    tell application "System Events"
        keystroke "t" using command down
    end tell

    delay 0.5

    -- Verify new tab was created
    if (count of tabs of front window) ≤ tabCount then
        error "Failed to create new tab"
    end if

    -- Target specific tab instead of assuming front window
    tell tab (count of tabs of front window) of front window
        do script "cd \"$DIRECTORY\""
        -- Set window title
        do script "printf '\\033]0;$TAB_NAME_ESCAPED\\007'"
        -- Set badge with tab initial (Terminal.app only shows this in some versions)
        do script "printf '\\033]1337;SetBadgeFormat=%s\\007' \$(echo -n '$TAB_INITIAL' | base64)"
        do script "$COMMAND_ESCAPED"
    end tell
end tell
EOF

    if [ $? -eq 0 ]; then
        success_message "$TAB_NAME" "Terminal.app"
        exit 0
    else
        print_error_header "Terminal.app" "$TAB_NAME" ""
        print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT"
        exit 1
    fi
    ;;

# ----------------------------------------------------------------------------
# tmux
# ----------------------------------------------------------------------------
tmux)
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

    # Convert RGB from iTerm format (0-65535) to color256 for tmux
    IFS=',' read -r RED GREEN BLUE <<< "$TAB_COLOR"
    # Convert to 0-255 range
    RED_255=$((RED * 255 / 65535))
    GREEN_255=$((GREEN * 255 / 65535))
    BLUE_255=$((BLUE * 255 / 65535))
    # Format as RGB for tmux (requires tmux 2.9+)
    TMUX_COLOR="colour${RED_255},${GREEN_255},${BLUE_255}"

    # Create new window with name and directory
    tmux new-window -t "$SESSION_NAME" -n "$TAB_NAME" -c "$DIRECTORY"

    # Give tmux time to process window creation
    sleep 0.1

    # Set window pane border color to distinguish it
    tmux set-window-option -t "$SESSION_NAME:$TAB_NAME" pane-border-style "fg=#$(printf "%02x%02x%02x" $RED_255 $GREEN_255 $BLUE_255)" 2>/dev/null || true
    tmux set-window-option -t "$SESSION_NAME:$TAB_NAME" pane-active-border-style "fg=#$(printf "%02x%02x%02x" $RED_255 $GREEN_255 $BLUE_255)" 2>/dev/null || true

    # Send the command to the new window
    # C-m sends a carriage return (Enter key)
    tmux send-keys -t "$SESSION_NAME:$TAB_NAME" "$FULL_COMMAND" C-m

    if [ $? -eq 0 ]; then
        success_message "$TAB_NAME" "tmux session '$SESSION_NAME'"
        exit 0
    else
        print_error_header "tmux" "$TAB_NAME" ""
        print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT"
        exit 1
    fi
    ;;

# ----------------------------------------------------------------------------
# GNOME Terminal
# ----------------------------------------------------------------------------
gnome-terminal)
    COMMAND_ESCAPED="${COMMAND//\'/\'\\\'\'}"
    GNOME_FULL_COMMAND="echo -ne '\\033]0;${TAB_NAME}\\007'; cd '${DIRECTORY}' && ${COMMAND}"

    if [ -n "$PROMPT" ]; then
        PROMPT_ESCAPED=$(printf '%q' "$PROMPT")
        GNOME_FULL_COMMAND="echo ${PROMPT_ESCAPED} | (${GNOME_FULL_COMMAND})"
    fi

    if gnome-terminal --tab --working-directory="$DIRECTORY" -- bash -c "$GNOME_FULL_COMMAND; exec bash" 2>/dev/null; then
        echo "✓ Created tab '$TAB_NAME' in GNOME Terminal"
        exit 0
    else
        echo "✗ Failed to create tab in GNOME Terminal" >&2
        echo "" >&2
        echo "Please manually open a new terminal tab and run:" >&2
        echo "  cd \"$DIRECTORY\"" >&2
        echo "  $COMMAND" >&2
        exit 3
    fi
    ;;

# ----------------------------------------------------------------------------
# Konsole
# ----------------------------------------------------------------------------
konsole)
    # Konsole has limited automation capabilities
    # We'll try using qdbus if available
    if command -v qdbus &>/dev/null; then
        # Try to create new tab via D-Bus
        # This is experimental and may not work on all Konsole versions
        echo "✗ Konsole automation via qdbus not fully supported yet" >&2
        echo "" >&2
        echo "Please manually open a new terminal tab (Ctrl+Shift+T) and run:" >&2
        echo "  cd \"$DIRECTORY\"" >&2
        echo "  $COMMAND" >&2
        exit 4
    else
        echo "✗ Konsole automation requires qdbus" >&2
        echo "" >&2
        echo "Please manually open a new terminal tab (Ctrl+Shift+T) and run:" >&2
        echo "  cd \"$DIRECTORY\"" >&2
        echo "  $COMMAND" >&2
        exit 4
    fi
    ;;

# ----------------------------------------------------------------------------
# Kitty
# ----------------------------------------------------------------------------
kitty)
    COMMAND_ESCAPED="${COMMAND//\'/\'\\\'\'}"
    # Use user's default shell for proper PATH
    USER_SHELL="${SHELL:-/bin/bash}"
    USER_SHELL_NAME=$(basename "$USER_SHELL")
    KITTY_FULL_COMMAND="cd '${DIRECTORY}' && ${COMMAND}; exec $USER_SHELL_NAME"

    if [ -n "$PROMPT" ]; then
        PROMPT_ESCAPED=$(printf '%q' "$PROMPT")
        KITTY_FULL_COMMAND="echo ${PROMPT_ESCAPED} | (cd '${DIRECTORY}' && ${COMMAND}); exec $USER_SHELL_NAME"
    fi

    # Convert RGB from iTerm format (0-65535) to hex format for Kitty
    IFS=',' read -r RED GREEN BLUE <<< "$TAB_COLOR"
    # Convert to 0-255 range and then to hex
    RED_HEX=$(printf "%02x" $((RED * 255 / 65535)))
    GREEN_HEX=$(printf "%02x" $((GREEN * 255 / 65535)))
    BLUE_HEX=$(printf "%02x" $((BLUE * 255 / 65535)))
    KITTY_COLOR="#${RED_HEX}${GREEN_HEX}${BLUE_HEX}"

    if command -v kitty &>/dev/null; then
        # Try socket connection first (works without TTY), then fall back to default
        KITTY_SOCKET="/tmp/kitty-socket"
        if [ -S "$KITTY_SOCKET" ]; then
            KITTY_OPTS="--to unix:$KITTY_SOCKET"
        else
            KITTY_OPTS=""
        fi

        if kitty @ $KITTY_OPTS launch --type=tab --tab-title "$TAB_NAME" --cwd "$DIRECTORY" "$USER_SHELL" -i -c "$KITTY_FULL_COMMAND" 2>/dev/null; then
            # Set tab color using set-tab-color (match most recently created tab)
            kitty @ $KITTY_OPTS set-tab-color -m recent:0 active_fg="$KITTY_COLOR" 2>/dev/null || true
            echo "✓ Created tab '$TAB_NAME' in Kitty"
            exit 0
        else
            echo "✗ Failed to create tab in Kitty" >&2
            echo "" >&2
            echo "Common causes:" >&2
            echo "  - Remote control not enabled in kitty.conf" >&2
            echo "  - Add this line to your kitty.conf:" >&2
            echo "    allow_remote_control yes" >&2
            echo "  - Then restart Kitty" >&2
            echo "" >&2
            echo "  - Not running inside a Kitty window" >&2
            echo "  - Kitty not installed or not in PATH" >&2
            echo "" >&2
            echo "Please manually open a new terminal tab and run:" >&2
            echo "  cd \"$DIRECTORY\"" >&2
            echo "  $COMMAND" >&2
            exit 3
        fi
    else
        echo "✗ Kitty not found in PATH" >&2
        echo "" >&2
        echo "Please manually open a new terminal tab and run:" >&2
        echo "  cd \"$DIRECTORY\"" >&2
        echo "  $COMMAND" >&2
        exit 3
    fi
    ;;

# ----------------------------------------------------------------------------
# Alacritty
# ----------------------------------------------------------------------------
alacritty)
    COMMAND_ESCAPED="${COMMAND//\'/\'\\\'\'}"
    ALACRITTY_FULL_COMMAND="bash -c 'echo -ne \"\\033]0;${TAB_NAME}\\007\"; cd \"${DIRECTORY}\" && ${COMMAND}; exec bash'"

    if [ -n "$PROMPT" ]; then
        PROMPT_ESCAPED=$(printf '%q' "$PROMPT")
        ALACRITTY_FULL_COMMAND="bash -c 'echo ${PROMPT_ESCAPED} | (cd \"${DIRECTORY}\" && ${COMMAND}); exec bash'"
    fi

    if command -v alacritty &>/dev/null; then
        if alacritty msg create-window --working-directory "$DIRECTORY" --title "$TAB_NAME" -e bash -c "cd '$DIRECTORY' && $COMMAND; exec bash" 2>/dev/null; then
            echo "✓ Created window '$TAB_NAME' in Alacritty"
            exit 0
        else
            # Fallback: spawn completely new instance
            if alacritty --working-directory "$DIRECTORY" --title "$TAB_NAME" -e bash -c "cd '$DIRECTORY' && $COMMAND; exec bash" &>/dev/null &
            then
                echo "✓ Created window '$TAB_NAME' in Alacritty (new instance)"
                exit 0
            fi
        fi
    fi

    echo "✗ Failed to create window in Alacritty" >&2
    echo "" >&2
    echo "Common causes:" >&2
    echo "  - Alacritty not installed or not in PATH" >&2
    echo "  - No Alacritty instance running (needed for 'msg' command)" >&2
    echo "" >&2
    echo "Please manually open a new terminal window and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 3
    ;;

# ----------------------------------------------------------------------------
# Warp
# ----------------------------------------------------------------------------
warp)
    echo "✗ Warp terminal automation not yet supported" >&2
    echo "" >&2
    echo "Warp doesn't currently provide a CLI API for creating tabs." >&2
    echo "" >&2
    echo "Please manually open a new terminal tab (Cmd+T) and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 4
    ;;

# ----------------------------------------------------------------------------
# Hyper
# ----------------------------------------------------------------------------
hyper)
    echo "✗ Hyper terminal automation not yet supported" >&2
    echo "" >&2
    echo "Hyper doesn't currently provide a CLI API for creating tabs." >&2
    echo "" >&2
    echo "Please manually open a new terminal tab (Cmd+T) and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 4
    ;;

# ----------------------------------------------------------------------------
# VS Code
# ----------------------------------------------------------------------------
vscode)
    echo "✗ VS Code integrated terminal automation not supported" >&2
    echo "" >&2
    echo "VS Code's integrated terminal has no external CLI API for creating tabs." >&2
    echo "" >&2
    echo "Recommended Solutions:" >&2
    echo "" >&2
    echo "Option 1: Use tmux inside VS Code terminal" >&2
    echo "  1. Start tmux in your VS Code terminal: tmux" >&2
    echo "  2. Run Tribble from within tmux" >&2
    echo "  3. Tribble will create tmux windows (Ctrl+B W to navigate)" >&2
    echo "" >&2
    echo "Option 2: Use an external terminal" >&2
    echo "  - Run Claude Code in iTerm2, Terminal.app, Ghostty, or GNOME Terminal" >&2
    echo "  - Tribble will work seamlessly with native terminal tabs" >&2
    echo "" >&2
    echo "Option 3: Manual execution" >&2
    echo "  Open a new terminal tab manually (Ctrl+Shift+\` or Cmd+T) and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    echo "" >&2
    echo "For more information, see:" >&2
    echo "  https://code.visualstudio.com/docs/terminal/basics" >&2
    exit 4
    ;;

# ----------------------------------------------------------------------------
# Windows Terminal
# ----------------------------------------------------------------------------
windows-terminal)
    echo "✗ Windows Terminal automation not yet fully supported" >&2
    echo "" >&2
    echo "Windows Terminal automation via WSL is experimental." >&2
    echo "" >&2
    echo "Please manually open a new terminal tab (Ctrl+Shift+T) and run:" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    exit 4
    ;;

# ----------------------------------------------------------------------------
# Ghostty
# ----------------------------------------------------------------------------
ghostty)
    if [ "$(uname)" = "Darwin" ]; then
        # macOS: Use AppleScript to create a new tab
        COMMAND_ESCAPED=$(echo "$FULL_COMMAND" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')

        ERROR_OUTPUT=$(osascript - "$COMMAND_ESCAPED" "$DIRECTORY" "$TAB_NAME" 2>&1 <<'APPLESCRIPT'
on run argv
    set theCommand to item 1 of argv
    set theDir to item 2 of argv
    set theName to item 3 of argv

    tell application "Ghostty"
        activate
        set fullCmd to "cd \"" & theDir & "\" && " & theCommand
        create tab command fullCmd
    end tell
end run
APPLESCRIPT
        )
        EXIT_CODE=$?

        if [ $EXIT_CODE -eq 0 ]; then
            success_message "$TAB_NAME" "Ghostty"
            exit 0
        else
            print_error_header "Ghostty" "$TAB_NAME" "$ERROR_OUTPUT"
            echo "" >&2
            echo "Common causes:" >&2
            echo "  - Ghostty is not running" >&2
            echo "  - Automation permissions not granted" >&2
            echo "  - AppleScript support not available (requires recent Ghostty build)" >&2
            echo "" >&2
            echo "To grant automation permissions:" >&2
            echo "  1. Open System Preferences > Security & Privacy > Privacy > Automation" >&2
            echo "  2. Find your terminal application and enable control of Ghostty" >&2
            print_manual_instructions "$TAB_NAME" "$COMMAND" "$DIRECTORY" "$PROMPT"
            exit 3
        fi
    else
        # Linux/other: No CLI API for creating tabs yet
        echo "Ghostty tab automation not yet supported on Linux" >&2
        echo "" >&2
        echo "Ghostty on Linux does not currently provide a CLI API for creating tabs." >&2
        echo "A +new-window action exists but +new-tab is not yet available." >&2
        echo "" >&2
        echo "Please manually open a new terminal tab (Ctrl+Shift+T) and run:" >&2
        echo "  cd \"$DIRECTORY\"" >&2
        echo "  $COMMAND" >&2
        exit 4
    fi
    ;;

# ----------------------------------------------------------------------------
# Unknown terminal
# ----------------------------------------------------------------------------
unknown)
    echo "Your terminal is not supported for automatic tab spawning" >&2
    echo "" >&2
    echo "To run this task manually, open a new tab and run:" >&2
    echo "" >&2
    echo "Task: $TAB_NAME" >&2
    echo "  cd \"$DIRECTORY\"" >&2
    echo "  $COMMAND" >&2
    echo "" >&2
    echo "Supported terminals: iTerm2, Terminal.app, Ghostty, tmux, GNOME Terminal," >&2
    echo "                     Konsole, Alacritty, Kitty, Warp, Hyper, Windows Terminal" >&2
    exit 4
    ;;

*)
    echo "✗ Unexpected terminal type: $TERMINAL_TYPE" >&2
    exit 4
    ;;

esac
