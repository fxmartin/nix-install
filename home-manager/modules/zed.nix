# ABOUTME: Zed editor configuration for fast, modern code editing with Catppuccin theming
# ABOUTME: Manages Zed settings.json via Home Manager with auto-update disabled
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
  # Configuration: Declarative settings.json managed by Home Manager
  #
  # Key Features:
  # - Catppuccin Mocha theme (dark) or Latte (light) via system appearance
  # - JetBrains Mono Nerd Font with ligatures
  # - Auto-update disabled (updates via 'rebuild' command only)
  # - GPU-accelerated rendering
  #
  # Note: Home Manager does not have a native programs.zed module yet,
  # so we manage the settings.json file directly via home.file

  # Zed settings.json location: ~/.config/zed/settings.json
  home.file.".config/zed/settings.json" = {
    enable = true;
    text = builtins.toJSON {
      # Update Control - CRITICAL for project philosophy
      auto_update = false; # Updates only via 'rebuild' or 'update' commands

      # Theme Configuration
      # Catppuccin variants follow macOS system appearance:
      # - Light mode → Catppuccin Latte
      # - Dark mode → Catppuccin Mocha
      # Note: Zed detects system theme automatically, but we set default to Mocha
      theme = {
        mode = "system"; # Follow macOS system appearance (light/dark)
        light = "Catppuccin Latte";
        dark = "Catppuccin Mocha";
      };

      # Font Configuration
      # JetBrains Mono Nerd Font from nixpkgs with ligatures enabled
      buffer_font_family = "JetBrains Mono";
      buffer_font_size = 14;
      buffer_font_features = {
        calt = true; # Enable contextual alternates (ligatures)
      };

      # UI Font
      ui_font_family = "JetBrains Mono";
      ui_font_size = 14;

      # Editor Behavior
      tab_size = 2;
      soft_wrap = "editor_width";
      show_whitespace = "selection";
      vim_mode = false; # Set to true if FX prefers Vim keybindings

      # Git Integration
      git = {
        git_gutter = "tracked_files";
        inline_blame_enabled = true;
      };

      # Telemetry (disable for privacy)
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # Language Server Protocol (LSP) settings
      # Epic-04 will expand with Python, Nix, Bash, etc.
      lsp = {
        # Enable LSP for all supported languages by default
      };

      # File Tree
      project_panel = {
        dock = "left";
        default_width = 240;
      };

      # Terminal Integration
      terminal = {
        shell = {
          program = "zsh"; # Will be configured in Epic-04
        };
        font_family = "JetBrains Mono";
        font_size = 14;
      };

      # Assistant/AI Features (if available)
      # Zed has AI features via API keys - FX can configure later
      assistant = {
        enabled = false; # Disabled by default, can be enabled later
      };
    };
  };

  # Optional: Install Zed-compatible language servers via Home Manager
  # Epic-04 will add language servers for development environment
  # Examples: nixd (Nix LSP), pyright (Python), bash-language-server
  home.packages = with pkgs; [
    # Language servers will be added in Epic-04 Development Environment
  ];
}
