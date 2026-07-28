#!/usr/bin/env bats
# ABOUTME: Guards scripts/smoke-test-clone.sh (Story 10.1-003), the scratch-clone
# ABOUTME: eval that catches file-list drift a local `nix-eval` run cannot see

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
    SCRIPT="${REPO_ROOT}/scripts/smoke-test-clone.sh"

    TEST_ROOT="$(mktemp -d)"
    export TEST_ROOT
    GIT_CALLS="${TEST_ROOT}/git-calls.log"
    NIX_CALLS="${TEST_ROOT}/nix-calls.log"
    export GIT_CALLS NIX_CALLS
    : > "${GIT_CALLS}"
    : > "${NIX_CALLS}"

    FAKE_HEAD_SHA="deadbeefcafefeedfacefeed00000000deadbeef"
    export FAKE_HEAD_SHA
}

teardown() {
    unset -f git nix mktemp 2>/dev/null || true
    if [[ -n "${TEST_ROOT:-}" && -d "${TEST_ROOT}" ]]; then
        rm -rf "${TEST_ROOT}"
    fi
}

# Fakes a successful clone: `clone` creates the destination so the script's
# later `cd` succeeds, `rev-parse` returns a fixed HEAD so no ref is required.
mock_git_success() {
    git() {
        echo "git $*" >> "${GIT_CALLS}"
        case " $* " in
        *" clone "*)
            mkdir -p "${*: -1}"
            ;;
        *" rev-parse "*)
            echo "${FAKE_HEAD_SHA}"
            ;;
        esac
        return 0
    }
    export -f git
}

mock_git_clone_fails() {
    git() {
        echo "git $*" >> "${GIT_CALLS}"
        if [[ " $* " == *" clone "* ]]; then
            # A real failed clone can leave a partially populated destination
            # behind, so create it here too. Without it the script would stop
            # merely because the later `cd` hit a missing directory, and the
            # test would stay green even if clone's exit status were ignored.
            mkdir -p "${*: -1}"
            return 128
        fi
        [[ " $* " == *" rev-parse "* ]] && echo "${FAKE_HEAD_SHA}"
        return 0
    }
    export -f git
}

mock_nix_success() {
    nix() {
        echo "nix $*" >> "${NIX_CALLS}"
        return 0
    }
    export -f nix
}

# Fails only for the profile named in NIX_FAIL_PROFILE so tests can prove the
# loop stops instead of silently continuing past a broken profile.
mock_nix_fails_for() {
    NIX_FAIL_PROFILE="$1"
    export NIX_FAIL_PROFILE
    nix() {
        echo "nix $*" >> "${NIX_CALLS}"
        if [[ "$*" == *"${NIX_FAIL_PROFILE}"* ]]; then
            return 1
        fi
        return 0
    }
    export -f nix
}

# macOS `/usr/bin/mktemp` takes its default directory from
# _CS_DARWIN_USER_TEMP_DIR and ignores $TMPDIR, so exporting TMPDIR cannot
# steer the script's scratch directory. Mocking mktemp is what makes the
# scratch path observable; asserting on a TMPDIR the script never honours is
# vacuous and stays green even with the script's EXIT trap deleted.
mock_mktemp() {
    SCRATCH_PARENT="${TEST_ROOT}/scratch"
    MKTEMP_LOG="${TEST_ROOT}/mktemp.log"
    export SCRATCH_PARENT MKTEMP_LOG
    mkdir -p "${SCRATCH_PARENT}"
    : > "${MKTEMP_LOG}"
    mktemp() {
        local scratch="${SCRATCH_PARENT}/scratch.$$"
        mkdir -p "${scratch}"
        echo "${scratch}" >> "${MKTEMP_LOG}"
        echo "${scratch}"
    }
    export -f mktemp
}

@test "smoke-test-clone.sh exists, is executable, and uses strict mode" {
    [ -x "${SCRIPT}" ]
    [[ "$(head -n1 "${SCRIPT}")" == "#!/usr/bin/env bash" ]]
    run grep -Fq 'set -euo pipefail' "${SCRIPT}"
    [ "$status" -eq 0 ]
    run grep -q '^# ABOUTME:' "${SCRIPT}"
    [ "$status" -eq 0 ]
}

