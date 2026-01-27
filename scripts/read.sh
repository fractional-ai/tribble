#!/usr/bin/env bash
# Read session buffer - thin wrapper that delegates to read/index.sh
# Usage: read.sh <session_id>
#
# Arguments:
#   session_id - Session identifier (format varies by terminal)
#
# Exit codes:
#   0 - Success
#   1 - Missing required arguments
#   2 - Invalid session
#   3 - Operation failed
#   4 - Terminal not supported
#
# Output:
#   Buffer content on stdout

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/read/index.sh" "$@"
