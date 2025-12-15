# ABOUTME: Backup job definitions for TerraMaster NAS
# ABOUTME: Configure rsync backup jobs - edit this file to add/remove backup sources
# ABOUTME: Changes take effect after running 'rebuild'
{
  # NAS connection settings
  # Using IP address instead of TNAS.local for reliable overnight backups
  # (mDNS/Bonjour may not resolve when Mac wakes from sleep at 2 AM)
  nasHost = "192.168.68.58";  # nas-lux (local network)
  defaultShare = "Photos";    # Default share if job doesn't specify one

  # Schedule: Daily at 2 AM
  # Uses launchd StartCalendarInterval format
  schedule = {
    Hour = 2;
    Minute = 0;
  };

  # Email notifications via msmtp
  notifyOnFailure = true;

  # Username for SMB mount (uses macOS Keychain for password)
  smbUsername = "fxmartin";

  # Backup jobs - add/remove as needed
  # Each job syncs a source folder to a destination on the NAS
  # Archive mode: deleted files on Mac are kept on NAS
  # Each job can specify its own 'share' or use defaultShare
  jobs = [
    {
      # Photos exported as plain browsable files (via osxphotos)
      # osxphotos automatically runs before rsync when this job is detected
      name = "photos";
      source = "Pictures/Photos-Export";  # osxphotos exports here
      share = "Photos";                   # NAS share to use
      destination = "";                   # Root of share
      excludes = [
        ".DS_Store"
        ".osxphotos_export.db"  # osxphotos tracking database
      ];
    }
    {
      # iCloud Drive backup - entire iCloud folder to NAS
      name = "icloud";
      source = "Library/Mobile Documents/com~apple~CloudDocs";
      share = "icloud";                   # Separate NAS share
      destination = "";                   # Root of share
      excludes = [
        ".DS_Store"
        "*.icloud"           # Placeholder files for not-downloaded content
        ".Trash"
        "~$*.docx"           # Office temp files
        "~$*.xlsx"
        "~$*.pptx"
        "*.tmp"
        ".~lock.*"
      ];
    }
  ];
}
