#!/bin/sh

# ABOUTME: SketchyBar external-display CPU per-core activity strip
# ABOUTME: Consumes CPU_CORES from system_metrics_update; no local polling

GREY=0xff585b70
GREEN=0xffa6e3a1
YELLOW=0xfff9e2af
RED=0xfff38ba8
TEXT=0xffcdd6f4
SUBTEXT=0xffa6adc8

if [ "$BUTTON" = "left" ]; then
  sketchybar --remove '/cpu\.proc\..*/' 2>/dev/null

  I=1
  ps -Ao pid=,pcpu=,comm= | sort -k2 -nr | head -10 | while read -r pid pct comm; do
    sketchybar --add item "cpu.proc.$I" popup.cpu.grid \
      --set "cpu.proc.$I" \
        icon="$(printf '%02d' "$I")" \
        icon.font="SF Pro:Regular:13.0" \
        icon.color="$SUBTEXT" \
        label="$(printf '%5s%%  %s' "$pct" "$comm")" \
        label.font="SF Pro:Regular:13.0" \
        label.color="$SUBTEXT"
    I=$((I + 1))
  done

  sketchybar --set cpu.grid popup.drawing=toggle
  exit 0
fi

if [ "$STALE" = "1" ] || [ -z "$CPU_CORES" ]; then
  sketchybar --set "$NAME" label="cores n/a" label.color=$GREY icon.color=$GREY
  exit 0
fi

HOT=$(printf '%s' "$CPU_CORES" | grep -o "█" | wc -l | tr -d ' ')
WARM=$(printf '%s' "$CPU_CORES" | grep -o "▇\\|▆" | wc -l | tr -d ' ')

if [ "$HOT" -gt 0 ]; then
  COLOR=$RED
elif [ "$WARM" -gt 0 ]; then
  COLOR=$YELLOW
else
  COLOR=$GREEN
fi

sketchybar --set "$NAME" \
  icon.color=$TEXT \
  label="$CPU_CORES" \
  label.color=$COLOR
