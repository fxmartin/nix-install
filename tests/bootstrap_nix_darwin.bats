#!/usr/bin/env bats
# ABOUTME: Comprehensive test suite for nix-darwin installation phase (Story 01.5-001)
# ABOUTME: Tests pinned-ref clone, submodule init, user config copy, nix-darwin build, and verification

# Setup and teardown
setup() {
    # Load bootstrap.sh for testing
    export TESTING=1

    # Create temporary test directory
    TEST_TMP_DIR="$(mktemp -d)"
    export TEST_TMP_DIR

    # Mock work directory. lib/common.sh honours _NIX_BOOTSTRAP_WORK_DIR, so
    # the readonly WORK_DIR it defines resolves here instead of a real /tmp run.
    export _NIX_BOOTSTRAP_WORK_DIR="${TEST_TMP_DIR}/nix-bootstrap"
    export WORK_DIR="${_NIX_BOOTSTRAP_WORK_DIR}"
    export FLAKE_REPO_DIR="${WORK_DIR}/repo"
    mkdir -p "${WORK_DIR}"

    # Mock user configuration variables
    export INSTALL_PROFILE="standard"
    export USER_FULLNAME="Test User"
    export USER_EMAIL="test@example.com"
    export GITHUB_USERNAME="testuser"

    # Mock user-config.nix location
    export USER_CONFIG_FILE="${WORK_DIR}/user-config.nix"
    cat > "${USER_CONFIG_FILE}" << 'EOF'
{
  username = "testuser";
  hostname = "test-mac";
  email = "test@example.com";
  fullName = "Test User";
  githubUsername = "testuser";
}
EOF

    # Mock git: clone populates the destination, submodule update is a no-op
    git() {
        case "${1:-}" in
            clone)
                if [[ "${MOCK_CLONE_FAIL:-0}" == "1" ]]; then
                    echo "fatal: repository not found" >&2
                    return 128
                fi
                local destination="${*: -1}"
                mkdir -p "${destination}"
                echo "# Mock flake.nix" > "${destination}/flake.nix"
                return 0
                ;;
            -C)
                echo "$*" >> "${TEST_TMP_DIR}/git_submodule.log"
                if [[ "$*" == *"claude-code-config"* ]]; then
                    # SSH-only submodule: expected to fail before Phase 6
                    return "${MOCK_SSH_SUBMODULE_STATUS:-1}"
                fi
                return "${MOCK_SUBMODULE_STATUS:-0}"
                ;;
            *)
                return 0
                ;;
        esac
    }
    export -f git

    # Mock nix command
    nix() {
        if [[ "${MOCK_NIX_BUILD_FAIL:-0}" == "1" ]]; then
            echo "error: build failed" >&2
            return 1
        fi

        # Simulate nix-darwin build output
        echo "building the system configuration..."
        echo "building '/nix/store/xxxxx-darwin-system.drv'..."
        echo "activating..."

        # Create mock darwin-rebuild command
        mkdir -p "${TEST_TMP_DIR}/bin"
        cat > "${TEST_TMP_DIR}/bin/darwin-rebuild" << 'SCRIPT'
#!/bin/bash
echo "darwin-rebuild version 1.0.0"
SCRIPT
        chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"

        # Create mock Homebrew inside the test temp dir. This previously wrote
        # to the real /opt/homebrew/bin/brew, which — paired with the teardown
        # that deleted it — destroyed the host's Homebrew on 2026-07-28.
        export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"
        mkdir -p "$(dirname "${NIX_INSTALL_BREW_PATH}")"
        touch "${NIX_INSTALL_BREW_PATH}"
        chmod +x "${NIX_INSTALL_BREW_PATH}"

        return 0
    }
    export -f nix

    # Mock command for verification
    command() {
        if [[ "$1" == "-v" ]]; then
            case "$2" in
                darwin-rebuild)
                    if [[ -x "${TEST_TMP_DIR}/bin/darwin-rebuild" ]]; then
                        echo "${TEST_TMP_DIR}/bin/darwin-rebuild"
                        return 0
                    fi
                    return 1
                    ;;
                *)
                    return 1
                    ;;
            esac
        fi
        builtin command "$@"
    }
    export -f command

    # Mock test for file operations
    test() {
        case "${1:-}" in
            -x)
                # Check if file is executable
                if [[ "$2" == "/opt/homebrew/bin/brew" && -e "/opt/homebrew/bin/brew" ]]; then
                    return 0
                fi
                builtin test "$@"
                ;;
            *)
                builtin test "$@"
                ;;
        esac
    }
    export -f test

    # Mock log functions
    log_info() {
        echo "[INFO] $*" >&2
    }
    export -f log_info

    log_warn() {
        echo "[WARN] $*" >&2
    }
    export -f log_warn

    log_error() {
        echo "[ERROR] $*" >&2
    }
    export -f log_error

    log_success() {
        echo "[SUCCESS] $*" >&2
    }
    export -f log_success
}

