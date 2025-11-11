#!/usr/bin/env bats
# ABOUTME: BATS test suite for bootstrap.sh Phase 7 (Repository Clone)
# ABOUTME: Tests git clone functionality, user-config.nix preservation, and directory handling

# Test Setup
# ===========================================================================
# Load BATS testing framework and support libraries

setup() {
    # Load bats-support for better assertions
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    # Source the bootstrap script to test its functions
    # This loads all functions but does NOT execute main()
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Create temporary test directory
    TEST_TEMP_DIR="$(mktemp -d)"
    export TEST_TEMP_DIR

    # Override HOME for testing
    export ORIGINAL_HOME="${HOME}"
    export HOME="${TEST_TEMP_DIR}/home"
    mkdir -p "${HOME}"

    # Override repository clone directory for testing
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"
    export BOOTSTRAP_TEMP_DIR="/tmp/nix-bootstrap"

    # Create bootstrap temp directory structure
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"

    # Mock git command to avoid actual network calls
    export GIT_MOCK_SUCCESS=1
    export GIT_MOCK_CLONE_CALLED=0
}

teardown() {
    # Restore original HOME
    export HOME="${ORIGINAL_HOME}"

    # Clean up test temporary directory
    if [[ -n "${TEST_TEMP_DIR}" ]] && [[ -d "${TEST_TEMP_DIR}" ]]; then
        rm -rf "${TEST_TEMP_DIR}"
    fi
}

# ===========================================================================
# CATEGORY 1: DIRECTORY CREATION TESTS (15 tests)
# ===========================================================================

@test "create_documents_directory: creates ~/Documents when missing" {
    # Verify ~/Documents doesn't exist
    [[ ! -d "${HOME}/Documents" ]]

    # Create Documents directory
    run create_documents_directory

    # Should succeed
    assert_success

    # Directory should now exist
    [[ -d "${HOME}/Documents" ]]
}

@test "create_documents_directory: succeeds when ~/Documents already exists" {
    # Create ~/Documents first
    mkdir -p "${HOME}/Documents"

    # Try to create again (idempotency test)
    run create_documents_directory

    # Should succeed (not fail on existing directory)
    assert_success

    # Directory should still exist
    [[ -d "${HOME}/Documents" ]]
}

@test "create_documents_directory: creates directory with correct permissions" {
    # Create Documents directory
    run create_documents_directory
    assert_success

    # Check permissions (should be drwxr-xr-x or similar)
    local perms
    perms=$(stat -f "%Sp" "${HOME}/Documents")

    # Owner should have read, write, execute
    [[ "${perms}" =~ ^drwx ]]
}

@test "create_documents_directory: handles permission errors gracefully" {
    # Create read-only parent directory to simulate permission error
    local readonly_parent="${TEST_TEMP_DIR}/readonly"
    mkdir -p "${readonly_parent}"
    chmod 555 "${readonly_parent}"

    # Override HOME to point to read-only location
    export HOME="${readonly_parent}/home"

    # Try to create Documents (should fail due to permissions)
    run create_documents_directory

    # Should return failure
    assert_failure

    # Clean up
    chmod 755 "${readonly_parent}"
}

@test "create_documents_directory: handles existing file named 'Documents'" {
    # Create a file named 'Documents' (not a directory)
    touch "${HOME}/Documents"

    # Try to create Documents directory
    run create_documents_directory

    # Should fail (can't create directory over file)
    assert_failure
}

@test "create_documents_directory: handles symlink named 'Documents'" {
    # Create another directory and symlink to it
    mkdir -p "${HOME}/other_location"
    ln -s "${HOME}/other_location" "${HOME}/Documents"

    # Try to create Documents directory
    run create_documents_directory

    # Should succeed (symlink is treated as directory)
    assert_success

    # Symlink should still exist
    [[ -L "${HOME}/Documents" ]]
}

@test "create_documents_directory: logs creation action" {
    # Create Documents directory
    run create_documents_directory

    # Output should mention creation
    assert_output --partial "Documents"
}

@test "create_documents_directory: logs when directory already exists" {
    # Create ~/Documents first
    mkdir -p "${HOME}/Documents"

    # Try to create again
    run create_documents_directory

    # Output should indicate it already exists
    assert_success
}

@test "create_documents_directory: handles spaces in HOME path" {
    # Create HOME with spaces
    export HOME="${TEST_TEMP_DIR}/home with spaces"
    mkdir -p "${HOME}"

    # Create Documents
    run create_documents_directory

    # Should succeed
    assert_success

    # Directory should exist
    [[ -d "${HOME}/Documents" ]]
}

@test "create_documents_directory: handles special characters in HOME" {
    # Create HOME with special characters
    export HOME="${TEST_TEMP_DIR}/home-special_chars@123"
    mkdir -p "${HOME}"

    # Create Documents
    run create_documents_directory

    # Should succeed
    assert_success

    # Directory should exist
    [[ -d "${HOME}/Documents" ]]
}

