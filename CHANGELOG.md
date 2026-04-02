# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Claude Code config extracted to standalone `claude-code-config` submodule at `config/claude-code-config/`
- Portable `install.sh` enables usage on non-Nix machines and SSH sessions
- Added symlinks for `keybindings.json`, `docs/`, and `hooks/` (previously untracked)
- Updated `claude-code.nix` to reference submodule paths

### Added
- `scc` fast code counter (lines of code, complexity, COCOMO estimates)
- `typst` modern typesetting system for PDF generation from markup
- Health check HTTP API endpoint on port 7780 for remote monitoring via Tailscale
- Ollama model verification in health check with profile-aware expected models
- Qwen3-TTS LaunchAgent and health check for Power profile
- `nomic-embed-text` embedding model to both profiles
- Podman health check (machine status, image count, disk usage)
- `rebuild-dry` shell alias for dry-run builds (preview changes without applying)
- Nix Flake Check CI workflow (`.github/workflows/nix-flake-check.yml`)
- Secret scanning CI with gitleaks (`.github/workflows/security-scan.yml`)
- Automated GitHub Release workflow (`.github/workflows/release.yml`)
- Markdown link validation CI (`.github/workflows/docs-lint.yml`)
- Architecture documentation with module dependency diagrams (`docs/architecture.md`)
- Bootstrap troubleshooting FAQ in `docs/troubleshooting.md`
- Optional bearer token authentication for health API (`HEALTH_API_TOKEN` env var)
- Hetzner infrastructure and Ollama network access via Tailscale
- `mactop` Apple Silicon system monitor
- Telegram messaging app
- Daily Calibre library backup to NAS
- Get Shit Done (GSD) meta-prompting system for Claude Code
- 1Password for Safari extension via Mac App Store
- LM Studio for local LLM management
- Calibre DeDRM and KFX plugin configuration deployment
- reMarkable desktop app via Mac App Store
- Tailscale VPN via Homebrew
- SMB automount via autofs for NAS shares (Power profile)
- iCloud sync for work proposals with per-job schedules (Power profile)
- Photo backup to TerraMaster NAS
- SSH/mosh environment-aware visual indicators (prod/staging/dev banners)
- Automatic MCP path updates after rebuild
- Disk cleanup script with monthly LaunchAgent
- Node.js to Nix packages
- macOS system update checking to release monitor
- Mac App Store apps installation support

### Changed
- Verify rsync daemon port 873 before backup when using daemon mode (fail fast instead of 10x120s retries)
- Centralized Ollama model lists in `flake.nix` with `mkOllamaModelScript` generator
- Centralized OLLAMA_HOST/OLLAMA_ORIGINS in `maintenance.nix` `let` block
- Created `mkScheduledAgent` helper — eliminated ~100 lines of LaunchAgent boilerplate
- Extracted shared `findRepoRoot` helper in `flake.nix` `extraSpecialArgs`
- Replaced `gpt-oss` with `ministral-3:14b` as primary Ollama model
- Use Finder-equivalent disk space metric (includes purgeable space)
- Use mDNS hostname for NAS, configure Playwright with Brave
- Use rsync daemon mode for faster NAS backups with automatic retry logic
- Read SMB password from file instead of keychain
- Add `timeout` to all expensive `du` commands in health checks (30s stores, 15s caches)
- Shared health check constants between `health-check.sh` and `health-api.py`
- Consolidated story directories: moved feature stories to `stories/features/`
- Centralized repo URLs in `lib/common.sh` for fork portability (env var overrides)
- Bootstrap temp dir uses `mktemp -d` instead of fixed `/tmp/nix-bootstrap`
- Added `Umask = 77` to all LaunchAgents via `mkScheduledAgent`
- Switched CI to DeterminateSystems/nix-installer-action (cachix fails on macOS runners)

### Fixed
- `log_warning` typo in `repo-clone.sh` — function was `log_warn`
- Hardcoded NAS username in `smb-automount.nix` — now uses `userConfig.username`
- Ghostty repo-finder fallback inconsistency
- Handle root-owned claude config files from failed runs
- Auto-cleanup leftover Nix backup files before installation
- Permission handling for claude config directory
- Use full path `/usr/bin/sudo` in activation script
- Use Nix path for npx in GSD installation
- Re-enable sequential-thinking MCP server
- Add missing `.gitmodules` for oh-my-zsh plugins
- Add iCloud file preparation before rsync backup
- Disable marksman due to nixpkgs Swift build issue
- MCP servers configuration for both Claude Desktop and CLI
- Add missing `darwin/*.nix` files to bootstrap download list
- Make maintenance scripts and osxphotos power-profile-only
- Update tailscale cask name to `tailscale-app`
- NAS mount fixes (activation scripts, synthetic.conf, escape sequences)
- Ensure `gh` CLI and `darwin-rebuild` in PATH during bootstrap
- SSH socket glob with `nullglob` in `ssh-github.sh` (no more unmatched pattern errors)
- Disk space check in `repo-clone.sh` now uses `REPO_CLONE_DIR` parent (not hardcoded `~/Documents`)
- `gh auth login` 5-minute timeout prevents indefinite blocking
- Outdated Ollama model names in troubleshooting guide

### Security
- Remove `shell=True` from `health-api.py` subprocess calls
- Remove `eval` from `maintenance-wrapper.sh`
- Move Calibre sensitive data to local secrets directory
- Add `Umask = 0077` to all LaunchAgents (log files restricted to owner)
- Health API optional bearer token authentication (timing-safe comparison)

### Removed
- Arc browser from installed apps
- GIMP from application installation
- GitHub MCP server from configuration
- Bootstrap dev server (moved to standalone repo)
- `bootstrap.sh.monolithic` legacy file (5081 lines, superseded by modular `lib/*.sh`)

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
| 1.1.0 | TBD | Health API, CI/CD, DRY refactors, Podman health check |
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
