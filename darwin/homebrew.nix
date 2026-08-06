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
      "asmvik/formulae" # skhd - simple hotkey daemon for macOS
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
      "pango" # WeasyPrint's GLib/Pango/cairo stack — Cellar's PDF export (F6.1)
      "pkgconf" # pkg-config implementation required by native Python extension builds

      # AI & LLM Tools
      "ollama" # Ollama CLI - Local LLM server (replaces ollama-app cask)
      "opencode" # OpenCode - Open source AI coding agent for the terminal
      "qwen-code" # Qwen Code - Open source AI coding agent for the terminal
      "starship" # Starship prompt binary (Homebrew bottle avoids nixpkgs Darwin Rust linker failure)

      # Hotkey Daemon
      "asmvik/formulae/skhd" # skhd - Simple hotkey daemon for macOS (https://github.com/asmvik/skhd)

      # Media Tools
      # Note: yt-dlp broken in nixpkgs (curl-impersonate AppleIDN check fails on macOS 15.3)
      "yt-dlp" # YouTube/video downloader (active fork of youtube-dl)

    ];

    # GUI applications; fonts remain owned by Nix/Stylix.
    casks = [
      # === Core Apps (all profiles) ===
      "ghostty" # Modern GPU-accelerated terminal (Phase 5 validation test app)
      # cmux moved from the manaflow-ai/cmux tap into homebrew-core (2026-08).
      # If the first rebuild after this change fails to resolve the cask, run:
      #   brew uninstall --cask cmux && brew untap manaflow-ai/cmux && brew update && brew install --cask cmux
      "cmux" # cmux - Ghostty-based terminal with vertical tabs and notifications for AI coding agents

      # AI & LLM Tools (Story 02.1-001, 02.1-002)
      "claude" # Claude Desktop - Anthropic's AI assistant
      "chatgpt" # ChatGPT Desktop - OpenAI's conversational AI
      # Usage/spend tracker for Claude Code, Codex, Copilot et al. All profiles,
      # since Claude Code runs on every one. Declares auto_updates, so it
      # self-updates outside `rebuild` (same exception as cmux and stats).
      "openusage" # OpenUsage - AI coding-agent usage tracker
      # OpenAI Codex CLI - terminal coding agent.
      #
      # The cask vendors ad-hoc-signed helper binaries (codex-path/rg,
      # codex-resources/zsh) that Gatekeeper rejects when quarantined — every
      # adversarial-review run popped "Apple could not verify rg is free of
      # malware". That was worked around on 2026-07-11 with `no_quarantine`.
      #
      # Homebrew 6.0 removed the `--no-quarantine` flag outright, so that arg
      # now aborts the whole `brew bundle` run:
      #   Error: invalid option: --no_quarantine
      # It stayed hidden because brew only applies args at (re)install time and
      # codex was already installed; a Caskroom wipe on 2026-07-28 forced a
      # reinstall and surfaced it. Both the underscore and dashed spellings are
      # rejected by brew 6.0.12 — this is not a spelling fix, the flag is gone.
      #
      # Partial mitigation already in place: the PATH ordering in
      # home-manager/modules/shell.nix prefers /run/current-system/sw/bin and
      # /opt/homebrew/bin over the cask's bundled codex-path/rg, so the common
      # case no longer reaches a quarantined binary. If the Gatekeeper prompts
      # return for a helper invoked by absolute path, strip the attribute by
      # hand rather than reinstating a flag brew no longer accepts:
      #   xattr -dr com.apple.quarantine /Applications/Codex.app
      "codex"

      # Development Environment
      "zed" # Zed Editor - Fast, modern code editor with GPU acceleration

      # Browsers
      "google-chrome" # Google Chrome - Web browser (auto-update managed by Homebrew)

      # Productivity & Utilities
      "1password" # 1Password - Password manager and secure vault (Story 02.4-002)
      "obsidian" # Obsidian - Markdown-based knowledge base and note-taking app
      "plaud" # Plaud - AI voice recorder and transcription companion

      # System Monitoring
      "stats" # Stats - Open-source menubar system monitor (replaced the licensed iStat Menus, 2026-08)

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
      "google-drive" # Google Drive - Desktop file sync and streaming
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
      # No `fluidvoice` cask: home-manager/modules/fluidvoice.nix builds FX's
      # patched fork at activation, and two copies would race for the hotkey.
      "qobuz" # Qobuz - Hi-Res music streaming and offline playback
      # 1Password CLI via Homebrew rather than nixpkgs `_1password-cli`. Both
      # ship 1Password's own signed binary (TeamIdentifier 2BUA8C4S2C), but
      # Homebrew is the vendor's documented macOS path and the one verified
      # working against the desktop app's biometric integration on this fleet.
      #
      # A cask, not a formula: upstream retired the `1password-cli` formula, so
      # `brew bundle` fails the whole rebuild with "No formulae found for
      # 1password-cli" while it is declared under `brews`.
      "1password-cli" # `op` - secret injection, vault access, biometric unlock via the 1Password app
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
    #   mas install 302584613   # Kindle
    #   mas install 890031187   # Marked 2
    #   mas install 310633997   # WhatsApp
    masApps = lib.mkIf (userConfig.enableMasApps or false) (
      {
        "1Password for Safari" = 1569813296; # Safari password manager extension
        "Kindle" = 302584613; # Ebook reader
        "Marked 2" = 890031187; # Markdown preview
        "WhatsApp" = 310633997; # Messaging app
        "reMarkable desktop" = 1276493162; # reMarkable tablet sync and screen share
      }
      # Power-only: full Xcode IDE (~8GB download, ~40GB installed).
      # First install requires the Apple ID to have "gotten" Xcode once in the
      # App Store; after install run `sudo xcodebuild -license accept`.
      // lib.optionalAttrs (profileName == "power") {
        "Xcode" = 497799835; # Apple IDE - simulators, Instruments, SDKs
      }
    );
  };

  # Environment variable to prevent Homebrew auto-updates
  # OP_BIOMETRIC_UNLOCK_ENABLED lets `op` authorise through the 1Password desktop
  # app (Touch ID) instead of prompting for a password every session. Power-only,
  # matching the CLI itself. Still requires the one-time GUI toggle:
  # 1Password → Settings → Developer → "Integrate with 1Password CLI".
  environment.variables = {
    HOMEBREW_NO_AUTO_UPDATE = "1";
  }
  // lib.optionalAttrs (profileName == "power") {
    OP_BIOMETRIC_UNLOCK_ENABLED = "true";
  };
}
