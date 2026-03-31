#!/bin/sh

# ABOUTME: SketchyBar plugin — Disk usage with spark bar (static level)

# Get disk usage percentage for Data volume (where user data lives)
DISK=$(df -h /System/Volumes/Data 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print int($5)}')
[ -z "$DISK" ] && exit 0

# Color based on current value
if [ "$DISK" -ge 85 ]; then
  COLOR="0xfff38ba8"  # Red (Catppuccin)
elif [ "$DISK" -ge 60 ]; then
  COLOR="0xfff9e2af"  # Yellow
else
  COLOR="0xffa6e3a1"  # Green
fi

sketchybar --set "$NAME" label="${DISK}%" label.color="$COLOR"
