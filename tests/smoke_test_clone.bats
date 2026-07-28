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
    unset -f git nix 2>/dev/null || true
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

    SCRATCH_TMPDIR="${TEST_ROOT}/scratch-tmp"
    mkdir -p "${SCRATCH_TMPDIR}"

    TMPDIR="${SCRATCH_TMPDIR}" run bash "${SCRIPT}" v2.0.33
    [ "$status" -eq 0 ]
    [ -z "$(ls -A "${SCRATCH_TMPDIR}")" ]
}

@test "removes the scratch clone directory even when a profile eval fails" {
    mock_git_success
    mock_nix_fails_for standard

    SCRATCH_TMPDIR="${TEST_ROOT}/scratch-tmp-fail"
    mkdir -p "${SCRATCH_TMPDIR}"

    TMPDIR="${SCRATCH_TMPDIR}" run bash "${SCRIPT}" v2.0.33
    [ "$status" -ne 0 ]
    [ -z "$(ls -A "${SCRATCH_TMPDIR}")" ]
}

@test "prints a success message naming the ref once all profiles evaluate" {
    mock_git_success
    mock_nix_success

    run bash "${SCRIPT}" v2.0.33
    [ "$status" -eq 0 ]
    [[ "$output" == *"Smoke test passed: all 3 profiles evaluate cleanly from a scratch clone of v2.0.33"* ]]
}
