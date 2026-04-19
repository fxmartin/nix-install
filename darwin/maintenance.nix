# ABOUTME: Maintenance LaunchAgents for automated system cleanup (Epic-06)
# ABOUTME: Configures garbage collection, store optimization, and weekly digest schedules
# ABOUTME: Scripts are installed to ~/.local/bin to avoid macOS TCC restrictions on ~/Documents
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: let
  # Scripts are installed to ~/.local/bin to avoid macOS TCC (Transparency, Consent, Control)
  # restrictions that block LaunchAgents from accessing ~/Documents
  scriptsDir = "/Users/${userConfig.username}/.local/bin";

  # Ollama network config (used in both LaunchAgent and global environment)
  # Bind to all interfaces for Tailscale access; restrict origins to localhost + Tailscale CGNAT
  # NOTE: Only one * per origin pattern (gin-contrib/cors limitation in Ollama 0.15+)
  ollamaHost = "0.0.0.0";
  ollamaOrigins = "http://localhost:*,http://127.0.0.1:*,http://100.*";

  # Standard PATH for scheduled LaunchAgents (includes per-user Nix profile)
  agentPath = "/etc/profiles/per-user/${userConfig.username}/bin:/run/current-system/sw/bin:/usr/bin:/bin";
  agentHome = "/Users/${userConfig.username}";

  # Helper to create a scheduled LaunchAgent with consistent defaults
  # Reduces boilerplate across all maintenance agents
  mkScheduledAgent = {
    command,                        # Bash command to execute
    schedule,                       # StartCalendarInterval attrset (e.g., { Hour = 3; Minute = 0; })
    name,                           # Agent name (used for log file paths)
    env ? {},                       # Extra environment variables (merged with PATH/HOME defaults)
    runAtLoad ? false,              # Start immediately at login
    keepAlive ? false,              # Restart if process exits
  }: {
    serviceConfig = {
      ProgramArguments = [ "/bin/bash" "-c" command ];
      StartCalendarInterval = [ schedule ];
      StandardOutPath = "/tmp/${name}.log";
      StandardErrorPath = "/tmp/${name}.err";
      EnvironmentVariables = {
        PATH = agentPath;
        HOME = agentHome;
      } // env;
      RunAtLoad = runAtLoad;
      KeepAlive = keepAlive;
      Umask = 77;  # 0077 — restrict log/output files to owner only
    };
  };
