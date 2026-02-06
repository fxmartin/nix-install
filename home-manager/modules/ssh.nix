# ABOUTME: SSH configuration via Home Manager programs.ssh module
# ABOUTME: Provides declarative SSH configuration for GitHub authentication with macOS Keychain integration

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # SSH Configuration (Story 04.6-003)
  # Configures SSH for GitHub authentication with macOS Keychain integration
  # SSH key generated in Epic-01 bootstrap Phase 6 (Story 01.6-002)
  #
  # Why this approach:
  # - Declarative SSH config via Home Manager
  # - macOS Keychain integration for automatic key management
  # - GitHub-specific settings for seamless authentication
  # - Password-less SSH authentication for git operations
  #
  # Configuration includes:
  # - GitHub host settings (github.com)
  # - SSH key identity file (~/.ssh/id_ed25519)
  # - macOS Keychain integration (AddKeysToAgent, UseKeychain)
  # - SSH agent settings for persistent authentication

  programs.ssh = {
    enable = true;

    # Disable Home Manager's default config - we define everything explicitly
    # This prevents deprecated default values warnings
    enableDefaultConfig = false;

    # macOS-specific SSH agent settings via extraConfig
    # UseKeychain: Store passphrases in macOS Keychain (macOS-specific, not a Home Manager option)
    extraConfig = ''
      UseKeychain yes
    '';

    # Host-specific SSH configurations
    matchBlocks = {
      # GitHub.com configuration
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        # Persist connection for faster subsequent operations
        controlMaster = "auto";
        controlPath = "~/.ssh/control-%r@%h:%p";
        controlPersist = "600";
      };

      # NAS Luxembourg (TerraMaster) - Local network
      "nas-lux" = {
        hostname = "tnas.local";
        user = "fxmartin";
        port = 2222;
        identityFile = "~/.ssh/id_nas_luxembourg";
      };

      # NAS Luxembourg via Tailscale (accessible from anywhere)
      "nas.ts" = {
        hostname = "100.98.9.111";  # Tailscale IP
        user = "fxmartin";
        port = 2222;
        identityFile = "~/.ssh/id_nas_luxembourg";
      };

      # Dev Server via Tailscale
      "dev.ts" = {
        hostname = "100.92.56.127";  # Tailscale IP
        user = "fxmartin";
        identityFile = "~/.ssh/id_ed25519";
      };

      # Dev Server via Public IP (Hetzner)
      "dev" = {
        hostname = "46.224.44.190";  # Hetzner public IP
        user = "fxmartin";
        identityFile = "~/.ssh/id_ed25519";
      };

      # Nyx server via Tailscale
      "nyx" = {
        hostname = "100.115.38.12";  # Tailscale IP
        user = "fx";
        identityFile = "~/.ssh/id_nyx";
      };

      # Nyx server root access
      "nyx-root" = {
        hostname = "100.115.38.12";
        user = "root";
        identityFile = "~/.ssh/id_nyx";
      };

      # Nyx DR server via Tailscale
      "nyx-dr" = {
        hostname = "100.112.184.36";
        user = "fx";
        identityFile = "~/.ssh/id_nyx-dr";
      };

      # Nyx DR root access
      "nyx-dr-root" = {
        hostname = "100.112.184.36";
        user = "root";
        identityFile = "~/.ssh/id_nyx-dr";
      };

      # Generic SSH settings for all hosts
      "*" = {
        # Add keys to SSH agent automatically (moved from deprecated top-level option)
        addKeysToAgent = "yes";
        # Forward SSH agent (disabled for security)
        forwardAgent = false;
        # Server alive settings (keep connection alive)
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        # Security settings - use only specified identity files
        identitiesOnly = true;
        # Default identity file
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  # Post-installation verification message
  # This runs after Home Manager activation
  home.activation.sshConfigVerify = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v ssh > /dev/null 2>&1; then
      echo ""
      echo "✓ SSH configuration applied:"
      echo "  - Config file: ~/.ssh/config"
      echo "  - GitHub host: github.com"
      echo "  - Identity file: ~/.ssh/id_ed25519"
      echo "  - macOS Keychain: Enabled"
      echo "  - SSH agent: AddKeysToAgent enabled"
      echo ""
      echo "Verify configuration:"
      echo "  → cat ~/.ssh/config"
      echo "  → ssh -T git@github.com"
      echo "  → ssh-add -l (list loaded keys)"
      echo ""
      echo "First-time key loading:"
      echo "  → ssh-add --apple-use-keychain ~/.ssh/id_ed25519"
      echo "  (This adds key to macOS Keychain for persistent authentication)"
      echo ""
    fi
  '';
}
