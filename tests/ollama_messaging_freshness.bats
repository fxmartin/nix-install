#!/usr/bin/env bats
# ABOUTME: Guards bootstrap Ollama messaging against promising models a rebuild never pulls
# ABOUTME: Model provisioning moved to the Local AI menubar app; no expected list may be advertised
#
# This file used to assert the opposite: that the bootstrap output named the
# exact per-profile model list from flake.nix's `ollamaModels`. That list is
# gone — a rebuild no longer starts Ollama or downloads anything, because the
# menubar app supervises the server and pulls on demand. Messaging that still
# said "Expected: <models>" would send the user to `ollama list` to look for
# models nothing had promised to install.

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    SUMMARY_LIB="${REPO_ROOT}/lib/summary.sh"
    DARWIN_REBUILD_LIB="${REPO_ROOT}/lib/darwin-rebuild.sh"
    # The generated artifact curl-installs actually download and execute; editing
    # lib/*.sh without rebuilding it leaves the shipped installer printing the old list.
    BOOTSTRAP_DIST="${REPO_ROOT}/bootstrap-dist.sh"
}

@test "bootstrap output advertises no expected Ollama model list" {
    run rg -n "Expected: .*(gemma4|qwen|nomic-embed|ministral)" \
        "$SUMMARY_LIB" "$DARWIN_REBUILD_LIB" "$BOOTSTRAP_DIST"
    [ "$status" -eq 1 ]
}

@test "retired Ollama model names are absent from bootstrap output" {
    run rg -n "gpt-oss:20b|qwen2\.5-coder:32b|llama3\.1:70b|deepseek-r1:32b" \
        "$SUMMARY_LIB" "$DARWIN_REBUILD_LIB" "$BOOTSTRAP_DIST"
    [ "$status" -eq 1 ]
}

@test "bootstrap output points at the menubar app for model pulls" {
    run rg -n "Local AI menubar app" "$SUMMARY_LIB"
    [ "$status" -eq 0 ]

    run rg -n "Local AI menubar app" "$DARWIN_REBUILD_LIB"
    [ "$status" -eq 0 ]
}
