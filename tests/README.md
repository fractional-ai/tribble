# Tribble Test Suite

This directory contains tests to validate the Tribble plugin functionality, ensuring scripts work correctly and catching issues before deployment.

## Overview

The test suite includes:
- **Syntax tests**: Validate bash script syntax
- **Validation tests**: Test error handling and input validation
- **Structure tests**: Verify plugin files and configuration
- **Integration tests**: Test actual terminal tab spawning (manual)

## Running Tests

### Quick Start

Run all automated tests:

```bash
./tests/run_tests.sh
```

This runs tests that don't require spawning actual tabs and can be run in any environment.

### What Gets Tested

The automated test suite validates:

1. **Script Syntax** - All bash scripts have valid syntax
2. **Executability** - Scripts have execute permissions
3. **Terminal Detection** - `detect-terminal.sh` runs successfully
4. **Input Validation** - Spawn scripts reject invalid arguments
5. **Directory Validation** - Spawn scripts reject nonexistent directories
6. **Required Files** - All essential plugin files exist
7. **Settings Format** - JSON files are valid and properly configured
8. **Plugin Structure** - Plugin configuration is correct

### Exit Codes

- `0`: All tests passed
- `1`: One or more tests failed

### Example Output

```
=== Tribble Test Suite ===

Test 1: Script Syntax Validation
-----------------------------------
✓ Syntax valid: detect-terminal.sh
✓ Syntax valid: spawn-iterm2.sh
✓ Syntax valid: spawn-terminal-app.sh
✓ Syntax valid: spawn-tmux.sh

Test 2: Script Executability
-----------------------------
✓ Executable: detect-terminal.sh
✓ Executable: spawn-iterm2.sh
✓ Executable: spawn-terminal-app.sh
✓ Executable: spawn-tmux.sh

...

============================================
Test Summary
============================================
Tests passed: 23
Tests failed: 0

✓ All tests passed!
```

## Manual Integration Testing

While the automated test suite validates script logic, manual testing is needed to verify actual tab spawning works in different terminals.

### Prerequisites

- macOS (for iTerm2/Terminal.app tests)
- iTerm2 and/or Terminal.app installed
- tmux installed (for tmux tests)
- Appropriate permissions granted (AppleScript, Accessibility)

### iTerm2 Integration Test

1. Open iTerm2
2. Run from the project directory:
   ```bash
   ./scripts/spawn-iterm2.sh "Test Tab" "echo 'Hello from test tab' && sleep 5" "$PWD"
   ```
3. Verify:
   - [ ] New tab opens in iTerm2
   - [ ] Tab name is "Test Tab"
   - [ ] Command executes and prints message
   - [ ] Tab changes to correct directory
   - [ ] Tab closes after 5 seconds

### Terminal.app Integration Test

1. Open Terminal.app
2. Run from the project directory:
   ```bash
   ./scripts/spawn-terminal-app.sh "Test Tab" "echo 'Hello from test tab' && sleep 5" "$PWD"
   ```
3. Verify:
   - [ ] New tab opens in Terminal.app
   - [ ] Tab title is "Test Tab"
   - [ ] Command executes and prints message
   - [ ] Tab changes to correct directory

### tmux Integration Test

1. Start or attach to a tmux session:
   ```bash
   tmux new-session -s test
   # or
   tmux attach -t test
   ```
2. Run from the project directory:
   ```bash
   ./scripts/spawn-tmux.sh "Test Tab" "echo 'Hello from test tab' && sleep 5" "$PWD"
   ```
3. Verify:
   - [ ] New window opens in tmux
   - [ ] Window name is "Test Tab"
   - [ ] Command executes and prints message
   - [ ] Window changes to correct directory

### Edge Case Testing

Test these scenarios manually:

#### Empty/Invalid Arguments
```bash
# Should fail with usage message
./scripts/spawn-iterm2.sh

# Should fail with usage message
./scripts/spawn-iterm2.sh "Tab Name"

# Should fail with directory error
./scripts/spawn-iterm2.sh "Test" "echo test" "/nonexistent"
```

#### Special Characters in Commands
```bash
# Commands with quotes
./scripts/spawn-iterm2.sh "Test" "echo 'hello \"world\"'" "$PWD"

# Commands with pipes
./scripts/spawn-iterm2.sh "Test" "echo test | grep test" "$PWD"

# Commands with variables
./scripts/spawn-iterm2.sh "Test" "echo \$HOME" "$PWD"
```

#### Long Commands
```bash
# Test with command > 500 characters
LONG_CMD="echo 'This is a very long command that...' && ..."
./scripts/spawn-iterm2.sh "Test" "$LONG_CMD" "$PWD"
```

#### No Terminal Windows Open
```bash
# Close all iTerm2 windows, then run:
./scripts/spawn-iterm2.sh "Test" "echo test" "$PWD"
# Should create a new window or fail gracefully
```

