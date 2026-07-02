# ABOUTME: Provisions local-code-bench MLX model server CLIs via a uv-managed venv
# ABOUTME: Installs local OpenAI-compatible benchmark inferencers for the power profile
{
  config,
  pkgs,
  lib,
  profileName ? "standard",
  ...
}:
let
  isPowerProfile = profileName == "power";
  dflashVersion = "0.1.8";
  turboquantVersion = "0.11.0";
  mlxLmVersion = "0.21.0";

  stateDir = "${config.home.homeDirectory}/.local/share/local-code-bench-servers";
  venvDir = "${stateDir}/venv";
  binDir = "${config.home.homeDirectory}/.local/bin";
  localCodeBenchRepo = "${config.home.homeDirectory}/dev/local-code-bench";
  uvBin = "${pkgs.uv}/bin/uv";
  pythonBin = "${pkgs.python312}/bin/python3";
in
{
  home.sessionVariables = {
    LOCAL_CODE_BENCH_SERVERS_VENV = venvDir;
    DFLASH_PORT = "8000";
    TURBOQUANT_PORT = "8002";
    DFLASH_COMMAND = "dflash serve -model mlx-community/Qwen3.6-27B-4bit -draft-model z-lab/Qwen3.6-27B-DFlash -host 127.0.0.1 -port 8000 -verify-mode adaptive -max-tokens 2048 -chat-template-args '{\\\"enable_thinking\\\": false}'";
    TURBOQUANT_COMMAND = "turboquant-serve --model manjunathshiva/Qwen3.6-35B-A3B-tq3-g32 --prompt-concurrency 1 --port 8002 --chat-template-args '{\\\"enable_thinking\\\": false}'";
  };

  home.activation.localCodeBenchServersSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -u

    STATE="${stateDir}"
    VENV="${venvDir}"
    BIN_DIR="${binDir}"
    LOCAL_CODE_BENCH_REPO="${localCodeBenchRepo}"
    MARKER="$STATE/.installed-dflash-${dflashVersion}-turboquant-${turboquantVersion}${lib.optionalString isPowerProfile "-power-inferencers-v1-mlx-lm-${mlxLmVersion}"}"
    PROJECT_MARKER="$STATE/.installed-local-code-bench-project-modules-mlx-lm-${mlxLmVersion}-mlc-v1"

    $DRY_RUN_CMD mkdir -p "$STATE" "$BIN_DIR"

    if [ ! -x "${uvBin}" ]; then
      echo "Warning: uv not found; skipping local-code-bench server CLI setup."
      echo "   Ensure darwin/configuration.nix installs uv, then re-run rebuild."
      exit 0
    fi

    NEEDS_CLI_INSTALL=0
    if [ ! -f "$MARKER" ] \
      || [ ! -x "$VENV/bin/dflash" ] \
      || [ ! -x "$VENV/bin/turboquant-serve" ]; then
      NEEDS_CLI_INSTALL=1
    fi
    ${lib.optionalString isPowerProfile ''
    if [ ! -x "$VENV/bin/vllm-mlx" ] || [ ! -x "$VENV/bin/mtplx" ]; then
      NEEDS_CLI_INSTALL=1
    fi
    ''}

    if [ "$NEEDS_CLI_INSTALL" = "1" ]; then
      echo "Provisioning local-code-bench server CLIs at $VENV"
      $DRY_RUN_CMD rm -rf "$VENV"
      $DRY_RUN_CMD env -u UV_NATIVE_TLS UV_SYSTEM_CERTS=1 UV_SYSTEM_PYTHON=0 \
        "${uvBin}" venv --python "${pythonBin}" "$VENV" >/dev/null

      echo "Installing local-code-bench server CLI packages"
      $DRY_RUN_CMD env -u UV_NATIVE_TLS UV_SYSTEM_CERTS=1 UV_SYSTEM_PYTHON=0 VIRTUAL_ENV="$VENV" \
        "${uvBin}" pip install \
        "dflash-mlx==${dflashVersion}" \
        "turboquant-mlx-full==${turboquantVersion}" \
        ${lib.optionalString isPowerProfile ''
        "vllm-mlx" \
        "mtplx" \
        ''} >/dev/null

      $DRY_RUN_CMD touch "$MARKER"
    fi

    for tool in dflash turboquant-serve ${lib.optionalString isPowerProfile "vllm-mlx mtplx"}; do
      if [ -x "$VENV/bin/$tool" ]; then
        $DRY_RUN_CMD ln -sfn "$VENV/bin/$tool" "$BIN_DIR/$tool"
      else
        echo "Warning: expected $tool in $VENV/bin, but it was not installed."
      fi
    done

    ${lib.optionalString isPowerProfile ''
    if [ -f "$LOCAL_CODE_BENCH_REPO/pyproject.toml" ]; then
      PROJECT_VENV="$LOCAL_CODE_BENCH_REPO/.venv"
      PROJECT_PYTHON="$PROJECT_VENV/bin/python"

      if [ ! -x "$PROJECT_PYTHON" ]; then
        echo "Creating local-code-bench project venv at $PROJECT_VENV"
        $DRY_RUN_CMD env -u UV_NATIVE_TLS UV_SYSTEM_CERTS=1 UV_SYSTEM_PYTHON=0 \
          "${uvBin}" venv --python "${pythonBin}" "$PROJECT_VENV" >/dev/null
      fi

      if [ ! -f "$PROJECT_MARKER" ] \
        || ! "$PROJECT_PYTHON" -c 'import mlx_lm, mlc_llm' >/dev/null 2>&1; then
        echo "Installing module-detected local-code-bench inferencers into $PROJECT_VENV"
        (
          cd "$LOCAL_CODE_BENCH_REPO"
          $DRY_RUN_CMD env -u UV_NATIVE_TLS UV_SYSTEM_CERTS=1 UV_SYSTEM_PYTHON=0 VIRTUAL_ENV="$PROJECT_VENV" \
            "${uvBin}" pip install --pre -U -f https://mlc.ai/wheels \
            "mlx-lm==${mlxLmVersion}" \
            "mlc-llm" \
            "mlc-ai" >/dev/null
        )
        $DRY_RUN_CMD touch "$PROJECT_MARKER"
      fi
    else
      echo "Warning: $LOCAL_CODE_BENCH_REPO not found; skipping module-detected inferencer setup."
      echo "   After cloning it, install mlx-lm and mlc-llm into that repo's uv environment."
    fi
    ''}

    echo "local-code-bench server CLIs ready: dflash ${dflashVersion}, turboquant-mlx-full ${turboquantVersion}${lib.optionalString isPowerProfile ", vllm-mlx, mtplx"}"
  '';
}
