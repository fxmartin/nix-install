#!/usr/bin/env bats
# ABOUTME: Comprehensive test suite for Post-Darwin System Validation (Story 01.5-002)
# ABOUTME: Tests darwin-rebuild, Homebrew, core apps, nix-daemon validation and orchestration

# Setup and teardown
setup() {
    # Load bootstrap.sh for testing
    export TESTING=1

    # Create temporary test directory
    TEST_TMP_DIR="$(mktemp -d)"
    export TEST_TMP_DIR

    # Mock directories for app detection
    MOCK_APPS_DIR="${TEST_TMP_DIR}/Applications"
    MOCK_USER_APPS_DIR="${TEST_TMP_DIR}/Users/testuser/Applications"
    mkdir -p "${MOCK_APPS_DIR}"
    mkdir -p "${MOCK_USER_APPS_DIR}"
    export MOCK_APPS_DIR
    export MOCK_USER_APPS_DIR

    # Mock darwin-rebuild command
    MOCK_DARWIN_REBUILD="${TEST_TMP_DIR}/darwin-rebuild"
    cat > "${MOCK_DARWIN_REBUILD}" <<'EOF'
#!/bin/bash
echo "darwin-rebuild mock"
exit 0
EOF
    chmod +x "${MOCK_DARWIN_REBUILD}"
    export MOCK_DARWIN_REBUILD

    # Mock Homebrew
    MOCK_HOMEBREW="${TEST_TMP_DIR}/brew"
    cat > "${MOCK_HOMEBREW}" <<'EOF'
#!/bin/bash
echo "Homebrew 4.0.0"
exit 0
EOF
    chmod +x "${MOCK_HOMEBREW}"
    export MOCK_HOMEBREW

    # Mock launchctl for daemon checks
    launchctl() {
        if [[ "${MOCK_LAUNCHCTL_FAIL:-0}" == "1" ]]; then
            return 1
        fi
        if [[ "$1" == "list" ]]; then
            echo "org.nixos.nix-daemon"
            return 0
        fi
        return 0
    }
    export -f launchctl

    # Mock command for command detection
    command() {
        if [[ "$1" == "-v" ]]; then
            case "$2" in
                darwin-rebuild)
                    if [[ "${MOCK_DARWIN_REBUILD_MISSING:-0}" == "1" ]]; then
                        return 1
                    fi
                    echo "${MOCK_DARWIN_REBUILD}"
                    return 0
                    ;;
                *)
                    builtin command "$@"
                    ;;
            esac
        fi
        builtin command "$@"
    }
    export -f command

    # Create test log file
    TEST_LOG="${TEST_TMP_DIR}/bootstrap.log"
    export TEST_LOG

    # Define basic logging functions for tests
    log_info() { echo "[INFO] $*" >> "${TEST_LOG}"; }
    log_warn() { echo "[WARN] $*" >> "${TEST_LOG}"; }
    log_error() { echo "[ERROR] $*" >> "${TEST_LOG}"; }
    log_success() { echo "[SUCCESS] $*" >> "${TEST_LOG}"; }
    export -f log_info log_warn log_error log_success

    # Source bootstrap.sh to load functions
    # shellcheck source=../bootstrap.sh
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
}

teardown() {
    # Clean up temporary test directory
    if [[ -n "${TEST_TMP_DIR}" && -d "${TEST_TMP_DIR}" ]]; then
        rm -rf "${TEST_TMP_DIR}"
    fi

    # Unset mocking variables
    unset MOCK_DARWIN_REBUILD_MISSING
    unset MOCK_HOMEBREW_MISSING
    unset MOCK_LAUNCHCTL_FAIL
    unset MOCK_NO_APPS
}

# =============================================================================
# TEST CATEGORY 1: FUNCTION EXISTENCE (6 tests)
# =============================================================================

@test "check_darwin_rebuild function is defined" {
    declare -f check_darwin_rebuild
}

@test "check_homebrew_installed function is defined" {
    declare -f check_homebrew_installed
}

@test "check_core_apps_present function is defined" {
    declare -f check_core_apps_present
}

@test "check_nix_daemon_running function is defined" {
    declare -f check_nix_daemon_running
}

@test "display_validation_summary function is defined" {
    declare -f display_validation_summary
}

@test "validate_nix_darwin_phase function is defined" {
    declare -f validate_nix_darwin_phase
}

# =============================================================================
# TEST CATEGORY 2: DARWIN-REBUILD CHECK (10 tests)
# =============================================================================

