#!/bin/sh

# ABOUTME: SketchyBar plugin — GPU utilization percentage via IORegistry

GPU=$(ioreg -r -d 1 -w 0 -c IOAccelerator 2>/dev/null | grep -o '"Device Utilization %"=[0-9]*' | head -1 | cut -d= -f2)
[ -z "$GPU" ] && exit 0

# Color based on current value
if [ "$GPU" -ge 85 ]; then
  COLOR="0xfff38ba8"  # Red (Catppuccin)
elif [ "$GPU" -ge 60 ]; then
  COLOR="0xfff9e2af"  # Yellow
else
  COLOR="0xffa6e3a1"  # Green
fi

sketchybar --set "$NAME" label="${GPU}%" label.color="$COLOR"
