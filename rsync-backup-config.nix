# ABOUTME: Backup job definitions for TerraMaster NAS
# ABOUTME: Configure rsync backup jobs - edit this file to add/remove backup sources
# ABOUTME: Changes take effect after running 'rebuild'
{
  # NAS connection settings
  nasHost = "TNAS.local";
  nasShare = "Photos";

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
  jobs = [
    {
      # Photos exported as plain browsable files (via osxphotos)
      # osxphotos automatically runs before rsync when this job is detected
      name = "photos";
      source = "Pictures/Photos-Export";  # osxphotos exports here
      destination = "Photos";             # Plain folder on NAS
      excludes = [
        ".DS_Store"
        ".osxphotos_export.db"  # osxphotos tracking database
      ];
    }
    # Uncomment and modify to add more backup jobs:
    # {
    #   name = "documents";
    #   source = "Documents";
    #   destination = "Documents";
    #   excludes = [ ".DS_Store" "*.tmp" ];
    # }
    # {
    #   name = "music";
    #   source = "Music";
    #   destination = "Music";
    #   excludes = [ ".DS_Store" ];
    # }
  ];
}