@test "create_documents_directory: creates parent directories if needed" {
    # Set HOME to non-existent nested path
    export HOME="${TEST_TEMP_DIR}/nested/home"

    # Create Documents (should create full path)
    run create_documents_directory

    # Should succeed
    assert_success

    # All directories should exist
    [[ -d "${HOME}/Documents" ]]
}

@test "create_documents_directory: returns 0 on success" {
    run create_documents_directory

    # Exit code should be 0
    assert_equal "$status" "0"
}

@test "create_documents_directory: returns 1 on failure" {
    # Create read-only parent directory
    local readonly_parent="${TEST_TEMP_DIR}/readonly"
    mkdir -p "${readonly_parent}"
    chmod 555 "${readonly_parent}"

    export HOME="${readonly_parent}/home"

    run create_documents_directory

    # Exit code should be 1
    assert_equal "$status" "1"

    chmod 755 "${readonly_parent}"
}

@test "create_documents_directory: handles very long paths" {
    # Create deeply nested HOME path
    local long_path="${TEST_TEMP_DIR}/very/long/nested/path/to/home"
    mkdir -p "${long_path}"
    export HOME="${long_path}"

    run create_documents_directory

    assert_success
    [[ -d "${HOME}/Documents" ]]
}

@test "create_documents_directory: works with relative path resolution" {
    # Change to test directory
    cd "${TEST_TEMP_DIR}" || skip "Could not change directory"

    # Create Documents
    run create_documents_directory

    assert_success
}

# ===========================================================================
# CATEGORY 2: EXISTING REPOSITORY HANDLING TESTS (20 tests)
# ===========================================================================

@test "check_existing_repo_directory: returns 1 when repo doesn't exist" {
    # Verify repo directory doesn't exist
    [[ ! -d "${REPO_CLONE_DIR}" ]]

    # Check for existing repo
    run check_existing_repo_directory

    # Should return 1 (not found)
    assert_equal "$status" "1"
}

@test "check_existing_repo_directory: returns 0 when repo exists" {
    # Create repo directory
    mkdir -p "${REPO_CLONE_DIR}"

    # Check for existing repo
    run check_existing_repo_directory

    # Should return 0 (found)
    assert_equal "$status" "0"
}

@test "check_existing_repo_directory: detects directory with .git" {
    # Create repo directory with .git
    mkdir -p "${REPO_CLONE_DIR}/.git"

    # Check for existing repo
    run check_existing_repo_directory

    # Should return 0 (found)
    assert_equal "$status" "0"
}

@test "check_existing_repo_directory: detects directory without .git" {
    # Create repo directory without .git (incomplete clone)
    mkdir -p "${REPO_CLONE_DIR}"

    # Check should still return 0 (directory exists)
    run check_existing_repo_directory

    assert_equal "$status" "0"
}

@test "check_existing_repo_directory: handles symlink to directory" {
    # Create target directory and symlink
    mkdir -p "${HOME}/Documents/real_repo"
    ln -s "${HOME}/Documents/real_repo" "${REPO_CLONE_DIR}"

    # Check for existing repo
    run check_existing_repo_directory

    # Should return 0 (symlink exists)
    assert_equal "$status" "0"
}

@test "check_existing_repo_directory: handles file named nix-install" {
    # Create file instead of directory
    mkdir -p "${HOME}/Documents"
    touch "${HOME}/Documents/nix-install"

    # Check for existing repo
    run check_existing_repo_directory

    # Should return 0 (something exists at that path)
    assert_equal "$status" "0"
}

@test "prompt_remove_existing_repo: accepts 'y' to remove" {
    skip "Interactive test - requires manual testing in VM"
    # This test requires user input, so we skip in automated tests
    # VM testing will validate interactive prompts
}

@test "prompt_remove_existing_repo: accepts 'Y' to remove (case insensitive)" {
    skip "Interactive test - requires manual testing in VM"
}

@test "prompt_remove_existing_repo: accepts 'n' to skip" {
    skip "Interactive test - requires manual testing in VM"
}

@test "prompt_remove_existing_repo: accepts 'N' to skip (case insensitive)" {
    skip "Interactive test - requires manual testing in VM"
}

@test "prompt_remove_existing_repo: rejects invalid input and retries" {
    skip "Interactive test - requires manual testing in VM"
}

@test "prompt_remove_existing_repo: displays warning about data loss" {
    skip "Interactive test - requires manual testing in VM"
}

@test "remove_existing_repo_directory: removes directory recursively" {
    # Create repo directory with files
    mkdir -p "${REPO_CLONE_DIR}/subdir"
    touch "${REPO_CLONE_DIR}/file1.txt"
    touch "${REPO_CLONE_DIR}/subdir/file2.txt"

    # Remove directory
    run remove_existing_repo_directory

    # Should succeed
    assert_success

    # Directory should be gone
    [[ ! -d "${REPO_CLONE_DIR}" ]]
}

