#!/bin/sh

# ABOUTME: SketchyBar plugin — Compact disk free-space status icon
# ABOUTME: Uses Finder-equivalent free space and colors the icon by remaining capacity

GREEN=0xffa6e3a1
YELLOW=0xfff9e2af
RED=0xfff38ba8

if [ -n "${SKETCHYBAR_DISK_AVAILABLE_BYTES:-}" ] && [ -n "${SKETCHYBAR_DISK_TOTAL_BYTES:-}" ]; then
  AVAILABLE="$SKETCHYBAR_DISK_AVAILABLE_BYTES"
  TOTAL="$SKETCHYBAR_DISK_TOTAL_BYTES"
else
  # Use Swift to get volumeAvailableCapacityForImportantUsage (same as Finder).
  CAPACITY=$(swift -e '
import Foundation
let url = URL(fileURLWithPath: "/")
let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
let available = values.volumeAvailableCapacityForImportantUsage ?? 0
let total = Int64(values.volumeTotalCapacity ?? 0)
print("\(available) \(total)")
' 2>/dev/null)

  [ -z "$CAPACITY" ] && exit 0
  AVAILABLE=$(printf '%s\n' "$CAPACITY" | awk '{print $1}')
  TOTAL=$(printf '%s\n' "$CAPACITY" | awk '{print $2}')
fi

case "$AVAILABLE:$TOTAL" in
  *[!0-9:]* | :* | *: | *::*) exit 0 ;;
esac

[ "$TOTAL" -le 0 ] && exit 0

FREE_PCT=$((AVAILABLE * 100 / TOTAL))

if [ "$FREE_PCT" -lt 10 ]; then
  COLOR=$RED
elif [ "$FREE_PCT" -lt 20 ]; then
  COLOR=$YELLOW
else
  COLOR=$GREEN
fi

sketchybar --set "$NAME" \
  icon.color="$COLOR" \
  label="${FREE_PCT}%" \
  label.drawing=off
