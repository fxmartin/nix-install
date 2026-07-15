#!/usr/bin/env bats
# ABOUTME: Guards rsync backup scheduling, connectivity, and iCloud preparation
# ABOUTME: Uses command shims so resilience behavior is tested without host mutation

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    BACKUP_SCRIPT="${REPO_ROOT}/scripts/rsync-backup.sh"
    BACKUP_MODULE="${REPO_ROOT}/darwin/rsync-backup.nix"
    BACKUP_CONFIG="${REPO_ROOT}/rsync-backup-config.nix"
    TEST_ROOT="${BATS_TEST_TMPDIR}/rsync-backup-${BATS_TEST_NUMBER}"
    TEST_HOME="${TEST_ROOT}/home"
    SHIM_DIR="${TEST_ROOT}/bin"
    mkdir -p "$TEST_HOME" "$SHIM_DIR"
}

@test "backup script can be sourced without executing main" {
    run env \
        HOME="$TEST_HOME" \
        LOG_FILE="${TEST_ROOT}/backup.log" \
        RSYNC_BACKUP_TEST_MODE=1 \
        bash -c 'source "$1"; declare -F run_backup_job' _ "$BACKUP_SCRIPT"

    [ "$status" -eq 0 ]
    [[ "$output" == *"run_backup_job"* ]]
}

@test "iCloud preparation materializes only placeholders" {
    local icloud_root="${TEST_HOME}/Library/Mobile Documents/com~apple~CloudDocs"
    mkdir -p "$icloud_root"
    touch "$icloud_root/.remote.txt.icloud" "$icloud_root/local-a.txt" "$icloud_root/local-b.txt"

    cat > "${SHIM_DIR}/brctl" <<'SHIM'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$BRCTL_LOG"
target="$2"
placeholder="$(dirname "$target")/.$(basename "$target").icloud"
rm -f "$placeholder"
SHIM
    chmod +x "${SHIM_DIR}/brctl"

    run env \
        HOME="$TEST_HOME" \
        PATH="${SHIM_DIR}:${PATH}" \
        BRCTL_LOG="${TEST_ROOT}/brctl.log" \
        LOG_FILE="${TEST_ROOT}/backup.log" \
        ICLOUD_DOWNLOAD_TIMEOUT=1 \
        ICLOUD_DOWNLOAD_POLL_INTERVAL=0 \
        RSYNC_BACKUP_TEST_MODE=1 \
        bash -c 'source "$1"; ensure_icloud_downloaded "$2"' _ "$BACKUP_SCRIPT" "$icloud_root"

    [ "$status" -eq 0 ]
    [ "$(wc -l < "${TEST_ROOT}/brctl.log" | tr -d ' ')" -eq 1 ]
    run rg -n 'local-(a|b)\.txt' "${TEST_ROOT}/brctl.log"
    [ "$status" -eq 1 ]
}

@test "unresolved iCloud placeholders fail instead of producing a partial backup" {
    local icloud_root="${TEST_HOME}/Library/Mobile Documents/com~apple~CloudDocs"
    mkdir -p "$icloud_root"
    touch "$icloud_root/.remote.txt.icloud"

    cat > "${SHIM_DIR}/brctl" <<'SHIM'
#!/usr/bin/env bash
exit 0
SHIM
    chmod +x "${SHIM_DIR}/brctl"

    run env \
        HOME="$TEST_HOME" \
        PATH="${SHIM_DIR}:${PATH}" \
        LOG_FILE="${TEST_ROOT}/backup.log" \
        ICLOUD_DOWNLOAD_TIMEOUT=0 \
        ICLOUD_DOWNLOAD_POLL_INTERVAL=0 \
        RSYNC_BACKUP_TEST_MODE=1 \
        bash -c 'source "$1"; ensure_icloud_downloaded "$2"' _ "$BACKUP_SCRIPT" "$icloud_root"

    [ "$status" -eq 1 ]
    [[ "$output" == *"placeholder file(s) remain unavailable"* ]]
}

