# ABOUTME: Phase 3 - Xcode Command Line Tools installation
# ABOUTME: Installs and verifies Xcode CLI Tools (required for Nix)
# ABOUTME: Depends on: lib/common.sh for logging functions

# Guard against double-sourcing
[[ -n "${_XCODE_SH_LOADED:-}" ]] && return 0
readonly _XCODE_SH_LOADED=1

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

    local dummy
    read_input dummy "Press ENTER when installation is complete... "
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
    local phase_start
    phase_start=$(date +%s)

    log_phase 3 "Xcode Command Line Tools" "~5 minutes"

    # Check if already installed
    if check_xcode_installed; then
        log_info "✓ Xcode CLI Tools already installed, skipping installation"
        local phase_end
        phase_end=$(date +%s)
        log_phase_complete 3 "Xcode Command Line Tools" $((phase_end - phase_start))
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
