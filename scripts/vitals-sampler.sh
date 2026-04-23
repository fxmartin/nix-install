#!/usr/bin/env bash
# ABOUTME: Capture hourly system vitals samples from the local /metrics endpoint
# ABOUTME: Persists a 7-day rolling window for weekly-maintenance-digest.sh

set -euo pipefail

HISTORY_DIR="${HOME}/.local/share/nix-install"
HISTORY_FILE="${HISTORY_DIR}/vitals-history.json"
MAX_SAMPLES=168
METRICS_URL="${METRICS_URL:-http://localhost:7780/metrics}"

mkdir -p "${HISTORY_DIR}"

json="$(curl -fsS --connect-timeout 3 --max-time 5 "${METRICS_URL}" 2>/dev/null || true)"
if [[ -z "${json}" ]]; then
    echo "vitals-sampler: /metrics unavailable" >&2
    exit 1
fi

metrics_tmp="${HISTORY_FILE}.metrics.tmp"
tmp_file="${HISTORY_FILE}.tmp"
printf '%s' "${json}" > "${metrics_tmp}"
/usr/bin/python3 - "${HISTORY_FILE}" "${MAX_SAMPLES}" "${metrics_tmp}" > "${tmp_file}" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

history_path = Path(sys.argv[1])
max_samples = int(sys.argv[2])
metrics_path = Path(sys.argv[3])
raw = json.loads(metrics_path.read_text(encoding="utf-8"))

sample = {
    "ts": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "power_watts": raw.get("power", {}).get("total_watts", 0),
    "cpu_temp_c": raw.get("thermal", {}).get("cpu_temp_c", 0),
    "gpu_temp_c": raw.get("thermal", {}).get("gpu_temp_c", 0),
    "swap_used_gb": raw.get("memory", {}).get("swap_used_gb", 0),
    "top_cpu": raw.get("processes", {}).get("top_cpu", []),
}

history = {"samples": []}
if history_path.exists():
    try:
        history = json.loads(history_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        history = {"samples": []}

samples = history.get("samples", [])
samples.append(sample)
history["samples"] = samples[-max_samples:]
print(json.dumps(history, indent=2))
PY

mv "${tmp_file}" "${HISTORY_FILE}"
rm -f "${metrics_tmp}"
