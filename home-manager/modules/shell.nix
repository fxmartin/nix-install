# ABOUTME: Shell configuration module for Zsh with Oh My Zsh and Starship (STUB for Epic-04)
# ABOUTME: Manages shell environment, aliases, plugins, and prompt configuration
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # Shell Configuration
  # Epic-04 will implement comprehensive Zsh configuration:

  # 1. Zsh Setup:
  #    - Enable Zsh as default shell
  #    - Oh My Zsh integration
  #    - Plugins: git, fzf, zsh-autosuggestions, z
  #    - ZSH_THEME="" (use Starship instead)
  #    - Custom aliases and functions

  # 2. Starship Prompt:
  #    - Enable and configure Starship
  #    - Custom prompt format
  #    - Git status integration
  #    - Directory truncation
  #    - Command duration display
  #    - Nix shell indicator

  # 3. FZF Integration:
  #    - Ctrl+R: Command history search
  #    - Ctrl+T: File search
  #    - Alt+C: Directory navigation
  #    - Custom key bindings

  # 4. Shell Aliases:
  #    - ls → eza (with colors and icons)
  #    - cat → bat (syntax highlighting)
  #    - grep → rg (ripgrep)
  #    - find → fd (faster alternative)
  #    - docker → podman (container compatibility)
  #    - docker-compose → podman-compose (compose compatibility)
  #    - Custom git aliases
  #    - Directory navigation shortcuts
  #    - Nix system management aliases:
  #      - nix-update: Update flake.lock only
  #      - nix-rebuild: Rebuild system without updating
  #      - nix-full: Update flake.lock and rebuild system

  # 5. Environment Variables:
  #    - EDITOR, VISUAL
  #    - PATH additions
  #    - Development tool configurations
  #    - Language-specific settings

  # 6. Shell Functions:
  #    - mkcd (make directory and cd into it)
  #    - extract (universal archive extractor)
  #    - Custom git workflows
  #    - Development shortcuts

  # Minimal shell setup for initial flake validation
  # Full implementation in Epic-04
  programs.zsh = {
    enable = lib.mkDefault false; # Will be enabled in Epic-04
    # Full configuration will be added in Epic-04

    # Shell aliases (available now, will be expanded in Epic-04)
    shellAliases = {
      # Nix system management (using scripts/update-system.sh)
      nix-update = "bash ${config.home.homeDirectory}/Documents/nix-install/scripts/update-system.sh update";
      nix-rebuild = "bash ${config.home.homeDirectory}/Documents/nix-install/scripts/update-system.sh rebuild";
      nix-full = "bash ${config.home.homeDirectory}/Documents/nix-install/scripts/update-system.sh full";

      # Quick rebuild (auto-detect profile)
      rebuild = "bash ${config.home.homeDirectory}/Documents/nix-install/scripts/update-system.sh rebuild";

      # Additional aliases will be added in Epic-04
      # ls → eza, cat → bat, grep → rg, find → fd, docker → podman, etc.
    };
  };

  programs.starship = {
    enable = lib.mkDefault false; # Will be enabled in Epic-04
    # Full configuration will be added in Epic-04
  };
}
