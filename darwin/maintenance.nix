# ABOUTME: Maintenance LaunchAgents for automated system cleanup (Epic-06)
# ABOUTME: Configures garbage collection, store optimization, and weekly digest schedules
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # =============================================================================
  # MAINTENANCE LAUNCHAGENTS (Epic-06: Maintenance & Monitoring)
  # =============================================================================
  # User-level LaunchAgents for automated Nix maintenance tasks
  # Reference: https://daiderd.com/nix-darwin/manual/index.html#opt-launchd.user.agents

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

        # Environment
        EnvironmentVariables = {
          PATH = "/run/current-system/sw/bin:/usr/bin:/bin";
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

        # Environment
        EnvironmentVariables = {
          PATH = "/run/current-system/sw/bin:/usr/bin:/bin";
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
            export NOTIFICATION_EMAIL="${userConfig.email}"
            export PATH="/run/current-system/sw/bin:/usr/bin:/bin:$PATH"
            export HOME="/Users/${userConfig.username}"

            # Run weekly digest script
            SCRIPT="${"$"}{HOME}/Documents/nix-install/scripts/weekly-maintenance-digest.sh"
            if [[ -x "$SCRIPT" ]]; then
              "$SCRIPT" "${userConfig.email}"
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

        # Environment
        EnvironmentVariables = {
          PATH = "/run/current-system/sw/bin:/usr/bin:/bin";
          HOME = "/Users/${userConfig.username}";
          NOTIFICATION_EMAIL = userConfig.email;
        };

        # Don't restart on failure - wait for next scheduled run
        RunAtLoad = false;
        KeepAlive = false;
      };
    };
  };
}