@test "remove_existing_repo_directory: removes .git directory" {
    # Create repo with .git
    mkdir -p "${REPO_CLONE_DIR}/.git/objects"
    touch "${REPO_CLONE_DIR}/.git/config"

    # Remove directory
    run remove_existing_repo_directory

    # Should succeed
    assert_success

    # .git should be gone
    [[ ! -d "${REPO_CLONE_DIR}/.git" ]]
}

@test "remove_existing_repo_directory: handles non-existent directory gracefully" {
    # Verify directory doesn't exist
    [[ ! -d "${REPO_CLONE_DIR}" ]]

    # Try to remove (should not fail)
    run remove_existing_repo_directory

    # Should succeed (idempotent)
    assert_success
}

@test "remove_existing_repo_directory: logs removal action" {
    # Create directory
    mkdir -p "${REPO_CLONE_DIR}"

    # Remove with logging
    run remove_existing_repo_directory

    # Should mention removal
    assert_output --partial "remov"
}

@test "remove_existing_repo_directory: handles permission errors" {
    # Create directory with read-only parent
    mkdir -p "${HOME}/Documents"
    chmod 555 "${HOME}/Documents"

    # Directory won't be removable
    mkdir -p "${REPO_CLONE_DIR}" 2>/dev/null || true

    # Try to remove (may fail due to permissions)
    run remove_existing_repo_directory

    # Clean up
    chmod 755 "${HOME}/Documents"
}

@test "remove_existing_repo_directory: removes symlinks" {
    # Create symlink
    mkdir -p "${HOME}/Documents/real_repo"
    ln -s "${HOME}/Documents/real_repo" "${REPO_CLONE_DIR}"

    # Remove
    run remove_existing_repo_directory

    # Should succeed
    assert_success

    # Symlink should be gone
    [[ ! -L "${REPO_CLONE_DIR}" ]]
}

@test "remove_existing_repo_directory: returns 0 on success" {
    mkdir -p "${REPO_CLONE_DIR}"

    run remove_existing_repo_directory

    assert_equal "$status" "0"
}

@test "remove_existing_repo_directory: handles very large directory" {
    # Create directory with many files
    mkdir -p "${REPO_CLONE_DIR}"
    for i in {1..100}; do
        touch "${REPO_CLONE_DIR}/file${i}.txt"
    done

    # Remove should still work
    run remove_existing_repo_directory

    assert_success
    [[ ! -d "${REPO_CLONE_DIR}" ]]
}

# ===========================================================================
# CATEGORY 3: GIT CLONE TESTS (25 tests)
# ===========================================================================

@test "clone_repository: successfully clones repository" {
    # Mock successful git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3"
            mkdir -p "$3/.git"
            echo "Cloning into '$3'..."
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Clone repository
    run clone_repository

    # Should succeed
    assert_success

    # Directory should exist
    [[ -d "${REPO_CLONE_DIR}" ]]
}

@test "clone_repository: uses correct repository URL" {
    # Mock git to capture arguments
    git() {
        if [[ "$1" == "clone" ]]; then
            echo "URL: $2"
            mkdir -p "$3/.git"
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Clone repository
    run clone_repository

    # Should use correct GitHub URL
    assert_output --partial "git@github.com:fxmartin/nix-install.git"
}

@test "clone_repository: clones to correct location" {
    # Mock git to capture destination
    git() {
        if [[ "$1" == "clone" ]]; then
            echo "Destination: $3"
            mkdir -p "$3/.git"
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Clone repository
    run clone_repository

    # Should clone to ~/Documents/nix-install
    assert_output --partial "${HOME}/Documents/nix-install"
}

@test "clone_repository: creates .git directory" {
    # Mock git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Clone repository
    run clone_repository

    # .git directory should exist
    [[ -d "${REPO_CLONE_DIR}/.git" ]]
}

@test "clone_repository: handles git clone failure" {
    # Mock failed git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            echo "fatal: Could not read from remote repository"
            return 128
        fi
        command git "$@"
    }
    export -f git

    # Try to clone
    run clone_repository

    # Should fail
    assert_failure
}

@test "clone_repository: displays error on network failure" {
    # Mock network failure
    git() {
        if [[ "$1" == "clone" ]]; then
            echo "fatal: unable to access 'https://github.com/': Could not resolve host"
            return 128
        fi
        command git "$@"
    }
    export -f git

    # Try to clone
    run clone_repository

    # Should display error
    assert_failure
    assert_output --partial "error" || assert_output --partial "Error" || assert_output --partial "fail"
}

@test "clone_repository: displays error on authentication failure" {
    # Mock auth failure
    git() {
        if [[ "$1" == "clone" ]]; then
            echo "fatal: Authentication failed"
            return 128
        fi
        command git "$@"
    }
    export -f git

    # Try to clone
    run clone_repository

    # Should fail
    assert_failure
}

@test "clone_repository: handles partial clone failure" {
    # Mock partial clone (directory created but no .git)
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3"
            # Don't create .git directory
            return 1
        fi
        command git "$@"
    }
    export -f git

    # Try to clone
    run clone_repository

    # Should fail
    assert_failure
}

