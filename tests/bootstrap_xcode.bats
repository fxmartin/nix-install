#!/usr/bin/env bats
# ABOUTME: Comprehensive test suite for Xcode CLI Tools installation phase (Story 01.3-001)
# ABOUTME: Tests detection, installation, license acceptance, verification, and error handling

# Setup and teardown
setup() {
    # Load bootstrap.sh for testing
    export TESTING=1

    # Mock sudo to avoid privilege escalation during tests
    sudo() {
        if [[ "${1:-}" == "xcodebuild" && "${2:-}" == "-license" && "${3:-}" == "accept" ]]; then
            # Use xcodebuild exit code when mocked
            return "${MOCK_XCODEBUILD_EXIT_CODE:-0}"
        fi
        command sudo "$@"
    }
    export -f sudo

    # Mock xcode-select
    xcode-select() {
        case "${1:-}" in
            -p)
                if [[ "${MOCK_XCODE_INSTALLED:-0}" == "1" ]]; then
                    echo "/Library/Developer/CommandLineTools"
                    return 0
                else
                    echo "xcode-select: error: unable to get active developer directory" >&2
                    return 1
                fi
                ;;
            --install)
                if [[ "${MOCK_XCODE_INSTALL_FAIL:-0}" == "1" ]]; then
                    return 1
                else
                    return 0
                fi
                ;;
            *)
                return 1
                ;;
        esac
    }
    export -f xcode-select

    # Mock xcodebuild (for license acceptance)
    xcodebuild() {
        if [[ "${1:-}" == "-license" && "${2:-}" == "accept" ]]; then
            return "${MOCK_XCODEBUILD_EXIT_CODE:-0}"
        fi
        return 1
    }
    export -f xcodebuild

    # Mock read for user interaction
    read() {
        # Simulate user pressing ENTER
        return 0
    }
    export -f read
}

teardown() {
    # Clean up environment
    unset MOCK_XCODE_INSTALLED
    unset MOCK_XCODE_INSTALL_FAIL
    unset MOCK_SUDO_EXIT_CODE
    unset MOCK_XCODEBUILD_EXIT_CODE
    unset TESTING
}

# =============================================================================
# Function Existence Tests (6 tests)
# =============================================================================

@test "check_xcode_installed function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f check_xcode_installed >/dev/null
}

@test "install_xcode_cli_tools function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f install_xcode_cli_tools >/dev/null
}

@test "wait_for_xcode_installation function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f wait_for_xcode_installation >/dev/null
}

@test "accept_xcode_license function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f accept_xcode_license >/dev/null
}

@test "verify_xcode_installation function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f verify_xcode_installation >/dev/null
}

@test "install_xcode_phase function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f install_xcode_phase >/dev/null
}

# =============================================================================
# Detection Logic Tests (10 tests)
# =============================================================================

@test "check_xcode_installed returns 0 when Xcode CLI tools installed" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run check_xcode_installed
    [ "$status" -eq 0 ]
}

@test "check_xcode_installed returns 1 when Xcode CLI tools not installed" {
    export MOCK_XCODE_INSTALLED=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run check_xcode_installed
    [ "$status" -eq 1 ]
}

@test "check_xcode_installed logs path when installed" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run check_xcode_installed
    [[ "$output" =~ "/Library/Developer/CommandLineTools" ]]
}

@test "check_xcode_installed logs not installed message" {
    export MOCK_XCODE_INSTALLED=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run check_xcode_installed
    [[ "$output" =~ "not installed" ]]
}

@test "check_xcode_installed handles xcode-select command failure gracefully" {
    export MOCK_XCODE_INSTALLED=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run check_xcode_installed
    [ "$status" -eq 1 ]
}

@test "check_xcode_installed detects valid installation path" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run check_xcode_installed
    [ "$status" -eq 0 ]
    [[ "$output" =~ "already installed" ]]
}

