#!/bin/sh

# ABOUTME: SketchyBar CPU aggregate percentage item
# ABOUTME: Consumes CPU_TOTAL from system_metrics_update; no local polling

GREY=0xff585b70
GREEN=0xffa6e3a1
YELLOW=0xfff9e2af
RED=0xfff38ba8
TEXT=0xffcdd6f4
SUBTEXT=0xffa6adc8

color_for_pct() {
  if [ "$1" -ge 80 ]; then
    printf '%s\n' "$RED"
  elif [ "$1" -ge 50 ]; then
    printf '%s\n' "$YELLOW"
  else
    printf '%s\n' "$GREEN"
  fi
}

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

sketchybar --remove '/cpu\.core\..*/' 2>/dev/null

if [ "$STALE" = "1" ] || [ -z "$CPU_TOTAL" ]; then
  sketchybar --set "$NAME" label="CPU n/a" label.color=$GREY icon.drawing=off
  exit 0
fi

CPU_INT=${CPU_TOTAL%.*}
[ -z "$CPU_INT" ] && CPU_INT=0

sketchybar --set "$NAME" \
  icon.drawing=off \
  label="CPU ${CPU_INT}%" \
  label.color="$(color_for_pct "$CPU_INT")"
