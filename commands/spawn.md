---
description: Spawn new Claude Code sessions or terminal tabs. Use when user wants to "start a session", "make a new session", "spawn a new session", "make a new claude session", "spawn a claude session", "open a new claude", "start another claude", "open a new tab", "new terminal tab", "new tab for", "create a tab", "spawn in a tab", "open another terminal", "new tmux window", "new iterm tab", "parallel session", "open an agent", "spin up an agent", "start an agent", or run commands in new tabs. NOT for subagents - this creates actual terminal tabs/windows.
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

**Detecting Claude prompts vs shell commands**:

When the user provides input, determine if it's a shell command or a Claude prompt:

**Shell command indicators** (treat as shell command):
- Starts with common commands: npm, git, python, node, cargo, go, docker, make, etc.
- Contains shell operators: &&, ||, |, >, <, ;
- Contains file paths or flags: ./script.sh, --flag, -x
- Follows command patterns: "run X", "start X", "build X" where X is a known script name
- Git operations: "git worktree", "git checkout", "git clone", etc. (but see Step 1.8 for worktree special handling)

**Claude prompt indicators** (treat as Claude session):
- Session creation phrases: "start a session", "make a new session", "spawn a new session", "make a new claude session", "spawn a claude session", "open a new claude", "start another claude", "create a claude session", "spin up a claude"
- Natural language requests: "write a poem", "explain quantum physics", "help me understand X"
- Imperative actions without command context: "create a React component", "refactor this code"
- Creative/analysis tasks: "design a logo", "review my code", "brainstorm ideas"
- Questions: "how do I...", "what is...", "can you..."
- Explicit Claude mentions: "open claude to...", "claude session for...", "claude for..."

**Default heuristic**: If unsure and input is:
- One word without common command prefix → likely Claude prompt (e.g., "poetry", "debug")
- Natural sentence structure → likely Claude prompt (e.g., "write a poem")
- Technical command structure → likely shell command (e.g., "npm test")

When in doubt, prefer interpreting as a Claude prompt if it reads like natural language.

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
User: "write a poem"
→ Task 1: claude, current dir, prompt: "Write a poem"
→ Spawn immediately (natural language = Claude prompt)

User: "open claude to work on auth"
→ Task 1: claude, current dir, prompt: "Work on auth"
→ Spawn immediately

User: "help me debug this code"
→ Task 1: claude, current dir, prompt: "Help me debug this code"
→ Spawn immediately (natural language = Claude prompt)

User: "run tests"
→ Task 1: npm test, current dir
→ Spawn immediately (command pattern = shell command)

User: "start dev server"
→ Task 1: npm run dev, current dir
→ Spawn immediately (command pattern = shell command)

User: "open claude sessions for auth and docs"
→ Task 1: claude, current dir, prompt: "Work on auth"
→ Task 2: claude, current dir, prompt: "Work on docs"
→ Spawn both immediately

User: "npm test && npm build"
→ Task 1: npm test && npm build, current dir
→ Spawn immediately (shell operators = shell command)

User: "explain how async/await works"
→ Task 1: claude, current dir, prompt: "Explain how async/await works"
→ Spawn immediately (question = Claude prompt)
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

### Step 1.8: Worktree Session Prompts (Special Case)

**⚠️  CRITICAL: Worktrees require a two-step process to work correctly.**

**Detection**: A task needs worktree setup if:
- User explicitly mentions "worktree", "git worktree", or "new worktree"
- User wants to work on a different branch in a new worktree
- Task involves creating a separate git working directory

**CORRECT Worktree Workflow (Two-Step Process)**:

**Step 1: Tell user to create worktree in CURRENT session first**

When a worktree request is detected, respond with:

```
⚠️  To work in a worktree, we need to create it first, then spawn a new session there.

Let me guide you through the two-step process:

Step 1 (in THIS session): Create the worktree
  Run: scripts/new-worktree.sh [branch-name]

Step 2 (after creation): Come back and I'll spawn a Claude session in the worktree

Ready to start? What should I name the branch?
```

**Step 2: After user confirms worktree is created, spawn in that directory**

Once worktree exists at `../<branch-name>`, spawn with:
- Working directory: `../<branch-name>`
- Command: `claude`
- Prompt: Context about the task

**Example workflow**:

```
User: /tribble:spawn open claude to work on feature-xyz in a new worktree

You: ⚠️  To work in a worktree, we need to create it first.

Step 1: Create the worktree in THIS session
  Run: scripts/new-worktree.sh feature-xyz

Step 2: After it's created, I'll spawn a Claude session in ../feature-xyz

Let's start - I'll create the worktree now.

[Run: bash scripts/new-worktree.sh feature-xyz]

✅ Worktree created at ../feature-xyz

Now spawning Claude session in the worktree...

[Spawn with directory: "../feature-xyz", command: "claude", prompt: "Work on feature-xyz: [task description]"]

[1/1] ✓ Tab 'Feature XYZ' created in ../feature-xyz

✓ Created 1 tab:
  - Tab 'Feature XYZ' - Claude session in worktree ../feature-xyz

The session is running in the worktree and will work on the feature branch.
```

