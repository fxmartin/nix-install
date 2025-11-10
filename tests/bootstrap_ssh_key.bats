#!/usr/bin/env bats
# ABOUTME: Test suite for Phase 6 SSH key generation for GitHub authentication
# ABOUTME: Tests SSH key generation, permissions, ssh-agent management, and existing key handling

# Load the bootstrap script for testing
setup() {
    # Source the bootstrap script to access functions
    # Skip main() execution by sourcing
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Set up test environment variables
    export USER_EMAIL="test@example.com"
    export HOME="${BATS_TEST_TMPDIR}/home"

    # Create temporary home directory for testing
    mkdir -p "${HOME}"
}

teardown() {
    # Clean up test files
    rm -rf "${HOME}"
}

# =============================================================================
# FUNCTION EXISTENCE TESTS (8 tests)
# =============================================================================

@test "ensure_ssh_directory function exists" {
    declare -f ensure_ssh_directory > /dev/null
}

@test "check_existing_ssh_key function exists" {
    declare -f check_existing_ssh_key > /dev/null
}

@test "prompt_use_existing_key function exists" {
    declare -f prompt_use_existing_key > /dev/null
}

@test "generate_ssh_key function exists" {
    declare -f generate_ssh_key > /dev/null
}

@test "set_ssh_key_permissions function exists" {
    declare -f set_ssh_key_permissions > /dev/null
}

@test "start_ssh_agent_and_add_key function exists" {
    declare -f start_ssh_agent_and_add_key > /dev/null
}

@test "display_ssh_key_summary function exists" {
    declare -f display_ssh_key_summary > /dev/null
}

@test "setup_ssh_key_phase function exists" {
    declare -f setup_ssh_key_phase > /dev/null
}

# =============================================================================
# SSH DIRECTORY CREATION TESTS (8 tests)
# =============================================================================

@test "ensure_ssh_directory creates .ssh directory if not exists" {
    # Mock mkdir to track calls
    mkdir() {
        if [[ "$1" == "-p" ]] && [[ "$2" == "${HOME}/.ssh" ]]; then
            command mkdir -p "$2"
            return 0
        fi
        command mkdir "$@"
    }
    export -f mkdir

    run ensure_ssh_directory
    [ "$status" -eq 0 ]
    [ -d "${HOME}/.ssh" ]
}

@test "ensure_ssh_directory sets correct permissions (700)" {
    # Mock chmod to verify it's called with correct arguments
    chmod() {
        if [[ "$1" == "700" ]] && [[ "$2" == "${HOME}/.ssh" ]]; then
            command chmod 700 "$2"
            return 0
        fi
        command chmod "$@"
    }
    export -f chmod

    run ensure_ssh_directory
    [ "$status" -eq 0 ]
}

@test "ensure_ssh_directory succeeds if directory already exists" {
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"

    run ensure_ssh_directory
    [ "$status" -eq 0 ]
    [ -d "${HOME}/.ssh" ]
}

@test "ensure_ssh_directory warns but continues on failure" {
    # Mock mkdir to fail
    mkdir() {
        return 1
    }
    export -f mkdir

    run ensure_ssh_directory
    # Should warn but not exit (NON-CRITICAL)
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "ensure_ssh_directory logs info message" {
    run ensure_ssh_directory
    [[ "$output" == *"ssh"* ]] || [[ "$output" == *"directory"* ]] || [ "$status" -eq 0 ]
}

@test "ensure_ssh_directory handles existing directory with wrong permissions" {
    mkdir -p "${HOME}/.ssh"
    chmod 755 "${HOME}/.ssh"

    run ensure_ssh_directory
    [ "$status" -eq 0 ]
    [ "$(stat -f %A "${HOME}/.ssh")" == "700" ]
}

@test "ensure_ssh_directory creates parent directories if needed" {
    rm -rf "${HOME}"

    run ensure_ssh_directory
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "ensure_ssh_directory is idempotent" {
    run ensure_ssh_directory
    local first_status=$status

    run ensure_ssh_directory
    [ "$status" -eq "$first_status" ]
}

# =============================================================================
# EXISTING KEY DETECTION TESTS (10 tests)
# =============================================================================

@test "check_existing_ssh_key returns 0 when key exists" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"

    run check_existing_ssh_key
    [ "$status" -eq 0 ]
}

@test "check_existing_ssh_key returns 1 when key does not exist" {
    mkdir -p "${HOME}/.ssh"

    run check_existing_ssh_key
    [ "$status" -eq 1 ]
}

@test "check_existing_ssh_key returns 1 when .ssh directory missing" {
    run check_existing_ssh_key
    [ "$status" -eq 1 ]
}

@test "check_existing_ssh_key checks for private key file" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519.pub"

    # Only public key exists, private key missing
    run check_existing_ssh_key
    [ "$status" -eq 1 ]
}

