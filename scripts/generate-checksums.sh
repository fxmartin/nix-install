#!/usr/bin/env bash
# ABOUTME: Generates deterministic SHA-256 checksums for published installer assets
# ABOUTME: Runs from any working directory and writes the repository SHA256SUMS file

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
assets=(bootstrap-dist.sh setup.sh user-config.template.nix)

for asset in "${assets[@]}"; do
    if [[ ! -f "${repo_root}/${asset}" ]]; then
        echo "Missing release asset: ${asset}" >&2
        exit 1
    fi
done

(
    cd "${repo_root}"
    shasum -a 256 "${assets[@]}" > SHA256SUMS
)
