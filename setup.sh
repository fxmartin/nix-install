#!/usr/bin/env bash
# ABOUTME: Curl-pipeable wrapper script that downloads and executes bootstrap.sh
# ABOUTME: Solves stdin redirection issue when script is executed via curl | bash

# ==============================================================================
# WHY THIS TWO-STAGE BOOTSTRAP PATTERN EXISTS
# ==============================================================================
#
# PROBLEM: When executing scripts via curl | bash, stdin is consumed by the
# curl output stream, preventing interactive prompts from reading user input.
#
# Example of broken pattern:
#   curl https://example.com/bootstrap.sh | bash
#   # ↑ bootstrap.sh cannot use "read" because stdin is the curl pipe
#
# SOLUTION: Two-stage bootstrap pattern
#   1. setup.sh (THIS FILE) - Curl-pipeable wrapper with NO interactive prompts
#      - Detects piped execution with [[ ! -t 0 ]]
#      - Downloads bootstrap.sh to /tmp directory
#      - Executes bootstrap.sh locally (NOT piped)
#
#   2. bootstrap.sh - Full installer with interactive prompts
#      - Runs with proper stdin connected to terminal
#      - Uses standard "read -r" commands (no /dev/tty hacks needed)
#      - Collects user information, performs installation
#
# This pattern is production-proven in mlgruby/dotfile-nix and is more robust
# than /dev/tty redirection approaches.
#
# ==============================================================================

set -euo pipefail  # Strict error handling

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Configuration
readonly REPO_OWNER="fxmartin"
readonly REPO_NAME="nix-install"
readonly BRANCH="${NIX_INSTALL_BRANCH:-main}"  # Allow override via env var
readonly REPO_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"
readonly BOOTSTRAP_SCRIPT="bootstrap.sh"
readonly TEMP_DIR="/tmp/nix-install-setup-$$"

# Minimum required macOS version
readonly MIN_MACOS_VERSION=14

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

handle_error() {
    log_error "$1"
    log_info "Cleaning up temporary directory: ${TEMP_DIR}"
    rm -rf "${TEMP_DIR}"
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# =============================================================================
# PRE-FLIGHT VALIDATION FUNCTIONS
# =============================================================================
# These checks run BEFORE downloading bootstrap.sh to fail fast if system
# doesn't meet requirements. No point downloading bootstrap if it will fail.
# =============================================================================

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
        log_error "Please run as a regular user (script will request sudo when needed)"
        return 1
    fi

    log_info "Running as non-root user: $(whoami) ✓"
    return 0
}

# Verify internet connectivity to required domains
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
    log_info "==================================="
    log_info "Phase 1: Pre-flight System Validation"
    log_info "==================================="
    echo ""

    # Display system information first
    display_system_info
    echo ""

    # Run individual checks
    local all_passed=true

    if ! check_macos_version; then
        all_passed=false
    fi

    if ! check_not_root; then
        all_passed=false
    fi

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
    echo ""
    return 0
}

