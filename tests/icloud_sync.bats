#!/usr/bin/env bats
# ABOUTME: Tests iCloud sync script guardrails and LaunchAgent scheduling
# ABOUTME: Keeps iCloud sync failures actionable without touching real CloudDocs data

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    TEST_HOME="${BATS_TEST_TMPDIR}/home"
    TEST_BIN="${BATS_TEST_TMPDIR}/bin"
    SOURCE_DIR="${BATS_TEST_TMPDIR}/source"

    mkdir -p "${TEST_HOME}/.config/icloud-sync"
    mkdir -p "${TEST_BIN}"
    mkdir -p "${SOURCE_DIR}"

    export HOME="${TEST_HOME}"
    export PATH="${TEST_BIN}:${PATH}"
    export SOURCE_DIR

    printf 'content\n' > "${SOURCE_DIR}/file.txt"

    cat > "${TEST_BIN}/rsync" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${RSYNC_CALL_LOG}"
exit 0
EOF
    chmod +x "${TEST_BIN}/rsync"

    RSYNC_CALL_LOG="${BATS_TEST_TMPDIR}/rsync.log"
    export RSYNC_CALL_LOG
}

@test "icloud-sync rejects destinations outside iCloud Drive" {
    cat > "${HOME}/.config/icloud-sync/config.conf" <<EOF
JOBS=(
  "bad|${SOURCE_DIR}|${BATS_TEST_TMPDIR}/outside|archive"
)
EOF

    run "${REPO_ROOT}/scripts/icloud-sync.sh"

    [[ "${status}" -ne 0 ]]
    [[ "${output}" == *"Destination must be inside iCloud Drive"* ]]
    [[ ! -f "${RSYNC_CALL_LOG}" ]]
}

@test "icloud-sync fails before creating destination when iCloud Drive is unavailable" {
    local dest="${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Documents/test"
    cat > "${HOME}/.config/icloud-sync/config.conf" <<EOF
JOBS=(
  "missing-icloud|${SOURCE_DIR}|${dest}|archive"
)
EOF

    run "${REPO_ROOT}/scripts/icloud-sync.sh"

    [[ "${status}" -ne 0 ]]
    [[ "${output}" == *"iCloud Drive is not available"* ]]
    [[ ! -d "${dest}" ]]
    [[ ! -f "${RSYNC_CALL_LOG}" ]]
}

@test "icloud-sync runs rsync for valid iCloud destinations" {
    local cloud_docs="${HOME}/Library/Mobile Documents/com~apple~CloudDocs"
    local dest="${cloud_docs}/Documents/test"
    mkdir -p "${cloud_docs}"
    cat > "${HOME}/.config/icloud-sync/config.conf" <<EOF
JOBS=(
  "valid|${SOURCE_DIR}|${dest}|archive"
)
EOF

    run "${REPO_ROOT}/scripts/icloud-sync.sh"

    [[ "${status}" -eq 0 ]]
    [[ "${output}" == *"All syncs completed successfully"* ]]
    [[ -f "${RSYNC_CALL_LOG}" ]]
    [[ "$(cat "${RSYNC_CALL_LOG}")" == *"${SOURCE_DIR}/ ${dest}/"* ]]
}

@test "iCloud LaunchAgent catches up after load and repeats while awake" {
    run rg -n "RunAtLoad = true|StartInterval = 21600" "${REPO_ROOT}/darwin/icloud-sync.nix"

    [[ "${status}" -eq 0 ]]
    [[ "${output}" == *"RunAtLoad = true"* ]]
    [[ "${output}" == *"StartInterval = 21600"* ]]
}
