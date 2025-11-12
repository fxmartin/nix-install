# ABOUTME: VSCode configuration for industry-standard code editing with Catppuccin theming
# ABOUTME: Automatically symlinks settings to repository for bidirectional sync (REQ-NFR-008 compliant)
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # VSCode Configuration
  # Story 02.2-002: Install and configure VSCode with Catppuccin theme
  #
  # Installation: Via Homebrew cask (darwin/homebrew.nix)
  # Configuration: Symlinked to repo for bidirectional sync
  #
  # REQ-NFR-008 Compliance Pattern:
  # - DO NOT use programs.vscode.userSettings (creates read-only /nix/store symlink)
  # - DO use home.activation script to symlink to repo working directory
  #
  # Why this approach (Issue #26 resolution):
  # - VSCode expects to manage its own settings.json file (needs write access)
  # - Home Manager's programs.vscode.userSettings creates read-only symlinks to /nix/store (breaks VSCode)
  # - Solution: Symlink to repo working directory (not /nix/store)
  #
  # How it works:
  # 1. Settings file in repo: config/vscode/settings.json (version controlled)
  # 2. Activation script dynamically finds repo location
  #    - Searches: ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install
  #    - Works with any NIX_INSTALL_DIR from bootstrap
  # 3. Creates symlink: ~/Library/Application Support/Code/User/settings.json -> $REPO_ROOT/config/vscode/settings.json
  # 4. Bidirectional sync:
  #    - Changes in VSCode → Instantly appear in repo (git will show them)
  #    - Changes in repo (git pull) → Instantly apply to VSCode
  #    - Settings version controlled, can commit/revert changes
  # 5. VSCode has full write access (symlink points to regular file, not /nix/store)
  #
  # Key Features (from template):
  # - Catppuccin Mocha theme (dark mode)
  # - JetBrains Mono Nerd Font with ligatures
  # - Auto-update disabled (updates via 'rebuild' command only)
  # - Git integration, telemetry disabled, terminal integration
  # - Language-specific settings for Nix, Python, Markdown, JSON

  # Activation script to symlink VSCode settings to repo (bidirectional sync)
  home.activation.vscodeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    VSCODE_CONFIG_DIR="$HOME/Library/Application Support/Code/User"
    VSCODE_SETTINGS="$VSCODE_CONFIG_DIR/settings.json"

    # Dynamically find repo location (works with any NIX_INSTALL_DIR)
    # Search for nix-install repo by looking for flake.nix + config/vscode directory
    REPO_ROOT=""
    for candidate in "${config.home.homeDirectory}/nix-install" \
                     "${config.home.homeDirectory}/.config/nix-install" \
                     "${config.home.homeDirectory}/Documents/nix-install"; do
      if [ -f "$candidate/flake.nix" ] && [ -d "$candidate/config/vscode" ]; then
        REPO_ROOT="$candidate"
        break
      fi
    done

    # Fallback to default if not found
    if [ -z "$REPO_ROOT" ]; then
      REPO_ROOT="${config.home.homeDirectory}/nix-install"
    fi

    REPO_SETTINGS="$REPO_ROOT/config/vscode/settings.json"

    # Create config directory if it doesn't exist
    if [ ! -d "$VSCODE_CONFIG_DIR" ]; then
      $DRY_RUN_CMD mkdir -p "$VSCODE_CONFIG_DIR"
      echo "Created VSCode config directory: $VSCODE_CONFIG_DIR"
    fi

    # Create/update symlink to repo settings (bidirectional sync)
    if [ ! -L "$VSCODE_SETTINGS" ]; then
      # If regular file exists, back it up first
      if [ -f "$VSCODE_SETTINGS" ]; then
        $DRY_RUN_CMD mv "$VSCODE_SETTINGS" "$VSCODE_SETTINGS.backup"
        echo "Backed up existing settings to: $VSCODE_SETTINGS.backup"
      fi

      if [ -f "$REPO_SETTINGS" ]; then
        $DRY_RUN_CMD ln -sf "$REPO_SETTINGS" "$VSCODE_SETTINGS"
        echo "✓ Symlinked VSCode settings to repo: config/vscode/settings.json"
        echo "  VSCode settings: $VSCODE_SETTINGS"
        echo "  Repo file: $REPO_SETTINGS"
        echo "  ✓ Bidirectional sync: Changes in VSCode appear in repo, and vice versa"
      else
        echo "⚠️  Warning: VSCode settings template not found at: $REPO_SETTINGS"
        echo "  Searched in: ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install"
        echo "  VSCode will use default settings on first launch"
      fi
    else
      # Symlink exists, verify it points to the right place
      CURRENT_TARGET=$(readlink "$VSCODE_SETTINGS")
      if [ "$CURRENT_TARGET" != "$REPO_SETTINGS" ]; then
        $DRY_RUN_CMD ln -sf "$REPO_SETTINGS" "$VSCODE_SETTINGS"
        echo "Updated VSCode settings symlink target to: $REPO_SETTINGS"
      fi
    fi

    # Auto-install required VSCode extensions (Issue #28)
    # Extensions must be installed for full functionality:
    #   1. Catppuccin Theme (provides Mocha/Latte themes)
    #   2. Auto Dark Mode (automatic theme switching based on macOS appearance)
    #
    # Why automation: Aligns with project goal of "zero manual intervention"
    # Extension installation via VSCode CLI is idempotent and safe

    # Check if VSCode CLI is available
    if command -v code &> /dev/null; then
      echo ""
      echo "Installing VSCode extensions..."

      # Extension IDs
      CATPPUCCIN_EXT="Catppuccin.catppuccin-vsc"
      AUTO_DARK_MODE_EXT="LinusU.auto-dark-mode"

      # Function to check if extension is already installed
      is_extension_installed() {
        local ext_id="$1"
        code --list-extensions 2>/dev/null | grep -q "^''${ext_id}$"
      }

      # Install Catppuccin Theme (MUST be first - provides the themes)
      if is_extension_installed "$CATPPUCCIN_EXT"; then
        echo "  ✓ Catppuccin Theme already installed"
      else
        echo "  Installing Catppuccin Theme..."
        if $DRY_RUN_CMD code --install-extension "$CATPPUCCIN_EXT" --force &> /dev/null; then
          echo "  ✓ Catppuccin Theme installed successfully"
        else
          echo "  ⚠️  Warning: Failed to install Catppuccin Theme"
          echo "     Manual installation: Open VSCode → Extensions (Cmd+Shift+X) → Search 'Catppuccin'"
        fi
      fi

      # Install Auto Dark Mode (MUST be second - uses the themes)
      if is_extension_installed "$AUTO_DARK_MODE_EXT"; then
        echo "  ✓ Auto Dark Mode already installed"
      else
        echo "  Installing Auto Dark Mode..."
        if $DRY_RUN_CMD code --install-extension "$AUTO_DARK_MODE_EXT" --force &> /dev/null; then
          echo "  ✓ Auto Dark Mode installed successfully"
          echo "  ✓ VSCode will now auto-switch themes based on macOS system appearance"
          echo "     • Light Mode → Catppuccin Latte"
          echo "     • Dark Mode → Catppuccin Mocha"
        else
          echo "  ⚠️  Warning: Failed to install Auto Dark Mode"
          echo "     Manual installation: Open VSCode → Extensions (Cmd+Shift+X) → Search 'Auto Dark Mode'"
        fi
      fi

      echo "✓ VSCode extension installation complete"
    else
      echo ""
      echo "⚠️  VSCode CLI 'code' command not found"
      echo "   Extensions will not be auto-installed"
      echo "   Solution: Launch VSCode once, then run 'darwin-rebuild' again"
      echo "   OR manually install extensions:"
      echo "     1. Open VSCode → Extensions (Cmd+Shift+X)"
      echo "     2. Search 'Catppuccin' → Install 'Catppuccin for VSCode'"
      echo "     3. Search 'Auto Dark Mode' → Install 'Auto Dark Mode' by LinusU"
    fi
  '';

  # Optional: Install VSCode-compatible language servers via Home Manager
  # Epic-04 will add language servers for development environment
  # Examples: nixd (Nix LSP), pyright (Python), bash-language-server
  home.packages = with pkgs; [
    # Language servers will be added in Epic-04 Development Environment
  ];
}