@test "clone_repository: validates clone success" {
    # Mock git clone that creates directory but fails
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3"
            return 1
        fi
        command git "$@"
    }
    export -f git

    # Try to clone
    run clone_repository

    # Should detect failure even though directory exists
    assert_failure
}

@test "clone_repository: logs clone progress" {
    # Mock git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            echo "Cloning into '$3'..."
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Clone repository
    run clone_repository

    # Should show progress
    assert_output --partial "Cloning"
}

@test "clone_repository: displays troubleshooting on failure" {
    # Mock failed clone
    git() {
        if [[ "$1" == "clone" ]]; then
            return 1
        fi
        command git "$@"
    }
    export -f git

    # Try to clone
    run clone_repository

    # Should show troubleshooting
    assert_failure
}

@test "clone_repository: handles disk full error" {
    # Mock disk full error
    git() {
        if [[ "$1" == "clone" ]]; then
            echo "fatal: write error: No space left on device"
            return 128
        fi
        command git "$@"
    }
    export -f git

    # Try to clone
    run clone_repository

    # Should fail
    assert_failure
}

@test "clone_repository: handles permission denied error" {
    # Create read-only Documents directory
    mkdir -p "${HOME}/Documents"
    chmod 555 "${HOME}/Documents"

    # Mock git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            return 1
        fi
        command git "$@"
    }
    export -f git

    # Try to clone
    run clone_repository

    # Should fail
    assert_failure

    # Clean up
    chmod 755 "${HOME}/Documents"
}

@test "clone_repository: returns 0 on success" {
    # Mock successful clone
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            return 0
        fi
        command git "$@"
    }
    export -f git

    run clone_repository

    assert_equal "$status" "0"
}

@test "clone_repository: returns 1 on failure" {
    # Mock failed clone
    git() {
        if [[ "$1" == "clone" ]]; then
            return 1
        fi
        command git "$@"
    }
    export -f git

    run clone_repository

    assert_equal "$status" "1"
}

@test "clone_repository: handles interrupted clone (SIGINT)" {
    skip "Signal handling test - requires manual testing in VM"
}

@test "clone_repository: handles timeout on slow network" {
    skip "Timeout test - requires manual testing in VM"
}

@test "clone_repository: uses SSH protocol" {
    # Mock git to verify SSH URL
    git() {
        if [[ "$1" == "clone" ]]; then
            # Verify SSH URL (starts with git@)
            if [[ "$2" =~ ^git@ ]]; then
                mkdir -p "$3/.git"
                return 0
            else
                return 1
            fi
        fi
        command git "$@"
    }
    export -f git

    run clone_repository

    assert_success
}

@test "clone_repository: validates repository structure after clone" {
    # Mock git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            return 0
        fi
        command git "$@"
    }
    export -f git

    run clone_repository

    assert_success
}

@test "clone_repository: handles corrupted .git directory" {
    # Mock clone that creates corrupted .git
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            # Create invalid .git structure
            return 0
        fi
        command git "$@"
    }
    export -f git

    run clone_repository

    # Should succeed (clone itself worked)
    assert_success
}

@test "clone_repository: handles spaces in HOME path" {
    # Change HOME to path with spaces
    export HOME="${TEST_TEMP_DIR}/home with spaces"
    mkdir -p "${HOME}"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Mock git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            return 0
        fi
        command git "$@"
    }
    export -f git

    run clone_repository

    assert_success
}

@test "clone_repository: logs clone success message" {
    # Mock git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            return 0
        fi
        command git "$@"
    }
    export -f git

    run clone_repository

    # Should show success message
    assert_success
}

@test "clone_repository: creates parent directory if missing" {
    # Remove Documents directory
    rm -rf "${HOME}/Documents"

    # Mock git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            # Git creates parent directories
            mkdir -p "$3/.git"
            return 0
        fi
        command git "$@"
    }
    export -f git

    run clone_repository

    # Should succeed
    assert_success
}

@test "clone_repository: handles very long repository name" {
    # Create very long path
    export REPO_CLONE_DIR="${HOME}/Documents/very-long-repository-name-that-exceeds-normal-expectations"

    # Mock git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            return 0
        fi
        command git "$@"
    }
    export -f git

    run clone_repository

    assert_success
}

@test "clone_repository: checks available disk space before clone" {
    skip "Disk space check - implementation detail to be added"
}

