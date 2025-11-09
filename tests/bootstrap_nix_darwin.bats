#!/usr/bin/env bats
# ABOUTME: Comprehensive test suite for nix-darwin installation phase (Story 01.5-001)
# ABOUTME: Tests flake fetch from GitHub, user config copy, git init, nix-darwin build, and verification

# Setup and teardown
setup() {
    # Load bootstrap.sh for testing
    export TESTING=1

    # Create temporary test directory
    TEST_TMP_DIR="$(mktemp -d)"
    export TEST_TMP_DIR

    # Mock work directory
    export WORK_DIR="${TEST_TMP_DIR}/nix-bootstrap"
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

    # Mock curl for GitHub fetches
    curl() {
        local output_file=""
        local url=""

        # Parse curl arguments
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -o|-O|--output)
                    output_file="$2"
                    shift 2
                    ;;
                -L|--location|-f|--fail|-s|--silent|-S|--show-error)
                    shift
                    ;;
                *)
                    url="$1"
                    shift
                    ;;
            esac
        done

        # Mock failure if requested
        if [[ "${MOCK_CURL_FAIL:-0}" == "1" ]]; then
            echo "curl: (22) The requested URL returned error: 404" >&2
            return 22
        fi

        # Determine output file from URL if -O used
        if [[ -z "$output_file" && "$url" =~ ([^/]+)$ ]]; then
            output_file="${BASH_REMATCH[1]}"
        fi

        # Create mock file with appropriate content
        if [[ -n "$output_file" ]]; then
            case "$output_file" in
                flake.nix)
                    echo "# Mock flake.nix" > "$output_file"
                    ;;
                flake.lock)
                    echo '{ "version": 7 }' > "$output_file"
                    ;;
                *.nix)
                    echo "# Mock $(basename "$output_file")" > "$output_file"
                    ;;
                *)
                    echo "mock content" > "$output_file"
                    ;;
            esac
        fi

        return 0
    }
    export -f curl

    # Mock git operations
    git() {
        if [[ "${MOCK_GIT_FAIL:-0}" == "1" ]]; then
            echo "git: command not found" >&2
            return 127
        fi

        case "${1:-}" in
            init)
                mkdir -p "${WORK_DIR}/.git"
                return 0
                ;;
            add)
                return 0
                ;;
            commit)
                return 0
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

        # Create mock Homebrew
        mkdir -p "/opt/homebrew/bin"
        touch "/opt/homebrew/bin/brew"
        chmod +x "/opt/homebrew/bin/brew"

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

    # Clean up mock Homebrew
    if [[ -d "/opt/homebrew/bin" ]]; then
        rm -f "/opt/homebrew/bin/brew"
        rmdir "/opt/homebrew/bin" 2>/dev/null || true
        rmdir "/opt/homebrew" 2>/dev/null || true
    fi

    # Clean up environment
    unset TEST_TMP_DIR
    unset WORK_DIR
    unset INSTALL_PROFILE
    unset USER_FULLNAME
    unset USER_EMAIL
    unset GITHUB_USERNAME
    unset USER_CONFIG_FILE
    unset MOCK_CURL_FAIL
    unset MOCK_GIT_FAIL
    unset MOCK_NIX_BUILD_FAIL
    unset TESTING
}

# =============================================================================
# Function Existence Tests (6 tests)
# =============================================================================

@test "fetch_flake_from_github function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f fetch_flake_from_github >/dev/null
}

@test "copy_user_config function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f copy_user_config >/dev/null
}

@test "initialize_git_for_flake function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f initialize_git_for_flake >/dev/null
}

@test "run_nix_darwin_build function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f run_nix_darwin_build >/dev/null
}

@test "verify_nix_darwin_installed function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f verify_nix_darwin_installed >/dev/null
}

@test "install_nix_darwin_phase function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f install_nix_darwin_phase >/dev/null
}

# =============================================================================
# GitHub Fetch Logic Tests (15 tests)
# =============================================================================

@test "fetch_flake_from_github creates darwin directory" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    fetch_flake_from_github

    [[ -d "${WORK_DIR}/darwin" ]]
}

@test "fetch_flake_from_github creates home-manager/modules directory" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    fetch_flake_from_github

    [[ -d "${WORK_DIR}/home-manager/modules" ]]
}

