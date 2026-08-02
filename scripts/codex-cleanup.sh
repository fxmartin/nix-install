#!/usr/bin/env bash
# ABOUTME: Reports Codex storage use and reclaims guarded log/cache bloat on demand
# ABOUTME: Never deletes Codex session history, installed plugins, or user configuration

set -euo pipefail

CODEX_CLEANUP_VERSION="1.0.0"
CODEX_CLEANUP_HOME="${CODEX_CLEANUP_HOME:-${HOME}}"
CODEX_DATA_DIR="${CODEX_CLEANUP_DATA_DIR:-${CODEX_CLEANUP_HOME}/.codex}"
CODEX_CACHE_DIR="${CODEX_CLEANUP_CACHE_DIR:-${CODEX_CLEANUP_HOME}/Library/Caches/Codex}"
CODEX_LOGS_DB="${CODEX_CLEANUP_LOGS_DB:-${CODEX_DATA_DIR}/logs_2.sqlite}"
CODEX_SQLITE_BIN="${CODEX_CLEANUP_SQLITE_BIN:-sqlite3}"
CODEX_LSOF_BIN="${CODEX_CLEANUP_LSOF_BIN:-lsof}"
CODEX_PGREP_BIN="${CODEX_CLEANUP_PGREP_BIN:-pgrep}"
CODEX_RM_BIN="${CODEX_CLEANUP_RM_BIN:-rm}"
CODEX_MIN_RECLAIM_MIB="${CODEX_CLEANUP_MIN_RECLAIM_MIB:-128}"

usage() {
    cat <<'USAGE'
Usage: codex-cleanup [--analyze] [--compact-logs] [--prune-caches --yes]

Options:
  --analyze        Report Codex sessions, database bloat, and cache sizes.
                   This is the default and never changes files.
  --compact-logs   Reclaim SQLite freelist space. Refuses while the database
                   is open and skips files below the reclaim threshold.
  --prune-caches   Remove only ~/.codex/.tmp, ~/.codex/cache, and
                   ~/Library/Caches/Codex. Requires --yes and closed Codex apps.
  --yes            Confirm the explicit --prune-caches operation.
  -h, --help       Show this help.

Session history and installed plugins are report-only and are never removed.
USAGE
}

fail() {
    printf 'Error: %s\n' "$1" >&2
    return 1
}

