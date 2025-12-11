# ABOUTME: Common utilities, logging, colors, and system validation functions
# ABOUTME: Sourced by bootstrap.sh and all other library modules
# ABOUTME: Provides foundational logging and system checking capabilities

# Guard against double-sourcing
[[ -n "${_COMMON_SH_LOADED:-}" ]] && return 0
readonly _COMMON_SH_LOADED=1

# ==============================================================================
# GLOBAL CONSTANTS
# ==============================================================================

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Bootstrap script version
readonly BOOTSTRAP_VERSION="1.0.0"

# Minimum required macOS version
readonly MIN_MACOS_VERSION=14

# Work directory for bootstrap operations
readonly WORK_DIR="/tmp/nix-bootstrap"
readonly USER_CONFIG_FILE="${WORK_DIR}/user-config.nix"

# Bootstrap temp directory (used by multiple phases)
readonly BOOTSTRAP_TEMP_DIR="/tmp/nix-bootstrap"

# Repository clone directory (configurable via NIX_INSTALL_DIR environment variable)
# Default: ~/.config/nix-install
# Custom: export NIX_INSTALL_DIR="~/nix-install" before running bootstrap
readonly REPO_CLONE_DIR="${NIX_INSTALL_DIR:-${HOME}/.config/nix-install}"

# ==============================================================================
# LOGGING FUNCTIONS
# ==============================================================================

# Log informational message with green [INFO] prefix
# Usage: log_info "message"
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Log warning message with yellow [WARN] prefix
# Usage: log_warn "message"
log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Log error message with red [ERROR] prefix (to stderr)
# Usage: log_error "message"
log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Log success message with green [SUCCESS] prefix
# Usage: log_success "message"
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# ==============================================================================
# INPUT HANDLING
# ==============================================================================

# Read user input with /dev/tty fallback for curl | bash scenarios
# Usage: read_input "variable_name" "prompt"
# This ensures read works when stdin is consumed by curl pipe
read_input() {
    local var_name="$1"
    local prompt="$2"
    local value

    # Try reading from stdin first, fall back to /dev/tty if needed
    if [[ -t 0 ]]; then
        # stdin is a terminal, read normally
        read -r -p "$prompt" value
    else
        # stdin is not a terminal (piped), use /dev/tty
        read -r -p "$prompt" value < /dev/tty
    fi

    # Assign to the named variable
    printf -v "$var_name" '%s' "$value"
}

# ==============================================================================
# PHASE PROGRESS INDICATORS
# ==============================================================================

# Phase progress indicator with consistent formatting
# Usage: log_phase <phase_num> <phase_name> [estimated_time]
# Example: log_phase 3 "Xcode CLI Tools" "~5 minutes"
log_phase() {
    local phase_num="$1"
    local phase_name="$2"
    local estimated_time="${3:-}"
    local total_phases=9

    echo ""
    echo "════════════════════════════════════════════════════════════════════════════"
    if [[ -n "${estimated_time}" ]]; then
        log_info "Phase ${phase_num}/${total_phases}: ${phase_name} (${estimated_time})"
    else
        log_info "Phase ${phase_num}/${total_phases}: ${phase_name}"
    fi
    echo "════════════════════════════════════════════════════════════════════════════"
    echo ""
}

# Phase completion indicator
# Usage: log_phase_complete <phase_num> <phase_name> <duration_seconds>
log_phase_complete() {
    local phase_num="$1"
    local phase_name="$2"
    local duration="$3"

    echo ""
    log_success "✓ Phase ${phase_num}/9 completed: ${phase_name} (${duration}s)"
    echo ""
}

# ==============================================================================
# SYSTEM VALIDATION FUNCTIONS
# ==============================================================================

# Check macOS version is Sonoma (14.0) or newer
# Returns: 0 if version OK, 1 if too old
check_macos_version() {
    local version
    version=$(sw_vers -productVersion)
    local major_version
    major_version=$(echo "${version}" | cut -d. -f1)

    # Check if Sonoma (14) or newer
    if [[ "${major_version}" -lt "${MIN_MACOS_VERSION}" ]]; then
        log_error "macOS Sonoma (14.0) or newer required. Found: ${version}"
        log_error "Please upgrade macOS before running this script."
        log_error "Visit System Settings > General > Software Update to upgrade."
        return 1
    fi

    log_info "macOS version: ${version} ✓"
    return 0
}

