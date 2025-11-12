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
  # Configuration: Template copied automatically on first run, then user-editable
  #
  # Why this approach (Issue #26):
  # - Zed expects to manage its own settings.json file
  # - Home Manager's home.file creates read-only symlinks to /nix/store
  # - Solution: Copy template once, then Zed has full write access
  #
  # How it works:
  # 1. Template stored in repo: config/zed/settings.json
  # 2. On first darwin-rebuild, activation script copies template to ~/.config/zed/settings.json
  # 3. Subsequent rebuilds preserve existing settings (no overwrite)
  # 4. Zed can modify settings.json freely
  #
  # Key Features (from template):
  # - Catppuccin Mocha theme (dark) or Latte (light) via system appearance
  # - JetBrains Mono Nerd Font with ligatures
  # - Auto-update disabled (updates via 'rebuild' command only)
  # - Git integration, telemetry disabled, terminal integration

  # Activation script to copy Zed settings template on first run
  home.activation.zedConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ZED_CONFIG_DIR="$HOME/.config/zed"
    ZED_SETTINGS="$ZED_CONFIG_DIR/settings.json"
    TEMPLATE="${config.home.homeDirectory}/nix-install/config/zed/settings.json"

    # Create config directory if it doesn't exist
    if [ ! -d "$ZED_CONFIG_DIR" ]; then
      $DRY_RUN_CMD mkdir -p "$ZED_CONFIG_DIR"
      echo "Created Zed config directory: $ZED_CONFIG_DIR"
    fi

    # Copy template only if settings.json doesn't exist
    if [ ! -f "$ZED_SETTINGS" ]; then
      if [ -f "$TEMPLATE" ]; then
        $DRY_RUN_CMD cp "$TEMPLATE" "$ZED_SETTINGS"
        echo "✓ Copied Zed settings template from config/zed/settings.json"
        echo "  Settings location: $ZED_SETTINGS"
        echo "  Zed can now modify this file freely"
      else
        echo "⚠️  Warning: Zed settings template not found at: $TEMPLATE"
        echo "  Expected location: ~/nix-install/config/zed/settings.json"
        echo "  Zed will use default settings on first launch"
      fi
    else
      echo "Zed settings.json already exists, preserving user modifications"
    fi
  '';

  # Optional: Install Zed-compatible language servers via Home Manager
  # Epic-04 will add language servers for development environment
  # Examples: nixd (Nix LSP), pyright (Python), bash-language-server
  home.packages = with pkgs; [
    # Language servers will be added in Epic-04 Development Environment
  ];
}
