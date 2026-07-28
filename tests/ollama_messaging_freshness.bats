#!/usr/bin/env bats
# ABOUTME: Guards bootstrap Ollama verification messaging against drifting from flake.nix
# ABOUTME: Ensures summary/rebuild output names the current per-profile models, not retired ones

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    SUMMARY_LIB="${REPO_ROOT}/lib/summary.sh"
    DARWIN_REBUILD_LIB="${REPO_ROOT}/lib/darwin-rebuild.sh"
}

@test "summary.sh Ollama verification lists current Power profile models" {
    run rg -n "Expected: gemma4:e4b, gemma4:26b, nomic-embed-text" "$SUMMARY_LIB"
    [ "$status" -eq 0 ]
}

@test "darwin-rebuild.sh Ollama verification lists current Power profile models" {
    run rg -n "Expected: gemma4:e4b, gemma4:26b, nomic-embed-text" "$DARWIN_REBUILD_LIB"
    [ "$status" -eq 0 ]
}

@test "retired Ollama model names are absent from bootstrap output" {
    run rg -n "gpt-oss:20b|qwen2\.5-coder:32b|llama3\.1:70b|deepseek-r1:32b" \
        "$SUMMARY_LIB" "$DARWIN_REBUILD_LIB"
    [ "$status" -eq 1 ]
}
