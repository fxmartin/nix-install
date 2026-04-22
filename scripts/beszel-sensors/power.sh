#!/bin/sh

# ABOUTME: Custom sensor — prints the current total power draw (W) as a single float (Story 08.4-002)
# ABOUTME: One-line stdout value for consumers like Beszel custom sensors / Prometheus exporters / logging pipelines

# Reads from the health-api /metrics endpoint (cached, 2s TTL), so calling this
# frequently has no compounding cost. Output is a single decimal number on
# stdout (e.g. "23.4"). Silent on failure (prints nothing, exits 1) so callers
# can distinguish missing data from zero draw.

METRICS_URL="${SKETCHYBAR_METRICS_URL:-http://localhost:7780/metrics}"

curl -sf --max-time 2 "$METRICS_URL" \
  | jq -r '.power.total_watts // empty' \
  | grep -E '^[0-9]+(\.[0-9]+)?$' \
  || exit 1
