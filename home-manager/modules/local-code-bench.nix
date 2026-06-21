# ABOUTME: Provisions local-code-bench MLX model server CLIs via a uv-managed venv
# ABOUTME: Installs DFlash and TurboQuant entrypoints for local OpenAI-compatible benchmarks
{
  config,
  pkgs,
  lib,
  ...
}:
let
  dflashVersion = "0.1.8";
  turboquantVersion = "0.11.0";

  stateDir = "${config.home.homeDirectory}/.local/share/local-code-bench-servers";
  venvDir = "${stateDir}/venv";
  binDir = "${config.home.homeDirectory}/.local/bin";
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
    MARKER="$STATE/.installed-dflash-${dflashVersion}-turboquant-${turboquantVersion}"

    $DRY_RUN_CMD mkdir -p "$STATE" "$BIN_DIR"

    if [ ! -x "${uvBin}" ]; then
      echo "Warning: uv not found; skipping local-code-bench server CLI setup."
      echo "   Ensure darwin/configuration.nix installs uv, then re-run rebuild."
      exit 0
    fi

    if [ ! -f "$MARKER" ] || [ ! -x "$VENV/bin/dflash" ] || [ ! -x "$VENV/bin/turboquant-serve" ]; then
      echo "Provisioning local-code-bench server CLIs at $VENV"
      $DRY_RUN_CMD rm -rf "$VENV"
      $DRY_RUN_CMD env -u UV_NATIVE_TLS UV_SYSTEM_CERTS=1 UV_SYSTEM_PYTHON=0 \
        "${uvBin}" venv --python "${pythonBin}" "$VENV" >/dev/null

      echo "Installing dflash-mlx==${dflashVersion} and turboquant-mlx-full==${turboquantVersion}"
      $DRY_RUN_CMD env -u UV_NATIVE_TLS UV_SYSTEM_CERTS=1 UV_SYSTEM_PYTHON=0 VIRTUAL_ENV="$VENV" \
        "${uvBin}" pip install \
        "dflash-mlx==${dflashVersion}" \
        "turboquant-mlx-full==${turboquantVersion}" >/dev/null

      $DRY_RUN_CMD touch "$MARKER"
    fi

    for tool in dflash turboquant-serve; do
      if [ -x "$VENV/bin/$tool" ]; then
        $DRY_RUN_CMD ln -sfn "$VENV/bin/$tool" "$BIN_DIR/$tool"
      else
        echo "Warning: expected $tool in $VENV/bin, but it was not installed."
      fi
    done

    echo "local-code-bench server CLIs ready: dflash ${dflashVersion}, turboquant-mlx-full ${turboquantVersion}"
  '';
}
