#!/usr/bin/env bats
# ABOUTME: Regression tests for release-monitor data collection and failure reporting
# ABOUTME: Prevents unavailable system tools from being reported as clean update checks

setup() {
    FETCH_SCRIPT="${BATS_TEST_DIRNAME}/../scripts/fetch-release-notes.sh"
    TEST_HOME="${BATS_TEST_TMPDIR}/home"
    mkdir -p "$TEST_HOME"
}

@test "release fetcher can be sourced without running the monitor" {
    run rg -n '^if \[\[ "\$\{BASH_SOURCE\[0\]\}" == "\$0" \]\]; then$' "$FETCH_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "macOS update check defaults to the system softwareupdate path" {
    run env HOME="$TEST_HOME" bash -c 'source "$1"; printf "%s" "$SOFTWAREUPDATE_BIN"' _ "$FETCH_SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "/usr/sbin/softwareupdate" ]
}

@test "missing softwareupdate is an error rather than zero updates" {
    run env HOME="$TEST_HOME" SOFTWAREUPDATE_BIN="${BATS_TEST_TMPDIR}/missing-softwareupdate" \
        bash -c 'source "$1"; fetch_macos_updates' _ "$FETCH_SCRIPT"
    [ "$status" -eq 0 ]

    run jq -e \
        '.check_status == "error" and .update_count == null and (.check_error | contains("not executable"))' \
        <<< "$output"
    [ "$status" -eq 0 ]
}

@test "failed softwareupdate scan is an error rather than zero updates" {
    local fake_softwareupdate="${BATS_TEST_TMPDIR}/softwareupdate-failure"
    printf '#!/usr/bin/env bash\necho "scan failed" >&2\nexit 2\n' > "$fake_softwareupdate"
    chmod +x "$fake_softwareupdate"

    run env HOME="$TEST_HOME" SOFTWAREUPDATE_BIN="$fake_softwareupdate" \
        bash -c 'source "$1"; fetch_macos_updates' _ "$FETCH_SCRIPT"
    [ "$status" -eq 0 ]

    run jq -e \
        '.check_status == "error" and .update_count == null and .check_error == "scan failed"' \
        <<< "$output"
    [ "$status" -eq 0 ]
}

@test "successful macOS scan can explicitly report zero updates" {
    local fake_softwareupdate="${BATS_TEST_TMPDIR}/softwareupdate-clean"
    printf '#!/usr/bin/env bash\necho "Software Update Tool"\necho "No new software available."\n' > "$fake_softwareupdate"
    chmod +x "$fake_softwareupdate"

    run env HOME="$TEST_HOME" SOFTWAREUPDATE_BIN="$fake_softwareupdate" \
        bash -c 'source "$1"; fetch_macos_updates' _ "$FETCH_SCRIPT"
    [ "$status" -eq 0 ]

    run jq -e \
        '.check_status == "success" and .update_count == 0 and .check_error == null' \
        <<< "$output"
    [ "$status" -eq 0 ]
}

@test "flake versions use the configured lock-file path" {
    local flake_lock="${BATS_TEST_TMPDIR}/custom/flake.lock"
    mkdir -p "$(dirname "$flake_lock")"
    printf '%s\n' \
        '{"nodes":{"nixpkgs":{"locked":{"rev":"abcdef1234567890","type":"github","owner":"NixOS","repo":"nixpkgs"}}}}' \
        > "$flake_lock"

    run env HOME="$TEST_HOME" NIX_INSTALL_FLAKE_LOCK="$flake_lock" \
        bash -c 'source "$1"; get_flake_versions' _ "$FETCH_SCRIPT"
    [ "$status" -eq 0 ]

    run jq -e '.nixpkgs.rev == "abcdef12" and .nixpkgs.repo == "nixpkgs"' <<< "$output"
    [ "$status" -eq 0 ]
}

@test "release-monitor LaunchAgent provides the configured flake lock" {
    run bash -c \
        'sed -n "/release-monitor =/,/^    };/p" "$1" | rg "NIX_INSTALL_FLAKE_LOCK"' \
        _ "${BATS_TEST_DIRNAME}/../darwin/maintenance.nix"
    [ "$status" -eq 0 ]
}
