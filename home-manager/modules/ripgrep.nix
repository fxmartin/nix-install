# ABOUTME: ripgrep (rg) configuration with sensible defaults
# ABOUTME: Fast grep replacement with smart defaults for development workflows
{
  config,
  pkgs,
  lib,
  ...
}: {
  # ripgrep is already installed via darwin/configuration.nix
  # This module provides configuration via .ripgreprc

  # ripgrep configuration file
  # ripgrep reads from RIPGREP_CONFIG_PATH environment variable
  home.file.".ripgreprc".text = ''
    # Ripgrep configuration file
    # https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file

    # Smart case: case-insensitive if pattern is all lowercase
    # Otherwise case-sensitive
    --smart-case

    # Follow symbolic links
    --follow

    # Search hidden files and directories (dotfiles)
    # Exclude .git by default (see below)
    --hidden

    # Don't search in .git directories
    --glob=!.git/*

    # Common directories to ignore
    --glob=!node_modules/*
    --glob=!__pycache__/*
    --glob=!*.pyc
    --glob=!.venv/*
    --glob=!venv/*
    --glob=!.env/*
    --glob=!env/*
    --glob=!.mypy_cache/*
    --glob=!.pytest_cache/*
    --glob=!.ruff_cache/*
    --glob=!.tox/*
    --glob=!.nox/*
    --glob=!*.egg-info/*
    --glob=!dist/*
    --glob=!build/*
    --glob=!target/*
    --glob=!.cargo/*
    --glob=!Cargo.lock
    --glob=!package-lock.json
    --glob=!yarn.lock
    --glob=!pnpm-lock.yaml
    --glob=!.next/*
    --glob=!.nuxt/*
    --glob=!.output/*
    --glob=!.cache/*
    --glob=!.parcel-cache/*
    --glob=!coverage/*
    --glob=!.nyc_output/*
    --glob=!*.min.js
    --glob=!*.min.css
    --glob=!*.map
    --glob=!.DS_Store
    --glob=!Thumbs.db
    --glob=!*.lock
    --glob=!flake.lock

    # Nix-specific ignores
    --glob=!result
    --glob=!result-*

    # Max columns before truncation (prevents long minified lines)
    --max-columns=200

    # Show column numbers
    --column

    # Show line numbers
    --line-number

    # Use colors
    --color=auto

    # Sort by file path (more predictable output)
    --sort=path

    # Number of threads (0 = auto-detect based on CPU cores)
    --threads=0
  '';

  # Set RIPGREP_CONFIG_PATH environment variable
  home.sessionVariables = {
    RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc";
  };

  # Activation script to verify ripgrep configuration
  home.activation.verifyRipgrep = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "ripgrep: Configuration applied"
    echo "  - Config: ~/.ripgreprc"
    echo "  - Smart case: enabled"
    echo "  - Hidden files: enabled (except .git)"
    echo "  - Common ignores: node_modules, __pycache__, .venv, etc."
    echo "  - Run 'rg <pattern>' to search"
    echo "  - Run 'rg --no-config <pattern>' to ignore config"
  '';
}
