#!/usr/bin/env bash
# ABOUTME: Email notification wrapper for maintenance job failures (Story 06.5-002)
# ABOUTME: Sends email via msmtp when maintenance jobs encounter errors

set -euo pipefail

# =============================================================================
# USAGE
# =============================================================================
# send-notification.sh <recipient> <subject> [body] [log_file]
#
# Arguments:
#   recipient  - Email address to send notification to (required)
#   subject    - Email subject line (required)
#   body       - Email body text (optional)
#   log_file   - Path to log file to append to email (optional)
#
# Environment:
#   MSMTP_CONFIG - Path to msmtp config (optional, uses default if not set)

# =============================================================================
# CONFIGURATION
# =============================================================================

RECIPIENT="${1:-}"
SUBJECT="${2:-Maintenance Notification}"
BODY="${3:-}"
LOG_FILE="${4:-}"

# Get hostname for identification
HOSTNAME=$(hostname)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

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
    echo "Error: Recipient email address required" >&2
    echo "Usage: send-notification.sh <recipient> <subject> [body] [log_file]" >&2
    exit 1
fi

# Basic email format validation
if [[ ! "${RECIPIENT}" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo "Error: Invalid recipient email format: ${RECIPIENT}" >&2
    exit 1
fi

# =============================================================================
# BUILD EMAIL
# =============================================================================

# Start building email content
EMAIL_CONTENT="Subject: ${SUBJECT}

Maintenance Notification from ${HOSTNAME}
==========================================

Time: ${TIMESTAMP}
Host: ${HOSTNAME}

"

# Add body if provided
if [[ -n "${BODY}" ]]; then
    EMAIL_CONTENT+="${BODY}

"
fi

# Add log file contents if provided and exists
if [[ -n "${LOG_FILE}" && -f "${LOG_FILE}" ]]; then
    EMAIL_CONTENT+="--- Log Output (last 100 lines) ---

$(tail -100 "${LOG_FILE}" 2>/dev/null || echo "[Could not read log file]")

"
fi

# Add footer
EMAIL_CONTENT+="---
Automated notification from nix-install maintenance system
"

# =============================================================================
# SEND EMAIL
# =============================================================================

echo "Sending notification to ${RECIPIENT}..."

if echo "${EMAIL_CONTENT}" | msmtp "${RECIPIENT}"; then
    echo "✅ Notification sent successfully"
    exit 0
else
    echo "❌ Failed to send notification" >&2
    exit 1
fi
