#!/bin/sh

# ABOUTME: SketchyBar plugin — GPU utilization % + frequency, event-driven from system_metrics_update
# ABOUTME: Reads GPU / GPU_MHZ from the event env set by system.sh (Story 08.3-001)

# Catppuccin Mocha palette
GREY=0xff585b70     # overlay0 — dim for stale
GREEN=0xffa6e3a1
YELLOW=0xfff9e2af
RED=0xfff38ba8
SUBTEXT=0xffa6adc8

# Stale state (no fresh /metrics this tick) — dim without erasing the old label
if [ "$STALE" = "1" ]; then
  sketchybar --set "$NAME" label.color=$GREY icon.color=$GREY
  exit 0
fi

GPU_INT=${GPU%.*}
[ -z "$GPU_INT" ] && GPU_INT=0

if [ "$GPU_INT" -ge 85 ]; then
  LABEL_COLOR=$RED
elif [ "$GPU_INT" -ge 60 ]; then
  LABEL_COLOR=$YELLOW
else
  LABEL_COLOR=$GREEN
fi

# Only show MHz when GPU is actually busy — keeps the bar quiet at idle
if [ "$GPU_INT" -ge 10 ] && [ -n "$GPU_MHZ" ] && [ "$GPU_MHZ" != "0" ]; then
  LABEL="${GPU_INT}% ${GPU_MHZ%.*}MHz"
else
  LABEL="${GPU_INT}%"
fi

sketchybar --set "$NAME" label="$LABEL" label.color=$LABEL_COLOR icon.color=$SUBTEXT
