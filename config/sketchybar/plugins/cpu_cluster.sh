#!/bin/sh

# ABOUTME: SketchyBar plugin — per-cluster CPU utilization (E/P) driven by system_metrics_update event
# ABOUTME: Reads CPU_E / CPU_P from the event env set by system.sh; shared by cpu.e and cpu.p items

# Catppuccin Mocha palette
GREY=0xff585b70       # overlay0 — dim for stale
GREEN=0xffa6e3a1
YELLOW=0xfff9e2af
RED=0xfff38ba8
E_ACCENT=0xff94e2d5   # teal — efficiency cluster
P_ACCENT=0xffcba6f7   # mauve — performance cluster (label color when low/idle)

# Stale state: no fresh /metrics payload this tick — dim both items.
if [ "$STALE" = "1" ]; then
  sketchybar --set "$NAME" label.color=$GREY icon.color=$GREY
  exit 0
fi

case "$NAME" in
  cpu.e) VAL="$CPU_E"; PREFIX="E" ;;
  cpu.p) VAL="$CPU_P"; PREFIX="P" ;;
  *)     exit 0 ;;
esac

# Strip fractional part for display (metrics sends floats like "12.5")
VAL_INT=${VAL%.*}
[ -z "$VAL_INT" ] && VAL_INT=0

# Color thresholds — applied to label color only; icon keeps its cluster accent.
# P-cluster bears the user-visible load; use stronger alert palette on it.
# E-cluster rarely exceeds 70% in practice; identical thresholds keep both
# items visually consistent.
if [ "$VAL_INT" -ge 70 ]; then
  LABEL_COLOR=$RED
elif [ "$VAL_INT" -ge 30 ]; then
  LABEL_COLOR=$YELLOW
else
  LABEL_COLOR=$GREEN
fi

# Icon stays a cluster-distinctive color regardless of load.
case "$NAME" in
  cpu.e) ICON_COLOR=$E_ACCENT ;;
  cpu.p) ICON_COLOR=$P_ACCENT ;;
esac

sketchybar --set "$NAME" \
  label="${PREFIX}:${VAL_INT}%" \
  label.color=$LABEL_COLOR \
  icon.color=$ICON_COLOR
