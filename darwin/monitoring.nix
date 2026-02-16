# ABOUTME: LaunchAgent for Beszel monitoring agent (system resource metrics)
# ABOUTME: Runs Beszel agent with nice -n 10 to prevent macOS IOKit throttling
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: let
  scriptsDir = "/Users/${userConfig.username}/.local/bin";
  configDir = "/Users/${userConfig.username}/.config/beszel";

  # Standard PATH for LaunchAgents (includes per-user Nix profile)
  agentPath = "/etc/profiles/per-user/${userConfig.username}/bin:/opt/homebrew/bin:/run/current-system/sw/bin:/usr/bin:/usr/sbin:/bin";
  agentHome = "/Users/${userConfig.username}";
in {
  # ===========================================================================
  # BESZEL AGENT LAUNCHAGENT
  # ===========================================================================
  # Collects system resource metrics (CPU, memory, disk, network) and ships
  # them to a Beszel hub for time-series graphing and alerting.
  #
  # The agent listens on port 45876 and requires a KEY from the Beszel hub.
  # Configuration is stored in ~/.config/beszel/beszel-agent.env
  #
  # Uses a bash wrapper to:
  #   1. Source env file (KEY, PORT) — LaunchAgents don't support EnvironmentFile
  #   2. Run with nice -n 10 to prevent macOS IOKit throttling on battery

  launchd.user.agents.beszel-agent = {
    serviceConfig = {
      Label = "org.nixos.beszel-agent";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        ''
          # Source environment variables (KEY, PORT) from config file
          ENV_FILE="${configDir}/beszel-agent.env"
          if [ -f "$ENV_FILE" ]; then
            set -a
            . "$ENV_FILE"
            set +a
          fi

          # Only run if KEY is configured
          if [ -z "$KEY" ]; then
            echo "Beszel agent KEY not configured. Edit $ENV_FILE" >&2
            exit 1
          fi

          # Run agent with reduced priority to avoid IOKit throttling
          exec /usr/bin/nice -n 10 ${scriptsDir}/beszel-agent
        ''
      ];

      # Start at login and restart on crash
      RunAtLoad = true;
      KeepAlive = {SuccessfulExit = false;};

      # Logging configuration
      StandardOutPath = "/tmp/beszel-agent.log";
      StandardErrorPath = "/tmp/beszel-agent.err";

      # Prevent restart loops (30 second cooldown — gives time to configure KEY)
      ThrottleInterval = 30;

      # Environment
      EnvironmentVariables = {
        HOME = agentHome;
        PATH = agentPath;
      };
    };
  };

  # Activation script to install Beszel agent binary and create config
  system.activationScripts.postActivation.text = lib.mkAfter ''
    # ========================================================================
    # BESZEL AGENT SETUP
    # ========================================================================
    echo "Setting up Beszel monitoring agent..."

    BESZEL_BIN="/Users/${userConfig.username}/.local/bin/beszel-agent"
    BESZEL_ENV="/Users/${userConfig.username}/.config/beszel/beszel-agent.env"

    # Download agent binary if not present
    if [ ! -f "$BESZEL_BIN" ]; then
      echo "Downloading Beszel agent..."
      ARCH=$(uname -m | sed 's/x86_64/amd64/')
      TARBALL_URL="https://github.com/henrygd/beszel/releases/latest/download/beszel-agent_Darwin_$ARCH.tar.gz"
      sudo -u ${userConfig.username} mkdir -p "$(dirname "$BESZEL_BIN")"
      if curl -sL "$TARBALL_URL" | tar -xz -C "$(dirname "$BESZEL_BIN")" beszel-agent 2>/dev/null; then
        chmod 755 "$BESZEL_BIN"
        chown ${userConfig.username}:staff "$BESZEL_BIN"
        echo "✓ Beszel agent binary installed"
      else
        echo "⚠ Failed to download Beszel agent (will retry on next rebuild)"
      fi
    else
      echo "✓ Beszel agent binary already installed"
    fi

    # Create env file placeholder if not configured
    if [ ! -f "$BESZEL_ENV" ]; then
      sudo -u ${userConfig.username} mkdir -p "$(dirname "$BESZEL_ENV")"
      cat > "$BESZEL_ENV" << 'ENVEOF'
# Beszel agent configuration
# Get the KEY value from Beszel Hub after adding this system
KEY=
PORT=45876
ENVEOF
      chown ${userConfig.username}:staff "$BESZEL_ENV"
      echo "⚠ Beszel agent env created (KEY needs configuration)"
      echo "  Edit: $BESZEL_ENV"
    else
      echo "✓ Beszel agent config exists"
    fi
  '';
}
