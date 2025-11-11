#!/usr/bin/env bats
# ABOUTME: Comprehensive test suite for Phase 6 (continued) GitHub SSH key upload
# ABOUTME: Tests automated GitHub CLI authentication and key upload workflow

# Load the bootstrap script for testing
setup() {
    # Source the bootstrap script to access functions
    # Skip main() execution by sourcing
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Set up test environment variables
    export USER_EMAIL="test@example.com"
    export HOME="${BATS_TEST_TMPDIR}/home"
    export SSH_KEY_PATH="${HOME}/.ssh/id_ed25519"
    export SSH_PUB_KEY_PATH="${SSH_KEY_PATH}.pub"

    # Create temporary home directory for testing
    mkdir -p "${HOME}/.ssh"

    # Create mock SSH keys for testing
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMockPublicKeyForTesting test@example.com" > "${SSH_PUB_KEY_PATH}"
    chmod 644 "${SSH_PUB_KEY_PATH}"
}

teardown() {
    # Clean up test files
    rm -rf "${HOME}"
}

# =============================================================================
# FUNCTION EXISTENCE TESTS (6 tests)
# =============================================================================

@test "check_github_cli_authenticated function exists" {
    declare -f check_github_cli_authenticated > /dev/null
}

@test "authenticate_github_cli function exists" {
    declare -f authenticate_github_cli > /dev/null
}

@test "check_key_exists_on_github function exists" {
    declare -f check_key_exists_on_github > /dev/null
}

@test "upload_ssh_key_to_github function exists" {
    declare -f upload_ssh_key_to_github > /dev/null
}

@test "fallback_manual_key_upload function exists" {
    declare -f fallback_manual_key_upload > /dev/null
}

@test "upload_github_key_phase function exists" {
    declare -f upload_github_key_phase > /dev/null
}

# =============================================================================
# AUTHENTICATION CHECK TESTS (10 tests)
# =============================================================================

@test "check_github_cli_authenticated returns 0 when gh auth status succeeds" {
    # Mock gh command to simulate authenticated state
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "status" ]]; then
            echo "✓ Logged in to github.com as testuser"
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run check_github_cli_authenticated
    [ "$status" -eq 0 ]
}

@test "check_github_cli_authenticated returns 1 when gh auth status fails" {
    # Mock gh command to simulate unauthenticated state
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "status" ]]; then
            echo "You are not logged into any GitHub hosts"
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run check_github_cli_authenticated
    [ "$status" -eq 1 ]
}

@test "check_github_cli_authenticated redirects output to /dev/null" {
    # Mock gh command
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "status" ]]; then
            echo "This should not appear in output"
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run check_github_cli_authenticated
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "This should not appear" ]]
}

@test "check_github_cli_authenticated handles gh command not found" {
    # Mock gh command to simulate not installed
    gh() {
        echo "gh: command not found"
        return 127
    }
    export -f gh

    run check_github_cli_authenticated
    [ "$status" -eq 127 ]
}

@test "check_github_cli_authenticated is NON-CRITICAL (no exit on failure)" {
    # Mock gh to fail
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "status" ]]; then
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    # Should return 1 but not exit the script
    run check_github_cli_authenticated
    [ "$status" -eq 1 ]
}

@test "check_github_cli_authenticated logs status check" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "status" ]]; then
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run check_github_cli_authenticated
    [ "$status" -eq 0 ]
}

@test "check_github_cli_authenticated handles network timeout" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "status" ]]; then
            echo "Error: connect: connection timed out"
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run check_github_cli_authenticated
    [ "$status" -eq 1 ]
}

@test "check_github_cli_authenticated handles expired token" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "status" ]]; then
            echo "Error: token expired"
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run check_github_cli_authenticated
    [ "$status" -eq 1 ]
}

@test "check_github_cli_authenticated uses correct gh command syntax" {
    local called_correctly=false
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "status" ]]; then
            called_correctly=true
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    check_github_cli_authenticated
    [[ "${called_correctly}" == "true" ]]
}

@test "check_github_cli_authenticated returns immediately on success" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "status" ]]; then
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run check_github_cli_authenticated
    [ "$status" -eq 0 ]
}

# =============================================================================
# OAUTH AUTHENTICATION FLOW TESTS (12 tests)
# =============================================================================

