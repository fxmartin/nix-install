#!/usr/bin/env bash
# ABOUTME: Multi-job rsync backup script for TerraMaster NAS
# ABOUTME: Reads job configuration from ~/.config/rsync-backup/jobs.conf
# ABOUTME: Supports multiple source/destination pairs with per-job excludes

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Script version
RSYNC_BACKUP_VERSION="2.0.0"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Paths
CONFIG_FILE="${HOME}/.config/rsync-backup/jobs.conf"
LOG_FILE="/tmp/rsync-backup.log"
SCRIPTS_DIR="${SCRIPTS_DIR:-$(dirname "$0")}"
SEND_NOTIFICATION="${SCRIPTS_DIR}/send-notification.sh"

# Report buffer for email
REPORT_BUFFER=""

# Track job results
TOTAL_JOBS=0
SUCCESSFUL_JOBS=0
FAILED_JOBS=0
FAILED_JOB_NAMES=""

# Photo export settings
PHOTOS_EXPORT_DIR="${HOME}/Pictures/Photos-Export"
OSXPHOTOS_CMD="${HOME}/.local/bin/osxphotos"

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Append to report buffer (for email)
report() {
    REPORT_BUFFER+="$1"$'\n'
}

log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] $1" | tee -a "${LOG_FILE}"
    report "[${timestamp}] $1"
}

print_header() {
    echo ""
    echo -e "${BOLD}=== $1 ===${NC}"
    log "=== $1 ==="
}

print_status() {
    local status="$1"
    local message="$2"
    case "${status}" in
        ok)      echo -e "${GREEN}✓${NC} ${message}"; log "✓ ${message}" ;;
        error)   echo -e "${RED}✗${NC} ${message}"; log "✗ ${message}" ;;
        warn)    echo -e "${YELLOW}⚠${NC} ${message}"; log "⚠ ${message}" ;;
        info)    echo -e "${BLUE}ℹ${NC} ${message}"; log "• ${message}" ;;
        skip)    echo -e "${YELLOW}⊘${NC} ${message}"; log "⊘ ${message}" ;;
        *)       echo -e "${message}"; log "${message}" ;;
    esac
}

# =============================================================================
# CONFIGURATION LOADING
# =============================================================================

