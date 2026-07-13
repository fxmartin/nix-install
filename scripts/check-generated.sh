#!/usr/bin/env bash
# ABOUTME: Verifies generated bootstrap and checksum files are reproducible from current sources
# ABOUTME: Compares pre-generation content so legitimate feature-branch diffs are accepted

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

generated_files=(bootstrap-dist.sh SHA256SUMS)
for generated_file in "${generated_files[@]}"; do
    if [[ ! -f "${repo_root}/${generated_file}" ]]; then
        echo "Generated file is missing: ${generated_file}" >&2
        exit 1
    fi
    cp "${repo_root}/${generated_file}" "${tmpdir}/${generated_file}"
done

"${repo_root}/scripts/build-bootstrap.sh"
"${repo_root}/scripts/generate-checksums.sh"

for generated_file in "${generated_files[@]}"; do
    if ! cmp -s "${tmpdir}/${generated_file}" "${repo_root}/${generated_file}"; then
        echo "Generated file is stale: ${generated_file}" >&2
        exit 1
    fi
done