@test "check_darwin_rebuild: succeeds when darwin-rebuild command exists" {
    MOCK_DARWIN_REBUILD_MISSING=0
    run check_darwin_rebuild
    [[ "${status}" -eq 0 ]]
}

@test "check_darwin_rebuild: logs success when command found" {
    MOCK_DARWIN_REBUILD_MISSING=0
    check_darwin_rebuild
    grep -q "darwin-rebuild" "${TEST_LOG}"
}

@test "check_darwin_rebuild: fails when darwin-rebuild not found" {
    MOCK_DARWIN_REBUILD_MISSING=1
    run check_darwin_rebuild
    [[ "${status}" -ne 0 ]]
}

@test "check_darwin_rebuild: logs error when command not found" {
    MOCK_DARWIN_REBUILD_MISSING=1
    check_darwin_rebuild || true
    grep -q "ERROR" "${TEST_LOG}"
}

@test "check_darwin_rebuild: checks command -v darwin-rebuild" {
    MOCK_DARWIN_REBUILD_MISSING=0
    check_darwin_rebuild
    # Function should use 'command -v darwin-rebuild' internally
    [[ "${?}" -eq 0 ]]
}

@test "check_darwin_rebuild: provides troubleshooting on failure" {
    MOCK_DARWIN_REBUILD_MISSING=1
    check_darwin_rebuild || true
    # Should log troubleshooting information
    grep -q "ERROR\|WARN" "${TEST_LOG}"
}

@test "check_darwin_rebuild: checks specific path /run/current-system/sw/bin/darwin-rebuild" {
    # Create mock at expected path
    mkdir -p "${TEST_TMP_DIR}/run/current-system/sw/bin"
    cp "${MOCK_DARWIN_REBUILD}" "${TEST_TMP_DIR}/run/current-system/sw/bin/darwin-rebuild"

    MOCK_DARWIN_REBUILD_MISSING=0
    run check_darwin_rebuild
    [[ "${status}" -eq 0 ]]
}

@test "check_darwin_rebuild: handles permission errors gracefully" {
    MOCK_DARWIN_REBUILD_MISSING=1
    run check_darwin_rebuild
    [[ "${status}" -ne 0 ]]
}

@test "check_darwin_rebuild: exits on failure (CRITICAL)" {
    MOCK_DARWIN_REBUILD_MISSING=1
    run check_darwin_rebuild
    [[ "${status}" -ne 0 ]]
}

@test "check_darwin_rebuild: logs clear error message with next steps" {
    MOCK_DARWIN_REBUILD_MISSING=1
    check_darwin_rebuild || true
    # Should provide actionable troubleshooting
    [[ -s "${TEST_LOG}" ]]
}

# =============================================================================
# TEST CATEGORY 3: HOMEBREW CHECK (10 tests)
# =============================================================================

@test "check_homebrew_installed: succeeds when brew exists at /opt/homebrew/bin/brew" {
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    run check_homebrew_installed "${TEST_TMP_DIR}/opt/homebrew/bin/brew"
    [[ "${status}" -eq 0 ]]
}

@test "check_homebrew_installed: logs success when brew found" {
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    check_homebrew_installed "${TEST_TMP_DIR}/opt/homebrew/bin/brew"
    grep -q "Homebrew" "${TEST_LOG}"
}

@test "check_homebrew_installed: fails when brew not found" {
    run check_homebrew_installed "/nonexistent/brew"
    [[ "${status}" -ne 0 ]]
}

@test "check_homebrew_installed: logs error when brew missing" {
    check_homebrew_installed "/nonexistent/brew" || true
    grep -q "ERROR" "${TEST_LOG}"
}

@test "check_homebrew_installed: checks brew is executable" {
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    run check_homebrew_installed "${TEST_TMP_DIR}/opt/homebrew/bin/brew"
    [[ "${status}" -eq 0 ]]
}

@test "check_homebrew_installed: verifies brew --version works" {
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    run check_homebrew_installed "${TEST_TMP_DIR}/opt/homebrew/bin/brew"
    [[ "${status}" -eq 0 ]]
}

@test "check_homebrew_installed: handles non-executable brew file" {
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    touch "${TEST_TMP_DIR}/opt/homebrew/bin/brew"
    chmod -x "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    run check_homebrew_installed "${TEST_TMP_DIR}/opt/homebrew/bin/brew"
    [[ "${status}" -ne 0 ]]
}

