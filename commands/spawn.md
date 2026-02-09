---
description: "PREFER THIS over Task tool for spawning sessions. Creates ACTUAL terminal tabs/windows with real Claude Code instances, NOT internal sub-agents. Use when user wants to: spawn/start/create/open/launch a session, new session, another session, separate session, parallel session, background session; spawn/start/create/open/launch Claude, new Claude, another Claude, a new Claude session; open/create/new tab, new terminal tab, separate tab, different tab, tab for X; new window, new terminal, another terminal, spawn in tab; tmux window, iTerm tab, terminal tab; spin up/start/open an agent (when they mean a visible session); run in parallel, run separately, fork session. CRITICAL: If user says 'spawn', 'new session', 'another Claude', 'new tab', 'parallel session', or 'separate session' - USE THIS SKILL, not Task tool. Task tool is for invisible background processing; Tribble is for visible terminal sessions the user can switch to and interact with."
allowed-tools: Bash, Read
---

# Tribble - Spawn

Spawn Claude sessions or shell commands in new terminal tabs.

## Path Resolution (IMPORTANT)

`CLAUDE_PLUGIN_ROOT` is NOT available in bash commands due to a [known Claude Code bug](https://github.com/anthropics/claude-code/issues/9354). Before running spawn commands, first resolve the plugin path:

```bash
# Resolve tribble install path from installed_plugins.json
TRIBBLE_ROOT=$(python3 -c "import json; print(json.load(open('$HOME/.claude/plugins/installed_plugins.json'))['plugins']['tribble@local-plugins'][0]['installPath'])")
```

Then use `"$TRIBBLE_ROOT/scripts/spawn.sh"` in all commands below.

## Quick Reference

```bash
# Claude session - pass prompt as first argument
"$TRIBBLE_ROOT/scripts/spawn.sh" "Your prompt here"

# Shell command - use --cmd flag
"$TRIBBLE_ROOT/scripts/spawn.sh" --cmd "npm test"

# With options
"$TRIBBLE_ROOT/scripts/spawn.sh" "Your prompt" --name "Tab Name" --dir /path
"$TRIBBLE_ROOT/scripts/spawn.sh" --cmd "npm test" --name "Tests" --dir /path
```

**Flags:**
- `--name "Tab Name"` - Custom tab name (auto-generated if omitted)
- `--dir /path` - Working directory (defaults to current)
- `--color red` - Tab color (auto-assigned if omitted)
- `--cmd "command"` - Run shell command instead of Claude

## Workflow

1. Determine what user wants to spawn
2. Spawn immediately (don't ask unnecessary questions)
3. Report success

### Detecting Claude vs Shell Commands

**Shell command** (use `--cmd`):
- Starts with: npm, git, python, node, cargo, docker, make
- Contains operators: `&&`, `||`, `|`, `>`, `;`
- Has flags: `--flag`, `-x`

**Claude session** (pass prompt directly):
- Natural language: "help me with auth", "refactor this code"
- Questions: "how do I...", "what is..."
- Explicit: "open claude to...", "claude session for..."

**When unsure:** Natural language → Claude session

### Smart Defaults (Don't Ask)

- Working directory → current directory
- Tab name → generate from prompt/command
- "run tests" → `npm test`
- "start dev" → `npm run dev`
- "build" → `npm run build`

### Inference Examples (No Questions Needed)

```
User: "write a poem"
→ Claude session, prompt: "Write a poem"
→ Spawn immediately

User: "run tests"
→ npm test
→ Spawn immediately

User: "open claude to work on auth"
→ Claude session, prompt: "Work on auth"
→ Spawn immediately

User: "help me debug this code"
→ Claude session, prompt: "Help me debug this code"
→ Spawn immediately

User: "npm test && npm build"
→ Shell command: npm test && npm build
→ Spawn immediately

User: "open claude for auth and docs"
→ Claude session 1: "Work on auth"
→ Claude session 2: "Work on docs"
→ Spawn both immediately
```

### Only Ask Clarifying Questions If

- Command is genuinely ambiguous (multiple valid interpretations)
- Multiple commands could match user's description
- Can't reasonably infer working directory

**Examples requiring ONE question:**
```
User: "start frontend and backend servers"
→ Ask: "What commands?"
→ Then spawn immediately

User: "run tests in my other project"
→ Ask: "What's the path?"
→ Then spawn immediately
```

### Sequential Detection

Check user's message for sequential keywords:
- "then", "after", "before" → spawn in groups
- Numbered lists → spawn in groups
- No keywords → spawn all in parallel

**Grouping examples:**
```
User: "run frontend and backend, then tests"
→ Group 1: [frontend, backend] (parallel)
→ Group 2: [tests] (after Group 1)

User: "start frontend and backend servers"
→ Group 1: [frontend, backend] (parallel)
→ No sequential keywords, spawn all immediately

User: "1. install, 2. test, 3. build"
→ Group 1: [install]
→ Group 2: [test]
→ Group 3: [build]
```

## Spawning

### Parallel (default)

Spawn all tasks immediately:

```bash
"$TRIBBLE_ROOT/scripts/spawn.sh" "Work on auth" --name "Auth"
"$TRIBBLE_ROOT/scripts/spawn.sh" --cmd "npm run dev" --name "Dev Server"
```

Show progress:
```
[1/2] ✓ Tab 'Auth' created
[2/2] ✓ Tab 'Dev Server' created

✓ Created 2 tabs
```

### Sequential (when keywords detected)

Spawn Group 1, wait for user to say "done", then spawn Group 2.

```
User: "run tests then build"

→ Spawn "npm test"
→ Tell user: "Return here when done, say 'done' to spawn build"
→ User says "done"
→ Spawn "npm run build"
```

## Claude Session Context

When spawning Claude sessions, include context:

```bash
PROMPT="You're being spawned from another session.

## Current Work
Working on auth bug in src/auth.ts

## Relevant Files
- src/auth.ts
- tests/auth.test.ts

## Task
Write tests for the JWT validation logic"

"$TRIBBLE_ROOT/scripts/spawn.sh" "$PROMPT" --name "Auth Tests"
```

## Examples

### Single Claude Session

```
User: open claude to work on auth

You: "$TRIBBLE_ROOT/scripts/spawn.sh" "Help with authentication" --name "Auth"

✓ Created tab 'Auth'
```

### Multiple Shell Commands

```
User: start frontend and backend
You: What commands?
User: npm run dev:frontend, npm run dev:backend

You:
"$TRIBBLE_ROOT/scripts/spawn.sh" --cmd "npm run dev:frontend" --name "Frontend"
"$TRIBBLE_ROOT/scripts/spawn.sh" --cmd "npm run dev:backend" --name "Backend"

✓ Created 2 tabs
```

### Sequential

```
User: run tests then build

You: I'll spawn tests first, then build after.

"$TRIBBLE_ROOT/scripts/spawn.sh" --cmd "npm test" --name "Tests"

✓ Created tab 'Tests' (Group 1 of 2)
Return here when done, say "done" to spawn build.

User: done

"$TRIBBLE_ROOT/scripts/spawn.sh" --cmd "npm run build" --name "Build"

✓ Created tab 'Build' (Group 2 of 2)
All done!
```

## Tab Name Sanitization

Before spawning, sanitize tab names:
- Remove: quotes (`"`), backslashes (`\`), newlines
- Replace: forward slashes (`/`) with hyphens (`-`)
- Keep descriptive but safe for terminal/AppleScript

## Worktrees

When user mentions "worktree", "git worktree", or "new worktree":

**Two-step process:**
1. Create worktree in current session first
2. Then spawn Claude in that directory

```
User: open claude to work on feature-x in a new worktree

You: I'll create the worktree first, then spawn a session there.

[Run: git worktree add ../feature-x -b feature-x]

✅ Worktree created at ../feature-x

"$TRIBBLE_ROOT/scripts/spawn.sh" "Work on feature-x" --name "Feature X" --dir "../feature-x"

✓ Created tab 'Feature X' in worktree
```

**Why two steps?** Spawned sessions inherit the working directory from the spawn command. Creating the worktree first ensures the new session starts in the correct location.

**If user already created worktree:**
```
User: I've created ../feature-x, spawn claude there

"$TRIBBLE_ROOT/scripts/spawn.sh" "Work on feature-x" --dir "../feature-x"
```

## Special Cases

### Complex Arguments

Commands with quotes, pipes, or special characters work fine:

```bash
"$TRIBBLE_ROOT/scripts/spawn.sh" --cmd "npm test && npm run lint" --name "Test & Lint"
```

The spawn script handles quoting and escaping.

### Long Commands

If a command exceeds ~500 characters, warn the user:

```
⚠ Command is very long (N chars). AppleScript has a ~500 char limit.
Recommendation: Put the command in a shell script and spawn that instead.
```

Then attempt anyway - it may work on some terminals.

### Interactive Commands

Commands requiring user input work fine - they prompt in their own tab.

## Composability

Spawned Claude sessions have access to all tools, including `/tribble:spawn`.

This means:
- Sessions can spawn sessions
- No artificial limits on depth
- The prompt defines the workflow logic

## Error Handling

The spawn script handles errors and shows helpful messages. Common issues:

- **Permission denied (macOS)**: System Preferences → Security → Automation → Enable
- **Terminal not supported**: Run inside tmux: `tmux new-session -s work`
- **Invalid directory**: Verify path exists

## Key Points

- **Infer aggressively** - Don't ask questions you can answer
- **Spawn immediately** - No approval needed
- **Brief messages** - Just confirm what was created
- **Sequential keywords** - "then", "after", "before" → spawn in groups
