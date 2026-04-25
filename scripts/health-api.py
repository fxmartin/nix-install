#!/usr/bin/env python3
# ABOUTME: Lightweight HTTP health check API server using stdlib only
# ABOUTME: Exposes /health (diagnostics), /metrics (Apple Silicon stats), and /ping on port 7780

import json
import subprocess
import os
import shutil
import socket
import hmac
import threading
import time
import re
import ctypes
import sys
from datetime import datetime, timezone
from http.server import HTTPServer, BaseHTTPRequestHandler
from socketserver import ThreadingMixIn

# NOTE: These thresholds are shared with scripts/health-check.sh (CLI).
# If you change a value here, update health-check.sh to match.
PORT = 7780
GENERATION_WARNING_THRESHOLD = 50   # Warn if more than N system generations
DISK_WARNING_GB = 20                # Warn if less than N GB free
CACHE_WARNING_KB = 1_048_576        # 1 GB — warn if any single cache exceeds this
HF_CACHE_WARNING_KB = 10_485_760    # 10 GB — Huggingface cache grows fastest (model blobs)
SWAP_WARNING_GB = 2                 # Warn when swap usage exceeds this (signals real memory pressure)

# Expected Ollama models per profile (keep in sync with flake.nix ollamaModels)
OLLAMA_MODELS = {
    "power": ["gemma4:e4b", "gemma4:26b", "nomic-embed-text"],
    "standard": ["ministral-3:14b", "nomic-embed-text"],
    "ai-assistant": ["nomic-embed-text"],
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
# 30 min: `du -sh /nix/store` takes 30-50s on a hard-link-dense store and
# spikes CPU during that window. Store size is diagnostic, not real-time —
# refreshing every 30 min keeps the refresher below 3% of wall clock.
NIX_STORE_CACHE_TTL = int(os.environ.get("NIX_STORE_CACHE_TTL", "1800"))


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
    """Detect installation profile from user-config.nix, fall back to LaunchAgent heuristic."""
    import pathlib
    home = pathlib.Path.home()
    for candidate in [home / ".config/nix-install", home / "nix-install", home / "Documents/nix-install"]:
        config = candidate / "user-config.nix"
        if config.exists():
            import re
            match = re.search(r'installProfile\s*=\s*"([^"]+)"', config.read_text())
            if match:
                return match.group(1)
            break
    # Fallback: detect via LaunchAgent presence
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
        "huggingface": get_cache_size("~/.cache/huggingface"),
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
# System Metrics via macmon (Apple Silicon monitoring)
# ---------------------------------------------------------------------------
# Sampling runs on a background daemon thread (same pattern as
# _nix_store_refresher).  macmon consistently takes 2-4s per sample on
# M3 Max, so running it on the request path made /metrics latency variable
# from 10ms (warm cache) to 4s (cold).  Worse, the original code had no
# lock around the cache refresh, so concurrent requests each spawned their
# own macmon subprocess — 300MB+ resident each, compounding under load.
#
# The refresher guarantees:
#   • /metrics latency is O(1) — always returns the cached dict under a lock
#   • At most one macmon subprocess at a time
#   • First request after startup may see {"status": "pending"} until the
#     first sample lands — intentional and clearly marked
_metrics_cache: dict = {"status": "pending", "detail": "first macmon sample in progress"}
_metrics_cache_time: float = 0.0
_metrics_lock = threading.Lock()
_fast_metrics_cache: dict = {}
_fast_metrics_cache_time: float = 0.0
_fast_metrics_lock = threading.Lock()
_last_core_cpu_sample: list[tuple[int, int, int, int]] | None = None

# Interval between macmon samples. macmon on M3 Max takes ~3-4s per
# --samples 1 --interval 500 call (startup + sensor enumeration).
# A 15s interval keeps macmon below ~3% of wall clock; 5s ran it at ~60%.
# Power/temp/ANE/freq are trend indicators — 15s staleness is fine.
# Override with METRICS_REFRESH_INTERVAL env var (e.g. for testing or
# machines where macmon is fast).
METRICS_REFRESH_INTERVAL = int(os.environ.get("METRICS_REFRESH_INTERVAL", "30"))
FAST_METRICS_REFRESH_INTERVAL = int(os.environ.get("FAST_METRICS_REFRESH_INTERVAL", "3"))

# Subprocess timeout for a single macmon invocation.  Runs on a
# background thread; nothing blocks on it, so generous is fine.
MACMON_TIMEOUT_SEC = int(os.environ.get("MACMON_TIMEOUT_SEC", "15"))
DEFAULT_HARDWARE_INFO = {
    "name": "Apple Silicon",
    "cores": 0,
    "e_cores": 0,
    "p_cores": 0,
    "gpu_cores": 0,
}
_hardware_info_cache: dict | None = None
_hardware_info_lock = threading.Lock()

CPU_STATE_USER = 0
CPU_STATE_SYSTEM = 1
CPU_STATE_IDLE = 2
CPU_STATE_NICE = 3
CPU_STATE_MAX = 4
PROCESSOR_CPU_LOAD_INFO = 2


def _run_lines(command: list[str], timeout: int = 5) -> list[str]:
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except Exception:
        return []
    if result.returncode != 0:
        return []
    return result.stdout.splitlines()


def _run_json(command: list[str], timeout: int = 10) -> dict:
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except Exception:
        return {}
    if result.returncode != 0 or not result.stdout.strip():
        return {}
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return {}


def _parse_cpu_core_info(hardware_json: dict) -> dict:
    hardware = hardware_json.get("SPHardwareDataType", [])
    if not hardware:
        return {}

    overview = hardware[0]
    info: dict = {}
    chip_type = overview.get("chip_type")
    if isinstance(chip_type, str) and chip_type:
        info["name"] = chip_type

    processors = overview.get("number_processors", "")
    if not isinstance(processors, str):
        return info

    match = re.search(r"proc\s+(\d+):(\d+):(\d+):", processors)
    if not match:
        return info

    cores, p_cores, e_cores = (int(value) for value in match.groups())
    info.update({
        "cores": cores,
        "p_cores": p_cores,
        "e_cores": e_cores,
    })
    return info


def _parse_gpu_core_info(displays_json: dict) -> dict:
    for display in displays_json.get("SPDisplaysDataType", []):
        if not isinstance(display, dict):
            continue
        cores = display.get("sppci_cores")
        if cores is None:
            continue
        try:
            return {"gpu_cores": int(cores)}
        except (TypeError, ValueError):
            return {}
    return {}


def _probe_hardware_info() -> dict:
    info = dict(DEFAULT_HARDWARE_INFO)

    cpu_json = _run_json(["/usr/sbin/system_profiler", "SPHardwareDataType", "-json"])
    display_json = _run_json(["/usr/sbin/system_profiler", "SPDisplaysDataType", "-json"])
    info.update(_parse_cpu_core_info(cpu_json))
    info.update(_parse_gpu_core_info(display_json))

    if info == DEFAULT_HARDWARE_INFO:
        print("health-api: hardware core counts unavailable; using zero defaults")
    return info


def get_hardware_info() -> dict:
    global _hardware_info_cache  # noqa: PLW0603
    with _hardware_info_lock:
        if _hardware_info_cache is None:
            _hardware_info_cache = _probe_hardware_info()
        return dict(_hardware_info_cache)


def _sample_core_cpu_times() -> list[tuple[int, int, int, int]]:
    """Return per-core Mach CPU tick counters as user/system/idle/nice tuples."""
    if sys.platform != "darwin":
        return []

    try:
        libsystem = ctypes.CDLL("/usr/lib/libSystem.dylib")
        processor_count = ctypes.c_uint(0)
        processor_info = ctypes.POINTER(ctypes.c_int)()
        processor_info_count = ctypes.c_uint(0)

        host_processor_info = libsystem.host_processor_info
        host_processor_info.argtypes = [
            ctypes.c_uint,
            ctypes.c_int,
            ctypes.POINTER(ctypes.c_uint),
            ctypes.POINTER(ctypes.POINTER(ctypes.c_int)),
            ctypes.POINTER(ctypes.c_uint),
        ]
        host_processor_info.restype = ctypes.c_int
        libsystem.mach_host_self.restype = ctypes.c_uint

        result = host_processor_info(
            libsystem.mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            ctypes.byref(processor_count),
            ctypes.byref(processor_info),
            ctypes.byref(processor_info_count),
        )
        if result != 0 or not processor_info:
            return []

        core_count = int(processor_count.value)
        times = []
        for index in range(core_count):
            offset = index * CPU_STATE_MAX
            times.append((
                int(processor_info[offset + CPU_STATE_USER]),
                int(processor_info[offset + CPU_STATE_SYSTEM]),
                int(processor_info[offset + CPU_STATE_IDLE]),
                int(processor_info[offset + CPU_STATE_NICE]),
            ))

        try:
            task = ctypes.c_uint.in_dll(libsystem, "mach_task_self_").value
            byte_count = int(processor_info_count.value) * ctypes.sizeof(ctypes.c_int)
            libsystem.vm_deallocate(task, ctypes.cast(processor_info, ctypes.c_void_p).value, byte_count)
        except Exception:
            pass

        return times
    except Exception:
        return []


def _core_usage_from_samples(
    previous: list[tuple[int, int, int, int]] | None,
    current: list[tuple[int, int, int, int]],
) -> dict:
    if not previous or len(previous) != len(current):
        return {
            "cores": [
                {"id": index, "active_percent": 0.0, "user_percent": 0.0, "system_percent": 0.0}
                for index in range(len(current))
            ],
            "user_percent": 0.0,
            "system_percent": 0.0,
            "idle_percent": 0.0,
        }

    cores = []
    totals = {"user": 0, "system": 0, "idle": 0, "nice": 0}
    for index, (before, after) in enumerate(zip(previous, current)):
        user = max(after[CPU_STATE_USER] - before[CPU_STATE_USER], 0)
        system_time = max(after[CPU_STATE_SYSTEM] - before[CPU_STATE_SYSTEM], 0)
        idle = max(after[CPU_STATE_IDLE] - before[CPU_STATE_IDLE], 0)
        nice = max(after[CPU_STATE_NICE] - before[CPU_STATE_NICE], 0)
        total = user + system_time + idle + nice

        totals["user"] += user
        totals["system"] += system_time
        totals["idle"] += idle
        totals["nice"] += nice

        if total <= 0:
            cores.append({"id": index, "active_percent": 0.0, "user_percent": 0.0, "system_percent": 0.0})
            continue

        cores.append({
            "id": index,
            "active_percent": round((user + system_time + nice) / total * 100, 1),
            "user_percent": round((user + nice) / total * 100, 1),
            "system_percent": round(system_time / total * 100, 1),
        })

    grand_total = sum(totals.values())
    if grand_total <= 0:
        return {"cores": cores, "user_percent": 0.0, "system_percent": 0.0, "idle_percent": 0.0}

    return {
        "cores": cores,
        "user_percent": round((totals["user"] + totals["nice"]) / grand_total * 100, 1),
        "system_percent": round(totals["system"] / grand_total * 100, 1),
        "idle_percent": round(totals["idle"] / grand_total * 100, 1),
    }


def _load_average() -> list[float]:
    try:
        return [round(value, 2) for value in os.getloadavg()]
    except OSError:
        return []


def _top_cpu_processes(n: int = 5) -> list[dict]:
    """Return the top-N CPU-consuming processes as [{pid, cpu_percent, name}, ...].

    Uses BSD ps (macOS) with whitespace-stripped columns, sorts numerically on
    pcpu desc. Skips the health-api server itself to avoid self-referential
    noise in the SketchyBar vitals popup. Truncates long process names to 40
    chars for compact rendering.
    """
    # Ask for n+1 rows to have headroom when filtering out our own process.
    out = run(f"ps -Ao pid=,pcpu=,comm= | sort -k2 -nr | head -{n + 2}")
    results: list[dict] = []
    for line in out.splitlines():
        parts = line.split(None, 2)
        if len(parts) < 3:
            continue
        pid_s, pct_s, name = parts
        # Filter the health-api python process; it appears under its script path.
        if name.endswith("health-api.py"):
            continue
        try:
            results.append({
                "pid": int(pid_s),
                "cpu_percent": float(pct_s),
                "name": name[:40],
            })
        except ValueError:
            continue
        if len(results) >= n:
            break
    return results


def _thermal_state_from_temps(cpu_temp: float, gpu_temp: float) -> str:
    """Synthesize a thermal state string from CPU/GPU temperatures.

    macmon does not emit a thermal-state label (unlike mactop), but
    health-check.sh reads d['thermal']['state'] directly, so we compute a
    label from the hotter of the two silicon sensors.  Thresholds picked
    to match typical Apple Silicon thermal envelopes (sustained heavy load
    on an M3 Max sits in the 80-90 C range on p-cluster).
    """
    hottest = max(cpu_temp or 0.0, gpu_temp or 0.0)
    if hottest <= 0:
        return "Unknown"
    if hottest < 70:
        return "Normal"
    if hottest < 85:
        return "Warning"
    return "Critical"


def _probe_system_metrics() -> dict | None:
    """Run one macmon sample and assemble the response dict.

    Returns the populated dict on success, or None if macmon failed.
    The refresher thread handles caching — this function just does the work.
    Called only from the background daemon; nothing on the request path
    blocks on this.
    """
    # Prefer the Nix-managed absolute path (stable across rebuilds); fall back
    # to PATH discovery so this also works in dev shells / on other machines.
    macmon_bin = "/run/current-system/sw/bin/macmon"
    if not os.path.isfile(macmon_bin):
        macmon_bin = shutil.which("macmon") or ""
    if not macmon_bin:
        print("health-api: macmon not installed; refresher idle")
        return None

    try:
        result = subprocess.run(
            [macmon_bin, "pipe", "--samples", "1", "--interval", "500"],
            capture_output=True, text=True, timeout=MACMON_TIMEOUT_SEC,
        )
        if result.returncode != 0 or not result.stdout.strip():
            print(f"health-api: macmon failed rc={result.returncode}: {result.stderr.strip()[:200]}")
            return None
    except subprocess.TimeoutExpired:
        print(f"health-api: macmon timed out ({MACMON_TIMEOUT_SEC}s)")
        return None
    except Exception as e:
        print(f"health-api: macmon exception: {str(e)[:200]}")
        return None

    try:
        # macmon emits one JSON object per sample; with --samples 1 it's a
        # single object on stdout.  Be defensive in case it ever becomes
        # NDJSON (take the first non-empty line).
        stdout = result.stdout.strip()
        first_line = stdout.splitlines()[0] if stdout else ""
        sample = json.loads(first_line)
    except (json.JSONDecodeError, IndexError) as e:
        print(f"health-api: macmon JSON parse error: {e}")
        return None

    # macmon field shape (v0.6.x):
    #   ecpu_usage / pcpu_usage / gpu_usage: [freq_mhz:int, active_fraction:float]
    #   memory: { ram_total, ram_usage, swap_total, swap_usage }  (bytes)
    #   temp: { cpu_temp_avg, gpu_temp_avg }  (degrees C)
    #   *_power: watts (all_power, cpu_power, gpu_power, ane_power, ram_power,
    #            sys_power, gpu_ram_power)
    ecpu = sample.get("ecpu_usage", [0, 0.0])
    pcpu = sample.get("pcpu_usage", [0, 0.0])
    gpu = sample.get("gpu_usage", [0, 0.0])
    mem = sample.get("memory", {})
    temp = sample.get("temp", {})

    ecpu_freq = ecpu[0] if len(ecpu) > 0 else 0
    ecpu_active = ecpu[1] if len(ecpu) > 1 else 0.0
    pcpu_freq = pcpu[0] if len(pcpu) > 0 else 0
    pcpu_active = pcpu[1] if len(pcpu) > 1 else 0.0
    gpu_freq = gpu[0] if len(gpu) > 0 else 0
    gpu_active = gpu[1] if len(gpu) > 1 else 0.0

    ram_total = mem.get("ram_total", 0)
    ram_usage = mem.get("ram_usage", 0)
    cpu_temp_c = round(temp.get("cpu_temp_avg", 0) or 0, 1)
    gpu_temp_c = round(temp.get("gpu_temp_avg", 0) or 0, 1)

    response = {
        "timestamp": sample.get("timestamp", datetime.now(timezone.utc).astimezone().isoformat()),
        "system": get_hardware_info(),
        "cpu": {
            "usage_percent": round((ecpu_active + pcpu_active) / 2 * 100, 1),
            "e_cluster": {
                "active_percent": round(ecpu_active * 100, 1),
                "freq_mhz": ecpu_freq,
            },
            "p_cluster": {
                "active_percent": round(pcpu_active * 100, 1),
                "freq_mhz": pcpu_freq,
            },
        },
        "gpu": {
            "usage_percent": round(gpu_active * 100, 1),
            "freq_mhz": gpu_freq,
            "power_watts": round(sample.get("gpu_power", 0), 1),
        },
        "memory": {
            "total_gb": round(ram_total / (1024 ** 3), 1),
            "used_gb": round(ram_usage / (1024 ** 3), 1),
            "available_gb": round(max(ram_total - ram_usage, 0) / (1024 ** 3), 1),
            "swap_total_gb": round(mem.get("swap_total", 0) / (1024 ** 3), 1),
            "swap_used_gb": round(mem.get("swap_usage", 0) / (1024 ** 3), 1),
        },
        "power": {
            "cpu_watts": round(sample.get("cpu_power", 0), 1),
            "gpu_watts": round(sample.get("gpu_power", 0), 1),
            "ane_watts": round(sample.get("ane_power", 0), 1),
            "dram_watts": round(sample.get("ram_power", 0), 1),
            "system_watts": round(sample.get("sys_power", 0), 1),
            "total_watts": round(sample.get("all_power", 0), 1),
        },
        "thermal": {
            "cpu_temp_c": cpu_temp_c,
            "gpu_temp_c": gpu_temp_c,
            # Synthesized from temps — macmon does not emit a state label,
            # but health-check.sh reads thermal.state, so we must provide one.
            "state": _thermal_state_from_temps(cpu_temp_c, gpu_temp_c),
        },
    }

    # Status flags: derived signals for dashboards / health-check.sh to key on.
    # Additive field; absent for backwards compatibility when all checks are OK.
    swap_used = response["memory"]["swap_used_gb"]
    status_flags: dict[str, str] = {}
    if swap_used > SWAP_WARNING_GB:
        status_flags["memory_swap"] = "warn"
    if status_flags:
        response["status_flags"] = status_flags

    # Top CPU processes — consumed by SketchyBar vitals popup (Story 08.3-005)
    # to avoid forking `ps` inside the click handler.
    response["processes"] = {"top_cpu": _top_cpu_processes(5)}

    return response


def _parse_vm_stat() -> dict | None:
    lines = _run_lines(["/usr/bin/vm_stat"], timeout=3)
    if not lines:
        return None

    page_size = 4096
    counters: dict[str, int] = {}
    page_match = re.search(r"page size of (\d+) bytes", lines[0])
    if page_match:
        page_size = int(page_match.group(1))

    for line in lines[1:]:
        match = re.match(r"(.+?):\s+(\d+)\.", line.strip())
        if match:
            counters[match.group(1)] = int(match.group(2))

    mem_total_raw = run("sysctl -n hw.memsize")
    try:
        mem_total = int(mem_total_raw)
    except ValueError:
        return None

    free_pages = counters.get("Pages free", 0) + counters.get("Pages speculative", 0)
    free_bytes = free_pages * page_size
    used_bytes = max(mem_total - free_bytes, 0)
    wired_bytes = counters.get("Pages wired down", 0) * page_size
    compressed_bytes = counters.get("Pages occupied by compressor", 0) * page_size
    active_bytes = counters.get("Pages active", 0) * page_size
    inactive_bytes = counters.get("Pages inactive", 0) * page_size

    memory = {
        "total_gb": round(mem_total / (1024 ** 3), 1),
        "used_gb": round(used_bytes / (1024 ** 3), 1),
        "available_gb": round(free_bytes / (1024 ** 3), 1),
        "wired_gb": round(wired_bytes / (1024 ** 3), 1),
        "compressed_gb": round(compressed_bytes / (1024 ** 3), 1),
        "active_gb": round(active_bytes / (1024 ** 3), 1),
        "inactive_gb": round(inactive_bytes / (1024 ** 3), 1),
    }
    available_ratio = free_bytes / mem_total if mem_total else 0
    if available_ratio < 0.05:
        memory["pressure_label"] = "critical"
    elif available_ratio < 0.10:
        memory["pressure_label"] = "warn"
    else:
        memory["pressure_label"] = "normal"
    return memory


def _parse_swap_usage() -> dict[str, float]:
    out = run("sysctl vm.swapusage")
    total_match = re.search(r"total = ([0-9.]+)([MGT])", out)
    used_match = re.search(r"used = ([0-9.]+)([MGT])", out)

    def to_gb(value: str, unit: str) -> float:
        multipliers = {"M": 1 / 1024, "G": 1.0, "T": 1024.0}
        return round(float(value) * multipliers[unit], 1)

    swap_total = to_gb(*total_match.groups()) if total_match else 0.0
    swap_used = to_gb(*used_match.groups()) if used_match else 0.0
    return {"swap_total_gb": swap_total, "swap_used_gb": swap_used}


def _fast_cpu_usage_percent() -> float:
    lines = _run_lines(["/usr/bin/top", "-l", "1"], timeout=3)
    for line in lines:
        if "CPU usage:" not in line:
            continue
        numbers = [float(value) for value in re.findall(r"([0-9]+(?:\.[0-9]+)?)%", line)]
        if len(numbers) >= 3:
            return round(numbers[0] + numbers[1], 1)
    return 0.0


def _probe_fast_metrics() -> dict:
    global _last_core_cpu_sample  # noqa: PLW0603
    memory = _parse_vm_stat() or {}
    memory.update(_parse_swap_usage())
    core_sample = _sample_core_cpu_times()
    cpu = {"usage_percent": 0.0}
    if core_sample:
        previous_sample = _last_core_cpu_sample
        cpu.update(_core_usage_from_samples(_last_core_cpu_sample, core_sample))
        _last_core_cpu_sample = core_sample
        if previous_sample:
            cpu["usage_percent"] = round(100.0 - cpu.get("idle_percent", 100.0), 1)
        else:
            cpu["usage_percent"] = _fast_cpu_usage_percent()
    else:
        cpu["usage_percent"] = _fast_cpu_usage_percent()

    return {
        "cpu": cpu,
        "system": {
            "load_average": _load_average(),
            "uptime_seconds": int(time.monotonic()),
        },
        "memory": memory,
        "processes": {"top_cpu": _top_cpu_processes(5)},
    }


def _fast_metrics_refresher() -> None:
    global _fast_metrics_cache, _fast_metrics_cache_time  # noqa: PLW0603
    while True:
        start = time.monotonic()
        fresh = _probe_fast_metrics()
        with _fast_metrics_lock:
            _fast_metrics_cache = fresh
            _fast_metrics_cache_time = time.monotonic()
        elapsed = time.monotonic() - start
        time.sleep(max(FAST_METRICS_REFRESH_INTERVAL - elapsed, 0.5))


def _merge_metric_caches(slow: dict, fast: dict) -> dict:
    merged = dict(slow)
    if "status" in merged:
        return merged

    if fast:
        merged_cpu = dict(merged.get("cpu", {}))
        merged_cpu.update(fast.get("cpu", {}))
        merged["cpu"] = merged_cpu

        merged_memory = dict(merged.get("memory", {}))
        merged_memory.update(fast.get("memory", {}))
        merged["memory"] = merged_memory

        merged_system = dict(merged.get("system", {}))
        merged_system.update(fast.get("system", {}))
        merged["system"] = merged_system

        merged_processes = dict(merged.get("processes", {}))
        merged_processes.update(fast.get("processes", {}))
        merged["processes"] = merged_processes

    swap_used = merged.get("memory", {}).get("swap_used_gb", 0)
    status_flags = dict(merged.get("status_flags", {}))
    if swap_used > SWAP_WARNING_GB:
        status_flags["memory_swap"] = "warn"
    else:
        status_flags.pop("memory_swap", None)
    if status_flags:
        merged["status_flags"] = status_flags
    else:
        merged.pop("status_flags", None)

    return merged


def _metrics_refresher() -> None:
    """Daemon-thread loop that refreshes the metrics cache every
    METRICS_REFRESH_INTERVAL seconds.  Guarantees at most one macmon
    subprocess runs at a time.
    """
    global _metrics_cache, _metrics_cache_time  # noqa: PLW0603
    while True:
        start = time.monotonic()
        fresh = _probe_system_metrics()
        if fresh is not None:
            with _metrics_lock:
                _metrics_cache = fresh
                _metrics_cache_time = time.monotonic()
        # Sleep the remainder of the refresh interval (never negative).
        # If macmon took longer than the interval, sleep briefly and loop
        # again rather than busy-looping.
        elapsed = time.monotonic() - start
        sleep_for = max(METRICS_REFRESH_INTERVAL - elapsed, 0.5)
        time.sleep(sleep_for)


def get_system_metrics() -> dict:
    """Non-blocking read of the latest cached macmon sample.

    Always returns in <1ms under a threading.Lock.  If the refresher has
    not yet produced a first sample (service just started), returns a
    {"status": "pending", ...} dict; clients distinguish this from an
    error by checking `status`.
    """
    with _metrics_lock:
        slow = dict(_metrics_cache)
    with _fast_metrics_lock:
        fast = dict(_fast_metrics_cache)
    return _merge_metric_caches(slow, fast)


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
        try:
            self.send_response(code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
        except (BrokenPipeError, ConnectionResetError):
            # The client (typically SketchyBar's system.sh with --max-time)
            # disconnected before we finished writing. Noise, not an error —
            # the cached response is already populated for the next request.
            pass

    def log_message(self, format, *args):
        # Suppress default stderr logging; write to stdout instead
        print(f"{self.address_string()} - {format % args}")


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle each request in a new thread to prevent slow checks from blocking."""
    daemon_threads = True


def main():
    # Static hardware metadata is cheap enough at startup, but too slow/noisy
    # to run on the request path or every macmon sample.
    get_hardware_info()

    # Start the nix-store refresher daemon before serving so /health never blocks
    # on `du -sh /nix/store`. It runs an initial refresh immediately and then
    # sleeps for NIX_STORE_CACHE_TTL seconds between refreshes.
    refresher = threading.Thread(
        target=_nix_store_refresher, name="nix-store-refresher", daemon=True
    )
    refresher.start()

    # Start the macmon metrics refresher on a separate daemon thread.  This
    # guarantees /metrics returns in O(1) and bounds concurrent macmon
    # subprocesses to one — the root cause of earlier 4s request latency.
    metrics_refresher = threading.Thread(
        target=_metrics_refresher, name="metrics-refresher", daemon=True
    )
    metrics_refresher.start()
    fast_metrics_refresher = threading.Thread(
        target=_fast_metrics_refresher, name="fast-metrics-refresher", daemon=True
    )
    fast_metrics_refresher.start()

    server = ThreadedHTTPServer(("0.0.0.0", PORT), HealthHandler)
    print(f"Health API listening on 0.0.0.0:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Shutting down health API server")
        server.server_close()


if __name__ == "__main__":
    main()
