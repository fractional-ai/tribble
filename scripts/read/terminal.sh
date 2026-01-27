#!/usr/bin/env bash
# Terminal.app read implementation
# Reads the buffer content from a Terminal.app tab
#
# Session ID format: TTY path (e.g., /dev/ttys017)

set -e

SESSION_ID="${1:-$SESSION_ID}"

if [ -z "$SESSION_ID" ]; then
    echo "[ERROR] Missing session_id argument" >&2
    exit 1
fi

OUTPUT=$(osascript - "$SESSION_ID" 2>&1 <<'APPLESCRIPT'
on run argv
    set targetTty to item 1 of argv

    tell application "Terminal"
        repeat with w in windows
            repeat with t in tabs of w
                if tty of t is targetTty then
                    -- Get contents (visible text) and history (scrollback)
                    set visibleContent to contents of t
                    set scrollbackHistory to history of t

                    -- Combine scrollback and visible content
                    -- History contains older content, contents has recent
                    return scrollbackHistory & visibleContent
                end if
            end repeat
        end repeat
    end tell

    error "Tab not found for TTY: " & targetTty
end run
APPLESCRIPT
)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "$OUTPUT"
else
    if echo "$OUTPUT" | grep -qi "not found"; then
        echo "[ERROR] Tab not found for TTY: $SESSION_ID" >&2
        exit 2
    else
        echo "[ERROR] Failed to read from Terminal.app: $OUTPUT" >&2
        exit 3
    fi
fi
