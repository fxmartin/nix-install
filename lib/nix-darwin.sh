# ABOUTME: Phase 5 - nix-darwin installation and validation
# ABOUTME: Clones the repo at a pinned ref, runs darwin-rebuild, validates installation
# ABOUTME: Depends on: lib/common.sh, lib/nix-install.sh
# shellcheck shell=bash

# Guard against double-sourcing
[[ -n "${_NIX_DARWIN_SH_LOADED:-}" ]] && return 0
readonly _NIX_DARWIN_SH_LOADED=1

# PHASE 5: NIX-DARWIN INSTALLATION (Story 01.5-001)
# =============================================================================

# Function: clone_flake_repository
# Purpose: Clone the configuration repository at a pinned ref into the work dir
# Replaces the former per-file curl download list: a clone is atomic, always
# complete, and cannot drift out of sync when new .nix modules are added.
# Arguments: None (uses $FLAKE_REPO_DIR, $NIX_INSTALL_REF, $GITHUB_HTTPS_URL)
# Returns: 0 on success, 1 on failure (CRITICAL - exits on failure)
clone_flake_repository() {
    log_info "Cloning configuration repository from GitHub..."
    log_info "Repository: ${GITHUB_OWNER}/${GITHUB_REPO_NAME}"
    log_info "Ref: ${NIX_INSTALL_REF}"
    log_info "Destination: ${FLAKE_REPO_DIR}"
    echo ""

    # Phase 3 (Xcode CLI Tools) guarantees /usr/bin/git by this point, so a
    # missing git means the phases ran out of order - fail loudly.
    if ! command -v git >/dev/null 2>&1; then
        log_error "git command not found"
        log_error "Phase 3 (Xcode CLI Tools) must complete before Phase 5"
        return 1
    fi

    # Idempotent: a re-run after an aborted bootstrap must not trip over a
    # half-populated directory left behind by the previous attempt.
    if [[ -e "${FLAKE_REPO_DIR}" ]]; then
        log_info "Removing incomplete clone from a previous run..."
        if ! rm -rf "${FLAKE_REPO_DIR}"; then
            log_error "Failed to remove existing directory: ${FLAKE_REPO_DIR}"
            return 1
        fi
    fi

    # HTTPS, not SSH: the SSH key is only generated in Phase 6.
    # GIT_TERMINAL_PROMPT=0 so an unexpected auth challenge fails fast instead
    # of hanging the installer on a credential prompt.
    if ! GIT_TERMINAL_PROMPT=0 git clone --depth 1 --branch "${NIX_INSTALL_REF}" \
            "${GITHUB_HTTPS_URL}" "${FLAKE_REPO_DIR}"; then
        echo ""
        log_error "Failed to clone ${GITHUB_HTTPS_URL} at ref ${NIX_INSTALL_REF}"
        log_error ""
        log_error "Troubleshooting:"
        log_error "  1. Verify network connectivity: curl -Is https://github.com"
        log_error "  2. Verify the ref exists: git ls-remote ${GITHUB_HTTPS_URL} ${NIX_INSTALL_REF}"
        log_error "  3. Check disk space: df -h"
        log_error "  4. Retry manually: git clone --depth 1 --branch ${NIX_INSTALL_REF} ${GITHUB_HTTPS_URL} ${FLAKE_REPO_DIR}"
        echo ""
        return 1
    fi

    # flake.nix is the one file the build cannot proceed without.
    if [[ ! -s "${FLAKE_REPO_DIR}/flake.nix" ]]; then
        log_error "Clone completed but flake.nix is missing or empty"
        log_error "Expected: ${FLAKE_REPO_DIR}/flake.nix"
        return 1
    fi

    log_success "Repository cloned at ${NIX_INSTALL_REF}"
    echo ""

    return 0
}

# Function: initialize_flake_submodules
# Purpose: Initialize the submodules needed by the first build, one path at a time
# The three oh-my-zsh submodules use HTTPS so they work before Phase 6 creates
# an SSH key. config/claude-code-config is SSH-only and is therefore expected to
# fail here; Phase 7 re-clones over SSH and initializes it then.
# Arguments: None (uses $FLAKE_REPO_DIR)
# Returns: 0 always (NON-CRITICAL - warns on failure)
initialize_flake_submodules() {
    log_info "Initializing submodules..."

    # Per-path rather than --recursive so one unreachable submodule cannot
    # abort the others. No --depth: a shallow submodule fetch fails whenever
    # the pinned commit is not the branch tip.
    local https_submodules=(
        "config/oh-my-zsh-custom/plugins/zsh-autosuggestions"
        "config/oh-my-zsh-custom/plugins/zsh-syntax-highlighting"
        "config/oh-my-zsh-custom/themes/powerlevel10k"
    )

    local failed_count=0
    local submodule_path
    for submodule_path in "${https_submodules[@]}"; do
        if GIT_TERMINAL_PROMPT=0 git -C "${FLAKE_REPO_DIR}" \
                submodule update --init -- "${submodule_path}"; then
            log_info "  ✓ ${submodule_path}"
        else
            failed_count=$((failed_count + 1))
            log_warn "  ✗ ${submodule_path} (continuing)"
        fi
    done

    # SSH-only submodule: a failure here is the normal case on a fresh machine.
    # Mirrors the non-fatal handling in lib/repo-clone.sh - the rebuild can
    # still proceed, and Phase 7 initializes it once the SSH key exists.
    # BatchMode=yes so ssh reports "Permission denied" instead of blocking on
    # the unknown-host prompt; without a key there is nothing to prompt for.
    if GIT_TERMINAL_PROMPT=0 \
            GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10" \
            git -C "${FLAKE_REPO_DIR}" submodule update --init -- "config/claude-code-config"; then
        log_info "  ✓ config/claude-code-config"
    else
        log_warn "  ⊘ config/claude-code-config skipped"
        log_warn "    It is SSH-only and the SSH key is created in Phase 6."
        log_warn "    Phase 7 clones over SSH and initializes it there."
    fi

    if [[ ${failed_count} -gt 0 ]]; then
        log_warn "${failed_count} submodule(s) failed to initialize"
        log_warn "Recover with:"
        log_warn "  git -C ${FLAKE_REPO_DIR} submodule update --init"
    else
        log_success "Submodules initialized"
    fi
    echo ""

    return 0
}

