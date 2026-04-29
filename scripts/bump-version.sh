#!/usr/bin/env bash
# ABOUTME: Bumps nix-install release metadata and commits staged work with a changelog entry
# ABOUTME: Supports semantic major, minor, and patch release increments from VERSION

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="${ROOT_DIR}/VERSION"

fail() {
    echo "bump-version failed: $*" >&2
    exit 1
}

usage() {
    cat <<'EOF'
Usage: scripts/bump-version.sh <major|minor|patch> <release note>

major  Bump X.Y.Z to (X+1).0.0 for breaking releases
minor  Bump X.Y.Z to X.(Y+1).0 for feature releases
patch  Bump X.Y.Z to X.Y.(Z+1) for fix releases

Stage the content change first, then run this script. It updates VERSION,
README.md, CLAUDE.md, and CHANGELOG.md, stages those metadata files, and
creates one commit containing the staged content plus release metadata.
EOF
}

kind="${1:-}"
case "${kind}" in
    major|minor|patch) ;;
    -h|--help|help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
shift

release_note="$*"
[[ -n "${release_note}" ]] || fail "release note is required"
[[ "${release_note}" != *$'\n'* ]] || fail "release note must be a single line"

cd "${ROOT_DIR}"

branch="$(git branch --show-current)"
[[ "${branch}" == "main" ]] || fail "must run on main, currently on ${branch:-detached HEAD}"

[[ -f "${VERSION_FILE}" ]] || fail "VERSION file is missing"
current="$(tr -d '[:space:]' < "${VERSION_FILE}")"
[[ "${current}" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || fail "VERSION must be X.Y.Z, got '${current}'"

major="${BASH_REMATCH[1]}"
minor="${BASH_REMATCH[2]}"
patch="${BASH_REMATCH[3]}"

case "${kind}" in
    major)
        major=$((major + 1))
        minor=0
        patch=0
        changelog_heading="Changed"
        ;;
    minor)
        minor=$((minor + 1))
        patch=0
        changelog_heading="Added"
        ;;
    patch)
        patch=$((patch + 1))
        changelog_heading="Fixed"
        ;;
    *)
        fail "unknown bump kind: ${kind}"
        ;;
esac

next="${major}.${minor}.${patch}"

printf '%s\n' "${next}" > "${VERSION_FILE}"

perl -0pi -e "s/(\\*\\*Version\\*\\*:\\s*)[0-9]+\\.[0-9]+\\.[0-9]+(?:\\s*\\+\\s*Epic-08)?/\${1}${next}/" README.md
perl -0pi -e "s/(\\*\\*Status\\*\\*:\\s*.*\\*\\*v)[0-9]+\\.[0-9]+\\.[0-9]+( Released\\*\\*)/\${1}${next}\${2}/" CLAUDE.md

today="$(date +%F)"
section="$(printf '## [%s] - %s\n\n### %s\n\n- %s\n\n' "${next}" "${today}" "${changelog_heading}" "${release_note}")"
SECTION="${section}" perl -0pi -e 's/(## \[Unreleased\]\n\n)/$1$ENV{SECTION}/' CHANGELOG.md

"${ROOT_DIR}/scripts/verify-version.sh"

git add VERSION README.md CLAUDE.md CHANGELOG.md
git commit -m "release(${kind}): v${next}" -m "${release_note}"

echo "Bumped release version: ${current} -> ${next}"
