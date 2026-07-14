#!/usr/bin/env bats
# ABOUTME: Guards the rationalised font stack and its package-manager ownership
# ABOUTME: Prevents native or developer font duplicates from returning via Homebrew

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    HOMEBREW_CONFIG="${REPO_ROOT}/darwin/homebrew.nix"
    STYLIX_CONFIG="${REPO_ROOT}/darwin/stylix.nix"
}

@test "Homebrew does not install fonts" {
    run rg -n '"font-[^"]+"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]
}

@test "Stylix retains one developer font and distinct fallback roles" {
    run rg -n 'pkgs\.nerd-fonts\.jetbrains-mono' "$STYLIX_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'pkgs\.inter|pkgs\.source-serif|pkgs\.noto-fonts-color-emoji' "$STYLIX_CONFIG"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 3 ]
}

@test "developer applications consistently use JetBrains Mono" {
    run rg -l 'JetBrains ?Mono' \
        "${REPO_ROOT}/config/ghostty/config" \
        "${REPO_ROOT}/config/zed/settings.json"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
}

@test "current documentation does not advertise duplicate fonts" {
    run rg -n 'SF Pro|Hack Nerd Font' \
        "${REPO_ROOT}/README.md" \
        "${REPO_ROOT}/CLAUDE.md" \
        "${REPO_ROOT}/docs/architecture.md"
    [ "$status" -eq 1 ]
}
