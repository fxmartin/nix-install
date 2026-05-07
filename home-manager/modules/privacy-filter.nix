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
  torchVersion = "2.11.0";

  # Valid OpenMed PII registry models. OpenMed 1.2.0 references a preconverted
  # OpenMed/privacy-filter-mlx repo internally, but that HF repo is not public;
  # these registry-backed models are loadable today and can still run through
  # OpenMed's MLX conversion path after the first request.
  modelRepo =
    if profileName == "power"
    then "OpenMed/OpenMed-PII-SuperClinical-Large-434M-v1"
    else "OpenMed/OpenMed-PII-SuperClinical-Small-44M-v1";

  venvDir = "${config.home.homeDirectory}/.local/share/privacy-filter/venv";
  stateDir = "${config.home.homeDirectory}/.local/share/privacy-filter";
  uvBin = "${pkgs.uv}/bin/uv";
  pythonBin = "${pkgs.python312}/bin/python3";
in {
  # =========================================================================
  # PRIVACY FILTER ENVIRONMENT VARIABLES
  # =========================================================================
  # Surface the chosen model + venv path so both the LaunchAgent (darwin module)
  # and ad-hoc CLI use agree on the same artifact without re-deriving from
  # profileName. HF_HOME pins the weight cache to the standard location so the
  # weekly digest's existing `huggingface` bucket continues to capture growth.
  home.sessionVariables = {
    PRIVACY_FILTER_MODEL = modelRepo;
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
    MARKER="$STATE/.installed-${openmedVersion}-${mlxLmVersion}-${torchVersion}"
    MODEL="${modelRepo}"

    $DRY_RUN_CMD mkdir -p "$STATE"

    # uv is provided by Nix. Use the store path instead of activation PATH,
    # which may not include /run/current-system/sw/bin early in a rebuild.
    if [ ! -x "${uvBin}" ]; then
      echo "⚠️  uv not found — skipping privacy-filter setup."
      echo "   Ensure darwin/configuration.nix installs uv, then re-run rebuild."
      exit 0
    fi

    # On first install (or when pin changes) rebuild the venv from scratch.
    # Cheaper and more predictable than chasing partial-upgrade state.
    if [ ! -f "$MARKER" ]; then
      echo "→ Provisioning privacy-filter venv at $VENV"
      $DRY_RUN_CMD rm -rf "$VENV"
      $DRY_RUN_CMD "${uvBin}" venv --python "${pythonBin}" "$VENV" >/dev/null

      echo "→ Installing openmed==${openmedVersion} (mlx,service), mlx-lm==${mlxLmVersion}, and torch==${torchVersion}"
      # VIRTUAL_ENV makes `uv pip install` target the venv without activation.
      VIRTUAL_ENV="$VENV" $DRY_RUN_CMD "${uvBin}" pip install \
        "openmed[mlx,service]==${openmedVersion}" \
        "mlx-lm==${mlxLmVersion}" \
        "torch==${torchVersion}" \
        "huggingface-hub" >/dev/null

      $DRY_RUN_CMD touch "$MARKER"
      echo "✓ Privacy-filter venv ready"
    fi

    # Pre-pull weights so the LaunchAgent's first request doesn't block on
    # a multi-hundred-MB download. Idempotent — huggingface-cli no-ops on hit.
    # HF cache layout: ~/.cache/huggingface/hub/models--<org>--<name>/
    if [ -x "$VENV/bin/hf" ]; then
      CACHE_DIR_NAME="models--$(printf '%s' "$MODEL" | sed 's|/|--|g')"
      if [ ! -d "$HOME/.cache/huggingface/hub/$CACHE_DIR_NAME" ]; then
        echo "→ Pre-pulling $MODEL (one-time, ~1.4-3 GB)"
        $DRY_RUN_CMD "$VENV/bin/hf" download "$MODEL" \
          --quiet 2>/dev/null \
          || echo "⚠️  Weight pre-pull failed; daemon will retry on first request."
      fi
    fi

    echo "✓ Privacy filter (${profileName}): model=$MODEL, port=7790"
  '';
}
