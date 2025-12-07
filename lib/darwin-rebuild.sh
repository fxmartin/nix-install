# ABOUTME: Phase 8 - Final darwin-rebuild with full configuration
# ABOUTME: Loads profile, runs darwin-rebuild, verifies Home Manager symlinks
# ABOUTME: Depends on: lib/common.sh, lib/repo-clone.sh

# Guard against double-sourcing
[[ -n "${_DARWIN_REBUILD_SH_LOADED:-}" ]] && return 0
readonly _DARWIN_REBUILD_SH_LOADED=1

# PHASE 8: FINAL DARWIN REBUILD
# ==============================================================================
# Story 01.7-002: Perform final darwin-rebuild with cloned repository
# Applies complete system configuration from $REPO_CLONE_DIR
# ==============================================================================

# Function: load_profile_from_user_config
# Purpose: Extract INSTALL_PROFILE from user-config.nix (CRITICAL)
# Returns: 0 on success, 1 on failure
# Sets: INSTALL_PROFILE global variable
load_profile_from_user_config() {
    local user_config_path="${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    log_info "Loading installation profile from user-config.nix..."

    # Verify user-config.nix exists
    if [[ ! -f "${user_config_path}" ]]; then
        log_error "user-config.nix not found at: ${user_config_path}"
        log_error "This should have been created in Phase 2"
        return 1
    fi

    # Extract installProfile value from user-config.nix
    # Pattern: installProfile = "standard"; or installProfile = "power";
    # Note: Use non-greedy pattern to extract FIRST quoted string (not from comment)
    local profile_value
    profile_value=$(grep -E '^\s*installProfile\s*=\s*"(standard|power)";' "${user_config_path}" | sed -E 's/^[^=]*=[[:space:]]*"([^"]+)".*/\1/')

    if [[ -z "${profile_value}" ]]; then
        log_error "Could not extract installProfile from user-config.nix"
        log_error "File may be corrupted or invalid"
        return 1
    fi

    # Validate profile value
    if [[ "${profile_value}" != "standard" ]] && [[ "${profile_value}" != "power" ]]; then
        log_error "Invalid profile value in user-config.nix: ${profile_value}"
        log_error "Expected 'standard' or 'power'"
        return 1
    fi

    # Set global variable
    export INSTALL_PROFILE="${profile_value}"

    log_success "✓ Profile loaded: ${INSTALL_PROFILE}"
    return 0
}

# Function: ensure_nix_paths_in_path
# Purpose: Ensure Nix and darwin-rebuild are available in PATH
# Note: After Phase 5 nix-darwin install, darwin-rebuild is at /run/current-system/sw/bin
#       but the bootstrap shell may not have updated PATH yet
# Returns: 0 if darwin-rebuild is available, 1 if not found
ensure_nix_paths_in_path() {
    # Check if darwin-rebuild is already in PATH
    if command -v darwin-rebuild >/dev/null 2>&1; then
        log_info "✓ darwin-rebuild found in PATH"
        return 0
    fi

    log_info "darwin-rebuild not in PATH, adding Nix paths..."

    # Add nix-darwin system path (where darwin-rebuild lives after install)
    if [[ -d "/run/current-system/sw/bin" ]]; then
        export PATH="/run/current-system/sw/bin:${PATH}"
        log_info "Added /run/current-system/sw/bin to PATH"
    fi

    # Add Nix default profile (backup location)
    if [[ -d "/nix/var/nix/profiles/default/bin" ]]; then
        export PATH="/nix/var/nix/profiles/default/bin:${PATH}"
        log_info "Added /nix/var/nix/profiles/default/bin to PATH"
    fi

    # Add user's Nix profile
    if [[ -d "${HOME}/.nix-profile/bin" ]]; then
        export PATH="${HOME}/.nix-profile/bin:${PATH}"
        log_info "Added ~/.nix-profile/bin to PATH"
    fi

    # Source nix-daemon if available (ensures NIX_PATH and other vars are set)
    if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
        # shellcheck source=/dev/null
        . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        log_info "Sourced nix-daemon.sh"
    fi

    # Check again after PATH updates
    if command -v darwin-rebuild >/dev/null 2>&1; then
        log_info "✓ darwin-rebuild now available in PATH"
        return 0
    fi

    # Still not found - report detailed error
    log_error "darwin-rebuild still not found after updating PATH"
    log_error "Checked locations:"
    log_error "  - /run/current-system/sw/bin/darwin-rebuild"
    log_error "  - /nix/var/nix/profiles/default/bin/darwin-rebuild"
    log_error "  - ~/.nix-profile/bin/darwin-rebuild"
    log_error "Current PATH: ${PATH}"
    return 1
}

