# ABOUTME: Main Nix flake defining system configurations for Standard and Power profiles
# ABOUTME: Integrates nixpkgs, nix-darwin, home-manager, nix-homebrew, and stylix
{
  description = "Nix-darwin configuration for FX's MacBooks - Standard, Power, and AI-Assistant profiles (v1.0.0)";

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

  outputs = {
    self,
    darwin,
    nixpkgs,
    home-manager,
    nix-homebrew,
    stylix,
    claude-code-nix,
    mcp-servers-nix,
    ...
  }: let
    # User configuration validation
    userConfig =
      if builtins.pathExists ./user-config.nix
      then import ./user-config.nix
      else throw "user-config.nix not found. Run bootstrap.sh first or create from user-config.template.nix";

    # Required attributes for user configuration
    requiredAttrs = [
      "username"
      "hostname"
      "email"
      "fullName"
      "githubUsername"
    ];
    missingAttrs = builtins.filter (attr: !(builtins.hasAttr attr userConfig)) requiredAttrs;

    # Enhanced user configuration with directory defaults
    # Default: .config/nix-install (matches bootstrap.sh default)
    enhancedUserConfig = let
      userDirectories = userConfig.directories or {};
    in userConfig // {
      directories = userDirectories // {
        dotfiles = userDirectories.dotfiles or ".config/nix-install";
      };
    };

    # Validate configuration
    validateConfig = config: let
      hostname = config.hostname or "";
      validFormat = builtins.match "[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*" hostname != null;
    in
      if builtins.length missingAttrs > 0
      then throw "Missing required attributes in user-config.nix: ${builtins.toString missingAttrs}"
      else if hostname == "" || !validFormat
      then throw "Invalid hostname format: ${hostname}. Use only letters, numbers, and hyphens."
      else config;

    validatedConfig = validateConfig enhancedUserConfig;

    # Allow unfree packages (needed for many GUI apps)
    nixpkgsConfig.config.allowUnfree = true;

    # Ollama model definitions — single source of truth for both profiles
    # Standard models are included in Power profile via ollamaModels.power
    ollamaModels = {
      standard = [
        { name = "ministral-3:14b"; desc = "Mistral multilingual reasoning model"; size = "~9GB"; }
        { name = "nomic-embed-text"; desc = "Text embeddings model"; size = "~274MB"; }
      ];
      power = [
        { name = "gemma4:e4b"; desc = "Google Gemma 4 compact 4B coding/chat model"; size = "~3GB"; }
        { name = "gemma4:26b"; desc = "Google Gemma 4 large 26B reasoning model"; size = "~16GB"; }
        { name = "nomic-embed-text"; desc = "Text embeddings model"; size = "~274MB"; }
      ];
      ai-assistant = [
        { name = "nomic-embed-text"; desc = "Text embeddings model for RAG/search"; size = "~274MB"; }
      ];
    };

    # Generate Ollama model pull activation script for a given profile
    mkOllamaModelScript = profileName: models: let
      modelCount = builtins.length models;
      modelNames = builtins.map (m: m.name) models;
      totalSize = builtins.concatStringsSep ", " (builtins.map (m: "${m.name} (${m.size})") models);
    in ''
      # Check if Ollama CLI is available (installed by Homebrew)
      if [ -x /opt/homebrew/bin/ollama ]; then
        echo "Checking Ollama models for ${profileName} profile..."

        # Check if Ollama daemon is running, start if needed
        if ! pgrep -q ollama; then
          echo "Starting Ollama daemon..."
          /opt/homebrew/bin/ollama serve > /dev/null 2>&1 &

          # Wait for daemon to be ready (up to 10 seconds)
          for _ in {1..10}; do
            if /opt/homebrew/bin/ollama list > /dev/null 2>&1; then
              echo "✓ Ollama daemon ready"
              break
            fi
            sleep 1
          done
        fi

        # Define models to pull (${toString modelCount} models: ${totalSize})
        MODELS=(
          ${builtins.concatStringsSep "\n          " (builtins.map (m: ''"${m.name}"  # ${m.size} - ${m.desc}'') models)}
        )

        # Pull each model sequentially with progress tracking
        for model in "''${MODELS[@]}"; do
          # Check if model already exists (idempotent)
          if ! /opt/homebrew/bin/ollama list 2>/dev/null | grep -q "$model"; then
            echo "Pulling Ollama model: $model (this may take several minutes)..."

            # Pull model (requires network and running daemon)
            if /opt/homebrew/bin/ollama pull "$model" 2>&1; then
              echo "✓ Successfully pulled Ollama model: $model"
            else
              echo "⚠️  Warning: Failed to pull Ollama model $model"
              echo "   This may be due to network issues or Ollama daemon not starting."
              echo "   You can manually pull the model later with: ollama pull $model"
            fi
          else
            echo "✓ Ollama model $model already installed"
          fi
        done

        echo "✓ Ollama model check complete for ${profileName} profile"
      else
        echo "⚠️  Warning: Ollama CLI not found at /opt/homebrew/bin/ollama"
        echo "   Model pull will be skipped. Install Ollama first."
      fi
    '';

    # Common configuration modules shared by both profiles
    commonModules = [
      # Core System Configuration
      ./darwin/configuration.nix

      # Home Manager Integration
      home-manager.darwinModules.home-manager
      ({profileName, ...}: {
        nixpkgs = nixpkgsConfig;
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-backup";
          extraSpecialArgs = {
            userConfig = validatedConfig;
            inherit profileName;  # Pass profile name to home-manager modules
            inherit
              (validatedConfig)
              username
              fullName
              email
              githubUsername
              hostname
              ;
            inherit mcp-servers-nix;  # Pass MCP servers flake to Home Manager
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
          users.${validatedConfig.username} = {lib, ...}: {
            imports = [./home-manager/home.nix];
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

      # Beszel Monitoring Agent (system resource metrics on port 45876)
      # Ships CPU, memory, disk, network data to Beszel hub on Nyx
      ./darwin/monitoring.nix

      # Calibre ebook configuration (DeDRM, KFX plugins)
      # Deploys pre-configured plugins from config/calibre/
      ./darwin/calibre.nix
    ];

    # Helper function to create darwin configuration
    mkDarwinConfiguration = {
      system,
      isPowerProfile,
      profileName,
      modules,
    }:
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          userConfig = validatedConfig;
          inherit nixpkgsConfig self isPowerProfile profileName system claude-code-nix mcp-servers-nix;
        };
        modules = commonModules ++ modules;
      };
  in {
    # Standard Profile - MacBook Air
    # Minimal configuration: Core apps, single Ollama model
    # Profile differentiation: modules can check `isPowerProfile` from specialArgs
    darwinConfigurations.standard = mkDarwinConfiguration {
      system = "aarch64-darwin"; # Apple Silicon (can also support x86_64-darwin)
      isPowerProfile = false;
      profileName = "standard";
      modules = [
        ({lib, ...}: {
          # Standard profile specific settings
          # - Ollama models: defined in ollamaModels.standard

          # Story 02.1-003: Automatically pull Ollama models for Standard profile
          # Use postActivation - one of the hardcoded script names that nix-darwin actually runs
          # See: https://github.com/nix-darwin/nix-darwin/issues/663
          system.activationScripts.postActivation.text = lib.mkAfter (
            mkOllamaModelScript "Standard" ollamaModels.standard
          );
        })
      ];
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

        # iCloud Sync for Work Proposals (Power profile only)
        # Mirrors proposals folder to iCloud Drive daily at 12:30 PM
        ./darwin/icloud-sync.nix

        ({lib, ...}: {
          # Power profile specific settings
          # - Ollama models: defined in ollamaModels.power

          # Story 02.1-004: Automatically pull Ollama models for Power profile
          # Use postActivation - one of the hardcoded script names that nix-darwin actually runs
          # See: https://github.com/nix-darwin/nix-darwin/issues/663
          system.activationScripts.postActivation.text = lib.mkAfter (
            mkOllamaModelScript "Power" ollamaModels.power
          );
        })
      ];
    };

    # AI-Assistant Profile - Older MacBook for personal AI assistant
    # Lightweight: No containers, no LSPs, minimal GUI apps
    # Focus: Claude Code, Ollama embeddings, terminal-centric workflow
    darwinConfigurations.ai-assistant = mkDarwinConfiguration {
      system = "aarch64-darwin"; # Apple Silicon
      isPowerProfile = false;
      profileName = "ai-assistant";
      modules = [
        ({lib, ...}: {
          # AI-Assistant profile: embeddings-only Ollama model
          system.activationScripts.postActivation.text = lib.mkAfter (
            mkOllamaModelScript "AI-Assistant" ollamaModels.ai-assistant
          );
        })
      ];
    };

    # Formatter for nix files
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixfmt-rfc-style;
  };
}
