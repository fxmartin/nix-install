#!/usr/bin/env bats
# ABOUTME: Guards bootstrap Ollama verification messaging against drifting from flake.nix
# ABOUTME: Ensures summary/rebuild output names the current per-profile models, not retired ones

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    SUMMARY_LIB="${REPO_ROOT}/lib/summary.sh"
    DARWIN_REBUILD_LIB="${REPO_ROOT}/lib/darwin-rebuild.sh"
    FLAKE_NIX="${REPO_ROOT}/flake.nix"
    # The generated artifact curl-installs actually download and execute; editing
    # lib/*.sh without rebuilding it leaves the shipped installer printing the old list.
    BOOTSTRAP_DIST="${REPO_ROOT}/bootstrap-dist.sh"
}

@test "summary.sh Ollama verification lists current Power profile models" {
    run rg -n "Expected: gemma4:e4b, gemma4:26b, qwen3.6:35b-a3b-coding-nvfp4, nomic-embed-text" "$SUMMARY_LIB"
    [ "$status" -eq 0 ]
}

@test "darwin-rebuild.sh Ollama verification lists current Power profile models" {
    run rg -n "Expected: gemma4:e4b, gemma4:26b, qwen3.6:35b-a3b-coding-nvfp4, nomic-embed-text" "$DARWIN_REBUILD_LIB"
    [ "$status" -eq 0 ]
}

@test "bootstrap-dist.sh Ollama verification lists current Power profile models" {
    run rg -c "Expected: gemma4:e4b, gemma4:26b, qwen3.6:35b-a3b-coding-nvfp4, nomic-embed-text" "$BOOTSTRAP_DIST"
    [ "$status" -eq 0 ]
    # Both the summary and darwin-rebuild call sites are concatenated into the dist.
    [ "$output" -eq 2 ]
}

@test "retired Ollama model names are absent from bootstrap output" {
    run rg -n "gpt-oss:20b|qwen2\.5-coder:32b|llama3\.1:70b|deepseek-r1:32b" \
        "$SUMMARY_LIB" "$DARWIN_REBUILD_LIB" "$BOOTSTRAP_DIST"
    [ "$status" -eq 1 ]
}

@test "Ollama verification messaging tracks flake.nix Power profile model list, not a hardcoded copy" {
    # Derive the expected list from flake.nix itself (the single source of truth
    # per its own comment at line 114) so this test fails loudly the next time
    # ollamaModels.power changes without the bootstrap messaging being updated,
    # instead of silently drifting like the retired gpt-oss/qwen2.5/llama3.1/deepseek-r1 set did.
    local power_models
    power_models=$(awk '/power = \[/{flag=1} flag{print} /ai-assistant = \[/{flag=0}' "$FLAKE_NIX" \
        | grep -oE 'name = "[^"]+"' | sed -E 's/name = "([^"]+)"/\1/')

    [ -n "$power_models" ]

    local expected_line
    expected_line=$(echo "$power_models" | paste -sd, - | sed 's/,/, /g')

    run rg -F "Expected: ${expected_line}" "$SUMMARY_LIB"
    [ "$status" -eq 0 ]

    run rg -F "Expected: ${expected_line}" "$DARWIN_REBUILD_LIB"
    [ "$status" -eq 0 ]

    run rg -F "Expected: ${expected_line}" "$BOOTSTRAP_DIST"
    [ "$status" -eq 0 ]
}
