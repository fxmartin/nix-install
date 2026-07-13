#!/usr/bin/env bash
# ABOUTME: Verifies setup source selection and bootstrap checksum enforcement
# ABOUTME: Sources setup.sh without running the interactive installer

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(tr -d '[:space:]' < "${repo_root}/VERSION")"

# shellcheck source=../setup.sh disable=SC1091
source "${repo_root}/setup.sh"

[[ "${SETUP_VERSION}" == "${version}" ]]
[[ "${SOURCE_REF}" == "v${version}" ]]
[[ "${BOOTSTRAP_URL}" == "https://github.com/fxmartin/nix-install/releases/download/v${version}/bootstrap-dist.sh" ]]

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
printf 'trusted bootstrap\n' > "${tmpdir}/bootstrap-dist.sh"
(
    cd "${tmpdir}"
    shasum -a 256 bootstrap-dist.sh > SHA256SUMS
)

verify_checksum "${tmpdir}/bootstrap-dist.sh" "${tmpdir}/SHA256SUMS"
printf 'tampered\n' >> "${tmpdir}/bootstrap-dist.sh"
if verify_checksum "${tmpdir}/bootstrap-dist.sh" "${tmpdir}/SHA256SUMS"; then
    echo "checksum verification accepted a modified artifact" >&2
    exit 1
fi

development_url="$({
    NIX_INSTALL_BRANCH=feature/test bash -c \
        'source "$1/setup.sh"; printf "%s" "$BOOTSTRAP_URL"' _ "${repo_root}"
})"
[[ "${development_url}" == "https://raw.githubusercontent.com/fxmartin/nix-install/feature/test/bootstrap-dist.sh" ]]

echo "setup-integrity-test OK"
