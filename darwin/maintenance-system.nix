# ABOUTME: Root-level LaunchDaemon for weekly system-profile garbage collection (Story 08.1-001)
# ABOUTME: Prunes /nix/var/nix/profiles/system-*-link generations that user-level nix-gc cannot touch
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # =============================================================================
  # SYSTEM-LEVEL GARBAGE COLLECTION (Story 08.1-001)
  # =============================================================================
  # The existing user-level nix-gc LaunchAgent (darwin/maintenance.nix) runs as
  # $USER and prunes per-user generations only. System profile generations
  # (/nix/var/nix/profiles/system-*-link) are root-owned and accumulate unbounded
  # until this runs — 175 generations observed on a Power-profile machine before
  # this daemon existed.
  #
  # LaunchDaemon (not LaunchAgent) — needs root to touch the system profile.
  # First launchd.daemons.* in this repo; future root-scheduled work should
  # live alongside this module.
  #
  # Schedule: Sunday 04:00 — between the daily nix-gc (03:00) and
  # nix-optimize (03:30). Running later means weekly-digest (Sunday 08:00)
  # still sees the result in the same report cycle.
  #
  # Safety: `nix-collect-garbage` always preserves the currently-booted
  # system generation, so rollback capability is preserved (just to a
  # narrower retention window).

  launchd.daemons.nix-gc-system = {
    serviceConfig = {
      Label = "org.nixos.nix-gc-system";
      ProgramArguments = [
        "/bin/bash" "-c"
        ''
          LOG=/var/log/nix-gc-system.log
          {
            echo "=== System Nix GC $(date '+%Y-%m-%d %H:%M:%S') ==="

            # Capture the generation count + store size before pruning so the
            # log shows what was reclaimed.
            before_gens=$(ls -1 /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l | tr -d ' ')
            before_size=$(du -sh /nix/store 2>/dev/null | cut -f1)
            echo "Before: $before_gens system generations, /nix/store = $before_size"

            if /run/current-system/sw/bin/nix-collect-garbage --delete-older-than 30d; then
              after_gens=$(ls -1 /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l | tr -d ' ')
              after_size=$(du -sh /nix/store 2>/dev/null | cut -f1)
              echo "After:  $after_gens system generations, /nix/store = $after_size"
              echo "✓ System GC completed"
            else
              echo "✗ System GC failed with exit code $?"
              exit 1
            fi

            echo "---"
          } >> "$LOG" 2>&1
        ''
      ];

      # Weekly: Sunday 04:00
      StartCalendarInterval = [
        { Weekday = 0; Hour = 4; Minute = 0; }
      ];

      # Daemon runs as root (required to prune system-*-link).
      # No need to set UserName — daemons default to root. Setting explicitly
      # for clarity.
      UserName = "root";
      GroupName = "wheel";

      # Logs live in /var/log (preserved across reboots, unlike /tmp).
      # Only root-writable, which is fine — this daemon runs as root.
      StandardOutPath = "/var/log/nix-gc-system.log";
      StandardErrorPath = "/var/log/nix-gc-system.err";

      # Sane, minimal PATH for a root cron-like job. /run/current-system/sw/bin
      # is the primary path; the rest are fallbacks for coreutils.
      EnvironmentVariables = {
        PATH = "/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };

      RunAtLoad = false;
      Umask = 77;  # 0077 — logs owner-readable only
    };
  };
}
