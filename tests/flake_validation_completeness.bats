#!/usr/bin/env bats
# ABOUTME: Regression tests for Story 10.4-003 - flake validation completeness
# ABOUTME: and removal of dead (never-executed) nix-darwin activation scripts

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    FLAKE_FILE="${REPO_ROOT}/flake.nix"
    DARWIN_CONFIG="${REPO_ROOT}/darwin/configuration.nix"
    MAINTENANCE_MODULE="${REPO_ROOT}/darwin/maintenance.nix"
}

@test "requiredAttrs includes notificationEmail so missing it hits the friendly validateConfig error" {
    run awk '/requiredAttrs = \[/,/\];/' "${FLAKE_FILE}"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"notificationEmail"'* ]]
}

@test "dead xcodeCheck activation script is removed from darwin/configuration.nix" {
    run rg -n "xcodeCheck" "${DARWIN_CONFIG}"
    [ "$status" -eq 1 ]
}

@test "dead disableHomebrewOllamaService activation script is removed from darwin/maintenance.nix" {
    run rg -n "disableHomebrewOllamaService" "${MAINTENANCE_MODULE}"
    [ "$status" -eq 1 ]
}
