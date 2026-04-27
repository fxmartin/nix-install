#!/usr/bin/env bash
# ABOUTME: Optional notification/progress adapter for the autonomous-sdlc Codex plugin
# ABOUTME: Keeps workflow logic independent from cmux, Telegram, or desktop notification availability

set -euo pipefail

subcommand="${1:-}"
shift || true

log_dir="${CODEX_SDLC_LOG_DIR:-/tmp}"
log_file="${log_dir}/codex-sdlc.log"

log() {
    local level="$1"
    local timestamp
    shift
    mkdir -p "${log_dir}"
    timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    printf '[%s] [%s] %s\n' "${timestamp}" "${level}" "$*" >> "${log_file}"
}

case "${subcommand}" in
    post-write)
        log info "Post-write hook observed"
        ;;
    status|progress|log|notify|telegram|clear)
        log "${subcommand}" "$*"
        if [[ -n "${CMUX_SOCKET_PATH:-}" && -x "${HOME}/.claude/hooks/cmux-bridge.sh" ]]; then
            "${HOME}/.claude/hooks/cmux-bridge.sh" "${subcommand}" "$@" || true
        fi
        ;;
    "")
        echo "Usage: codex-sdlc-bridge.sh <post-write|status|progress|log|notify|telegram|clear> [args...]" >&2
        exit 2
        ;;
    *)
        log warn "Unknown bridge subcommand: ${subcommand} $*"
        ;;
esac
