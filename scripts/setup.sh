#!/usr/bin/env bash
# scripts/setup.sh - Validates plugin configuration

echo "Checking permissions configuration..."

if [ ! -f ".claude/settings.local.json" ]; then
  echo "✗ Missing .claude/settings.local.json"
  echo "  Copy from .claude/settings.local.json.example"
  exit 1
fi

# Check if paths contain ${CLAUDE_PLUGIN_ROOT}
if grep -q "/Users/" .claude/settings.local.json; then
  echo "✗ settings.local.json contains hardcoded paths"
  echo "  Use \${CLAUDE_PLUGIN_ROOT} variable instead"
  exit 1
fi

echo "✓ Configuration looks good!"
