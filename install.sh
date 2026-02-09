#!/bin/bash

# Tribble Plugin Installer
# Usage: ./install.sh [REPO_URL]
#
# Example:
#   ./install.sh https://github.com/fractional-ai/tribble.git

set -e

PLUGIN_NAME="tribble"
MARKETPLACE="local-plugins"
PLUGIN_KEY="${PLUGIN_NAME}@${MARKETPLACE}"
CLAUDE_DIR="${HOME}/.claude"
CLAUDE_PLUGINS_DIR="${CLAUDE_DIR}/plugins"
INSTALL_DIR="${CLAUDE_PLUGINS_DIR}/${PLUGIN_NAME}"
INSTALLED_PLUGINS_FILE="${CLAUDE_PLUGINS_DIR}/installed_plugins.json"
KNOWN_MARKETPLACES_FILE="${CLAUDE_PLUGINS_DIR}/known_marketplaces.json"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"

# Repository URL - can be passed as argument or use default
REPO_URL="${1:-https://github.com/fractional-ai/tribble.git}"

echo "🐹 Installing Tribble Plugin..."
echo ""

# Check dependencies
for cmd in git node; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ Required command '$cmd' not found. Please install it first."
        exit 1
    fi
done

# Create plugins directory if it doesn't exist
mkdir -p "${CLAUDE_PLUGINS_DIR}"

# Check if already installed
if [ -d "${INSTALL_DIR}" ]; then
    echo "📦 Plugin already installed — updating..."
    cd "${INSTALL_DIR}"
    git pull
    chmod +x "${INSTALL_DIR}"/scripts/*.sh
    echo ""
    echo "✅ Plugin updated successfully!"
    echo ""
    echo "Restart Claude Code to load the updates:"
    echo "  claude"
    exit 0
fi

# Clone repository
echo "📦 Cloning repository from ${REPO_URL}..."
if ! git clone "${REPO_URL}" "${INSTALL_DIR}"; then
    echo ""
    echo "❌ Failed to clone repository."
    echo ""
    echo "If you see an authentication error, try:"
    echo "  1. Check your internet connection"
    echo "  2. Setting up SSH keys: https://docs.github.com/en/authentication"
    exit 1
fi

# Make scripts executable
echo "🔧 Setting permissions..."
chmod +x "${INSTALL_DIR}"/scripts/*.sh

# Read plugin version from plugin.json
PLUGIN_VERSION=$(node -e "
  const fs = require('fs');
  try {
    const p = JSON.parse(fs.readFileSync('${INSTALL_DIR}/.claude-plugin/plugin.json', 'utf8'));
    process.stdout.write(p.version || '1.0.0');
  } catch { process.stdout.write('1.0.0'); }
")

# Register plugin in Claude Code config files
echo "🔗 Registering plugin with Claude Code..."

NOW=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

# 1. Register in installed_plugins.json
node -e "
  const fs = require('fs');
  const file = '${INSTALLED_PLUGINS_FILE}';
  let data;
  try { data = JSON.parse(fs.readFileSync(file, 'utf8')); } catch { data = {}; }
  if (!data.version) data.version = 2;
  if (!data.plugins) data.plugins = {};
  data.plugins['${PLUGIN_KEY}'] = [{
    scope: 'user',
    installPath: '${INSTALL_DIR}',
    version: '${PLUGIN_VERSION}',
    installedAt: '${NOW}',
    lastUpdated: '${NOW}'
  }];
  fs.writeFileSync(file, JSON.stringify(data, null, 2) + '\n');
"

# 2. Ensure local-plugins marketplace exists in known_marketplaces.json
node -e "
  const fs = require('fs');
  const file = '${KNOWN_MARKETPLACES_FILE}';
  let data;
  try { data = JSON.parse(fs.readFileSync(file, 'utf8')); } catch { data = {}; }
  if (!data['${MARKETPLACE}']) {
    data['${MARKETPLACE}'] = {
      source: { source: 'directory', path: '${CLAUDE_PLUGINS_DIR}' },
      installLocation: '${CLAUDE_PLUGINS_DIR}',
      lastUpdated: '${NOW}'
    };
    fs.writeFileSync(file, JSON.stringify(data, null, 2) + '\n');
  }
"

# 3. Enable plugin and add permissions in settings.json
node -e "
  const fs = require('fs');
  const file = '${SETTINGS_FILE}';
  let data;
  try { data = JSON.parse(fs.readFileSync(file, 'utf8')); } catch { data = {}; }

  // Enable plugin
  if (!data.enabledPlugins) data.enabledPlugins = {};
  data.enabledPlugins['${PLUGIN_KEY}'] = true;

  // Add Skill permission
  if (!data.permissions) data.permissions = {};
  if (!data.permissions.allow) data.permissions.allow = [];
  const skillPerm = 'Skill(${PLUGIN_NAME}:*)';
  if (!data.permissions.allow.includes(skillPerm)) {
    data.permissions.allow.push(skillPerm);
  }

  // Add script execution permission
  const bashPerm = 'Bash(${INSTALL_DIR}/scripts/*)';
  if (!data.permissions.allow.includes(bashPerm)) {
    data.permissions.allow.push(bashPerm);
  }

  fs.writeFileSync(file, JSON.stringify(data, null, 2) + '\n');
"

echo ""
echo "✅ Installation complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next steps:"
echo ""
echo "  1. Restart Claude Code (plugin auto-loads from ~/.claude/plugins/):"
echo "     claude"
echo ""
echo "  2. In Claude Code, verify installation:"
echo "     /tribble:spawn"
echo "     /tribble:help"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Note: The plugin is installed to ${INSTALL_DIR}"
echo "    It will automatically load in all Claude Code sessions."
echo ""
echo "To update in the future:"
echo "  cd ${INSTALL_DIR} && git pull && claude"
echo ""
echo "For help, see: ${INSTALL_DIR}/README.md"
echo ""