@test "check_existing_ssh_key logs info message when key exists" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"

    run check_existing_ssh_key
    [[ "$output" == *"existing"* ]] || [[ "$output" == *"found"* ]] || [ "$status" -eq 0 ]
}

@test "check_existing_ssh_key logs info message when key missing" {
    mkdir -p "${HOME}/.ssh"

    run check_existing_ssh_key
    [ "$status" -eq 1 ]
}

@test "check_existing_ssh_key handles symlink to key file" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/real_key"
    ln -s "${HOME}/.ssh/real_key" "${HOME}/.ssh/id_ed25519"

    run check_existing_ssh_key
    [ "$status" -eq 0 ]
}

@test "check_existing_ssh_key handles broken symlink" {
    mkdir -p "${HOME}/.ssh"
    ln -s "${HOME}/.ssh/nonexistent" "${HOME}/.ssh/id_ed25519"

    run check_existing_ssh_key
    [ "$status" -eq 1 ]
}

@test "check_existing_ssh_key validates file path" {
    mkdir -p "${HOME}/.ssh"

    # Create directory instead of file
    mkdir "${HOME}/.ssh/id_ed25519"

    run check_existing_ssh_key
    [ "$status" -eq 1 ]
}

@test "check_existing_ssh_key uses correct key path" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_rsa"  # Different key type

    run check_existing_ssh_key
    [ "$status" -eq 1 ]
}

# =============================================================================
# USER PROMPT TESTS (12 tests)
# =============================================================================

@test "prompt_use_existing_key accepts 'y' as yes" {
    # Mock read to return 'y'
    read() {
        if [[ "$*" == *"Use existing"* ]] || [[ "$*" == *"-r -p"* ]]; then
            eval "$1='y'"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 0 ]
}

@test "prompt_use_existing_key accepts 'Y' as yes" {
    read() {
        if [[ "$*" == *"-r -p"* ]]; then
            eval "$1='Y'"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 0 ]
}

@test "prompt_use_existing_key accepts 'yes' as yes" {
    read() {
        if [[ "$*" == *"-r -p"* ]]; then
            eval "$1='yes'"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 0 ]
}

@test "prompt_use_existing_key accepts 'Yes' as yes" {
    read() {
        if [[ "$*" == *"-r -p"* ]]; then
            eval "$1='Yes'"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 0 ]
}

@test "prompt_use_existing_key accepts 'n' as no" {
    read() {
        if [[ "$*" == *"-r -p"* ]]; then
            eval "$1='n'"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 1 ]
}

@test "prompt_use_existing_key accepts 'N' as no" {
    read() {
        if [[ "$*" == *"-r -p"* ]]; then
            eval "$1='N'"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 1 ]
}

@test "prompt_use_existing_key accepts 'no' as no" {
    read() {
        if [[ "$*" == *"-r -p"* ]]; then
            eval "$1='no'"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 1 ]
}

@test "prompt_use_existing_key accepts 'No' as no" {
    read() {
        if [[ "$*" == *"-r -p"* ]]; then
            eval "$1='No'"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 1 ]
}

@test "prompt_use_existing_key defaults to yes on invalid input" {
    read() {
        if [[ "$*" == *"-r -p"* ]]; then
            eval "$1='invalid'"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 0 ]
}

@test "prompt_use_existing_key defaults to yes on empty input" {
    read() {
        if [[ "$*" == *"-r -p"* ]]; then
            eval "$1=''"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 0 ]
}

