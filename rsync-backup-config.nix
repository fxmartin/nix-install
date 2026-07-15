# ABOUTME: Backup job definitions for TerraMaster NAS
# ABOUTME: Configure rsync backup jobs - edit this file to add/remove backup sources
# ABOUTME: Changes take effect after running 'rebuild'
{
  # NAS connection settings
  # Using mDNS hostname - if overnight backups fail, may need static IP
  nasHost = "tnas.local"; # NAS hostname (mDNS)
  defaultShare = "Photos"; # Default share if job doesn't specify one

  # ==========================================================================
  # RSYNC DAEMON MODE (Recommended - much faster than SMB)
  # ==========================================================================
  # Uses native rsync protocol (port 873) instead of SMB mount
  # Benefits: checksum on server, no SMB overhead, 2-5x faster
  useRsyncDaemon = true;
  rsyncUsername = "rsync-user";
  # Password file path (created manually, chmod 600)
  # Contains just the password, no username
  rsyncPasswordFile = "~/.config/rsync-backup/rsync.secret";

  # Default schedule: Daily at 2 AM
  # Uses launchd StartCalendarInterval format
  defaultSchedule = {
    Hour = 2;
    Minute = 0;
  };

  # Weekly jobs start later so the daily Calibre job cannot overlap them.
  weeklySchedule = {
    Hour = 3;
    Minute = 0;
  };

  # Bound transient network retries and iCloud placeholder materialization.
  maxRetries = 3;
  retryDelaySeconds = 60;
  icloudDownloadTimeoutSeconds = 300;
  icloudDownloadPollSeconds = 5;

  # Email notifications via msmtp
  notifyOnFailure = true;

  # Username for SMB mount (fallback if rsync daemon disabled)
  smbUsername = "fxmartin";

  # Backup jobs - add/remove as needed
  # Each job syncs a source folder to a destination on the NAS
  # Archive mode: deleted files on Mac are kept on NAS
  # Each job can specify its own 'share' or use defaultShare
  # Jobs choose the daily schedule or the weekly schedule and weekday.
  # Schedule options: "daily" (default), "weekly" (Sunday 3 AM by default)
  jobs = [
    {
      # Photos exported as plain browsable files (via osxphotos)
      # osxphotos automatically runs before rsync when this job is detected
      name = "photos";
      source = "Pictures/Photos-Export"; # osxphotos exports here
      share = "Photos"; # NAS share to use
      destination = ""; # Root of share
      schedule = "weekly"; # Run weekly (Sunday 3 AM)
      excludes = [
        ".DS_Store"
        ".osxphotos_export.db" # osxphotos tracking database
      ];
    }
    {
      # iCloud Drive backup - entire iCloud folder to NAS
      name = "icloud";
      source = "Library/Mobile Documents/com~apple~CloudDocs";
      share = "icloud"; # Separate NAS share
      destination = ""; # Root of share
      schedule = "weekly"; # Run weekly
      weekday = 3; # Wednesday (0=Sun, 1=Mon, ..., 6=Sat)
      excludes = [
        ".DS_Store"
        "*.icloud" # Placeholder files for not-downloaded content
        ".Trash"
        "~$*.docx" # Office temp files
        "~$*.xlsx"
        "~$*.pptx"
        "*.tmp"
        ".~lock.*"
      ];
    }
    {
      # Calibre ebook library backup - stored in iCloud Drive
      name = "calibre";
      source = "Library/Mobile Documents/com~apple~CloudDocs/Documents/02. Library/Calibre Library";
      share = "calibre"; # Dedicated NAS share for ebook library
      destination = ""; # Root of share
      schedule = "daily"; # Run daily at 2 AM
      excludes = [
        ".DS_Store"
        "*.lock" # Calibre lock files during operation
        ".calnotes" # Calibre internal cache
        "*.tmp" # Temporary files
        ".#*" # Editor swap files
      ];
    }
  ];
}
