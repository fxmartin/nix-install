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

common_package_lines() {
    local package_name="$1"

    awk -v package_name="$package_name" '
        /lib\.optionals/ {
            in_profile_specific_block = 1
        }
        in_profile_specific_block && /^[[:space:]]*\][[:space:]]*$/ {
            in_profile_specific_block = 0
            next
        }
        !in_profile_specific_block && $0 ~ "^[[:space:]]*" package_name "([[:space:]]|#)" {
            print
        }
    ' "$DARWIN_CONFIG"
}

@test "bats is installed in shared system packages for every profile" {
    run common_package_lines bats
    [ "$status" -eq 0 ]
    [[ "$output" == *"bats"* ]]
}

@test "Bun is installed in shared system packages for every profile" {
    run common_package_lines bun
    [ "$status" -eq 0 ]
    [[ "$output" == *"bun"* ]]
}

@test "Xcode ships via mas only on the Power profile" {
    run bash -c "sed -n '/optionalAttrs (profileName == \"power\")/,/}/p' '$HOMEBREW_CONFIG' | rg '\"Xcode\" = 497799835'"
    [ "$status" -eq 0 ]

    run bash -c "sed -n '/masApps = /,/optionalAttrs/p' '$HOMEBREW_CONFIG' | rg '\"Xcode\"'"
    [ "$status" -eq 1 ]
}

@test "1Password CLI ships via Homebrew on the Power profile only" {
    # Homebrew, not Nix: FX verified the brew formula works with the desktop
    # app's biometric integration, and it is 1Password's own documented path.
    run bash -c "sed -n '/optionals (profileName == \"power\")/,/\]/p' '$HOMEBREW_CONFIG' | rg '\"1password-cli\"'"
    [ "$status" -eq 0 ]

    # Must not leak into the Nix system package set
    run rg -n '_1password-cli' "$DARWIN_CONFIG"
    [ "$status" -eq 1 ]

    run rg -n 'OP_BIOMETRIC_UNLOCK_ENABLED' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]
}

@test "the JDK ships only with the Power profile, with JAVA_HOME set" {
    run bash -c "sed -n '/lib.optionals isPowerProfile \[/,/^[[:space:]]*\]/p' '$DARWIN_CONFIG' | rg '^[[:space:]]+jdk([[:space:]]|#)'"
    [ "$status" -eq 0 ]

    run common_package_lines jdk
    [ "$output" = "" ]

    # A JDK on PATH without JAVA_HOME half-works: java runs, but Maven/Gradle
    # and IDE integrations that resolve the toolchain by env var do not.
    run rg -n 'JAVA_HOME' "$DARWIN_CONFIG"
    [ "$status" -eq 0 ]
}

@test "gitlab-runner ships only with the Power profile" {
    run bash -c "sed -n '/lib.optionals isPowerProfile \[/,/^[[:space:]]*\]/p' '$DARWIN_CONFIG' | rg '^[[:space:]]+gitlab-runner([[:space:]]|#)'"
    [ "$status" -eq 0 ]

    run common_package_lines gitlab-runner
    [ "$output" = "" ]
}
