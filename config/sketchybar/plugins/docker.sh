#!/bin/sh

# ABOUTME: SketchyBar plugin — Docker container status with click-to-list popup

# Ensure docker is in PATH (SketchyBar runs with minimal environment)
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

DOCKER=$(command -v docker)
[ -z "$DOCKER" ] && exit 0

GREEN="0xffa6e3a1"
YELLOW="0xfff9e2af"
RED="0xfff38ba8"
SUBTEXT="0xffa6adc8"

# On click: toggle popup and populate container list
if [ "$BUTTON" = "left" ]; then
  # Remove old dynamic popup items
  sketchybar --remove '/docker\.container\..*/' 2>/dev/null

  CONTAINERS=$(docker ps --format '{{.Names}}|{{.Status}}' 2>/dev/null)

  if [ -z "$CONTAINERS" ]; then
    sketchybar --add item docker.container.none popup.docker \
      --set docker.container.none \
        icon="—" \
        label="No running containers" \
        label.font="SF Pro:Regular:13.0" \
        label.color="$SUBTEXT" \
        icon.color="$SUBTEXT"
  else
    echo "$CONTAINERS" | while IFS='|' read -r name status; do
      # Determine health from status string
      if echo "$status" | grep -qi "unhealthy"; then
        ICON="󰅙"  # nf-md-close_circle
        COLOR="$RED"
        HEALTH="unhealthy"
      elif echo "$status" | grep -qi "healthy"; then
        ICON="󰄬"  # nf-md-check_circle
        COLOR="$GREEN"
        HEALTH="healthy"
      else
        ICON="󰋗"  # nf-md-help_circle
        COLOR="$YELLOW"
        HEALTH="no healthcheck"
      fi

      # Sanitize name for sketchybar item id (replace non-alphanumeric with _)
      SAFE_NAME=$(echo "$name" | tr -c '[:alnum:]' '_')

      sketchybar --add item "docker.container.${SAFE_NAME}" popup.docker \
        --set "docker.container.${SAFE_NAME}" \
          icon="$ICON" \
          icon.font="Hack Nerd Font:Bold:14.0" \
          icon.color="$COLOR" \
          label="${name} (${HEALTH})" \
          label.font="SF Pro:Regular:13.0" \
          label.color="$SUBTEXT" \
          click_script="open -a 'Docker Desktop' ; sketchybar --set docker popup.drawing=off"
    done
  fi

  sketchybar --set docker popup.drawing=toggle
  exit 0
fi

# Periodic update: check Docker status and container count
if ! docker info >/dev/null 2>&1; then
  sketchybar --set "$NAME" label="!" label.color="$RED" icon.color="$RED"
  exit 0
fi

COUNT=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')

# Check if any container is unhealthy
UNHEALTHY=$(docker ps --filter "health=unhealthy" -q 2>/dev/null | wc -l | tr -d ' ')

if [ "$UNHEALTHY" -gt 0 ]; then
  COLOR="$YELLOW"
elif [ "$COUNT" -gt 0 ]; then
  COLOR="$GREEN"
else
  COLOR="$SUBTEXT"
fi

sketchybar --set "$NAME" label="$COUNT" label.color="$COLOR" icon.color="$COLOR"
