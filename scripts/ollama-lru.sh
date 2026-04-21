#!/usr/bin/env bash
# ABOUTME: LRU-based Ollama model pruning with profile-aware protection (Story 08.1-004)
# ABOUTME: Reports stale models, prompts for removal, or auto-prunes in --auto mode

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Last-use is derived (in order of preference) from:
#   1. Ollama server log (parses "model=<name>" request lines)
#   2. Manifest file mtime (represents pull/refresh time — floor only)
OLLAMA_LOG="${OLLAMA_LOG:-/tmp/ollama-serve.log}"
OLLAMA_MANIFESTS="${HOME}/.ollama/models/manifests/registry.ollama.ai/library"

# Default retention window (can be overridden per invocation)
DEFAULT_THRESHOLD_DAYS=30

# Profile-expected models (mirror flake.nix ollamaModels.* and health-api.py).
# These are NEVER auto-removed in --auto mode, but can be manually selected
# via --prune.  Keep in sync with flake.nix.
PROFILE_STANDARD=(ministral-3 nomic-embed-text)
PROFILE_POWER=(gemma4 nomic-embed-text)
PROFILE_AI_ASSISTANT=(nomic-embed-text)

# =============================================================================
# PROFILE DETECTION
# =============================================================================

detect_profile() {
    local candidates=(
        "${HOME}/.config/nix-install/user-config.nix"
        "${HOME}/nix-install/user-config.nix"
        "${HOME}/Documents/nix-install/user-config.nix"
    )
    for config in "${candidates[@]}"; do
        if [[ -f "${config}" ]]; then
            local p
            p=$(grep -E '^\s*installProfile\s*=' "${config}" 2>/dev/null \
                | sed -E 's/.*"([^"]+)".*/\1/' || true)
            if [[ "${p}" == "power" || "${p}" == "standard" || "${p}" == "ai-assistant" ]]; then
                echo "${p}"
                return 0
            fi
        fi
    done
    echo "standard"  # conservative fallback
}

# Return protected model name prefixes for the detected profile.
profile_protected_prefixes() {
    local profile="$1"
    case "${profile}" in
        power)        printf '%s\n' "${PROFILE_POWER[@]}" ;;
        ai-assistant) printf '%s\n' "${PROFILE_AI_ASSISTANT[@]}" ;;
        *)            printf '%s\n' "${PROFILE_STANDARD[@]}" ;;
    esac
}

# Return 0 if the given model tag starts with any profile-protected prefix.
is_protected() {
    local tag="$1"
    local profile="$2"
    local base="${tag%%:*}"   # strip ":14b" etc. to compare on family name
    while read -r prefix; do
        [[ "${base}" == "${prefix}" ]] && return 0
    done < <(profile_protected_prefixes "${profile}")
    return 1
}

# =============================================================================
# LAST-USE DETECTION
# =============================================================================

# Print the most recent epoch timestamp a model appears in the server log,
# or "0" if no entry is found.
# Ollama server logs include lines like: ... model=gemma4:26b ...
last_use_from_log() {
    local tag="$1"
    if [[ ! -f "${OLLAMA_LOG}" ]]; then
        echo 0
        return
    fi
    # Grep lines mentioning this exact tag; keep newest; extract the "time=...T..." stamp
    local line
    line=$(grep -F "model=${tag}" "${OLLAMA_LOG}" 2>/dev/null | tail -1 || true)
    if [[ -z "${line}" ]]; then
        echo 0
        return
    fi
    # Ollama server logs time as "time=2026-04-21T17:00:00.000Z level=INFO ..."
    local ts_iso
    ts_iso=$(echo "${line}" | grep -oE 'time="?[0-9T:.-]+Z?' | head -1 | sed -E 's/^time="?//' || true)
    if [[ -z "${ts_iso}" ]]; then
        echo 0
        return
    fi
    # Convert ISO-8601 → epoch on macOS (requires -j and a matching format)
    local epoch
    epoch=$(date -ju -f "%Y-%m-%dT%H:%M:%S" "${ts_iso%.*}" "+%s" 2>/dev/null || echo 0)
    echo "${epoch}"
}

