#!/bin/sh

# ABOUTME: SketchyBar plugin — Memory usage percentage (active + wired + compressed)

PAGE_SIZE=$(sysctl -n hw.pagesize)
TOTAL_MEM=$(sysctl -n hw.memsize)
VM=$(vm_stat 2>/dev/null)
[ -z "$VM" ] && exit 0

ACTIVE=$(echo "$VM" | awk '/Pages active/ {gsub(/\./,""); print $3}')
WIRED=$(echo "$VM" | awk '/Pages wired/ {gsub(/\./,""); print $4}')
COMPRESSED=$(echo "$VM" | awk '/Pages occupied by compressor/ {gsub(/\./,""); print $5}')

USED=$(( (ACTIVE + WIRED + COMPRESSED) * PAGE_SIZE ))
MEM=$(( USED * 100 / TOTAL_MEM ))

# Color based on current value
if [ "$MEM" -ge 85 ]; then
  COLOR="0xfff38ba8"  # Red (Catppuccin)
elif [ "$MEM" -ge 60 ]; then
  COLOR="0xfff9e2af"  # Yellow
else
  COLOR="0xffa6e3a1"  # Green
fi

sketchybar --set "$NAME" label="${MEM}%" label.color="$COLOR"
