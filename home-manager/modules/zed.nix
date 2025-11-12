# ABOUTME: Zed editor configuration for fast, modern code editing with Catppuccin theming
# ABOUTME: Install Zed via Homebrew, manual configuration required (see docs/app-post-install-configuration.md)
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # Zed Editor Configuration
  # Story 02.2-001: Install and configure Zed with Catppuccin theme
  #
  # Installation: Via Homebrew cask (darwin/homebrew.nix)
  # Configuration: Manual post-install setup (see docs/app-post-install-configuration.md)
  #
  # Why manual configuration:
  # Zed expects to manage its own settings.json file (~/.config/zed/settings.json)
  # Home Manager creates read-only symlinks to /nix/store, preventing Zed from updating settings
  # Issue #26: Attempting declarative config causes "failed to write to /nix/store" errors
  #
  # Solution:
  # - Zed installed via Homebrew cask
  # - Settings configured manually on first launch (documented in app-post-install-configuration.md)
  # - Critical settings: auto_update=false, Catppuccin theme, JetBrains Mono font
  #
  # Key Features (configured manually):
  # - Catppuccin Mocha theme (dark) or Latte (light) via system appearance
  # - JetBrains Mono Nerd Font with ligatures
  # - Auto-update disabled (updates via 'rebuild' command only)
  # - Git integration, telemetry disabled, terminal integration

  # Optional: Install Zed-compatible language servers via Home Manager
  # Epic-04 will add language servers for development environment
  # Examples: nixd (Nix LSP), pyright (Python), bash-language-server
  home.packages = with pkgs; [
    # Language servers will be added in Epic-04 Development Environment
  ];
}
