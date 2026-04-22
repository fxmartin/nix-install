#!/bin/sh

# ABOUTME: SketchyBar plugin — hottest silicon temperature in °C, from system_metrics_update event
# ABOUTME: Replaces the qualitative thermal.sh (OK/WARM/HOT) with actual measured temps

GREY=0xff585b70       # overlay0 — stale
GREEN=0xffa6e3a1      # <70°C — comfortable
YELLOW=0xfff9e2af     # 70-85°C — sustained load
RED=0xfff38ba8        # ≥85°C — watch for throttling

if [ "$STALE" = "1" ]; then
  sketchybar --set "$NAME" label.color=$GREY icon.color=$GREY
  exit 0
fi

# Pick the hotter of CPU / GPU dies — that's the signal that matters for
# throttling. Both come in as floats like "72.5" from macmon.
TCPU=${TEMP_CPU%.*}
TGPU=${TEMP_GPU%.*}
[ -z "$TCPU" ] && TCPU=0
[ -z "$TGPU" ] && TGPU=0

if [ "$TCPU" -gt "$TGPU" ]; then
  HOT=$TCPU
else
  HOT=$TGPU
fi

# Zero temp usually means macmon hasn't populated readings yet — don't flash red.
if [ "$HOT" -le 0 ]; then
  sketchybar --set "$NAME" label.color=$GREY icon.color=$GREY
  exit 0
fi

if [ "$HOT" -ge 85 ]; then
  COLOR=$RED
elif [ "$HOT" -ge 70 ]; then
  COLOR=$YELLOW
else
  COLOR=$GREEN
fi

sketchybar --set "$NAME" label="${HOT}°C" label.color=$COLOR icon.color=$COLOR
