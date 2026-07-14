# ABOUTME: Main Home Manager configuration for user environment
# ABOUTME: Manages user packages, dotfiles, and application settings
{
  lib,
  username,
  profileName ? "standard",
  ...
}:
{
  imports = [
    # Shell configuration (Epic-04)
    ./modules/shell.nix
    # Git configuration (Story 02.4-007)
    ./modules/git.nix
    # SSH configuration (Story 04.6-003)
    ./modules/ssh.nix
    # Zed editor configuration (Story 02.2-001)
    ./modules/zed.nix
    # Ghostty terminal configuration (Story 02.2-003)
    ./modules/ghostty.nix
    # Claude Code CLI and MCP servers configuration (Story 02.2-006)
    ./modules/claude-code.nix
    # Python development environment configuration (Feature 04.7)
    ./modules/python.nix
    # OpenAI Privacy Filter (MLX): venv + weight pre-pull (companion to darwin/privacy-filter.nix)
    ./modules/privacy-filter.nix
    # Apple-native local inference through a dedicated MLX-LM environment
    ./modules/mlx-lm.nix
    # Email notifications for maintenance (Feature 06.5)
    ./modules/msmtp.nix
    # CLI tool configurations with Catppuccin theming and sensible defaults
    ./modules/btop.nix # System monitor with Catppuccin Mocha theme
    ./modules/bat.nix # Cat replacement with syntax highlighting
    ./modules/ripgrep.nix # Grep replacement with smart defaults
    ./modules/fd.nix # Find replacement with ignore patterns
    ./modules/httpie.nix # HTTP client with developer defaults
  ]
  # Modules excluded from ai-assistant profile
  ++ lib.optionals (profileName != "ai-assistant") [
    ./modules/docker.nix # Docker container development environment (Feature 04.8)
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "23.11";
    enableNixpkgsReleaseCheck = false;

    # Packages are owned by imported Home Manager modules or nix-darwin.
    packages = [ ];
  };

  programs = {
    home-manager.enable = true;

    # Implemented via modules:
    # - programs.zsh (shell.nix - Oh My Zsh integration)
    # - programs.starship (shell.nix - prompt configuration)
    # - programs.git (git.nix - configuration for system-managed Git)
    # - programs.fzf (shell.nix - fuzzy finder)
    # - programs.bat (bat.nix - package and Catppuccin configuration)
    # - programs.btop (btop.nix - package and Catppuccin configuration)
    # - programs.direnv (python.nix - directory environments)
    #
    # Implemented via config files:
    # - ripgrep (ripgrep.nix - ~/.ripgreprc)
    # - fd (fd.nix - ~/.fdignore)
    # - httpie (httpie.nix - ~/.config/httpie/config.json)
  };

  # Stylix Target Configuration (Epic-05)
  # Configure which applications Stylix should theme
  stylix = {
    # Darwin-level release checks are disabled in darwin/stylix.nix; this
    # suppresses the matching Home Manager profile warning.
    enableReleaseChecks = false;

    targets = {
      # System monitoring - Stylix auto-themes btop with Catppuccin colors
      btop.enable = true;

      # bat - Stylix can theme bat but we use custom Catppuccin theme
      bat.enable = false; # Using catppuccin/bat theme instead

      # Disable targets we don't use
      vim.enable = false;
      firefox.enable = false;
    };
  };
}
