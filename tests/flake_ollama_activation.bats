#!/usr/bin/env bats
# ABOUTME: Regression tests for Ollama activation behavior in flake.nix

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    FLAKE_FILE="${REPO_ROOT}/flake.nix"
}

@test "Ollama activation tracks daemon started during rebuild" {
    run rg -n "OLLAMA_STARTED_BY_ACTIVATION=0|OLLAMA_STARTED_BY_ACTIVATION=1" "${FLAKE_FILE}"

    [[ "${status}" -eq 0 ]]
    [[ "${output}" == *"OLLAMA_STARTED_BY_ACTIVATION=0"* ]]
    [[ "${output}" == *"OLLAMA_STARTED_BY_ACTIVATION=1"* ]]
}

@test "Ollama model pulls are disabled by default" {
    run rg -n "enableOllamaModelPulls or false|Skipping Ollama model check" "${FLAKE_FILE}"

    [[ "${status}" -eq 0 ]]
    [[ "${output}" == *"enableOllamaModelPulls or false"* ]]
    [[ "${output}" == *"Skipping Ollama model check"* ]]
}

@test "Ollama activation stops only temporary daemon after model check" {
    run rg -n 'if \[ "\$OLLAMA_STARTED_BY_ACTIVATION" = "1" \]|Stopping temporary Ollama daemon|/usr/bin/pkill -f "ollama serve"|/usr/bin/pkill -x ollama' "${FLAKE_FILE}"

    [[ "${status}" -eq 0 ]]
    [[ "${output}" == *'if [ "$OLLAMA_STARTED_BY_ACTIVATION" = "1" ]'* ]]
    [[ "${output}" == *"Stopping temporary Ollama daemon"* ]]
    [[ "${output}" == *'/usr/bin/pkill -f "ollama serve"'* ]]
    [[ "${output}" == *"/usr/bin/pkill -x ollama"* ]]
}
