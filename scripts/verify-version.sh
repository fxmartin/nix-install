#!/usr/bin/env bash
# ABOUTME: Verifies release version metadata stays synchronized
# ABOUTME: Blocks release drift between VERSION, README.md, and CLAUDE.md

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="${ROOT_DIR}/VERSION"
README_FILE="${ROOT_DIR}/README.md"
CLAUDE_FILE="${ROOT_DIR}/CLAUDE.md"

fail() {
    echo "version check failed: $*" >&2
    exit 1
}

[[ -f "${VERSION_FILE}" ]] || fail "VERSION file is missing"

version="$(tr -d '[:space:]' < "${VERSION_FILE}")"
[[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "VERSION must be X.Y.Z, got '${version}'"

readme_version="$(perl -ne 'if (/\*\*Version\*\*:\s*([0-9]+\.[0-9]+\.[0-9]+)/) { print $1; exit }' "${README_FILE}")"
claude_version="$(perl -ne 'if (/\*\*Status\*\*:\s*.*\*\*v([0-9]+\.[0-9]+\.[0-9]+) Released\*\*/) { print $1; exit }' "${CLAUDE_FILE}")"

[[ -n "${readme_version}" ]] || fail "could not find README.md version"
[[ -n "${claude_version}" ]] || fail "could not find CLAUDE.md status version"

[[ "${readme_version}" == "${version}" ]] || fail "README.md version ${readme_version} != VERSION ${version}"
[[ "${claude_version}" == "${version}" ]] || fail "CLAUDE.md version ${claude_version} != VERSION ${version}"

echo "version metadata OK: ${version}"
