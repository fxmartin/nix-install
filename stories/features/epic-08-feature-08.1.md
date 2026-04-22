# ABOUTME: Epic-08 Feature 08.1 (Disk Consumption Optimization) implementation details
# ABOUTME: System-level GC, cache coverage gaps, Ollama LRU, pre-rebuild guard, growth telemetry

# Epic-08 Feature 08.1: Disk Consumption Optimization

## Feature Overview

**Feature ID**: Feature 08.1
**Feature Name**: Disk Consumption Optimization
**Epic**: Epic-08
**Status**: ✅ Complete (shipped 2026-04-21)

### Delivery Summary
| Story | Title | PR | Notes |
|-------|-------|----|-------|
| 08.1-001 | System-Level GC LaunchDaemon | #270 | `darwin/maintenance-system.nix`, Sunday 04:00 |
| 08.1-002 | Huggingface Cache Pruning | #261, fix #269 | `cleanup_huggingface()` — atime → mtime after APFS `noatime` discovery |
| 08.1-003 | Browser Cache Cleanup | #262 | Arc/Brave/Chrome, skips running browsers |
| 08.1-004 | Ollama LRU Pruning | #268, fix #273 | `scripts/ollama-lru.sh` + activation sync to `~/.local/bin` |
| 08.1-005 | Docker Quarterly Deep-Prune | #266 | LaunchAgent on 1st of Jan/Apr/Jul/Oct |
| 08.1-006 | `~/.claude/projects` Pruning | #263 | `claude-cleanup.sh --prune-old` + weekly LaunchAgent, `memory/` preserved |
| 08.1-007 | Pre-Rebuild Disk Guard | #259 | `rebuild`/`update` refuse <10 GB free; `--force` bypass |
| 08.1-008 | Growth Telemetry in Digest | #267 | Week-over-week per-consumer deltas in weekly digest |

### Feature 08.1: Disk Consumption Optimization
**Feature Description**: Close the disk leaks that v1.0.0 maintenance misses: system-level Nix generations, Huggingface cache, browser caches, stale Ollama models, unbounded `~/.claude/projects/`. Add a pre-rebuild guard and per-consumer growth telemetry in the weekly digest.
**User Value**: Reclaim 12–18 GB of "invisible" disk today and bound long-term growth automatically
**Story Count**: 8
**Story Points**: 44
**Priority**: Must Have (P0)
**Complexity**: Medium

#### Stories in This Feature

---

##### Story 08.1-001: System-Level Garbage Collection LaunchDaemon
**User Story**: As FX, I want a weekly system-level Nix GC to run as root so that system profile generations don't accumulate unbounded (currently 175 on Power)

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 11

**Acceptance Criteria**:
- **Given** `ls /nix/var/nix/profiles/system-*-link | wc -l` returns a number >20
- **When** the weekly system-GC LaunchDaemon fires (Sunday 4 AM)
- **Then** it runs `nix-collect-garbage --delete-older-than 30d` as root
- **And** the count drops to <20 after one cycle
- **And** the current system generation is always preserved
- **And** output is logged to `/tmp/nix-gc-system.log`
- **And** failures trigger email via `send-notification.sh`

**Additional Requirements**:
- LaunchDaemon (not agent) — requires root for `/nix/var/nix/profiles/system-*`
- Schedule: Sunday 4:00 AM (after `nix-gc` user agent, before `nix-optimize`)
- Dry-run mode: `--dry-run` flag logged before first production run
- Report generations deleted and space freed in log

**Technical Notes**:
- New file: `darwin/maintenance-system.nix` imported by `commonModules`
- LaunchDaemon shape (note `launchd.daemons.*`, not `launchd.user.agents.*`):
  ```nix
  launchd.daemons.nix-gc-system = {
    serviceConfig = {
      Label = "org.nixos.nix-gc-system";
      ProgramArguments = [
        "/bin/bash" "-c"
        "/run/current-system/sw/bin/nix-collect-garbage --delete-older-than 30d"
      ];
      StartCalendarInterval = [{ Weekday = 0; Hour = 4; Minute = 0; }];
      StandardOutPath = "/tmp/nix-gc-system.log";
      StandardErrorPath = "/tmp/nix-gc-system.err";
      UserName = "root";
    };
  };
  ```
- Verify: `sudo launchctl list | grep nix-gc-system`
- Manual trigger for testing: `sudo launchctl start org.nixos.nix-gc-system`
- Add `gc-system` alias (already referenced in health-check tips) → `sudo nix-collect-garbage -d`

