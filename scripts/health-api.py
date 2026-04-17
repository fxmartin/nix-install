#!/usr/bin/env python3
# ABOUTME: Lightweight HTTP health check API server using stdlib only
# ABOUTME: Exposes /health (diagnostics), /metrics (Apple Silicon stats), and /ping on port 7780

import json
import subprocess
import os
import socket
import hmac
import threading
import time
from datetime import datetime, timezone
from http.server import HTTPServer, BaseHTTPRequestHandler
from socketserver import ThreadingMixIn

# NOTE: These thresholds are shared with scripts/health-check.sh (CLI).
# If you change a value here, update health-check.sh to match.
PORT = 7780
GENERATION_WARNING_THRESHOLD = 50   # Warn if more than N system generations
DISK_WARNING_GB = 20                # Warn if less than N GB free
CACHE_WARNING_KB = 1_048_576        # 1 GB — warn if any single cache exceeds this

# Expected Ollama models per profile (keep in sync with flake.nix ollamaModels)
OLLAMA_MODELS = {
    "power": ["ministral-3:14b", "phi4:14b", "gemma4:e4b", "nomic-embed-text"],
    "standard": ["ministral-3:14b", "nomic-embed-text"],
}


def run(cmd: str, timeout: int = 10) -> str:
    """Run a command and return stdout, empty string on failure.

    Uses shell=False via /bin/sh -c for safety — no shell metacharacter injection.
    """
    try:
        result = subprocess.run(
            ["/bin/sh", "-c", cmd],
            capture_output=True, text=True, timeout=timeout,
        )
        return result.stdout.strip()
    except Exception:
        return ""


def check_nix_daemon() -> dict:
    if run("pgrep -x nix-daemon"):
        return {"status": "ok", "detail": "Nix daemon running"}
    return {"status": "error", "detail": "Nix daemon not running"}


def check_homebrew() -> dict:
    if not run("command -v brew"):
        return {"status": "error", "detail": "Homebrew not found"}
    if os.path.isdir("/opt/homebrew/Library/.homebrew-is-managed-by-nix"):
        return {"status": "ok", "detail": "Managed by nix-darwin"}
    return {"status": "ok", "detail": "Homebrew present"}


def check_disk() -> dict:
    # Use NSURL volumeAvailableCapacityForImportantUsage (same metric as Finder)
    # This includes purgeable space that macOS reclaims automatically
    swift_src = (
        'import Foundation\n'
        'let url = URL(fileURLWithPath: "/")\n'
        'let v = try url.resourceValues(forKeys: '
        '[.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey])\n'
        'if let t = v.volumeTotalCapacity, '
        'let a = v.volumeAvailableCapacityForImportantUsage '
        '{ print("\\(t) \\(a)") }\n'
    )
    try:
        result = subprocess.run(
            ["/usr/bin/swift", "-e", swift_src],
            capture_output=True, text=True, timeout=15
        )
        if result.returncode == 0 and result.stdout.strip():
            parts = result.stdout.strip().split()
            total_gb = int(parts[0]) // (1024 ** 3)
            free_gb = int(parts[1]) // (1024 ** 3)
            status = "warn" if free_gb < DISK_WARNING_GB else "ok"
            return {"status": status, "free_gb": free_gb, "total_gb": total_gb}
    except Exception:
        pass
    # Fallback to df (reports raw free, not purgeable-inclusive)
    line = run("df -k / | tail -1")
    if not line:
        return {"status": "error", "free_gb": 0, "total_gb": 0}
    parts = line.split()
    try:
        total_kb = int(parts[1])
        free_kb = int(parts[3])
        free_gb = free_kb // (1024 * 1024)
        total_gb = total_kb // (1024 * 1024)
        status = "warn" if free_gb < DISK_WARNING_GB else "ok"
        return {"status": status, "free_gb": free_gb, "total_gb": total_gb}
    except (IndexError, ValueError):
        return {"status": "error", "free_gb": 0, "total_gb": 0}


def check_filevault() -> dict:
    out = run("fdesetup status 2>/dev/null")
    if "FileVault is On" in out:
        return {"status": "ok"}
    return {"status": "warn"}


def check_firewall() -> dict:
    out = run("/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null")
    if "enabled" in out:
        return {"status": "ok"}
    return {"status": "warn"}


def check_generations() -> dict:
    out = run("ls -1 /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l")
    try:
        count = int(out.strip())
        status = "warn" if count > GENERATION_WARNING_THRESHOLD else "ok"
        return {"status": status, "count": count}
    except ValueError:
        return {"status": "warn", "count": 0}