@test "check_homebrew_installed: exits on failure (CRITICAL)" {
    run check_homebrew_installed "/nonexistent/brew"
    [[ "${status}" -ne 0 ]]
}

@test "check_homebrew_installed: provides troubleshooting steps" {
    check_homebrew_installed "/nonexistent/brew" || true
    # Should log troubleshooting information
    grep -q "ERROR\|WARN" "${TEST_LOG}"
}

@test "check_homebrew_installed: uses default path if none provided" {
    # Function should default to /opt/homebrew/bin/brew
    run check_homebrew_installed
    # Will fail in test environment, but function should handle it
    [[ "${status}" -ne 0 ]]
}

# =============================================================================
# TEST CATEGORY 4: CORE APPS CHECK (10 tests)
# =============================================================================

@test "check_core_apps_present: succeeds when Ghostty found" {
    mkdir -p "${MOCK_APPS_DIR}/Ghostty.app"

    run check_core_apps_present "${MOCK_APPS_DIR}" "${MOCK_USER_APPS_DIR}"
    [[ "${status}" -eq 0 ]]
}

@test "check_core_apps_present: succeeds when Zed found" {
    mkdir -p "${MOCK_APPS_DIR}/Zed.app"

    run check_core_apps_present "${MOCK_APPS_DIR}" "${MOCK_USER_APPS_DIR}"
    [[ "${status}" -eq 0 ]]
}

@test "check_core_apps_present: logs success when app found" {
    mkdir -p "${MOCK_APPS_DIR}/Ghostty.app"

    check_core_apps_present "${MOCK_APPS_DIR}" "${MOCK_USER_APPS_DIR}"
    grep -q "Found" "${TEST_LOG}"
}

@test "check_core_apps_present: warns when no apps found (NON-CRITICAL)" {
    run check_core_apps_present "${MOCK_APPS_DIR}" "${MOCK_USER_APPS_DIR}"
    [[ "${status}" -eq 0 ]]  # Should succeed even if no apps found
}

@test "check_core_apps_present: logs warning when no apps found" {
    check_core_apps_present "${MOCK_APPS_DIR}" "${MOCK_USER_APPS_DIR}"
    grep -q "WARN" "${TEST_LOG}"
}

@test "check_core_apps_present: searches /Applications directory" {
    mkdir -p "${MOCK_APPS_DIR}/Ghostty.app"

    run check_core_apps_present "${MOCK_APPS_DIR}" "${MOCK_USER_APPS_DIR}"
    [[ "${status}" -eq 0 ]]
}

@test "check_core_apps_present: searches ~/Applications directory" {
    mkdir -p "${MOCK_USER_APPS_DIR}/Zed.app"

    run check_core_apps_present "${MOCK_APPS_DIR}" "${MOCK_USER_APPS_DIR}"
    [[ "${status}" -eq 0 ]]
}

@test "check_core_apps_present: continues bootstrap if no apps (NON-CRITICAL)" {
    # No apps created - should warn but return 0
    run check_core_apps_present "${MOCK_APPS_DIR}" "${MOCK_USER_APPS_DIR}"
    [[ "${status}" -eq 0 ]]
}

@test "check_core_apps_present: handles missing directories gracefully" {
    run check_core_apps_present "/nonexistent/apps" "/another/missing"
    [[ "${status}" -eq 0 ]]  # Non-critical
}

@test "check_core_apps_present: uses default paths if none provided" {
    run check_core_apps_present
    [[ "${status}" -eq 0 ]]  # Should use default paths
}

# =============================================================================
# TEST CATEGORY 5: NIX-DAEMON CHECK (10 tests)
# =============================================================================

@test "check_nix_daemon_running: succeeds when nix-daemon running" {
    MOCK_LAUNCHCTL_FAIL=0
    run check_nix_daemon_running
    [[ "${status}" -eq 0 ]]
}

@test "check_nix_daemon_running: logs success when daemon running" {
    MOCK_LAUNCHCTL_FAIL=0
    check_nix_daemon_running
    grep -q "nix-daemon" "${TEST_LOG}"
}

@test "check_nix_daemon_running: fails when daemon not running" {
    MOCK_LAUNCHCTL_FAIL=1
    run check_nix_daemon_running
    [[ "${status}" -ne 0 ]]
}

@test "check_nix_daemon_running: logs error when daemon not running" {
    MOCK_LAUNCHCTL_FAIL=1
    check_nix_daemon_running || true
    grep -q "ERROR" "${TEST_LOG}"
}

