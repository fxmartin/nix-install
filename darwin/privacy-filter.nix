# ABOUTME: LaunchAgent for OpenAI Privacy Filter (MLX) localhost HTTP server
# ABOUTME: Runs uvicorn-served openmed.service.app on 127.0.0.1:7790, MLX backend
{
  config,
  pkgs,
  lib,
  userConfig,
  profileName ? "standard",
  ...
}:
let
  homeDir = "/Users/${userConfig.username}";
  venvDir = "${homeDir}/.local/share/privacy-filter/venv";

  # Mirror the model choice from home-manager/modules/privacy-filter.nix.
  # Both modules derive from profileName independently — keep these in sync.
  modelRepo =
    if profileName == "power" then
      "OpenMed/OpenMed-PII-SuperClinical-Large-434M-v1"
    else
      "OpenMed/OpenMed-PII-SuperClinical-Small-44M-v1";
in
{
  # =========================================================================
  # PRIVACY FILTER LAUNCHAGENT
  # =========================================================================
  # Always-on localhost-only PII redaction service. Bound to 127.0.0.1 — never
  # exposed to Tailscale (PII data is by definition sensitive; keep it on-host).
  #
  # Endpoints (per OpenMed FastAPI service):
  #   GET  /health               liveness
  #   POST /pii/extract          {text} → {entities:[{label,word,start,end}]}
  #   POST /pii/deidentify       {text, method:"mask"|"replace"} → {redacted}
  #
  # The first request after boot triggers MLX model load (~1-3 s). The Viterbi
  # decoder + BIOES head then run ~14 ms per ~10-token input on M-series GPU.

  launchd.user.agents.privacy-filter = {
    serviceConfig = {
      Label = "org.nixos.privacy-filter";
      ProgramArguments = [
        "${venvDir}/bin/uvicorn"
        "openmed.service.app:app"
        "--host"
        "127.0.0.1"
        "--port"
        "7790"
      ];

      # Start at login, restart on crash — but throttle to avoid loops if the
      # venv is broken (e.g. mid-rebuild on a fresh machine).
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
      };
      ThrottleInterval = 30;

      StandardOutPath = "/tmp/privacy-filter.log";
      StandardErrorPath = "/tmp/privacy-filter.err";

      # Pin the model and HF cache location so behavior matches what the
      # home-manager activation pre-pulled. PATH includes Nix profile + Homebrew
      # so uvicorn can find python and any system tools openmed shells out to.
      EnvironmentVariables = {
        HOME = homeDir;
        PATH = "${venvDir}/bin:/etc/profiles/per-user/${userConfig.username}/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/bin:/bin";
        PRIVACY_FILTER_MODEL = modelRepo;
        HF_HOME = "${homeDir}/.cache/huggingface";
        # MLX picks up the Metal device automatically on aarch64-darwin; no
        # explicit device flag needed. Tokenizer parallelism off to avoid
        # log spam from forking under launchd.
        TOKENIZERS_PARALLELISM = "false";
      };
    };
  };
}