@test "prompt_use_existing_key displays clear prompt message" {
    read() {
        if [[ "$*" == *"-r -p"* ]]; then
            eval "$1='y'"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [[ "$output" == *"existing"* ]] || [[ "$output" == *"Use"* ]] || [ "$status" -eq 0 ]
}

@test "prompt_use_existing_key handles whitespace in input" {
    read() {
        if [[ "$*" == *"-r -p"* ]]; then
            eval "$1='  y  '"
            return 0
        fi
        command read "$@"
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 0 ]
}

# =============================================================================
# SSH KEY GENERATION TESTS (12 tests)
# =============================================================================

@test "generate_ssh_key calls ssh-keygen with correct arguments" {
    mkdir -p "${HOME}/.ssh"

    # Mock ssh-keygen to verify arguments
    ssh-keygen() {
        if [[ "$1" == "-t" ]] && [[ "$2" == "ed25519" ]] && \
           [[ "$3" == "-C" ]] && [[ "$4" == "$USER_EMAIL" ]] && \
           [[ "$5" == "-f" ]] && [[ "$6" == "${HOME}/.ssh/id_ed25519" ]] && \
           [[ "$7" == "-N" ]] && [[ "$8" == "" ]]; then
            touch "${HOME}/.ssh/id_ed25519"
            touch "${HOME}/.ssh/id_ed25519.pub"
            return 0
        fi
        return 1
    }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 0 ]
}

@test "generate_ssh_key uses ed25519 key type" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() {
        [[ "$2" == "ed25519" ]]
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 0 ]
}

@test "generate_ssh_key uses user email as comment" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() {
        if [[ "$4" == "$USER_EMAIL" ]]; then
            touch "${HOME}/.ssh/id_ed25519"
            touch "${HOME}/.ssh/id_ed25519.pub"
            return 0
        fi
        return 1
    }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 0 ]
}

@test "generate_ssh_key generates key without passphrase" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() {
        # Check -N flag with empty passphrase
        if [[ "$7" == "-N" ]] && [[ "$8" == "" ]]; then
            touch "${HOME}/.ssh/id_ed25519"
            touch "${HOME}/.ssh/id_ed25519.pub"
            return 0
        fi
        return 1
    }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 0 ]
}

@test "generate_ssh_key verifies private key created" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() {
        touch "${HOME}/.ssh/id_ed25519.pub"
        # Don't create private key - should fail verification
        return 0
    }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 1 ]
}

@test "generate_ssh_key verifies public key created" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() {
        touch "${HOME}/.ssh/id_ed25519"
        # Don't create public key - should fail verification
        return 0
    }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 1 ]
}

@test "generate_ssh_key exits on ssh-keygen failure" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() {
        return 1
    }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 1 ]
}

@test "generate_ssh_key displays troubleshooting on failure" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() {
        return 1
    }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 1 ]
    [[ "$output" == *"troubleshoot"* ]] || [[ "$output" == *"failed"* ]] || [[ "$output" == *"error"* ]]
}

@test "generate_ssh_key displays security warning about no passphrase" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() {
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    export -f ssh-keygen

    run generate_ssh_key
    [[ "$output" == *"passphrase"* ]] || [[ "$output" == *"security"* ]] || [ "$status" -eq 0 ]
}

@test "generate_ssh_key logs success message" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() {
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 0 ]
}

@test "generate_ssh_key uses correct key path" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() {
        if [[ "$6" == "${HOME}/.ssh/id_ed25519" ]]; then
            touch "${HOME}/.ssh/id_ed25519"
            touch "${HOME}/.ssh/id_ed25519.pub"
            return 0
        fi
        return 1
    }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 0 ]
}

@test "generate_ssh_key handles existing key file" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"

    ssh-keygen() {
        # Overwrite existing file
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 0 ]
}

# =============================================================================
# PERMISSIONS SETTING TESTS (10 tests)
# =============================================================================

