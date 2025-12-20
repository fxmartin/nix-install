# ABOUTME: Calibre configuration deployment for ebook management
# ABOUTME: Deploys pre-configured plugins (DeDRM, KFX, DeACSM) from repo to system
# ABOUTME: Secrets (Kindle serial, Adobe keys, API keys) loaded from ~/.config/calibre-secrets/
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # ===========================================================================
  # CALIBRE CONFIGURATION DEPLOYMENT
  # ===========================================================================
  # Copies Calibre plugins and settings from nix-install repo to system location
  # Includes: DeDRM (Kindle DRM removal), KFX Input/Output, DeACSM (Adobe DRM)
  #
  # SECRETS HANDLING:
  # - Plugin .zip files and non-sensitive configs: config/calibre/ (in repo)
  # - Sensitive data (Kindle serial, Adobe keys, API keys): ~/.config/calibre-secrets/ (local only)
  #   - dedrm.json (Kindle serial, Adobe adeptkeys)
  #   - bookfusion.json (BookFusion API key)
  #   - DeACSM/account/ (Adobe activation data)

  system.activationScripts.postActivation.text = lib.mkAfter ''
    # ========================================================================
    # CALIBRE CONFIGURATION DEPLOYMENT
    # ========================================================================
    CALIBRE_SRC="/Users/${userConfig.username}/${userConfig.directories.dotfiles}/config/calibre"
    CALIBRE_DST="/Users/${userConfig.username}/Library/Preferences/calibre"
    CALIBRE_SECRETS="/Users/${userConfig.username}/.config/calibre-secrets"

    if [[ -d "$CALIBRE_SRC" ]]; then
      echo "Deploying Calibre configuration..."
      mkdir -p "$CALIBRE_DST"
      mkdir -p "$CALIBRE_DST/plugins"

      # Copy global settings if exists
      if [[ -f "$CALIBRE_SRC/global.py.json" ]]; then
        cp "$CALIBRE_SRC/global.py.json" "$CALIBRE_DST/"
        echo "✓ Calibre global settings deployed"
      fi

      # Copy plugins directory if exists (non-sensitive files)
      if [[ -d "$CALIBRE_SRC/plugins" ]]; then
        cp -r "$CALIBRE_SRC/plugins"/* "$CALIBRE_DST/plugins/"
        echo "✓ Calibre plugins deployed (DeDRM, KFX, DeACSM)"
      fi

      # Merge secrets from local config (not in git)
      if [[ -d "$CALIBRE_SECRETS" ]]; then
        # DeDRM config with Kindle serial and Adobe keys
        if [[ -f "$CALIBRE_SECRETS/dedrm.json" ]]; then
          cp "$CALIBRE_SECRETS/dedrm.json" "$CALIBRE_DST/plugins/"
          echo "✓ DeDRM secrets merged (Kindle serial, Adobe keys)"
        fi

        # BookFusion API key
        if [[ -f "$CALIBRE_SECRETS/bookfusion.json" ]]; then
          cp "$CALIBRE_SECRETS/bookfusion.json" "$CALIBRE_DST/plugins/"
          echo "✓ BookFusion secrets merged (API key)"
        fi

        # DeACSM Adobe account data
        if [[ -d "$CALIBRE_SECRETS/DeACSM/account" ]]; then
          mkdir -p "$CALIBRE_DST/plugins/DeACSM/account"
          cp -r "$CALIBRE_SECRETS/DeACSM/account"/* "$CALIBRE_DST/plugins/DeACSM/account/"
          echo "✓ DeACSM secrets merged (Adobe activation)"
        fi
      else
        echo "⚠ Calibre secrets not found at $CALIBRE_SECRETS"
        echo "  Create with: mkdir -p ~/.config/calibre-secrets/DeACSM/account"
        echo "  Then add dedrm.json, bookfusion.json, and DeACSM/account/ files"
      fi

      # Set correct ownership and permissions
      chown -R ${userConfig.username}:staff "$CALIBRE_DST"
      chmod 700 "$CALIBRE_DST/plugins"
      echo "✓ Calibre configuration complete"
    else
      echo "⚠ Calibre config not found at $CALIBRE_SRC (optional)"
    fi
  '';
}
