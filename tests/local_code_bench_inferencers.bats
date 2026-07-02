#!/usr/bin/env bats
# ABOUTME: Regression tests for power-profile local-code-bench inferencer deployment
# ABOUTME: Guards declarative install coverage while excluding intentionally skipped engines

setup() {
    HOME_MANAGER_MODULE="${BATS_TEST_DIRNAME}/../home-manager/modules/local-code-bench.nix"
    HOMEBREW_MODULE="${BATS_TEST_DIRNAME}/../darwin/homebrew.nix"
}

@test "power profile includes Homebrew-managed local-code-bench inferencers" {
    run rg -n '"jundot/omlx"' "$HOMEBREW_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'clone_target = "https://github.com/jundot/omlx";' "$HOMEBREW_MODULE"
    [ "$status" -eq 0 ]

    run rg -n '"llama.cpp"' "$HOMEBREW_MODULE"
    [ "$status" -eq 0 ]

    run rg -n '"omlx"' "$HOMEBREW_MODULE"
    [ "$status" -eq 0 ]

    run rg -n '"lm-studio"' "$HOMEBREW_MODULE"
    [ "$status" -eq 0 ]
}

@test "home-manager provisions Python local-code-bench inferencers for power profile" {
    run rg -n 'profileName == "power"' "$HOME_MANAGER_MODULE"
    [ "$status" -eq 0 ]

    run rg -n '"mlx-lm==\$\{mlxLmVersion\}"' "$HOME_MANAGER_MODULE"
    [ "$status" -eq 0 ]

    run rg -n '"vllm-mlx"' "$HOME_MANAGER_MODULE"
    [ "$status" -eq 0 ]

    run rg -n '"mtplx"' "$HOME_MANAGER_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'mlc-ai' "$HOME_MANAGER_MODULE"
    [ "$status" -eq 0 ]
}

@test "local-code-bench deployment keeps exo and GPT4All excluded" {
    run rg -n -i '(^|[^a-z])exo([^a-z]|$)|gpt4all' "$HOME_MANAGER_MODULE" "$HOMEBREW_MODULE"
    [ "$status" -eq 1 ]
}