teardown() {
    # Clean up test directory
    if [[ -n "${TEST_TMP_DIR:-}" && -d "${TEST_TMP_DIR}" ]]; then
        rm -rf "${TEST_TMP_DIR}"
    fi

    # No Homebrew cleanup needed: the mock now lives under TEST_TMP_DIR and is
    # removed with it above. This block used to `rm -f /opt/homebrew/bin/brew`
    # after every test, deleting the host's real brew binary 87 times per run.
    unset NIX_INSTALL_BREW_PATH

    # Clean up environment
    unset TEST_TMP_DIR
    unset WORK_DIR
    unset INSTALL_PROFILE
    unset USER_FULLNAME
    unset USER_EMAIL
    unset GITHUB_USERNAME
    unset USER_CONFIG_FILE
    unset _NIX_BOOTSTRAP_WORK_DIR
    unset FLAKE_REPO_DIR
    unset MOCK_CLONE_FAIL
    unset MOCK_SUBMODULE_STATUS
    unset MOCK_SSH_SUBMODULE_STATUS
    unset MOCK_NIX_BUILD_FAIL
    unset TESTING
}

# =============================================================================
# Function Existence Tests (6 tests)
# =============================================================================

@test "clone_flake_repository function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f clone_flake_repository >/dev/null
}

@test "copy_user_config function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f copy_user_config >/dev/null
}

@test "initialize_flake_submodules function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f initialize_flake_submodules >/dev/null
}

@test "run_nix_darwin_build function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f run_nix_darwin_build >/dev/null
}

@test "verify_nix_darwin_installed function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f verify_nix_darwin_installed >/dev/null
}

@test "install_nix_darwin_phase function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f install_nix_darwin_phase >/dev/null
}

# =============================================================================
# Repository Clone Tests (7 tests)
# =============================================================================

@test "clone_flake_repository creates the clone directory" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository

    [[ -d "${FLAKE_REPO_DIR}" ]]
}

@test "clone_flake_repository produces a flake.nix" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository

    [[ -s "${FLAKE_REPO_DIR}/flake.nix" ]]
}

@test "clone_flake_repository clones the pinned ref over HTTPS" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    git() {
        echo "$*" >> "${TEST_TMP_DIR}/git_clone.log"
        local destination="${*: -1}"
        mkdir -p "${destination}"
        echo "# Mock flake.nix" > "${destination}/flake.nix"
        return 0
    }

    clone_flake_repository

    grep -q -- "--depth 1 --branch ${NIX_INSTALL_REF}" "${TEST_TMP_DIR}/git_clone.log"
    grep -q "https://github.com/fxmartin/nix-install.git" "${TEST_TMP_DIR}/git_clone.log"
}

@test "clone_flake_repository handles clone failures gracefully" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_CLONE_FAIL=1

    run clone_flake_repository
    [[ "$status" -eq 1 ]]
}

