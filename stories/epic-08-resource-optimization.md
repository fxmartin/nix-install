# Epic 08: Resource Optimization & Deep Telemetry

## Epic Overview
**Epic ID**: Epic-08
**Epic Description**: Close long-running disk and memory leaks introduced by heavy AI workloads (Ollama, Huggingface), third-party browser caches, and unbounded Nix system generations. Elevate SketchyBar from qualitative status indicators (OK/WARM/HOT, single-percent CPU/GPU) into a mactop-grade telemetry surface driven by the existing `health-api` `/metrics` endpoint, removing the need to launch `mactop` in a terminal to inspect per-cluster CPU, ANE utilization, power draw, and silicon temperatures.
**Business Value**: Reclaim 12–18 GB of disk on Power profile today, bound long-term disk growth with auto-remediation, eliminate the 3 GB swap + 11 GB compressor pressure caused by default Ollama keep-alive behavior, and consolidate system vitals into the always-visible status bar.
**User Impact**: FX stops needing a second terminal window for live performance monitoring, recovers 10+ GB of "invisible" disk (system generations, Huggingface, stale Ollama models), and runs large models (gemma4:26b) without the machine swapping 3 GB of active memory.
**Success Metrics**:
- System generation count drops from 175 → <20 after first cycle
- `~/.cache/huggingface`, browser caches, and stale Ollama models are pruned by scheduled maintenance
- `OLLAMA_MAX_LOADED_MODELS=1` + tuned `OLLAMA_KEEP_ALIVE` eliminates double-loaded model RAM spikes
- Memory-pressure probe auto-unloads Ollama models on `warn`/`critical` pressure states
- SketchyBar shows per-cluster CPU %, GPU %/MHz, ANE indicator, total watts, hottest silicon °C
- One `/metrics` fetch per tick replaces N per-plugin `top`/`ioreg`/`swift` spawns
- FX can retire `mactop` for day-to-day monitoring

## Epic Scope
**Total Stories**: 23
**Total Story Points**: 118
**MVP Stories**: 13 (57% — Features 08.1 and 08.2)
**Priority Level**: Should Have (post-v1.0 enhancement)
**Target Release**: v1.1.0

## Features in This Epic

> **Note**: Detailed story implementations live in `stories/features/` following the Epic-06 pattern.

### Feature 08.1: Disk Consumption Optimization
**Feature Description**: System-level Nix GC, Huggingface/browser/cache pruning gaps, Ollama LRU pruning, pre-rebuild disk guard, week-over-week growth telemetry
**Story Count**: 8 | **Story Points**: 44 | **Priority**: Must Have (P0) | **Complexity**: Medium
👉 **[View detailed implementation](features/epic-08-feature-08.1.md)**

### Feature 08.2: Memory Pressure Mitigation
**Feature Description**: Tune Ollama LaunchAgent environment (`OLLAMA_MAX_LOADED_MODELS`, `OLLAMA_KEEP_ALIVE`, `OLLAMA_NUM_PARALLEL`), memory-pressure-triggered model unload, LaunchAgent steady-state audit, swap alerting
**Story Count**: 5 | **Story Points**: 26 | **Priority**: Must Have (P0) | **Complexity**: Medium
👉 **[View detailed implementation](features/epic-08-feature-08.2.md)**

### Feature 08.3: SketchyBar Deep Telemetry
**Feature Description**: Consolidate CPU/GPU/memory/thermal plugins into a `system.sh` aggregator polling `/metrics` once per tick; add per-cluster E/P CPU, ANE indicator, total watts, temperatures; rich click popup replacing mactop glance; adaptive update frequency on battery
**Story Count**: 8 | **Story Points**: 38 | **Priority**: Should Have (P1) | **Complexity**: Medium
👉 **[View detailed implementation](features/epic-08-feature-08.3.md)**

### Feature 08.4: Observability Polish
**Feature Description**: Extend `/metrics` with top-5 CPU processes for SketchyBar popups; expose power/temps as custom Beszel sensors
**Story Count**: 2 | **Story Points**: 10 | **Priority**: Nice to Have (P2) | **Complexity**: Low
👉 **[View detailed implementation](features/epic-08-feature-08.4.md)**

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-06 (Maintenance & Monitoring)**: Builds directly on `nix-gc` / `nix-optimize` / `disk-cleanup` LaunchAgents, `scripts/health-api.py`, and `scripts/disk-cleanup.sh`
- **Epic-02 (Applications)**: Requires Ollama, `macmon`, `jq` present in PATH
- **Epic-05 (Theming)**: SketchyBar plugin color palette must stay Catppuccin-aligned

### Stories This Epic Enables
- Future power-efficiency work (clock-gate triggers on battery based on `/metrics`)
- Future Beszel dashboards for long-horizon AI workload analysis

### Stories This Epic Blocks
- None — pure enhancement layer on top of v1.0.0

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 11 | 08.1-001 to 08.1-008 | 44 | Close disk leaks, add pre-rebuild guard and growth telemetry |
| Sprint 12 | 08.2-001 to 08.2-005 | 26 | Tune Ollama, auto-unload on pressure, swap alerting |
| Sprint 13 | 08.3-001 to 08.3-008 | 38 | SketchyBar `/metrics` consolidation, per-cluster CPU, power/temp surfaces |
| Sprint 14 | 08.4-001 to 08.4-002 | 10 | Top-N processes endpoint, Beszel custom sensors |

