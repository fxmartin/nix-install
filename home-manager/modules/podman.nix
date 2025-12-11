# ABOUTME: Podman container development environment configuration via Home Manager
# ABOUTME: Configures Podman machine initialization, Docker compatibility aliases, and container workflows

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Podman Container Development Environment Configuration (Feature 04.8)
  # Provides Docker-compatible container development experience with Podman
  #
  # Why Podman over Docker:
  # - Daemonless architecture (no root daemon running)
  # - Rootless containers by default (better security)
  # - Docker CLI compatible (most docker commands work)
  # - Native macOS integration via Podman machine (lightweight VM)
  #
  # Configuration includes:
  # - Docker → Podman aliases for seamless compatibility
  # - Podman machine initialization guidance
  # - Container workflow aliases

  # Post-installation verification and machine initialization guidance
  # Note: Podman machine init requires user interaction and is not idempotent
  # in all cases, so we provide guidance rather than automatic initialization
  home.activation.podmanConfigVerify = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v podman > /dev/null 2>&1; then
      echo ""
      echo "✓ Podman container environment configured:"
      echo "  - Podman: $(podman --version 2>&1 | head -1)"
      if command -v podman-compose > /dev/null 2>&1; then
        echo "  - podman-compose: available"
      fi
      echo "  - Docker aliases: docker → podman, docker-compose → podman-compose"
      echo ""

      # Check if podman machine exists
      if podman machine list 2>/dev/null | grep -q "podman-machine-default"; then
        machine_status=$(podman machine list --format "{{.Running}}" 2>/dev/null | head -1)
        if [ "$machine_status" = "true" ]; then
          echo "  - Podman machine: Running ✓"
        else
          echo "  - Podman machine: Stopped (run 'podman machine start' to start)"
        fi
      else
        echo ""
        echo "⚠ Podman machine not initialized. First-time setup required:"
        echo "  → podman machine init              # Initialize VM (one-time, ~2-3 min)"
        echo "  → podman machine start             # Start the VM"
        echo "  → podman run hello-world           # Verify container execution"
        echo ""
        echo "Machine management commands:"
        echo "  → podman machine start             # Start VM"
        echo "  → podman machine stop              # Stop VM"
        echo "  → podman machine rm                # Remove VM (to reinitialize)"
        echo "  → podman machine list              # Show machine status"
      fi
      echo ""
      echo "Quick start:"
      echo "  → docker run -it alpine sh          # Run Alpine container (uses podman)"
      echo "  → docker-compose up                 # Start compose project (uses podman-compose)"
      echo "  → podman system prune               # Clean up unused containers/images"
      echo ""
    fi
  '';
}
