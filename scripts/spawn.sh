#!/usr/bin/env bash
# Unified spawn script - thin wrapper that delegates to spawn/index.sh
#
# Usage:
#   spawn.sh "Your prompt here"              # Claude session (common case)
#   spawn.sh --cmd "npm test"                # Shell command
#
# Optional flags:
#   --name "Tab Name"    Tab name (auto-generated from prompt if not provided)
#   --dir /path          Working directory (defaults to current)
#   --color red          Tab color (auto-assigned if not provided)
#   --cmd "command"      Run shell command instead of Claude
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
