#!/usr/bin/env bats
# ABOUTME: Functional tests for the SMB NAS activation script body (issue #407)
# ABOUTME: Renders the real activation-script text via nix-instantiate and runs
# ABOUTME: it in a sandbox, rather than only grepping the Nix source for substrings

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    SMB_MODULE="${REPO_ROOT}/darwin/smb-automount.nix"

    SANDBOX="${BATS_TEST_TMPDIR}/sandbox"
    STUB_DIR="${BATS_TEST_TMPDIR}/stubs"
    mkdir -p "${SANDBOX}/etc" "${SANDBOX}/home" "${STUB_DIR}"

    export PATH="${STUB_DIR}:${PATH}"

    # `chown` needs a real group/root privileges the sandbox doesn't have, and
    # `automount` is a macOS system binary with nothing to reload here - both
    # are side effects the module fires for real hosts, not what this test is
    # verifying. Everything else in the rendered script runs unstubbed.
    for cmd in chown automount; do
        {
            echo '#!/usr/bin/env bash'
            echo 'exit 0'
        } > "${STUB_DIR}/${cmd}"
        chmod +x "${STUB_DIR}/${cmd}"
    done

    render_activation_script
}

# Evaluates the real Nix module with mock config/pkgs/lib/userConfig, extracts
# system.activationScripts.postActivation.text (the exact string nix-darwin
# runs on rebuild), then remaps its hardcoded absolute paths onto sandbox paths
# so the rendered bash can execute without touching /etc or a real home dir.
render_activation_script() {
    local eval_expr="${BATS_TEST_TMPDIR}/eval.nix"
    {
        echo 'let'
        echo '  pkgs = import <nixpkgs> {};'
        echo '  lib = pkgs.lib;'
        echo '  userConfig = { username = "testuser"; directories.dotfiles = "nix-install"; };'
        echo "  mod = import ${SMB_MODULE} { config = {}; inherit pkgs lib userConfig; };"
        echo 'in'
        echo '  mod.system.activationScripts.postActivation.text'
    } > "${eval_expr}"

    RENDERED="${BATS_TEST_TMPDIR}/activation.sh"
    nix-instantiate --eval --strict --json "${eval_expr}" | jq -r '.content' \
        | sed -e "s#/etc/auto_smb#${SANDBOX}/etc/auto_smb#g" \
              -e "s#/etc/auto_master#${SANDBOX}/etc/auto_master#g" \
              -e "s#/Users/testuser#${SANDBOX}/home#g" \
        > "${RENDERED}"

    CONFIG_FILE="${SANDBOX}/home/.config/smb-nas/shares.conf"
    PASSWORD_FILE="${SANDBOX}/home/.config/smb-nas/password"
    MOUNT_SCRIPT_SRC="${SANDBOX}/home/nix-install/scripts/smb-mount-nas.sh"
    MOUNT_SCRIPT_DEST="${SANDBOX}/home/.local/bin/smb-mount-nas.sh"
    MOUNT_ROOT="${SANDBOX}/home/NAS"
}

@test "activation renders as syntactically valid, non-empty bash" {
    [ -s "${RENDERED}" ]
    run bash -n "${RENDERED}"
    [ "$status" -eq 0 ]
}

@test "activation removes a stale auto_smb map and reports it" {
    printf 'auto_smb\n' > "${SANDBOX}/etc/auto_smb"

    run bash "${RENDERED}"
    [ "$status" -eq 0 ]
    [ ! -f "${SANDBOX}/etc/auto_smb" ]
    [[ "$output" == *"Removed stale"*"auto_smb"* ]]
}

