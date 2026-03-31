#!/bin/sh

# ABOUTME: SketchyBar plugin — Thermal state via macOS ProcessInfo API
# States: 0=nominal, 1=fair, 2=serious, 3=critical

STATE=$(swift -e 'import Foundation; print(ProcessInfo.processInfo.thermalState.rawValue)' 2>/dev/null)
[ -z "$STATE" ] && exit 0

case "$STATE" in
  0) COLOR="0xffa6e3a1"; LABEL="OK" ;;       # Green - nominal
  1) COLOR="0xfff9e2af"; LABEL="WARM" ;;      # Yellow - fair
  2) COLOR="0xfffab387"; LABEL="HOT" ;;       # Orange - serious
  3) COLOR="0xfff38ba8"; LABEL="CRIT" ;;      # Red - critical
  *) COLOR="0xffa6adc8"; LABEL="?" ;;
esac

sketchybar --set "$NAME" label="$LABEL" label.color="$COLOR" icon.color="$COLOR"
