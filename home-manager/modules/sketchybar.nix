# ABOUTME: SketchyBar configuration - highly customizable macOS status bar replacement
# ABOUTME: Symlinks config directory to repo for bidirectional sync (REQ-NFR-008 compliant)
{
  config,
  lib,
  userConfig,
  findRepoRoot,
  ...
}: {
  # SketchyBar Configuration
  # Installation: Via Homebrew formula (darwin/homebrew.nix, tap: felixkratz/formulae)
  # Configuration: Symlinked to repo for bidirectional sync
  #
  # How it works:
  # 1. Config files in repo: config/sketchybar/ (version controlled)
  # 2. Activation script dynamically finds repo location
  # 3. Creates symlink: ~/.config/sketchybar -> $REPO_ROOT/config/sketchybar
  # 4. Bidirectional sync: changes in repo apply immediately on sketchybar reload

  home.activation.sketchybarConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    SKETCHYBAR_CONFIG_DIR="$HOME/.config/sketchybar"

    # Find nix-install repo root (shared helper from flake.nix extraSpecialArgs)
    ${findRepoRoot config.home.homeDirectory}

    # Fallback to default if not found
    if [ -z "$REPO_ROOT" ]; then
      REPO_ROOT="${config.home.homeDirectory}/.config/nix-install"
    fi

    REPO_CONFIG="$REPO_ROOT/config/sketchybar"

    if [ -d "$REPO_CONFIG" ]; then
      # If a regular directory exists (not a symlink), back it up
      if [ -d "$SKETCHYBAR_CONFIG_DIR" ] && [ ! -L "$SKETCHYBAR_CONFIG_DIR" ]; then
        $DRY_RUN_CMD mv "$SKETCHYBAR_CONFIG_DIR" "$SKETCHYBAR_CONFIG_DIR.backup"
        echo "Backed up existing config to: $SKETCHYBAR_CONFIG_DIR.backup"
      fi

      # Create or update the symlink
      if [ ! -L "$SKETCHYBAR_CONFIG_DIR" ] || [ "$(readlink "$SKETCHYBAR_CONFIG_DIR")" != "$REPO_CONFIG" ]; then
        $DRY_RUN_CMD ln -sfn "$REPO_CONFIG" "$SKETCHYBAR_CONFIG_DIR"
        echo "✓ Symlinked SketchyBar config to repo: config/sketchybar/"
        echo "  SketchyBar config: $SKETCHYBAR_CONFIG_DIR"
        echo "  Repo directory: $REPO_CONFIG"
      fi
    else
      echo "⚠️  Warning: SketchyBar config not found at: $REPO_CONFIG"
      echo "  Searched in: ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install"
    fi
  '';
}
