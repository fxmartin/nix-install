#!/usr/bin/env bash
# ABOUTME: Installs tracked Git hooks for this repository
# ABOUTME: Points core.hooksPath at .githooks so local checks are versioned

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "${ROOT_DIR}"
git config core.hooksPath .githooks
echo "Installed tracked Git hooks: core.hooksPath=.githooks"
