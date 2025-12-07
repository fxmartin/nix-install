# ABOUTME: Phase 9 - Installation summary and next steps
# ABOUTME: Displays installation results, FileVault prompt, useful commands
# ABOUTME: Depends on: lib/common.sh for logging functions

# Guard against double-sourcing
[[ -n "${_SUMMARY_SH_LOADED:-}" ]] && return 0
readonly _SUMMARY_SH_LOADED=1

# PHASE 9: INSTALLATION SUMMARY
#############################################################################
# Story 01.8-001: Display comprehensive installation summary
# Shows duration, components installed, next steps, useful commands
# This is the final phase that provides user guidance post-installation
#############################################################################

# Function: format_installation_duration
# Purpose: Calculate and format installation duration as human-readable string
# Arguments: $1 - start_time (Unix timestamp), $2 - end_time (Unix timestamp)
# Returns: Formatted duration string via stdout (e.g., "18 minutes 32 seconds")
# Exit: 0 always (non-critical formatting)
format_installation_duration() {
    local start_time="${1:-0}"
    local end_time="${2:-0}"
    local total_seconds=$((end_time - start_time))

    # Handle edge cases
    if [[ ${total_seconds} -lt 0 ]]; then
        echo "unknown duration"
        return 0
    elif [[ ${total_seconds} -eq 0 ]]; then
        echo "less than 1 second"
        return 0
    fi

    local hours=$((total_seconds / 3600))
    local minutes=$(( (total_seconds % 3600) / 60 ))
    local seconds=$((total_seconds % 60))

    # Build formatted string based on duration
    local duration_str=""

    if [[ ${hours} -gt 0 ]]; then
        if [[ ${hours} -eq 1 ]]; then
            duration_str="${hours} hour"
        else
            duration_str="${hours} hours"
        fi

        if [[ ${minutes} -gt 0 ]]; then
            if [[ ${minutes} -eq 1 ]]; then
                duration_str="${duration_str} ${minutes} minute"
            else
                duration_str="${duration_str} ${minutes} minutes"
            fi
        fi
    elif [[ ${minutes} -gt 0 ]]; then
        if [[ ${minutes} -eq 1 ]]; then
            duration_str="${minutes} minute"
        else
            duration_str="${minutes} minutes"
        fi

        if [[ ${seconds} -gt 0 ]]; then
            if [[ ${seconds} -eq 1 ]]; then
                duration_str="${duration_str} ${seconds} second"
            else
                duration_str="${duration_str} ${seconds} seconds"
            fi
        fi
    else
        # Less than 1 minute - show seconds only
        if [[ ${seconds} -eq 1 ]]; then
            duration_str="${seconds} second"
        else
            duration_str="${seconds} seconds"
        fi
    fi

    echo "${duration_str}"
    return 0
}

# Function: display_installed_components
# Purpose: Display summary of installed components (Nix, nix-darwin, profile, apps)
# Arguments: None (reads from environment: INSTALL_PROFILE)
# Returns: 0 always (non-critical display)
# Output: Formatted component list to stdout
display_installed_components() {
    local nix_version
    nix_version=$(nix --version 2>/dev/null | head -1 || echo "unknown")

    local app_count="unknown"
    case "${INSTALL_PROFILE:-standard}" in
        standard)
            app_count="47 applications"
            ;;
        power)
            app_count="51 applications"
            ;;
        *)
            app_count="~50 applications"
            ;;
    esac

    echo "Components Installed:"
    echo "  ✓ Nix Package Manager (${nix_version})"
    echo "  ✓ nix-darwin System Configuration"
    echo "  ✓ Home Manager User Configuration"
    echo "  ✓ Profile: ${INSTALL_PROFILE:-unknown} (${app_count})"
    echo ""

    return 0
}

# Function: check_filevault_status
# Purpose: Check if FileVault disk encryption is enabled
# Story: 03.2-002 (FileVault Encryption Prompt)
# Arguments: None
# Returns: 0 if FileVault enabled, 1 if disabled
# Output: Status message to stdout
check_filevault_status() {
    # Use fdesetup to check FileVault status
    # fdesetup status returns "FileVault is On" or "FileVault is Off"
    if fdesetup status | grep -q "FileVault is On"; then
        return 0  # FileVault enabled
    else
        return 1  # FileVault disabled
    fi
}

