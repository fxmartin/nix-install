#!/usr/bin/env bash
# ABOUTME: Classifies a release tag's signature as verified, unverifiable, or absent
# ABOUTME: Extracted so the three-way distinction is testable (issue #358)

# Why this exists as its own script:
#
# `git tag -v` is the only real verification, but it exits 1 for two very
# different reasons: a bad signature, and a local config gap
# (`gpg.ssh.allowedSignersFile` unset — the default on this machine, where SSH
# signing is used). Treating both as failure blocks every release; treating
# both as success accepts an unsigned tag as signed. An earlier attempt at this
# check grepped for a `-----BEGIN ... SIGNATURE-----` block, which proves a
# signature is *present* but not that it is *valid* — that is the bug this
# replaces.
#
# Exit codes:
#   0  signature verified, OR present but unverifiable locally (warns)
#   1  no signature, or signature invalid
#   2  usage error / unknown tag
#
# Set RELEASE_REQUIRE_VERIFIED_TAG=1 to make "present but unverifiable" fail
# too, for environments where allowedSignersFile is configured and verification
# is expected to be conclusive.

set -uo pipefail

tag="${1:-}"
if [[ -z "${tag}" || "${tag}" == "-h" || "${tag}" == "--help" ]]; then
    sed -n '4,25p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    [[ -n "${tag}" ]] && exit 0
    exit 2
fi

if ! git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
    echo "error: tag ${tag} does not exist" >&2
    exit 2
fi

# A lightweight tag has no object to sign at all.
if [[ "$(git cat-file -t "${tag}" 2>/dev/null)" != "tag" ]]; then
    echo "error: ${tag} is a lightweight tag and carries no signature" >&2
    exit 1
fi

verify_output="$(git tag -v "${tag}" 2>&1)"
verify_rc=$?

if [[ ${verify_rc} -eq 0 ]]; then
    echo "${tag}: signature verified"
    exit 0
fi

# Distinguish "cannot verify here" from "signature is bad". The allowedSigners
# message is emitted before any signature check happens, so it means the check
# never ran — not that it failed.
if grep -q "allowedSignersFile" <<<"${verify_output}"; then
    if ! git cat-file -p "${tag}" | grep -q '^-----BEGIN .*SIGNATURE-----'; then
        echo "error: ${tag} has no signature" >&2
        exit 1
    fi
    if [[ "${RELEASE_REQUIRE_VERIFIED_TAG:-0}" == "1" ]]; then
        echo "error: ${tag} signature present but could not be verified" >&2
        echo "  configure: git config gpg.ssh.allowedSignersFile <path>" >&2
        exit 1
    fi
    echo "warning: ${tag} signature present but NOT verified" >&2
    echo "  gpg.ssh.allowedSignersFile is unset, so git cannot check it" >&2
    echo "  configure it to make this conclusive: git config gpg.ssh.allowedSignersFile <path>" >&2
    exit 0
fi

echo "error: ${tag} signature is invalid" >&2
printf '%s\n' "${verify_output}" >&2
exit 1
