#!/usr/bin/env bats
# ABOUTME: Credential-handling tests for the SMB NAS mount path (10.3-002, #396, #407)
# ABOUTME: The autofs map that used to hold the password is gone; nothing may replace it
# ABOUTME: Verifies the credential stays in memory and the URL-encoding stays complete

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    SMB_MODULE="${REPO_ROOT}/darwin/smb-automount.nix"
    MOUNT_SCRIPT="${REPO_ROOT}/scripts/smb-mount-nas.sh"

    export HOME="${BATS_TEST_TMPDIR}/home"
    STUB_DIR="${BATS_TEST_TMPDIR}/stubs"
    mkdir -p "${HOME}" "${STUB_DIR}"

    export SMB_MOUNT_CONFIG="${BATS_TEST_TMPDIR}/shares.conf"
    export SMB_MOUNT_PASSWORD_FILE="${BATS_TEST_TMPDIR}/password"
    MOUNT_TABLE="${BATS_TEST_TMPDIR}/mount.table"
    export PATH="${STUB_DIR}:${PATH}"

    {
        echo 'NAS_HOST="tnas.local"'
        echo 'SMB_USERNAME="fxmartin"'
        echo "MOUNT_ROOT=\"${HOME}/NAS\""
        echo 'SHARES=('
        echo '  "Photos"'
        echo ')'
    } > "${SMB_MOUNT_CONFIG}"

    : > "${MOUNT_TABLE}"
    {
        echo '#!/usr/bin/env bash'
        echo "cat '${MOUNT_TABLE}'"
    } > "${STUB_DIR}/mount"
    chmod +x "${STUB_DIR}/mount"

    {
        echo '#!/usr/bin/env bash'
        echo 'exit 0'
    } > "${STUB_DIR}/nc"
    chmod +x "${STUB_DIR}/nc"
}

# Extracts the shipped URL-encoding sed program so the assertions exercise the
# real expression rather than a hand-copied imitation of it.
url_encode_sed() {
    rg "URL_ENCODE_SED='" "${MOUNT_SCRIPT}" \
        | sed -E "s/^[^']*URL_ENCODE_SED='([^']*)'.*/\1/"
}

# mount_smbfs stub that succeeds and records nothing.
stub_mount_smbfs_ok() {
    {
        echo '#!/usr/bin/env bash'
        echo 'exit 0'
    } > "${STUB_DIR}/mount_smbfs"
    chmod +x "${STUB_DIR}/mount_smbfs"
}

# mount_smbfs stub that fails and echoes the URL it was handed back at the
# caller — the real binary does this on some parse errors, and the URL carries
# the credential.
stub_mount_smbfs_echoes_url() {
    {
        echo '#!/usr/bin/env bash'
        echo 'echo "mount_smbfs: could not parse $1"'
        echo 'exit 68'
    } > "${STUB_DIR}/mount_smbfs"
    chmod +x "${STUB_DIR}/mount_smbfs"
}

# ---------------------------------------------------------------------------
# The credential must never reach disk
# ---------------------------------------------------------------------------

@test "module writes no credentialed map file at all" {
    # /etc/auto_smb held the plaintext NAS password. macOS 26 ignores it, so it
    # was pure liability; nothing may reintroduce a credential-bearing file.
    run grep -F 'ENCODED_PASSWORD' "${SMB_MODULE}"
    [ "$status" -ne 0 ]

    run grep -F 'cat > /etc/auto_smb' "${SMB_MODULE}"
    [ "$status" -ne 0 ]
}

@test "module removes the stale credentialed map left by earlier releases" {
    run grep -F 'rm -f /etc/auto_smb' "${SMB_MODULE}"
    [ "$status" -eq 0 ]
}

@test "generated share config is owner-only and carries no credential" {
    run grep -F 'chmod 600 "${configFile}"' "${SMB_MODULE}"
    [ "$status" -eq 0 ]

    # The generated heredoc describes host/user/mount-root/shares only. Anything
    # password-shaped assigned inside it would be a credential on disk.
    local heredoc
    heredoc=$(awk '/SMB_SHARES_EOF.$/,/^ *SMB_SHARES_EOF$/' "${SMB_MODULE}")
    [ -n "$heredoc" ]
    [[ "$heredoc" == *'NAS_HOST='* ]]
    [[ "$heredoc" == *'SHARES=('* ]]
    [[ "$heredoc" != *'PASSWORD'* ]]
    [[ "$heredoc" != *'password'* ]]
}

@test "a successful mount run leaves no copy of the credential on disk" {
    stub_mount_smbfs_ok
    printf 'tr0ub4dor-and-3\n' > "${SMB_MOUNT_PASSWORD_FILE}"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]

    # Everything the run touched lives under BATS_TEST_TMPDIR. The only file
    # allowed to contain the password is the password file itself.
    local hits
    hits=$(grep -rlF 'tr0ub4dor-and-3' "${BATS_TEST_TMPDIR}" 2>/dev/null || true)
    [ "$hits" = "${SMB_MOUNT_PASSWORD_FILE}" ]
}

