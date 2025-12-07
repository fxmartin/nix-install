# ABOUTME: Phase 4 - Nix package manager installation and configuration
# ABOUTME: Installs Nix multi-user, enables flakes, configures binary cache
# ABOUTME: Depends on: lib/common.sh for logging functions

# Guard against double-sourcing
[[ -n "${_NIX_INSTALL_SH_LOADED:-}" ]] && return 0
readonly _NIX_INSTALL_SH_LOADED=1

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
    local phase_start
    phase_start=$(date +%s)
    log_phase 4 "Nix Package Manager Installation" "~5-10 minutes"

    log_info "This phase will install the Nix package manager with flakes support."
    log_info "Nix is required for nix-darwin and all declarative system configuration."
    echo ""

    # Check if already installed
    if check_nix_installed; then
        log_info "✓ Nix is already installed, skipping installation"
        local phase_end
        phase_end=$(date +%s)
        log_phase_complete 4 "Nix Package Manager Installation" $((phase_end - phase_start))
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

    local phase_end
    phase_end=$(date +%s)
    log_phase_complete 4 "Nix Package Manager Installation" $((phase_end - phase_start))
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
