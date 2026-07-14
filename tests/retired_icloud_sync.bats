#!/usr/bin/env bats
# ABOUTME: Guards retirement of the former LTM OneDrive-to-iCloud copy workflow
# ABOUTME: Keeps NAS backup support while preventing the corporate sync job from returning

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    FLAKE_FILE="${REPO_ROOT}/flake.nix"
    DARWIN_CONFIG="${REPO_ROOT}/darwin/configuration.nix"
    HEALTH_API="${REPO_ROOT}/scripts/health-api.py"
    HEALTH_CHECK="${REPO_ROOT}/scripts/health-check.sh"
    AGENT_AUDIT="${REPO_ROOT}/scripts/audit-launchagents.sh"
    BOOTSTRAP_FETCHER="${REPO_ROOT}/lib/nix-darwin.sh"
}

@test "Power profile no longer imports the iCloud sync module" {
    run rg -n 'icloud-sync' "$FLAKE_FILE" "$DARWIN_CONFIG"
    [ "$status" -eq 1 ]
}

@test "retired iCloud sync implementation files are absent" {
    [ ! -e "${REPO_ROOT}/darwin/icloud-sync.nix" ]
    [ ! -e "${REPO_ROOT}/scripts/icloud-sync.sh" ]
    [ ! -e "${REPO_ROOT}/config/icloud-sync-config.conf.template" ]
}

@test "health checks detect Power profile through NAS backup agents" {
    run rg -n 'org\.nixos\.rsync-backup-daily' "$HEALTH_API" "$HEALTH_CHECK"
    [ "$status" -eq 0 ]

    run rg -n 'org\.nixos\.icloud-sync|"icloud-sync"' "$HEALTH_API" "$HEALTH_CHECK" "$AGENT_AUDIT"
    [ "$status" -eq 1 ]
}

@test "bootstrap no longer fetches the retired module" {
    run rg -n 'icloud-sync\.nix' "$BOOTSTRAP_FETCHER"
    [ "$status" -eq 1 ]
}

@test "current profile documentation no longer advertises iCloud proposal sync" {
    run rg -n -i 'iCloud (proposal )?sync' \
        "${REPO_ROOT}/CLAUDE.md" \
        "${REPO_ROOT}/README.md" \
        "${REPO_ROOT}/docs/architecture.md"
    [ "$status" -eq 1 ]
}
