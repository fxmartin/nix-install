#!/bin/sh

# ABOUTME: SketchyBar plugin — Network IN/OUT throughput with top-5 processes popup

CACHE_FILE="/tmp/sketchybar_network_cache"
SUBTEXT="0xffa6adc8"

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

# On click: show top 5 network-consuming processes
if [ "$BUTTON" = "left" ]; then
  # Remove old popup items
  sketchybar --remove '/network\.proc\..*/' 2>/dev/null

  # Get top 5 processes by total bytes (in+out), skip header and zero-traffic
  TOP5=$(nettop -P -L 1 -n -x 2>/dev/null | tail -n +2 | awk -F',' '
    $5+0 > 0 || $6+0 > 0 {
      name=$2; sub(/\.[0-9]+$/, "", name)
      bytes_in=$5+0; bytes_out=$6+0
      total=bytes_in+bytes_out
      printf "%d|%d|%d|%s\n", total, bytes_in, bytes_out, name
    }
  ' | sort -t'|' -k1 -rn | head -5)

  if [ -z "$TOP5" ]; then
    sketchybar --add item network.proc.none popup.network \
      --set network.proc.none \
        icon="—" \
        label="No network activity" \
        label.font="SF Pro:Regular:13.0" \
        label.color="$SUBTEXT" \
        icon.color="$SUBTEXT"
  else
    IDX=0
    echo "$TOP5" | while IFS='|' read -r total bytes_in bytes_out name; do
      IN_STR=$(format_bytes "$bytes_in")
      OUT_STR=$(format_bytes "$bytes_out")

      sketchybar --add item "network.proc.p${IDX}" popup.network \
        --set "network.proc.p${IDX}" \
          icon="󰛳" \
          icon.font="Hack Nerd Font:Bold:14.0" \
          icon.color="$SUBTEXT" \
          label="${name}  ↓${IN_STR} ↑${OUT_STR}" \
          label.font="SF Pro:Regular:13.0" \
          label.color="$SUBTEXT"
      IDX=$((IDX + 1))
    done
  fi

  sketchybar --set network popup.drawing=toggle
  exit 0
fi

# Periodic update: compute throughput delta
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

IN_STR=$(format_bytes "$DELTA_IN")
OUT_STR=$(format_bytes "$DELTA_OUT")

sketchybar --set "$NAME" label="↓${IN_STR} ↑${OUT_STR}" label.color="$SUBTEXT"