**Why this two-step process?**
- Spawned sessions inherit the working directory from the spawn command
- If you spawn from staging, the session starts in staging
- Creating worktree FIRST, then spawning IN that directory ensures safety
- The spawned session will verify it's on a feature branch before making changes

**Alternative: User creates worktree manually**

If the user prefers to create the worktree themselves:

```
User: I've created ../feature-xyz, spawn claude there

You: I'll spawn a Claude session in ../feature-xyz

[Spawn with directory: "../feature-xyz"]
```

**Common worktree patterns**:

```
"work on auth in new worktree" → Create ../auth worktree, then spawn there
"create worktree for feature-x" → Create ../feature-x worktree, then spawn there
"new branch in separate worktree" → Create ../branch worktree, then spawn there
```

#### PARALLEL MODE (1 group only)

Use this mode when NO sequential keywords were detected. Spawn all tasks immediately in parallel.

**For each task, spawn immediately using the unified spawn script** (after any worktree setup from Step 1.8):

```bash
# POSITIONAL ARGUMENTS ONLY - no flags like --prompt or --name
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "<tab_name>" "<command>" "<directory>" "[prompt]" "[color]"
```

**Arguments (positional, in order)**:
1. `tab_name` - Name for the tab (required)
2. `command` - Command to run, e.g. "claude" or "npm test" (required)
3. `directory` - Working directory path (required)
4. `prompt` - Optional prompt to pipe to command
5. `color` - Optional tab color

**Example**:
```bash
# Spawn a Claude session with a prompt
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Auth Work" "claude" "/Users/me/project" "Help me with authentication"
```

The unified spawn script automatically detects the terminal type and spawns the tab accordingly. It supports: iTerm2, Terminal.app, Ghostty, tmux, GNOME Terminal, Konsole, Alacritty, Kitty, Warp, Hyper, Windows Terminal, and VS Code.

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

Supported terminals: iTerm2, Terminal.app, Ghostty, tmux, GNOME Terminal, Konsole, Alacritty, Kitty, Warp, Hyper, Windows Terminal
```

#### SEQUENTIAL MODE (2+ groups)

Use this mode when sequential keywords were detected. Spawn groups one at a time with user coordination.

**Spawn Group 1 first**:

1. Spawn ONLY the tasks in Group 1 using the unified spawn script
2. Show progress as they spawn

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

When spawning Claude sessions, **always include relevant context from the current session** so the new Claude instance understands what's being worked on.

**Context to gather and include**:
1. **Current task/goal** - What is the user working on in this session?
2. **Relevant files** - What files have been discussed, read, or modified?
3. **Errors or issues** - Any errors encountered or problems being debugged?
4. **Technical context** - Framework, language, architecture details mentioned
5. **Git context** - Current branch, recent changes (use Read tool on git commands if needed)

**Format the enhanced prompt**:
```
You're being spawned from another Claude session. Here's the context:

## Current Work
[Summary of what the user is working on - 2-3 sentences]

## Relevant Files
[List files that have been discussed or are relevant to the task]

## Background
[Any errors, issues, or technical details the new session needs to know]

