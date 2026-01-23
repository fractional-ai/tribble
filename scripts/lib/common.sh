#!/usr/bin/env bash
# Common shared functions for Tribble spawn scripts
# This library provides validation, error formatting, and user feedback
# functions used across all spawn scripts.

# Validates that required arguments are provided
# Arguments:
#   $1 - tab/window name
#   $2 - command
# Returns:
#   0 - Valid arguments
#   1 - Missing arguments
validate_arguments() {
    local name="$1"
    local command="$2"

    if [ -z "$name" ] || [ -z "$command" ]; then
        echo "[ERROR] Missing required arguments" >&2
        echo "" >&2
        echo "Usage: $(basename "$0") <name> <command> <directory> [prompt]" >&2
        echo "" >&2
        echo "Arguments:" >&2
        echo "  name       - Descriptive name for the tab/window" >&2
        echo "  command    - Command to execute" >&2
        echo "  directory  - Working directory (absolute path)" >&2
        echo "  prompt     - Optional: Initial prompt/input to pipe into the command" >&2
        return 1
    fi

    return 0
}

# Validates that a directory exists
# Arguments:
#   $1 - directory path
# Returns:
#   0 - Directory exists
#   2 - Directory does not exist
validate_directory() {
    local directory="$1"

    if [ ! -d "$directory" ]; then
        echo "[ERROR] Directory does not exist: '$directory'" >&2
        echo "" >&2
        echo "The specified directory was not found." >&2
        echo "" >&2
        echo "Common causes:" >&2
        echo "  - Typo in directory path" >&2
        echo "  - Directory not yet created" >&2
        echo "  - Incorrect relative vs absolute path" >&2
        echo "" >&2
        echo "To fix:" >&2
        echo "  - Verify path: ls -la \"$(dirname "$directory")\"" >&2
        echo "  - Create directory: mkdir -p \"$directory\"" >&2
        echo "  - Use absolute paths (e.g., /Users/name/project)" >&2
        return 2
    fi

    return 0
}

# Prints a success message in consistent format
# Arguments:
#   $1 - tab/window name
#   $2 - terminal type (e.g., "iTerm2", "Terminal.app", "tmux session")
success_message() {
    local name="$1"
    local terminal="$2"

    echo "✓ Created tab '$name' in $terminal"
}

# Prints manual instructions when automated spawn fails
# Arguments:
#   $1 - tab/window name
#   $2 - command
#   $3 - directory
#   $4 - prompt (optional)
print_manual_instructions() {
    local name="$1"
    local command="$2"
    local directory="$3"
    local prompt="$4"

    echo "" >&2
    echo "Manual workaround - open a new tab and run:" >&2
    echo "  cd \"$directory\"" >&2

    if [ -n "$prompt" ]; then
        # Save prompt to temp file for complex commands
        echo "  echo '$prompt' | $command" >&2
        echo "" >&2
        echo "  Or save prompt to file first if command is complex:" >&2
        echo "  echo '$prompt' > /tmp/prompt.txt" >&2
        echo "  $command < /tmp/prompt.txt && rm /tmp/prompt.txt" >&2
    else
        echo "  $command" >&2
    fi
}

# Handles prompt for commands
# Arguments:
#   $1 - prompt text
#   $2 - command
# Outputs:
#   Full command with prompt handling
# Note: Claude Code takes prompts as positional arguments, not stdin.
#       Other commands use stdin redirection.
prepare_command_with_prompt() {
    local prompt="$1"
    local command="$2"

    if [ -n "$prompt" ]; then
        # Claude Code: pipe prompt to claude
        if [ "$command" = "claude" ]; then
            # Escape double quotes and backslashes in prompt for shell
            local escaped_prompt="${prompt//\\/\\\\}"
            escaped_prompt="${escaped_prompt//\"/\\\"}"
            echo "echo \"${escaped_prompt}\" | claude"
        else
            # Other commands: use stdin redirection
            local prompt_file=$(mktemp)
            echo "$prompt" > "$prompt_file"
            echo "$command < \"$prompt_file\" && rm \"$prompt_file\""
        fi
    else
        echo "$command"
    fi
}

# Prints a formatted error header
# Arguments:
#   $1 - terminal type (e.g., "iTerm2", "Terminal.app", "tmux")
#   $2 - tab/window name
#   $3 - error message
print_error_header() {
    local terminal="$1"
    local name="$2"
    local error_msg="$3"

    echo "[ERROR] $terminal Spawn: Failed to create tab '$name'" >&2
    if [ -n "$error_msg" ]; then
        echo "" >&2
        echo "Error details:" >&2
        echo "$error_msg" >&2
    fi
}

# Sanitizes tab name for safe use in terminal/AppleScript
# Arguments:
#   $1 - original tab name
# Outputs:
#   Sanitized tab name safe for use
sanitize_tab_name() {
    local name="$1"
    # Remove quotes, backslashes, newlines
    # Replace forward slashes with hyphens
    echo "$name" | tr -d '"\\' | tr '\n' ' ' | tr '/' '-' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//'
}
