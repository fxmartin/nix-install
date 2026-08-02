#!/usr/bin/env bash
# ABOUTME: Exercises Codex storage analysis and cleanup against disposable fixtures
# ABOUTME: Verifies database guards, compaction, cache boundaries, and history preservation

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cleanup_script="${repo_root}/scripts/codex-cleanup.sh"
test_root="$(mktemp -d)"
trap 'rm -rf "${test_root}"' EXIT

test_home="${test_root}/home"
codex_dir="${test_home}/.codex"
codex_cache_dir="${test_home}/Library/Caches/Codex"
mock_bin_dir="${test_root}/bin"

mkdir -p \
    "${codex_dir}/sessions/2026/07/31" \
    "${codex_dir}/plugins/example" \
    "${codex_dir}/.tmp/plugins" \
    "${codex_dir}/cache/catalog" \
    "${codex_cache_dir}/Default" \
    "${mock_bin_dir}"

printf 'session history\n' >"${codex_dir}/sessions/2026/07/31/rollout.jsonl"
printf 'installed plugin\n' >"${codex_dir}/plugins/example/SKILL.md"
printf 'temporary plugin\n' >"${codex_dir}/.tmp/plugins/archive"
printf 'catalog cache\n' >"${codex_dir}/cache/catalog/index.json"
printf 'browser cache\n' >"${codex_cache_dir}/Default/cache.bin"

sqlite3 "${codex_dir}/logs_2.sqlite" >/dev/null <<'SQL'
PRAGMA journal_mode=DELETE;
CREATE TABLE logs (payload BLOB NOT NULL);
WITH RECURSIVE sequence(value) AS (
    SELECT 1
    UNION ALL
    SELECT value + 1 FROM sequence WHERE value < 96
)
INSERT INTO logs(payload)
SELECT randomblob(65536) FROM sequence;
DELETE FROM logs WHERE rowid <= 80;
SQL

cat >"${mock_bin_dir}/closed-lsof" <<'MOCK'
#!/usr/bin/env bash
exit 1
MOCK

cat >"${mock_bin_dir}/open-lsof" <<'MOCK'
#!/usr/bin/env bash
printf 'codex 123 fx 4u REG logs_2.sqlite\n'
exit 0
MOCK

cat >"${mock_bin_dir}/no-processes" <<'MOCK'
#!/usr/bin/env bash
exit 1
MOCK

chmod +x \
    "${mock_bin_dir}/closed-lsof" \
    "${mock_bin_dir}/open-lsof" \
    "${mock_bin_dir}/no-processes"

run_cleanup() {
    CODEX_CLEANUP_HOME="${test_home}" \
        CODEX_CLEANUP_LSOF_BIN="${mock_bin_dir}/closed-lsof" \
        CODEX_CLEANUP_PGREP_BIN="${mock_bin_dir}/no-processes" \
        CODEX_CLEANUP_MIN_RECLAIM_MIB=1 \
        bash "${cleanup_script}" "$@"
}

assert_exists() {
    if [[ ! -e "$1" ]]; then
        printf 'Expected path to exist: %s\n' "$1" >&2
        exit 1
    fi
}

assert_absent() {
    if [[ -e "$1" ]]; then
        printf 'Expected path to be absent: %s\n' "$1" >&2
        exit 1
    fi
}

analysis_output="$(run_cleanup --analyze)"
[[ "${analysis_output}" == *"Codex sessions"* ]]
[[ "${analysis_output}" == *"SQLite reclaimable"* ]]
[[ "${analysis_output}" == *"Session history is report-only"* ]]

if invalid_threshold_output="$(CODEX_CLEANUP_HOME="${test_home}" \
    CODEX_CLEANUP_MIN_RECLAIM_MIB=invalid \
    bash "${cleanup_script}" --analyze 2>&1)"; then
    printf 'Analysis unexpectedly accepted a non-numeric threshold\n' >&2
    exit 1
fi
[[ "${invalid_threshold_output}" == *"must be a non-negative integer"* ]]

database_before="$(/usr/bin/stat -f '%z' "${codex_dir}/logs_2.sqlite")"
if open_database_output="$(CODEX_CLEANUP_HOME="${test_home}" \
    CODEX_CLEANUP_LSOF_BIN="${mock_bin_dir}/open-lsof" \
    CODEX_CLEANUP_PGREP_BIN="${mock_bin_dir}/no-processes" \
    CODEX_CLEANUP_MIN_RECLAIM_MIB=1 \
    bash "${cleanup_script}" --compact-logs 2>&1)"; then
    printf 'Compaction unexpectedly accepted an open database\n' >&2
    exit 1
fi
[[ "${open_database_output}" == *"close Codex before compacting"* ]]
[[ "$(/usr/bin/stat -f '%z' "${codex_dir}/logs_2.sqlite")" -eq "${database_before}" ]]

run_cleanup --compact-logs
database_after="$(/usr/bin/stat -f '%z' "${codex_dir}/logs_2.sqlite")"
[[ "${database_after}" -lt "${database_before}" ]]
[[ "$(sqlite3 -readonly "${codex_dir}/logs_2.sqlite" 'PRAGMA integrity_check;')" == "ok" ]]
assert_exists "${codex_dir}/sessions/2026/07/31/rollout.jsonl"
assert_exists "${codex_dir}/plugins/example/SKILL.md"

if missing_confirmation_output="$(run_cleanup --prune-caches 2>&1)"; then
    printf 'Cache pruning unexpectedly ran without --yes\n' >&2
    exit 1
fi
[[ "${missing_confirmation_output}" == *"requires --yes"* ]]
assert_exists "${codex_dir}/.tmp/plugins/archive"
assert_exists "${codex_dir}/cache/catalog/index.json"
assert_exists "${codex_cache_dir}/Default/cache.bin"

run_cleanup --prune-caches --yes
assert_absent "${codex_dir}/.tmp"
assert_absent "${codex_dir}/cache"
assert_absent "${codex_cache_dir}"
assert_exists "${codex_dir}/sessions/2026/07/31/rollout.jsonl"
assert_exists "${codex_dir}/plugins/example/SKILL.md"

echo "Codex cleanup tests passed"
