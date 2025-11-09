#!/usr/bin/env bash
# ABOUTME: Automated macOS bootstrap script for Nix-Darwin setup system
# ABOUTME: Transforms fresh macOS into fully configured dev environment in <30 minutes

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

    # Future phases will be added here in subsequent stories
    log_warn "Bootstrap implementation incomplete - only pre-flight checks implemented (Story 01.1-001)"
    log_warn "Remaining phases will be added in future stories"

    exit 0
}

# Only run main if script is executed directly (not sourced for testing)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
