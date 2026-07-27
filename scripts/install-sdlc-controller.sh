#!/usr/bin/env bash
# ABOUTME: Installs the sdlc controller CLI from a checkout, pinned to its uv.lock
# ABOUTME: Extracted from sdlc-controller.nix so the failure paths are testable (issue #531)

# Why this is a script and not inline in the Nix module:
#
# The activation script runs under `set -e`, and this logic broke a real
# rebuild twice — first an unguarded `mktemp` (GNU coreutils rejects the `-t
# prefix` form that BSD mktemp in /usr/bin accepts), then a cleanup written as
# `[ -n "$C" ] && rm -f "$C"`, where under `set -e` it is the command *after*
# the final && that triggers the exit. Both were one-line fixes; the real
# defect was that nothing tested them. Shell inlined in a .nix string cannot be
# exercised without evaluating the whole flake, which needs the gitignored
# user-config.nix. As a script it gets tests/sdlc_controller_install.bats.
#
# Contract: report the truth via exit status. NEVER let a failure here break an
# activation — that is the caller's job, and the module invokes this inside an
# `if` so any non-zero exit is absorbed.

set -uo pipefail

UV_BIN="${UV_BIN:-uv}"

usage() {
    cat <<'EOF'
Usage: install-sdlc-controller.sh <controller-dir>

Installs the sdlc controller CLI from <controller-dir> via `uv tool install`,
constrained to the versions in that project's uv.lock.

Environment:
  UV_BIN   uv executable to use (default: uv)

Exit codes:
  0  installed (pinned, or unpinned with a warning on stderr)
  1  controller directory missing, or the install itself failed
  2  usage error
EOF
}

controller_dir="${1:-}"
if [[ -z "${controller_dir}" || "${controller_dir}" == "--help" || "${controller_dir}" == "-h" ]]; then
    usage
    [[ -n "${controller_dir}" ]] && exit 0
    exit 2
fi

if [[ ! -d "${controller_dir}" ]]; then
    echo "error: controller directory not found: ${controller_dir}" >&2
    exit 1
fi

# `uv tool install` has no --locked/--frozen: it re-resolves from
# pyproject.toml and ignores the committed uv.lock, so the installed dependency
# set drifts from the one the controller's tests ran against. Observed, not
# hypothetical: uv.lock pins annotated-types==0.7.0 and an unpinned install
# resolved 0.8.0. Export the lock to a constraints file and feed it in.
#
# Explicit XXXXXX template: GNU mktemp rejects `-t prefix`. `|| true` so a
# mktemp failure degrades to an unpinned install rather than killing the run.
constraints="$(mktemp "${TMPDIR:-/tmp}/sdlc-controller-constraints.XXXXXX" 2>/dev/null || true)"

pin_args=()
if [[ -n "${constraints}" ]] && (
    cd "${controller_dir}" && "${UV_BIN}" export \
        --frozen --no-emit-project --no-hashes --format requirements-txt
) >"${constraints}" 2>/dev/null; then
    pin_args=(-c "${constraints}")
else
    # Reproducibility is this repo's premise, so say plainly that we are
    # proceeding without it rather than installing silently unpinned.
    echo "warning: could not export uv.lock — installing unpinned, versions may drift" >&2
fi

# --force so a submodule bump actually replaces the installed build: without it
# uv keeps the existing tool and the CLI silently lags the checkout, which has
# bitten before (a stale `sdlc` missing a flag the skills had started passing).
rc=0
if ! "${UV_BIN}" tool install --force "${pin_args[@]}" "${controller_dir}"; then
    echo "error: sdlc controller install failed" >&2
    echo "       retry: ${UV_BIN} tool install --force ${controller_dir}" >&2
    rc=1
fi

# Cleanup must never be the thing that fails the run.
if [[ -n "${constraints}" ]]; then
    rm -f "${constraints}" || true
fi

exit "${rc}"
