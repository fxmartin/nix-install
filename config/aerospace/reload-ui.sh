#!/usr/bin/env bash
set -euo pipefail

if ! command -v sketchybar >/dev/null 2>&1; then
  echo "sketchybar command not found" >&2
  exit 1
fi

if ! command -v aerospace >/dev/null 2>&1; then
  echo "aerospace command not found" >&2
  exit 1
fi

aerospace reload-config
sketchybar --reload
