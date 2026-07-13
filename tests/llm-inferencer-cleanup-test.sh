#!/usr/bin/env bash
# ABOUTME: Exercises LLM inferencer cleanup against isolated disposable fixtures
# ABOUTME: Verifies dry-run, deletion boundaries, app validation, and idempotence

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cleanup_script="${repo_root}/scripts/cleanup-llm-inferencers.sh"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

test_home="${test_root}/home"
applications_dir="${test_root}/Applications"
mkdir -p \
    "${test_home}/.lmstudio/models" \
    "${test_home}/.omlx/models" \
    "${test_home}/.local/share/local-code-bench-servers" \
    "${test_home}/dev/local-code-bench/.venv" \
    "${test_home}/dev/local-code-bench/src" \
    "${test_home}/Library/Containers/com.inferencer" \
    "${test_home}/.ollama/models" \
    "${test_home}/.cache/huggingface" \
    "${test_home}/.local/share/privacy-filter" \
    "${test_home}/.local/bin" \
    "${applications_dir}/LM Studio.app/Contents" \
    "${applications_dir}/Inferencer.app/Contents"

touch \
    "${test_home}/.lmstudio/models/model.gguf" \
    "${test_home}/.omlx/models/model.safetensors" \
    "${test_home}/.local/share/local-code-bench-servers/runtime" \
    "${test_home}/dev/local-code-bench/.venv/python" \
    "${test_home}/dev/local-code-bench/src/keep.py" \
    "${test_home}/Library/Containers/com.inferencer/state" \
    "${test_home}/.ollama/models/keep" \
    "${test_home}/.cache/huggingface/keep" \
    "${test_home}/.local/share/privacy-filter/keep"

for command_name in dflash turboquant-serve vllm-mlx mtplx; do
    ln -s "${test_home}/.local/share/local-code-bench-servers/venv/bin/${command_name}" \
        "${test_home}/.local/bin/${command_name}"
done

cat >"${applications_dir}/LM Studio.app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>CFBundleIdentifier</key><string>ai.elementlabs.lmstudio</string></dict></plist>
PLIST
cat >"${applications_dir}/Inferencer.app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>CFBundleIdentifier</key><string>com.inferencer</string></dict></plist>
PLIST

run_cleanup() {
    CLEANUP_HOME="$test_home" \
        CLEANUP_APPLICATIONS_DIR="$applications_dir" \
        CLEANUP_SKIP_PACKAGE_MANAGERS=1 \
        CLEANUP_SKIP_PROCESS_STOP=1 \
        bash "$cleanup_script" "$@"
}

run_cleanup_with_rm() {
    local rm_command="$1"
    shift
    CLEANUP_HOME="$test_home" \
        CLEANUP_APPLICATIONS_DIR="$applications_dir" \
        CLEANUP_SKIP_PACKAGE_MANAGERS=1 \
        CLEANUP_SKIP_PROCESS_STOP=1 \
        CLEANUP_RM_BIN="$rm_command" \
        bash "$cleanup_script" "$@"
}

assert_exists() {
    if [ ! -e "$1" ] && [ ! -L "$1" ]; then
        echo "Expected path to exist: $1" >&2
        exit 1
    fi
}

assert_absent() {
    if [ -e "$1" ] || [ -L "$1" ]; then
        echo "Expected path to be absent: $1" >&2
        exit 1
    fi
}

run_cleanup
assert_exists "${test_home}/.lmstudio"
assert_exists "${test_home}/.omlx"
assert_exists "${applications_dir}/LM Studio.app"

run_cleanup --apply

for retired_path in \
    "${test_home}/.lmstudio" \
    "${test_home}/.omlx" \
    "${test_home}/.local/share/local-code-bench-servers" \
    "${test_home}/dev/local-code-bench/.venv" \
    "${test_home}/Library/Containers/com.inferencer" \
    "${applications_dir}/LM Studio.app" \
    "${applications_dir}/Inferencer.app"; do
    assert_absent "$retired_path"
done

for command_name in dflash turboquant-serve vllm-mlx mtplx; do
    assert_absent "${test_home}/.local/bin/${command_name}"
done

assert_exists "${test_home}/.ollama/models/keep"
assert_exists "${test_home}/.cache/huggingface/keep"
assert_exists "${test_home}/.local/share/privacy-filter/keep"
assert_exists "${test_home}/dev/local-code-bench/src/keep.py"

# A second apply must be a safe no-op.
run_cleanup --apply

# A protected target must not prevent later allowlisted targets from cleanup.
mkdir -p "${test_home}/Library/Containers/com.inferencer"
touch "${test_home}/Library/Containers/com.inferencer/protected"
ln -s "${test_home}/retired/dflash" "${test_home}/.local/bin/dflash"
mock_rm="${test_root}/mock-rm"
cat >"$mock_rm" <<'MOCK'
#!/usr/bin/env bash
for argument in "$@"; do
    if [[ "$argument" == */Library/Containers/com.inferencer ]]; then
        exit 1
    fi
done
exec /bin/rm "$@"
MOCK
chmod +x "$mock_rm"
if run_cleanup_with_rm "$mock_rm" --apply; then
    echo "Cleanup unexpectedly ignored a target deletion failure" >&2
    exit 1
fi
assert_exists "${test_home}/Library/Containers/com.inferencer"
assert_absent "${test_home}/.local/bin/dflash"

# Refuse to delete an application if its bundle identity does not match.
mkdir -p "${applications_dir}/LM Studio.app/Contents"
sed 's/ai\.elementlabs\.lmstudio/com.example.not-lmstudio/' \
    "${repo_root}/tests/fixtures/lm-studio-info.plist" \
    >"${applications_dir}/LM Studio.app/Contents/Info.plist"
if run_cleanup --apply; then
    echo "Cleanup unexpectedly accepted a mismatched application bundle" >&2
    exit 1
fi
assert_exists "${applications_dir}/LM Studio.app"

echo "LLM inferencer cleanup tests passed"
