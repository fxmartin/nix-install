# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Nothing yet

### Changed
- Nothing yet

### Fixed
- Nothing yet

## [1.0.0] - 2025-12-07

### Added

#### Bootstrap & Installation (Epic-01)
- One-command bootstrap script with 9 phases
- Pre-flight environment checks (macOS version, disk space, network)
- Profile selection system (Standard for MacBook Air, Power for MacBook Pro)
- Automated Xcode CLI tools installation
- Nix multi-user installation with flakes enabled
- Nix-darwin system configuration
- SSH key generation with GitHub SSH key upload (via `gh auth`)
- Full repository clone and final darwin rebuild
- Installation summary with next steps

#### Application Installation (Epic-02)
- AI & LLM tools: Claude Desktop, Ollama with profile-specific models
- Development apps: Zed editor, VSCode, Ghostty terminal, Claude Code CLI
- Python tools: uv, ruff, pyright via Nix
- Container tools: Podman, podman-compose
- Browsers: Arc, Brave (replaced Firefox)
- Productivity: Raycast, 1Password, Dropbox, Calibre, Kindle, Keka, Marked 2
- Communication: WhatsApp, Zoom, Cisco Webex
- Media: VLC, GIMP
- Security: NordVPN
- System utilities: Onyx, f.lux, gotop, macmon, btop, iStat Menus
- Profile-specific: Parallels Desktop (Power profile only)
- Office 365 suite via Homebrew cask

#### System Configuration (Epic-03)
- Finder preferences: View settings, behavior settings, sidebar customization
- Security: Firewall enabled with stealth mode, FileVault prompt
- Input: Trackpad gestures, mouse/scroll settings, keyboard repeat rates
- Display: Auto light/dark mode, Night Shift documentation
- Dock: Auto-hide, minimize to app icon, persistent apps
- Time Machine: Preferences and exclusions configuration

#### Development Environment (Epic-04)
- Zsh shell with Oh My Zsh and plugins (git, fzf, zsh-autosuggestions, z)
- Starship prompt with custom configuration
- FZF integration with keybindings (Ctrl+R, Ctrl+T, Alt+C)
- Ghostty terminal configuration with Catppuccin theme
- Comprehensive shell aliases (Nix, Git, modern CLI tools)
- Git configuration with LFS support
- SSH configuration for GitHub
- Python environment variables and dev tools
- Podman machine initialization and Docker compatibility aliases
- Editor theming for Zed and VSCode

#### Theming & Visual Consistency (Epic-05)
- Stylix-based system-wide theming
- Catppuccin Mocha (dark) and Latte (light) themes
- JetBrains Mono Nerd Font with ligatures
- Automatic light/dark mode switching following macOS
- Consistent theming across Ghostty, Zed, btop, and CLI tools

#### Maintenance & Monitoring (Epic-06)
- Nix store garbage collection (weekly LaunchAgent + manual alias)
- Nix store optimization (weekly LaunchAgent + manual alias)
- System monitoring: btop, gotop, macmon, iStat Menus
- Health check script (`health-check` alias)
- Weekly maintenance digest with email reports
- AI-powered release monitor for GitHub repositories

#### Documentation (Epic-07)
- README quick start guide
- Update philosophy documentation
- Licensed app documentation (post-install activation)
- Post-install checklist
- Common issues and troubleshooting guide
- Rollback documentation
- Adding apps and customization guide
- Configuration examples

### Changed
- Repository renamed from `nix-config` to `nix-install`
- Default installation path changed to `~/.config/nix-install`
- Firefox replaced with Brave browser
- Office 365 installation changed from manual to Homebrew cask
- LaunchAgent scripts moved to `~/.local/bin` for TCC compliance

### Fixed
- Catppuccin/bat theme commit hash corrected
- Stylix for btop theme instead of manual config
- Profile parsing from user-config.nix
- Bootstrap handling of unset terminal env vars
- VM testing template download and uppercase Y acceptance

### Security
- SSH keys generated locally, private key never transmitted
- No secrets in Git repository (.gitignore excludes sensitive files)
- FileVault disk encryption prompt and status check
- Firewall enabled with stealth mode by default
- HOMEBREW_NO_AUTO_UPDATE=1 to prevent uncontrolled updates

### Tested
- Parallels macOS VM (macOS 15.x Sequoia)
- MacBook Pro M3 Max with macOS 26.1 Tahoe (Power profile)
- Apple Silicon (arm64) architecture fully supported

---

## Version History

| Version | Date | Milestone |
|---------|------|-----------|
| 1.0.0 | 2025-12-07 | Initial release - MacBook Pro M3 Max running Power profile |

## Migration Notes

### From Manual Setup to Nix-Install 1.0.0

If migrating from a manually configured Mac:

1. **Backup existing dotfiles**: Bootstrap creates backups automatically
2. **Export app settings**: Some apps may need settings exported (1Password, Raycast)
3. **Note license keys**: Have license keys ready for activation post-install
4. **Run bootstrap**: `curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/bootstrap.sh | bash`
5. **Activate licenses**: Follow `docs/licensed-apps.md` for post-install setup

### Breaking Changes

None in this initial release.

## Contributing

When contributing, please update this changelog in the "Unreleased" section with:
- **Added**: New features
- **Changed**: Changes to existing functionality
- **Deprecated**: Features that will be removed
- **Removed**: Features that have been removed
- **Fixed**: Bug fixes
- **Security**: Security improvements

## Links

- [Repository](https://github.com/fxmartin/nix-install)
- [Documentation](./docs/)
- [Issues](https://github.com/fxmartin/nix-install/issues)
- [Requirements](./docs/REQUIREMENTS.md)
