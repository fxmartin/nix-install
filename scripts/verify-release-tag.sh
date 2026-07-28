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
#   0  signature verified against configured or repository signer trust
#   1  no signature, signature invalid, OR signer trust unconfigured
#   2  usage error / unknown tag
#
# Fails closed: an unverifiable signature is rejected, because a signature that
# cannot be checked proves nothing. Set RELEASE_ALLOW_UNVERIFIED_TAG=1 to accept
# one deliberately.

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

verify_git=(git)
repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"
if ! git config --get gpg.ssh.allowedSignersFile >/dev/null 2>&1 \
    && [[ -f "${repo_root}/.allowed_signers" ]]; then
    verify_git+=(-c "gpg.ssh.allowedSignersFile=${repo_root}/.allowed_signers")
fi

verify_output="$("${verify_git[@]}" tag -v "${tag}" 2>&1)"
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
    # Fail closed. A signature nobody can check is not evidence of anything —
    # accepting it would let a release claim a verified tag on the strength of
    # an unreadable blob, which is the failure this script exists to prevent.
    # The remedy is one command and is printed here, so this is a one-time
    # setup cost rather than a permanent obstacle.
    if [[ "${RELEASE_ALLOW_UNVERIFIED_TAG:-0}" == "1" ]]; then
        echo "warning: ${tag} signature present but NOT verified — proceeding" >&2
        echo "  RELEASE_ALLOW_UNVERIFIED_TAG=1 was set explicitly" >&2
        exit 0
    fi
    echo "error: ${tag} has a signature, but signer trust is not configured" >&2
    echo "  git cannot tell a valid signature from a forged one without it." >&2
    echo "" >&2
    echo "  Configure once:" >&2
    echo "    printf '%s %s' \"\$(git config user.email)\" \"\$(cat ~/.ssh/id_ed25519.pub)\" > ~/.ssh/allowed_signers" >&2
    echo "    git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers" >&2
    echo "" >&2
    echo "  Or bypass deliberately: RELEASE_ALLOW_UNVERIFIED_TAG=1" >&2
    exit 1
fi

echo "error: ${tag} signature is invalid" >&2
printf '%s\n' "${verify_output}" >&2
exit 1
