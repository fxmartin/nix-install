#!/usr/bin/env bash
# ABOUTME: One-off LaunchAgent steady-state RSS audit (Story 08.2-004)
# ABOUTME: Samples each known agent 10x over 5min and reports median RSS in MB
#
# Utility script — NOT scheduled. Run manually when you want a fresh
# snapshot of memory cost per LaunchAgent, e.g. after adding new ones.
# Output is a markdown table that can be pasted into docs/architecture.md.
#
# Scheduled one-shot agents (nix-gc, disk-cleanup, etc.) typically only run
# briefly and are not resident — they'll appear as "not running" in the
# audit, which is the expected state. The interesting rows are the
# always-on agents: ollama-serve, health-api, beszel-agent.

set -euo pipefail

# Sample configuration
SAMPLES="${SAMPLES:-10}"
INTERVAL_SEC="${INTERVAL_SEC:-30}"  # 10 samples × 30s = 5 minutes total
WARN_MB="${WARN_MB:-100}"

# Agents known to this repo (Epic-06 through Epic-08).
# Keep in sync with darwin/maintenance.nix, darwin/health-api.nix,
# darwin/monitoring.nix, darwin/rsync-backup.nix, darwin/icloud-sync.nix.
COMMON_AGENTS=(
    # Epic-06
    nix-gc nix-optimize weekly-digest disk-cleanup release-monitor
    ollama-serve health-api beszel-agent claude-code-cleanup
    # Epic-08
    claude-project-prune docker-deep-prune ollama-lru ollama-pressure-guard
)

# Power-profile only (guarded at print time — don't fail if missing)
POWER_AGENTS=(
    rsync-backup-daily rsync-backup-weekly-sunday
    rsync-backup-weekly-wednesday icloud-sync
)

# Root-level daemons (launchctl scope differs)
SYSTEM_DAEMONS=(
    nix-gc-system
)

# Resolve the pid of a user-level service, or empty string if not running.
# `|| true` — launchctl print exits non-zero for unloaded services, which
# would kill the script under `set -euo pipefail`. Non-running is a normal
# outcome we want to report as empty, not as an error.
user_agent_pid() {
    local label="$1"
    launchctl print "gui/$UID/org.nixos.${label}" 2>/dev/null \
        | awk '/^[[:space:]]*pid = / {print $3; exit}' \
        || true
}

# Resolve the pid of a system-level daemon.
system_daemon_pid() {
    local label="$1"
    sudo -n launchctl print "system/org.nixos.${label}" 2>/dev/null \
        | awk '/^[[:space:]]*pid = / {print $3; exit}' \
        || true
}

# Return RSS (in KB) for a pid, or empty if the process has exited.
# `|| true` — ps exits non-zero when the pid no longer exists (common
# for scheduled one-shots that fire between samples).
rss_kb() {
    local pid="$1"
    [[ -z "$pid" ]] && return 0
    ps -o rss= -p "$pid" 2>/dev/null | awk '{print $1}' || true
}

# Compute median of stdin (newline-separated integers). Empty input → empty output.
median() {
    awk '
        { values[NR] = $1 }
        END {
            if (NR == 0) { print ""; exit }
            # Simple sort (NR is small — typically 10)
            n = NR
            for (i = 1; i <= n; i++) for (j = i+1; j <= n; j++)
                if (values[i] > values[j]) { t = values[i]; values[i] = values[j]; values[j] = t }
            if (n % 2) print values[(n+1)/2]
            else print int((values[n/2] + values[n/2+1]) / 2)
        }
    '
}

# -----------------------------------------------------------------------------
# Sample collection
# -----------------------------------------------------------------------------

# Build unified list: "label\tscope" (user or system)
# Power agents are included unconditionally; missing ones just report "not running".
agents_list=$(mktemp)
for a in "${COMMON_AGENTS[@]}" "${POWER_AGENTS[@]}"; do
    printf '%s\tuser\n' "$a" >> "$agents_list"
done
for d in "${SYSTEM_DAEMONS[@]}"; do
    printf '%s\tsystem\n' "$d" >> "$agents_list"
done

# Per-agent sample file: results/<label> containing one RSS (KB) per line.
results_dir=$(mktemp -d)
trap 'rm -rf "$results_dir" "$agents_list"' EXIT

echo "Sampling ${SAMPLES} times at ${INTERVAL_SEC}s intervals (≈ $(( SAMPLES * INTERVAL_SEC / 60 )) minutes)..."
for (( i = 1; i <= SAMPLES; i++ )); do
    printf "  Sample %d/%d...\n" "$i" "$SAMPLES"
    while IFS=$'\t' read -r label scope; do
        if [[ "$scope" == "system" ]]; then
            pid=$(system_daemon_pid "$label")
        else
            pid=$(user_agent_pid "$label")
        fi
        kb=$(rss_kb "$pid")
        # Empty kb means the process wasn't running at this sample — record a
        # sentinel so we can count miss ratio in the summary.
        echo "${kb:-0}" >> "${results_dir}/${label}"
    done < "$agents_list"
    # Don't sleep after the last sample
    if (( i < SAMPLES )); then
        sleep "$INTERVAL_SEC"
    fi
done

# -----------------------------------------------------------------------------
# Markdown report
# -----------------------------------------------------------------------------

echo ""
echo "## LaunchAgent Memory Profile"
echo ""
echo "_Median RSS over ${SAMPLES} samples, ${INTERVAL_SEC}s interval. Flag threshold: ${WARN_MB} MB._"
echo ""
echo "| Agent | Scope | Running samples | Median RSS (MB) | Notes |"
echo "|-------|-------|-----------------|-----------------|-------|"

while IFS=$'\t' read -r label scope; do
    file="${results_dir}/${label}"
    # Count samples where rss > 0 (i.e. process was running at that tick)
    running=$(awk '$1 > 0' "$file" | wc -l | tr -d ' ')
    if [[ "$running" -eq 0 ]]; then
        printf '| %s | %s | 0/%d | — | not running during audit (scheduled one-shot) |\n' \
            "$label" "$scope" "$SAMPLES"
        continue
    fi

    # Median RSS only over samples where process was running
    median_kb=$(awk '$1 > 0' "$file" | median)
    median_mb=$(( median_kb / 1024 ))

    flag=""
    (( median_mb > WARN_MB )) && flag=" ⚠"

    printf '| %s | %s | %d/%d | %d%s |  |\n' \
        "$label" "$scope" "$running" "$SAMPLES" "$median_mb" "$flag"
done < "$agents_list"

echo ""
echo "_System-level daemons require \`sudo\` for \`launchctl print system/...\` — re-run with sudo if all system daemons show as 'not running' unexpectedly._"
