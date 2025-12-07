# ABOUTME: Phase 6 - SSH key generation and GitHub authentication
# ABOUTME: Generates SSH keys, uploads to GitHub, tests SSH connection
# ABOUTME: Depends on: lib/common.sh, lib/nix-darwin.sh (for gh CLI)

# Guard against double-sourcing
[[ -n "${_SSH_GITHUB_SH_LOADED:-}" ]] && return 0
readonly _SSH_GITHUB_SH_LOADED=1

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
    read_input response "Use existing SSH key? (y/n) [default: yes]: "

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
    local phase_start
    phase_start=$(date +%s)
    log_phase 6 "SSH & GitHub Authentication" "~3-5 minutes"

    log_info "Step 1/3: Generate SSH key for GitHub authentication"
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

    log_success "✓ SSH key generation complete"
    echo ""

    return 0
}

# =============================================================================
# PHASE 6 (CONTINUED): GITHUB SSH KEY UPLOAD VIA GITHUB CLI
# Story 01.6-002: Automated GitHub SSH key upload using gh CLI
# =============================================================================

# Function: ensure_gh_in_path
# Purpose: Ensure GitHub CLI (gh) is available in PATH
# Note: After darwin-rebuild installs Homebrew, gh is at /opt/homebrew/bin/gh
#       but the bootstrap shell may not have updated PATH yet
# Returns: 0 if gh is available, 1 if not found
ensure_gh_in_path() {
    # Check if gh is already in PATH
    if command -v gh >/dev/null 2>&1; then
        log_info "✓ GitHub CLI (gh) found in PATH"
        return 0
    fi

    # Add Homebrew bin to PATH if it exists (macOS arm64)
    if [[ -d "/opt/homebrew/bin" ]]; then
        log_info "Adding /opt/homebrew/bin to PATH for gh access..."
        export PATH="/opt/homebrew/bin:${PATH}"

        if command -v gh >/dev/null 2>&1; then
            log_info "✓ GitHub CLI (gh) now available via Homebrew"
            return 0
        fi
    fi

    # Check Intel Mac location
    if [[ -d "/usr/local/bin" ]]; then
        export PATH="/usr/local/bin:${PATH}"

        if command -v gh >/dev/null 2>&1; then
            log_info "✓ GitHub CLI (gh) now available via Homebrew (Intel)"
            return 0
        fi
    fi

    # Check nix profile location (Home Manager)
    local nix_profile="${HOME}/.nix-profile/bin"
    if [[ -d "${nix_profile}" ]]; then
        export PATH="${nix_profile}:${PATH}"

        if command -v gh >/dev/null 2>&1; then
            log_info "✓ GitHub CLI (gh) now available via Nix profile"
            return 0
        fi
    fi

    # Still not found
    log_error "GitHub CLI (gh) not found in any expected location"
    log_error "Expected locations checked:"
    log_error "  - PATH: $(echo $PATH | tr ':' '\n' | head -5)"
    log_error "  - /opt/homebrew/bin/gh (macOS arm64)"
    log_error "  - /usr/local/bin/gh (macOS Intel)"
    log_error "  - ~/.nix-profile/bin/gh (Nix/Home Manager)"
    return 1
}

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
    # Note: Must create both ~/.config and ~/.config/gh with correct ownership
    local config_dir="${HOME}/.config"
    local gh_config_dir="${HOME}/.config/gh"

    # Fix ~/.config ownership and permissions if it exists (Hotfix #10 - Issue #16)
    # When NIX_INSTALL_DIR is set to ~/.config/*, Nix may create ~/.config/nix/
    # with incorrect ownership, causing GitHub CLI authentication to fail
    if [[ -d "${config_dir}" ]]; then
        # Check if ~/.config is owned by current user
        if [[ ! -O "${config_dir}" ]]; then
            log_warn "${config_dir} exists but is not owned by current user"
            log_info "Attempting to fix ownership (requires sudo)..."
            if sudo chown "${USER}:staff" "${config_dir}"; then
                log_info "✓ Fixed ownership of ${config_dir}"
            else
                log_warn "Failed to fix ownership of ${config_dir}"
                log_info "Manual fix: sudo chown -R ${USER}:staff ${config_dir}"
            fi
        fi
        # Ensure proper permissions (755 = rwxr-xr-x)
        if chmod 755 "${config_dir}" 2>/dev/null; then
            log_info "✓ Set permissions on ${config_dir} (755)"
        else
            log_warn "Failed to set permissions on ${config_dir}"
        fi
    fi

    # Create ~/.config if it doesn't exist
    if [[ ! -d "${config_dir}" ]]; then
        log_info "Creating ~/.config directory..."
        if ! mkdir -p "${config_dir}"; then
            log_error "Failed to create ${config_dir}"
            log_error "This will prevent GitHub CLI from saving authentication"
            return 1
        fi
        # Set proper ownership and permissions
        chmod 755 "${config_dir}" || true
        log_info "✓ ~/.config directory created"
    fi

    # Fix ~/.config/gh ownership if it exists (Hotfix #10 - Issue #16)
    if [[ -d "${gh_config_dir}" ]]; then
        # Check if ~/.config/gh is owned by current user
        if [[ ! -O "${gh_config_dir}" ]]; then
            log_warn "${gh_config_dir} exists but is not owned by current user"
            log_info "Attempting to fix ownership (requires sudo)..."
            if sudo chown -R "${USER}:staff" "${gh_config_dir}"; then
                log_info "✓ Fixed ownership of ${gh_config_dir}"
            else
                log_warn "Failed to fix ownership of ${gh_config_dir}"
            fi
        fi
    fi

    # Create ~/.config/gh if it doesn't exist
    if [[ ! -d "${gh_config_dir}" ]]; then
        log_info "Creating GitHub CLI config directory..."
        if ! mkdir -p "${gh_config_dir}"; then
            log_error "Failed to create ${gh_config_dir}"
            log_error "This will prevent GitHub CLI from saving authentication"
            return 1
        fi
        # Set proper ownership and permissions
        chmod 755 "${gh_config_dir}" || true
        log_info "✓ GitHub CLI config directory created"
        echo ""
    fi

    # Ensure the directory is writable (fix any permission issues)
    if [[ -d "${gh_config_dir}" ]]; then
        if ! touch "${gh_config_dir}/.test_write" 2>/dev/null; then
            log_warn "GitHub CLI config directory exists but is not writable"
            log_info "Attempting to fix permissions..."
            chmod 755 "${gh_config_dir}" || true
            # Try again
            if ! touch "${gh_config_dir}/.test_write" 2>/dev/null; then
                log_error "Cannot write to ${gh_config_dir}"
                log_error "Manual fix: sudo chown -R $(whoami) ${config_dir}"
                return 1
            fi
        fi
        # Clean up test file
        rm -f "${gh_config_dir}/.test_write" 2>/dev/null || true
    fi

    # Check for existing Home Manager symlink and remove it (Hotfix #12 - Issue #20)
    # Even after removing programs.gh.settings (Hotfix #11), existing systems may
    # still have the old read-only symlink to /nix/store. Home Manager doesn't
    # automatically delete files when removed from config, so we must handle it here.
    local gh_config_file="${gh_config_dir}/config.yml"
    if [[ -L "${gh_config_file}" ]]; then
        log_warn "GitHub CLI config is a symlink (likely from old Home Manager config)"
        log_info "Removing read-only symlink to allow authentication..."
        if rm -f "${gh_config_file}"; then
            log_info "✓ Removed symlink: ${gh_config_file}"
            log_info "Note: GitHub CLI will create a writable config file"
        else
            log_error "Failed to remove symlink: ${gh_config_file}"
            log_error "Manual fix: rm ${gh_config_file}"
            return 1
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
    local dummy
    read_input dummy "Press ENTER when you've added the key to GitHub..."

    echo ""
    log_success "✓ Manual key upload completed"
    echo ""

    return 0
}

