#!/usr/bin/env bash
# ABOUTME: Syncs work proposals to iCloud Drive for backup
# ABOUTME: Reads configuration from ~/.config/icloud-sync/config.conf
# ABOUTME: Scheduled via LaunchAgent, configured in darwin/icloud-sync.nix

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

SCRIPT_VERSION="1.1.0"

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

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] $1" | tee -a "${LOG_FILE}"
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

    # Validate required variables
    if [[ -z "${SOURCE_DIR:-}" ]]; then
        print_status "error" "SOURCE_DIR not defined in config"
        exit 1
    fi

    if [[ -z "${DEST_DIR:-}" ]]; then
        print_status "error" "DEST_DIR not defined in config"
        exit 1
    fi

    # Default sync mode to mirror if not specified
    SYNC_MODE="${SYNC_MODE:-mirror}"

    print_status "ok" "Loaded config from ${CONFIG_FILE}"
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
    echo -e "${BOLD}iCloud Sync - Proposals v${SCRIPT_VERSION}${NC}"
    echo "Host: ${hostname_str}"
    echo "Date: ${date_str}"
    echo ""
    log "=== iCloud Sync Started ==="

    # Load configuration
    load_config

    # Validate source directory exists
    if [[ ! -d "${SOURCE_DIR}" ]]; then
        print_status "error" "Source directory does not exist: ${SOURCE_DIR}"
        exit 1
    fi

    # Create destination directory if needed
    if [[ ! -d "${DEST_DIR}" ]]; then
        print_status "info" "Creating destination directory..."
        mkdir -p "${DEST_DIR}"
    fi

    print_status "info" "Source: ${SOURCE_DIR}"
    print_status "info" "Destination: ${DEST_DIR}"

    # Build rsync command based on mode
    local rsync_opts=("-avz" "--progress")

    if [[ "${SYNC_MODE}" == "mirror" ]]; then
        rsync_opts+=("--delete")
        print_status "info" "Mode: Mirror (--delete)"
    else
        print_status "info" "Mode: Archive (no delete)"
    fi

    # Run rsync
    # -a: archive mode (preserves permissions, timestamps, etc.)
    # -v: verbose
    # -z: compress during transfer
    # --delete: mirror mode - remove files in dest that don't exist in source
    # --progress: show progress (useful for manual runs)
    # --exclude: skip unwanted files
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
        "${SOURCE_DIR}/" "${DEST_DIR}/" 2>&1 | tee -a "${LOG_FILE}"; then

        local sync_end
        sync_end=$(date +%s)
        local duration=$((sync_end - sync_start))

        echo ""
        print_status "ok" "Sync completed successfully in ${duration}s"
        log "=== iCloud Sync Completed (${duration}s) ==="
    else
        print_status "error" "Sync failed!"
        log "=== iCloud Sync FAILED ==="
        exit 1
    fi
}

main "$@"
