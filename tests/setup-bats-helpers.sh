#!/usr/bin/env bash
# ABOUTME: Installs BATS helper libraries used by tests/*.bats into tests/test_helper
# ABOUTME: Keeps helper dependencies reproducible without committing vendored copies

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPER_DIR="${SCRIPT_DIR}/test_helper"

clone_or_update() {
    local name="$1"
    local url="$2"
    local ref="$3"
    local dest="${HELPER_DIR}/${name}"

    mkdir -p "${HELPER_DIR}"

    if [[ -d "${dest}/.git" ]]; then
        git -C "${dest}" fetch --tags --quiet
    else
        git clone --quiet "${url}" "${dest}"
    fi

    git -C "${dest}" checkout --quiet "${ref}"
}

clone_or_update "bats-support" "https://github.com/bats-core/bats-support.git" "v0.3.0"
clone_or_update "bats-assert" "https://github.com/bats-core/bats-assert.git" "v2.1.0"

echo "BATS helpers installed in ${HELPER_DIR}"
