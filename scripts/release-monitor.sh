#!/usr/bin/env bash
# ABOUTME: Main orchestration script for weekly release monitoring
# ABOUTME: Coordinates fetch, analyze, issue creation, and email steps (Story 06.6-004)

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${HOME}/.local/log"
LOG_FILE="${LOG_DIR}/release-monitor.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NOTIFICATION_EMAIL="${NOTIFICATION_EMAIL:-}"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

# Send error notification
send_error_notification() {
    local subject="$1"
    local body="$2"

    if [[ -z "${NOTIFICATION_EMAIL}" ]]; then
        log "WARNING: No NOTIFICATION_EMAIL set, cannot send error notification"
        return 0
    fi

    if ! command -v msmtp &>/dev/null; then
        log "WARNING: msmtp not available, cannot send email"
        return 0
    fi

    # Try to send email
    echo -e "Subject: ${subject}\nFrom: release-monitor <${NOTIFICATION_EMAIL}>\nTo: ${NOTIFICATION_EMAIL}\n\n${body}" | \
        msmtp "${NOTIFICATION_EMAIL}" 2>/dev/null || {
            log "WARNING: Failed to send error notification"
        }
}

# Banner
print_banner() {
    log ""
    log "╔════════════════════════════════════════════════════════╗"
    log "║           RELEASE MONITOR - Weekly Check               ║"
    log "╚════════════════════════════════════════════════════════╝"
    log ""
}

# Main execution
main() {
    local start_time
    start_time=$(date +%s)

    print_banner
    log "=== Release Monitor Starting ==="
    log "Timestamp: ${TIMESTAMP}"
    log "Host: $(hostname)"

    # Working files
    local release_file="/tmp/release-notes-${TIMESTAMP}.json"
    local analysis_file="/tmp/analysis-results-${TIMESTAMP}.json"
    local issues_file="/tmp/created-issues-${TIMESTAMP}.json"

    # Step 1: Fetch release notes
    log ""
    log "Step 1/4: Fetching release notes..."
    log "─────────────────────────────────────"

    if ! "${SCRIPT_DIR}/fetch-release-notes.sh" "${release_file}" >> "${LOG_FILE}" 2>&1; then
        log "ERROR: Failed to fetch release notes"
        send_error_notification \
            "[ALERT] Release Monitor: Fetch failed" \
            "Release note fetching failed on $(hostname).\n\nCheck ${LOG_FILE} for details."
        exit 1
    fi

    if [[ ! -s "${release_file}" ]]; then
        log "ERROR: Release notes file is empty"
        send_error_notification \
            "[ALERT] Release Monitor: Empty release notes" \
            "Release notes file is empty on $(hostname).\n\nCheck ${LOG_FILE} for details."
        exit 1
    fi

    log "Release notes saved to ${release_file}"

    # Step 2: Analyze with Claude
    log ""
    log "Step 2/4: Analyzing with Claude CLI..."
    log "─────────────────────────────────────────"

    if ! "${SCRIPT_DIR}/analyze-releases.sh" "${release_file}" "${analysis_file}" >> "${LOG_FILE}" 2>&1; then
        log "WARNING: Claude analysis failed, continuing with fallback"
        # analyze-releases.sh creates a fallback result, so we continue
    fi

    log "Analysis results saved to ${analysis_file}"

    # Check if analysis had an error
    local analysis_error
    analysis_error=$(jq -r '.error // empty' "${analysis_file}" 2>/dev/null || echo "")
    if [[ -n "${analysis_error}" ]]; then
        log "WARNING: Analysis returned error: ${analysis_error}"
    fi

    # Step 3: Create GitHub issues
    log ""
    log "Step 3/4: Creating GitHub issues..."
    log "────────────────────────────────────────"

    if ! "${SCRIPT_DIR}/create-release-issues.sh" "${analysis_file}" "${issues_file}" >> "${LOG_FILE}" 2>&1; then
        log "WARNING: Issue creation failed, continuing"
    fi

    local issues_count
    issues_count=$(jq 'length' "${issues_file}" 2>/dev/null || echo "0")
    log "Created ${issues_count} GitHub issue(s)"

    # Step 4: Send email summary
    log ""
    log "Step 4/4: Sending email summary..."
    log "──────────────────────────────────────"

    if ! "${SCRIPT_DIR}/send-release-summary.sh" "${analysis_file}" "${issues_file}" >> "${LOG_FILE}" 2>&1; then
        log "WARNING: Email summary failed"
    fi

    # Calculate duration
    local end_time duration_seconds
    end_time=$(date +%s)
    duration_seconds=$((end_time - start_time))

    log ""
    log "═══════════════════════════════════════════════════════"
    log "  Release Monitor Complete!"
    log "  Duration: ${duration_seconds} seconds"
    log "  Issues created: ${issues_count}"
    log "  Log: ${LOG_FILE}"
    log "═══════════════════════════════════════════════════════"

    # Cleanup old files (keep last 4 weeks)
    log ""
    log "Cleaning up old files..."
    find /tmp -name "release-notes-*.json" -mtime +28 -delete 2>/dev/null || true
    find /tmp -name "analysis-results-*.json" -mtime +28 -delete 2>/dev/null || true
    find /tmp -name "created-issues-*.json" -mtime +28 -delete 2>/dev/null || true

    log "Release monitor completed successfully"
}

# Run main
main "$@"
