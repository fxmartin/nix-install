#!/usr/bin/env bash
# ABOUTME: Notify on orphaned Apple Virtualization.framework VMs holding multi-GB RSS
# ABOUTME: Invoked every 10 min by the virt-vm-orphan-watch LaunchAgent (darwin/maintenance.nix)
#
# Problem: Apple Virtualization.framework VMs (most commonly Claude Desktop's
# sandbox, ~5 GB) sometimes get orphaned (PPID=1) after the parent .app crashes.
# The VM keeps holding RAM until killed manually. On 2026-04-22 a ~5 GB orphan
# VM contributed to a watchdog-timeout kernel panic (compressor saturated,
# 20 swapfiles, LOW swap space).
#
# This script runs on a timer, flags orphan VMs, and delivers two notifications:
#   - a modal macOS alert (`display alert ... as critical`, auto-dismiss 5 min)
#   - an email via send-notification.sh (if NOTIFICATION_EMAIL is set)
# It DOES NOT kill anything — the decision is explicitly left to the operator.
#
# Dedup: a pid is notified at most once per script lifetime (seen-state in
# $STATE). Orphans that restart get fresh pids and are re-notified.
#
# Configuration (env vars):
#   VIRT_VM_RSS_GB_MIN   default 2   Flag orphans whose RSS >= this many GB
#   NOTIFICATION_EMAIL   optional    If set, also mail a summary via send-notification.sh
#
# Logs:
#   /tmp/virt-vm-orphan-watch.log     detections and housekeeping
#   /tmp/virt-vm-orphan-watch.seen    state file — pids already notified

set -euo pipefail

THRESHOLD_GB="${VIRT_VM_RSS_GB_MIN:-2}"
EMAIL="${NOTIFICATION_EMAIL:-}"
LOG=/tmp/virt-vm-orphan-watch.log
STATE=/tmp/virt-vm-orphan-watch.seen
SEND_NOTIFICATION="${HOME}/.local/bin/send-notification.sh"

log() {
    printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "$*" >> "$LOG"
}

# macOS `ps -o rss` reports KiB; convert GB threshold to KiB for integer compare
threshold_kb=$(( THRESHOLD_GB * 1024 * 1024 ))

touch "$STATE"

# Enumerate candidate VM processes. Match loosely on `Virtualization.Virtual`
# to cover both `com.apple.Virtualization.VirtualMachine` and any future
# Apple-framework VM process name. Filter PPID=1 AND rss >= threshold in awk.
# `|| true` guards a potentially-empty pipeline under `pipefail`.
candidates=$(/bin/ps -axo pid,ppid,rss,command 2>/dev/null \
    | /usr/bin/awk -v min="$threshold_kb" '
        /Virtualization\.Virtual/ && $2 == 1 && $3 >= min {
            printf "%s %s %s", $1, $2, $3
            for (i=4; i<=NF; i++) printf " %s", $i
            printf "\n"
        }' || true)

if [[ -z "$candidates" ]]; then
    # Housekeeping: prune dead pids from state so it can't grow unbounded
    if [[ -s "$STATE" ]]; then
        alive=""
        while IFS= read -r pid; do
            [[ -n "$pid" ]] && /bin/kill -0 "$pid" 2>/dev/null \
                && alive="${alive}${pid}"$'\n'
        done < "$STATE"
        printf '%s' "$alive" > "$STATE"
    fi
    exit 0
fi

# For each candidate, notify only if pid not in seen-state.
new_lines=""
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    pid=$(printf '%s\n' "$line" | /usr/bin/awk '{print $1}')
    if ! /usr/bin/grep -qxF "$pid" "$STATE" 2>/dev/null; then
        new_lines="${new_lines}${line}"$'\n'
        printf '%s\n' "$pid" >> "$STATE"
    fi
done <<< "$candidates"

if [[ -z "$new_lines" ]]; then
    exit 0
fi

# Per-orphan human-readable detail lines — reused for log, email body, alert.
detail=$(printf '%s' "$new_lines" | /usr/bin/awk '
    NF >= 4 {
        pid=$1; rss_kb=$3
        gb = rss_kb / 1024 / 1024
        cmd=""
        for (i=4; i<=NF; i++) cmd = cmd (i==4?"":" ") $i
        printf "  pid=%s rss=%.1fGB cmd=%s\n", pid, gb, cmd
    }')

log "ORPHAN VM detected (threshold=${THRESHOLD_GB}GB):"
printf '%s' "$detail" >> "$LOG"

count=$(printf '%s' "$new_lines" | /usr/bin/awk 'NF {c++} END {print c+0}')
first_pid=$(printf '%s\n' "$new_lines" | /usr/bin/awk 'NF {print $1; exit}')
first_gb=$(printf '%s\n' "$new_lines" | /usr/bin/awk 'NF {printf "%.1f", $3/1024/1024; exit}')
host="$(hostname 2>/dev/null || echo unknown)"

# --- macOS modal alert (display alert ... as critical) ---
# Backgrounded so the LaunchAgent tick doesn't block on a lingering modal.
# `as critical` renders with the red caution icon; `giving up after 300`
# auto-dismisses after 5 minutes so old alerts can't pile up across ticks.
alert_title="Orphan VM detected"
alert_msg="${count} Virtualization.framework VM(s) with PPID=1

pid ${first_pid} ~${first_gb}GB RSS

See /tmp/virt-vm-orphan-watch.log"

/usr/bin/osascript \
    -e "display alert \"${alert_title}\" message \"${alert_msg}\" as critical giving up after 300" \
    >/dev/null 2>&1 &

# --- Email summary via send-notification.sh (if configured) ---
if [[ -n "$EMAIL" && -x "$SEND_NOTIFICATION" ]]; then
    subject="[${host}] Orphan VM detected — ${count} process(es)"
    body="Orphaned Apple Virtualization.framework VM process(es) detected (PPID=1, RSS >= ${THRESHOLD_GB}GB).
Most common source: Claude Desktop sandbox VM left behind after a Claude.app crash.

This script is NOTIFY-ONLY — no processes were killed.

DETECTIONS:
${detail}
To reclaim RAM manually:
  sudo kill <pid>

Full log: ${LOG}
"
    "$SEND_NOTIFICATION" "$EMAIL" "$subject" "$body" "$LOG" >> "$LOG" 2>&1 \
        || log "email notification failed (recipient=${EMAIL})"
elif [[ -n "$EMAIL" ]]; then
    log "NOTIFICATION_EMAIL set but send-notification.sh not found at ${SEND_NOTIFICATION}"
fi
