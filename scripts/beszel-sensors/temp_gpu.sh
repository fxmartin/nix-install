#!/bin/sh

# ABOUTME: Custom sensor — prints GPU temperature (°C) as a single float (Story 08.4-002)

METRICS_URL="${SKETCHYBAR_METRICS_URL:-http://localhost:7780/metrics}"

curl -sf --max-time 2 "$METRICS_URL" \
  | jq -r '.thermal.gpu_temp_c // empty' \
  | grep -E '^[0-9]+(\.[0-9]+)?$' \
  || exit 1
