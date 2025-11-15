# ABOUTME: Main nix-darwin system configuration for macOS
# ABOUTME: Manages system-level settings, packages, and activation scripts
{
  config,
  pkgs,
  lib,
  userConfig,
  claude-code-nix,
  mcp-servers-nix,
  system,
  ...
}: {
  # Nix package manager settings
  nix.enable = true;

  # Nix configuration settings
  nix.settings = {
    # Enable modern Nix features (required for flakes)
    experimental-features = ["nix-command" "flakes"];

    # Trust specific users
    trusted-users = ["root" userConfig.username];
  };

  # Set correct GID for nixbld group
  ids.gids.nixbld = 350;

  # Allow installation of non-free packages
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # System-wide packages installed via Nix
  # Keep minimal - most CLI tools managed via Home Manager
  environment.systemPackages = with pkgs; [
    # macOS Integration
    darwin.cctools

    # Core Utilities
    curl
    wget
    tree

    # Build Dependencies
    openssl
    readline
    sqlite
    zlib

    # Python Development Environment (Story 02.2-004)
    python312           # Python 3.12 interpreter
    uv                  # Fast Python package installer and resolver

    # Python Development Tools
    ruff                # Extremely fast Python linter and formatter
    black               # Python code formatter
    python312Packages.isort    # Import statement organizer
    python312Packages.mypy     # Static type checker
    python312Packages.pylint   # Comprehensive linter

    # Claude Code CLI and MCP Servers (Story 02.2-006)
    claude-code-nix.packages.${system}.default  # Claude Code CLI

    # MCP Servers - Use legacyPackages instead of packages (Issue #35 fix)
    mcp-servers-nix.legacyPackages.${system}.mcp-server-context7  # Context7 MCP server
    mcp-servers-nix.legacyPackages.${system}.mcp-server-github    # GitHub MCP server
    mcp-servers-nix.legacyPackages.${system}.mcp-server-sequential-thinking  # Sequential Thinking MCP server
  ];

  # Application Management & System Configuration
  system = {
    activationScripts = {
      # Create aliases for Nix-installed GUI apps in /Applications
      applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
              app_name=$(basename "$src")
              echo "copying $src" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

      # Verify Xcode Command Line Tools are installed
      xcodeCheck.text = ''
        echo "Checking for Xcode Command Line Tools..."
        if ! xcode-select -p &> /dev/null; then
          echo "⚠️  Xcode Command Line Tools not found"
          echo "Please install them using: xcode-select --install"
          exit 1
        else
          echo "✓ Xcode Command Line Tools installed"
        fi
      '';
    };

    # macOS System Preferences (minimal - expanded in Epic-03)
    defaults = {
      finder.FXPreferredViewStyle = "clmv"; # Column view
      loginwindow.GuestEnabled = false; # Disable guest account
      NSGlobalDomain = {
        AppleICUForce24HourTime = true; # 24-hour time
        AppleInterfaceStyle = "Dark"; # Dark mode
        KeyRepeat = 2; # Fast key repeat
      };
    };

    # System state version
    stateVersion = lib.mkForce 4;

    # Set primary user for nix-darwin
    primaryUser = userConfig.username;
  };

  # Platform architecture (Apple Silicon and Intel support)
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Security Configuration
  security.pam.services.sudo_local.touchIdAuth = true; # TouchID for sudo

  # System Configuration Validation
  assertions = [
    {
      assertion = config.nix.enable;
      message = "Nix daemon must be enabled for this configuration";
    }
  ];

  # Warning Messages
  warnings = [
    "Remember to run 'xcode-select --install' if building fails"
    "Use 'uv' for Python project dependencies and version management"
  ];

  # Stylix System-wide Theming (Catppuccin)
  # Will be expanded in Epic-05
  stylix = {
    enable = true;

    # Catppuccin Mocha theme (dark mode)
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Generate solid color wallpaper from theme
    image = config.lib.stylix.pixel "base00";

    # Font configuration (JetBrains Mono Nerd Font)
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.source-serif;
        name = "Source Serif 4";
      };
    };
  };
}
