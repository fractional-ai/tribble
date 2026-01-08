# Contributing to Pasta Maker

## Development Setup
1. Fork the repository
2. Clone your fork
3. Make scripts executable: chmod +x scripts/*.sh
4. Test locally: claude --plugin-dir .

## Testing Changes
- Test all three terminal types (iTerm2, Terminal.app, tmux)
- Verify error handling with invalid inputs
- Check permission scenarios

## Code Style
- Bash: Use shellcheck to validate scripts
- Markdown: Follow CommonMark specification
- Comments: Explain WHY, not WHAT

## Submitting Changes
1. Create feature branch
2. Make focused changes
3. Test thoroughly
4. Write descriptive commit messages
5. Submit pull request with:
   - Description of changes
   - Testing performed
   - Breaking changes (if any)
