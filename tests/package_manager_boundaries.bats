#!/usr/bin/env bats
# ABOUTME: Guards canonical ownership of packages shared across configuration layers
# ABOUTME: Prevents duplicate binaries from returning through Nix, Home Manager, and Homebrew

setup() {
    DARWIN_CONFIG="${BATS_TEST_DIRNAME}/../darwin/configuration.nix"
    HOMEBREW_CONFIG="${BATS_TEST_DIRNAME}/../darwin/homebrew.nix"
    HOME_CONFIG="${BATS_TEST_DIRNAME}/../home-manager/home.nix"
    GIT_CONFIG="${BATS_TEST_DIRNAME}/../home-manager/modules/git.nix"
    HOME_MANAGER_DIR="${BATS_TEST_DIRNAME}/../home-manager"
    BOOTSTRAP_FETCHER="${BATS_TEST_DIRNAME}/../lib/nix-darwin.sh"
}

@test "Home Manager owned tools are absent from system packages" {
    for package_name in fzf bat btop; do
        run rg -n "^[[:space:]]+${package_name}[[:space:]]*(#.*)?$" "$DARWIN_CONFIG"
        [ "$status" -eq 1 ]
    done
}

@test "Home Manager configures Git without installing Git or Git LFS" {
    run rg -n '^[[:space:]]+package = null;' "$GIT_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n '^[[:space:]]+lfs\.package = null;' "$GIT_CONFIG"
    [ "$status" -eq 0 ]
}

@test "GitHub CLI is owned only by Homebrew" {
    run rg -n '"gh"[[:space:]]+# GitHub CLI' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'programs\.gh|modules/github\.nix' "$HOME_CONFIG" "$HOME_MANAGER_DIR/modules"
    [ "$status" -eq 1 ]

    run rg -n 'home-manager/modules/github\.nix' "$BOOTSTRAP_FETCHER"
    [ "$status" -eq 1 ]
}

@test "SDLC controller dependency is installed through Homebrew" {
    run rg -n '"osv-scanner"[[:space:]]+# OSV Scanner' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]
}

@test "Homebrew Starship bridge remains explicit" {
    run rg -n '"starship"[[:space:]]+# Starship prompt binary' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'exec /opt/homebrew/bin/starship' "$HOME_MANAGER_DIR/modules/shell.nix"
    [ "$status" -eq 0 ]
}
