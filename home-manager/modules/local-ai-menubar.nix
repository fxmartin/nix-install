# ABOUTME: Builds and installs the Local AI menubar app from its source checkout
# ABOUTME: Activation-time `xcodebuild` — the app owns Ollama's lifecycle on this machine

# The app (github.com/fxmartin/local-ai-menubar-app) is a SwiftUI `MenuBarExtra`
# that supervises `ollama serve`, manages models, and launches Open WebUI. This
# repo installs it because the alternative — a manual Xcode build per machine —
# defeats the point of a fresh install needing no manual intervention.
#
# Why an activation build rather than a Nix derivation: the app is an .app
# bundle whose asset catalog is compiled by `xcodebuild`, which cannot run in a
# Nix sandbox (Xcode is not a Nix package), and `pkgs.swift` on Darwin is
# currently broken in this nixpkgs pin — see the marksman note in
# `darwin/configuration.nix`. This mirrors the bargain already struck for the
# sdlc controller and mlx-lm: the artifact lands outside the Nix store, so it is
# not atomic and not rolled back by a generation switch; `rebuild` keeps it
# current. Revisit a real derivation when Swift on Darwin is usable in nixpkgs —
# `darwin/configuration.nix`'s /Applications aliasing already handles bundle
# placement for any package that produces one.
#
# Requires full Xcode (Command Line Tools alone cannot build an .app bundle),
# which only the Power profile installs. Other profiles skip with a log line
# rather than failing: a missing optional app must never abort a rebuild.
#
# **Ollama ownership**: this app starts and stops `ollama serve` itself. Nothing
# in this repo may do the same — an always-on LaunchAgent would make the app's
# Stop button impossible to honour, and an activation `pkill` would trip its
# crash detection. `tests/flake_ollama_activation.bats` pins that invariant.
{
  config,
  pkgs,
  lib,
  findRepoRoot,
  ...
}:

let
  # Source checkout location. Searched rather than hardcoded so the module
  # works whether the repo is cloned to ~/dev or elsewhere, mirroring
  # findRepoRoot's own convention for this repo.
  sourceCandidates = [
    "${config.home.homeDirectory}/dev/local-ai-menubar-app"
    "${config.home.homeDirectory}/local-ai-menubar-app"
    "${config.home.homeDirectory}/Documents/local-ai-menubar-app"
  ];
in
{
  home.activation.localAIMenubar = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    APP_SRC=""
    for candidate in ${lib.concatStringsSep " " (map (p: ''"${p}"'') sourceCandidates)}; do
      if [ -f "$candidate/LocalAIMenubar.xcodeproj/project.pbxproj" ]; then
        APP_SRC="$candidate"
        break
      fi
    done

    if [ -z "$APP_SRC" ]; then
      echo "• Local AI menubar: no source checkout found — skipping"
    elif ! /usr/bin/xcodebuild -version >/dev/null 2>&1; then
      # Command Line Tools answer `xcode-select -p` but not `xcodebuild
      # -version`, which is the distinction that matters here.
      echo "• Local AI menubar: full Xcode not available — skipping (Power profile installs it)"
    else
      echo "Building Local AI menubar from $APP_SRC..."
      # Invoked inside `if` so a non-zero exit is absorbed: activation runs
      # under `set -e`, and a failed optional app build must never take down
      # the whole rebuild.
      if $DRY_RUN_CMD bash "$APP_SRC/scripts/install-app.sh" "${config.home.homeDirectory}/Applications"; then
        echo "✓ Local AI menubar installed to ~/Applications"
      else
        echo "⚠ Local AI menubar build failed — the app was left as-is" >&2
      fi
    fi
  '';
}
