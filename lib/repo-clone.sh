# ABOUTME: Phase 7 - Repository cloning and user config deployment
# ABOUTME: Clones nix-install repo, copies user-config.nix to proper location
# ABOUTME: Depends on: lib/common.sh, lib/ssh-github.sh

# Guard against double-sourcing
[[ -n "${_REPO_CLONE_SH_LOADED:-}" ]] && return 0
readonly _REPO_CLONE_SH_LOADED=1

# PHASE 7: REPOSITORY CLONE
# Story 01.7-001: Clone nix-install repository to ~/Documents
# =============================================================================

# Function: create_documents_directory
# Purpose: Ensure ~/Documents directory exists for repository clone (NON-CRITICAL)
# Returns: 0 on success or if directory already exists, 1 on failure
create_documents_directory() {
    local documents_dir="${HOME}/Documents"

    # Check if Documents directory already exists
    if [[ -d "${documents_dir}" ]]; then
        log_info "✓ Documents directory already exists"
        return 0
    fi

    # Create Documents directory
    log_info "Creating ~/Documents directory..."
    if ! mkdir -p "${documents_dir}"; then
        log_error "Failed to create ~/Documents directory"
        log_error "Check filesystem permissions"
        return 1
    fi

    log_success "✓ Documents directory created"
    return 0
}

# Function: check_existing_repo_directory
# Purpose: Check if nix-install directory already exists at configured location (NON-CRITICAL)
# Returns: 0 if exists, 1 if not found
check_existing_repo_directory() {
    if [[ -d "${REPO_CLONE_DIR}" ]] || [[ -e "${REPO_CLONE_DIR}" ]]; then
        return 0
    else
        return 1
    fi
}

# Function: prompt_remove_existing_repo
# Purpose: Interactive prompt to remove existing repository directory (CRITICAL)
# Returns: 0 if user wants to remove, 1 if user wants to skip clone
prompt_remove_existing_repo() {
    echo ""
    log_warn "========================================"
    log_warn "EXISTING DIRECTORY DETECTED"
    log_warn "========================================"
    echo ""

    log_warn "Directory already exists: ${REPO_CLONE_DIR}"
    log_warn ""
    log_warn "WARNING: Removing this directory will DELETE ALL CONTENTS"
    log_warn "If you have uncommitted changes, they will be LOST"
    echo ""

    while true; do
        read_input response "Remove existing directory and re-clone? (y/n): "
        case "${response}" in
            y|Y)
                log_info "User chose to remove and re-clone"
                return 0
                ;;
            n|N)
                log_info "User chose to skip clone"
                return 1
                ;;
            *)
                log_error "Invalid input. Please enter 'y' or 'n'"
                ;;
        esac
    done
}

# Function: remove_existing_repo_directory
# Purpose: Remove existing repository directory recursively (CRITICAL)
# Returns: 0 on success, 1 on failure
remove_existing_repo_directory() {
    # Check if directory exists first (idempotent)
    if [[ ! -d "${REPO_CLONE_DIR}" ]] && [[ ! -e "${REPO_CLONE_DIR}" ]]; then
        log_info "✓ No existing directory to remove"
        return 0
    fi

    log_info "Removing existing directory..."
    log_info "Path: ${REPO_CLONE_DIR}"

    # Remove directory recursively
    if ! rm -rf "${REPO_CLONE_DIR}"; then
        log_error "Failed to remove existing directory"
        log_error "Check filesystem permissions"
        return 1
    fi

    log_success "✓ Existing directory removed"
    return 0
}