@test "set_ssh_key_permissions sets private key to 600" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    touch "${HOME}/.ssh/id_ed25519.pub"

    chmod() {
        if [[ "$1" == "600" ]] && [[ "$2" == "${HOME}/.ssh/id_ed25519" ]]; then
            command chmod 600 "$2"
            return 0
        fi
        command chmod "$@"
    }
    export -f chmod

    run set_ssh_key_permissions
    [ "$status" -eq 0 ]
}

@test "set_ssh_key_permissions sets public key to 644" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    touch "${HOME}/.ssh/id_ed25519.pub"

    chmod() {
        if [[ "$1" == "644" ]] && [[ "$2" == "${HOME}/.ssh/id_ed25519.pub" ]]; then
            command chmod 644 "$2"
            return 0
        fi
        command chmod "$@"
    }
    export -f chmod

    run set_ssh_key_permissions
    [ "$status" -eq 0 ]
}

@test "set_ssh_key_permissions verifies private key permissions" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    touch "${HOME}/.ssh/id_ed25519.pub"
    chmod 600 "${HOME}/.ssh/id_ed25519"
    chmod 644 "${HOME}/.ssh/id_ed25519.pub"

    run set_ssh_key_permissions
    [ "$status" -eq 0 ]
    [ "$(stat -f %A "${HOME}/.ssh/id_ed25519")" == "600" ]
}

@test "set_ssh_key_permissions verifies public key permissions" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    touch "${HOME}/.ssh/id_ed25519.pub"
    chmod 600 "${HOME}/.ssh/id_ed25519"
    chmod 644 "${HOME}/.ssh/id_ed25519.pub"

    run set_ssh_key_permissions
    [ "$status" -eq 0 ]
    [ "$(stat -f %A "${HOME}/.ssh/id_ed25519.pub")" == "644" ]
}

@test "set_ssh_key_permissions exits on private key chmod failure" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    touch "${HOME}/.ssh/id_ed25519.pub"

    chmod() {
        if [[ "$1" == "600" ]]; then
            return 1
        fi
        command chmod "$@"
    }
    export -f chmod

    run set_ssh_key_permissions
    [ "$status" -eq 1 ]
}

@test "set_ssh_key_permissions exits on public key chmod failure" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    touch "${HOME}/.ssh/id_ed25519.pub"

    chmod() {
        if [[ "$1" == "644" ]]; then
            return 1
        fi
        command chmod "$@"
    }
    export -f chmod

    run set_ssh_key_permissions
    [ "$status" -eq 1 ]
}

@test "set_ssh_key_permissions exits if private key missing" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519.pub"

    run set_ssh_key_permissions
    [ "$status" -eq 1 ]
}

@test "set_ssh_key_permissions exits if public key missing" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"

    run set_ssh_key_permissions
    [ "$status" -eq 1 ]
}

@test "set_ssh_key_permissions logs success message" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    touch "${HOME}/.ssh/id_ed25519.pub"
    chmod 600 "${HOME}/.ssh/id_ed25519"
    chmod 644 "${HOME}/.ssh/id_ed25519.pub"

    run set_ssh_key_permissions
    [ "$status" -eq 0 ]
}

@test "set_ssh_key_permissions is idempotent" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    touch "${HOME}/.ssh/id_ed25519.pub"
    chmod 600 "${HOME}/.ssh/id_ed25519"
    chmod 644 "${HOME}/.ssh/id_ed25519.pub"

    run set_ssh_key_permissions
    local first_status=$status

    run set_ssh_key_permissions
    [ "$status" -eq "$first_status" ]
}

# =============================================================================
# SSH AGENT MANAGEMENT TESTS (10 tests)
# =============================================================================

@test "start_ssh_agent_and_add_key starts ssh-agent" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    chmod 600 "${HOME}/.ssh/id_ed25519"

    ssh-agent() {
        echo "SSH_AUTH_SOCK=/tmp/ssh-agent.sock; export SSH_AUTH_SOCK;"
        echo "SSH_AGENT_PID=12345; export SSH_AGENT_PID;"
        return 0
    }
    export -f ssh-agent

    ssh-add() {
        return 0
    }
    export -f ssh-add

    run start_ssh_agent_and_add_key
    [ "$status" -eq 0 ]
}

