#!/usr/bin/env bash
# ABOUTME: Removes retired local LLM inferencers and their downloaded data
# ABOUTME: Defaults to dry-run and protects retained Ollama, MLX, and project state

set -euo pipefail

mode="dry-run"
case "${1:-}" in
    "") ;;
    --dry-run) ;;
    --apply) mode="apply" ;;
    -h|--help)
        echo "Usage: $(basename "$0") [--dry-run|--apply]"
        exit 0
        ;;
    *)
        echo "Usage: $(basename "$0") [--dry-run|--apply]" >&2
        exit 2
        ;;
esac

if [ "$#" -gt 1 ]; then
    echo "Usage: $(basename "$0") [--dry-run|--apply]" >&2
    exit 2
fi

cleanup_home="${CLEANUP_HOME:-${HOME}}"
applications_dir="${CLEANUP_APPLICATIONS_DIR:-/Applications}"
skip_package_managers="${CLEANUP_SKIP_PACKAGE_MANAGERS:-0}"
skip_process_stop="${CLEANUP_SKIP_PROCESS_STOP:-0}"
plist_buddy="${CLEANUP_PLIST_BUDDY:-/usr/libexec/PlistBuddy}"
rm_bin="${CLEANUP_RM_BIN:-rm}"
failure=0
reclaimable_kib=0

retired_paths=(
    "${cleanup_home}/.lmstudio"
    "${cleanup_home}/.omlx"
    "${cleanup_home}/.local/share/local-code-bench-servers"
    "${cleanup_home}/dev/local-code-bench/.venv"
    "${cleanup_home}/Library/Containers/com.inferencer"
)

retired_links=(
    "${cleanup_home}/.local/bin/dflash"
    "${cleanup_home}/.local/bin/turboquant-serve"
    "${cleanup_home}/.local/bin/vllm-mlx"
    "${cleanup_home}/.local/bin/mtplx"
)

is_allowlisted_path() {
    local candidate="$1"
    local allowlisted
    for allowlisted in "${retired_paths[@]}" "${retired_links[@]}"; do
        if [ "$candidate" = "$allowlisted" ]; then
            return 0
        fi
    done
    return 1
}

record_size() {
    local target="$1"
    local size_kib
    if [ -e "$target" ] || [ -L "$target" ]; then
        size_kib="$(du -sk "$target" 2>/dev/null | awk '{print $1}')"
        reclaimable_kib=$((reclaimable_kib + ${size_kib:-0}))
    fi
}

remove_allowlisted_path() {
    local target="$1"
    if ! is_allowlisted_path "$target"; then
        echo "Refusing non-allowlisted path: $target" >&2
        failure=1
        return
    fi
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        return
    fi

    record_size "$target"
    if [ "$mode" = "apply" ]; then
        echo "Removing $target"
        if ! "$rm_bin" -rf "$target"; then
            echo "Failed to remove $target; continuing with remaining targets" >&2
            failure=1
        fi
    else
        echo "Would remove $target"
    fi
}

read_bundle_id() {
    local app_path="$1"
    "$plist_buddy" -c 'Print :CFBundleIdentifier' "$app_path/Contents/Info.plist" 2>/dev/null
}

remove_validated_app() {
    local app_name="$1"
    local expected_bundle_id="$2"
    local app_path="${applications_dir}/${app_name}"
    local actual_bundle_id

    if [ ! -e "$app_path" ]; then
        return
    fi
    if ! actual_bundle_id="$(read_bundle_id "$app_path")"; then
        echo "Refusing to remove $app_path: bundle identifier is unreadable" >&2
        failure=1
        return
    fi
    if [ "$actual_bundle_id" != "$expected_bundle_id" ]; then
        echo "Refusing to remove $app_path: expected $expected_bundle_id, found $actual_bundle_id" >&2
        failure=1
        return
    fi

    record_size "$app_path"
    if [ "$mode" = "dry-run" ]; then
        echo "Would remove $app_path (bundle $actual_bundle_id)"
    elif [ -w "$applications_dir" ]; then
        echo "Removing $app_path"
        if ! "$rm_bin" -rf "$app_path"; then
            echo "Failed to remove $app_path; continuing with remaining targets" >&2
            failure=1
        fi
    else
        echo "Removing $app_path with administrator privileges"
        if ! sudo rm -rf "$app_path"; then
            echo "Failed to remove $app_path; continuing with remaining targets" >&2
            failure=1
        fi
    fi
}

stop_retired_processes() {
    if [ "$mode" != "apply" ] || [ "$skip_process_stop" = "1" ]; then
        return
    fi
    osascript -e 'tell application "LM Studio" to quit' >/dev/null 2>&1 || true
    osascript -e 'tell application "Inferencer" to quit' >/dev/null 2>&1 || true
    pkill -x 'LM Studio' >/dev/null 2>&1 || true
    pkill -x 'Inferencer' >/dev/null 2>&1 || true
}

uninstall_retired_packages() {
    local formula
    if [ "$skip_package_managers" = "1" ]; then
        return
    fi

    if command -v brew >/dev/null 2>&1; then
        for formula in llama.cpp omlx; do
            if brew list --formula "$formula" >/dev/null 2>&1; then
                if [ "$mode" = "apply" ]; then
                    brew uninstall "$formula"
                else
                    echo "Would run: brew uninstall $formula"
                fi
            fi
        done
        if brew list --cask lm-studio >/dev/null 2>&1; then
            if [ "$mode" = "apply" ]; then
                brew uninstall --cask lm-studio
            else
                echo "Would run: brew uninstall --cask lm-studio"
            fi
        fi
        if brew tap | rg -x 'jundot/omlx' >/dev/null 2>&1; then
            if [ "$mode" = "apply" ]; then
                brew untap jundot/omlx
            else
                echo "Would run: brew untap jundot/omlx"
            fi
        fi
    fi

    # Inferencer is removed directly after validating its bundle identifier.
    # Avoid `mas list` here: it can block indefinitely when App Store services
    # are unavailable, and deleting the validated bundle handles MAS installs.
}

echo "LLM inferencer cleanup mode: $mode"
echo "Preserving Ollama, Hugging Face cache, privacy-filter state, and local-code-bench source"

stop_retired_processes
uninstall_retired_packages

for retired_path in "${retired_paths[@]}" "${retired_links[@]}"; do
    remove_allowlisted_path "$retired_path"
done

remove_validated_app "LM Studio.app" "ai.elementlabs.lmstudio"
remove_validated_app "Inferencer.app" "com.inferencer"

reclaimable_gib="$(awk -v kib="$reclaimable_kib" 'BEGIN { printf "%.1f", kib / 1048576 }')"
if [ "$mode" = "dry-run" ]; then
    echo "Estimated reclaimable space: ${reclaimable_gib} GiB"
    echo "Run with --apply to permanently delete these items."
else
    echo "Cleanup complete; processed approximately ${reclaimable_gib} GiB."
fi

exit "$failure"
