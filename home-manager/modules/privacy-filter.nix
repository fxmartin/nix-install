# ABOUTME: Home Manager module for OpenAI Privacy Filter (MLX port via OpenMed)
# ABOUTME: Provisions uv-managed venv, pins openmed[mlx,service], pre-pulls HF weights
{
  config,
  pkgs,
  lib,
  profileName ? "standard",
  ...
}: let
  # Pinned dependency coordinates. Bump only via `update` per repo philosophy
  # (CLAUDE.md: "All app updates ONLY via `rebuild` or `update` commands").
  openmedVersion = "1.2.0";
  mlxLmVersion = "0.21.0";

  # Variant selection: BF16 full precision on Power (M3 Max has the RAM),
  # 8-bit elsewhere (~1.4 GB cache, ~1.7× faster, fits 8/16 GB Airs).
  modelRepo =
    if profileName == "power"
    then "OpenMed/privacy-filter-mlx"
    else "OpenMed/privacy-filter-mlx-8bit";

  venvDir = "${config.home.homeDirectory}/.local/share/privacy-filter/venv";
  stateDir = "${config.home.homeDirectory}/.local/share/privacy-filter";
in {
  # =========================================================================
  # PRIVACY FILTER ENVIRONMENT VARIABLES
  # =========================================================================
  # Surface the chosen model + venv path so both the LaunchAgent (darwin module)
  # and ad-hoc CLI use agree on the same artifact without re-deriving from
  # profileName. HF_HOME pins the weight cache to the standard location so the
  # weekly digest's existing `huggingface` bucket continues to capture growth.
  home.sessionVariables = {
    OPENMED_PII_MODEL = modelRepo;
    PRIVACY_FILTER_VENV = venvDir;
    PRIVACY_FILTER_PORT = "7790";
  };

  # =========================================================================
  # ACTIVATION: create venv, install pinned openmed[mlx,service], pre-pull weights
  # =========================================================================
  # Runs every `home-manager switch` / `darwin-rebuild switch`. Idempotent —
  # short-circuits when the marker file matches the pinned versions.
  home.activation.privacyFilterSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -u

    VENV="${venvDir}"
    STATE="${stateDir}"
    MARKER="$STATE/.installed-${openmedVersion}-${mlxLmVersion}"
    MODEL="${modelRepo}"

    $DRY_RUN_CMD mkdir -p "$STATE"

    # uv is provided by darwin/configuration.nix; bail loudly if missing rather
    # than installing it ourselves (would fight the Nix-first policy).
    if ! command -v uv >/dev/null 2>&1; then
      echo "⚠️  uv not found — skipping privacy-filter setup."
      echo "   Ensure darwin/configuration.nix installs uv, then re-run rebuild."
      exit 0
    fi

    # On first install (or when pin changes) rebuild the venv from scratch.
    # Cheaper and more predictable than chasing partial-upgrade state.
    if [ ! -f "$MARKER" ]; then
      echo "→ Provisioning privacy-filter venv at $VENV"
      $DRY_RUN_CMD rm -rf "$VENV"
      $DRY_RUN_CMD uv venv --python 3.12 "$VENV" >/dev/null

      echo "→ Installing openmed==${openmedVersion} (mlx,service) and mlx-lm==${mlxLmVersion}"
      # VIRTUAL_ENV makes `uv pip install` target the venv without activation.
      VIRTUAL_ENV="$VENV" $DRY_RUN_CMD uv pip install \
        "openmed[mlx,service]==${openmedVersion}" \
        "mlx-lm==${mlxLmVersion}" \
        "huggingface-hub" >/dev/null

      $DRY_RUN_CMD touch "$MARKER"
      echo "✓ Privacy-filter venv ready"
    fi

    # Pre-pull weights so the LaunchAgent's first request doesn't block on
    # a multi-hundred-MB download. Idempotent — huggingface-cli no-ops on hit.
    # HF cache layout: ~/.cache/huggingface/hub/models--<org>--<name>/
    if [ -x "$VENV/bin/huggingface-cli" ]; then
      CACHE_DIR_NAME="models--$(printf '%s' "$MODEL" | sed 's|/|--|g')"
      if [ ! -d "$HOME/.cache/huggingface/hub/$CACHE_DIR_NAME" ]; then
        echo "→ Pre-pulling $MODEL (one-time, ~1.4-3 GB)"
        $DRY_RUN_CMD "$VENV/bin/huggingface-cli" download "$MODEL" \
          --quiet 2>/dev/null \
          || echo "⚠️  Weight pre-pull failed; daemon will retry on first request."
      fi
    fi

    echo "✓ Privacy filter (${profileName}): model=$MODEL, port=7790"
  '';
}
