# ABOUTME: AeroSpace configuration - i3-like tiling window manager
# ABOUTME: Symlinks config directory to repo for bidirectional sync (REQ-NFR-008 compliant)
{
  config,
  lib,
  userConfig,
  findRepoRoot,
  ...
}: {
  # AeroSpace Configuration
  # Installation: Via Homebrew cask (darwin/homebrew.nix, tap: nikitabobko/tap)
  # Configuration: Symlinked to repo for bidirectional sync
  #
  # How it works:
  # 1. Config file in repo: config/aerospace/aerospace.toml (version controlled)
  # 2. Activation script dynamically finds repo location
  # 3. Creates symlink: ~/.config/aerospace -> $REPO_ROOT/config/aerospace
  # 4. Reload after edits with: aerospace reload-config

  home.activation.aerospaceConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    AEROSPACE_CONFIG_DIR="$HOME/.config/aerospace"

    # Find nix-install repo root (shared helper from flake.nix extraSpecialArgs)
    ${findRepoRoot config.home.homeDirectory}

    # Fallback to default if not found
    if [ -z "$REPO_ROOT" ]; then
      REPO_ROOT="${config.home.homeDirectory}/.config/nix-install"
    fi

    REPO_CONFIG="$REPO_ROOT/config/aerospace"

    if [ -d "$REPO_CONFIG" ]; then
      # If a regular directory exists (not a symlink), back it up
      if [ -d "$AEROSPACE_CONFIG_DIR" ] && [ ! -L "$AEROSPACE_CONFIG_DIR" ]; then
        $DRY_RUN_CMD mv "$AEROSPACE_CONFIG_DIR" "$AEROSPACE_CONFIG_DIR.backup"
        echo "Backed up existing config to: $AEROSPACE_CONFIG_DIR.backup"
      fi

      # Create or update the symlink
      if [ ! -L "$AEROSPACE_CONFIG_DIR" ] || [ "$(readlink "$AEROSPACE_CONFIG_DIR")" != "$REPO_CONFIG" ]; then
        $DRY_RUN_CMD ln -sfn "$REPO_CONFIG" "$AEROSPACE_CONFIG_DIR"
        echo "✓ Symlinked AeroSpace config to repo: config/aerospace/"
        echo "  AeroSpace config: $AEROSPACE_CONFIG_DIR"
        echo "  Repo directory: $REPO_CONFIG"
      fi
    else
      echo "⚠️  Warning: AeroSpace config not found at: $REPO_CONFIG"
      echo "  Searched in: ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install"
    fi
  '';
}
