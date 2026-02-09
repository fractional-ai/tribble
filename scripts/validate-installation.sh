#!/usr/bin/env bash
# Validates Tribble installation and environment
# Usage: ./scripts/validate-installation.sh

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Tribble Installation Validator ==="
echo ""

ERRORS=0
WARNINGS=0

# Helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

info() {
    echo "  $1"
}

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Plugin directory: $PLUGIN_ROOT"
echo ""

# Check 1: Required files exist
echo "Checking required files..."
REQUIRED_FILES=(
    "scripts/spawn.sh"
    "scripts/lib/common.sh"
    "commands/spawn.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PLUGIN_ROOT/$file" ]; then
        pass "Found $file"
    else
        fail "Missing $file"
    fi
done
echo ""

# Check 2: Scripts are executable
echo "Checking script permissions..."
for script in "$PLUGIN_ROOT/scripts"/*.sh; do
    if [ -x "$script" ]; then
        pass "Executable: $(basename "$script")"
    else
        fail "Not executable: $(basename "$script")"
        info "Fix with: chmod +x $script"
    fi
done
echo ""

# Check 3: Terminal detection
echo "Checking terminal detection..."
# Detect terminal type using environment variables (same logic as spawn.sh)
DETECTED="unknown"
if [ -n "$TMUX" ]; then
    DETECTED="tmux"
elif [ "$TERM" = "alacritty" ]; then
    DETECTED="alacritty"
elif [ -n "$KITTY_WINDOW_ID" ]; then
    DETECTED="kitty"
elif [ "$TERM_PROGRAM" = "vscode" ]; then
    DETECTED="vscode"
elif [ "$WARP_IS_TERMINAL" = "1" ] || [ "$TERM_PROGRAM" = "WarpTerminal" ]; then
    DETECTED="warp"
elif [ "$TERM_PROGRAM" = "Hyper" ]; then
    DETECTED="hyper"
elif [ -n "$GNOME_TERMINAL_SERVICE" ] || [ -n "$GNOME_TERMINAL_SCREEN" ]; then
    DETECTED="gnome-terminal"
elif [ -n "$KONSOLE_VERSION" ] || [ -n "$KONSOLE_DBUS_SERVICE" ]; then
    DETECTED="konsole"
elif [ -n "$ITERM_SESSION_ID" ] || [ "$TERM_PROGRAM" = "iTerm.app" ]; then
    DETECTED="iterm2"
elif [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
    DETECTED="terminal"
elif [ -n "$WT_SESSION" ] || [ -n "$WT_PROFILE_ID" ]; then
    DETECTED="windows-terminal"
fi

if [ "$DETECTED" = "unknown" ]; then
    warn "Terminal type: unknown"
    info "Your terminal may not be supported for automatic spawning"
    info "Consider using tmux for compatibility"
else
    pass "Terminal detected: $DETECTED"
fi
echo ""

# Check 4: Settings file
echo "Checking settings configuration..."
if [ -f "$PLUGIN_ROOT/.claude/settings.local.json" ]; then
    pass "Found .claude/settings.local.json"

    # Check for hardcoded paths
    if grep -q "/Users/" "$PLUGIN_ROOT/.claude/settings.local.json" 2>/dev/null; then
        fail "settings.local.json contains hardcoded paths"
        info "Use \${CLAUDE_PLUGIN_ROOT} instead of absolute paths"
    else
        pass "No hardcoded paths in settings"
    fi

    # Validate JSON
    if command -v python3 &> /dev/null; then
        if python3 -m json.tool "$PLUGIN_ROOT/.claude/settings.local.json" > /dev/null 2>&1; then
            pass "Valid JSON syntax"
        else
            fail "Invalid JSON in settings.local.json"
        fi
    else
        warn "Python3 not found, skipping JSON validation"
    fi
else
    warn "No .claude/settings.local.json found"
    info "Plugin may work without it, but permissions should be configured"
fi
echo ""

# Check 5: Terminal-specific requirements
echo "Checking terminal-specific requirements..."
# Use the DETECTED variable from above

case "$DETECTED" in
    iterm2|terminal)
        info "macOS terminal detected"
        info "Ensure automation permissions are granted:"
        info "  System Settings → Privacy & Security → Automation"
        ;;
    tmux)
        if command -v tmux &> /dev/null; then
            pass "tmux is installed"
            TMUX_VERSION=$(tmux -V 2>/dev/null || echo "unknown")
            info "Version: $TMUX_VERSION"
        else
            fail "tmux not found in PATH"
            info "Install with: brew install tmux (macOS) or apt install tmux (Linux)"
        fi
        ;;
    windows-terminal)
        if command -v wt.exe &> /dev/null; then
            pass "Windows Terminal (wt.exe) is available"
        else
            fail "Windows Terminal not found"
            info "Install from Microsoft Store or https://aka.ms/terminal"
        fi
        ;;
    kitty)
        if grep -q "allow_remote_control yes" ~/.config/kitty/kitty.conf 2>/dev/null; then
            pass "Kitty remote control enabled"
        else
            warn "Kitty remote control may not be enabled"
            info "Add to ~/.config/kitty/kitty.conf: allow_remote_control yes"
        fi
        ;;
    unknown)
        warn "Unknown terminal type"
        info "Automatic spawning may not work"
        info "Consider using tmux for best compatibility"
        ;;
esac
echo ""

# Check 6: Common issues
echo "Checking for common issues..."

# Check if Claude Code is in PATH
if command -v claude &> /dev/null; then
    pass "Claude Code CLI found in PATH"
else
    warn "Claude Code CLI not found in PATH"
    info "You may need to specify full path when using the plugin"
fi

# Check git (for updates)
if command -v git &> /dev/null; then
    pass "Git is installed (for updates)"
else
    warn "Git not found"
    info "You won't be able to update the plugin via 'git pull'"
fi
echo ""

# Summary
echo "==================================="
echo "Validation Summary"
echo "==================================="
echo -e "${GREEN}Passed: $(($(ls -1 "$PLUGIN_ROOT/scripts"/*.sh 2>/dev/null | wc -l) + 7 - ERRORS - WARNINGS))${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Errors: $ERRORS${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Installation looks good!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Start Claude Code: claude --plugin-dir $PLUGIN_ROOT"
    echo "  2. Run the command: /tribble:spawn"
    echo "  3. Check Examples.md for usage examples"
    exit 0
else
    echo -e "${RED}✗ Please fix the errors above${NC}"
    echo ""
    echo "Common fixes:"
    echo "  - Make scripts executable: chmod +x $PLUGIN_ROOT/scripts/*.sh"
    echo "  - Check file permissions"
    echo "  - Verify terminal requirements"
    exit 1
fi
