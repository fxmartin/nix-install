#!/usr/bin/env bats
# ABOUTME: Guards the phase-5 pinned-tag git clone that replaced per-file curl downloads
# ABOUTME: Hermetic - stubs git and never touches the host or the network

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    COMMON_LIB="${REPO_ROOT}/lib/common.sh"
    NIX_DARWIN_LIB="${REPO_ROOT}/lib/nix-darwin.sh"

    TEST_ROOT="$(mktemp -d)"
    export TEST_ROOT
    GIT_CALLS="${TEST_ROOT}/git-calls.log"
    export GIT_CALLS
}

teardown() {
    if [[ -n "${TEST_ROOT:-}" && -d "${TEST_ROOT}" ]]; then
        rm -rf "${TEST_ROOT}"
    fi
}

# Source phase 5 with an isolated work directory. lib/common.sh honours
# _NIX_BOOTSTRAP_WORK_DIR, so WORK_DIR never points at a real bootstrap run.
load_phase5() {
    export _NIX_BOOTSTRAP_WORK_DIR="${TEST_ROOT}/work"
    mkdir -p "${_NIX_BOOTSTRAP_WORK_DIR}"

    # shellcheck disable=SC1090
    source "${COMMON_LIB}"
    # shellcheck disable=SC1090
    source "${NIX_DARWIN_LIB}"
}

# Records every git invocation and fakes a successful clone.
stub_git_success() {
    git() {
        echo "$*" >> "${GIT_CALLS}"
        if [[ "${1:-}" == "clone" ]]; then
            local destination="${*: -1}"
            mkdir -p "${destination}"
            echo "# flake" > "${destination}/flake.nix"
        fi
        return 0
    }
}

# =============================================================================
# Clone behaviour (AC 1)
# =============================================================================

@test "clone_flake_repository clones the pinned ref over HTTPS into WORK_DIR/repo" {
    load_phase5
    stub_git_success

    run clone_flake_repository
    [ "$status" -eq 0 ]

    run grep -F -- "clone --depth 1 --branch ${NIX_INSTALL_REF} https://github.com/${GITHUB_OWNER}/${GITHUB_REPO_NAME}.git ${WORK_DIR}/repo" "${GIT_CALLS}"
    [ "$status" -eq 0 ]
}

@test "clone_flake_repository targets FLAKE_REPO_DIR under the work directory" {
    load_phase5

    [ "${FLAKE_REPO_DIR}" = "${WORK_DIR}/repo" ]
}

@test "NIX_INSTALL_REF defaults to main" {
    load_phase5

    [ "${NIX_INSTALL_REF}" = "main" ]
}

@test "NIX_INSTALL_REF honours an environment override for release pinning" {
    export NIX_INSTALL_REF="v2.0.31"
    load_phase5
    stub_git_success

    run clone_flake_repository
    [ "$status" -eq 0 ]

    run grep -F -- "--branch v2.0.31" "${GIT_CALLS}"
    [ "$status" -eq 0 ]
}

@test "clone_flake_repository fails when the clone fails" {
    load_phase5
    git() {
        echo "$*" >> "${GIT_CALLS}"
        return 128
    }

    run clone_flake_repository
    [ "$status" -eq 1 ]
    [[ "$output" =~ "clone" ]]
}

@test "clone_flake_repository fails when flake.nix is missing from the clone" {
    load_phase5
    git() {
        echo "$*" >> "${GIT_CALLS}"
        [[ "${1:-}" == "clone" ]] && mkdir -p "${*: -1}"
        return 0
    }

    run clone_flake_repository
    [ "$status" -eq 1 ]
    [[ "$output" =~ "flake.nix" ]]
}

@test "clone_flake_repository replaces a leftover clone from an aborted run" {
    load_phase5
    stub_git_success

    mkdir -p "${FLAKE_REPO_DIR}"
    echo "stale" > "${FLAKE_REPO_DIR}/stale-artifact"

    run clone_flake_repository
    [ "$status" -eq 0 ]
    [ ! -e "${FLAKE_REPO_DIR}/stale-artifact" ]
}

@test "phase 5 no longer downloads individual configuration files" {
    run rg -n 'curl .*-o ' "${BATS_TEST_DIRNAME}/../lib/nix-darwin.sh"
    [ "$status" -eq 1 ]

    run rg -n 'fetch_flake_from_github' "${BATS_TEST_DIRNAME}/../lib/nix-darwin.sh"
    [ "$status" -eq 1 ]
}

