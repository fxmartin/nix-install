#!/bin/sh
# ABOUTME: SketchyBar plugin — highlight the AeroSpace focused workspace
#
# Invoked on two events:
#   1. `aerospace_workspace_change` — triggered by AeroSpace on every switch.
#      $FOCUSED_WORKSPACE is injected by the trigger in aerospace.toml.
#   2. Initial `sketchybar --update` at load — no env var, so we query AeroSpace.

# Each item is named `workspace.<id>`; extract the id portion
WORKSPACE_ID="${NAME#workspace.}"

# When triggered by AeroSpace, $FOCUSED_WORKSPACE is set; otherwise query the CLI
if [ -z "${FOCUSED_WORKSPACE}" ]; then
    FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null)"
fi

# Catppuccin Mocha: blue=0xff89b4fa (active), surface0=0x40585b70 (inactive)
if [ "${WORKSPACE_ID}" = "${FOCUSED_WORKSPACE}" ]; then
    sketchybar --set "${NAME}" \
        background.color=0xff89b4fa \
        icon.color=0xff1e1e2e \
        label.color=0xff1e1e2e
else
    sketchybar --set "${NAME}" \
        background.color=0x40585b70 \
        icon.color=0xffcdd6f4 \
        label.color=0xffcdd6f4
fi
