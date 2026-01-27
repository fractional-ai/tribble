#!/usr/bin/env bash

# Tests for lib/common.sh functions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PARENT_DIR/scripts/lib/common.sh"

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

cleanup() {
    rm -f /tmp/tribble_run_*.sh 2>/dev/null || true
}
trap cleanup EXIT

echo "=== Testing lib/common.sh ==="
echo ""

# validate_arguments
echo "validate_arguments"
echo "------------------"
validate_arguments "" "cmd" 2>/dev/null && fail_test "empty name" "fail" "pass" || pass_test "rejects empty name"
validate_arguments "tab" "" 2>/dev/null && fail_test "empty cmd" "fail" "pass" || pass_test "rejects empty command"
validate_arguments "tab" "cmd" 2>/dev/null && pass_test "accepts valid args" || fail_test "valid args" "pass" "fail"
echo ""

# validate_directory
echo "validate_directory"
echo "------------------"
validate_directory "/nonexistent_$$" 2>/dev/null && fail_test "bad dir" "fail" "pass" || pass_test "rejects nonexistent dir"
validate_directory "/tmp" 2>/dev/null && pass_test "accepts valid dir" || fail_test "valid dir" "pass" "fail"
echo ""

# sanitize_tab_name
echo "sanitize_tab_name"
echo "-----------------"
result=$(sanitize_tab_name 'Test "Name"')
[[ "$result" == "Test Name" ]] && pass_test "removes quotes" || fail_test "quotes" "Test Name" "$result"

result=$(sanitize_tab_name "path/to/thing")
[[ "$result" == "path-to-thing" ]] && pass_test "replaces slashes" || fail_test "slashes" "path-to-thing" "$result"
echo ""

# prepare_command_with_prompt
echo "prepare_command_with_prompt"
echo "---------------------------"

# No prompt - returns command unchanged
result=$(prepare_command_with_prompt "" "echo hello")
[[ "$result" == "echo hello" ]] && pass_test "no prompt returns command unchanged" || fail_test "no prompt" "echo hello" "$result"

# Claude with prompt - creates executable wrapper script
result=$(prepare_command_with_prompt "Write a poem" "claude")
[[ "$result" == /tmp/tribble_run_*.sh ]] && pass_test "creates wrapper script path" || fail_test "wrapper path" "/tmp/tribble_run_*.sh" "$result"
[[ -x "$result" ]] && pass_test "wrapper is executable" || fail_test "executable" "yes" "no"
grep -q "Write a poem" "$result" && pass_test "wrapper contains prompt" || fail_test "prompt in wrapper" "found" "not found"
grep -q 'claude "\$prompt"' "$result" && pass_test "wrapper calls claude" || fail_test "claude call" "found" "not found"
grep -q "rm -f" "$result" && pass_test "wrapper self-deletes" || fail_test "self-delete" "found" "not found"
rm -f "$result"

# Multiline prompt
result=$(prepare_command_with_prompt $'Line1\nLine2' "claude")
grep -q "Line1" "$result" && grep -q "Line2" "$result" && pass_test "handles multiline" || fail_test "multiline" "both lines" "missing"
rm -f "$result"

# Special characters preserved (heredoc with quoted delimiter)
result=$(prepare_command_with_prompt 'Test $var and "quotes"' "claude")
grep -q '\$var' "$result" && pass_test "preserves dollar signs" || fail_test "special chars" '$var literal' "expanded"
rm -f "$result"

echo ""
echo "============================================"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}  Failed: ${RED}$TESTS_FAILED${NC}"
[ $TESTS_FAILED -eq 0 ] && exit 0 || exit 1