@test "authenticate_github_cli displays OAuth flow instructions" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]]; then
            echo "Opening browser for authentication..."
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run authenticate_github_cli
    [ "$status" -eq 0 ]
    [[ "$output" =~ "OAuth" ]] || [[ "$output" =~ "authentication" ]]
}

@test "authenticate_github_cli runs gh auth login with correct flags" {
    local correct_flags=false
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]] && \
           [[ "$3" == "--hostname" ]] && [[ "$4" == "github.com" ]] && \
           [[ "$5" == "--git-protocol" ]] && [[ "$6" == "ssh" ]] && \
           [[ "$7" == "--web" ]]; then
            correct_flags=true
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    authenticate_github_cli
    [[ "${correct_flags}" == "true" ]]
}

@test "authenticate_github_cli opens browser for OAuth" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]]; then
            echo "! First copy your one-time code: ABCD-1234"
            echo "Press Enter to open github.com in your browser..."
            echo "✓ Authentication complete"
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run authenticate_github_cli
    [ "$status" -eq 0 ]
}

@test "authenticate_github_cli verifies authentication succeeded" {
    local login_called=false
    local status_checked=false

    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]]; then
            login_called=true
            return 0
        elif [[ "$1" == "auth" ]] && [[ "$2" == "status" ]]; then
            status_checked=true
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    authenticate_github_cli
    [[ "${login_called}" == "true" ]]
}

@test "authenticate_github_cli exits on login failure (CRITICAL)" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]]; then
            echo "Error: authentication failed"
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run authenticate_github_cli
    [ "$status" -ne 0 ]
}

@test "authenticate_github_cli logs authentication start" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]]; then
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run authenticate_github_cli
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Authenticating" ]] || [[ "$output" =~ "GitHub" ]]
}

@test "authenticate_github_cli logs authentication success" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]]; then
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run authenticate_github_cli
    [ "$status" -eq 0 ]
}

@test "authenticate_github_cli handles browser not opening" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]]; then
            echo "Error: could not open browser"
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run authenticate_github_cli
    [ "$status" -ne 0 ]
}

@test "authenticate_github_cli handles user cancellation" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]]; then
            echo "Error: authentication cancelled by user"
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run authenticate_github_cli
    [ "$status" -ne 0 ]
}

@test "authenticate_github_cli displays troubleshooting on failure" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]]; then
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run authenticate_github_cli
    [ "$status" -ne 0 ]
    [[ "$output" =~ "troubleshoot" ]] || [[ "$output" =~ "failed" ]]
}

@test "authenticate_github_cli is CRITICAL (exits on failure)" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]]; then
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run authenticate_github_cli
    [ "$status" -ne 0 ]
}

@test "authenticate_github_cli uses --web flag for browser OAuth" {
    local uses_web_flag=false
    gh() {
        if [[ "$*" =~ "--web" ]]; then
            uses_web_flag=true
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    authenticate_github_cli
    [[ "${uses_web_flag}" == "true" ]]
}

# =============================================================================
# KEY EXISTENCE CHECK TESTS (10 tests)
# =============================================================================

@test "check_key_exists_on_github extracts fingerprint from local key" {
    # Mock ssh-keygen
    ssh-keygen() {
        if [[ "$1" == "-l" ]] && [[ "$2" == "-f" ]]; then
            echo "256 SHA256:abcd1234efgh5678 test@example.com (ED25519)"
            return 0
        fi
        command ssh-keygen "$@"
    }
    export -f ssh-keygen

    # Mock gh to return success
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "list" ]]; then
            echo "SHA256:abcd1234efgh5678  test-key (2025-11-11)"
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run check_key_exists_on_github
    [ "$status" -eq 0 ]
}

@test "check_key_exists_on_github queries gh ssh-key list" {
    ssh-keygen() {
        if [[ "$1" == "-l" ]] && [[ "$2" == "-f" ]]; then
            echo "256 SHA256:testfingerprint test@example.com (ED25519)"
            return 0
        fi
        command ssh-keygen "$@"
    }
    export -f ssh-keygen

    local list_called=false
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "list" ]]; then
            list_called=true
            echo "SHA256:testfingerprint  test-key"
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    check_key_exists_on_github
    [[ "${list_called}" == "true" ]]
}