# ---------------------------------------------------------------------------
# Nix store size — cached asynchronously to avoid blocking /health
# `du -sh /nix/store` takes 10+ seconds on large stores and used to run on
# every /health request.  A daemon thread refreshes the value every
# NIX_STORE_CACHE_TTL seconds off the request critical path, so check_nix_store()
# returns instantly from the cache.  Stale data is acceptable here — store size
# is a diagnostic signal, not a real-time metric.
# ---------------------------------------------------------------------------
_nix_store_cache: dict = {}
_nix_store_cache_time: float = 0.0
_nix_store_lock = threading.Lock()
NIX_STORE_CACHE_TTL = 300  # seconds (5 minutes)


def _refresh_nix_store_cache() -> None:
    """Run du -sh /nix/store and populate the cache. Safe to call from any thread."""
    global _nix_store_cache, _nix_store_cache_time  # noqa: PLW0603
    # 60s timeout: du on a hard-link-dense store (millions of inodes) can take
    # 30-50s even on M3 Max NVMe. Runs off the request critical path, so a
    # generous timeout is harmless — the request still returns instantly from cache.
    size = run("du -sh /nix/store 2>/dev/null | cut -f1", timeout=60)
    with _nix_store_lock:
        _nix_store_cache = {"size": size or "timed out"}
        _nix_store_cache_time = time.monotonic()


def _nix_store_refresher() -> None:
    """Daemon-thread loop that refreshes the cache every NIX_STORE_CACHE_TTL seconds."""
    while True:
        try:
            _refresh_nix_store_cache()
        except Exception:
            # Never let the refresher thread die — leave last-good cache in place
            pass
        time.sleep(NIX_STORE_CACHE_TTL)


def check_nix_store() -> dict:
    """Return the cached nix store size. Non-blocking.

    Returns {"size": "pending", ...} if the background refresher has not yet
    produced a first sample. Otherwise returns the last cached value.
    """
    with _nix_store_lock:
        if not _nix_store_cache:
            return {"size": "pending", "detail": "first sample in progress"}
        return dict(_nix_store_cache)


def detect_profile(launchctl_output: str) -> str:
    if "org.nixos.icloud-sync" in launchctl_output:
        return "power"
    return "standard"


def check_ollama(profile: str) -> dict:
    if not run("command -v ollama"):
        return {"status": "skipped", "models": [], "missing": [], "detail": "Ollama not installed"}
    if not run("pgrep -q ollama && echo ok"):
        return {"status": "warn", "models": [], "missing": [], "detail": "Ollama daemon not running"}

    ollama_list = run("ollama list 2>/dev/null")
    expected = OLLAMA_MODELS.get(profile, OLLAMA_MODELS["standard"])

    installed = []
    missing = []
    for model in expected:
        base = model.split(":")[0]
        if base in ollama_list:
            installed.append(model)
        else:
            missing.append(model)

    status = "ok" if not missing else ("warn" if installed else "error")
    return {"status": status, "models": installed, "missing": missing}


def check_docker() -> dict:
    if not run("command -v docker"):
        return {"status": "skipped", "detail": "Docker not installed"}
    if not run("docker info 2>/dev/null"):
        return {"status": "ok", "running": False, "images": 0, "detail": "Docker Desktop not running"}
    images_output = run("docker images --format '{{.ID}}' 2>/dev/null")
    image_count = len(images_output.splitlines()) if images_output else 0
    return {"status": "ok", "running": True, "images": image_count}


def check_launch_agents(launchctl_output: str, profile: str) -> dict:
    # Common agents (all profiles)
    expected = ["nix-gc", "nix-optimize", "weekly-digest", "disk-cleanup",
                "ollama-serve", "health-api", "release-monitor", "beszel-agent"]
    # Power-only agents
    if profile == "power":
        expected += ["rsync-backup-daily", "rsync-backup-weekly-sunday",
                     "rsync-backup-weekly-wednesday", "icloud-sync"]

    loaded = []
    missing = []
    for agent in expected:
        if f"org.nixos.{agent}" in launchctl_output:
            loaded.append(agent)
        else:
            missing.append(agent)

    status = "ok" if not missing else "warn"
    return {"status": status, "loaded": loaded, "missing": missing}


def get_cache_size(path: str) -> str:
    expanded = os.path.expanduser(path)
    if not os.path.isdir(expanded):
        return "0B"
    return run(f"du -sh {expanded} 2>/dev/null | cut -f1") or "0B"


def get_caches() -> dict:
    return {
        "uv": get_cache_size("~/.cache/uv"),
        "homebrew": get_cache_size("~/Library/Caches/Homebrew"),
        "npm": get_cache_size("~/.npm"),
    }


def compute_overall_status(checks: dict) -> str:
    has_error = False
    has_warn = False
    for value in checks.values():
        s = value.get("status", "ok")
        if s == "error":
            has_error = True
        elif s == "warn":
            has_warn = True
    if has_error:
        return "unhealthy"
    if has_warn:
        return "degraded"
    return "healthy"


