#!/usr/bin/env bats
# ABOUTME: Guards the repo's "no auto-updates, rebuild is the only mechanism" principle
# ABOUTME: Casks that ship auto_updates must have their updater pinned off declaratively

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    HOMEBREW_CONFIG="${REPO_ROOT}/darwin/homebrew.nix"
    MACOS_DEFAULTS="${REPO_ROOT}/darwin/macos-defaults.nix"
}

@test "Homebrew neither auto-updates nor upgrades on its own" {
    run rg -n 'autoUpdate = false' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'upgrade = false' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'HOMEBREW_NO_AUTO_UPDATE = "1"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]
}

@test "self-updating casks have their updaters pinned off declaratively" {
    # cmux, stats and openusage all ship `auto_updates`, which would otherwise
    # bypass rebuild entirely. Toggling this in each app's settings panel is
    # machine-local and does not survive a fresh install, so it is declared.
    run rg -n '"com\.cmuxterm\.app"' "$MACOS_DEFAULTS"
    [ "$status" -eq 0 ]

    run rg -n '"com\.robinebers\.openusage"' "$MACOS_DEFAULTS"
    [ "$status" -eq 0 ]

    run rg -n '"eu\.exelban\.Stats"' "$MACOS_DEFAULTS"
    [ "$status" -eq 0 ]

    # Sparkle's automatic check must be off wherever it is declared
    run rg -n 'SUEnableAutomaticChecks = true' "$MACOS_DEFAULTS"
    [ "$status" -eq 1 ]
}
