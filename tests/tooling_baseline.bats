#!/usr/bin/env bats
# ABOUTME: Guards the minimal global Python and Nix language-tooling baseline
# ABOUTME: Prevents duplicate tools, stale Homebrew placeholders, and retired inferencer claims

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    DARWIN_CONFIG="${REPO_ROOT}/darwin/configuration.nix"
    SHELL_CONFIG="${REPO_ROOT}/home-manager/modules/shell.nix"
    PYTHON_CONFIG="${REPO_ROOT}/home-manager/modules/python.nix"
    HOMEBREW_CONFIG="${REPO_ROOT}/darwin/homebrew.nix"
}

@test "global Python baseline contains Ruff and Pyright" {
    run rg -n '^\s+ruff\b|^\s+pyright\b' "$DARWIN_CONFIG"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
}

@test "duplicate global Python tools remain absent" {
    run rg -n '^\s+(black|python312Packages\.(isort|mypy|pylint))\b' "$DARWIN_CONFIG"
    [ "$status" -eq 1 ]

    run rg -n '\b(black|isort|mypy|pylint)\b' "$SHELL_CONFIG" "$PYTHON_CONFIG"
    [ "$status" -eq 1 ]
}

@test "nixd is the only global Nix language server" {
    run rg -n '^\s+nixd\b' "$DARWIN_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n '^\s+nil\b' "$DARWIN_CONFIG"
    [ "$status" -eq 1 ]
}

@test "Homebrew module contains no scaffolding placeholders" {
    run rg -n -i 'stub|epic-02 will|will populate|will expand|minimal install' "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]
}

@test "current AI documentation lists no retired inferencers" {
    run rg -n -i 'lm studio|lm-studio|omlx|vllm-mlx|dflash|turboquant|mtplx|local-code-bench' \
        "${REPO_ROOT}/docs/apps/ai/ai-llm-tools.md" \
        "${REPO_ROOT}/docs/apps/README.md"
    [ "$status" -eq 1 ]
}

@test "current Python documentation describes the minimal baseline" {
    run rg -n '\b(black|isort|mypy|pylint)\b' \
        "${REPO_ROOT}/README.md" \
        "${REPO_ROOT}/docs/REQUIREMENTS.md" \
        "${REPO_ROOT}/docs/apps/dev/python-tools.md" \
        "${REPO_ROOT}/docs/architecture.md"
    [ "$status" -eq 1 ]
}
