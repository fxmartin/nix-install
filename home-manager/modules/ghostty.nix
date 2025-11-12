# ABOUTME: Ghostty terminal configuration for fast, GPU-accelerated terminal with Catppuccin theming
# ABOUTME: Symlinks config to repo for bidirectional sync (REQ-NFR-008 compliant)
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # Ghostty Terminal Configuration
  # Story 02.2-003: Install and configure Ghostty with existing config/config.ghostty
  #
  # Installation: Via Homebrew cask (darwin/homebrew.nix)
  # Configuration: Symlinked to repo for bidirectional sync
  #
  # Why this approach (REQ-NFR-008 compliant):
  # - Ghostty expects to manage its own config file (may need write access for some settings)
  # - Home Manager's xdg.configFile creates read-only symlinks to /nix/store (breaks some apps)
  # - Solution: Symlink to repo working directory (not /nix/store)
  # - Same pattern as Zed (Story 02.2-001) and VSCode (Story 02.2-002)
  #
  # How it works:
  # 1. Config file in repo: config/config.ghostty (version controlled)
  # 2. Activation script dynamically finds repo location
  #    - Searches: ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install
  #    - Works with any NIX_INSTALL_DIR from bootstrap
  # 3. Creates symlink: ~/.config/ghostty/config -> $REPO_ROOT/config/config.ghostty
  # 4. Bidirectional sync:
  #    - Changes in repo (git pull) → Instantly apply to Ghostty
  #    - Settings version controlled, can commit/revert changes
  #    - Ghostty reads config from symlink target
  # 5. Ghostty can read config from working directory (not /nix/store)
  #
  # Key Features (from existing config/config.ghostty):
  # - Theme: Catppuccin (Latte for light, Mocha for dark) with automatic switching
  # - Font: JetBrains Mono with ligatures
  # - Auto-update: Disabled (auto-update = off)
  # - Background: 95% opacity with blur effect
  # - Window padding: 16px horizontal/vertical
  # - Shell integration: Enabled with cursor, sudo, title features
  # - Clipboard: Read on ask, write allowed, copy-on-select enabled
  # - Keybindings: Comprehensive productivity bindings for splits, tabs, navigation

  # Activation script to symlink Ghostty config to repo (bidirectional sync)
  home.activation.ghosttyConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
    GHOSTTY_CONFIG_FILE="$GHOSTTY_CONFIG_DIR/config"

    # Dynamically find repo location (works with any NIX_INSTALL_DIR)
    # Search for nix-install repo by looking for flake.nix + config/config.ghostty
    REPO_ROOT=""
    for candidate in "${config.home.homeDirectory}/nix-install" \
                     "${config.home.homeDirectory}/.config/nix-install" \
                     "${config.home.homeDirectory}/Documents/nix-install"; do
      if [ -f "$candidate/flake.nix" ] && [ -f "$candidate/config/config.ghostty" ]; then
        REPO_ROOT="$candidate"
        break
      fi
    done

    # Fallback to default if not found
    if [ -z "$REPO_ROOT" ]; then
      REPO_ROOT="${config.home.homeDirectory}/nix-install"
    fi

    REPO_CONFIG="$REPO_ROOT/config/config.ghostty"

    # Create config directory if it doesn't exist
    if [ ! -d "$GHOSTTY_CONFIG_DIR" ]; then
      $DRY_RUN_CMD mkdir -p "$GHOSTTY_CONFIG_DIR"
      echo "Created Ghostty config directory: $GHOSTTY_CONFIG_DIR"
    fi

    # Create/update symlink to repo config (bidirectional sync)
    if [ ! -L "$GHOSTTY_CONFIG_FILE" ]; then
      # If regular file exists, back it up first
      if [ -f "$GHOSTTY_CONFIG_FILE" ]; then
        $DRY_RUN_CMD mv "$GHOSTTY_CONFIG_FILE" "$GHOSTTY_CONFIG_FILE.backup"
        echo "Backed up existing config to: $GHOSTTY_CONFIG_FILE.backup"
      fi

      if [ -f "$REPO_CONFIG" ]; then
        $DRY_RUN_CMD ln -sf "$REPO_CONFIG" "$GHOSTTY_CONFIG_FILE"
        echo "✓ Symlinked Ghostty config to repo: config/config.ghostty"
        echo "  Ghostty config: $GHOSTTY_CONFIG_FILE"
        echo "  Repo file: $REPO_CONFIG"
        echo "  ✓ Bidirectional sync: Changes in repo appear in Ghostty on reload"
      else
        echo "⚠️  Warning: Ghostty config not found at: $REPO_CONFIG"
        echo "  Searched in: ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install"
        echo "  Ghostty will use default settings on first launch"
      fi
    else
      # Symlink exists, verify it points to the right place
      CURRENT_TARGET=$(readlink "$GHOSTTY_CONFIG_FILE")
      if [ "$CURRENT_TARGET" != "$REPO_CONFIG" ]; then
        $DRY_RUN_CMD ln -sf "$REPO_CONFIG" "$GHOSTTY_CONFIG_FILE"
        echo "Updated Ghostty config symlink target to: $REPO_CONFIG"
      fi
    fi
  '';

  # Optional: Install Ghostty-related utilities
  # Epic-04 will add shell integration enhancements if needed
  home.packages = with pkgs; [
    # Utilities will be added in Epic-04 Development Environment if needed
  ];
}
