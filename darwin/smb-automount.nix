# ABOUTME: SMB automount configuration for NAS shares via autofs
# ABOUTME: Creates on-demand mounting - shares mount when accessed, unmount when idle
# ABOUTME: Credentials stored in macOS Keychain (not in config files)
#
# IMPORTANT: This module does NOT touch /etc/synthetic.conf
# That file is managed by nix-darwin for the Nix store mount point.
# SMB mounts go directly to /Volumes/ which already exists on macOS.
#
# SETUP: Run once after first rebuild to store credentials in Keychain:
#   security add-internet-password -a "USERNAME" -s "NAS_HOST" -D "network password" \
#     -r "smb " -w "YOUR_PASSWORD" -U -T ""
#
# Example for this config:
#   security add-internet-password -a "fxmartin" -s "192.168.68.58" -D "network password" \
#     -r "smb " -w "YOUR_NAS_PASSWORD" -U -T ""
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
    ];
  };

  # Generate auto_smb entries for each share (direct map format)
  # Format: /Volumes/share<TAB>options<TAB>://user@host/share
  # Using direct map (/-) means we specify full mount paths here
  autoSmbEntries = lib.concatMapStringsSep "\n" (share:
    "/Volumes/${share}\t-fstype=smbfs,soft,nodev,nosuid\t://${nasConfig.username}@${nasConfig.host}/${share}"
  ) nasConfig.shares;

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

    # --- /etc/auto_smb ---
    # Direct map format: full paths to mount points
    echo "  Writing /etc/auto_smb..."
    cat > /etc/auto_smb << 'AUTO_SMB_EOF'
#
# SMB automount configuration for NAS shares
# Managed by nix-darwin - changes will be overwritten on rebuild
#
# NAS: ${nasConfig.host} (${nasConfig.hostname})
# User: ${nasConfig.username}
# Shares: ${lib.concatStringsSep ", " nasConfig.shares}
#
# Credentials are stored in macOS Keychain (not in this file)
# To add/update credentials:
#   security add-internet-password -a "${nasConfig.username}" -s "${nasConfig.host}" \
#     -D "network password" -r "smb " -w "YOUR_PASSWORD" -U -T ""
#
${autoSmbEntries}
AUTO_SMB_EOF
    chmod 644 /etc/auto_smb

    # --- Reload autofs ---
    echo "  Reloading autofs..."
    if automount -vc 2>&1 | grep -v "^$" | head -5; then
      echo "  autofs reloaded successfully"
    else
      echo "  Note: autofs reload completed (may need first access to trigger mount)"
    fi

    # --- Check keychain credentials ---
    echo "  Checking Keychain credentials..."
    if security find-internet-password -s "${nasConfig.host}" -a "${nasConfig.username}" >/dev/null 2>&1; then
      echo "  Keychain: credentials found for ${nasConfig.username}@${nasConfig.host}"
    else
      echo ""
      echo "  WARNING: No Keychain credentials found for NAS!"
      echo "  Run this command to add credentials (one-time setup):"
      echo ""
      echo "    security add-internet-password -a \"${nasConfig.username}\" -s \"${nasConfig.host}\" \\"
      echo "      -D \"network password\" -r \"smb \" -w \"YOUR_NAS_PASSWORD\" -U -T \"\""
      echo ""
    fi

    echo "SMB automount configuration complete"
    echo "  Shares: ${lib.concatStringsSep ", " (map (s: "/Volumes/${s}") nasConfig.shares)}"
    echo "  Access shares to trigger mount: ls /Volumes/Photos"
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
