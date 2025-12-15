#!/usr/bin/env bash
# ABOUTME: Multi-job iCloud sync script for work folders
# ABOUTME: Reads job configuration from ~/.config/icloud-sync/config.conf
# ABOUTME: Scheduled via LaunchAgent, configured in darwin/icloud-sync.nix

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

SCRIPT_VERSION="2.0.0"

# Config file location
CONFIG_FILE="${HOME}/.config/icloud-sync/config.conf"

# Logging
LOG_FILE="/tmp/icloud-sync-proposals.log"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Track job results
TOTAL_JOBS=0
SUCCESSFUL_JOBS=0
FAILED_JOBS=0
FAILED_JOB_NAMES=""

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] $1" | tee -a "${LOG_FILE}"
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
        *)       echo -e "${message}"; log "${message}" ;;
    esac
}

# =============================================================================
# CONFIGURATION LOADING
# =============================================================================

load_config() {
    if [[ ! -f "${CONFIG_FILE}" ]]; then
        print_status "error" "Config file not found: ${CONFIG_FILE}"
        print_status "info" "Create config from template:"
        print_status "info" "  mkdir -p ~/.config/icloud-sync"
        print_status "info" "  cp config/icloud-sync-config.conf.template ~/.config/icloud-sync/config.conf"
        print_status "info" "  Edit ~/.config/icloud-sync/config.conf with your paths"
        exit 1
    fi

    # Source the config file
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"

    # Validate JOBS array exists
    # shellcheck disable=SC2154
    if ! declare -p JOBS &>/dev/null; then
        print_status "error" "JOBS array not defined in config"
        exit 1
    fi

    # shellcheck disable=SC2154
    if [[ ${#JOBS[@]} -eq 0 ]]; then
        print_status "warn" "No sync jobs defined in config"
        exit 0
    fi

    # shellcheck disable=SC2154
    print_status "ok" "Loaded config with ${#JOBS[@]} job(s)"
}

# =============================================================================
# SYNC EXECUTION
# =============================================================================

run_sync_job() {
    local job_spec="$1"

    # Parse job spec: name|source|destination|mode
    IFS='|' read -r job_name source_dir dest_dir sync_mode <<< "${job_spec}"

    print_header "Sync Job: ${job_name}"
    print_status "info" "Source: ${source_dir}"
    print_status "info" "Destination: ${dest_dir}"

    # Validate source exists
    if [[ ! -d "${source_dir}" ]]; then
        print_status "error" "Source directory does not exist: ${source_dir}"
        return 1
    fi

    # Create destination directory if needed
    if [[ ! -d "${dest_dir}" ]]; then
        print_status "info" "Creating destination directory..."
        mkdir -p "${dest_dir}"
    fi

    # Build rsync command based on mode
    local rsync_opts=("-avz" "--progress")

    if [[ "${sync_mode}" == "mirror" ]]; then
        rsync_opts+=("--delete")
        print_status "info" "Mode: Mirror (--delete)"
    else
        print_status "info" "Mode: Archive (no delete)"
    fi

    # Run rsync
    print_status "info" "Starting rsync..."

    local sync_start
    sync_start=$(date +%s)

    if rsync "${rsync_opts[@]}" \
        --exclude='.DS_Store' \
        --exclude='~$*.docx' \
        --exclude='~$*.xlsx' \
        --exclude='~$*.pptx' \
        --exclude='*.tmp' \
        --exclude='.~lock.*' \
        "${source_dir}/" "${dest_dir}/" 2>&1 | tee -a "${LOG_FILE}"; then

        local sync_end
        sync_end=$(date +%s)
        local duration=$((sync_end - sync_start))

        print_status "ok" "Sync completed in ${duration}s"
        return 0
    else
        print_status "error" "Sync failed for ${job_name}"
        return 1
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

    # Rotate log file if too large (>1MB)
    if [[ -f "${LOG_FILE}" ]] && [[ $(stat -f%z "${LOG_FILE}" 2>/dev/null || echo 0) -gt 1048576 ]]; then
        mv "${LOG_FILE}" "${LOG_FILE}.old"
    fi

    echo ""
    echo -e "${BOLD}iCloud Sync v${SCRIPT_VERSION}${NC}"
    echo "Host: ${hostname_str}"
    echo "Date: ${date_str}"
    echo ""
    log "=== iCloud Sync Started ==="

    # Load configuration
    load_config

    # Run each sync job
    # shellcheck disable=SC2154
    for job in "${JOBS[@]}"; do
        TOTAL_JOBS=$((TOTAL_JOBS + 1))
        local job_name
        job_name=$(echo "${job}" | cut -d'|' -f1)

        if run_sync_job "${job}"; then
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

    # Exit with error if any job failed
    if [[ ${FAILED_JOBS} -gt 0 ]]; then
        exit 1
    fi

    echo ""
    print_status "ok" "All syncs completed successfully!"
    log "=== iCloud Sync Completed ==="
}

main "$@"
