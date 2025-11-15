# ABOUTME: Main Nix flake defining system configurations for Standard and Power profiles
# ABOUTME: Integrates nixpkgs, nix-darwin, home-manager, nix-homebrew, and stylix
{
  description = "Nix-darwin configuration for FX's MacBooks - Standard and Power profiles";

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
    enhancedUserConfig = userConfig // {
      directories = (userConfig.directories or {}) // {
        dotfiles = userConfig.directories.dotfiles or "dev/nix-install";
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

    # Common configuration modules shared by both profiles
    commonModules = [
      # Core System Configuration
      ./darwin/configuration.nix

      # Home Manager Integration
      home-manager.darwinModules.home-manager
      {
        nixpkgs = nixpkgsConfig;
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-backup";
          extraSpecialArgs = {
            userConfig = validatedConfig;
            inherit
              (validatedConfig)
              username
              fullName
              email
              githubUsername
              hostname
              ;
            inherit mcp-servers-nix;  # Pass MCP servers flake to Home Manager
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
      }

      # Homebrew Management
      nix-homebrew.darwinModules.nix-homebrew
      ./darwin/homebrew.nix

      # System Preferences
      ./darwin/macos-defaults.nix

      # Theming with Stylix
      stylix.darwinModules.stylix
    ];

    # Helper function to create darwin configuration
    mkDarwinConfiguration = {
      system,
      isPowerProfile,
      modules,
    }:
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          userConfig = validatedConfig;
          inherit nixpkgsConfig self isPowerProfile system claude-code-nix mcp-servers-nix;
        };
        modules = commonModules ++ modules;
      };
  in {
    # Standard Profile - MacBook Air
    # Minimal configuration: Core apps, no Parallels, single Ollama model
    # Profile differentiation: modules can check `isPowerProfile` from specialArgs
    darwinConfigurations.standard = mkDarwinConfiguration {
      system = "aarch64-darwin"; # Apple Silicon (can also support x86_64-darwin)
      isPowerProfile = false;
      modules = [
        {
          # Standard profile specific settings (to be expanded in Epic-02)
          # - No Parallels Desktop (isPowerProfile = false)
          # - Minimal app set
          # - Single Ollama model (gpt-oss:20b)

          # Story 02.1-003: Automatically pull gpt-oss:20b Ollama model
          system.activationScripts.pullOllamaModel.text = ''
            # Check if Ollama CLI is available (installed by Homebrew)
            if [ -x /opt/homebrew/bin/ollama ]; then
              echo "Checking Ollama model: gpt-oss:20b..."

              # Check if model already exists (idempotent)
              if ! /opt/homebrew/bin/ollama list 2>/dev/null | grep -q "gpt-oss:20b"; then
                echo "Pulling Ollama model: gpt-oss:20b (~12GB, this may take several minutes)..."

                # Check if Ollama daemon is running, start if needed
                DAEMON_STARTED=0
                if ! pgrep -q ollama; then
                  echo "Starting Ollama daemon..."
                  /opt/homebrew/bin/ollama serve > /dev/null 2>&1 &
                  DAEMON_STARTED=1

                  # Wait for daemon to be ready (up to 10 seconds)
                  for i in {1..10}; do
                    if /opt/homebrew/bin/ollama list > /dev/null 2>&1; then
                      echo "✓ Ollama daemon ready"
                      break
                    fi
                    sleep 1
                  done
                fi

                # Pull model (requires network and running daemon)
                if /opt/homebrew/bin/ollama pull gpt-oss:20b 2>&1; then
                  echo "✓ Successfully pulled Ollama model: gpt-oss:20b"
                else
                  echo "⚠️  Warning: Failed to pull Ollama model gpt-oss:20b"
                  echo "   This may be due to network issues or Ollama daemon not starting."
                  echo "   You can manually pull the model later with: ollama pull gpt-oss:20b"
                fi
              else
                echo "✓ Ollama model gpt-oss:20b already installed"
              fi
            else
              echo "⚠️  Warning: Ollama CLI not found at /opt/homebrew/bin/ollama"
              echo "   Model pull will be skipped. Install Ollama first."
            fi
          '';
        }
      ];
    };

    # Power Profile - MacBook Pro M3 Max
    # Full configuration: All apps, Parallels enabled, multiple Ollama models
    # Profile differentiation: modules can check `isPowerProfile` from specialArgs
    darwinConfigurations.power = mkDarwinConfiguration {
      system = "aarch64-darwin"; # Apple Silicon only
      isPowerProfile = true;
      modules = [
        {
          # Power profile specific settings (to be expanded in Epic-02)
          # - Parallels Desktop enabled (isPowerProfile = true)
          # - Full app set
          # - Multiple Ollama models (gpt-oss:20b, qwen2.5-coder:32b, llama3.1:70b, deepseek-r1:32b)

          # Story 02.1-004: Automatically pull 4 Ollama models for Power profile
          system.activationScripts.pullOllamaModels.text = ''
            # Check if Ollama CLI is available (installed by Homebrew)
            if [ -x /opt/homebrew/bin/ollama ]; then
              echo "Checking Ollama models for Power profile..."

              # Check if Ollama daemon is running, start if needed
              DAEMON_STARTED=0
              if ! pgrep -q ollama; then
                echo "Starting Ollama daemon..."
                /opt/homebrew/bin/ollama serve > /dev/null 2>&1 &
                DAEMON_STARTED=1

                # Wait for daemon to be ready (up to 10 seconds)
                for i in {1..10}; do
                  if /opt/homebrew/bin/ollama list > /dev/null 2>&1; then
                    echo "✓ Ollama daemon ready"
                    break
                  fi
                  sleep 1
                done
              fi

              # Define models to pull (4 models, ~90GB total)
              MODELS=(
                "gpt-oss:20b"          # ~12GB - General purpose LLM
                "qwen2.5-coder:32b"    # ~20GB - Code-specialized LLM
                "llama3.1:70b"         # ~40GB - Large general LLM
                "deepseek-r1:32b"      # ~18GB - Reasoning-focused LLM
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

              echo "✓ Ollama model check complete for Power profile"
            else
              echo "⚠️  Warning: Ollama CLI not found at /opt/homebrew/bin/ollama"
              echo "   Model pull will be skipped. Install Ollama first."
            fi
          '';
        }
      ];
    };

    # Formatter for nix files
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixfmt-rfc-style;
  };
}
