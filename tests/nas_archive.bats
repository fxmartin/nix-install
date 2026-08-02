#!/usr/bin/env bats
# ABOUTME: Story 11.1-002 - argument validation and refusal-path tests for nas-archive.sh
# ABOUTME: Hermetic - stubs du/df and uses a temp staging dir, never touches the real NAS

setup() {
    SCRIPT="${BATS_TEST_DIRNAME}/../scripts/nas-archive.sh"
    STAGING_DIR="${BATS_TEST_TMPDIR}/staging"
    SOURCE_DIR="${BATS_TEST_TMPDIR}/source"
    STUB_BIN="${BATS_TEST_TMPDIR}/bin"

    mkdir -p "${STAGING_DIR}" "${SOURCE_DIR}" "${STUB_BIN}"
    echo "hello" > "${SOURCE_DIR}/file.txt"
}

run_nas_archive() {
    run env PATH="${STUB_BIN}:${PATH}" NAS_ARCHIVE_STAGING_DIR="${STAGING_DIR}" \
        "${SCRIPT}" "$@"
}

# =============================================================================
# Argument validation
# =============================================================================

@test "no subcommand prints usage and exits non-zero" {
    run_nas_archive
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage: nas-archive.sh bundle"* ]]
}

@test "--help prints usage and exits 0" {
    run_nas_archive --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: nas-archive.sh bundle"* ]]
}

@test "unknown subcommand is rejected" {
    run_nas_archive upload some-archive
    [ "$status" -eq 1 ]
    [[ "$output" == *"unknown subcommand: upload"* ]]
}

@test "bundle with missing archive-name argument is rejected" {
    run_nas_archive bundle "${SOURCE_DIR}"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage: nas-archive.sh bundle"* ]]
}

@test "bundle with missing source-dir argument is rejected" {
    run_nas_archive bundle
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage: nas-archive.sh bundle"* ]]
}

@test "bundle refuses a source directory that does not exist" {
    run_nas_archive bundle "${BATS_TEST_TMPDIR}/does-not-exist" my-archive
    [ "$status" -eq 1 ]
    [[ "$output" == *"source directory does not exist"* ]]
}

@test "bundle refuses an archive name with a path separator" {
    run_nas_archive bundle "${SOURCE_DIR}" "../escape"
    [ "$status" -eq 1 ]
    [[ "$output" == *"archive name must contain only letters, numbers, dots, dashes, underscores"* ]]
}

@test "bundle refuses an archive name with a space" {
    run_nas_archive bundle "${SOURCE_DIR}" "bad name"
    [ "$status" -eq 1 ]
    [[ "$output" == *"archive name must contain only letters, numbers, dots, dashes, underscores"* ]]
}

# =============================================================================
# Refusal paths (AC: no silent overwrite, staging free-space guard)
# =============================================================================

@test "bundle aborts without overwriting an existing archive" {
    touch "${STAGING_DIR}/my-archive.tar.zst"

    run_nas_archive bundle "${SOURCE_DIR}" my-archive
    [ "$status" -eq 1 ]
    [[ "$output" == *"bundle already exists, refusing to overwrite"* ]]

    # Original (empty) archive must be untouched, not silently replaced.
    [ ! -s "${STAGING_DIR}/my-archive.tar.zst" ]
}

@test "bundle aborts when staging free space is less than source size" {
    cat > "${STUB_BIN}/du" <<'EOF'
#!/usr/bin/env bash
echo "999999999	fake-source"
EOF
    cat > "${STUB_BIN}/df" <<'EOF'
#!/usr/bin/env bash
printf 'Filesystem 1024-blocks Used Available Capacity Mounted-on\n'
printf 'fake 1000 900 100 90%% /fake\n'
EOF
    chmod +x "${STUB_BIN}/du" "${STUB_BIN}/df"

    run_nas_archive bundle "${SOURCE_DIR}" my-archive
    [ "$status" -eq 1 ]
    [[ "$output" == *"insufficient staging free space"* ]]

    # No partial archive should be left behind.
    [ ! -e "${STAGING_DIR}/my-archive.tar.zst" ]
}

