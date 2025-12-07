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

# Detect profile from user-config.nix or hostname
detect_profile() {
    # First, try to read from user-config.nix (most reliable)
    local user_config="${PROJECT_ROOT}/user-config.nix"
    if [[ -f "$user_config" ]]; then
        local profile
        # Extract value: installProfile = "standard"; -> standard
        # Use awk to get the first quoted string after the = sign, ignoring comments
        profile=$(grep 'installProfile' "$user_config" | awk -F'"' '{print $2}' | head -1)
        if [[ "$profile" == "standard" || "$profile" == "power" ]]; then
            echo "$profile"
            return 0
        fi
    fi

    # Fallback: detect from hostname
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
            log_warning "And could not read from user-config.nix"
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

    # Show what changed and prompt for commit
    if git diff --quiet flake.lock; then
        log_info "No changes to flake.lock"
    else
        log_info "Changes to flake.lock:"
        git diff flake.lock | /usr/bin/grep -E '^\+|^\-' | /usr/bin/grep -v '^\+\+\+|^\-\-\-' || true
        echo ""
        log_warning "flake.lock has uncommitted changes"
        echo ""
        echo "To commit and push:"
        echo "  git add flake.lock && git commit -m 'chore: update flake.lock' && git push"
        echo ""
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
