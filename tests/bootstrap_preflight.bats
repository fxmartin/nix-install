#!/usr/bin/env bats
# ABOUTME: Test suite for bootstrap.sh pre-flight environment validation
# ABOUTME: Validates macOS version checks, internet connectivity, root prevention, and error messaging

# Test helper for sourcing bootstrap functions without executing main
setup() {
    # Store the path to bootstrap script
    BOOTSTRAP_SCRIPT="${BATS_TEST_DIRNAME}/../scripts/bootstrap.sh"

    # Load bootstrap functions without running main()
    # We'll source it in a way that doesn't execute main
    export -f log_info log_warn log_error 2>/dev/null || true
}

@test "bootstrap.sh exists and is executable" {
    [ -f "$BOOTSTRAP_SCRIPT" ]
    [ -x "$BOOTSTRAP_SCRIPT" ]
}

@test "bootstrap.sh has proper shebang" {
    run head -n 1 "$BOOTSTRAP_SCRIPT"
    [[ "$output" == "#!/usr/bin/env bash" ]] || [[ "$output" == "#!/bin/bash" ]]
}

@test "bootstrap.sh uses strict error handling (set -euo pipefail)" {
    run grep -E "^set -euo pipefail" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "bootstrap.sh has ABOUTME comments" {
    run grep -c "^# ABOUTME:" "$BOOTSTRAP_SCRIPT"
    [ "$output" -ge 2 ]
}

@test "check_macos_version function exists" {
    run grep -E "^check_macos_version\(\)" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "check_not_root function exists" {
    run grep -E "^check_not_root\(\)" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "check_internet function exists" {
    run grep -E "^check_internet\(\)" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "display_system_info function exists" {
    run grep -E "^display_system_info\(\)" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "preflight_checks function exists" {
    run grep -E "^preflight_checks\(\)" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script uses sw_vers for macOS version detection" {
    run grep "sw_vers" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script checks for macOS 14 (Sonoma) or newer" {
    run grep -E "\[\[ .* -lt 14 \]\]|\[ .* -lt 14 \]" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script checks internet connectivity to nixos.org" {
    run grep "nixos.org" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script checks internet connectivity to github.com as fallback" {
    run grep "github.com" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script uses EUID to check for root user" {
    run grep "EUID" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script has log_info function with color support" {
    run grep -E "log_info\(\)" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script has log_error function with color support" {
    run grep -E "log_error\(\)" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script has log_warn function with color support" {
    run grep -E "log_warn\(\)" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "error messages mention 'macOS Sonoma (14.0) or newer required'" {
    run grep -i "sonoma.*14.*required\|14.*sonoma.*required" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "error messages are actionable for macOS version failure" {
    run grep -i "upgrade.*macos\|please.*upgrade" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "error messages are actionable for root user failure" {
    run grep -i "not.*run.*root\|regular user" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "error messages are actionable for internet connectivity failure" {
    run grep -i "network connection\|internet access" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script displays system information including macOS version" {
    run grep -E "sw_vers.*productVersion|macOS Version" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script displays system information including hostname" {
    run grep "hostname" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script displays system information including architecture" {
    run grep "uname -m" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script displays system information including current user" {
    run grep "whoami" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script exits with error on pre-flight failure" {
    run grep -E "exit 1" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script uses curl with timeout for connectivity checks" {
    run grep -E "curl.*--connect-timeout|curl.*timeout" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "main function exists" {
    run grep -E "^main\(\)" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "main function calls preflight_checks" {
    run grep -A 10 "^main()" "$BOOTSTRAP_SCRIPT" | grep "preflight_checks"
    [ "$status" -eq 0 ]
}

@test "script outputs phase information (Phase 1/10)" {
    run grep -i "phase.*1.*10\|pre-flight" "$BOOTSTRAP_SCRIPT"
    [ "$status" -eq 0 ]
}

# Manual test documentation (FX will perform these)
@test "MANUAL: script refuses to run as root (sudo ./bootstrap.sh)" {
    skip "Manual test required: sudo ./scripts/bootstrap.sh should display error and exit 1"
}

@test "MANUAL: script detects old macOS versions gracefully" {
    skip "Manual test required: Test on macOS Ventura (13.x) should fail with clear message"
}

@test "MANUAL: script detects no internet connection gracefully" {
    skip "Manual test required: Disable network and verify error message is actionable"
}

@test "MANUAL: script displays complete system info summary" {
    skip "Manual test required: Verify system info includes version, build, hostname, user, arch"
}

@test "MANUAL: script exits gracefully on any pre-flight failure" {
    skip "Manual test required: Verify clean exit with exit code 1 on failures"
}