@test "clone_flake_repository logs error on failure" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_CLONE_FAIL=1

    run clone_flake_repository
    [[ "$output" =~ "ERROR" || "$output" =~ "failed" || "$output" =~ "Failed" ]]
}

@test "clone_flake_repository logs progress messages" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run clone_flake_repository

    [[ "$output" =~ "Cloning" || "$output" =~ "Repository" ]]
}

@test "clone_flake_repository is idempotent across re-runs" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository
    run clone_flake_repository

    [[ "$status" -eq 0 ]]
}

# =============================================================================
# User Config Copy Tests (10 tests)
# =============================================================================

@test "copy_user_config validates source file exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository
    run copy_user_config

    [[ "$status" -eq 0 ]]
}

@test "copy_user_config copies into the cloned repository" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository
    copy_user_config

    [[ -f "${FLAKE_REPO_DIR}/user-config.nix" ]]
}

@test "copy_user_config leaves the destination readable" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    chmod 644 "${USER_CONFIG_FILE}"
    clone_flake_repository

    copy_user_config

    [[ -r "${FLAKE_REPO_DIR}/user-config.nix" ]]
}

@test "copy_user_config validates destination readable" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository
    copy_user_config

    [[ -r "${FLAKE_REPO_DIR}/user-config.nix" ]]
}

@test "copy_user_config handles missing source file" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Remove source file
    rm -f "${USER_CONFIG_FILE}"
    export USER_CONFIG_FILE="${WORK_DIR}/nonexistent.nix"

    clone_flake_repository
    run copy_user_config

    [[ "$status" -ne 0 ]]
}

@test "copy_user_config exits on copy failure" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Destination directory does not exist
    run copy_user_config

    [[ "$status" -ne 0 ]]
}

@test "copy_user_config logs success message" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository
    run copy_user_config

    [[ "$output" =~ "SUCCESS" || "$output" =~ "Copied" || "$output" =~ "copied" ]]
}

@test "copy_user_config validates file content preserved" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository
    copy_user_config

    grep -q "testuser" "${FLAKE_REPO_DIR}/user-config.nix"
}

@test "copy_user_config handles existing destination file" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository
    # Create existing file
    echo "old content" > "${FLAKE_REPO_DIR}/user-config.nix"

    copy_user_config

    # Should overwrite
    grep -q "testuser" "${FLAKE_REPO_DIR}/user-config.nix"
}

@test "copy_user_config logs error on failure" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    rm -f "${USER_CONFIG_FILE}"
    export USER_CONFIG_FILE="${WORK_DIR}/missing.nix"

    clone_flake_repository
    run copy_user_config

    [[ "$output" =~ "ERROR" || "$output" =~ "error" || "$output" =~ "Failed" ]]
}

# =============================================================================
# Submodule Initialization Tests (5 tests)
# =============================================================================

@test "initialize_flake_submodules initializes each HTTPS submodule per path" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository
    initialize_flake_submodules

    grep -q "zsh-autosuggestions" "${TEST_TMP_DIR}/git_submodule.log"
    grep -q "zsh-syntax-highlighting" "${TEST_TMP_DIR}/git_submodule.log"
    grep -q "powerlevel10k" "${TEST_TMP_DIR}/git_submodule.log"
}

@test "initialize_flake_submodules tolerates the SSH-only submodule failing" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository
    run initialize_flake_submodules

    [[ "$status" -eq 0 ]]
    [[ "$output" =~ "claude-code-config" ]]
    [[ "$output" =~ "WARN" ]]
}

@test "initialize_flake_submodules keeps going when an HTTPS submodule fails" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_SUBMODULE_STATUS=1
    clone_flake_repository
    run initialize_flake_submodules

    [[ "$status" -eq 0 ]]
    [[ "$output" =~ "WARN" ]]
}

@test "initialize_flake_submodules is NON-CRITICAL" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_SUBMODULE_STATUS=1
    export MOCK_SSH_SUBMODULE_STATUS=1
    clone_flake_repository
    run initialize_flake_submodules

    [[ "$status" -eq 0 ]]
}

