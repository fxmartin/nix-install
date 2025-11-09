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

# =============================================================================
# PHASE 2: USER CONFIG FILE GENERATION FUNCTIONS
# =============================================================================
# Story 01.2-003: User Config File Generation
# These functions generate user-config.nix from collected user information
# Template placeholders are replaced with actual values for personalization
# =============================================================================

# Global variable for user config file path
USER_CONFIG_PATH="/tmp/nix-bootstrap/user-config.nix"

# Create bootstrap work directory for temporary files
# Creates /tmp/nix-bootstrap/ if it doesn't exist
# Returns: 0 on success
create_bootstrap_workdir() {
    local work_dir="/tmp/nix-bootstrap"

    # Create directory with proper permissions (755)
    if ! mkdir -p "${work_dir}"; then
        log_error "Failed to create bootstrap work directory: ${work_dir}"
        return 1
    fi

    return 0
}

# Get current macOS username
# Returns: Current user from $USER variable
get_macos_username() {
    echo "${USER}"
}

# Get and sanitize macOS hostname
# Removes special characters, converts to lowercase
# Only allows: alphanumeric and hyphens
# Returns: Sanitized hostname
get_macos_hostname() {
    local raw_hostname
    raw_hostname=$(hostname)

    # Sanitize hostname:
    # - Convert to lowercase
    # - Replace underscores with hyphens
    # - Remove periods (dots)
    # - Remove all characters except alphanumeric and hyphens
    local sanitized
    sanitized=$(echo "${raw_hostname}" | \
        tr '[:upper:]' '[:lower:]' | \
        tr '_' '-' | \
        tr -d '.' | \
        sed 's/[^a-z0-9-]//g')

    echo "${sanitized}"
}

# Validate basic Nix file syntax
# Checks: file exists, not empty, balanced braces
# Input: path to .nix file
# Returns: 0 if valid, 1 if invalid
validate_nix_syntax() {
    local nix_file="$1"

    # Check file exists
    if [[ ! -f "${nix_file}" ]]; then
        log_error "Nix config file does not exist: ${nix_file}"
        return 1
    fi

    # Check file is readable
    if [[ ! -r "${nix_file}" ]]; then
        log_error "Cannot read Nix config file: ${nix_file}"
        return 1
    fi

    # Check file is not empty
    if [[ ! -s "${nix_file}" ]]; then
        log_error "Nix config file is empty: ${nix_file}"
        return 1
    fi

    # Count opening and closing braces
    local open_braces
    local close_braces
    open_braces=$(grep -o '{' "${nix_file}" | wc -l | tr -d ' ')
    close_braces=$(grep -o '}' "${nix_file}" | wc -l | tr -d ' ')

    # Check braces are balanced
    if [[ "${open_braces}" -ne "${close_braces}" ]]; then
        log_error "Nix config has unbalanced braces: ${open_braces} open, ${close_braces} close"
        return 1
    fi

    # Basic validation passed
    return 0
}

# Display generated config file for user review
# Input: path to config file
# Returns: 0 on success, 1 on error
display_generated_config() {
    local config_file="$1"

    # Check file exists
    if [[ ! -f "${config_file}" ]]; then
        log_error "Config file does not exist: ${config_file}"
        return 1
    fi

    echo ""
    log_info "==================================="
    log_info "Generated User Configuration"
    log_info "==================================="
    echo ""

    # Display file contents
    cat "${config_file}"

    echo ""
    log_info "==================================="
    echo ""

    return 0
}

