#!/bin/sh

# ABOUTME: SketchyBar graphical memory pressure summary
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

BAR_USED=${MEM_ACTIVE:-$MEM_USED}
PCT=$(awk -v u="$BAR_USED" -v t="$MEM_TOTAL" 'BEGIN { if (t > 0) printf "%d", (u/t)*100; else print 0 }')
FILLED=$(awk -v p="$PCT" 'BEGIN { printf "%d", (p / 20) + 1 }')
[ "$FILLED" -lt 0 ] && FILLED=0
[ "$FILLED" -gt 5 ] && FILLED=5

BAR=""
i=0
while [ "$i" -lt 5 ]; do
  if [ "$i" -lt "$FILLED" ]; then
    BAR="${BAR}▰"
  else
    BAR="${BAR}▱"
  fi
  i=$((i + 1))
done

case "$NAME" in
  memory.short) LABEL="${BAR} S${SWAP_USED}G" ;;
  *)            LABEL="${BAR} A${MEM_ACTIVE}G I${MEM_INACTIVE}G S${SWAP_USED}G" ;;
esac

sketchybar --set "$NAME" \
  label="$LABEL" \
  label.color=$COLOR \
  icon.color=$COLOR