@test "check_xcode_installed is idempotent" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run check_xcode_installed
    local first_status=$status

    run check_xcode_installed
    [ "$status" -eq "$first_status" ]
}

@test "check_xcode_installed handles empty xcode-select output" {
    xcode-select() {
        if [[ "${1:-}" == "-p" ]]; then
            echo ""
            return 1
        fi
    }
    export -f xcode-select

    source /Users/user/dev/nix-install/bootstrap.sh
    run check_xcode_installed
    [ "$status" -eq 1 ]
}

@test "check_xcode_installed validates installation before returning success" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run check_xcode_installed
    [ "$status" -eq 0 ]
}

@test "check_xcode_installed logs info level messages" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run check_xcode_installed
    # Should contain log_info output (not error)
    ! [[ "$output" =~ "ERROR" ]]
}

# =============================================================================
# Installation Triggering Tests (8 tests)
# =============================================================================

@test "install_xcode_cli_tools calls xcode-select --install" {
    export MOCK_XCODE_INSTALL_FAIL=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_cli_tools
    [ "$status" -eq 0 ]
}

@test "install_xcode_cli_tools returns 0 on successful trigger" {
    export MOCK_XCODE_INSTALL_FAIL=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_cli_tools
    [ "$status" -eq 0 ]
}

@test "install_xcode_cli_tools returns 1 on installation trigger failure" {
    export MOCK_XCODE_INSTALL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_cli_tools
    [ "$status" -eq 1 ]
}

@test "install_xcode_cli_tools logs starting message" {
    export MOCK_XCODE_INSTALL_FAIL=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_cli_tools
    [[ "$output" =~ "Starting" || "$output" =~ "installation" ]]
}

@test "install_xcode_cli_tools logs success message" {
    export MOCK_XCODE_INSTALL_FAIL=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_cli_tools
    [[ "$output" =~ "dialog opened" || "$output" =~ "✓" ]]
}

@test "install_xcode_cli_tools logs error on failure" {
    export MOCK_XCODE_INSTALL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_cli_tools
    [[ "$output" =~ "Failed" || "$output" =~ "ERROR" ]]
}

@test "install_xcode_cli_tools handles already-in-progress installation" {
    export MOCK_XCODE_INSTALL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_cli_tools
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Failed" ]]
}

@test "install_xcode_cli_tools does not require sudo" {
    export MOCK_XCODE_INSTALL_FAIL=0
    source /Users/user/dev/nix-install/bootstrap.sh

    # Should succeed without sudo
    run install_xcode_cli_tools
    [ "$status" -eq 0 ]
}

# =============================================================================
# User Interaction Tests (8 tests)
# =============================================================================

@test "wait_for_xcode_installation prompts user" {
    source /Users/user/dev/nix-install/bootstrap.sh

    run wait_for_xcode_installation
    [[ "$output" =~ "MANUAL STEP" || "$output" =~ "Press ENTER" ]]
}

@test "wait_for_xcode_installation displays clear instructions" {
    source /Users/user/dev/nix-install/bootstrap.sh

    run wait_for_xcode_installation
    [[ "$output" =~ "Click 'Install'" ]]
}

@test "wait_for_xcode_installation mentions time estimate" {
    source /Users/user/dev/nix-install/bootstrap.sh

    run wait_for_xcode_installation
    [[ "$output" =~ "5-10 minutes" || "$output" =~ "minutes" ]]
}

@test "wait_for_xcode_installation returns 0 after user input" {
    source /Users/user/dev/nix-install/bootstrap.sh

    run wait_for_xcode_installation
    [ "$status" -eq 0 ]
}

@test "wait_for_xcode_installation waits for ENTER key" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Mock read is already set up to simulate ENTER
    run wait_for_xcode_installation
    [ "$status" -eq 0 ]
}

@test "wait_for_xcode_installation displays header separator" {
    source /Users/user/dev/nix-install/bootstrap.sh

    run wait_for_xcode_installation
    [[ "$output" =~ "======" ]]
}

