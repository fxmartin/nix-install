#!/usr/bin/env bash
# ABOUTME: Comprehensive disk cleanup script for development caches (Feature 06.7)
# ABOUTME: Cleans uv, Homebrew, npm, pip, node-gyp, and Podman/Docker caches with size reporting

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Color codes for output (disabled in email mode)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Version
DISK_CLEANUP_VERSION="1.0.0"

# Email configuration
NOTIFICATION_EMAIL="${NOTIFICATION_EMAIL:-}"
SCRIPTS_DIR="${SCRIPTS_DIR:-$(dirname "$0")}"
SEND_NOTIFICATION="${SCRIPTS_DIR}/send-notification.sh"

# Report buffer for email
REPORT_BUFFER=""

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Append to report buffer (for email)
report() {
    REPORT_BUFFER+="$1"$'\n'
}

print_header() {
    echo ""
    echo -e "${BOLD}=== $1 ===${NC}"
    report ""
    report "=== $1 ==="
}

print_status() {
    local status="$1"
    local message="$2"
    local symbol=""
    case "${status}" in
        ok)      echo -e "${GREEN}✓${NC} ${message}"; symbol="✓" ;;
        cleaned) echo -e "${GREEN}✓${NC} ${message}"; symbol="✓" ;;
        skip)    echo -e "${YELLOW}⊘${NC} ${message}"; symbol="⊘" ;;
        info)    echo -e "${BLUE}ℹ${NC} ${message}"; symbol="•" ;;
        warn)    echo -e "${YELLOW}⚠${NC} ${message}"; symbol="⚠" ;;
        error)   echo -e "${RED}✗${NC} ${message}"; symbol="✗" ;;
        *)       echo -e "${message}"; symbol="" ;;
    esac
    report "${symbol} ${message}"
}

# Get size of a directory in human-readable format, or "0B" if not present
get_size() {
    local path="${1}"
    if [[ -d "${path}" ]]; then
        du -sh "${path}" 2>/dev/null | cut -f1
    else
        echo "0B"
    fi
}