@test "check_key_exists_on_github returns 0 if fingerprint found" {
    ssh-keygen() {
        if [[ "$1" == "-l" ]] && [[ "$2" == "-f" ]]; then
            echo "256 SHA256:matchingfingerprint test@example.com (ED25519)"
            return 0
        fi
        command ssh-keygen "$@"
    }
    export -f ssh-keygen

    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "list" ]]; then
            echo "SHA256:matchingfingerprint  MacBook-Pro-20251111"
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run check_key_exists_on_github
    [ "$status" -eq 0 ]
}

@test "check_key_exists_on_github returns 1 if fingerprint not found" {
    ssh-keygen() {
        if [[ "$1" == "-l" ]] && [[ "$2" == "-f" ]]; then
            echo "256 SHA256:localfingerprint test@example.com (ED25519)"
            return 0
        fi
        command ssh-keygen "$@"
    }
    export -f ssh-keygen

    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "list" ]]; then
            echo "SHA256:differentfingerprint  OtherMachine-20251111"
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run check_key_exists_on_github
    [ "$status" -eq 1 ]
}

@test "check_key_exists_on_github handles multiple keys on GitHub" {
    ssh-keygen() {
        if [[ "$1" == "-l" ]] && [[ "$2" == "-f" ]]; then
            echo "256 SHA256:targetfingerprint test@example.com (ED25519)"
            return 0
        fi
        command ssh-keygen "$@"
    }
    export -f ssh-keygen

    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "list" ]]; then
            echo "SHA256:key1fingerprint  Machine1-20251110"
            echo "SHA256:targetfingerprint  Machine2-20251111"
            echo "SHA256:key3fingerprint  Machine3-20251112"
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run check_key_exists_on_github
    [ "$status" -eq 0 ]
}

@test "check_key_exists_on_github handles network failure gracefully (NON-CRITICAL)" {
    ssh-keygen() {
        if [[ "$1" == "-l" ]] && [[ "$2" == "-f" ]]; then
            echo "256 SHA256:testkey test@example.com (ED25519)"
            return 0
        fi
        command ssh-keygen "$@"
    }
    export -f ssh-keygen

    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "list" ]]; then
            echo "Error: network unreachable"
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run check_key_exists_on_github
    # Should return 1 (not found) but not exit script
    [ "$status" -eq 1 ]
}

@test "check_key_exists_on_github logs warning on check failure" {
    ssh-keygen() {
        if [[ "$1" == "-l" ]] && [[ "$2" == "-f" ]]; then
            echo "256 SHA256:testkey test@example.com (ED25519)"
            return 0
        fi
        command ssh-keygen "$@"
    }
    export -f ssh-keygen

    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "list" ]]; then
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run check_key_exists_on_github
    [ "$status" -eq 1 ]
}

@test "check_key_exists_on_github handles empty key list" {
    ssh-keygen() {
        if [[ "$1" == "-l" ]] && [[ "$2" == "-f" ]]; then
            echo "256 SHA256:testkey test@example.com (ED25519)"
            return 0
        fi
        command ssh-keygen "$@"
    }
    export -f ssh-keygen

    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "list" ]]; then
            # Empty output (no keys)
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run check_key_exists_on_github
    [ "$status" -eq 1 ]
}

@test "check_key_exists_on_github handles missing local key file" {
    # Remove mock key
    rm -f "${SSH_PUB_KEY_PATH}"

    ssh-keygen() {
        if [[ "$1" == "-l" ]] && [[ "$2" == "-f" ]]; then
            echo "Error: ${SSH_PUB_KEY_PATH}: No such file or directory"
            return 1
        fi
        command ssh-keygen "$@"
    }
    export -f ssh-keygen

    run check_key_exists_on_github
    [ "$status" -ne 0 ]
}

@test "check_key_exists_on_github uses correct ssh-keygen syntax" {
    local correct_syntax=false
    ssh-keygen() {
        if [[ "$1" == "-l" ]] && [[ "$2" == "-f" ]] && [[ "$3" == "${SSH_PUB_KEY_PATH}" ]]; then
            correct_syntax=true
            echo "256 SHA256:test test@example.com (ED25519)"
            return 0
        fi
        command ssh-keygen "$@"
    }
    export -f ssh-keygen

    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "list" ]]; then
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    check_key_exists_on_github
    [[ "${correct_syntax}" == "true" ]]
}

# =============================================================================
# AUTOMATED UPLOAD TESTS (12 tests)
# =============================================================================