@test "bundle creates the staging directory before running the free-space check" {
    STAGING_DIR="${BATS_TEST_TMPDIR}/nested/staging"
    cat > "${STUB_BIN}/du" <<'EOF'
#!/usr/bin/env bash
echo "999999999	fake-source"
EOF
    cat > "${STUB_BIN}/df" <<'EOF'
#!/usr/bin/env bash
printf 'Filesystem 1024-blocks Used Available Capacity Mounted-on\n'
printf 'fake 1000 900 100 90%% /fake\n'
EOF
    chmod +x "${STUB_BIN}/du" "${STUB_BIN}/df"

    run_nas_archive bundle "${SOURCE_DIR}" my-archive
    [ "$status" -eq 1 ]
    [ -d "${STAGING_DIR}" ]
}

@test "bundle aborts when du cannot determine source size" {
    cat > "${STUB_BIN}/du" <<'EOF'
#!/usr/bin/env bash
echo ""
EOF
    chmod +x "${STUB_BIN}/du"

    run_nas_archive bundle "${SOURCE_DIR}" my-archive
    [ "$status" -eq 1 ]
    [[ "$output" == *"could not determine source size"* ]]
}

@test "bundle aborts when df cannot determine free space" {
    cat > "${STUB_BIN}/df" <<'EOF'
#!/usr/bin/env bash
printf 'Filesystem 1024-blocks Used Available Capacity Mounted-on\n'
EOF
    chmod +x "${STUB_BIN}/df"

    run_nas_archive bundle "${SOURCE_DIR}" my-archive
    [ "$status" -eq 1 ]
    [[ "$output" == *"could not determine free space"* ]]
}

# =============================================================================
# Happy path (bundle creation) - tar/zstd stubbed since BSD tar on the
# macOS test host does not understand GNU tar's -I compress-program syntax;
# the real GNU-tooling path runs on the NAS and is covered manually there.
# =============================================================================

stub_tar() {
    cat > "${STUB_BIN}/tar" <<'EOF'
#!/usr/bin/env bash
args=("$@")
for i in "${!args[@]}"; do
    if [[ "${args[$i]}" == "-cf" ]]; then
        touch "${args[$((i+1))]}"
        exit 0
    elif [[ "${args[$i]}" == "-tf" ]]; then
        printf './file.txt\n'
        exit 0
    fi
done
exit 1
EOF
    chmod +x "${STUB_BIN}/tar"
}

@test "bundle happy path writes archive, checksum manifest, and filelist" {
    stub_tar

    run_nas_archive bundle "${SOURCE_DIR}" my-archive
    [ "$status" -eq 0 ]
    [[ "$output" == *"Bundle complete:"* ]]
    [ -e "${STAGING_DIR}/my-archive.tar.zst" ]
    [ -e "${STAGING_DIR}/my-archive.sha256" ]
    [ -e "${STAGING_DIR}/my-archive.filelist.txt.zst" ]
    grep -q 'my-archive.tar.zst' "${STAGING_DIR}/my-archive.sha256"
}

@test "bundle proceeds when free space exactly equals source size" {
    cat > "${STUB_BIN}/du" <<'EOF'
#!/usr/bin/env bash
echo "100	fake-source"
EOF
    cat > "${STUB_BIN}/df" <<'EOF'
#!/usr/bin/env bash
printf 'Filesystem 1024-blocks Used Available Capacity Mounted-on\n'
printf 'fake 1000 900 100 90%% /fake\n'
EOF
    chmod +x "${STUB_BIN}/du" "${STUB_BIN}/df"
    stub_tar

    run_nas_archive bundle "${SOURCE_DIR}" boundary-archive
    [ "$status" -eq 0 ]
    [[ "$output" == *"Bundle complete:"* ]]
}
