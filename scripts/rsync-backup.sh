#!/usr/bin/env bash
# ABOUTME: Multi-job rsync backup script for TerraMaster NAS
# ABOUTME: Reads job configuration from ~/.config/rsync-backup/jobs.conf
# ABOUTME: Supports rsync daemon (fast) or SMB mount (fallback) modes
# ABOUTME: Supports multiple source/destination pairs with per-job shares and excludes

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Script version
RSYNC_BACKUP_VERSION="3.0.0"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Paths - CONFIG_FILE can be overridden by environment variable
CONFIG_FILE="${CONFIG_FILE:-${HOME}/.config/rsync-backup/jobs.conf}"
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

# Track mounted shares
declare -A MOUNTED_SHARES

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

    # Source the config file (defines NAS_HOST, DEFAULT_SHARE, JOBS, etc.)
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

    # First try ping
    if ping -c 1 -W 5 "${NAS_HOST}" &>/dev/null; then
        print_status "ok" "NAS ${NAS_HOST} is reachable (ping)"
        return 0
    fi

    # If ping fails, try SMB connection test (NAS might block ICMP)
    print_status "info" "Ping failed, trying SMB connection..."
    if nc -z -w 5 "${NAS_HOST}" 445 &>/dev/null; then
        print_status "ok" "NAS ${NAS_HOST} is reachable (SMB port 445)"
        return 0
    fi

    print_status "error" "NAS ${NAS_HOST} is not reachable"
    return 1
}

# Mount a specific NAS share
# Returns 0 if mounted (or already mounted), 1 on failure
mount_share() {
    local share_name="$1"
    local mount_point="/Volumes/${share_name}"

    # Check if already mounted (track in our array)
    if [[ "${MOUNTED_SHARES[$share_name]:-}" == "1" ]]; then
        return 0
    fi

    # Check if already mounted on system
    if mount | grep -q "on ${mount_point} "; then
        print_status "ok" "Share '${share_name}' already mounted at ${mount_point}"
        MOUNTED_SHARES[$share_name]="1"
        return 0
    fi

    print_status "info" "Mounting NAS share '${share_name}'..."

    # Create mount point if needed
    if [[ ! -d "${mount_point}" ]]; then
        mkdir -p "${mount_point}" 2>/dev/null || {
            print_status "warn" "Cannot create mount point ${mount_point}"
            print_status "info" "Please mount manually: Cmd+K → smb://${NAS_HOST}/${share_name}"
            return 1
        }
    fi

    # Try to mount using stored Keychain credentials
    if mount_smbfs -N "//${SMB_USERNAME:-${USER}}@${NAS_HOST}/${share_name}" "${mount_point}" 2>/dev/null; then
        print_status "ok" "Share '${share_name}' mounted at ${mount_point}"
        MOUNTED_SHARES[$share_name]="1"
        return 0
    else
        print_status "warn" "Auto-mount failed for '${share_name}'. Please mount manually."
        print_status "info" "Manual mount: Finder → Cmd+K → smb://${NAS_HOST}/${share_name}"
        return 1
    fi
}

# =============================================================================
# PHOTO EXPORT (osxphotos)
# =============================================================================

