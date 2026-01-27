#!/usr/bin/env bash
# List sessions - thin wrapper that delegates to list/index.sh
# Usage: list.sh
#
# Arguments:
#   (none)
#
# Exit codes:
#   0 - Success
#   3 - Operation failed
#   4 - Terminal not supported
#
# Output:
#   JSON array of sessions on stdout

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/list/index.sh" "$@"
