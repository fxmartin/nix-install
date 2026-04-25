#!/bin/sh

# ABOUTME: SketchyBar external-display Apple Silicon cluster summary
# ABOUTME: Consumes P/E/GPU/ANE/power/temp values from system_metrics_update

GREY=0xff585b70
SUBTEXT=0xffa6adc8
TEXT=0xffcdd6f4

if [ "$STALE" = "1" ]; then
  sketchybar --set "$NAME" label="silicon n/a" label.color=$GREY icon.color=$GREY
  exit 0
fi

E=${CPU_E%.*}
P=${CPU_P%.*}
G=${GPU%.*}
[ -z "$E" ] && E=0
[ -z "$P" ] && P=0
[ -z "$G" ] && G=0

sketchybar --set "$NAME" \
  label="E:${E}% P:${P}% G:${G}% ANE:${ANE_W}W" \
  label.color=$TEXT \
  icon.color=$SUBTEXT