load_config() {
    if [[ ! -f "${CONFIG_FILE}" ]]; then
        print_status "error" "Config file not found: ${CONFIG_FILE}"
        print_status "info" "Run 'rebuild' to generate the config from rsync-backup-config.nix"
        exit 1
    fi

    # Source the config file (defines NAS_HOST, NAS_SHARE, JOBS, etc.)
    # shellcheck source=/dev/null
    # shellcheck disable=SC2034  # Variables are used after sourcing
    source "${CONFIG_FILE}"
    # shellcheck disable=SC2154  # JOBS is defined in sourced config file
    declare -p JOBS &>/dev/null || { print_status "error" "JOBS not defined in config"; exit 1; }

    # Validate required variables
    if [[ -z "${NAS_HOST:-}" ]]; then
        print_status "error" "NAS_HOST not defined in config"
        exit 1
    fi

    if [[ -z "${NAS_SHARE:-}" ]]; then
        print_status "error" "NAS_SHARE not defined in config"
        exit 1
    fi

    # shellcheck disable=SC2154  # JOBS is defined in sourced config file
    if [[ ${#JOBS[@]} -eq 0 ]]; then
        print_status "warn" "No backup jobs defined in config"
        exit 0
    fi

    # shellcheck disable=SC2154  # JOBS is defined in sourced config file
    print_status "ok" "Loaded config with ${#JOBS[@]} job(s)"
}

# =============================================================================
# NAS CONNECTION
# =============================================================================

check_nas_reachable() {
    print_header "Checking NAS Connectivity"

    if ping -c 1 -W 5 "${NAS_HOST}" &>/dev/null; then
        print_status "ok" "NAS ${NAS_HOST} is reachable"
        return 0
    else
        print_status "error" "NAS ${NAS_HOST} is not reachable"
        return 1
    fi
}

mount_nas_share() {
    local mount_point="/Volumes/${NAS_SHARE}"

    # Check if already mounted
    if mount | grep -q "${mount_point}"; then
        print_status "ok" "NAS share already mounted at ${mount_point}"
        return 0
    fi

    print_status "info" "Mounting NAS share ${NAS_SHARE}..."

    # Create mount point if needed
    if [[ ! -d "${mount_point}" ]]; then
        mkdir -p "${mount_point}" 2>/dev/null || {
            # May need sudo, but LaunchAgents run as user
            print_status "warn" "Cannot create mount point ${mount_point}"
            print_status "info" "Please mount the share manually: Cmd+K → smb://${NAS_HOST}/${NAS_SHARE}"
            return 1
        }
    fi

    # Try to mount using stored Keychain credentials
    # The -N flag tells mount_smbfs to not prompt for password (use Keychain)
    if mount_smbfs -N "//${SMB_USERNAME:-${USER}}@${NAS_HOST}/${NAS_SHARE}" "${mount_point}" 2>/dev/null; then
        print_status "ok" "NAS share mounted at ${mount_point}"
        return 0
    else
        print_status "warn" "Auto-mount failed. Please mount manually or add credentials to Keychain."
        print_status "info" "Manual mount: Finder → Cmd+K → smb://${NAS_HOST}/${NAS_SHARE}"
        return 1
    fi
}

# =============================================================================
# PHOTO EXPORT (osxphotos)
# =============================================================================

# Export photos from Apple Photos library to plain files
# Organizes by year/month, preserves original filenames, only exports new/changed
export_photos() {
    print_header "Photo Export (osxphotos)"

    # Check if osxphotos is installed
    if [[ ! -x "${OSXPHOTOS_CMD}" ]]; then
        print_status "error" "osxphotos not found at ${OSXPHOTOS_CMD}"
        print_status "info" "Run 'rebuild' to install osxphotos"
        return 1
    fi

    # Create export directory if needed
    mkdir -p "${PHOTOS_EXPORT_DIR}"

    print_status "info" "Exporting to: ${PHOTOS_EXPORT_DIR}"
    print_status "info" "Organization: year/month folders"
    print_status "info" "This may take a while on first run..."

    local export_start
    export_start=$(date +%s)

    # Run osxphotos export
    # --directory: Organize by year/month
    # --filename: Keep original filename
    # --update: Only export new/changed photos
    # --skip-edited: Export originals only (edited versions are larger)
    # --download-missing: Download iCloud photos if needed
    # --retry: Retry failed downloads
    if "${OSXPHOTOS_CMD}" export "${PHOTOS_EXPORT_DIR}" \
        --directory "{created.year}/{created.month:02d}" \
        --filename "{original_name}" \
        --update \
        --skip-edited \
        --download-missing \
        --retry 3 \
        2>&1 | tee -a "${LOG_FILE}"; then
        local export_end
        export_end=$(date +%s)
        local duration=$((export_end - export_start))
        print_status "ok" "Photo export completed in ${duration}s"
        return 0
    else
        print_status "error" "Photo export failed"
        return 1
    fi
}

# =============================================================================
# BACKUP EXECUTION
# =============================================================================

run_backup_job() {
    local job_spec="$1"

    # Parse job spec: name|source|destination|excludes
    IFS='|' read -r job_name source_path dest_path excludes_csv <<< "${job_spec}"

    print_header "Backup Job: ${job_name}"
    print_status "info" "Source: ~/${source_path}"
    print_status "info" "Destination: /Volumes/${NAS_SHARE}/${dest_path}"

    local source_full="${HOME}/${source_path}"
    local dest_full="/Volumes/${NAS_SHARE}/${dest_path}"

    # Validate source exists
    if [[ ! -e "${source_full}" ]]; then
        print_status "error" "Source does not exist: ${source_full}"
        return 1
    fi

    # Create destination parent directory if needed
    local dest_parent
    dest_parent=$(dirname "${dest_full}")
    if [[ ! -d "${dest_parent}" ]]; then
        mkdir -p "${dest_parent}" 2>/dev/null || {
            print_status "error" "Cannot create destination directory: ${dest_parent}"
            return 1
        }
    fi

    # Build exclude arguments
    local exclude_args=()
    if [[ -n "${excludes_csv}" ]]; then
        IFS=',' read -ra exclude_patterns <<< "${excludes_csv}"
        for pattern in "${exclude_patterns[@]}"; do
            exclude_args+=(--exclude="${pattern}")
        done
        print_status "info" "Excludes: ${excludes_csv}"
    fi

    # Run rsync
    # -a: archive mode (preserves permissions, timestamps, etc.)
    # -v: verbose
    # -z: compress during transfer
    # --progress: show progress
    # NO --delete: archive mode keeps deleted files on NAS
    print_status "info" "Starting rsync..."

    local rsync_start
    rsync_start=$(date +%s)

    if rsync -avz --progress "${exclude_args[@]}" "${source_full}/" "${dest_full}/" 2>&1 | tee -a "${LOG_FILE}"; then
        local rsync_end
        rsync_end=$(date +%s)
        local duration=$((rsync_end - rsync_start))
        print_status "ok" "Backup completed in ${duration}s"
        return 0
    else
        print_status "error" "Backup failed for ${job_name}"
        return 1
    fi
}

# =============================================================================
# NOTIFICATION
# =============================================================================

send_failure_notification() {
    local recipient="${NOTIFICATION_EMAIL:-}"

    if [[ -z "${recipient}" ]]; then
        return 0
    fi

    if [[ "${NOTIFY_ON_FAILURE:-false}" != "true" ]]; then
        return 0
    fi

    if [[ ${FAILED_JOBS} -eq 0 ]]; then
        return 0
    fi

    echo ""
    print_status "info" "Sending failure notification to ${recipient}..."

    if [[ -x "${SEND_NOTIFICATION}" ]]; then
        local subject="[rsync-backup] FAILED - $(hostname) - ${FAILED_JOB_NAMES}"
        if "${SEND_NOTIFICATION}" "${recipient}" "${subject}" "${REPORT_BUFFER}"; then
            print_status "ok" "Notification sent"
        else
            print_status "error" "Failed to send notification"
        fi
    else
        print_status "warn" "send-notification.sh not found at ${SEND_NOTIFICATION}"
    fi
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    local hostname_str
    local date_str
    hostname_str=$(hostname)
    date_str=$(date '+%Y-%m-%d %H:%M:%S')

    # Clear/rotate log file if too large (>1MB)
    if [[ -f "${LOG_FILE}" ]] && [[ $(stat -f%z "${LOG_FILE}" 2>/dev/null || echo 0) -gt 1048576 ]]; then
        mv "${LOG_FILE}" "${LOG_FILE}.old"
    fi

    echo ""
    echo -e "${BOLD}rsync Backup Script v${RSYNC_BACKUP_VERSION}${NC}"
    echo "Host: ${hostname_str}"
    echo "Date: ${date_str}"
    echo ""

    # Initialize report
    report "rsync Backup Report v${RSYNC_BACKUP_VERSION}"
    report "Host: ${hostname_str}"
    report "Date: ${date_str}"
    report ""

    # Load configuration
    load_config

    # Check NAS connectivity
    if ! check_nas_reachable; then
        print_status "error" "Cannot reach NAS. Backup aborted."
        FAILED_JOBS=1
        FAILED_JOB_NAMES="NAS unreachable"
        send_failure_notification
        exit 1
    fi

    # Mount NAS share
    if ! mount_nas_share; then
        print_status "error" "Cannot mount NAS share. Backup aborted."
        FAILED_JOBS=1
        FAILED_JOB_NAMES="Mount failed"
        send_failure_notification
        exit 1
    fi

    # Check if any job requires photo export (source contains Photos-Export)
    # shellcheck disable=SC2154  # JOBS is defined in sourced config file
    local needs_photo_export=false
    for job in "${JOBS[@]}"; do
        if [[ "${job}" == *"Photos-Export"* ]]; then
            needs_photo_export=true
            break
        fi
    done

    # Run photo export if needed
    if [[ "${needs_photo_export}" == "true" ]]; then
        if ! export_photos; then
            print_status "warn" "Photo export failed, but continuing with backup..."
            # Don't abort - rsync will just sync what's already there
        fi
    fi

    # Run each backup job
    # shellcheck disable=SC2154  # JOBS is defined in sourced config file
    for job in "${JOBS[@]}"; do
        TOTAL_JOBS=$((TOTAL_JOBS + 1))
        local job_name
        job_name=$(echo "${job}" | cut -d'|' -f1)

        if run_backup_job "${job}"; then
            SUCCESSFUL_JOBS=$((SUCCESSFUL_JOBS + 1))
        else
            FAILED_JOBS=$((FAILED_JOBS + 1))
            if [[ -n "${FAILED_JOB_NAMES}" ]]; then
                FAILED_JOB_NAMES="${FAILED_JOB_NAMES}, ${job_name}"
            else
                FAILED_JOB_NAMES="${job_name}"
            fi
        fi
    done

    # Summary
    print_header "Summary"
    print_status "info" "Total jobs: ${TOTAL_JOBS}"
    print_status "ok" "Successful: ${SUCCESSFUL_JOBS}"
    if [[ ${FAILED_JOBS} -gt 0 ]]; then
        print_status "error" "Failed: ${FAILED_JOBS} (${FAILED_JOB_NAMES})"
    else
        print_status "ok" "Failed: 0"
    fi

    # Send notification on failure
    send_failure_notification

    # Exit with error if any job failed
    if [[ ${FAILED_JOBS} -gt 0 ]]; then
        exit 1
    fi

    echo ""
    print_status "ok" "All backups completed successfully!"
}

main "$@"
