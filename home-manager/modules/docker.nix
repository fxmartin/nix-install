# ABOUTME: Docker Desktop container development environment configuration via Home Manager
# ABOUTME: Configures Docker Desktop verification and container workflow guidance

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Docker Desktop Container Development Environment Configuration (Feature 04.8)
  # Docker Desktop provides a full container development platform on macOS
  # with integrated Docker Engine, Docker Compose, and a GUI dashboard.

  # Post-installation verification
  home.activation.dockerConfigVerify = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v docker > /dev/null 2>&1; then
      echo ""
      echo "✓ Docker container environment configured:"
      echo "  - Docker: $(docker --version 2>&1 | head -1)"
      if docker compose version > /dev/null 2>&1; then
        echo "  - Docker Compose: $(docker compose version --short 2>&1)"
      fi
      echo ""
      echo "Quick start:"
      echo "  → docker run -it alpine sh          # Quick Alpine shell"
      echo "  → docker compose up                 # Start compose project"
      echo "  → docker system prune               # Clean up unused containers/images"
      echo ""
    fi
  '';
}
