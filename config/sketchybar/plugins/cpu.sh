#!/bin/sh

# ABOUTME: SketchyBar plugin — CPU usage percentage

# Get CPU usage (100 - idle%)
CPU=$(top -l 1 -n 0 2>/dev/null | awk '/CPU usage/ {print int(100 - $7)}')
[ -z "$CPU" ] && exit 0

# Color based on current value
if [ "$CPU" -ge 85 ]; then
  COLOR="0xfff38ba8"  # Red (Catppuccin)
elif [ "$CPU" -ge 60 ]; then
  COLOR="0xfff9e2af"  # Yellow
else
  COLOR="0xffa6e3a1"  # Green
fi

sketchybar --set "$NAME" label="${CPU}%" label.color="$COLOR"
