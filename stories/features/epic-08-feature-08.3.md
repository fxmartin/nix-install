# ABOUTME: Epic-08 Feature 08.3 (SketchyBar Deep Telemetry) implementation details
# ABOUTME: Consolidate plugins into /metrics consumer; add per-cluster CPU, ANE, power, temps, rich popup

# Epic-08 Feature 08.3: SketchyBar Deep Telemetry

## Feature Overview

**Feature ID**: Feature 08.3
**Feature Name**: SketchyBar Deep Telemetry
**Epic**: Epic-08
**Status**: 📋 Planned

### Feature 08.3: SketchyBar Deep Telemetry
**Feature Description**: Replace the per-plugin `top`/`ioreg`/`swift`/`vm_stat` spawns with a single `system.sh` aggregator that polls `http://localhost:7780/metrics` once per tick, then fans data out to bar items via SketchyBar trigger events. Surface the same data mactop shows — per-cluster E/P CPU %, GPU %/MHz, ANE utilization, CPU+GPU temperatures in °C, total power draw in watts — so FX can retire the mactop terminal habit.
**User Value**: Always-visible silicon vitals; faster bar updates; lower bar overhead; richer click-through detail
**Story Count**: 8
**Story Points**: 38
**Priority**: Should Have (P1)
**Complexity**: Medium

#### Stories in This Feature

---

##### Story 08.3-001: system.sh Aggregator Plugin
**User Story**: As FX, I want one SketchyBar plugin that fetches `/metrics` per tick and broadcasts a custom event so that individual bar items don't each spawn their own silicon probe

**Priority**: Should Have
**Story Points**: 8
**Sprint**: Sprint 13

**Acceptance Criteria**:
- **Given** `config/sketchybar/plugins/system.sh` runs every 2s
- **When** it executes
- **Then** it fetches `curl -s --max-time 1 http://localhost:7780/metrics`
- **And** parses the JSON with `jq` into SketchyBar-safe shell vars
- **And** triggers `sketchybar --trigger system_metrics_update cpu_e=... cpu_p=... gpu=... ane=... watts=... temp=...`
- **And** on failure (timeout, non-200, parse error) triggers `system_metrics_update stale=1`

**Additional Requirements**:
- Use `jq -r` with `//` default operators (safe against missing fields)
- No process-spawning beyond `curl` + `jq` + `sketchybar`
- Timeout budget: 1s curl, 200ms jq, fits easily in 2s tick

**Technical Notes**:
- New plugin `config/sketchybar/plugins/system.sh`:
  ```bash
  #!/bin/sh
  # ABOUTME: Single /metrics poller that fans out to all system bar items
  JSON=$(curl -s --max-time 1 http://localhost:7780/metrics 2>/dev/null)
  if [ -z "$JSON" ]; then
    sketchybar --trigger system_metrics_update stale=1
    exit 0
  fi
  eval "$(echo "$JSON" | jq -r '
    "cpu_e=" + (.cpu.e_cluster.active_percent|tostring),
    "cpu_p=" + (.cpu.p_cluster.active_percent|tostring),
    "gpu="   + (.gpu.usage_percent|tostring),
    "gpu_mhz=" + (.gpu.freq_mhz|tostring),
    "ane_w=" + (.power.ane_watts|tostring),
    "watts=" + (.power.total_watts|tostring),
    "temp_cpu=" + (.thermal.cpu_temp_c|tostring),
    "temp_gpu=" + (.thermal.gpu_temp_c|tostring),
    "mem_used=" + (.memory.used_gb|tostring),
    "mem_total=" + (.memory.total_gb|tostring),
    "swap_used=" + (.memory.swap_used_gb|tostring)
    ' | sed 's/^/export /')"
  sketchybar --trigger system_metrics_update \
    CPU_E="$cpu_e" CPU_P="$cpu_p" GPU="$gpu" GPU_MHZ="$gpu_mhz" \
    ANE_W="$ane_w" WATTS="$watts" \
    TEMP_CPU="$temp_cpu" TEMP_GPU="$temp_gpu" \
    MEM_USED="$mem_used" MEM_TOTAL="$mem_total" SWAP_USED="$swap_used" \
    STALE=0
  ```
