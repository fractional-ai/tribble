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

# supports_primitive - tmux
echo "supports_primitive (tmux)"
echo "-------------------------"
supports_primitive "tmux" "spawn" && pass_test "tmux supports spawn" || fail_test "tmux spawn" "supported" "unsupported"
supports_primitive "tmux" "read" && pass_test "tmux supports read" || fail_test "tmux read" "supported" "unsupported"
supports_primitive "tmux" "write" && pass_test "tmux supports write" || fail_test "tmux write" "supported" "unsupported"
supports_primitive "tmux" "list" && pass_test "tmux supports list" || fail_test "tmux list" "supported" "unsupported"
echo ""

# supports_primitive - kitty
echo "supports_primitive (kitty)"
echo "--------------------------"
supports_primitive "kitty" "spawn" && pass_test "kitty supports spawn" || fail_test "kitty spawn" "supported" "unsupported"
supports_primitive "kitty" "read" && pass_test "kitty supports read" || fail_test "kitty read" "supported" "unsupported"
supports_primitive "kitty" "write" && pass_test "kitty supports write" || fail_test "kitty write" "supported" "unsupported"
supports_primitive "kitty" "list" && pass_test "kitty supports list" || fail_test "kitty list" "supported" "unsupported"
echo ""

# supports_primitive - iterm2
echo "supports_primitive (iterm2)"
echo "---------------------------"
supports_primitive "iterm2" "spawn" && pass_test "iterm2 supports spawn" || fail_test "iterm2 spawn" "supported" "unsupported"
supports_primitive "iterm2" "read" && pass_test "iterm2 supports read" || fail_test "iterm2 read" "supported" "unsupported"
supports_primitive "iterm2" "write" && pass_test "iterm2 supports write" || fail_test "iterm2 write" "supported" "unsupported"
supports_primitive "iterm2" "list" && pass_test "iterm2 supports list" || fail_test "iterm2 list" "supported" "unsupported"
echo ""

# supports_primitive - terminal
echo "supports_primitive (terminal)"
echo "-----------------------------"
supports_primitive "terminal" "spawn" && pass_test "terminal supports spawn" || fail_test "terminal spawn" "supported" "unsupported"
supports_primitive "terminal" "read" && pass_test "terminal supports read" || fail_test "terminal read" "supported" "unsupported"
supports_primitive "terminal" "write" && pass_test "terminal supports write" || fail_test "terminal write" "supported" "unsupported"
supports_primitive "terminal" "list" && pass_test "terminal supports list" || fail_test "terminal list" "supported" "unsupported"
echo ""

# supports_primitive - limited terminals (spawn only)
echo "supports_primitive (limited terminals)"
echo "--------------------------------------"
supports_primitive "ghostty" "spawn" && pass_test "ghostty supports spawn" || fail_test "ghostty spawn" "supported" "unsupported"
supports_primitive "ghostty" "read" && fail_test "ghostty read" "unsupported" "supported" || pass_test "ghostty correctly rejects read"
supports_primitive "ghostty" "write" && fail_test "ghostty write" "unsupported" "supported" || pass_test "ghostty correctly rejects write"
supports_primitive "ghostty" "list" && fail_test "ghostty list" "unsupported" "supported" || pass_test "ghostty correctly rejects list"

supports_primitive "alacritty" "spawn" && pass_test "alacritty supports spawn" || fail_test "alacritty spawn" "supported" "unsupported"
supports_primitive "alacritty" "read" && fail_test "alacritty read" "unsupported" "supported" || pass_test "alacritty correctly rejects read"

supports_primitive "gnome-terminal" "spawn" && pass_test "gnome-terminal supports spawn" || fail_test "gnome-terminal spawn" "supported" "unsupported"
supports_primitive "gnome-terminal" "read" && fail_test "gnome-terminal read" "unsupported" "supported" || pass_test "gnome-terminal correctly rejects read"
echo ""

# supports_primitive - unknown terminal
echo "supports_primitive (unknown)"
echo "----------------------------"
supports_primitive "unknown" "spawn" && fail_test "unknown spawn" "unsupported" "supported" || pass_test "unknown correctly rejects spawn"
supports_primitive "unknown" "read" && fail_test "unknown read" "unsupported" "supported" || pass_test "unknown correctly rejects read"
echo ""

# list_supported_terminals
echo "list_supported_terminals"
echo "------------------------"
result=$(list_supported_terminals "spawn")
if echo "$result" | grep -q "tmux" && echo "$result" | grep -q "kitty" && echo "$result" | grep -q "iterm2"; then
    pass_test "spawn list includes tmux, kitty, iterm2"
else
    fail_test "spawn list" "tmux kitty iterm2 ..." "$result"
fi

result=$(list_supported_terminals "read")
if echo "$result" | grep -q "tmux" && echo "$result" | grep -q "kitty"; then
    pass_test "read list includes tmux, kitty"
else
    fail_test "read list" "tmux kitty ..." "$result"
fi

# Should not include ghostty/alacritty/gnome-terminal in read list
if echo "$result" | grep -qv "ghostty"; then
    pass_test "read list excludes ghostty"
else
    fail_test "read list exclusion" "no ghostty" "includes ghostty"
fi
echo ""

echo "============================================"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}  Failed: ${RED}$TESTS_FAILED${NC}"
[ $TESTS_FAILED -eq 0 ] && exit 0 || exit 1
