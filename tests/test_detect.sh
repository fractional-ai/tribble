#!/usr/bin/env bash

# Tests for lib/detect.sh functions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PARENT_DIR/scripts/lib/detect.sh"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

pass_test() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail_test() {
    echo -e "${RED}✗${NC} $1: expected '$2', got '$3'"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

echo "=== Testing lib/detect.sh ==="
echo ""

# detect_terminal
echo "detect_terminal"
echo "---------------"
# Should return something (actual detection depends on environment)
result=$(detect_terminal)
if [ -n "$result" ]; then
    pass_test "detect_terminal returns a value: $result"
else
    fail_test "detect_terminal" "non-empty result" "empty"
fi
echo ""

# is_terminal_supported - supported terminals
echo "is_terminal_supported (supported terminals)"
echo "--------------------------------------------"
is_terminal_supported "tmux" && pass_test "tmux is supported" || fail_test "tmux" "supported" "unsupported"
is_terminal_supported "kitty" && pass_test "kitty is supported" || fail_test "kitty" "supported" "unsupported"
is_terminal_supported "iterm2" && pass_test "iterm2 is supported" || fail_test "iterm2" "supported" "unsupported"
is_terminal_supported "terminal" && pass_test "terminal is supported" || fail_test "terminal" "supported" "unsupported"
is_terminal_supported "ghostty" && pass_test "ghostty is supported" || fail_test "ghostty" "supported" "unsupported"
is_terminal_supported "alacritty" && pass_test "alacritty is supported" || fail_test "alacritty" "supported" "unsupported"
is_terminal_supported "gnome-terminal" && pass_test "gnome-terminal is supported" || fail_test "gnome-terminal" "supported" "unsupported"
is_terminal_supported "windows-terminal" && pass_test "windows-terminal is supported" || fail_test "windows-terminal" "supported" "unsupported"
echo ""

# is_terminal_supported - unsupported terminals
echo "is_terminal_supported (unsupported terminals)"
echo "----------------------------------------------"
is_terminal_supported "unknown" && fail_test "unknown" "unsupported" "supported" || pass_test "unknown correctly rejected"
is_terminal_supported "vscode" && fail_test "vscode" "unsupported" "supported" || pass_test "vscode correctly rejected"
is_terminal_supported "warp" && fail_test "warp" "unsupported" "supported" || pass_test "warp correctly rejected"
echo ""

# list_supported_terminals
echo "list_supported_terminals"
echo "------------------------"
result=$(list_supported_terminals)
if echo "$result" | grep -q "tmux" && echo "$result" | grep -q "kitty" && echo "$result" | grep -q "iterm2" && echo "$result" | grep -q "ghostty" && echo "$result" | grep -q "alacritty"; then
    pass_test "list includes all supported terminals"
else
    fail_test "list_supported_terminals" "all terminals" "$result"
fi
echo ""

echo "============================================"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}  Failed: ${RED}$TESTS_FAILED${NC}"
[ $TESTS_FAILED -eq 0 ] && exit 0 || exit 1
