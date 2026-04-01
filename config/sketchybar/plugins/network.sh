#!/bin/sh

# ABOUTME: SketchyBar plugin — Network IN/OUT throughput using netstat bytes delta

CACHE_FILE="/tmp/sketchybar_network_cache"

# Get current byte counts (all interfaces)
CURRENT=$(netstat -ib 2>/dev/null | awk '
  /^en[0-9]/ && $4 != "" && NF >= 10 {
    in_bytes += $7
    out_bytes += $10
  }
  END { print in_bytes, out_bytes }
')

CURRENT_IN=$(echo "$CURRENT" | awk '{print $1}')
CURRENT_OUT=$(echo "$CURRENT" | awk '{print $2}')
CURRENT_TIME=$(date +%s)

# Read previous values
if [ -f "$CACHE_FILE" ]; then
  PREV_IN=$(awk 'NR==1' "$CACHE_FILE")
  PREV_OUT=$(awk 'NR==2' "$CACHE_FILE")
  PREV_TIME=$(awk 'NR==3' "$CACHE_FILE")
else
  PREV_IN=$CURRENT_IN
  PREV_OUT=$CURRENT_OUT
  PREV_TIME=$CURRENT_TIME
fi

# Save current values
printf '%s\n%s\n%s\n' "$CURRENT_IN" "$CURRENT_OUT" "$CURRENT_TIME" > "$CACHE_FILE"

# Calculate delta
ELAPSED=$((CURRENT_TIME - PREV_TIME))
[ "$ELAPSED" -le 0 ] && ELAPSED=1

DELTA_IN=$(( (CURRENT_IN - PREV_IN) / ELAPSED ))
DELTA_OUT=$(( (CURRENT_OUT - PREV_OUT) / ELAPSED ))

# Guard against negative values (interface reset)
[ "$DELTA_IN" -lt 0 ] 2>/dev/null && DELTA_IN=0
[ "$DELTA_OUT" -lt 0 ] 2>/dev/null && DELTA_OUT=0

# Human-readable format
format_bytes() {
  local bytes=$1
  if [ "$bytes" -ge 1073741824 ]; then
    printf "%.1fG" "$(echo "$bytes / 1073741824" | bc -l)"
  elif [ "$bytes" -ge 1048576 ]; then
    printf "%.1fM" "$(echo "$bytes / 1048576" | bc -l)"
  elif [ "$bytes" -ge 1024 ]; then
    printf "%.0fK" "$(echo "$bytes / 1024" | bc -l)"
  else
    printf "0K"
  fi
}

IN_STR=$(format_bytes "$DELTA_IN")
OUT_STR=$(format_bytes "$DELTA_OUT")

sketchybar --set "$NAME" label="↓${IN_STR} ↑${OUT_STR}" label.color=0xffa6adc8
