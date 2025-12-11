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

# Get issues by category and format for email
# Returns grouped issues in text format
get_grouped_issues() {
    if [[ ! -f "${ISSUES_FILE}" ]]; then
        echo "None created this week"
        return
    fi

    local issues_content
    issues_content=$(jq -r '.' "${ISSUES_FILE}" 2>/dev/null)

    if [[ -z "${issues_content}" || "${issues_content}" == "[]" ]]; then
        echo "None created this week"
        return
    fi

    # Check if new format (array of objects with category) or old format (array of strings)
    local first_item
    first_item=$(echo "${issues_content}" | jq -r '.[0]' 2>/dev/null)

    if [[ "${first_item}" == *"{"* ]]; then
        # New format: array of objects with url, category, tool
        local output=""

        # Security Updates
        local security_issues
        security_issues=$(echo "${issues_content}" | jq -r '.[] | select(.category == "security") | "  \(.tool): \(.url)"' 2>/dev/null)
        if [[ -n "${security_issues}" ]]; then
            output="${output}🔴 Security Updates:\n${security_issues}\n\n"
        fi

        # Breaking Changes
        local breaking_issues
        breaking_issues=$(echo "${issues_content}" | jq -r '.[] | select(.category == "breaking") | "  \(.tool): \(.url)"' 2>/dev/null)
        if [[ -n "${breaking_issues}" ]]; then
            output="${output}🟠 Breaking Changes:\n${breaking_issues}\n\n"
        fi

        # New Features
        local feature_issues
        feature_issues=$(echo "${issues_content}" | jq -r '.[] | select(.category == "feature") | "  \(.tool): \(.url)"' 2>/dev/null)
        if [[ -n "${feature_issues}" ]]; then
            output="${output}🟢 New Features:\n${feature_issues}\n\n"
        fi

        # Ollama Models
        local model_issues
        model_issues=$(echo "${issues_content}" | jq -r '.[] | select(.category == "model") | "  \(.tool): \(.url)"' 2>/dev/null)
        if [[ -n "${model_issues}" ]]; then
            output="${output}🤖 Ollama Models:\n${model_issues}\n\n"
        fi

        # Notable Updates
        local update_issues
        update_issues=$(echo "${issues_content}" | jq -r '.[] | select(.category == "update") | "  \(.tool): \(.url)"' 2>/dev/null)
        if [[ -n "${update_issues}" ]]; then
            output="${output}🔵 Notable Updates:\n${update_issues}\n"
        fi

        if [[ -n "${output}" ]]; then
            echo -e "${output}"
        else
            echo "None created this week"
        fi
    else
        # Old format: array of URL strings - just list them
        echo "${issues_content}" | jq -r '.[]' 2>/dev/null | head -10 || echo "None created this week"
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
    local issues_section analysis_error

    summary=$(get_summary)
    security_count=$(count_category "security_updates")
    breaking_count=$(count_category "breaking_changes")
    features_count=$(count_category "new_features")
    models_count=$(count_category "ollama_models")
    notable_count=$(count_category "notable_updates")
    issues_section=$(get_grouped_issues)
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
