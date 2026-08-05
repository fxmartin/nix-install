# ABOUTME: Main Nix flake defining system configurations for Standard and Power profiles
# ABOUTME: Integrates nixpkgs, nix-darwin, home-manager, nix-homebrew, and stylix
{
  description = "Nix-darwin configuration for FX's MacBooks - Standard, Power, and AI-Assistant profiles";

  inputs = {
    # Package Sources
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home Manager for user environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin for macOS system configuration
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homebrew management
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Stylix for system-wide theming (Catppuccin)
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude Code CLI
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MCP Servers (Context7, GitHub, Sequential Thinking)
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      stylix,
      claude-code-nix,
      mcp-servers-nix,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # User configuration validation
      userConfig =
        if builtins.pathExists ./user-config.nix then
          import ./user-config.nix
        else if builtins.getEnv "NIX_INSTALL_CI" == "1" then
          import ./tests/fixtures/user-config.ci.nix
        else
          throw "user-config.nix not found. Run bootstrap.sh first or create from user-config.template.nix";

      # Required attributes for user configuration
      requiredAttrs = [
        "username"
        "hostname"
        "email"
        "fullName"
        "githubUsername"
        "notificationEmail"
      ];
      missingAttrs = builtins.filter (attr: !(builtins.hasAttr attr userConfig)) requiredAttrs;

      # Enhanced user configuration with directory defaults
      # Default: .config/nix-install (matches bootstrap.sh default)
      enhancedUserConfig =
        let
          userDirectories = userConfig.directories or { };
        in
        userConfig
        // {
          directories = userDirectories // {
            dotfiles = userDirectories.dotfiles or ".config/nix-install";
          };
        };

      # Validate configuration
      validateConfig =
        config:
        let
          hostname = config.hostname or "";
          validFormat = builtins.match "[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*" hostname != null;
        in
        if builtins.length missingAttrs > 0 then
          throw "Missing required attributes in user-config.nix: ${builtins.toString missingAttrs}"
        else if hostname == "" || !validFormat then
          throw "Invalid hostname format: ${hostname}. Use only letters, numbers, and hyphens."
        else
          config;

      validatedConfig = validateConfig enhancedUserConfig;

      # Allow unfree packages (needed for many GUI apps)
      nixpkgsConfig.config.allowUnfree = true;

      # Common configuration modules shared by both profiles
      commonModules = [
        # Core System Configuration
        ./darwin/configuration.nix

        # Home Manager Integration
        home-manager.darwinModules.home-manager
        ({ profileName, ... }: {
          nixpkgs = nixpkgsConfig;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            extraSpecialArgs = {
              userConfig = validatedConfig;
              inherit profileName; # Pass profile name to home-manager modules
              inherit (validatedConfig)
                username
                fullName
                email
                githubUsername
                hostname
                ;
              inherit mcp-servers-nix; # Pass MCP servers flake to Home Manager
              # Shared bash snippet to find the nix-install repo root directory
              # Used by ghostty.nix, zed.nix, claude-code.nix activation scripts
              # Consistent search order: ~/.config/nix-install > ~/nix-install > ~/Documents/nix-install
              # Sets REPO_ROOT variable; empty string if not found
              findRepoRoot = homeDir: ''
                REPO_ROOT=""
                for candidate in "${homeDir}/.config/nix-install" \
                                 "${homeDir}/nix-install" \
                                 "${homeDir}/Documents/nix-install"; do
                  if [ -f "$candidate/flake.nix" ]; then
                    REPO_ROOT="$candidate"
                    break
                  fi
                done
              '';
            };
            users.${validatedConfig.username} = { lib, ... }: {
              imports = [ ./home-manager/home.nix ];
              home = {
                username = lib.mkForce validatedConfig.username;
                homeDirectory = lib.mkForce "/Users/${validatedConfig.username}";
                stateVersion = "23.11";
              };
              programs.home-manager.enable = true;
            };
          };
        })

        # Homebrew Management
        nix-homebrew.darwinModules.nix-homebrew
        ./darwin/homebrew.nix

        # System Preferences
        ./darwin/macos-defaults.nix

        # Theming with Stylix (Story 05.1-001, 05.2-001)
        # Stylix module must be loaded before our configuration
        stylix.darwinModules.stylix
        ./darwin/stylix.nix

        # Maintenance LaunchAgents (Epic-06: Features 06.1, 06.2)
        # Automated garbage collection and store optimization
        ./darwin/maintenance.nix

        # System-level Nix GC LaunchDaemon (Epic-08 Story 08.1-001)
        # Root-owned weekly prune of system profile generations — the user-level
        # nix-gc agent above cannot touch /nix/var/nix/profiles/system-*-link
        ./darwin/maintenance-system.nix

        # Health API Server (HTTP JSON endpoint on port 7780)
        # Accessible via Tailscale for remote health monitoring
        ./darwin/health-api.nix

        # Privacy Filter LaunchAgent (localhost-only PII redaction on port 7790)
        # MLX-backed OpenAI Privacy Filter port; daemon resident on all profiles.
        # Variant per profile: BF16 on Power, 8-bit on Standard / AI-Assistant.
        ./darwin/privacy-filter.nix

        # Beszel Monitoring Agent (system resource metrics on port 45876)
        # Ships CPU, memory, disk, network data to Beszel hub on Nyx
        ./darwin/monitoring.nix

        # Calibre ebook configuration (DeDRM, KFX plugins)
        # Deploys pre-configured plugins from config/calibre/
        ./darwin/calibre.nix
      ];

      # Helper function to create darwin configuration
      mkDarwinConfiguration =
        {
          system,
          isPowerProfile,
          profileName,
          modules,
        }:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            userConfig = validatedConfig;
            inherit
              nixpkgsConfig
              self
              isPowerProfile
              profileName
              system
              claude-code-nix
              mcp-servers-nix
              ;
          };
          modules = commonModules ++ modules;
        };
    in
    {
      # Standard Profile - MacBook Air
      # Minimal configuration: Core apps
      # Profile differentiation: modules can check `isPowerProfile` from specialArgs
      darwinConfigurations.standard = mkDarwinConfiguration {
        system = "aarch64-darwin"; # Apple Silicon (can also support x86_64-darwin)
        isPowerProfile = false;
        profileName = "standard";
        modules = [ ];
      };

      # Power Profile - MacBook Pro M3 Max
      # Full configuration: All apps, multiple Ollama models
      # Profile differentiation: modules can check `isPowerProfile` from specialArgs
      darwinConfigurations.power = mkDarwinConfiguration {
        system = "aarch64-darwin"; # Apple Silicon only
        isPowerProfile = true;
        profileName = "power";
        modules = [
          # SMB Automount for NAS shares (Power profile only)
          # On-demand mounting via autofs - mounts when accessed, unmounts when idle
          ./darwin/smb-automount.nix

          # rsync Backup to NAS (Power profile only)
          # Automated backup of configured folders to TerraMaster NAS
          ./darwin/rsync-backup.nix
        ];
      };

      # AI-Assistant Profile - Older MacBook for personal AI assistant
      # Lightweight: No containers, no LSPs, minimal GUI apps
      # Focus: Claude Code, terminal-centric workflow
      darwinConfigurations.ai-assistant = mkDarwinConfiguration {
        system = "aarch64-darwin"; # Apple Silicon
        isPowerProfile = false;
        profileName = "ai-assistant";
        modules = [ ];
      };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bats
              gitleaks
              jq
              nixfmt
              python3
              ripgrep
              shellcheck
            ];
          };
        }
      );
    };
}