# Function: clone_repository
# Purpose: Clone nix-install repository from GitHub via SSH (CRITICAL)
# Method: git clone git@github.com:fxmartin/nix-install.git $REPO_CLONE_DIR
# Default location: ~/.config/nix-install (configurable via NIX_INSTALL_DIR)
# Returns: 0 on success, exits script on failure
clone_repository() {
    local repo_url="git@github.com:fxmartin/nix-install.git"

    log_info "Cloning repository from GitHub..."
    log_info "URL: ${repo_url}"
    log_info "Destination: ${REPO_CLONE_DIR}"
    echo ""

    # Check available disk space (require at least 500MB)
    local available_space
    available_space=$(df -k "${HOME}/Documents" | awk 'NR==2 {print $4}')
    local required_space=512000  # 500MB in KB

    if [[ "${available_space}" -lt "${required_space}" ]]; then
        log_warn "Low disk space detected (less than 500MB available)"
        log_warn "Available: $((available_space / 1024))MB"
        log_warn "Recommended: 500MB"
    fi

    # Clone repository using SSH
    if ! git clone "${repo_url}" "${REPO_CLONE_DIR}"; then
        echo ""
        log_error "Git clone failed"
        log_error ""
        log_error "Troubleshooting:"
        log_error "1. Verify SSH connection: ssh -T git@github.com"
        log_error "2. Check GitHub key upload: gh ssh-key list"
        log_error "3. Verify network connection"
        log_error "4. Check disk space: df -h"
        log_error "5. Try manual clone: git clone ${repo_url}"
        echo ""
        return 1
    fi

    echo ""
    log_success "✓ Repository cloned successfully"
    return 0
}

# Function: copy_user_config_to_repo
# Purpose: Copy generated user-config.nix from /tmp to repository (CRITICAL)
# Behavior: ALWAYS overwrites existing user-config.nix with freshly generated one
#           The user already confirmed their settings in Phase 2, so we use those values
#           This ensures paths (dotfiles) and settings match the current bootstrap environment
# Returns: 0 on success, 1 on failure
copy_user_config_to_repo() {
    local source_config="${BOOTSTRAP_TEMP_DIR}/user-config.nix"
    local dest_config="${REPO_CLONE_DIR}/user-config.nix"

    # Validate source file exists
    if [[ ! -f "${source_config}" ]]; then
        log_error "Source user-config.nix not found: ${source_config}"
        log_error "This should have been created in Phase 2"
        return 1
    fi

    # Check if destination already exists - we'll overwrite it with fresh config
    if [[ -f "${dest_config}" ]]; then
        log_info "user-config.nix exists in repository - will update with fresh configuration"
        log_info "Backing up existing config to user-config.nix.backup"
        cp "${dest_config}" "${dest_config}.backup" 2>/dev/null || true
    fi

    # Copy user-config.nix to repository (always use freshly generated config)
    log_info "Copying user-config.nix to repository..."
    if ! cp "${source_config}" "${dest_config}"; then
        log_error "Failed to copy user-config.nix"
        log_error "Check filesystem permissions"
        return 1
    fi

    # Validate copy was successful
    if [[ ! -f "${dest_config}" ]]; then
        log_error "user-config.nix copy verification failed"
        return 1
    fi

    log_success "✓ User configuration copied to repository"

    # Mark user-config.nix as skip-worktree so local changes aren't tracked
    # This prevents accidental commits of personal info while keeping the file visible to Nix
    # The file remains in git's index (required by Nix flakes) but local changes are ignored
    log_info "Marking user-config.nix as skip-worktree..."
    if ! (cd "${REPO_CLONE_DIR}" && git update-index --skip-worktree user-config.nix); then
        log_warning "Could not set skip-worktree on user-config.nix"
        log_warning "Your personal config may appear in git status - do NOT commit it"
    else
        log_success "✓ User configuration protected from accidental commits"
    fi

    return 0
}

# Function: verify_repository_clone
# Purpose: Validate repository clone integrity (CRITICAL)
# Checks: .git directory exists, flake.nix exists, user-config.nix exists, git status works
# Returns: 0 on success, 1 on failure
verify_repository_clone() {
    log_info "Verifying repository clone integrity..."
    echo ""

    local validation_failed=0

    # Check 1: .git directory exists
    if [[ -d "${REPO_CLONE_DIR}/.git" ]]; then
        log_success "  ✓ Git directory exists"
    else
        log_error "  ✗ Git directory missing"
        validation_failed=1
    fi

    # Check 2: flake.nix exists
    if [[ -f "${REPO_CLONE_DIR}/flake.nix" ]]; then
        log_success "  ✓ Flake configuration exists"
    else
        log_error "  ✗ Flake configuration missing"
        validation_failed=1
    fi

    # Check 3: user-config.nix exists
    if [[ -f "${REPO_CLONE_DIR}/user-config.nix" ]]; then
        log_success "  ✓ User configuration exists"
    else
        log_error "  ✗ User configuration missing"
        validation_failed=1
    fi

    # Check 4: Git repository is valid
    if git -C "${REPO_CLONE_DIR}" status >/dev/null 2>&1; then
        log_success "  ✓ Git repository valid"
    else
        log_error "  ✗ Git repository corrupted or invalid"
        validation_failed=1
    fi

    echo ""

    if [[ "${validation_failed}" -eq 1 ]]; then
        log_error "Repository verification failed"
        log_error "Clone may be incomplete or corrupted"
        return 1
    fi

    log_success "✓ Repository verification passed"
    return 0
}

