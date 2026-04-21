#!/usr/bin/env bash
# ABOUTME: Auto-unload Ollama models when macOS is under sustained memory pressure (Story 08.2-002)
# ABOUTME: Invoked every 60s by the ollama-pressure-guard LaunchAgent (darwin/maintenance.nix)
#
# Problem: default Ollama behavior pins a loaded model in RAM for its full
# keep-alive window. On a 48 GB machine running gemma4:26b (17 GB resident)
# plus a browser-heavy workload, this tips macOS into swap thrash — the 3 GB
# swap + 11 GB compressor baseline seen at Epic-08 baseline.
#
# This script probes swap usage every minute and, when it exceeds the
# configured threshold, unloads every loaded Ollama model via the API
# (keep_alive=0). Ollama re-loads on the next request — cold-load penalty
# is cheap compared to the cost of swap-thrashing other workloads.
#
# Configuration (env vars):
#   OLLAMA_UNLOAD_ON_PRESSURE  off|warn|critical   (default: warn)
#                              off      — never unload
#                              warn     — unload when swap > SWAP_WARN_GB
#                              critical — unload only at SWAP_CRITICAL_GB
#   SWAP_WARN_GB               default 2   (matches health-api.py SWAP_WARNING_GB)
#   SWAP_CRITICAL_GB           default 5
#
# Logs: /tmp/ollama-pressure.log — timestamp, swap_gb, action taken

set -euo pipefail

LOG=/tmp/ollama-pressure.log
MODE="${OLLAMA_UNLOAD_ON_PRESSURE:-warn}"
SWAP_WARN_GB="${SWAP_WARN_GB:-2}"
SWAP_CRITICAL_GB="${SWAP_CRITICAL_GB:-5}"
OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"

log() {
    printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "$*" >> "$LOG"
}

# Quick exit if operator disabled the guard
if [[ "$MODE" == "off" ]]; then
    exit 0
fi

# Current swap usage in whole GB (integer floor).
# sysctl output: "total = 4096.00M  used = 850.75M  free = 3245.25M  (encrypted)"
swap_used_mb=$(sysctl -n vm.swapusage 2>/dev/null | sed -nE 's/.*used = ([0-9]+)\.[0-9]+M.*/\1/p' || echo 0)
swap_used_gb=$(( swap_used_mb / 1024 ))

# Pick the active threshold based on mode.
threshold_gb=$SWAP_WARN_GB
[[ "$MODE" == "critical" ]] && threshold_gb=$SWAP_CRITICAL_GB

# Under the threshold → no action. Don't spam the log on quiet ticks.
if (( swap_used_gb < threshold_gb )); then
    exit 0
fi

# Over threshold — check whether Ollama is even responding.
if ! curl -sf --max-time 2 "${OLLAMA_URL}/api/version" >/dev/null 2>&1; then
    log "pressure=${swap_used_gb}GB (mode=${MODE}, threshold=${threshold_gb}GB) — Ollama not responding, skipping"
    exit 0
fi

# Enumerate loaded models from `ollama ps`. First column is NAME.
# Skip header line (NR>1) and empty lines.
loaded=$(ollama ps 2>/dev/null | awk 'NR>1 && NF>0 {print $1}' || true)

if [[ -z "$loaded" ]]; then
    log "pressure=${swap_used_gb}GB (mode=${MODE}, threshold=${threshold_gb}GB) — no models loaded, skipping"
    exit 0
fi

# Unload every loaded model. keep_alive=0 tells Ollama to release immediately.
# We accept the small risk of aborting an in-flight request; a 60s tick
# interval makes this rare, and the alternative (continued swap thrash) is
# worse for overall system responsiveness.
unloaded=""
failed=""
while IFS= read -r model; do
    if curl -sf --max-time 5 "${OLLAMA_URL}/api/generate" \
         -d "{\"model\":\"${model}\",\"keep_alive\":0}" >/dev/null 2>&1; then
        unloaded="${unloaded}${unloaded:+,}${model}"
    else
        failed="${failed}${failed:+,}${model}"
    fi
done <<< "$loaded"

log "pressure=${swap_used_gb}GB (mode=${MODE}, threshold=${threshold_gb}GB) unloaded=[${unloaded:-none}]${failed:+ failed=[${failed}]}"
