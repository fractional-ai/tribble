#!/usr/bin/env bash

# Pasta Maker Test Suite
# Tests script syntax and validation logic without spawning actual tabs

set -e

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Pasta Maker Test Suite ==="
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
    ((TESTS_PASSED++))
}

fail_test() {
    echo -e "${RED}✗${NC} $1"
    echo -e "  ${YELLOW}$2${NC}"
    ((TESTS_FAILED++))
}

# Test 1: Script syntax validation
echo "Test 1: Script Syntax Validation"
echo "-----------------------------------"
for script in "$PARENT_DIR/scripts"/*.sh; do
    script_name=$(basename "$script")
    if bash -n "$script" 2>/dev/null; then
        pass_test "Syntax valid: $script_name"
    else
        fail_test "Syntax error in $script_name" "Run: bash -n $script"
    fi
done
echo ""

# Test 2: Scripts are executable
echo "Test 2: Script Executability"
echo "-----------------------------"
for script in "$PARENT_DIR/scripts"/*.sh; do
    script_name=$(basename "$script")
    if [ -x "$script" ]; then
        pass_test "Executable: $script_name"
    else
        fail_test "Not executable: $script_name" "Run: chmod +x $script"
    fi
done
echo ""

# Test 3: Terminal detection
echo "Test 3: Terminal Detection"
echo "--------------------------"
if [ -f "$PARENT_DIR/scripts/detect-terminal.sh" ]; then
    RESULT=$("$PARENT_DIR/scripts/detect-terminal.sh" 2>/dev/null || echo "")
    if [ -n "$RESULT" ]; then
        pass_test "detect-terminal.sh returned: $RESULT"
    else
        fail_test "detect-terminal.sh produced no output" "Script may have failed"
    fi
else
    fail_test "detect-terminal.sh not found" "Expected at $PARENT_DIR/scripts/detect-terminal.sh"
fi
echo ""

# Test 4: Spawn script validation - Missing arguments
echo "Test 4: Spawn Script Validation - Missing Arguments"
echo "----------------------------------------------------"
for spawn_script in "$PARENT_DIR/scripts/spawn-"*.sh; do
    script_name=$(basename "$spawn_script")
    # Test with no arguments - should show usage
    if OUTPUT=$("$spawn_script" 2>&1); then
        fail_test "$script_name: Should fail with no arguments" "Expected usage message"
    else
        if echo "$OUTPUT" | grep -q "Usage:" || echo "$OUTPUT" | grep -q "usage:"; then
            pass_test "$script_name: Correctly shows usage for missing arguments"
        else
            fail_test "$script_name: Failed but didn't show usage" "Output: $OUTPUT"
        fi
    fi
done
echo ""

# Test 5: Spawn script validation - Invalid directory
echo "Test 5: Spawn Script Validation - Invalid Directory"
echo "----------------------------------------------------"
NONEXISTENT_DIR="/nonexistent_dir_$(date +%s)"
for spawn_script in "$PARENT_DIR/scripts/spawn-"*.sh; do
    script_name=$(basename "$spawn_script")
    # Test with invalid directory
    if OUTPUT=$("$spawn_script" "TestTab" "echo test" "$NONEXISTENT_DIR" 2>&1); then
        fail_test "$script_name: Should fail with invalid directory" "Accepted nonexistent: $NONEXISTENT_DIR"
    else
        if echo "$OUTPUT" | grep -q "does not exist" || echo "$OUTPUT" | grep -q "not.*directory"; then
            pass_test "$script_name: Correctly rejects invalid directory"
        else
            fail_test "$script_name: Failed but didn't report directory issue" "Output: $OUTPUT"
        fi
    fi
done
echo ""

# Test 6: Required files exist
echo "Test 6: Required Files Exist"
echo "-----------------------------"
REQUIRED_FILES=(
    "scripts/detect-terminal.sh"
    "scripts/spawn-iterm2.sh"
    "scripts/spawn-terminal-app.sh"
    "scripts/spawn-tmux.sh"
    "commands/run.md"
    "lib/dependency-analyzer.md"
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

# Test 7: Settings file structure
echo "Test 7: Settings File Validation"
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

# Test 8: Plugin structure
echo "Test 8: Plugin Structure"
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