# Function: run_final_darwin_rebuild
# Purpose: Execute darwin-rebuild switch with cloned repository flake (CRITICAL)
# Returns: 0 on success, 1 on failure
# Arguments: None (uses $INSTALL_PROFILE and $REPO_CLONE_DIR)
run_final_darwin_rebuild() {
    local flake_ref="${REPO_CLONE_DIR}#${INSTALL_PROFILE}"
    local rebuild_start_time rebuild_end_time rebuild_duration

    echo ""
    log_info "========================================"
    log_info "RUNNING FINAL DARWIN-REBUILD"
    log_info "========================================"
    log_info "Profile: ${INSTALL_PROFILE}"
    log_info "Flake reference: ${flake_ref}"
    log_info "Repository: ${REPO_CLONE_DIR}"
    echo ""

    log_info "This will apply your complete system configuration..."
    log_info "Expected duration: 2-5 minutes (packages cached from initial build)"
    echo ""

    # darwin-rebuild switch requires sudo for system activation
    log_warn "This step requires sudo privileges for system activation"
    echo ""

    # CRITICAL: Ensure darwin-rebuild is available in PATH
    # After Phase 5 nix-darwin install, darwin-rebuild is installed but the current
    # shell session may not have updated PATH yet
    # Hotfix for Issue: "Cannot find darwin-rebuild command in PATH"
    log_info "Ensuring darwin-rebuild is available in PATH..."
    if ! ensure_nix_paths_in_path; then
        log_error "Failed to locate darwin-rebuild"
        log_error "Phase 5 nix-darwin installation may have failed"
        return 1
    fi
    echo ""

    rebuild_start_time=$(date +%s)

    # Find full path to darwin-rebuild (Hotfix #13 - Issue #22)
    # When running with sudo, the root user doesn't have the same PATH as the regular user
    # Nix tools are in user's PATH via shell profile, but not in root's PATH
    # Solution: Find full path first, then use it with sudo
    local darwin_rebuild_path
    darwin_rebuild_path=$(command -v darwin-rebuild)

    if [[ -z "${darwin_rebuild_path}" ]]; then
        log_error "Cannot find darwin-rebuild command in PATH"
        log_error "Expected location: /nix/var/nix/profiles/default/bin/darwin-rebuild"
        log_error "Check that Nix is properly installed and sourced"
        return 1
    fi

    log_info "Found darwin-rebuild: ${darwin_rebuild_path}"

    # Execute darwin-rebuild switch with sudo using full path
    log_info "Executing: sudo ${darwin_rebuild_path} switch --flake ${flake_ref}"
    echo ""

    if sudo "${darwin_rebuild_path}" switch --flake "${flake_ref}"; then
        rebuild_end_time=$(date +%s)
        rebuild_duration=$((rebuild_end_time - rebuild_start_time))

        echo ""
        log_success "✓ Darwin-rebuild completed successfully"
        log_info "Build time: ${rebuild_duration} seconds"
        return 0
    else
        rebuild_end_time=$(date +%s)
        rebuild_duration=$((rebuild_end_time - rebuild_start_time))

        echo ""
        log_error "Darwin-rebuild failed after ${rebuild_duration} seconds"
        log_error "Check the error messages above for details"
        return 1
    fi
}

# Function: verify_home_manager_symlinks
# Purpose: Validate Home Manager created symlinks in home directory (NON-CRITICAL)
# Returns: 0 always (warnings only, not fatal)
verify_home_manager_symlinks() {
    log_info "Verifying Home Manager symlinks..."

    local symlinks_found=0
    local symlink_checks=(
        "${HOME}/.config/ghostty:Ghostty terminal config"
        "${HOME}/.zshrc:Zsh shell config"
        "${HOME}/.gitconfig:Git configuration"
        "${HOME}/.config/starship.toml:Starship prompt config"
    )

    echo ""
    for check in "${symlink_checks[@]}"; do
        local path="${check%%:*}"
        local description="${check##*:}"

        if [[ -L "${path}" ]] || [[ -f "${path}" ]]; then
            log_success "  ✓ ${description}: ${path}"
            ((symlinks_found++))
        else
            log_warn "  ⚠ ${description} not found: ${path}"
        fi
    done
    echo ""

    if [[ ${symlinks_found} -eq 0 ]]; then
        log_warn "No Home Manager symlinks detected"
        log_warn "This may be normal if home-manager modules aren't configured yet"
        log_warn "Check ${REPO_CLONE_DIR}/home-manager/ for configuration"
    else
        log_success "✓ Found ${symlinks_found} Home Manager symlinks"
    fi

    return 0
}

