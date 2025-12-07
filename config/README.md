# Configuration Files

This directory contains configuration files for the nix-darwin MacBook setup.

## Current Configuration Files

### Terminal & Shell
- **config.ghostty** - Ghostty terminal configuration (Catppuccin theme, JetBrains Mono, keybindings)
  - **Status**: Active - Used in Story 02.2-003 and Epic-05
  - Referenced in Home Manager as: `xdg.configFile."ghostty/config".source = ../config/config.ghostty;`

- **starship.toml** - Starship prompt configuration (adapted from p10k lean style)
  - **Status**: Active - Used in Story 04.2-001 (Starship Prompt)
  - **Adapted from**: config/p10k.zsh (Powerlevel10k configuration)
  - **Style**: 2-line, lean, disconnected, transient prompt support
  - **Features**: os_icon, directory, git, comprehensive right prompt (status, duration, languages, cloud, nix_shell)
  - Referenced in Home Manager as: `programs.starship.configFile = ../config/starship.toml;`

### Wallpaper
- **wallpaper/Ropey_Photo_by_Bob_Farrell.jpg** - Desktop wallpaper
  - **Status**: Active - Used in Story 05.1-001 (Stylix configuration)
  - Referenced in Stylix config as: `image = ./wallpaper/Ropey_Photo_by_Bob_Farrell.jpg;`

