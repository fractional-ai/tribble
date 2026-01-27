#!/usr/bin/env bash
# Terminal.app write implementation
# Sends text/command to a Terminal.app tab
#
# Session ID format: TTY path (e.g., /dev/ttys017)

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

# Escape text for AppleScript
TEXT_ESCAPED=$(echo "$TEXT" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')

OUTPUT=$(osascript - "$SESSION_ID" "$TEXT_ESCAPED" 2>&1 <<'APPLESCRIPT'
on run argv
    set targetTty to item 1 of argv
    set textToWrite to item 2 of argv

    tell application "Terminal"
        repeat with w in windows
            repeat with t in tabs of w
                if tty of t is targetTty then
                    -- Execute the text as a script/command in the tab
                    do script textToWrite in t
                    return ""
                end if
            end repeat
        end repeat
    end tell

    error "Tab not found for TTY: " & targetTty
end run
APPLESCRIPT
)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    if echo "$OUTPUT" | grep -qi "not found"; then
        echo "[ERROR] Tab not found for TTY: $SESSION_ID" >&2
        exit 2
    else
        echo "[ERROR] Failed to write to Terminal.app: $OUTPUT" >&2
        exit 3
    fi
fi
