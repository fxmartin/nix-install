#!/bin/sh

# ABOUTME: SketchyBar click handler — full system vitals popup (Story 08.3-005, mactop replacement)
# ABOUTME: Renders on-demand when user left-clicks the cpu.p item; pulls one /metrics payload

# Catppuccin Mocha palette
GREY=0xff585b70
SUBTEXT=0xffa6adc8
TEXT=0xffcdd6f4
GREEN=0xffa6e3a1
YELLOW=0xfff9e2af
RED=0xfff38ba8
TEAL=0xff94e2d5
MAUVE=0xffcba6f7
PINK=0xfff5c2be

POPUP_PARENT="popup.cpu.p"

# Fresh /metrics fetch — we're here because the user clicked, so a one-shot
# probe is fine (not a periodic cost).
JSON=$(curl -s --max-time 2 "http://localhost:7780/metrics" 2>/dev/null)
if [ -z "$JSON" ]; then
  sketchybar --remove '/vitals\..*/' 2>/dev/null
  sketchybar --add item vitals.error "$POPUP_PARENT" \
    --set vitals.error icon="⚠" icon.color=$YELLOW \
      label="health-api not responding" label.color=$SUBTEXT
  sketchybar --set cpu.p popup.drawing=toggle
  exit 0
fi

# Wipe any previous popup items before repopulating.
sketchybar --remove '/vitals\..*/' 2>/dev/null

# Tiny helper: add a row (icon="label", label="value") to the popup.
row() {
  id="$1"; head="$2"; val="$3"; color="${4:-$SUBTEXT}"
  sketchybar --add item "vitals.$id" "$POPUP_PARENT" \
    --set "vitals.$id" \
      icon="$head" \
      icon.font="SF Pro:Regular:13.0" \
      icon.color="$SUBTEXT" \
      label="$val" \
      label.font="SF Pro:Regular:13.0" \
      label.color="$color" >/dev/null
}

divider() {
  id="$1"
  sketchybar --add item "vitals.div.$id" "$POPUP_PARENT" \
    --set "vitals.div.$id" \
      icon="" label="─────────────" label.color=$GREY >/dev/null
}

# Numeric helpers — be robust to missing fields (handle null / empty / decimal).
# Use jq with //0 defaults; output integers where sensible, floats otherwise.
j() { echo "$JSON" | jq -r "$1 // 0"; }
js() { echo "$JSON" | jq -r "$1 // \"\""; }

# ---------------------------------------------------------------------------
# Cluster summary
# ---------------------------------------------------------------------------
E_PCT=$(j '.cpu.e_cluster.active_percent' | awk '{printf "%d", $1}')
P_PCT=$(j '.cpu.p_cluster.active_percent' | awk '{printf "%d", $1}')
GPU_PCT=$(j '.gpu.usage_percent' | awk '{printf "%d", $1}')
ANE_W=$(j '.power.ane_watts')

E_MHZ=$(j '.cpu.e_cluster.freq_mhz')
P_MHZ=$(j '.cpu.p_cluster.freq_mhz')
GPU_MHZ=$(j '.gpu.freq_mhz')

row cluster "Cluster" "E:${E_PCT}%  P:${P_PCT}%  GPU:${GPU_PCT}%  ANE:${ANE_W}W" "$TEXT"
row freq    "Freq"    "E:${E_MHZ} MHz  P:${P_MHZ} MHz  GPU:${GPU_MHZ} MHz"     "$SUBTEXT"

divider 1

# ---------------------------------------------------------------------------
# Memory + swap
# ---------------------------------------------------------------------------
MEM_USED=$(j '.memory.used_gb')
MEM_TOTAL=$(j '.memory.total_gb')
SWAP_USED=$(j '.memory.swap_used_gb')

# Swap color matches #248 threshold (2 GB warn)
SWAP_INT=${SWAP_USED%.*}
if [ "$SWAP_INT" -ge 2 ]; then SWAP_COLOR=$RED
elif [ "$SWAP_INT" -ge 1 ]; then SWAP_COLOR=$YELLOW
else SWAP_COLOR=$SUBTEXT; fi

row mem  "Memory" "${MEM_USED} / ${MEM_TOTAL} GB" "$TEXT"
row swap "Swap"   "${SWAP_USED} GB"                "$SWAP_COLOR"

divider 2

# ---------------------------------------------------------------------------
# Power breakdown
# ---------------------------------------------------------------------------
P_CPU=$(j '.power.cpu_watts')
P_GPU=$(j '.power.gpu_watts')
P_ANE=$(j '.power.ane_watts')
P_DRAM=$(j '.power.dram_watts')
P_TOTAL=$(j '.power.total_watts')

row pw_split "Power"  "CPU:${P_CPU}  GPU:${P_GPU}  ANE:${P_ANE}  DRAM:${P_DRAM} W" "$TEXT"
row pw_total "Total"  "${P_TOTAL} W"                                                "$TEXT"

divider 3

# ---------------------------------------------------------------------------
# Temperatures
# ---------------------------------------------------------------------------
TCPU=$(j '.thermal.cpu_temp_c')
TGPU=$(j '.thermal.gpu_temp_c')

# Hottest-silicon color
TCPU_INT=${TCPU%.*}
TGPU_INT=${TGPU%.*}
if [ "$TCPU_INT" -gt "$TGPU_INT" ]; then HOT=$TCPU_INT; else HOT=$TGPU_INT; fi
if [ "$HOT" -ge 85 ]; then TCOLOR=$RED
elif [ "$HOT" -ge 70 ]; then TCOLOR=$YELLOW
else TCOLOR=$GREEN; fi

row temps "Temps" "CPU:${TCPU}°C  GPU:${TGPU}°C" "$TCOLOR"

divider 4

# ---------------------------------------------------------------------------
# Top-5 CPU processes — from /metrics (#257) if present, fall back to `ps`.
# ---------------------------------------------------------------------------
HAS_PROCS=$(js '.processes.top_cpu | length')
if [ -n "$HAS_PROCS" ] && [ "$HAS_PROCS" != "0" ] && [ "$HAS_PROCS" != "null" ]; then
  # Authoritative source: already cached in /metrics (2s TTL)
  I=0
  echo "$JSON" | jq -r '.processes.top_cpu[] | "\(.pid)\t\(.cpu_percent)\t\(.name)"' | while IFS=$(printf '\t') read pid pct name; do
    row "proc$I" "$(printf '%-4s' "$pid")" "$(printf '%5.1f%%  %s' "$pct" "$name")" "$SUBTEXT"
    I=$((I + 1))
  done
else
  # Fallback: local ps, self-filter. Only runs if health-api is too old to
  # include .processes.top_cpu — #257 adds it, but this keeps the popup
  # useful before that lands.
  I=0
  ps -Ao pid=,pcpu=,comm= | sort -k2 -nr | head -10 | while read pid pct comm; do
    case "$comm" in *health-api.py) continue ;; esac
    row "proc$I" "$(printf '%-4s' "$pid")" "$(printf '%5s%%  %s' "$pct" "$comm")" "$SUBTEXT"
    I=$((I + 1))
    [ $I -ge 5 ] && break
  done
fi

# Finally: toggle the popup so the new items appear.
sketchybar --set cpu.p popup.drawing=toggle