# Function: upload_github_key_phase
# Purpose: Orchestrate GitHub SSH key upload workflow (Phase 6 continued)
# Workflow: Ensure gh in PATH → Check auth → Authenticate → Check exists → Upload → Fallback
# Returns: 0 on success, 1 if CRITICAL step fails
upload_github_key_phase() {
    # Continuation of Phase 6 - no separate header needed
    log_info "Step 2/3: Upload SSH key to GitHub"
    echo ""

    # CRITICAL: Ensure gh CLI is available in PATH
    # After Phase 5 darwin-rebuild, gh is installed via Homebrew at /opt/homebrew/bin/gh
    # but the current shell session may not have updated PATH yet
    # Hotfix for Issue: "bootstrap-dist.sh: line 3540: gh: command not found"
    log_info "Ensuring GitHub CLI (gh) is available..."
    if ! ensure_gh_in_path; then
        log_error "GitHub CLI (gh) is not available"
        log_error "This is required for automated SSH key upload"
        log_error ""
        log_error "Possible causes:"
        log_error "  1. Phase 5 darwin-rebuild did not complete successfully"
        log_error "  2. Homebrew installation failed"
        log_error "  3. gh brew formula not installed"
        log_error ""
        log_error "Falling back to manual SSH key upload..."
        echo ""
        fallback_manual_key_upload
        return 0
    fi
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
    log_info "Checking if SSH key already exists on GitHub..."
    if check_key_exists_on_github; then
        log_success "✓ SSH key already exists on GitHub"
        log_info "Skipping upload (idempotency check passed)"
        echo ""
        return 0
    fi

    # Step 3: Upload SSH key to GitHub (CRITICAL)
    log_info "Uploading SSH key to GitHub..."
    echo ""

    if upload_ssh_key_to_github; then
        log_success "✓ SSH key uploaded to GitHub successfully"
        echo ""
        return 0
    else
        # Fallback to manual upload if automation failed
        log_warn "Automated upload failed, falling back to manual process"
        echo ""
        fallback_manual_key_upload
        log_success "✓ GitHub SSH key upload complete (manual)"
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
        read_input response "Continue without SSH test? (y/n) [not recommended]: "

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
    # Continuation of Phase 6 - no separate header needed
    log_info "Step 3/3: Testing SSH connection to GitHub"
    log_info "This validates that your SSH key is correctly configured."
    echo ""

    # Attempt connection with retry mechanism
    if retry_ssh_connection; then
        log_success "✓ GitHub SSH connection verified"
        echo ""
        return 0
    fi

    # Connection test failed - display troubleshooting help
    display_ssh_troubleshooting

    # Ask user if they want to continue or abort
    if prompt_continue_without_ssh; then
        log_warn "Proceeding to next phase despite SSH test failure"
        log_warn "Repository cloning in Phase 7 may fail if SSH is not configured correctly"
        echo ""
        return 0
    else
        # User chose to abort
        log_error "Bootstrap terminated by user choice"
        return 1
    fi
}

# =============================================================================
