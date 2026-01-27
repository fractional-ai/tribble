#!/usr/bin/env bash
# Write to session - thin wrapper that delegates to write/index.sh
# Usage: write.sh <session_id> <text>
#
# Arguments:
#   session_id - Session identifier (format varies by terminal)
#   text       - Text to send to the session
#
# Exit codes:
#   0 - Success
#   1 - Missing required arguments
#   2 - Invalid session
#   3 - Operation failed
#   4 - Terminal not supported
#
# Output:
#   Empty on success

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/write/index.sh" "$@"
