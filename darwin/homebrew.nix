# ABOUTME: Homebrew package management configuration (STUB for Epic-02)
# ABOUTME: Manages GUI applications (casks), CLI tools (brews), and Mac App Store apps
{userConfig, isPowerProfile, profileName, lib, ...}: let
  isAiAssistant = profileName == "ai-assistant";
in {
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
    taps = [
      "felixkratz/formulae" # SketchyBar - highly customizable macOS status bar replacement
      "manaflow-ai/cmux" # cmux terminal - Ghostty-based terminal with vertical tabs for AI coding agents
      "nikitabobko/tap" # AeroSpace - i3-like tiling window manager for macOS
      "koekeishiya/formulae" # skhd - simple hotkey daemon for macOS
    ];

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

      # AI & LLM Tools
      "ollama"          # Ollama CLI - Local LLM server (replaces ollama-app cask)

      # System Monitoring (Apple Silicon)
      # Note: Not available in nixpkgs, Homebrew formula only
      "mactop"          # Real-time Apple Silicon CPU/GPU/ANE monitor (TUI)

      # Status Bar
      "felixkratz/formulae/sketchybar" # SketchyBar - Highly customizable macOS status bar replacement

      # Hotkey Daemon
      "koekeishiya/formulae/skhd" # skhd - Simple hotkey daemon for macOS (https://github.com/koekeishiya/skhd)

      # Media Tools
      # Note: yt-dlp broken in nixpkgs (curl-impersonate AppleIDN check fails on macOS 15.3)
      "yt-dlp"          # YouTube/video downloader (active fork of youtube-dl)

    ];

    # GUI Applications (Casks)
    # Epic-02 will populate with:
    # - Development: Zed, VSCode, Cursor, Docker Desktop
    # - Browsers: Brave
    # - Communication: Zoom, Webex, Slack, WhatsApp
    # - Productivity: 1Password, Raycast, Obsidian, Dropbox
    # - Terminal: Ghostty
    # - Fonts: JetBrains Mono Nerd Font, etc.
    # - Power profile only: additional apps as needed

    # MINIMAL INSTALL: Ghostty terminal for Phase 5 validation testing
    # Epic-02 will expand this list with full app inventory
    casks = [
      # === Core Apps (all profiles) ===
      "ghostty" # Modern GPU-accelerated terminal (Phase 5 validation test app)
      "manaflow-ai/cmux/cmux" # cmux - Ghostty-based terminal with vertical tabs and notifications for AI coding agents

      # AI & LLM Tools (Story 02.1-001, 02.1-002)
      "claude" # Claude Desktop - Anthropic's AI assistant
      "chatgpt" # ChatGPT Desktop - OpenAI's conversational AI

      # Development Environment
      "zed" # Zed Editor - Fast, modern code editor with GPU acceleration

      # Browsers
      "google-chrome"    # Google Chrome - Web browser (auto-update managed by Homebrew)

      # Productivity & Utilities
      "raycast" # Raycast - Application launcher and productivity tool (Story 02.4-001)
      "1password" # 1Password - Password manager and secure vault (Story 02.4-002)
      "obsidian" # Obsidian - Markdown-based knowledge base and note-taking app

      # Window Management
      "nikitabobko/tap/aerospace" # AeroSpace - i3-like tiling window manager for macOS

      # System Monitoring
      "istat-menus" # iStat Menus - Professional menubar system monitoring (licensed app)

      # Messaging
      "telegram" # Telegram - Cross-platform messaging with cloud sync

      # Security & VPN
      "nordvpn" # NordVPN - VPN privacy and security service (subscription required)
      "tailscale-app" # Tailscale - Zero-config mesh VPN built on WireGuard
      "little-snitch" # Little Snitch - Application-level network firewall and monitor

      # Fonts
      "font-sf-pro"         # SF Pro - Apple's system font for native macOS look (used by SketchyBar)
      "font-hack-nerd-font" # Hack Nerd Font - Patched font for SketchyBar and dev tools
    ]
    # === Standard/Power profile additional apps ===
    ++ lib.optionals (!isAiAssistant) [
      # Container Tools (Story 02.2-005)
      "docker-desktop" # Docker Desktop - Container development platform

      # Database Tools
      "tableplus" # TablePlus - Modern database management GUI

      # Additional Browsers
      "brave-browser"    # Brave Browser - Privacy-focused browser
      "arc"              # Arc Browser - Modern workspace browser with Spaces

      # Productivity
      "dropbox" # Dropbox - Cloud storage and file sync (Story 02.4-004)
      "excalidraw" # Excalidraw - Virtual whiteboard for sketching hand-drawn diagrams

      # File Utilities (Story 02.4-003)
      "calibre" # Calibre - Ebook library manager and converter
      "keka"    # Keka - Archive utility for zip, rar, 7z, etc.

      # System Utilities (Story 02.4-005)
      "onyx"     # Onyx - System maintenance and optimization utility
      "flux-app" # f.lux - Display color temperature adjustment

      # Media Tools (Story 02.6-001)
      "vlc"  # VLC - Universal media player supporting 100+ formats

      # Video Conferencing (Story 02.5-002)
      "zoom"  # Zoom - Video conferencing and meetings
      "webex" # Cisco Webex - Enterprise video conferencing

      # Additional Messaging
      "slack"    # Slack - Team communication and collaboration platform

      # Remote Access
      "rustdesk"      # RustDesk - Open source remote desktop application

      # Office 365 (Story 02.9-001)
      "microsoft-office-businesspro" # Office 365 - Word, Excel, PowerPoint, Outlook, OneNote, Teams
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
    #   mas install 937984704   # Amphetamine
    #   mas install 6714467650  # Perplexity
    #   mas install 302584613   # Kindle
    #   mas install 890031187   # Marked 2
    #   mas install 310633997   # WhatsApp
    #   mas install 6749861443  # Inferencer
    masApps = lib.mkIf (userConfig.enableMasApps or false) {
      "1Password for Safari" = 1569813296;  # Safari password manager extension
      "Perplexity" = 6714467650;  # AI search assistant
      "Kindle" = 302584613;       # Ebook reader
      "Marked 2" = 890031187;     # Markdown preview
      "WhatsApp" = 310633997;     # Messaging app
      "Amphetamine" = 937984704;  # Keep-awake utility to prevent sleep
      "reMarkable desktop" = 1276493162;  # reMarkable tablet sync and screen share
      "Inferencer" = 6749861443;  # Private on-device AI model runner
    };
  };

  # Environment variable to prevent Homebrew auto-updates
  environment.variables.HOMEBREW_NO_AUTO_UPDATE = "1";
}
