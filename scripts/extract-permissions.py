#!/usr/bin/env python3
"""
Extract tool uses from a Claude Code session and generate permission suggestions.

Usage:
    extract-permissions.py [session_file]

If no session file is provided, attempts to find the current session.
"""

import json
import sys
import os
import re
from pathlib import Path
from collections import defaultdict


def find_current_session():
    """Find the most recently modified session file for the current directory."""
    cwd = os.getcwd()
    # Convert path to Claude's project directory format
    project_dir_name = cwd.replace("/", "-")
    if project_dir_name.startswith("-"):
        project_dir_name = project_dir_name[1:]

    claude_projects = Path.home() / ".claude" / "projects"

    # Try exact match first
    project_path = claude_projects / f"-{project_dir_name}"
    if not project_path.exists():
        # Try finding a matching project directory
        for p in claude_projects.iterdir():
            if p.is_dir() and project_dir_name in p.name:
                project_path = p
                break

    if not project_path.exists():
        return None

    # Find most recent session file
    session_files = list(project_path.glob("*.jsonl"))
    if not session_files:
        return None

    return max(session_files, key=lambda f: f.stat().st_mtime)


def extract_tool_uses(session_file):
    """Extract all tool uses from a session file."""
    bash_commands = defaultdict(int)
    other_tools = defaultdict(int)

    with open(session_file, 'r') as f:
        for line in f:
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            # Look for assistant messages with tool_use
            if entry.get("type") == "assistant" or "message" in entry:
                message = entry.get("message", entry)
                content = message.get("content", [])

                if isinstance(content, list):
                    for item in content:
                        if isinstance(item, dict) and item.get("type") == "tool_use":
                            tool_name = item.get("name", "")
                            tool_input = item.get("input", {})

                            if tool_name == "Bash":
                                cmd = tool_input.get("command", "")
                                if cmd:
                                    bash_commands[cmd] += 1
                            elif tool_name in ("Read", "Write", "Edit", "Glob", "Grep"):
                                # These are typically auto-allowed, skip
                                pass
                            elif tool_name.startswith("mcp__"):
                                other_tools[tool_name] += 1
                            elif tool_name == "WebFetch":
                                url = tool_input.get("url", "")
                                if url:
                                    other_tools[f"WebFetch({url})"] += 1
                            elif tool_name not in ("Task", "AskUserQuestion", "TodoWrite", "TaskCreate", "TaskUpdate", "TaskList", "TaskGet"):
                                other_tools[tool_name] += 1

    return bash_commands, other_tools


def generalize_bash_command(cmd):
    """Convert a specific bash command to a permission rule pattern."""
    # Extract the base command (first word)
    parts = cmd.split()
    if not parts:
        return None

    base_cmd = parts[0]

    # Skip very short or common commands that are usually allowed or don't need approval
    skip_commands = {'ls', 'pwd', 'cd', 'echo', 'cat', 'head', 'tail', 'which', 'whoami', 'date',
                     'grep', 'find', 'rg', 'ag', 'chmod', 'mkdir', 'touch', 'mv', 'cp', 'rm'}
    if base_cmd in skip_commands:
        return None

    # Skip environment variable assignments at the start
    if '=' in base_cmd and not base_cmd.startswith('/'):
        return None

    # For paths, generalize them
    if base_cmd.startswith('/') or base_cmd.startswith('~') or base_cmd.startswith('.'):
        # It's a script path - use wildcard
        if '/.claude/plugins/' in base_cmd:
            # Plugin script - extract plugin name
            match = re.search(r'/\.claude/plugins/([^/]+)/scripts/', base_cmd)
            if match:
                plugin = match.group(1)
                return f"Bash(~/.claude/plugins/{plugin}/scripts/*)"
        return f"Bash({base_cmd})"

    # Common patterns
    patterns = {
        'git': f"Bash(git {parts[1]}*)" if len(parts) > 1 else "Bash(git *)",
        'npm': f"Bash(npm {parts[1]}*)" if len(parts) > 1 else "Bash(npm *)",
        'pnpm': f"Bash(pnpm {parts[1]}*)" if len(parts) > 1 else "Bash(pnpm *)",
        'yarn': f"Bash(yarn {parts[1]}*)" if len(parts) > 1 else "Bash(yarn *)",
        'bun': f"Bash(bun {parts[1]}*)" if len(parts) > 1 else "Bash(bun *)",
        'python': "Bash(python *)",
        'python3': "Bash(python3 *)",
        'node': "Bash(node *)",
        'cargo': "Bash(cargo *)",
        'make': "Bash(make *)",
        'docker': f"Bash(docker {parts[1]}*)" if len(parts) > 1 else "Bash(docker *)",
        'kubectl': "Bash(kubectl *)",
        'terraform': "Bash(terraform *)",
        'source': f"Bash(source *)",
        'kitty': f"Bash(kitty {parts[1]}*)" if len(parts) > 1 else "Bash(kitty *)",
        'tmux': f"Bash(tmux {parts[1]}*)" if len(parts) > 1 else "Bash(tmux *)",
        'osascript': "Bash(osascript *)",
        'gh': f"Bash(gh {parts[1]}*)" if len(parts) > 1 else "Bash(gh *)",
        'grep': "Bash(grep *)",
        'find': "Bash(find *)",
        'curl': "Bash(curl *)",
        'wget': "Bash(wget *)",
    }

    if base_cmd in patterns:
        return patterns[base_cmd]

    # For unknown commands, suggest the full pattern
    if len(parts) > 1:
        return f"Bash({base_cmd} *)"
    return f"Bash({base_cmd}*)"


def main():
    # Find session file
    if len(sys.argv) > 1:
        session_file = Path(sys.argv[1])
    else:
        session_file = find_current_session()

    if not session_file or not session_file.exists():
        print(json.dumps({
            "error": "Could not find session file",
            "suggestion": "Provide a session file path as argument"
        }))
        sys.exit(1)

    # Extract tool uses
    bash_commands, other_tools = extract_tool_uses(session_file)

    # Generate permission suggestions
    suggestions = {}

    for cmd, count in bash_commands.items():
        rule = generalize_bash_command(cmd)
        if rule:
            if rule not in suggestions:
                suggestions[rule] = {"count": 0, "examples": []}
            suggestions[rule]["count"] += count
            if len(suggestions[rule]["examples"]) < 3:
                suggestions[rule]["examples"].append(cmd[:100])

    for tool, count in other_tools.items():
        if tool not in suggestions:
            suggestions[tool] = {"count": count, "examples": []}
        else:
            suggestions[tool]["count"] += count

    # Sort by count
    sorted_suggestions = dict(sorted(suggestions.items(), key=lambda x: -x[1]["count"]))

    print(json.dumps({
        "session_file": str(session_file),
        "suggestions": sorted_suggestions,
        "total_unique_rules": len(sorted_suggestions)
    }, indent=2))


if __name__ == "__main__":
    main()
