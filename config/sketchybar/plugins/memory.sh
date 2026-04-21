#!/bin/sh

# ABOUTME: SketchyBar plugin — memory % event-driven from system_metrics_update
# ABOUTME: Left-click opens a popup with wired/active/compressed/swap breakdown (one-shot vm_stat)

GREY=0xff585b70
TEAL=0xff94e2d5
GREEN=0xffa6e3a1
YELLOW=0xfff9e2af
RED=0xfff38ba8
SUBTEXT=0xffa6adc8

# Human-readable GB formatter for a byte count from vm_stat (pages × page_size).
format_gb() {
  bytes=$1
  awk -v b="$bytes" 'BEGIN { printf "%.1f", b / 1073741824 }'
}

# ---------------------------------------------------------------------------
# Left-click: populate + toggle the detailed popup.
# vm_stat is a one-shot here (not on the periodic tick), so there's no
# per-tick cost for the extra detail.
# ---------------------------------------------------------------------------
if [ "$BUTTON" = "left" ]; then
  sketchybar --remove '/memory\.detail\..*/' 2>/dev/null

  PAGE_SIZE=$(sysctl -n hw.pagesize 2>/dev/null || echo 16384)
  VM=$(vm_stat 2>/dev/null)

  WIRED_PAGES=$(echo "$VM" | awk '/Pages wired/ {gsub(/\./,""); print $4}')
  ACTIVE_PAGES=$(echo "$VM" | awk '/Pages active/ {gsub(/\./,""); print $3}')
  COMPRESSED_PAGES=$(echo "$VM" | awk '/Pages occupied by compressor/ {gsub(/\./,""); print $5}')

  WIRED_GB=$(format_gb $((WIRED_PAGES * PAGE_SIZE)))
  ACTIVE_GB=$(format_gb $((ACTIVE_PAGES * PAGE_SIZE)))
  COMPRESSED_GB=$(format_gb $((COMPRESSED_PAGES * PAGE_SIZE)))

  # Swap usage (via sysctl — same as ollama-pressure-guard for consistency)
  SWAP_USED_MB=$(sysctl -n vm.swapusage 2>/dev/null \
      | sed -nE 's/.*used = ([0-9]+)\.[0-9]+M.*/\1/p')
  SWAP_USED_MB=${SWAP_USED_MB:-0}
  SWAP_GB=$(awk -v m="$SWAP_USED_MB" 'BEGIN { printf "%.1f", m / 1024 }')

  add_row() {
    id="$1"; label="$2"; value="$3"; color="$4"
    sketchybar --add item "memory.detail.$id" popup.memory \
      --set "memory.detail.$id" \
        icon="$label" \
        icon.font="SF Pro:Regular:13.0" \
        icon.color="$SUBTEXT" \
        label="$value" \
        label.font="SF Pro:Regular:13.0" \
        label.color="$color"
  }

  add_row wired      "Wired"      "${WIRED_GB} GB"      "$SUBTEXT"
  add_row active     "Active"     "${ACTIVE_GB} GB"     "$SUBTEXT"
  add_row compressed "Compressed" "${COMPRESSED_GB} GB" "$YELLOW"

  # Swap row colored by severity — matches #248 SWAP_WARNING_GB (2 GB)
  SWAP_INT=${SWAP_GB%.*}
  if [ "$SWAP_INT" -ge 2 ]; then
    SWAP_COLOR=$RED
  elif [ "$SWAP_INT" -ge 1 ]; then
    SWAP_COLOR=$YELLOW
  else
    SWAP_COLOR=$SUBTEXT
  fi
  add_row swap "Swap" "${SWAP_GB} GB" "$SWAP_COLOR"

  sketchybar --set memory popup.drawing=toggle
  exit 0
fi

# ---------------------------------------------------------------------------
# Periodic event update from system_metrics_update (#249).
# MEM_USED / MEM_TOTAL / SWAP_USED come from /metrics; no local probes.
# ---------------------------------------------------------------------------
if [ "$STALE" = "1" ] || [ -z "$MEM_USED" ] || [ -z "$MEM_TOTAL" ]; then
  sketchybar --set "$NAME" label.color=$GREY icon.color=$GREY
  exit 0
fi

# Use awk to compute percentage (floats) without spawning bc
PCT=$(awk -v u="$MEM_USED" -v t="$MEM_TOTAL" 'BEGIN { if (t > 0) printf "%d", (u/t)*100; else print 0 }')

if [ "$PCT" -ge 85 ]; then
  LABEL_COLOR=$RED
elif [ "$PCT" -ge 60 ]; then
  LABEL_COLOR=$YELLOW
else
  LABEL_COLOR=$GREEN
fi

# Icon color reflects swap pressure (not just total usage) — swap in use
# is the signal that actually hurts responsiveness.
SWAP_INT=${SWAP_USED%.*}
if [ -z "$SWAP_INT" ]; then SWAP_INT=0; fi

if [ "$SWAP_INT" -ge 3 ]; then
  ICON_COLOR=$RED
elif [ "$SWAP_INT" -ge 1 ]; then
  ICON_COLOR=$YELLOW
else
  ICON_COLOR=$TEAL
fi

sketchybar --set "$NAME" label="${PCT}%" label.color=$LABEL_COLOR icon.color=$ICON_COLOR
