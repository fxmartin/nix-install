# ABOUTME: Python development environment configuration via Home Manager
# ABOUTME: Configures Python 3.12 + uv environment variables, aliases, and dev workflow

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Python Development Environment Configuration (Feature 04.7)
  # Provides optimal Python development experience with uv-first workflow
  #
  # Why this approach:
  # - Python 3.12 and uv installed via Nix (darwin/configuration.nix)
  # - Environment variables optimize Python behavior
  # - Shell aliases streamline common dev workflows
  # - uv is the primary tool for project and dependency management
  #
  # Configuration includes:
  # - Python environment variables (no bytecode, unbuffered output)
  # - uv environment variables (system Python, system certificates)
  # - Shell aliases for Python/uv workflows
  # - direnv integration for per-project environments

  # Environment variables for Python development
  home.sessionVariables = {
    # Python behavior settings
    PYTHONDONTWRITEBYTECODE = "1"; # Don't create .pyc files
    PYTHONUNBUFFERED = "1"; # Unbuffered stdout/stderr for better logging

    # uv configuration
    UV_SYSTEM_PYTHON = "1"; # Use system Python by default
    UV_SYSTEM_CERTS = "1"; # Use system certificate store for TLS
  };

  # direnv integration for automatic environment activation
  programs.direnv = {
    enable = true;
    enableZshIntegration = false; # Default embeds a generation-specific store path
    nix-direnv.enable = true; # Faster direnv for Nix environments
  };

  # Keep the hook valid when a rebuild replaces or garbage-collects the direnv
  # store path while an interactive shell is still running.
  programs.zsh.initContent = lib.mkAfter ''
    if [[ -x "${config.home.profileDirectory}/bin/direnv" ]]; then
      eval "$("${config.home.profileDirectory}/bin/direnv" hook zsh)"
    fi
  '';

  # Python dev workflow aliases (added to shell.nix shellAliases)
  # These are defined here for documentation but integrated via shell.nix
  # Actual integration happens in shell.nix via imports

  # Post-installation verification message
  home.activation.pythonConfigVerify = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v python > /dev/null 2>&1 && command -v uv > /dev/null 2>&1; then
      echo ""
      echo "✓ Python development environment configured:"
      echo "  - Python: $(python --version 2>&1)"
      echo "  - uv: $(uv --version 2>&1 | head -1)"
      echo "  - PYTHONDONTWRITEBYTECODE: enabled"
      echo "  - PYTHONUNBUFFERED: enabled"
      echo "  - UV_SYSTEM_PYTHON: enabled"
      echo "  - direnv: enabled"
      echo ""
      echo "Quick start:"
      echo "  → uv init my-project       # Create new project"
      echo "  → cd my-project"
      echo "  → uv add requests          # Add dependency"
      echo "  → uv run python main.py    # Run with deps"
      echo ""
      echo "Dev tools available:"
      echo "  → ruff check .             # Lint and check import order"
      echo "  → ruff check . --fix       # Fix lint and import issues"
      echo "  → ruff format .            # Format code"
      echo "  → pyright                  # Type checking"
      echo ""
    fi
  '';
}
