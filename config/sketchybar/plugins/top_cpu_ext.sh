#!/bin/sh

# ABOUTME: SketchyBar external-display top CPU process ticker
# ABOUTME: Consumes TOP_CPU from system_metrics_update; no local ps polling

GREY=0xff585b70
SUBTEXT=0xffa6adc8

if [ "$STALE" = "1" ] || [ -z "$TOP_CPU" ]; then
  sketchybar --set "$NAME" label="top cpu n/a" label.color=$GREY icon.color=$GREY
  exit 0
fi

sketchybar --set "$NAME" label="$TOP_CPU" label.color=$SUBTEXT icon.color=$SUBTEXT
