#!/usr/bin/env bats
# ABOUTME: Regression tests for the supported Ollama and Apple-native MLX-LM runtimes
# ABOUTME: Prevents retired local inferencers from returning to declarative configuration

setup() {
    HOME_MANAGER_CONFIG="${BATS_TEST_DIRNAME}/../home-manager/home.nix"
    MLX_LM_MODULE="${BATS_TEST_DIRNAME}/../home-manager/modules/mlx-lm.nix"
    HOMEBREW_MODULE="${BATS_TEST_DIRNAME}/../darwin/homebrew.nix"
}

@test "home-manager imports the dedicated MLX-LM module" {
    run rg -n './modules/mlx-lm\.nix' "$HOME_MANAGER_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n './modules/local-code-bench\.nix' "$HOME_MANAGER_CONFIG"
    [ "$status" -eq 1 ]
}

@test "MLX-LM is pinned and limited to Apple Silicon" {
    run rg -n 'mlxLmVersion = "0\.21\.0";' "$MLX_LM_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'hostPlatform\.isDarwin.*hostPlatform\.isAarch64|hostPlatform\.isAarch64.*hostPlatform\.isDarwin' "$MLX_LM_MODULE"
    [ "$status" -eq 0 ]

    run rg -n '\.local/share/mlx-lm' "$MLX_LM_MODULE"
    [ "$status" -eq 0 ]

    run rg -n '"mlx-lm==\$\{mlxLmVersion\}"' "$MLX_LM_MODULE"
    [ "$status" -eq 0 ]
}

@test "MLX-LM exposes its supported commands" {
    for command_name in mlx_lm.generate mlx_lm.chat mlx_lm.server mlx_lm.convert mlx_lm.manage; do
        run rg -n "$command_name" "$MLX_LM_MODULE"
        [ "$status" -eq 0 ]
    done
}

@test "Ollama remains and retired inferencers are absent" {
    run rg -n '"ollama"' "$HOMEBREW_MODULE"
    [ "$status" -eq 0 ]

    run rg -n -i 'llama\.cpp|omlx|lm-studio|inferencer|dflash|turboquant|vllm-mlx|mtplx|mlc-llm|mlc-ai' \
        "$HOME_MANAGER_CONFIG" "$MLX_LM_MODULE" "$HOMEBREW_MODULE"
    [ "$status" -eq 1 ]
}
