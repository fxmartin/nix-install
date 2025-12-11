# ABOUTME: Stylix system-wide theming configuration for macOS
# ABOUTME: Configures Catppuccin color scheme, JetBrains Mono font, and custom wallpaper
#
# Story 05.1-001: Stylix Installation and Base16 Scheme
# Story 05.2-001: JetBrains Mono Nerd Font Installation
#
# Key Architecture Decisions:
# 1. Stylix provides base16 color scheme for apps without native theme support
# 2. Apps with native auto-switching (Ghostty, Zed) use their own theme configs
#    - Ghostty: theme = "light:Catppuccin Latte,dark:Catppuccin Mocha"
#    - Zed: theme.mode = "system" with light/dark variants
# 3. Stylix handles: wallpaper, fonts, and apps that need base16 integration
# 4. polarity = "dark" sets Catppuccin Mocha as the primary base16 scheme
#    - Auto light/dark switching is handled at the application level
#
# Why this approach:
# - Stylix doesn't support dynamic polarity switching without rebuild
# - Ghostty and Zed have excellent native auto-switching support
# - We leverage each tool's strengths for best user experience
#
# Note: Some Stylix options (cursor, opacity) are NixOS-only and not available
# for nix-darwin. macOS manages cursor themes at the system level, and opacity
# is configured per-application (e.g., Ghostty's background-opacity setting).
#
# Note: Stylix's `image` setting doesn't set macOS desktop wallpaper directly.
# We use a separate activation script with osascript to set the wallpaper.
# See: https://discourse.nixos.org/t/set-wallpaper-in-nix-darwin-over-desktoppr/58161
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: let
  # Wallpaper path - copied to a persistent location for macOS to access
  # Using builtins.path to ensure proper Nix store path resolution
  wallpaperSource = builtins.path {
    path = ../wallpaper/Ropey_Photo_by_Bob_Farrell.jpg;
    name = "wallpaper.jpg";
  };
  wallpaperDest = "/Users/${userConfig.username}/.local/share/wallpaper/current.jpg";
  wallpaperDir = "/Users/${userConfig.username}/.local/share/wallpaper";
in {
  # Stylix System-wide Theming Configuration
  stylix = {
    enable = true;

    # Disable version mismatch warnings between Stylix and nix-darwin
    # Safe to use as we track nixpkgs-unstable for both
    enableReleaseChecks = false;

    # ============================================================================
    # COLOR SCHEME CONFIGURATION
    # ============================================================================
    # Catppuccin Mocha (dark mode) as the primary base16 scheme
    # This provides consistent colors for apps that integrate with Stylix
    #
    # Apps with native theme support (Ghostty, Zed, VSCode) use their own
    # Catppuccin implementations with auto light/dark switching
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Set polarity to dark - Catppuccin Mocha is a dark theme
    # Note: Stylix doesn't support dynamic polarity switching
    # Auto light/dark is handled at the application level
    polarity = "dark";

    # ============================================================================
    # WALLPAPER CONFIGURATION
    # ============================================================================
    # Custom wallpaper from wallpaper/ directory
    # Story 05.1-001 requirement: wallpaper from wallpaper/Ropey_Photo_by_Bob_Farrell.jpg
    #
    # The image is copied to the Nix store and applied to all desktops/spaces
    # Persists across rebuilds as an immutable reference
    image = ../wallpaper/Ropey_Photo_by_Bob_Farrell.jpg;

    # ============================================================================
    # FONT CONFIGURATION
    # ============================================================================
    # Story 05.2-001: JetBrains Mono Nerd Font Installation
    #
    # JetBrains Mono Nerd Font for all monospace contexts:
    # - Terminal (Ghostty)
    # - Code editors (Zed, VSCode)
    # - Shell prompt (Starship icons)
    #
    # Nerd Font variant includes icons and symbols for:
    # - Starship prompt icons
    # - Dev tools (git, language icons)
    # - File type icons
    fonts = {
      # Primary monospace font for code and terminal
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      # Sans-serif for UI elements (Inter is clean and modern)
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };

      # Serif for documentation and reading (Source Serif is professional)
      serif = {
        package = pkgs.source-serif;
        name = "Source Serif 4";
      };

      # Emoji font for proper emoji rendering
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      # Font sizes for different contexts
      sizes = {
        # Terminal font size
        terminal = 12;

        # Desktop/system font size
        desktop = 10;

        # Application UI font size
        applications = 11;

        # Pop-up/tooltip font size
        popups = 10;
      };
    };

    # NOTE: Cursor and opacity options are NixOS-only, not available in nix-darwin
    # - Cursor theming: macOS manages cursors at the system level
    # - Opacity: Configure per-application (e.g., Ghostty's background-opacity = 0.95)
  };

  # ============================================================================
  # WALLPAPER ACTIVATION SCRIPT
  # ============================================================================
  # Stylix's `image` setting doesn't set macOS desktop wallpaper directly.
  # This activation script copies the wallpaper to a persistent location and
  # uses osascript to set it as the desktop picture for all desktops.
  #
  # Why copy to ~/.local/share/wallpaper/:
  # - Nix store paths can change between rebuilds
  # - macOS needs a stable path for the wallpaper
  # - User-accessible location for easy verification
  # Use postActivation - one of the hardcoded script names that nix-darwin actually runs
  # See: https://github.com/nix-darwin/nix-darwin/issues/663
  system.activationScripts.postActivation.text = ''
    echo "Setting macOS desktop wallpaper..."

    # Create wallpaper directory if it doesn't exist
    mkdir -p "${wallpaperDir}"

    # Copy wallpaper from Nix store to persistent location
    # The source path is the Nix store path of the wallpaper image
    WALLPAPER_SOURCE="${toString wallpaperSource}"
    WALLPAPER_DEST="${wallpaperDest}"

    echo "  Source: $WALLPAPER_SOURCE"
    echo "  Destination: $WALLPAPER_DEST"

    if [[ -f "$WALLPAPER_SOURCE" ]]; then
      cp -f "$WALLPAPER_SOURCE" "$WALLPAPER_DEST"
      chmod 644 "$WALLPAPER_DEST"
      echo "✓ Wallpaper copied to $WALLPAPER_DEST"

      # Set wallpaper for all desktops using osascript
      # This AppleScript sets the desktop picture for every desktop/space
      if /usr/bin/osascript -e "
        tell application \"System Events\"
          tell every desktop
            set picture to \"$WALLPAPER_DEST\"
          end tell
        end tell
      "; then
        echo "✓ Desktop wallpaper set successfully"
      else
        echo "⚠️  Warning: Could not set wallpaper via osascript"
        echo "   This may require running as the logged-in user"
        echo "   You can manually set it from: $WALLPAPER_DEST"
      fi
    else
      echo "⚠️  Warning: Wallpaper source not found: $WALLPAPER_SOURCE"
      echo "   Skipping wallpaper setup"
    fi
  '';
}
