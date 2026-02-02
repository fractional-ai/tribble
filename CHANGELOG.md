# Changelog

All notable changes to Tribble will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-08

### Added
- Initial release of Tribble plugin
- Task parallelization with dependency analysis
- Multi-terminal support:
  - macOS: iTerm2, Terminal.app
  - Linux: tmux, GNOME Terminal, Konsole
- Intelligent dependency detection
- Interactive execution plan approval
- Automatic terminal tab spawning
- `/tribble:run` command
- Comprehensive documentation:
  - README with installation and usage
  - DISTRIBUTION_GUIDE for team deployment
  - MARKETING_PLAN for visibility strategies
  - USABILITY_REPORT with optimization findings
  - Examples.md with use cases
- Installation script for easy deployment
- Test suite with automated testing

### Security
- Command validation before execution
- User approval required before spawning tasks
- No arbitrary code execution
- Scripts run with user permissions only

## [Unreleased]

### Changed
- **BREAKING**: Simplified to spawn-only utility
  - Removed `read`, `write`, `list` primitives and commands
  - Removed `/tribble:read`, `/tribble:write`, `/tribble:list` commands
  - All terminals now supported for spawn (was limited to terminals with full primitive support)

### Added
- Spawn support for Alacritty, Ghostty, GNOME Terminal, Windows Terminal
- All 8 terminals now fully supported: iTerm2, Terminal.app, Ghostty, Kitty, Alacritty, tmux, GNOME Terminal, Windows Terminal

### Removed
- `scripts/read.sh`, `scripts/write.sh`, `scripts/list.sh` and related directories
- `commands/read.md`, `commands/write.md`, `commands/list.md`
- `supports_primitive()` function from detect.sh (replaced with simpler `is_terminal_supported()`)

---

## Version History Guidelines

**Major Version (X.0.0)** - Breaking changes
- Incompatible API changes
- Removal of features
- Major architectural changes

**Minor Version (0.X.0)** - New features
- New functionality (backwards compatible)
- New terminal support
- Enhanced features

**Patch Version (0.0.X)** - Bug fixes
- Bug fixes
- Documentation updates
- Performance improvements
- Security patches

---

For detailed upgrade instructions between versions, see the [DISTRIBUTION_GUIDE](guides/DISTRIBUTION_GUIDE.md).
