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
    nix-gc = {
      serviceConfig = {
        # Command to execute
        # Uses --delete-older-than 30d to keep recent generations for rollback
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            echo "=== Nix Garbage Collection ===" >> /tmp/nix-gc.log
            echo "Started at: $(date)" >> /tmp/nix-gc.log
            echo "Removing generations older than 30 days..." >> /tmp/nix-gc.log

            # Run garbage collection
            if /run/current-system/sw/bin/nix-collect-garbage --delete-older-than 30d >> /tmp/nix-gc.log 2>&1; then
              echo "✓ Garbage collection completed successfully" >> /tmp/nix-gc.log
            else
              echo "✗ Garbage collection failed with exit code $?" >> /tmp/nix-gc.log
              exit 1
            fi

            echo "Completed at: $(date)" >> /tmp/nix-gc.log
            echo "---" >> /tmp/nix-gc.log
          ''
        ];

        # Schedule: Daily at 3:00 AM
        StartCalendarInterval = [
          {
            Hour = 3;
            Minute = 0;
          }
        ];

        # Logging configuration
        StandardOutPath = "/tmp/nix-gc.log";
        StandardErrorPath = "/tmp/nix-gc.err";

        # Environment - include per-user profile for consistency with other agents
        EnvironmentVariables = {
          PATH = "/etc/profiles/per-user/${userConfig.username}/bin:/run/current-system/sw/bin:/usr/bin:/bin";
          HOME = "/Users/${userConfig.username}";
        };

        # Don't restart on failure - wait for next scheduled run
        RunAtLoad = false;
        KeepAlive = false;
      };
    };

    # =========================================================================
    # STORE OPTIMIZATION (Feature 06.2, Story 06.2-001)
    # =========================================================================
    # Runs daily at 3:30 AM (after GC) to deduplicate store via hard-linking
    # Saves disk space by linking identical files
    nix-optimize = {
      serviceConfig = {
        # Command to execute
        # Runs after GC to optimize the now-cleaned store
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            echo "=== Nix Store Optimization ===" >> /tmp/nix-optimize.log
            echo "Started at: $(date)" >> /tmp/nix-optimize.log
            echo "Hard-linking identical files in store..." >> /tmp/nix-optimize.log

            # Run store optimization
            if /run/current-system/sw/bin/nix-store --optimize >> /tmp/nix-optimize.log 2>&1; then
              echo "✓ Store optimization completed successfully" >> /tmp/nix-optimize.log
            else
              echo "✗ Store optimization failed with exit code $?" >> /tmp/nix-optimize.log
              exit 1
            fi

            echo "Completed at: $(date)" >> /tmp/nix-optimize.log
            echo "---" >> /tmp/nix-optimize.log
          ''
        ];

        # Schedule: Daily at 3:30 AM (30 minutes after GC)
        StartCalendarInterval = [
          {
            Hour = 3;
            Minute = 30;
          }
        ];

        # Logging configuration
        StandardOutPath = "/tmp/nix-optimize.log";
        StandardErrorPath = "/tmp/nix-optimize.err";

        # Environment - include per-user profile for consistency with other agents
        EnvironmentVariables = {
          PATH = "/etc/profiles/per-user/${userConfig.username}/bin:/run/current-system/sw/bin:/usr/bin:/bin";
          HOME = "/Users/${userConfig.username}";
        };

        # Don't restart on failure - wait for next scheduled run
        RunAtLoad = false;
        KeepAlive = false;
      };
    };

    # =========================================================================
    # WEEKLY MAINTENANCE DIGEST (Feature 06.5, Story 06.5-003)
    # =========================================================================
    # Runs weekly on Sunday at 8:00 AM to send maintenance summary email
    # Aggregates GC/optimization stats and system health metrics
    weekly-digest = {
      serviceConfig = {
        # Command to execute weekly digest script
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            # Set notification email from user config
            export NOTIFICATION_EMAIL="${userConfig.notificationEmail}"
            export PATH="/run/current-system/sw/bin:/usr/bin:/bin:$PATH"
            export HOME="/Users/${userConfig.username}"

            # Run weekly digest script from ~/.local/bin (TCC-safe location)
            SCRIPT="${scriptsDir}/weekly-maintenance-digest.sh"
            if [[ -x "$SCRIPT" ]]; then
              "$SCRIPT" "${userConfig.notificationEmail}"
            else
              echo "Weekly digest script not found: $SCRIPT" >> /tmp/weekly-digest.err
              exit 1
            fi
          ''
        ];

        # Schedule: Sunday at 8:00 AM
        # Weekday: 0 = Sunday, 1 = Monday, ..., 6 = Saturday
        StartCalendarInterval = [
          {
            Weekday = 0;
            Hour = 8;
            Minute = 0;
          }
        ];

        # Logging configuration
        StandardOutPath = "/tmp/weekly-digest.log";
        StandardErrorPath = "/tmp/weekly-digest.err";

        # Environment - must include per-user Nix profile for msmtp
        EnvironmentVariables = {
          PATH = "/etc/profiles/per-user/${userConfig.username}/bin:/run/current-system/sw/bin:/usr/bin:/bin";
          HOME = "/Users/${userConfig.username}";
          NOTIFICATION_EMAIL = userConfig.notificationEmail;
        };

        # Don't restart on failure - wait for next scheduled run
        RunAtLoad = false;
        KeepAlive = false;
      };
    };

    # =========================================================================
    # RELEASE MONITOR (Feature 06.6, Story 06.6-004)
    # =========================================================================
    # Runs weekly on Monday at 7:00 AM to check for upstream updates
    # Fetches Homebrew, Nix, nix-darwin, and Ollama releases
    # Analyzes with Claude CLI and creates GitHub issues for actionable items
    release-monitor = {
      serviceConfig = {
        # Command to execute release monitor script
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            # Set environment
            export NOTIFICATION_EMAIL="${userConfig.notificationEmail}"
            export PATH="/run/current-system/sw/bin:/usr/bin:/bin:$PATH"
            export HOME="/Users/${userConfig.username}"

            # Run release monitor script from ~/.local/bin (TCC-safe location)
            SCRIPT="${scriptsDir}/release-monitor.sh"
            if [[ -x "$SCRIPT" ]]; then
              "$SCRIPT"
            else
              echo "Release monitor script not found: $SCRIPT" >> /tmp/release-monitor.err
              exit 1
            fi
          ''
        ];

        # Schedule: Monday at 7:00 AM
        # Weekday: 0 = Sunday, 1 = Monday, ..., 6 = Saturday
        StartCalendarInterval = [
          {
            Weekday = 1;
            Hour = 7;
            Minute = 0;
          }
        ];

        # Logging configuration
        StandardOutPath = "/tmp/release-monitor.log";
        StandardErrorPath = "/tmp/release-monitor.err";

        # Environment - must include per-user Nix profile for msmtp and other tools
        EnvironmentVariables = {
          PATH = "/etc/profiles/per-user/${userConfig.username}/bin:/run/current-system/sw/bin:/usr/bin:/bin";
          HOME = "/Users/${userConfig.username}";
          NOTIFICATION_EMAIL = userConfig.notificationEmail;
        };

        # Don't restart on failure - wait for next scheduled run
        RunAtLoad = false;
        KeepAlive = false;
      };
    };

    # =========================================================================
    # MONTHLY DISK CLEANUP (Feature 06.7, Story 06.7-001)
    # =========================================================================
    # Runs monthly on the 1st at 4:00 AM to clean development caches
    # Cleans uv, Homebrew, npm, pip, node-gyp, and Podman/Docker caches
    # Sends email report to NOTIFICATION_EMAIL after cleanup
    disk-cleanup = {
      serviceConfig = {
        # Command to execute disk cleanup script
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            # Set environment
            export NOTIFICATION_EMAIL="${userConfig.notificationEmail}"
            export SCRIPTS_DIR="${scriptsDir}"
            export PATH="/etc/profiles/per-user/${userConfig.username}/bin:/run/current-system/sw/bin:/usr/bin:/bin:$PATH"
            export HOME="/Users/${userConfig.username}"

            # Run disk cleanup script from ~/.local/bin (TCC-safe location)
            SCRIPT="${scriptsDir}/disk-cleanup.sh"
            if [[ -x "$SCRIPT" ]]; then
              "$SCRIPT"
            else
              echo "Disk cleanup script not found: $SCRIPT" >> /tmp/disk-cleanup.err
              exit 1
            fi
          ''
        ];

        # Schedule: 1st of every month at 4:00 AM
        # Day: 1 = 1st day of month
        StartCalendarInterval = [
          {
            Day = 1;
            Hour = 4;
            Minute = 0;
          }
        ];

        # Logging configuration
        StandardOutPath = "/tmp/disk-cleanup.log";
        StandardErrorPath = "/tmp/disk-cleanup.err";

        # Environment - must include per-user Nix profile for msmtp and other tools
        EnvironmentVariables = {
          PATH = "/etc/profiles/per-user/${userConfig.username}/bin:/run/current-system/sw/bin:/usr/bin:/bin";
          HOME = "/Users/${userConfig.username}";
          NOTIFICATION_EMAIL = userConfig.notificationEmail;
          SCRIPTS_DIR = scriptsDir;
        };

        # Don't restart on failure - wait for next scheduled run
        RunAtLoad = false;
        KeepAlive = false;
      };
    };
  };
}