# Generate user-config.nix from template
# Replaces placeholders with actual user values
# Sets global variable: USER_CONFIG_PATH
# Returns: 0 on success, 1 on error
generate_user_config() {
    log_info "==================================="
    log_info "Phase 3/10: User Config Generation"
    log_info "==================================="
    echo ""

    # Verify required variables are set
    if [[ -z "${USER_FULLNAME:-}" ]]; then
        log_error "USER_FULLNAME is not set. Cannot generate config."
        return 1
    fi

    if [[ -z "${USER_EMAIL:-}" ]]; then
        log_error "USER_EMAIL is not set. Cannot generate config."
        return 1
    fi

    if [[ -z "${GITHUB_USERNAME:-}" ]]; then
        log_error "GITHUB_USERNAME is not set. Cannot generate config."
        return 1
    fi

    # Create work directory
    log_info "Creating bootstrap work directory..."
    if ! create_bootstrap_workdir; then
        log_error "Failed to create work directory"
        return 1
    fi
    log_info "✓ Work directory created"

    # Get system information
    local macos_username
    macos_username=$(get_macos_username)
    log_info "macOS username: ${macos_username}"

    local hostname
    hostname=$(get_macos_hostname)
    log_info "Hostname (sanitized): ${hostname}"

    # Set dotfiles path
    local dotfiles_path="Documents/nix-install"
    log_info "Dotfiles path: ${dotfiles_path}"

    echo ""
    log_info "Generating user configuration file..."

    # Check template exists
    local template_file="user-config.template.nix"
    if [[ ! -f "${template_file}" ]]; then
        log_error "Template file not found: ${template_file}"
        log_error "Please ensure you're running this script from the project root directory."
        return 1
    fi

    # Replace placeholders and generate config file
    if ! sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${template_file}" > "${USER_CONFIG_PATH}"; then
        log_error "Failed to generate user config file"
        return 1
    fi

    log_info "✓ Config file generated: ${USER_CONFIG_PATH}"

    # Validate generated file
    echo ""
    log_info "Validating generated config syntax..."
    if ! validate_nix_syntax "${USER_CONFIG_PATH}"; then
        log_error "Generated config file has invalid syntax"
        return 1
    fi
    log_info "✓ Config file syntax validated"

    # Display generated config for user review
    display_generated_config "${USER_CONFIG_PATH}"

    log_info "✓ User configuration generated successfully"
    echo ""

    return 0
}

# =============================================================================
# PHASE 2: PROFILE SELECTION FUNCTIONS
# =============================================================================
# Story 01.2-002: Profile Selection System
# These functions allow FX to choose between Standard and Power installation profiles
# Standard: MacBook Air - essential apps, 1 Ollama model (~35GB)
# Power: MacBook Pro M3 Max - all apps, 4 Ollama models, Parallels (~120GB)
# =============================================================================

# Validate profile choice input (must be 1 or 2)
# Returns: 0 if valid (1 or 2), 1 otherwise
validate_profile_choice() {
    local choice="$1"

    # Reject empty input
    if [[ -z "$choice" ]]; then
        return 1
    fi

    # Accept only 1 or 2
    if [[ "$choice" == "1" ]] || [[ "$choice" == "2" ]]; then
        return 0
    fi

    # All other inputs are invalid
    return 1
}

# Convert numeric profile choice to profile name
# Input: "1" or "2" (or invalid input)
# Output: "standard" or "power"
# Defaults to "standard" for invalid input
convert_profile_choice_to_name() {
    local choice="$1"

    case "$choice" in
        1)
            echo "standard"
            ;;
        2)
            echo "power"
            ;;
        *)
            # Default to standard for any invalid input
            echo "standard"
            ;;
    esac
}

# Display profile options with descriptions
# Shows both Standard and Power profiles with:
# - Target hardware (MacBook Air vs MacBook Pro M3 Max)
# - App count and key differences
# - Ollama model count
# - Disk usage estimates
display_profile_options() {
    echo ""
    log_info "==================================="
    log_info "Available Installation Profiles"
    log_info "==================================="
    echo ""
    echo "1) Standard Profile"
    echo "   Target:         MacBook Air"
    echo "   Apps:           Essential apps only"
    echo "   Ollama Models:  1 Ollama model (gpt-oss:20b)"
    echo "   Virtualization: no virtualization"
    echo "   Disk Usage:     ~35GB"
    echo ""
    echo "2) Power Profile"
    echo "   Target:         MacBook Pro M3 Max"
    echo "   Apps:           All apps + Parallels Desktop"
    echo "   Ollama Models:  4 Ollama models (gpt-oss:20b, qwen2.5-coder:32b,"
    echo "                   llama3.1:70b, deepseek-r1:32b)"
    echo "   Virtualization: Parallels Desktop"
    echo "   Disk Usage:     ~120GB"
    echo ""
}

