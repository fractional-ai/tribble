# Pasta Maker - Quick Start Guide

Get up and running with Pasta Maker in 2 minutes.

## What is Pasta Maker?

Pasta Maker runs multiple tasks in parallel across terminal tabs. Claude analyzes dependencies and spawns tasks automatically, saving you time.

**Example:** Frontend tests + backend tests run in parallel (saves ~10 min), then build runs after both complete.

## Installation (2 minutes)

### Step 1: Install the Plugin

Choose one method:

**Option A: One-line install**
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR-ORG/pasta-maker/main/install.sh | bash -s git@github.com:YOUR-ORG/pasta-maker.git
```

**Option B: Manual install**
```bash
git clone git@github.com:YOUR-ORG/pasta-maker.git ~/.claude/plugins/pasta-maker
chmod +x ~/.claude/plugins/pasta-maker/scripts/*.sh
```

### Step 2: Configure Your Shell (Optional but Recommended)

Add this alias to your `~/.bashrc` or `~/.zshrc`:

```bash
alias claude-pasta='claude --plugin-dir ~/.claude/plugins/pasta-maker'
```

Then reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

### Step 3: Verify Installation

Start Claude Code:
```bash
claude-pasta  # if you added the alias
# or
claude --plugin-dir ~/.claude/plugins/pasta-maker
```

In Claude Code, run:
```
/pasta-maker:run
```

You should see: **"What tasks would you like to accomplish?"**

✅ Installation successful!

## Your First Workflow

Let's run a simple example. In Claude Code:

```
You: /pasta-maker:run

Claude: What tasks would you like to accomplish?

You: I want to run tests and then build my app

Claude: What commands should I run?

You: npm test
     npm run build

Claude: What directory should these run in?

You: /Users/yourname/projects/myapp

Claude: EXECUTION PLAN
        Group 1: Tests (npm test)
        Group 2 (after Group 1): Build (npm run build)

        Proceed? (yes/no)

You: yes

Claude: ✓ Tab 'Tests' created and running
        ✓ Waiting for tests to complete...
        ✓ Tab 'Build' created and running
```

## Common Use Cases

### Parallel Development Servers

```
Tasks:
- Start frontend dev server: npm run dev
- Start backend API: npm run api:dev
- Start database: docker-compose up postgres

All from: ~/projects/myapp
```

Result: All three servers start in separate tabs simultaneously.

### CI Pipeline Locally

```
Tasks:
- Lint code: npm run lint
- Run tests: npm test
- Type check: npm run type-check
Then: Build: npm run build

From: ~/projects/myapp
```

Result: Linting, tests, and type checking run in parallel. Build runs after all three complete.

### Data Processing

```
Tasks:
- Process dataset A: python process_a.py
- Process dataset B: python process_b.py
Then: Merge results: python merge.py

From: ~/projects/data-pipeline
```

Result: Both datasets process in parallel, merge runs when both complete.

## Tips

**Describing Dependencies:**
- Say "then" or "after" to indicate sequence
- Tasks without dependencies run in parallel
- Claude will show you the plan before executing

**Terminal Support:**
- macOS: iTerm2 or Terminal.app (with automation permissions)
- Linux: tmux, GNOME Terminal, Konsole
- Windows: WSL with tmux

**Resource Management:**
- Light tasks (tests, lints): up to 10 parallel
- Heavy tasks (builds): 2-4 parallel
- Close tabs when done to free resources

## Troubleshooting

### "Not authorized to send Apple events" (macOS)

Fix: System Settings → Privacy & Security → Automation → Enable your terminal

### "Permission denied" when running scripts

Fix:
```bash
chmod +x ~/.claude/plugins/pasta-maker/scripts/*.sh
```

### Plugin not found

Fix:
```bash
# Verify installation
ls -la ~/.claude/plugins/pasta-maker

# Start Claude Code with explicit path
claude --plugin-dir ~/.claude/plugins/pasta-maker
```

### Git authentication fails

Try HTTPS instead:
```bash
git clone https://github.com/YOUR-ORG/pasta-maker.git ~/.claude/plugins/pasta-maker
```

## Getting Help

- Full documentation: `~/.claude/plugins/pasta-maker/README.md`
- Distribution guide: `~/.claude/plugins/pasta-maker/guides/DISTRIBUTION_GUIDE.md`
- Report issues: GitHub repository (ask your team lead for URL)
- Ask in your team's support channel

## Updating

Keep your plugin up to date:

```bash
cd ~/.claude/plugins/pasta-maker
git pull
```

Check for updates weekly or when you see new features announced.

## Next Steps

1. Try the examples above with your own projects
2. Experiment with different task combinations
3. Share useful workflows with your team
4. Check the README for advanced features

Happy parallelizing! 🍝