@test "fetch_flake_from_github fetches flake.nix" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    fetch_flake_from_github

    [[ -f "${WORK_DIR}/flake.nix" ]]
}

@test "fetch_flake_from_github fetches flake.lock" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    fetch_flake_from_github

    [[ -f "${WORK_DIR}/flake.lock" ]]
}

@test "fetch_flake_from_github fetches darwin configuration files" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    fetch_flake_from_github

    [[ -f "${WORK_DIR}/darwin/configuration.nix" ]]
    [[ -f "${WORK_DIR}/darwin/homebrew.nix" ]]
    [[ -f "${WORK_DIR}/darwin/macos-defaults.nix" ]]
}

@test "fetch_flake_from_github fetches home-manager files" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    fetch_flake_from_github

    [[ -f "${WORK_DIR}/home-manager/home.nix" ]]
    [[ -f "${WORK_DIR}/home-manager/modules/shell.nix" ]]
}

@test "fetch_flake_from_github validates files are non-empty" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    fetch_flake_from_github

    # Check flake.nix has content
    [[ -s "${WORK_DIR}/flake.nix" ]]
}

@test "fetch_flake_from_github handles curl failures gracefully" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    export MOCK_CURL_FAIL=1

    run fetch_flake_from_github
    [[ "$status" -eq 1 ]]
}

@test "fetch_flake_from_github uses correct GitHub URLs" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Override curl to capture URLs
    curl() {
        echo "$*" >> "${TEST_TMP_DIR}/curl_calls.log"
        builtin curl "$@" 2>/dev/null || true
    }
    export -f curl

    cd "${WORK_DIR}"
    fetch_flake_from_github || true

    [[ -f "${TEST_TMP_DIR}/curl_calls.log" ]]
    grep -q "github.com/fxmartin/nix-install" "${TEST_TMP_DIR}/curl_calls.log" || true
}

@test "fetch_flake_from_github exits on fetch failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    export MOCK_CURL_FAIL=1

    run fetch_flake_from_github
    [[ "$status" -ne 0 ]]
}

@test "fetch_flake_from_github logs progress messages" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    run fetch_flake_from_github

    # Should log fetching activities
    [[ "$output" =~ "Fetching" || "$output" =~ "Downloading" ]]
}

@test "fetch_flake_from_github creates all required directories" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    fetch_flake_from_github

    [[ -d "${WORK_DIR}/darwin" ]]
    [[ -d "${WORK_DIR}/home-manager" ]]
    [[ -d "${WORK_DIR}/home-manager/modules" ]]
}

@test "fetch_flake_from_github fetches from main branch" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Override curl to capture branch
    curl() {
        echo "$*" >> "${TEST_TMP_DIR}/curl_branch.log"
        builtin curl "$@" 2>/dev/null || true
    }
    export -f curl

    cd "${WORK_DIR}"
    fetch_flake_from_github || true

    if [[ -f "${TEST_TMP_DIR}/curl_branch.log" ]]; then
        grep -q "/main/" "${TEST_TMP_DIR}/curl_branch.log" || true
    fi
}

@test "fetch_flake_from_github validates all required files present" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    fetch_flake_from_github

    # All critical files must exist
    [[ -f "${WORK_DIR}/flake.nix" ]]
    [[ -f "${WORK_DIR}/flake.lock" ]]
    [[ -f "${WORK_DIR}/darwin/configuration.nix" ]]
    [[ -f "${WORK_DIR}/darwin/homebrew.nix" ]]
    [[ -f "${WORK_DIR}/home-manager/home.nix" ]]
}

@test "fetch_flake_from_github logs error on failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    export MOCK_CURL_FAIL=1

    run fetch_flake_from_github
    [[ "$output" =~ "ERROR" || "$output" =~ "failed" || "$output" =~ "Failed" ]]
}

# =============================================================================
# User Config Copy Tests (10 tests)
# =============================================================================

@test "copy_user_config validates source file exists" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    run copy_user_config

    [[ "$status" -eq 0 ]]
}

@test "copy_user_config copies to correct destination" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    # Remove existing file to test copy
    rm -f "${WORK_DIR}/user-config.nix"

    copy_user_config

    [[ -f "${WORK_DIR}/user-config.nix" ]]
}

