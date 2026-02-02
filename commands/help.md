---
description: Display help and documentation for Tribble
allowed-tools: Read
---

# Tribble - Help

Display help information about the Tribble plugin.

## Overview

Tribble is a Claude Code plugin that quickly spawns Claude Code sessions or commands in new terminal tabs.

Like tribbles, your sessions multiply rapidly.

## Available Commands

### Session Management
- `/tribble:spawn` - Spawn new tabs/sessions

### Help
- `/tribble:help` - Display this help information

## How It Works

1. You say what to spawn
2. Claude spawns tabs (minimal questions)
3. Done

**Single tab:**
```
/tribble:spawn open claude for auth
→ ✓ Tab created
```

**Multiple tabs:**
```
/tribble:spawn start frontend and backend
→ What commands?
→ ✓ Both tabs created
```

## Supported Terminals

### macOS
- ✅ **iTerm2** - Native AppleScript support
- ✅ **Terminal.app** - Native AppleScript support
- ✅ **Ghostty** - Native AppleScript support
- ✅ **Kitty** - Via remote control API (requires config)
- ✅ **Alacritty** - Via `msg create-window`
- ✅ **tmux** - Native tmux commands

### Linux
- ✅ **GNOME Terminal** - Native CLI support
- ✅ **tmux** - Native tmux commands
- ✅ **Alacritty** - Via `msg create-window`
- ✅ **Kitty** - Via remote control API (requires config)

### Windows (WSL)
- ✅ **Windows Terminal** - Native wt.exe command
- ✅ **tmux** - Native tmux commands
- ✅ **Alacritty** - Via `msg create-window`
- ✅ **Kitty** - Via remote control API (requires config)

### Not Supported
- ❌ **VS Code integrated terminal** - No external automation API (use tmux inside VS Code)

## Configuration Requirements

### Kitty
Add to `~/.config/kitty/kitty.conf`:
```
allow_remote_control yes
```

## Common Uses

- Open Claude session for specific feature
- Start multiple dev servers
- Run commands in parallel
- Open multiple Claude instances for different tasks

## Debug Mode

Enable debug output for terminal detection:
```bash
export TRIBBLE_DEBUG=1
```

This outputs environment variables and detection logic to help troubleshoot issues.

## Getting Help

- **Documentation**: See [README.md](../README.md)
- **Examples**: See [Examples.md](../Examples.md)
- **Issues**: Report bugs at https://github.com/fractional-ai/tribble/issues

## Quick Start

Simply run:
```
/tribble:spawn
```

Then tell Claude what you want to spawn. Tabs are created immediately - like tribbles multiplying.

---

**Tip**: Be specific about what you want. "Open claude to work on auth" spawns instantly. For multiple tasks, mention them all upfront: "start frontend, backend, and database".
