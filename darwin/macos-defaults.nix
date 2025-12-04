# ABOUTME: macOS system preferences and defaults configuration
# ABOUTME: Manages Finder, Dock, trackpad, security, and other system settings
{
  config,
  lib,
  userConfig,
  ...
}: {
  # macOS System Preferences
  # Comprehensive system defaults for consistent macOS configuration

  system.defaults = {
    # ============================================================================
    # FINDER SETTINGS (Epic-03, Feature 03.1)
    # ============================================================================

    finder = {
      # Story 03.1-001: Finder View and Display Settings

      # Default view style: List view (Nlsv)
      # Options: "icnv" (icon), "Nlsv" (list), "clmv" (column), "glyv" (gallery)
      FXPreferredViewStyle = "Nlsv";

      # Show path bar at bottom of Finder window
      # Displays current folder path for easy navigation
      ShowPathbar = true;

      # Show status bar at bottom of Finder window
      # Displays item count, folder size, and available space
      ShowStatusBar = true;

      # Show hidden files (dotfiles starting with .)
      # Essential for development work and system administration
      AppleShowAllFiles = true;

      # Show all file extensions
      # Prevents confusion about file types
      AppleShowAllExtensions = true;

      # Story 03.1-002: Finder Behavior Settings

      # NOTE: WarnOnEmptyTrash was removed in nix-darwin update (Dec 2025)
      # macOS now manages this setting directly - no longer configurable via nix-darwin

      # Keep folders on top when sorting by name
      # Maintains folders-first organization in list/column views
      _FXSortFoldersFirst = true;

      # Default search scope: current folder (SCcf)
      # Options: "SCev" (This Mac), "SCcf" (Current Folder), "SCsp" (Previous Scope)
      # Current folder is more useful for targeted searches
      FXDefaultSearchScope = "SCcf";

      # Warn before changing file extension
      # Prevents accidental file corruption from extension changes
      FXEnableExtensionChangeWarning = true;

      # Story 03.1-003: Finder Sidebar and Desktop

      # New Finder windows open to Home directory
      # Options: "Computer", "OS volume", "Home", "Desktop", "Documents", "Recents", "iCloud Drive", "Other"
      # More intuitive than opening to "Recents" or other default locations
      NewWindowTarget = "Home";

      # Show external hard drives on desktop
      # Provides quick access to mounted external storage
      ShowExternalHardDrivesOnDesktop = true;

      # Show removable media (CDs, DVDs, iPods) on desktop
      # Useful for physical media access
      ShowRemovableMediaOnDesktop = true;

      # Show mounted servers on desktop
      # Network volumes appear on desktop for easy access
      ShowMountedServersOnDesktop = true;
    };

    # Global macOS settings
    NSGlobalDomain = {
      # Always show file extensions in all applications
      # Duplicates finder setting for system-wide consistency
      AppleShowAllExtensions = true;

      # Existing global settings (moved from configuration.nix)
      AppleICUForce24HourTime = true; # 24-hour time format
      AppleInterfaceStyle = "Dark"; # Dark mode
      KeyRepeat = 2; # Fast key repeat rate
    };

    # Login window settings
    loginwindow = {
      # Disable guest account for security
      GuestEnabled = false;
    };
  };

  # ============================================================================
  # FUTURE EPIC-03 SETTINGS (To Be Implemented)
  # ============================================================================

  # Feature 03.2: Security and Privacy Settings
  # - Firewall configuration
  # - Password requirements
  # - FileVault encryption

  # Feature 03.3: Trackpad Configuration
  # - Tap to click
  # - Tracking speed
  # - Natural scrolling
  # - Secondary click

  # Feature 03.4: Display and Energy Settings
  # - Screen resolution
  # - Night Shift
  # - Sleep/display settings

  # Feature 03.5: Keyboard and Input Settings
  # - Key repeat rates
  # - Modifier keys
  # - Input sources

  # Feature 03.6: Dock Configuration
  # - Auto-hide
  # - Icon size
  # - Position
  # - Persistent applications
}