**Definition of Done**:
- [ ] LaunchDaemon created via nix-darwin
- [ ] Runs as root weekly at Sunday 4 AM
- [ ] System generation count drops to <20 on first cycle on Power profile
- [ ] Failure path sends email
- [ ] `gc-system` alias documented and working

**Dependencies**:
- Epic-06 Story 06.1-001 (nix-gc user agent pattern)

**Risk Level**: Medium
**Risk Mitigation**: Dry-run validation; retention window 30d matches user-level agent

---

##### Story 08.1-002: Extend disk-cleanup for Huggingface Cache
**User Story**: As FX, I want `~/.cache/huggingface` pruned by the monthly disk-cleanup so that HF downloads don't silently accumulate (currently 14 GB)

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 11

**Acceptance Criteria**:
- **Given** `~/.cache/huggingface/hub` exceeds 5 GB
- **When** `disk-cleanup.sh` runs (monthly or manual)
- **Then** it prunes `hub/` with an LRU strategy retaining models accessed in the last 60 days
- **And** `datasets/` snapshots older than 90 days are removed
- **And** `health-check.sh` reports HF cache size with warning at >10 GB

**Additional Requirements**:
- Add `HF_CACHE_WARNING_KB=10485760` (10 GB) threshold shared between `health-check.sh` and `health-api.py`
- Preserve `token` and `config.json` in `~/.cache/huggingface/`
- Dry-run support: `disk-cleanup --analyze` shows what would be removed

**Technical Notes**:
- Use `find ~/.cache/huggingface/hub/models--*/blobs -type f -atime +60 -delete` (atime, not mtime — HF touches blobs on use)
- APFS defaults to `noatime` on `/`; verify with `mount | grep "^/dev/disk3s5"` — if `noatime`, fall back to `ctime` on snapshot dirs or log a one-time warning
- Add `cleanup_huggingface()` function to `scripts/disk-cleanup.sh` between `cleanup_pip` and `cleanup_nodegyp`
- Extend `get_caches()` in `health-api.py` to include `huggingface`

**Definition of Done**:
- [ ] `cleanup_huggingface()` added to `disk-cleanup.sh`
- [ ] Threshold constant shared across `health-check.sh` and `health-api.py`
- [ ] `--analyze` mode lists HF cache before pruning
- [ ] Tested on Power profile (14 GB → <5 GB)

**Dependencies**:
- Epic-06 Story 06.7-001 (disk-cleanup.sh base)

**Risk Level**: Low

---

##### Story 08.1-003: Browser Cache Cleanup
**User Story**: As FX, I want Arc/Brave/Chrome caches cleaned monthly so that they don't grow past 3 GB combined

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 11

**Acceptance Criteria**:
- **Given** browser caches in `~/Library/Caches/{Arc,company.thebrowser.Browser,BraveSoftware,Google}`
- **When** `disk-cleanup.sh` runs
- **Then** it clears each cache only if the corresponding browser is NOT currently running (avoids DB corruption)
- **And** it skips (with reason logged) when a browser is live
- **And** total browser cache drops by >70% post-run

**Additional Requirements**:
- Running-process detection: `pgrep -x "Arc"`, `pgrep -x "Brave Browser"`, `pgrep -x "Google Chrome"`
- Include both Arc paths (`Arc` and `company.thebrowser.Browser` — duplicated by historical path migration)
- Safe targets: Only `Cache/` and `Code Cache/` subdirs, never profile data
- Report per-browser before/after sizes

**Technical Notes**:
- New function `cleanup_browsers()` in `disk-cleanup.sh`
- Loop over `{ "Arc", "company.thebrowser.Browser", "BraveSoftware/Brave-Browser", "Google/Chrome" }` with matching `pgrep` labels
- Remove only `Cache/Cache_Data/`, `Code Cache/`, `GPUCache/` — preserve `Network`, `Sessions`, cookies, bookmarks
- Add to health-check warnings if total >2 GB

**Definition of Done**:
- [ ] `cleanup_browsers()` added
- [ ] Running browsers skipped with log line
- [ ] Only cache subdirs removed (profile data untouched)
- [ ] Dry-run + analyze mode support
- [ ] Tested on Power (3+ GB → <500 MB)

**Dependencies**:
- Story 08.1-002 (disk-cleanup extension pattern)

**Risk Level**: Low

---

##### Story 08.1-004: Ollama LRU Model Pruning
**User Story**: As FX, I want stale Ollama models (not used in N days) flagged and optionally auto-removed so that 9.6 GB doesn't sit idle

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 11

