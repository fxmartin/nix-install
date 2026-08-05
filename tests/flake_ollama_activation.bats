#!/usr/bin/env bats
# ABOUTME: Regression tests asserting a rebuild never touches Ollama.
#
# Ollama's lifecycle and model provisioning belong to the Local AI menubar
# app (home-manager/modules/local-ai-menubar.nix), which supervises
# `ollama serve` and pulls models on demand. A rebuild that starts, stops, or
# pulls behind the app's back would fight it: killing a supervised server
# trips the app's crash detection, and a KeepAlive agent makes its Stop
# button impossible to honour. These tests fail if any of that comes back.

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    FLAKE_FILE="${REPO_ROOT}/flake.nix"
    MAINTENANCE_FILE="${REPO_ROOT}/darwin/maintenance.nix"
}

@test "flake.nix never pulls Ollama models during activation" {
    run rg -n "ollama pull|ollamaModels|mkOllamaModelScript|enableOllamaModelPulls" "${FLAKE_FILE}"

    [[ "${status}" -ne 0 ]]
}

@test "flake.nix never starts or kills an Ollama server" {
    run rg -n "ollama serve|pkill -x ollama|OLLAMA_STARTED_BY_ACTIVATION" "${FLAKE_FILE}"

    [[ "${status}" -ne 0 ]]
}

@test "no always-on Ollama LaunchAgent is defined" {
    run rg -n "ollama-serve|enableOllamaServeAgent" "${MAINTENANCE_FILE}"

    [[ "${status}" -ne 0 ]]
}
