#!/usr/bin/env bats
# ABOUTME: Behaviour tests for the LaunchAgent-driven NAS mount script (issue #407)
# ABOUTME: Covers mount idempotency, NAS-offline soft fail, and per-share failure isolation
# ABOUTME: Also guards the module against regressing to the autofs mechanism macOS 26 ignores

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    SMB_MODULE="${REPO_ROOT}/darwin/smb-automount.nix"
    MOUNT_SCRIPT="${REPO_ROOT}/scripts/smb-mount-nas.sh"

    # Sandbox HOME so nothing can reach the real user's dotfiles or NAS dir.
    export HOME="${BATS_TEST_TMPDIR}/home"
    STUB_DIR="${BATS_TEST_TMPDIR}/stubs"
    mkdir -p "${HOME}" "${STUB_DIR}"

    export SMB_MOUNT_CONFIG="${BATS_TEST_TMPDIR}/shares.conf"
    export SMB_MOUNT_PASSWORD_FILE="${BATS_TEST_TMPDIR}/password"

    MOUNT_ARGS="${BATS_TEST_TMPDIR}/mount_smbfs.args"
    MOUNT_TABLE="${BATS_TEST_TMPDIR}/mount.table"

    export PATH="${STUB_DIR}:${PATH}"

    write_config "Photos" "icloud" "calibre"
    printf 'secret\n' > "${SMB_MOUNT_PASSWORD_FILE}"
    : > "${MOUNT_TABLE}"
    stub_mount
    stub_nc 0
    stub_mount_smbfs 0
}

write_config() {
    {
        echo 'NAS_HOST="tnas.local"'
        echo 'SMB_USERNAME="fxmartin"'
        echo "MOUNT_ROOT=\"${HOME}/NAS\""
        echo 'SHARES=('
        for share in "$@"; do
            echo "  \"${share}\""
        done
        echo ')'
    } > "${SMB_MOUNT_CONFIG}"
}

# `mount` stub: prints whatever the fake mount table currently holds.
stub_mount() {
    {
        echo '#!/usr/bin/env bash'
        echo "cat '${MOUNT_TABLE}'"
    } > "${STUB_DIR}/mount"
    chmod +x "${STUB_DIR}/mount"
}

# `nc` stub: reachability probe result is whatever rc we are given.
stub_nc() {
    {
        echo '#!/usr/bin/env bash'
        echo "exit ${1}"
    } > "${STUB_DIR}/nc"
    chmod +x "${STUB_DIR}/nc"
}

# `mount_smbfs` stub: records its argv, optionally emits output, exits with rc.
# A share name may be passed to fail selectively.
stub_mount_smbfs() {
    local rc="$1" output="${2:-}" fail_share="${3:-}"
    {
        echo '#!/usr/bin/env bash'
        echo "printf '%s\\n' \"\$*\" >> '${MOUNT_ARGS}'"
        if [[ -n "${output}" ]]; then
            echo "printf '%s\\n' '${output}'"
        fi
        if [[ -n "${fail_share}" ]]; then
            echo "case \"\$*\" in *'/${fail_share}'*) exit ${rc} ;; esac"
            echo 'exit 0'
        else
            echo "exit ${rc}"
        fi
    } > "${STUB_DIR}/mount_smbfs"
    chmod +x "${STUB_DIR}/mount_smbfs"
}

mount_calls() {
    if [[ -f "${MOUNT_ARGS}" ]]; then
        wc -l < "${MOUNT_ARGS}" | tr -d ' '
    else
        echo 0
    fi
}

# ---------------------------------------------------------------------------
# Regression guard: the module must not mount via autofs any more
# ---------------------------------------------------------------------------

@test "module no longer generates an autofs map to mount shares" {
    # macOS 26 ignores custom /etc/auto_master maps entirely: `automount -vc`
    # exits 0, creates no triggers, and the shares silently never mount. Any
    # reintroduction of the map is a silent no-op, so fail loudly here.
    run grep -F 'cat > /etc/auto_master' "${SMB_MODULE}"
    [ "$status" -ne 0 ]

    run grep -F 'cat > /etc/auto_smb' "${SMB_MODULE}"
    [ "$status" -ne 0 ]

    run grep -F -- '-fstype=smbfs' "${SMB_MODULE}"
    [ "$status" -ne 0 ]
}

@test "module defines a user LaunchAgent that runs the mount script" {
    run grep -F 'launchd.user.agents.smb-mount-nas' "${SMB_MODULE}"
    [ "$status" -eq 0 ]

    run grep -F 'smb-mount-nas.sh' "${SMB_MODULE}"
    [ "$status" -eq 0 ]

    [ -x "${MOUNT_SCRIPT}" ]
}

@test "mount agent retries on a timer instead of thrashing under KeepAlive" {
    run grep -F 'RunAtLoad = true;' "${SMB_MODULE}"
    [ "$status" -eq 0 ]

    run grep -E 'StartInterval = [0-9]+;' "${SMB_MODULE}"
    [ "$status" -eq 0 ]

    # KeepAlive would respawn the one-shot script in a tight loop whenever the
    # NAS is unreachable.
    run grep -F 'KeepAlive = false;' "${SMB_MODULE}"
    [ "$status" -eq 0 ]
}

