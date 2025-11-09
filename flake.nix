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
  };

  outputs = {
    self,
    darwin,
    nixpkgs,
    home-manager,
    nix-homebrew,
    stylix,
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
          inherit nixpkgsConfig self isPowerProfile;
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
        }
      ];
    };

    # Formatter for nix files
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixfmt-rfc-style;
  };
}
