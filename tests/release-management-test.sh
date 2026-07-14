#!/usr/bin/env bash
# ABOUTME: Exercises semantic release bumping and commit-time release metadata checks
# ABOUTME: Uses an isolated temporary git repository to avoid touching the working tree

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

fail() {
    echo "release-management-test failed: $*" >&2
    exit 1
}

assert_contains() {
    local file="$1"
    local expected="$2"
    if ! grep -Fq -- "${expected}" "${file}"; then
        echo "Expected to find: ${expected}" >&2
        echo "In file: ${file}" >&2
        sed -n '1,80p' "${file}" >&2 || true
        exit 1
    fi
}

assert_not_contains() {
    local file="$1"
    local unexpected="$2"
    if grep -Fq -- "${unexpected}" "${file}"; then
        echo "Expected not to find: ${unexpected}" >&2
        echo "In file: ${file}" >&2
        exit 1
    fi
}

cp -R "${ROOT_DIR}/scripts" "${TMP_DIR}/scripts"
cp "${ROOT_DIR}/VERSION" "${TMP_DIR}/VERSION"
cp "${ROOT_DIR}/README.md" "${TMP_DIR}/README.md"
cp "${ROOT_DIR}/CLAUDE.md" "${TMP_DIR}/CLAUDE.md"
cp "${ROOT_DIR}/CHANGELOG.md" "${TMP_DIR}/CHANGELOG.md"
cp "${ROOT_DIR}/setup.sh" "${TMP_DIR}/setup.sh"

cd "${TMP_DIR}"
git init -b main >/dev/null
git config user.email "test@example.invalid"
git config user.name "Release Test"
git add VERSION README.md CLAUDE.md CHANGELOG.md setup.sh scripts/bump-version.sh scripts/release.sh scripts/verify-version.sh scripts/verify-release-change.sh
git commit -m "test: initial fixture" >/dev/null

current_version="$(tr -d '[:space:]' < VERSION)"
IFS=. read -r current_major current_minor current_patch <<< "${current_version}"
next_patch="${current_major}.${current_minor}.$((current_patch + 1))"

RELEASE_SKIP_CHECKS=1 scripts/bump-version.sh patch "Exercise release management" >/tmp/release-management-bump.out
[[ "$(tr -d '[:space:]' < VERSION)" == "${next_patch}" ]] || fail "expected VERSION to be ${next_patch}"
assert_contains setup.sh "readonly SETUP_VERSION=\"${next_patch}\""
assert_contains CHANGELOG.md "## [${next_patch}] - $(date +%F)"
assert_contains CHANGELOG.md "### Fixed"
assert_contains CHANGELOG.md "- Exercise release management"
assert_not_contains CHANGELOG.md "- Exercise release management## ["
git log -1 --pretty=%s | grep -Fxq "release(patch): v${next_patch}" || fail "unexpected release commit subject"

printf '\nRelease guard smoke test\n' >> README.md
git add README.md
if scripts/verify-release-change.sh >/tmp/release-management-guard.out 2>&1; then
    fail "expected release guard to reject staged change without release metadata"
fi
assert_contains /tmp/release-management-guard.out "staged commits must include VERSION"

assert_contains "${ROOT_DIR}/scripts/release.sh" 'git tag -s "${tag}"'

printf 'unstaged release input\n' > unstaged.txt
if RELEASE_SKIP_CHECKS=1 scripts/release.sh patch "Reject unstaged input" >/tmp/release-management-release.out 2>&1; then
    fail "expected release command to reject unstaged or untracked input"
fi
assert_contains /tmp/release-management-release.out "stage all intended changes"

echo "release-management-test OK"
