---
description: List all spawned sessions. Use when user wants to "see my sessions", "what tabs are running", "list active sessions", or find a session ID.
allowed-tools: Bash, Read
---

# Tribble - List Sessions

List all terminal sessions/tabs with their IDs and names.

## Mission

Help users see all their spawned sessions and find session IDs for read/write operations.

## Usage

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/list.sh"
```

No arguments required.

## Output Format

Returns a JSON array of sessions:

```json
[
  {"id": "tribble:0", "name": "Auth Work", "terminal": "tmux", "session": "tribble"},
  {"id": "tribble:1", "name": "Test Runner", "terminal": "tmux", "session": "tribble"},
  {"id": "1", "name": "Frontend Dev", "terminal": "kitty", "tab_id": "1"}
]
```

### Fields

| Field | Description |
|-------|-------------|
| `id` | Session ID for read/write operations |
| `name` | Tab/window name |
| `terminal` | Terminal type |
| Additional | Terminal-specific metadata |

## Supported Terminals

- **tmux** - Lists all windows across all sessions
- **kitty** - Lists all windows via `kitty @ ls`
- **iTerm2** - Lists all sessions via AppleScript
- **Terminal.app** - Lists all tabs via AppleScript

**Not supported**: Ghostty, GNOME Terminal, Alacritty (no list API)

## Exit Codes

- `0` - Success (JSON array on stdout, may be empty `[]`)
- `3` - Operation failed
- `4` - Terminal doesn't support list

## Workflow

### Step 1: List Sessions

```bash
SESSIONS=$("${CLAUDE_PLUGIN_ROOT}/scripts/list.sh")
echo "$SESSIONS"
```

### Step 2: Present to User

Format the JSON nicely:

```
Active sessions:
1. tribble:0 - "Auth Work" (tmux)
2. tribble:1 - "Test Runner" (tmux)
3. tribble:2 - "Build" (tmux)
```

### Step 3: Use Session ID

Now the user can reference sessions by ID for read/write:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/read.sh" "tribble:1"
```

## Examples

### List all sessions

```
User: What sessions do I have running?

You: [Run: "${CLAUDE_PLUGIN_ROOT}/scripts/list.sh"]

You have 3 active sessions:

| # | Name | ID | Terminal |
|---|------|----| ---------|
| 1 | Auth Work | tribble:0 | tmux |
| 2 | Test Runner | tribble:1 | tmux |
| 3 | Frontend Dev | tribble:2 | tmux |

Use the ID to read from or write to a session.
```

### Find a specific session

```
User: Which session is running the tests?

You: [Run: "${CLAUDE_PLUGIN_ROOT}/scripts/list.sh"]

The "Test Runner" session is at ID `tribble:1`.

Would you like me to check its status?
```

### No sessions running

```
User: /tribble:list

You: [Run: "${CLAUDE_PLUGIN_ROOT}/scripts/list.sh"]
# Returns: []

No active sessions found.

Use /tribble:spawn to spawn new sessions.
```

### Check before reading

```
User: What's happening in the build?

You: Let me find the build session first.

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/list.sh"]

Found it - the build is session `tribble:2`.

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/read.sh" "tribble:2"]

The build shows:
- 85% complete
- No errors
- ETA: ~2 minutes
```

## Error Handling

### Terminal Not Supported

```
[ERROR] Terminal 'ghostty' does not support list

Ghostty doesn't have a list API yet.
You'll need to check your tabs manually.

Supported terminals: tmux, kitty, iTerm2, Terminal.app
```

### Empty Result

An empty array `[]` is valid - it means no sessions are detected. This could mean:
- No sessions were spawned
- Sessions were closed
- Running in a terminal without list support

## Tips

- List returns ALL sessions for the current terminal, not just Tribble-spawned ones
- Session names come from the tab/window title set during spawn
- For tmux, sessions are organized as `session:window`
- Use list to find IDs, then read/write to interact
- The JSON output can be parsed programmatically if needed
