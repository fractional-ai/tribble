#!/usr/bin/env bash

# Tribble Test Suite
# Tests script syntax and validation logic without spawning actual tabs

set -e

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Tribble Test Suite ==="
echo ""

# Determine script directory (handles both direct execution and symlinks)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function for test results
pass_test() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail_test() {
    echo -e "${RED}✗${NC} $1"
    echo -e "  ${YELLOW}$2${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Test 1: Script syntax validation - top level
echo "Test 1: Script Syntax Validation (top level)"
echo "---------------------------------------------"
for script in "$PARENT_DIR/scripts"/*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        if bash -n "$script" 2>/dev/null; then
            pass_test "Syntax valid: $script_name"
        else
            fail_test "Syntax error in $script_name" "Run: bash -n $script"
        fi
    fi
done
echo ""

# Test 2: Script syntax validation - lib
echo "Test 2: Script Syntax Validation (lib/)"
echo "----------------------------------------"
for script in "$PARENT_DIR/scripts/lib"/*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        if bash -n "$script" 2>/dev/null; then
            pass_test "Syntax valid: lib/$script_name"
        else
            fail_test "Syntax error in lib/$script_name" "Run: bash -n $script"
        fi
    fi
done
echo ""

# Test 3: Script syntax validation - spawn/
echo "Test 3: Script Syntax Validation (spawn/)"
echo "------------------------------------------"
for script in "$PARENT_DIR/scripts/spawn"/*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        if bash -n "$script" 2>/dev/null; then
            pass_test "Syntax valid: spawn/$script_name"
        else
            fail_test "Syntax error in spawn/$script_name" "Run: bash -n $script"
        fi
    fi
done
echo ""

# Test 4: Scripts are executable
echo "Test 4: Script Executability"
echo "-----------------------------"
for dir in "" "/lib" "/spawn"; do
    for script in "$PARENT_DIR/scripts$dir"/*.sh; do
        if [ -f "$script" ]; then
            script_name="${dir#/}/$(basename "$script")"
            script_name="${script_name#/}"
            if [ -x "$script" ]; then
                pass_test "Executable: $script_name"
            else
                fail_test "Not executable: $script_name" "Run: chmod +x $script"
            fi
        fi
    done
done
echo ""

# Test 5: Spawn router validation - Missing arguments
echo "Test 5: Spawn Router Validation - Missing Arguments"
echo "----------------------------------------------------"
spawn_script="$PARENT_DIR/scripts/spawn/index.sh"
if [ -f "$spawn_script" ]; then
    if OUTPUT=$("$spawn_script" 2>&1); then
        fail_test "spawn/index.sh: Should fail with no arguments" "Expected usage message"
    else
        if echo "$OUTPUT" | grep -qi "Missing\|Usage:"; then
            pass_test "spawn/index.sh: Correctly shows usage for missing arguments"
        else
            fail_test "spawn/index.sh: Failed but didn't show usage" "Output: $OUTPUT"
        fi
    fi
else
    fail_test "spawn/index.sh not found" "Expected at $spawn_script"
fi
echo ""

# Test 6: Spawn router validation - Invalid directory
echo "Test 6: Spawn Router Validation - Invalid Directory"
echo "----------------------------------------------------"
NONEXISTENT_DIR="/nonexistent_dir_$(date +%s)"
if [ -f "$spawn_script" ]; then
    if OUTPUT=$("$spawn_script" --cmd "echo test" --dir "$NONEXISTENT_DIR" 2>&1); then
        fail_test "spawn/index.sh: Should fail with invalid directory" "Accepted nonexistent: $NONEXISTENT_DIR"
    else
        if echo "$OUTPUT" | grep -qi "does not exist\|not.*directory"; then
            pass_test "spawn/index.sh: Correctly rejects invalid directory"
        else
            fail_test "spawn/index.sh: Failed but didn't report directory issue" "Output: $OUTPUT"
        fi
    fi
fi
echo ""

# Test 7: Required files exist
echo "Test 7: Required Files Exist"
echo "-----------------------------"
REQUIRED_FILES=(
    "scripts/spawn.sh"
    "scripts/spawn/index.sh"
    "scripts/spawn/tmux.sh"
    "scripts/spawn/kitty.sh"
    "scripts/spawn/iterm2.sh"
    "scripts/spawn/terminal.sh"
    "scripts/spawn/alacritty.sh"
    "scripts/spawn/ghostty.sh"
    "scripts/spawn/gnome-terminal.sh"
    "scripts/spawn/windows-terminal.sh"
    "scripts/lib/common.sh"
    "scripts/lib/detect.sh"
    "scripts/lib/colors.sh"
    "scripts/validate-installation.sh"
    "commands/spawn.md"
    "README.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PARENT_DIR/$file" ]; then
        pass_test "Found: $file"
    else
        fail_test "Missing: $file" "Expected at $PARENT_DIR/$file"
    fi
done
echo ""

# Test 8: Settings file structure
echo "Test 8: Settings File Validation"
echo "---------------------------------"
SETTINGS_FILE="$PARENT_DIR/.claude/settings.local.json"
if [ -f "$SETTINGS_FILE" ]; then
    # Check for hardcoded paths (common issue)
    if grep -q "/Users/" "$SETTINGS_FILE" 2>/dev/null; then
        fail_test "settings.local.json contains hardcoded paths" "Use \${CLAUDE_PLUGIN_ROOT} instead"
    else
        pass_test "settings.local.json has no hardcoded paths"
    fi

    # Check if valid JSON
    if python3 -m json.tool "$SETTINGS_FILE" > /dev/null 2>&1; then
        pass_test "settings.local.json is valid JSON"
    else
        fail_test "settings.local.json is invalid JSON" "Check syntax"
    fi
else
    fail_test "settings.local.json not found" "Expected at $SETTINGS_FILE"
fi
echo ""

# Test 9: Plugin structure
echo "Test 9: Plugin Structure"
echo "------------------------"
if [ -f "$PARENT_DIR/.claude-plugin/plugin.json" ]; then
    pass_test "plugin.json exists"

    # Validate JSON structure
    if python3 -m json.tool "$PARENT_DIR/.claude-plugin/plugin.json" > /dev/null 2>&1; then
        pass_test "plugin.json is valid JSON"
    else
        fail_test "plugin.json is invalid JSON" "Check syntax"
    fi
else
    fail_test "plugin.json not found" "Expected at $PARENT_DIR/.claude-plugin/plugin.json"
fi
echo ""

# Test 10: Run lib/common.sh unit tests
echo "Test 10: lib/common.sh Unit Tests"
echo "----------------------------------"
if [ -f "$SCRIPT_DIR/test_common.sh" ]; then
    if "$SCRIPT_DIR/test_common.sh"; then
        pass_test "lib/common.sh unit tests passed"
    else
        fail_test "lib/common.sh unit tests failed" "Run: $SCRIPT_DIR/test_common.sh"
    fi
else
    fail_test "test_common.sh not found" "Expected at $SCRIPT_DIR/test_common.sh"
fi
echo ""

# Test 11: Run lib/detect.sh unit tests
echo "Test 11: lib/detect.sh Unit Tests"
echo "----------------------------------"
if [ -f "$SCRIPT_DIR/test_detect.sh" ]; then
    if "$SCRIPT_DIR/test_detect.sh"; then
        pass_test "lib/detect.sh unit tests passed"
    else
        fail_test "lib/detect.sh unit tests failed" "Run: $SCRIPT_DIR/test_detect.sh"
    fi
else
    fail_test "test_detect.sh not found" "Expected at $SCRIPT_DIR/test_detect.sh"
fi
echo ""

# Test 12: Run spawn script tests
echo "Test 12: Spawn Script Tests"
echo "---------------------------"
if [ -f "$SCRIPT_DIR/test_spawn.sh" ]; then
    if "$SCRIPT_DIR/test_spawn.sh"; then
        pass_test "spawn script tests passed"
    else
        fail_test "spawn script tests failed" "Run: $SCRIPT_DIR/test_spawn.sh"
    fi
else
    fail_test "test_spawn.sh not found" "Expected at $SCRIPT_DIR/test_spawn.sh"
fi
echo ""

# Final summary
echo "============================================"
echo "Test Summary"
echo "============================================"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo "Please fix the issues above before deploying"
    exit 1
fi