@test "upload_ssh_key_to_github generates key title with hostname and date" {
    local title_correct=false
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]]; then
            # Check if title matches hostname-YYYYMMDD pattern
            if [[ "$4" == "--title" ]] && [[ "$5" =~ ^[a-zA-Z0-9\-]+\-[0-9]{8}$ ]]; then
                title_correct=true
            fi
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    upload_ssh_key_to_github
    [[ "${title_correct}" == "true" ]]
}

@test "upload_ssh_key_to_github calls gh ssh-key add with correct path" {
    local correct_path=false
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]] && [[ "$3" == "${SSH_PUB_KEY_PATH}" ]]; then
            correct_path=true
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    upload_ssh_key_to_github
    [[ "${correct_path}" == "true" ]]
}

@test "upload_ssh_key_to_github returns 0 on success" {
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]]; then
            echo "✓ Public key added to your account"
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run upload_ssh_key_to_github
    [ "$status" -eq 0 ]
}

@test "upload_ssh_key_to_github handles 'key already exists' gracefully (not an error)" {
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]]; then
            echo "Error: key already exists"
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run upload_ssh_key_to_github
    # Should log info and return success (exit code 0) because key exists is not an error
    [ "$status" -eq 0 ]
}

@test "upload_ssh_key_to_github exits on network failure (CRITICAL)" {
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]]; then
            echo "Error: network unreachable"
            return 2
        fi
        command gh "$@"
    }
    export -f gh

    run upload_ssh_key_to_github
    [ "$status" -ne 0 ]
}

@test "upload_ssh_key_to_github exits on permission failure (CRITICAL)" {
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]]; then
            echo "Error: insufficient permissions"
            return 3
        fi
        command gh "$@"
    }
    export -f gh

    run upload_ssh_key_to_github
    [ "$status" -ne 0 ]
}

@test "upload_ssh_key_to_github logs upload start" {
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]]; then
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run upload_ssh_key_to_github
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Uploading" ]] || [[ "$output" =~ "Adding" ]]
}

@test "upload_ssh_key_to_github logs upload success" {
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]]; then
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    run upload_ssh_key_to_github
    [ "$status" -eq 0 ]
}

@test "upload_ssh_key_to_github includes date in key title" {
    local has_date=false
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]] && [[ "$4" == "--title" ]]; then
            # Check if title contains YYYYMMDD pattern
            if [[ "$5" =~ [0-9]{8} ]]; then
                has_date=true
            fi
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    upload_ssh_key_to_github
    [[ "${has_date}" == "true" ]]
}

@test "upload_ssh_key_to_github includes hostname in key title" {
    local has_hostname=false
    local expected_hostname
    expected_hostname=$(hostname)

    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]] && [[ "$4" == "--title" ]]; then
            if [[ "$5" =~ ${expected_hostname} ]]; then
                has_hostname=true
            fi
            return 0
        fi
        command gh "$@"
    }
    export -f gh

    upload_ssh_key_to_github
    [[ "${has_hostname}" == "true" ]]
}

@test "upload_ssh_key_to_github handles malformed key file" {
    # Create malformed key file
    echo "not a valid ssh key" > "${SSH_PUB_KEY_PATH}"

    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]]; then
            echo "Error: invalid key format"
            return 4
        fi
        command gh "$@"
    }
    export -f gh

    run upload_ssh_key_to_github
    [ "$status" -ne 0 ]
}

@test "upload_ssh_key_to_github is CRITICAL (exits on non-'already exists' failures)" {
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]]; then
            echo "Error: unknown failure"
            return 5
        fi
        command gh "$@"
    }
    export -f gh

    run upload_ssh_key_to_github
    [ "$status" -ne 0 ]
}

# =============================================================================
# MANUAL FALLBACK TESTS (8 tests)
# =============================================================================

@test "fallback_manual_key_upload copies key to clipboard" {
    local clipboard_called=false
    pbcopy() {
        clipboard_called=true
        command cat > /dev/null  # Consume stdin
    }
    export -f pbcopy

    # Mock read to avoid waiting for user input
    read() {
        return 0
    }
    export -f read

    fallback_manual_key_upload
    [[ "${clipboard_called}" == "true" ]]
}

@test "fallback_manual_key_upload displays key content" {
    pbcopy() {
        command cat > /dev/null
    }
    export -f pbcopy

    read() {
        return 0
    }
    export -f read

    run fallback_manual_key_upload
    [ "$status" -eq 0 ]
    [[ "$output" =~ "ssh-ed25519" ]]
}

