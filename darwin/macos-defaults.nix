# ABOUTME: macOS system preferences and defaults configuration (STUB for Epic-03)
# ABOUTME: Manages Finder, Dock, trackpad, security, and other system settings
{
  config,
  lib,
  userConfig,
  ...
}: {
  # macOS System Preferences
  # Epic-03 will expand with comprehensive system defaults:

  # 1. Finder Settings:
  #    - Show hidden files
  #    - Show file extensions
  #    - Show path bar and status bar
  #    - Disable warning on file extension changes
  #    - Default to column view
  #    - Search current folder by default

  # 2. Dock Settings:
  #    - Auto-hide dock
  #    - Icon size and magnification
  #    - Minimize effect
  #    - Show recent applications
  #    - Persistent apps configuration

  # 3. Trackpad Settings:
  #    - Tap to click
  #    - Tracking speed
  #    - Natural scrolling
  #    - Secondary click

  # 4. Security Settings:
  #    - Firewall enabled
  #    - Require password immediately after sleep
  #    - Disable guest login
  #    - FileVault encryption

  # 5. Keyboard Settings:
  #    - Key repeat rate
  #    - Delay until repeat
  #    - Disable press-and-hold for accents

  # 6. Global Settings:
  #    - Dark mode
  #    - 24-hour time format
  #    - Disable auto-correct
  #    - Disable smart quotes/dashes

  # Minimal defaults already set in configuration.nix
  # Epic-03 will move all system.defaults here for better organization
}
