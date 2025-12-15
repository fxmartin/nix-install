# ABOUTME: iCloud sync LaunchAgent for work proposals
# ABOUTME: Mirrors proposals folder to iCloud Drive daily at 12:30 PM
# ABOUTME: Script installed to ~/.local/bin to avoid macOS TCC restrictions
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: let
  # Scripts directory (TCC-safe location)
  scriptsDir = "/Users/${userConfig.username}/.local/bin";
in {
  # ===========================================================================
  # ICLOUD SYNC SCRIPT INSTALLATION
  # ===========================================================================
  # Copy script to TCC-safe location during activation

  system.activationScripts.postActivation.text = lib.mkAfter ''
    # ========================================================================
    # ICLOUD SYNC SCRIPT INSTALLATION
    # ========================================================================
    ICLOUD_SCRIPT_SRC="/Users/${userConfig.username}/${userConfig.directories.dotfiles}/scripts/icloud-sync-proposals.sh"
    ICLOUD_SCRIPT_DST="${scriptsDir}/icloud-sync-proposals.sh"
    if [[ -f "$ICLOUD_SCRIPT_SRC" ]]; then
      cp "$ICLOUD_SCRIPT_SRC" "$ICLOUD_SCRIPT_DST"
      chmod 755 "$ICLOUD_SCRIPT_DST"
      chown ${userConfig.username}:staff "$ICLOUD_SCRIPT_DST"
      echo "✓ icloud-sync-proposals.sh installed to $ICLOUD_SCRIPT_DST"
    else
      echo "⚠ icloud-sync-proposals.sh not found at $ICLOUD_SCRIPT_SRC"
    fi
  '';

  # ===========================================================================
  # ICLOUD SYNC LAUNCHAGENT
  # ===========================================================================
  # Scheduled sync of work proposals to iCloud Drive
  # Runs daily at 12:30 PM (when Mac is likely awake)

  launchd.user.agents.icloud-sync-proposals = {
    serviceConfig = {
      # Command to execute the sync script
      ProgramArguments = [
        "/bin/bash"
        "-c"
        ''
          # Set up environment
          export PATH="/etc/profiles/per-user/${userConfig.username}/bin:/run/current-system/sw/bin:/usr/bin:/bin"
          export HOME="/Users/${userConfig.username}"

          # Run the iCloud sync script
          if [[ -x "${scriptsDir}/icloud-sync-proposals.sh" ]]; then
            "${scriptsDir}/icloud-sync-proposals.sh"
          else
            echo "ERROR: icloud-sync-proposals.sh not found at ${scriptsDir}/icloud-sync-proposals.sh"
            echo "Run 'rebuild' to install the script"
            exit 1
          fi
        ''
      ];

      # Schedule: Daily at 12:30 PM
      StartCalendarInterval = [
        {
          Hour = 12;
          Minute = 30;
        }
      ];

      # Logging configuration
      StandardOutPath = "/tmp/icloud-sync-proposals.log";
      StandardErrorPath = "/tmp/icloud-sync-proposals.err";

      # Environment variables
      EnvironmentVariables = {
        PATH = "/etc/profiles/per-user/${userConfig.username}/bin:/run/current-system/sw/bin:/usr/bin:/bin";
        HOME = "/Users/${userConfig.username}";
      };

      # Don't run on load, wait for scheduled time
      RunAtLoad = false;
      KeepAlive = false;
    };
  };
}