# Get display name for profile confirmation
# Input: "standard" or "power"
# Output: "Standard Profile" or "Power Profile"
get_profile_display_name() {
    local profile="$1"

    case "$profile" in
        standard)
            echo "Standard Profile (MacBook Air - ~35GB)"
            ;;
        power)
            echo "Power Profile (MacBook Pro M3 Max - ~120GB)"
            ;;
        *)
            echo "Unknown Profile"
            ;;
    esac
}

# Confirm profile choice with user
# Input: profile name ("standard" or "power")
# Returns: 0 if confirmed (y), 1 if rejected (n)
confirm_profile_choice() {
    local profile="$1"
    local display_name
    display_name=$(get_profile_display_name "$profile")

    echo ""
    log_info "You selected: $display_name"
    echo ""

    local confirmed
    read -r -p "Continue with this profile? (y/n): " confirmed

    if [[ "$confirmed" == "y" ]]; then
        return 0
    else
        return 1
    fi
}

# Main profile selection function
# Sets global variable: INSTALL_PROFILE ("standard" or "power")
# Interactive prompt with validation and confirmation
select_installation_profile() {
    log_info "==================================="
    log_info "Phase 2/10: Profile Selection"
    log_info "==================================="
    echo ""
    log_info "Choose the installation profile for this MacBook."
    log_info "This determines which apps and models will be installed."

    local profile_confirmed="n"

    # Loop until user confirms profile choice
    while [[ "$profile_confirmed" != "y" ]]; do
        # Display profile options
        display_profile_options

        # Prompt for profile choice
        local choice
        while true; do
            read -r -p "Enter your choice (1 or 2): " choice

            if validate_profile_choice "$choice"; then
                log_info "✓ Profile choice validated"
                break
            else
                log_error "Invalid choice. Please enter 1 for Standard or 2 for Power."
            fi
        done

        # Convert choice to profile name
        INSTALL_PROFILE=$(convert_profile_choice_to_name "$choice")

        # Confirm profile choice
        if confirm_profile_choice "$INSTALL_PROFILE"; then
            profile_confirmed="y"
        else
            log_warn "Let's choose a different profile."
            echo ""
        fi
    done

    echo ""
    log_info "✓ Installation profile selected: $INSTALL_PROFILE"
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

# =============================================================================
# PHASE 3: XCODE COMMAND LINE TOOLS INSTALLATION
# =============================================================================
# Story 01.3-001: Xcode CLI Tools Installation
# These functions install Xcode Command Line Tools which provide essential
# build dependencies for Nix and other development tools.
# =============================================================================

# Check if Xcode Command Line Tools are installed
# Returns: 0 if installed, 1 if not installed
check_xcode_installed() {
    if xcode-select -p &>/dev/null; then
        log_info "Xcode CLI Tools already installed at: $(xcode-select -p)"
        return 0
    else
        log_info "Xcode CLI Tools not installed"
        return 1
    fi
}

# Trigger Xcode CLI Tools installation dialog
# Returns: 0 if dialog opened successfully, 1 on failure
install_xcode_cli_tools() {
    log_info "Starting Xcode CLI Tools installation..."
    echo ""

    if ! xcode-select --install 2>/dev/null; then
        log_error "Failed to trigger Xcode CLI Tools installation"
        log_error "The installation may already be in progress"
        return 1
    fi

    log_info "✓ Installation dialog opened"
    return 0
}

# Wait for user to complete Xcode installation dialog
# This function is interactive and waits for user confirmation
# Returns: 0 when user presses ENTER
wait_for_xcode_installation() {
    echo ""
    log_info "======================================"
    log_info "MANUAL STEP REQUIRED"
    log_info "======================================"
    echo ""
    log_info "A system dialog has appeared asking to install Xcode Command Line Tools."
    log_info "Please:"
    log_info "  1. Click 'Install' in the dialog"
    log_info "  2. Wait for installation to complete (5-10 minutes)"
    log_info "  3. Return here and press ENTER to continue"
    echo ""

    read -r -p "Press ENTER when installation is complete... "
    echo ""
    return 0
}

# Accept Xcode license agreement
# Requires sudo password
# Returns: 0 if license accepted, 1 on failure
accept_xcode_license() {
    log_info "Accepting Xcode license agreement..."
    echo ""

    sudo xcodebuild -license accept 2>/dev/null
    local exit_code=$?

    if [[ ${exit_code} -eq 0 ]]; then
        log_info "✓ Xcode license accepted"
        return 0
    elif [[ ${exit_code} -eq 69 ]]; then
        log_warn "License already accepted or not required"
        return 0
    else
        log_error "Failed to accept Xcode license (exit code: ${exit_code})"
        log_error "You may need to run: sudo xcodebuild -license accept"
        return 1
    fi
}

# Verify Xcode CLI Tools installation succeeded
# Returns: 0 if verified, 1 on failure
verify_xcode_installation() {
    log_info "Verifying Xcode CLI Tools installation..."
    echo ""

    if ! xcode-select -p &>/dev/null; then
        log_error "Xcode CLI Tools verification failed"
        log_error "Installation may not have completed successfully"
        log_error "Please try running: xcode-select --install"
        return 1
    fi

    local xcode_path
    xcode_path=$(xcode-select -p)

    log_info "✓ Xcode CLI Tools installed successfully"
    log_info "  Path: ${xcode_path}"
    echo ""
    return 0
}

# Phase 3: Install Xcode Command Line Tools
# Main orchestration function for Xcode installation
# Returns: 0 on success (installed or already present), 1 on failure
install_xcode_phase() {
    log_info "========================================"
    log_info "Phase 3/10: Xcode Command Line Tools"
    log_info "========================================"
    echo ""

    # Check if already installed
    if check_xcode_installed; then
        log_info "✓ Xcode CLI Tools already installed, skipping installation"
        echo ""
        return 0
    fi

    # Trigger installation
    if ! install_xcode_cli_tools; then
        log_error "Failed to start Xcode CLI Tools installation"
        return 1
    fi

    # Wait for user to complete installation
    wait_for_xcode_installation

    # Verify installation completed
    if ! verify_xcode_installation; then
        log_error "Xcode CLI Tools installation verification failed"
        return 1
    fi

    # Accept license
    if ! accept_xcode_license; then
        log_warn "License acceptance failed, but installation succeeded"
        log_warn "You may need to accept manually later"
    fi

    log_info "✓ Xcode CLI Tools installation phase complete"
    echo ""
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
    # PHASE 2: USER CONFIGURATION & PROFILE SELECTION
    # ==========================================================================
    # This is the first phase with interactive prompts, which is why the
    # two-stage bootstrap pattern exists - to ensure stdin works correctly.
    # ==========================================================================

    # Story 01.2-001: Collect user information (name, email, GitHub username)
    prompt_user_info

    # Story 01.2-002: Select installation profile (Standard vs Power)
    select_installation_profile

    # Story 01.2-003: Generate user-config.nix from collected information
    # shellcheck disable=SC2310  # Intentional: Using ! to handle validation failure
    if ! generate_user_config; then
        log_error "Failed to generate user configuration file"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 3: XCODE COMMAND LINE TOOLS INSTALLATION
    # ==========================================================================
    # Story 01.3-001: Install Xcode CLI Tools (required for Nix builds)
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle installation failure
    if ! install_xcode_phase; then
        log_error "Xcode CLI Tools installation failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # FUTURE PHASES (4-10)
    # ==========================================================================
    # Future phases will be added here in subsequent stories
    log_warn "Bootstrap implementation incomplete - Phases 4-10 not yet implemented"
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