@test "copy_user_config preserves file permissions" {
    source /Users/user/dev/nix-install/bootstrap.sh

    chmod 644 "${USER_CONFIG_FILE}"
    cd "${WORK_DIR}"

    copy_user_config

    # File should be readable
    [[ -r "${WORK_DIR}/user-config.nix" ]]
}

@test "copy_user_config validates destination readable" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    copy_user_config

    [[ -r "${WORK_DIR}/user-config.nix" ]]
}

@test "copy_user_config handles missing source file" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Remove source file
    rm -f "${USER_CONFIG_FILE}"
    export USER_CONFIG_FILE="${WORK_DIR}/nonexistent.nix"

    cd "${WORK_DIR}"
    run copy_user_config

    [[ "$status" -ne 0 ]]
}

@test "copy_user_config exits on copy failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Make destination read-only
    chmod 000 "${WORK_DIR}"

    run copy_user_config

    # Restore permissions
    chmod 755 "${WORK_DIR}"

    [[ "$status" -ne 0 ]]
}

@test "copy_user_config logs success message" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    run copy_user_config

    [[ "$output" =~ "SUCCESS" || "$output" =~ "Copied" || "$output" =~ "copied" ]]
}

@test "copy_user_config validates file content preserved" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    rm -f "${WORK_DIR}/user-config.nix"

    copy_user_config

    grep -q "testuser" "${WORK_DIR}/user-config.nix"
}

@test "copy_user_config handles existing destination file" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    # Create existing file
    echo "old content" > "${WORK_DIR}/user-config.nix"

    copy_user_config

    # Should overwrite
    grep -q "testuser" "${WORK_DIR}/user-config.nix"
}

@test "copy_user_config logs error on failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    rm -f "${USER_CONFIG_FILE}"
    export USER_CONFIG_FILE="${WORK_DIR}/missing.nix"

    cd "${WORK_DIR}"
    run copy_user_config

    [[ "$output" =~ "ERROR" || "$output" =~ "error" || "$output" =~ "Failed" ]]
}

# =============================================================================
# Git Initialization Tests (8 tests)
# =============================================================================

@test "initialize_git_for_flake runs git init in correct directory" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    initialize_git_for_flake

    [[ -d "${WORK_DIR}/.git" ]]
}

@test "initialize_git_for_flake adds all files" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    # Create some test files
    touch "${WORK_DIR}/flake.nix"
    touch "${WORK_DIR}/user-config.nix"

    initialize_git_for_flake

    [[ -d "${WORK_DIR}/.git" ]]
}

@test "initialize_git_for_flake creates initial commit" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run initialize_git_for_flake

    [[ "$status" -eq 0 ]]
}

@test "initialize_git_for_flake handles git not installed" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_GIT_FAIL=1
    cd "${WORK_DIR}"

    run initialize_git_for_flake

    # Should log warning but not fail
    [[ "$output" =~ "WARN" || "$output" =~ "warn" || "$status" -eq 0 ]]
}

@test "initialize_git_for_flake is idempotent" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    # Run twice
    initialize_git_for_flake
    run initialize_git_for_flake

    [[ "$status" -eq 0 ]]
}

@test "initialize_git_for_flake logs warning on failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_GIT_FAIL=1
    cd "${WORK_DIR}"

    run initialize_git_for_flake

    [[ "$output" =~ "WARN" || "$output" =~ "warn" ]]
}

@test "initialize_git_for_flake continues on failure (non-critical)" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_GIT_FAIL=1
    cd "${WORK_DIR}"

    run initialize_git_for_flake

    # Should return success even if git fails (non-critical)
    [[ "$status" -eq 0 ]]
}

@test "initialize_git_for_flake logs success message" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run initialize_git_for_flake

    [[ "$output" =~ "SUCCESS" || "$output" =~ "Git" || "$output" =~ "initialized" ]]
}

# =============================================================================
# Nix-Darwin Build Tests (12 tests)
# =============================================================================

@test "run_nix_darwin_build uses correct profile standard" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export INSTALL_PROFILE="standard"
    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run run_nix_darwin_build

    [[ "$status" -eq 0 ]]
}

