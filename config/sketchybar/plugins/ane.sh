#!/bin/sh

# ABOUTME: SketchyBar plugin — Apple Neural Engine activity indicator (Story 08.3-003)
# ABOUTME: Lights up when ANE_W > 0.5 from /metrics event; dim otherwise

# Catppuccin Mocha palette
GREY=0xff585b70        # overlay0 — dim when idle or stale
ACTIVE=0xfff5c2be       # a soft pink — visually distinct from GPU/CPU

# Stale state: dim and hide label
if [ "$STALE" = "1" ] || [ -z "$ANE_W" ]; then
  sketchybar --set "$NAME" icon.color=$GREY label.drawing=off
  exit 0
fi

# ANE watts is a float like "0.12" or "1.8". Use awk for portable float compare.
# Threshold 0.5W picked empirically: idle draw is ~0.1W, any active inference
# pushes past 1W within milliseconds.
ACTIVE_NOW=$(awk -v w="$ANE_W" 'BEGIN { print (w > 0.5) ? 1 : 0 }')

if [ "$ACTIVE_NOW" = "1" ]; then
  sketchybar --set "$NAME" icon.color=$ACTIVE label="${ANE_W}W" label.drawing=on label.color=$ACTIVE
else
  sketchybar --set "$NAME" icon.color=$GREY label.drawing=off
fi
