# ABOUTME: Calibre configuration deployment for ebook management
# ABOUTME: Deploys pre-configured plugins (DeDRM, KFX, DeACSM) from repo to system
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
  # Kindle Oasis serial number pre-configured in dedrm.json

  system.activationScripts.postActivation.text = lib.mkAfter ''
    # ========================================================================
    # CALIBRE CONFIGURATION DEPLOYMENT
    # ========================================================================
    CALIBRE_SRC="/Users/${userConfig.username}/${userConfig.directories.dotfiles}/config/calibre"
    CALIBRE_DST="/Users/${userConfig.username}/Library/Preferences/calibre"

    if [[ -d "$CALIBRE_SRC" ]]; then
      echo "Deploying Calibre configuration..."
      mkdir -p "$CALIBRE_DST"

      # Copy global settings if exists
      if [[ -f "$CALIBRE_SRC/global.py.json" ]]; then
        cp "$CALIBRE_SRC/global.py.json" "$CALIBRE_DST/"
        echo "✓ Calibre global settings deployed"
      fi

      # Copy plugins directory if exists
      if [[ -d "$CALIBRE_SRC/plugins" ]]; then
        # Use rsync-like behavior: copy contents, preserve structure
        cp -r "$CALIBRE_SRC/plugins" "$CALIBRE_DST/"
        echo "✓ Calibre plugins deployed (DeDRM, KFX, DeACSM)"
      fi

      # Set correct ownership
      chown -R ${userConfig.username}:staff "$CALIBRE_DST"
      echo "✓ Calibre configuration complete"
    else
      echo "⚠ Calibre config not found at $CALIBRE_SRC (optional)"
    fi
  '';
}