**Acceptance Criteria**:
- **Given** Ollama models on disk under `~/.ollama/models`
- **When** `ollama-lru` script runs
- **Then** it reports each model with last-used timestamp and days-since-use
- **And** models unused >30 days are listed as prune candidates
- **And** `ollama-lru --prune` asks for `y/N` confirmation per model before `ollama rm`
- **And** `ollama-lru --auto --threshold-days=60` removes without prompting (for LaunchAgent)
- **And** expected profile models (from `flake.nix` `ollamaModels.*`) are NEVER pruned automatically

**Additional Requirements**:
- New script: `scripts/ollama-lru.sh`
- Last-used: touch `~/.ollama/lru/<model-tag>` after each `ollama run` via shell wrapper OR parse HTTP access log if enabled
- Profile-aware: reads `user-config.nix installProfile` to protect expected models
- Integration: weekly-digest includes "Ollama models not used in 14+ days"

**Technical Notes**:
- Simplest last-used source: `stat -f '%m' ~/.ollama/models/manifests/registry.ollama.ai/library/<model>/<tag>` (manifest mtime is bumped on pull, not on use — insufficient)
- Better: shell wrapper `ollama-run` that `touch`es a tracking file then `exec`s real ollama
- Alternative: parse `~/.ollama/logs/server.log` for `POST /api/generate` with model name
- Script must handle model names with `:` tag separator
- Add aliases: `ollama-lru`, `ollama-lru-dry-run`
- New LaunchAgent `ollama-lru-monthly` (opt-in, behind `user-config.nix` flag `enableOllamaLRU = true`)

**Definition of Done**:
- [ ] `scripts/ollama-lru.sh` with `--analyze`, `--prune`, `--auto` modes
- [ ] Wrapper or log-parser tracks last-use
- [ ] Expected-model protection via profile detection
- [ ] Weekly digest includes stale model list
- [ ] Opt-in LaunchAgent documented in `docs/customization.md`

**Dependencies**:
- `flake.nix` `ollamaModels` structure (existing)

**Risk Level**: Medium
**Risk Mitigation**: Profile-model protection list prevents auto-removing required models; default is report-only

---

##### Story 08.1-005: Docker Quarterly Deep Prune
**User Story**: As FX, I want Docker's 13 GB VM image and build cache deep-pruned quarterly so that monthly `docker system prune` isn't enough

**Priority**: Should Have
**Story Points**: 3
**Sprint**: Sprint 11

**Acceptance Criteria**:
- **Given** Docker Desktop is not running OR is idle
- **When** the quarterly `docker-deep-prune` agent fires (1st of Jan/Apr/Jul/Oct at 4:30 AM)
- **Then** it runs `docker builder prune --all -f`, `docker volume prune -f`, `docker system prune -a --volumes -f`
- **And** it skips if Docker Desktop has running containers (safe check)
- **And** reports space reclaimed in log

**Additional Requirements**:
- New LaunchAgent `docker-deep-prune` in `darwin/maintenance.nix`
- `StartCalendarInterval` with 4 entries (one per quarter start)
- Pre-check: `docker ps -q | wc -l` must be 0

**Technical Notes**:
- Extends existing `cleanup_containers()` in `disk-cleanup.sh` — add `--deep` flag
- Only runs if `/Applications/Docker.app` exists (skip on AI-assistant profile)

**Definition of Done**:
- [ ] New LaunchAgent scheduled quarterly
- [ ] Safe container check
- [ ] Space-reclaimed reported
- [ ] Skipped cleanly on ai-assistant profile

**Dependencies**:
- Epic-06 Feature 06.7 (disk-cleanup)

**Risk Level**: Low

---

##### Story 08.1-006: ~/.claude Project Pruning
**User Story**: As FX, I want `~/.claude/projects/*` older than 90 days archived so that 1.2 GB of old transcripts doesn't grow unbounded

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 11

**Acceptance Criteria**:
- **Given** per-project transcript dirs under `~/.claude/projects/`
- **When** `claude-cleanup.sh` runs in `--prune-old` mode
- **Then** project dirs not modified in 90 days are deleted
- **And** `memory/` subdirs are ALWAYS preserved (auto-memory persists across conversations)
- **And** a summary file `~/.claude/archive/pruned-<date>.txt` lists what was removed

**Additional Requirements**:
- Extend existing `claude-cleanup.sh` (currently orphan-process-only) with `--prune-old` subcommand
- Existing LaunchAgent (90-minute orphan kill) stays unchanged; add a weekly invocation with `--prune-old` flag
- Preserve any path matching `**/memory/**`

