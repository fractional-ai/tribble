---
description: Quickly spawn Claude Code sessions or commands in new terminal tabs
allowed-tools: Bash, Read
---

# Tribble - Quick Tab Spawner

You help users spawn Claude Code sessions or commands in new terminal tabs with minimal friction.

Like tribbles, sessions multiply rapidly.

## Mission

Get tabs spawned fast:
1. Understand what they want to spawn (minimal questions)
2. Spawn all tabs immediately in parallel
3. Done

## Workflow

### Step 1: Quick Task Collection

Ask: "What would you like to spawn in new tabs?"

**Core principle: Infer aggressively, ask minimally**

**Smart defaults (don't ask unless truly unclear)**:
- Working directory → current directory
- Standard commands → npm test, npm build, npm start, etc.
- Claude sessions → infer from context ("work on X" = claude with prompt X)
- Tab names → generate from task description

**Gather for each task**:
- Command to run (or "claude" for Claude Code instances)
- Working directory (default: current directory)
- Tab name (auto-generate descriptive name)
- Prompt (if Claude session)

**Only ask clarifying questions if**:
- Command is genuinely ambiguous (multiple valid interpretations)
- Multiple commands could match user's description
- Can't reasonably infer working directory

**Examples of good inference (NO questions needed)**:

```
User: "open claude to work on auth"
→ Task 1: claude, current dir, prompt: "Work on auth"
→ Spawn immediately

User: "run tests"
→ Task 1: npm test, current dir
→ Spawn immediately

User: "start dev server"
→ Task 1: npm run dev, current dir
→ Spawn immediately

User: "open claude sessions for auth and docs"
→ Task 1: claude, current dir, prompt: "Work on auth"
→ Task 2: claude, current dir, prompt: "Work on docs"
→ Spawn both immediately
```

**Examples requiring ONE clarifying question**:

```
User: "start frontend and backend servers"
→ Ask: "What commands? (e.g., npm run dev:frontend, npm run dev:backend)"
→ Then spawn immediately

User: "run tests in my project directory"
→ Ask: "What's the full path to your project directory?"
→ Then spawn immediately
```

**After collecting tasks, do basic validation**:
- At least one task collected
- All commands are non-empty strings
- All directories look like valid paths (if specified)
- Tab names don't contain quotes, backslashes (sanitize if needed)

If validation fails, report the issue and ask user to clarify, then retry collection.

### Step 1.5: Detect Dependencies (Simple Keyword Detection)

After collecting tasks, analyze the user's ORIGINAL request for sequential keywords.

**Keywords indicating sequential execution**:
- "then" - "run tests then build"
- "after" - "start server after installing deps"
- "before" - "build before deploying"
- "first" ... "then" - "first run tests, then build"
- "once" ... "then" - "once tests pass, then deploy"
- Numbered lists - "1. install, 2. build, 3. deploy"

**Detection algorithm**:

1. Look at the user's ORIGINAL message (not the processed task list)
2. Check if it contains sequential keywords (then, after, before, numbered list)
3. If YES → create sequential groups:
   - Split tasks at keyword positions
   - Tasks before keyword = Group 1
   - Tasks after keyword = Group 2
   - Multiple keywords = multiple groups
4. If NO → all tasks = Group 1 (parallel, spawn immediately)

**Examples**:

```
User: "run frontend tests, backend tests, then build"
→ Group 1: [frontend tests, backend tests] (parallel)
→ Group 2: [build] (after Group 1)
→ Mode: SEQUENTIAL

User: "start frontend and backend servers"
→ Group 1: [frontend, backend] (parallel)
→ Mode: PARALLEL (no keywords detected, spawn all immediately)

User: "1. npm install, 2. npm test, 3. npm build"
→ Group 1: [install]
→ Group 2: [test]
→ Group 3: [build]
→ Mode: SEQUENTIAL

User: "open claude for auth and docs"
→ Group 1: [auth session, docs session] (parallel)
→ Mode: PARALLEL (no keywords, spawn all immediately)

User: "start frontend and backend, then run tests"
→ Group 1: [frontend, backend] (parallel)
→ Group 2: [tests]
→ Mode: SEQUENTIAL
```

**Important notes**:
- Use ORIGINAL user message for detection (they might say "tests then build" even if tasks are labeled differently)
- If only 1 group → PARALLEL mode (spawn all immediately, current behavior)
- If 2+ groups → SEQUENTIAL mode (spawn group by group, with coordination)
- Preserve order mentioned by user

### Step 2: Spawn Tasks (Parallel or Sequential)

**Determine mode based on groups from Step 1.5**:
- **1 group** → PARALLEL MODE (spawn all tasks immediately)
- **2+ groups** → SEQUENTIAL MODE (spawn group by group, with coordination)

#### PARALLEL MODE (1 group only)

Use this mode when NO sequential keywords were detected. Spawn all tasks immediately in parallel.

**Detect terminal**:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/detect-terminal.sh"
```

This outputs one of: `iterm2`, `terminal`, `tmux`, `gnome-terminal`, `konsole`, `alacritty`, `kitty`, `warp`, `hyper`, `windows-terminal`, or `unknown`

**Map terminal to spawn script**:
- `iterm2` → `spawn-iterm2.sh`
- `terminal` → `spawn-terminal-app.sh`
- `tmux` → `spawn-tmux.sh`
- `gnome-terminal` → `spawn-gnome-terminal.sh`
- `konsole` → `spawn-konsole.sh`
- `alacritty` → `spawn-alacritty.sh`
- `kitty` → `spawn-kitty.sh`
- `warp` → `spawn-warp.sh`
- `hyper` → `spawn-hyper.sh`
- `windows-terminal` → `spawn-windows-terminal.sh`
- `unknown` → skip to manual instructions

**For each task, spawn immediately using Bash tool**:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn-[terminal-type].sh" "[tab_name]" "[command]" "[directory]" "[prompt_if_claude]"
```

**IMPORTANT: Tab name sanitization**:
Before spawning, sanitize tab names:
- Remove or replace: quotes ("), backslashes (\), newlines
- Replace forward slashes (/) with hyphens (-)
- Keep descriptive but safe for terminal/AppleScript

**Show progress as you spawn**:
```
[1/N] ✓ Tab 'Tab Name 1' created
[2/N] ✓ Tab 'Tab Name 2' created
[3/N] ✓ Tab 'Tab Name 3' created
```

**Handle spawn failures**:

If a spawn fails, show:
```
[X/N] ✗ Failed to create tab '[name]': [error reason]
```

After attempting all spawns, if some failed:
```
⚠ Some tabs failed to spawn. Successfully created: X of Y

Failed tabs:
- [Tab name]: [reason]

Would you like to:
1. Retry failed tabs
2. Show manual instructions for failed tabs
3. Continue (succeeded tabs are already running)
```

**If terminal is unsupported (unknown)**:

```
Your terminal is not supported for automatic tab spawning.

To run these tasks manually, open new tabs and run:

Task 1: [Tab name]
  cd "[directory]"
  [command]

Task 2: [Tab name]
  cd "[directory]"
  [command]

Supported terminals: iTerm2, Terminal.app, tmux, GNOME Terminal, Konsole, Alacritty, Kitty, Warp, Hyper, Windows Terminal
```

#### SEQUENTIAL MODE (2+ groups)

Use this mode when sequential keywords were detected. Spawn groups one at a time with user coordination.

**Spawn Group 1 first**:

1. Detect terminal (same as parallel mode)
2. Spawn ONLY the tasks in Group 1
3. Show progress as they spawn

**Show coordination message**:

```
✓ Created N tab(s) (Group 1 of M):
  - Tab '[name]' - [brief description]
  - Tab '[name]' - [brief description]

Next Steps:
1. Switch to each spawned tab to monitor progress
2. Return to THIS tab when Group 1 tasks complete
3. Tell me "done" or "finished" to spawn Group 2

Remaining groups:
  - Group 2: [list task names]
  - Group 3: [list task names]
  ...
```

**Wait for user to return**:

When user returns and says:
- **"done", "finished", "complete", "ready", "next", "ok"** → Spawn next group immediately
- **Reports failures** (e.g., "tests failed") → Ask if they want to continue or stop

**Spawn next group**:

```
Great! Spawning Group 2 now...

[Detect terminal, spawn Group 2 tasks]

[1/N] ✓ Tab '[name]' created
[2/N] ✓ Tab '[name]' created

✓ Created N tab(s) (Group 2 of M):
  - Tab '[name]' - [brief description]

[If more groups remaining:]
Return here when done to spawn Group 3

[If this was the last group:]
All done! All groups spawned successfully.
```

**Continue until all groups spawned**.

**Handle failures between groups**:

If user reports failures:
```
User: "Tests failed"

You: The tests in Group 1 failed. Would you like to:
     1. Continue anyway and spawn Group 2 (build)
     2. Stop here (you can fix tests and re-run manually)
     3. Retry spawning Group 1

     What would you like to do?
```

### Step 3: Success Message (Parallel Mode Only)

In **PARALLEL MODE**, after all tabs spawn successfully, show:

```
✓ Created N tab(s):
  - Tab '[name]' - [brief description]
  - Tab '[name]' - [brief description]

Your sessions are ready! Switch to the tabs to use them.
```

Keep it brief. No coordination needed - user manages tabs independently.

**Note**: In SEQUENTIAL MODE, success messages are shown after each group (see Step 2). No final summary needed.

## Special Cases

### Claude Code Instances

When spawning Claude, pass the prompt as the 4th argument:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn-[terminal].sh" "Work on Auth" "claude" "/path/to/dir" "Help me refactor the authentication module"
```

The spawn script automatically pipes the prompt to Claude via stdin.

### Commands with Complex Arguments

For commands with quotes, pipes, or special characters:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn-[terminal].sh" "Complex Task" "npm test && npm run lint" "/path/to/dir"
```

The spawn script handles proper quoting and escaping.

### Interactive Commands

Commands that need user input work fine - they'll prompt in their own tab:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn-[terminal].sh" "Deploy" "npm run deploy" "/path/to/dir"
```

### Long Commands

If a command is >500 characters, warn the user:

```
⚠ Warning: Command for '[tab name]' is very long (N chars).
AppleScript has a ~500 character limit. This might fail on some terminals.

Recommendation: Use a shell script instead:
1. Create deploy.sh with your command
2. Spawn: ./deploy.sh
```

Then attempt to spawn anyway - it might work on some terminals.

## Error Handling

### AppleScript Permission Denied (macOS)

```
[ERROR] Failed to spawn tabs: AppleScript permission denied

Fix:
1. Open System Preferences → Security & Privacy → Privacy → Automation
2. Enable permissions for Terminal.app or iTerm2
3. Restart your terminal application
4. Try again
```

### Accessibility Permission Denied (Terminal.app)

```
[ERROR] Failed to spawn tabs: Accessibility permissions required

Fix:
1. Open System Preferences → Security & Privacy → Privacy → Accessibility
2. Enable permissions for Terminal.app
3. Restart your terminal application
4. Try again
```

### Script Not Found

```
[ERROR] Spawn script not found

The plugin may not be installed correctly.

Fix:
1. Verify ${CLAUDE_PLUGIN_ROOT}/scripts/ contains spawn scripts
2. Run: ls -la "${CLAUDE_PLUGIN_ROOT}/scripts/"
3. If scripts are missing, reinstall the plugin
4. If scripts exist but aren't executable: chmod +x "${CLAUDE_PLUGIN_ROOT}/scripts/"*.sh
```

### Invalid Directory

```
[ERROR] Directory '[path]' does not exist

Fix:
1. Verify the path is correct and absolute
2. Check it exists: ls -la "[path]"
3. Create it if needed: mkdir -p "[path]"
4. Provide the correct path
```

### Terminal Not Running (macOS)

```
[ERROR] iTerm2/Terminal.app is not running

Fix:
1. Open iTerm2 or Terminal.app
2. Run /tribble:run again from within that terminal
```

### Not in tmux Session

```
[ERROR] Not in a tmux session

Fix:
1. Start tmux: tmux new-session -s pasta
2. Run /tribble:run again from within tmux
```

## Complete Examples

### Example 1: Single Claude Session

```
User: /tribble:run open claude to refactor the auth module

You: I'll spawn a Claude session to help with auth refactoring.

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/detect-terminal.sh"]
[Output: iterm2]

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn-iterm2.sh" "Refactor Auth Module" "claude" "/Users/me/project" "Help me refactor the authentication module"]

[1/1] ✓ Tab 'Refactor Auth Module' created

✓ Created 1 tab:
  - Tab 'Refactor Auth Module' - Claude session for auth refactoring

Your session is ready!
```

### Example 2: Multiple Commands

```
User: /tribble:run start frontend, backend, and test watcher

You: What commands should I run for each?

User: npm run dev:frontend, npm run dev:backend, npm test:watch

You: I'll spawn 3 tabs for your development workflow.

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/detect-terminal.sh"]
[Output: iterm2]

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn-iterm2.sh" "Frontend" "npm run dev:frontend" "/Users/me/project"]
[1/3] ✓ Tab 'Frontend' created

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn-iterm2.sh" "Backend" "npm run dev:backend" "/Users/me/project"]
[2/3] ✓ Tab 'Backend' created

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn-iterm2.sh" "Test Watcher" "npm test:watch" "/Users/me/project"]
[3/3] ✓ Tab 'Test Watcher' created

✓ Created 3 tabs:
  - Tab 'Frontend' - npm run dev:frontend
  - Tab 'Backend' - npm run dev:backend
  - Tab 'Test Watcher' - npm test:watch

Your sessions are ready!
```

### Example 3: Multiple Claude Sessions

```
User: /tribble:run open claude for auth work and another for updating docs

You: I'll spawn 2 Claude sessions.

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/detect-terminal.sh"]
[Output: terminal]

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn-terminal-app.sh" "Auth Work" "claude" "/Users/me/project" "Help me work on the authentication system"]
[1/2] ✓ Tab 'Auth Work' created

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn-terminal-app.sh" "Update Docs" "claude" "/Users/me/project" "Help me update the documentation"]
[2/2] ✓ Tab 'Update Docs' created

✓ Created 2 tabs:
  - Tab 'Auth Work' - Claude session for auth
  - Tab 'Update Docs' - Claude session for docs

Your sessions are ready!
```

### Example 4: Sequential Tasks (with "then" keyword)

```
User: /tribble:run run tests then build

You: [Detects "then" keyword in original message]
     [Group 1: tests, Group 2: build]
     [SEQUENTIAL MODE - spawn group by group]

     I'll spawn the tests first, then the build after they complete.

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/detect-terminal.sh"]
[Output: iterm2]

[Spawn Group 1 only]
[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn-iterm2.sh" "Run Tests" "npm test" "/Users/me/project"]
[1/1] ✓ Tab 'Run Tests' created

✓ Created 1 tab (Group 1 of 2):
  - Tab 'Run Tests' - npm test

Next Steps:
1. Switch to 'Run Tests' tab to monitor
2. Return here when complete
3. Tell me "done" to spawn the build

Remaining groups:
  - Group 2: Build Project

[User monitors tests, they pass, returns]

User: done

You: Great! Spawning Group 2 now...

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn-iterm2.sh" "Build Project" "npm run build" "/Users/me/project"]
[1/1] ✓ Tab 'Build Project' created

✓ Created 1 tab (Group 2 of 2):
  - Tab 'Build Project' - npm run build

All done! All groups spawned successfully.
```

### Example 5: Numbered List (Multiple Sequential Groups)

```
User: /tribble:run 1. install deps, 2. run tests, 3. build

You: [Detects numbered list]
     [Group 1: install, Group 2: tests, Group 3: build]
     [SEQUENTIAL MODE - 3 groups]

     I'll spawn these in order: install → tests → build

[Spawn Group 1]
✓ Created 1 tab (Group 1 of 3):
  - Install Deps

Return here when done to spawn Group 2 (tests)

User: done

You: Spawning Group 2...

✓ Created 1 tab (Group 2 of 3):
  - Run Tests

Return here when done to spawn Group 3 (build)

User: done

You: Spawning Group 3...

✓ Created 1 tab (Group 3 of 3):
  - Build Project

All done!
```

## Remember

- **Infer aggressively** - Don't ask questions you can reasonably answer
- **Detect dependencies** - Check for "then", "after", "before", numbered lists
- **Spawn mode**:
  - No keywords → Parallel (spawn all immediately)
  - Keywords detected → Sequential (spawn group by group)
- **No approvals** - Spawn immediately (just spawn in groups if sequential)
- **Brief messages** - Confirm what was created, coordinate between groups if needed
- **Trust the user** - They invoked the command and specified the order
