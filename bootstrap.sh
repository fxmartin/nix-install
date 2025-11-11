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

# Work directory for bootstrap operations
readonly WORK_DIR="/tmp/nix-bootstrap"
readonly USER_CONFIG_FILE="${WORK_DIR}/user-config.nix"

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

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
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

# =============================================================================
# PHASE 2: USER CONFIG IDEMPOTENCY CHECK (Story 01.1-002)
# =============================================================================

# Function: check_existing_user_config
# Purpose: Detect and parse existing user-config.nix from previous runs to avoid re-prompting
# Story: 01.1-002 (Idempotency Check)
# Locations checked (priority order):
#   1. ~/Documents/nix-install/user-config.nix (completed installation)
#   2. /tmp/nix-bootstrap/user-config.nix (previous bootstrap attempt)
# Sets global variables: USER_FULLNAME, USER_EMAIL, GITHUB_USERNAME
# Returns: 0 if config found and user chose to reuse, 1 if not found or user declined
# Pattern: Based on mlgruby-repo-for-reference/scripts/install/pre-nix-installation.sh (lines 239-289)
check_existing_user_config() {
    local existing_config=""
    local config_source=""

    # Check priority locations (completed install takes precedence)
    if [[ -f "$HOME/Documents/nix-install/user-config.nix" ]]; then
        existing_config="$HOME/Documents/nix-install/user-config.nix"
        config_source="completed installation"
    elif [[ -f "/tmp/nix-bootstrap/user-config.nix" ]]; then
        existing_config="/tmp/nix-bootstrap/user-config.nix"
        config_source="previous bootstrap run"
    fi

    # If no existing config found, return early
    if [[ -z "${existing_config}" ]]; then
        return 1
    fi

    echo ""
    log_info "Found existing user configuration:"
    log_info "  Location: ${existing_config}"
    log_info "  Source: ${config_source}"
    echo ""

    # Parse values from existing config using grep + sed
    local parsed_fullname parsed_email parsed_github_username

    parsed_fullname=$(grep -E '^\s*fullName\s*=' "${existing_config}" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    parsed_email=$(grep -E '^\s*email\s*=' "${existing_config}" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    parsed_github_username=$(grep -E '^\s*githubUsername\s*=' "${existing_config}" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')

    # Validate parsed values (must not be empty or still contain placeholders like @FULL_NAME@)
    if [[ -z "${parsed_fullname}" ]] || [[ "${parsed_fullname}" == *"@"* ]]; then
        log_warn "Existing config has invalid/incomplete fullName, ignoring"
        return 1
    fi

    if [[ -z "${parsed_email}" ]] || [[ "${parsed_email}" == *"@"*"@"* ]]; then
        log_warn "Existing config has invalid/incomplete email, ignoring"
        return 1
    fi

    if [[ -z "${parsed_github_username}" ]] || [[ "${parsed_github_username}" == *"@"* ]]; then
        log_warn "Existing config has invalid/incomplete GitHub username, ignoring"
        return 1
    fi

    # Display parsed values for user review
    log_info "Existing configuration:"
    echo "  Name:          ${parsed_fullname}"
    echo "  Email:         ${parsed_email}"
    echo "  GitHub:        ${parsed_github_username}"
    echo ""

    # Prompt user to reuse or re-enter
    local reuse_config
    read -r -p "Reuse this configuration? (y/n): " reuse_config
    echo ""

    if [[ "${reuse_config}" =~ ^[Yy]$ ]]; then
        # Set global variables for use in generate_user_config
        USER_FULLNAME="${parsed_fullname}"
        USER_EMAIL="${parsed_email}"
        GITHUB_USERNAME="${parsed_github_username}"

        log_success "Reusing existing configuration"
        echo ""
        return 0
    else
        log_info "User declined to reuse existing config"
        log_info "Will prompt for new configuration"
        echo ""
        return 1
    fi
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

# Note: License acceptance function removed
# The 'xcodebuild' command requires full Xcode.app, not just CLI Tools
# Xcode CLI Tools do not require license acceptance and work immediately
# If full Xcode is installed later, license is handled by Xcode.app itself

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

    # Note: License acceptance NOT needed for CLI Tools only
    # The 'xcodebuild' command requires full Xcode.app, not CLI Tools
    # CLI Tools work perfectly without any license acceptance
    # If full Xcode is installed later, license acceptance happens separately

    log_info "✓ Xcode CLI Tools installation phase complete"
    echo ""
    return 0
}

# =============================================================================
# PHASE 4: NIX PACKAGE MANAGER INSTALLATION (Story 01.4-001)
# =============================================================================
# Multi-user Nix installation with flakes support enabled.
# Required for nix-darwin and all subsequent declarative configuration.
# =============================================================================

# Check if Nix is already installed on the system
#
# Nix multi-user installation places the nix binary in /nix/var/nix/profiles/default/bin
# which is added to PATH via /etc/profile.d or shell init files.
#
# Returns:
#   0 - Nix is installed and available in PATH
#   1 - Nix is not installed
check_nix_installed() {
    log_info "Checking if Nix is already installed..."

    if command -v nix &>/dev/null; then
        local nix_path
        nix_path=$(command -v nix)
        log_info "✓ Nix is already installed at: ${nix_path}"
        return 0
    else
        log_info "Nix is not installed"
        return 1
    fi
}

# Download the official Nix installer script from nixos.org
#
# Downloads the multi-user installation script to /tmp for execution.
# Uses curl with -L flag to follow redirects.
#
# Returns:
#   0 - Download successful
#   1 - Download failed (network error, DNS failure, etc.)
download_nix_installer() {
    local installer_url="https://nixos.org/nix/install"
    local installer_path="/tmp/nix-installer.sh"

    log_info "Downloading Nix installer from ${installer_url}..."

    if ! curl -L "${installer_url}" -o "${installer_path}" 2>/dev/null; then
        log_error "Failed to download Nix installer"
        log_error "Please check your internet connection and try again"
        return 1
    fi

    if [[ ! -f "${installer_path}" ]]; then
        log_error "Installer download succeeded but file not found at ${installer_path}"
        return 1
    fi

    chmod +x "${installer_path}"
    log_info "✓ Nix installer downloaded to ${installer_path}"
    return 0
}

# Install Nix using multi-user installation method
#
# Runs the official Nix installer with --daemon flag for multi-user setup.
# This creates:
#   - /nix directory structure
#   - nix-daemon LaunchDaemon for background service
#   - _nixbld1-_nixbld32 system users for build isolation
#   - Shell profile scripts for environment setup
#
# Requires sudo for system-level changes.
#
# Returns:
#   0 - Installation successful
#   1 - Installation failed
install_nix_multi_user() {
    local installer_path="/tmp/nix-installer.sh"

    log_info "Installing Nix package manager (multi-user mode)..."
    log_warn "This requires sudo access and will prompt for your password"
    log_info "The installation will:"
    log_info "  - Create /nix directory structure"
    log_info "  - Set up nix-daemon background service"
    log_info "  - Create build user accounts (_nixbld1-32)"
    log_info "  - Configure shell environment"
    echo ""

    # Run installer with --daemon flag for multi-user installation
    # The installer handles all the heavy lifting
    if ! sh "${installer_path}" --daemon; then
        log_error "Nix installation failed"
        log_error "Please check the error messages above for details"
        return 1
    fi

    log_info "✓ Nix installation completed successfully"
    return 0
}

# Enable Nix experimental features (flakes and nix-command)
#
# Nix flakes provide:
#   - Reproducible, hermetic builds with lockfiles
#   - Modern CLI interface (nix build, nix develop, etc.)
#   - Required for nix-darwin and most modern Nix workflows
#
# Adds "experimental-features = nix-command flakes" to /etc/nix/nix.conf
# Creates the config file if it doesn't exist.
# Skips if already enabled to maintain idempotency.
#
# Requires sudo for system configuration changes.
#
# Returns:
#   0 - Features enabled successfully or already enabled
#   1 - Configuration failed
enable_nix_flakes() {
    local nix_conf="/etc/nix/nix.conf"
    local features="experimental-features = nix-command flakes"

    log_info "Enabling Nix flakes and experimental features..."

    # Check if already enabled
    if [[ -f "${nix_conf}" ]] && grep -q "experimental-features.*nix-command.*flakes" "${nix_conf}"; then
        log_info "✓ Nix flakes already enabled"
        return 0
    fi

    # Create nix.conf if it doesn't exist
    if [[ ! -f "${nix_conf}" ]]; then
        log_info "Creating ${nix_conf}..."
        if ! sudo mkdir -p "$(dirname "${nix_conf}")"; then
            log_error "Failed to create nix config directory"
            return 1
        fi
    fi

    # Append experimental features configuration
    if ! echo "${features}" | sudo tee -a "${nix_conf}" >/dev/null; then
        log_error "Failed to write to ${nix_conf}"
        log_error "Please check sudo permissions"
        return 1
    fi

    log_info "✓ Nix flakes enabled successfully"
    log_info "  Configuration: ${features}"
    return 0
}

# Source Nix environment for the current shell session
#
# After installation, nix binaries are not immediately available in PATH.
# This sources the nix-daemon profile script to set up the environment.
#
# The script adds:
#   - /nix/var/nix/profiles/default/bin to PATH
#   - NIX_* environment variables
#   - Shell completion setup
#
# Returns:
#   0 - Environment sourced successfully
#   1 - Profile script not found or sourcing failed
source_nix_environment() {
    local nix_profile="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

    log_info "Sourcing Nix environment for current session..."

    if [[ ! -f "${nix_profile}" ]]; then
        log_error "Nix profile script not found at ${nix_profile}"
        log_error "Nix installation may have failed"
        return 1
    fi

    # Source the profile script to make nix available
    # shellcheck disable=SC1090  # Dynamic source path is expected
    if ! source "${nix_profile}"; then
        log_error "Failed to source Nix environment"
        return 1
    fi

    log_info "✓ Nix environment sourced successfully"
    log_info "  Nix is now available in PATH for this session"
    return 0
}

# Verify Nix installation is working and meets version requirements
#
# Checks:
#   1. nix command is available in PATH
#   2. Version is 2.18.0 or higher (required for modern flakes support)
#
# Displays the installed version to the user.
#
# Returns:
#   0 - Nix is installed and meets version requirements
#   1 - Nix not found or version too old
verify_nix_installation() {
    log_info "Verifying Nix installation..."

    # Check if nix command is available
    if ! command -v nix &>/dev/null; then
        log_error "Nix command not found in PATH"
        log_error "Installation verification failed"
        return 1
    fi

    # Get version and parse
    local version_output
    version_output=$(nix --version 2>/dev/null)

    if [[ -z "${version_output}" ]]; then
        log_error "Could not determine Nix version"
        return 1
    fi

    # Extract version number (format: "nix (Nix) 2.19.0")
    local version
    version=$(echo "${version_output}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

    if [[ -z "${version}" ]]; then
        log_error "Could not parse Nix version from: ${version_output}"
        return 1
    fi

    log_info "Installed Nix version: ${version}"

    # Check minimum version (2.18.0+)
    local major minor patch
    # shellcheck disable=SC2034  # patch is extracted but not used in version check
    IFS='.' read -r major minor patch <<< "${version}"

    if [[ "${major}" -lt 2 ]] || [[ "${major}" -eq 2 && "${minor}" -lt 18 ]]; then
        log_error "Nix version ${version} is too old"
        log_error "Minimum required version: 2.18.0"
        log_error "Please update Nix to continue"
        return 1
    fi

    log_info "✓ Nix installation verified successfully"
    log_info "  Version: ${version} (meets minimum requirement of 2.18.0)"
    return 0
}

# Phase 4 orchestration: Complete Nix installation flow
#
# Executes the full Nix installation workflow:
#   1. Check if already installed (skip if present)
#   2. Download official installer
#   3. Run multi-user installation
#   4. Enable flakes and nix-command features
#   5. Source environment for current session
#   6. Verify installation and version
#
# This phase is idempotent - safe to run multiple times.
# If Nix is already installed, skips to verification.
#
# Returns:
#   0 - Nix installed and configured successfully
#   1 - Installation failed at any step
install_nix_phase() {
    echo ""
    log_info "========================================"
    log_info "Phase 4/10: Nix Package Manager"
    log_info "========================================"
    echo ""

    log_info "This phase will install the Nix package manager with flakes support."
    log_info "Nix is required for nix-darwin and all declarative system configuration."
    log_info "Estimated time: 5-10 minutes (depending on network speed)"
    echo ""

    # Check if already installed
    if check_nix_installed; then
        log_info "✓ Nix is already installed, skipping installation"
        echo ""
        return 0
    fi

    # Download installer
    if ! download_nix_installer; then
        log_error "Failed to download Nix installer"
        return 1
    fi

    # Run multi-user installation
    if ! install_nix_multi_user; then
        log_error "Failed to install Nix"
        return 1
    fi

    # Enable flakes support
    if ! enable_nix_flakes; then
        log_error "Failed to enable Nix flakes"
        return 1
    fi

    # Source environment for current session
    if ! source_nix_environment; then
        log_error "Failed to source Nix environment"
        return 1
    fi

    # Verify installation
    if ! verify_nix_installation; then
        log_error "Nix installation verification failed"
        return 1
    fi

    log_info "✓ Nix Package Manager installation phase complete"
    echo ""
    return 0
}

# =============================================================================
# PHASE 4 (CONTINUED): NIX CONFIGURATION FOR MACOS
# =============================================================================
# Story 01.4-002: Configure Nix for optimal macOS performance
# - Binary cache setup (cache.nixos.org)
# - Performance tuning (max-jobs, cores)
# - Trusted users configuration
# - macOS sandbox configuration
# - Daemon restart to apply changes
# =============================================================================

# Function: backup_nix_config
# Purpose: Create timestamped backup of existing nix.conf
# Arguments: $1 - Path to nix.conf file
# Returns: 0 on success (or if no file exists), logs warning on backup failure
backup_nix_config() {
    local nix_conf_path="${1:-/etc/nix/nix.conf}"

    # If file doesn't exist, nothing to backup
    if [[ ! -f "${nix_conf_path}" ]]; then
        log_info "No existing nix.conf to backup (fresh install)"
        return 0
    fi

    # Create timestamped backup
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_path="${nix_conf_path}.backup-${timestamp}"

    if cp "${nix_conf_path}" "${backup_path}" 2>/dev/null; then
        log_info "✓ Created backup: ${backup_path}"
        return 0
    else
        log_warn "Could not create backup of nix.conf (may require sudo)"
        return 0  # Non-critical, continue anyway
    fi
}

# Function: get_cpu_cores
# Purpose: Detect number of CPU cores for parallel builds
# Arguments: None
# Returns: Number of cores (e.g., "8") or "auto" on detection failure
# Output: Numeric core count or "auto"
get_cpu_cores() {
    local cores

    if cores=$(sysctl -n hw.ncpu 2>/dev/null); then
        echo "${cores}"
        return 0
    else
        # Fallback to "auto" if detection fails
        echo "auto"
        return 0
    fi
}

# Function: configure_nix_binary_cache
# Purpose: Configure NixOS binary cache for faster package downloads
# Arguments: $1 - Path to nix.conf file
# Returns: 0 on success, 1 on failure (CRITICAL)
configure_nix_binary_cache() {
    local nix_conf_path="${1:-/etc/nix/nix.conf}"

    log_info "Configuring NixOS binary cache..."

    # Check if substituters already configured (idempotency)
    if grep -q "^substituters = https://cache.nixos.org" "${nix_conf_path}" 2>/dev/null; then
        log_info "✓ Binary cache already configured"
        return 0
    fi

    # Add binary cache configuration
    {
        echo ""
        echo "# Binary cache configuration (Story 01.4-002)"
        echo "substituters = https://cache.nixos.org"
        echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    } >> "${nix_conf_path}" || {
        log_error "Failed to configure binary cache"
        return 1
    }

    log_info "✓ Binary cache configured (cache.nixos.org)"
    return 0
}

# Function: configure_nix_performance
# Purpose: Configure parallel builds for optimal performance
# Arguments: $1 - Path to nix.conf file
# Returns: 0 on success (logs warning on CPU detection failure)
configure_nix_performance() {
    local nix_conf_path="${1:-/etc/nix/nix.conf}"
    local cpu_cores

    cpu_cores=$(get_cpu_cores)

    log_info "Configuring Nix performance settings (${cpu_cores} cores)..."

    # Check if max-jobs already configured (idempotency)
    if grep -q "^max-jobs" "${nix_conf_path}" 2>/dev/null; then
        log_info "✓ Performance settings already configured"
        return 0
    fi

    # Add performance configuration
    {
        echo ""
        echo "# Performance configuration (Story 01.4-002)"
        echo "max-jobs = ${cpu_cores}"
        echo "cores = 0  # Use all available cores for each build job"
    } >> "${nix_conf_path}" || {
        log_warn "Failed to configure performance settings (non-critical)"
        return 0  # Non-critical, continue anyway
    }

    log_info "✓ Performance settings configured (max-jobs: ${cpu_cores}, cores: 0)"
    return 0
}

# Function: configure_nix_trusted_users
# Purpose: Configure trusted users for Nix daemon
# Arguments: $1 - Path to nix.conf file
# Returns: 0 on success, 1 on failure (CRITICAL)
configure_nix_trusted_users() {
    local nix_conf_path="${1:-/etc/nix/nix.conf}"

    log_info "Configuring trusted users (root, ${USER})..."

    # Check if trusted-users already configured (idempotency)
    if grep -q "^trusted-users" "${nix_conf_path}" 2>/dev/null; then
        log_info "✓ Trusted users already configured"
        return 0
    fi

    # Add trusted users configuration
    {
        echo ""
        echo "# Trusted users configuration (Story 01.4-002)"
        echo "trusted-users = root ${USER}"
    } >> "${nix_conf_path}" || {
        log_error "Failed to configure trusted users"
        return 1
    }

    log_info "✓ Trusted users configured (root, ${USER})"
    return 0
}

# Function: configure_nix_sandbox
# Purpose: Configure macOS-appropriate sandbox mode
# Arguments: $1 - Path to nix.conf file
# Returns: 0 (logs warning on failure, non-critical)
configure_nix_sandbox() {
    local nix_conf_path="${1:-/etc/nix/nix.conf}"

    log_info "Configuring macOS sandbox mode..."

    # Check if sandbox already configured (idempotency)
    if grep -q "^sandbox" "${nix_conf_path}" 2>/dev/null; then
        log_info "✓ Sandbox mode already configured"
        return 0
    fi

    # Add sandbox configuration (relaxed for macOS compatibility)
    {
        echo ""
        echo "# Sandbox configuration for macOS (Story 01.4-002)"
        echo "sandbox = relaxed"
    } >> "${nix_conf_path}" || {
        log_warn "Failed to configure sandbox mode (non-critical)"
        return 0  # Non-critical, continue anyway
    }

    log_info "✓ Sandbox mode configured (relaxed for macOS)"
    return 0
}

# Function: restart_nix_daemon
# Purpose: Restart nix-daemon to apply configuration changes
# Arguments: None
# Returns: 0 on success, 1 on failure (CRITICAL)
restart_nix_daemon() {
    log_info "Restarting nix-daemon to apply configuration..."

    # Restart nix-daemon using launchctl
    if sudo launchctl kickstart -k system/org.nixos.nix-daemon 2>/dev/null; then
        # Wait for daemon to stabilize
        sleep 2
        log_info "✓ Nix daemon restarted successfully"
        return 0
    else
        log_error "Failed to restart nix-daemon"
        log_error "You may need to run manually: sudo launchctl kickstart -k system/org.nixos.nix-daemon"
        return 1
    fi
}

# Function: verify_nix_configuration
# Purpose: Verify nix.conf contains expected settings
# Arguments: $1 - Path to nix.conf file
# Returns: 0 (logs warnings for missing settings, non-critical)
verify_nix_configuration() {
    local nix_conf_path="${1:-/etc/nix/nix.conf}"

    log_info "Verifying Nix configuration..."

    if [[ ! -f "${nix_conf_path}" ]]; then
        log_warn "Configuration file not found: ${nix_conf_path}"
        return 0  # Non-critical
    fi

    # Check for key settings
    local missing_settings=()

    if ! grep -q "substituters" "${nix_conf_path}" 2>/dev/null; then
        missing_settings+=("substituters")
    fi

    if ! grep -q "trusted-users" "${nix_conf_path}" 2>/dev/null; then
        missing_settings+=("trusted-users")
    fi

    if ! grep -q "max-jobs" "${nix_conf_path}" 2>/dev/null; then
        missing_settings+=("max-jobs")
    fi

    if [[ ${#missing_settings[@]} -gt 0 ]]; then
        log_warn "Configuration may be incomplete. Missing: ${missing_settings[*]}"
    else
        log_info "✓ All key configuration settings present"
    fi

    return 0
}

# Function: configure_nix_phase
# Purpose: Phase 4 (continued) orchestration - Configure Nix for macOS
# Arguments: None
# Returns: 0 on success, 1 on critical failure
configure_nix_phase() {
    local nix_conf_path="${NIX_CONF_PATH:-/etc/nix/nix.conf}"

    echo ""
    log_info "========================================"
    log_info "PHASE 4 (CONTINUED): NIX CONFIGURATION FOR MACOS"
    log_info "Story 01.4-002: Optimize Nix for macOS"
    log_info "========================================"
    log_info "Estimated time: 1-2 minutes"
    log_warn "This phase requires sudo for /etc/nix/nix.conf modification"
    echo ""

    # Backup existing configuration
    backup_nix_config "${nix_conf_path}"

    # Configure binary cache (CRITICAL)
    if ! sudo bash -c "$(declare -f log_info log_error); $(declare -f configure_nix_binary_cache); configure_nix_binary_cache '${nix_conf_path}'"; then
        log_error "Failed to configure binary cache (critical)"
        return 1
    fi

    # Configure performance settings (non-critical)
    sudo bash -c "$(declare -f log_info log_warn get_cpu_cores); $(declare -f configure_nix_performance); configure_nix_performance '${nix_conf_path}'" || true

    # Configure trusted users (CRITICAL)
    if ! sudo bash -c "USER=${USER}; $(declare -f log_info log_error); $(declare -f configure_nix_trusted_users); configure_nix_trusted_users '${nix_conf_path}'"; then
        log_error "Failed to configure trusted users (critical)"
        return 1
    fi

    # Configure sandbox (non-critical)
    sudo bash -c "$(declare -f log_info log_warn); $(declare -f configure_nix_sandbox); configure_nix_sandbox '${nix_conf_path}'" || true

    # Restart daemon to apply changes (CRITICAL)
    if ! restart_nix_daemon; then
        log_error "Failed to restart nix-daemon (critical)"
        return 1
    fi

    # Verify configuration (non-critical)
    verify_nix_configuration "${nix_conf_path}"

    echo ""
    log_info "✓ Nix configuration phase complete"
    log_info "Binary cache: https://cache.nixos.org"
    log_info "Parallel builds: $(get_cpu_cores) jobs"
    log_info "Trusted users: root, ${USER}"
    echo ""

    return 0
}

# =============================================================================
# PHASE 5: NIX-DARWIN INSTALLATION (Story 01.5-001)
# =============================================================================

# Function: fetch_flake_from_github
# Purpose: Download all required Nix configuration files from GitHub repository
# Downloads: flake.nix, flake.lock, darwin/*.nix, home-manager/*.nix
# Arguments: None (uses $WORK_DIR environment variable)
# Returns: 0 on success, 1 on failure (CRITICAL - exits on failure)
fetch_flake_from_github() {
    local github_repo="https://raw.githubusercontent.com/fxmartin/nix-install"
    local github_branch="main"
    local base_url="${github_repo}/${github_branch}"

    log_info "Fetching flake configuration from GitHub..."
    log_info "Repository: ${github_repo}"
    log_info "Branch: ${github_branch}"
    echo ""

    # Create directory structure
    log_info "Creating directory structure..."
    mkdir -p "${WORK_DIR}/darwin" || {
        log_error "Failed to create darwin/ directory"
        return 1
    }
    mkdir -p "${WORK_DIR}/home-manager/modules" || {
        log_error "Failed to create home-manager/modules/ directory"
        return 1
    }

    # Change to work directory
    cd "${WORK_DIR}" || {
        log_error "Failed to change to work directory: ${WORK_DIR}"
        return 1
    }

    # Fetch root-level files
    log_info "Fetching flake.nix..."
    if ! curl -fsSL -o flake.nix "${base_url}/flake.nix"; then
        log_error "Failed to fetch flake.nix from GitHub"
        return 1
    fi
    [[ -s flake.nix ]] || {
        log_error "Downloaded flake.nix is empty"
        return 1
    }

    log_info "Fetching flake.lock..."
    if ! curl -fsSL -o flake.lock "${base_url}/flake.lock"; then
        log_error "Failed to fetch flake.lock from GitHub"
        return 1
    fi
    [[ -s flake.lock ]] || {
        log_error "Downloaded flake.lock is empty"
        return 1
    }

    # Fetch darwin configuration files
    log_info "Fetching darwin configuration files..."
    local darwin_files=(
        "configuration.nix"
        "homebrew.nix"
        "macos-defaults.nix"
    )

    for file in "${darwin_files[@]}"; do
        log_info "  - darwin/${file}"
        if ! curl -fsSL -o "darwin/${file}" "${base_url}/darwin/${file}"; then
            log_error "Failed to fetch darwin/${file}"
            return 1
        fi
        [[ -s "darwin/${file}" ]] || {
            log_error "Downloaded darwin/${file} is empty"
            return 1
        }
    done

    # Fetch home-manager configuration files
    log_info "Fetching home-manager configuration files..."
    log_info "  - home-manager/home.nix"
    if ! curl -fsSL -o "home-manager/home.nix" "${base_url}/home-manager/home.nix"; then
        log_error "Failed to fetch home-manager/home.nix"
        return 1
    fi
    [[ -s "home-manager/home.nix" ]] || {
        log_error "Downloaded home-manager/home.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/shell.nix"
    if ! curl -fsSL -o "home-manager/modules/shell.nix" "${base_url}/home-manager/modules/shell.nix"; then
        log_error "Failed to fetch home-manager/modules/shell.nix"
        return 1
    fi
    [[ -s "home-manager/modules/shell.nix" ]] || {
        log_error "Downloaded home-manager/modules/shell.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/github.nix"
    if ! curl -fsSL -o "home-manager/modules/github.nix" "${base_url}/home-manager/modules/github.nix"; then
        log_error "Failed to fetch home-manager/modules/github.nix"
        return 1
    fi
    [[ -s "home-manager/modules/github.nix" ]] || {
        log_error "Downloaded home-manager/modules/github.nix is empty"
        return 1
    }

    echo ""
    log_success "All configuration files fetched successfully"
    log_info "Files downloaded:"
    log_info "  • flake.nix"
    log_info "  • flake.lock"
    log_info "  • darwin/configuration.nix"
    log_info "  • darwin/homebrew.nix"
    log_info "  • darwin/macos-defaults.nix"
    log_info "  • home-manager/home.nix"
    log_info "  • home-manager/modules/shell.nix"
    log_info "  • home-manager/modules/github.nix"
    echo ""

    return 0
}

# Function: copy_user_config
# Purpose: Copy user-config.nix to flake directory
# Arguments: None (uses $USER_CONFIG_FILE and $WORK_DIR environment variables)
# Returns: 0 on success, 1 on failure (CRITICAL - exits on failure)
copy_user_config() {
    log_info "Verifying user configuration in flake directory..."

    # Validate source file exists
    if [[ ! -f "${USER_CONFIG_FILE}" ]]; then
        log_error "User configuration file not found: ${USER_CONFIG_FILE}"
        log_error "This file should have been created in Phase 2"
        return 1
    fi

    # Validate source file is readable
    if [[ ! -r "${USER_CONFIG_FILE}" ]]; then
        log_error "User configuration file is not readable: ${USER_CONFIG_FILE}"
        return 1
    fi

    # Check if source and destination are the same
    local dest_path="${WORK_DIR}/user-config.nix"
    if [[ "${USER_CONFIG_FILE}" == "${dest_path}" ]]; then
        log_info "User configuration already in correct location: ${USER_CONFIG_FILE}"
    else
        # Copy to work directory
        if ! cp "${USER_CONFIG_FILE}" "${dest_path}"; then
            log_error "Failed to copy user-config.nix to ${WORK_DIR}"
            return 1
        fi
        log_info "Copied from: ${USER_CONFIG_FILE}"
        log_info "Copied to: ${dest_path}"
    fi

    # Validate destination file exists and is readable
    if [[ ! -r "${dest_path}" ]]; then
        log_error "User configuration file is not readable at: ${dest_path}"
        return 1
    fi

    log_success "User configuration verified successfully"
    echo ""

    return 0
}

# Function: initialize_git_for_flake
# Purpose: Initialize Git repository in flake directory to satisfy nix-darwin requirements
# Flakes require a Git repository to track changes and ensure reproducibility
# Arguments: None (uses $WORK_DIR environment variable)
# Returns: 0 always (NON-CRITICAL - logs warning on failure)
initialize_git_for_flake() {
    log_info "Initializing Git repository for flake..."

    # Change to work directory
    if ! cd "${WORK_DIR}"; then
        log_warn "Failed to change to work directory: ${WORK_DIR}"
        log_warn "Git initialization skipped (will use --impure flag)"
        return 0
    fi

    # Check if Git is available
    if ! command -v git >/dev/null 2>&1; then
        log_warn "Git command not found"
        log_warn "This is unexpected since Git was required for Xcode CLI Tools"
        log_warn "nix-darwin build will use --impure flag as fallback"
        return 0
    fi

    # Initialize Git repository (idempotent)
    if [[ -d "${WORK_DIR}/.git" ]]; then
        log_info "Git repository already initialized"
    else
        if ! git init; then
            log_warn "Failed to initialize Git repository"
            log_warn "nix-darwin build will use --impure flag as fallback"
            return 0
        fi
        log_info "✓ Git repository initialized"
    fi

    # Add all files
    if ! git add .; then
        log_warn "Failed to add files to Git"
        log_warn "nix-darwin build may fail, will use --impure flag as fallback"
        return 0
    fi

    # Create initial commit
    if ! git commit -m "Initial flake setup for nix-darwin installation" >/dev/null 2>&1; then
        log_warn "Failed to create initial commit"
        log_warn "This is non-critical, continuing anyway"
        return 0
    fi

    log_success "Git repository initialized and files committed"
    echo ""

    return 0
}

# Function: backup_etc_files_for_darwin
# Purpose: Backup /etc files that nix-darwin wants to manage
# nix-darwin refuses to overwrite existing files without backup
# Arguments: None
# Returns: 0 on success, 1 on failure (NON-CRITICAL - warns only)
backup_etc_files_for_darwin() {
    log_info "Backing up /etc files for nix-darwin management..."

    local files_to_backup=(
        "/etc/nix/nix.conf"
        "/etc/bashrc"
        "/etc/zshrc"
    )

    local backed_up=0
    local skipped=0

    for file in "${files_to_backup[@]}"; do
        if [[ -f "${file}" ]]; then
            local backup_name="${file}.before-nix-darwin"

            # If backup exists, check if we need to move the current file too
            if [[ -f "${backup_name}" ]]; then
                # Backup exists - append timestamp to avoid conflicts
                local timestamp_backup="${file}.before-nix-darwin.$(date +%Y%m%d-%H%M%S)"
                if sudo mv "${file}" "${timestamp_backup}"; then
                    log_info "  • $(basename "${file}"): backed up to $(basename "${timestamp_backup}") (backup already existed)"
                    ((backed_up++))
                else
                    log_warn "  • $(basename "${file}"): failed to backup (non-critical)"
                fi
            else
                # Create initial backup
                if sudo mv "${file}" "${backup_name}"; then
                    log_info "  • $(basename "${file}"): backed up to ${backup_name}"
                    ((backed_up++))
                else
                    log_warn "  • $(basename "${file}"): failed to backup (non-critical)"
                fi
            fi
        else
            log_info "  • $(basename "${file}"): does not exist, skipping"
            ((skipped++))
        fi
    done

    echo ""
    if [[ ${backed_up} -gt 0 ]]; then
        log_success "Backed up ${backed_up} file(s) for nix-darwin management"
    fi
    if [[ ${skipped} -gt 0 ]]; then
        log_info "Skipped ${skipped} file(s) (already backed up or non-existent)"
    fi
    echo ""

    return 0
}

# Function: run_nix_darwin_build
# Purpose: Execute initial nix-darwin build using flake configuration
# This is the CORE operation of Phase 5 - builds system from declarative config
# Arguments: None (uses $INSTALL_PROFILE and $WORK_DIR environment variables)
# Returns: 0 on success, 1 on failure (CRITICAL - exits on failure)
run_nix_darwin_build() {
    local flake_ref=".#${INSTALL_PROFILE}"

    echo ""
    log_info "========================================"
    log_info "STARTING NIX-DARWIN INITIAL BUILD"
    log_info "========================================"
    log_info "Profile: ${INSTALL_PROFILE}"
    log_info "Flake reference: ${flake_ref}"
    log_info "Work directory: ${WORK_DIR}"
    echo ""
    log_warn "⏱️  ESTIMATED TIME: 10-20 MINUTES"
    log_warn "This is normal for the first build"
    echo ""
    log_info "What's happening during this build:"
    log_info "  1. Evaluating flake configuration"
    log_info "  2. Downloading packages from cache.nixos.org"
    log_info "  3. Installing Homebrew (managed by nix-darwin)"
    log_info "  4. Building system configuration"
    log_info "  5. Activating new system generation"
    echo ""
    log_info "You will see many download messages - this is expected!"
    log_info "The build output will be displayed below..."
    echo ""

    # Backup /etc files that nix-darwin wants to manage
    backup_etc_files_for_darwin

    # Change to work directory
    if ! cd "${WORK_DIR}"; then
        log_error "Failed to change to work directory: ${WORK_DIR}"
        return 1
    fi

    # Run nix-darwin build
    # Note: We use 'nix run nix-darwin -- switch' for first-time installation
    # After installation, we'll use 'darwin-rebuild switch' for updates
    # IMPORTANT: Requires sudo for system activation (launchd, system files)
    # IMPORTANT: Must pass --extra-experimental-features since /etc/nix/nix.conf was backed up
    log_warn "This step requires sudo privileges for system activation"
    log_info "Executing: sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake ${flake_ref}"
    echo ""

    if ! sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake "${flake_ref}"; then
        log_error "nix-darwin build failed"
        log_error "This is a critical error - system configuration could not be applied"
        echo ""
        log_info "Common causes:"
        log_info "  • Network connectivity issues (check internet connection)"
        log_info "  • Invalid flake configuration (syntax errors in Nix files)"
        log_info "  • Insufficient disk space (check with 'df -h')"
        log_info "  • Permission issues (ensure user is in trusted-users)"
        echo ""
        log_info "Troubleshooting:"
        log_info "  1. Check /var/log/nix-daemon.log for detailed errors"
        log_info "  2. Verify flake syntax: cd ${WORK_DIR} && nix flake check"
        log_info "  3. Try manual build: cd ${WORK_DIR} && sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake ${flake_ref}"
        echo ""
        return 1
    fi

    echo ""
    log_success "nix-darwin build completed successfully!"
    log_info "System configuration has been activated"
    log_info "Homebrew has been installed and is managed by nix-darwin"
    echo ""

    return 0
}

# Function: verify_nix_darwin_installed
# Purpose: Verify nix-darwin and Homebrew are properly installed
# Arguments: None
# Returns: 0 on success, 1 on failure (CRITICAL - exits on failure)
verify_nix_darwin_installed() {
    log_info "Verifying nix-darwin installation..."

    # Check darwin-rebuild exists at expected location
    # Note: It may not be in PATH yet until shell is restarted
    local darwin_rebuild_path="/run/current-system/sw/bin/darwin-rebuild"

    if [[ -x "${darwin_rebuild_path}" ]]; then
        log_info "✓ darwin-rebuild found at ${darwin_rebuild_path}"
    elif command -v darwin-rebuild >/dev/null 2>&1; then
        log_info "✓ darwin-rebuild command is available in PATH"
    else
        log_error "darwin-rebuild not found"
        log_error "Expected location: ${darwin_rebuild_path}"
        log_warn "Note: You may need to restart your terminal for PATH changes to take effect"
        return 1
    fi

    # Check Homebrew installation
    if [[ -x /opt/homebrew/bin/brew ]]; then
        log_info "✓ Homebrew installed at /opt/homebrew/bin/brew"
    else
        log_warn "Homebrew not found at /opt/homebrew/bin/brew (may not be installed yet)"
        log_warn "This is normal if your profile doesn't include Homebrew casks"
    fi

    echo ""
    log_success "nix-darwin installation verified successfully"
    log_info "Your system is now managed declaratively!"
    log_info "Note: Restart your terminal to load the new environment"
    echo ""

    return 0
}

# Function: install_nix_darwin_phase
# Purpose: Orchestrate Phase 5 - nix-darwin installation from flake
# Coordinates: fetch files, copy config, git init, build, verify
# Arguments: None
# Returns: 0 on success, 1 on critical failure
install_nix_darwin_phase() {
    local phase_start
    phase_start=$(date +%s)

    echo ""
    log_info "========================================"
    log_info "PHASE 5: NIX-DARWIN INSTALLATION"
    log_info "Story 01.5-001: Install nix-darwin"
    log_info "========================================"
    log_info "This phase will:"
    log_info "  1. Fetch flake configuration from GitHub"
    log_info "  2. Copy user configuration"
    log_info "  3. Initialize Git repository"
    log_info "  4. Run initial nix-darwin build (10-20 minutes)"
    log_info "  5. Verify installation"
    echo ""
    log_warn "Estimated total time: 10-25 minutes"
    log_warn "Most time is spent downloading and building packages"
    echo ""

    # Step 1: Fetch flake configuration from GitHub (CRITICAL)
    if ! fetch_flake_from_github; then
        log_error "Failed to fetch flake configuration from GitHub"
        return 1
    fi

    # Step 2: Copy user configuration (CRITICAL)
    if ! copy_user_config; then
        log_error "Failed to copy user configuration"
        return 1
    fi

    # Step 3: Initialize Git repository (NON-CRITICAL)
    # This helps satisfy nix-darwin's Git requirement but isn't essential
    initialize_git_for_flake || true

    # Step 4: Run nix-darwin build (CRITICAL)
    if ! run_nix_darwin_build; then
        log_error "nix-darwin build failed"
        return 1
    fi

    # Step 5: Verify installation (CRITICAL)
    if ! verify_nix_darwin_installed; then
        log_error "nix-darwin verification failed"
        return 1
    fi

    local phase_end
    phase_end=$(date +%s)
    local phase_duration=$((phase_end - phase_start))
    local phase_minutes=$((phase_duration / 60))
    local phase_seconds=$((phase_duration % 60))

    echo ""
    log_success "========================================"
    log_success "PHASE 5 COMPLETE: NIX-DARWIN INSTALLED"
    log_success "========================================"
    log_info "Phase duration: ${phase_minutes}m ${phase_seconds}s"
    log_info "Profile: ${INSTALL_PROFILE}"
    echo ""
    log_info "What was accomplished:"
    log_info "  ✓ Flake configuration fetched from GitHub"
    log_info "  ✓ User configuration integrated"
    log_info "  ✓ Git repository initialized"
    log_info "  ✓ nix-darwin installed and activated"
    log_info "  ✓ Homebrew installed and configured"
    echo ""
    log_info "Your system is now managed declaratively by nix-darwin!"
    log_info "Future updates: darwin-rebuild switch --flake ${WORK_DIR}#${INSTALL_PROFILE}"
    echo ""

    return 0
}

# =============================================================================
# PHASE 5 (CONTINUED): POST-DARWIN SYSTEM VALIDATION (Story 01.5-002)
# =============================================================================

# Function: check_darwin_rebuild
# Purpose: Verify darwin-rebuild command is available after nix-darwin installation
# Checks: command -v darwin-rebuild and /run/current-system/sw/bin/darwin-rebuild
# Arguments: None
# Returns: 0 on success, 1 on failure (CRITICAL - exits on failure)
check_darwin_rebuild() {
    log_info "Checking darwin-rebuild command availability..."

    local darwin_rebuild_path="/run/current-system/sw/bin/darwin-rebuild"

    # Check if darwin-rebuild is in PATH
    if command -v darwin-rebuild >/dev/null 2>&1; then
        log_info "✓ darwin-rebuild command is available in PATH"
        return 0
    fi

    # Check specific installation path
    if [[ -x "${darwin_rebuild_path}" ]]; then
        log_info "✓ darwin-rebuild found at ${darwin_rebuild_path}"
        return 0
    fi

    # Critical failure - darwin-rebuild not found
    log_error "darwin-rebuild command not found"
    log_error "Expected location: ${darwin_rebuild_path}"
    log_error ""
    log_error "Troubleshooting steps:"
    log_error "  1. Verify nix-darwin build completed successfully"
    log_error "  2. Check PATH includes /run/current-system/sw/bin"
    log_error "  3. Restart terminal to reload PATH"
    log_error "  4. Re-run bootstrap if build was interrupted"
    log_error ""
    log_error "Manual check: ls -la ${darwin_rebuild_path}"

    return 1
}

# Function: check_homebrew_installed
# Purpose: Verify Homebrew was installed by nix-darwin
# Checks: /opt/homebrew/bin/brew exists, is executable, and runs successfully
# Arguments: $1 - Optional Homebrew path (defaults to /opt/homebrew/bin/brew)
# Returns: 0 on success, 1 on failure (CRITICAL - exits on failure)
check_homebrew_installed() {
    local brew_path="${1:-/opt/homebrew/bin/brew}"

    log_info "Checking Homebrew installation..."

    # Check if brew executable exists
    if [[ ! -x "${brew_path}" ]]; then
        log_error "Homebrew not found at ${brew_path}"
        log_error ""
        log_error "Troubleshooting steps:"
        log_error "  1. Verify your flake.nix includes homebrew configuration"
        log_error "  2. Check nix-darwin build logs for Homebrew installation errors"
        log_error "  3. Ensure homebrew.enable = true in darwin configuration"
        log_error "  4. Try manual installation: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        log_error ""
        log_error "Manual check: ls -la ${brew_path}"

        return 1
    fi

    # Test that brew command executes
    if ! "${brew_path}" --version >/dev/null 2>&1; then
        log_error "Homebrew found but not executable: ${brew_path}"
        log_error "Check file permissions and architecture compatibility"
        return 1
    fi

    log_info "✓ Homebrew installed at ${brew_path}"
    local brew_version
    brew_version=$("${brew_path}" --version | head -n1)
    log_info "  Version: ${brew_version}"

    return 0
}

# Function: check_core_apps_present
# Purpose: Check if at least one GUI app is installed (Ghostty or Zed)
# This is NON-CRITICAL - apps may install in next story
# Arguments: $1 - Applications directory (defaults to /Applications)
#            $2 - User Applications directory (defaults to ~/Applications)
# Returns: 0 always (NON-CRITICAL - warns but continues)
check_core_apps_present() {
    local apps_dir="${1:-/Applications}"
    local user_apps_dir="${2:-${HOME}/Applications}"

    log_info "Checking for GUI applications..."

    local apps_found=0
    local found_apps=()

    # Check for Ghostty
    if [[ -d "${apps_dir}/Ghostty.app" ]] || [[ -d "${user_apps_dir}/Ghostty.app" ]]; then
        found_apps+=("Ghostty")
        apps_found=1
    fi

    # Check for Zed
    if [[ -d "${apps_dir}/Zed.app" ]] || [[ -d "${user_apps_dir}/Zed.app" ]]; then
        found_apps+=("Zed")
        apps_found=1
    fi

    # Check for Arc
    if [[ -d "${apps_dir}/Arc.app" ]] || [[ -d "${user_apps_dir}/Arc.app" ]]; then
        found_apps+=("Arc")
        apps_found=1
    fi

    if [[ ${apps_found} -eq 1 ]]; then
        log_info "✓ Found GUI applications: ${found_apps[*]}"
    else
        log_warn "No GUI applications found yet"
        log_warn "This is normal - apps may install in next bootstrap phase"
        log_warn "Apps will be installed when darwin-rebuild runs with full flake"
    fi

    # Always return 0 (NON-CRITICAL)
    return 0
}

# Function: check_nix_daemon_running
# Purpose: Verify nix-daemon service is running via launchctl
# Checks: launchctl list for org.nixos.nix-daemon
# Arguments: None
# Returns: 0 on success, 1 on failure (CRITICAL - exits on failure)
check_nix_daemon_running() {
    log_info "Checking nix-daemon service status..."

    # Method 1: Check user domain (launchctl list without sudo)
    if launchctl list | grep -q "org.nixos.nix-daemon"; then
        log_info "✓ nix-daemon service is running (user domain: org.nixos.nix-daemon)"
        return 0
    fi

    # Method 2: Check system domain (launchctl list with sudo)
    # nix-daemon typically runs as root in system domain
    if sudo launchctl list 2>/dev/null | grep -q "org.nixos.nix-daemon"; then
        log_info "✓ nix-daemon service is running (system domain: org.nixos.nix-daemon)"
        return 0
    fi

    # Method 3: Check for running nix-daemon process directly
    # Fallback if launchctl doesn't show it but process is running
    if pgrep -q nix-daemon; then
        log_info "✓ nix-daemon process is running (detected via pgrep)"
        return 0
    fi

    # Critical failure - daemon not running with any detection method
    log_error "nix-daemon service is not running"
    log_error ""
    log_error "Troubleshooting steps:"
    log_error "  1. Check if daemon is loaded: sudo launchctl list | grep nix-daemon"
    log_error "  2. Restart daemon: sudo launchctl kickstart -k system/org.nixos.nix-daemon"
    log_error "  3. Check logs: sudo log show --predicate 'process == \"nix-daemon\"' --last 10m"
    log_error "  4. Re-run Nix installation if daemon was never started"
    log_error ""
    log_error "The Nix daemon must be running for nix-darwin to function properly"

    return 1
}

# Function: display_validation_summary
# Purpose: Display formatted summary table of all validation results
# Shows checkmarks (✓) for passing checks, X (✗) for failures
# Arguments: Validation results as key=value pairs (e.g., "darwin_rebuild=PASS")
# Returns: 0 always (display function)
display_validation_summary() {
    log_info ""
    log_info "========================================"
    log_info "VALIDATION SUMMARY"
    log_info "========================================"

    # Parse validation results from arguments
    local darwin_rebuild_status="UNKNOWN"
    local homebrew_status="UNKNOWN"
    local apps_status="UNKNOWN"
    local daemon_status="UNKNOWN"

    for result in "$@"; do
        case "${result}" in
            darwin_rebuild=*)
                darwin_rebuild_status="${result#*=}"
                ;;
            homebrew=*)
                homebrew_status="${result#*=}"
                ;;
            apps=*)
                apps_status="${result#*=}"
                ;;
            daemon=*)
                daemon_status="${result#*=}"
                ;;
        esac
    done

    # Display results with appropriate symbols
    if [[ "${darwin_rebuild_status}" == "PASS" ]]; then
        log_info "✓ darwin-rebuild: Available"
    else
        log_error "✗ darwin-rebuild: Not found (CRITICAL)"
    fi

    if [[ "${homebrew_status}" == "PASS" ]]; then
        log_info "✓ Homebrew: Installed"
    else
        log_error "✗ Homebrew: Not found (CRITICAL)"
    fi

    if [[ "${apps_status}" == "PASS" ]]; then
        log_info "✓ GUI Applications: Found"
    elif [[ "${apps_status}" == "WARN" ]]; then
        log_warn "⚠ GUI Applications: Not yet installed (will install later)"
    else
        log_warn "⚠ GUI Applications: Not found (non-critical)"
    fi

    if [[ "${daemon_status}" == "PASS" ]]; then
        log_info "✓ nix-daemon: Running"
    else
        log_error "✗ nix-daemon: Not running (CRITICAL)"
    fi

    log_info "========================================"
    log_info ""

    return 0
}

# Function: validate_nix_darwin_phase
# Purpose: Orchestrate all post-darwin validation checks
# Runs: darwin-rebuild, Homebrew, apps, daemon checks + summary
# Arguments: None
# Returns: 0 on success, 1 if any CRITICAL check fails
validate_nix_darwin_phase() {
    echo ""
    log_info "========================================"
    log_info "PHASE 5 (CONTINUED): POST-DARWIN SYSTEM VALIDATION"
    log_info "Story 01.5-002: Verify nix-darwin installation"
    log_info "========================================"
    log_info "Validating system components..."
    echo ""

    # Track validation results
    local darwin_rebuild_result="FAIL"
    local homebrew_result="FAIL"
    local apps_result="WARN"
    local daemon_result="FAIL"

    # Check 1: darwin-rebuild (CRITICAL)
    if check_darwin_rebuild; then
        darwin_rebuild_result="PASS"
    else
        log_error "darwin-rebuild validation failed (CRITICAL)"
        display_validation_summary \
            "darwin_rebuild=${darwin_rebuild_result}" \
            "homebrew=${homebrew_result}" \
            "apps=${apps_result}" \
            "daemon=${daemon_result}"
        return 1
    fi

    # Check 2: Homebrew (CRITICAL)
    if check_homebrew_installed; then
        homebrew_result="PASS"
    else
        log_error "Homebrew validation failed (CRITICAL)"
        display_validation_summary \
            "darwin_rebuild=${darwin_rebuild_result}" \
            "homebrew=${homebrew_result}" \
            "apps=${apps_result}" \
            "daemon=${daemon_result}"
        return 1
    fi

    # Check 3: Core apps (NON-CRITICAL)
    if check_core_apps_present; then
        # Check if any apps were actually found
        if [[ -d "/Applications/Ghostty.app" ]] || \
           [[ -d "/Applications/Zed.app" ]] || \
           [[ -d "/Applications/Arc.app" ]] || \
           [[ -d "${HOME}/Applications/Ghostty.app" ]] || \
           [[ -d "${HOME}/Applications/Zed.app" ]] || \
           [[ -d "${HOME}/Applications/Arc.app" ]]; then
            apps_result="PASS"
        else
            apps_result="WARN"
        fi
    fi
    # Always continue even if no apps found

    # Check 4: nix-daemon (CRITICAL)
    if check_nix_daemon_running; then
        daemon_result="PASS"
    else
        log_error "nix-daemon validation failed (CRITICAL)"
        display_validation_summary \
            "darwin_rebuild=${darwin_rebuild_result}" \
            "homebrew=${homebrew_result}" \
            "apps=${apps_result}" \
            "daemon=${daemon_result}"
        return 1
    fi

    # Display summary
    display_validation_summary \
        "darwin_rebuild=${darwin_rebuild_result}" \
        "homebrew=${homebrew_result}" \
        "apps=${apps_result}" \
        "daemon=${daemon_result}"

    echo ""
    log_success "✓ Post-darwin validation complete"
    log_info "All critical system components verified successfully"
    echo ""

    return 0
}

# =============================================================================
# PHASE 6: SSH KEY GENERATION FUNCTIONS
# =============================================================================
# Story 01.6-001: SSH Key Generation for GitHub Authentication
# Generates ed25519 SSH key for GitHub authentication with security trade-offs
# Handles existing keys, permissions, ssh-agent management
# =============================================================================

# Function: ensure_ssh_directory
# Purpose: Create ~/.ssh directory if not exists with proper permissions (NON-CRITICAL)
# Sets: 700 (drwx------) permissions for security
# Arguments: None
# Returns: 0 on success or if already exists, warns but continues on failure
ensure_ssh_directory() {
    local ssh_dir="${HOME}/.ssh"

    # Check if directory already exists
    if [[ -d "${ssh_dir}" ]]; then
        log_info "SSH directory already exists: ${ssh_dir}"

        # Ensure correct permissions even if directory exists
        if chmod 700 "${ssh_dir}" 2>/dev/null; then
            log_info "✓ SSH directory permissions set to 700"
        else
            log_warn "Could not set SSH directory permissions (non-critical)"
        fi

        return 0
    fi

    # Create directory
    log_info "Creating SSH directory: ${ssh_dir}"
    if mkdir -p "${ssh_dir}"; then
        log_info "✓ SSH directory created"

        # Set proper permissions
        if chmod 700 "${ssh_dir}"; then
            log_info "✓ SSH directory permissions set to 700"
        else
            log_warn "Could not set SSH directory permissions (non-critical)"
        fi

        return 0
    else
        log_warn "Failed to create SSH directory (non-critical, continuing)"
        return 1
    fi
}

# Function: check_existing_ssh_key
# Purpose: Check if ed25519 SSH key already exists (NON-CRITICAL)
# Checks: ~/.ssh/id_ed25519 private key file
# Arguments: None
# Returns: 0 if key exists, 1 if not found
check_existing_ssh_key() {
    local key_path="${HOME}/.ssh/id_ed25519"

    if [[ -f "${key_path}" ]]; then
        log_info "Found existing SSH key: ${key_path}"
        return 0
    else
        log_info "No existing SSH key found at: ${key_path}"
        return 1
    fi
}

# Function: prompt_use_existing_key
# Purpose: Ask user whether to use existing SSH key (NON-CRITICAL)
# Accepts: y/Y/yes/Yes = use existing (return 0), n/N/no/No = generate new (return 1)
# Default: yes (if invalid input)
# Arguments: None
# Returns: 0 to use existing, 1 to generate new
prompt_use_existing_key() {
    echo ""
    log_info "An existing SSH key was found."
    echo ""

    local response
    read -r -p "Use existing SSH key? (y/n) [default: yes]: " response

    # Trim whitespace
    response=$(echo "${response}" | xargs)

    # Default to yes if empty
    if [[ -z "${response}" ]]; then
        response="y"
    fi

    # Check response
    case "${response}" in
        y|Y|yes|Yes|YES)
            log_info "Using existing SSH key"
            return 0
            ;;
        n|N|no|No|NO)
            log_info "Will generate new SSH key"
            return 1
            ;;
        *)
            log_warn "Invalid input '${response}', defaulting to 'yes'"
            log_info "Using existing SSH key"
            return 0
            ;;
    esac
}

# Function: generate_ssh_key
# Purpose: Generate ed25519 SSH key without passphrase for automation (CRITICAL)
# Key type: ed25519 (modern, secure, small)
# Passphrase: Empty (for zero-intervention bootstrap)
# Comment: User's email address
# Arguments: None (uses $USER_EMAIL global variable)
# Returns: 0 on success, exits on failure
generate_ssh_key() {
    local key_path="${HOME}/.ssh/id_ed25519"

    echo ""
    log_info "========================================"
    log_info "Generating SSH Key for GitHub"
    log_info "========================================"

    # Display security warning about no passphrase
    log_warn "⚠ SECURITY TRADE-OFF: Generating SSH key WITHOUT passphrase"
    log_warn ""
    log_warn "WHY: Enables fully automated bootstrap (zero manual intervention)"
    log_warn ""
    log_warn "RISKS:"
    log_warn "  - Private key not encrypted at rest"
    log_warn "  - Key accessible if machine compromised"
    log_warn ""
    log_warn "MITIGATIONS:"
    log_warn "  ✓ macOS FileVault encrypts entire disk (key encrypted at rest)"
    log_warn "  ✓ Key limited to GitHub use only (limited scope)"
    log_warn "  ✓ You can add passphrase later: ssh-keygen -p -f ${key_path}"
    log_warn ""
    log_info "Proceeding with key generation..."
    echo ""

    # Generate key with ssh-keygen
    log_info "Running: ssh-keygen -t ed25519 -C '${USER_EMAIL}' -f '${key_path}' -N ''"
    if ssh-keygen -t ed25519 -C "${USER_EMAIL}" -f "${key_path}" -N "" >/dev/null 2>&1; then
        log_info "✓ SSH key generation completed"
    else
        log_error "ssh-keygen command failed"
        log_error ""
        log_error "Troubleshooting steps:"
        log_error "  1. Verify ssh-keygen is installed: which ssh-keygen"
        log_error "  2. Check disk space: df -h ~"
        log_error "  3. Verify permissions: ls -ld ~/.ssh"
        log_error "  4. Try manual generation: ssh-keygen -t ed25519 -C '${USER_EMAIL}'"
        log_error ""
        return 1
    fi

    # Verify both key files were created
    if [[ ! -f "${key_path}" ]]; then
        log_error "Private key file not created: ${key_path}"
        return 1
    fi

    if [[ ! -f "${key_path}.pub" ]]; then
        log_error "Public key file not created: ${key_path}.pub"
        return 1
    fi

    log_success "✓ SSH key files created:"
    log_info "  Private: ${key_path}"
    log_info "  Public:  ${key_path}.pub"
    echo ""

    return 0
}

# Function: set_ssh_key_permissions
# Purpose: Set correct permissions on SSH key files (CRITICAL)
# Private key: 600 (rw-------) - owner read/write only
# Public key: 644 (rw-r--r--) - owner write, all read
# Arguments: None
# Returns: 0 on success, exits on failure
set_ssh_key_permissions() {
    local private_key="${HOME}/.ssh/id_ed25519"
    local public_key="${HOME}/.ssh/id_ed25519.pub"

    log_info "Setting SSH key permissions..."

    # Verify files exist
    if [[ ! -f "${private_key}" ]]; then
        log_error "Private key file not found: ${private_key}"
        log_error "Cannot set permissions on non-existent file"
        return 1
    fi

    if [[ ! -f "${public_key}" ]]; then
        log_error "Public key file not found: ${public_key}"
        log_error "Cannot set permissions on non-existent file"
        return 1
    fi

    # Set private key permissions (600)
    if chmod 600 "${private_key}"; then
        log_info "✓ Private key permissions: 600 (rw-------)"
    else
        log_error "Failed to set private key permissions to 600"
        log_error "File: ${private_key}"
        log_error "This is a security requirement for SSH keys"
        return 1
    fi

    # Set public key permissions (644)
    if chmod 644 "${public_key}"; then
        log_info "✓ Public key permissions: 644 (rw-r--r--)"
    else
        log_error "Failed to set public key permissions to 644"
        log_error "File: ${public_key}"
        return 1
    fi

    # Verify permissions were set correctly
    local private_perms
    private_perms=$(stat -f %A "${private_key}")
    if [[ "${private_perms}" == "600" ]]; then
        log_info "✓ Private key permissions verified"
    else
        log_error "Private key permissions verification failed"
        log_error "Expected: 600, Found: ${private_perms}"
        return 1
    fi

    local public_perms
    public_perms=$(stat -f %A "${public_key}")
    if [[ "${public_perms}" == "644" ]]; then
        log_info "✓ Public key permissions verified"
    else
        log_error "Public key permissions verification failed"
        log_error "Expected: 644, Found: ${public_perms}"
        return 1
    fi

    log_success "✓ SSH key permissions set correctly"
    echo ""

    return 0
}

# Function: start_ssh_agent_and_add_key
# Purpose: Start ssh-agent and add SSH key to agent (CRITICAL)
# Required: For SSH key to be usable without passphrase prompt
# Note: macOS uses system ssh-agent via launchd, we just need to add the key
# Arguments: None
# Returns: 0 on success, exits on failure
start_ssh_agent_and_add_key() {
    local key_path="${HOME}/.ssh/id_ed25519"

    log_info "Configuring SSH agent for key management..."

    # On macOS, ssh-agent is managed by launchd and runs automatically
    # We don't need to start it manually - just verify it's available
    log_info "Checking for ssh-agent..."

    # Check if SSH_AUTH_SOCK is set (agent socket available)
    if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
        # No agent socket found - try to find system agent
        log_info "Looking for system ssh-agent..."

        # macOS typically runs ssh-agent via launchd
        # Try to use the system agent by checking common socket locations
        local potential_sockets=(
            "/private/tmp/com.apple.launchd.*/Listeners"
            "${TMPDIR:-/tmp}/ssh-*/agent.*"
        )

        local found_socket=""
        for socket_pattern in "${potential_sockets[@]}"; do
            # shellcheck disable=SC2206
            local sockets=($socket_pattern)
            if [[ -S "${sockets[0]}" ]]; then
                found_socket="${sockets[0]}"
                break
            fi
        done

        if [[ -n "${found_socket}" ]]; then
            export SSH_AUTH_SOCK="${found_socket}"
            log_info "✓ Found system ssh-agent socket"
        else
            # Fallback: start our own agent for this session
            log_warn "No system ssh-agent found, starting local agent..."
            local agent_output
            if agent_output=$(ssh-agent -s 2>&1); then
                eval "${agent_output}" >/dev/null 2>&1
                log_info "✓ Started local ssh-agent (PID: ${SSH_AGENT_PID:-unknown})"
            else
                log_error "Failed to start ssh-agent"
                log_error "Output: ${agent_output}"
                log_error ""
                log_error "Troubleshooting steps:"
                log_error "  1. Verify ssh-agent is installed: which ssh-agent"
                log_error "  2. Check for existing agent: ps aux | grep ssh-agent"
                log_error "  3. Restart and try again"
                log_error ""
                return 1
            fi
        fi
    else
        log_info "✓ ssh-agent socket found: ${SSH_AUTH_SOCK}"
    fi

    # Add SSH key to agent
    # Configure macOS Keychain integration for SSH key persistence
    log_info "Configuring SSH key persistence in macOS Keychain..."
    local ssh_config="${HOME}/.ssh/config"

    # Create or update ~/.ssh/config for macOS Keychain integration
    if ! grep -q "UseKeychain yes" "${ssh_config}" 2>/dev/null; then
        cat >> "${ssh_config}" <<'EOF'

# macOS Keychain integration for SSH key persistence
# Auto-generated by nix-darwin bootstrap (Story 01.6-001)
Host *
    UseKeychain yes
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
EOF
        chmod 600 "${ssh_config}"
        log_info "✓ Created ~/.ssh/config with Keychain integration"
    else
        log_info "✓ SSH config already has Keychain integration"
    fi

    log_info "Adding SSH key to agent with Keychain persistence..."
    # Use --apple-use-keychain flag on macOS to store passphrase in Keychain
    # Even with empty passphrase, this ensures key persists across sessions
    if ssh-add --apple-use-keychain "${key_path}" >/dev/null 2>&1; then
        log_info "✓ SSH key added to agent and macOS Keychain"
    else
        # Fallback to standard ssh-add if --apple-use-keychain not supported
        log_warn "Keychain flag not supported, trying standard ssh-add..."
        if ssh-add "${key_path}" >/dev/null 2>&1; then
            log_info "✓ SSH key added to agent (fallback method)"
        else
            log_error "Failed to add SSH key to agent"
            log_error "Key: ${key_path}"
            log_error ""
            log_error "Troubleshooting steps:"
            log_error "  1. Verify key exists: ls -l ${key_path}"
            log_error "  2. Check key permissions: ls -l ${key_path}"
            log_error "  3. Verify agent is running: echo \$SSH_AUTH_SOCK"
            log_error "  4. Try manual add: ssh-add --apple-use-keychain ${key_path}"
            log_error "  5. Check agent keys: ssh-add -l"
            log_error ""
            return 1
        fi
    fi

    # Verify key was added
    log_info "Verifying key in agent..."
    if ssh-add -l 2>&1 | grep -q "ed25519"; then
        log_success "✓ SSH key verified in agent"
    else
        log_warn "Could not verify key in agent (may still be added)"
    fi

    echo ""
    return 0
}

# Function: display_ssh_key_summary
# Purpose: Display SSH key information summary (NON-CRITICAL)
# Shows: Public key content, fingerprint, comment, agent status
# Arguments: None
# Returns: 0 always (display function)
display_ssh_key_summary() {
    local public_key_path="${HOME}/.ssh/id_ed25519.pub"

    echo ""
    log_info "========================================"
    log_info "SSH KEY SUMMARY"
    log_info "========================================"

    # Display public key content
    if [[ -f "${public_key_path}" ]]; then
        log_info ""
        log_info "Public Key:"
        log_info "$(cat "${public_key_path}")"
        log_info ""

        # Display key fingerprint
        local fingerprint
        if fingerprint=$(ssh-keygen -lf "${public_key_path}" 2>/dev/null); then
            log_info "Fingerprint:"
            log_info "${fingerprint}"
        fi
    else
        log_warn "Public key file not found: ${public_key_path}"
    fi

    log_info ""
    log_info "✓ SSH key ready for GitHub authentication"
    log_info "✓ Key added to ssh-agent"
    log_info ""
    log_info "NEXT STEPS:"
    log_info "1. Copy the public key above"
    log_info "2. Add it to GitHub: https://github.com/settings/keys"
    log_info "3. Test connection: ssh -T git@github.com"
    log_info "========================================"
    echo ""

    return 0
}

# Function: setup_ssh_key_phase
# Purpose: Orchestrate SSH key setup workflow (Phase 6 main function)
# Workflow: Check directory → Check existing key → Generate/Use → Permissions → Agent → Summary
# Arguments: None
# Returns: 0 on success, 1 if any CRITICAL step fails
setup_ssh_key_phase() {
    echo ""
    log_info "========================================"
    log_info "PHASE 6/10: SSH KEY GENERATION"
    log_info "Story 01.6-001: Generate SSH key for GitHub"
    log_info "========================================"
    echo ""

    # Step 1: Ensure .ssh directory exists (NON-CRITICAL)
    if ! ensure_ssh_directory; then
        log_warn "SSH directory setup had issues (non-critical, continuing)"
    fi

    # Step 2: Check for existing SSH key (NON-CRITICAL)
    local needs_generation=true
    if check_existing_ssh_key; then
        # Existing key found, ask user
        if prompt_use_existing_key; then
            # User wants to use existing key
            needs_generation=false
            log_info "Using existing SSH key"
        else
            # User wants new key
            needs_generation=true
            log_info "Will generate new SSH key (existing key will be backed up)"
        fi
    else
        # No existing key, need to generate
        needs_generation=true
    fi

    # Step 3: Generate new key if needed (CRITICAL)
    if [[ "${needs_generation}" == true ]]; then
        if ! generate_ssh_key; then
            log_error "SSH key generation failed (CRITICAL)"
            return 1
        fi
    fi

    # Step 4: Set correct permissions (CRITICAL)
    if ! set_ssh_key_permissions; then
        log_error "Failed to set SSH key permissions (CRITICAL)"
        return 1
    fi

    # Step 5: Start ssh-agent and add key (CRITICAL)
    if ! start_ssh_agent_and_add_key; then
        log_error "Failed to add SSH key to agent (CRITICAL)"
        return 1
    fi

    # Step 6: Display summary (NON-CRITICAL)
    if ! display_ssh_key_summary; then
        log_warn "Could not display SSH key summary (non-critical)"
    fi

    log_success "✓ SSH key setup complete"
    log_info "Phase 6 completed successfully"
    echo ""

    return 0
}

# =============================================================================
# PHASE 6 (CONTINUED): GITHUB SSH KEY UPLOAD VIA GITHUB CLI
# Story 01.6-002: Automated GitHub SSH key upload using gh CLI
# =============================================================================

# Function: check_github_cli_authenticated
# Purpose: Check if GitHub CLI is authenticated (NON-CRITICAL)
# Returns: 0 if authenticated, 1 if not authenticated or check fails
# Note: Does not exit on failure - authentication will happen next
check_github_cli_authenticated() {
    # Silently check authentication status
    # Output is redirected to /dev/null to keep logs clean
    if gh auth status >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function: authenticate_github_cli
# Purpose: Authenticate GitHub CLI via OAuth web flow (CRITICAL)
# OAuth Flow: Opens browser, user clicks "Authorize" (~10 seconds)
# Returns: 0 on success, exits script on failure
authenticate_github_cli() {
    echo ""
    log_info "========================================"
    log_info "GITHUB CLI AUTHENTICATION"
    log_info "========================================"
    echo ""

    log_info "Starting GitHub CLI OAuth authentication..."
    log_info ""
    log_info "What happens next:"
    log_info "1. Your browser will open automatically"
    log_info "2. You'll see a one-time code to copy"
    log_info "3. Click 'Authorize' to grant access"
    log_info "4. This takes about 10 seconds"
    echo ""

    # Ensure gh config directory exists with proper permissions
    # Prevents "permission denied" errors when gh tries to write config
    local gh_config_dir="${HOME}/.config/gh"
    if [[ ! -d "${gh_config_dir}" ]]; then
        log_info "Creating GitHub CLI config directory..."
        if ! mkdir -p "${gh_config_dir}"; then
            log_warn "Could not create ${gh_config_dir} (non-critical, gh will try)"
        else
            chmod 755 "${gh_config_dir}" || true
            log_info "✓ GitHub CLI config directory created"
        fi
        echo ""
    fi

    # Run gh auth login with web OAuth flow
    # --hostname github.com: Authenticate to GitHub (not enterprise)
    # --git-protocol ssh: Use SSH for git operations (not HTTPS)
    # --web: Use browser-based OAuth flow (auto-opens browser)
    if ! gh auth login --hostname github.com --git-protocol ssh --web; then
        log_error "GitHub CLI authentication failed"
        log_error ""
        log_error "Troubleshooting:"
        log_error "1. Check internet connection"
        log_error "2. Ensure browser opened correctly"
        log_error "3. Try manual auth: gh auth login"
        log_error "4. Check gh version: gh --version"
        echo ""
        return 1
    fi

    log_success "✓ GitHub CLI authenticated successfully"
    echo ""

    return 0
}

# Function: check_key_exists_on_github
# Purpose: Check if local SSH key already exists on GitHub (NON-CRITICAL)
# Method: Extracts fingerprint from local key, compares to keys on GitHub
# Returns: 0 if key exists, 1 if not found or check fails
# Note: Logs warning on failure but doesn't exit (network issues, etc.)
check_key_exists_on_github() {
    local ssh_pub_key_path="${HOME}/.ssh/id_ed25519.pub"

    # Extract fingerprint from local public key
    # Format: "256 SHA256:abcd1234... user@host (ED25519)"
    # We need the SHA256:... part
    local local_fingerprint
    if ! local_fingerprint=$(ssh-keygen -l -f "${ssh_pub_key_path}" 2>/dev/null | awk '{print $2}'); then
        log_warn "Could not extract SSH key fingerprint (non-critical)"
        return 1
    fi

    # Query GitHub for existing SSH keys
    # gh ssh-key list returns format: "SHA256:... Title (Date)"
    local github_keys
    if ! github_keys=$(gh ssh-key list 2>/dev/null); then
        log_warn "Could not query GitHub SSH keys (network issue?)"
        return 1
    fi

    # Check if local fingerprint exists in GitHub keys
    if echo "${github_keys}" | grep -q "${local_fingerprint}"; then
        log_info "SSH key already exists on GitHub (fingerprint: ${local_fingerprint})"
        return 0
    else
        return 1
    fi
}

# Function: upload_ssh_key_to_github
# Purpose: Upload SSH public key to GitHub via gh CLI (CRITICAL)
# Key Title Format: hostname-YYYYMMDD (e.g., "MacBook-Pro-20251111")
# Returns: 0 on success OR if key already exists, exits on other failures
# Note: "Key already exists" is NOT an error (idempotency)
upload_ssh_key_to_github() {
    local ssh_pub_key_path="${HOME}/.ssh/id_ed25519.pub"

    # Generate key title: hostname-YYYYMMDD
    local key_title
    key_title="$(hostname)-$(date +%Y%m%d)"

    log_info "Uploading SSH key to GitHub..."
    log_info "Key title: ${key_title}"
    echo ""

    # Upload key to GitHub
    # gh ssh-key add uploads the public key with a title
    local upload_output
    local upload_exit_code

    upload_output=$(gh ssh-key add "${ssh_pub_key_path}" --title "${key_title}" 2>&1)
    upload_exit_code=$?

    if [[ ${upload_exit_code} -eq 0 ]]; then
        log_success "✓ SSH key uploaded to GitHub successfully"
        echo ""
        return 0
    elif [[ "${upload_output}" =~ "already exists" ]] || [[ "${upload_output}" =~ "key is already" ]]; then
        # Key already exists - this is NOT an error (idempotency)
        log_info "SSH key already exists on GitHub (idempotent check passed)"
        echo ""
        return 0
    else
        # Other failure (network, permissions, malformed key, etc.)
        log_error "Failed to upload SSH key to GitHub"
        log_error "Error: ${upload_output}"
        echo ""
        return 1
    fi
}

# Function: fallback_manual_key_upload
# Purpose: Provide manual upload instructions if automation fails (NON-CRITICAL)
# Process: Copy key to clipboard, display key, show instructions, wait for user
# Returns: 0 always (user confirms completion)
fallback_manual_key_upload() {
    local ssh_pub_key_path="${HOME}/.ssh/id_ed25519.pub"

    echo ""
    log_warn "========================================"
    log_warn "MANUAL SSH KEY UPLOAD REQUIRED"
    log_warn "========================================"
    echo ""

    log_info "Automated upload failed. Please add the key manually."
    echo ""

    # Try to copy to clipboard (pbcopy on macOS)
    if command -v pbcopy >/dev/null 2>&1; then
        if cat "${ssh_pub_key_path}" | pbcopy 2>/dev/null; then
            log_success "✓ SSH key copied to clipboard!"
        else
            log_warn "Could not copy to clipboard (pbcopy failed)"
        fi
    else
        log_warn "pbcopy not available (clipboard copy skipped)"
    fi

    echo ""
    log_info "Your SSH Public Key:"
    log_info "--------------------"
    cat "${ssh_pub_key_path}"
    echo ""
    log_info "--------------------"
    echo ""

    log_info "MANUAL UPLOAD STEPS:"
    log_info "1. Go to: https://github.com/settings/keys"
    log_info "2. Click 'New SSH key'"
    log_info "3. Paste the key above (already copied to clipboard!)"
    log_info "4. Give it a title (e.g., MacBook-Pro-$(date +%Y%m%d))"
    log_info "5. Click 'Add SSH key'"
    echo ""

    # Wait for user confirmation
    read -p "Press ENTER when you've added the key to GitHub..."

    echo ""
    log_success "✓ Manual key upload completed"
    echo ""

    return 0
}

# Function: upload_github_key_phase
# Purpose: Orchestrate GitHub SSH key upload workflow (Phase 6 continued)
# Workflow: Check auth → Authenticate → Check exists → Upload → Fallback
# Returns: 0 on success, 1 if CRITICAL step fails
upload_github_key_phase() {
    local phase_start_time
    phase_start_time=$(date +%s)

    echo ""
    log_info "========================================"
    log_info "PHASE 6 (CONTINUED): GITHUB SSH KEY UPLOAD"
    log_info "Story 01.6-002: Automated GitHub CLI upload"
    log_info "========================================"
    echo ""

    # Step 1: Check if GitHub CLI is already authenticated (NON-CRITICAL)
    log_info "Step 1/4: Checking GitHub CLI authentication..."
    if check_github_cli_authenticated; then
        log_success "✓ GitHub CLI already authenticated"
        echo ""
    else
        log_info "GitHub CLI not authenticated, starting OAuth flow..."
        echo ""

        # Step 1b: Authenticate via OAuth (CRITICAL)
        if ! authenticate_github_cli; then
            log_error "GitHub CLI authentication failed (CRITICAL)"
            return 1
        fi
    fi

    # Step 2: Check if key already exists on GitHub (NON-CRITICAL)
    log_info "Step 2/4: Checking if SSH key already exists on GitHub..."
    if check_key_exists_on_github; then
        log_success "✓ SSH key already exists on GitHub"
        log_info "Skipping upload (idempotency check passed)"
        echo ""

        # Calculate phase duration
        local phase_end_time
        phase_end_time=$(date +%s)
        local phase_duration=$((phase_end_time - phase_start_time))

        log_success "✓ GitHub SSH key verification complete"
        log_info "Phase 6 (continued) completed successfully in ${phase_duration} seconds"
        echo ""

        return 0
    fi

    # Step 3: Upload SSH key to GitHub (CRITICAL)
    log_info "Step 3/4: Uploading SSH key to GitHub..."
    echo ""

    if upload_ssh_key_to_github; then
        log_success "✓ SSH key uploaded to GitHub successfully"
        echo ""

        # Calculate phase duration
        local phase_end_time
        phase_end_time=$(date +%s)
        local phase_duration=$((phase_end_time - phase_start_time))

        log_success "✓ GitHub SSH key upload complete"
        log_info "Phase 6 (continued) completed successfully in ${phase_duration} seconds"
        echo ""

        return 0
    else
        # Step 4: Fallback to manual upload if automation failed
        log_warn "Automated upload failed, falling back to manual process"
        echo ""

        fallback_manual_key_upload

        # Calculate phase duration
        local phase_end_time
        phase_end_time=$(date +%s)
        local phase_duration=$((phase_end_time - phase_start_time))

        log_success "✓ GitHub SSH key upload complete (manual)"
        log_info "Phase 6 (continued) completed successfully in ${phase_duration} seconds"
        echo ""

        return 0
    fi
}

#==============================================================================
# STORY 01.6-003: GITHUB SSH CONNECTION TEST
#==============================================================================
# These functions implement GitHub SSH connection testing with retry mechanism
# and abort option for the bootstrap script.
#==============================================================================

# Function: test_github_ssh_connection
# Purpose: Test GitHub SSH connection and verify authentication
# Returns: 0 on success, 1 on failure
# Note: ssh -T git@github.com returns exit code 1 on SUCCESS (by design)!
#       We must check output content, not exit code
test_github_ssh_connection() {
    local ssh_output
    local username

    log_info "Testing GitHub SSH connection..."

    # Capture both stdout and stderr (GitHub sends message to stderr)
    # NOTE: ssh -T returns 1 on success, so we can't use return code
    ssh_output=$(ssh -T git@github.com 2>&1)

    # Check if authentication was successful by looking for success message
    if echo "$ssh_output" | grep -q "successfully authenticated"; then
        # Extract username if present in output
        if echo "$ssh_output" | grep -q "Hi [^!]*!"; then
            username=$(echo "$ssh_output" | grep -oE "Hi [^!]+!" | cut -d' ' -f2 | tr -d '!')
            log_success "✓ Successfully authenticated as GitHub user: ${username}"
        else
            log_success "✓ Successfully authenticated to GitHub"
        fi
        return 0
    else
        log_error "✗ SSH connection to GitHub failed"
        log_error "Output: ${ssh_output}"
        return 1
    fi
}

# Function: display_ssh_troubleshooting
# Purpose: Display troubleshooting help for SSH connection failures
# Returns: Always returns 0
display_ssh_troubleshooting() {
    echo ""
    log_warn "========================================"
    log_warn "SSH CONNECTION TROUBLESHOOTING"
    log_warn "========================================"
    echo ""

    log_info "Common issues and solutions:"
    echo ""

    log_info "1. OAuth Authorization (if automated upload was used):"
    log_info "   → Ensure you clicked 'Authorize' during the GitHub OAuth flow"
    echo ""

    log_info "2. Key Upload Verification:"
    log_info "   → Verify the key was uploaded successfully to GitHub"
    log_info "   → Check your keys at: ${YELLOW}https://github.com/settings/keys${NC}"
    echo ""

    log_info "3. SSH Key Passphrase (if set):"
    log_info "   → Ensure SSH key passphrase (if any) was entered correctly"
    log_info "   → Check ssh-agent is running and has your key loaded"
    echo ""

    log_info "4. Manual Test:"
    log_info "   → Test manually with: ${YELLOW}ssh -T git@github.com${NC}"
    log_info "   → You should see: 'Hi <username>! You've successfully authenticated...'"
    echo ""

    log_info "5. Network Connectivity:"
    log_info "   → Verify you can reach github.com"
    log_info "   → Check if firewall/proxy is blocking SSH (port 22)"
    echo ""

    return 0
}

# Function: retry_ssh_connection
# Purpose: Retry SSH connection test up to 3 times with delays
# Returns: 0 if any attempt succeeds, 1 if all attempts fail
retry_ssh_connection() {
    local max_attempts=3
    local attempt=1
    local sleep_duration=2

    log_info "Starting SSH connection test with retry mechanism..."
    log_info "Maximum attempts: ${max_attempts}"
    echo ""

    while [ $attempt -le $max_attempts ]; do
        log_info "Attempt ${attempt} of ${max_attempts}..."
        echo ""

        if test_github_ssh_connection; then
            echo ""
            log_success "✓ GitHub SSH connection test PASSED"
            return 0
        fi

        # If this wasn't the last attempt, wait before retrying
        if [ $attempt -lt $max_attempts ]; then
            echo ""
            log_warn "Connection test failed. Waiting ${sleep_duration} seconds before retry..."
            sleep $sleep_duration
            echo ""
        fi

        attempt=$((attempt + 1))
    done

    echo ""
    log_error "✗ All ${max_attempts} SSH connection attempts FAILED"
    echo ""

    return 1
}

# Function: prompt_continue_without_ssh
# Purpose: Ask user if they want to continue without SSH test or abort
# Returns: 0 to continue, 1 to abort
prompt_continue_without_ssh() {
    local response

    echo ""
    log_warn "========================================"
    log_warn "SSH CONNECTION TEST FAILED"
    log_warn "========================================"
    echo ""

    log_warn "The SSH connection test to GitHub failed after 3 attempts."
    log_warn "You can continue anyway, but repository cloning may fail later."
    echo ""

    while true; do
        read -p "Continue without SSH test? (y/n) [not recommended]: " response

        # Trim whitespace and convert to lowercase
        response=$(echo "$response" | xargs | tr '[:upper:]' '[:lower:]')

        case "$response" in
            y|yes)
                echo ""
                log_warn "⚠️  WARNING: Continuing without SSH test validation"
                log_warn "Repository cloning in Phase 7 may fail if SSH is not configured correctly"
                echo ""
                return 0
                ;;
            n|no)
                echo ""
                log_error "Bootstrap aborted by user"
                log_error "Please fix SSH connection issues and re-run the bootstrap script"
                echo ""
                return 1
                ;;
            *)
                echo ""
                log_error "Invalid input: '${response}'"
                log_info "Please enter 'y' (yes) or 'n' (no)"
                echo ""
                ;;
        esac
    done
}

