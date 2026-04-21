#!/bin/sh

# ABOUTME: Custom sensor — prints the hottest silicon temperature (°C) as a single float (Story 08.4-002)
# ABOUTME: max(cpu_temp_c, gpu_temp_c); one-line stdout value for external time-series consumers

# See power.sh — same contract: single number on stdout, silent-failure exit 1.

METRICS_URL="${SKETCHYBAR_METRICS_URL:-http://localhost:7780/metrics}"

curl -sf --max-time 2 "$METRICS_URL" \
  | jq -r '[.thermal.cpu_temp_c // 0, .thermal.gpu_temp_c // 0] | max' \
  | grep -E '^[0-9]+(\.[0-9]+)?$' \
  || exit 1
