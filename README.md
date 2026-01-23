# 🐹 Tribble

Spawn Claude sessions and terminal tabs directly from Claude Code.

```
Spawn claude sessions for auth, payments, and docs

✓ Created Session for 'Auth'
✓ Created Session for  'Payments'
✓ Created Session for  'Docs'
```

Three Claude sessions. Running in parallel. One command.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/fractional-ai/tribble/main/install.sh | bash
```

Then restart Claude Code. To skip approval prompts, add `Bash(~/.claude/plugins/tribble/scripts/*)` to your allowed permissions in `~/.claude/settings.json`.

## Usage

Just ask Claude, or use the slash command:

```
Use tribble to open a claude session for the auth refactor
Spawn a claude to work on tests while I work on the feature
Start three tabs: frontend, backend, and test watcher

/tribble:run open claude to refactor the auth module
/tribble:run npm run dev, npm test --watch, docker-compose up
```

Spawned Claude sessions receive context from your current session—relevant files, current task, and background—so they can start working immediately. They can use Tribble too, so complex recursive workflows are wupported.

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

Run `./scripts/validate-installation.sh` to diagnose issues.

## Manual Install

```bash
git clone https://github.com/fractional-ai/tribble.git ~/.claude/plugins/tribble
chmod +x ~/.claude/plugins/tribble/scripts/*.sh
```

Add alias to load automatically: `alias claude='claude --plugin-dir ~/.claude/plugins/tribble'`

## Update

```bash
cd ~/.claude/plugins/tribble && git pull
```

## Issues

Report bugs: https://github.com/fractional-ai/tribble/issues

---
*"Obviously tribbles are very perceptive creatures, Captain."*   
— Spock (Star Trek)

![Tribbles multiplying](assets/tribbles.png)