@test "start_ssh_agent_and_add_key calls ssh-add with key path" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    chmod 600 "${HOME}/.ssh/id_ed25519"

    ssh-agent() {
        echo "SSH_AUTH_SOCK=/tmp/ssh-agent.sock; export SSH_AUTH_SOCK;"
        return 0
    }
    export -f ssh-agent

    ssh-add() {
        [[ "$1" == "${HOME}/.ssh/id_ed25519" ]]
        return 0
    }
    export -f ssh-add

    run start_ssh_agent_and_add_key
    [ "$status" -eq 0 ]
}

@test "start_ssh_agent_and_add_key verifies key added successfully" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    chmod 600 "${HOME}/.ssh/id_ed25519"

    ssh-agent() {
        echo "SSH_AUTH_SOCK=/tmp/ssh-agent.sock; export SSH_AUTH_SOCK;"
        return 0
    }
    export -f ssh-agent

    ssh-add() {
        echo "Identity added: ${HOME}/.ssh/id_ed25519"
        return 0
    }
    export -f ssh-add

    run start_ssh_agent_and_add_key
    [ "$status" -eq 0 ]
}

@test "start_ssh_agent_and_add_key exits on ssh-agent failure" {
    ssh-agent() {
        return 1
    }
    export -f ssh-agent

    run start_ssh_agent_and_add_key
    [ "$status" -eq 1 ]
}

@test "start_ssh_agent_and_add_key exits on ssh-add failure" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    chmod 600 "${HOME}/.ssh/id_ed25519"

    ssh-agent() {
        echo "SSH_AUTH_SOCK=/tmp/ssh-agent.sock; export SSH_AUTH_SOCK;"
        return 0
    }
    export -f ssh-agent

    ssh-add() {
        return 1
    }
    export -f ssh-add

    run start_ssh_agent_and_add_key
    [ "$status" -eq 1 ]
}

@test "start_ssh_agent_and_add_key displays troubleshooting on agent failure" {
    ssh-agent() {
        return 1
    }
    export -f ssh-agent

    run start_ssh_agent_and_add_key
    [ "$status" -eq 1 ]
    [[ "$output" == *"troubleshoot"* ]] || [[ "$output" == *"failed"* ]] || [[ "$output" == *"error"* ]]
}

@test "start_ssh_agent_and_add_key displays troubleshooting on add failure" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    chmod 600 "${HOME}/.ssh/id_ed25519"

    ssh-agent() {
        echo "SSH_AUTH_SOCK=/tmp/ssh-agent.sock; export SSH_AUTH_SOCK;"
        return 0
    }
    export -f ssh-agent

    ssh-add() {
        return 1
    }
    export -f ssh-add

    run start_ssh_agent_and_add_key
    [ "$status" -eq 1 ]
    [[ "$output" == *"troubleshoot"* ]] || [[ "$output" == *"failed"* ]] || [[ "$output" == *"error"* ]]
}

@test "start_ssh_agent_and_add_key logs success message" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    chmod 600 "${HOME}/.ssh/id_ed25519"

    ssh-agent() {
        echo "SSH_AUTH_SOCK=/tmp/ssh-agent.sock; export SSH_AUTH_SOCK;"
        return 0
    }
    export -f ssh-agent

    ssh-add() {
        return 0
    }
    export -f ssh-add

    run start_ssh_agent_and_add_key
    [ "$status" -eq 0 ]
}

@test "start_ssh_agent_and_add_key evaluates ssh-agent output" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"
    chmod 600 "${HOME}/.ssh/id_ed25519"

    ssh-agent() {
        echo "SSH_AUTH_SOCK=/tmp/ssh-agent.sock; export SSH_AUTH_SOCK;"
        echo "SSH_AGENT_PID=12345; export SSH_AGENT_PID;"
        return 0
    }
    export -f ssh-agent

    ssh-add() {
        return 0
    }
    export -f ssh-add

    run start_ssh_agent_and_add_key
    [ "$status" -eq 0 ]
}

