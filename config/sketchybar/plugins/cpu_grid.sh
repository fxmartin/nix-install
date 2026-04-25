#!/bin/sh

# ABOUTME: SketchyBar external-display CPU per-core activity strip
# ABOUTME: Consumes CPU_CORE_PCTS from system_metrics_update; no local polling

GREY=0xff585b70
AMBER=0xfff9e2af
RED=0xfff38ba8
TEXT=0xffcdd6f4
SUBTEXT=0xffa6adc8

color_for_pct() {
  if awk -v v="$1" 'BEGIN { exit !(v > 60) }'; then
    printf '%s\n' "$RED"
  elif awk -v v="$1" 'BEGIN { exit !(v >= 25) }'; then
    printf '%s\n' "$AMBER"
  else
    printf '%s\n' "$GREY"
  fi
}

glyph_for_pct() {
  awk -v p="$1" 'BEGIN {
    if (p >= 90) print "█";
    else if (p >= 75) print "▇";
    else if (p >= 60) print "▆";
    else if (p >= 45) print "▅";
    else if (p >= 30) print "▄";
    else if (p >= 15) print "▃";
    else if (p >= 5) print "▂";
    else print "▁";
  }'
}

ensure_core_items() {
  count="$1"
  state_file="${TMPDIR:-/tmp}/sketchybar-cpu-core-count"
  desired_state="v2:$count"
  current_count=$(cat "$state_file" 2>/dev/null || printf '0')

  if [ "$current_count" = "$desired_state" ] && sketchybar --query cpu.core.1 >/dev/null 2>&1; then
    return
  fi

  sketchybar --remove '/cpu\.core\..*/' 2>/dev/null

  i=1
  previous=cpu.grid
  while [ "$i" -le "$count" ]; do
    item="cpu.core.$i"
    sketchybar --add item "$item" right \
      --set "$item" \
        icon.drawing=off \
        label.font="Hack Nerd Font:Regular:13.0" \
        label.padding_left=0 \
        label.padding_right=0 \
        padding_left=0 \
        padding_right=0 \
        click_script="$0" \
      --move "$item" before "$previous"
    previous="$item"
    i=$((i + 1))
  done

  printf '%s\n' "$desired_state" > "$state_file"
}

if [ "$BUTTON" = "left" ]; then
  sketchybar --remove '/cpu\.proc\..*/' 2>/dev/null

  I=1
  ps -Ao pid=,pcpu=,comm= | sort -k2 -nr | head -10 | while read -r pid pct comm; do
    sketchybar --add item "cpu.proc.$I" popup.cpu.grid \
      --set "cpu.proc.$I" \
        icon="$(printf '%02d' "$I")" \
        icon.font="SF Pro:Regular:13.0" \
        icon.color="$SUBTEXT" \
        label="$(printf '%5s%%  %s' "$pct" "$comm")" \
        label.font="SF Pro:Regular:13.0" \
        label.color="$SUBTEXT"
    I=$((I + 1))
  done

  sketchybar --set cpu.grid popup.drawing=toggle
  exit 0
fi

if [ "$STALE" = "1" ] || [ -z "$CPU_CORE_PCTS" ]; then
  sketchybar --remove '/cpu\.core\..*/' 2>/dev/null
  sketchybar --set "$NAME" label="cores n/a" label.color=$GREY icon.color=$GREY
  exit 0
fi

CORE_COUNT=$(printf '%s\n' "$CPU_CORE_PCTS" | awk -F, '{ print NF }')
ensure_core_items "$CORE_COUNT"

i=1
printf '%s\n' "$CPU_CORE_PCTS" | tr ',' '\n' | while IFS= read -r pct; do
  sketchybar --set "cpu.core.$i" \
    label="$(glyph_for_pct "$pct")" \
    label.color="$(color_for_pct "$pct")"
  i=$((i + 1))
done

sketchybar --set "$NAME" \
  icon.color=$TEXT \
  label.drawing=off
