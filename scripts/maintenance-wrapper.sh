#!/usr/bin/env bash
# ABOUTME: Wrapper script for maintenance jobs with error notification (Story 06.5-002)
# ABOUTME: Executes job and sends email notification only on failure

set -euo pipefail

# =============================================================================
# USAGE
# =============================================================================
# maintenance-wrapper.sh <job_name> <command>
#
# Arguments:
#   job_name  - Name of the maintenance job (used in logs and notifications)
#   command   - Command to execute (quoted if contains spaces)
#
# Environment:
#   NOTIFICATION_EMAIL - Email address to send failure notifications to (optional)
#                        If not set, no notifications are sent
#   SCRIPTS_DIR        - Directory containing send-notification.sh (optional)
#                        Defaults to ~/Documents/nix-install/scripts

# =============================================================================
# CONFIGURATION
# =============================================================================

JOB_NAME="${1:-maintenance}"
COMMAND="${2:-echo 'No command specified'}"
RECIPIENT="${NOTIFICATION_EMAIL:-}"

# Script directories
SCRIPTS_DIR="${SCRIPTS_DIR:-${HOME}/Documents/nix-install/scripts}"
SEND_NOTIFICATION="${SCRIPTS_DIR}/send-notification.sh"

# Log files
LOG_DIR="/tmp"
LOG_FILE="${LOG_DIR}/${JOB_NAME}.log"
ERR_FILE="${LOG_DIR}/${JOB_NAME}.err"

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Log start
echo "=== ${JOB_NAME} ===" >> "${LOG_FILE}"
echo "Started at: $(date '+%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"
echo "Command: ${COMMAND}" >> "${LOG_FILE}"
echo "" >> "${LOG_FILE}"

# Execute the command
EXIT_CODE=0
if ! eval "${COMMAND}" >> "${LOG_FILE}" 2>> "${ERR_FILE}"; then
    EXIT_CODE=$?
fi

# Log completion
echo "" >> "${LOG_FILE}"
echo "Completed at: $(date '+%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"
echo "Exit code: ${EXIT_CODE}" >> "${LOG_FILE}"
echo "---" >> "${LOG_FILE}"

# Handle failure
if [[ ${EXIT_CODE} -ne 0 ]]; then
    echo "Job ${JOB_NAME} failed with exit code ${EXIT_CODE}" >> "${LOG_FILE}"

    # Send notification if recipient is configured
    if [[ -n "${RECIPIENT}" ]]; then
        if [[ -x "${SEND_NOTIFICATION}" ]]; then
            BODY="Maintenance job '${JOB_NAME}' failed with exit code ${EXIT_CODE}.

Command: ${COMMAND}

Please check the logs at:
  ${LOG_FILE}
  ${ERR_FILE}"

            "${SEND_NOTIFICATION}" \
                "${RECIPIENT}" \
                "[ALERT] ${JOB_NAME} failed on $(hostname)" \
                "${BODY}" \
                "${ERR_FILE}" || echo "Warning: Failed to send notification"
        else
            echo "Warning: send-notification.sh not found at ${SEND_NOTIFICATION}" >> "${LOG_FILE}"
        fi
    fi

    exit ${EXIT_CODE}
fi

# Success - no notification (issues only)
echo "✓ ${JOB_NAME} completed successfully" >> "${LOG_FILE}"
exit 0
