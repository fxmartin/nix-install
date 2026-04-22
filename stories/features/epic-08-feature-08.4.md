# ABOUTME: Epic-08 Feature 08.4 (Observability Polish) implementation details
# ABOUTME: Top-N processes endpoint for SketchyBar popups; Beszel custom sensors for power/temp

# Epic-08 Feature 08.4: Observability Polish

## Feature Overview

**Feature ID**: Feature 08.4
**Feature Name**: Observability Polish
**Epic**: Epic-08
**Status**: ✅ Complete (shipped 2026-04-21)

### Delivery Summary
| Story | Title | PR | Notes |
|-------|-------|----|-------|
| 08.4-001 | Top-N CPU Processes in `/metrics` | #275 | `processes.top_cpu[]` (5 entries), self-process filtered |
| 08.4-002 | Beszel Custom Sensors (Power + Temp) | #283 | `scripts/beszel-sensors/{power,temp,temp_gpu}.sh` shipped via activation |

### Feature 08.4: Observability Polish
**Feature Description**: Extend `/metrics` with top-5 CPU processes (avoids forking `ps` inside SketchyBar click handlers) and wire the existing Beszel agent to ship power-draw + silicon-temperature time series for long-horizon analysis.
**User Value**: Rich click-through process view without the latency of spawning `ps`; historical power/thermal trending in Beszel hub (Nyx)
**Story Count**: 2
**Story Points**: 10
**Priority**: Nice to Have (P2)
**Complexity**: Low

#### Stories in This Feature

---

##### Story 08.4-001: Top-N CPU Processes in /metrics
**User Story**: As FX, I want `/metrics` to include top-5 CPU processes so that the SketchyBar vitals popup doesn't need its own `ps` call

**Priority**: Nice to Have
**Story Points**: 5
**Sprint**: Sprint 14

**Acceptance Criteria**:
- **Given** `/metrics` is queried
- **When** the response is returned
- **Then** it includes a `processes` object with `top_cpu: [{pid, cpu_percent, name}]` (length 5)
- **And** the additional work does not push `/metrics` latency above the existing budget (<2s p95)
- **And** the process list is cached alongside the rest of the metrics response (2s TTL)

**Additional Requirements**:
- Use `ps -Ao pid=,pcpu=,comm= | sort -k2 -nr | head -5` (macOS BSD ps)
- Truncate process names to 40 chars
- Skip the health-api process itself (avoid self-referential noise)

**Technical Notes**:
- Extend `health-api.py::get_system_metrics()`:
  ```python
  def _top_cpu_processes(n: int = 5) -> list[dict]:
      out = run(f"ps -Ao pid=,pcpu=,comm= | sort -k2 -nr | head -{n+1}")
      results = []
      for line in out.splitlines():
          parts = line.split(None, 2)
          if len(parts) < 3:
              continue
          pid, pct, name = parts
          if name.endswith("health-api.py"):
              continue
          results.append({"pid": int(pid), "cpu_percent": float(pct), "name": name[:40]})
          if len(results) >= n:
              break
      return results
  ```
- Add to response dict:
  ```python
  response["processes"] = {"top_cpu": _top_cpu_processes(5)}
  ```

**Definition of Done**:
- [ ] `/metrics` returns `processes.top_cpu[]` with 5 entries
- [ ] Self-process filtered out
- [ ] p95 latency unchanged (measured with 20 samples)
- [ ] SketchyBar popup (Story 08.3-005) consumes it instead of local `ps` fallback

**Dependencies**:
- Existing `health-api.py`

**Risk Level**: Low

---

##### Story 08.4-002: Beszel Custom Sensors (Power + Temp)
**User Story**: As FX, I want the Beszel agent to ship power-draw and silicon-temperature time series so that I can trend them on the Beszel hub

**Priority**: Nice to Have
**Story Points**: 5
**Sprint**: Sprint 14

**Acceptance Criteria**:
- **Given** Beszel agent is running with custom sensor config
- **When** the hub polls the agent
- **Then** Beszel receives `power_total_watts`, `temp_cpu_c`, `temp_gpu_c` custom metrics every 60s
- **And** the Beszel hub dashboard can chart them over 7/30 days
- **And** custom sensor script has zero runtime dependencies beyond curl + jq (already in PATH)

**Additional Requirements**:
- Beszel supports extra sensors via `SYS_SENSORS` + custom scripts
- New sensor scripts in `~/.local/bin/beszel-sensors/` (e.g., `power.sh`, `temp.sh`)
- Each script: reads `/metrics`, prints single float, exits 0
- Wired via `beszel-agent.env` additions: `EXTRA_FS=...` / `SENSORS=power,temp_cpu,temp_gpu`

**Technical Notes**:
- Check Beszel agent docs for exact custom-sensor interface (varies by version)
- Likely shape (pseudo):
  ```bash
  # power.sh
  curl -s http://localhost:7780/metrics | jq -r '.power.total_watts'
  ```
- Update `darwin/monitoring.nix` to deploy sensor scripts + update env file template
- Minimal risk: Beszel will keep working without custom sensors if wiring is off; this is additive

**Definition of Done**:
- [ ] Sensor scripts deployed via activation
- [ ] Beszel env file references them
- [ ] Metrics visible on Nyx Beszel hub dashboard
- [ ] 24h of history captured

**Dependencies**:
- Existing `darwin/monitoring.nix` (Beszel agent)

**Risk Level**: Low — additive only

---