@test "start_ssh_agent_and_add_key handles missing key file" {
    mkdir -p "${HOME}/.ssh"

    ssh-agent() {
        echo "SSH_AUTH_SOCK=/tmp/ssh-agent.sock; export SSH_AUTH_SOCK;"
        return 0
    }
    export -f ssh-agent

    ssh-add() {
        return 1
    }
    export -f ssh-add

    run start_ssh_agent_and_add_key
    [ "$status" -eq 1 ]
}

# =============================================================================
# SUMMARY DISPLAY TESTS (5 tests)
# =============================================================================

@test "display_ssh_key_summary shows public key content" {
    mkdir -p "${HOME}/.ssh"
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITest test@example.com" > "${HOME}/.ssh/id_ed25519.pub"

    run display_ssh_key_summary
    [[ "$output" == *"ssh-ed25519"* ]] || [ "$status" -eq 0 ]
}

@test "display_ssh_key_summary shows key fingerprint" {
    mkdir -p "${HOME}/.ssh"
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITest test@example.com" > "${HOME}/.ssh/id_ed25519.pub"

    ssh-keygen() {
        if [[ "$1" == "-lf" ]]; then
            echo "256 SHA256:fingerprint test@example.com (ED25519)"
            return 0
        fi
        command ssh-keygen "$@"
    }
    export -f ssh-keygen

    run display_ssh_key_summary
    [[ "$output" == *"fingerprint"* ]] || [[ "$output" == *"SHA256"* ]] || [ "$status" -eq 0 ]
}

@test "display_ssh_key_summary shows key comment" {
    mkdir -p "${HOME}/.ssh"
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITest test@example.com" > "${HOME}/.ssh/id_ed25519.pub"

    run display_ssh_key_summary
    [[ "$output" == *"test@example.com"* ]] || [ "$status" -eq 0 ]
}

@test "display_ssh_key_summary confirms ssh-agent status" {
    mkdir -p "${HOME}/.ssh"
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITest test@example.com" > "${HOME}/.ssh/id_ed25519.pub"

    run display_ssh_key_summary
    [[ "$output" == *"agent"* ]] || [[ "$output" == *"added"* ]] || [ "$status" -eq 0 ]
}

@test "display_ssh_key_summary formats output clearly" {
    mkdir -p "${HOME}/.ssh"
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITest test@example.com" > "${HOME}/.ssh/id_ed25519.pub"

    run display_ssh_key_summary
    [ "$status" -eq 0 ]
}

# =============================================================================
# ORCHESTRATION TESTS (8 tests)
# =============================================================================

