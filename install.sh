#!/bin/bash

# Tribble Plugin Installer
# Usage: ./install.sh [REPO_URL]
#
# Example:
#   ./install.sh https://github.com/fractional-ai/tribble.git

set -e

PLUGIN_NAME="tribble"
CLAUDE_PLUGINS_DIR="${HOME}/.claude/plugins"
INSTALL_DIR="${CLAUDE_PLUGINS_DIR}/${PLUGIN_NAME}"

# Repository URL - can be passed as argument or use default
REPO_URL="${1:-https://github.com/fractional-ai/tribble.git}"

echo "🐹 Installing Tribble Plugin..."
echo ""

# Create plugins directory if it doesn't exist
mkdir -p "${CLAUDE_PLUGINS_DIR}"

# Check if already installed
if [ -d "${INSTALL_DIR}" ]; then
    echo "⚠️  Plugin already installed at ${INSTALL_DIR}"
    echo ""
    read -p "Would you like to update it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 Updating plugin..."
        cd "${INSTALL_DIR}"
        git pull
        chmod +x "${INSTALL_DIR}"/scripts/*.sh
        echo ""
        echo "✅ Plugin updated successfully!"
        echo ""
        echo "Restart Claude Code to load the updates:"
        echo "  claude"
    else
        echo "Skipping update."
    fi
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
echo "     /tribble:run"
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
