---
description: Send text or commands to a spawned session. Use when user wants to "type something in that tab", "send a command to the session", "interact with the other Claude", or control a running process.
allowed-tools: Bash, Read
---

# Tribble - Write to Session

Send text or commands to a spawned terminal session.

## Mission

Help users interact with spawned sessions without switching tabs - send commands, respond to prompts, or communicate with other Claude instances.

## Usage

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/write.sh" "<session_id>" "<text>"
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

- **tmux** - Full support via `tmux send-keys`
- **kitty** - Full support via `kitty @ send-text`
- **iTerm2** - Full support via AppleScript `write text`
- **Terminal.app** - Full support via AppleScript `do script`

**Not supported**: Ghostty, GNOME Terminal, Alacritty (no write API)

## Exit Codes

- `0` - Success (text sent)
- `1` - Missing arguments
- `2` - Invalid session (not found)
- `3` - Operation failed
- `4` - Terminal doesn't support write

## Important Notes

### Text is sent literally

The text is sent as-is. To execute a command, include a newline or the user must press Enter in that session.

For tmux, you can append `C-m` (Enter) by chaining:
```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/write.sh" "tribble:0" "npm test"
# Then send Enter:
tmux send-keys -t "tribble:0" C-m
```

### Be careful with running processes

Sending text to a session with a running process will inject that text into whatever is running. Make sure the session is ready for input.

## Workflow

### Step 1: Verify Session State

Use `/tribble:read` first to see what's happening in the session:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/read.sh" "tribble:0"
```

### Step 2: Send Text

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/write.sh" "tribble:0" "your text here"
```

### Step 3: Verify the Result

**Always read after writing** to confirm the text was received and any response:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/read.sh" "tribble:0"
```

**Important**: Don't ask the user to verify - check yourself using the read command. This lets you confirm success and see any responses or errors without requiring the user to switch tabs.

## Examples

### Send a command to a shell session

```
User: Run the linter in the other tab

You: Let me send that command.

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/read.sh" "tribble:1"]
# Verify it's at a shell prompt

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/write.sh" "tribble:1" "npm run lint"]

Sent `npm run lint` to the session. The command is ready - you may need to press Enter in that tab to execute it.
```

### Respond to a prompt

```
User: The build is asking for confirmation, say yes

You: [Run: "${CLAUDE_PLUGIN_ROOT}/scripts/write.sh" "tribble:2" "yes"]

Sent "yes" to the build session.
```

### Send context to another Claude session

```
User: Tell the other Claude about the bug we found

You: [Run: "${CLAUDE_PLUGIN_ROOT}/scripts/write.sh" "tribble:0" "Update: We found the bug is in src/auth.ts line 45. The JWT validation is inverted."]

Sent the update to the auth Claude session.
```

### Answer an interactive prompt

```
User: The installer is asking which package manager, choose npm

You: [Run: "${CLAUDE_PLUGIN_ROOT}/scripts/read.sh" "tribble:1"]
# Shows: "Which package manager? (npm/yarn/pnpm)"

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/write.sh" "tribble:1" "npm"]

Sent "npm" to select the package manager.
```

## Error Handling

### Session Not Found

```
[ERROR] Session not found: tribble:5

The session may have been closed.
Use /tribble:list to see active sessions.
```

### Terminal Not Supported

```
[ERROR] Terminal 'alacritty' does not support write

Alacritty doesn't have a write API.
You'll need to switch to that tab and type manually.
```

## Tips

- Always read the session first to understand its state
- **Always read after writing** to verify success - don't ask the user to check
- Don't send commands to sessions running processes that don't expect input
- For tmux, you can send special keys like `C-c` (Ctrl+C) via tmux directly
- Session IDs from spawn output are essential - save them if you need to interact later
- Use `/tribble:list` to find sessions if you've lost track
