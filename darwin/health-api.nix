# ABOUTME: LaunchAgent for health check HTTP API server
# ABOUTME: Runs Python HTTP server on port 7780, accessible via localhost and Tailscale
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: let
  scriptsDir = "/Users/${userConfig.username}/.local/bin";
in {
  # ===========================================================================
  # HEALTH API SERVER LAUNCHAGENT
  # ===========================================================================
  # Starts a lightweight Python HTTP server at login on port 7780
  # Endpoints: /health (diagnostics), /metrics (Apple Silicon stats), /ping (liveness)
  # Accessible via localhost and Tailscale (0.0.0.0 binding)
  # Zero dependencies - uses Python 3.12 stdlib http.server

  launchd.user.agents.health-api = {
    serviceConfig = {
      Label = "org.nixos.health-api";
      ProgramArguments = [
        "${pkgs.python312}/bin/python3"
        "${scriptsDir}/health-api.py"
      ];

      # Start at login and restart on crash
      RunAtLoad = true;
      KeepAlive = {SuccessfulExit = false;};

      # Logging configuration
      StandardOutPath = "/tmp/health-api.log";
      StandardErrorPath = "/tmp/health-api.err";

      # Prevent restart loops (10 second cooldown)
      ThrottleInterval = 10;

      # Environment
      EnvironmentVariables = {
        HOME = "/Users/${userConfig.username}";
        PATH = "/etc/profiles/per-user/${userConfig.username}/bin:/opt/homebrew/bin:/run/current-system/sw/bin:/usr/bin:/usr/sbin:/bin";
      };
    };
  };
}
