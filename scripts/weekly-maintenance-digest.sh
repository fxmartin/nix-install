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

# =============================================================================
# VALIDATION
# =============================================================================

# Check for msmtp
if ! command -v msmtp &> /dev/null; then
    echo "Error: msmtp not found. Install via darwin-rebuild switch." >&2
    exit 1
fi

# Validate recipient
if [[ -z "${RECIPIENT}" ]]; then
    echo "Error: Recipient email required" >&2
    echo "Usage: weekly-maintenance-digest.sh <recipient>" >&2
    echo "Or set NOTIFICATION_EMAIL environment variable" >&2
    exit 1
fi

# =============================================================================
# GATHER METRICS
# =============================================================================

echo "Generating weekly maintenance digest..."

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

# Get current system state
GENERATIONS="unknown"
if command -v darwin-rebuild &> /dev/null; then
    GENERATIONS=$(darwin-rebuild --list-generations 2>/dev/null | wc -l | tr -d ' ')
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