# Fall back to manifest mtime (covers the case of zero log entries — model
# pulled but never used). Represents pull time, which is a conservative floor
# for "last known activity".
last_use_from_manifest() {
    local tag="$1"
    local model="${tag%%:*}"
    local ver="${tag##*:}"
    [[ "${ver}" == "${model}" ]] && ver="latest"
    local path="${OLLAMA_MANIFESTS}/${model}/${ver}"
    if [[ -f "${path}" ]]; then
        stat -f '%m' "${path}" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Best-guess last-use epoch for a model tag.
model_last_use_epoch() {
    local tag="$1"
    local from_log from_manifest
    from_log=$(last_use_from_log "${tag}")
    from_manifest=$(last_use_from_manifest "${tag}")
    if [[ "${from_log}" -gt "${from_manifest}" ]]; then
        echo "${from_log}"
    else
        echo "${from_manifest}"
    fi
}

# =============================================================================
# MODEL ENUMERATION
# =============================================================================

# Parse `ollama list` output to yield "tag<TAB>size" lines.
list_models() {
    if ! command -v ollama &>/dev/null; then
        echo "ollama: command not found" >&2
        return 1
    fi
    ollama list 2>/dev/null | awk 'NR>1 && $1 != "" { print $1 "\t" $3 $4 }'
}

# =============================================================================
# REPORTING
# =============================================================================

now_epoch() { date '+%s'; }

# Print a pretty-printed analysis table.
# Format: tag  size  last-used  days-idle  protected?
analyze() {
    local profile; profile=$(detect_profile)
    local now; now=$(now_epoch)

    printf '%-30s %8s %12s %10s %s\n' "MODEL" "SIZE" "LAST USE" "DAYS IDLE" "PROTECTED"
    printf '%s\n' "---------------------------------------------------------------------------------"

    while IFS=$'\t' read -r tag size; do
        [[ -z "${tag}" ]] && continue
        local epoch; epoch=$(model_last_use_epoch "${tag}")
        local days_idle="-"
        local last_str="never"
        if [[ "${epoch}" -gt 0 ]]; then
            days_idle=$(( (now - epoch) / 86400 ))
            last_str=$(date -r "${epoch}" '+%Y-%m-%d')
        fi
        local prot="no"
        is_protected "${tag}" "${profile}" && prot="yes"
        printf '%-30s %8s %12s %10s %s\n' "${tag}" "${size}" "${last_str}" "${days_idle}" "${prot}"
    done < <(list_models)

    echo ""
    echo "Profile: ${profile} — models matching protected prefixes are never auto-pruned."
}

# Return stale model tags (days-idle > threshold) as newline-separated list.
stale_tags() {
    local threshold_days="$1"
    local now; now=$(now_epoch)
    local threshold_sec=$(( threshold_days * 86400 ))

    while IFS=$'\t' read -r tag size; do
        [[ -z "${tag}" ]] && continue
        local epoch; epoch=$(model_last_use_epoch "${tag}")
        # If we have no signal at all, don't flag (let user decide)
        [[ "${epoch}" -eq 0 ]] && continue
        local idle=$(( now - epoch ))
        if [[ "${idle}" -gt "${threshold_sec}" ]]; then
            echo "${tag}"
        fi
    done < <(list_models)
}

# Interactive prune — ask y/N per stale model.
prune_interactive() {
    local threshold_days="$1"
    local profile; profile=$(detect_profile)
    local tags
    tags=$(stale_tags "${threshold_days}")
    if [[ -z "${tags}" ]]; then
        echo "No models idle for >${threshold_days}d."
        return 0
    fi

    echo "Stale models (idle >${threshold_days}d, profile=${profile}):"
    echo ""
    while IFS= read -r tag; do
        local prot="no"; is_protected "${tag}" "${profile}" && prot="yes (profile-expected)"
        local epoch; epoch=$(model_last_use_epoch "${tag}")
        local last_str="never"; [[ "${epoch}" -gt 0 ]] && last_str=$(date -r "${epoch}" '+%Y-%m-%d')
        printf '  %s  (last use: %s, protected: %s)\n' "${tag}" "${last_str}" "${prot}"
    done <<< "${tags}"
    echo ""

    while IFS= read -r tag; do
        read -r -p "Remove ${tag}? [y/N] " reply </dev/tty || reply=""
        case "${reply}" in
            [yY]|[yY][eE][sS])
                if ollama rm "${tag}"; then
                    echo "✓ Removed: ${tag}"
                else
                    echo "✗ Failed to remove: ${tag}" >&2
                fi
                ;;
            *)
                echo "  skipped: ${tag}"
                ;;
        esac
    done <<< "${tags}"
}

# Non-interactive prune — used by the LaunchAgent.
# Never touches profile-protected models.
prune_auto() {
    local threshold_days="$1"
    local profile; profile=$(detect_profile)
    local removed=0
    while IFS= read -r tag; do
        [[ -z "${tag}" ]] && continue
        if is_protected "${tag}" "${profile}"; then
            echo "⊘ Protected (profile=${profile}): ${tag}"
            continue
        fi
        if ollama rm "${tag}" 2>&1; then
            echo "✓ Removed: ${tag}"
            removed=$((removed + 1))
        else
            echo "✗ Failed to remove: ${tag}" >&2
        fi
    done < <(stale_tags "${threshold_days}")
    echo ""
    echo "Summary: ${removed} model(s) removed (threshold=${threshold_days}d, profile=${profile})."
}

# =============================================================================
# DISPATCH
# =============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") [MODE] [options]

Modes:
  --analyze (default)   Report each model's size and days-since-use.
  --prune               Interactive: ask y/N per stale model. Respects
                        --threshold-days but DOES NOT auto-protect the
                        profile-expected list (you decide).
  --auto                Non-interactive: remove stale models. ALWAYS
                        preserves profile-expected models. Designed for
                        the opt-in LaunchAgent.

Options:
  --threshold-days=N    Idle-days threshold for --prune / --auto (default: ${DEFAULT_THRESHOLD_DAYS}).
  --help, -h            This message.

Env:
  OLLAMA_LOG            Override path to the Ollama server log for
                        last-use parsing (default: /tmp/ollama-serve.log).

Profile-expected models are detected from user-config.nix and loaded
from the hardcoded list in this script — keep in sync with flake.nix.
EOF
}

main() {
    local mode="analyze"
    local threshold="${DEFAULT_THRESHOLD_DAYS}"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --analyze) mode="analyze"; shift ;;
            --prune)   mode="prune"; shift ;;
            --auto)    mode="auto"; shift ;;
            --threshold-days=*) threshold="${1#*=}"; shift ;;
            --threshold-days)   threshold="${2:?}"; shift 2 ;;
            -h|--help) usage; exit 0 ;;
            *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
        esac
    done

    case "${mode}" in
        analyze) analyze ;;
        prune)   prune_interactive "${threshold}" ;;
        auto)    prune_auto "${threshold}" ;;
    esac
}

main "$@"
