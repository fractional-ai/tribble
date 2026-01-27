# Tribble

A decentralized orchestrator for Claude Code. Spawn sessions, monitor their output, and send them commands — all from your main session.

```
Spawn claude sessions for auth, payments, and docs

✓ Created 'Auth' (session 1)
✓ Created 'Payments' (session 2)
✓ Created 'Docs' (session 3)
```

Three Claude sessions. Running in parallel. Orchestrated from one place.

## Primitives

| Command | What it does |
|---------|--------------|
| `spawn` | Create new Claude sessions or terminal tabs |
| `list` | See all running sessions |
| `read` | Get output from any session |
| `write` | Send text or commands to any session |

These four primitives let you build orchestration patterns: spawn workers, check their progress, intervene when needed.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/fractional-ai/tribble/main/install.sh | bash
```

Restart Claude Code after installing. To skip approval prompts, add `Bash(~/.claude/plugins/tribble/scripts/*)` to your allowed permissions in `~/.claude/settings.json`.

## Usage

### Spawn sessions

```
Spawn a claude session for the auth refactor
Start three tabs: frontend, backend, and test watcher
Make a new session to work on tests

/tribble:spawn open claude to refactor the auth module
/tribble:spawn npm run dev, npm test --watch
```

Spawned Claude sessions receive context from your current session — relevant files, current task, and background — so they hit the ground running.

### Monitor sessions

```
/tribble:list                  # See all sessions
/tribble:read 1                # Get output from session 1
```

### Control sessions

```
/tribble:write 1 "focus on the edge cases"
```

### Orchestration patterns

Since spawned sessions can use Tribble too, you can build recursive workflows:

- **Fan-out**: Spawn workers for parallel tasks, read their results
- **Supervisor**: Monitor multiple sessions, intervene when stuck
- **Pipeline**: Chain sessions where output of one feeds the next

## Supported Terminals

| Platform | Terminals |
|----------|-----------|
| macOS | iTerm2, Terminal.app, Ghostty, Kitty, tmux |
| Linux | GNOME Terminal, Konsole, Kitty, tmux |
| Windows | Windows Terminal (WSL), tmux |
| Any | Alacritty, Warp, Hyper |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Not authorized to send Apple events" | System Preferences → Security → Automation → Enable |
| Tabs don't spawn | `chmod +x ~/.claude/plugins/tribble/scripts/*.sh` |
| "Not in a tmux session" | Start tmux first: `tmux new-session -s work` |

Run `./scripts/validate-installation.sh` to diagnose issues.

## Manual Install

```bash
git clone https://github.com/fractional-ai/tribble.git ~/.claude/plugins/tribble
chmod +x ~/.claude/plugins/tribble/scripts/*.sh
```

## Update

```bash
cd ~/.claude/plugins/tribble && git pull
```

## Issues

Report bugs: https://github.com/fractional-ai/tribble/issues

---

![Tribbles multiplying](assets/tribbles.png)
*"Obviously tribbles are very perceptive creatures, Captain."*
— Spock
