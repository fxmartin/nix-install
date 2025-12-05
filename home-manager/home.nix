# ABOUTME: Main Home Manager configuration for user environment
# ABOUTME: Manages user packages, dotfiles, and application settings
{
  config,
  pkgs,
  lib,
  username,
  userConfig,
  ...
}: {
  imports = [
    # Shell configuration (Epic-04)
    ./modules/shell.nix
    # GitHub CLI configuration (Story 01.6-002 dependency)
    ./modules/github.nix
    # Git configuration (Story 02.4-007)
    ./modules/git.nix
    # SSH configuration (Story 04.6-003)
    ./modules/ssh.nix
    # Zed editor configuration (Story 02.2-001)
    ./modules/zed.nix
    # VSCode configuration (Story 02.2-002) - DISABLED: Electron crash issues
    # ./modules/vscode.nix
    # Ghostty terminal configuration (Story 02.2-003)
    ./modules/ghostty.nix
    # Claude Code CLI and MCP servers configuration (Story 02.2-006)
    ./modules/claude-code.nix
    # Python development environment configuration (Feature 04.7)
    ./modules/python.nix
    # Podman container development environment (Feature 04.8)
    ./modules/podman.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "23.11";

    # User packages installed via Home Manager
    # Epic-04 will expand with development tools:
    # - direnv (directory-specific environments)
    # - pipx (Python CLI tool installer)
    # - markdownlint-cli (Markdown linting)
    # - Additional dev tools
    packages = with pkgs; [
      # Minimal packages for initial setup
      # Epic-04 will populate this with full development environment
    ];
  };

  programs = {
    home-manager.enable = true;

    # Epic-04 will add:
    # - programs.zsh (full Zsh configuration with Oh My Zsh)
    # - programs.starship (prompt configuration)
    # - programs.git (Git configuration)
    # - programs.fzf (fuzzy finder)
    # - programs.bat (cat replacement)
    # - programs.eza (ls replacement)
    # - programs.ripgrep (grep replacement)
    # - programs.jq (JSON processor)
    # - programs.btop (system monitor)
    # - programs.direnv (directory environments)
  };

  # Stylix Target Configuration (Epic-05)
  # Configure which applications Stylix should theme
  stylix.targets = {
    # Terminal applications
    # Epic-05 will configure: ghostty, alacritty (if used)

    # Development tools
    # Epic-05 will enable: neovim, bat, lazygit, tmux

    # System monitoring
    # Epic-05 will enable: btop

    # Disable targets we don't use
    vim.enable = false;
    firefox.enable = false;
  };
}
