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

    # Claude Code CLI (Story 02.2-006)
    claude-code-nix.packages.${system}.default  # Claude Code CLI

    # NOTE: MCP servers are configured via Home Manager using mcp-servers-nix.lib.mkConfig
    # See home-manager/modules/claude-code.nix for MCP server configuration

    # Version Control (Story 02.4-007)
    git                 # Git version control system
    git-lfs             # Git Large File Storage

    # Shell Enhancement Tools (Epic-04)
    fzf                 # Fuzzy finder for shell (Ctrl+R history, Ctrl+T files)
    fd                  # Fast find alternative (used by fzf)

    # Modern CLI Tools (Story 04.5-003)
    ripgrep             # Fast grep alternative (rg) - respects .gitignore, blazing fast
    bat                 # Cat clone with syntax highlighting and git integration
    eza                 # Modern ls replacement with tree view, icons, git support
    zoxide              # Smarter cd - tracks frecency (frequency + recency) for directory jumping
    httpie              # Modern curl alternative with JSON support and colored output
    tldr                # Simplified, community-driven man pages (tealdeer implementation)

    # System Monitoring (Story 02.4-006, Feature 06.3)
    btop                # Modern resource monitor (TUI) - prettier than gotop with themes
    gotop               # Interactive CLI system monitor (TUI for CPU, RAM, disk, network)
    macmon              # macOS system monitoring CLI tool (hardware specs, sensors)

    # Remote Access Tools
    mosh                # Mobile shell - persistent SSH alternative with roaming support

    # Nix Development Tools
    nil                 # Nix language server (simpler, lightweight)
    nixd                # Nix language server (feature-rich, used by Zed extension)

    # Language Servers for Editor Integration (Zed, VSCode)
    # Python
    pyright             # Python type checker and language server (fastest, recommended)

    # Shell/Bash
    bash-language-server  # Bash/Shell script language server
    shellcheck          # Shell script static analysis (used by bash-language-server)

    # Web Development (React.js / TypeScript / JavaScript)
    nodePackages.typescript-language-server  # TypeScript/JavaScript language server
    nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON, ESLint language servers
    nodePackages.prettier                    # Code formatter for JS/TS/HTML/CSS/JSON

    # YAML (for docker-compose, podman-compose, CI configs)
    yaml-language-server  # YAML language server with schema support

    # TOML (for pyproject.toml, Cargo.toml)
    taplo               # TOML language server and formatter

    # Markdown
    marksman            # Markdown language server with wiki-links support
  ];

  # Application Management & System Configuration
  system = {
    activationScripts = {
      # Create aliases for Nix-installed GUI apps in /Applications
      applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = [ "/Applications" ];
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

      # Sync maintenance scripts to ~/.local/bin (TCC-safe location for LaunchAgents)
      # macOS TCC blocks LaunchAgents from accessing ~/Documents, so we copy scripts
      # to ~/.local/bin which is not a protected folder
      syncMaintenanceScripts.text = ''
        echo "Syncing maintenance scripts to ~/.local/bin..."
        SCRIPTS_SRC="/Users/${userConfig.username}/${userConfig.directories.dotfiles}/scripts"
        SCRIPTS_DST="/Users/${userConfig.username}/.local/bin"

        # Create destination directory if it doesn't exist
        mkdir -p "$SCRIPTS_DST"

        # List of scripts used by LaunchAgents
        SCRIPTS=(
          "weekly-maintenance-digest.sh"
          "release-monitor.sh"
          "health-check.sh"
          "send-notification.sh"
          "fetch-release-notes.sh"
          "analyze-releases.sh"
          "create-release-issues.sh"
          "send-release-summary.sh"
        )

        for script in "''${SCRIPTS[@]}"; do
          if [[ -f "$SCRIPTS_SRC/$script" ]]; then
            cp "$SCRIPTS_SRC/$script" "$SCRIPTS_DST/$script"
            chmod 755 "$SCRIPTS_DST/$script"
            echo "  ✓ Synced $script"
          else
            echo "  ⚠ Script not found: $script"
          fi
        done

        echo "✓ Maintenance scripts synced to $SCRIPTS_DST"
      '';
    };

    # macOS System Preferences
    # NOTE: All system defaults have been moved to darwin/macos-defaults.nix (Epic-03)
    # This ensures better organization and single source of truth for system preferences

    # System state version
    stateVersion = lib.mkForce 4;

    # Set primary user for nix-darwin
    primaryUser = userConfig.username;
  };

  # Platform architecture (Apple Silicon and Intel support)
  nixpkgs.hostPlatform = "aarch64-darwin";

  # User Configuration (required by home-manager as of Dec 2025 update)
  users.users.${userConfig.username} = {
    name = userConfig.username;
    home = "/Users/${userConfig.username}";
    uid = 501;  # Standard macOS first user UID
  };

  # Security Configuration
  security.pam.services.sudo_local.touchIdAuth = true; # TouchID for sudo

  # System Configuration Validation
  assertions = [
    {
      assertion = config.nix.enable;
      message = "Nix daemon must be enabled for this configuration";
    }
  ];

  # Warning Messages (disabled - these showed on every rebuild)
  # warnings = [
  #   "Remember to run 'xcode-select --install' if building fails"
  #   "Use 'uv' for Python project dependencies and version management"
  # ];

  # NOTE: Stylix theming configuration has been moved to darwin/stylix.nix (Epic-05)
  # The stylix.nix module is imported via flake.nix commonModules
}
