#!/usr/bin/env bash
# iTerm2 read implementation
# Reads the buffer content from an iTerm2 session
#
# Session ID format: session GUID

set -e

SESSION_ID="${1:-$SESSION_ID}"

if [ -z "$SESSION_ID" ]; then
    echo "[ERROR] Missing session_id argument" >&2
    exit 1
fi

OUTPUT=$(osascript - "$SESSION_ID" 2>&1 <<'APPLESCRIPT'
on run argv
    set targetSessionId to item 1 of argv

    tell application "iTerm2"
        repeat with w in windows
            repeat with t in tabs of w
                repeat with s in sessions of t
                    if id of s is targetSessionId then
                        -- Get the contents (visible text and scrollback)
                        return contents of s
                    end if
                end repeat
            end repeat
        end repeat
    end tell

    error "Session not found: " & targetSessionId
end run
APPLESCRIPT
)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "$OUTPUT"
else
    if echo "$OUTPUT" | grep -qi "not found"; then
        echo "[ERROR] Session not found: $SESSION_ID" >&2
        exit 2
    else
        echo "[ERROR] Failed to read from iTerm2 session: $OUTPUT" >&2
        exit 3
    fi
fi