## Test Checklist

Use this checklist when testing changes or before releasing:

### Basic Functionality
- [ ] All automated tests pass (`./tests/run_tests.sh`)
- [ ] Scripts have correct permissions (executable)
- [ ] No syntax errors in any script
- [ ] Terminal detection works in current environment

### iTerm2
- [ ] Spawn single tab successfully
- [ ] Spawn multiple tabs in parallel
- [ ] Handle long commands (> 500 chars)
- [ ] Handle special characters in commands
- [ ] Handle tab names with special characters
- [ ] Fail gracefully with invalid directory
- [ ] Fail gracefully with no windows open
- [ ] Show clear error messages

### Terminal.app
- [ ] Spawn single tab successfully
- [ ] Spawn multiple tabs in parallel
- [ ] Handle long commands
- [ ] Handle special characters in commands
- [ ] Require accessibility permissions (show clear error if denied)
- [ ] Fail gracefully with invalid directory
- [ ] Show clear error messages

### tmux
- [ ] Spawn single window successfully
- [ ] Spawn multiple windows in parallel
- [ ] Handle long commands
- [ ] Handle special characters in commands
- [ ] Detect when not in tmux session
- [ ] Fail gracefully with invalid directory
- [ ] Show clear error messages

### Error Handling
- [ ] Missing arguments show usage message
- [ ] Invalid directory shows clear error
- [ ] Permission errors show actionable message
- [ ] All errors go to stderr (not stdout)
- [ ] Non-zero exit codes on failure

### Plugin Integration
- [ ] Plugin loads in Claude Code
- [ ] `/tribble:run` command is recognized
- [ ] Permissions whitelist includes all spawn scripts
- [ ] Settings file has no hardcoded paths
- [ ] All required files are present

## Troubleshooting Test Failures

### "Syntax error in [script].sh"
**Cause:** Bash syntax error in script

**Fix:** Run `bash -n scripts/[script].sh` to see the error, then fix the syntax issue.

### "Not executable: [script].sh"
**Cause:** Script doesn't have execute permission

**Fix:** Run `chmod +x scripts/[script].sh`

### "detect-terminal.sh produced no output"
**Cause:** Terminal detection failed or script error

**Fix:** Run `./scripts/detect-terminal.sh` directly to see the error. Check that environment variables like `$TERM_PROGRAM` are set.

### "settings.local.json contains hardcoded paths"
**Cause:** Absolute paths like `/Users/username/...` in settings

**Fix:** Replace with `${CLAUDE_PLUGIN_ROOT}` variable:
```json
"Bash(${CLAUDE_PLUGIN_ROOT}/scripts/spawn-iterm2.sh:*)"
```

### "Invalid JSON"
**Cause:** JSON syntax error in settings or plugin.json

**Fix:** Run `python3 -m json.tool [file].json` to see the specific error.

### Integration test fails to spawn tab
**Causes:**
- Terminal not running
- Permission denied (AppleScript/Accessibility)
- Script path incorrect
- Terminal version incompatible

**Fix:**
1. Ensure terminal is running before test
2. Grant required permissions in System Preferences > Security & Privacy
3. Run with full path to script
4. Check terminal version compatibility

## CI/CD Integration

To run tests in continuous integration:

### GitHub Actions

```yaml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Make scripts executable
        run: chmod +x scripts/*.sh tests/*.sh
      - name: Install shellcheck
        run: brew install shellcheck
      - name: Run shellcheck
        run: shellcheck scripts/*.sh
      - name: Run test suite
        run: ./tests/run_tests.sh
```

### Local Pre-commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
echo "Running Tribble tests..."
./tests/run_tests.sh || {
    echo "Tests failed. Commit aborted."
    exit 1
}
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Contributing Tests

When adding new features, please add corresponding tests:

1. **New spawn script**: Add validation tests for the script
2. **New terminal support**: Add detection logic test
3. **Bug fix**: Add test that would have caught the bug
4. **New validation**: Add test to verify validation works

See the main test suite (`run_tests.sh`) for examples of how to structure tests.

## Future Enhancements

Potential test improvements for future versions:

- [ ] Automated integration tests using terminal automation
- [ ] Performance tests (time to spawn N tabs)
- [ ] Resource usage tests (memory, CPU)
- [ ] Concurrent execution tests (multiple spawns at once)
- [ ] Cross-version compatibility tests
- [ ] Mock terminal environment for unit testing
- [ ] Coverage reporting for bash scripts

## Support

If tests are failing and you can't determine why:

1. Run tests with bash debugging: `bash -x ./tests/run_tests.sh`
2. Check the specific test that's failing
3. Run the failing component directly to see detailed errors
4. Check the troubleshooting section above
5. Review plugin permissions and configuration

For persistent issues, please open an issue with:
- Test output (full)
- Environment details (OS version, terminal type, shell)
- Steps to reproduce
- What you've tried already
