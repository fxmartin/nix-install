# ABOUTME: macOS system preferences and defaults configuration
# ABOUTME: Manages Finder, Dock, trackpad, security, and other system settings
{
  config,
  lib,
  pkgs,
  userConfig,
  isPowerProfile,
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

      # Story 03.4-001: Time Format
      # 24-hour time format for clarity and international standard
      # Menubar clock shows 14:30 instead of 2:30 PM
      AppleICUForce24HourTime = true;

      # Story 03.4-001: Auto Light/Dark Mode
      # Enable automatic appearance switching based on time of day
      # macOS will switch between Light and Dark mode at sunrise/sunset
      # NOTE: We set AppleInterfaceStyleSwitchesAutomatically = true below
      # and do NOT set AppleInterfaceStyle to allow auto switching
      # If you prefer forced dark mode, uncomment the line below:
      # AppleInterfaceStyle = "Dark";

      # ============================================================================
      # KEYBOARD AND TEXT INPUT (Epic-03, Feature 03.5)
      # ============================================================================

      # Story 03.5-001: Keyboard Repeat and Text Corrections

      # Key repeat rate (lower = faster, range: 1-15, 2 is very fast)
      # 1 = fastest, 2 = very fast (recommended for coding)
      KeyRepeat = 2;

      # Initial key repeat delay (lower = shorter delay, range: 10-120)
      # 10 = shortest (immediate), 15 = short (recommended), 25 = default
      InitialKeyRepeat = 15;

      # Disable automatic capitalization (essential for coding)
      # Prevents unwanted capitalization when typing code
      NSAutomaticCapitalizationEnabled = false;

      # Disable smart dash substitution (essential for coding)
      # Prevents "--" from becoming "—" (em dash)
      NSAutomaticDashSubstitutionEnabled = false;

      # Disable automatic period substitution
      # Prevents double-space from becoming ". " (period + space)
      NSAutomaticPeriodSubstitutionEnabled = false;

      # Disable smart quote substitution (essential for coding)
      # Prevents straight quotes from becoming curly quotes
      # Critical for programming - curly quotes break code
      NSAutomaticQuoteSubstitutionEnabled = false;

      # Disable automatic spelling correction (essential for coding)
      # Prevents auto-correct from changing variable names, commands, etc.
      NSAutomaticSpellingCorrectionEnabled = false;

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
  # POWER MANAGEMENT (Power Profile Only)
  # ============================================================================
  # System Settings → Battery → Options
  # Only for MacBook Pro M3 Max — keep MacBook Airs on default sleep behavior

  # "Prevent automatic sleeping when display is off"
  # Runs: sudo pmset -a sleep 0
  power.sleep.computer = lib.mkIf isPowerProfile "never";

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

  # macOS Sonoma/Sequoia stores Apple aerial screen saver selection in
  # WallpaperAgent's binary plist, not only in com.apple.screensaver defaults.
  # Sequoia Sunrise asset ID is documented by Apple's local aerial assets and
  # appears as /Library/Application Support/com.apple.idleassetsd/.../6D6834A4-...
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "Setting macOS screen saver to Sequoia Sunrise..."

    WALLPAPER_INDEX="/Users/${userConfig.username}/Library/Application Support/com.apple.wallpaper/Store/Index.plist"
    WALLPAPER_USER="${userConfig.username}"
    WALLPAPER_UID="$(/usr/bin/id -u "$WALLPAPER_USER" 2>/dev/null || true)"

    if [[ ! -f "$WALLPAPER_INDEX" ]]; then
      echo "⚠️  Warning: WallpaperAgent index not found: $WALLPAPER_INDEX"
      echo "   Open System Settings → Screen Saver once, then rerun rebuild."
    elif [[ -z "$WALLPAPER_UID" ]]; then
      echo "⚠️  Warning: Could not resolve user $WALLPAPER_USER; skipping screen saver setup"
    else
      WALLPAPER_INDEX="$WALLPAPER_INDEX" ${pkgs.python312}/bin/python3 <<'PY'
import datetime
import os
import plistlib
import tempfile

asset_id = "6D6834A4-2F0F-479A-B053-7D4DC5CB8EB7"
index_path = os.environ["WALLPAPER_INDEX"]

with open(index_path, "rb") as plist_file:
    wallpaper_index = plistlib.load(plist_file)

configuration = plistlib.dumps({"assetID": asset_id}, fmt=plistlib.FMT_BINARY)
encoded_options = plistlib.dumps({"values": []}, fmt=plistlib.FMT_BINARY)
now = datetime.datetime.now(datetime.UTC).replace(tzinfo=None)

def configure_idle(node):
    if not isinstance(node, dict):
        return 0

    updated = 0
    idle = node.get("Idle")
    if isinstance(idle, dict):
        idle["LastSet"] = now
        idle["LastUse"] = now
        content = idle.setdefault("Content", {})
        content["Choices"] = [
            {
                "Provider": "com.apple.wallpaper.choice.aerials",
                "Files": [],
                "Configuration": configuration,
            }
        ]
        content["Shuffle"] = "$null"
        content["EncodedOptionValues"] = encoded_options
        updated += 1

    for value in node.values():
        if isinstance(value, dict):
            updated += configure_idle(value)
        elif isinstance(value, list):
            for item in value:
                updated += configure_idle(item)

    return updated

updated_count = configure_idle(wallpaper_index)
if updated_count == 0:
    raise SystemExit("no Idle screen saver entries found in WallpaperAgent index")

directory = os.path.dirname(index_path)
with tempfile.NamedTemporaryFile("wb", dir=directory, delete=False) as temp_file:
    plistlib.dump(wallpaper_index, temp_file, fmt=plistlib.FMT_BINARY)
    temp_path = temp_file.name

os.replace(temp_path, index_path)
print(f"Updated {updated_count} screen saver entries to Sequoia Sunrise")
PY
      /usr/sbin/chown "$WALLPAPER_USER":staff "$WALLPAPER_INDEX"
      /bin/launchctl asuser "$WALLPAPER_UID" /usr/bin/killall WallpaperAgent 2>/dev/null || true
      /bin/launchctl asuser "$WALLPAPER_UID" /usr/bin/killall cfprefsd 2>/dev/null || true
      echo "✓ Screen saver set to Sequoia Sunrise"
    fi
  '';

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
  # DISPLAY AND APPEARANCE (Epic-03, Feature 03.4)
  # ============================================================================

  # Story 03.4-001: Auto Light/Dark Mode and Icon/Widget Style
  # CustomUserPreferences allows setting options not directly supported by nix-darwin
  system.defaults.CustomUserPreferences = {
    # Enable automatic appearance switching (Light/Dark mode)
    # macOS will switch based on sunrise/sunset times
    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true;

      # Icon & Widget Style (macOS Tahoe 26+)
      # Options: "Default", "Light", "Dark", "Clear", "ClearLight", "ClearDark",
      #          "Tinted", "TintedLight", "TintedDark"
      # "Light" = Clean light appearance for icons and widgets
      AppleIconAppearanceTheme = "Light";

      # Menu bar auto-hide is managed via osascript in the activation script below
      # (defaults write alone doesn't apply immediately on macOS 26 Tahoe)
    };
  };

  # Story 03.4-002: Night Shift Scheduling
  # Night Shift reduces blue light from sunset to sunrise to reduce eye strain
  # Note: Night Shift settings are complex and may require manual configuration
  # The CoreBrightness domain requires specific user context to persist properly
  # Documented manual setup: System Settings → Displays → Night Shift → Schedule: Sunset to Sunrise

  # ============================================================================
  # DOCK CONFIGURATION (Epic-03, Feature 03.6)
  # ============================================================================

  # Story 03.6-001: Dock Behavior and Apps
  system.defaults.dock = {
    # Persistent applications in Dock (replaces macOS defaults)
    # Only show apps FX actually uses - removes Safari, Finder, etc.
    # Note: Finder cannot be removed from Dock (macOS restriction)
    # Format: Full path to .app bundle
    persistent-apps = [
      # Communication (leftmost - most frequently accessed)
      "/System/Applications/Mail.app"
      "/Applications/WhatsApp.app"
      # AI Tools (core productivity)
      "/Applications/Claude.app"
      "/Applications/ChatGPT.app"
      "/Applications/Perplexity.app"
      # Development
      "/Applications/Ghostty.app"
      "/Applications/Brave Browser.app"
      # Security & Infrastructure
      "/Applications/1Password.app"
      "/Applications/NordVPN.app"
      # System (rightmost - less frequent)
      "/System/Applications/System Settings.app"
    ];

    # Minimize windows into their application's icon (cleaner Dock)
    # Instead of creating separate minimized window icons
    minimize-to-application = true;

    # Auto-hide the Dock (saves screen space)
    # Dock appears when mouse moves to screen edge
    autohide = true;

    # Speed up auto-hide animation (default is ~0.5)
    # Lower values = faster animation
    autohide-time-modifier = 0.2;

    # Remove delay before Dock shows when auto-hidden
    # Default is 0.5 seconds, 0 = instant
    autohide-delay = 0.0;

    # Dock position (bottom, left, right)
    orientation = "left";

    # Don't show recent applications in Dock
    # Keeps Dock clean and predictable
    show-recents = false;

    # Icon size in pixels (default is 48)
    # 48 is a good balance of visibility and space
    tilesize = 48;

    # Enable magnification on hover (disabled for cleaner look)
    magnification = false;

    # Magnified icon size when hovering (only if magnification = true)
    # largesize = 64;

    # Use scale effect when minimizing (alternative: "genie")
    # Scale is faster and less distracting
    mineffect = "scale";

    # Don't animate opening applications (faster feel)
    launchanim = false;

    # Show indicator lights for open applications
    show-process-indicators = true;

    # Don't automatically rearrange Spaces based on recent use
    # Keeps workspace organization predictable
    mru-spaces = false;

    # Expose settings (hot corners and spaces)
    # Expose all windows when mouse enters top-left corner (disabled)
    # wvous-tl-corner = 1;  # Mission Control
    # wvous-tr-corner = 1;  # Mission Control
    # wvous-bl-corner = 1;  # Mission Control
    # wvous-br-corner = 1;  # Mission Control
  };

  # ============================================================================
  # TIME MACHINE BACKUP CONFIGURATION (Epic-03, Feature 03.7)
  # ============================================================================

  # Story 03.7-001: Time Machine Preferences & Exclusions
  # Configure Time Machine with intelligent exclusions to save backup space
  # Excludes reproducible content (Nix store) and temporary files (caches, trash)

  # Time Machine preferences and exclusions via activation script
  # NOTE: nix-darwin doesn't have system.defaults.TimeMachine, so we use defaults write
  # These paths are excluded from backups to save space and time:
  # - /nix: Fully reproducible via flake.lock (20-50GB saved)
  # - ~/.Trash: User's deleted files
  # - ~/Library/Caches: Application caches (reproducible)
  # - ~/Downloads: Usually temporary files
  # - /private/var/folders: System temporary files
  # Use extraActivation - one of the hardcoded script names that nix-darwin actually runs
  # Custom script names like 'configureTimeMachine' are NOT executed
  # See: https://github.com/nix-darwin/nix-darwin/issues/663
  system.activationScripts.extraActivation.text = ''
    # ============================================================================
    # POWER MANAGEMENT - Wake for Network Access (Power Profile Only)
    # ============================================================================
    # System Settings → Battery → Options → "Wake for network access"
    ${if isPowerProfile then ''
      echo "Configuring power management for Power profile..."
      /usr/bin/sudo /usr/bin/pmset -a womp 1
      echo "✅ Wake for network access enabled"
    '' else ''
      echo "Skipping power management (Standard profile)"
    ''}

    # ============================================================================
    # TIME MACHINE CONFIGURATION
    # ============================================================================
    # ============================================================================
    # MENU BAR AUTO-HIDE
    # ============================================================================
    # Automatically hide and show the menu bar: Always
    # Options: 0 = Never, 1 = In Full Screen Only, 2 = Always
    # Pairs well with SketchyBar as a replacement status bar
    # Both keys must be set: NSGlobalDomain._HIHideMenuBar (set via system.defaults)
    # and com.apple.controlcenter.AutoHideMenuBarOption (the actual ControlCenter key)
    /usr/bin/sudo -u ${userConfig.username} /usr/bin/osascript -e 'tell application "System Events" to tell dock preferences to set autohide menu bar to true'
    echo "✅ Menu bar auto-hide set to Always"

    # ============================================================================
    # SAFARI CONFIGURATION
    # ============================================================================
    # Force "target=_blank" links to open in tabs instead of new windows
    /usr/bin/defaults write com.apple.Safari TargetedClicksCreateTabs -bool true

    # Open pages in tabs instead of windows: Automatically
    # 0 = Never, 1 = Automatically, 2 = Always
    /usr/bin/defaults write com.apple.Safari TabCreationPolicy -int 1

    # Safari opens with: All windows from last session
    # 0 = A new window, 1 = A new private window, 2 = All windows from last session
    # 3 = All non-private windows from last session
    /usr/bin/defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool true
    /usr/bin/defaults write com.apple.Safari ExcludePrivateWindowWhenRestoringSessionAtLaunch -bool false

    echo "✅ Safari configured (tabs, restore last session)"

    # ============================================================================
    # SKETCHYBAR SERVICE
    # ============================================================================
    # Start SketchyBar as a brew service (runs as LaunchAgent for current user)
    if /opt/homebrew/bin/brew list sketchybar &>/dev/null; then
      /usr/bin/sudo -u ${userConfig.username} /opt/homebrew/bin/brew services start sketchybar 2>/dev/null || true
      echo "✅ SketchyBar service started"
    fi

    # ============================================================================
    # SKHD SERVICE
    # ============================================================================
    # Start skhd as a brew service (simple hotkey daemon for macOS)
    if /opt/homebrew/bin/brew list skhd &>/dev/null; then
      /usr/bin/sudo -u ${userConfig.username} /opt/homebrew/bin/skhd --start-service 2>/dev/null || true
      echo "✅ skhd service started"
    fi

    # ============================================================================
    # TIME MACHINE CONFIGURATION
    # ============================================================================
    echo "Configuring Time Machine preferences and exclusions..."

    # Don't prompt to use new hard drives as backup volume
    # Prevents annoying popup when connecting external drives
    /usr/bin/defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    # Get the actual user's home directory (activation runs as root)
    USER_HOME="/Users/${userConfig.username}"

    # Add standard exclusions (safe to run multiple times)
    # Using -p flag for "sticky" exclusions that persist across volume changes
    # The || true ensures the script continues even if path doesn't exist

    # Nix store - fully reproducible, no need to backup (~20-50GB)
    # NOTE: /nix is an APFS volume; tmutil addexclusion fails with EINVAL on it.
    # The Nix installer already excludes this volume from Time Machine at the volume level.
    # Verify with: tmutil isexcluded /nix

    # User trash - no need to backup deleted files
    /usr/bin/tmutil addexclusion -p "$USER_HOME/.Trash" 2>/dev/null || true

    # Application caches - reproducible, often large
    /usr/bin/tmutil addexclusion -p "$USER_HOME/Library/Caches" 2>/dev/null || true

    # Downloads folder - usually temporary files
    /usr/bin/tmutil addexclusion -p "$USER_HOME/Downloads" 2>/dev/null || true

    # System temporary files
    /usr/bin/tmutil addexclusion -p /private/var/folders 2>/dev/null || true

    # Homebrew caches - reproducible
    /usr/bin/tmutil addexclusion -p "$USER_HOME/Library/Caches/Homebrew" 2>/dev/null || true

    # npm/yarn caches - reproducible
    /usr/bin/tmutil addexclusion -p "$USER_HOME/.npm" 2>/dev/null || true
    /usr/bin/tmutil addexclusion -p "$USER_HOME/.yarn" 2>/dev/null || true

    # Python caches - reproducible
    /usr/bin/tmutil addexclusion -p "$USER_HOME/.cache/pip" 2>/dev/null || true
    /usr/bin/tmutil addexclusion -p "$USER_HOME/.cache/uv" 2>/dev/null || true

    echo "✅ Time Machine exclusions configured"
    echo "   Verify with: tmutil isexcluded /nix"
  '';

  # ============================================================================
  # EPIC-03 COMPLETION STATUS
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

  # Feature 03.4: Display and Appearance (Complete)
  # - [✅] 24-hour time format (Story 03.4-001 - in NSGlobalDomain)
  # - [✅] Auto Light/Dark Mode (Story 03.4-001 - via CustomUserPreferences)
  # - [⚠️] Night Shift scheduling (Story 03.4-002 - manual setup required, see docs)

  # Feature 03.5: Keyboard and Text Input (Complete)
  # - [✅] Fast key repeat rate (Story 03.5-001 - KeyRepeat = 2)
  # - [✅] Short initial delay (Story 03.5-001 - InitialKeyRepeat = 15)
  # - [✅] Auto-capitalization disabled (Story 03.5-001)
  # - [✅] Smart quotes disabled (Story 03.5-001)
  # - [✅] Smart dashes disabled (Story 03.5-001)
  # - [✅] Auto-correct disabled (Story 03.5-001)

  # Feature 03.6: Dock Configuration (Complete)
  # - [✅] Persistent apps configured (Story 03.6-001) - Mail, Claude, Ghostty, WhatsApp, Perplexity, ChatGPT, 1Password, Brave, Settings, NordVPN
  # - [✅] Minimize to application icon (Story 03.6-001)
  # - [✅] Auto-hide enabled (Story 03.6-001)
  # - [✅] Fast auto-hide animation (Story 03.6-001)
  # - [✅] Dock position at bottom (Story 03.6-001)
  # - [✅] Recent apps hidden (Story 03.6-001)
  # - [✅] Icon size 48px (Story 03.6-001)
  # - [✅] Scale minimize effect (Story 03.6-001)
  # - [✅] Launch animation disabled (Story 03.6-001)
  # - [✅] Process indicators enabled (Story 03.6-001)
  # - [✅] MRU spaces disabled (Story 03.6-001)

  # Feature 03.7: Time Machine Backup Configuration (Complete)
  # - [✅] Don't prompt for new disks (Story 03.7-001)
  # - [✅] Nix store excluded from backups (Story 03.7-001)
  # - [✅] User caches excluded (Story 03.7-001)
  # - [✅] Trash excluded (Story 03.7-001)
  # - [✅] Downloads excluded (Story 03.7-001)
  # - [✅] System temp files excluded (Story 03.7-001)
  # - [✅] Package manager caches excluded (Story 03.7-001)
  # - [⏸️] Destination setup prompt (Story 03.7-002 - deferred)
}
