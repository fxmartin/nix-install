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

        # `uv tool install` has no --locked/--frozen: it re-resolves from
        # pyproject.toml and ignores the committed uv.lock, so the installed
        # dependency set drifts from the one the controller's tests ran
        # against. That is not hypothetical — the lockfile pins
        # annotated-types==0.7.0 and an unpinned install resolved 0.8.0.
        # Export the lockfile to a constraints file and feed it to the
        # install, so a rebuild reproduces the locked set.
        CONSTRAINTS="$(mktemp -t sdlc-controller-constraints)"
        if (cd "$CONTROLLER_DIR" && ${pkgs.uv}/bin/uv export \
              --frozen --no-emit-project --no-hashes \
              --format requirements-txt) > "$CONSTRAINTS" 2>/dev/null; then
          UV_PIN_ARGS="-c $CONSTRAINTS"
        else
          # Reproducibility is the point of this repo, so say plainly that we
          # are proceeding without it rather than installing silently unpinned.
          echo "⚠ could not export uv.lock — installing unpinned, versions may drift" >&2
          UV_PIN_ARGS=""
        fi

        # --force so a submodule bump actually replaces the installed build:
        # without it uv keeps the existing tool and the CLI silently lags the
        # checkout, which has bitten before (a stale `sdlc` missing a flag the
        # skills had started passing).
        # shellcheck disable=SC2086  # UV_PIN_ARGS is intentionally word-split
        if $DRY_RUN_CMD ${pkgs.uv}/bin/uv tool install --force $UV_PIN_ARGS "$CONTROLLER_DIR" 2>&1; then
          echo "✓ sdlc controller installed from $CONTROLLER_DIR"
        else
          # Non-fatal: a failed install must not break the whole activation.
          # The skills degrade to an actionable error naming this install
          # command, rather than the rebuild dying here.
          echo "⚠ sdlc controller install failed (retry: uv tool install --force $CONTROLLER_DIR)" >&2
        fi
        rm -f "$CONSTRAINTS"
      else
        echo "⚠ sdlc controller not found at $CONTROLLER_DIR — is the submodule initialised?" >&2
      fi
    fi
  '';
}
