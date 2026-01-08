---
description: Display comprehensive help and documentation for Pasta Maker
allowed-tools: Read
---

# Pasta Maker - Help

Display comprehensive help information about the Pasta Maker plugin.

## Overview

Pasta Maker is a Claude Code plugin that parallelizes tasks across terminal tabs. It analyzes dependencies between tasks and intelligently spawns them in parallel groups or sequential order.

## Available Commands

- `/pasta-maker:run` - Start the interactive task collection and parallelization workflow
- `/pasta-maker:help` - Display this help information

## How It Works

1. **Task Collection**: Describe your tasks in natural language
2. **Dependency Analysis**: Claude analyzes which tasks can run in parallel
3. **Plan Review**: You approve the execution plan
4. **Tab Spawning**: Tasks are automatically spawned in terminal tabs
5. **Coordination**: Claude helps coordinate sequential groups

## Supported Terminals

### macOS
- ✅ **iTerm2** - Native AppleScript support
- ✅ **Terminal.app** - Native AppleScript support
- ✅ **tmux** - Native tmux commands
- ✅ **Alacritty** - Via `msg create-window`
- ✅ **Kitty** - Via remote control API (requires config)
- ✅ **Warp** - Via AppleScript automation
- ✅ **Hyper** - Via AppleScript automation

### Linux
- ✅ **GNOME Terminal** - Native CLI support
- ✅ **Konsole** - Native CLI support (requires config)
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

### Konsole (KDE)
Enable in: **Settings → Configure Konsole → General**
- ☑ "Run all Konsole windows in a single process"

### Warp/Hyper (macOS)
Grant accessibility permissions:
- System Preferences → Security & Privacy → Privacy → Accessibility

## Example Use Cases

**Parallel Testing:**
```
Task 1: Run frontend tests
Task 2: Run backend tests
Task 3: Run linting
→ All run in parallel
```

**Sequential Build Pipeline:**
```
Group 1 (Parallel):
  - Install dependencies
  - Generate types

Group 2 (Sequential):
  - Build project

Group 3 (Parallel):
  - Run tests
  - Generate docs
```

**Dev Server Setup:**
```
Task 1: Start frontend dev server
Task 2: Start backend API server
Task 3: Start database
→ All run in parallel, stay open
```

## Debug Mode

Enable debug output for terminal detection:
```bash
export PASTA_MAKER_DEBUG=1
```

This outputs environment variables and detection logic to help troubleshoot issues.

## Getting Help

- **Documentation**: See [README.md](../README.md)
- **Issues**: Report bugs at https://github.com/fractional-ai/pasta-maker/issues
- **Usability Report**: See [guides/USABILITY_REPORT.md](../guides/USABILITY_REPORT.md)

## Quick Start

Simply run:
```
/pasta-maker:run
```

Then follow the interactive prompts to describe your tasks.

---

**Tip**: pasta-maker works best when you clearly describe what each task does and its dependencies. Claude will ask clarifying questions if needed.
