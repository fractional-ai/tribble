#!/usr/bin/env bash
# iTerm2 list implementation
# Lists all iTerm2 sessions as JSON
#
# Output format:
# [
#   {"id": "session-guid", "name": "session-name", "terminal": "iterm2", "window": "0", "tab": "0"},
#   ...
# ]

set -e

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"
source "$LIB_DIR/common.sh"

OUTPUT=$(osascript 2>&1 <<'APPLESCRIPT'
on run
    set jsonParts to {}

    tell application "iTerm2"
        set windowIndex to 0
        repeat with w in windows
            set tabIndex to 0
            repeat with t in tabs of w
                repeat with s in sessions of t
                    set sessionId to id of s
                    set sessionName to name of s

                    -- Build JSON object manually
                    set jsonObj to "{\"id\":\"" & sessionId & "\",\"name\":\"" & sessionName & "\",\"terminal\":\"iterm2\",\"window\":\"" & windowIndex & "\",\"tab\":\"" & tabIndex & "\"}"
                    set end of jsonParts to jsonObj
                end repeat
                set tabIndex to tabIndex + 1
            end repeat
            set windowIndex to windowIndex + 1
        end repeat
    end tell

    -- Join with commas
    if (count of jsonParts) = 0 then
        return "[]"
    end if

    set AppleScript's text item delimiters to ","
    set jsonArray to "[" & (jsonParts as text) & "]"
    set AppleScript's text item delimiters to ""

    return jsonArray
end run
APPLESCRIPT
)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ] && [ -n "$OUTPUT" ]; then
    echo "$OUTPUT"
else
    echo "[]"
fi
