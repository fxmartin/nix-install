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
    brews = [
      "gh" # GitHub CLI - Required for automated SSH key upload in bootstrap
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
    masApps = {};
  };

  # Environment variable to prevent Homebrew auto-updates
  environment.variables.HOMEBREW_NO_AUTO_UPDATE = "1";
}