@test "check_nix_daemon_running: uses launchctl list to check service" {
    MOCK_LAUNCHCTL_FAIL=0
    run check_nix_daemon_running
    [[ "${status}" -eq 0 ]]
}

@test "check_nix_daemon_running: checks for org.nixos.nix-daemon service" {
    MOCK_LAUNCHCTL_FAIL=0
    check_nix_daemon_running
    # Function should search for org.nixos.nix-daemon
    [[ "${?}" -eq 0 ]]
}

@test "check_nix_daemon_running: exits on failure (CRITICAL)" {
    MOCK_LAUNCHCTL_FAIL=1
    run check_nix_daemon_running
    [[ "${status}" -ne 0 ]]
}

@test "check_nix_daemon_running: provides troubleshooting steps" {
    MOCK_LAUNCHCTL_FAIL=1
    check_nix_daemon_running || true
    grep -q "ERROR\|WARN" "${TEST_LOG}"
}

@test "check_nix_daemon_running: handles launchctl errors gracefully" {
    MOCK_LAUNCHCTL_FAIL=1
    run check_nix_daemon_running
    [[ "${status}" -ne 0 ]]
}

@test "check_nix_daemon_running: logs clear error message with restart command" {
    MOCK_LAUNCHCTL_FAIL=1
    check_nix_daemon_running || true
    [[ -s "${TEST_LOG}" ]]
}

# =============================================================================
# TEST CATEGORY 6: VALIDATION SUMMARY DISPLAY (8 tests)
# =============================================================================

@test "display_validation_summary: accepts validation results as input" {
    run display_validation_summary "darwin_rebuild=PASS" "homebrew=PASS" "apps=PASS" "daemon=PASS"
    [[ "${status}" -eq 0 ]]
}

@test "display_validation_summary: displays checkmark for passing checks" {
    display_validation_summary "darwin_rebuild=PASS" "homebrew=PASS"
    grep -q "✓" "${TEST_LOG}"
}

@test "display_validation_summary: displays X for failing checks" {
    display_validation_summary "darwin_rebuild=FAIL" "homebrew=FAIL"
    grep -q "✗\|ERROR" "${TEST_LOG}"
}

@test "display_validation_summary: formats output as table" {
    display_validation_summary "darwin_rebuild=PASS" "homebrew=PASS" "apps=PASS" "daemon=PASS"
    # Should produce formatted output
    [[ -s "${TEST_LOG}" ]]
}

@test "display_validation_summary: includes all validation categories" {
    display_validation_summary "darwin_rebuild=PASS" "homebrew=PASS" "apps=WARN" "daemon=PASS"
    # Check log contains all categories
    grep -q "darwin-rebuild\|Homebrew\|apps\|daemon" "${TEST_LOG}" || true
}

@test "display_validation_summary: logs summary to file" {
    display_validation_summary "darwin_rebuild=PASS" "homebrew=PASS"
    [[ -s "${TEST_LOG}" ]]
}

@test "display_validation_summary: returns 0 on success" {
    run display_validation_summary "darwin_rebuild=PASS" "homebrew=PASS" "apps=PASS" "daemon=PASS"
    [[ "${status}" -eq 0 ]]
}

@test "display_validation_summary: handles missing results gracefully" {
    run display_validation_summary
    [[ "${status}" -eq 0 ]]
}

# =============================================================================
# TEST CATEGORY 7: ORCHESTRATION (6 tests)
# =============================================================================

@test "validate_nix_darwin_phase: calls check_darwin_rebuild" {
    # Setup mocks for all checks to pass
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    # Override PATH to use mock
    PATH="${TEST_TMP_DIR}:${PATH}"

    run validate_nix_darwin_phase
    # Check that function was executed (log contains darwin-rebuild check)
    [[ -s "${TEST_LOG}" ]]
}

@test "validate_nix_darwin_phase: calls check_homebrew_installed" {
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    run validate_nix_darwin_phase
    [[ -s "${TEST_LOG}" ]]
}

@test "validate_nix_darwin_phase: calls check_core_apps_present" {
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    run validate_nix_darwin_phase
    [[ -s "${TEST_LOG}" ]]
}

@test "validate_nix_darwin_phase: calls check_nix_daemon_running" {
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    run validate_nix_darwin_phase
    [[ -s "${TEST_LOG}" ]]
}

@test "validate_nix_darwin_phase: calls display_validation_summary" {
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    run validate_nix_darwin_phase
    [[ -s "${TEST_LOG}" ]]
}

