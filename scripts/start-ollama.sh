#!/usr/bin/env bash
# ABOUTME: Starts Ollama only when the external model drive is mounted.
# ABOUTME: Keeps large model files off the internal MacBook disk.

set -euo pipefail

VOLUME_PATH="${OLLAMA_EXTERNAL_VOLUME:-/Volumes/UGREEN-storage}"
MODEL_DIR="${OLLAMA_MODEL_DIR_ON_VOLUME:-$VOLUME_PATH/ollama-models}"
OLLAMA_BIN="${OLLAMA_BIN:-/opt/homebrew/bin/ollama}"
LOG_FILE="${OLLAMA_LOG_FILE:-/tmp/ollama-serve.log}"
ERR_FILE="${OLLAMA_ERR_FILE:-/tmp/ollama-serve.err}"
LAUNCH_LABEL="${OLLAMA_LAUNCH_LABEL:-org.nixos.ollama-manual}"

show_error() {
  local message="$1"
  printf 'Error: %s\n' "$message" >&2

  if command -v osascript >/dev/null 2>&1; then
    osascript -e "display alert \"Ollama cannot start\" message \"$message\"" >/dev/null 2>&1 || true
  fi
}

if ! /sbin/mount | /usr/bin/grep -q " on ${VOLUME_PATH} "; then
  show_error "External drive UGREEN-storage is not mounted at ${VOLUME_PATH}."
  exit 1
fi

if [[ ! -d "$MODEL_DIR" ]]; then
  show_error "Ollama model directory is missing: ${MODEL_DIR}."
  exit 1
fi

if [[ ! -x "$OLLAMA_BIN" ]]; then
  show_error "Ollama binary is missing or not executable: ${OLLAMA_BIN}."
  exit 1
fi

if /usr/bin/pgrep -f "[o]llama serve" >/dev/null 2>&1; then
  printf 'Ollama is already running.\n'
  "$OLLAMA_BIN" list
  exit 0
fi

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1}"
export OLLAMA_ORIGINS="${OLLAMA_ORIGINS:-http://localhost:*,http://127.0.0.1:*}"
export OLLAMA_MAX_LOADED_MODELS="${OLLAMA_MAX_LOADED_MODELS:-1}"
export OLLAMA_NUM_PARALLEL="${OLLAMA_NUM_PARALLEL:-1}"
export OLLAMA_KEEP_ALIVE="${OLLAMA_KEEP_ALIVE:-5m}"

/bin/launchctl remove "$LAUNCH_LABEL" >/dev/null 2>&1 || true
/bin/launchctl submit -l "$LAUNCH_LABEL" -- /bin/bash -lc \
  "OLLAMA_HOST='$OLLAMA_HOST' OLLAMA_ORIGINS='$OLLAMA_ORIGINS' OLLAMA_MAX_LOADED_MODELS='$OLLAMA_MAX_LOADED_MODELS' OLLAMA_NUM_PARALLEL='$OLLAMA_NUM_PARALLEL' OLLAMA_KEEP_ALIVE='$OLLAMA_KEEP_ALIVE' exec '$OLLAMA_BIN' serve >>'$LOG_FILE' 2>>'$ERR_FILE'"

sleep 3

if "$OLLAMA_BIN" list >/dev/null 2>&1; then
  printf 'Started Ollama via launchd label %s.\n' "$LAUNCH_LABEL"
  "$OLLAMA_BIN" list
else
  /bin/launchctl remove "$LAUNCH_LABEL" >/dev/null 2>&1 || true
  show_error "Ollama failed to start. Check ${ERR_FILE}."
  exit 1
fi
