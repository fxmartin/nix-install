# ABOUTME: Epic-08 Feature 08.2 (Memory Pressure Mitigation) implementation details
# ABOUTME: Ollama env tuning, pressure-triggered unload, agent audit, swap alerting

# Epic-08 Feature 08.2: Memory Pressure Mitigation

## Feature Overview

**Feature ID**: Feature 08.2
**Feature Name**: Memory Pressure Mitigation
**Epic**: Epic-08
**Status**: ✅ Complete (shipped 2026-04-21)

### Delivery Summary
| Story | Title | PR | Notes |
|-------|-------|----|-------|
| 08.2-001 | Tune Ollama LaunchAgent Env | #264 | `OLLAMA_MAX_LOADED_MODELS=1`, `NUM_PARALLEL=1`, profile-scoped `KEEP_ALIVE` |
| 08.2-002 | Memory-Pressure Auto-Unload | #271, fix #273 | `ollama-pressure-guard.sh` + LaunchAgent, 60s poll |
| 08.2-003 | `ollama-warm`/`ollama-evict` Helpers | #260 | Zsh functions in `home-manager/modules/shell.nix` |
| 08.2-004 | LaunchAgent Steady-State Audit | #272, docs #247, fix #274 | `audit-launchagents.sh` + snapshot in `docs/architecture.md` |
| 08.2-005 | Swap-Usage Alerting | #265 | `/metrics` `status_flags.memory_swap`; digest + `health-check.sh` consume it |

### Feature 08.2: Memory Pressure Mitigation
**Feature Description**: Stop Ollama defaults from pinning 20+ GB of RAM on idle. Tune `OLLAMA_MAX_LOADED_MODELS`, `OLLAMA_KEEP_ALIVE`, `OLLAMA_NUM_PARALLEL`; add a memory-pressure-triggered auto-unload agent; audit long-running LaunchAgents; flag swap use.
**User Value**: Eliminate the 3 GB swap + 11 GB compressor steady-state seen today; make large models (gemma4:26b) usable without memory eviction cascades
**Story Count**: 5
**Story Points**: 26
**Priority**: Must Have (P0)
**Complexity**: Medium

#### Stories in This Feature

---

##### Story 08.2-001: Tune Ollama LaunchAgent Environment
**User Story**: As FX, I want Ollama to limit loaded models to 1 and unload fast so that a single large-model call doesn't pin 17 GB for 5 minutes

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 12

**Acceptance Criteria**:
- **Given** the Ollama LaunchAgent starts at login
- **When** I make a request to a model
- **Then** `OLLAMA_MAX_LOADED_MODELS=1` is in effect (second model evicts the first)
- **And** `OLLAMA_KEEP_ALIVE` is profile-scoped: Standard `2m`, Power `5m`, AI-Assistant `30s`
- **And** `OLLAMA_NUM_PARALLEL=1` (single in-flight request prevents speculative memory)
- **And** `ollama ps` confirms unload within keep-alive + 10s grace

**Additional Requirements**:
- Modify `darwin/maintenance.nix` `ollama-serve` agent `env` block
- Profile-aware values via `profileName` specialArg (already available in common modules)
- Document override path: users can set `OLLAMA_KEEP_ALIVE` in `user-config.nix` (`ollamaKeepAlive` optional attr)

**Technical Notes**:
- Current `env` attrs in `maintenance.nix` ollama-serve:
  ```
  OLLAMA_HOST = ollamaHost;
  OLLAMA_ORIGINS = ollamaOrigins;
  ```
- Add:
  ```nix
  OLLAMA_MAX_LOADED_MODELS = "1";
  OLLAMA_NUM_PARALLEL = "1";
  OLLAMA_KEEP_ALIVE = if profileName == "power" then "5m"
                      else if profileName == "ai-assistant" then "30s"
                      else "2m";
  ```
- Also update `environment.variables` block (so manually-started `ollama serve` picks them up)
- Check `profileName` threading: currently only `isPowerProfile` / `profileName` is available in `commonModules`; `maintenance.nix` may need `profileName` added to args

