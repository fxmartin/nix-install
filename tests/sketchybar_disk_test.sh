#!/usr/bin/env bash
# ABOUTME: Tests SketchyBar disk icon free-space color thresholds

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN="${ROOT_DIR}/config/sketchybar/plugins/disk.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

export SKETCHYBAR_CALLS="${TMP_DIR}/sketchybar.calls"
mkdir -p "${TMP_DIR}/bin"

cat > "${TMP_DIR}/bin/sketchybar" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${SKETCHYBAR_CALLS}"
SCRIPT
chmod +x "${TMP_DIR}/bin/sketchybar"
export PATH="${TMP_DIR}/bin:${PATH}"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

run_case() {
  local name="$1"
  local available="$2"
  local total="$3"
  local expected_color="$4"

  : > "${SKETCHYBAR_CALLS}"
  NAME=disk \
    SKETCHYBAR_DISK_AVAILABLE_BYTES="${available}" \
    SKETCHYBAR_DISK_TOTAL_BYTES="${total}" \
    "${PLUGIN}"

  rg -q "icon.color=${expected_color}" "${SKETCHYBAR_CALLS}" \
    || fail "${name}: expected ${expected_color}, got $(cat "${SKETCHYBAR_CALLS}")"
  rg -q "label.drawing=off" "${SKETCHYBAR_CALLS}" \
    || fail "${name}: expected hidden label"
}

run_case "green at 20 percent free" 20 100 0xffa6e3a1
run_case "amber below 20 percent free" 19 100 0xfff9e2af
run_case "red below 10 percent free" 9 100 0xfff38ba8

printf 'sketchybar disk tests passed\n'
