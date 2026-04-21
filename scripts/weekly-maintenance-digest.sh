#!/usr/bin/env bash
# ABOUTME: Weekly maintenance digest generator and sender (Story 06.5-003)
# ABOUTME: Aggregates maintenance logs and sends summary email every Sunday

set -euo pipefail

# =============================================================================
# USAGE
# =============================================================================
# weekly-maintenance-digest.sh [recipient]
#
# Arguments:
#   recipient  - Email address to send digest to (optional)
#                Falls back to NOTIFICATION_EMAIL environment variable
#
# Environment:
#   NOTIFICATION_EMAIL - Default email if recipient not provided

# =============================================================================
# CONFIGURATION
# =============================================================================

RECIPIENT="${1:-${NOTIFICATION_EMAIL:-}}"

# Get system info
HOSTNAME=$(hostname)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
WEEK_START=$(date -v-7d "+%Y-%m-%d")
WEEK_END=$(date "+%Y-%m-%d")

# Log files
LOG_DIR="/tmp"
GC_LOG="${LOG_DIR}/nix-gc.log"
OPT_LOG="${LOG_DIR}/nix-optimize.log"

# Disk growth telemetry (Story 08.1-008)
# Rolling 12-week history of per-consumer sizes, persisted between runs so the
# digest can surface week-over-week deltas and flag silent growth.
HISTORY_DIR="${HOME}/.local/share/nix-install"
HISTORY_FILE="${HISTORY_DIR}/disk-history.json"
HISTORY_MAX_SAMPLES=12
GROWTH_WARN_GB=1  # Flag consumers growing more than this GB/week

# =============================================================================
# VALIDATION
# =============================================================================

# Check for msmtp
if ! command -v msmtp &> /dev/null; then
    echo "Error: msmtp not found. Install via darwin-rebuild switch." >&2
    exit 1
fi

# jq is used for history file maintenance (08.1-008).
# If missing, growth telemetry degrades gracefully (skipped with a log line);
# the rest of the digest still sends.
HAS_JQ=0
if command -v jq &> /dev/null; then
    HAS_JQ=1
fi

# Validate recipient
if [[ -z "${RECIPIENT}" ]]; then
    echo "Error: Recipient email required" >&2
    echo "Usage: weekly-maintenance-digest.sh <recipient>" >&2
    echo "Or set NOTIFICATION_EMAIL environment variable" >&2
    exit 1
fi

# =============================================================================
# DISK GROWTH TELEMETRY (Story 08.1-008)
# =============================================================================
# Captures per-consumer sizes, persists to rolling history, renders week-over-week
# deltas in the digest body. All helpers are no-ops if jq is unavailable.

# Return kb size of a directory or 0 if absent/inaccessible.
# du -sk is slow on hard-link-dense dirs (notably /nix/store) but only
# runs once a week — acceptable.
du_kb() {
    local path="$1"
    if [[ -d "${path}" ]]; then
        du -sk "${path}" 2>/dev/null | cut -f1 || echo 0
    else
        echo 0
    fi
}

# Collect current sizes into a newline-separated "name\tkb" report.
# Consumer list tracks the biggest Epic-08 offenders identified at baseline.
collect_disk_sizes() {
    printf '%s\t%s\n' "nix_store"    "$(du_kb /nix/store)"
    printf '%s\t%s\n' "ollama"       "$(du_kb "${HOME}/.ollama")"
    printf '%s\t%s\n' "huggingface"  "$(du_kb "${HOME}/.cache/huggingface")"
    printf '%s\t%s\n' "docker"       "$(du_kb "${HOME}/Library/Containers/com.docker.docker")"
    printf '%s\t%s\n' "library_caches" "$(du_kb "${HOME}/Library/Caches")"
    printf '%s\t%s\n' "claude"       "$(du_kb "${HOME}/.claude")"
}

