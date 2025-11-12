# ABOUTME: Zed editor configuration for fast, modern code editing with Catppuccin theming
# ABOUTME: Automatically copies template settings.json on first run, then Zed manages its own config
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # Zed Editor Configuration
  # Story 02.2-001: Install and configure Zed with Catppuccin theme
  #
  # Installation: Via Homebrew cask (darwin/homebrew.nix)
  # Configuration: Symlinked to repo for bidirectional sync
  #
  # Why this approach (Issue #26):
  # - Zed expects to manage its own settings.json file (needs write access)
  # - Home Manager's home.file creates read-only symlinks to /nix/store (breaks Zed)
  # - Solution: Symlink to repo working directory (not /nix/store)
  #
  # How it works:
  # 1. Settings file in repo: config/zed/settings.json (version controlled)
  # 2. Activation script creates: ~/.config/zed/settings.json -> ~/nix-install/config/zed/settings.json
  # 3. Bidirectional sync:
  #    - Changes in Zed → Instantly appear in repo (git will show them)
  #    - Changes in repo (git pull) → Instantly apply to Zed
  #    - Settings version controlled, can commit/revert changes
  # 4. Zed has full write access (symlink points to regular file, not /nix/store)
  #
  # Key Features (from template):
  # - Catppuccin Mocha theme (dark) or Latte (light) via system appearance
  # - JetBrains Mono Nerd Font with ligatures
  # - Auto-update disabled (updates via 'rebuild' command only)
  # - Git integration, telemetry disabled, terminal integration

  # Activation script to symlink Zed settings to repo (bidirectional sync)
  home.activation.zedConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ZED_CONFIG_DIR="$HOME/.config/zed"
    ZED_SETTINGS="$ZED_CONFIG_DIR/settings.json"
    REPO_SETTINGS="${config.home.homeDirectory}/nix-install/config/zed/settings.json"

    # Create config directory if it doesn't exist
    if [ ! -d "$ZED_CONFIG_DIR" ]; then
      $DRY_RUN_CMD mkdir -p "$ZED_CONFIG_DIR"
      echo "Created Zed config directory: $ZED_CONFIG_DIR"
    fi

    # Create/update symlink to repo settings (bidirectional sync)
    if [ ! -L "$ZED_SETTINGS" ]; then
      # If regular file exists, back it up first
      if [ -f "$ZED_SETTINGS" ]; then
        $DRY_RUN_CMD mv "$ZED_SETTINGS" "$ZED_SETTINGS.backup"
        echo "Backed up existing settings to: $ZED_SETTINGS.backup"
      fi

      if [ -f "$REPO_SETTINGS" ]; then
        $DRY_RUN_CMD ln -sf "$REPO_SETTINGS" "$ZED_SETTINGS"
        echo "✓ Symlinked Zed settings to repo: config/zed/settings.json"
        echo "  Zed settings: $ZED_SETTINGS"
        echo "  Repo file: $REPO_SETTINGS"
        echo "  ✓ Bidirectional sync: Changes in Zed appear in repo, and vice versa"
      else
        echo "⚠️  Warning: Zed settings template not found at: $REPO_SETTINGS"
        echo "  Expected location: ~/nix-install/config/zed/settings.json"
        echo "  Zed will use default settings on first launch"
      fi
    else
      # Symlink exists, verify it points to the right place
      CURRENT_TARGET=$(readlink "$ZED_SETTINGS")
      if [ "$CURRENT_TARGET" != "$REPO_SETTINGS" ]; then
        $DRY_RUN_CMD ln -sf "$REPO_SETTINGS" "$ZED_SETTINGS"
        echo "Updated Zed settings symlink target to: $REPO_SETTINGS"
      fi
    fi
  '';

  # Optional: Install Zed-compatible language servers via Home Manager
  # Epic-04 will add language servers for development environment
  # Examples: nixd (Nix LSP), pyright (Python), bash-language-server
  home.packages = with pkgs; [
    # Language servers will be added in Epic-04 Development Environment
  ];
}
