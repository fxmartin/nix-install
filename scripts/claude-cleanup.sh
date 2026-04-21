#!/usr/bin/env bash
# ABOUTME: Two-mode Claude Code maintenance: orphan-process killer + stale-project pruner
# ABOUTME: Default mode (no arg) runs the orphan killer — invoked every 90 minutes via LaunchAgent
#
# Background: Running many parallel Claude Code agents on macOS leaks kernel
# memory in the kalloc.1024 zone and leaves orphaned Node subprocesses behind
# when Claude Code crashes or is force-quit. The orphan killer targets processes
# re-parented to launchd (PPID=1) only, so MCP servers of live sessions are
# left alone.
#
# The --prune-old mode addresses a different growth axis: ~/.claude/projects/
# accumulates transcript dirs indefinitely. This mode removes project dirs
# untouched for N days (default 90) while ALWAYS preserving any path that
# contains a memory/ subdir (auto-memory persists across conversations).

set -euo pipefail

LOG_FILE="${HOME}/.claude/cleanup.log"
mkdir -p "$(dirname "${LOG_FILE}")"

# ---------------------------------------------------------------------------
# Orphan process killer (default mode)
# ---------------------------------------------------------------------------

# Patterns matching Claude Code spawned Node processes
PATTERNS=(
    "node.*mcp-server"
    "node.*claude.*server"
)

# List orphans (PPID=1) whose command matches the pattern
orphan_pids() {
    local pattern="$1"
    ps -axo pid=,ppid=,command= \
        | awk -v pat="${pattern}" '$2 == 1 && $0 ~ pat { print $1 }'
}

kill_orphans() {
    local killed=0
    for pattern in "${PATTERNS[@]}"; do
        local pids
        pids=$(orphan_pids "${pattern}")
        [[ -z "${pids}" ]] && continue

        # Graceful TERM, wait, then forceful KILL on anything that survived
        echo "${pids}" | xargs kill -TERM 2>/dev/null || true
        sleep 2

        local leftover
        leftover=$(orphan_pids "${pattern}")
        if [[ -n "${leftover}" ]]; then
            echo "${leftover}" | xargs kill -KILL 2>/dev/null || true
        fi

        # shellcheck disable=SC2086  # intentional word-splitting to count PIDs
        killed=$((killed + $(echo ${pids} | wc -w)))
    done

    printf '%s cleaned %d orphaned Claude Code processes\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "${killed}" >> "${LOG_FILE}"
}

# ---------------------------------------------------------------------------
# Stale-project pruner (--prune-old)
# ---------------------------------------------------------------------------

# Return 0 if the given directory contains any memory/ subdir (anywhere), else 1.
# memory/ is Claude Code's auto-memory store — must never be removed.
has_memory_dir() {
    local dir="$1"
    [[ -n "$(find "${dir}" -type d -name memory -print -quit 2>/dev/null)" ]]
}

# Return 0 if the given project base-name is in CLAUDE_PROJECTS_KEEP (colon-separated).
is_kept() {
    local name="$1"
    local keep_list="${CLAUDE_PROJECTS_KEEP:-}"
    [[ -z "${keep_list}" ]] && return 1
    local IFS=':'
    # shellcheck disable=SC2206
    local kept=(${keep_list})
    for k in "${kept[@]}"; do
        [[ "${k}" == "${name}" ]] && return 0
    done
    return 1
}

prune_old_projects() {
    local retention_days="${CLAUDE_RETENTION_DAYS:-90}"
    local projects_dir="${HOME}/.claude/projects"
    local archive_dir="${HOME}/.claude/archive"
    local dry_run="${1:-}"

    if [[ ! -d "${projects_dir}" ]]; then
        echo "No ~/.claude/projects directory — nothing to prune."
        return 0
    fi

    mkdir -p "${archive_dir}"
    local manifest="${archive_dir}/pruned-$(date '+%Y-%m-%d').txt"

    local pruned=0
    local skipped_memory=0
    local skipped_kept=0
    local scanned=0

    # find ... -mtime +N gives dirs whose contents haven't changed in N days.
    # -maxdepth 1 to list only top-level project dirs under projects/.
    while IFS= read -r -d '' project; do
        scanned=$((scanned + 1))
        local name
        name=$(basename "${project}")

        if is_kept "${name}"; then
            skipped_kept=$((skipped_kept + 1))
            [[ -n "${dry_run}" ]] && echo "KEEP (config): ${name}"
            continue
        fi

        if has_memory_dir "${project}"; then
            skipped_memory=$((skipped_memory + 1))
            [[ -n "${dry_run}" ]] && echo "KEEP (memory/): ${name}"
            continue
        fi

        if [[ -n "${dry_run}" ]]; then
            echo "WOULD PRUNE: ${name}"
        else
            {
                echo "pruned=${name}"
                echo "  mtime=$(stat -f '%Sm' "${project}")"
                echo "  size=$(du -sh "${project}" 2>/dev/null | cut -f1)"
            } >> "${manifest}"
            rm -rf "${project}"
            pruned=$((pruned + 1))
        fi
    done < <(find "${projects_dir}" -mindepth 1 -maxdepth 1 -type d -mtime "+${retention_days}" -print0 2>/dev/null)

    if [[ -n "${dry_run}" ]]; then
        printf 'DRY-RUN: would prune %d/%d projects (%d kept via config, %d via memory/)\n' \
            "${pruned}" "${scanned}" "${skipped_kept}" "${skipped_memory}"
    else
        printf '%s pruned %d Claude projects (>%dd old); kept %d via config, %d via memory/; manifest: %s\n' \
            "$(date '+%Y-%m-%d %H:%M:%S')" "${pruned}" "${retention_days}" \
            "${skipped_kept}" "${skipped_memory}" "${manifest}" >> "${LOG_FILE}"
        echo "✓ Pruned ${pruned} project dir(s); manifest at ${manifest}"
    fi
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

usage() {
    cat <<EOF
Usage: $(basename "$0") [command]

Commands:
    (no arg)     Kill orphaned Claude Code MCP / Node processes (default;
                 invoked by the 90-minute LaunchAgent)
    --prune-old  Remove ~/.claude/projects/ dirs not modified in
                 \$CLAUDE_RETENTION_DAYS days (default: 90). Always
                 preserves any path containing a memory/ subdir.
    --dry-run    With --prune-old: list what would be removed, no changes.
    --help, -h   This message.

Env:
    CLAUDE_RETENTION_DAYS    Retention window for --prune-old (default: 90)
    CLAUDE_PROJECTS_KEEP     Colon-separated project names to never prune
                             (e.g., "important-project:nix-install")
EOF
}

main() {
    local mode="${1:-}"
    case "${mode}" in
        "" | orphans)
            kill_orphans
            ;;
        --prune-old)
            local dry=""
            [[ "${2:-}" == "--dry-run" ]] && dry="dry-run"
            prune_old_projects "${dry}"
            ;;
        --dry-run)
            # Support --dry-run --prune-old ordering too
            [[ "${2:-}" == "--prune-old" ]] && prune_old_projects "dry-run" || {
                echo "--dry-run requires --prune-old" >&2
                exit 2
            }
            ;;
        --help|-h|help)
            usage
            ;;
        *)
            echo "Unknown command: ${mode}" >&2
            usage
            exit 2
            ;;
    esac
}

main "$@"