in {
  # =============================================================================
  # MAINTENANCE LAUNCHAGENTS (Epic-06: Maintenance & Monitoring)
  # =============================================================================
  # User-level LaunchAgents for automated Nix maintenance tasks
  # Reference: https://daiderd.com/nix-darwin/manual/index.html#opt-launchd.user.agents
  #
  # NOTE: Scripts must be in ~/.local/bin (not ~/Documents) because macOS TCC
  # blocks LaunchAgents from accessing protected folders like ~/Documents

  launchd.user.agents = {
    # =========================================================================
    # GARBAGE COLLECTION (Feature 06.1, Story 06.1-001)
    # =========================================================================
    # Runs daily at 3:00 AM to remove generations older than 30 days
    # Keeps recent generations for rollback capability
    nix-gc = mkScheduledAgent {
      name = "nix-gc";
      schedule = { Hour = 3; Minute = 0; };
      command = ''
        echo "=== Nix Garbage Collection ===" >> /tmp/nix-gc.log
        echo "Started at: $(date)" >> /tmp/nix-gc.log
        echo "Removing generations older than 30 days..." >> /tmp/nix-gc.log

        if /run/current-system/sw/bin/nix-collect-garbage --delete-older-than 30d >> /tmp/nix-gc.log 2>&1; then
          echo "✓ Garbage collection completed successfully" >> /tmp/nix-gc.log
        else
          echo "✗ Garbage collection failed with exit code $?" >> /tmp/nix-gc.log
          exit 1
        fi

        echo "Completed at: $(date)" >> /tmp/nix-gc.log
        echo "---" >> /tmp/nix-gc.log
      '';
    };

    # =========================================================================
    # STORE OPTIMIZATION (Feature 06.2, Story 06.2-001)
    # =========================================================================
    # Runs daily at 3:30 AM (after GC) to deduplicate store via hard-linking
    # Saves disk space by linking identical files
    nix-optimize = mkScheduledAgent {
      name = "nix-optimize";
      schedule = { Hour = 3; Minute = 30; };
      command = ''
        echo "=== Nix Store Optimization ===" >> /tmp/nix-optimize.log
        echo "Started at: $(date)" >> /tmp/nix-optimize.log
        echo "Hard-linking identical files in store..." >> /tmp/nix-optimize.log

        if /run/current-system/sw/bin/nix-store --optimize >> /tmp/nix-optimize.log 2>&1; then
          echo "✓ Store optimization completed successfully" >> /tmp/nix-optimize.log
        else
          echo "✗ Store optimization failed with exit code $?" >> /tmp/nix-optimize.log
          exit 1
        fi

        echo "Completed at: $(date)" >> /tmp/nix-optimize.log
        echo "---" >> /tmp/nix-optimize.log
      '';
    };

    # =========================================================================
    # WEEKLY MAINTENANCE DIGEST (Feature 06.5, Story 06.5-003)
    # =========================================================================
    # Runs weekly on Sunday at 8:00 AM to send maintenance summary email
    # Aggregates GC/optimization stats and system health metrics
    weekly-digest = mkScheduledAgent {
      name = "weekly-digest";
      schedule = { Weekday = 0; Hour = 8; Minute = 0; };
      env = { NOTIFICATION_EMAIL = userConfig.notificationEmail; };
      command = ''
        SCRIPT="${scriptsDir}/weekly-maintenance-digest.sh"
        if [[ -x "$SCRIPT" ]]; then
          "$SCRIPT" "${userConfig.notificationEmail}"
        else
          echo "Weekly digest script not found: $SCRIPT" >> /tmp/weekly-digest.err
          exit 1
        fi
      '';
    };

    # =========================================================================
    # RELEASE MONITOR (Feature 06.6, Story 06.6-004)
    # =========================================================================
    # Runs weekly on Monday at 7:00 AM to check for upstream updates
    # Fetches Homebrew, Nix, nix-darwin, and Ollama releases
    # Analyzes with Claude CLI and creates GitHub issues for actionable items
    release-monitor = mkScheduledAgent {
      name = "release-monitor";
      schedule = { Weekday = 1; Hour = 7; Minute = 0; };
      env = { NOTIFICATION_EMAIL = userConfig.notificationEmail; };
      command = ''
        SCRIPT="${scriptsDir}/release-monitor.sh"
        if [[ -x "$SCRIPT" ]]; then
          "$SCRIPT"
        else
          echo "Release monitor script not found: $SCRIPT" >> /tmp/release-monitor.err
          exit 1
        fi
      '';
    };

    # =========================================================================
    # MONTHLY DISK CLEANUP (Feature 06.7, Story 06.7-001)
    # =========================================================================
    # Runs monthly on the 1st at 4:00 AM to clean development caches
    # Cleans uv, Homebrew, npm, pip, node-gyp, and Docker caches
    # Sends email report to NOTIFICATION_EMAIL after cleanup
    disk-cleanup = mkScheduledAgent {
      name = "disk-cleanup";
      schedule = { Day = 1; Hour = 4; Minute = 0; };
      env = {
        NOTIFICATION_EMAIL = userConfig.notificationEmail;
        SCRIPTS_DIR = scriptsDir;
      };
      command = ''
        SCRIPT="${scriptsDir}/disk-cleanup.sh"
        if [[ -x "$SCRIPT" ]]; then
          "$SCRIPT"
        else
          echo "Disk cleanup script not found: $SCRIPT" >> /tmp/disk-cleanup.err
          exit 1
        fi
      '';
    };

    # =========================================================================
    # CLAUDE CODE ORPHAN CLEANUP
    # =========================================================================
    # Runs every 90 minutes to kill orphaned Claude Code MCP / node server
    # processes (PPID=1 only — live Claude Code sessions are untouched).
    # Mitigates the kalloc.1024 kernel memory leak seen when running many
    # parallel Claude Code agents on macOS.
    #
    # NOTE: Uses StartInterval (not StartCalendarInterval) so it's a simple
    # periodic timer. The mkScheduledAgent helper doesn't cover this shape,
    # so the service is defined directly.
    claude-code-cleanup = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/bash" "-c"
          ''
            SCRIPT="${scriptsDir}/claude-cleanup.sh"
            if [[ -x "$SCRIPT" ]]; then
              "$SCRIPT"
            else
              echo "Claude cleanup script not found: $SCRIPT" >> /tmp/claude-code-cleanup.err
              exit 1
            fi
          ''
        ];
        StartInterval = 5400;  # 90 minutes
        StandardOutPath = "/tmp/claude-code-cleanup.log";
        StandardErrorPath = "/tmp/claude-code-cleanup.err";
        EnvironmentVariables = {
          PATH = agentPath;
          HOME = agentHome;
        };
        RunAtLoad = false;
        Umask = 77;
      };
    };

    # =========================================================================
    # OLLAMA SERVER (Network-accessible via Tailscale)
    # =========================================================================
    # Starts Ollama server at login bound to all interfaces (0.0.0.0)
    # Allows access via Tailscale from other devices on the mesh network
    # Security: OLLAMA_ORIGINS restricts API access to Tailscale IPs only (100.x.x.x)
    #
    # NOTE: Uses a bash wrapper to kill any existing Ollama process first.
    # Safety measure in case another Ollama instance is running (e.g., manually started).
    # The pkill ensures this LaunchAgent always owns the 0.0.0.0 binding.
    ollama-serve = mkScheduledAgent {
      name = "ollama-serve";
      # Schedule unused for KeepAlive services but required by mkScheduledAgent
      schedule = { Hour = 0; Minute = 0; };
      runAtLoad = true;
      keepAlive = true;
      env = {
        OLLAMA_HOST = ollamaHost;
        OLLAMA_ORIGINS = ollamaOrigins;
        PATH = "/opt/homebrew/bin:/run/current-system/sw/bin:/usr/bin:/bin";
      };
      command = ''
        # Kill any existing Ollama server that may be bound to localhost only
        /usr/bin/pkill -f "ollama serve" 2>/dev/null || true
        /usr/bin/pkill -x ollama 2>/dev/null || true
        sleep 2
        # Start Ollama bound to all interfaces via OLLAMA_HOST env var
        exec /opt/homebrew/bin/ollama serve
      '';
    };
  };

  # Global environment variables for Ollama
  # Ensures any manually started Ollama server (e.g., `ollama serve` from terminal)
  # also binds to all interfaces for Tailscale accessibility
  environment.variables.OLLAMA_HOST = ollamaHost;
  environment.variables.OLLAMA_ORIGINS = ollamaOrigins;
}
