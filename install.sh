#!/bin/bash

# Pasta Maker Plugin Installer
# Usage: ./install.sh [REPO_URL]
#
# Example:
#   ./install.sh git@github.com:fractional-ai/pasta-maker.git
#   ./install.sh https://github.com/fractional-ai/pasta-maker.git

set -e

PLUGIN_NAME="pasta-maker"
CLAUDE_PLUGINS_DIR="${HOME}/.claude/plugins"
INSTALL_DIR="${CLAUDE_PLUGINS_DIR}/${PLUGIN_NAME}"

# Repository URL - can be passed as argument or use default
REPO_URL="${1:-git@github.com:fractional-ai/pasta-maker.git}"

echo "🍝 Installing Pasta Maker Plugin..."
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
    echo "  1. Using HTTPS: ./install.sh https://github.com/fractional-ai/pasta-maker.git"
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
echo "To use the plugin:"
echo ""
echo "  1. Start Claude Code with the plugin:"
echo "     claude --plugin-dir ${INSTALL_DIR}"
echo ""
echo "  2. Or add to your shell config (~/.bashrc or ~/.zshrc):"
echo "     alias claude-pasta='claude --plugin-dir ${INSTALL_DIR}'"
echo ""
echo "  3. In Claude Code, run:"
echo "     /pasta-maker:run"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "To update in the future:"
echo "  cd ${INSTALL_DIR} && git pull"
echo ""
echo "For help, see: ${INSTALL_DIR}/README.md"
echo ""
