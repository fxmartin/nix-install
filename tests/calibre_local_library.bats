#!/usr/bin/env bats
# ABOUTME: Guards Calibre against File Provider database hangs and stale global settings
# ABOUTME: Keeps the active library local while preserving declarative plugins and NAS backup

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    CALIBRE_MODULE="${REPO_ROOT}/darwin/calibre.nix"
    CALIBRE_CONFIG="${REPO_ROOT}/config/calibre"
    BACKUP_CONFIG="${REPO_ROOT}/rsync-backup-config.nix"
    CALIBRE_DOCS="${REPO_ROOT}/docs/apps/productivity/file-utilities.md"
}

@test "Calibre library and database stay outside iCloud Drive" {
    run rg -n 'source = "Calibre Library";' "$BACKUP_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'Mobile Documents.*Calibre Library' "$BACKUP_CONFIG" "$CALIBRE_DOCS"
    [ "$status" -eq 1 ]
}

@test "daily NAS backup preserves the complete Calibre library" {
    run rg -n 'share = "calibre";' "$BACKUP_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'schedule = "daily";' "$BACKUP_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n '"\.calnotes"' "$BACKUP_CONFIG"
    [ "$status" -eq 1 ]
}

@test "rebuild does not deploy volatile Calibre global settings" {
    [ ! -e "${CALIBRE_CONFIG}/global.py.json" ]

    run rg -n 'global\.py\.json|global settings deployed' "$CALIBRE_MODULE"
    [ "$status" -eq 1 ]
}

@test "declarative plugins and external secrets remain supported" {
    run rg -n 'cp -r "\$CALIBRE_SRC/plugins"/\*' "$CALIBRE_MODULE"
    [ "$status" -eq 0 ]

    run rg -n '\.config/calibre-secrets' "$CALIBRE_MODULE"
    [ "$status" -eq 0 ]
}

@test "documentation keeps machine-specific global state out of Git" {
    run rg -n 'cp .*global\.py\.json.*config/calibre' "$CALIBRE_DOCS"
    [ "$status" -eq 1 ]

    run rg -n '~/Calibre Library' "$CALIBRE_DOCS"
    [ "$status" -eq 0 ]
}