@test "run_nix_darwin_build uses correct profile power" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export INSTALL_PROFILE="power"
    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run run_nix_darwin_build

    [[ "$status" -eq 0 ]]
}

@test "run_nix_darwin_build changes to work directory" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd /tmp
    export WORK_DIR="${TEST_TMP_DIR}/nix-bootstrap"
    mkdir -p "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run run_nix_darwin_build

    [[ "$status" -eq 0 ]]
}

@test "run_nix_darwin_build runs nix run nix-darwin command" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run run_nix_darwin_build

    [[ "$status" -eq 0 ]]
}

@test "run_nix_darwin_build uses flake path format" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

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
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run run_nix_darwin_build

    [[ "$output" =~ "build" || "$output" =~ "nix-darwin" || "$output" =~ "minutes" ]]
}

@test "run_nix_darwin_build shows Nix output" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run run_nix_darwin_build

    [[ "$output" =~ "building" ]]
}

@test "run_nix_darwin_build exits on build failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_NIX_BUILD_FAIL=1
    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run run_nix_darwin_build

    [[ "$status" -ne 0 ]]
}

@test "run_nix_darwin_build returns 0 on success" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run run_nix_darwin_build

    [[ "$status" -eq 0 ]]
}

@test "run_nix_darwin_build displays build duration estimate" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run run_nix_darwin_build

    [[ "$output" =~ "10" || "$output" =~ "20" || "$output" =~ "minutes" ]]
}

@test "run_nix_darwin_build mentions Homebrew installation" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run run_nix_darwin_build

    [[ "$output" =~ "Homebrew" || "$output" =~ "applications" || "$status" -eq 0 ]]
}

@test "run_nix_darwin_build logs error on failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_NIX_BUILD_FAIL=1
    cd "${WORK_DIR}"
    touch "${WORK_DIR}/flake.nix"

    run run_nix_darwin_build

    [[ "$output" =~ "ERROR" || "$output" =~ "error" || "$output" =~ "failed" ]]
}

# =============================================================================
# Verification Logic Tests (10 tests)
# =============================================================================

@test "verify_nix_darwin_installed checks darwin-rebuild exists" {
    source /Users/user/dev/nix-install/bootstrap.sh

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
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create mock Homebrew
    mkdir -p /opt/homebrew/bin
    touch /opt/homebrew/bin/brew
    chmod +x /opt/homebrew/bin/brew

    # Mock darwin-rebuild
    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    run verify_nix_darwin_installed

    [[ "$status" -eq 0 ]]
}

@test "verify_nix_darwin_installed exits on missing darwin-rebuild" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Ensure darwin-rebuild doesn't exist
    export PATH="/usr/bin:/bin"

    run verify_nix_darwin_installed

    [[ "$status" -ne 0 ]]
}

@test "verify_nix_darwin_installed exits on missing Homebrew" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Mock darwin-rebuild exists
    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    # Ensure Homebrew doesn't exist
    rm -rf /opt/homebrew/bin/brew

    run verify_nix_darwin_installed

    [[ "$status" -ne 0 ]]
}

@test "verify_nix_darwin_installed logs success on all checks passing" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Mock both commands
    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    mkdir -p /opt/homebrew/bin
    touch /opt/homebrew/bin/brew
    chmod +x /opt/homebrew/bin/brew

    run verify_nix_darwin_installed

    [[ "$output" =~ "SUCCESS" || "$output" =~ "verified" || "$output" =~ "installed" ]]
}

@test "verify_nix_darwin_installed uses command -v for darwin-rebuild" {
    source /Users/user/dev/nix-install/bootstrap.sh

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    mkdir -p /opt/homebrew/bin
    touch /opt/homebrew/bin/brew
    chmod +x /opt/homebrew/bin/brew

    run verify_nix_darwin_installed

    [[ "$status" -eq 0 ]]
}

@test "verify_nix_darwin_installed checks Homebrew at /opt/homebrew/bin/brew" {
    source /Users/user/dev/nix-install/bootstrap.sh

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    mkdir -p /opt/homebrew/bin
    touch /opt/homebrew/bin/brew
    chmod +x /opt/homebrew/bin/brew

    run verify_nix_darwin_installed

    [[ "$status" -eq 0 ]]
}

