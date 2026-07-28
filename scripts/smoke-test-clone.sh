#!/usr/bin/env bash
# ABOUTME: Clones the repo tree at a ref into a scratch directory and eval-tests
# ABOUTME: all 3 darwinConfigurations profiles, proving the clone-based bootstrap
# ABOUTME: (Story 10.1-001) can never omit a file the old per-file download list did

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
profiles=(standard power ai-assistant)

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
clone_dir="${tmpdir}/repo"

if [[ $# -ge 1 ]]; then
    ref="$1"
    echo "Cloning ${ref} (--depth 1) into a scratch directory..."
    git -c advice.detachedHead=false clone --quiet --depth 1 --branch "${ref}" "file://${repo_root}" "${clone_dir}"
else
    ref="$(git -C "${repo_root}" rev-parse HEAD)"
    echo "Cloning current HEAD (${ref}) into a scratch directory..."
    git clone --quiet "file://${repo_root}" "${clone_dir}"
    git -C "${clone_dir}" -c advice.detachedHead=false checkout --quiet "${ref}"
fi

echo "Evaluating darwinConfigurations from the scratch clone..."
for profile in "${profiles[@]}"; do
    echo "  -> ${profile}"
    (cd "${clone_dir}" && NIX_INSTALL_CI=1 nix eval --impure --raw "path:.#darwinConfigurations.${profile}.system.drvPath" >/dev/null)
done

echo "Smoke test passed: all 3 profiles evaluate cleanly from a scratch clone of ${ref}"
