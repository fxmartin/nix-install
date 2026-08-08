# ABOUTME: Installs the oMLX menubar inference server from its notarized DMG (Power profile only)
# ABOUTME: Pinned URL + SHA-256, with a Gatekeeper check before the app is copied into /Applications
#
# Why a DMG rather than Homebrew: oMLX has no cask, and its formula lives in an
# untrusted third-party tap (`jundot/omlx`). Homebrew refuses to load untrusted
# formulae, and the trust state lives in ~/.homebrew/trust.json — machine-local
# and undeclarable — so a fresh install would fail at `brew bundle`. The DMG
# carries an Apple-notarized Developer ID (Heejun Kim, PSK5Q5T46L), which is a
# stronger identity guarantee than a Ruby formula and is verifiable here.
#
# The formula also built a 1.6GB Python venv by resolving dozens of unpinned
# PyPI dependencies at install time. The DMG is a self-contained signed bundle.
#
# ⚠️ oMLX ships in-app auto-update. That means the installed version can drift
# away from the pin below without a rebuild — the same exception cmux, Stats and
# OpenUsage carry (see darwin/macos-defaults.nix). Disable it in the app's
# settings; if a preference key surfaces, pin it there alongside the others.
{
  pkgs,
  lib,
  profileName,
  userConfig,
  ...
}:
let
  omlxVersion = "0.5.7";

  homeDir = "/Users/${userConfig.username}";

  # macOS 26/27 build. The Sequoia (macos15) variant is a separate asset —
  # switch the filename if this ever runs on an older machine.
  omlxUrl = "https://github.com/jundot/omlx/releases/download/v${omlxVersion}/oMLX-${omlxVersion}-macos26-27.dmg";
  omlxSha256 = "30934506f0834943f97f040110ea26409b5c98812dcb7a4fa53eaa3bf35ef45f";

  appPath = "/Applications/oMLX.app";
in
lib.mkIf (profileName == "power") {
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "Checking oMLX (${omlxVersion})..."

    OMLX_INSTALLED=""
    if [ -d "${appPath}" ]; then
      OMLX_INSTALLED=$(/usr/bin/defaults read "${appPath}/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "")
    fi

    if [ "$OMLX_INSTALLED" = "${omlxVersion}" ]; then
      echo "✓ oMLX ${omlxVersion} already installed"
    else
      OMLX_TMP=$(/usr/bin/mktemp -d)
      OMLX_DMG="$OMLX_TMP/omlx.dmg"

      echo "  Downloading oMLX ${omlxVersion} (~788MB)..."
      # Every failure below is soft: an optional app must never take down a
      # rebuild, and activation runs under `set -e`.
      if ${pkgs.curl}/bin/curl -fsSL --max-time 1800 -o "$OMLX_DMG" "${omlxUrl}"; then
        ACTUAL=$(${pkgs.coreutils}/bin/sha256sum "$OMLX_DMG" | ${pkgs.coreutils}/bin/cut -d' ' -f1)

        if [ "$ACTUAL" != "${omlxSha256}" ]; then
          echo "⚠ oMLX checksum mismatch — refusing to install"
          echo "   expected ${omlxSha256}"
          echo "   actual   $ACTUAL"
        # Defence in depth: the checksum proves it is the file we pinned, and
        # spctl proves Apple still vouches for its signature (a notarisation
        # can be revoked after the fact).
        elif ! /usr/sbin/spctl -a -t install "$OMLX_DMG" >/dev/null 2>&1; then
          echo "⚠ oMLX DMG failed Gatekeeper verification — refusing to install"
        else
          OMLX_MNT="$OMLX_TMP/mnt"
          /bin/mkdir -p "$OMLX_MNT"
          if /usr/bin/hdiutil attach -nobrowse -readonly -mountpoint "$OMLX_MNT" "$OMLX_DMG" >/dev/null 2>&1; then
            /bin/rm -rf "${appPath}"
            if /bin/cp -R "$OMLX_MNT/oMLX.app" /Applications/; then
              echo "✓ oMLX ${omlxVersion} installed to ${appPath}"
            else
              echo "⚠ oMLX copy failed — the app was left as-is"
            fi
            /usr/bin/hdiutil detach "$OMLX_MNT" >/dev/null 2>&1 || true
          else
            echo "⚠ Could not mount the oMLX DMG — skipping"
          fi
        fi
      else
        echo "⚠ oMLX download failed — skipping (the installed app is untouched)"
      fi

      /bin/rm -rf "$OMLX_TMP"
    fi

    # Point the app at the shared local model root. OMLX_MODEL_DIR (see
    # darwin/configuration.nix) only reaches shell-launched processes — the
    # menubar app is launched by launchd, which never sources /etc/zshenv, so
    # the authoritative setting is ~/.omlx/settings.json. Patch it in place.
    # Soft-fail throughout: activation runs under `set -e`, and a missing
    # settings.json just means the app has never launched — the next rebuild
    # after first launch converges it.
    OMLX_SETTINGS="${homeDir}/.omlx/settings.json"
    OMLX_TARGET_DIR="${homeDir}/models/mlx"
    /bin/mkdir -p "$OMLX_TARGET_DIR"
    /usr/sbin/chown ${userConfig.username}:staff "${homeDir}/models" "$OMLX_TARGET_DIR"
    if [ -f "$OMLX_SETTINGS" ]; then
      OMLX_CURRENT=$(${pkgs.jq}/bin/jq -r '.model.model_dir // ""' "$OMLX_SETTINGS" 2>/dev/null || echo "")
      if [ "$OMLX_CURRENT" != "$OMLX_TARGET_DIR" ]; then
        OMLX_SETTINGS_TMP=$(/usr/bin/mktemp)
        if ${pkgs.jq}/bin/jq --arg dir "$OMLX_TARGET_DIR" \
             '.model.model_dir = $dir | .model.model_dirs = [$dir]' \
             "$OMLX_SETTINGS" > "$OMLX_SETTINGS_TMP" 2>/dev/null; then
          # cat-over, not mv: preserves the file's owner and 0600 mode
          /bin/cat "$OMLX_SETTINGS_TMP" > "$OMLX_SETTINGS"
          echo "✓ oMLX model_dir repointed at $OMLX_TARGET_DIR (was: ''${OMLX_CURRENT:-unset})"
          echo "  Quit oMLX, then move existing weights: mv ~/.omlx/models/* $OMLX_TARGET_DIR/"
        else
          echo "⚠ Could not patch oMLX settings.json — leaving it as-is"
        fi
        /bin/rm -f "$OMLX_SETTINGS_TMP"
      fi
    fi
  '';
}