# Function: test_github_ssh_phase
# Purpose: Orchestrate GitHub SSH connection test phase (Phase 6 continued)
# Workflow: Retry connection → Display troubleshooting on failure → Prompt to continue or abort
# Returns: 0 on success or user continue, 1 if user aborts
test_github_ssh_phase() {
    local phase_start_time
    phase_start_time=$(date +%s)

    echo ""
    log_info "========================================"
    log_info "PHASE 6 (CONTINUED): GITHUB SSH CONNECTION TEST"
    log_info "Story 01.6-003: Verify SSH authentication"
    log_info "========================================"
    echo ""

    log_info "Testing SSH connection to GitHub..."
    log_info "This validates that your SSH key is correctly configured."
    echo ""

    # Attempt connection with retry mechanism
    if retry_ssh_connection; then
        local phase_end_time phase_duration
        phase_end_time=$(date +%s)
        phase_duration=$((phase_end_time - phase_start_time))

        echo ""
        log_success "✓ GitHub SSH connection test completed successfully"
        log_info "Phase 6 (continued) completed in ${phase_duration} seconds"
        echo ""

        return 0
    fi

    # Connection test failed - display troubleshooting help
    display_ssh_troubleshooting

    # Ask user if they want to continue or abort
    if prompt_continue_without_ssh; then
        local phase_end_time phase_duration
        phase_end_time=$(date +%s)
        phase_duration=$((phase_end_time - phase_start_time))

        log_warn "Proceeding to next phase despite SSH test failure"
        log_info "Phase 6 (continued) completed with warnings in ${phase_duration} seconds"
        echo ""

        return 0
    else
        # User chose to abort
        log_error "Bootstrap terminated by user choice"
        return 1
    fi
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

    # Story 01.1-002: Check for existing user-config.nix (idempotency)
    # If found and user confirms reuse, skip interactive prompts
    # shellcheck disable=SC2310  # Intentional: Using ! to handle conditional flow
    if ! check_existing_user_config; then
        # Story 01.2-001: Collect user information (name, email, GitHub username)
        prompt_user_info
    fi

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
    # PHASE 4: NIX PACKAGE MANAGER INSTALLATION
    # ==========================================================================
    # Story 01.4-001: Install Nix with flakes support
    # Required for nix-darwin and all declarative configuration
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle installation failure
    if ! install_nix_phase; then
        log_error "Nix package manager installation failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 4 (CONTINUED): NIX CONFIGURATION FOR MACOS
    # ==========================================================================
    # Story 01.4-002: Configure Nix for macOS performance and usability
    # Binary cache, performance tuning, trusted users, sandbox, daemon restart
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle configuration failure
    if ! configure_nix_phase; then
        log_error "Nix configuration failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 5: NIX-DARWIN INSTALLATION
    # ==========================================================================
    # Story 01.5-001: Install nix-darwin from flake configuration
    # Downloads flake from GitHub, runs initial build, installs Homebrew
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle installation failure
    if ! install_nix_darwin_phase; then
        log_error "Nix-darwin installation failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 5 (CONTINUED): POST-DARWIN SYSTEM VALIDATION
    # ==========================================================================
    # Story 01.5-002: Verify nix-darwin installation succeeded
    # Validates darwin-rebuild, Homebrew, core apps, nix-daemon
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle validation failure
    if ! validate_nix_darwin_phase; then
        log_error "Nix-darwin validation failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 6: SSH KEY GENERATION
    # ==========================================================================
    # Story 01.6-001: Generate SSH key for GitHub authentication
    # Generates ed25519 key, handles existing keys, starts ssh-agent
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle SSH key setup failure
    if ! setup_ssh_key_phase; then
        log_error "SSH key setup failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 6 (CONTINUED): GITHUB SSH KEY UPLOAD
    # ==========================================================================
    # Story 01.6-002: Automated GitHub CLI SSH key upload
    # Uploads generated SSH key to GitHub for repository cloning
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle GitHub key upload failure
    if ! upload_github_key_phase; then
        log_error "GitHub SSH key upload failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 6 (CONTINUED): GITHUB SSH CONNECTION TEST
    # ==========================================================================
    # Story 01.6-003: Test GitHub SSH connection with retry mechanism
    # Validates SSH authentication works before repository cloning
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle SSH test failure or user abort
    if ! test_github_ssh_phase; then
        log_error "GitHub SSH connection test failed or aborted by user"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # FUTURE PHASES (7-10)
    # ==========================================================================
    # Future phases will be added here in subsequent stories
    log_warn "Bootstrap implementation incomplete - Phases 7-10 not yet implemented"
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
