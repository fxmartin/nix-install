# ABOUTME: LaunchAgent for Whisper STT server (Power profile only)
# ABOUTME: Runs uvicorn on port 8766, accessible via localhost and Tailscale
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # ===========================================================================
  # WHISPER STT SERVER LAUNCHAGENT
  # ===========================================================================
  # Starts mlx-whisper FastAPI server at login on port 8766
  # Accessible via localhost and Tailscale (0.0.0.0 binding)
  # Prerequisites: ~/Projects/whisper-stt with .venv and server.py

  launchd.user.agents.whisper-stt-serve = {
    serviceConfig = {
      Label = "com.whisper-stt.server";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "cd /Users/${userConfig.username}/Projects/whisper-stt && source .venv/bin/activate && exec uvicorn server:app --host 0.0.0.0 --port 8766"
      ];
      WorkingDirectory = "/Users/${userConfig.username}/Projects/whisper-stt";

      # Start at login and restart on crash
      RunAtLoad = true;
      KeepAlive = {SuccessfulExit = false;};

      # Logging configuration
      StandardOutPath = "/tmp/whisper-stt-serve.log";
      StandardErrorPath = "/tmp/whisper-stt-serve.err";

      # Prevent restart loops (10 second cooldown)
      ThrottleInterval = 10;

      # Environment (includes /opt/homebrew/bin for ffmpeg)
      EnvironmentVariables = {
        HOME = "/Users/${userConfig.username}";
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
      };
    };
  };
}
