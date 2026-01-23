# 🐹 Tribble

Quickly spawn Claude Code sessions or commands in new terminal tabs.

Like tribbles, your Claude sessions multiply rapidly.

**Example:**
```bash
/tribble:run open claude to work on auth
✓ Tab created in 5 seconds
```

## Install

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/fractional-ai/tribble/main/install.sh | bash
```

### Manual Installation

**Clone and set up the plugin:**
```bash
# Clone the repository to ~/.claude/plugins/
git clone https://github.com/fractional-ai/tribble.git ~/.claude/plugins/tribble

# Make scripts executable
chmod +x ~/.claude/plugins/tribble/scripts/*.sh
```

**To use the plugin, start Claude Code with the `--plugin-dir` flag:**
```bash
claude --plugin-dir ~/.claude/plugins/tribble
```

**Note:** The plugin must be at `~/.claude/plugins/tribble` (or symlinked there) because the scripts reference this path at runtime.

### Optional: Shell Alias

To avoid typing `--plugin-dir` every time, add an alias to your shell config:

```bash
# For zsh users, add to ~/.zshrc:
alias claude='claude --plugin-dir ~/.claude/plugins/tribble'

# For bash users, add to ~/.bashrc:
alias claude='claude --plugin-dir ~/.claude/plugins/tribble'
```

After adding the alias, restart your terminal or run `source ~/.zshrc` (or `source ~/.bashrc`).

### For Development

If you're working on the plugin from a different location:
```bash
# Clone to your development directory
git clone https://github.com/fractional-ai/tribble.git ~/path/to/dev/tribble

# Make scripts executable
chmod +x ~/path/to/dev/tribble/scripts/*.sh

# Create symlink so scripts can be found at runtime
ln -s ~/path/to/dev/tribble ~/.claude/plugins/tribble

# Start Claude Code with the plugin
claude --plugin-dir ~/path/to/dev/tribble
```

Changes to the plugin will be picked up when you restart Claude Code.

### Verify Installation

In Claude Code, check the command is available:
```
/tribble:run
```

If the command is recognized, installation succeeded.

### Updating

```bash
# Navigate to plugin directory
cd ~/.claude/plugins/tribble

# Pull latest changes
git pull

# Restart Claude Code
```

## Use

```bash
/tribble:run
```

Tell Claude what you want to spawn, and tabs are created immediately.

**Single session:**
```
You: /tribble:run open claude to refactor auth

Claude: ✓ Created tab 'Refactor Auth'
        Your session is ready!
```

**Multiple tasks:**
```
You: /tribble:run start frontend, backend, and test watcher

Claude: What commands?

You: npm run dev:frontend, npm run dev:backend, npm test:watch

Claude: ✓ Created tab 'Frontend'
        ✓ Created tab 'Backend'
        ✓ Created tab 'Test Watcher'

        Your sessions are ready!
```

**That's it.** No approvals, no plans, no coordination - just spawn and go.

## Requirements

**Supported Terminals:**
- **macOS:** iTerm2, Terminal.app, Ghostty
- **Linux:** tmux, GNOME Terminal, Konsole
- **Windows:** Windows Terminal (via WSL)
- **Cross-platform:** tmux, Alacritty, Kitty, Hyper, Warp, VS Code

Tabs spawn automatically using terminal-specific commands (AppleScript, tmux, etc.)

## FAQ

**Q: How many tabs can I spawn?**

As many as your system can handle. Each tab runs independently with ~50-100MB memory per tab.

**Q: Does this work with Docker containers?**

Yes, but terminal detection may not work inside containers. Use tmux inside the container for best results.

**Q: What if tasks depend on each other?**

Spawn them all and run them in order yourself. Tribble spawns tabs quickly - you control when to start each one.

**Q: Can I spawn Claude sessions with specific prompts?**

Yes! Just say: "open claude to work on X" - the prompt is automatically passed to the new session.

## Performance

- Memory: ~50-100MB per tab
- CPU: Depends on what you're running
- Monitor resources if spawning many tabs

## Security

**Command Execution:**
- Tribble executes commands exactly as provided
- Validate commands before approving the execution plan
- Be cautious with commands from untrusted sources

**Directory Access:**
- Commands run with your user permissions
- Spawned tabs have full access to specified directories
- Don't run destructive commands without review

**AppleScript Permissions:**
- Grants automation control to terminal applications
- Can be revoked in System Preferences if needed
- Only affects terminal automation, not system access

## Troubleshooting

### Validation Tool

Run the validation script to diagnose setup issues:

```bash
./scripts/validate-installation.sh
```

This checks:
- Required files exist
- Scripts are executable
- Terminal detection works
- Configuration is valid
- Terminal-specific requirements

### Common Issues

**"Not authorized to send Apple events" (macOS)**

Fix: System Preferences → Security & Privacy → Privacy → Automation → Enable your terminal

**Tabs don't spawn**

Fixes:
1. Check scripts are executable: `chmod +x ~/.claude/plugins/tribble/scripts/*.sh`
2. Verify terminal is detected: `./scripts/detect-terminal.sh`
3. Run validation: `./scripts/validate-installation.sh`

**"Not in a tmux session"**

Fix: Start tmux first, then run Tribble from within the tmux session:
```bash
tmux new-session -s tribble
# Then run /tribble:run in Claude Code
```

**Terminal not detected or shows "unknown"**

Options:
1. Use tmux for best compatibility: `brew install tmux` or `apt install tmux`
2. Check if your terminal is supported (see Requirements section)
3. File an issue with your terminal details

**Permission denied errors**

Fix:
```bash
chmod +x ~/.claude/plugins/tribble/scripts/*.sh
```

**Plugin not found**

Verify installation:
```bash
ls -la ~/.claude/plugins/tribble
claude --plugin-dir ~/.claude/plugins/tribble
```

**Commands fail in spawned tabs**

Check:
1. Directory exists and is accessible
2. Command works when run manually
3. Environment variables are set correctly
4. Command doesn't require interactive input

### Getting Help

If issues persist:
1. Run `./scripts/validate-installation.sh` and share the output
2. Include your terminal type and OS version
3. Share any error messages
4. Report issues at: https://github.com/fractional-ai/tribble/issues