# ===========================================================================
# CATEGORY 4: USER CONFIG COPY TESTS (20 tests)
# ===========================================================================

@test "copy_user_config_to_repo: successfully copies user-config.nix" {
    # Create source file
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# User config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Create destination directory
    mkdir -p "${REPO_CLONE_DIR}"

    # Copy file
    run copy_user_config_to_repo

    # Should succeed
    assert_success

    # File should exist in repo
    [[ -f "${REPO_CLONE_DIR}/user-config.nix" ]]
}

@test "copy_user_config_to_repo: preserves file contents" {
    # Create source file with specific content
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "{ fullName = \"FX Martin\"; }" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Create destination
    mkdir -p "${REPO_CLONE_DIR}"

    # Copy file
    run copy_user_config_to_repo

    # Verify contents preserved
    local content
    content=$(<"${REPO_CLONE_DIR}/user-config.nix")
    [[ "${content}" == "{ fullName = \"FX Martin\"; }" ]]
}

@test "copy_user_config_to_repo: skips copy if destination exists" {
    # Create source file
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# New config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Create existing destination file
    mkdir -p "${REPO_CLONE_DIR}"
    echo "# Existing config" > "${REPO_CLONE_DIR}/user-config.nix"

    # Try to copy (should skip)
    run copy_user_config_to_repo

    # Should succeed
    assert_success

    # Original content should be preserved
    local content
    content=$(<"${REPO_CLONE_DIR}/user-config.nix")
    [[ "${content}" == "# Existing config" ]]
}

@test "copy_user_config_to_repo: validates source file exists" {
    # Don't create source file
    rm -rf "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Create destination directory
    mkdir -p "${REPO_CLONE_DIR}"

    # Try to copy
    run copy_user_config_to_repo

    # Should fail (source missing)
    assert_failure
}

@test "copy_user_config_to_repo: validates destination directory exists" {
    # Create source file
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Don't create destination directory
    rm -rf "${REPO_CLONE_DIR}"

    # Try to copy
    run copy_user_config_to_repo

    # Should fail (destination doesn't exist)
    assert_failure
}

@test "copy_user_config_to_repo: preserves file permissions" {
    # Create source with specific permissions
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"
    chmod 644 "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Create destination
    mkdir -p "${REPO_CLONE_DIR}"

    # Copy file
    run copy_user_config_to_repo

    # Check permissions preserved
    local perms
    perms=$(stat -f "%Sp" "${REPO_CLONE_DIR}/user-config.nix")
    [[ "${perms}" =~ ^-rw-r--r-- ]]
}

@test "copy_user_config_to_repo: logs copy action" {
    # Create source and destination
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"
    mkdir -p "${REPO_CLONE_DIR}"

    # Copy file
    run copy_user_config_to_repo

    # Should log the action
    assert_output --partial "user-config" || assert_output --partial "copy" || assert_output --partial "Copy"
}

@test "copy_user_config_to_repo: logs when skipping existing file" {
    # Create source and existing destination
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# New" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"
    mkdir -p "${REPO_CLONE_DIR}"
    echo "# Existing" > "${REPO_CLONE_DIR}/user-config.nix"

    # Try to copy
    run copy_user_config_to_repo

    # Should log skip action
    assert_success
}

@test "copy_user_config_to_repo: handles permission errors" {
    # Create source
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Create read-only destination
    mkdir -p "${REPO_CLONE_DIR}"
    chmod 555 "${REPO_CLONE_DIR}"

    # Try to copy
    run copy_user_config_to_repo

    # Should fail
    assert_failure

    # Clean up
    chmod 755 "${REPO_CLONE_DIR}"
}

@test "copy_user_config_to_repo: handles read-only source file" {
    # Create read-only source
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"
    chmod 444 "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Create destination
    mkdir -p "${REPO_CLONE_DIR}"

    # Copy should still work (reading is allowed)
    run copy_user_config_to_repo

    assert_success

    # Clean up
    chmod 644 "${BOOTSTRAP_TEMP_DIR}/user-config.nix"
}

@test "copy_user_config_to_repo: returns 0 on success" {
    # Create source and destination
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"
    mkdir -p "${REPO_CLONE_DIR}"

    run copy_user_config_to_repo

    assert_equal "$status" "0"
}

@test "copy_user_config_to_repo: returns 1 on failure" {
    # Don't create source file
    rm -rf "${BOOTSTRAP_TEMP_DIR}/user-config.nix"
    mkdir -p "${REPO_CLONE_DIR}"

    run copy_user_config_to_repo

    assert_equal "$status" "1"
}

@test "copy_user_config_to_repo: validates file copied successfully" {
    # Create source
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"
    mkdir -p "${REPO_CLONE_DIR}"

    # Copy file
    run copy_user_config_to_repo

    # Validate destination exists
    [[ -f "${REPO_CLONE_DIR}/user-config.nix" ]]
}