def build_health_response() -> dict:
    launchctl_output = run("launchctl list 2>/dev/null")
    profile = detect_profile(launchctl_output)

    checks = {
        "nix_daemon": check_nix_daemon(),
        "homebrew": check_homebrew(),
        "disk": check_disk(),
        "filevault": check_filevault(),
        "firewall": check_firewall(),
        "generations": check_generations(),
        "nix_store": check_nix_store(),
        "docker": check_docker(),
        "ollama": check_ollama(profile),
        "launch_agents": check_launch_agents(launchctl_output, profile),
    }

    return {
        "hostname": socket.gethostname(),
        "timestamp": datetime.now(timezone.utc).astimezone().isoformat(),
        "profile": profile,
        "status": compute_overall_status(checks),
        "checks": checks,
        "caches": get_caches(),
    }


# ---------------------------------------------------------------------------
# System Metrics via mactop (Apple Silicon monitoring)
# ---------------------------------------------------------------------------
_metrics_cache: dict = {}
_metrics_cache_time: float = 0.0
METRICS_CACHE_TTL = 2  # seconds

# Last known-good mactop sample, used as a fallback when mactop times out or
# errors.  Returning slightly-stale data is far more useful than an error for
# the /metrics endpoint, which is consumed by dashboards and health-check.sh.
_metrics_last_good: dict = {}
_metrics_last_good_time: float = 0.0


def _stale_metrics_fallback(error_detail: str) -> dict:
    """Return the last-good metrics sample marked stale, or the error dict if none."""
    if _metrics_last_good:
        stale = dict(_metrics_last_good)
        stale["stale"] = True
        stale["stale_age_seconds"] = round(time.monotonic() - _metrics_last_good_time, 1)
        stale["stale_reason"] = error_detail
        return stale
    return {"status": "error", "detail": error_detail}


def get_system_metrics() -> dict:
    """Return Apple Silicon metrics from mactop (CPU, GPU, memory, thermal, power).

    Calls `mactop --headless --format json --count 1` and reshapes the output
    into a clean API response.  Results are cached for METRICS_CACHE_TTL seconds.
    On mactop timeout/error, returns the last-good sample marked as stale
    (or an error dict if no sample has ever succeeded).
    """
    global _metrics_cache, _metrics_cache_time  # noqa: PLW0603
    global _metrics_last_good, _metrics_last_good_time  # noqa: PLW0603
    now = time.monotonic()
    if _metrics_cache and (now - _metrics_cache_time) < METRICS_CACHE_TTL:
        return _metrics_cache

    mactop_bin = "/opt/homebrew/bin/mactop"
    if not os.path.isfile(mactop_bin):
        return _stale_metrics_fallback("mactop not installed")

    try:
        result = subprocess.run(
            [mactop_bin, "--headless", "--format", "json", "--count", "1"],
            capture_output=True, text=True, timeout=3,
        )
        if result.returncode != 0 or not result.stdout.strip():
            return _stale_metrics_fallback(f"mactop failed: {result.stderr.strip()[:200]}")
    except subprocess.TimeoutExpired:
        return _stale_metrics_fallback("mactop timed out (3s)")
    except Exception as e:
        return _stale_metrics_fallback(str(e)[:200])

    try:
        raw = json.loads(result.stdout)
        # mactop returns a JSON array; take first sample
        sample = raw[0] if isinstance(raw, list) else raw
    except (json.JSONDecodeError, IndexError) as e:
        return _stale_metrics_fallback(f"mactop JSON parse error: {e}")

    mem = sample.get("memory", {})
    soc = sample.get("soc_metrics", {})
    nd = sample.get("net_disk", {})
    si = sample.get("system_info", {})

    total_bytes = mem.get("total", 0)
    used_bytes = mem.get("used", 0)
    available_bytes = mem.get("available", 0)

    response = {
        "timestamp": sample.get("timestamp", datetime.now(timezone.utc).astimezone().isoformat()),
        "system": {
            "name": si.get("name", "Unknown"),
            "cores": si.get("core_count", 0),
            "e_cores": si.get("e_core_count", 0),
            "p_cores": si.get("p_core_count", 0),
            "gpu_cores": si.get("gpu_core_count", 0),
        },
        "cpu": {
            "usage_percent": round(sample.get("cpu_usage", 0), 1),
            "e_cluster": {
                "active_percent": round(soc.get("e_cluster_active", 0), 1),
                "freq_mhz": soc.get("e_cluster_freq_mhz", 0),
            },
            "p_cluster": {
                "active_percent": round(soc.get("p_cluster_active", 0), 1),
                "freq_mhz": soc.get("p_cluster_freq_mhz", 0),
            },
            "per_core": [round(c, 1) for c in sample.get("core_usages", [])],
        },
        "gpu": {
            "usage_percent": round(sample.get("gpu_usage", 0), 1),
            "freq_mhz": soc.get("gpu_freq_mhz", 0),
            "power_watts": round(soc.get("gpu_power", 0), 1),
        },
        "memory": {
            "total_gb": round(total_bytes / (1024 ** 3), 1),
            "used_gb": round(used_bytes / (1024 ** 3), 1),
            "available_gb": round(available_bytes / (1024 ** 3), 1),
            "swap_total_gb": round(mem.get("swap_total", 0) / (1024 ** 3), 1),
            "swap_used_gb": round(mem.get("swap_used", 0) / (1024 ** 3), 1),
        },
        "power": {
            "cpu_watts": round(soc.get("cpu_power", 0), 1),
            "gpu_watts": round(soc.get("gpu_power", 0), 1),
            "ane_watts": round(soc.get("ane_power", 0), 1),
            "dram_watts": round(soc.get("dram_power", 0), 1),
            "system_watts": round(soc.get("system_power", 0), 1),
            "total_watts": round(soc.get("total_power", 0), 1),
        },
        "thermal": {
            "cpu_temp_c": round(soc.get("cpu_temp", 0), 1),
            "gpu_temp_c": round(soc.get("gpu_temp", 0), 1),
            "soc_temp_c": round(soc.get("soc_temp", 0), 1),
            "state": sample.get("thermal_state", "Unknown"),
        },
        "network": {
            "in_bytes_per_sec": round(nd.get("in_bytes_per_sec", 0)),
            "out_bytes_per_sec": round(nd.get("out_bytes_per_sec", 0)),
            "in_packets_per_sec": round(nd.get("in_packets_per_sec", 0)),
            "out_packets_per_sec": round(nd.get("out_packets_per_sec", 0)),
        },
        "disk": {
            "read_kbytes_per_sec": round(nd.get("read_kbytes_per_sec", 0)),
            "write_kbytes_per_sec": round(nd.get("write_kbytes_per_sec", 0)),
            "read_ops_per_sec": round(nd.get("read_ops_per_sec", 0)),
            "write_ops_per_sec": round(nd.get("write_ops_per_sec", 0)),
        },
    }

    _metrics_cache = response
    _metrics_cache_time = now
    _metrics_last_good = response
    _metrics_last_good_time = now
    return response


