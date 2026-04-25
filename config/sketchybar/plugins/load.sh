#!/bin/sh

# ABOUTME: SketchyBar external-display load-average item
# ABOUTME: Consumes LOAD_AVG from system_metrics_update

GREY=0xff585b70
SUBTEXT=0xffa6adc8
YELLOW=0xfff9e2af

if [ "$STALE" = "1" ] || [ -z "$LOAD_AVG" ]; then
  sketchybar --set "$NAME" label="0/0/0" label.color=$GREY icon.color=$GREY
  exit 0
fi

FIRST=${LOAD_AVG%%/*}
FIRST_INT=${FIRST%.*}
[ -z "$FIRST_INT" ] && FIRST_INT=0

if [ "$FIRST_INT" -ge 16 ]; then
  COLOR=$YELLOW
else
  COLOR=$SUBTEXT
fi

sketchybar --set "$NAME" label="$LOAD_AVG" label.color=$COLOR icon.color=$SUBTEXT
