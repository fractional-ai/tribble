#!/usr/bin/env bash
# Unified spawn script - thin wrapper that delegates to spawn/index.sh
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
#
# Output:
#   Session ID on stdout (format varies by terminal)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/spawn/index.sh" "$@"