@test "activation removes the stale credentialed auto_smb map" {
    # The retired map held the NAS password in plaintext; the switch must clean
    # it up rather than leave it on disk forever.
    run grep -F 'rm -f /etc/auto_smb' "${SMB_MODULE}"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Happy path
# ---------------------------------------------------------------------------

@test "mounts every configured share under the mount root" {
    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [ "$(mount_calls)" -eq 3 ]

    run grep -F "//fxmartin:secret@tnas.local/Photos ${HOME}/NAS/Photos" "${MOUNT_ARGS}"
    [ "$status" -eq 0 ]
    run grep -F "//fxmartin:secret@tnas.local/icloud ${HOME}/NAS/icloud" "${MOUNT_ARGS}"
    [ "$status" -eq 0 ]
    run grep -F "//fxmartin:secret@tnas.local/calibre ${HOME}/NAS/calibre" "${MOUNT_ARGS}"
    [ "$status" -eq 0 ]
}

@test "creates the per-share mount point directories" {
    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [ -d "${HOME}/NAS/Photos" ]
    [ -d "${HOME}/NAS/icloud" ]
    [ -d "${HOME}/NAS/calibre" ]
}

# ---------------------------------------------------------------------------
# Idempotency
# ---------------------------------------------------------------------------

@test "skips shares that are already mounted" {
    printf '//fxmartin@tnas.local/Photos on %s/NAS/Photos (smbfs, nodev, nosuid)\n' \
        "${HOME}" > "${MOUNT_TABLE}"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [ "$(mount_calls)" -eq 2 ]

    run grep -F '/Photos' "${MOUNT_ARGS}"
    [ "$status" -ne 0 ]
}

@test "a second run with everything mounted issues no mount at all" {
    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [ "$(mount_calls)" -eq 3 ]

    # The mounts from the first run are now visible to `mount`.
    for share in Photos icloud calibre; do
        printf '//fxmartin@tnas.local/%s on %s/NAS/%s (smbfs, nodev, nosuid)\n' \
            "${share}" "${HOME}" "${share}" >> "${MOUNT_TABLE}"
    done

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [ "$(mount_calls)" -eq 3 ]
    [[ "$output" == *"already mounted"* ]]
}

@test "a mount point whose path is a prefix of another is not confused for it" {
    # " on <path> " is matched with the surrounding spaces so /NAS/Photos does
    # not satisfy the check for /NAS/Photos-Archive.
    write_config "Photos" "Photos-Archive"
    printf '//fxmartin@tnas.local/Photos on %s/NAS/Photos (smbfs)\n' "${HOME}" > "${MOUNT_TABLE}"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [ "$(mount_calls)" -eq 1 ]
    run grep -F "/Photos-Archive ${HOME}/NAS/Photos-Archive" "${MOUNT_ARGS}"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Error and edge paths
# ---------------------------------------------------------------------------

@test "NAS offline is a soft failure with no mount attempts" {
    stub_nc 1

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [ "$(mount_calls)" -eq 0 ]
    [[ "$output" == *"unreachable"* ]]
}

@test "one failing share does not stop the remaining shares from mounting" {
    stub_mount_smbfs 68 "mount_smbfs: server connection failed" "icloud"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [ "$(mount_calls)" -eq 3 ]
    [[ "$output" == *"✗ icloud: mount failed"* ]]
    [[ "$output" == *"✓ Photos mounted"* ]]
    [[ "$output" == *"✓ calibre mounted"* ]]
    [[ "$output" == *"1 failed mount(s)"* ]]
}

@test "missing password file fails with setup guidance and no mount attempt" {
    rm -f "${SMB_MOUNT_PASSWORD_FILE}"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 1 ]
    [ "$(mount_calls)" -eq 0 ]
    [[ "$output" == *"Password file not found"* ]]
    [[ "$output" == *".config/smb-nas/password"* ]]
}

@test "empty password file fails instead of mounting with an empty credential" {
    : > "${SMB_MOUNT_PASSWORD_FILE}"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 1 ]
    [ "$(mount_calls)" -eq 0 ]
    [[ "$output" == *"empty"* ]]
}

@test "missing config file fails with a rebuild hint" {
    rm -f "${SMB_MOUNT_CONFIG}"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 1 ]
    [ "$(mount_calls)" -eq 0 ]
    [[ "$output" == *"rebuild"* ]]
}

@test "config missing required keys fails rather than mounting a half-built URL" {
    printf 'NAS_HOST="tnas.local"\n' > "${SMB_MOUNT_CONFIG}"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 1 ]
    [ "$(mount_calls)" -eq 0 ]
    [[ "$output" == *"Incomplete config"* ]]
}

@test "config with an empty share list fails instead of silently doing nothing" {
    write_config

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 1 ]
    [ "$(mount_calls)" -eq 0 ]
    [[ "$output" == *"Incomplete config"* ]]
}