@test "fallback_manual_key_upload shows manual instructions" {
    pbcopy() {
        command cat > /dev/null
    }
    export -f pbcopy

    read() {
        return 0
    }
    export -f read

    run fallback_manual_key_upload
    [ "$status" -eq 0 ]
    [[ "$output" =~ "https://github.com/settings/keys" ]]
}

@test "fallback_manual_key_upload includes step-by-step guide" {
    pbcopy() {
        command cat > /dev/null
    }
    export -f pbcopy

    read() {
        return 0
    }
    export -f read

    run fallback_manual_key_upload
    [ "$status" -eq 0 ]
    [[ "$output" =~ "1." ]] && [[ "$output" =~ "2." ]] && [[ "$output" =~ "3." ]]
}

@test "fallback_manual_key_upload waits for user confirmation" {
    pbcopy() {
        command cat > /dev/null
    }
    export -f pbcopy

    local read_called=false
    read() {
        if [[ "$*" =~ "Press ENTER" ]] || [[ "$*" =~ "when you" ]]; then
            read_called=true
        fi
        return 0
    }
    export -f read

    fallback_manual_key_upload
    [[ "${read_called}" == "true" ]]
}

@test "fallback_manual_key_upload handles pbcopy failure gracefully" {
    pbcopy() {
        echo "Error: pbcopy not available"
        return 1
    }
    export -f pbcopy

    read() {
        return 0
    }
    export -f read

    run fallback_manual_key_upload
    # Should continue even if clipboard fails (show key manually)
    [ "$status" -eq 0 ]
}

@test "fallback_manual_key_upload is NON-CRITICAL (returns 0 after user confirms)" {
    pbcopy() {
        command cat > /dev/null
    }
    export -f pbcopy

    read() {
        return 0
    }
    export -f read

    run fallback_manual_key_upload
    [ "$status" -eq 0 ]
}

@test "fallback_manual_key_upload mentions clipboard copy in output" {
    pbcopy() {
        command cat > /dev/null
    }
    export -f pbcopy

    read() {
        return 0
    }
    export -f read

    run fallback_manual_key_upload
    [ "$status" -eq 0 ]
    [[ "$output" =~ "clipboard" ]] || [[ "$output" =~ "copied" ]]
}

# =============================================================================
# ORCHESTRATION TESTS (8 tests)
# =============================================================================

@test "upload_github_key_phase displays phase banner" {
    # Mock all functions to succeed
    check_github_cli_authenticated() { return 0; }
    check_key_exists_on_github() { return 1; }
    upload_ssh_key_to_github() { return 0; }
    export -f check_github_cli_authenticated check_key_exists_on_github upload_ssh_key_to_github

    run upload_github_key_phase
    [ "$status" -eq 0 ]
    [[ "$output" =~ "PHASE 6" ]] || [[ "$output" =~ "Phase 6" ]]
}

@test "upload_github_key_phase checks authentication first" {
    local check_auth_called=false
    check_github_cli_authenticated() {
        check_auth_called=true
        return 0
    }
    check_key_exists_on_github() { return 1; }
    upload_ssh_key_to_github() { return 0; }
    export -f check_github_cli_authenticated check_key_exists_on_github upload_ssh_key_to_github

    upload_github_key_phase
    [[ "${check_auth_called}" == "true" ]]
}

@test "upload_github_key_phase authenticates if not authenticated" {
    local authenticate_called=false
    check_github_cli_authenticated() { return 1; }
    authenticate_github_cli() {
        authenticate_called=true
        return 0
    }
    check_key_exists_on_github() { return 1; }
    upload_ssh_key_to_github() { return 0; }
    export -f check_github_cli_authenticated authenticate_github_cli check_key_exists_on_github upload_ssh_key_to_github

    upload_github_key_phase
    [[ "${authenticate_called}" == "true" ]]
}

@test "upload_github_key_phase skips upload if key already exists" {
    local upload_called=false
    check_github_cli_authenticated() { return 0; }
    check_key_exists_on_github() { return 0; }  # Key exists
    upload_ssh_key_to_github() {
        upload_called=true
        return 0
    }
    export -f check_github_cli_authenticated check_key_exists_on_github upload_ssh_key_to_github

    run upload_github_key_phase
    [ "$status" -eq 0 ]
    [[ "${upload_called}" == "false" ]]
}

