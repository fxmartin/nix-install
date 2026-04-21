# ABOUTME: User configuration template for Nix-Darwin MacBook setup
# ABOUTME: Placeholders are replaced during bootstrap to generate user-config.nix
{
  # Personal Information
  username = "@MACOS_USERNAME@";  # macOS login username
  fullName = "@FULL_NAME@";
  email = "@EMAIL@";
  notificationEmail = "@NOTIFICATION_EMAIL@";  # Email for maintenance notifications
  githubUsername = "@GITHUB_USERNAME@";
  hostname = "@HOSTNAME@";  # Only letters, numbers, and hyphens
  signingKey = "";  # GPG key ID (leave empty initially)

  # Installation Profile
  installProfile = "@INSTALL_PROFILE@";  # "standard", "power", or "ai-assistant"

  # Mac App Store apps (requires App Store sign-in)
  # Set to true only if signed into App Store before running bootstrap
  enableMasApps = @ENABLE_MAS_APPS@;

  # Directory Configuration
  directories = {
    dotfiles = "@DOTFILES_PATH@";  # Nix configuration repository location
  };

  # Claude Code project retention
  # Projects under ~/.claude/projects/ untouched for 90 days are pruned
  # weekly by the claude-project-prune LaunchAgent (Story 08.1-006).
  # Any path containing a memory/ subdir is preserved automatically.
  # List project dir names here to preserve them even without memory/.
  # claudeProjectsKeep = [ "important-project" "long-running-research" ];

  # Ollama keep-alive override (Story 08.2-001)
  # Defaults: power "5m", standard "2m", ai-assistant "30s".
  # Uncomment to override — format matches Go duration strings.
  # ollamaKeepAlive = "10m";

  # Ollama LRU pruning (Story 08.1-004) — opt-in
  # When true, runs ollama-lru.sh --auto monthly (1st @ 05:00) to remove
  # models idle >threshold days. Profile-expected models are ALWAYS
  # preserved (see flake.nix ollamaModels.*). Manual control via
  # `ollama-lru` alias (--analyze / --prune / --auto).
  # enableOllamaLRU = true;
  # ollamaLRUThresholdDays = 60;  # default 60

  # Ollama memory-pressure guard (Story 08.2-002)
  # Default: "warn" — unload loaded models when swap usage > 2 GB.
  # "critical" — only unload when swap > 5 GB (less aggressive).
  # "off" — disable the guard entirely.
  # ollamaUnloadOnPressure = "warn";
}
