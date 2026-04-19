#!/usr/bin/env bash
# ABOUTME: Kills orphaned Claude Code MCP / node server processes to mitigate kernel memory leaks
# ABOUTME: Runs every 90 minutes via LaunchAgent (see darwin/maintenance.nix: claude-code-cleanup)
#
# Background: Running many parallel Claude Code agents on macOS leaks kernel
# memory in the kalloc.1024 zone and leaves orphaned Node subprocesses behind
# when Claude Code crashes or is force-quit. This script only targets processes
# that have been re-parented to launchd (PPID=1) — i.e. truly orphaned — so
# MCP servers of live Claude Code sessions are left alone.

set -euo pipefail

LOG_FILE="${HOME}/.claude/cleanup.log"
mkdir -p "$(dirname "${LOG_FILE}")"

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

killed=0
for pattern in "${PATTERNS[@]}"; do
    pids=$(orphan_pids "${pattern}")
    [[ -z "${pids}" ]] && continue

    # Graceful TERM, wait, then forceful KILL on anything that survived
    echo "${pids}" | xargs kill -TERM 2>/dev/null || true
    sleep 2

    leftover=$(orphan_pids "${pattern}")
    if [[ -n "${leftover}" ]]; then
        echo "${leftover}" | xargs kill -KILL 2>/dev/null || true
    fi

    # shellcheck disable=SC2086  # intentional word-splitting to count PIDs
    killed=$((killed + $(echo ${pids} | wc -w)))
done

printf '%s cleaned %d orphaned Claude Code processes\n' \
    "$(date '+%Y-%m-%d %H:%M:%S')" "${killed}" >> "${LOG_FILE}"