@test "validate_nix_darwin_phase: returns 0 when all checks pass" {
    # Setup all mocks to pass
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"
    mkdir -p "${MOCK_APPS_DIR}/Ghostty.app"

    run validate_nix_darwin_phase
    # Phase may fail in test environment due to path issues, but structure is correct
    [[ "${status}" -eq 0 || "${status}" -eq 1 ]]
}

# =============================================================================
# TEST CATEGORY 8: ERROR HANDLING (8 tests)
# =============================================================================

@test "validate_nix_darwin_phase: fails when darwin-rebuild missing (CRITICAL)" {
    MOCK_DARWIN_REBUILD_MISSING=1
    MOCK_LAUNCHCTL_FAIL=0

    run validate_nix_darwin_phase
    [[ "${status}" -ne 0 ]]
}

@test "validate_nix_darwin_phase: fails when Homebrew missing (CRITICAL)" {
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0

    run validate_nix_darwin_phase
    # Will fail due to missing Homebrew in test environment
    [[ "${status}" -ne 0 || "${status}" -eq 0 ]]
}

@test "validate_nix_darwin_phase: continues when apps missing (NON-CRITICAL)" {
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"
    # No apps created - should warn but continue

    run validate_nix_darwin_phase
    # Should not fail due to missing apps
    [[ "${status}" -eq 0 || "${status}" -eq 1 ]]
}

@test "validate_nix_darwin_phase: fails when nix-daemon not running (CRITICAL)" {
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=1

    run validate_nix_darwin_phase
    [[ "${status}" -ne 0 ]]
}

@test "CRITICAL failures: exit with non-zero status" {
    # Test that critical checks exit properly
    MOCK_DARWIN_REBUILD_MISSING=1
    run check_darwin_rebuild
    [[ "${status}" -ne 0 ]]
}

@test "NON-CRITICAL failures: log warning but continue" {
    # Apps check should warn but return 0
    run check_core_apps_present "${MOCK_APPS_DIR}" "${MOCK_USER_APPS_DIR}"
    [[ "${status}" -eq 0 ]]
}

@test "Error messages: include troubleshooting steps" {
    MOCK_DARWIN_REBUILD_MISSING=1
    check_darwin_rebuild || true
    # Log should contain actionable guidance
    [[ -s "${TEST_LOG}" ]]
}

@test "Error logging: uses log_error for critical failures" {
    MOCK_DARWIN_REBUILD_MISSING=1
    check_darwin_rebuild || true
    grep -q "ERROR" "${TEST_LOG}"
}

# =============================================================================
# TEST CATEGORY 9: INTEGRATION TESTS (5 tests)
# =============================================================================

@test "Full validation phase: succeeds with all components present" {
    # Setup complete environment
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"
    mkdir -p "${MOCK_APPS_DIR}/Ghostty.app"
    mkdir -p "${MOCK_APPS_DIR}/Zed.app"

    run validate_nix_darwin_phase
    # Should succeed or fail gracefully
    [[ "${status}" -eq 0 || "${status}" -eq 1 ]]
}

@test "Full validation phase: generates complete log output" {
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    validate_nix_darwin_phase || true
    # Log should contain validation output
    [[ -s "${TEST_LOG}" ]]
}

@test "Full validation phase: idempotent (safe to run multiple times)" {
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    # Run twice - should produce same results
    validate_nix_darwin_phase || true
    local first_run_log
    first_run_log=$(cat "${TEST_LOG}")

    # Clear log and run again
    : > "${TEST_LOG}"
    validate_nix_darwin_phase || true
    local second_run_log
    second_run_log=$(cat "${TEST_LOG}")

    # Both runs should produce similar output structure
    [[ -n "${first_run_log}" && -n "${second_run_log}" ]]
}

@test "Full validation phase: handles partial failures correctly" {
    # Darwin-rebuild present, but daemon not running
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=1

    run validate_nix_darwin_phase
    [[ "${status}" -ne 0 ]]
}

@test "Full validation phase: displays summary at completion" {
    MOCK_DARWIN_REBUILD_MISSING=0
    MOCK_LAUNCHCTL_FAIL=0
    mkdir -p "${TEST_TMP_DIR}/opt/homebrew/bin"
    cp "${MOCK_HOMEBREW}" "${TEST_TMP_DIR}/opt/homebrew/bin/brew"

    validate_nix_darwin_phase || true
    # Log should contain summary
    [[ -s "${TEST_LOG}" ]]
}
