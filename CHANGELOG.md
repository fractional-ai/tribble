# Changelog

All notable changes to pasta-maker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-08

### Added
- Initial release of Pasta Maker plugin
- Task parallelization with dependency analysis
- Multi-terminal support:
  - macOS: iTerm2, Terminal.app
  - Linux: tmux, GNOME Terminal, Konsole
- Intelligent dependency detection
- Interactive execution plan approval
- Automatic terminal tab spawning
- `/pasta-maker:run` command
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

### Added
- Windows Terminal support for WSL environments
- Tab name sanitization helper in common library
- Improved terminal detection for Windows Terminal
- Installation validation script (`scripts/validate-installation.sh`)
- Comprehensive troubleshooting section in README
- Better error messages with actionable fixes in common library

### Fixed
- Test suite arithmetic expansion bug for better POSIX compatibility

### Improved
- Error messages in spawn scripts now include context and suggestions
- Directory validation provides detailed troubleshooting steps
- tmux spawn script has clearer error messages with examples

### Planned Features
- Save and reuse workflow configurations
- Web-based dashboard for monitoring tasks
- Task templates for common workflows
- Enhanced error handling and recovery

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
