---
description: Extract tool uses from current session and suggest permission rules to add to settings. Use when user wants to "save permissions", "extract permissions", "add session permissions to settings", or "what did I approve".
allowed-tools: Bash, Read, Edit
---

# Extract Permissions from Session

Analyze the current session to find all tool invocations and generate permission rule suggestions for settings.json.

## Mission

Help users identify what tools were used during a session and add appropriate permission rules to their settings files so they won't need to approve them again.

## Usage

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/extract-permissions.py"
```

## Output Format

Returns JSON with permission rule suggestions:

```json
{
  "session_file": "/path/to/session.jsonl",
  "suggestions": {
    "Bash(git status*)": {"count": 5, "examples": ["git status", "git status --short"]},
    "Bash(kitty @*)": {"count": 3, "examples": ["kitty @ ls", "kitty @ send-text"]},
    "mcp__figma__get_figma_data": {"count": 1, "examples": []}
  },
  "total_unique_rules": 3
}
```

## Workflow

### Step 1: Extract Suggestions

Run the extraction script:

```bash
RESULT=$(python3 "${CLAUDE_PLUGIN_ROOT}/scripts/extract-permissions.py")
echo "$RESULT"
```

### Step 2: Present to User

Format the suggestions as a table:

```
Found 5 permission rules from this session:

| Rule | Uses | Example |
|------|------|---------|
| Bash(kitty @*) | 8 | kitty @ ls |
| Bash(source *) | 3 | source ~/.zshrc |
| Bash(python3 -c *) | 2 | python3 -c 'import json...' |

Which would you like to add to settings?
1. Add all to global settings (~/.claude/settings.json)
2. Add all to local settings (this project only)
3. Let me pick specific ones
```

### Step 3: Read Current Settings

```bash
cat ~/.claude/settings.json
```

### Step 4: Add Selected Permissions

Use the Edit tool to add the selected rules to the appropriate settings file.

For global settings (`~/.claude/settings.json`):
- Add rules to `permissions.allow` array
- Avoid duplicates

For project settings (`.claude/settings.json` or `.claude/settings.local.json`):
- Create file if it doesn't exist
- Add rules to `permissions.allow` array

## Examples

### Extract and show suggestions

```
User: What permissions did I use this session?

You: [Run extraction script]

I found these tool patterns from your session:

| Rule | Uses | Example |
|------|------|---------|
| Bash(kitty @*) | 8 | kitty @ ls |
| Bash(~/.claude/plugins/tribble/scripts/*) | 5 | ~/.claude/plugins/tribble/scripts/list.sh |

You already have the tribble scripts allowed in your global settings.

Would you like me to add `Bash(kitty @*)` so you won't be prompted for Kitty commands?
```

### Add permissions to settings

```
User: Yes, add it to my global settings

You: [Read ~/.claude/settings.json]
[Edit to add "Bash(kitty @*)" to permissions.allow]

Done! Added `Bash(kitty @*)` to ~/.claude/settings.json

You won't be prompted for Kitty remote control commands anymore.
```

### Check for duplicates

Before adding, always check if the rule or a more general version already exists:

- If `Bash(git *)` exists, don't add `Bash(git status*)`
- If `Bash(~/.claude/plugins/tribble/scripts/*)` exists, don't add specific script paths

## Settings File Locations

| Scope | File | Use Case |
|-------|------|----------|
| Global | `~/.claude/settings.json` | Permissions for all projects |
| Project (shared) | `.claude/settings.json` | Permissions for team/repo |
| Project (local) | `.claude/settings.local.json` | Personal project permissions |

## Tips

- The script finds the most recent session for the current directory automatically
- Suggestions are grouped and generalized (e.g., multiple `git status` calls become `Bash(git status*)`)
- Read-only tools (Read, Glob, Grep) are excluded since they don't require approval
- Check existing permissions before adding to avoid redundant rules
- More specific rules can be covered by existing wildcards