# Function: copy_user_config
# Purpose: Copy the Phase 2 user-config.nix into the cloned flake repository
# The clone does not carry one - user-config.nix is gitignored - so the build
# would throw "user-config.nix not found" without this step.
# Arguments: None (uses $USER_CONFIG_FILE and $FLAKE_REPO_DIR environment variables)
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

    # Copy into the cloned repository, next to flake.nix
    local dest_path="${FLAKE_REPO_DIR}/user-config.nix"
    if ! cp "${USER_CONFIG_FILE}" "${dest_path}"; then
        log_error "Failed to copy user-config.nix to ${FLAKE_REPO_DIR}"
        return 1
    fi
    log_info "Copied from: ${USER_CONFIG_FILE}"
    log_info "Copied to: ${dest_path}"

    # Validate destination file exists and is readable
    if [[ ! -r "${dest_path}" ]]; then
        log_error "User configuration file is not readable at: ${dest_path}"
        return 1
    fi

    log_success "User configuration verified successfully"
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
# Arguments: None (uses $INSTALL_PROFILE and $FLAKE_REPO_DIR environment variables)
# Returns: 0 on success, 1 on failure (CRITICAL - exits on failure)
run_nix_darwin_build() {
    # "path:" (rather than a bare path) makes Nix copy the directory verbatim
    # instead of going through the Git fetcher. The clone is a Git repository,
    # and the Git fetcher would drop both the gitignored user-config.nix and
    # every submodule working tree. Phase 8 uses the same prefix.
    local flake_ref="path:${FLAKE_REPO_DIR}#${INSTALL_PROFILE}"

    echo ""
    log_info "========================================"
    log_info "STARTING NIX-DARWIN INITIAL BUILD"
    log_info "========================================"
    log_info "Profile: ${INSTALL_PROFILE}"
    log_info "Flake reference: ${flake_ref}"
    log_info "Repository: ${FLAKE_REPO_DIR}"
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

    # Change to the cloned repository
    if ! cd "${FLAKE_REPO_DIR}"; then
        log_error "Failed to change to flake directory: ${FLAKE_REPO_DIR}"
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
        log_info "  2. Verify flake syntax: cd ${FLAKE_REPO_DIR} && nix flake check"
        log_info "  3. Try manual build: sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake ${flake_ref}"
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

    # Check Homebrew installation.
    #
    # The path is overridable via NIX_INSTALL_BREW_PATH so tests can point at a
    # fixture. It was previously hardcoded, which left tests no way to exercise
    # the missing-Homebrew branch except by deleting the real installation —
    # tests/bootstrap_nix_darwin.bats did exactly that (`rm -rf /opt/homebrew`)
    # and wiped a working machine's Homebrew on 2026-07-28. Never reintroduce a
    # bare literal here; keep the seam so the tests stay host-safe.
    local brew_path="${NIX_INSTALL_BREW_PATH:-/opt/homebrew/bin/brew}"
    if [[ -x "${brew_path}" ]]; then
        log_info "✓ Homebrew installed at ${brew_path}"
    else
        log_warn "Homebrew not found at ${brew_path} (may not be installed yet)"
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
# Coordinates: clone repo, init submodules, copy config, build, verify
# Arguments: None
# Returns: 0 on success, 1 on critical failure
install_nix_darwin_phase() {
    local phase_start
    phase_start=$(date +%s)
    log_phase 5 "Nix-Darwin Installation" "~10-25 minutes"

    log_info "This phase will:"
    log_info "  1. Clone the configuration repository at ${NIX_INSTALL_REF}"
    log_info "  2. Initialize submodules"
    log_info "  3. Copy user configuration"
    log_info "  4. Run initial nix-darwin build"
    log_info "  5. Verify installation"
    echo ""
    log_warn "Most time is spent downloading and building packages"
    echo ""

    # Step 1: Clone the configuration repository at the pinned ref (CRITICAL)
    if ! clone_flake_repository; then
        log_error "Failed to clone the configuration repository"
        return 1
    fi

    # Step 2: Initialize submodules (NON-CRITICAL)
    # config/claude-code-config is SSH-only and is expected to fail until Phase 6
    initialize_flake_submodules || true

    # Step 3: Copy user configuration into the clone (CRITICAL)
    if ! copy_user_config; then
        log_error "Failed to copy user configuration"
        return 1
    fi

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
    log_info "  ✓ Configuration repository cloned at ${NIX_INSTALL_REF}"
    log_info "  ✓ Submodules initialized"
    log_info "  ✓ User configuration integrated"
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
           [[ -d "${HOME}/Applications/Ghostty.app" ]] || \
           [[ -d "${HOME}/Applications/Zed.app" ]]; then
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
