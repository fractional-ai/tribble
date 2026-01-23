# 🐹 Tribble

Spawn terminal tabs with one command. Run tasks in parallel.

![Tribbles multiplying](assets/tribbles.png)

```
/tribble:run start frontend, backend, and tests

✓ Created 'Frontend'
✓ Created 'Backend'
✓ Created 'Tests'
```

Three tabs. Three seconds. Done.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/fractional-ai/tribble/main/install.sh | bash
```

Then restart Claude Code.

### Skip the Approval Prompts

Add Tribble to your allowed permissions in `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(~/.claude/plugins/tribble/scripts/*)"
    ]
  }
}
```

Now tabs spawn instantly—no confirmation dialogs.

## Use

```
/tribble:run
```

**Spawn a Claude session:**
```
/tribble:run open claude to refactor the auth module
```

**Spawn multiple tabs:**
```
/tribble:run npm run dev, npm test --watch, docker-compose up
```

**Spawn in a specific directory:**
```
/tribble:run in ~/projects/api start the server
```

### Just Ask

Skip the slash command. Talk to Claude normally:

- *Use tribble to open a claude session for the auth refactor*
- *Spawn three tabs: frontend, backend, and test watcher*
- *Start claude working on the API while I work on the UI*

Claude invokes Tribble automatically.

### Tribbles Spawning Tribbles

Spawned Claude sessions can use Tribble too. Parallel workflows go recursive:

```
You: Use tribble to spawn two claude sessions - one for frontend, one for backend

Claude: ✓ Created 'Frontend Claude'
        ✓ Created 'Backend Claude'

[In Frontend Claude tab]
Frontend Claude: I'll use tribble to run the dev server and test watcher in parallel...
                 ✓ Created 'Dev Server'
                 ✓ Created 'Test Watcher'
```

Break big tasks into parallel subtasks. Each Claude works independently.

## Supported Terminals

| Platform | Terminals |
|----------|-----------|
| macOS | iTerm2, Terminal.app, Ghostty, tmux |
| Linux | GNOME Terminal, Konsole, tmux |
| Windows | Windows Terminal (WSL), tmux |
| Any | Alacritty, Kitty, Warp, Hyper |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Not authorized to send Apple events" | System Preferences → Security → Automation → Enable |
| Tabs don't spawn | `chmod +x ~/.claude/plugins/tribble/scripts/*.sh` |
| "Not in a tmux session" | Start tmux first: `tmux new-session -s work` |
| Terminal shows "unknown" | Use tmux for best compatibility |
| Permission denied | `chmod +x ~/.claude/plugins/tribble/scripts/*.sh` |

Run `./scripts/validate-installation.sh` to diagnose issues.

## Manual Install

If the quick install doesn't work:

```bash
git clone https://github.com/fractional-ai/tribble.git ~/.claude/plugins/tribble
chmod +x ~/.claude/plugins/tribble/scripts/*.sh
```

To load automatically, add to your shell config:
```bash
alias claude='claude --plugin-dir ~/.claude/plugins/tribble'
```

## Update

```bash
cd ~/.claude/plugins/tribble && git pull
```

## Questions

**How many tabs can I spawn?**
As many as your system handles. Each tab uses ~50-100MB.

**Works in Docker?**
Yes. Use tmux inside the container for best results.

**Can I pass prompts to spawned Claude sessions?**
Yes. Say "open claude to work on X" and the prompt passes through.

## Issues

Report bugs: https://github.com/fractional-ai/tribble/issues
