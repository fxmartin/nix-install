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

      # Story 03.3-001: Trackpad speed and scrolling
      # Fast trackpad pointer speed (range: 0.0 - 3.0, default: ~0.6875)
      # 3.0 provides maximum tracking speed for efficient cursor movement
      "com.apple.trackpad.scaling" = 3.0;


      # Story 03.3-001: Natural scrolling direction
      # Disable natural scrolling (false = standard scroll direction)
      # Content moves DOWN when scrolling DOWN (traditional desktop behavior)
      # Applies to both trackpad and external mice
      "com.apple.swipescrolldirection" = false;
    };

    # Login window settings
    loginwindow = {
      # Disable guest account for security
      GuestEnabled = false;
    };

    # Story 03.3-002: Mouse speed
    # Mouse scaling is under .GlobalPreferences domain (not NSGlobalDomain)
    ".GlobalPreferences" = {
      # Fast mouse tracking speed (range: 0.0 - 3.0)
      # Matches trackpad speed for consistent pointer behavior
      "com.apple.mouse.scaling" = 3.0;
    };

  };

  # ============================================================================
  # SECURITY SETTINGS (Epic-03, Feature 03.2)
  # ============================================================================

  # Story 03.2-001: Firewall Configuration
  # NOTE: Migrated from system.defaults.alf to networking.applicationFirewall (Dec 2025 nix-darwin update)
  networking.applicationFirewall = {
    # Enable the application firewall
    # Provides protection while allowing necessary services
    enable = true;

    # Enable stealth mode
    # Mac doesn't respond to ping/ICMP requests or port scans
    # Makes the Mac invisible to network attackers
    enableStealthMode = true;

    # Automatically allow signed applications
    # Signed apps can receive incoming connections without prompts
    # Reduces security prompts for trusted, code-signed applications
    allowSigned = true;
  };

  # Story 03.2-003: Screen Lock and Password Policies
  # Password required immediately after sleep/screensaver (0 second delay)
  # Provides security when Mac is unattended or locked
  system.defaults.screensaver = {
    # Require password after sleep or screensaver starts
    # Prevents unauthorized access when Mac is left unattended
    askForPassword = true;

    # Immediate password requirement (0 seconds delay)
    # No grace period - password required instantly upon wake
    askForPasswordDelay = 0;
  };

  # Touch ID for sudo is ALREADY configured in darwin/configuration.nix:
  # security.pam.services.sudo_local.touchIdAuth = true;
  #
  # Guest login is ALREADY disabled above in loginwindow settings:
  # system.defaults.loginwindow.GuestEnabled = false;

  # ============================================================================
  # TRACKPAD AND INPUT CONFIGURATION (Epic-03, Feature 03.3)
  # ============================================================================

  # Story 03.3-001: Trackpad Gestures and Speed
  system.defaults.trackpad = {
    # Enable tap-to-click
    # Single tap performs a click instead of requiring physical press
    Clicking = true;

    # Enable three-finger drag (Accessibility feature)
    # Allows dragging windows/items with three-finger swipe
    # Note: nix-darwin sets this in the appropriate macOS domains automatically
    TrackpadThreeFingerDrag = true;
  };

  # ============================================================================
  # FUTURE EPIC-03 SETTINGS (To Be Implemented)
  # ============================================================================

  # Feature 03.2: Security and Privacy Settings (Complete)
  # - [✅] Firewall configuration (Story 03.2-001)
  # - [✅] Screen lock and password policies (Story 03.2-003)
  # - [✅] FileVault encryption prompt (Story 03.2-002 - implemented in bootstrap.sh Phase 9)

  # Feature 03.3: Trackpad and Input Configuration (Complete)
  # - [✅] Tap to click (Story 03.3-001)
  # - [✅] Three-finger drag (Story 03.3-001)
  # - [✅] Fast trackpad speed (Story 03.3-001 - in NSGlobalDomain)
  # - [✅] Natural scrolling disabled (Story 03.3-001 - in NSGlobalDomain)
  # - [✅] Secondary click (Story 03.3-001 - default macOS behavior)
  # - [✅] Fast mouse speed (Story 03.3-002 - in .GlobalPreferences)

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
