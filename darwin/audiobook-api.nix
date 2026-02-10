# ABOUTME: LaunchAgent for Audiobook API server (Power profile only)
# ABOUTME: Runs uvicorn on port 8767, accessible via localhost and Tailscale
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # ===========================================================================
  # AUDIOBOOK API SERVER LAUNCHAGENT
  # ===========================================================================
  # Starts audiobook-api FastAPI server at login on port 8767
  # Accessible via localhost and Tailscale (0.0.0.0 binding)
  # Depends on: qwen3-tts (:8765), whisper-stt (:8766)
  # Prerequisites: ~/Projects/audiobook-api with .venv and server.py

  launchd.user.agents.audiobook-api-serve = {
    serviceConfig = {
      Label = "com.audiobook-api.server";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "cd /Users/${userConfig.username}/Projects/audiobook-api && source .venv/bin/activate && exec uvicorn server:app --host 0.0.0.0 --port 8767"
      ];
      WorkingDirectory = "/Users/${userConfig.username}/Projects/audiobook-api";

      # Start at login and restart on crash
      RunAtLoad = true;
      KeepAlive = {SuccessfulExit = false;};

      # Logging configuration
      StandardOutPath = "/tmp/audiobook-api-serve.log";
      StandardErrorPath = "/tmp/audiobook-api-serve.err";

      # Prevent restart loops (10 second cooldown)
      ThrottleInterval = 10;

      # Environment
      EnvironmentVariables = {
        HOME = "/Users/${userConfig.username}";
        PATH = "/run/current-system/sw/bin:/etc/profiles/per-user/${userConfig.username}/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
      };
    };
  };
}
