#!/usr/bin/env bash
# ABOUTME: Runs the verified semantic-version release flow and creates a signed tag
# ABOUTME: Leaves pushing the release commit and tag as an explicit operator action

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$#" -lt 2 ]]; then
    echo "Usage: scripts/release.sh <major|minor|patch> <release note>" >&2
    exit 2
fi

kind="$1"
shift
release_note="$*"

unstaged_files="$(git -C "${repo_root}" diff --name-only)"
untracked_files="$(git -C "${repo_root}" ls-files --others --exclude-standard)"
if [[ -n "${unstaged_files}" || -n "${untracked_files}" ]]; then
    echo "release failed: stage all intended changes before releasing" >&2
    exit 1
fi

"${repo_root}/scripts/bump-version.sh" "${kind}" "${release_note}"

cd "${repo_root}"
version="$(tr -d '[:space:]' < VERSION)"
tag="v${version}"

if git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
    echo "release failed: tag ${tag} already exists" >&2
    exit 1
fi

remaining_untracked_files="$(git ls-files --others --exclude-standard)"
if ! git diff --quiet || ! git diff --cached --quiet || [[ -n "${remaining_untracked_files}" ]]; then
    echo "release failed: verification left the working tree dirty" >&2
    exit 1
fi

git tag -s "${tag}" -m "Release ${tag}"
echo "Created signed tag ${tag}. Push the release with:"
echo "  git push origin main ${tag}"
