# ABOUTME: LaunchAgent for Qwen3-TTS server (Power profile only)
# ABOUTME: Runs uvicorn on port 8765, accessible via localhost and Tailscale
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # ===========================================================================
  # QWEN3-TTS SERVER LAUNCHAGENT
  # ===========================================================================
  # Starts Qwen3-TTS FastAPI server at login on port 8765
  # Accessible via localhost and Tailscale (0.0.0.0 binding)
  # Prerequisites: ~/Projects/qwen3-tts with .venv and server.py

  launchd.user.agents.qwen3-tts-serve = {
    serviceConfig = {
      Label = "com.qwen3tts.server";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "cd /Users/${userConfig.username}/Projects/qwen3-tts && source .venv/bin/activate && exec uvicorn server:app --host 0.0.0.0 --port 8765"
      ];
      WorkingDirectory = "/Users/${userConfig.username}/Projects/qwen3-tts";

      # Start at login and restart on crash
      RunAtLoad = false;
      KeepAlive = false;

      # Logging configuration
      StandardOutPath = "/tmp/qwen3-tts-serve.log";
      StandardErrorPath = "/tmp/qwen3-tts-serve.err";

      # Prevent restart loops (10 second cooldown)
      ThrottleInterval = 10;

      # Environment
      EnvironmentVariables = {
        HOME = "/Users/${userConfig.username}";
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
      };
    };
  };
}