@test "activation strips only the auto_smb line from auto_master, leaving others intact" {
    {
        echo '#'
        echo '# Automounter master map'
        echo '+auto_master'
        echo '/net -hosts'
        echo '/home auto_home'
        echo '/- auto_smb'
        echo '/-  auto_ci'
    } > "${SANDBOX}/etc/auto_master"

    run bash "${RENDERED}"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Removed auto_smb entry"* ]]

    run grep -F 'auto_smb' "${SANDBOX}/etc/auto_master"
    [ "$status" -ne 0 ]

    run grep -F '/net -hosts' "${SANDBOX}/etc/auto_master"
    [ "$status" -eq 0 ]
    run grep -F '/home auto_home' "${SANDBOX}/etc/auto_master"
    [ "$status" -eq 0 ]
    run grep -F 'auto_ci' "${SANDBOX}/etc/auto_master"
    [ "$status" -eq 0 ]
}

@test "activation leaves auto_master untouched when it has no auto_smb entry" {
    printf '/net -hosts\n' > "${SANDBOX}/etc/auto_master"

    run bash "${RENDERED}"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Removed auto_smb entry"* ]]
    [ "$(cat "${SANDBOX}/etc/auto_master")" = "/net -hosts" ]
}

@test "activation generates a credential-free, owner-only shares.conf" {
    run bash "${RENDERED}"
    [ "$status" -eq 0 ]
    [ -f "${CONFIG_FILE}" ]

    run /usr/bin/stat -f '%Lp' "${CONFIG_FILE}"
    [ "$status" -eq 0 ]
    [ "$output" = "600" ]

    run grep -F 'NAS_HOST="tnas.local"' "${CONFIG_FILE}"
    [ "$status" -eq 0 ]
    run grep -F 'SMB_USERNAME="testuser"' "${CONFIG_FILE}"
    [ "$status" -eq 0 ]
    run grep -F "MOUNT_ROOT=\"${MOUNT_ROOT}\"" "${CONFIG_FILE}"
    [ "$status" -eq 0 ]
    run grep -F '"Photos"' "${CONFIG_FILE}"
    [ "$status" -eq 0 ]
    run grep -F '"icloud"' "${CONFIG_FILE}"
    [ "$status" -eq 0 ]
    run grep -F '"calibre"' "${CONFIG_FILE}"
    [ "$status" -eq 0 ]

    run grep -iF 'password' "${CONFIG_FILE}"
    [ "$status" -ne 0 ]
}

@test "activation creates the mount root directory" {
    run bash "${RENDERED}"
    [ "$status" -eq 0 ]
    [ -d "${MOUNT_ROOT}" ]
}

@test "activation installs the mount script when the source file is present" {
    mkdir -p "$(dirname "${MOUNT_SCRIPT_SRC}")"
    printf '#!/usr/bin/env bash\necho stub\n' > "${MOUNT_SCRIPT_SRC}"
    chmod 644 "${MOUNT_SCRIPT_SRC}"

    run bash "${RENDERED}"
    [ "$status" -eq 0 ]
    [ -f "${MOUNT_SCRIPT_DEST}" ]
    [[ "$output" == *"installed to"* ]]

    run /usr/bin/stat -f '%Lp' "${MOUNT_SCRIPT_DEST}"
    [ "$status" -eq 0 ]
    [ "$output" = "755" ]
}

@test "activation warns instead of failing when the source script is absent" {
    [ ! -e "${MOUNT_SCRIPT_SRC}" ]

    run bash "${RENDERED}"
    [ "$status" -eq 0 ]
    [ ! -e "${MOUNT_SCRIPT_DEST}" ]
    [[ "$output" == *"smb-mount-nas.sh not found at"* ]]
}

@test "activation warns when the password file is missing" {
    [ ! -e "${PASSWORD_FILE}" ]

    run bash "${RENDERED}"
    [ "$status" -eq 0 ]
    [[ "$output" == *"WARNING: Password file not found"* ]]
}

@test "activation stays quiet about the password when it already exists" {
    mkdir -p "$(dirname "${PASSWORD_FILE}")"
    printf 'secret\n' > "${PASSWORD_FILE}"

    run bash "${RENDERED}"
    [ "$status" -eq 0 ]
    [[ "$output" != *"WARNING: Password file not found"* ]]
}
