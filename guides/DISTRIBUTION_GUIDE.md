# Pasta Maker Distribution Guide

A comprehensive guide for distributing the pasta-maker plugin to your team.

## Table of Contents

1. [Distribution Methods Overview](#distribution-methods-overview)
2. [Recommended Approach](#recommended-approach)
3. [Implementation Guide](#implementation-guide)
4. [Alternative Distribution Methods](#alternative-distribution-methods)
5. [Update Mechanisms](#update-mechanisms)
6. [Team Onboarding](#team-onboarding)
7. [Troubleshooting](#troubleshooting)

---

## Distribution Methods Overview

### Method Comparison Matrix

| Method | Setup Complexity | Update Ease | Version Control | Team Size | Recommended |
|--------|-----------------|-------------|-----------------|-----------|-------------|
| **Private Git Repository** | Low | Excellent | Native | Any | ✓ **Best** |
| **Install Script + Git** | Medium | Excellent | Native | Any | ✓ **Good** |
| **Direct File Sharing** | Very Low | Poor | Manual | Small (<5) | Limited use |
| **Private npm Registry** | High | Excellent | Native | Large (>20) | Enterprise |
| **Monorepo Subdirectory** | Very Low | Automatic | Native | Any | ✓ **Best for monorepos** |

### Evaluation Criteria

**Installation Simplicity**
- Git-based: One-line clone command
- npm-based: Requires private registry setup
- File sharing: Manual copy/paste

**Update Mechanisms**
- Git: `git pull` for instant updates
- npm: `npm update` (requires registry)
- File sharing: Manual redistribution

**Version Control**
- Git: Full history, branching, rollbacks
- npm: Versioned packages
- File sharing: No version control

**Team Onboarding**
- Git: Minimal (clone + configure path)
- npm: Requires npm auth setup
- File sharing: Manual for each member

---

## Recommended Approach

### Primary: Private Git Repository

**Best for:** Most teams (5-100 people), active development

**Why this approach:**
- ✓ Simple installation (one command)
- ✓ Easy updates (`git pull`)
- ✓ Full version control and history
- ✓ No infrastructure required
- ✓ Works with existing Git workflows
- ✓ Supports branching for testing
- ✓ Free (GitHub/GitLab/Bitbucket)

**Setup Time:** 15 minutes
**Maintenance:** Minimal
**Cost:** Free (most platforms)

---

## Implementation Guide

### Step 1: Prepare the Repository

#### Option A: Standalone Repository (Recommended for sharing)

```bash
# Navigate to the plugin directory
cd /Users/darianbailey/Desktop/experiments/pasta-maker

# Initialize git if not already done
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# macOS
.DS_Store

# IDE
.idea/
.vscode/
*.swp
*.swo

# Local settings (user-specific)
.claude/settings.local.json

# Logs
*.log
EOF

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: pasta-maker plugin v1.0.0"
```

#### Option B: Monorepo Subdirectory (If team uses monorepo)

```bash
# In your monorepo root
mkdir -p tools/claude-plugins
cp -r /Users/darianbailey/Desktop/experiments/pasta-maker tools/claude-plugins/

# Commit to monorepo
git add tools/claude-plugins/pasta-maker
git commit -m "Add pasta-maker Claude Code plugin"
```

### Step 2: Create Remote Repository

#### GitHub (Recommended)

1. **Create repository:**
   - Go to GitHub → New Repository
   - Name: `pasta-maker` or `claude-plugins`
   - Visibility: **Private** (for internal team use)
   - Don't initialize with README (already have one)

2. **Push to GitHub:**
   ```bash
   # Add remote
   git remote add origin git@github.com:YOUR-ORG/pasta-maker.git

   # Push to main branch
   git branch -M main
   git push -u origin main
   ```

3. **Set up team access:**
   - Settings → Collaborators and teams
   - Add your organization or team members
   - Grant "Write" access for contributors, "Read" for users

#### GitLab / Bitbucket

Similar process - create private repository and push code.

### Step 3: Create Installation Script

Create a simple installation script for team members:

```bash
# Create install.sh in the repository
cat > install.sh << 'EOF'
#!/bin/bash

# Pasta Maker Plugin Installer
# Usage: ./install.sh

set -e

PLUGIN_NAME="pasta-maker"
CLAUDE_PLUGINS_DIR="${HOME}/.claude/plugins"
INSTALL_DIR="${CLAUDE_PLUGINS_DIR}/${PLUGIN_NAME}"

echo "🍝 Installing Pasta Maker Plugin..."

# Create plugins directory if it doesn't exist
mkdir -p "${CLAUDE_PLUGINS_DIR}"

# Check if already installed
if [ -d "${INSTALL_DIR}" ]; then
    echo "⚠️  Plugin already installed at ${INSTALL_DIR}"
    echo "To update, run: cd ${INSTALL_DIR} && git pull"
    exit 0
fi

# Clone repository
echo "📦 Cloning repository..."
git clone git@github.com:YOUR-ORG/pasta-maker.git "${INSTALL_DIR}"

# Make scripts executable
echo "🔧 Setting permissions..."
chmod +x "${INSTALL_DIR}"/scripts/*.sh

# Configure Claude Code
echo "⚙️  Configuring Claude Code..."
CLAUDE_CONFIG="${HOME}/.claude/config.json"

# Create config if it doesn't exist
if [ ! -f "${CLAUDE_CONFIG}" ]; then
    echo '{"plugins": []}' > "${CLAUDE_CONFIG}"
fi

# Add plugin to config (if not already there)
if ! grep -q "pasta-maker" "${CLAUDE_CONFIG}" 2>/dev/null; then
    # Add plugin path to config
    echo "Adding plugin to Claude Code configuration..."
    # Note: This is a simple approach. Adjust based on actual config format.
fi

echo "✅ Installation complete!"
echo ""
echo "To use the plugin:"
echo "  1. Start Claude Code: claude"
echo "  2. Run: /pasta-maker:run"
echo ""
echo "To update in the future:"
echo "  cd ${INSTALL_DIR} && git pull"
EOF

chmod +x install.sh
git add install.sh
git commit -m "Add installation script"
git push
```

**Note:** Adjust the GitHub URL in the script to match your repository.

### Step 4: Create Documentation

#### Update README.md

Add a team installation section:

```markdown
## Installation for Team Members

### Quick Install (Recommended)

```bash
# One-line install
curl -fsSL https://raw.githubusercontent.com/YOUR-ORG/pasta-maker/main/install.sh | bash
```

### Manual Install

```bash
# Clone to Claude plugins directory
git clone git@github.com:YOUR-ORG/pasta-maker.git ~/.claude/plugins/pasta-maker

# Make scripts executable
chmod +x ~/.claude/plugins/pasta-maker/scripts/*.sh

# Restart Claude Code
```

### Verify Installation

```bash
# Start Claude Code
claude

# Try the plugin
/pasta-maker:run
```

## Updating

```bash
# Navigate to plugin directory
cd ~/.claude/plugins/pasta-maker

# Pull latest changes
git pull

# Restart Claude Code
```
```

### Step 5: Test Installation Flow

**Before distributing, test the complete flow:**

```bash
# On a test machine or different directory
# 1. Clone repository
git clone git@github.com:YOUR-ORG/pasta-maker.git ~/.claude/plugins/pasta-maker

# 2. Set permissions
chmod +x ~/.claude/plugins/pasta-maker/scripts/*.sh

# 3. Start Claude Code with plugin
claude --plugin-dir ~/.claude/plugins/pasta-maker

# 4. Test the command
# In Claude Code: /pasta-maker:run
```

---

## Alternative Distribution Methods

### Method 2: Install Script with Auto-Update

**Best for:** Teams wanting zero-maintenance updates

Create a wrapper script that handles installation and updates:

```bash
#!/bin/bash
# pasta-maker-launcher.sh

PLUGIN_DIR="${HOME}/.claude/plugins/pasta-maker"
REPO_URL="git@github.com:YOUR-ORG/pasta-maker.git"

# Install if not present
if [ ! -d "${PLUGIN_DIR}" ]; then
    echo "Installing pasta-maker..."
    git clone "${REPO_URL}" "${PLUGIN_DIR}"
    chmod +x "${PLUGIN_DIR}"/scripts/*.sh
fi

# Auto-update (optional: disable for stability)
echo "Checking for updates..."
cd "${PLUGIN_DIR}"
git pull --quiet

# Launch Claude Code with plugin
claude --plugin-dir "${PLUGIN_DIR}"
```

**Usage:**
```bash
# Team members add to ~/.bashrc or ~/.zshrc
alias claude-pasta="bash ~/scripts/pasta-maker-launcher.sh"

# Then simply run:
claude-pasta
```

### Method 3: Monorepo Integration

**Best for:** Teams already using a monorepo

```bash
# Project structure
your-monorepo/
├── apps/
├── packages/
└── tools/
    └── claude-plugins/
        └── pasta-maker/
            ├── .claude-plugin/
            ├── commands/
            ├── scripts/
            └── lib/

# Team members install via:
claude --plugin-dir $(pwd)/tools/claude-plugins/pasta-maker
```

**Advantages:**
- No separate repository needed
- Updates via normal repo sync
- Version controlled with project
- Same access controls as main repo

**Add to project README:**
```markdown
## Development Tools

### Pasta Maker (Task Parallelization)

Install the pasta-maker plugin:

```bash
# From project root
claude --plugin-dir tools/claude-plugins/pasta-maker
```
```

### Method 4: Private npm Registry (Enterprise)

**Best for:** Large organizations (50+ developers) with existing npm infrastructure

**Setup Requirements:**
- Private npm registry (Verdaccio, npm Enterprise, Artifactory)
- npm authentication configured

**Package Structure:**

```json
{
  "name": "@yourorg/claude-plugin-pasta-maker",
  "version": "1.0.0",
  "description": "Task parallelization plugin for Claude Code",
  "bin": {
    "pasta-maker-install": "./bin/install.js"
  },
  "files": [
    ".claude-plugin/",
    "commands/",
    "scripts/",
    "lib/"
  ]
}
```

**Installation:**
```bash
# Team members install via npm
npm install -g @yourorg/claude-plugin-pasta-maker

# Auto-installs to ~/.claude/plugins/
```

**When to use:**
- Organization already uses private npm
- Need strict version management
- Automated deployment pipelines
- Compliance requires package scanning

---

## Update Mechanisms

### Automatic Update Strategies

#### Strategy 1: Git-Based Auto-Update (Recommended)

**Implementation:**

Add to the plugin's command file (commands/run.md):

```markdown
Before starting, check for updates:

Use the Bash tool to run:
```bash
cd "${CLAUDE_PLUGIN_ROOT}" && git fetch origin && git status | grep -q "behind" && echo "UPDATE_AVAILABLE" || echo "UP_TO_DATE"
```

If result contains "UPDATE_AVAILABLE", inform the user:
```
🔔 A new version of pasta-maker is available!
To update: cd ~/.claude/plugins/pasta-maker && git pull
```
```

**Benefits:**
- Non-intrusive notifications
- User controls when to update
- No breaking changes mid-session

#### Strategy 2: Automated Pull on Startup

**Implementation:**

Create a wrapper script that auto-updates:

```bash
#!/bin/bash
# ~/.local/bin/claude-with-pasta-maker

PLUGIN_DIR="${HOME}/.claude/plugins/pasta-maker"

# Silent auto-update
if [ -d "${PLUGIN_DIR}/.git" ]; then
    (cd "${PLUGIN_DIR}" && git pull --quiet) &
fi

# Launch Claude Code
claude --plugin-dir "${PLUGIN_DIR}"
```

**Caution:** May introduce breaking changes unexpectedly.

#### Strategy 3: Semantic Versioning with Git Tags

**Implementation:**

```bash
# Release workflow
# 1. Tag releases
git tag v1.0.0
git push origin v1.0.0

# 2. Team members can pin versions
cd ~/.claude/plugins/pasta-maker
git checkout v1.0.0

# 3. Or stay on latest
git checkout main
git pull
```

**Version Management:**
```bash
# Check current version
cd ~/.claude/plugins/pasta-maker
git describe --tags

# Update to latest stable
git fetch --tags
git checkout $(git describe --tags $(git rev-list --tags --max-count=1))

# Update to latest development
git checkout main && git pull
```

### Update Communication

**Create a CHANGELOG.md:**

```markdown
# Changelog

All notable changes to pasta-maker will be documented in this file.

## [1.1.0] - 2026-01-15

### Added
- Support for Alacritty terminal
- Ability to pause/resume execution plans

### Fixed
- iTerm2 tab naming on macOS 14+

### Changed
- Improved dependency analysis accuracy

## [1.0.0] - 2026-01-08

### Added
- Initial release
- iTerm2, Terminal.app, and tmux support
- Dependency analysis engine
```

**Announce updates via:**
- Slack/Teams channel
- Email to team
- Weekly standup mentions

---

## Team Onboarding

### Quick Start Guide for New Team Members

Create `QUICK_START.md`:

```markdown
# Pasta Maker - Quick Start

## Installation (2 minutes)

### Step 1: Install the Plugin

```bash
git clone git@github.com:YOUR-ORG/pasta-maker.git ~/.claude/plugins/pasta-maker
chmod +x ~/.claude/plugins/pasta-maker/scripts/*.sh
```

### Step 2: Verify Installation

```bash
# Start Claude Code
claude --plugin-dir ~/.claude/plugins/pasta-maker

# In Claude Code, run:
/pasta-maker:run
```

You should see: "What tasks would you like to accomplish?"

✅ Installation successful!

## Your First Parallelization

Try this example:

```
/pasta-maker:run

Tasks:
- Run frontend tests: npm test
- Run backend tests: npm run test:api
- Both from: /Users/yourname/projects/myapp

Result: Both tests run in parallel, saving time!
```

## Getting Help

- Read the full README: `~/.claude/plugins/pasta-maker/README.md`
- Ask in #claude-tools Slack channel
- Report bugs: [GitHub Issues](https://github.com/YOUR-ORG/pasta-maker/issues)

## Updating

```bash
cd ~/.claude/plugins/pasta-maker
git pull
```
```

### Onboarding Checklist

**For team leads distributing the plugin:**

- [ ] Repository created and team has access
- [ ] README.md updated with team-specific instructions
- [ ] QUICK_START.md created
- [ ] Installation tested on clean machine
- [ ] Announcement sent to team
- [ ] Support channel established (Slack/Teams)
- [ ] Example workflows documented
- [ ] Permissions verified (macOS automation for iTerm2/Terminal.app)

**For team members installing:**

- [ ] Git access to repository confirmed
- [ ] Plugin cloned to `~/.claude/plugins/pasta-maker`
- [ ] Scripts are executable (`chmod +x`)
- [ ] Claude Code starts with plugin
- [ ] `/pasta-maker:run` command works
- [ ] Test workflow completed
- [ ] macOS automation permissions granted (if needed)

### Training Materials

**Create example workflows for your team's common tasks:**

```markdown
## Common Workflows for Our Team

### Frontend Development
```
/pasta-maker:run

Tasks:
1. Start dev server: npm run dev
2. Start test watcher: npm run test:watch
3. Start Storybook: npm run storybook

All from: ~/projects/frontend-app
```

### CI Pipeline Locally
```
/pasta-maker:run

Tasks:
1. Lint code: npm run lint
2. Run tests: npm test
3. Type check: npm run type-check
Then: Build: npm run build

From: ~/projects/main-app
```

### Data Processing
```
/pasta-maker:run

Tasks:
1. Process dataset A: python process_a.py
2. Process dataset B: python process_b.py
Then: Merge: python merge.py
Then: Generate report: python report.py

From: ~/projects/data-pipeline
```
```

---

## Troubleshooting

### Common Installation Issues

#### Issue: "Permission denied" when running scripts

**Cause:** Scripts not executable

**Solution:**
```bash
chmod +x ~/.claude/plugins/pasta-maker/scripts/*.sh
```

#### Issue: "Plugin not found" in Claude Code

**Cause:** Plugin not in expected directory or not specified

**Solutions:**
1. Verify plugin location:
   ```bash
   ls -la ~/.claude/plugins/pasta-maker/.claude-plugin/plugin.json
   ```

2. Start Claude Code with explicit plugin path:
   ```bash
   claude --plugin-dir ~/.claude/plugins/pasta-maker
   ```

3. Check Claude Code plugin configuration

#### Issue: "Not authorized to send Apple events"

**Cause:** macOS automation permissions not granted

**Solution:**
1. Open **System Settings** → **Privacy & Security** → **Automation**
2. Find **Terminal.app** or **iTerm2**
3. Enable permission to control other applications
4. Restart terminal
5. Try `/pasta-maker:run` again

#### Issue: Git authentication fails

**Cause:** SSH keys not configured

**Solutions:**

1. **Use HTTPS instead:**
   ```bash
   git clone https://github.com/YOUR-ORG/pasta-maker.git ~/.claude/plugins/pasta-maker
   ```

2. **Or configure SSH:**
   ```bash
   # Generate SSH key if needed
   ssh-keygen -t ed25519 -C "your.email@company.com"

   # Add to GitHub
   cat ~/.ssh/id_ed25519.pub
   # Copy and add to GitHub → Settings → SSH Keys
   ```

### Update Issues

#### Issue: `git pull` fails with merge conflicts

**Cause:** Local modifications conflict with updates

**Solution:**
```bash
cd ~/.claude/plugins/pasta-maker

# Option 1: Stash local changes
git stash
git pull
git stash pop

# Option 2: Reset to remote (loses local changes)
git fetch origin
git reset --hard origin/main
```

#### Issue: Scripts stop working after update

**Cause:** Permissions reset during update

**Solution:**
```bash
cd ~/.claude/plugins/pasta-maker
chmod +x scripts/*.sh
```

---

## Best Practices

### For Plugin Maintainers

1. **Use semantic versioning:**
   - Major: Breaking changes (v2.0.0)
   - Minor: New features (v1.1.0)
   - Patch: Bug fixes (v1.0.1)

2. **Tag releases:**
   ```bash
   git tag -a v1.0.1 -m "Fix iTerm2 compatibility"
   git push origin v1.0.1
   ```

3. **Document breaking changes:**
   - Update CHANGELOG.md
   - Announce to team before pushing
   - Provide migration guide

4. **Test before releasing:**
   - Test on multiple terminals
   - Test clean install
   - Test update from previous version

5. **Maintain backwards compatibility:**
   - Deprecate features before removing
   - Provide migration scripts if needed

### For Team Members

1. **Update regularly:**
   ```bash
   # Weekly or before major work
   cd ~/.claude/plugins/pasta-maker && git pull
   ```

2. **Report issues:**
   - Include error messages
   - Specify terminal type
   - Share task configuration

3. **Share improvements:**
   - Submit PRs for bug fixes
   - Share useful workflow examples
   - Contribute documentation

---

## Security Considerations

### For Internal Distribution

1. **Private repository:**
   - Never make public without review
   - Contains team-specific workflows
   - May contain internal URLs/paths

2. **Access control:**
   - Limit write access to maintainers
   - Grant read access to team members
   - Review permissions quarterly

3. **Code review:**
   - Review PRs before merging
   - Scan for sensitive data
   - Test changes in isolated environment

4. **Audit trail:**
   - Git history tracks all changes
   - Tag releases for stability
   - Document who has access

### Script Safety

The plugin's scripts execute shell commands. Ensure:

1. **Input validation:**
   - Scripts validate directory paths
   - Commands are escaped properly
   - No arbitrary code execution

2. **Permissions:**
   - Scripts have minimal permissions
   - Only execute in specified directories
   - User approves before spawning

---

## Appendix

### A. Complete Installation Commands

**For team members (copy-paste ready):**

```bash
# 1. Clone repository
git clone git@github.com:YOUR-ORG/pasta-maker.git ~/.claude/plugins/pasta-maker

# 2. Set permissions
chmod +x ~/.claude/plugins/pasta-maker/scripts/*.sh

# 3. Verify installation
ls -la ~/.claude/plugins/pasta-maker

# 4. Start Claude Code
claude --plugin-dir ~/.claude/plugins/pasta-maker

# 5. Test plugin (in Claude Code)
# Run: /pasta-maker:run
```

### B. Uninstallation

```bash
# Remove plugin directory
rm -rf ~/.claude/plugins/pasta-maker

# Remove from Claude Code config (if added)
# Edit ~/.claude/config.json and remove pasta-maker reference
```

### C. Support Resources

**Internal Resources:**
- Plugin repository: `git@github.com:YOUR-ORG/pasta-maker.git`
- Documentation: Repository README.md
- Support channel: #claude-tools Slack
- Issue tracker: GitHub Issues

**External Resources:**
- Claude Code documentation: https://docs.anthropic.com/claude-code
- Terminal automation: Check terminal-specific docs
- Git basics: https://git-scm.com/book

---

## Summary: Recommended Distribution Flow

### For Most Teams (5-50 people)

1. **Setup (15 minutes):**
   - Create private GitHub/GitLab repository
   - Push pasta-maker code
   - Update README with team instructions
   - Test installation flow

2. **Distribute (5 minutes per person):**
   - Share repository URL
   - Provide one-line install command
   - Point to QUICK_START.md
   - Available in support channel

3. **Maintain (ongoing):**
   - Push updates to main branch
   - Tag stable releases
   - Announce major changes
   - Review issues/PRs weekly

4. **Team members use:**
   - Clone once: `git clone ...`
   - Update weekly: `git pull`
   - Use daily: `/pasta-maker:run`

**Total setup time:** 20 minutes
**Per-user install time:** 2 minutes
**Update time:** 30 seconds (git pull)

**Result:** Efficient distribution with minimal overhead and maximum flexibility.

---

*Last updated: 2026-01-08*
*Plugin version: 1.0.0*
