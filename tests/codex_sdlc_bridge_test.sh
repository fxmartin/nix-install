#!/usr/bin/env bash
# ABOUTME: Verifies Codex SDLC bridge logging and cmux forwarding behavior
# ABOUTME: Exercises the bridge without requiring a real cmux session

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BRIDGE="${ROOT_DIR}/plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

fail() {
    echo "codex_sdlc_bridge_test failed: $*" >&2
    exit 1
}

assert_contains() {
    local file="$1"
    local expected="$2"
    if ! grep -Fq -- "${expected}" "${file}"; then
        echo "Expected to find: ${expected}" >&2
        echo "In file: ${file}" >&2
        sed -n '1,120p' "${file}" >&2 || true
        exit 1
    fi
}

LOG_DIR="${TMP_DIR}/logs"
HOME_DIR="${TMP_DIR}/home"
FAKE_CALLS="${TMP_DIR}/fake-bridge.calls"
mkdir -p "${HOME_DIR}/.claude/hooks"

CODEX_SDLC_LOG_DIR="${LOG_DIR}" "${BRIDGE}" status phase "Preflight" --icon shield
assert_contains "${LOG_DIR}/codex-sdlc.log" "[status] phase Preflight --icon shield"

cat > "${HOME_DIR}/.claude/hooks/cmux-bridge.sh" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${FAKE_CALLS}"
SCRIPT
chmod +x "${HOME_DIR}/.claude/hooks/cmux-bridge.sh"

export FAKE_CALLS
export HOME="${HOME_DIR}"
export CODEX_SDLC_LOG_DIR="${LOG_DIR}"
export CMUX_SOCKET_PATH="${TMP_DIR}/cmux.sock"

"${BRIDGE}" status phase "Building" --icon hammer --color "#FF9500"
"${BRIDGE}" progress 0.5 --label "Phase 4: Build"
"${BRIDGE}" log success "Build finished" --source fix-issue
"${BRIDGE}" clear phase
"${BRIDGE}" clear

assert_contains "${FAKE_CALLS}" "status phase Building --icon hammer --color #FF9500"
assert_contains "${FAKE_CALLS}" "progress 0.5 --label Phase 4: Build"
assert_contains "${FAKE_CALLS}" "log success Build finished --source fix-issue"
assert_contains "${FAKE_CALLS}" "clear phase"
assert_contains "${FAKE_CALLS}" "clear"

echo "codex_sdlc_bridge_test OK"
