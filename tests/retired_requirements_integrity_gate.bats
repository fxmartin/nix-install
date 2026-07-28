#!/usr/bin/env bats
# ABOUTME: Guards retirement of the dead requirements-integrity gate
# ABOUTME: Prevents doc drift (test counts, LaunchAgent table, mlgruby references) from recurring

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
}

@test "verify-requirements-integrity script and manifest are removed" {
    [ ! -e "${REPO_ROOT}/scripts/verify-requirements-integrity.sh" ]
    [ ! -e "${REPO_ROOT}/requirements-integrity.json" ]
}

@test "docs/REQUIREMENTS.md no longer invokes the deleted verify script" {
    run rg -n 'scripts/verify-requirements-integrity\.sh' "${REPO_ROOT}/docs/REQUIREMENTS.md"
    [ "$status" -eq 1 ]
}

@test "current documentation no longer points at the mlgruby reference repo" {
    run rg -n 'mlgruby-repo-for-reference' \
        "${REPO_ROOT}/CLAUDE.md" \
        "${REPO_ROOT}/STORIES.md" \
        "${REPO_ROOT}/config/README.md" \
        "${REPO_ROOT}/bootstrap-dist.sh" \
        "${REPO_ROOT}/lib/user-config.sh"
    [ "$status" -eq 1 ]
}

@test "architecture.md LaunchAgent table lists the current scheduled agents" {
    run rg -n 'vitals-sampler' "${REPO_ROOT}/docs/architecture.md"
    [ "$status" -eq 0 ]

    run rg -n 'virt-vm-orphan-watch' "${REPO_ROOT}/docs/architecture.md"
    [ "$status" -eq 0 ]

    run rg -n 'privacy-filter' "${REPO_ROOT}/docs/architecture.md"
    [ "$status" -eq 0 ]
}

@test "README beszel-sensors listing names the actual script files" {
    run rg -n 'beszel-sensors/.*power\.sh, temp\.sh, temp_gpu\.sh' "${REPO_ROOT}/README.md"
    [ "$status" -eq 0 ]

    [ -e "${REPO_ROOT}/scripts/beszel-sensors/power.sh" ]
    [ -e "${REPO_ROOT}/scripts/beszel-sensors/temp.sh" ]
    [ -e "${REPO_ROOT}/scripts/beszel-sensors/temp_gpu.sh" ]
}

@test "README headline test counts match the actual bats totals" {
    cd "${REPO_ROOT}"

    actual_total=0
    actual_files=0
    for file in tests/*.bats; do
        count=$(grep -c '^@test' "$file")
        actual_total=$((actual_total + count))
        actual_files=$((actual_files + 1))
    done

    gate_total=0
    gate_files=$(sed -n '/safe_bats_suites=(/,/^)/p' tests/run-safe-suite.sh | grep -oE 'tests/[A-Za-z0-9_.-]+\.bats')
    for file in $gate_files; do
        count=$(grep -c '^@test' "$file")
        gate_total=$((gate_total + count))
    done

    if [ "$actual_total" -ge 1000 ]; then
        formatted_total=$(printf "%d,%03d" $((actual_total / 1000)) $((actual_total % 1000)))
    else
        formatted_total="${actual_total}"
    fi

    run rg -F "${formatted_total} test cases (${actual_files} BATS files, ${gate_total} in the active gate)" README.md
    [ "$status" -eq 0 ]
}
