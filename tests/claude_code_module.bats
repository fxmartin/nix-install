#!/usr/bin/env bats
# ABOUTME: Regression tests for Claude Code / Codex Home Manager activation behavior
# ABOUTME: Guards Codex plugin marketplace registration so home-local plugins become available

@test "claude-code activation registers the home-local Codex marketplace" {
    run rg -n 'plugin marketplace add "\\$\\{config\\.home\\.homeDirectory\\}"' \
        "${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"
    [ "$status" -eq 0 ]
}

@test "claude-code activation still writes the home-local Codex marketplace manifest" {
    run rg -n 'CODEX_MARKETPLACE="\\$\\{config\\.home\\.homeDirectory\\}/\\.agents/plugins/marketplace\\.json"' \
        "${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"
    [ "$status" -eq 0 ]
}

@test "claude-code activation marks autonomous-sdlc installed by default" {
    run rg -n '"installation": "INSTALLED_BY_DEFAULT"' \
        "${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"
    [ "$status" -eq 0 ]
}