- Register event: `sketchybar --add event system_metrics_update`
- Add to `sketchybarrc` with `update_freq=2` (adaptive in 08.3-007)

**Definition of Done**:
- [ ] `system.sh` created, executable
- [ ] Event `system_metrics_update` registered in `sketchybarrc`
- [ ] Sample payload verified with `sketchybar --subscribe debug system_metrics_update`
- [ ] Failure path triggers stale=1

**Dependencies**:
- Existing `health-api` on port 7780

**Risk Level**: Low

---

##### Story 08.3-002: Per-Cluster CPU Items (E / P)
**User Story**: As FX, I want the bar to show E-cluster and P-cluster CPU utilization separately so that I can tell efficiency work from performance work at a glance

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 13

**Acceptance Criteria**:
- **Given** the bar has `cpu.e` and `cpu.p` items replacing the single `cpu` item
- **When** `system_metrics_update` fires
- **Then** `cpu.e` shows "E: 12%" (blue-ish color)
- **And** `cpu.p` shows "P: 78%" (Catppuccin green/yellow/red based on value)
- **And** color thresholds: <30% green, <70% yellow, >=70% red (P-cluster matters more)
- **And** in stale state, both items dim to grey

**Additional Requirements**:
- Both items share a single script `cpu_cluster.sh` that reads `CPU_E`/`CPU_P`/`STALE` from event env
- Icons:
  - `cpu.e` icon = `` (nf-mdi-leaf or similar for efficiency)
  - `cpu.p` icon = `` (existing CPU glyph for performance)
- Preserve bar width: both items share small padding

**Technical Notes**:
- New plugin `config/sketchybar/plugins/cpu_cluster.sh`:
  ```bash
  #!/bin/sh
  # $NAME passed in by sketchybar; $CPU_E, $CPU_P, $STALE via event
  if [ "$STALE" = "1" ]; then
    sketchybar --set "$NAME" label.color=0xff585b70
    exit 0
  fi
  case "$NAME" in
    cpu.e) VAL="$CPU_E"; PREFIX="E" ;;
    cpu.p) VAL="$CPU_P"; PREFIX="P" ;;
  esac
  VAL_INT=${VAL%.*}  # strip decimal
  if [ "$VAL_INT" -ge 70 ]; then COLOR=0xfff38ba8
  elif [ "$VAL_INT" -ge 30 ]; then COLOR=0xfff9e2af
  else COLOR=0xffa6e3a1; fi
  sketchybar --set "$NAME" label="${PREFIX}:${VAL_INT}%" label.color=$COLOR
  ```
- `sketchybarrc`: remove existing `cpu` item; add:
  ```
  --add item cpu.p right \
  --set cpu.p icon= icon.font="Hack Nerd Font:Bold:15.0" \
            script="$PLUGIN_DIR/cpu_cluster.sh" \
  --subscribe cpu.p system_metrics_update \
  --add item cpu.e right \
  --set cpu.e icon= icon.font="Hack Nerd Font:Bold:15.0" \
            script="$PLUGIN_DIR/cpu_cluster.sh" \
  --subscribe cpu.e system_metrics_update
  ```

**Definition of Done**:
- [ ] Old `cpu` item removed
- [ ] `cpu.e` and `cpu.p` items show correct %
- [ ] Colors match thresholds
- [ ] Stale state dims both

**Dependencies**:
- Story 08.3-001 (system.sh aggregator)

**Risk Level**: Low

---

##### Story 08.3-003: GPU + ANE Items
**User Story**: As FX, I want GPU % with MHz and a distinct ANE indicator so that I can see when Ollama is using the Neural Engine vs the GPU

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 13