### Delivery Milestones
- **Milestone 1** (end Sprint 11): Disk free grows by 12+ GB after first cycle; system generations <20
- **Milestone 2** (end Sprint 12): No swap use during idle Ollama sessions; memory-pressure auto-unload validated under stress
- **Milestone 3** (end Sprint 13): FX retires `mactop` for a full workday; no plugin spawns its own silicon probe
- **Epic Complete** (end Sprint 14): All metrics flowing into Beszel long-term store

### Risk Assessment
**Low Risk Items**:
- 08.1 and 08.2 extend existing, proven patterns in `darwin/maintenance.nix`
- SketchyBar refactor is strictly additive until the last story retires old plugins

**Medium Risk Items**:
- **08.1-001 (system-level GC)**: Requires a root-level LaunchDaemon, first one in this repo. Mitigation: gated by `--dry-run` first, validate with single machine before rolling out.
- **08.2-002 (auto-unload on pressure)**: Unloading a model mid-request would abort the request. Mitigation: only unload when no active request in the last 10s (check `ollama ps`).
- **08.3-001 (health-api dependency)**: If `health-api` is down, the bar goes blind. Mitigation: fall back to existing per-plugin probes with a clear "metrics stale" visual state.

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 0 of 23 (0%)
- **Story Points Completed**: 0 of 118 (0%)
- **MVP Stories Completed**: 0 of 13 (0%)
- **P1 Stories Completed**: 0 of 8 (0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 11 | 44 | 0 | 0/8 | Planned |
| Sprint 12 | 26 | 0 | 0/5 | Planned |
| Sprint 13 | 38 | 0 | 0/8 | Planned |
| Sprint 14 | 10 | 0 | 0/2 | Planned |

## Epic Acceptance Criteria

### P0 — Feature 08.1 (Disk Optimization)
- [ ] Weekly system-level GC LaunchDaemon prunes system generations (count <20 after first cycle on Power)
- [ ] `disk-cleanup.sh` covers `~/.cache/huggingface`, Arc/Brave/Chrome caches, `~/.claude/projects/*` >90 days
- [ ] `ollama-lru` script reports models not used in >N days; opt-in auto-remove behind confirmation flag
- [ ] `rebuild` / `update` aliases refuse to run when free disk <10 GB; offer `gc` prompt
- [ ] Weekly digest email includes week-over-week per-consumer size deltas (flag >1 GB/week growth)

### P0 — Feature 08.2 (Memory Optimization)
- [ ] Ollama LaunchAgent sets `OLLAMA_MAX_LOADED_MODELS=1`, `OLLAMA_KEEP_ALIVE=2m` (Standard), `OLLAMA_KEEP_ALIVE=5m` (Power for 26B), `OLLAMA_NUM_PARALLEL=1`
- [ ] Memory-pressure LaunchAgent polls `memory_pressure` every 60s; unloads models on `warn`/`critical` when no active request
- [ ] `ollama-evict` and `ollama-warm` aliases work
- [ ] LaunchAgent audit documented in `docs/architecture.md` (steady-state RSS per agent)
- [ ] `/metrics` surfaces `swap_used_gb > 2` as `status: warn`; weekly digest flags it

### P1 — Feature 08.3 (SketchyBar)
- [ ] Single `system.sh` plugin fetches `/metrics` once per 2s tick; fans out via `trigger` events to cpu/gpu/memory/thermal/power items
- [ ] Bar shows `cpu.e` + `cpu.p` (E/P cluster % with distinct colors)
- [ ] Bar shows `gpu` (% + MHz) and `ane` indicator (lights on ANE watts >0.5)
- [ ] Bar shows `power` (total watts, color-graded) and `temp` (hottest silicon °C)
- [ ] Left-click on `cpu` opens popup with per-cluster breakdown, top-5 CPU processes, memory compressor/swap, power split
- [ ] Adaptive update freq: 2s on AC, 10s on battery
- [ ] When `/metrics` fails, items show stale-state color instead of blank; recovers automatically

### P2 — Feature 08.4 (Observability)
- [ ] `/metrics` includes `processes.top_cpu[]` (pid, %, name) for popup consumption
- [ ] Beszel custom sensors track power watts and hottest silicon temp over time

## Story Validation Checklist

### Quality Assurance for Each Story
- [ ] Follows proper user story format ("As [persona], I want [functionality] so that [benefit]")
- [ ] Has clear, testable acceptance criteria (Given/When/Then format)
- [ ] Includes all necessary context and constraints
- [ ] Sized appropriately for single sprint
- [ ] Dependencies clearly identified
- [ ] Business value articulated
- [ ] Persona alignment verified (FX as primary user)
- [ ] Technical feasibility confirmed

### Epic Health Metrics
- **Story Readiness**: Target 100% of stories meet definition of ready before Sprint 11 starts
- **Dependency Coverage**: All dependencies on Epic-06 (`health-api.py`, `disk-cleanup.sh`, `maintenance.nix`) identified
- **Estimation Confidence**: Medium-high — patterns are proven by Epic-06; new work is system-level LaunchDaemon (08.1-001) and memory-pressure LaunchAgent (08.2-002)
- **Acceptance Criteria Quality**: Every P0 story has a verifiable numeric outcome (disk bytes, generation count, pressure state)
