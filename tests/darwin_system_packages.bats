#!/usr/bin/env bats
# ABOUTME: Tests shared nix-darwin system packages available across all profiles
# ABOUTME: Guards common developer tooling that should not be profile-specific

setup() {
    DARWIN_CONFIG="${BATS_TEST_DIRNAME}/../darwin/configuration.nix"
    HOMEBREW_CONFIG="${BATS_TEST_DIRNAME}/../darwin/homebrew.nix"
}

@test "pkgconf remains declarative for native extension builds" {
    run rg -n '"pkgconf"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]
}

common_bats_package_lines() {
    awk '
        /lib\.optionals/ {
            in_profile_specific_block = 1
        }
        in_profile_specific_block && /^[[:space:]]*\][[:space:]]*$/ {
            in_profile_specific_block = 0
            next
        }
        !in_profile_specific_block && /^[[:space:]]*bats([[:space:]]|#)/ {
            print
        }
    ' "$DARWIN_CONFIG"
}

@test "bats is installed in shared system packages for every profile" {
    run common_bats_package_lines
    [ "$status" -eq 0 ]
    [[ "$output" == *"bats"* ]]
}