# Append the current sample to the rolling history, trimming to MAX_SAMPLES.
# Returns 0 on success, 1 if jq missing.
persist_history() {
    [[ ${HAS_JQ} -eq 0 ]] && return 1

    mkdir -p "${HISTORY_DIR}"
    local now
    now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

    # Build the sample object from the collected sizes
    local sample
    sample=$(collect_disk_sizes | jq -Rcn --arg ts "${now}" '
        {
            ts: $ts,
            sizes_kb: (
                [inputs | split("\t") | {(.[0]): (.[1]|tonumber)}]
                | add
            )
        }
    ')

    # Initialize history file if absent
    if [[ ! -f "${HISTORY_FILE}" ]]; then
        echo '{"samples": []}' > "${HISTORY_FILE}"
    fi

    # Append + trim to rolling window
    local tmp="${HISTORY_FILE}.tmp"
    jq --argjson new "${sample}" --argjson max "${HISTORY_MAX_SAMPLES}" '
        .samples = ((.samples // []) + [$new] | .[-$max:])
    ' "${HISTORY_FILE}" > "${tmp}" && mv "${tmp}" "${HISTORY_FILE}"
}

# Format bytes (as kb) to human-readable GB/MB string.
fmt_size_kb() {
    local kb=$1
    if [[ ${kb} -ge 1048576 ]]; then
        awk -v k="${kb}" 'BEGIN { printf "%.1fG", k/1024/1024 }'
    elif [[ ${kb} -ge 1024 ]]; then
        awk -v k="${kb}" 'BEGIN { printf "%dM", k/1024 }'
    else
        echo "${kb}K"
    fi
}

# Render the growth-telemetry section of the digest.
# Reads current+previous samples from HISTORY_FILE, computes deltas,
# flags >GROWTH_WARN_GB growth per consumer.
render_growth_section() {
    if [[ ${HAS_JQ} -eq 0 ]]; then
        echo "Disk growth telemetry skipped (jq not available)."
        return 0
    fi
    if [[ ! -f "${HISTORY_FILE}" ]]; then
        echo "Disk growth telemetry: baseline sample captured this run."
        return 0
    fi

    local n_samples
    n_samples=$(jq '.samples | length' "${HISTORY_FILE}" 2>/dev/null || echo 0)

    if [[ "${n_samples}" -lt 2 ]]; then
        echo "Disk growth telemetry: baseline sample captured — deltas available next week."
        return 0
    fi

    # Pull latest two samples for delta
    local prev_sample curr_sample
    prev_sample=$(jq -r '.samples[-2].sizes_kb | to_entries | map("\(.key)=\(.value)") | join(" ")' "${HISTORY_FILE}")
    curr_sample=$(jq -r '.samples[-1].sizes_kb | to_entries | map("\(.key)=\(.value)") | join(" ")' "${HISTORY_FILE}")

    printf 'Disk Consumers — Week over Week\n'
    printf '%-18s %12s %12s %12s\n' "consumer" "previous" "current" "Δ"

    local warn_gb_kb=$((GROWTH_WARN_GB * 1024 * 1024))
    local flagged=0

    # Iterate over keys from the current sample
    while read -r name; do
        local prev_kb curr_kb delta_kb
        prev_kb=$(echo "${prev_sample}" | tr ' ' '\n' | grep "^${name}=" | cut -d= -f2 || echo 0)
        curr_kb=$(echo "${curr_sample}" | tr ' ' '\n' | grep "^${name}=" | cut -d= -f2 || echo 0)
        delta_kb=$((curr_kb - prev_kb))

        local flag=""
        if [[ ${delta_kb} -gt ${warn_gb_kb} ]]; then
            flag="  ⚠"
            flagged=$((flagged + 1))
        fi

        local delta_fmt
        if [[ ${delta_kb} -ge 0 ]]; then
            delta_fmt="+$(fmt_size_kb ${delta_kb})"
        else
            # fmt_size_kb wants positive; format absolute then prefix
            delta_fmt="-$(fmt_size_kb $(( -delta_kb )) )"
        fi

        printf '%-18s %12s %12s %12s%s\n' \
            "${name}" \
            "$(fmt_size_kb ${prev_kb})" \
            "$(fmt_size_kb ${curr_kb})" \
            "${delta_fmt}" \
            "${flag}"
    done < <(jq -r '.samples[-1].sizes_kb | keys[]' "${HISTORY_FILE}")

    if [[ ${flagged} -gt 0 ]]; then
        printf '\n⚠ %d consumer(s) grew more than %dGB this week — consider disk-cleanup or targeted pruning.\n' \
            "${flagged}" "${GROWTH_WARN_GB}"
    fi
}

# =============================================================================
# GATHER METRICS
# =============================================================================

echo "Generating weekly maintenance digest..."

# Capture + persist disk history early (before email render needs it)
persist_history || echo "Note: jq unavailable — skipping disk growth telemetry"
GROWTH_SECTION=$(render_growth_section)

# Count GC runs from log
GC_RUNS=0
if [[ -f "${GC_LOG}" ]]; then
    GC_RUNS=$(grep -c "=== nix-gc ===" "${GC_LOG}" 2>/dev/null || echo "0")
fi

# Count optimization runs from log
OPT_RUNS=0
if [[ -f "${OPT_LOG}" ]]; then
    OPT_RUNS=$(grep -c "=== nix-optimize ===" "${OPT_LOG}" 2>/dev/null || echo "0")
fi

# Get current system state - use fast method (profile symlinks)
GENERATIONS="unknown"
if [[ -d /nix/var/nix/profiles ]]; then
    GENERATIONS=$(ls -1 /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l | tr -d ' ')
fi

# Nix store size
NIX_STORE_SIZE="unknown"
if [[ -d /nix/store ]]; then
    NIX_STORE_SIZE=$(du -sh /nix/store 2>/dev/null | cut -f1 || echo "unknown")
fi

# Disk space
DISK_FREE="unknown"
if [[ -d /nix ]]; then
    DISK_FREE=$(df -h /nix | tail -1 | awk '{print $4}')
fi

# Security status
FILEVAULT_STATUS="Unknown"
if command -v fdesetup &> /dev/null; then
    if fdesetup status 2>/dev/null | grep -q "FileVault is On"; then
        FILEVAULT_STATUS="Enabled ✅"
    else
        FILEVAULT_STATUS="Disabled ⚠️"
    fi
fi

FIREWALL_STATUS="Unknown"
FIREWALL_CMD="/usr/libexec/ApplicationFirewall/socketfilterfw"
if [[ -x "${FIREWALL_CMD}" ]]; then
    if ${FIREWALL_CMD} --getglobalstate 2>/dev/null | grep -q "enabled"; then
        FIREWALL_STATUS="Enabled ✅"
    else
        FIREWALL_STATUS="Disabled ⚠️"
    fi
fi

# =============================================================================
# BUILD RECOMMENDATIONS
# =============================================================================

RECOMMENDATIONS=""

# Check generation count
if [[ "${GENERATIONS}" != "unknown" && ${GENERATIONS} -gt 50 ]]; then
    RECOMMENDATIONS+="
• Consider running 'gc' to clean up old generations (current: ${GENERATIONS})"
fi

# Check disk space (warn if less than 20GB)
if [[ -d /nix ]]; then
    DISK_FREE_KB=$(df -k /nix | tail -1 | awk '{print $4}')
    DISK_FREE_GB=$((DISK_FREE_KB / 1024 / 1024))
    if [[ ${DISK_FREE_GB} -lt 20 ]]; then
        RECOMMENDATIONS+="
• Low disk space on /nix (${DISK_FREE}). Run 'cleanup' to free space."
    fi
fi

# Check security
if [[ "${FILEVAULT_STATUS}" == *"Disabled"* ]]; then
    RECOMMENDATIONS+="
• Enable FileVault for disk encryption (System Settings → Privacy & Security → FileVault)"
fi

if [[ "${FIREWALL_STATUS}" == *"Disabled"* ]]; then
    RECOMMENDATIONS+="
• Enable Firewall for network protection (System Settings → Network → Firewall)"
fi

# Default message if no recommendations
if [[ -z "${RECOMMENDATIONS}" ]]; then
    RECOMMENDATIONS="
• No issues detected. System is healthy! ✅"
fi

# =============================================================================
# BUILD EMAIL
# =============================================================================

DIGEST="Subject: Weekly Maintenance Digest - ${HOSTNAME}

========================================
Weekly Maintenance Digest - ${HOSTNAME}
========================================

Report Period: ${WEEK_START} to ${WEEK_END}
Generated: ${TIMESTAMP}

MAINTENANCE ACTIVITY
--------------------
Garbage Collection Runs: ${GC_RUNS}
Store Optimization Runs: ${OPT_RUNS}

SYSTEM STATE
------------
Nix Store Size: ${NIX_STORE_SIZE}
Disk Free (/nix): ${DISK_FREE}
System Generations: ${GENERATIONS}

DISK GROWTH (12-week rolling window)
------------------------------------
${GROWTH_SECTION}

SECURITY STATUS
---------------
FileVault: ${FILEVAULT_STATUS}
Firewall: ${FIREWALL_STATUS}

RECOMMENDATIONS
---------------${RECOMMENDATIONS}

QUICK COMMANDS
--------------
• gc        - Remove all old generations
• cleanup   - GC + store optimization
• rebuild   - Rebuild system configuration
• health-check - Run system health check

---
Automated weekly digest from nix-install maintenance system
"

# =============================================================================
# SEND EMAIL
# =============================================================================

echo "Sending digest to ${RECIPIENT}..."

if echo "${DIGEST}" | msmtp "${RECIPIENT}"; then
    echo "✅ Weekly digest sent successfully"
    exit 0
else
    echo "❌ Failed to send weekly digest" >&2
    exit 1
fi