# Ensure script is not running as root
# Returns: 0 if not root, 1 if root
check_not_root() {
    if [[ "${EUID}" -eq 0 ]]; then
        log_error "This script must NOT be run as root"
        log_error "Please run as a regular user: ./bootstrap.sh"
        log_error "The script will request sudo permissions when needed."
        return 1
    fi

    log_info "Running as non-root user: $(whoami) ✓"
    return 0
}

# Verify internet connectivity
# Tests both nixos.org and github.com
# Returns: 0 if connected, 1 if no connectivity
check_internet() {
    log_info "Testing internet connectivity..."

    # Try nixos.org first (primary package source)
    if curl -Is --connect-timeout 5 https://nixos.org > /dev/null 2>&1; then
        log_info "Internet connectivity verified (nixos.org) ✓"
        return 0
    fi

    # Try github.com as fallback (secondary package source)
    if curl -Is --connect-timeout 5 https://github.com > /dev/null 2>&1; then
        log_info "Internet connectivity verified (github.com) ✓"
        return 0
    fi

    # Both failed - no internet connectivity
    log_error "No internet connectivity detected"
    log_error "Please check your network connection and try again."
    log_error "This installation requires internet access to download packages from:"
    log_error "  - nixos.org (Nix packages)"
    log_error "  - github.com (repository access)"
    return 1
}

# Check if terminal has Full Disk Access (FDA)
# Required for Power profile to install Parallels Desktop via Homebrew
# Returns: 0 if FDA granted, 1 if not granted
check_terminal_full_disk_access() {
    log_info "Checking terminal Full Disk Access permissions..."
    echo ""

    # Determine current terminal app
    # Use :- default to handle unset variables with set -u
    local terminal_app="Terminal"
    if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
        terminal_app="Ghostty"
    elif [[ -n "${ITERM_SESSION_ID:-}" ]]; then
        terminal_app="iTerm2"
    elif [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" ]]; then
        terminal_app="Terminal.app"
    fi

    log_info "Detected terminal: ${terminal_app}"
    echo ""

    # Test FDA by attempting to read a protected directory
    # ~/Library/Mail is protected and requires FDA
    local test_path="${HOME}/Library/Mail"

    if [[ -d "${test_path}" ]]; then
        # Try to list contents of protected directory
        if ls "${test_path}" >/dev/null 2>&1; then
            log_info "Terminal has Full Disk Access ✓"
            log_info "FDA is granted for: ${terminal_app}"
            echo ""
            return 0
        fi
    else
        # If Mail directory doesn't exist, try Safari
        test_path="${HOME}/Library/Safari"
        if [[ -d "${test_path}" ]]; then
            if ls "${test_path}" >/dev/null 2>&1; then
                log_info "Terminal has Full Disk Access ✓"
                log_info "FDA is granted for: ${terminal_app}"
                echo ""
                return 0
            fi
        fi
    fi

    # FDA not granted - provide instructions
    log_error "Terminal does NOT have Full Disk Access"
    log_error "FDA is REQUIRED for Power profile to install Parallels Desktop"
    echo ""
    log_info "======================================"
    log_info "MANUAL ACTION REQUIRED"
    log_info "======================================"
    echo ""
    log_info "Please grant Full Disk Access to your terminal:"
    echo ""
    log_info "1. Open System Settings → Privacy & Security → Full Disk Access"
    log_info "   (or run: open 'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles')"
    echo ""
    log_info "2. Click the lock icon (🔒) → Authenticate with your password"
    echo ""
    log_info "3. Find your terminal app: ${terminal_app}"
    echo ""
    log_info "4. Toggle switch to ON (blue checkmark)"
    echo ""
    log_info "5. Click lock icon (🔒) again to prevent changes"
    echo ""
    log_info "6. QUIT terminal completely (Cmd+Q)"
    echo ""
    log_info "7. Relaunch terminal and run bootstrap.sh again"
    echo ""
    log_warn "Without FDA, Parallels Desktop installation will fail!"
    echo ""

    return 1
}

# Display system information summary
# Useful for debugging and validation
display_system_info() {
    log_info "==================================="
    log_info "System Information Summary"
    log_info "==================================="
    log_info "macOS Version: $(sw_vers -productVersion)"
    log_info "Build: $(sw_vers -buildVersion)"
    log_info "Product Name: $(sw_vers -productName)"
    log_info "Hostname: $(hostname)"
    log_info "User: $(whoami)"
    log_info "Architecture: $(uname -m)"
    log_info "Kernel: $(uname -r)"
    log_info "==================================="
}