# Main setup function
main() {
    echo ""
    log_info "========================================"
    log_info "Nix-Darwin Setup Wrapper"
    log_info "Two-Stage Bootstrap Pattern"
    log_info "========================================"
    echo ""

    # Detect piped execution and inform user
    if [[ ! -t 0 ]]; then
        log_info "Detected piped execution (curl | bash)"
        log_info "This wrapper will download and execute bootstrap.sh locally"
        log_info "This ensures interactive prompts work correctly"
        echo ""
    fi

    # ==========================================================================
    # PHASE 1: PRE-FLIGHT VALIDATION
    # ==========================================================================
    # Run comprehensive system checks BEFORE downloading bootstrap.sh
    # This fails fast if system doesn't meet requirements - no point downloading
    # bootstrap script if it will fail anyway.
    # ==========================================================================

    if ! preflight_checks; then
        log_error "Pre-flight validation failed. Installation cannot continue."
        echo ""
        log_error "Please resolve the issues above and try again."
        exit 1
    fi

    log_success "Pre-flight validation complete!"
    log_info "System is ready for Nix-Darwin installation."
    echo ""

    # ==========================================================================
    # PHASE 2: DOWNLOAD BOOTSTRAP SCRIPT
    # ==========================================================================
    # Pre-flight checks passed - now download the full installer
    # ==========================================================================

    # Create temporary directory
    log_info "Creating temporary directory: ${TEMP_DIR}"
    mkdir -p "${TEMP_DIR}" || handle_error "Failed to create temporary directory"

    # Download bootstrap.sh
    log_info "Downloading bootstrap script..."
    log_info "Source: ${REPO_URL}/${BOOTSTRAP_SCRIPT}"

    if ! curl -fsSL "${REPO_URL}/${BOOTSTRAP_SCRIPT}" -o "${TEMP_DIR}/${BOOTSTRAP_SCRIPT}"; then
        handle_error "Failed to download bootstrap script from ${REPO_URL}/${BOOTSTRAP_SCRIPT}"
    fi

    # Verify the script was downloaded and is not empty
    if [[ ! -s "${TEMP_DIR}/${BOOTSTRAP_SCRIPT}" ]]; then
        handle_error "Downloaded script is empty or corrupted"
    fi

    log_success "Bootstrap script downloaded successfully"

    # Display script information
    log_info "Script information:"
    echo "  • Size: $(wc -c < "${TEMP_DIR}/${BOOTSTRAP_SCRIPT}") bytes"
    echo "  • Lines: $(wc -l < "${TEMP_DIR}/${BOOTSTRAP_SCRIPT}") lines"
    echo ""

    # Make the script executable
    chmod +x "${TEMP_DIR}/${BOOTSTRAP_SCRIPT}"

    # Display what the bootstrap will do
    log_info "The bootstrap script will perform:"
    echo "  • Phase 2: Collect user information (name, email, GitHub username)"
    echo "  • Phase 3: Install Nix package manager"
    echo "  • Phase 4: Install nix-darwin system configuration"
    echo "  • Phase 5: Install Homebrew and GUI applications"
    echo "  • Phase 6: Configure macOS system preferences"
    echo "  • Phase 7: Set up development environment (Zsh, Git, Python, etc.)"
    echo "  • Phase 8: Apply Catppuccin theming (Ghostty, Zed, system-wide)"
    echo ""
    log_info "Note: Phase 1 (pre-flight validation) already completed ✓"
    echo ""

    # CRITICAL: Execute bootstrap.sh locally (NOT piped)
    # This is the key to solving the stdin issue:
    # - When setup.sh is piped (curl | bash), stdin is the curl stream
    # - By downloading bootstrap.sh and executing it locally with "bash",
    #   we give bootstrap.sh a fresh stdin connected to the terminal
    # - This allows bootstrap.sh to use standard "read -r" commands
    #   without needing /dev/tty redirects or other workarounds
    log_info "Starting bootstrap installation..."
    log_info "Executing: bash ${TEMP_DIR}/${BOOTSTRAP_SCRIPT}"
    echo ""

    cd "${TEMP_DIR}" || handle_error "Failed to change to temporary directory"

    if bash "${BOOTSTRAP_SCRIPT}"; then
        log_success "Bootstrap installation completed successfully! 🎉"
        echo ""
    else
        local exit_code=$?
        log_error "Bootstrap installation failed with exit code: ${exit_code}"
        log_info "The bootstrap script is available at: ${TEMP_DIR}/${BOOTSTRAP_SCRIPT}"
        log_info "You can inspect it and run it manually if needed"
        rm -rf "${TEMP_DIR}"
        exit "${exit_code}"
    fi

    # Cleanup
    log_info "Cleaning up temporary files..."
    cd "${HOME}" || true
    rm -rf "${TEMP_DIR}"

    echo ""
    log_success "Setup complete! Your macOS system is now configured with Nix-Darwin"
    echo ""
    log_info "Next steps:"
    echo "  1. Restart your terminal to load new shell configuration"
    echo "  2. Verify installation: nix --version && darwin-rebuild --version"
    echo "  3. Check system configuration: darwin-rebuild check"
    echo ""
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo "  --version, -v Show version information"
        echo ""
        echo "Environment Variables:"
        echo "  NIX_INSTALL_BRANCH    Git branch to install from (default: main)"
        echo ""
        echo "This script downloads and runs the Nix-Darwin bootstrap installer."
        echo "It uses a two-stage pattern to ensure interactive prompts work correctly."
        echo ""
        echo "Installation methods:"
        echo "  1. One-line install (recommended):"
        echo "     curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/setup.sh | bash"
        echo ""
        echo "  2. Download and inspect first:"
        echo "     curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/setup.sh -o setup.sh"
        echo "     less setup.sh  # Inspect the script"
        echo "     bash setup.sh"
        echo ""
        exit 0
        ;;
    --version|-v)
        echo "Nix-Darwin Setup Wrapper v1.0.0"
        echo "Repository: https://github.com/${REPO_OWNER}/${REPO_NAME}"
        echo "Branch: ${BRANCH}"
        exit 0
        ;;
esac

# Run main function
main "$@"