**Definition of Done**:
- [ ] `maintenance.nix` sets all three env vars
- [ ] Per-profile keep-alive correct
- [ ] `environment.variables` block matches
- [ ] `launchctl print gui/$UID/org.nixos.ollama-serve | grep -i environment` shows new vars
- [ ] Manual test: load gemma4:26b, wait 5m+10s, `ollama ps` shows empty

**Dependencies**:
- Existing `darwin/maintenance.nix`

**Risk Level**: Low

---

##### Story 08.2-002: Memory-Pressure Auto-Unload Agent
**User Story**: As FX, I want Ollama models auto-unloaded when macOS reports memory pressure so that the system doesn't swap 3 GB during other workloads

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 12

**Acceptance Criteria**:
- **Given** a LaunchAgent polling memory pressure every 60s
- **When** `memory_pressure` reports `Warning` or `Critical`
- **Then** the agent queries `ollama ps` for loaded models
- **And** unloads each via `curl -X DELETE http://localhost:11434/api/generate -d '{"model": "<name>", "keep_alive": 0}'`
- **And** only unloads models with no request in the last 10s (check via ollama API metrics or log tail)
- **And** logs the action to `/tmp/ollama-pressure.log` with timestamp + pressure state + models unloaded
- **And** does NOT trigger on `Normal` pressure

**Additional Requirements**:
- New script `scripts/ollama-pressure-guard.sh`
- New LaunchAgent `ollama-pressure-guard` (StartInterval=60, KeepAlive=false, RunAtLoad=true)
- Configurable thresholds via env: `OLLAMA_UNLOAD_ON_PRESSURE=warn|critical|off` (default: `warn`)

**Technical Notes**:
- Check pressure: `memory_pressure -l warn` returns the state as first line
  - Alternative: parse `vm_stat` compressor % or use `sysctl kern.memorystatus_level`
  - Simplest: `memory_pressure | head -1 | awk '{print $NF}'` → `Normal`/`Warning`/`Critical`
- Unload API (Ollama):
  ```bash
  curl -s http://localhost:11434/api/generate \
    -d "{\"model\": \"$model\", \"keep_alive\": 0}" >/dev/null
  ```
- Active-request detection: check `ollama ps` output has no entry with `Until` in the future AND no recent `POST /api/generate` in server log within last 10s
- Log format: `<iso-ts> pressure=<state> unloaded=<model1,model2> skipped_active=<modelN>`

**Definition of Done**:
- [ ] Script handles all 3 pressure states correctly
- [ ] Only unloads when no active request
- [ ] LaunchAgent loaded, `StartInterval=60`
- [ ] Stress test: run `stress-ng --vm 4 --vm-bytes 8G` while gemma4:26b loaded → model unloads within 2 minutes
- [ ] Does not unload during active `ollama run`

**Dependencies**:
- Story 08.2-001 (base Ollama agent config)

**Risk Level**: Medium
**Risk Mitigation**: Active-request guard prevents mid-response aborts; opt-out env var

---

##### Story 08.2-003: Ollama Warm/Evict Aliases
**User Story**: As FX, I want `ollama-warm <model>` and `ollama-evict [model]` aliases so that I can explicitly control model residency

**Priority**: Should Have
**Story Points**: 3
**Sprint**: Sprint 12

**Acceptance Criteria**:
- **Given** `ollama-warm gemma4:26b` runs
- **When** the command completes
- **Then** the model is loaded with `keep_alive=-1` (permanent until evicted)
- **And** `ollama ps` shows it
- **And** `ollama-evict gemma4:26b` immediately unloads it
- **And** `ollama-evict` (no arg) unloads all loaded models

**Additional Requirements**:
- Define in `home-manager/modules/shell.nix` as zsh functions (not plain aliases — need args)
- Error handling: refuse if Ollama daemon not running (exit 1 with message)

**Technical Notes**:
- `ollama-warm`:
  ```bash
  ollama-warm() {
    local model="${1:?usage: ollama-warm <model>}"
    curl -sf http://localhost:11434/api/generate \
      -d "{\"model\":\"$model\",\"prompt\":\"\",\"keep_alive\":-1}" \
      >/dev/null && echo "✓ Warmed: $model"
  }
  ```