**Acceptance Criteria**:
- **Given** `system_metrics_update` event
- **When** `ANE_W > 0.5` (watts)
- **Then** a new `ane` bar item lights up (icon color = accent)
- **And** when `ANE_W <= 0.5`, the `ane` item is dimmed
- **And** `gpu` item shows e.g. "45% 920MHz"
- **And** GPU color thresholds same as existing (<60 green, <85 yellow, else red)

**Additional Requirements**:
- New plugin `config/sketchybar/plugins/ane.sh`
- Update existing `gpu.sh` to read from event env (`GPU`, `GPU_MHZ`) instead of running `ioreg`
- Keep same glyph for GPU (`󰏔`); ANE uses `` (nf-mdi-brain) or similar available in Hack Nerd Font

**Technical Notes**:
- ANE threshold 0.5W picked empirically — idle draw is ~0.1W, any active inference pushes past 1W
- `ane.sh`:
  ```bash
  #!/bin/sh
  if [ "$STALE" = "1" ] || [ -z "$ANE_W" ]; then
    sketchybar --set "$NAME" icon.color=0xff585b70 label.drawing=off
    exit 0
  fi
  # bash float compare via awk
  ACTIVE=$(awk "BEGIN{print ($ANE_W > 0.5)}")
  if [ "$ACTIVE" = "1" ]; then
    sketchybar --set "$NAME" icon.color=0xfff5c2e7 \
      label="${ANE_W}W" label.drawing=on label.color=0xfff5c2e7
  else
    sketchybar --set "$NAME" icon.color=0xff585b70 label.drawing=off
  fi
  ```
- `gpu.sh` becomes event-driven:
  ```bash
  #!/bin/sh
  [ "$STALE" = "1" ] && { sketchybar --set "$NAME" label.color=0xff585b70; exit 0; }
  GPU_INT=${GPU%.*}
  # color logic same as before
  sketchybar --set "$NAME" label="${GPU_INT}% ${GPU_MHZ}MHz" ...
  ```

**Definition of Done**:
- [ ] New `ane` bar item, subscribed to `system_metrics_update`
- [ ] `gpu.sh` rewritten to use event env
- [ ] Verified: running `ollama run gemma4:e4b "hi"` lights ANE briefly
- [ ] Old GPU `ioreg` call removed

**Dependencies**:
- Story 08.3-001

**Risk Level**: Low

---

##### Story 08.3-004: Power (Watts) + Temp Items
**User Story**: As FX, I want total watts drawn and the hottest silicon temperature in the bar so that I have quantitative thermal/power info instead of just OK/WARM/HOT

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 13

**Acceptance Criteria**:
- **Given** `system_metrics_update` fires
- **When** the bar updates
- **Then** a new `power` item shows "23W" (color: <15W green, <30W yellow, >=45W red)
- **And** a new `temp` item shows "72°C" using `max(TEMP_CPU, TEMP_GPU)` (color: <70 green, <85 yellow, else red)
- **And** existing qualitative `thermal` item is removed
- **And** icons: power = `` (nf-mdi-flash), temp = `` (existing)

**Additional Requirements**:
- Retire the current `thermal.sh` (ProcessInfo state label) — replaced by quantitative temp
- Power item position: between GPU and battery (visually groups with CPU cluster items)

**Technical Notes**:
- New `power.sh`:
  ```bash
  #!/bin/sh
  [ "$STALE" = "1" ] && { sketchybar --set "$NAME" label.color=0xff585b70; exit 0; }
  W_INT=${WATTS%.*}
  if [ "$W_INT" -ge 45 ]; then COLOR=0xfff38ba8
  elif [ "$W_INT" -ge 30 ]; then COLOR=0xfff9e2af
  elif [ "$W_INT" -ge 15 ]; then COLOR=0xffa6e3a1
  else COLOR=0xff94e2d5; fi  # idle = teal
  sketchybar --set "$NAME" label="${W_INT}W" label.color=$COLOR
  ```
