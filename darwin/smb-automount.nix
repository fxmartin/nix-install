# ABOUTME: SMB automount configuration for NAS shares via autofs
# ABOUTME: Creates on-demand mounting - shares mount when accessed, unmount when idle
# ABOUTME: Password read from ~/.config/smb-nas/password at activation time
#
# IMPORTANT: This module does NOT touch /etc/synthetic.conf
# That file is managed by nix-darwin for the Nix store mount point.
# SMB mounts go directly to /Volumes/ which already exists on macOS.
#
# SETUP (one-time):
#   1. Create password file (not tracked in git):
#      mkdir -p ~/.config/smb-nas
#      echo "YOUR_NAS_PASSWORD" > ~/.config/smb-nas/password
#      chmod 600 ~/.config/smb-nas/password
#
#   2. Run rebuild to apply configuration
#
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: let
  # NAS configuration - centralized for easy modification
  nasConfig = {
    host = "192.168.68.58";      # NAS IP (use IP instead of hostname for reliability)
    hostname = "TNAS.local";     # mDNS hostname (backup)
    username = "fxmartin";       # SMB username
    shares = [
      "Photos"                   # Photo backup share
      "icloud"                   # iCloud Drive backup share
      "calibre"                  # Calibre ebook library backup share
    ];
  };

  # Password file location (not in git, user must create manually)
  passwordFile = "/Users/${userConfig.username}/.config/smb-nas/password";

in {
  # ===========================================================================
  # AUTOFS CONFIGURATION VIA ACTIVATION SCRIPT
  # ===========================================================================
  # We use activation scripts instead of environment.etc because:
  # 1. environment.etc tries to stat/chmod files before creating them
  # 2. This causes failures when files don't exist yet
  # 3. Activation scripts give us full control over file creation
  #
  # NOTE: We do NOT manage /etc/synthetic.conf here.
  # nix-darwin handles it automatically for the Nix store.
  # SMB mounts use /Volumes/ which is a standard macOS directory.
  #
  # Password is read from ${passwordFile} and embedded in auto_smb
  # (URL-encoded). The auto_smb file is chmod 600 (root-only readable).

  system.activationScripts.postActivation.text = lib.mkAfter ''
    # ========================================================================
    # SMB AUTOMOUNT CONFIGURATION
    # ========================================================================
    echo "Configuring SMB automount for NAS shares..."

    # --- /etc/auto_master ---
    # Uses direct map (/-) so auto_smb can specify full mount paths
    echo "  Writing /etc/auto_master..."
    cat > /etc/auto_master << 'AUTO_MASTER_EOF'
#
# Automounter master map
# Managed by nix-darwin - changes will be overwritten on rebuild
#
+auto_master		# Use directory service
/home			auto_home	-nobrowse,hidefromfinder
/Network/Servers	-fstab
/-			-static
/-			auto_smb	-nosuid,nodev
AUTO_MASTER_EOF
    chmod 644 /etc/auto_master

    # --- Read password and generate /etc/auto_smb ---
    PASSWORD_FILE="${passwordFile}"
    if [[ -f "$PASSWORD_FILE" ]]; then
      # Read password and URL-encode special characters
      RAW_PASSWORD=$(cat "$PASSWORD_FILE" | tr -d '\n')
      # URL-encode: @ → %40, : → %3A, / → %2F, # → %23, ? → %3F, & → %26
      ENCODED_PASSWORD=$(echo "$RAW_PASSWORD" | sed -e 's/@/%40/g' -e 's/:/%3A/g' -e 's/\//%2F/g' -e 's/#/%23/g' -e 's/?/%3F/g' -e 's/&/%26/g')

      echo "  Writing /etc/auto_smb (with credentials)..."
      cat > /etc/auto_smb << AUTO_SMB_EOF
#
# SMB automount configuration for NAS shares
# Managed by nix-darwin - changes will be overwritten on rebuild
# Password from: $PASSWORD_FILE
#
${lib.concatMapStringsSep "\n" (share:
  "/Volumes/${share}\t-fstype=smbfs,soft,nodev,nosuid\t://${nasConfig.username}:\$ENCODED_PASSWORD@${nasConfig.host}/${share}"
) nasConfig.shares}
AUTO_SMB_EOF
      chmod 600 /etc/auto_smb
      echo "  auto_smb configured with credentials (chmod 600)"
    else
      echo ""
      echo "  WARNING: Password file not found: $PASSWORD_FILE"
      echo "  SMB automount will NOT work without credentials."
      echo ""
      echo "  Create the password file (one-time setup):"
      echo "    mkdir -p ~/.config/smb-nas"
      echo "    echo 'YOUR_NAS_PASSWORD' > ~/.config/smb-nas/password"
      echo "    chmod 600 ~/.config/smb-nas/password"
      echo ""

      # Write auto_smb without password (won't work but shows config)
      cat > /etc/auto_smb << 'AUTO_SMB_EOF'
#
# SMB automount configuration for NAS shares
# WARNING: No password configured - mounts will fail!
# Create ~/.config/smb-nas/password and run rebuild
#
${lib.concatMapStringsSep "\n" (share:
  "/Volumes/${share}\t-fstype=smbfs,soft,nodev,nosuid\t://${nasConfig.username}@${nasConfig.host}/${share}"
) nasConfig.shares}
AUTO_SMB_EOF
      chmod 644 /etc/auto_smb
    fi

    # --- Reload autofs ---
    echo "  Reloading autofs..."
    if automount -vc 2>&1 | grep -v "^$" | head -5; then
      echo "  autofs reloaded successfully"
    else
      echo "  Note: autofs reload completed (may need first access to trigger mount)"
    fi

    echo "SMB automount configuration complete"
    echo "  Shares: ${lib.concatStringsSep ", " (map (s: "/Volumes/${s}") nasConfig.shares)}"
    echo "  Test with: ls /Volumes/Photos"
  '';

  # ===========================================================================
  # ASSERTIONS
  # ===========================================================================

  assertions = [
    {
      assertion = builtins.length nasConfig.shares > 0;
      message = "At least one SMB share must be configured in smb-automount.nix";
    }
  ];
}
