---
description: Read the buffer content from a spawned session. Use when user wants to "check on a session", "see what happened in that tab", "read the output", or monitor a running task.
allowed-tools: Bash, Read
---

# Tribble - Read Session Buffer

Read the contents (visible text and scrollback) from a spawned terminal session.

## Mission

Help users see what's happening in their spawned sessions without switching tabs.

## Usage

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/read.sh" "<session_id>"
```

## Session ID Formats

Session IDs are returned when spawning and vary by terminal:

| Terminal | Format | Example |
|----------|--------|---------|
| tmux | `session:window` | `tribble:0` |
| kitty | window ID | `1` |
| iTerm2 | session GUID | `w0t0p0:XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` |
| Terminal.app | TTY path | `/dev/ttys017` |

## Supported Terminals

- **tmux** - Full support via `tmux capture-pane`
- **kitty** - Full support via `kitty @ get-text`
- **iTerm2** - Full support via AppleScript `contents`
- **Terminal.app** - Full support via AppleScript `contents` + `history`

**Not supported**: Ghostty, GNOME Terminal, Alacritty (no read API)

## Exit Codes

- `0` - Success (buffer content on stdout)
- `1` - Missing session_id argument
- `2` - Invalid session (not found)
- `3` - Operation failed
- `4` - Terminal doesn't support read

## Workflow

### Step 1: Get Session ID

If user doesn't have the session ID, use `/tribble:list` first to see all sessions.

### Step 2: Read the Buffer

```bash
OUTPUT=$("${CLAUDE_PLUGIN_ROOT}/scripts/read.sh" "tribble:0")
echo "$OUTPUT"
```

### Step 3: Present to User

Show the relevant output. For long buffers, summarize or show the last N lines:

```
The session shows:
- Tests are running (15/30 complete)
- No failures so far
- Currently testing auth module
```

## Examples

### Check on a tmux session

```
User: What's happening in the test runner?

You: Let me check the test session.

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/read.sh" "tribble:1"]

The test runner shows:
- 45/50 tests passed
- 5 tests remaining
- Currently running: test_auth_flow
- No failures yet
```

### Monitor a long-running build

```
User: How's the build going?

You: [Run: "${CLAUDE_PLUGIN_ROOT}/scripts/read.sh" "tribble:2"]

The build is at 78% complete:
- Compiled 156/200 modules
- No errors
- Currently compiling: src/components/
```

### Check Claude session output

```
User: What did the other Claude figure out?

You: [Run: "${CLAUDE_PLUGIN_ROOT}/scripts/read.sh" "tribble:0"]

The auth Claude session found:
- The bug is in token validation (line 45)
- JWT expiry check was inverted
- It's working on a fix now
```

## Error Handling

### Session Not Found

```
[ERROR] Session not found: tribble:5

The session may have:
- Been closed
- Had its window renamed

Use /tribble:list to see active sessions.
```

### Terminal Not Supported

```
[ERROR] Terminal 'ghostty' does not support read

Ghostty doesn't have a read API yet.
You'll need to switch to that tab manually to see its contents.
```

## Tips

- Save session IDs from spawn output for later use
- Use `/tribble:list` to find session IDs if you forgot them
- For tmux, session IDs are predictable (`session:0`, `session:1`, etc.)
- Long-running processes accumulate large buffers - consider checking periodically