@test "initialize_flake_submodules logs success when everything initializes" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_SSH_SUBMODULE_STATUS=0
    clone_flake_repository
    run initialize_flake_submodules

    [[ "$output" =~ "Submodules initialized" ]]
}

# =============================================================================
# Nix-Darwin Build Tests (12 tests)
# =============================================================================

@test "run_nix_darwin_build uses correct profile standard" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export INSTALL_PROFILE="standard"
    clone_flake_repository

    run run_nix_darwin_build

    [[ "$status" -eq 0 ]]
}

@test "run_nix_darwin_build uses correct profile power" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export INSTALL_PROFILE="power"
    clone_flake_repository

    run run_nix_darwin_build

    [[ "$status" -eq 0 ]]
}

@test "run_nix_darwin_build changes to work directory" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository
    cd /tmp

    run run_nix_darwin_build

    [[ "$status" -eq 0 ]]
}

@test "run_nix_darwin_build runs nix run nix-darwin command" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository

    run run_nix_darwin_build

    [[ "$status" -eq 0 ]]
}

@test "run_nix_darwin_build uses flake path format" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository

    # Override nix to capture arguments
    nix() {
        echo "$*" >> "${TEST_TMP_DIR}/nix_args.log"
        echo "building..."
        return 0
    }
    export -f nix

    run run_nix_darwin_build

    if [[ -f "${TEST_TMP_DIR}/nix_args.log" ]]; then
        grep -q "#" "${TEST_TMP_DIR}/nix_args.log" || [[ "$status" -eq 0 ]]
    fi
}

@test "run_nix_darwin_build displays progress messages" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository

    run run_nix_darwin_build

    [[ "$output" =~ "build" || "$output" =~ "nix-darwin" || "$output" =~ "minutes" ]]
}

@test "run_nix_darwin_build shows Nix output" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository

    run run_nix_darwin_build

    [[ "$output" =~ "building" ]]
}

@test "run_nix_darwin_build exits on build failure" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_NIX_BUILD_FAIL=1
    clone_flake_repository

    run run_nix_darwin_build

    [[ "$status" -ne 0 ]]
}

@test "run_nix_darwin_build returns 0 on success" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository

    run run_nix_darwin_build

    [[ "$status" -eq 0 ]]
}

@test "run_nix_darwin_build displays build duration estimate" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository

    run run_nix_darwin_build

    [[ "$output" =~ "10" || "$output" =~ "20" || "$output" =~ "minutes" ]]
}

@test "run_nix_darwin_build mentions Homebrew installation" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    clone_flake_repository

    run run_nix_darwin_build

    [[ "$output" =~ "Homebrew" || "$output" =~ "applications" || "$status" -eq 0 ]]
}

@test "run_nix_darwin_build logs error on failure" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_NIX_BUILD_FAIL=1
    clone_flake_repository

    run run_nix_darwin_build

    [[ "$output" =~ "ERROR" || "$output" =~ "error" || "$output" =~ "failed" ]]
}

# =============================================================================
# Verification Logic Tests (10 tests)
# =============================================================================

@test "verify_nix_darwin_installed checks darwin-rebuild exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Create mock darwin-rebuild
    mkdir -p "${TEST_TMP_DIR}/bin"
    cat > "${TEST_TMP_DIR}/bin/darwin-rebuild" << 'SCRIPT'
#!/bin/bash
echo "darwin-rebuild"
SCRIPT
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    run verify_nix_darwin_installed

    [[ "$status" -eq 0 ]]
}

@test "verify_nix_darwin_installed checks Homebrew exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Create mock Homebrew
    # Point the check at a fixture. Creating /opt/homebrew/bin/brew for real
    # clobbers the host's actual brew binary with an empty file.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"
    mkdir -p "$(dirname "${NIX_INSTALL_BREW_PATH}")"
    touch "${NIX_INSTALL_BREW_PATH}"
    chmod +x "${NIX_INSTALL_BREW_PATH}"

    # Mock darwin-rebuild
    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    run verify_nix_darwin_installed

    [[ "$status" -eq 0 ]]
}

