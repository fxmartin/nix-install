#!/usr/bin/env bats
# ABOUTME: Regression tests for safe flake update and release behavior
# ABOUTME: Ensures feature-branch updates do not stage release changes

setup() {
    UPDATE_SCRIPT="${BATS_TEST_DIRNAME}/../scripts/update-system.sh"
    STUB_BIN="${BATS_TEST_TMPDIR}/bin"
    GIT_ADD_MARKER="${BATS_TEST_TMPDIR}/git-add-called"
    mkdir -p "${STUB_BIN}"

    cat > "${STUB_BIN}/nix" <<'EOF'
#!/usr/bin/env bash
[[ "$*" == "flake update" ]]
EOF

    cat > "${STUB_BIN}/git" <<'EOF'
#!/usr/bin/env bash
case "$*" in
    "diff --quiet flake.lock")
        exit 1
        ;;
    "diff -- flake.lock")
        printf '%s\n' '-old lock input' '+new lock input'
        ;;
    "branch --show-current")
        printf '%s\n' 'fix/example'
        ;;
    "add flake.lock")
        touch "${GIT_ADD_MARKER}"
        ;;
    *)
        printf 'Unexpected git invocation: %s\n' "$*" >&2
        exit 2
        ;;
esac
EOF

    chmod +x "${STUB_BIN}/nix" "${STUB_BIN}/git"
}

@test "update skips the release commit before staging on feature branches" {
    run env PATH="${STUB_BIN}:${PATH}" GIT_ADD_MARKER="${GIT_ADD_MARKER}" \
        bash "${UPDATE_SCRIPT}" update

    [ "$status" -eq 0 ]
    [[ "$output" == *"Release commit skipped: must run on main, currently on fix/example"* ]]
    [[ "$output" != *"git add flake.lock"* ]]
    [ ! -e "${GIT_ADD_MARKER}" ]
}