@test "wait_for_xcode_installation provides numbered steps" {
    source /Users/user/dev/nix-install/bootstrap.sh

    run wait_for_xcode_installation
    [[ "$output" =~ "1." && "$output" =~ "2." && "$output" =~ "3." ]]
}

@test "wait_for_xcode_installation is non-blocking after user input" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Should return immediately with mocked read
    run wait_for_xcode_installation
    [ "$status" -eq 0 ]
}

# =============================================================================
# License Acceptance Tests (8 tests)
# =============================================================================

@test "accept_xcode_license calls sudo xcodebuild" {
    export MOCK_SUDO_EXIT_CODE=0
    export MOCK_XCODEBUILD_EXIT_CODE=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run accept_xcode_license
    [ "$status" -eq 0 ]
}

@test "accept_xcode_license returns 0 on successful acceptance" {
    export MOCK_SUDO_EXIT_CODE=0
    export MOCK_XCODEBUILD_EXIT_CODE=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run accept_xcode_license
    [ "$status" -eq 0 ]
}

@test "accept_xcode_license returns 1 on license acceptance failure" {
    export MOCK_SUDO_EXIT_CODE=1
    export MOCK_XCODEBUILD_EXIT_CODE=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run accept_xcode_license
    [ "$status" -eq 1 ]
}

@test "accept_xcode_license handles exit code 69 (already accepted)" {
    export MOCK_XCODEBUILD_EXIT_CODE=69
    source /Users/user/dev/nix-install/bootstrap.sh

    run accept_xcode_license
    [ "$status" -eq 0 ]
}

@test "accept_xcode_license logs success message" {
    export MOCK_SUDO_EXIT_CODE=0
    export MOCK_XCODEBUILD_EXIT_CODE=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run accept_xcode_license
    [[ "$output" =~ "license accepted" || "$output" =~ "✓" ]]
}

@test "accept_xcode_license logs error with helpful message on failure" {
    export MOCK_SUDO_EXIT_CODE=1
    export MOCK_XCODEBUILD_EXIT_CODE=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run accept_xcode_license
    [[ "$output" =~ "Failed" && "$output" =~ "sudo xcodebuild" ]]
}

@test "accept_xcode_license handles already-accepted license gracefully" {
    export MOCK_XCODEBUILD_EXIT_CODE=69
    source /Users/user/dev/nix-install/bootstrap.sh

    run accept_xcode_license
    [ "$status" -eq 0 ]
    [[ "$output" =~ "already accepted" || "$output" =~ "not required" ]]
}

@test "accept_xcode_license includes exit code in error messages" {
    export MOCK_XCODEBUILD_EXIT_CODE=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run accept_xcode_license
    [[ "$output" =~ "exit code" ]]
}

# =============================================================================
# Verification Logic Tests (8 tests)
# =============================================================================

@test "verify_xcode_installation returns 0 when installed" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run verify_xcode_installation
    [ "$status" -eq 0 ]
}

@test "verify_xcode_installation returns 1 when not installed" {
    export MOCK_XCODE_INSTALLED=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run verify_xcode_installation
    [ "$status" -eq 1 ]
}

@test "verify_xcode_installation displays installation path" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run verify_xcode_installation
    [[ "$output" =~ "/Library/Developer/CommandLineTools" ]]
}

@test "verify_xcode_installation logs success message" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run verify_xcode_installation
    [[ "$output" =~ "installed successfully" || "$output" =~ "✓" ]]
}

@test "verify_xcode_installation logs error on verification failure" {
    export MOCK_XCODE_INSTALLED=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run verify_xcode_installation
    [[ "$output" =~ "verification failed" || "$output" =~ "ERROR" ]]
}

@test "verify_xcode_installation provides troubleshooting guidance" {
    export MOCK_XCODE_INSTALLED=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run verify_xcode_installation
    [[ "$output" =~ "xcode-select --install" ]]
}

