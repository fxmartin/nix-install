# ABOUTME: Phase 5 - nix-darwin installation and validation
# ABOUTME: Downloads flake files, runs darwin-rebuild, validates installation
# ABOUTME: Depends on: lib/common.sh, lib/nix-install.sh

# Guard against double-sourcing
[[ -n "${_NIX_DARWIN_SH_LOADED:-}" ]] && return 0
readonly _NIX_DARWIN_SH_LOADED=1

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
        "stylix.nix"
        "maintenance.nix"
        "calibre.nix"
        # Power profile only (downloaded for both but only used by power)
        "smb-automount.nix"
        "rsync-backup.nix"
        "icloud-sync.nix"
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

    log_info "  - home-manager/modules/git.nix"
    if ! curl -fsSL -o "home-manager/modules/git.nix" "${base_url}/home-manager/modules/git.nix"; then
        log_error "Failed to fetch home-manager/modules/git.nix"
        return 1
    fi
    [[ -s "home-manager/modules/git.nix" ]] || {
        log_error "Downloaded home-manager/modules/git.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/ssh.nix"
    if ! curl -fsSL -o "home-manager/modules/ssh.nix" "${base_url}/home-manager/modules/ssh.nix"; then
        log_error "Failed to fetch home-manager/modules/ssh.nix"
        return 1
    fi
    [[ -s "home-manager/modules/ssh.nix" ]] || {
        log_error "Downloaded home-manager/modules/ssh.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/zed.nix"
    if ! curl -fsSL -o "home-manager/modules/zed.nix" "${base_url}/home-manager/modules/zed.nix"; then
        log_error "Failed to fetch home-manager/modules/zed.nix"
        return 1
    fi
    [[ -s "home-manager/modules/zed.nix" ]] || {
        log_error "Downloaded home-manager/modules/zed.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/vscode.nix"
    if ! curl -fsSL -o "home-manager/modules/vscode.nix" "${base_url}/home-manager/modules/vscode.nix"; then
        log_error "Failed to fetch home-manager/modules/vscode.nix"
        return 1
    fi
    [[ -s "home-manager/modules/vscode.nix" ]] || {
        log_error "Downloaded home-manager/modules/vscode.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/ghostty.nix"
    if ! curl -fsSL -o "home-manager/modules/ghostty.nix" "${base_url}/home-manager/modules/ghostty.nix"; then
        log_error "Failed to fetch home-manager/modules/ghostty.nix"
        return 1
    fi
    [[ -s "home-manager/modules/ghostty.nix" ]] || {
        log_error "Downloaded home-manager/modules/ghostty.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/claude-code.nix"
    if ! curl -fsSL -o "home-manager/modules/claude-code.nix" "${base_url}/home-manager/modules/claude-code.nix"; then
        log_error "Failed to fetch home-manager/modules/claude-code.nix"
        return 1
    fi
    [[ -s "home-manager/modules/claude-code.nix" ]] || {
        log_error "Downloaded home-manager/modules/claude-code.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/python.nix"
    if ! curl -fsSL -o "home-manager/modules/python.nix" "${base_url}/home-manager/modules/python.nix"; then
        log_error "Failed to fetch home-manager/modules/python.nix"
        return 1
    fi
    [[ -s "home-manager/modules/python.nix" ]] || {
        log_error "Downloaded home-manager/modules/python.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/podman.nix"
    if ! curl -fsSL -o "home-manager/modules/podman.nix" "${base_url}/home-manager/modules/podman.nix"; then
        log_error "Failed to fetch home-manager/modules/podman.nix"
        return 1
    fi
    [[ -s "home-manager/modules/podman.nix" ]] || {
        log_error "Downloaded home-manager/modules/podman.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/msmtp.nix"
    if ! curl -fsSL -o "home-manager/modules/msmtp.nix" "${base_url}/home-manager/modules/msmtp.nix"; then
        log_error "Failed to fetch home-manager/modules/msmtp.nix"
        return 1
    fi
    [[ -s "home-manager/modules/msmtp.nix" ]] || {
        log_error "Downloaded home-manager/modules/msmtp.nix is empty"
        return 1
    }

    # CLI tool configurations with Catppuccin theming
    log_info "  - home-manager/modules/btop.nix"
    if ! curl -fsSL -o "home-manager/modules/btop.nix" "${base_url}/home-manager/modules/btop.nix"; then
        log_error "Failed to fetch home-manager/modules/btop.nix"
        return 1
    fi
    [[ -s "home-manager/modules/btop.nix" ]] || {
        log_error "Downloaded home-manager/modules/btop.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/bat.nix"
    if ! curl -fsSL -o "home-manager/modules/bat.nix" "${base_url}/home-manager/modules/bat.nix"; then
        log_error "Failed to fetch home-manager/modules/bat.nix"
        return 1
    fi
    [[ -s "home-manager/modules/bat.nix" ]] || {
        log_error "Downloaded home-manager/modules/bat.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/ripgrep.nix"
    if ! curl -fsSL -o "home-manager/modules/ripgrep.nix" "${base_url}/home-manager/modules/ripgrep.nix"; then
        log_error "Failed to fetch home-manager/modules/ripgrep.nix"
        return 1
    fi
    [[ -s "home-manager/modules/ripgrep.nix" ]] || {
        log_error "Downloaded home-manager/modules/ripgrep.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/fd.nix"
    if ! curl -fsSL -o "home-manager/modules/fd.nix" "${base_url}/home-manager/modules/fd.nix"; then
        log_error "Failed to fetch home-manager/modules/fd.nix"
        return 1
    fi
    [[ -s "home-manager/modules/fd.nix" ]] || {
        log_error "Downloaded home-manager/modules/fd.nix is empty"
        return 1
    }

    log_info "  - home-manager/modules/httpie.nix"
    if ! curl -fsSL -o "home-manager/modules/httpie.nix" "${base_url}/home-manager/modules/httpie.nix"; then
        log_error "Failed to fetch home-manager/modules/httpie.nix"
        return 1
    fi
    [[ -s "home-manager/modules/httpie.nix" ]] || {
        log_error "Downloaded home-manager/modules/httpie.nix is empty"
        return 1
    }

    # Fetch maintenance scripts (Epic-06)
    log_info "Fetching maintenance scripts..."
    mkdir -p scripts

    log_info "  - scripts/health-check.sh"
    if ! curl -fsSL -o "scripts/health-check.sh" "${base_url}/scripts/health-check.sh"; then
        log_error "Failed to fetch scripts/health-check.sh"
        return 1
    fi
    [[ -s "scripts/health-check.sh" ]] || {
        log_error "Downloaded scripts/health-check.sh is empty"
        return 1
    }
    chmod +x "scripts/health-check.sh"

    log_info "  - scripts/setup-msmtp-keychain.sh"
    if ! curl -fsSL -o "scripts/setup-msmtp-keychain.sh" "${base_url}/scripts/setup-msmtp-keychain.sh"; then
        log_error "Failed to fetch scripts/setup-msmtp-keychain.sh"
        return 1
    fi
    [[ -s "scripts/setup-msmtp-keychain.sh" ]] || {
        log_error "Downloaded scripts/setup-msmtp-keychain.sh is empty"
        return 1
    }
    chmod +x "scripts/setup-msmtp-keychain.sh"

    log_info "  - scripts/send-notification.sh"
    if ! curl -fsSL -o "scripts/send-notification.sh" "${base_url}/scripts/send-notification.sh"; then
        log_error "Failed to fetch scripts/send-notification.sh"
        return 1
    fi
    [[ -s "scripts/send-notification.sh" ]] || {
        log_error "Downloaded scripts/send-notification.sh is empty"
        return 1
    }
    chmod +x "scripts/send-notification.sh"

    log_info "  - scripts/maintenance-wrapper.sh"
    if ! curl -fsSL -o "scripts/maintenance-wrapper.sh" "${base_url}/scripts/maintenance-wrapper.sh"; then
        log_error "Failed to fetch scripts/maintenance-wrapper.sh"
        return 1
    fi
    [[ -s "scripts/maintenance-wrapper.sh" ]] || {
        log_error "Downloaded scripts/maintenance-wrapper.sh is empty"
        return 1
    }
    chmod +x "scripts/maintenance-wrapper.sh"

    log_info "  - scripts/weekly-maintenance-digest.sh"
    if ! curl -fsSL -o "scripts/weekly-maintenance-digest.sh" "${base_url}/scripts/weekly-maintenance-digest.sh"; then
        log_error "Failed to fetch scripts/weekly-maintenance-digest.sh"
        return 1
    fi
    [[ -s "scripts/weekly-maintenance-digest.sh" ]] || {
        log_error "Downloaded scripts/weekly-maintenance-digest.sh is empty"
        return 1
    }
    chmod +x "scripts/weekly-maintenance-digest.sh"

    # Fetch release monitor scripts (Feature 06.6)
    log_info "Fetching release monitor scripts..."
    log_info "  - scripts/fetch-release-notes.sh"
    if ! curl -fsSL -o "scripts/fetch-release-notes.sh" "${base_url}/scripts/fetch-release-notes.sh"; then
        log_error "Failed to fetch scripts/fetch-release-notes.sh"
        return 1
    fi
    [[ -s "scripts/fetch-release-notes.sh" ]] || {
        log_error "Downloaded scripts/fetch-release-notes.sh is empty"
        return 1
    }
    chmod +x "scripts/fetch-release-notes.sh"

    log_info "  - scripts/analyze-releases.sh"
    if ! curl -fsSL -o "scripts/analyze-releases.sh" "${base_url}/scripts/analyze-releases.sh"; then
        log_error "Failed to fetch scripts/analyze-releases.sh"
        return 1
    fi
    [[ -s "scripts/analyze-releases.sh" ]] || {
        log_error "Downloaded scripts/analyze-releases.sh is empty"
        return 1
    }
    chmod +x "scripts/analyze-releases.sh"

    log_info "  - scripts/create-release-issues.sh"
    if ! curl -fsSL -o "scripts/create-release-issues.sh" "${base_url}/scripts/create-release-issues.sh"; then
        log_error "Failed to fetch scripts/create-release-issues.sh"
        return 1
    fi
    [[ -s "scripts/create-release-issues.sh" ]] || {
        log_error "Downloaded scripts/create-release-issues.sh is empty"
        return 1
    }
    chmod +x "scripts/create-release-issues.sh"

    log_info "  - scripts/release-monitor.sh"
    if ! curl -fsSL -o "scripts/release-monitor.sh" "${base_url}/scripts/release-monitor.sh"; then
        log_error "Failed to fetch scripts/release-monitor.sh"
        return 1
    fi
    [[ -s "scripts/release-monitor.sh" ]] || {
        log_error "Downloaded scripts/release-monitor.sh is empty"
        return 1
    }
    chmod +x "scripts/release-monitor.sh"

    log_info "  - scripts/send-release-summary.sh"
    if ! curl -fsSL -o "scripts/send-release-summary.sh" "${base_url}/scripts/send-release-summary.sh"; then
        log_error "Failed to fetch scripts/send-release-summary.sh"
        return 1
    fi
    [[ -s "scripts/send-release-summary.sh" ]] || {
        log_error "Downloaded scripts/send-release-summary.sh is empty"
        return 1
    }
    chmod +x "scripts/send-release-summary.sh"

    # Fetch wallpaper for Stylix theming (Story 05.1-001)
    log_info "Fetching wallpaper for Stylix theming..."
    mkdir -p wallpaper
    log_info "  - wallpaper/Ropey_Photo_by_Bob_Farrell.jpg"
    if ! curl -fsSL -o "wallpaper/Ropey_Photo_by_Bob_Farrell.jpg" "${base_url}/wallpaper/Ropey_Photo_by_Bob_Farrell.jpg"; then
        log_error "Failed to fetch wallpaper/Ropey_Photo_by_Bob_Farrell.jpg"
        return 1
    fi
    [[ -s "wallpaper/Ropey_Photo_by_Bob_Farrell.jpg" ]] || {
        log_error "Downloaded wallpaper/Ropey_Photo_by_Bob_Farrell.jpg is empty"
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
    log_info "  • darwin/stylix.nix"
    log_info "  • darwin/maintenance.nix"
    log_info "  • darwin/calibre.nix"
    log_info "  • darwin/smb-automount.nix"
    log_info "  • darwin/rsync-backup.nix"
    log_info "  • darwin/icloud-sync.nix"
    log_info "  • home-manager/home.nix"
    log_info "  • home-manager/modules/shell.nix"
    log_info "  • home-manager/modules/github.nix"
    log_info "  • home-manager/modules/git.nix"
    log_info "  • home-manager/modules/ssh.nix"
    log_info "  • home-manager/modules/zed.nix"
    log_info "  • home-manager/modules/vscode.nix"
    log_info "  • home-manager/modules/ghostty.nix"
    log_info "  • home-manager/modules/claude-code.nix"
    log_info "  • home-manager/modules/python.nix"
    log_info "  • home-manager/modules/podman.nix"
    log_info "  • home-manager/modules/msmtp.nix"
    log_info "  • scripts/health-check.sh"
    log_info "  • scripts/setup-msmtp-keychain.sh"
    log_info "  • scripts/send-notification.sh"
    log_info "  • scripts/maintenance-wrapper.sh"
    log_info "  • scripts/weekly-maintenance-digest.sh"
    log_info "  • scripts/fetch-release-notes.sh"
    log_info "  • scripts/analyze-releases.sh"
    log_info "  • scripts/create-release-issues.sh"
    log_info "  • scripts/release-monitor.sh"
    log_info "  • scripts/send-release-summary.sh"
    log_info "  • wallpaper/Ropey_Photo_by_Bob_Farrell.jpg"
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
    log_phase 5 "Nix-Darwin Installation" "~10-25 minutes"

    log_info "This phase will:"
    log_info "  1. Fetch flake configuration from GitHub"
    log_info "  2. Copy user configuration"
    log_info "  3. Initialize Git repository"
    log_info "  4. Run initial nix-darwin build"
    log_info "  5. Verify installation"
    echo ""
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
    log_phase_complete 5 "Nix-Darwin Installation" $((phase_end - phase_start))

    log_info "What was accomplished:"
    log_info "  ✓ Flake configuration fetched from GitHub"
    log_info "  ✓ User configuration integrated"
    log_info "  ✓ Git repository initialized"
    log_info "  ✓ nix-darwin installed and activated"
    log_info "  ✓ Homebrew installed and configured"
    echo ""
    log_info "Your system is now managed declaratively by nix-darwin!"
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