# Optional bearer token authentication
# Set HEALTH_API_TOKEN environment variable to require authentication.
# When set, all requests except /ping must include: Authorization: Bearer <token>
# When unset, all endpoints are open (backwards compatible).
HEALTH_API_TOKEN = os.environ.get("HEALTH_API_TOKEN", "")


class HealthHandler(BaseHTTPRequestHandler):
    def _check_auth(self) -> bool:
        """Return True if request is authorized. Sends 401 and returns False otherwise."""
        if not HEALTH_API_TOKEN:
            return True  # No token configured — open access
        auth_header = self.headers.get("Authorization", "")
        if auth_header.startswith("Bearer "):
            token = auth_header[7:]
            if hmac.compare_digest(token, HEALTH_API_TOKEN):
                return True
        self._respond(401, {"error": "Unauthorized. Set Authorization: Bearer <token>"})
        return False

    def do_GET(self):
        if self.path == "/ping":
            self._respond(200, {"status": "ok"})
        elif self.path == "/health":
            if not self._check_auth():
                return
            self._respond(200, build_health_response())
        elif self.path == "/metrics":
            if not self._check_auth():
                return
            self._respond(200, get_system_metrics())
        else:
            self._respond(404, {"error": "Not found. Use /health, /metrics, or /ping"})

    def _respond(self, code: int, body: dict):
        payload = json.dumps(body, indent=2).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format, *args):
        # Suppress default stderr logging; write to stdout instead
        print(f"{self.address_string()} - {format % args}")


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle each request in a new thread to prevent slow checks from blocking."""
    daemon_threads = True


def main():
    # Start the nix-store refresher daemon before serving so /health never blocks
    # on `du -sh /nix/store`. It runs an initial refresh immediately and then
    # sleeps for NIX_STORE_CACHE_TTL seconds between refreshes.
    refresher = threading.Thread(
        target=_nix_store_refresher, name="nix-store-refresher", daemon=True
    )
    refresher.start()

    server = ThreadedHTTPServer(("0.0.0.0", PORT), HealthHandler)
    print(f"Health API listening on 0.0.0.0:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Shutting down health API server")
        server.server_close()


if __name__ == "__main__":
    main()