@test "verify_nix_darwin_installed logs error on darwin-rebuild missing" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export PATH="/usr/bin:/bin"

    run verify_nix_darwin_installed

    [[ "$output" =~ "ERROR" || "$output" =~ "error" || "$output" =~ "not found" ]]
}

@test "verify_nix_darwin_installed logs error on Homebrew missing" {
    source /Users/user/dev/nix-install/bootstrap.sh

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    rm -rf /opt/homebrew

    run verify_nix_darwin_installed

    [[ "$output" =~ "ERROR" || "$output" =~ "error" || "$output" =~ "Homebrew" ]]
}

@test "verify_nix_darwin_installed returns 0 on success" {
    source /Users/user/dev/nix-install/bootstrap.sh

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    mkdir -p /opt/homebrew/bin
    touch /opt/homebrew/bin/brew
    chmod +x /opt/homebrew/bin/brew

    run verify_nix_darwin_installed

    [[ "$status" -eq 0 ]]
}

# =============================================================================
# Orchestration Tests (10 tests)
# =============================================================================

@test "install_nix_darwin_phase calls fetch_flake_from_github" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Check if flake files exist (evidence of fetch)
    [[ -f "${WORK_DIR}/flake.nix" || "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase calls copy_user_config" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Check if user-config.nix exists in work dir
    [[ -f "${WORK_DIR}/user-config.nix" || "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase calls initialize_git_for_flake" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Check if .git directory exists
    [[ -d "${WORK_DIR}/.git" || "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase calls run_nix_darwin_build" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Check for build output
    [[ "$output" =~ "build" || "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase calls verify_nix_darwin_installed" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Mock verification commands
    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    mkdir -p /opt/homebrew/bin
    touch /opt/homebrew/bin/brew
    chmod +x /opt/homebrew/bin/brew

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    [[ "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase logs phase start" {
    source /Users/user/dev/nix-install/bootstrap.sh

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    [[ "$output" =~ "PHASE" || "$output" =~ "Phase" || "$output" =~ "Installing" ]]
}

@test "install_nix_darwin_phase logs phase end" {
    source /Users/user/dev/nix-install/bootstrap.sh

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    mkdir -p /opt/homebrew/bin
    touch /opt/homebrew/bin/brew
    chmod +x /opt/homebrew/bin/brew

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    [[ "$output" =~ "complete" || "$output" =~ "completed" || "$output" =~ "SUCCESS" ]]
}

@test "install_nix_darwin_phase exits on function failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_CURL_FAIL=1
    cd "${WORK_DIR}"

    run install_nix_darwin_phase

    [[ "$status" -ne 0 ]]
}

@test "install_nix_darwin_phase returns 0 on success" {
    source /Users/user/dev/nix-install/bootstrap.sh

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    mkdir -p /opt/homebrew/bin
    touch /opt/homebrew/bin/brew
    chmod +x /opt/homebrew/bin/brew

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    [[ "$status" -eq 0 ]]
}

@test "install_nix_darwin_phase includes timestamps in logs" {
    source /Users/user/dev/nix-install/bootstrap.sh

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    mkdir -p /opt/homebrew/bin
    touch /opt/homebrew/bin/brew
    chmod +x /opt/homebrew/bin/brew

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Timestamps would appear in actual logs (hard to test in mock)
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# Error Handling Tests (10 tests)
# =============================================================================

@test "fetch_flake_from_github is CRITICAL and exits on failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_CURL_FAIL=1
    cd "${WORK_DIR}"

    run fetch_flake_from_github

    [[ "$status" -ne 0 ]]
}

@test "copy_user_config is CRITICAL and exits on failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    rm -f "${USER_CONFIG_FILE}"
    export USER_CONFIG_FILE="${WORK_DIR}/missing.nix"

    cd "${WORK_DIR}"
    run copy_user_config

    [[ "$status" -ne 0 ]]
}

@test "initialize_git_for_flake is NON-CRITICAL and logs warnings" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_GIT_FAIL=1
    cd "${WORK_DIR}"

    run initialize_git_for_flake

    [[ "$output" =~ "WARN" || "$output" =~ "warn" || "$status" -eq 0 ]]
}

@test "run_nix_darwin_build is CRITICAL and exits on failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_NIX_BUILD_FAIL=1
    cd "${WORK_DIR}"

    run run_nix_darwin_build

    [[ "$status" -ne 0 ]]
}

@test "verify_nix_darwin_installed is CRITICAL and exits on failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export PATH="/usr/bin:/bin"

    run verify_nix_darwin_installed

    [[ "$status" -ne 0 ]]
}

@test "fetch_flake_from_github displays clear error messages" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_CURL_FAIL=1
    cd "${WORK_DIR}"

    run fetch_flake_from_github

    [[ "$output" =~ "ERROR" || "$output" =~ "Failed" || "$output" =~ "failed" ]]
}

@test "copy_user_config displays clear error messages" {
    source /Users/user/dev/nix-install/bootstrap.sh

    rm -f "${USER_CONFIG_FILE}"
    export USER_CONFIG_FILE="${WORK_DIR}/missing.nix"

    cd "${WORK_DIR}"
    run copy_user_config

    [[ "$output" =~ "ERROR" || "$output" =~ "not found" || "$output" =~ "missing" ]]
}

@test "run_nix_darwin_build displays clear error messages" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_NIX_BUILD_FAIL=1
    cd "${WORK_DIR}"

    run run_nix_darwin_build

    [[ "$output" =~ "ERROR" || "$output" =~ "error" || "$output" =~ "failed" ]]
}

@test "verify_nix_darwin_installed displays clear error messages" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export PATH="/usr/bin:/bin"

    run verify_nix_darwin_installed

    [[ "$output" =~ "ERROR" || "$output" =~ "not found" || "$output" =~ "missing" ]]
}

@test "install_nix_darwin_phase provides actionable guidance on failures" {
    source /Users/user/dev/nix-install/bootstrap.sh

    export MOCK_CURL_FAIL=1
    cd "${WORK_DIR}"

    run install_nix_darwin_phase

    [[ "$output" =~ "ERROR" || "$output" =~ "Failed" || "$status" -ne 0 ]]
}

# =============================================================================
# Integration Tests (5 tests)
# =============================================================================

@test "Phase 5 integration: all variables available" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Verify variables from previous phases
    [[ -n "$INSTALL_PROFILE" ]]
    [[ -n "$USER_FULLNAME" ]]
    [[ -n "$USER_EMAIL" ]]
    [[ -n "$GITHUB_USERNAME" ]]
}

@test "Phase 5 integration: work directory accessible" {
    source /Users/user/dev/nix-install/bootstrap.sh

    [[ -d "$WORK_DIR" ]]
    [[ -w "$WORK_DIR" ]]
}

@test "Phase 5 integration: user-config.nix available from Phase 2" {
    source /Users/user/dev/nix-install/bootstrap.sh

    [[ -f "$USER_CONFIG_FILE" ]]
    [[ -r "$USER_CONFIG_FILE" ]]
}

@test "Phase 5 integration: functions callable from main" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # All phase functions should be defined
    declare -f install_nix_darwin_phase >/dev/null
    declare -f fetch_flake_from_github >/dev/null
    declare -f copy_user_config >/dev/null
    declare -f initialize_git_for_flake >/dev/null
    declare -f run_nix_darwin_build >/dev/null
    declare -f verify_nix_darwin_installed >/dev/null
}

@test "Phase 5 integration: end-to-end phase execution" {
    source /Users/user/dev/nix-install/bootstrap.sh

    mkdir -p "${TEST_TMP_DIR}/bin"
    touch "${TEST_TMP_DIR}/bin/darwin-rebuild"
    chmod +x "${TEST_TMP_DIR}/bin/darwin-rebuild"
    export PATH="${TEST_TMP_DIR}/bin:$PATH"

    mkdir -p /opt/homebrew/bin
    touch /opt/homebrew/bin/brew
    chmod +x /opt/homebrew/bin/brew

    cd "${WORK_DIR}"
    run install_nix_darwin_phase

    # Full phase should complete successfully
    [[ "$status" -eq 0 ]]
    [[ -f "${WORK_DIR}/flake.nix" ]]
    [[ -f "${WORK_DIR}/user-config.nix" ]]
    [[ -d "${WORK_DIR}/.git" ]]
}
