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

    # macOS-specific SSH agent settings
    # AddKeysToAgent: Automatically add keys to ssh-agent on first use
    # UseKeychain: Store passphrases in macOS Keychain (macOS-specific)
    extraConfig = ''
      AddKeysToAgent yes
      UseKeychain yes
      IdentityFile ~/.ssh/id_ed25519
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

      # Generic SSH settings for all hosts
      "*" = {
        # Forward SSH agent (useful for GitHub operations through jump hosts)
        forwardAgent = false;  # Disabled by default for security
        # Server alive settings (keep connection alive)
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        # Security settings
        # Use only modern SSH key algorithms
        identitiesOnly = true;
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