# Function: display_rebuild_success_message
# Purpose: Display formatted success message for Phase 8 (NON-CRITICAL)
# Returns: 0 always
display_rebuild_success_message() {
    local rebuild_duration="${1:-0}"
    local rebuild_minutes=$((rebuild_duration / 60))
    local rebuild_seconds=$((rebuild_duration % 60))

    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    log_success "🎉 BOOTSTRAP COMPLETE! YOUR SYSTEM IS CONFIGURED!"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    log_info "Profile Applied: ${INSTALL_PROFILE}"
    log_info "Configuration: ${REPO_CLONE_DIR}"
    log_info "Build Time: ${rebuild_minutes}m ${rebuild_seconds}s"
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    log_info "NEXT STEPS"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    log_info "1. Restart your terminal or run: source ~/.zshrc"
    echo ""
    log_info "2. Activate licensed applications:"
    log_info "   • Office 365: Sign in with your Microsoft account"
    log_info "   • 1Password: Sign in and set up browser extensions"
    log_info "   • Dropbox: Sign in and configure selective sync"
    echo ""

    if [[ "${INSTALL_PROFILE}" == "power" ]]; then
        log_info "3. Verify Ollama models (Power profile):"
        log_info "   ollama list"
        log_info "   Expected: gpt-oss:20b, qwen2.5-coder:32b, llama3.1:70b, deepseek-r1:32b"
        echo ""
        log_info "4. Configure Parallels Desktop (Power profile):"
        log_info "   • Launch Parallels Desktop"
        log_info "   • Activate your license"
        log_info "   • Set up development VMs as needed"
        echo ""
    fi

    echo "════════════════════════════════════════════════════════════════════"
    log_info "USEFUL COMMANDS"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    log_info "rebuild      Apply configuration changes from ${REPO_CLONE_DIR}"
    log_info "update       Update packages and rebuild system"
    log_info "health-check Verify system health and configuration"
    log_info "cleanup      Run garbage collection and free disk space"
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    log_info "DOCUMENTATION"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    log_info "Quick Start:  ${REPO_CLONE_DIR}/README.md"
    log_info "Customization: ${REPO_CLONE_DIR}/docs/customization.md"
    log_info "Troubleshooting: ${REPO_CLONE_DIR}/docs/troubleshooting.md"
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    log_success "✨ Enjoy your declaratively configured MacBook!"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""

    return 0
}

# Function: final_darwin_rebuild_phase
# Purpose: Orchestrate final darwin-rebuild phase (Phase 8)
# Workflow: Load profile → Run rebuild → Verify symlinks → Success message
# Returns: 0 on success, 1 on failure
final_darwin_rebuild_phase() {
    local phase_start_time
    phase_start_time=$(date +%s)
    log_phase 8 "Final Darwin Rebuild" "~5-10 minutes"

    # Step 1: Load profile from user-config.nix (CRITICAL)
    log_info "Step 1/3: Loading installation profile..."
    if ! load_profile_from_user_config; then
        log_error "Failed to load profile from user-config.nix"
        return 1
    fi
    echo ""

    # Prepare for Home Manager shell management (NON-CRITICAL)
    # Home Manager needs to manage ~/.zshrc for Oh My Zsh, FZF, autosuggestions, etc.
    log_info "Preparing shell configuration for Home Manager..."
    if [[ -f "${HOME}/.zshrc" && ! -L "${HOME}/.zshrc" ]]; then
        log_info "Found existing ~/.zshrc (not managed by Home Manager)"
        log_info "Backing up to ~/.zshrc.pre-nix-install"
        mv "${HOME}/.zshrc" "${HOME}/.zshrc.pre-nix-install"
        log_success "✓ Backed up existing .zshrc - Home Manager will create new one"
    elif [[ -L "${HOME}/.zshrc" ]]; then
        log_info "~/.zshrc is already a symlink (likely Home Manager managed)"
    else
        log_info "No existing ~/.zshrc found - Home Manager will create one"
    fi
    echo ""

    # Step 2: Run darwin-rebuild switch (CRITICAL)
    log_info "Step 2/3: Running darwin-rebuild switch..."
    log_info "This will apply your complete system configuration from:"
    log_info "  ${REPO_CLONE_DIR}"
    echo ""

    if ! run_final_darwin_rebuild; then
        log_error "Darwin-rebuild failed"
        log_error "Your system may be in a partially configured state"
        log_error "Try running: sudo darwin-rebuild switch --flake ${REPO_CLONE_DIR}#${INSTALL_PROFILE}"
        return 1
    fi
    echo ""

    # Step 3: Verify Home Manager symlinks (NON-CRITICAL)
    log_info "Step 3/3: Verifying Home Manager symlinks..."
    verify_home_manager_symlinks
    echo ""

    # Calculate phase duration and display success
    local phase_end_time
    phase_end_time=$(date +%s)
    local phase_duration=$((phase_end_time - phase_start_time))

    display_rebuild_success_message "${phase_duration}"
    log_phase_complete 8 "Final Darwin Rebuild" "${phase_duration}"

    return 0
}

#############################################################################
