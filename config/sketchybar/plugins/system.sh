#!/bin/sh

# ABOUTME: SketchyBar /metrics aggregator — single poller that fans out to all system items
# ABOUTME: Triggers system_metrics_update event with parsed values for cpu.e/cpu.p/gpu/ane/power/temp/memory

# Replaces N per-plugin top/ioreg/swift/vm_stat spawns with a single
# HTTP fetch per tick. Runs every update_freq (see sketchybarrc — 2s
# on AC, 10s on battery per Story 08.3-007).
#
# On success: triggers system_metrics_update with all parsed values as env.
# On failure (timeout, non-200, parse error): triggers with STALE=1 so
# consumer items can dim to grey rather than render stale numbers.

METRICS_URL="${SKETCHYBAR_METRICS_URL:-http://localhost:7780/metrics}"

JSON=$(curl -s --max-time 1 "$METRICS_URL" 2>/dev/null)
if [ -z "$JSON" ]; then
  sketchybar --trigger system_metrics_update STALE=1
  exit 0
fi

# Parse with jq. `// 0` and `// ""` defaults guard against missing fields
# (older health-api versions won't have ANE/power/processes yet).
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
    "SWAP_USED=" + ((.memory.swap_used_gb // 0) | tostring),
    "STALE=0"
  ] | join(" ")
' 2>/dev/null)

if [ -z "$PAYLOAD" ]; then
  sketchybar --trigger system_metrics_update STALE=1
  exit 0
fi

# shellcheck disable=SC2086  # intentional: $PAYLOAD is space-separated KEY=VAL pairs
sketchybar --trigger system_metrics_update $PAYLOAD
