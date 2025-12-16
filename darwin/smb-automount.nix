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
  autoSmbEntries = lib.concatMapStringsSep "\\n" (share:
    "/Volumes/${share}\\t-fstype=smbfs,soft,noowners,nosuid,rw\\t://${nasConfig.username}@${nasConfig.host}/${share}"
  ) nasConfig.shares;

  # Generate synthetic.conf entries to create mount points
  # Format: dirname\tSystem/Volumes/Data/Volumes/dirname
  syntheticEntries = lib.concatMapStringsSep "\\n" (share:
    "${share}\\tSystem/Volumes/Data/Volumes/${share}"
  ) nasConfig.shares;

in {
  # ===========================================================================
  # AUTOFS CONFIGURATION VIA ACTIVATION SCRIPT
  # ===========================================================================
  # We use activation scripts instead of environment.etc because:
  # 1. environment.etc tries to stat/chmod files before creating them
  # 2. This causes failures when files don't exist yet
  # 3. Activation scripts give us full control over file creation

  system.activationScripts.postActivation.text = lib.mkAfter ''
    # ========================================================================
    # SMB AUTOMOUNT CONFIGURATION
    # ========================================================================
    echo "Configuring SMB automount for NAS shares..."

    # --- /etc/auto_master ---
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
/-			auto_smb	-nosuid,noowners
AUTO_MASTER_EOF
    chmod 644 /etc/auto_master

    # --- /etc/auto_smb ---
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

    # --- /etc/synthetic.conf ---
    # Only update if content is different (requires reboot to take effect)
    SYNTHETIC_CONTENT="#
# Synthetic filesystem entries
# Managed by nix-darwin - changes will be overwritten on rebuild
# NOTE: Reboot required for changes to take effect
#
# NAS mount points for autofs
${syntheticEntries}"

    if [[ ! -f /etc/synthetic.conf ]] || [[ "$(cat /etc/synthetic.conf 2>/dev/null)" != "$SYNTHETIC_CONTENT" ]]; then
      echo "  Writing /etc/synthetic.conf..."
      echo "$SYNTHETIC_CONTENT" > /etc/synthetic.conf
      chmod 644 /etc/synthetic.conf
      echo "  NOTE: Reboot required for synthetic.conf changes to take effect"
    else
      echo "  /etc/synthetic.conf unchanged"
    fi

    # --- Create mount point directories ---
    echo "  Creating mount point directories..."
    ${lib.concatMapStringsSep "\n" (share: ''
    if [[ ! -d "/System/Volumes/Data/Volumes/${share}" ]]; then
      mkdir -p "/System/Volumes/Data/Volumes/${share}" 2>/dev/null || true
      echo "    Created: /Volumes/${share}"
    fi
    '') nasConfig.shares}

    # --- Reload autofs ---
    echo "  Reloading autofs..."
    if automount -cv 2>&1 | grep -v "^$" | head -3; then
      echo "  autofs reloaded"
    else
      echo "  Warning: automount reload may require reboot"
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
