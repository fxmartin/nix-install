#!/bin/sh

# ABOUTME: SketchyBar plugin — total system power draw in watts, from system_metrics_update event
# ABOUTME: Color graded by draw: teal idle, green normal, yellow heavy, red sustained peak

GREY=0xff585b70        # overlay0 — stale state
TEAL=0xff94e2d5        # idle
GREEN=0xffa6e3a1       # normal
YELLOW=0xfff9e2af      # heavy
RED=0xfff38ba8         # sustained peak

if [ "$STALE" = "1" ] || [ -z "$WATTS" ]; then
  sketchybar --set "$NAME" label.color=$GREY icon.color=$GREY
  exit 0
fi

# Integer watts (strip decimal)
W_INT=${WATTS%.*}
[ -z "$W_INT" ] && W_INT=0

# M3 Max envelopes — thresholds picked from observed ranges on Power profile:
#   <15W idle / light web browsing
#   <30W mixed dev work (compiling, ollama on ANE)
#   <45W heavy (ollama on GPU, xcode builds)
#   ≥45W sustained peak
if [ "$W_INT" -ge 45 ]; then
  COLOR=$RED
elif [ "$W_INT" -ge 30 ]; then
  COLOR=$YELLOW
elif [ "$W_INT" -ge 15 ]; then
  COLOR=$GREEN
else
  COLOR=$TEAL
fi

sketchybar --set "$NAME" label="${W_INT}W" label.color=$COLOR icon.color=$COLOR
