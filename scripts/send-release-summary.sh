#!/usr/bin/env bash
# ABOUTME: Sends email summary of release monitor findings
# ABOUTME: Formats analysis results and created issues for email (Story 06.6-005)

set -euo pipefail

# Configuration
ANALYSIS_FILE="${1:-/tmp/analysis-results.json}"
ISSUES_FILE="${2:-/tmp/created-issues.json}"
NOTIFICATION_EMAIL="${NOTIFICATION_EMAIL:-}"
LOG_DIR="${HOME}/.local/log"
LOG_FILE="${LOG_DIR}/release-monitor.log"
HOSTNAME=$(hostname)

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "${LOG_FILE}"
}

log "=== Sending release summary email ==="

# Check if email is configured
if [[ -z "${NOTIFICATION_EMAIL}" ]]; then
    log "No NOTIFICATION_EMAIL set, skipping email"
    echo "No email configured"
    exit 0
fi

# Check for msmtp
if ! command -v msmtp &>/dev/null; then
    log "msmtp not available, skipping email"
    echo "msmtp not available"
    exit 0
fi

# Extract summary from analysis
get_summary() {
    if [[ -f "${ANALYSIS_FILE}" ]]; then
        jq -r '.summary // "No summary available"' "${ANALYSIS_FILE}" 2>/dev/null || echo "Analysis unavailable"
    else
        echo "Analysis file not found"
    fi
}

# Count items by category
count_category() {
    local category="$1"
    if [[ -f "${ANALYSIS_FILE}" ]]; then
        jq -r ".${category} // [] | length" "${ANALYSIS_FILE}" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Get created issue URLs (max 10)
get_issue_urls() {
    if [[ -f "${ISSUES_FILE}" ]]; then
        jq -r '.[]' "${ISSUES_FILE}" 2>/dev/null | head -10 || echo ""
    else
        echo ""
    fi
}

# Check if there was an analysis error
get_analysis_error() {
    if [[ -f "${ANALYSIS_FILE}" ]]; then
        jq -r '.error // empty' "${ANALYSIS_FILE}" 2>/dev/null || echo ""
    else
        echo "Analysis file not found"
    fi
}

# Build and send email
main() {
    local summary security_count breaking_count features_count models_count notable_count
    local issues analysis_error

    summary=$(get_summary)
    security_count=$(count_category "security_updates")
    breaking_count=$(count_category "breaking_changes")
    features_count=$(count_category "new_features")
    models_count=$(count_category "ollama_models")
    notable_count=$(count_category "notable_updates")
    issues=$(get_issue_urls)
    analysis_error=$(get_analysis_error)

    # Calculate total findings
    local total_findings=$((security_count + breaking_count + features_count + models_count + notable_count))

    # Build next steps section
    local next_steps=""
    if [[ "${security_count}" -gt 0 ]]; then
        next_steps="${next_steps}  - Review security updates immediately\n"
    fi
    if [[ "${breaking_count}" -gt 0 ]]; then
        next_steps="${next_steps}  - Check breaking changes before next rebuild\n"
    fi
    if [[ "${features_count}" -gt 0 ]]; then
        next_steps="${next_steps}  - Consider adopting new features\n"
    fi
    if [[ "${models_count}" -gt 0 ]]; then
        next_steps="${next_steps}  - Try new Ollama models if relevant\n"
    fi
    if [[ -z "${next_steps}" ]]; then
        next_steps="  - No urgent items this week\n"
    fi

    # Build issues section
    local issues_section
    if [[ -n "${issues}" && "${issues}" != "" ]]; then
        issues_section="${issues}"
    else
        issues_section="None created this week"
    fi

    # Build status indicator
    local status_indicator
    if [[ -n "${analysis_error}" ]]; then
        status_indicator="WARNING: ${analysis_error}"
    elif [[ "${security_count}" -gt 0 ]]; then
        status_indicator="ATTENTION REQUIRED: Security updates found"
    elif [[ "${breaking_count}" -gt 0 ]]; then
        status_indicator="ACTION NEEDED: Breaking changes detected"
    elif [[ "${total_findings}" -gt 0 ]]; then
        status_indicator="INFORMATIONAL: ${total_findings} notable updates"
    else
        status_indicator="ALL CLEAR: No significant updates this week"
    fi

    # Send email
    cat << EOF | msmtp "${NOTIFICATION_EMAIL}"
Subject: Weekly Release Monitor - ${HOSTNAME}
From: release-monitor <${NOTIFICATION_EMAIL}>
To: ${NOTIFICATION_EMAIL}
Content-Type: text/plain; charset=UTF-8

=======================================================
        WEEKLY RELEASE MONITOR REPORT
=======================================================
Generated: $(date)
Host: ${HOSTNAME}

STATUS: ${status_indicator}

-------------------------------------------------------
EXECUTIVE SUMMARY
-------------------------------------------------------
${summary}

-------------------------------------------------------
FINDINGS BREAKDOWN
-------------------------------------------------------
  Security Updates:   ${security_count}
  Breaking Changes:   ${breaking_count}
  New Features:       ${features_count}
  Ollama Models:      ${models_count}
  Notable Updates:    ${notable_count}
  -----------------------
  Total Findings:     ${total_findings}

-------------------------------------------------------
GITHUB ISSUES CREATED
-------------------------------------------------------
${issues_section}

-------------------------------------------------------
NEXT STEPS
-------------------------------------------------------
$(echo -e "${next_steps}")
-------------------------------------------------------
USEFUL COMMANDS
-------------------------------------------------------
  Manual check:    release-monitor
  View log:        cat ~/.local/log/release-monitor.log
  Update system:   update

=======================================================
Automated report from nix-install release-monitor
https://github.com/fxmartin/nix-install
=======================================================
EOF

    log "Email sent successfully to ${NOTIFICATION_EMAIL}"
    echo "Email sent to ${NOTIFICATION_EMAIL}"
}

main "$@"