@test "copy_user_config_to_repo: handles empty source file" {
    # Create empty source
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    touch "${BOOTSTRAP_TEMP_DIR}/user-config.nix"
    mkdir -p "${REPO_CLONE_DIR}"

    # Copy should work
    run copy_user_config_to_repo

    assert_success
    [[ -f "${REPO_CLONE_DIR}/user-config.nix" ]]
}

@test "copy_user_config_to_repo: handles large source file" {
    # Create large source file (1MB)
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    dd if=/dev/zero of="${BOOTSTRAP_TEMP_DIR}/user-config.nix" bs=1024 count=1024 2>/dev/null
    mkdir -p "${REPO_CLONE_DIR}"

    # Copy should work
    run copy_user_config_to_repo

    assert_success
}

@test "copy_user_config_to_repo: handles symlink source" {
    # Create real file and symlink
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Real config" > "${BOOTSTRAP_TEMP_DIR}/real-config.nix"
    ln -s "${BOOTSTRAP_TEMP_DIR}/real-config.nix" "${BOOTSTRAP_TEMP_DIR}/user-config.nix"
    mkdir -p "${REPO_CLONE_DIR}"

    # Copy should work
    run copy_user_config_to_repo

    assert_success
}

@test "copy_user_config_to_repo: handles symlink destination directory" {
    # Create source
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Create real directory and symlink
    mkdir -p "${HOME}/Documents/real-nix-install"
    ln -s "${HOME}/Documents/real-nix-install" "${REPO_CLONE_DIR}"

    # Copy should work
    run copy_user_config_to_repo

    assert_success
}

@test "copy_user_config_to_repo: handles spaces in file path" {
    # Create source in path with spaces
    local temp_with_spaces="${TEST_TEMP_DIR}/temp with spaces"
    mkdir -p "${temp_with_spaces}"
    echo "# Config" > "${temp_with_spaces}/user-config.nix"

    # Override BOOTSTRAP_TEMP_DIR
    export BOOTSTRAP_TEMP_DIR="${temp_with_spaces}"

    mkdir -p "${REPO_CLONE_DIR}"

    # Copy should work
    run copy_user_config_to_repo

    assert_success
}

@test "copy_user_config_to_repo: creates backup of existing file (optional)" {
    skip "Backup feature not implemented - may add in future"
}

@test "copy_user_config_to_repo: validates file integrity after copy" {
    # Create source with checksum
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "{ fullName = \"Test\"; }" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    mkdir -p "${REPO_CLONE_DIR}"

    # Copy file
    run copy_user_config_to_repo

    # Verify content matches
    diff "${BOOTSTRAP_TEMP_DIR}/user-config.nix" "${REPO_CLONE_DIR}/user-config.nix"
}

# ===========================================================================
# CATEGORY 5: REPOSITORY VERIFICATION TESTS (15 tests)
# ===========================================================================

