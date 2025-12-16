# ABOUTME: SMB automount configuration for NAS shares via autofs
# ABOUTME: Creates on-demand mounting - shares mount when accessed, unmount when idle
# ABOUTME: Credentials stored in macOS Keychain (not in config files)
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

  # Generate auto_smb entries for each share
  # Format: /Volumes/share -fstype=smbfs,soft,noowners,nosuid ://user@host/share
  autoSmbEntries = lib.concatMapStringsSep "\n" (share:
    "/Volumes/${share}\t-fstype=smbfs,soft,noowners,nosuid,rw\t://${nasConfig.username}@${nasConfig.host}/${share}"
  ) nasConfig.shares;

  # Generate synthetic.conf entries to create mount points
  # Format: dirname\tSystem/Volumes/Data/Volumes/dirname
  # This creates /dirname -> /System/Volumes/Data/Volumes/dirname symlinks
  syntheticEntries = lib.concatMapStringsSep "\n" (share:
    "${share}\tSystem/Volumes/Data/Volumes/${share}"
  ) nasConfig.shares;

in {
  # ===========================================================================
  # AUTOFS CONFIGURATION
  # ===========================================================================

  # /etc/auto_master - main autofs configuration
  # The /- entry with auto_smb uses direct map (mount points specified in auto_smb)
  environment.etc."auto_master".text = ''
    #
    # Automounter master map
    # Managed by nix-darwin - changes will be overwritten on rebuild
    #
    +auto_master		# Use directory service
    /home			auto_home	-nobrowse,hidefromfinder
    /Network/Servers	-fstab
    /-			-static
    /-			auto_smb	-nosuid,noowners
  '';

  # /etc/auto_smb - SMB share definitions
  # Credentials are looked up from macOS Keychain automatically
  environment.etc."auto_smb".text = ''
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
  '';

  # /etc/synthetic.conf - create mount point directories at root level
  # Required for macOS Catalina+ due to read-only system volume
  # Creates symlinks: /Volumes/share -> /System/Volumes/Data/Volumes/share
  # NOTE: Changes require reboot to take effect
  environment.etc."synthetic.conf".text = ''
    #
    # Synthetic filesystem entries
    # Managed by nix-darwin - changes will be overwritten on rebuild
    # NOTE: Reboot required for changes to take effect
    #
    # NAS mount points for autofs
    ${syntheticEntries}
  '';

  # ===========================================================================
  # ACTIVATION SCRIPTS
  # ===========================================================================

  system.activationScripts.postActivation.text = lib.mkAfter ''
    # ========================================================================
    # SMB AUTOMOUNT SETUP
    # ========================================================================
    echo "Configuring SMB automount..."

    # Create mount point directories in /System/Volumes/Data/Volumes
    # These are the actual directories that synthetic.conf symlinks point to
    ${lib.concatMapStringsSep "\n" (share: ''
    if [[ ! -d "/System/Volumes/Data/Volumes/${share}" ]]; then
      mkdir -p "/System/Volumes/Data/Volumes/${share}" 2>/dev/null || true
      echo "  Created mount point: /Volumes/${share}"
    fi
    '') nasConfig.shares}

    # Reload autofs to pick up new configuration
    echo "Reloading autofs..."
    if automount -cv 2>&1 | head -5; then
      echo "  autofs reloaded successfully"
    else
      echo "  Warning: automount -cv failed (may need reboot for synthetic.conf)"
    fi

    # Check if keychain credentials are configured
    echo "Checking Keychain credentials..."
    if security find-internet-password -s "${nasConfig.host}" -a "${nasConfig.username}" >/dev/null 2>&1; then
      echo "  Keychain credentials found for ${nasConfig.username}@${nasConfig.host}"
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
    echo "  Mount points: ${lib.concatStringsSep ", " (map (s: "/Volumes/${s}") nasConfig.shares)}"
    echo "  Note: First access after reboot triggers mount"
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