export_photos() {
    print_header "Photo Export (osxphotos)"

    if [[ ! -x "${OSXPHOTOS_CMD}" ]]; then
        print_status "error" "osxphotos not found at ${OSXPHOTOS_CMD}"
        print_status "info" "Run 'rebuild' to install osxphotos"
        return 1
    fi

    mkdir -p "${PHOTOS_EXPORT_DIR}"

    print_status "info" "Exporting to: ${PHOTOS_EXPORT_DIR}"
    print_status "info" "Organization: year/month folders"
    print_status "info" "This may take a while on first run..."

    local export_start
    export_start=$(date +%s)

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

    # Parse job spec: name|source|share|destination|excludes
    IFS='|' read -r job_name source_path share_name dest_path excludes_csv <<< "${job_spec}"

    print_header "Backup Job: ${job_name}"
    print_status "info" "Source: ~/${source_path}"
    print_status "info" "Module: ${share_name}"

    local source_full="${HOME}/${source_path}"
    local dest_full=""

    # Validate source exists
    if [[ ! -e "${source_full}" ]]; then
        print_status "error" "Source does not exist: ${source_full}"
        return 1
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

    # Determine rsync mode and build destination
    local rsync_args=()
    local password_args=()

    if [[ "${USE_RSYNC_DAEMON:-false}" == "true" ]]; then
        # RSYNC DAEMON MODE (fast - native rsync protocol)
        dest_full="rsync://${RSYNC_USERNAME}@${NAS_HOST}/${share_name}/"
        [[ -n "${dest_path}" ]] && dest_full="rsync://${RSYNC_USERNAME}@${NAS_HOST}/${share_name}/${dest_path}/"
        print_status "info" "Mode: rsync daemon (fast)"
        print_status "info" "Destination: ${dest_full}"

        # Password file for authentication
        local password_file="${RSYNC_PASSWORD_FILE:-}"
        password_file="${password_file/#\~/$HOME}"  # Expand tilde
        if [[ -n "${password_file}" ]] && [[ -f "${password_file}" ]]; then
            password_args=(--password-file="${password_file}")
        else
            print_status "error" "Password file not found: ${password_file}"
            print_status "info" "Create it with: echo 'your_password' > ~/.config/rsync-backup/rsync.secret && chmod 600 ~/.config/rsync-backup/rsync.secret"
            return 1
        fi

        # Optimized flags for rsync daemon on LAN
        # -a: archive mode (preserves permissions, timestamps, etc.)
        # -v: verbose
        # --progress: show progress
        # --whole-file: skip delta algorithm (faster on LAN)
        # --partial: keep partial files for resume
        # NO -z: compression wastes CPU on fast LAN
        # NO --delete: archive mode keeps deleted files on NAS
        rsync_args=(-av --progress --whole-file --partial)
    else
        # SMB MOUNT MODE (fallback - slower but simpler)
        print_status "info" "Mode: SMB mount (fallback)"
        print_status "info" "Destination: /Volumes/${share_name}/${dest_path}"

        # Mount the share for this job
        if ! mount_share "${share_name}"; then
            print_status "error" "Cannot mount share '${share_name}' for job '${job_name}'"
            return 1
        fi

        dest_full="/Volumes/${share_name}"
        [[ -n "${dest_path}" ]] && dest_full="${dest_full}/${dest_path}"

        # Create destination directory if needed
        if [[ -n "${dest_path}" ]] && [[ ! -d "${dest_full}" ]]; then
            mkdir -p "${dest_full}" 2>/dev/null || {
                print_status "error" "Cannot create destination directory: ${dest_full}"
                return 1
            }
        fi

        # Optimized flags for SMB mount on LAN
        # --whole-file: delta algorithm over SMB is very slow
        # --inplace: reduce disk I/O
        rsync_args=(-av --progress --whole-file --partial --inplace)
        dest_full="${dest_full}/"
    fi

    # Run rsync with retry logic
    local max_retries="${RSYNC_MAX_RETRIES:-10}"
    local retry_delay="${RSYNC_RETRY_DELAY:-30}"
    local attempt=1
    local rsync_start
    local rsync_end
    local duration

    rsync_start=$(date +%s)

    while [[ ${attempt} -le ${max_retries} ]]; do
        if [[ ${attempt} -gt 1 ]]; then
            print_status "warn" "Retry attempt ${attempt}/${max_retries} (waiting ${retry_delay}s)..."
            sleep "${retry_delay}"
        else
            print_status "info" "Starting rsync..."
        fi

        if rsync "${rsync_args[@]}" "${password_args[@]}" "${exclude_args[@]}" "${source_full}/" "${dest_full}" 2>&1 | tee -a "${LOG_FILE}"; then
            rsync_end=$(date +%s)
            duration=$((rsync_end - rsync_start))
            print_status "ok" "Backup completed in ${duration}s"
            [[ ${attempt} -gt 1 ]] && print_status "info" "Succeeded on attempt ${attempt}"
            return 0
        else
            print_status "error" "rsync failed (attempt ${attempt}/${max_retries})"
            ((attempt++))
        fi
    done

    rsync_end=$(date +%s)
    duration=$((rsync_end - rsync_start))
    print_status "error" "Backup failed for ${job_name} after ${max_retries} attempts (${duration}s)"
    return 1
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
