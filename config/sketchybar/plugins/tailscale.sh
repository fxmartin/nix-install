#!/bin/sh

# ABOUTME: SketchyBar plugin — Tailscale connection status indicator

STATE=$(/usr/local/bin/tailscale status --json 2>/dev/null | jq -r '.BackendState')

if [ "$STATE" = "Running" ]; then
  COLOR="0xffa6e3a1"  # Green (Catppuccin)
else
  COLOR="0xfff38ba8"  # Red (Catppuccin)
fi

sketchybar --set "$NAME" icon.color="$COLOR"
