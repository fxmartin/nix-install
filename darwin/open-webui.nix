# ABOUTME: LaunchAgent for Open WebUI running in a Podman container
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
in {
  # ===========================================================================
  # OPEN WEBUI LAUNCHAGENT (Podman Container)
  # ===========================================================================
  # Runs Open WebUI as a Podman container, providing a web-based chat interface
  # for Ollama models. Accessible at http://localhost:3000 and via Tailscale.
  #
  # Container details:
  #   - Image: ghcr.io/open-webui/open-webui:main
  #   - Port mapping: 3000 (host) → 8080 (container)
  #   - Ollama connection: http://host.containers.internal:11434
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
          # Wait for Podman machine to be ready (up to 120 seconds)
          for i in $(seq 1 24); do
            if /opt/homebrew/bin/podman info > /dev/null 2>&1; then
              echo "Podman machine ready."
              break
            fi
            if [ "$i" -eq 24 ]; then
              echo "Podman machine not available after 120s. Exiting."
              exit 1
            fi
            echo "Waiting for Podman machine... (attempt $i/24)"
            sleep 5
          done

          # Stop and remove existing container (idempotent)
          /opt/homebrew/bin/podman stop ${containerName} 2>/dev/null || true
          /opt/homebrew/bin/podman rm ${containerName} 2>/dev/null || true

          # Pull image only if not already present (avoids slow pull on every restart)
          if ! /opt/homebrew/bin/podman image exists ${containerImage} 2>/dev/null; then
            echo "Pulling ${containerImage}..."
            /opt/homebrew/bin/podman pull ${containerImage}
          else
            echo "Image ${containerImage} already present, skipping pull."
          fi

          # Run container with exec for clean process management
          exec /opt/homebrew/bin/podman run \
            --name ${containerName} \
            --rm \
            -p ${hostPort}:${containerPort} \
            -v ${volumeName}:/app/backend/data \
            -e OLLAMA_BASE_URL=http://host.containers.internal:11434 \
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

      # Prevent restart loops (30 second cooldown — gives time for Podman machine)
      ThrottleInterval = 30;

      # Environment
      EnvironmentVariables = {
        HOME = "/Users/${userConfig.username}";
        PATH = "/etc/profiles/per-user/${userConfig.username}/bin:/opt/homebrew/bin:/run/current-system/sw/bin:/usr/bin:/usr/sbin:/bin";
      };
    };
  };
}
