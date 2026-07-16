# ABOUTME: Declarative Homebrew configuration for GUI apps and bootstrap-critical tools
# ABOUTME: Defines profile-aware casks, formulas, and Mac App Store applications
{
  userConfig,
  profileName,
  lib,
  ...
}:
let
  isAiAssistant = profileName == "ai-assistant";
in
{
  nix-homebrew = {
    enable = true;
    user = userConfig.username;
    autoMigrate = true; # Handle existing Homebrew installations
    mutableTaps = true;
  };

  homebrew = {
    enable = true;

    # Homebrew taps (repositories)
    taps = [
      "manaflow-ai/cmux" # cmux terminal - Ghostty-based terminal with vertical tabs for AI coding agents
      "koekeishiya/formulae" # skhd - simple hotkey daemon for macOS
    ];

    onActivation = {
      autoUpdate = false; # CRITICAL: Disable auto-updates per REQUIREMENTS.md
      upgrade = false; # Updates only via 'rebuild' or 'update' commands
      cleanup = "zap"; # Aggressive cleanup of old versions
    };

    # CRITICAL: gh (GitHub CLI) installed here for immediate PATH availability
    #           Required by Phase 6 (Story 01.6-002) for SSH key upload
    #           Homebrew formula makes it available immediately after darwin-rebuild
    #           (Home Manager would require shell reload to update PATH)
    # CRITICAL: mas (Mac App Store CLI) required for masApps installations
    #           Must be installed before any masApps can be installed
    #           Issue #25: Bootstrap failed without mas on fresh MacBook Pro M3 Max
    brews = [
      "gh" # GitHub CLI - Required for automated SSH key upload in bootstrap
      "mas" # Mac App Store CLI - Required for masApps installations (Issue #25)
      "osv-scanner" # OSV Scanner - Vulnerability scanning for the SDLC controller
      "pkgconf" # pkg-config implementation required by native Python extension builds

      # AI & LLM Tools
      "ollama" # Ollama CLI - Local LLM server (replaces ollama-app cask)
      "opencode" # OpenCode - Open source AI coding agent for the terminal
      "qwen-code" # Qwen Code - Open source AI coding agent for the terminal
      "starship" # Starship prompt binary (Homebrew bottle avoids nixpkgs Darwin Rust linker failure)

      # Hotkey Daemon
      "koekeishiya/formulae/skhd" # skhd - Simple hotkey daemon for macOS (https://github.com/koekeishiya/skhd)

      # Media Tools
      # Note: yt-dlp broken in nixpkgs (curl-impersonate AppleIDN check fails on macOS 15.3)
      "yt-dlp" # YouTube/video downloader (active fork of youtube-dl)

    ];

    # GUI applications; fonts remain owned by Nix/Stylix.
    casks = [
      # === Core Apps (all profiles) ===
      "ghostty" # Modern GPU-accelerated terminal (Phase 5 validation test app)
      "manaflow-ai/cmux/cmux" # cmux - Ghostty-based terminal with vertical tabs and notifications for AI coding agents

      # AI & LLM Tools (Story 02.1-001, 02.1-002)
      "claude" # Claude Desktop - Anthropic's AI assistant
      "chatgpt" # ChatGPT Desktop - OpenAI's conversational AI
      # OpenAI Codex CLI - terminal coding agent. no_quarantine because the cask
      # vendors ad-hoc-signed helper binaries (codex-path/rg, codex-resources/zsh)
      # that Gatekeeper rejects when quarantined — every adversarial-review run
      # popped "Apple could not verify rg is free of malware" (fixed 2026-07-11).
      # Note: brew applies args at (re)install time, so an already-installed cask
      # stays quarantined until its next upgrade.
      {
        name = "codex";
        args = {
          no_quarantine = true;
        };
      }

      # Development Environment
      "zed" # Zed Editor - Fast, modern code editor with GPU acceleration

      # Browsers
      "google-chrome" # Google Chrome - Web browser (auto-update managed by Homebrew)

      # Productivity & Utilities
      "raycast" # Raycast - Keyboard-first launcher and productivity tool (Story 02.4-001)
      "1password" # 1Password - Password manager and secure vault (Story 02.4-002)
      "obsidian" # Obsidian - Markdown-based knowledge base and note-taking app
      "plaud" # Plaud - AI voice recorder and transcription companion

      # System Monitoring
      "istat-menus" # iStat Menus - Professional menubar system monitoring (licensed app)

      # Messaging
      "telegram" # Telegram - Cross-platform messaging with cloud sync

      # Security & VPN
      "nordvpn" # NordVPN - VPN privacy and security service (subscription required)
      "tailscale-app" # Tailscale - Zero-config mesh VPN built on WireGuard
      "little-snitch" # Little Snitch - Application-level network firewall and monitor

    ]
    # === Standard/Power profile additional apps ===
    ++ lib.optionals (!isAiAssistant) [
      # Container Tools (Story 02.2-005)
      "docker-desktop" # Docker Desktop - Container development platform

      # Database Tools
      "tableplus" # TablePlus - Modern database management GUI

      # Additional Browsers
      "brave-browser" # Brave Browser - Privacy-focused browser

      # File Utilities (Story 02.4-003)
      "calibre" # Calibre - Ebook library manager and converter
      "keka" # Keka - Archive utility for zip, rar, 7z, etc.

      # System Utilities (Story 02.4-005)
      "elgato-stream-deck" # Stream Deck - Hardware macro controller companion app

      # Media Tools (Story 02.6-001)
      "vlc" # VLC - Universal media player supporting 100+ formats

      # Additional Messaging
      "slack" # Slack - Team communication and collaboration platform

      # Remote Access
      "rustdesk" # RustDesk - Open source remote desktop application

      # Microsoft 365 core applications (Story 02.9-001)
      "microsoft-word" # Word processor
      "microsoft-excel" # Spreadsheet application
      "microsoft-powerpoint" # Presentation application
    ]
    ++ lib.optionals (profileName == "power") [
      "fluidvoice" # FluidVoice - Local-first voice dictation with on-device speech models
    ];

    # Global Homebrew options
    global = {
      autoUpdate = false; # CRITICAL: Match onActivation setting
      brewfile = true;
    };

    # Mac App Store apps
    # Controlled by userConfig.enableMasApps (set during bootstrap)
    # Requires user to be signed into App Store before installation
    #
    # If disabled, install manually after bootstrap:
    #   mas install 6714467650  # Perplexity
    #   mas install 302584613   # Kindle
    #   mas install 890031187   # Marked 2
    #   mas install 310633997   # WhatsApp
    masApps = lib.mkIf (userConfig.enableMasApps or false) {
      "1Password for Safari" = 1569813296; # Safari password manager extension
      "Perplexity" = 6714467650; # AI search assistant
      "Kindle" = 302584613; # Ebook reader
      "Marked 2" = 890031187; # Markdown preview
      "WhatsApp" = 310633997; # Messaging app
      "reMarkable desktop" = 1276493162; # reMarkable tablet sync and screen share
    };
  };

  # Environment variable to prevent Homebrew auto-updates
  environment.variables.HOMEBREW_NO_AUTO_UPDATE = "1";
}