- New `temp.sh`:
  ```bash
  #!/bin/sh
  [ "$STALE" = "1" ] && { sketchybar --set "$NAME" label.color=0xff585b70; exit 0; }
  TCPU=${TEMP_CPU%.*}
  TGPU=${TEMP_GPU%.*}
  [ "$TCPU" -gt "$TGPU" ] && HOT=$TCPU || HOT=$TGPU
  if [ "$HOT" -ge 85 ]; then COLOR=0xfff38ba8
  elif [ "$HOT" -ge 70 ]; then COLOR=0xfff9e2af
  else COLOR=0xffa6e3a1; fi
  sketchybar --set "$NAME" label="${HOT}°C" label.color=$COLOR
  ```

**Definition of Done**:
- [ ] `power` item added to bar
- [ ] `temp` item added
- [ ] Old `thermal` item removed from `sketchybarrc`
- [ ] `thermal.sh` deleted (or left as dead code until final cleanup story)
- [ ] Validated on sustained workload: watts climb >40, temp >75°C

**Dependencies**:
- Story 08.3-001

**Risk Level**: Low

---

##### Story 08.3-005: System Vitals Popup (mactop replacement)
**User Story**: As FX, I want a left-click popup on `cpu.p` showing top-5 CPU processes, full per-cluster breakdown, memory compressor/swap, and power split so that I never need to open mactop

**Priority**: Should Have
**Story Points**: 8
**Sprint**: Sprint 13

**Acceptance Criteria**:
- **Given** I left-click the `cpu.p` item
- **When** the popup opens
- **Then** it shows:
  - Per-cluster: E-cluster %, P-cluster %, GPU %, ANE W
  - Frequencies: E MHz, P MHz, GPU MHz
  - Memory: used/total GB, compressed GB, swap used GB
  - Power split: CPU W, GPU W, ANE W, DRAM W, total W
  - Temps: CPU °C, GPU °C
  - Top-5 CPU processes (pid, %, command) — requires Story 08.4-001 OR falls back to `ps -eo pid,pcpu,comm | sort -k2 -nr | head -5` locally
- **And** popup auto-refreshes on next `system_metrics_update`
- **And** second click dismisses

**Additional Requirements**:
- Popup item naming: `vitals.e_cluster`, `vitals.p_cluster`, `vitals.gpu`, `vitals.power.cpu`, etc.
- Dynamic items added/updated via `sketchybar --add ... popup.cpu.p` pattern
- Background styling matches existing docker/tailscale popups (Catppuccin mocha surface, 12px corner radius)

**Technical Notes**:
- Click handler in `cpu_cluster.sh`:
  ```bash
  if [ "$BUTTON" = "left" ] && [ "$NAME" = "cpu.p" ]; then
    # Populate popup items from event env + ps
    sketchybar --remove '/vitals\..*/' 2>/dev/null
    # Add summary items
    sketchybar --add item vitals.cluster popup.cpu.p \
      --set vitals.cluster label="E:${CPU_E}%  P:${CPU_P}%  GPU:${GPU}%  ANE:${ANE_W}W"
    # ... more items
    sketchybar --set cpu.p popup.drawing=toggle
    exit 0
  fi
  ```
- If Story 08.4-001 not done, fall back to:
  ```bash
  ps -Ao pid,pcpu,comm | sort -k2 -nr | head -6 | tail -5 | while read pid pcpu comm; do ...
  ```

**Definition of Done**:
- [ ] Popup renders all requested sections
- [ ] Top-5 CPU processes shown
- [ ] Auto-refreshes with event
- [ ] Dismiss works
- [ ] Catppuccin styling matches existing popups

**Dependencies**:
- Stories 08.3-001 through 08.3-004
- Story 08.4-001 (optional — fallback path provided)

**Risk Level**: Low

---

##### Story 08.3-006: Memory Breakdown Popup
**User Story**: As FX, I want the memory bar item to have a click popup showing wired/active/compressed/swap breakdown so that I understand pressure state

**Priority**: Should Have
**Story Points**: 3
**Sprint**: Sprint 13

