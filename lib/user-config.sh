# ABOUTME: Phase 2 - User configuration and installation profile selection
# ABOUTME: Handles user information prompting, validation, and config file generation
# ABOUTME: Depends on: lib/common.sh for logging functions

# Guard against double-sourcing
[[ -n "${_USER_CONFIG_SH_LOADED:-}" ]] && return 0
readonly _USER_CONFIG_SH_LOADED=1

# ==============================================================================
# PHASE 2: USER INFORMATION VALIDATION FUNCTIONS
# ==============================================================================

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
#   1. ~/.config/nix-install/user-config.nix (completed installation - new default)
#   2. ~/Documents/nix-install/user-config.nix (legacy location)
#   3. /tmp/nix-bootstrap/user-config.nix (previous bootstrap attempt)
# Sets global variables: USER_FULLNAME, USER_EMAIL, GITHUB_USERNAME
# Returns: 0 if config found and user chose to reuse, 1 if not found or user declined
# Pattern: Based on mlgruby-repo-for-reference/scripts/install/pre-nix-installation.sh (lines 239-289)
check_existing_user_config() {
    local existing_config=""
    local config_source=""

    # Check priority locations (completed install takes precedence)
    # New default location first, then legacy location for backwards compatibility
    if [[ -f "$HOME/.config/nix-install/user-config.nix" ]]; then
        existing_config="$HOME/.config/nix-install/user-config.nix"
        config_source="completed installation"
    elif [[ -f "$HOME/Documents/nix-install/user-config.nix" ]]; then
        existing_config="$HOME/Documents/nix-install/user-config.nix"
        config_source="completed installation (legacy location)"
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
    read_input reuse_config "Reuse this configuration? (y/n): "
    echo ""

    if [[ "${reuse_config}" =~ ^[Yy]$ ]]; then
        # Set global variables for use in generate_user_config
        USER_FULLNAME="${parsed_fullname}"
        USER_EMAIL="${parsed_email}"
        NOTIFICATION_EMAIL="${parsed_email}"  # Default to main email when reusing git config
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
    # Phase header logged in main() - this is part of Phase 2
    log_info "Please provide your information for Git, SSH, and system configuration."
    echo ""

    local confirmed="n"

    # Loop until user confirms all information
    while [[ ! "$confirmed" =~ ^[Yy]$ ]]; do
        # Prompt for full name with validation
        while true; do
            read_input USER_FULLNAME "Full Name: "
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
            read_input USER_EMAIL "Email Address: "
            if validate_email "$USER_EMAIL"; then
                log_info "✓ Email validated"
                break
            else
                log_error "Invalid email format. Please include @ and domain (e.g., user@example.com)"
            fi
        done

        echo ""

        # Prompt for notification email (defaults to main email)
        while true; do
            read_input NOTIFICATION_EMAIL "Notification Email (press Enter to use $USER_EMAIL): "
            if [[ -z "$NOTIFICATION_EMAIL" ]]; then
                NOTIFICATION_EMAIL="$USER_EMAIL"
                log_info "✓ Using main email for notifications"
                break
            elif validate_email "$NOTIFICATION_EMAIL"; then
                log_info "✓ Notification email validated"
                break
            else
                log_error "Invalid email format. Please include @ and domain (e.g., user@example.com)"
            fi
        done

        echo ""

        # Prompt for GitHub username with validation
        while true; do
            read_input GITHUB_USERNAME "GitHub Username: "
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
        echo "  Notifications: $NOTIFICATION_EMAIL"
        echo "  GitHub:        $GITHUB_USERNAME"
        echo ""

        read_input confirmed "Is this correct? (y/n): "
        echo ""

        if [[ ! "$confirmed" =~ ^[Yy]$ ]]; then
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
    # Derive dotfiles path from REPO_CLONE_DIR (relative to HOME)
    # Example: ~/.config/nix-install → .config/nix-install (default)
    # Example: ~/nix-install → nix-install
    # Example: ~/Documents/nix-install → Documents/nix-install (legacy)
    local dotfiles_path="${REPO_CLONE_DIR#${HOME}/}"
    log_info "Dotfiles path: ${dotfiles_path}"

    echo ""
    log_info "Generating user configuration file..."

    # Check template exists, download if missing (when run via setup.sh from /tmp)
    local template_file="user-config.template.nix"
    if [[ ! -f "${template_file}" ]]; then
        log_warn "Template file not found locally, downloading from GitHub..."
        local template_url="https://raw.githubusercontent.com/fxmartin/nix-install/main/${template_file}"
        if ! curl -fsSL "${template_url}" -o "${template_file}"; then
            log_error "Failed to download template file from: ${template_url}"
            log_error "Please check your internet connection and try again."
            return 1
        fi
        if [[ ! -s "${template_file}" ]]; then
            log_error "Downloaded template file is empty"
            return 1
        fi
        log_info "✓ Template file downloaded successfully"
    fi

    # Replace placeholders and generate config file
    if ! sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@NOTIFICATION_EMAIL@/${NOTIFICATION_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s/@INSTALL_PROFILE@/${INSTALL_PROFILE}/g" \
        -e "s/@ENABLE_MAS_APPS@/${ENABLE_MAS_APPS}/g" \
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
    read_input confirmed "Continue with this profile? (y/n): "

    if [[ "$confirmed" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Main profile selection function
# Sets global variable: INSTALL_PROFILE ("standard" or "power")
# Interactive prompt with validation and confirmation
select_installation_profile() {
    # Part of Phase 2 - no separate header needed
    log_info "Choose the installation profile for this MacBook."
    log_info "This determines which apps and models will be installed."

    local profile_confirmed=""

    # Loop until user confirms profile choice
    while [[ ! "$profile_confirmed" =~ ^[Yy]$ ]]; do
        # Display profile options
        display_profile_options

        # Prompt for profile choice
        local choice
        while true; do
            read_input choice "Enter your choice (1 or 2): "

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

# Global variable for MAS apps preference
ENABLE_MAS_APPS="false"

# Prompt user for Mac App Store apps installation preference
# Sets global variable: ENABLE_MAS_APPS ("true" or "false")
prompt_mas_apps_preference() {
    echo ""
    log_info "Mac App Store Apps Installation"
    echo ""
    log_info "The following apps are available from the Mac App Store:"
    echo "  • Perplexity (AI search assistant)"
    echo "  • Kindle (ebook reader)"
    echo "  • Marked 2 (Markdown preview)"
    echo "  • WhatsApp (messaging)"
    echo ""
    log_warn "IMPORTANT: You must be signed into the App Store for this to work."
    log_warn "If not signed in, these installations will fail and block the bootstrap."
    echo ""

    local response
    read_input response "Install Mac App Store apps? (y/n) [default: no]: "

    # Trim whitespace
    response=$(echo "${response}" | xargs)

    # Default to no if empty
    if [[ -z "${response}" ]]; then
        response="n"
    fi

    if [[ "${response}" =~ ^[Yy]$ ]]; then
        ENABLE_MAS_APPS="true"
        log_info "✓ Mac App Store apps will be installed"
    else
        ENABLE_MAS_APPS="false"
        log_info "✓ Mac App Store apps skipped (install manually later with 'mas install')"
    fi
    echo ""
}

# Run all pre-flight validation checks
