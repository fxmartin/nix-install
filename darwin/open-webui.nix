# ABOUTME: LaunchAgent for Open WebUI running in a Docker container
# ABOUTME: Provides web interface for Ollama LLMs on port 3000, accessible via localhost and Tailscale
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: let
  containerName = "open-webui";
  containerImage = "ghcr.io/open-webui/open-webui:main";
  hostPort = "3000";
  containerPort = "8080";
  volumeName = "open-webui";
  dockerBin = "/usr/local/bin/docker";
in {
  # ===========================================================================
  # OPEN WEBUI LAUNCHAGENT (Docker Container)
  # ===========================================================================
  # Runs Open WebUI as a Docker container, providing a web-based chat interface
  # for Ollama models. Accessible at http://localhost:3000 and via Tailscale.
  #
  # Container details:
  #   - Image: ghcr.io/open-webui/open-webui:main
  #   - Port mapping: 3000 (host) → 8080 (container)
  #   - Ollama connection: http://host.docker.internal:11434
  #   - Persistent data: "open-webui" named volume
  #
  # The bash wrapper:
  #   1. Stops and removes any existing container (idempotent restart)
  #   2. Pulls the latest image
  #   3. Runs the container with exec for clean process management

  launchd.user.agents.open-webui = {
    serviceConfig = {
      Label = "org.nixos.open-webui";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        ''
          # Wait for Docker Desktop to be ready (up to 120 seconds)
          for i in $(seq 1 24); do
            if ${dockerBin} info > /dev/null 2>&1; then
              echo "Docker Desktop ready."
              break
            fi
            if [ "$i" -eq 24 ]; then
              echo "Docker Desktop not available after 120s. Exiting."
              exit 1
            fi
            echo "Waiting for Docker Desktop... (attempt $i/24)"
            sleep 5
          done

          # Stop and remove existing container (idempotent)
          ${dockerBin} stop ${containerName} 2>/dev/null || true
          ${dockerBin} rm ${containerName} 2>/dev/null || true

          # Pull image only if not already present (avoids slow pull on every restart)
          if ! ${dockerBin} image inspect ${containerImage} > /dev/null 2>&1; then
            echo "Pulling ${containerImage}..."
            ${dockerBin} pull ${containerImage}
          else
            echo "Image ${containerImage} already present, skipping pull."
          fi

          # Run container with exec for clean process management
          exec ${dockerBin} run \
            --name ${containerName} \
            --rm \
            -p ${hostPort}:${containerPort} \
            -v ${volumeName}:/app/backend/data \
            -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
            -e WEBUI_AUTH=false \
            ${containerImage}
        ''
      ];

      # Start at login and restart on crash
      RunAtLoad = true;
      KeepAlive = {SuccessfulExit = false;};

      # Logging configuration
      StandardOutPath = "/tmp/open-webui.log";
      StandardErrorPath = "/tmp/open-webui.err";

      # Prevent restart loops (30 second cooldown — gives time for Docker Desktop)
      ThrottleInterval = 30;

      # Environment
      EnvironmentVariables = {
        HOME = "/Users/${userConfig.username}";
        PATH = "/etc/profiles/per-user/${userConfig.username}/bin:/usr/local/bin:/opt/homebrew/bin:/run/current-system/sw/bin:/usr/bin:/usr/sbin:/bin";
      };
    };
  };
}