@test "daemon connectivity is rechecked for every transfer attempt" {
    mkdir -p "${TEST_HOME}/source" "${TEST_HOME}/.config/rsync-backup"
    printf 'secret\n' > "${TEST_HOME}/.config/rsync-backup/rsync.secret"

    cat > "${SHIM_DIR}/nc" <<'SHIM'
#!/usr/bin/env bash
printf 'nc\n' >> "$NC_LOG"
exit 1
SHIM
    cat > "${SHIM_DIR}/rsync" <<'SHIM'
#!/usr/bin/env bash
printf 'rsync\n' >> "$RSYNC_LOG"
exit 0
SHIM
    chmod +x "${SHIM_DIR}/nc" "${SHIM_DIR}/rsync"

    run env \
        HOME="$TEST_HOME" \
        PATH="${SHIM_DIR}:${PATH}" \
        NC_LOG="${TEST_ROOT}/nc.log" \
        RSYNC_LOG="${TEST_ROOT}/rsync.log" \
        LOG_FILE="${TEST_ROOT}/backup.log" \
        USE_RSYNC_DAEMON=true \
        NAS_HOST=tnas.test \
        RSYNC_USERNAME=rsync-user \
        RSYNC_PASSWORD_FILE="${TEST_HOME}/.config/rsync-backup/rsync.secret" \
        RSYNC_MAX_RETRIES=2 \
        RSYNC_RETRY_DELAY=0 \
        RSYNC_BACKUP_TEST_MODE=1 \
        bash -c 'source "$1"; run_backup_job "test|source|backup||"' _ "$BACKUP_SCRIPT"

    [ "$status" -eq 1 ]
    [ "$(wc -l < "${TEST_ROOT}/nc.log" | tr -d ' ')" -eq 2 ]
    [ ! -e "${TEST_ROOT}/rsync.log" ]
}

@test "rsync stderr detail is retained in the notification report" {
    mkdir -p "${TEST_HOME}/source" "${TEST_HOME}/.config/rsync-backup"
    printf 'secret\n' > "${TEST_HOME}/.config/rsync-backup/rsync.secret"

    cat > "${SHIM_DIR}/nc" <<'SHIM'
#!/usr/bin/env bash
exit 0
SHIM
    cat > "${SHIM_DIR}/rsync" <<'SHIM'
#!/usr/bin/env bash
echo 'rsync: failed to connect to tnas.test: No route to host' >&2
echo 'rsync error: error in socket IO (code 10)' >&2
exit 10
SHIM
    chmod +x "${SHIM_DIR}/nc" "${SHIM_DIR}/rsync"

    run env \
        HOME="$TEST_HOME" \
        PATH="${SHIM_DIR}:${PATH}" \
        LOG_FILE="${TEST_ROOT}/backup.log" \
        USE_RSYNC_DAEMON=true \
        NAS_HOST=tnas.test \
        RSYNC_USERNAME=rsync-user \
        RSYNC_PASSWORD_FILE="${TEST_HOME}/.config/rsync-backup/rsync.secret" \
        RSYNC_MAX_RETRIES=1 \
        RSYNC_RETRY_DELAY=0 \
        RSYNC_BACKUP_TEST_MODE=1 \
        bash -c 'source "$1"; run_backup_job "test|source|backup||" || true; printf "REPORT_START\n%s" "$REPORT_BUFFER"' _ "$BACKUP_SCRIPT"

    [ "$status" -eq 0 ]
    [[ "${output#*REPORT_START}" == *"No route to host"* ]]
}

@test "generated agents isolate logs and stagger weekly jobs" {
    run rg -n 'LOG_FILE = "/tmp/rsync-backup\$\{logSuffix\}\.log"' "$BACKUP_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'StandardOutPath = "/tmp/rsync-backup\$\{logSuffix\}\.stdout\.log"' "$BACKUP_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'StandardErrorPath = "/tmp/rsync-backup\$\{logSuffix\}\.stderr\.log"' "$BACKUP_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'Hour = rsyncConfig\.weeklySchedule\.Hour' "$BACKUP_MODULE"
    [ "$status" -eq 0 ]

    run rg -n -U 'weeklySchedule = \{\n\s+Hour = 3;\n\s+Minute = 0;' "$BACKUP_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'RSYNC_MAX_RETRIES="\$\{toString \(rsyncConfig\.maxRetries' "$BACKUP_MODULE"
    [ "$status" -eq 0 ]
}
