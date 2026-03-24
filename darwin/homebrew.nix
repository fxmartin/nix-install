# ABOUTME: Homebrew package management configuration (STUB for Epic-02)
# ABOUTME: Manages GUI applications (casks), CLI tools (brews), and Mac App Store apps
{userConfig, isPowerProfile, lib, ...}: {
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
      "manaflow-ai/cmux" # cmux terminal - Ghostty-based terminal with vertical tabs for AI coding agents
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
      "ghostty" # Modern GPU-accelerated terminal (Phase 5 validation test app)
      "manaflow-ai/cmux/cmux" # cmux - Ghostty-based terminal with vertical tabs and notifications for AI coding agents

      # AI & LLM Tools (Story 02.1-001, 02.1-002)
      # Auto-update disable: Check app preferences after first launch
      "claude" # Claude Desktop - Anthropic's AI assistant
      "chatgpt" # ChatGPT Desktop - OpenAI's conversational AI
      # Note: Perplexity moved to Mac App Store (masApps) - no Homebrew cask available
      "lm-studio" # LM Studio - Discover, download, and run local LLMs with GUI

      # Development Environment Applications (Story 02.2-001, 02.2-005)
      # Auto-update disable: Managed via Home Manager settings.json
      # NOTE: VSCode DISABLED due to Electron crash issues during darwin-rebuild (Issue: Electron crashes)
      # "visual-studio-code" # VSCode - DISABLED: Causes Electron crashes during rebuild
      "zed" # Zed Editor - Fast, modern code editor with GPU acceleration
            # Configuration: home-manager/modules/zed.nix (Catppuccin theme, JetBrains Mono)

      # Container Tools (Story 02.2-005)
      "docker" # Docker Desktop - Container development platform

      # Database Tools
      "tableplus" # TablePlus - Modern database management GUI (PostgreSQL, MySQL, SQLite, Redis, etc.)

      # Browsers (Story 02.3-001, 02.3-002)
      # Auto-update disable: Updates managed by Homebrew (no in-app setting available)
      "brave-browser"    # Brave Browser - Privacy-focused browser with built-in ad/tracker blocking
      "arc"              # Arc Browser - Modern workspace browser with Spaces and vertical sidebar
      "google-chrome"    # Google Chrome - Web browser (auto-update managed by Homebrew)

      # Productivity & Utilities (Story 02.4-001, 02.4-002, 02.4-004)
      # Auto-update disable: Raycast/1Password (Preferences → Advanced), Dropbox (Preferences → Account → Disable automatic updates)
      "raycast" # Raycast - Application launcher and productivity tool (Story 02.4-001)
      "1password" # 1Password - Password manager and secure vault (Story 02.4-002)
      "dropbox" # Dropbox - Cloud storage and file sync (Story 02.4-004)

      # File Utilities (Story 02.4-003)
      # Auto-update disable: Calibre (Preferences → Misc), Marked 2 (Preferences → General)
      "calibre" # Calibre - Ebook library manager and converter (Story 02.4-003)
      "keka"    # Keka - Archive utility for zip, rar, 7z, etc. (Story 02.4-003)

      # System Utilities (Story 02.4-005)
      # Auto-update disable: None required (both free utilities, Homebrew-controlled)
      # Permission notes: Onyx requires admin password for system tasks, f.lux may request accessibility
      "onyx"     # Onyx - System maintenance and optimization utility (Story 02.4-005)
      "flux-app" # f.lux - Display color temperature adjustment (Story 02.4-005)

      # System Monitoring (Story 02.4-006)
      # Auto-update disable: iStat Menus (Preferences → General → Updates → Uncheck "Automatically check for updates")
      # License: iStat Menus requires activation (14-day free trial, $11.99 USD for license)
      # Permission notes: iStat Menus may request Accessibility permissions for system monitoring
      "istat-menus" # iStat Menus - Professional menubar system monitoring (licensed app)

      # Media Tools (Story 02.6-001)
      # Auto-update disable: VLC (Preferences → General → Uncheck auto-update)
      "vlc"  # VLC - Universal media player supporting 100+ formats (Story 02.6-001)

      # Communication Tools - Video Conferencing (Story 02.5-002)
      # CRITICAL: Auto-update disable required for both apps
      # Zoom: Preferences → General → Uncheck "Update Zoom automatically when connected to Wi-Fi"
      # Webex: Preferences → General → Check for auto-update option (may vary by version)
      # Both apps require account sign-in:
      #   - Zoom: Free account available, license may be needed for full features (meeting duration, participant limits)
      #   - Webex: Requires company account or free Webex account
      # Permissions: Both apps request camera and microphone on first use
      "zoom"  # Zoom - Video conferencing and meetings (Story 02.5-002)
      "webex" # Cisco Webex - Enterprise video conferencing (Story 02.5-002)

      # Messaging (Story 02.5-001)
      # Auto-update disable: Settings → Advanced → Uncheck "Automatic updates"
      "slack"    # Slack - Team communication and collaboration platform
      "telegram" # Telegram - Cross-platform messaging with cloud sync

      # Security & VPN (Story 02.7-001)
      # Auto-update: Check Preferences → Settings → Advanced during VM testing (may not be user-configurable)
      # License: Requires active NordVPN subscription (NO free tier)
      # Permissions: Network Extension permission required on first VPN connection
      "nordvpn" # NordVPN - VPN privacy and security service (subscription required)
      "tailscale-app" # Tailscale - Zero-config mesh VPN built on WireGuard
      "rustdesk"      # RustDesk - Open source remote desktop application

      # Network Firewall (Story 02.7-001)
      # Auto-update disable: Preferences → Advanced → Uncheck "Automatically check for updates"
      # License: Paid software ($59 single license, or subscription)
      # Permissions: Network Extension and System Extension permissions required
      # Note: Requires system restart after installation to enable kernel extension
      "little-snitch" # Little Snitch - Application-level network firewall and monitor

      # Office 365 (Story 02.9-001)
      # Sign-in required: Microsoft account (personal, work, or school) - ONE-TIME activates ALL apps
      # Auto-update disable: EACH app → Preferences → Update → Uncheck (6 apps total: Word, Excel, PowerPoint, Outlook, OneNote, Teams)
      # License: Active Microsoft 365 subscription required (Personal $69.99/year, Family $99.99/year, or company-provided)
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
    masApps = lib.mkIf (userConfig.enableMasApps or false) {
      "1Password for Safari" = 1569813296;  # Safari password manager extension
      "Perplexity" = 6714467650;  # AI search assistant
      "Kindle" = 302584613;       # Ebook reader
      "Marked 2" = 890031187;     # Markdown preview
      "WhatsApp" = 310633997;     # Messaging app
      "Amphetamine" = 937984704;  # Keep-awake utility to prevent sleep
      "reMarkable desktop" = 1276493162;  # reMarkable tablet sync and screen share
    };
  };

  # Environment variable to prevent Homebrew auto-updates
  environment.variables.HOMEBREW_NO_AUTO_UPDATE = "1";
}
