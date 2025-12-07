#!/usr/bin/env bash
# ABOUTME: Stage 2 bootstrap installer - interactive macOS configuration with Nix-Darwin
# ABOUTME: Modular version that sources lib/*.sh library files
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

# ==============================================================================
# LIBRARY MODULE SOURCING
# ==============================================================================
# Source all library modules in dependency order
# Each module has double-sourcing guards to prevent reloading
# ==============================================================================

# Determine script directory (works for both direct execution and sourcing)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries in dependency order
# All modules depend on common.sh, so load it first
if [[ -f "${SCRIPT_DIR}/lib/common.sh" ]]; then
    # shellcheck source=lib/common.sh
    source "${SCRIPT_DIR}/lib/common.sh"
else
    echo "ERROR: lib/common.sh not found. Cannot continue." >&2
    exit 1
fi

# Phase-specific modules
# shellcheck source=lib/preflight.sh
source "${SCRIPT_DIR}/lib/preflight.sh" || {
    log_error "Failed to source lib/preflight.sh"
    exit 1
}

# shellcheck source=lib/user-config.sh
source "${SCRIPT_DIR}/lib/user-config.sh" || {
    log_error "Failed to source lib/user-config.sh"
    exit 1
}

# shellcheck source=lib/xcode.sh
source "${SCRIPT_DIR}/lib/xcode.sh" || {
    log_error "Failed to source lib/xcode.sh"
    exit 1
}

# shellcheck source=lib/nix-install.sh
source "${SCRIPT_DIR}/lib/nix-install.sh" || {
    log_error "Failed to source lib/nix-install.sh"
    exit 1
}

# shellcheck source=lib/nix-darwin.sh
source "${SCRIPT_DIR}/lib/nix-darwin.sh" || {
    log_error "Failed to source lib/nix-darwin.sh"
    exit 1
}

# shellcheck source=lib/ssh-github.sh
source "${SCRIPT_DIR}/lib/ssh-github.sh" || {
    log_error "Failed to source lib/ssh-github.sh"
    exit 1
}

# shellcheck source=lib/repo-clone.sh
source "${SCRIPT_DIR}/lib/repo-clone.sh" || {
    log_error "Failed to source lib/repo-clone.sh"
    exit 1
}

# shellcheck source=lib/darwin-rebuild.sh
source "${SCRIPT_DIR}/lib/darwin-rebuild.sh" || {
    log_error "Failed to source lib/darwin-rebuild.sh"
    exit 1
}

# shellcheck source=lib/summary.sh
source "${SCRIPT_DIR}/lib/summary.sh" || {
    log_error "Failed to source lib/summary.sh"
    exit 1
}

# ==============================================================================
# MAIN ORCHESTRATOR
# ==============================================================================
# Calls each phase in sequence
# All phase functions are defined in lib/*.sh modules
# ==============================================================================

