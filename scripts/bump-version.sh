#!/usr/bin/env bash
# ABOUTME: Bumps nix-install release metadata and commits the release version
# ABOUTME: Supports minor and patch release increments from the VERSION file

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="${ROOT_DIR}/VERSION"

fail() {
    echo "bump-version failed: $*" >&2
    exit 1
}

usage() {
    cat <<'EOF'
Usage: scripts/bump-version.sh <minor|patch>

minor  Bump X.Y.Z to X.(Y+1).0 for feature releases
patch  Bump X.Y.Z to X.Y.(Z+1) for fix-only releases
EOF
}

kind="${1:-}"
case "${kind}" in
    minor|patch) ;;
    -h|--help|help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac

cd "${ROOT_DIR}"

branch="$(git branch --show-current)"
[[ "${branch}" == "main" ]] || fail "must run on main, currently on ${branch:-detached HEAD}"

untracked="$(git ls-files --others --exclude-standard)"
if ! git diff --quiet || ! git diff --cached --quiet || [[ -n "${untracked}" ]]; then
    fail "working tree must be clean before bumping a release"
fi

[[ -f "${VERSION_FILE}" ]] || fail "VERSION file is missing"
current="$(tr -d '[:space:]' < "${VERSION_FILE}")"
[[ "${current}" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || fail "VERSION must be X.Y.Z, got '${current}'"

major="${BASH_REMATCH[1]}"
minor="${BASH_REMATCH[2]}"
patch="${BASH_REMATCH[3]}"

case "${kind}" in
    minor)
        minor=$((minor + 1))
        patch=0
        ;;
    patch)
        patch=$((patch + 1))
        ;;
    *)
        fail "unknown bump kind: ${kind}"
        ;;
esac

next="${major}.${minor}.${patch}"

printf '%s\n' "${next}" > "${VERSION_FILE}"

perl -0pi -e "s/(\\*\\*Version\\*\\*:\\s*)[0-9]+\\.[0-9]+\\.[0-9]+(?:\\s*\\+\\s*Epic-08)?/\${1}${next}/" README.md
perl -0pi -e "s/(\\*\\*Status\\*\\*:\\s*.*\\*\\*v)[0-9]+\\.[0-9]+\\.[0-9]+( Released\\*\\*)/\${1}${next}\${2}/" CLAUDE.md

"${ROOT_DIR}/scripts/verify-version.sh"

git add VERSION README.md CLAUDE.md
git commit -m "chore(release): v${next}"

echo "Bumped release version: ${current} -> ${next}"
