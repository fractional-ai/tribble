#!/bin/bash

# Tribble Plugin Uninstaller
# Usage: ./uninstall.sh
#
# Or remotely:
#   curl -fsSL https://raw.githubusercontent.com/fractional-ai/tribble/main/uninstall.sh | bash

set -e

PLUGIN_NAME="tribble"
MARKETPLACE="local-plugins"
PLUGIN_KEY="${PLUGIN_NAME}@${MARKETPLACE}"
CLAUDE_DIR="${HOME}/.claude"
CLAUDE_PLUGINS_DIR="${CLAUDE_DIR}/plugins"
INSTALL_DIR="${CLAUDE_PLUGINS_DIR}/${PLUGIN_NAME}"
INSTALLED_PLUGINS_FILE="${CLAUDE_PLUGINS_DIR}/installed_plugins.json"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"

echo "🐹 Uninstalling Tribble Plugin..."
echo ""

if [ ! -d "${INSTALL_DIR}" ]; then
    echo "Plugin directory not found at ${INSTALL_DIR}"
    echo "Nothing to uninstall."
    exit 0
fi

# Check for node
if ! command -v node &> /dev/null; then
    echo "❌ Required command 'node' not found. Please install it first."
    exit 1
fi

# 1. Remove from installed_plugins.json
if [ -f "${INSTALLED_PLUGINS_FILE}" ]; then
    echo "Removing from installed_plugins.json..."
    node -e "
      const fs = require('fs');
      const file = '${INSTALLED_PLUGINS_FILE}';
      const data = JSON.parse(fs.readFileSync(file, 'utf8'));
      delete data.plugins['${PLUGIN_KEY}'];
      fs.writeFileSync(file, JSON.stringify(data, null, 2) + '\n');
    "
fi

# 2. Remove from settings.json
if [ -f "${SETTINGS_FILE}" ]; then
    echo "Removing from settings.json..."
    node -e "
      const fs = require('fs');
      const file = '${SETTINGS_FILE}';
      const data = JSON.parse(fs.readFileSync(file, 'utf8'));

      // Remove from enabledPlugins
      if (data.enabledPlugins) {
        delete data.enabledPlugins['${PLUGIN_KEY}'];
      }

      // Remove permissions
      if (data.permissions && data.permissions.allow) {
        data.permissions.allow = data.permissions.allow.filter(
          p => !p.includes('${PLUGIN_NAME}:') && !p.includes('${INSTALL_DIR}')
        );
      }

      fs.writeFileSync(file, JSON.stringify(data, null, 2) + '\n');
    "
fi

# 3. Remove plugin directory
echo "Removing plugin directory..."
rm -rf "${INSTALL_DIR}"

echo ""
echo "✅ Tribble has been uninstalled."
echo ""
echo "Restart Claude Code to complete removal:"
echo "  claude"
echo ""
