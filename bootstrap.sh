#!/usr/bin/env bash
# ABOUTME: Stage 2 bootstrap installer - interactive macOS configuration with Nix-Darwin
# ABOUTME: Called by setup.sh wrapper to ensure interactive prompts work correctly

# ==============================================================================
# TWO-STAGE BOOTSTRAP PATTERN - STAGE 2: INTERACTIVE INSTALLER
# ==============================================================================
#
# This script is STAGE 2 of the two-stage bootstrap pattern:
#
# STAGE 1 (setup.sh):
#   - Curl-pipeable wrapper with NO interactive prompts
#   - Downloads this script to /tmp
#   - Executes this script locally (NOT piped)
#
# STAGE 2 (THIS FILE - bootstrap.sh):
#   - Full interactive installer with user prompts
#   - Runs with proper stdin connected to terminal
#   - Uses standard "read -r" commands (works because NOT piped)
#   - Performs actual Nix-Darwin installation
#
# WHY THIS WORKS:
#   When setup.sh downloads this script and executes it with "bash bootstrap.sh",
#   stdin is properly connected to the terminal, allowing interactive prompts
#   to read user input. No /dev/tty redirects or workarounds needed.
#
# PHASE SEPARATION:
#   Phase 1 (Pre-flight validation) is performed by setup.sh BEFORE this script
#   is downloaded. This script starts at Phase 2 (User Configuration).
#
#   By the time this script runs:
#   ✓ macOS version validated (Sonoma 14.0+)
#   ✓ Not running as root
#   ✓ Internet connectivity verified
#   ✓ System meets minimum requirements
#
# INSTALLATION METHODS:
#   1. Recommended (via setup.sh wrapper):
#      curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/setup.sh | bash
#
#   2. Direct execution (advanced users):
#      curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/bootstrap.sh -o bootstrap.sh
#      chmod +x bootstrap.sh
#      ./bootstrap.sh
#      (Note: Direct execution will repeat some pre-flight checks)
#
# ==============================================================================

set -euo pipefail  # Strict error handling

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Minimum required macOS version
readonly MIN_MACOS_VERSION=14

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check macOS version is Sonoma (14.0) or newer
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

# Display system information summary
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

# =============================================================================
# PHASE 2: USER INFORMATION VALIDATION FUNCTIONS
# =============================================================================

# Validate email address format
# Email regex: ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
# Requires: @ symbol, domain name, and TLD (at least 2 characters)
validate_email() {
    local email="$1"
    local email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

    if [[ ! "$email" =~ $email_regex ]]; then
        return 1
    fi

    # Additional validation: reject leading/trailing dots
    if [[ "$email" =~ ^\. ]] || [[ "$email" =~ \.$ ]]; then
        return 1
    fi

    return 0
}

# Validate GitHub username format
# GitHub allows: alphanumeric, hyphens, underscores
# Does NOT allow: leading/trailing hyphens, special characters, periods
validate_github_username() {
    local username="$1"

    # Reject empty string
    if [[ -z "$username" ]]; then
        return 1
    fi

    # Reject leading or trailing hyphens (GitHub restriction)
    if [[ "$username" =~ ^- ]] || [[ "$username" =~ -$ ]]; then
        return 1
    fi

    # Validate allowed characters only: alphanumeric, hyphen, underscore
    local username_regex='^[a-zA-Z0-9_-]+$'
    if [[ ! "$username" =~ $username_regex ]]; then
        return 1
    fi

    return 0
}

# Validate user's full name
# Allows: letters, spaces, apostrophes, hyphens, periods, commas, accented characters
# Rejects: empty string, whitespace-only string
validate_name() {
    local name="$1"

    # Reject empty string
    if [[ -z "$name" ]]; then
        return 1
    fi

    # Reject whitespace-only string (spaces, tabs, newlines)
    if [[ "$name" =~ ^[[:space:]]*$ ]]; then
        return 1
    fi

    # Name is valid if non-empty and not just whitespace
    return 0
}