# Function: display_filevault_prompt
# Purpose: Display FileVault encryption prompt if not already enabled
# Story: 03.2-002 (FileVault Encryption Prompt)
# Arguments: None
# Returns: 0 always (non-critical display)
# Output: FileVault prompt to stdout if encryption disabled
display_filevault_prompt() {
    # Check FileVault status (non-intrusive)
    if check_filevault_status; then
        log_info "✓ FileVault disk encryption is already enabled"
        echo ""
        return 0
    fi

    # FileVault is disabled - display prominent prompt
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    log_warn "⚠️  SECURITY: FileVault Disk Encryption Not Enabled"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    log_warn "FileVault provides full-disk encryption to protect your data if your"
    log_warn "MacBook is lost, stolen, or accessed by unauthorized users."
    echo ""
    log_info "To enable FileVault:"
    echo ""
    echo "  1. Open System Settings → Privacy & Security → FileVault"
    echo "  2. Click 'Turn On FileVault'"
    echo "  3. Choose recovery method:"
    echo "     • iCloud account (easiest)"
    echo "     • Recovery key (save in 1Password - recommended)"
    echo "  4. Restart your Mac to begin encryption"
    echo ""
    log_warn "⚠️  IMPORTANT: Save your recovery key in 1Password!"
    log_warn "Without the recovery key, you cannot access your data if you forget your password."
    echo ""
    echo "Encryption happens in the background and may take several hours."
    echo "You can continue using your Mac during encryption."
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo ""

    return 0
}

# Function: display_next_steps
# Purpose: Display numbered next steps for user post-installation
# Arguments: None (reads from environment: INSTALL_PROFILE)
# Returns: 0 always (non-critical display)
# Output: Numbered steps to stdout (profile-aware)
display_next_steps() {
    echo "Next Steps:"
    echo ""
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo ""
    echo "  2. Activate licensed applications (see list below)"
    echo ""

    # Ollama verification step only for Power profile
    if [[ "${INSTALL_PROFILE:-standard}" == "power" ]]; then
        echo "  3. Verify Ollama models (Power profile):"
        echo "     ollama list"
        echo "     Expected: gpt-oss:20b, qwen2.5-coder:32b, llama3.1:70b, deepseek-r1:32b"
        echo ""
    fi

    return 0
}

# Function: display_useful_commands
# Purpose: Display useful commands for managing the system post-installation
# Arguments: None (reads from environment: REPO_CLONE_DIR)
# Returns: 0 always (non-critical display)
# Output: Command reference to stdout
display_useful_commands() {
    echo "Useful Commands:"
    echo ""
    echo "  sudo rebuild       Apply configuration changes from ${REPO_CLONE_DIR}"
    echo "  sudo update        Update packages and rebuild system"
    echo "  health-check       Verify system health and configuration"
    echo "  cleanup            Run garbage collection and free disk space"
    echo ""
    echo "  Note: rebuild and update require sudo (they use darwin-rebuild)"
    echo ""

    return 0
}

# Function: display_manual_activation_apps
# Purpose: Display list of apps requiring manual license activation
# Arguments: None (reads from environment: INSTALL_PROFILE)
# Returns: 0 always (non-critical display)
# Output: Bulleted list to stdout (profile-aware)
display_manual_activation_apps() {
    echo "Apps Requiring Manual Activation:"
    echo ""
    echo "  • 1Password (license key required)"
    echo "  • Microsoft Office (Office 365 subscription required)"

    # Parallels Desktop only for Power profile
    if [[ "${INSTALL_PROFILE:-standard}" == "power" ]]; then
        echo "  • Parallels Desktop (license key required)"
    fi

    echo ""

    return 0
}

# Function: display_documentation_paths
# Purpose: Display paths to documentation for further reference
# Arguments: None (reads from environment: REPO_CLONE_DIR)
# Returns: 0 always (non-critical display)
# Output: Documentation paths to stdout
display_documentation_paths() {
    echo "Documentation:"
    echo ""
    echo "  • Quick Start:     ${REPO_CLONE_DIR}/README.md"
    echo "  • Troubleshooting: ${REPO_CLONE_DIR}/docs/"
    echo ""

    return 0
}

# Function: installation_summary_phase
# Purpose: Main orchestration function for Phase 9 (Installation Summary)
# Workflow: Calculate duration → Display banner → Show all sections
# Arguments: None (reads from environment: BOOTSTRAP_START_TIME, INSTALL_PROFILE)
# Returns: 0 always (final phase, non-critical)
# Output: Complete installation summary to stdout
installation_summary_phase() {
    log_phase 9 "Installation Summary"

    # Calculate total installation duration
    local bootstrap_end_time duration_str
    bootstrap_end_time=$(date +%s)
    duration_str=$(format_installation_duration "${BOOTSTRAP_START_TIME:-${bootstrap_end_time}}" "${bootstrap_end_time}")

    log_info "Total Installation Time: ${duration_str}"
    echo ""

    # Display all summary sections
    echo "════════════════════════════════════════════════════════════════════"
    display_installed_components

    echo "════════════════════════════════════════════════════════════════════"
    display_next_steps

    echo "════════════════════════════════════════════════════════════════════"
    display_filevault_prompt

    echo "════════════════════════════════════════════════════════════════════"
    display_useful_commands

    echo "════════════════════════════════════════════════════════════════════"
    display_manual_activation_apps

    echo "════════════════════════════════════════════════════════════════════"
    display_documentation_paths

    echo "════════════════════════════════════════════════════════════════════"
    log_success "✨ Bootstrap Complete! Enjoy your declaratively configured MacBook!"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""

    return 0
}

# Main execution flow
