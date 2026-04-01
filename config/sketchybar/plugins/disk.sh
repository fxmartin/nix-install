#!/bin/sh

# ABOUTME: SketchyBar plugin — Disk usage percentage matching Finder (includes purgeable space)

# Use Swift to get volumeAvailableCapacityForImportantUsage (same as Finder)
DISK=$(swift -e '
import Foundation
let url = URL(fileURLWithPath: "/")
let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
let available = values.volumeAvailableCapacityForImportantUsage ?? 0
let total = Int64(values.volumeTotalCapacity ?? 0)
let usedPct = Int(Double(total - available) / Double(total) * 100)
print(usedPct)
' 2>/dev/null)

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