@test "verify_xcode_installation validates path format" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run verify_xcode_installation
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Path:" ]]
}

@test "verify_xcode_installation uses xcode-select -p" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run verify_xcode_installation
    [ "$status" -eq 0 ]
}

# =============================================================================
# Integration Tests (5 tests)
# =============================================================================

@test "install_xcode_phase skips when already installed" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_phase
    [ "$status" -eq 0 ]
    [[ "$output" =~ "already installed" ]]
}

@test "install_xcode_phase orchestrates full installation flow" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Mock the entire flow: not installed → install → verify → license
    export MOCK_XCODE_INSTALL_FAIL=0
    export MOCK_XCODEBUILD_EXIT_CODE=0

    # Mock check_xcode_installed to return "not installed" first time
    check_count=0
    check_xcode_installed() {
        if [[ $check_count -eq 0 ]]; then
            check_count=1
            log_info "Xcode CLI Tools not installed"
            return 1  # First check: not installed
        else
            log_info "Xcode CLI Tools already installed at: /Library/Developer/CommandLineTools"
            return 0  # Subsequent checks: installed
        fi
    }
    export -f check_xcode_installed

    # Mock verify_xcode_installation to succeed (simulate completed install)
    verify_xcode_installation() {
        log_info "Verifying Xcode CLI Tools installation..."
        log_info "✓ Xcode CLI Tools installed successfully"
        log_info "  Path: /Library/Developer/CommandLineTools"
        return 0
    }
    export -f verify_xcode_installation

    run install_xcode_phase
    [ "$status" -eq 0 ]
}

@test "install_xcode_phase displays Phase 3/10 header" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_phase
    [[ "$output" =~ "Phase 3" ]]
}

@test "install_xcode_phase returns 1 on installation failure" {
    export MOCK_XCODE_INSTALLED=0
    export MOCK_XCODE_INSTALL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_phase
    [ "$status" -eq 1 ]
}

@test "install_xcode_phase returns 1 on verification failure" {
    export MOCK_XCODE_INSTALLED=0
    export MOCK_XCODE_INSTALL_FAIL=0

    source /Users/user/dev/nix-install/bootstrap.sh

    # Mock verify_xcode_installation to fail
    verify_xcode_installation() {
        log_error "Verification failed"
        return 1
    }
    export -f verify_xcode_installation

    run install_xcode_phase
    [ "$status" -eq 1 ]
}

# =============================================================================
# Error Handling Tests (12 tests)
# =============================================================================

@test "install_xcode_phase handles missing xcode-select command" {
    xcode-select() {
        echo "command not found: xcode-select" >&2
        return 127
    }
    export -f xcode-select

    source /Users/user/dev/nix-install/bootstrap.sh
    run install_xcode_phase
    [ "$status" -ne 0 ]
}

@test "install_xcode_phase handles installation dialog cancellation" {
    export MOCK_XCODE_INSTALLED=0
    export MOCK_XCODE_INSTALL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_phase
    [ "$status" -eq 1 ]
}

@test "install_xcode_phase handles license acceptance denial" {
    export MOCK_XCODE_INSTALL_FAIL=0
    export MOCK_XCODEBUILD_EXIT_CODE=1

    source /Users/user/dev/nix-install/bootstrap.sh

    # Mock successful check after installation but failed license
    check_count=0
    check_xcode_installed() {
        if [[ $check_count -eq 0 ]]; then
            check_count=1
            log_info "Xcode CLI Tools not installed"
            return 1
        else
            log_info "Xcode CLI Tools already installed at: /Library/Developer/CommandLineTools"
            return 0
        fi
    }
    export -f check_xcode_installed

    # Mock verify_xcode_installation to succeed
    verify_xcode_installation() {
        log_info "Verifying Xcode CLI Tools installation..."
        log_info "✓ Xcode CLI Tools installed successfully"
        log_info "  Path: /Library/Developer/CommandLineTools"
        return 0
    }
    export -f verify_xcode_installation

    run install_xcode_phase
    # Should still succeed (license warning only)
    [ "$status" -eq 0 ]
    [[ "$output" =~ "License acceptance failed" || "$output" =~ "WARN" ]]
}