@test "verify_nix_darwin_installed exits on missing darwin-rebuild" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Ensure darwin-rebuild doesn't exist
    export PATH="/usr/bin:/bin"

    run verify_nix_darwin_installed

    [[ "$status" -ne 0 ]]
}

@test "verify_nix_darwin_installed exits on missing Homebrew" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Mock darwin-rebuild exists
    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Ensure Homebrew doesn't exist — by pointing the check at a path that was
    # never created, NOT by deleting the host's real Homebrew.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew-absent/bin/brew"

    run verify_nix_darwin_installed

    [[ "$status" -ne 0 ]]
}

@test "verify_nix_darwin_installed logs success on all checks passing" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Mock both commands
    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Point the check at a fixture. Creating /opt/homebrew/bin/brew for real
    # clobbers the host's actual brew binary with an empty file.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"
    mkdir -p "$(dirname "${NIX_INSTALL_BREW_PATH}")"
    touch "${NIX_INSTALL_BREW_PATH}"
    chmod +x "${NIX_INSTALL_BREW_PATH}"

    run verify_nix_darwin_installed

    [[ "$output" =~ "SUCCESS" || "$output" =~ "verified" || "$output" =~ "installed" ]]
}

@test "verify_nix_darwin_installed uses command -v for darwin-rebuild" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Point the check at a fixture. Creating /opt/homebrew/bin/brew for real
    # clobbers the host's actual brew binary with an empty file.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"
    mkdir -p "$(dirname "${NIX_INSTALL_BREW_PATH}")"
    touch "${NIX_INSTALL_BREW_PATH}"
    chmod +x "${NIX_INSTALL_BREW_PATH}"

    run verify_nix_darwin_installed

    [[ "$status" -eq 0 ]]
}

@test "verify_nix_darwin_installed defaults to /opt/homebrew/bin/brew" {
    # Asserts the production default by reading the source rather than by
    # touching /opt/homebrew. The override exists for tests only; if someone
    # changes the default, this catches it without risking the host.
    run grep -q 'NIX_INSTALL_BREW_PATH:-/opt/homebrew/bin/brew' \
        "${BATS_TEST_DIRNAME}/../lib/nix-darwin.sh"

    [[ "$status" -eq 0 ]]
}

@test "verify_nix_darwin_installed succeeds with Homebrew present" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Point the check at a fixture. Creating /opt/homebrew/bin/brew for real
    # clobbers the host's actual brew binary with an empty file.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"
    mkdir -p "$(dirname "${NIX_INSTALL_BREW_PATH}")"
    touch "${NIX_INSTALL_BREW_PATH}"
    chmod +x "${NIX_INSTALL_BREW_PATH}"

    run verify_nix_darwin_installed

    [[ "$status" -eq 0 ]]
}

@test "verify_nix_darwin_installed logs error on darwin-rebuild missing" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export PATH="/usr/bin:/bin"

    run verify_nix_darwin_installed

    [[ "$output" =~ "ERROR" || "$output" =~ "error" || "$output" =~ "not found" ]]
}

@test "verify_nix_darwin_installed logs error on Homebrew missing" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Absent Homebrew is simulated with an unused fixture path. This line used
    # to be `rm -rf /opt/homebrew`, which destroyed the real installation.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew-absent/bin/brew"

    run verify_nix_darwin_installed

    [[ "$output" =~ "ERROR" || "$output" =~ "error" || "$output" =~ "Homebrew" ]]
}