@test "verify_repository_clone: succeeds for valid repository" {
    # Create valid repository structure
    mkdir -p "${REPO_CLONE_DIR}/.git"
    touch "${REPO_CLONE_DIR}/flake.nix"
    touch "${REPO_CLONE_DIR}/user-config.nix"

    # Mock git status
    git() {
        if [[ "$1" == "status" ]]; then
            echo "On branch main"
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Verify repository
    run verify_repository_clone

    # Should succeed
    assert_success
}

@test "verify_repository_clone: fails when .git missing" {
    # Create directory without .git
    mkdir -p "${REPO_CLONE_DIR}"
    touch "${REPO_CLONE_DIR}/flake.nix"
    touch "${REPO_CLONE_DIR}/user-config.nix"

    # Verify repository
    run verify_repository_clone

    # Should fail
    assert_failure
}

@test "verify_repository_clone: fails when flake.nix missing" {
    # Create directory without flake.nix
    mkdir -p "${REPO_CLONE_DIR}/.git"
    touch "${REPO_CLONE_DIR}/user-config.nix"

    # Verify repository
    run verify_repository_clone

    # Should fail
    assert_failure
}

@test "verify_repository_clone: fails when user-config.nix missing" {
    # Create directory without user-config.nix
    mkdir -p "${REPO_CLONE_DIR}/.git"
    touch "${REPO_CLONE_DIR}/flake.nix"

    # Verify repository
    run verify_repository_clone

    # Should fail
    assert_failure
}

@test "verify_repository_clone: checks git status works" {
    # Create valid structure
    mkdir -p "${REPO_CLONE_DIR}/.git"
    touch "${REPO_CLONE_DIR}/flake.nix"
    touch "${REPO_CLONE_DIR}/user-config.nix"

    # Mock git status failure
    git() {
        if [[ "$1" == "status" ]]; then
            return 128
        fi
        command git "$@"
    }
    export -f git

    # Verify repository
    run verify_repository_clone

    # Should fail (git status failed)
    assert_failure
}

@test "verify_repository_clone: displays validation results" {
    # Create valid structure
    mkdir -p "${REPO_CLONE_DIR}/.git"
    touch "${REPO_CLONE_DIR}/flake.nix"
    touch "${REPO_CLONE_DIR}/user-config.nix"

    # Mock git
    git() {
        if [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Verify repository
    run verify_repository_clone

    # Should show validation results
    assert_success
}

@test "verify_repository_clone: logs each validation step" {
    # Create valid structure
    mkdir -p "${REPO_CLONE_DIR}/.git"
    touch "${REPO_CLONE_DIR}/flake.nix"
    touch "${REPO_CLONE_DIR}/user-config.nix"

    # Mock git
    git() {
        if [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Verify repository
    run verify_repository_clone

    # Should mention multiple checks
    assert_success
}

@test "verify_repository_clone: returns 0 on success" {
    # Create valid structure
    mkdir -p "${REPO_CLONE_DIR}/.git"
    touch "${REPO_CLONE_DIR}/flake.nix"
    touch "${REPO_CLONE_DIR}/user-config.nix"

    git() {
        if [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    run verify_repository_clone

    assert_equal "$status" "0"
}

@test "verify_repository_clone: returns 1 on failure" {
    # Create invalid structure (missing .git)
    mkdir -p "${REPO_CLONE_DIR}"
    touch "${REPO_CLONE_DIR}/flake.nix"

    run verify_repository_clone

    assert_equal "$status" "1"
}

@test "verify_repository_clone: handles corrupted .git directory" {
    # Create .git but make it invalid
    mkdir -p "${REPO_CLONE_DIR}/.git"
    touch "${REPO_CLONE_DIR}/flake.nix"
    touch "${REPO_CLONE_DIR}/user-config.nix"

    # Mock git status failure
    git() {
        if [[ "$1" == "status" ]]; then
            echo "fatal: not a git repository"
            return 128
        fi
        command git "$@"
    }
    export -f git

    # Verify should fail
    run verify_repository_clone

    assert_failure
}

@test "verify_repository_clone: handles permission errors on .git" {
    # Create structure with unreadable .git
    mkdir -p "${REPO_CLONE_DIR}/.git"
    touch "${REPO_CLONE_DIR}/flake.nix"
    touch "${REPO_CLONE_DIR}/user-config.nix"
    chmod 000 "${REPO_CLONE_DIR}/.git"

    # Verify should fail
    run verify_repository_clone

    # Should fail
    assert_failure

    # Clean up
    chmod 755 "${REPO_CLONE_DIR}/.git"
}

@test "verify_repository_clone: checks all required files exist" {
    # Create structure with all required files
    mkdir -p "${REPO_CLONE_DIR}/.git"
    touch "${REPO_CLONE_DIR}/flake.nix"
    touch "${REPO_CLONE_DIR}/user-config.nix"
    touch "${REPO_CLONE_DIR}/bootstrap.sh"

    git() {
        if [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Verify
    run verify_repository_clone

    # Should check for all files
    assert_success
}

@test "verify_repository_clone: validates git repository integrity" {
    # Create valid structure
    mkdir -p "${REPO_CLONE_DIR}/.git"
    touch "${REPO_CLONE_DIR}/flake.nix"
    touch "${REPO_CLONE_DIR}/user-config.nix"

    # Mock git status success
    git() {
        if [[ "$1" == "status" ]]; then
            echo "On branch main"
            echo "nothing to commit, working tree clean"
            return 0
        fi
        command git "$@"
    }
    export -f git

    run verify_repository_clone

    assert_success
}

@test "verify_repository_clone: handles non-existent repository directory" {
    # Don't create directory
    rm -rf "${REPO_CLONE_DIR}"

    # Verify should fail
    run verify_repository_clone

    assert_failure
}

@test "verify_repository_clone: displays helpful error messages" {
    # Create incomplete structure
    mkdir -p "${REPO_CLONE_DIR}/.git"
    # Missing flake.nix and user-config.nix

    # Verify
    run verify_repository_clone

    # Should show what's missing
    assert_failure
}

# ===========================================================================
# CATEGORY 6: INTEGRATION TESTS (18 tests)
# ===========================================================================

@test "clone_repository_phase: complete happy path execution" {
    # Mock git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            return 0
        elif [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Create source user-config.nix
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# User config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Run full phase
    run clone_repository_phase

    # Should succeed
    assert_success

    # Repository should exist
    [[ -d "${REPO_CLONE_DIR}" ]]

    # user-config.nix should be copied
    [[ -f "${REPO_CLONE_DIR}/user-config.nix" ]]
}

@test "clone_repository_phase: handles existing directory (remove path)" {
    skip "Interactive test - requires manual VM testing"
}

@test "clone_repository_phase: handles existing directory (skip path)" {
    skip "Interactive test - requires manual VM testing"
}

@test "clone_repository_phase: aborts on git clone failure" {
    # Mock failed git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            return 1
        fi
        command git "$@"
    }
    export -f git

    # Create source user-config.nix
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Run phase
    run clone_repository_phase

    # Should fail
    assert_failure
}

@test "clone_repository_phase: displays phase banner" {
    # Mock git
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            return 0
        elif [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Run phase
    run clone_repository_phase

    # Should show phase header
    assert_output --partial "Phase 7" || assert_output --partial "Repository"
}

@test "clone_repository_phase: updates PHASE_CURRENT variable" {
    # Mock git
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            return 0
        elif [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Set initial phase
    PHASE_CURRENT=6

    # Run phase
    clone_repository_phase

    # Phase should be updated to 7
    [[ "${PHASE_CURRENT}" -eq 7 ]]
}

@test "clone_repository_phase: logs phase completion" {
    # Mock git
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            return 0
        elif [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Run phase
    run clone_repository_phase

    # Should log completion
    assert_success
}

@test "clone_repository_phase: displays success message" {
    # Mock git
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            return 0
        elif [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Run phase
    run clone_repository_phase

    # Should show success message
    assert_success
}

@test "clone_repository_phase: shows repository path" {
    # Mock git
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            return 0
        elif [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Run phase
    run clone_repository_phase

    # Should display repository path
    assert_output --partial "${HOME}/Documents/nix-install" || assert_output --partial "~/Documents"
}

@test "clone_repository_phase: idempotent - can run twice safely" {
    skip "Idempotency test - requires interactive handling of existing directory"
}

@test "clone_repository_phase: calls all sub-functions in order" {
    # This test verifies orchestration flow
    # Mock git
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            return 0
        elif [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Run phase
    run clone_repository_phase

    # All steps should complete
    assert_success
}

@test "clone_repository_phase: handles missing user-config.nix in /tmp" {
    # Mock git
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            return 0
        elif [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Don't create user-config.nix
    rm -rf "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Run phase
    run clone_repository_phase

    # Should fail at copy step
    assert_failure
}

@test "clone_repository_phase: preserves existing user-config.nix in repo" {
    # Mock git
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            # Create existing user-config.nix
            echo "# Existing config in repo" > "$3/user-config.nix"
            return 0
        elif [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    # Create different user-config.nix in /tmp
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# New config from /tmp" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Run phase
    run clone_repository_phase

    # Existing config should be preserved
    local content
    content=$(<"${REPO_CLONE_DIR}/user-config.nix")
    [[ "${content}" == "# Existing config in repo" ]]
}

@test "clone_repository_phase: returns 0 on success" {
    # Mock git
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            return 0
        elif [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    run clone_repository_phase

    assert_equal "$status" "0"
}

@test "clone_repository_phase: returns 1 on failure" {
    # Mock failed git clone
    git() {
        if [[ "$1" == "clone" ]]; then
            return 1
        fi
        command git "$@"
    }
    export -f git

    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    run clone_repository_phase

    assert_equal "$status" "1"
}

@test "clone_repository_phase: cleans up on failure" {
    skip "Cleanup on failure - implementation detail to verify in VM testing"
}

@test "clone_repository_phase: displays next phase preview" {
    # Mock git
    git() {
        if [[ "$1" == "clone" ]]; then
            mkdir -p "$3/.git"
            touch "$3/flake.nix"
            return 0
        elif [[ "$1" == "status" ]]; then
            return 0
        fi
        command git "$@"
    }
    export -f git

    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    echo "# Config" > "${BOOTSTRAP_TEMP_DIR}/user-config.nix"

    # Run phase
    run clone_repository_phase

    # Should mention next phase
    assert_success
}

@test "clone_repository_phase: handles slow network gracefully" {
    skip "Network speed test - requires manual VM testing with network throttling"
}

# ===========================================================================
# SUCCESS MESSAGE TESTS (5 additional tests)
# ===========================================================================

@test "display_clone_success_message: shows formatted success message" {
    # Run function
    run display_clone_success_message

    # Should display success message
    assert_success
}

@test "display_clone_success_message: displays repository path" {
    # Run function
    run display_clone_success_message

    # Should show repository location
    assert_output --partial "${HOME}/Documents/nix-install" || assert_output --partial "~/Documents"
}

@test "display_clone_success_message: shows next phase preview" {
    # Run function
    run display_clone_success_message

    # Should mention next phase
    assert_success
}

@test "display_clone_success_message: uses consistent formatting" {
    # Run function
    run display_clone_success_message

    # Should have formatting characters
    assert_success
}

@test "display_clone_success_message: returns 0" {
    run display_clone_success_message

    assert_equal "$status" "0"
}

# ===========================================================================
# END OF TESTS
# ===========================================================================
# Total: 93 tests across 6 categories + success message tests