## Task
[User's specific request for this new session]
```

**Example**:
```bash
# User in current session is debugging auth issues in src/auth.ts
# They want to spawn a Claude session to work on tests in parallel

PROMPT="You're being spawned from another Claude session. Here's the context:

## Current Work
Working on fixing authentication bug where JWT tokens aren't being validated correctly. The main session is debugging src/auth.ts.

## Relevant Files
- src/auth.ts (JWT validation logic)
- src/middleware/auth.middleware.ts (uses validation)
- tests/auth.test.ts (needs updating)

## Task
Write comprehensive tests for the JWT validation logic in src/auth.ts to ensure tokens are validated correctly."

"${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Auth Tests" "claude" "/Users/me/project" "$PROMPT"
```

The spawn script automatically pipes the enhanced prompt to Claude via stdin.

### Commands with Complex Arguments

For commands with quotes, pipes, or special characters:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Complex Task" "npm test && npm run lint" "/path/to/dir"
```

The spawn script handles proper quoting and escaping.

### Interactive Commands

Commands that need user input work fine - they'll prompt in their own tab:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Deploy" "npm run deploy" "/path/to/dir"
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
2. Run /tribble:spawn again from within that terminal
```

### Not in tmux Session

```
[ERROR] Not in a tmux session

Fix:
1. Start tmux: tmux new-session -s tribble
2. Run /tribble:spawn again from within tmux
```

## Complete Examples

### Example 1: Single Claude Session

```
User: /tribble:spawn open claude to refactor the auth module

You: I'll spawn a Claude session to help with auth refactoring.

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Refactor Auth Module" "claude" "/Users/me/project" "Help me refactor the authentication module"]

[1/1] ✓ Tab 'Refactor Auth Module' created

✓ Created 1 tab:
  - Tab 'Refactor Auth Module' - Claude session for auth refactoring

Your session is ready!
```

### Example 2: Multiple Commands

```
User: /tribble:spawn start frontend, backend, and test watcher

You: What commands should I run for each?

User: npm run dev:frontend, npm run dev:backend, npm test:watch

You: I'll spawn 3 tabs for your development workflow.

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Frontend" "npm run dev:frontend" "/Users/me/project"]
[1/3] ✓ Tab 'Frontend' created

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Backend" "npm run dev:backend" "/Users/me/project"]
[2/3] ✓ Tab 'Backend' created

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Test Watcher" "npm test:watch" "/Users/me/project"]
[3/3] ✓ Tab 'Test Watcher' created

✓ Created 3 tabs:
  - Tab 'Frontend' - npm run dev:frontend
  - Tab 'Backend' - npm run dev:backend
  - Tab 'Test Watcher' - npm test:watch

Your sessions are ready!
```

### Example 3: Multiple Claude Sessions

```
User: /tribble:spawn open claude for auth work and another for updating docs

You: I'll spawn 2 Claude sessions.

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Auth Work" "claude" "/Users/me/project" "Help me work on the authentication system"]
[1/2] ✓ Tab 'Auth Work' created

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Update Docs" "claude" "/Users/me/project" "Help me update the documentation"]
[2/2] ✓ Tab 'Update Docs' created

✓ Created 2 tabs:
  - Tab 'Auth Work' - Claude session for auth
  - Tab 'Update Docs' - Claude session for docs

Your sessions are ready!
```

### Example 4: Sequential Tasks (with "then" keyword)

```
User: /tribble:spawn run tests then build

You: [Detects "then" keyword in original message]
     [Group 1: tests, Group 2: build]
     [SEQUENTIAL MODE - spawn group by group]

     I'll spawn the tests first, then the build after they complete.

[Spawn Group 1 only]
[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Run Tests" "npm test" "/Users/me/project"]
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

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Build Project" "npm run build" "/Users/me/project"]
[1/1] ✓ Tab 'Build Project' created

✓ Created 1 tab (Group 2 of 2):
  - Tab 'Build Project' - npm run build

All done! All groups spawned successfully.
```

### Example 5: Numbered List (Multiple Sequential Groups)

```
User: /tribble:spawn 1. install deps, 2. run tests, 3. build

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

### Example 6: Worktree Creation (In-Session Setup)

```
User: /tribble:spawn open claude to work on feature-login in a new worktree

You: [Detects "worktree" keyword - needs worktree setup]

     I'll spawn a Claude session to create the worktree and work on feature-login.

[Spawn with enhanced prompt:]

PROMPT="Create a new git worktree for feature-login and work on implementing the login feature.

Steps:
1. Create worktree: git worktree add ../feature-login -b feature-login
2. The worktree will be at ../feature-login
3. After creation, begin work on implementing the login feature

Current context: Working on authentication system in main codebase."

[Run: "${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" "Feature Login Worktree" "claude" "/Users/me/project" "$PROMPT"]

[1/1] ✓ Tab 'Feature Login Worktree' created

✓ Created 1 tab:
  - Tab 'Feature Login Worktree' - Claude will create worktree and work on feature

The Claude session will create the worktree at ../feature-login and begin work.
```

**Key difference**: Claude spawns immediately with instructions to create the worktree. The worktree creation happens INSIDE the new Claude session, not in the current window.

## Composability

Spawned Claude sessions are full instances with access to all tools, including `/tribble:spawn`.

This means:
- Sessions can spawn sessions
- The prompt defines the workflow logic
- No artificial limits on depth or structure

Tribble provides the spawning primitive. You provide the logic.

## Remember

- **Infer aggressively** - Don't ask questions you can reasonably answer
- **Worktree handling** - Spawn Claude sessions with instructions to create worktrees INSIDE the new session. Include clear steps in the prompt.
- **Detect dependencies** - Check for "then", "after", "before", numbered lists
- **Spawn mode**:
  - No keywords → Parallel (spawn all immediately)
  - Keywords detected → Sequential (spawn group by group)
- **No approvals** - Spawn immediately (just spawn in groups if sequential)
- **Brief messages** - Confirm what was created, coordinate between groups if needed
- **Trust the user** - They invoked the command and specified the order
