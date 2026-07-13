# ABOUTME: Provisions the supported Apple-native MLX-LM runtime on Apple Silicon
# ABOUTME: Keeps MLX-LM isolated in a pinned uv-managed environment
{
  config,
  pkgs,
  lib,
  ...
}:
let
  isAppleSilicon = pkgs.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isAarch64;
  mlxLmVersion = "0.21.0";
  stateDir = "${config.home.homeDirectory}/.local/share/mlx-lm";
  venvDir = "${stateDir}/venv";
  binDir = "${config.home.homeDirectory}/.local/bin";
  uvBin = "${pkgs.uv}/bin/uv";
  pythonBin = "${pkgs.python312}/bin/python3";
in
{
  config = lib.mkIf isAppleSilicon {
    home.sessionVariables.MLX_LM_VENV = venvDir;

    home.activation.mlxLmSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      set -eu

      STATE="${stateDir}"
      VENV="${venvDir}"
      BIN_DIR="${binDir}"
      MARKER="$STATE/.installed-${mlxLmVersion}"

      $DRY_RUN_CMD mkdir -p "$STATE" "$BIN_DIR"

      if [ ! -x "${uvBin}" ]; then
        echo "MLX-LM setup failed: uv is unavailable at ${uvBin}." >&2
        exit 1
      fi

      if [ ! -f "$MARKER" ] || [ ! -x "$VENV/bin/mlx_lm.generate" ]; then
        echo "Provisioning MLX-LM ${mlxLmVersion} at $VENV"
        $DRY_RUN_CMD rm -rf "$VENV"
        $DRY_RUN_CMD env -u UV_NATIVE_TLS UV_SYSTEM_CERTS=1 UV_SYSTEM_PYTHON=0 \
          "${uvBin}" venv --python "${pythonBin}" "$VENV" >/dev/null
        $DRY_RUN_CMD env -u UV_NATIVE_TLS UV_SYSTEM_CERTS=1 UV_SYSTEM_PYTHON=0 VIRTUAL_ENV="$VENV" \
          "${uvBin}" pip install "mlx-lm==${mlxLmVersion}" >/dev/null
        $DRY_RUN_CMD touch "$MARKER"
      fi

      for command_name in \
        mlx_lm.generate \
        mlx_lm.chat \
        mlx_lm.server \
        mlx_lm.convert \
        mlx_lm.manage; do
        command_path="$VENV/bin/$command_name"
        if [ ! -x "$command_path" ]; then
          echo "MLX-LM setup failed: expected command is missing: $command_path" >&2
          exit 1
        fi
        $DRY_RUN_CMD ln -sfn "$command_path" "$BIN_DIR/$command_name"
      done

      echo "MLX-LM ${mlxLmVersion} is ready"
    '';
  };
}
