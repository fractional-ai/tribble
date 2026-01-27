#!/usr/bin/env bash
# Color palette and color utility functions for Tribble
# Colors are stored in iTerm2 format (RGB 0-65535) as the canonical format.

# Predefined color palette (RGB values 0-65535 for iTerm2)
# Colors are chosen to be visually distinct and pleasant
declare -a COLOR_PALETTE=(
    "50000,20000,20000"   # Red
    "20000,50000,20000"   # Green
    "20000,20000,50000"   # Blue
    "50000,40000,0"       # Orange
    "40000,0,50000"       # Purple
    "0,45000,50000"       # Cyan
    "50000,20000,40000"   # Pink
    "30000,50000,0"       # Lime
    "0,30000,50000"       # Teal
    "50000,30000,0"       # Amber
)

# State file for tracking current color index
COLOR_STATE_FILE="${TMPDIR:-/tmp}/tribble_color_index"

# Get next color in sequential order (loops through palette)
# Outputs: RGB color string in format "r,g,b" (0-65535 range)
get_next_color() {
    local current_index=0

    # Read current index from state file if it exists
    if [ -f "$COLOR_STATE_FILE" ]; then
        current_index=$(cat "$COLOR_STATE_FILE" 2>/dev/null || echo "0")
        # Validate it's a number
        if ! [[ "$current_index" =~ ^[0-9]+$ ]]; then
            current_index=0
        fi
    fi

    # Get the color at current index
    local color="${COLOR_PALETTE[$current_index]}"

    # Increment index for next call (loop back to 0 at end)
    local next_index=$(( (current_index + 1) % ${#COLOR_PALETTE[@]} ))

    # Save next index to state file
    echo "$next_index" > "$COLOR_STATE_FILE"

    echo "$color"
}

# Convert iTerm2 color format (0-65535) to 0-255 range
# Arguments:
#   $1 - color in "r,g,b" format (0-65535)
# Outputs: "r,g,b" in 0-255 format
color_to_255() {
    local color="$1"
    IFS=',' read -r r g b <<< "$color"
    local r_255=$((r * 255 / 65535))
    local g_255=$((g * 255 / 65535))
    local b_255=$((b * 255 / 65535))
    echo "$r_255,$g_255,$b_255"
}

# Convert iTerm2 color format to hex (#RRGGBB)
# Arguments:
#   $1 - color in "r,g,b" format (0-65535)
# Outputs: Hex color string like "#ff3300"
color_to_hex() {
    local color="$1"
    IFS=',' read -r r g b <<< "$color"
    local r_255=$((r * 255 / 65535))
    local g_255=$((g * 255 / 65535))
    local b_255=$((b * 255 / 65535))
    printf "#%02x%02x%02x" "$r_255" "$g_255" "$b_255"
}

# Parse color into separate R, G, B variables (0-255 range)
# Arguments:
#   $1 - color in "r,g,b" format (0-65535)
# Sets global variables: COLOR_R, COLOR_G, COLOR_B (0-255)
parse_color_255() {
    local color="$1"
    IFS=',' read -r r g b <<< "$color"
    COLOR_R=$((r * 255 / 65535))
    COLOR_G=$((g * 255 / 65535))
    COLOR_B=$((b * 255 / 65535))
}

# Reset color state (for testing)
reset_color_state() {
    rm -f "$COLOR_STATE_FILE"
}
