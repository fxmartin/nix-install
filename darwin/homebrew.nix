# ABOUTME: Homebrew package management configuration (STUB for Epic-02)
# ABOUTME: Manages GUI applications (casks), CLI tools (brews), and Mac App Store apps
{userConfig, ...}: {
  nix-homebrew = {
    enable = true;
    user = userConfig.username;
    autoMigrate = true; # Handle existing Homebrew installations
    mutableTaps = true;
  };

  homebrew = {
    enable = true;

    # Homebrew taps (repositories)
    # Epic-02 will add: homebrew/cask-fonts, etc.
    taps = [];

    onActivation = {
      autoUpdate = false; # CRITICAL: Disable auto-updates per REQUIREMENTS.md
      upgrade = false; # Updates only via 'rebuild' or 'update' commands
      cleanup = "zap"; # Aggressive cleanup of old versions
    };

    # CLI Tools
    # Epic-02 will populate with:
    # - Python environment (uv, python@3.12)
    # - Development tools (git, node, etc.)
    # - Text processing (bat, fzf, jq, ripgrep, yq)
    # - System monitoring (btop, bottom, neofetch)
    # - Cloud tools (awscli, terraform, etc.)
    # CRITICAL: gh (GitHub CLI) installed here for immediate PATH availability
    #           Required by Phase 6 (Story 01.6-002) for SSH key upload
    #           Homebrew formula makes it available immediately after darwin-rebuild
    #           (Home Manager would require shell reload to update PATH)
    # CRITICAL: mas (Mac App Store CLI) required for masApps installations
    #           Must be installed before any masApps can be installed
    #           Issue #25: Bootstrap failed without mas on fresh MacBook Pro M3 Max
    brews = [
      "gh"  # GitHub CLI - Required for automated SSH key upload in bootstrap
      "mas" # Mac App Store CLI - Required for masApps installations (Issue #25)

      # Container Tools (Story 02.2-005)
      # Note: Installed via Homebrew instead of Nix for better GUI integration
      # Podman Desktop (GUI app) needs to find podman CLI in standard PATH
      "podman"          # Podman container engine (Docker alternative)
      "podman-compose"  # Docker Compose alternative for Podman
    ];

    # GUI Applications (Casks)
    # Epic-02 will populate with:
    # - Development: Zed, VSCode, Cursor, Podman Desktop
    # - Browsers: Arc, Firefox, Google Chrome
    # - Communication: Zoom, Webex, Slack, WhatsApp
    # - Productivity: 1Password, Raycast, Obsidian, Dropbox
    # - Terminal: Ghostty
    # - Fonts: JetBrains Mono Nerd Font, etc.
    # - Power profile only: Parallels Desktop

    # MINIMAL INSTALL: Ghostty terminal for Phase 5 validation testing
    # Epic-02 will expand this list with full app inventory
    casks = [
      "ghostty" # Modern GPU-accelerated terminal (Phase 5 validation test app)

      # AI & LLM Tools (Story 02.1-001, 02.1-002)
      # Auto-update disable: Check app preferences after first launch
      "claude" # Claude Desktop - Anthropic's AI assistant
      "chatgpt" # ChatGPT Desktop - OpenAI's conversational AI
      # Note: Perplexity moved to Mac App Store (masApps) - no Homebrew cask available
      "ollama-app" # Ollama Desktop - Local LLM runner with GUI and CLI (Story 02.1-002)
                   # Note: Renamed from "ollama" to "ollama-app" in Homebrew

      # Development Environment Applications (Story 02.2-001, 02.2-005)
      # Auto-update disable: Managed via Home Manager settings.json
      # NOTE: VSCode DISABLED due to Electron crash issues during darwin-rebuild (Issue: Electron crashes)
      # "visual-studio-code" # VSCode - DISABLED: Causes Electron crashes during rebuild
      "zed" # Zed Editor - Fast, modern code editor with GPU acceleration
            # Configuration: home-manager/modules/zed.nix (Catppuccin theme, JetBrains Mono)

      # Container Tools (Story 02.2-005)
      "podman-desktop" # Podman Desktop - GUI for managing Podman containers

      # Browsers (Story 02.3-001, 02.3-002)
      # Auto-update disable: Updates managed by Homebrew (no in-app setting available)
      "brave-browser" # Brave Browser - Privacy-focused browser with built-in ad/tracker blocking
      "arc"           # Arc Browser - Modern workspace-focused browser with unique UI

      # Productivity & Utilities (Story 02.4-001, 02.4-002)
      # Auto-update disable: Preferences → Advanced → Disable auto-update (manual step)
      "raycast" # Raycast - Application launcher and productivity tool (Story 02.4-001)
      "1password" # 1Password - Password manager and secure vault (Story 02.4-002)
    ];

    # Global Homebrew options
    global = {
      autoUpdate = false; # CRITICAL: Match onActivation setting
      brewfile = true;
      lockfiles = true;
    };

    # Mac App Store apps
    # Epic-02 will populate with:
    # - Kindle (302584613)
    # - WhatsApp (310633997)
    masApps = {
      # AI & LLM Tools (Story 02.1-001)
      # Perplexity AI desktop app (released October 24, 2024)
      # No Homebrew cask available - distributed via Mac App Store only
      "Perplexity" = 6714467650;
    };
  };

  # Environment variable to prevent Homebrew auto-updates
  environment.variables.HOMEBREW_NO_AUTO_UPDATE = "1";
}
