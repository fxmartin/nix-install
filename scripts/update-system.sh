#!/usr/bin/env bash
# ABOUTME: Nix system update/rebuild automation script
# ABOUTME: Handles flake updates, darwin-rebuild, and provides convenient shortcuts

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

# Detect profile based on hostname
detect_profile() {
    local hostname
    hostname=$(hostname -s | tr '[:upper:]' '[:lower:]')

    case "$hostname" in
        *pro*|*max*)
            echo "power"
            ;;
        *air*)
            echo "standard"
            ;;
        *)
            log_warning "Could not auto-detect profile from hostname: $hostname"
            log_info "Please specify profile: ./scripts/update-system.sh [update|rebuild] [standard|power]"
            return 1
            ;;
    esac
}

# Update flake.lock (get latest package versions)
update_flake() {
    log_info "Updating flake.lock..."

    cd "$PROJECT_ROOT" || exit 1

    if ! nix flake update; then
        log_error "Failed to update flake.lock"
        return 1
    fi

    log_success "Flake updated successfully"

    # Show what changed
    if git diff --quiet flake.lock; then
        log_info "No changes to flake.lock"
    else
        log_info "Changes to flake.lock:"
        git diff flake.lock | grep -E '^\+|^\-' | grep -v '^\+\+\+|^\-\-\-' || true
    fi
}

# Rebuild system configuration
rebuild_system() {
    local profile="${1:-}"

    if [[ -z "$profile" ]]; then
        profile=$(detect_profile) || return 1
    fi

    log_info "Rebuilding system with profile: $profile"

    cd "$PROJECT_ROOT" || exit 1

    if ! sudo darwin-rebuild switch --flake ".#${profile}"; then
        log_error "Failed to rebuild system"
        return 1
    fi

    log_success "System rebuilt successfully"

    # Check for uncommitted changes
    if ! git diff --quiet flake.lock; then
        log_warning "flake.lock has uncommitted changes"
        log_info "Consider committing with:"
        echo "  cd $PROJECT_ROOT"
        echo "  git add flake.lock"
        echo "  git commit -m 'chore: update flake.lock'"
        echo "  git push"
    fi
}

# Show usage
usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [profile]

Commands:
    update              Update flake.lock only (no rebuild)
    rebuild [profile]   Rebuild system without updating flake.lock
    full [profile]      Update flake.lock AND rebuild system

Profiles:
    standard           MacBook Air profile (~35GB)
    power              MacBook Pro M3 Max profile (~120GB)
    (auto-detected if not specified)

Examples:
    $(basename "$0") update              # Update flake.lock
    $(basename "$0") rebuild             # Rebuild with auto-detected profile
    $(basename "$0") rebuild power       # Rebuild with Power profile
    $(basename "$0") full                # Update + rebuild with auto-detected profile
    $(basename "$0") full standard       # Update + rebuild with Standard profile

EOF
}

# Main function
main() {
    local command="${1:-}"
    local profile="${2:-}"

    if [[ -z "$command" ]]; then
        usage
        exit 1
    fi

    case "$command" in
        update)
            update_flake
            ;;
        rebuild)
            rebuild_system "$profile"
            ;;
        full)
            update_flake && rebuild_system "$profile"
            ;;
        -h|--help|help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown command: $command"
            echo
            usage
            exit 1
            ;;
    esac
}

main "$@"
