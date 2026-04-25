#!/bin/sh

# ABOUTME: SketchyBar external-display CPU user/system/idle split
# ABOUTME: Consumes CPU_USER, CPU_SYS, CPU_IDLE from system_metrics_update

GREY=0xff585b70
SUBTEXT=0xffa6adc8
TEXT=0xffcdd6f4

if [ "$STALE" = "1" ]; then
  sketchybar --set "$NAME" label="U/S/I n/a" label.color=$GREY icon.color=$GREY
  exit 0
fi

USER_INT=${CPU_USER%.*}
SYS_INT=${CPU_SYS%.*}
IDLE_INT=${CPU_IDLE%.*}

[ -z "$USER_INT" ] && USER_INT=0
[ -z "$SYS_INT" ] && SYS_INT=0
[ -z "$IDLE_INT" ] && IDLE_INT=0

sketchybar --set "$NAME" \
  icon.color=$TEXT \
  label="U:${USER_INT}% S:${SYS_INT}% I:${IDLE_INT}%" \
  label.color=$SUBTEXT