# Get size in bytes for comparison
get_size_bytes() {
    local path="${1}"
    if [[ -d "${path}" ]]; then
        du -sk "${path}" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

# =============================================================================
# CACHE SIZE ANALYSIS
# =============================================================================

analyze_caches() {
    print_header "Analyzing Cache Sizes"

    local total_kb=0

    # uv cache
    local uv_size=$(get_size ~/.cache/uv)
    local uv_kb=$(get_size_bytes ~/.cache/uv)
    total_kb=$((total_kb + uv_kb))
    print_status "info" "uv cache: ${uv_size}"

    # Homebrew cache
    local brew_size=$(get_size ~/Library/Caches/Homebrew)
    local brew_kb=$(get_size_bytes ~/Library/Caches/Homebrew)
    total_kb=$((total_kb + brew_kb))
    print_status "info" "Homebrew cache: ${brew_size}"

    # npm cache
    local npm_size=$(get_size ~/.npm)
    local npm_kb=$(get_size_bytes ~/.npm)
    total_kb=$((total_kb + npm_kb))
    print_status "info" "npm cache: ${npm_size}"

    # pip cache
    local pip_size=$(get_size ~/Library/Caches/pip)
    local pip_kb=$(get_size_bytes ~/Library/Caches/pip)
    total_kb=$((total_kb + pip_kb))
    print_status "info" "pip cache: ${pip_size}"

    # node-gyp cache
    local nodegyp_size=$(get_size ~/Library/Caches/node-gyp)
    local nodegyp_kb=$(get_size_bytes ~/Library/Caches/node-gyp)
    total_kb=$((total_kb + nodegyp_kb))
    print_status "info" "node-gyp cache: ${nodegyp_size}"

    # Huggingface cache
    local hf_size=$(get_size ~/.cache/huggingface)
    local hf_kb=$(get_size_bytes ~/.cache/huggingface)
    total_kb=$((total_kb + hf_kb))
    print_status "info" "Huggingface cache: ${hf_size}"

    # Podman/Docker
    if command -v podman &>/dev/null && podman machine list 2>/dev/null | grep -q "Currently running"; then
        local podman_info=$(podman system df --format "{{.TotalCount}} items, {{.Size}}" 2>/dev/null | head -1 || echo "unknown")
        print_status "info" "Podman: ${podman_info}"
    elif command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        local docker_size=$(docker system df --format "{{.Size}}" 2>/dev/null | head -1 || echo "unknown")
        print_status "info" "Docker: ${docker_size}"
    else
        print_status "skip" "Podman/Docker: not running"
    fi

    echo ""
    local total_gb=$((total_kb / 1024 / 1024))
    local total_mb=$((total_kb / 1024))
    if [[ ${total_gb} -gt 0 ]]; then
        print_status "info" "Total cleanable (excluding containers): ~${total_gb}GB"
    else
        print_status "info" "Total cleanable (excluding containers): ~${total_mb}MB"
    fi
}

# =============================================================================
# CLEANUP FUNCTIONS
# =============================================================================

cleanup_uv() {
    print_header "Cleaning uv Cache"
    if command -v uv &>/dev/null; then
        local before=$(get_size ~/.cache/uv)
        if uv cache clean 2>&1; then
            print_status "cleaned" "uv cache cleaned (was: ${before})"
        else
            print_status "error" "Failed to clean uv cache"
        fi
    else
        print_status "skip" "uv not installed"
    fi
}

cleanup_homebrew() {
    print_header "Cleaning Homebrew Cache"
    if command -v brew &>/dev/null; then
        local before=$(get_size ~/Library/Caches/Homebrew)
        # Run brew cleanup
        brew cleanup 2>&1 || true

        # Also remove the cache directory contents directly for thorough cleanup
        rm -rf ~/Library/Caches/Homebrew/* 2>/dev/null || true

        print_status "cleaned" "Homebrew cache cleaned (was: ${before})"
    else
        print_status "skip" "Homebrew not installed"
    fi
}

cleanup_npm() {
    print_header "Cleaning npm Cache"
    local before=$(get_size ~/.npm)
    if [[ -d ~/.npm ]]; then
        rm -rf ~/.npm
        print_status "cleaned" "npm cache cleaned (was: ${before})"
    else
        print_status "skip" "npm cache not present"
    fi
}

cleanup_pip() {
    print_header "Cleaning pip Cache"
    local before=$(get_size ~/Library/Caches/pip)
    if [[ -d ~/Library/Caches/pip ]]; then
        rm -rf ~/Library/Caches/pip
        print_status "cleaned" "pip cache cleaned (was: ${before})"
    else
        print_status "skip" "pip cache not present"
    fi
}

cleanup_nodegyp() {
    print_header "Cleaning node-gyp Cache"
    local before=$(get_size ~/Library/Caches/node-gyp)
    if [[ -d ~/Library/Caches/node-gyp ]]; then
        rm -rf ~/Library/Caches/node-gyp
        print_status "cleaned" "node-gyp cache cleaned (was: ${before})"
    else
        print_status "skip" "node-gyp cache not present"
    fi
}

cleanup_containers() {
    print_header "Cleaning Container Runtime"

    # Try Podman first (preferred in this project)
    if command -v podman &>/dev/null; then
        if podman machine list 2>/dev/null | grep -q "Currently running"; then
            echo "Cleaning Podman (unused containers, images, volumes, build cache)..."
            if podman system prune -a --volumes -f 2>&1; then
                print_status "cleaned" "Podman system pruned"
            else
                print_status "error" "Failed to prune Podman"
            fi
        else
            print_status "skip" "Podman machine not running (start with: podman machine start)"
        fi
    # Fall back to Docker if present
    elif command -v docker &>/dev/null; then
        if docker info &>/dev/null 2>&1; then
            echo "Cleaning Docker (unused containers, images, volumes, build cache)..."
            if docker system prune -a --volumes -f 2>&1; then
                print_status "cleaned" "Docker system pruned"
            else
                print_status "error" "Failed to prune Docker"
            fi
        else
            print_status "skip" "Docker not running"
        fi
    else
        print_status "skip" "No container runtime found (Podman or Docker)"
    fi
}

# =============================================================================
# DISK SPACE REPORTING
# =============================================================================

report_disk_space() {
    print_header "Disk Space"
    local avail capacity
    avail=$(df -h / | tail -1 | awk '{print $4}')
    capacity=$(df -h / | tail -1 | awk '{print $5}')
    print_status "info" "Available: ${avail} (${capacity} used)"
}

# =============================================================================
# EMAIL NOTIFICATION
# =============================================================================

send_email_report() {
    local recipient="${1:-}"

    if [[ -z "${recipient}" ]]; then
        return 0
    fi

    echo ""
    echo "Sending email report to ${recipient}..."

    if [[ -x "${SEND_NOTIFICATION}" ]]; then
        local subject="[Disk Cleanup] Monthly report - $(hostname)"
        if "${SEND_NOTIFICATION}" "${recipient}" "${subject}" "${REPORT_BUFFER}"; then
            echo "✓ Email report sent successfully"
        else
            echo "✗ Failed to send email report" >&2
        fi
    else
        echo "⚠ send-notification.sh not found at ${SEND_NOTIFICATION}" >&2
        echo "  Email report not sent"
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

    echo ""
    echo -e "${BOLD}Disk Cleanup Script v${DISK_CLEANUP_VERSION}${NC}"
    echo "Host: ${hostname_str}"
    echo "Date: ${date_str}"

    # Initialize report buffer
    report "Disk Cleanup Report v${DISK_CLEANUP_VERSION}"
    report "Host: ${hostname_str}"
    report "Date: ${date_str}"

    # Check for --dry-run or --analyze flag
    local dry_run=false
    if [[ "${1:-}" == "--dry-run" ]] || [[ "${1:-}" == "--analyze" ]] || [[ "${1:-}" == "-n" ]]; then
        dry_run=true
        echo ""
        echo -e "${YELLOW}Dry run mode - showing what would be cleaned${NC}"
    fi

    # Initial disk space
    report_disk_space

    if [[ "${dry_run}" == true ]]; then
        analyze_caches
        echo ""
        echo "Run without --dry-run to perform cleanup."
    else
        # Perform all cleanups
        cleanup_uv
        cleanup_homebrew
        cleanup_npm
        cleanup_pip
        cleanup_nodegyp
        cleanup_containers

        # Final disk space
        echo ""
        report_disk_space

        # Send email report if configured
        send_email_report "${NOTIFICATION_EMAIL}"
    fi

    print_header "Tips"
    echo "• Time Machine snapshots can hold freed space hostage"
    echo "  → sudo tmutil deletelocalsnapshots /"
    echo "• Nix garbage collection: gc or gc-system"
    echo "• Check large folders: du -sh ~/Library/* | sort -hr | head -10"
    echo ""
}

main "$@"
