#!/bin/sh

# ABOUTME: SketchyBar plugin — WiFi connection status indicator

WIFI_STATUS=$(ifconfig en0 2>/dev/null | awk '/status:/ {print $2}')
IP=$(ipconfig getifaddr en0 2>/dev/null)

if [ "$WIFI_STATUS" = "active" ] && [ -n "$IP" ]; then
  COLOR="0xffa6e3a1"  # Green (Catppuccin)
  ICON="󰖩"            # nf-md-wifi
else
  COLOR="0xfff38ba8"  # Red (Catppuccin)
  ICON="󰖪"            # nf-md-wifi_off
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR"
