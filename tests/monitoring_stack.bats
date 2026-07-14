#!/usr/bin/env bats
# ABOUTME: Guards the deliberately small monitoring stack and telemetry backend
# ABOUTME: Prevents redundant interactive monitors from returning

setup() {
    DARWIN_CONFIG="${BATS_TEST_DIRNAME}/../darwin/configuration.nix"
    HOMEBREW_CONFIG="${BATS_TEST_DIRNAME}/../darwin/homebrew.nix"
    HOME_CONFIG="${BATS_TEST_DIRNAME}/../home-manager/home.nix"
    HEALTH_API="${BATS_TEST_DIRNAME}/../scripts/health-api.py"
    MONITORING_MODULE="${BATS_TEST_DIRNAME}/../darwin/monitoring.nix"
    README_FILE="${BATS_TEST_DIRNAME}/../README.md"
}

@test "redundant interactive monitors remain absent" {
    run rg -n '^[[:space:]]+gotop[[:space:]]*(#.*)?$' "$DARWIN_CONFIG"
    [ "$status" -eq 1 ]

    run rg -n '"mactop"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]
}

@test "macmon remains an explicit health API backend" {
    run rg -n 'macmon # Headless Apple Silicon telemetry backend' "$DARWIN_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n '/run/current-system/sw/bin/macmon' "$HEALTH_API"
    [ "$status" -eq 0 ]
}

@test "retained monitoring layers remain declared" {
    run rg -n './modules/btop\.nix' "$HOME_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n '"istat-menus"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n '\$\{pkgs\.beszel\}/bin/beszel-agent' "$MONITORING_MODULE"
    [ "$status" -eq 0 ]
}

@test "README advertises only the rationalised stack" {
    run rg -n 'System & Monitoring.*iStat Menus.*btop.*Beszel' "$README_FILE"
    [ "$status" -eq 0 ]

    run rg -n 'System & Monitoring.*(gotop|mactop)' "$README_FILE"
    [ "$status" -eq 1 ]
}
