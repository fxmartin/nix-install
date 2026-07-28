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

# NIX_INSTALL_REF must be exported into bootstrap-dist.sh's environment so the
# whole install chain (setup.sh -> bootstrap-dist.sh -> cloned config) runs
# from one immutable ref. Default install: pin to the release tag.
default_ref="$(
    env -u NIX_INSTALL_BRANCH bash -c '
        source "$1/setup.sh"
        export_bootstrap_ref
        printf "%s" "${NIX_INSTALL_REF}"
    ' _ "${repo_root}"
)"
[[ "${default_ref}" == "v${version}" ]]

# NIX_INSTALL_BRANCH developer override must flow through as NIX_INSTALL_REF,
# preserving the current dev workflow.
override_ref="$(
    NIX_INSTALL_BRANCH=feature/test bash -c '
        source "$1/setup.sh"
        export_bootstrap_ref
        printf "%s" "${NIX_INSTALL_REF}"
    ' _ "${repo_root}"
)"
[[ "${override_ref}" == "feature/test" ]]

# The export must actually be visible to a child process (not just a local var).
child_visible_ref="$(
    env -u NIX_INSTALL_BRANCH bash -c '
        source "$1/setup.sh"
        export_bootstrap_ref
        bash -c "printf %s \"\${NIX_INSTALL_REF:-}\""
    ' _ "${repo_root}"
)"
[[ "${child_visible_ref}" == "v${version}" ]]

# Temp dir must be created with an unpredictable mktemp template (not the
# PID-predictable "-$$" suffix) and removed automatically once the shell that
# created it exits, via a trap on EXIT.
temp_dir_path="$(
    bash -c '
        source "$1/setup.sh"
        create_temp_dir
        printf "%s" "${TEMP_DIR}"
    ' _ "${repo_root}"
)"
[[ "${temp_dir_path}" =~ ^/tmp/nix-install-setup\.[A-Za-z0-9]{6}$ ]]
if [[ -d "${temp_dir_path}" ]]; then
    echo "trap did not clean up temp dir after shell exit: ${temp_dir_path}" >&2
    exit 1
fi

if grep -q 'nix-install-setup-\$\$' "${repo_root}/setup.sh"; then
    echo "setup.sh still uses the PID-predictable temp dir naming pattern" >&2
    exit 1
fi

# The user-config template must be checksum-verified the same way bootstrap-dist.sh is.
if ! grep -q 'verify_checksum "\${TEMP_DIR}/\${USER_CONFIG_TEMPLATE}"' "${repo_root}/setup.sh"; then
    echo "setup.sh does not verify the downloaded user-config template checksum" >&2
    exit 1
fi

# Default (no NIX_INSTALL_BRANCH) help/version output must not print a
# double-slash "nix-install//setup.sh" artifact or an empty Branch value.
help_output="$(cd "${repo_root}" && env -u NIX_INSTALL_BRANCH bash setup.sh --help)"
if grep -q '//setup.sh' <<<"${help_output}"; then
    echo "help output contains a double-slash URL artifact" >&2
    exit 1
fi

version_output="$(cd "${repo_root}" && env -u NIX_INSTALL_BRANCH bash setup.sh --version)"
if grep -q '^Branch: $' <<<"${version_output}"; then
    echo "version output has an empty Branch value" >&2
    exit 1
fi

echo "setup-integrity-test OK"