**Acceptance Criteria**:
- **Given** I left-click the memory bar item
- **When** the popup opens
- **Then** it shows used/total, compressor GB, swap GB, and a color-coded pressure state (Normal/Warning/Critical)
- **And** bar icon color reflects swap usage: teal when swap<1 GB, yellow 1–3 GB, red >3 GB
- **And** existing `memory.sh` is rewritten to be event-driven

**Additional Requirements**:
- Use `memory_pressure` state (same as 08.2-002) for popup status
- Compressor pages: not exposed by `/metrics` today (macmon doesn't emit it); fall back to `vm_stat` locally inside the click handler only (one-shot, no periodic spawn)

**Technical Notes**:
- `memory.sh` becomes event-driven:
  ```bash
  [ "$STALE" = "1" ] && exit 0
  PCT=$(awk "BEGIN{printf \"%.0f\", ($MEM_USED/$MEM_TOTAL)*100}")
  # color on PCT like today, but factor swap into icon tint
  ```
- Popup click handler computes compressor once via `vm_stat`

**Definition of Done**:
- [ ] `memory.sh` event-driven
- [ ] Popup shows detailed breakdown
- [ ] Swap influences icon color
- [ ] Tested: run gemma4:26b → popup shows rising compressor

**Dependencies**:
- Story 08.3-001

**Risk Level**: Low

---

##### Story 08.3-007: Adaptive Update Frequency on Battery
**User Story**: As FX, I want `system.sh` to poll every 10s on battery and every 2s on AC so that the bar doesn't drain the laptop when unplugged

**Priority**: Should Have
**Story Points**: 3
**Sprint**: Sprint 13

**Acceptance Criteria**:
- **Given** the bar is running
- **When** power source changes from AC to battery
- **Then** `system.sh` detects it (via `pmset -g ps`) and reconfigures its own `update_freq` to 10s
- **And** on reconnect to AC, it returns to 2s
- **And** the switch happens within one tick of the change

**Additional Requirements**:
- Add listener on existing `power_source_change` event (battery plugin already subscribes to it — reuse)
- Store desired freq in a state file `/tmp/sketchybar_sys_freq` so reload preserves it

**Technical Notes**:
- In `system.sh` on entry:
  ```bash
  if [ "$SENDER" = "power_source_change" ]; then
    if pmset -g ps | head -1 | grep -q "Battery Power"; then
      sketchybar --set system update_freq=10
    else
      sketchybar --set system update_freq=2
    fi
    exit 0
  fi
  ```
- Subscribe the `system` item to `power_source_change`

**Definition of Done**:
- [ ] Freq switches on power source change
- [ ] Verified by unplugging + watching `sketchybar --query system`
- [ ] Battery drain measured (before/after optional — minimum: poll freq changes correctly)

**Dependencies**:
- Story 08.3-001

**Risk Level**: Low

---

##### Story 08.3-008: Retire mactop Habit (Acceptance-Only Story)
**User Story**: As FX, I want to confirm that all signal I previously got from mactop is available in the bar so that I can uninstall or deprioritize mactop

**Priority**: Should Have
**Story Points**: 1
**Sprint**: Sprint 13

**Acceptance Criteria**:
- **Given** Features 08.3-001 through 08.3-007 are complete
- **When** FX runs normal work for one full day without opening mactop
- **Then** all formerly-mactop data points are available from the bar (either directly or via popups)
- **And** a follow-up note is added to `docs/post-install.md` documenting the new bar layout
- **And** optional: mactop moved from `brews` to an opt-in list (kept installable but not default)

**Additional Requirements**:
- This is a validation story, not implementation
- Output: short retrospective note in STORIES.md Epic-08 section

**Technical Notes**:
- No code changes strictly required
- If validation fails, file follow-up stories for gaps

**Definition of Done**:
- [ ] Full-day validation done
- [ ] Gaps (if any) filed as follow-ups
- [ ] `docs/post-install.md` updated with bar reference
- [ ] Optional: mactop removed from default `brews`

**Dependencies**:
- All Feature 08.3 stories

**Risk Level**: Low

---