# Prompt user for personal information with validation
# Sets global variables: USER_FULLNAME, USER_EMAIL, GITHUB_USERNAME
prompt_user_info() {
    log_info "==================================="
    log_info "Phase 2/10: User Configuration"
    log_info "==================================="
    echo ""
    log_info "Please provide your information for Git, SSH, and system configuration."
    echo ""

    local confirmed="n"

    # Loop until user confirms all information
    while [[ "$confirmed" != "y" ]]; do
        # Prompt for full name with validation
        while true; do
            read -r -p "Full Name: " USER_FULLNAME
            if validate_name "$USER_FULLNAME"; then
                log_info "✓ Name validated"
                break
            else
                log_error "Invalid name. Please enter your full name (cannot be empty)."
            fi
        done

        echo ""

        # Prompt for email with validation
        while true; do
            read -r -p "Email Address: " USER_EMAIL
            if validate_email "$USER_EMAIL"; then
                log_info "✓ Email validated"
                break
            else
                log_error "Invalid email format. Please include @ and domain (e.g., user@example.com)"
            fi
        done

        echo ""

        # Prompt for GitHub username with validation
        while true; do
            read -r -p "GitHub Username: " GITHUB_USERNAME
            if validate_github_username "$GITHUB_USERNAME"; then
                log_info "✓ GitHub username validated"
                break
            else
                log_error "Invalid GitHub username. Use only letters, numbers, hyphens, and underscores."
                log_error "Username cannot start or end with a hyphen."
            fi
        done

        echo ""

        # Display confirmation summary
        log_info "Please confirm your information:"
        echo "  Name:          $USER_FULLNAME"
        echo "  Email:         $USER_EMAIL"
        echo "  GitHub:        $GITHUB_USERNAME"
        echo ""

        read -r -p "Is this correct? (y/n): " confirmed
        echo ""

        if [[ "$confirmed" != "y" ]]; then
            log_warn "Let's try again. Please re-enter your information."
            echo ""
        fi
    done

    log_info "✓ User information collected successfully"
    echo ""
}

# Run all pre-flight validation checks
preflight_checks() {
    # shellcheck disable=SC2310  # Intentional: capture failures to show all errors
    log_info "Starting pre-flight system validation..."
    echo ""

    # Display system information first
    display_system_info
    echo ""

    # Run individual checks
    local all_passed=true

    # shellcheck disable=SC2310  # Intentional: Using ! with functions to capture all failures
    if ! check_macos_version; then
        all_passed=false
    fi

    # shellcheck disable=SC2310
    if ! check_not_root; then
        all_passed=false
    fi

    # shellcheck disable=SC2310
    if ! check_internet; then
        all_passed=false
    fi

    echo ""

    if [[ "${all_passed}" == "false" ]]; then
        log_error "One or more pre-flight checks failed"
        log_error "Please resolve the issues above and try again"
        return 1
    fi

    log_info "All pre-flight checks passed ✓"
    return 0
}

# Main execution flow
main() {
    echo ""
    log_info "========================================"
    log_info "Nix-Darwin macOS Bootstrap"
    log_info "Automated System Configuration"
    log_info "========================================"
    echo ""

    # ==========================================================================
    # PHASE 1: PRE-FLIGHT VALIDATION (May be redundant if run via setup.sh)
    # ==========================================================================
    # When run via setup.sh (recommended), these checks already passed.
    # When run directly, these checks are essential for safety.
    # Running them twice is harmless - defense in depth.
    # ==========================================================================

    log_info "Phase 1/10: Pre-flight System Validation"
    echo ""

    # shellcheck disable=SC2310  # Intentional: Using ! to handle validation failure
    if ! preflight_checks; then
        log_error "Pre-flight checks failed. Aborting installation."
        echo ""
        log_error "Bootstrap process terminated."
        exit 1
    fi

    echo ""
    log_info "Pre-flight validation complete!"
    log_info "System is ready for Nix-Darwin installation."
    echo ""

    # ==========================================================================
    # PHASE 2: USER CONFIGURATION
    # ==========================================================================
    # This is the first phase with interactive prompts, which is why the
    # two-stage bootstrap pattern exists - to ensure stdin works correctly.
    # ==========================================================================

    prompt_user_info

    # ==========================================================================
    # FUTURE PHASES (3-10)
    # ==========================================================================
    # Future phases will be added here in subsequent stories
    log_warn "Bootstrap implementation incomplete - Phases 3-10 not yet implemented"
    log_warn "Remaining phases will be added in future stories"

    exit 0
}

# Execution guard - run main() only when executed, not when sourced for testing
#
# This script is executed in two ways:
# 1. Called by setup.sh wrapper: "bash bootstrap.sh"
#    → BASH_SOURCE[0] == $0 → run main()
#
# 2. Direct execution: "./bootstrap.sh"
#    → BASH_SOURCE[0] == $0 → run main()
#
# 3. Sourced for BATS testing: "source bootstrap.sh"
#    → BASH_SOURCE[0] != $0 → skip main() (test functions only)
#
if [[ -z "${BASH_SOURCE[0]:-}" ]] || [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