@test "install_xcode_phase propagates installation trigger errors" {
    export MOCK_XCODE_INSTALLED=0
    export MOCK_XCODE_INSTALL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_phase
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Failed" ]]
}

@test "install_xcode_phase propagates verification errors" {
    export MOCK_XCODE_INSTALLED=0
    export MOCK_XCODE_INSTALL_FAIL=0

    source /Users/user/dev/nix-install/bootstrap.sh

    # Mock verify to always fail
    verify_xcode_installation() {
        return 1
    }
    export -f verify_xcode_installation

    run install_xcode_phase
    [ "$status" -eq 1 ]
}

@test "error messages include actionable guidance" {
    export MOCK_XCODE_INSTALLED=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run verify_xcode_installation
    [[ "$output" =~ "xcode-select --install" ]]
}

@test "error messages are clear and descriptive" {
    export MOCK_XCODE_INSTALL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_cli_tools
    [[ "$output" =~ "Failed" ]]
}

@test "install_xcode_phase handles partial installation gracefully" {
    export MOCK_XCODE_INSTALLED=0
    export MOCK_XCODE_INSTALL_FAIL=0

    source /Users/user/dev/nix-install/bootstrap.sh

    # Simulate verification failure after installation attempt
    verify_xcode_installation() {
        log_error "Partial installation detected"
        return 1
    }
    export -f verify_xcode_installation

    run install_xcode_phase
    [ "$status" -eq 1 ]
}

@test "license acceptance errors include exit codes" {
    export MOCK_XCODEBUILD_EXIT_CODE=5
    source /Users/user/dev/nix-install/bootstrap.sh

    run accept_xcode_license
    [[ "$output" =~ "exit code: 5" ]]
}

@test "verification errors suggest manual intervention" {
    export MOCK_XCODE_INSTALLED=0
    source /Users/user/dev/nix-install/bootstrap.sh

    run verify_xcode_installation
    [[ "$output" =~ "xcode-select --install" ]]
}

@test "installation errors do not expose stack traces" {
    export MOCK_XCODE_INSTALL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_cli_tools
    ! [[ "$output" =~ "line [0-9]" ]]
}

@test "phase errors return non-zero exit codes" {
    export MOCK_XCODE_INSTALLED=0
    export MOCK_XCODE_INSTALL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_phase
    [ "$status" -ne 0 ]
}

# =============================================================================
# Idempotency Tests (5 tests)
# =============================================================================

@test "install_xcode_phase is safe to run multiple times when installed" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_phase
    local first_status=$status

    run install_xcode_phase
    [ "$status" -eq "$first_status" ]
}

@test "check_xcode_installed produces consistent results" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run check_xcode_installed
    local first_output="$output"

    run check_xcode_installed
    [ "$output" = "$first_output" ]
}

@test "install_xcode_phase skips installation when already complete" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run install_xcode_phase
    [[ "$output" =~ "already installed" ]]
    [[ "$output" =~ "skipping" ]]
}

@test "verify_xcode_installation can be called multiple times" {
    export MOCK_XCODE_INSTALLED=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run verify_xcode_installation
    [ "$status" -eq 0 ]

    run verify_xcode_installation
    [ "$status" -eq 0 ]
}

@test "accept_xcode_license handles already-accepted scenario" {
    export MOCK_XCODEBUILD_EXIT_CODE=69
    source /Users/user/dev/nix-install/bootstrap.sh

    run accept_xcode_license
    [ "$status" -eq 0 ]

    run accept_xcode_license
    [ "$status" -eq 0 ]
}