### Application Configurations
- **zed/settings.json** - Zed editor configuration (bidirectional sync)
  - **Status**: Active - Used in Story 02.2-001 (Zed Editor Installation)
  - **Configuration**: Catppuccin theme, JetBrains Mono font, auto-update disabled
  - **Deployment**: Symlinked to `~/.config/zed/settings.json` (bidirectional sync)
  - **Sync Strategy**: `~/.config/zed/settings.json` → `~/nix-install/config/zed/settings.json`
  - **Benefits**:
    * Changes in Zed instantly appear in repo (trackable with git)
    * Pulling repo updates instantly updates Zed settings
    * Settings version controlled, can commit/revert changes
    * Zed has full write access (symlink to working directory, not /nix/store)
  - **Why this works**: Symlink points to repo working directory, not read-only /nix/store (Issue #26)
  - Referenced via activation script in `home-manager/modules/zed.nix`

- **istat-menus/iStat Menus Settings.ismp7** - iStat Menus configuration export
  - **Status**: Active - Manual import on bootstrap
  - **Configuration**: FX's preferred menubar items, update intervals, display formats, auto-update disabled
  - **Deployment**: Manual import via iStat Menus → Preferences → General → Import Settings
  - **Benefits**:
    * Consistent iStat Menus setup across all MacBooks
    * Auto-update already disabled in exported settings (critical for update control policy)
    * Version-controlled configuration, changes trackable
    * Quick setup on new machines (no manual configuration)
  - **Note**: iStat Menus cannot be configured via symlink (encrypted plist), requires manual import
  - **Export New Settings**: Preferences → General → Export Settings → Save to this directory
  - Referenced in `docs/apps/system/system-monitoring.md`

### CLI Tool Configurations (Home Manager Generated)

The following CLI tools have their configurations managed via Home Manager modules in `home-manager/modules/`:

- **btop** - System monitor with Catppuccin Mocha theme
  - **Module**: `home-manager/modules/btop.nix`
  - **Config Location**: `~/.config/btop/btop.conf` (generated)
  - **Theme File**: `~/.config/btop/themes/catppuccin_mocha.theme` (generated)
  - **Features**: 2s update interval, braille graphs, battery monitoring

- **bat** - Cat replacement with syntax highlighting
  - **Module**: `home-manager/modules/bat.nix`
  - **Config Location**: `~/.config/bat/config` (generated)
  - **Theme**: Catppuccin Mocha (downloaded from catppuccin/bat repo)
  - **Features**: Line numbers, changes indicator, grid style

- **ripgrep** - Grep replacement with smart defaults
  - **Module**: `home-manager/modules/ripgrep.nix`
  - **Config Location**: `~/.ripgreprc` (generated)
  - **Features**: Smart case, hidden files, common ignores (node_modules, __pycache__, .venv, etc.)
  - **Environment**: `RIPGREP_CONFIG_PATH` set automatically

- **fd** - Find replacement with ignore patterns
  - **Module**: `home-manager/modules/fd.nix`
  - **Config Location**: `~/.fdignore` (generated)
  - **Features**: Comprehensive ignore patterns for development (build artifacts, lock files, media)

- **httpie** - HTTP client with developer defaults
  - **Module**: `home-manager/modules/httpie.nix`
  - **Config Location**: `~/.config/httpie/config.json` (generated)
  - **Features**: Pretty print, monokai style, follow redirects, JSON default

## Reference Files (Legacy/Backup)

These files are preserved as reference from the previous Oh My Zsh + Powerlevel10k setup:

### Zsh Configuration (Reference Only)
- **p10k.zsh** - Powerlevel10k configuration (88KB)
  - **Status**: Reference only - NOT used in final nix-install
  - **Purpose**: Backup of previous p10k setup, reference for prompt preferences
  - **Note**: nix-install uses **Starship** instead of Powerlevel10k (Story 04.2-001)

- **zshrc** - Previous .zshrc configuration
  - **Status**: Reference only - NOT used in final nix-install
  - **Purpose**: Reference for any custom aliases, functions, or settings
  - **Note**: Zsh config is managed by Home Manager (Story 04.1-001, 04.1-002)

- **zprofile** - Previous .zprofile configuration (if exists)
  - **Status**: Reference only - NOT used in final nix-install
  - **Purpose**: Reference for environment variables and login shell settings

### Oh My Zsh Custom (Reference Only)
- **oh-my-zsh-custom/** - Custom Oh My Zsh plugins and themes
  - **Status**: Reference only - NOT used in final nix-install
  - **Purpose**: Backup of custom plugins (like zsh-autosuggestions)
  - **Note**: Plugins are managed via Home Manager Oh My Zsh integration (Story 04.1-002)

## Design Decisions

### Why Starship Instead of Powerlevel10k?
The nix-install project uses **Starship** (Story 04.2-001) instead of Powerlevel10k for:
1. **Nix-Native**: Pure Nix package, fully declarative
2. **Cross-Platform**: Works on macOS and Linux
3. **Fast**: Rust-based, instant prompt rendering
4. **Declarative Config**: TOML-based configuration fits Nix philosophy
5. **Reference Alignment**: Used in mlgruby reference implementation

### Configuration Management Philosophy
- **Active Configs**: Minimal, essential configs tracked in this directory
- **Generated Configs**: Most configs generated by Home Manager/Stylix
- **Reference Files**: Previous configs saved for reference, not used in automation
- **Immutability**: Configs copied to Nix store, symlinked to correct locations

## Configuration File Workflow

1. **Active Files**: Copied from `config/` to appropriate locations by Home Manager
2. **Reference Files**: Kept for historical reference and migration insights
3. **Generated Files**: Created by Stylix, Home Manager, or activation scripts
4. **Symlinks**: Home Manager creates symlinks from `~/.config/` to Nix store

Example:
```nix
# In home-manager module
xdg.configFile."ghostty/config".source = ../config/config.ghostty;
# Results in: ~/.config/ghostty/config -> /nix/store/...-config.ghostty
```

## Adding New Configuration Files

When adding new config files to this directory:
1. Place the file in `config/`
2. Add a reference in the appropriate Home Manager module
3. Update this README with file purpose and status
4. Test in VM to ensure symlinks work correctly
5. Commit with clear documentation of intent

## See Also
- **Epic-04**: Development Environment & Shell Configuration
- **Epic-05**: Theming & Visual Consistency
- **mlgruby-repo-for-reference/**: Production reference implementation
