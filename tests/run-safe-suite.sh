#!/usr/bin/env bash
# ABOUTME: Runs the deterministic repository test gate without host-mutating legacy suites
# ABOUTME: Keeps the required BATS set explicit so new tests are reviewed before execution

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

required_commands=(bats gitleaks python3)
for command_name in "${required_commands[@]}"; do
    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Required test dependency is missing: ${command_name}" >&2
        exit 1
    fi
done

safe_bats_suites=(
    tests/bootstrap_preflight.bats
    tests/claude_code_module.bats
    tests/communication_tooling.bats
    tests/darwin_system_packages.bats
    tests/flake_ollama_activation.bats
    tests/font_stack.bats
    tests/gitleaks-secrets.bats
    tests/mlx_lm_inferencer.bats
    tests/monitoring_stack.bats
    tests/network_security.bats
    tests/office_apps.bats
    tests/package_manager_boundaries.bats
    tests/rebuild_regressions.bats
    tests/release_monitor.bats
    tests/retired_desktop_utilities.bats
    tests/retired_icloud_sync.bats
    tests/retired_vscode.bats
    tests/tooling_baseline.bats
)

bats "${safe_bats_suites[@]}"
python3 -m unittest tests/test_health_api.py
bash tests/codex_sdlc_bridge_test.sh
bash tests/llm-inferencer-cleanup-test.sh
bash tests/release-management-test.sh
bash tests/setup-integrity-test.sh
