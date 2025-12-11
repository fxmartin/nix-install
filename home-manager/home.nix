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
    # Email notifications for maintenance (Feature 06.5)
    ./modules/msmtp.nix
    # CLI tool configurations with Catppuccin theming and sensible defaults
    ./modules/btop.nix     # System monitor with Catppuccin Mocha theme
    ./modules/bat.nix      # Cat replacement with syntax highlighting
    ./modules/ripgrep.nix  # Grep replacement with smart defaults
    ./modules/fd.nix       # Find replacement with ignore patterns
    ./modules/httpie.nix   # HTTP client with developer defaults
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

    # Implemented via modules:
    # - programs.zsh (shell.nix - Oh My Zsh integration)
    # - programs.starship (shell.nix - prompt configuration)
    # - programs.git (git.nix - Git configuration)
    # - programs.fzf (shell.nix - fuzzy finder)
    # - programs.bat (bat.nix - cat replacement with Catppuccin)
    # - programs.btop (btop.nix - system monitor with Catppuccin)
    # - programs.direnv (python.nix - directory environments)
    #
    # Implemented via config files:
    # - ripgrep (ripgrep.nix - ~/.ripgreprc)
    # - fd (fd.nix - ~/.fdignore)
    # - httpie (httpie.nix - ~/.config/httpie/config.json)
  };

  # Stylix Target Configuration (Epic-05)
  # Configure which applications Stylix should theme
  stylix.targets = {
    # System monitoring - Stylix auto-themes btop with Catppuccin colors
    btop.enable = true;

    # bat - Stylix can theme bat but we use custom Catppuccin theme
    bat.enable = false;  # Using catppuccin/bat theme instead

    # Disable targets we don't use
    vim.enable = false;
    firefox.enable = false;
  };
}