command_available() {
    if [[ "$1" == */* ]]; then
        [[ -x "$1" ]]
    else
        command -v "$1" >/dev/null 2>&1
    fi
}

format_bytes() {
    local bytes="$1"
    awk -v bytes="${bytes}" 'BEGIN {
        if (bytes >= 1073741824) {
            printf "%.2f GiB", bytes / 1073741824
        } else if (bytes >= 1048576) {
            printf "%.1f MiB", bytes / 1048576
        } else if (bytes >= 1024) {
            printf "%.1f KiB", bytes / 1024
        } else {
            printf "%d B", bytes
        }
    }'
}

path_size_kib() {
    local path="$1"
    if [[ -e "${path}" ]]; then
        du -sk "${path}" 2>/dev/null | awk '{print $1}'
    else
        printf '0\n'
    fi
}

path_size_human() {
    local kib
    kib="$(path_size_kib "$1")"
    format_bytes "$((kib * 1024))"
}

print_path_size() {
    local label="$1"
    local path="$2"
    printf '%-24s %10s  %s\n' "${label}:" "$(path_size_human "${path}")" "${path}"
}

validate_paths() {
    if [[ ! "${CODEX_MIN_RECLAIM_MIB}" =~ ^[0-9]+$ ]]; then
        fail "CODEX_CLEANUP_MIN_RECLAIM_MIB must be a non-negative integer"
        return 1
    fi
    if [[ -z "${CODEX_CLEANUP_HOME}" || "${CODEX_CLEANUP_HOME}" == "/" ]]; then
        fail "unsafe cleanup home: ${CODEX_CLEANUP_HOME:-<empty>}"
        return 1
    fi
    if [[ "$(basename "${CODEX_DATA_DIR}")" != ".codex" ]]; then
        fail "Codex data directory must end in /.codex: ${CODEX_DATA_DIR}"
        return 1
    fi
    if [[ "$(basename "${CODEX_CACHE_DIR}")" != "Codex" ]]; then
        fail "Codex cache directory must end in /Codex: ${CODEX_CACHE_DIR}"
        return 1
    fi
}

read_sqlite_metrics() {
    if [[ ! -f "${CODEX_LOGS_DB}" ]]; then
        printf '0 0 0\n'
        return 0
    fi
    if ! command_available "${CODEX_SQLITE_BIN}"; then
        fail "sqlite3 is required to inspect ${CODEX_LOGS_DB}"
        return 1
    fi

    "${CODEX_SQLITE_BIN}" -readonly "${CODEX_LOGS_DB}" \
        'PRAGMA page_size; PRAGMA page_count; PRAGMA freelist_count;' 2>/dev/null \
        | awk 'NR == 1 {page_size=$1} NR == 2 {page_count=$1} NR == 3 {free_pages=$1} END {print page_size, page_count, free_pages}'
}

analyze_storage() {
    local page_size page_count free_pages
    local live_bytes=0
    local reclaimable_bytes=0
    local cache_kib=0

    printf 'Codex Storage Report v%s\n\n' "${CODEX_CLEANUP_VERSION}"
    print_path_size "Codex data" "${CODEX_DATA_DIR}"
    print_path_size "Codex sessions" "${CODEX_DATA_DIR}/sessions"
    print_path_size "Installed plugins" "${CODEX_DATA_DIR}/plugins"
    print_path_size "Temporary data" "${CODEX_DATA_DIR}/.tmp"
    print_path_size "Codex data cache" "${CODEX_DATA_DIR}/cache"
    print_path_size "Codex app cache" "${CODEX_CACHE_DIR}"
    print_path_size "Logs database" "${CODEX_LOGS_DB}"

    read -r page_size page_count free_pages <<<"$(read_sqlite_metrics)"
    if [[ "${page_size}" -gt 0 ]]; then
        live_bytes=$(((page_count - free_pages) * page_size))
        reclaimable_bytes=$((free_pages * page_size))
        printf '%-24s %10s\n' "SQLite live pages:" "$(format_bytes "${live_bytes}")"
        printf '%-24s %10s\n' "SQLite reclaimable:" "$(format_bytes "${reclaimable_bytes}")"
    else
        printf '%-24s %10s\n' "SQLite reclaimable:" "not available"
    fi

    cache_kib=$(($(path_size_kib "${CODEX_DATA_DIR}/.tmp") \
        + $(path_size_kib "${CODEX_DATA_DIR}/cache") \
        + $(path_size_kib "${CODEX_CACHE_DIR}")))
    printf '%-24s %10s\n' "Explicit cache targets:" "$(format_bytes "$((cache_kib * 1024))")"
    printf '\nSession history is report-only and is never removed by this tool.\n'
}

codex_process_running() {
    "${CODEX_PGREP_BIN}" -x Codex >/dev/null 2>&1 \
        || "${CODEX_PGREP_BIN}" -x codex >/dev/null 2>&1 \
        || "${CODEX_PGREP_BIN}" -f '/Codex\.app/' >/dev/null 2>&1 \
        || "${CODEX_PGREP_BIN}" -f 'codex-aarch64-apple-darwin' >/dev/null 2>&1
}

database_is_open() {
    if ! command_available "${CODEX_LSOF_BIN}"; then
        fail "lsof is required to prove the Codex database is closed"
        return 2
    fi
    "${CODEX_LSOF_BIN}" "${CODEX_LOGS_DB}" >/dev/null 2>&1
}

ensure_compaction_space() {
    local database_bytes="$1"
    local available_kib
    local required_kib
    available_kib="$(df -Pk "$(dirname "${CODEX_LOGS_DB}")" | awk 'NR == 2 {print $4}')"
    required_kib=$((database_bytes / 1024 + 262144))
    if [[ -z "${available_kib}" || "${available_kib}" -lt "${required_kib}" ]]; then
        fail "compaction needs the database size plus 256 MiB free"
        return 1
    fi
}

compact_logs() {
    local page_size page_count free_pages
    local reclaimable_bytes
    local minimum_bytes=$((CODEX_MIN_RECLAIM_MIB * 1024 * 1024))
    local before_bytes
    local after_bytes
    local sqlite_output

    if [[ ! -f "${CODEX_LOGS_DB}" ]]; then
        printf 'No Codex logs database found at %s\n' "${CODEX_LOGS_DB}"
        return 0
    fi
    if ! command_available "${CODEX_SQLITE_BIN}"; then
        fail "sqlite3 is required to compact ${CODEX_LOGS_DB}"
        return 1
    fi
    if database_is_open; then
        fail "Codex is using ${CODEX_LOGS_DB}; close Codex before compacting"
        return 1
    else
        local open_status=$?
        if [[ "${open_status}" -eq 2 ]]; then
            return 1
        fi
    fi

    read -r page_size page_count free_pages <<<"$(read_sqlite_metrics)"
    reclaimable_bytes=$((free_pages * page_size))
    if [[ "${reclaimable_bytes}" -lt "${minimum_bytes}" ]]; then
        printf 'Skipping log compaction: %s reclaimable is below the %s MiB threshold.\n' \
            "$(format_bytes "${reclaimable_bytes}")" "${CODEX_MIN_RECLAIM_MIB}"
        return 0
    fi

    before_bytes="$(/usr/bin/stat -f '%z' "${CODEX_LOGS_DB}")"
    ensure_compaction_space "${before_bytes}"

    printf 'Compacting %s (%s reclaimable)...\n' \
        "${CODEX_LOGS_DB}" "$(format_bytes "${reclaimable_bytes}")"
    if ! sqlite_output="$("${CODEX_SQLITE_BIN}" "${CODEX_LOGS_DB}" <<'SQL'
PRAGMA busy_timeout=5000;
PRAGMA wal_checkpoint(TRUNCATE);
VACUUM;
PRAGMA integrity_check;
SQL
    )"; then
        fail "SQLite compaction failed; the original database remains authoritative"
        return 1
    fi
    if [[ $'\n'"${sqlite_output}"$'\n' != *$'\nok\n'* ]]; then
        fail "SQLite integrity check did not return ok"
        return 1
    fi

    after_bytes="$(/usr/bin/stat -f '%z' "${CODEX_LOGS_DB}")"
    printf 'Log database compacted: %s -> %s.\n' \
        "$(format_bytes "${before_bytes}")" "$(format_bytes "${after_bytes}")"
}

prune_caches() {
    local confirmed="$1"
    local target
    local before
    local failed=0
    local targets=(
        "${CODEX_DATA_DIR}/.tmp"
        "${CODEX_DATA_DIR}/cache"
        "${CODEX_CACHE_DIR}"
    )

    if [[ "${confirmed}" != "true" ]]; then
        fail "--prune-caches requires --yes"
        return 1
    fi
    if ! command_available "${CODEX_PGREP_BIN}"; then
        fail "pgrep is required to prove Codex is stopped"
        return 1
    fi
    if codex_process_running; then
        fail "Codex is running; close all Codex app and CLI processes before pruning caches"
        return 1
    fi

    for target in "${targets[@]}"; do
        if [[ ! -e "${target}" ]]; then
            continue
        fi
        before="$(path_size_human "${target}")"
        if "${CODEX_RM_BIN}" -rf -- "${target}"; then
            printf 'Removed cache target: %s (was %s)\n' "${target}" "${before}"
        else
            printf 'Failed to remove cache target: %s\n' "${target}" >&2
            failed=1
        fi
    done

    return "${failed}"
}

main() {
    local analyze=false
    local compact=false
    local prune=false
    local confirmed=false

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --analyze) analyze=true ;;
            --compact-logs) compact=true ;;
            --prune-caches) prune=true ;;
            --yes) confirmed=true ;;
            -h|--help) usage; return 0 ;;
            *) usage >&2; fail "unknown option: $1"; return 2 ;;
        esac
        shift
    done

    if [[ "${analyze}" == false && "${compact}" == false && "${prune}" == false ]]; then
        analyze=true
    fi

    validate_paths
    if [[ "${compact}" == true ]]; then
        compact_logs
    fi
    if [[ "${prune}" == true ]]; then
        prune_caches "${confirmed}"
    fi
    if [[ "${analyze}" == true ]]; then
        analyze_storage
    fi
}

main "$@"
