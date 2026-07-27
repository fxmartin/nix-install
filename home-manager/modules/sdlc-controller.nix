# ABOUTME: Installs the sdlc controller CLI from the claude-code-config submodule (issue #531)
# ABOUTME: Activation-time `uv tool install` — the autonomous-sdlc skills shell out to `sdlc`

# The `build-stories` and `fix-issue` skills are thin wrappers that shell out to
# an external `sdlc` binary; the orchestration lives in deterministic Python in
# `config/claude-code-config/controller/`, not in the prompts. Nothing deployed
# that binary, so a fresh machine got skills that could not run — the whole
# point of this repo being that a fresh install needs no manual intervention.
#
# Why `uv tool install` rather than a Nix derivation: the controller's
# dependencies are pinned in its own `uv.lock`, and it changes with every
# submodule bump. A `buildPythonApplication` would duplicate that pinning in
# Nix and need updating on each bump. Installing from the checkout tracks the
# submodule automatically and mirrors the path CI already exercises
# (`.github/workflows/skill-mirror-check.yml`), so the two agree.
#
# The trade-off is real and worth stating: the binary lands in `~/.local/bin`,
# outside the Nix store, so it is not atomic and not rolled back by a
# generation switch. `rebuild` is what keeps it current. `uv` itself is
# Nix-managed, which is the same bargain `darwin/configuration.nix` already
# strikes for osxphotos.
{
  config,
  pkgs,
  lib,
  findRepoRoot,
  ...
}:

{
  home.activation.sdlcController = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Shared helper from flake.nix extraSpecialArgs; sets $REPO_ROOT (or empty).
    ${findRepoRoot config.home.homeDirectory}

    if [ -n "$REPO_ROOT" ]; then
      CONTROLLER_DIR="$REPO_ROOT/config/claude-code-config/controller"

      if [ -d "$CONTROLLER_DIR" ]; then
        echo "Installing sdlc controller via uv..."
        # Invoked inside `if` so a non-zero exit is absorbed: activation runs
        # under `set -e` and a failed controller install must never take down
        # the whole rebuild. The installer owns the pinning and the failure
        # handling; it lives in scripts/ so tests/sdlc_controller_install.bats
        # can exercise the paths that broke activation twice.
        if UV_BIN=${pkgs.uv}/bin/uv $DRY_RUN_CMD bash \
             "$REPO_ROOT/scripts/install-sdlc-controller.sh" "$CONTROLLER_DIR"; then
          echo "✓ sdlc controller installed from $CONTROLLER_DIR"
        else
          echo "⚠ sdlc controller install failed — skills will report it" >&2
        fi
      else
        echo "⚠ sdlc controller not found at $CONTROLLER_DIR — is the submodule initialised?" >&2
      fi
    fi
  '';
}