**Technical Notes**:
- Detection via `find ~/.claude/projects -maxdepth 1 -type d -mtime +90`
- Guard: confirm each candidate dir contains no `memory/` subdir OR skip that subdir with `find` pruning
- Retention exception list configurable via `user-config.nix` (`claudeProjectsKeep = [ "my-important-project" ]`)

**Definition of Done**:
- [ ] `claude-cleanup.sh --prune-old` implemented
- [ ] `memory/` always preserved (tested with memory inside old project)
- [ ] Weekly LaunchAgent schedule added
- [ ] Keep-list in `user-config.nix` works

**Dependencies**:
- Existing `scripts/claude-cleanup.sh` and `maintenance.nix`

**Risk Level**: Low

---

##### Story 08.1-007: Pre-Rebuild Disk Guard
**User Story**: As FX, I want `rebuild` and `update` to refuse running when free disk is <10 GB so that I don't fill the disk mid-build

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 11

**Acceptance Criteria**:
- **Given** free disk (via Finder metric: `volumeAvailableCapacityForImportantUsage`) is <10 GB
- **When** I run `rebuild` or `update`
- **Then** the alias refuses with a clear error showing free GB
- **And** it offers: `gc`, `gc-system`, `disk-cleanup`, or `--force` to bypass
- **And** `--force` flag bypasses the check
- **And** the guard is skipped entirely when running inside CI

**Additional Requirements**:
- Modify `shell.nix` `rebuild` / `update` function definitions (wrappers around `darwin-rebuild switch`)
- Use the same Swift one-liner as `health-api.py check_disk()` for Finder-equivalent metric
- Threshold constant shared with `health-check.sh` (extend `DISK_WARNING_GB` or introduce `DISK_REBUILD_MIN_GB`)

**Technical Notes**:
- Current `rebuild` alias likely lives in `home-manager/modules/shell.nix`
- New shape:
  ```bash
  rebuild() {
    local force=0
    [[ "${1:-}" == "--force" ]] && force=1 && shift
    if [[ $force -eq 0 && -z "${CI:-}" ]]; then
      local free_gb=$(swift -e '...' 2>/dev/null || echo 999)
      if (( free_gb < 10 )); then
        echo "✗ Only ${free_gb}GB free. Run: gc, gc-system, disk-cleanup, or rebuild --force"
        return 1
      fi
    fi
    darwin-rebuild switch --flake ~/.config/nix-install "$@"
  }
  ```
- Keep the function tight — CLAUDE.md says surgical changes

**Definition of Done**:
- [ ] `rebuild` refuses <10 GB free
- [ ] `update` same guard
- [ ] `--force` bypass works
- [ ] CI bypass via `$CI` env
- [ ] Tested by filling disk to 9 GB free and attempting rebuild

**Dependencies**:
- Existing shell aliases in `home-manager/modules/shell.nix`

**Risk Level**: Low

---

##### Story 08.1-008: Growth Telemetry in Weekly Digest
**User Story**: As FX, I want the weekly digest to show week-over-week disk growth per consumer so that I can catch silent leaks early

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 11

**Acceptance Criteria**:
- **Given** the weekly digest runs Sunday 8 AM
- **When** it assembles the email body
- **Then** it includes a "Disk Consumers — Week over Week" section with:
  - Previous week size, current size, delta (GB and %)
  - Per consumer: `/nix/store`, `~/.ollama`, `~/.cache/huggingface`, Docker, `~/Library/Caches` total, `~/.claude`
- **And** consumers growing >1 GB/week are flagged with ⚠
- **And** history is persisted to `~/.local/share/nix-install/disk-history.json`

**Additional Requirements**:
- Rolling history: keep 12 weeks, trim older entries
- On first run, no previous data → show "baseline" label
- Integration: new function `collect_disk_metrics()` in `weekly-maintenance-digest.sh`

**Technical Notes**:
- History format:
  ```json
  {"samples": [{"ts": "2026-04-20T08:00:00Z", "sizes_kb": {"nix_store": 11534336, ...}}, ...]}
  ```
- Use `jq` for read/write (already in PATH on all profiles)
- Previous sample = second-most-recent; current = just collected

**Definition of Done**:
- [ ] `collect_disk_metrics()` added to digest script
- [ ] History file persisted under `~/.local/share/nix-install/`
- [ ] Growth section rendered in email body
- [ ] >1 GB/week flagged
- [ ] 12-week trim works

**Dependencies**:
- Epic-06 Story 06.5-003 (weekly-maintenance-digest.sh)

**Risk Level**: Low

---
