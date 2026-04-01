#!/bin/sh

# ABOUTME: SketchyBar plugin — Tailscale connection status with device list popup

TAILSCALE="/usr/local/bin/tailscale"
GREEN="0xffa6e3a1"
RED="0xfff38ba8"
YELLOW="0xfff9e2af"
SUBTEXT="0xffa6adc8"

# On click: show device list
if [ "$BUTTON" = "left" ]; then
  # Remove old popup items
  sketchybar --remove '/tailscale\.dev\..*/' 2>/dev/null

  DEVICES=$($TAILSCALE status 2>/dev/null)

  if [ -z "$DEVICES" ]; then
    sketchybar --add item tailscale.dev.none popup.tailscale \
      --set tailscale.dev.none \
        icon="—" \
        label="Tailscale not running" \
        label.font="SF Pro:Regular:13.0" \
        label.color="$RED" \
        icon.color="$RED"
  else
    IDX=0
    echo "$DEVICES" | while read -r line; do
      # Parse: IP, hostname, user, OS, status...
      IP=$(echo "$line" | awk '{print $1}')
      HOSTNAME=$(echo "$line" | awk '{print $2}')
      OS=$(echo "$line" | awk '{print $4}')
      # Everything after the 4th field is the status
      STATUS=$(echo "$line" | awk '{for(i=5;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/ *$//')

      if [ -z "$STATUS" ] || [ "$STATUS" = "-" ]; then
        # No status or "-" means online/connected
        ICON="󰪥"  # nf-md-circle
        COLOR="$GREEN"
        STATE="online"
      elif echo "$STATUS" | grep -q "^active"; then
        ICON="󰪥"
        COLOR="$GREEN"
        STATE="online"
      elif echo "$STATUS" | grep -q "^offline"; then
        ICON="󰪥"
        COLOR="$RED"
        # Extract last seen info
        LAST_SEEN=$(echo "$STATUS" | sed 's/offline, //')
        STATE="$LAST_SEEN"
      else
        ICON="󰪥"
        COLOR="$YELLOW"
        STATE="$STATUS"
      fi

      sketchybar --add item "tailscale.dev.d${IDX}" popup.tailscale \
        --set "tailscale.dev.d${IDX}" \
          icon="$ICON" \
          icon.font="Hack Nerd Font:Bold:10.0" \
          icon.color="$COLOR" \
          label="${HOSTNAME} (${IP} / ${OS}) — ${STATE}" \
          label.font="SF Pro:Regular:13.0" \
          label.color="$SUBTEXT"
      IDX=$((IDX + 1))
    done
  fi

  sketchybar --set tailscale popup.drawing=toggle
  exit 0
fi

# Periodic update: check Tailscale backend state
STATE=$($TAILSCALE status --json 2>/dev/null | jq -r '.BackendState')

if [ "$STATE" = "Running" ]; then
  COLOR="$GREEN"
else
  COLOR="$RED"
fi

sketchybar --set "$NAME" icon.color="$COLOR"
