#!/bin/sh

# ABOUTME: SketchyBar external-display memory pressure summary
# ABOUTME: Consumes memory fields from system_metrics_update

GREY=0xff585b70
GREEN=0xffa6e3a1
YELLOW=0xfff9e2af
RED=0xfff38ba8

if [ "$STALE" = "1" ]; then
  sketchybar --set "$NAME" label="mem n/a" label.color=$GREY icon.color=$GREY
  exit 0
fi

case "$MEM_PRESSURE" in
  critical) COLOR=$RED ;;
  warn) COLOR=$YELLOW ;;
  *) COLOR=$GREEN ;;
esac

sketchybar --set "$NAME" \
  label="${MEM_USED}/${MEM_TOTAL}G swap:${SWAP_USED}G" \
  label.color=$COLOR \
  icon.color=$COLOR