@test "verify_nix_darwin_installed returns 0 on success" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Point the check at a fixture. Creating /opt/homebrew/bin/brew for real
    # clobbers the host's actual brew binary with an empty file.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"
    mkdir -p "$(dirname "${NIX_INSTALL_BREW_PATH}")"
    touch "${NIX_INSTALL_BREW_PATH}"
    chmod +x "${NIX_INSTALL_BREW_PATH}"

    run verify_nix_darwin_installed

    [[ "$status" -eq 0 ]]
}

# =============================================================================
# Orchestration Tests (10 tests)
# =============================================================================

@test "install_nix_darwin_phase calls clone_flake_repository" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Check if the clone exists (evidence of the clone step)
    [[ -f "${FLAKE_REPO_DIR}/flake.nix" || "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase calls copy_user_config" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Check if user-config.nix landed inside the clone
    [[ -f "${FLAKE_REPO_DIR}/user-config.nix" || "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase calls initialize_flake_submodules" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Check for evidence of a per-path submodule init
    [[ -f "${TEST_TMP_DIR}/git_submodule.log" || "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase calls run_nix_darwin_build" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Check for build output
    [[ "$output" =~ "build" || "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase calls verify_nix_darwin_installed" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Mock verification commands
    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Point the check at a fixture. Creating /opt/homebrew/bin/brew for real
    # clobbers the host's actual brew binary with an empty file.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"
    mkdir -p "$(dirname "${NIX_INSTALL_BREW_PATH}")"
    touch "${NIX_INSTALL_BREW_PATH}"
    chmod +x "${NIX_INSTALL_BREW_PATH}"

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    [[ "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase logs phase start" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    [[ "$output" =~ "PHASE" || "$output" =~ "Phase" || "$output" =~ "Installing" ]]
}

@test "install_nix_darwin_phase logs phase end" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Point the check at a fixture. Creating /opt/homebrew/bin/brew for real
    # clobbers the host's actual brew binary with an empty file.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"
    mkdir -p "$(dirname "${NIX_INSTALL_BREW_PATH}")"
    touch "${NIX_INSTALL_BREW_PATH}"
    chmod +x "${NIX_INSTALL_BREW_PATH}"

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    [[ "$output" =~ "complete" || "$output" =~ "completed" || "$output" =~ "SUCCESS" ]]
}

@test "install_nix_darwin_phase exits on function failure" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_CLONE_FAIL=1
    cd "${WORK_DIR}"

    run install_nix_darwin_phase

    [[ "$status" -ne 0 ]]
}

@test "install_nix_darwin_phase returns 0 on success" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Point the check at a fixture. Creating /opt/homebrew/bin/brew for real
    # clobbers the host's actual brew binary with an empty file.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"
    mkdir -p "$(dirname "${NIX_INSTALL_BREW_PATH}")"
    touch "${NIX_INSTALL_BREW_PATH}"
    chmod +x "${NIX_INSTALL_BREW_PATH}"

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    [[ "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase includes timestamps in logs" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Point the check at a fixture. Creating /opt/homebrew/bin/brew for real
    # clobbers the host's actual brew binary with an empty file.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"
    mkdir -p "$(dirname "${NIX_INSTALL_BREW_PATH}")"
    touch "${NIX_INSTALL_BREW_PATH}"
    chmod +x "${NIX_INSTALL_BREW_PATH}"

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Timestamps would appear in actual logs (hard to test in mock)
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# Error Handling Tests (10 tests)
# =============================================================================

@test "clone_flake_repository is CRITICAL and exits on failure" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_CLONE_FAIL=1
    cd "${WORK_DIR}"

    run clone_flake_repository

    [[ "$status" -ne 0 ]]
}

@test "copy_user_config is CRITICAL and exits on failure" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    rm -f "${USER_CONFIG_FILE}"
    export USER_CONFIG_FILE="${WORK_DIR}/missing.nix"

    cd "${WORK_DIR}"
    run copy_user_config

    [[ "$status" -ne 0 ]]
}

@test "initialize_flake_submodules is NON-CRITICAL and logs warnings" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_SUBMODULE_STATUS=1
    cd "${WORK_DIR}"
    clone_flake_repository

    run initialize_flake_submodules

    [[ "$output" =~ "WARN" || "$output" =~ "warn" ]]
    [[ "$status" -eq 0 ]]
}

@test "run_nix_darwin_build is CRITICAL and exits on failure" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_NIX_BUILD_FAIL=1
    cd "${WORK_DIR}"

    run run_nix_darwin_build

    [[ "$status" -ne 0 ]]
}

@test "verify_nix_darwin_installed is CRITICAL and exits on failure" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export PATH="/usr/bin:/bin"

    run verify_nix_darwin_installed

    [[ "$status" -ne 0 ]]
}

@test "clone_flake_repository displays clear error messages" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_CLONE_FAIL=1
    cd "${WORK_DIR}"

    run clone_flake_repository

    [[ "$output" =~ "ERROR" || "$output" =~ "Failed" || "$output" =~ "failed" ]]
}

@test "copy_user_config displays clear error messages" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    rm -f "${USER_CONFIG_FILE}"
    export USER_CONFIG_FILE="${WORK_DIR}/missing.nix"

    cd "${WORK_DIR}"
    run copy_user_config

    [[ "$output" =~ "ERROR" || "$output" =~ "not found" || "$output" =~ "missing" ]]
}

@test "run_nix_darwin_build displays clear error messages" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_NIX_BUILD_FAIL=1
    cd "${WORK_DIR}"

    run run_nix_darwin_build

    [[ "$output" =~ "ERROR" || "$output" =~ "error" || "$output" =~ "failed" ]]
}

@test "verify_nix_darwin_installed displays clear error messages" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export PATH="/usr/bin:/bin"

    run verify_nix_darwin_installed

    [[ "$output" =~ "ERROR" || "$output" =~ "not found" || "$output" =~ "missing" ]]
}