# Function: display_clone_success_message
# Purpose: Display formatted success message for Phase 7 (NON-CRITICAL)
# Returns: 0 always
display_clone_success_message() {
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    log_success "✨ Repository Clone Complete!"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    log_info "Repository location: ${REPO_CLONE_DIR}"
    echo ""
    log_info "Next: Phase 8 will perform initial Nix evaluation"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""

    return 0
}

# Function: clone_repository_phase
# Purpose: Orchestrate repository clone phase (Phase 7)
# Workflow: Create Documents → Check existing → Clone → Copy config → Verify → Success message
# Returns: 0 on success, 1 on failure or user abort
clone_repository_phase() {
    local phase_start_time
    phase_start_time=$(date +%s)
    log_phase 7 "Repository Clone" "~1-2 minutes"

    # Step 1: Create ~/Documents directory if needed (NON-CRITICAL)
    log_info "Step 1/5: Creating ~/Documents directory..."
    if ! create_documents_directory; then
        log_error "Failed to create Documents directory"
        return 1
    fi
    echo ""

    # Step 2: Check for existing repository directory (NON-CRITICAL)
    log_info "Step 2/5: Checking for existing repository..."
    if check_existing_repo_directory; then
        log_warn "Existing repository directory found: ${REPO_CLONE_DIR}"
        echo ""

        # Prompt user to remove or skip
        if prompt_remove_existing_repo; then
            # User wants to remove and re-clone
            if ! remove_existing_repo_directory; then
                log_error "Failed to remove existing directory"
                return 1
            fi
        else
            # User wants to skip clone
            log_info "Skipping repository clone (using existing directory)"
            echo ""

            # Still need to verify and copy user-config.nix
            log_info "Copying user-config.nix to existing repository..."
            if ! copy_user_config_to_repo; then
                log_error "Failed to copy user-config.nix"
                return 1
            fi
            echo ""

            # Verify existing repository
            log_info "Verifying existing repository..."
            if ! verify_repository_clone; then
                log_error "Existing repository verification failed"
                log_warn "Consider removing and re-cloning"
                return 1
            fi

            # Display success and return
            display_clone_success_message

            local phase_end_time
            phase_end_time=$(date +%s)
            log_phase_complete 7 "Repository Clone" $((phase_end_time - phase_start_time))

            return 0
        fi
    else
        log_success "✓ No existing repository found"
    fi
    echo ""

    # Step 3: Clone repository from GitHub (CRITICAL)
    log_info "Step 3/5: Cloning repository from GitHub..."
    if ! clone_repository; then
        log_error "Repository clone failed"
        return 1
    fi
    echo ""

    # Step 4: Copy user-config.nix to repository (CRITICAL)
    log_info "Step 4/5: Copying user-config.nix..."
    if ! copy_user_config_to_repo; then
        log_error "Failed to copy user configuration"
        return 1
    fi
    echo ""

    # Step 5: Verify repository clone (CRITICAL)
    log_info "Step 5/5: Verifying repository clone..."
    if ! verify_repository_clone; then
        log_error "Repository verification failed"
        return 1
    fi

    # Display success message
    display_clone_success_message

    local phase_end_time
    phase_end_time=$(date +%s)
    log_phase_complete 7 "Repository Clone" $((phase_end_time - phase_start_time))

    return 0
}

# ==============================================================================