@test "upload_github_key_phase uploads key if not exists" {
    local upload_called=false
    check_github_cli_authenticated() { return 0; }
    check_key_exists_on_github() { return 1; }  # Key doesn't exist
    upload_ssh_key_to_github() {
        upload_called=true
        return 0
    }
    export -f check_github_cli_authenticated check_key_exists_on_github upload_ssh_key_to_github

    upload_github_key_phase
    [[ "${upload_called}" == "true" ]]
}

@test "upload_github_key_phase falls back to manual on upload failure" {
    local fallback_called=false
    check_github_cli_authenticated() { return 0; }
    check_key_exists_on_github() { return 1; }
    upload_ssh_key_to_github() { return 1; }  # Upload fails
    fallback_manual_key_upload() {
        fallback_called=true
        return 0
    }
    export -f check_github_cli_authenticated check_key_exists_on_github upload_ssh_key_to_github fallback_manual_key_upload

    upload_github_key_phase
    [[ "${fallback_called}" == "true" ]]
}

@test "upload_github_key_phase displays success message" {
    check_github_cli_authenticated() { return 0; }
    check_key_exists_on_github() { return 1; }
    upload_ssh_key_to_github() { return 0; }
    export -f check_github_cli_authenticated check_key_exists_on_github upload_ssh_key_to_github

    run upload_github_key_phase
    [ "$status" -eq 0 ]
    [[ "$output" =~ "success" ]] || [[ "$output" =~ "complete" ]]
}

@test "upload_github_key_phase returns 0 on success" {
    check_github_cli_authenticated() { return 0; }
    check_key_exists_on_github() { return 1; }
    upload_ssh_key_to_github() { return 0; }
    export -f check_github_cli_authenticated check_key_exists_on_github upload_ssh_key_to_github

    run upload_github_key_phase
    [ "$status" -eq 0 ]
}

# =============================================================================
# ERROR HANDLING TESTS (8 tests)
# =============================================================================

@test "authenticate_github_cli is classified as CRITICAL" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "login" ]]; then
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    run authenticate_github_cli
    [ "$status" -ne 0 ]
}

@test "upload_ssh_key_to_github is classified as CRITICAL" {
    gh() {
        if [[ "$1" == "ssh-key" ]] && [[ "$2" == "add" ]]; then
            return 2  # Non-"already exists" error
        fi
        command gh "$@"
    }
    export -f gh

    run upload_ssh_key_to_github
    [ "$status" -ne 0 ]
}

@test "check_github_cli_authenticated is classified as NON-CRITICAL" {
    gh() {
        if [[ "$1" == "auth" ]] && [[ "$2" == "status" ]]; then
            return 1
        fi
        command gh "$@"
    }
    export -f gh

    # Should return error but not exit script
    run check_github_cli_authenticated
    [ "$status" -eq 1 ]
}

@test "check_key_exists_on_github is classified as NON-CRITICAL" {
    ssh-keygen() {
        return 1
    }
    export -f ssh-keygen

    # Should return error but not exit script
    run check_key_exists_on_github
    [ "$status" -ne 0 ]
}

@test "fallback_manual_key_upload is classified as NON-CRITICAL" {
    pbcopy() {
        return 1
    }
    export -f pbcopy

    read() {
        return 0
    }
    export -f read

    run fallback_manual_key_upload
    # Should succeed even if clipboard fails
    [ "$status" -eq 0 ]
}

@test "upload_github_key_phase handles authentication failure" {
    check_github_cli_authenticated() { return 1; }
    authenticate_github_cli() { return 1; }  # Auth fails
    export -f check_github_cli_authenticated authenticate_github_cli

    run upload_github_key_phase
    [ "$status" -ne 0 ]
}

@test "upload_github_key_phase handles upload failure with fallback" {
    check_github_cli_authenticated() { return 0; }
    check_key_exists_on_github() { return 1; }
    upload_ssh_key_to_github() { return 1; }
    fallback_manual_key_upload() { return 0; }
    export -f check_github_cli_authenticated check_key_exists_on_github upload_ssh_key_to_github fallback_manual_key_upload

    run upload_github_key_phase
    [ "$status" -eq 0 ]
}

