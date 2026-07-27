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

# bump-version.sh creates the release tag itself (issue #358), so by the time we
# reach here the tag normally exists already, pointing at the commit it just
# made. That is the expected path, not a collision — only a tag on some *other*
# commit is a genuine conflict.
tag_already_ours=0
if git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
    if [[ "$(git rev-parse "${tag}^{commit}")" == "$(git rev-parse HEAD)" ]]; then
        tag_already_ours=1
    else
        echo "release failed: tag ${tag} already exists on a different commit" >&2
        exit 1
    fi
fi

remaining_untracked_files="$(git ls-files --others --exclude-standard)"
if ! git diff --quiet || ! git diff --cached --quiet || [[ -n "${remaining_untracked_files}" ]]; then
    echo "release failed: verification left the working tree dirty" >&2
    exit 1
fi

if [[ "${tag_already_ours}" -eq 1 ]]; then
    echo "Tag ${tag} already created by bump-version.sh."
else
    git tag -s "${tag}" -m "Release ${tag}"
    echo "Created signed tag ${tag}."
fi
echo "Push the release with:"
echo "  git push origin main ${tag}"