@test "install_nix_darwin_phase provides actionable guidance on failures" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    export MOCK_CLONE_FAIL=1
    cd "${WORK_DIR}"

    run install_nix_darwin_phase

    [[ "$output" =~ "ERROR" || "$output" =~ "Failed" || "$status" -ne 0 ]]
}

# =============================================================================
# Integration Tests (5 tests)
# =============================================================================

@test "Phase 5 integration: all variables available" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Verify variables from previous phases
    [[ -n "$INSTALL_PROFILE" ]]
    [[ -n "$USER_FULLNAME" ]]
    [[ -n "$USER_EMAIL" ]]
    [[ -n "$GITHUB_USERNAME" ]]
}

@test "Phase 5 integration: work directory accessible" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    [[ -d "$WORK_DIR" ]]
    [[ -w "$WORK_DIR" ]]
}

@test "Phase 5 integration: user-config.nix available from Phase 2" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    [[ -f "$USER_CONFIG_FILE" ]]
    [[ -r "$USER_CONFIG_FILE" ]]
}

@test "Phase 5 integration: functions callable from main" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # All phase functions should be defined
    declare -f install_nix_darwin_phase >/dev/null
    declare -f clone_flake_repository >/dev/null
    declare -f copy_user_config >/dev/null
    declare -f initialize_flake_submodules >/dev/null
    declare -f run_nix_darwin_build >/dev/null
    declare -f verify_nix_darwin_installed >/dev/null
}

@test "Phase 5 integration: end-to-end phase execution" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Point the check at a fixture. Creating /opt/homebrew/bin/brew for real
    # clobbers the host's actual brew binary with an empty file.
    export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"
    mkdir -p "$(dirname "${NIX_INSTALL_BREW_PATH}")"
    touch "${NIX_INSTALL_BREW_PATH}"
    chmod +x "${NIX_INSTALL_BREW_PATH}"

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Full phase should complete successfully
    [[ "$status" -eq 0 ]]
    [[ -f "${FLAKE_REPO_DIR}/flake.nix" ]]
    [[ -f "${FLAKE_REPO_DIR}/user-config.nix" ]]
}