- `ollama-evict`:
  ```bash
  ollama-evict() {
    local target="${1:-}"
    if [[ -z "$target" ]]; then
      ollama ps | awk 'NR>1 {print $1}' | while read m; do
        curl -sf http://localhost:11434/api/generate \
          -d "{\"model\":\"$m\",\"keep_alive\":0}" >/dev/null
        echo "✓ Evicted: $m"
      done
    else
      curl -sf http://localhost:11434/api/generate \
        -d "{\"model\":\"$target\",\"keep_alive\":0}" >/dev/null \
        && echo "✓ Evicted: $target"
    fi
  }
  ```

**Definition of Done**:
- [ ] Both functions defined in `shell.nix`
- [ ] Error on daemon down
- [ ] Documented in `docs/post-install.md` under "Managing Ollama"

**Dependencies**:
- Existing shell.nix function pattern

**Risk Level**: Low

---

##### Story 08.2-004: LaunchAgent Steady-State Audit
**User Story**: As FX, I want a one-time audit of all LaunchAgents' steady-state RSS so that I understand which long-running processes cost memory

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 12

**Acceptance Criteria**:
- **Given** the audit script runs during normal system use
- **When** it samples 10 times over 5 minutes
- **Then** it reports median RSS for each LaunchAgent-owned process
- **And** flags any agent with median RSS >100 MB
- **And** output is written to `docs/architecture.md` "LaunchAgent Memory Profile" subsection (manually via PR, not automated)

**Additional Requirements**:
- New script `scripts/audit-launchagents.sh` (one-off utility, not scheduled)
- List of agents to audit: nix-gc, nix-optimize, weekly-digest, disk-cleanup, release-monitor, ollama-serve, health-api, beszel-agent, claude-cleanup (+ Power: rsync-*, icloud-sync; + new: ollama-pressure-guard)
- Match process via `launchctl procinfo <pid>` or `ps -eo pid,rss,command | grep <label>`

**Technical Notes**:
- Agent → PID lookup:
  ```bash
  launchctl print gui/$UID/org.nixos.health-api | awk '/pid = / {print $NF}'
  ```
- Sample: `ps -o rss= -p <pid>` (kb); convert to MB
- Median over 10 samples avoids spike noise
- Output format (markdown table for docs):
  ```
  | Agent | Median RSS (MB) | Notes |
  ```

**Definition of Done**:
- [ ] Script runs to completion
- [ ] 10 samples, median computed
- [ ] Markdown table output
- [ ] `docs/architecture.md` updated with current profile
- [ ] Any >100 MB agent has a note explaining why

**Dependencies**:
- Existing LaunchAgent inventory

**Risk Level**: Low

---

##### Story 08.2-005: Swap-Usage Alerting
**User Story**: As FX, I want `/metrics` and the weekly digest to flag sustained swap use so that I notice when I'm memory-bound before it hurts

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 12

**Acceptance Criteria**:
- **Given** `/metrics` is queried
- **When** `memory.swap_used_gb > 2`
- **Then** the response includes a `status_flags.memory_swap: "warn"` field
- **And** the weekly digest's memory section flags any day with sustained >2 GB swap for >30 minutes
- **And** `health-check.sh` echoes a warning when querying `/metrics` sees swap>2 GB

**Additional Requirements**:
- Extend `health-api.py` `get_system_metrics()` with computed `status_flags`
- Weekly digest samples `/metrics` hourly (via cron or small LaunchAgent sampler) and persists to `~/.local/share/nix-install/swap-history.json` — or simpler: read `/metrics` at digest time and include current value
- Threshold: `SWAP_WARNING_GB=2` constant, shared with `health-check.sh`

**Technical Notes**:
- `status_flags` approach avoids breaking the existing nested shape:
  ```python
  response["status_flags"] = {}
  if response["memory"]["swap_used_gb"] > 2:
      response["status_flags"]["memory_swap"] = "warn"
  ```
- For digest: start with point-in-time reading ("swap now: 3.1 GB ⚠"). Sustained-over-30-min is a future enhancement.

**Definition of Done**:
- [ ] `/metrics` has `status_flags` field
- [ ] `health-check.sh` reads it and warns
- [ ] Weekly digest shows current swap
- [ ] Threshold constant shared

**Dependencies**:
- Story 08.1-008 (growth telemetry pattern for digest)

**Risk Level**: Low

---