# =============================================================================
# Redundant git init removed, build points at the clone (AC 2)
# =============================================================================

@test "the redundant git-init-for-flake step is gone" {
    load_phase5

    ! declare -f initialize_git_for_flake >/dev/null
}

@test "run_nix_darwin_build builds the profile from the cloned repository" {
    run rg -n 'flake_ref="path:\$\{FLAKE_REPO_DIR\}#\$\{INSTALL_PROFILE\}"' \
        "${BATS_TEST_DIRNAME}/../lib/nix-darwin.sh"
    [ "$status" -eq 0 ]

    run rg -n 'flake_ref="\.#' "${BATS_TEST_DIRNAME}/../lib/nix-darwin.sh"
    [ "$status" -eq 1 ]
}

# =============================================================================
# Submodules (AC 3)
# =============================================================================

@test "initialize_flake_submodules initializes each HTTPS submodule per path" {
    load_phase5
    stub_git_success

    run initialize_flake_submodules
    [ "$status" -eq 0 ]

    for submodule_path in \
        config/oh-my-zsh-custom/plugins/zsh-autosuggestions \
        config/oh-my-zsh-custom/plugins/zsh-syntax-highlighting \
        config/oh-my-zsh-custom/themes/powerlevel10k; do
        run grep -F -- "submodule update --init -- ${submodule_path}" "${GIT_CALLS}"
        [ "$status" -eq 0 ]
    done
}

@test "initialize_flake_submodules tolerates the SSH-only claude-code-config failure" {
    load_phase5
    git() {
        echo "$*" >> "${GIT_CALLS}"
        if [[ "$*" == *"config/claude-code-config"* ]]; then
            return 1
        fi
        return 0
    }

    run initialize_flake_submodules
    [ "$status" -eq 0 ]
    [[ "$output" =~ "claude-code-config" ]]
    [[ "$output" =~ "WARN" ]]
}

@test "initialize_flake_submodules keeps going when one HTTPS submodule fails" {
    load_phase5
    git() {
        echo "$*" >> "${GIT_CALLS}"
        if [[ "$*" == *"powerlevel10k"* ]]; then
            return 1
        fi
        return 0
    }

    run initialize_flake_submodules
    [ "$status" -eq 0 ]

    run grep -F -- "submodule update --init -- config/claude-code-config" "${GIT_CALLS}"
    [ "$status" -eq 0 ]
}

# =============================================================================
# user-config.nix placement (AC 4)
# =============================================================================

@test "copy_user_config copies the phase-2 config into the clone" {
    load_phase5

    mkdir -p "${FLAKE_REPO_DIR}"
    printf '{ username = "testuser"; }\n' > "${USER_CONFIG_FILE}"

    run copy_user_config
    [ "$status" -eq 0 ]
    [ -r "${FLAKE_REPO_DIR}/user-config.nix" ]

    run grep -q testuser "${FLAKE_REPO_DIR}/user-config.nix"
    [ "$status" -eq 0 ]
}

@test "copy_user_config fails when phase 2 produced no configuration" {
    load_phase5

    mkdir -p "${FLAKE_REPO_DIR}"
    rm -f "${USER_CONFIG_FILE}"

    run copy_user_config
    [ "$status" -eq 1 ]
    [[ "$output" =~ "not found" ]]
}

# =============================================================================
# Orchestration
# =============================================================================

@test "install_nix_darwin_phase clones, initializes submodules, then copies config" {
    local phase_source
    phase_source="$(sed -n '/^install_nix_darwin_phase()/,/^}/p' "${BATS_TEST_DIRNAME}/../lib/nix-darwin.sh")"

    local clone_line submodule_line config_line build_line
    clone_line="$(echo "${phase_source}" | grep -n 'clone_flake_repository' | head -n1 | cut -d: -f1)"
    submodule_line="$(echo "${phase_source}" | grep -n 'initialize_flake_submodules' | head -n1 | cut -d: -f1)"
    config_line="$(echo "${phase_source}" | grep -n 'copy_user_config' | head -n1 | cut -d: -f1)"
    build_line="$(echo "${phase_source}" | grep -n 'run_nix_darwin_build' | head -n1 | cut -d: -f1)"

    [ -n "${clone_line}" ]
    [ "${clone_line}" -lt "${submodule_line}" ]
    [ "${submodule_line}" -lt "${config_line}" ]
    [ "${config_line}" -lt "${build_line}" ]
}