@test "the credential never appears in the script's log output" {
    stub_mount_smbfs_ok
    printf 'tr0ub4dor-and-3\n' > "${SMB_MOUNT_PASSWORD_FILE}"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [[ "$output" != *"tr0ub4dor-and-3"* ]]
}

@test "mount_smbfs output echoing the URL back is suppressed, not logged" {
    stub_mount_smbfs_echoes_url
    printf 'tr0ub4dor-and-3\n' > "${SMB_MOUNT_PASSWORD_FILE}"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [[ "$output" == *"mount failed"* ]]
    [[ "$output" == *"suppressed"* ]]
    [[ "$output" != *"tr0ub4dor-and-3"* ]]
}

@test "credential containing glob characters is still suppressed" {
    # A bash pattern match is only literal when the expansion is quoted. An
    # unquoted one would let '*' in the password match everything (or nothing)
    # and let the secret through.
    stub_mount_smbfs_echoes_url
    printf 'a*b[c]d\n' > "${SMB_MOUNT_PASSWORD_FILE}"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [[ "$output" == *"suppressed"* ]]
    [[ "$output" != *'a*b[c]d'* ]]
}

# ---------------------------------------------------------------------------
# URL-encoding (carried over from the autofs implementation, hardened in #396)
# ---------------------------------------------------------------------------

@test "URL-encode sed pipeline encodes percent first" {
    local line pct_idx at_idx
    line=$(rg "URL_ENCODE_SED='" "${MOUNT_SCRIPT}")
    pct_idx=$(awk -v l="$line" 'BEGIN{print index(l, "s/%/%25/g")}')
    at_idx=$(awk -v l="$line" 'BEGIN{print index(l, "s/@/%40/g")}')
    [ "$pct_idx" -gt 0 ]
    [ "$at_idx" -gt 0 ]
    [ "$pct_idx" -lt "$at_idx" ]
}

@test "URL-encode sed pipeline covers space, plus, and semicolon" {
    for token in 's/%/%25/g' 's/ /%20/g' 's/+/%2B/g' 's/;/%3B/g'; do
        run grep -F -- "$token" "${MOUNT_SCRIPT}"
        [ "$status" -eq 0 ]
    done
}

@test "URL-encode sed pipeline correctly encodes a password with %, space, +, and ;" {
    local sed_expr
    sed_expr=$(url_encode_sed)
    [ -n "$sed_expr" ]

    run bash -c 'echo "$1" | sed -e "$2"' _ 'p@ss:w/ord#1?a&b 100%+;free' "$sed_expr"
    [ "$status" -eq 0 ]
    [ "$output" = "p%40ss%3Aw%2Ford%231%3Fa%26b%20100%25%2B%3Bfree" ]
}

@test "URL-encode sed pipeline does not double-encode a literal percent sequence alongside a real @" {
    local sed_expr
    sed_expr=$(url_encode_sed)
    [ -n "$sed_expr" ]

    # A password already containing the literal text "%40" must have its '%'
    # encoded to %25 without corrupting the trailing "40", and the real '@'
    # must still become %40 — proving % is encoded before the other rules run.
    run bash -c 'echo "$1" | sed -e "$2"' _ 'user%40name@host' "$sed_expr"
    [ "$status" -eq 0 ]
    [ "$output" = "user%2540name%40host" ]
}

@test "URL-encode sed pipeline handles an empty password without error" {
    local sed_expr
    sed_expr=$(url_encode_sed)
    [ -n "$sed_expr" ]

    run bash -c 'echo "$1" | sed -e "$2"' _ '' "$sed_expr"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "a password with URL-special characters reaches mount_smbfs encoded" {
    # End-to-end proof that the encoding is actually applied to the URL rather
    # than merely defined: an unencoded '@' would truncate the host.
    local args_file="${BATS_TEST_TMPDIR}/mount_smbfs.args"
    {
        echo '#!/usr/bin/env bash'
        echo "printf '%s\\n' \"\$1\" > '${args_file}'"
        echo 'exit 0'
    } > "${STUB_DIR}/mount_smbfs"
    chmod +x "${STUB_DIR}/mount_smbfs"

    printf 'p@ss word\n' > "${SMB_MOUNT_PASSWORD_FILE}"

    run bash "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
    [ "$(cat "${args_file}")" = "//fxmartin:p%40ss%20word@tnas.local/Photos" ]
}

# ---------------------------------------------------------------------------
# Password-file contract (unchanged across the autofs -> LaunchAgent switch)
# ---------------------------------------------------------------------------

@test "password file path contract is still ~/.config/smb-nas/password" {
    run grep -F '.config/smb-nas/password' "${SMB_MODULE}"
    [ "$status" -eq 0 ]

    run grep -F '.config/smb-nas/password' "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
}

@test "the password file is read at mount time, not baked into the agent" {
    # The credential must not be interpolated into the LaunchAgent plist, which
    # is world-readable in ~/Library/LaunchAgents.
    run grep -F 'cat "$PASSWORD_FILE"' "${SMB_MODULE}"
    [ "$status" -ne 0 ]
    run grep -F 'RAW_PASSWORD' "${SMB_MODULE}"
    [ "$status" -ne 0 ]

    run grep -F 'PASSWORD_FILE' "${MOUNT_SCRIPT}"
    [ "$status" -eq 0 ]
}
