#!/usr/bin/env bats
# ABOUTME: Regression tests for the sdlc controller installer's failure paths
# ABOUTME: This logic broke activation twice via unguarded set -e exits (issue #531)

setup() {
    INSTALL_SCRIPT="${BATS_TEST_DIRNAME}/../scripts/install-sdlc-controller.sh"
    CONTROLLER_DIR="${BATS_TEST_TMPDIR}/controller"
    mkdir -p "$CONTROLLER_DIR"
    BIN_DIR="${BATS_TEST_TMPDIR}/bin"
    mkdir -p "$BIN_DIR"
}

# A stub `uv` whose export/install behaviour is driven by env vars, so each
# failure path can be exercised without touching the real toolchain.
make_uv_stub() {
    cat >"${BIN_DIR}/uv" <<'STUB'
#!/usr/bin/env bash
case "$1" in
  export)
    [ "${STUB_EXPORT_FAILS:-0}" = "1" ] && exit 1
    echo "annotated-types==0.7.0"
    ;;
  tool)
    [ "${STUB_INSTALL_FAILS:-0}" = "1" ] && exit 1
    printf '%s\n' "$@" >"${STUB_ARGS_FILE:-/dev/null}"
    ;;
esac
exit 0
STUB
    chmod 755 "${BIN_DIR}/uv"
}

@test "installs pinned to uv.lock when export succeeds" {
    make_uv_stub
    ARGS="${BATS_TEST_TMPDIR}/args"
    run env UV_BIN="${BIN_DIR}/uv" STUB_ARGS_FILE="$ARGS" \
        bash "$INSTALL_SCRIPT" "$CONTROLLER_DIR"
    [ "$status" -eq 0 ]
    # The constraints flag is what pins the install to the lockfile.
    grep -q -- "-c" "$ARGS"
}

@test "missing controller directory fails with a clear message" {
    make_uv_stub
    run env UV_BIN="${BIN_DIR}/uv" \
        bash "$INSTALL_SCRIPT" "${BATS_TEST_TMPDIR}/does-not-exist"
    [ "$status" -eq 1 ]
    [[ "$output" == *"controller directory not found"* ]]
}

@test "export failure degrades to an unpinned install, not an abort" {
    make_uv_stub
    ARGS="${BATS_TEST_TMPDIR}/args"
    run env UV_BIN="${BIN_DIR}/uv" STUB_EXPORT_FAILS=1 STUB_ARGS_FILE="$ARGS" \
        bash "$INSTALL_SCRIPT" "$CONTROLLER_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"installing unpinned"* ]]
    # It must still have attempted the install rather than bailing out.
    grep -q "install" "$ARGS"
}

@test "install failure is reported as non-zero, not swallowed" {
    make_uv_stub
    run env UV_BIN="${BIN_DIR}/uv" STUB_INSTALL_FAILS=1 \
        bash "$INSTALL_SCRIPT" "$CONTROLLER_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"install failed"* ]]
}

@test "an unwritable TMPDIR does not abort the run" {
    # Reproduces the first activation break: an unguarded mktemp under set -e.
    make_uv_stub
    run env UV_BIN="${BIN_DIR}/uv" TMPDIR="${BATS_TEST_TMPDIR}/nonexistent-dir" \
        bash "$INSTALL_SCRIPT" "$CONTROLLER_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"installing unpinned"* ]]
}

@test "cleanup failure does not change the exit status" {
    # Reproduces the second break: `[ -n "$C" ] && rm -f "$C"` under set -e,
    # where a failing rm is the command after the final && and so exits.
    make_uv_stub
    cat >"${BIN_DIR}/rm" <<'STUB'
#!/usr/bin/env bash
exit 1
STUB
    chmod 755 "${BIN_DIR}/rm"
    run env PATH="${BIN_DIR}:$PATH" UV_BIN="${BIN_DIR}/uv" \
        bash "$INSTALL_SCRIPT" "$CONTROLLER_DIR"
    [ "$status" -eq 0 ]
}

@test "the nix module never lets the installer abort activation" {
    # The module must invoke the script inside an `if`, so any non-zero exit is
    # absorbed rather than taking down the whole rebuild.
    MODULE="${BATS_TEST_DIRNAME}/../home-manager/modules/sdlc-controller.nix"
    # The invocation is wrapped across lines with a trailing backslash, so flatten
    # the file before matching rather than grepping line-wise.
    run bash -c "tr '\n' ' ' < '$MODULE' | grep -Eq 'if [^;]{0,200}install-sdlc-controller\.sh'"
    [ "$status" -eq 0 ]
}