main() {
    # Track bootstrap start time for installation summary (Phase 9)
    BOOTSTRAP_START_TIME=$(date +%s)
    readonly BOOTSTRAP_START_TIME

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

    # shellcheck disable=SC2310  # Intentional: Using ! to handle validation failure
    if ! preflight_checks; then
        log_error "Pre-flight checks failed. Aborting installation."
        echo ""
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 2: USER CONFIGURATION & PROFILE SELECTION
    # ==========================================================================
    # This is the first phase with interactive prompts, which is why the
    # two-stage bootstrap pattern exists - to ensure stdin works correctly.
    # ==========================================================================

    local phase2_start
    phase2_start=$(date +%s)
    log_phase 2 "User Configuration & Profile Selection" "~2 minutes"

    # Story 01.1-002: Check for existing user-config.nix (idempotency)
    # If found and user confirms reuse, skip interactive prompts
    # shellcheck disable=SC2310  # Intentional: Using ! to handle conditional flow
    if ! check_existing_user_config; then
        # Story 01.2-001: Collect user information (name, email, GitHub username)
        prompt_user_info
    fi

    # Story 01.2-002: Select installation profile (Standard vs Power)
    select_installation_profile

    # Prompt for Mac App Store apps preference
    prompt_mas_apps_preference

    # Story 01.2-003: Generate user-config.nix from collected information
    # shellcheck disable=SC2310  # Intentional: Using ! to handle validation failure
    if ! generate_user_config; then
        log_error "Failed to generate user configuration file"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # Story 02.8-001: Parallels Desktop requires terminal FDA for installation
    # Only check for Power profile (Parallels is Power-only)
    if [[ "${INSTALL_PROFILE}" == "power" ]]; then
        log_info "Power profile requires terminal Full Disk Access for Parallels Desktop installation."
        echo ""

        # shellcheck disable=SC2310  # Intentional: Using ! to handle validation failure
        if ! check_terminal_full_disk_access; then
            log_error "Terminal Full Disk Access check failed"
            log_error "Please grant FDA to your terminal and relaunch before continuing."
            log_error "Bootstrap process terminated."
            exit 1
        fi

        log_info "✓ Terminal has required permissions for Power profile"
        echo ""
    fi

    local phase2_end
    phase2_end=$(date +%s)
    log_phase_complete 2 "User Configuration & Profile Selection" $((phase2_end - phase2_start))

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
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle installation failure
    if ! install_nix_phase; then
        log_error "Nix installation failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # Story 01.4-002: Configure Nix (binary cache, performance tuning)
    # shellcheck disable=SC2310  # Intentional: Using ! to handle configuration failure
    if ! configure_nix_phase; then
        log_error "Nix configuration failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 5: NIX-DARWIN INSTALLATION
    # ==========================================================================
    # Story 01.5-001: Install nix-darwin (declarative system configuration)
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle installation failure
    if ! install_nix_darwin_phase; then
        log_error "nix-darwin installation failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # Story 01.5-002: Validate nix-darwin installation
    # shellcheck disable=SC2310  # Intentional: Using ! to handle validation failure
    if ! validate_nix_darwin_phase; then
        log_error "nix-darwin validation failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 6: SSH KEY GENERATION & GITHUB AUTHENTICATION
    # ==========================================================================
    # Story 01.6-001: Generate SSH keys for GitHub access
    # Story 01.6-002: Upload SSH key to GitHub
    # Story 01.6-003: Test GitHub SSH connection
    # ==========================================================================

    # Generate SSH key
    # shellcheck disable=SC2310  # Intentional: Using ! to handle setup failure
    if ! setup_ssh_key_phase; then
        log_error "SSH key setup failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # Upload to GitHub
    # shellcheck disable=SC2310  # Intentional: Using ! to handle upload failure
    if ! upload_github_key_phase; then
        log_error "GitHub key upload failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # Test connection
    # shellcheck disable=SC2310  # Intentional: Using ! to handle test failure
    if ! test_github_ssh_phase; then
        log_error "GitHub SSH connection test failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 7: REPOSITORY CLONE
    # ==========================================================================
    # Story 01.7-001: Clone nix-install repository via SSH
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle clone failure
    if ! clone_repository_phase; then
        log_error "Repository clone failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 8: FINAL DARWIN-REBUILD
    # ==========================================================================
    # Story 01.8-001: Run final darwin-rebuild with full configuration
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle rebuild failure
    if ! final_darwin_rebuild_phase; then
        log_error "Final darwin-rebuild failed"
        log_error "Bootstrap process terminated."
        exit 1
    fi

    # ==========================================================================
    # PHASE 9: INSTALLATION SUMMARY
    # ==========================================================================
    # Story 01.9-002: Display installation summary and next steps
    # ==========================================================================

    # shellcheck disable=SC2310  # Intentional: Using ! to handle summary failure
    if ! installation_summary_phase; then
        log_warn "Installation summary display had issues (non-critical)"
    fi

    # Bootstrap complete!
    echo ""
    log_success "========================================"
    log_success "Bootstrap Installation Complete!"
    log_success "========================================"
    echo ""
    log_info "Your macOS system is now configured with Nix-Darwin."
    log_info "Restart your terminal to apply all changes."
    echo ""

    return 0
}

# ==============================================================================
# SCRIPT ENTRY POINT
# ==============================================================================
# Call main function with all arguments
# ==============================================================================

main "$@"
