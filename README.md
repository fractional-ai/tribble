# Pasta Maker 🍝

Run multiple tasks in parallel across terminal tabs. Claude analyzes dependencies and spawns tasks automatically.

**Example:** Frontend tests + backend tests run in parallel (saves ~10 min), then build runs after both complete.

## Install

> **Note:** This repository is currently private. The quick install method via curl will be available once the repository becomes public.

### Installation

**Clone and set up the plugin:**
```bash
# Clone the repository to ~/.claude/plugins/
git clone git@github.com:fractional-ai/pasta-maker.git ~/.claude/plugins/pasta-maker

# Make scripts executable
chmod +x ~/.claude/plugins/pasta-maker/scripts/*.sh
```

**To use the plugin, start Claude Code with the `--plugin-dir` flag:**
```bash
claude --plugin-dir ~/.claude/plugins/pasta-maker
```

**Note:** The plugin must be at `~/.claude/plugins/pasta-maker` (or symlinked there) because the scripts reference this path at runtime.

### Optional: Shell Alias

To avoid typing `--plugin-dir` every time, add an alias to your shell config:

```bash
# For zsh users, add to ~/.zshrc:
alias claude='claude --plugin-dir ~/.claude/plugins/pasta-maker'

# For bash users, add to ~/.bashrc:
alias claude='claude --plugin-dir ~/.claude/plugins/pasta-maker'
```

After adding the alias, restart your terminal or run `source ~/.zshrc` (or `source ~/.bashrc`).

### For Development

If you're working on the plugin from a different location:
```bash
# Clone to your development directory
git clone git@github.com:fractional-ai/pasta-maker.git ~/path/to/dev/pasta-maker

# Make scripts executable
chmod +x ~/path/to/dev/pasta-maker/scripts/*.sh

# Create symlink so scripts can be found at runtime
ln -s ~/path/to/dev/pasta-maker ~/.claude/plugins/pasta-maker

# Start Claude Code with the plugin
claude --plugin-dir ~/path/to/dev/pasta-maker
```

Changes to the plugin will be picked up when you restart Claude Code.

### Quick Install (Available After Repository Goes Public)

Once public, users will be able to install via:
```bash
curl -fsSL https://raw.githubusercontent.com/fractional-ai/pasta-maker/main/install.sh | bash
```

### Verify Installation

In Claude Code, check the command is available:
```
/pasta-maker:run
```

If the command is recognized, installation succeeded.

### Updating

```bash
# Navigate to plugin directory
cd ~/.claude/plugins/pasta-maker

# Pull latest changes
git pull

# Restart Claude Code
```

## Use

```bash
/pasta-maker:run
```

Claude asks what tasks you need, analyzes which can run in parallel, shows you a plan, and spawns terminal tabs when you approve.

```
You: /pasta-maker:run

Claude: What tasks would you like to accomplish?

You: Run frontend tests, backend tests, then build

Claude: (asks for commands and directory)

You: npm run test:frontend, npm run test:backend, npm run build
     All in /Users/me/project

Claude: EXECUTION PLAN
        Group 1 (parallel): Frontend Tests + Backend Tests
        Group 2 (after tests): Build

        Proceed? (yes/no)

You: yes

Claude: ✓ Tab 'Frontend Tests' created
        ✓ Tab 'Backend Tests' created
```

## What's Next

Once the repository becomes public, we're planning:

**Distribution & Accessibility:**
- One-line install via curl for frictionless onboarding
- Package manager support (npm, brew, apt)
- Pre-built binaries for major platforms
- Public documentation site with interactive examples

**Feature Enhancements:**
- Task templates for common workflows (test suites, multi-service dev, CI/CD simulation)
- Progress monitoring dashboard across all spawned tabs
- Task retry and error recovery mechanisms
- Support for remote task execution (SSH, cloud instances)

**Community & Ecosystem:**
- Plugin marketplace integration
- Community-contributed task templates
- Integration examples with popular frameworks
- Video tutorials and use case guides

Stay tuned! Follow releases at https://github.com/fractional-ai/pasta-maker/releases

## Requirements

**Supported Terminals:**
- **macOS:** iTerm2, Terminal.app
- **Linux:** tmux, GNOME Terminal, Konsole
- **Windows:** Windows Terminal (via WSL)
- **Cross-platform:** tmux, Alacritty, Kitty, Hyper, Warp, VS Code

Tabs spawn automatically using terminal-specific commands (AppleScript, tmux, etc.)

## FAQ

**Q: How many tasks can I run in parallel?**

Technically unlimited, but practical limits depend on your system resources. Recommendations:
- Light tasks (tests, lints): up to 10 parallel
- Heavy tasks (builds): 2-4 parallel
- Dev servers: as many as needed

**Q: Can I use this with Docker containers?**

Yes, but terminal detection may not work inside containers. Use tmux inside the container.

**Q: What if my shell takes time to initialize?**

Commands run immediately after cd. Include environment setup in the command if needed:
```bash
source ~/.bashrc && npm test
```

**Q: Does this work with sudo commands?**

Yes, but each tab will prompt for password separately. Consider using sudo with timeout or running without sudo if possible.

## Performance

**Resource Usage:**
- Each spawned tab runs independently with full environment
- Memory: ~50-100MB per tab
- CPU: Depends on tasks

**Recommendations:**
- Monitor system resources if spawning many tabs
- Close unused tabs to free resources
- Consider sequential groups for resource-intensive tasks

## Security

**Command Execution:**
- Pasta Maker executes commands exactly as provided
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
1. Check scripts are executable: `chmod +x ~/.claude/plugins/pasta-maker/scripts/*.sh`
2. Verify terminal is detected: `./scripts/detect-terminal.sh`
3. Run validation: `./scripts/validate-installation.sh`

**"Not in a tmux session"**

Fix: Start tmux first, then run Pasta Maker from within the tmux session:
```bash
tmux new-session -s pasta-maker
# Then run /pasta-maker:run in Claude Code
```

**Terminal not detected or shows "unknown"**

Options:
1. Use tmux for best compatibility: `brew install tmux` or `apt install tmux`
2. Check if your terminal is supported (see Requirements section)
3. File an issue with your terminal details

**Permission denied errors**

Fix:
```bash
chmod +x ~/.claude/plugins/pasta-maker/scripts/*.sh
```

**Plugin not found**

Verify installation:
```bash
ls -la ~/.claude/plugins/pasta-maker
claude --plugin-dir ~/.claude/plugins/pasta-maker
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
4. Report issues at: https://github.com/fractional-ai/pasta-maker/issues
