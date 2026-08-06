# ABOUTME: Builds and installs the patched FluidVoice dictation app from its source checkout
# ABOUTME: Activation-time `xcodebuild` — local fork with the Auto-Enter per-app allowlist feature

# The app is FX's local fork of github.com/altic-dev/FluidVoice (GPLv3), branch
# feat/auto-enter-allowlist: on-device dictation (Parakeet via FluidAudio)
# patched to auto-press Return after insertion in allowlisted apps (cmux,
# Ghostty). This repo installs it instead of the upstream Homebrew cask so the
# patch survives fresh installs; do NOT add the `fluidvoice` cask alongside —
# two copies would race for the global hotkey.
#
# Why an activation build rather than a Nix derivation: same bargain as
# local-ai-menubar.nix — an .app bundle needs `xcodebuild`, which cannot run
# in the Nix sandbox, so the artifact lands outside the Nix store, is not
# atomic, and is not rolled back by a generation switch; `rebuild` keeps it
# current.
#
# Requires full Xcode, which only the Power profile installs. Other profiles
# skip with a log line rather than failing.
#
# Signing: the install script prefers an Apple Development identity (free
# Personal Team) so the Accessibility grant survives rebuilds, falling back
# to an unsigned build. The app needs Microphone + Accessibility permissions
# on first launch either way.
{
  config,
  pkgs,
  lib,
  findRepoRoot,
  ...
}:

let
  # Source checkout location. Searched rather than hardcoded so the module
  # works whether the repo is cloned to ~/dev or elsewhere.
  sourceCandidates = [
    "${config.home.homeDirectory}/dev/FluidVoice"
    "${config.home.homeDirectory}/FluidVoice"
    "${config.home.homeDirectory}/Documents/FluidVoice"
  ];
in
{
  home.activation.fluidVoice = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    APP_SRC=""
    for candidate in ${lib.concatStringsSep " " (map (p: ''"${p}"'') sourceCandidates)}; do
      if [ -f "$candidate/Fluid.xcodeproj/project.pbxproj" ]; then
        APP_SRC="$candidate"
        break
      fi
    done

    if [ -z "$APP_SRC" ]; then
      echo "• FluidVoice: no source checkout found — skipping"
    elif ! /usr/bin/xcodebuild -version >/dev/null 2>&1; then
      # Command Line Tools answer `xcode-select -p` but not `xcodebuild
      # -version`, which is the distinction that matters here.
      echo "• FluidVoice: full Xcode not available — skipping (Power profile installs it)"
    else
      echo "Building FluidVoice from $APP_SRC..."
      # Home Manager's activation PATH is Nix-only, but this build shells out
      # to system tools: install-app.sh runs `awk` to pick a signing identity,
      # and SwiftPM needs `unzip` to unpack the CTranscribe xcframework. Both
      # live in /usr/bin, and without them the build dies part-way through
      # dependency resolution (observed 2026-08-06). Appended rather than
      # prepended so Nix-provided tools still win where they exist.
      #
      # Invoked inside `if` so a non-zero exit is absorbed: activation runs
      # under `set -e`, and a failed optional app build must never take down
      # the whole rebuild.
      if PATH="$PATH:/usr/bin:/bin" $DRY_RUN_CMD bash "$APP_SRC/scripts/install-app.sh" "${config.home.homeDirectory}/Applications"; then
        echo "✓ FluidVoice installed to ~/Applications"
      else
        echo "⚠ FluidVoice build failed — the app was left as-is" >&2
      fi
    fi
  '';
}