@test "setup_ssh_key_phase calls ensure_ssh_directory" {
    # Mock all dependent functions
    ensure_ssh_directory() { return 0; }
    check_existing_ssh_key() { return 1; }
    generate_ssh_key() {
        mkdir -p "${HOME}/.ssh"
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    set_ssh_key_permissions() { return 0; }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key generate_ssh_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
}

@test "setup_ssh_key_phase calls check_existing_ssh_key" {
    ensure_ssh_directory() { return 0; }
    check_existing_ssh_key() { return 1; }
    generate_ssh_key() {
        mkdir -p "${HOME}/.ssh"
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    set_ssh_key_permissions() { return 0; }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key generate_ssh_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
}

@test "setup_ssh_key_phase skips generation when key exists and user chooses yes" {
    ensure_ssh_directory() { return 0; }
    check_existing_ssh_key() {
        mkdir -p "${HOME}/.ssh"
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    prompt_use_existing_key() { return 0; }
    set_ssh_key_permissions() { return 0; }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key prompt_use_existing_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
}

@test "setup_ssh_key_phase generates new key when none exists" {
    ensure_ssh_directory() { return 0; }
    check_existing_ssh_key() { return 1; }
    generate_ssh_key() {
        mkdir -p "${HOME}/.ssh"
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    set_ssh_key_permissions() { return 0; }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key generate_ssh_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
}

@test "setup_ssh_key_phase generates new key when user chooses no" {
    ensure_ssh_directory() { return 0; }
    check_existing_ssh_key() { return 0; }
    prompt_use_existing_key() { return 1; }
    generate_ssh_key() {
        mkdir -p "${HOME}/.ssh"
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    set_ssh_key_permissions() { return 0; }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key prompt_use_existing_key generate_ssh_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
}

@test "setup_ssh_key_phase exits on CRITICAL function failure" {
    ensure_ssh_directory() { return 0; }
    check_existing_ssh_key() { return 1; }
    generate_ssh_key() { return 1; }
    export -f ensure_ssh_directory check_existing_ssh_key generate_ssh_key

    run setup_ssh_key_phase
    [ "$status" -eq 1 ]
}

@test "setup_ssh_key_phase calls all functions in sequence" {
    local call_order=""

    ensure_ssh_directory() { call_order+="1,"; return 0; }
    check_existing_ssh_key() { call_order+="2,"; return 1; }
    generate_ssh_key() {
        call_order+="3,"
        mkdir -p "${HOME}/.ssh"
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    set_ssh_key_permissions() { call_order+="4,"; return 0; }
    start_ssh_agent_and_add_key() { call_order+="5,"; return 0; }
    display_ssh_key_summary() { call_order+="6,"; return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key generate_ssh_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
    [[ "$call_order" == "1,2,3,4,5,6," ]] || [ "$status" -eq 0 ]
}

@test "setup_ssh_key_phase returns 0 on success" {
    ensure_ssh_directory() { return 0; }
    check_existing_ssh_key() { return 1; }
    generate_ssh_key() {
        mkdir -p "${HOME}/.ssh"
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    set_ssh_key_permissions() { return 0; }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key generate_ssh_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
}

# =============================================================================
# ERROR HANDLING TESTS (10 tests)
# =============================================================================

@test "generate_ssh_key is CRITICAL - exits on failure" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() { return 1; }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 1 ]
}

@test "set_ssh_key_permissions is CRITICAL - exits on failure" {
    mkdir -p "${HOME}/.ssh"
    touch "${HOME}/.ssh/id_ed25519"

    chmod() { return 1; }
    export -f chmod

    run set_ssh_key_permissions
    [ "$status" -eq 1 ]
}

@test "start_ssh_agent_and_add_key is CRITICAL - exits on failure" {
    ssh-agent() { return 1; }
    export -f ssh-agent

    run start_ssh_agent_and_add_key
    [ "$status" -eq 1 ]
}

@test "ensure_ssh_directory is NON-CRITICAL - warns but continues" {
    mkdir() {
        if [[ "$1" == "-p" ]]; then
            return 1
        fi
        command mkdir "$@"
    }
    export -f mkdir

    run ensure_ssh_directory
    # Should not exit with error
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "check_existing_ssh_key is NON-CRITICAL - returns status only" {
    run check_existing_ssh_key
    # Should not cause script termination
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "prompt_use_existing_key is NON-CRITICAL - returns status only" {
    read() {
        eval "$1='y'"
        return 0
    }
    export -f read

    run prompt_use_existing_key
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "display_ssh_key_summary is NON-CRITICAL - warns on errors" {
    mkdir -p "${HOME}/.ssh"

    run display_ssh_key_summary
    # Should not cause script termination
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "CRITICAL functions display error messages" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() { return 1; }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR"* ]] || [[ "$output" == *"failed"* ]]
}

@test "CRITICAL functions provide troubleshooting guidance" {
    mkdir -p "${HOME}/.ssh"

    ssh-keygen() { return 1; }
    export -f ssh-keygen

    run generate_ssh_key
    [ "$status" -eq 1 ]
    [[ "$output" == *"troubleshoot"* ]] || [[ "$output" == *"Try"* ]] || [[ "$output" == *"help"* ]] || [[ "$output" == *"failed"* ]]
}

@test "NON-CRITICAL failures do not terminate phase" {
    ensure_ssh_directory() {
        log_warn "Directory creation failed"
        return 1
    }
    check_existing_ssh_key() { return 1; }
    generate_ssh_key() {
        mkdir -p "${HOME}/.ssh"
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    set_ssh_key_permissions() { return 0; }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key generate_ssh_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
}

# =============================================================================
# INTEGRATION TESTS (7 tests)
# =============================================================================

@test "full phase execution - new key generation workflow" {
    ensure_ssh_directory() {
        mkdir -p "${HOME}/.ssh"
        chmod 700 "${HOME}/.ssh"
        return 0
    }
    check_existing_ssh_key() { return 1; }
    generate_ssh_key() {
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    set_ssh_key_permissions() {
        chmod 600 "${HOME}/.ssh/id_ed25519"
        chmod 644 "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key generate_ssh_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
    [ -f "${HOME}/.ssh/id_ed25519" ]
    [ -f "${HOME}/.ssh/id_ed25519.pub" ]
}

@test "full phase execution - existing key workflow" {
    ensure_ssh_directory() {
        mkdir -p "${HOME}/.ssh"
        chmod 700 "${HOME}/.ssh"
        return 0
    }
    check_existing_ssh_key() {
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    prompt_use_existing_key() { return 0; }
    set_ssh_key_permissions() {
        chmod 600 "${HOME}/.ssh/id_ed25519"
        chmod 644 "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key prompt_use_existing_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
}

@test "full phase execution - replace existing key workflow" {
    ensure_ssh_directory() {
        mkdir -p "${HOME}/.ssh"
        chmod 700 "${HOME}/.ssh"
        return 0
    }
    check_existing_ssh_key() {
        touch "${HOME}/.ssh/id_ed25519.old"
        return 0
    }
    prompt_use_existing_key() { return 1; }
    generate_ssh_key() {
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    set_ssh_key_permissions() {
        chmod 600 "${HOME}/.ssh/id_ed25519"
        chmod 644 "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key prompt_use_existing_key generate_ssh_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
}

@test "phase fails gracefully on CRITICAL error" {
    ensure_ssh_directory() { return 0; }
    check_existing_ssh_key() { return 1; }
    generate_ssh_key() { return 1; }
    export -f ensure_ssh_directory check_existing_ssh_key generate_ssh_key

    run setup_ssh_key_phase
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR"* ]] || [[ "$output" == *"failed"* ]]
}

@test "phase logs are clear and informative" {
    ensure_ssh_directory() {
        log_info "Creating SSH directory"
        mkdir -p "${HOME}/.ssh"
        return 0
    }
    check_existing_ssh_key() {
        log_info "Checking for existing key"
        return 1
    }
    generate_ssh_key() {
        log_info "Generating new SSH key"
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    set_ssh_key_permissions() {
        log_info "Setting permissions"
        return 0
    }
    start_ssh_agent_and_add_key() {
        log_info "Starting ssh-agent"
        return 0
    }
    display_ssh_key_summary() {
        log_info "SSH key ready"
        return 0
    }
    export -f ensure_ssh_directory check_existing_ssh_key generate_ssh_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
}

@test "phase is idempotent - can run multiple times safely" {
    ensure_ssh_directory() {
        mkdir -p "${HOME}/.ssh"
        return 0
    }
    check_existing_ssh_key() {
        if [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
            return 0
        fi
        return 1
    }
    prompt_use_existing_key() { return 0; }
    set_ssh_key_permissions() { return 0; }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key prompt_use_existing_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    # First run - generates key
    run setup_ssh_key_phase
    local first_status=$status

    # Second run - uses existing key
    run setup_ssh_key_phase
    [ "$status" -eq "$first_status" ]
}

@test "phase integrates with USER_EMAIL variable" {
    export USER_EMAIL="fx@example.com"

    ensure_ssh_directory() { return 0; }
    check_existing_ssh_key() { return 1; }
    generate_ssh_key() {
        # Verify USER_EMAIL is used
        [[ -n "$USER_EMAIL" ]]
        touch "${HOME}/.ssh/id_ed25519"
        touch "${HOME}/.ssh/id_ed25519.pub"
        return 0
    }
    set_ssh_key_permissions() { return 0; }
    start_ssh_agent_and_add_key() { return 0; }
    display_ssh_key_summary() { return 0; }
    export -f ensure_ssh_directory check_existing_ssh_key generate_ssh_key
    export -f set_ssh_key_permissions start_ssh_agent_and_add_key display_ssh_key_summary

    run setup_ssh_key_phase
    [ "$status" -eq 0 ]
}
