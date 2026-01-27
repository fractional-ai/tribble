#!/usr/bin/env bash
# Terminal.app list implementation
# Lists all Terminal.app tabs as JSON
#
# Output format:
# [
#   {"id": "/dev/ttys017", "name": "tab-title", "terminal": "terminal", "window": "0", "tab": "0"},
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

    tell application "Terminal"
        set windowIndex to 0
        repeat with w in windows
            set tabIndex to 0
            repeat with t in tabs of w
                set ttyPath to tty of t
                -- Get custom title if set, otherwise use default name
                set tabName to custom title of t
                if tabName is "" then
                    set tabName to "Terminal " & windowIndex & ":" & tabIndex
                end if

                -- Escape any special characters in the name
                set escapedName to my escapeForJson(tabName)

                -- Build JSON object manually
                set jsonObj to "{\"id\":\"" & ttyPath & "\",\"name\":\"" & escapedName & "\",\"terminal\":\"terminal\",\"window\":\"" & windowIndex & "\",\"tab\":\"" & tabIndex & "\"}"
                set end of jsonParts to jsonObj

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

on escapeForJson(theText)
    set escapedText to ""
    repeat with c in theText
        if c is "\"" then
            set escapedText to escapedText & "\\\""
        else if c is "\\" then
            set escapedText to escapedText & "\\\\"
        else
            set escapedText to escapedText & c
        end if
    end repeat
    return escapedText
end escapeForJson
APPLESCRIPT
)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ] && [ -n "$OUTPUT" ]; then
    echo "$OUTPUT"
else
    echo "[]"
fi
