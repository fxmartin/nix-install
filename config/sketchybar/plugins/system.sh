#!/bin/sh

# ABOUTME: SketchyBar /metrics aggregator — single poller that fans out to all system items
# ABOUTME: Adaptive: 2s tick on AC, 10s on battery (Story 08.3-007)

# Replaces N per-plugin top/ioreg/swift/vm_stat spawns with a single
# HTTP fetch per tick. On battery, slows to 10s ticks to save power —
# sampled at boot and on every power_source_change event the bar receives.

# ---------------------------------------------------------------------------
# Power-source adaptation (Story 08.3-007)
# When invoked by the power_source_change event, adjust the item's own
# update_freq and exit — don't do a /metrics probe on the same call.
# ---------------------------------------------------------------------------
if [ "$SENDER" = "power_source_change" ]; then
  if pmset -g ps 2>/dev/null | head -1 | grep -q "Battery Power"; then
    sketchybar --set system update_freq=10
  else
    sketchybar --set system update_freq=2
  fi
  exit 0
fi

# ---------------------------------------------------------------------------
# Periodic tick: fetch /metrics and fan out via system_metrics_update event.
# Runs every update_freq (2s on AC, 10s on battery per above).
#
# On success: trigger system_metrics_update with all parsed values as env.
# On failure (timeout, non-200, parse error): trigger with STALE=1 so
# consumer items can dim to grey rather than render stale numbers.
# ---------------------------------------------------------------------------

METRICS_URL="${SKETCHYBAR_METRICS_URL:-http://localhost:7780/metrics}"

# --max-time budget: macmon sampling takes 1-2s on a cold 2s-TTL cache, so a
# 1s budget guarantees a timeout every other tick. 3s gives the cold path
# room to breathe while the warm path (within 2s cache TTL) still returns
# in <100ms — bar perceived latency is unchanged for most ticks.
JSON=$(curl -s --max-time 3 "$METRICS_URL" 2>/dev/null)
if [ -z "$JSON" ]; then
  sketchybar --trigger system_metrics_update STALE=1
  exit 0
fi

PAYLOAD=$(echo "$JSON" | jq -r '
  [
    "CPU_E="  + ((.cpu.e_cluster.active_percent // 0) | tostring),
    "CPU_P="  + ((.cpu.p_cluster.active_percent // 0) | tostring),
    "GPU="    + ((.gpu.usage_percent // 0) | tostring),
    "GPU_MHZ=" + ((.gpu.freq_mhz // 0) | tostring),
    "ANE_W="  + ((.power.ane_watts // 0) | tostring),
    "WATTS="  + ((.power.total_watts // 0) | tostring),
    "TEMP_CPU=" + ((.thermal.cpu_temp_c // 0) | tostring),
    "TEMP_GPU=" + ((.thermal.gpu_temp_c // 0) | tostring),
    "MEM_USED=" + ((.memory.used_gb // 0) | tostring),
    "MEM_TOTAL=" + ((.memory.total_gb // 0) | tostring),
    "MEM_ACTIVE=" + ((.memory.active_gb // 0) | tostring),
    "MEM_INACTIVE=" + ((.memory.inactive_gb // 0) | tostring),
    "SWAP_USED=" + ((.memory.swap_used_gb // 0) | tostring),
    "CPU_USER=" + ((.cpu.user_percent // 0) | tostring),
    "CPU_SYS=" + ((.cpu.system_percent // 0) | tostring),
    "CPU_IDLE=" + ((.cpu.idle_percent // 0) | tostring),
    "CPU_CORE_PCTS=" + ([.cpu.cores[]? | (.active_percent // 0)] | map(tostring) | join(",")),
    "LOAD_AVG=" + (
      if (.system.load_average // []) | length >= 3
      then (.system.load_average[0:3] | map(tostring) | join("/"))
      else "0/0/0" end
    ),
    "MEM_PRESSURE=" + ((.memory.pressure_label // "unknown") | tostring),
    "TOP_CPU=" + (
      [.processes.top_cpu[0:3][]? |
        (((.cpu_percent // 0) | round | tostring) + "%:" + ((.name // "") | split("/") | last | gsub("[^A-Za-z0-9._-]"; "_")))
      ] | join("|")
    ),
    "STALE=0"
  ] | join(" ")
' 2>/dev/null)

if [ -z "$PAYLOAD" ]; then
  sketchybar --trigger system_metrics_update STALE=1
  exit 0
fi

# shellcheck disable=SC2086  # intentional: $PAYLOAD is space-separated KEY=VAL pairs
sketchybar --trigger system_metrics_update $PAYLOAD
