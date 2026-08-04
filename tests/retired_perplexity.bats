#!/usr/bin/env bats
# ABOUTME: Guards retirement of the Perplexity Mac App Store app
# ABOUTME: Prevents the masApps entry, Dock slot, and documentation from returning

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    HOMEBREW_CONFIG="${REPO_ROOT}/darwin/homebrew.nix"
    MACOS_DEFAULTS="${REPO_ROOT}/darwin/macos-defaults.nix"
}

@test "Mac App Store no longer installs Perplexity" {
    run rg -n -i 'Perplexity|6714467650' "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]
}

@test "Dock no longer pins Perplexity" {
    run rg -n -i 'Perplexity' "$MACOS_DEFAULTS"
    [ "$status" -eq 1 ]
}

@test "current documentation no longer advertises Perplexity" {
    run rg -n -i 'perplexity' \
        "${REPO_ROOT}/README.md" \
        "${REPO_ROOT}/docs/REQUIREMENTS.md" \
        "${REPO_ROOT}/docs/apps/README.md" \
        "${REPO_ROOT}/docs/apps/ai/ai-llm-tools.md" \
        "${REPO_ROOT}/docs/apps/mac-app-store-requirements.md"
    [ "$status" -eq 1 ]
}

@test "retained Mac App Store apps remain declared" {
    # The retirement must not take the rest of masApps with it
    run rg -n '"Kindle" = 302584613' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n '"WhatsApp" = 310633997' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]
}