@test "with no ref, clones current HEAD via full clone + checkout" {
    mock_git_success
    mock_nix_success

    run bash "${SCRIPT}"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Cloning current HEAD (${FAKE_HEAD_SHA})"* ]]

    run grep -F -- "rev-parse HEAD" "${GIT_CALLS}"
    [ "$status" -eq 0 ]
    run grep -F -- "clone --quiet" "${GIT_CALLS}"
    [ "$status" -eq 0 ]
    run grep -F -- "--depth 1" "${GIT_CALLS}"
    [ "$status" -eq 1 ]
    run grep -F -- "checkout --quiet ${FAKE_HEAD_SHA}" "${GIT_CALLS}"
    [ "$status" -eq 0 ]
}

@test "with a ref argument, clones --depth 1 --branch <ref> and skips checkout" {
    mock_git_success
    mock_nix_success

    run bash "${SCRIPT}" v2.0.33
    [ "$status" -eq 0 ]
    [[ "$output" == *"Cloning v2.0.33 (--depth 1)"* ]]

    run grep -F -- "--depth 1 --branch v2.0.33" "${GIT_CALLS}"
    [ "$status" -eq 0 ]
    run grep -F -- "rev-parse" "${GIT_CALLS}"
    [ "$status" -eq 1 ]
}

@test "evaluates all 3 profiles under NIX_INSTALL_CI with the drvPath attribute" {
    mock_git_success
    mock_nix_success

    run env NIX_INSTALL_CI=0 bash "${SCRIPT}" v2.0.33
    [ "$status" -eq 0 ]

    for profile in standard power ai-assistant; do
        run grep -F -- "eval --impure --raw path:.#darwinConfigurations.${profile}.system.drvPath" "${NIX_CALLS}"
        [ "$status" -eq 0 ]
    done
}

@test "sets NIX_INSTALL_CI=1 for every nix eval regardless of the caller's environment" {
    mock_git_success
    nix() {
        echo "nix ${NIX_INSTALL_CI:-unset} $*" >> "${NIX_CALLS}"
        return 0
    }
    export -f nix

    run env NIX_INSTALL_CI=0 bash "${SCRIPT}" v2.0.33
    [ "$status" -eq 0 ]

    run grep -F -- "nix 0 eval" "${NIX_CALLS}"
    [ "$status" -eq 1 ]
    run grep -c -F -- "nix 1 eval" "${NIX_CALLS}"
    [ "$output" -eq 3 ]
}

@test "fails without evaluating any profile when the clone fails" {
    mock_git_clone_fails
    mock_nix_success

    run bash "${SCRIPT}" v2.0.33
    [ "$status" -ne 0 ]
    [ ! -s "${NIX_CALLS}" ]
}

@test "stops evaluating once a profile's eval fails, never reaching later profiles" {
    mock_git_success
    mock_nix_fails_for power

    run bash "${SCRIPT}" v2.0.33
    [ "$status" -ne 0 ]

    run grep -F -- "darwinConfigurations.standard." "${NIX_CALLS}"
    [ "$status" -eq 0 ]
    run grep -F -- "darwinConfigurations.power." "${NIX_CALLS}"
    [ "$status" -eq 0 ]
    run grep -F -- "darwinConfigurations.ai-assistant." "${NIX_CALLS}"
    [ "$status" -eq 1 ]
}

@test "removes the scratch clone directory on exit, success or failure" {
    mock_git_success
    mock_nix_success
    mock_mktemp

    run bash "${SCRIPT}" v2.0.33
    [ "$status" -eq 0 ]

    # Non-empty log proves the script really took a scratch directory, so the
    # removal assertion below cannot pass by never having created one.
    scratch="$(cat "${MKTEMP_LOG}")"
    [ -n "${scratch}" ]
    [ ! -e "${scratch}" ]
    [ -z "$(ls -A "${SCRATCH_PARENT}")" ]
}

@test "removes the scratch clone directory even when a profile eval fails" {
    mock_git_success
    mock_nix_fails_for standard
    mock_mktemp

    run bash "${SCRIPT}" v2.0.33
    [ "$status" -ne 0 ]

    scratch="$(cat "${MKTEMP_LOG}")"
    [ -n "${scratch}" ]
    [ ! -e "${scratch}" ]
    [ -z "$(ls -A "${SCRATCH_PARENT}")" ]
}

@test "prints a success message naming the ref once all profiles evaluate" {
    mock_git_success
    mock_nix_success

    run bash "${SCRIPT}" v2.0.33
    [ "$status" -eq 0 ]
    [[ "$output" == *"Smoke test passed: all 3 profiles evaluate cleanly from a scratch clone of v2.0.33"* ]]
}
