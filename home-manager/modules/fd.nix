# ABOUTME: fd (find replacement) configuration with ignore patterns
# ABOUTME: Fast file finder with sensible defaults for development workflows
{
  config,
  pkgs,
  lib,
  ...
}: {
  # fd is already installed via darwin/configuration.nix
  # This module provides configuration via .fdignore

  # fd ignore file (similar to .gitignore syntax)
  # fd automatically respects .gitignore, but .fdignore adds additional patterns
  home.file.".fdignore".text = ''
    # fd ignore file
    # Patterns here are ALWAYS ignored (in addition to .gitignore)
    # https://github.com/sharkdp/fd#how-to-use

    # Version control
    .git/
    .hg/
    .svn/

    # Node.js
    node_modules/
    package-lock.json
    yarn.lock
    pnpm-lock.yaml

    # Python
    __pycache__/
    *.pyc
    *.pyo
    *.pyd
    .venv/
    venv/
    .env/
    env/
    .mypy_cache/
    .pytest_cache/
    .ruff_cache/
    .tox/
    .nox/
    *.egg-info/
    dist/
    build/
    .eggs/

    # Rust
    target/
    Cargo.lock

    # Go
    vendor/

    # Java/Kotlin
    .gradle/
    .idea/
    *.class
    *.jar

    # C/C++
    *.o
    *.a
    *.so
    *.dylib

    # Build artifacts
    build/
    dist/
    out/
    .output/

    # IDE and editor files
    .idea/
    .vscode/
    *.swp
    *.swo
    *~

    # Frontend build tools
    .next/
    .nuxt/
    .cache/
    .parcel-cache/

    # Test coverage
    coverage/
    .nyc_output/
    htmlcov/

    # Minified files
    *.min.js
    *.min.css
    *.map

    # macOS
    .DS_Store
    .AppleDouble
    .LSOverride
    ._*
    .Spotlight-V100
    .Trashes

    # Windows
    Thumbs.db
    ehthumbs.db
    Desktop.ini

    # Nix
    result
    result-*
    .direnv/

    # Lock files (usually auto-generated)
    *.lock
    flake.lock

    # Logs
    *.log
    logs/

    # Temporary files
    tmp/
    temp/
    *.tmp
    *.temp

    # Archives (usually not searched)
    *.zip
    *.tar
    *.tar.gz
    *.tgz
    *.rar
    *.7z

    # Binary files
    *.exe
    *.dll
    *.bin

    # Media files (usually not searched for code)
    *.jpg
    *.jpeg
    *.png
    *.gif
    *.ico
    *.svg
    *.webp
    *.mp3
    *.mp4
    *.avi
    *.mov
    *.pdf
  '';

  # Activation script to verify fd configuration
  home.activation.verifyFd = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "fd: Configuration applied"
    echo "  - Config: ~/.fdignore"
    echo "  - Ignores: node_modules, __pycache__, .venv, build artifacts, etc."
    echo "  - Also respects .gitignore files"
    echo "  - Run 'fd <pattern>' to search for files"
    echo "  - Run 'fd -H <pattern>' to include hidden files"
    echo "  - Run 'fd -I <pattern>' to ignore .fdignore"
  '';
}
