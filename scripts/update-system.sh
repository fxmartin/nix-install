#!/usr/bin/env bash
# ABOUTME: Nix system update/rebuild automation script
# ABOUTME: Handles flake updates, darwin-rebuild, and provides convenient shortcuts

set -euo pipefail

# Script version
readonly UPDATE_SYSTEM_VERSION="1.0.0"

# Minimum free disk required for rebuild/build (GB).
# Guards against mid-rebuild disk-fill. Bypass with --force or $CI.
# Uses Finder-equivalent metric (volumeAvailableCapacityForImportantUsage).
readonly DISK_REBUILD_MIN_GB=10

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

# Check that enough free disk is available before starting a rebuild.
# Honors --force (via FORCE_REBUILD=1) and CI environments.
check_free_disk() {
    if [[ "${FORCE_REBUILD:-0}" == "1" ]] || [[ -n "${CI:-}" ]]; then
        return 0
    fi

    local free_gb=""
    # Prefer NSURL volumeAvailableCapacityForImportantUsage (matches Finder — includes purgeable)
    free_gb=$(/usr/bin/swift -e '
import Foundation
let url = URL(fileURLWithPath: "/")
let v = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
if let a = v.volumeAvailableCapacityForImportantUsage { print(a / 1073741824) }
' 2>/dev/null || true)

    # Fallback to df if swift is unavailable (e.g. stripped-down environments)
    if [[ -z "$free_gb" ]]; then
        free_gb=$(df -k / 2>/dev/null | tail -1 | awk '{print int($4/1024/1024)}')
    fi

    if [[ -z "$free_gb" ]]; then
        log_warning "Could not determine free disk space — skipping guard"
        return 0
    fi

    if [[ "$free_gb" -lt "$DISK_REBUILD_MIN_GB" ]]; then
        log_error "Only ${free_gb}GB free — ${DISK_REBUILD_MIN_GB}GB required for rebuild"
        echo ""
        echo "Free up space with:"
        echo "  gc            # Remove old user generations"
        echo "  gc-system     # Remove old system generations (sudo)"
        echo "  disk-cleanup  # Clean dev caches (uv, npm, Homebrew, Docker)"
        echo ""
        echo "Or bypass this check:"
        echo "  rebuild --force"
        return 1
    fi
    return 0
}

# Check if user-config.nix exists and provide helpful error if not
check_user_config() {
    local user_config="${PROJECT_ROOT}/user-config.nix"
    local template="${PROJECT_ROOT}/user-config.template.nix"

    if [[ ! -f "$user_config" ]]; then
        log_error "user-config.nix not found!"
        echo ""
        echo "This file contains your personal configuration and is not tracked in git."
        echo ""
        if [[ -f "$template" ]]; then
            echo "To create it, either:"
            echo "  1. Run the bootstrap script: curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/bootstrap.sh | bash"
            echo "  2. Or manually copy the template and fill in your values:"
            echo "     cp ${template} ${user_config}"
            echo "     # Then edit ${user_config} with your actual values"
        else
            echo "Run the bootstrap script to set up your configuration:"
            echo "  curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/bootstrap.sh | bash"
        fi
        echo ""
        return 1
    fi
    return 0
}

# Detect profile from user-config.nix or hostname
detect_profile() {
    # First, check if user-config.nix exists
    local user_config="${PROJECT_ROOT}/user-config.nix"
    if [[ -f "$user_config" ]]; then
        local profile
        # Extract value: installProfile = "standard"; -> standard
        # Use awk to get the first quoted string after the = sign, ignoring comments
        profile=$(grep 'installProfile' "$user_config" | awk -F'"' '{print $2}' | head -1)
        if [[ "$profile" == "standard" || "$profile" == "power" || "$profile" == "ai-assistant" ]]; then
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
            log_info "Please specify profile: ./scripts/update-system.sh [update|rebuild] [standard|power|ai-assistant]"
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

# Update MCP server paths in Claude Code config files
update_mcp_paths() {
    local mcp_script="${SCRIPT_DIR}/update-mcp-paths.sh"

    if [[ -x "$mcp_script" ]]; then
        log_info "Updating MCP server paths..."
        if "$mcp_script"; then
            log_success "MCP paths updated"
        else
            log_warning "MCP path update failed (non-critical)"
        fi
    fi
}

# Rebuild system configuration
rebuild_system() {
    local profile="${1:-}"

    # Check user-config.nix exists before attempting rebuild
    check_user_config || return 1
    check_free_disk || return 1

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

    # Update MCP server paths after successful rebuild
    update_mcp_paths
}

# Dry-run rebuild (build without switching)
# Shows what would change without applying
dry_run_system() {
    local profile="${1:-}"

    check_user_config || return 1
    check_free_disk || return 1

    if [[ -z "$profile" ]]; then
        profile=$(detect_profile) || return 1
    fi

    log_info "Dry-run build with profile: $profile (build only, no switch)"

    cd "$PROJECT_ROOT" || exit 1

    if ! sudo darwin-rebuild build --flake ".#${profile}"; then
        log_error "Dry-run build failed"
        return 1
    fi

    log_success "Dry-run build succeeded — no changes applied"
    log_info "To apply: rebuild"
}

# Show usage
usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [profile] [--force]

Commands:
    update              Update flake.lock only (no rebuild)
    rebuild [profile]   Rebuild system without updating flake.lock
    dry [profile]       Build without switching (preview changes)
    full [profile]      Update flake.lock AND rebuild system

Flags:
    --force             Bypass the ${DISK_REBUILD_MIN_GB}GB free-disk guard for rebuild/dry/full
                        (also skipped automatically when \$CI is set)

Profiles:
    standard           MacBook Air profile (~35GB)
    power              MacBook Pro M3 Max profile (~120GB)
    ai-assistant       Older MacBook personal AI assistant profile (~20GB)
    (auto-detected if not specified)

Examples:
    $(basename "$0") update              # Update flake.lock
    $(basename "$0") rebuild             # Rebuild with auto-detected profile
    $(basename "$0") rebuild power       # Rebuild with Power profile
    $(basename "$0") rebuild ai-assistant # Rebuild with AI-Assistant profile
    $(basename "$0") full                # Update + rebuild with auto-detected profile
    $(basename "$0") full standard       # Update + rebuild with Standard profile

EOF
}

# Main function
main() {
    # Extract --force flag from anywhere in argv, before positional parsing.
    # FORCE_REBUILD is consumed by check_free_disk().
    local filtered=()
    for arg in "$@"; do
        if [[ "$arg" == "--force" ]]; then
            export FORCE_REBUILD=1
        else
            filtered+=("$arg")
        fi
    done
    set -- "${filtered[@]}"

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
        dry)
            dry_run_system "$profile"
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
