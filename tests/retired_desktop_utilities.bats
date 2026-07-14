#!/usr/bin/env bats
# ABOUTME: Guards retirement of redundant macOS desktop utilities
# ABOUTME: Prevents f.lux, Amphetamine, and OnyX from returning to managed profiles

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    HOMEBREW_CONFIG="${REPO_ROOT}/darwin/homebrew.nix"
}

@test "Homebrew no longer installs f.lux or OnyX" {
    run rg -n '"flux-app"|"onyx"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]
}

@test "Mac App Store no longer installs Amphetamine" {
    run rg -n 'Amphetamine|937984704' "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]
}

@test "current documentation no longer advertises retired utilities" {
    run rg -n -i 'flux-app|f\.lux|amphetamine|onyx' \
        "${REPO_ROOT}/README.md" \
        "${REPO_ROOT}/docs/REQUIREMENTS.md" \
        "${REPO_ROOT}/docs/apps/README.md" \
        "${REPO_ROOT}/docs/apps/productivity/system-utilities.md" \
        "${REPO_ROOT}/docs/customization.md"
    [ "$status" -eq 1 ]
}

@test "Stream Deck documentation remains available" {
    run rg -n 'Stream Deck' "${REPO_ROOT}/docs/apps/productivity/system-utilities.md"
    [ "$status" -eq 0 ]
}
