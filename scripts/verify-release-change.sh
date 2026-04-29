#!/usr/bin/env bash
# ABOUTME: Verifies commits include synchronized release metadata and changelog entries
# ABOUTME: Enforces semantic version bumps for every normal commit before push

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
    echo "release check failed: $*" >&2
    exit 1
}

if [[ "${SKIP_RELEASE_CHECK:-}" == "1" ]]; then
    exit 0
fi

cd "${ROOT_DIR}"

if git rev-parse -q --verify MERGE_HEAD >/dev/null; then
    exit 0
fi

mapfile -t staged_files < <(git diff --cached --name-only --diff-filter=ACMRT)
if [[ "${#staged_files[@]}" -eq 0 ]]; then
    exit 0
fi

required_files=(VERSION README.md CLAUDE.md CHANGELOG.md)
for required in "${required_files[@]}"; do
    if ! printf '%s\n' "${staged_files[@]}" | grep -Fxq "${required}"; then
        fail "staged commits must include ${required}. Run: scripts/bump-version.sh <major|minor|patch> \"release note\""
    fi
    if ! git diff --quiet -- "${required}"; then
        fail "${required} has unstaged release metadata changes; stage it before committing"
    fi
done

"${ROOT_DIR}/scripts/verify-version.sh" >/dev/null

version="$(tr -d '[:space:]' < VERSION)"
[[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "VERSION must be X.Y.Z, got '${version}'"

if git rev-parse -q --verify HEAD >/dev/null; then
    previous_version="$(git show HEAD:VERSION 2>/dev/null | tr -d '[:space:]' || true)"
    if [[ "${previous_version}" == "${version}" ]]; then
        fail "VERSION must change from ${previous_version} for this commit"
    fi
fi

today="$(date +%F)"
if ! grep -Fq "## [${version}] - ${today}" CHANGELOG.md; then
    fail "CHANGELOG.md must contain a dated section for ${version}: ## [${version}] - ${today}"
fi

echo "release metadata OK: ${version}"
