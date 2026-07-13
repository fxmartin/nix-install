#!/usr/bin/env bats
# ABOUTME: Security regression tests for local service binding and pinned agents
# ABOUTME: Prevents unauthenticated management services and mutable binary downloads

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    HEALTH_MODULE="${REPO_ROOT}/darwin/health-api.nix"
    MAINTENANCE_MODULE="${REPO_ROOT}/darwin/maintenance.nix"
    MONITORING_MODULE="${REPO_ROOT}/darwin/monitoring.nix"
    OLLAMA_START="${REPO_ROOT}/scripts/start-ollama.sh"
}

@test "health API launch agent is explicitly loopback-only" {
    run rg -n 'HEALTH_API_HOST = "127\.0\.0\.1"' "$HEALTH_MODULE"
    [ "$status" -eq 0 ]
}

@test "health API security policy module is deployed with the service" {
    run grep '"health_api_security.py"' "${REPO_ROOT}/darwin/configuration.nix"
    [ "$status" -eq 0 ]
}

@test "Ollama launch agent and manual start are loopback-only" {
    run rg -n 'ollamaHost = "127\.0\.0\.1"' "$MAINTENANCE_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'OLLAMA_HOST:-127\.0\.0\.1' "$OLLAMA_START"
    [ "$status" -eq 0 ]

    run rg -n '0\.0\.0\.0|http://100\.\*' "$MAINTENANCE_MODULE" "$OLLAMA_START"
    [ "$status" -eq 1 ]
}

@test "Beszel runs from locked nixpkgs without activation downloads" {
    run rg -n '\$\{pkgs\.beszel\}/bin/beszel-agent' "$MONITORING_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'releases/latest|TARBALL_URL|curl .*tar' "$MONITORING_MODULE"
    [ "$status" -eq 1 ]
}