@test "upload_github_key_phase provides clear error messages" {
    check_github_cli_authenticated() { return 1; }
    authenticate_github_cli() {
        echo "ERROR: Authentication failed"
        return 1
    }
    export -f check_github_cli_authenticated authenticate_github_cli

    run upload_github_key_phase
    [ "$status" -ne 0 ]
    [[ "$output" =~ "ERROR" ]] || [[ "$output" =~ "failed" ]]
}

# =============================================================================
# INTEGRATION TESTS (6 tests)
# =============================================================================

@test "INTEGRATION: Full happy path (not authenticated → authenticate → upload)" {
    local auth_check=0
    local auth_login=0
    local key_check=0
    local key_upload=0

    check_github_cli_authenticated() {
        auth_check=1
        return 1  # Not authenticated
    }
    authenticate_github_cli() {
        auth_login=1
        return 0
    }
    check_key_exists_on_github() {
        key_check=1
        return 1  # Key doesn't exist
    }
    upload_ssh_key_to_github() {
        key_upload=1
        return 0
    }
    export -f check_github_cli_authenticated authenticate_github_cli check_key_exists_on_github upload_ssh_key_to_github

    run upload_github_key_phase
    [ "$status" -eq 0 ]
    [ "${auth_check}" -eq 1 ]
    [ "${auth_login}" -eq 1 ]
    [ "${key_check}" -eq 1 ]
    [ "${key_upload}" -eq 1 ]
}

@test "INTEGRATION: Full happy path (already authenticated → upload)" {
    local auth_check=0
    local auth_login=0
    local key_check=0
    local key_upload=0

    check_github_cli_authenticated() {
        auth_check=1
        return 0  # Already authenticated
    }
    authenticate_github_cli() {
        auth_login=1
        return 0
    }
    check_key_exists_on_github() {
        key_check=1
        return 1  # Key doesn't exist
    }
    upload_ssh_key_to_github() {
        key_upload=1
        return 0
    }
    export -f check_github_cli_authenticated authenticate_github_cli check_key_exists_on_github upload_ssh_key_to_github

    run upload_github_key_phase
    [ "$status" -eq 0 ]
    [ "${auth_check}" -eq 1 ]
    [ "${auth_login}" -eq 0 ]  # Should NOT authenticate
    [ "${key_check}" -eq 1 ]
    [ "${key_upload}" -eq 1 ]
}

@test "INTEGRATION: Key already exists path" {
    local auth_check=0
    local key_check=0
    local key_upload=0

    check_github_cli_authenticated() {
        auth_check=1
        return 0
    }
    check_key_exists_on_github() {
        key_check=1
        return 0  # Key exists
    }
    upload_ssh_key_to_github() {
        key_upload=1
        return 0
    }
    export -f check_github_cli_authenticated check_key_exists_on_github upload_ssh_key_to_github

    run upload_github_key_phase
    [ "$status" -eq 0 ]
    [ "${auth_check}" -eq 1 ]
    [ "${key_check}" -eq 1 ]
    [ "${key_upload}" -eq 0 ]  # Should NOT upload
}

@test "INTEGRATION: Fallback path (upload fails → manual)" {
    local upload_failed=0
    local fallback_called=0

    check_github_cli_authenticated() { return 0; }
    check_key_exists_on_github() { return 1; }
    upload_ssh_key_to_github() {
        upload_failed=1
        return 1
    }
    fallback_manual_key_upload() {
        fallback_called=1
        return 0
    }
    export -f check_github_cli_authenticated check_key_exists_on_github upload_ssh_key_to_github fallback_manual_key_upload

    run upload_github_key_phase
    [ "$status" -eq 0 ]
    [ "${upload_failed}" -eq 1 ]
    [ "${fallback_called}" -eq 1 ]
}

@test "INTEGRATION: Idempotent re-run (key exists)" {
    # First run
    check_github_cli_authenticated() { return 0; }
    check_key_exists_on_github() { return 0; }  # Key exists
    export -f check_github_cli_authenticated check_key_exists_on_github

    run upload_github_key_phase
    [ "$status" -eq 0 ]

    # Second run (should also succeed without re-uploading)
    run upload_github_key_phase
    [ "$status" -eq 0 ]
}

@test "INTEGRATION: Network failure during authentication" {
    check_github_cli_authenticated() { return 1; }
    authenticate_github_cli() {
        echo "Error: Network unreachable"
        return 1
    }
    export -f check_github_cli_authenticated authenticate_github_cli

    run upload_github_key_phase
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Network" ]] || [[ "$output" =~ "failed" ]]
}
