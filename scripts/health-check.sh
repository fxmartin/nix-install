#!/usr/bin/env bash
# ABOUTME: System health check script for nix-darwin configuration (Feature 06.4)
# ABOUTME: Validates Nix daemon, Homebrew, disk space, security settings, and generations

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================
# NOTE: These thresholds are shared with scripts/health-api.py (HTTP API).
# If you change a value here, update health-api.py to match.

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Version
HEALTH_CHECK_VERSION="1.2.0"

# Shared thresholds (keep in sync with health-api.py)
GENERATION_WARNING_THRESHOLD=50  # Warn if more than N system generations
DISK_WARNING_GB=20               # Warn if less than N GB free
CACHE_WARNING_KB=1048576         # 1 GB — warn if any single cache exceeds this
HF_CACHE_WARNING_KB=10485760     # 10 GB — Huggingface cache grows fastest (model blobs)
SWAP_WARNING_GB=2                # Warn when swap usage exceeds this (signals real memory pressure)

# Expected Ollama models per profile (keep in sync with flake.nix ollamaModels)
# Power: gemma4:e4b, gemma4:26b, nomic-embed-text
# Standard: ministral-3:14b, nomic-embed-text
# AI-Assistant: nomic-embed-text

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

print_status() {
    local status="$1"
    local message="$2"
    case "${status}" in
        ok)     echo -e "${GREEN}✅${NC} ${message}" ;;
        warn)   echo -e "${YELLOW}⚠️${NC}  ${message}" ;;
        error)  echo -e "${RED}❌${NC} ${message}" ;;
        info)   echo -e "${BLUE}💾${NC} ${message}" ;;
        check)  echo -e "${BLUE}🔄${NC} ${message}" ;;
    esac
}

# =============================================================================
# HEALTH CHECKS
# =============================================================================

# Detect installation profile from user-config.nix (used in header and Ollama check)
PROFILE=""
for config_path in "$HOME/.config/nix-install/user-config.nix" "$HOME/nix-install/user-config.nix" "$HOME/Documents/nix-install/user-config.nix"; do
    if [[ -f "${config_path}" ]]; then
        PROFILE=$(grep -E '^\s*installProfile\s*=' "${config_path}" 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' || true)
        break
    fi
done

echo ""
echo "=== System Health Check ==="
echo "Host:    $(hostname)"
echo "Profile: ${PROFILE:-unknown}"
echo "Date:    $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ---------------------------------------------------------------------------
# Check 1: Nix daemon status
# ---------------------------------------------------------------------------
echo "Checking Nix daemon..."
if pgrep -x nix-daemon > /dev/null 2>&1; then
    print_status "ok" "Nix daemon running"
else
    print_status "error" "Nix daemon not running"
    echo "    → Try: sudo launchctl kickstart -k system/org.nixos.nix-daemon"
fi

# ---------------------------------------------------------------------------
# Check 2: Homebrew health
# ---------------------------------------------------------------------------
echo "Checking Homebrew..."
if command -v brew &> /dev/null; then
    # Check if Homebrew is managed by nix-darwin (expected state)
    if [[ -d "/opt/homebrew/Library/.homebrew-is-managed-by-nix" ]]; then
        print_status "ok" "Homebrew managed by nix-darwin"
    elif brew doctor &>/dev/null; then
        print_status "ok" "Homebrew healthy"
    else
        print_status "warn" "Homebrew issues detected"
        echo "    → Run: brew doctor"
    fi
else
    print_status "error" "Homebrew not found"
    echo "    → Homebrew should be installed by nix-darwin"
fi

# ---------------------------------------------------------------------------
# Check 3: Disk space (using Finder-equivalent metric)
# ---------------------------------------------------------------------------
echo "Checking disk space..."
# Use NSURL volumeAvailableCapacityForImportantUsage (same as Finder)
# This includes purgeable space that macOS reclaims automatically
# Falls back to df if swift fails
DISK_SWIFT=$(swift -e '
import Foundation
let url = URL(fileURLWithPath: "/")
let v = try url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey])
if let t = v.volumeTotalCapacity, let a = v.volumeAvailableCapacityForImportantUsage {
    print("\(t / 1073741824) \(a / 1073741824)")
}
' 2>/dev/null || true)

if [[ -n "${DISK_SWIFT}" ]]; then
    DISK_TOTAL_GB=$(echo "${DISK_SWIFT}" | awk '{print $1}')
    DISK_FREE_GB=$(echo "${DISK_SWIFT}" | awk '{print $2}')

    if [[ ${DISK_FREE_GB} -lt ${DISK_WARNING_GB} ]]; then
        print_status "warn" "Disk available: ${DISK_FREE_GB}GB / ${DISK_TOTAL_GB}GB (low space!)"
        echo "    → Run: gc  # to remove old generations"
    else
        print_status "info" "Disk available: ${DISK_FREE_GB}GB / ${DISK_TOTAL_GB}GB (includes purgeable)"
    fi
elif [[ -d /nix ]]; then
    # Fallback to df (reports raw free, not purgeable-inclusive)
    DISK_FREE_KB=$(df -k / | tail -1 | awk '{print $4}')
    DISK_FREE_GB=$((DISK_FREE_KB / 1024 / 1024))
    DISK_FREE_HUMAN=$(df -h / | tail -1 | awk '{print $4}')

    if [[ ${DISK_FREE_GB} -lt ${DISK_WARNING_GB} ]]; then
        print_status "warn" "Disk free: ${DISK_FREE_HUMAN} (low space!)"
        echo "    → Run: gc  # to remove old generations"
    else
        print_status "info" "Disk free: ${DISK_FREE_HUMAN}"
    fi
else
    print_status "error" "/nix directory not found"
fi

# Home directory space (also using Finder metric if available)
HOME_FREE=$(df -h ~ | tail -1 | awk '{print $4}')
print_status "info" "Disk free on ~: ${HOME_FREE}"

# ---------------------------------------------------------------------------
# Check 4: FileVault status
# ---------------------------------------------------------------------------
echo "Checking security settings..."
if command -v fdesetup &> /dev/null; then
    if fdesetup status 2>/dev/null | grep -q "FileVault is On"; then
        print_status "ok" "FileVault enabled"
    else
        print_status "warn" "FileVault disabled (encryption recommended)"
        echo "    → Enable: System Settings → Privacy & Security → FileVault"
    fi
else
    print_status "warn" "fdesetup not available (cannot check FileVault)"
fi

# ---------------------------------------------------------------------------
# Check 5: Firewall status
# ---------------------------------------------------------------------------
FIREWALL_CMD="/usr/libexec/ApplicationFirewall/socketfilterfw"
if [[ -x "${FIREWALL_CMD}" ]]; then
    if ${FIREWALL_CMD} --getglobalstate 2>/dev/null | grep -q "enabled"; then
        print_status "ok" "Firewall enabled"
    else
        print_status "warn" "Firewall disabled"
        echo "    → Enable: System Settings → Network → Firewall"
    fi
else
    print_status "warn" "Firewall control not available"
fi

# ---------------------------------------------------------------------------
# Check 6: System generations
# ---------------------------------------------------------------------------
echo "Checking system generations..."
# Use fast method: count profile symlinks directly instead of slow darwin-rebuild --list-generations
if [[ -d /nix/var/nix/profiles ]]; then
    GENERATIONS=$(ls -1 /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l | tr -d ' ')

    if [[ ${GENERATIONS} -gt ${GENERATION_WARNING_THRESHOLD} ]]; then
        print_status "warn" "System generations: ${GENERATIONS} (many generations!)"
        echo "    → Run: gc  # to clean up old generations"
    else
        print_status "ok" "System generations: ${GENERATIONS}"
    fi
else
    print_status "warn" "Nix profiles directory not found"
fi

# ---------------------------------------------------------------------------
# Check 7: Nix store size
# ---------------------------------------------------------------------------
echo "Checking Nix store..."
if [[ -d /nix/store ]]; then
    STORE_SIZE=$(du -sh /nix/store 2>/dev/null | cut -f1 || true)
    if [[ -n "${STORE_SIZE}" ]]; then
        print_status "info" "Nix store size: ${STORE_SIZE}"
    else
        print_status "info" "Nix store size: (timed out after 30s)"
    fi
fi

# ---------------------------------------------------------------------------
# Check 8: Development cache sizes
# ---------------------------------------------------------------------------
echo "Checking development caches..."

# Helper to get cache size in KB for comparison
get_cache_kb() {
    local path="${1}"
    if [[ -d "${path}" ]]; then
        du -sk "${path}" 2>/dev/null | cut -f1 || echo "0"
    else
        echo "0"
    fi
    return 0
}

# Cache size threshold (uses shared CACHE_WARNING_KB from config section above)

# Check each cache
UV_CACHE_KB=$(get_cache_kb ~/.cache/uv)
UV_CACHE_SIZE=$(du -sh ~/.cache/uv 2>/dev/null | cut -f1 || echo "0B")
if [[ ${UV_CACHE_KB} -gt ${CACHE_WARNING_KB} ]]; then
    print_status "warn" "uv cache: ${UV_CACHE_SIZE} (large!)"
else
    print_status "info" "uv cache: ${UV_CACHE_SIZE}"
fi

BREW_CACHE_KB=$(get_cache_kb ~/Library/Caches/Homebrew)
BREW_CACHE_SIZE=$(du -sh ~/Library/Caches/Homebrew 2>/dev/null | cut -f1 || echo "0B")
if [[ ${BREW_CACHE_KB} -gt ${CACHE_WARNING_KB} ]]; then
    print_status "warn" "Homebrew cache: ${BREW_CACHE_SIZE} (large!)"
else
    print_status "info" "Homebrew cache: ${BREW_CACHE_SIZE}"
fi

NPM_CACHE_KB=$(get_cache_kb ~/.npm)
NPM_CACHE_SIZE=$(du -sh ~/.npm 2>/dev/null | cut -f1 || echo "0B")
if [[ ${NPM_CACHE_KB} -gt ${CACHE_WARNING_KB} ]]; then
    print_status "warn" "npm cache: ${NPM_CACHE_SIZE} (large!)"
else
    print_status "info" "npm cache: ${NPM_CACHE_SIZE}"
fi

HF_CACHE_KB=$(get_cache_kb ~/.cache/huggingface)
HF_CACHE_SIZE=$(du -sh ~/.cache/huggingface 2>/dev/null | cut -f1 || echo "0B")
if [[ ${HF_CACHE_KB} -gt ${HF_CACHE_WARNING_KB} ]]; then
    print_status "warn" "Huggingface cache: ${HF_CACHE_SIZE} (large! → disk-cleanup)"
else
    print_status "info" "Huggingface cache: ${HF_CACHE_SIZE}"
fi

# Total cache estimate (includes HF since it often dominates)
TOTAL_CACHE_KB=$((UV_CACHE_KB + BREW_CACHE_KB + NPM_CACHE_KB + HF_CACHE_KB))
TOTAL_CACHE_GB=$((TOTAL_CACHE_KB / 1024 / 1024))
if [[ ${TOTAL_CACHE_GB} -gt 5 ]]; then
    print_status "warn" "Total dev caches: ~${TOTAL_CACHE_GB}GB → Run: disk-cleanup"
fi

# ---------------------------------------------------------------------------
# Check 9: Claude Code MCP servers
# ---------------------------------------------------------------------------
echo "Checking Claude Code MCP servers..."

# Check if claude CLI is available
if command -v claude &> /dev/null; then
    # Run mcp list and capture output
    MCP_OUTPUT=$(claude mcp list 2>/dev/null || true)

    if [[ -n "${MCP_OUTPUT}" ]]; then
        # Count connected and failed servers
        MCP_CONNECTED=$(echo "${MCP_OUTPUT}" | /usr/bin/grep -c "✓ Connected" || true)
        MCP_FAILED=$(echo "${MCP_OUTPUT}" | /usr/bin/grep -c "✗ Failed" || true)

        if [[ ${MCP_FAILED} -gt 0 ]]; then
            print_status "warn" "MCP servers: ${MCP_CONNECTED} connected, ${MCP_FAILED} failed"
            echo "    → Run: ~/Documents/nix-install/scripts/update-mcp-paths.sh"
        elif [[ ${MCP_CONNECTED} -gt 0 ]]; then
            print_status "ok" "MCP servers: ${MCP_CONNECTED} connected"
        else
            print_status "warn" "No MCP servers configured"
        fi
    else
        print_status "warn" "Could not check MCP servers"
    fi
else
    print_status "info" "Claude Code CLI not installed (MCP check skipped)"
fi

# ---------------------------------------------------------------------------
# Check 10: LaunchAgents status
# ---------------------------------------------------------------------------
echo "Checking LaunchAgents..."
# Capture launchctl output once (avoids pipefail issues with repeated calls)
LAUNCHCTL_OUTPUT=$(launchctl list 2>/dev/null || true)

# Common LaunchAgents (all profiles)
COMMON_AGENTS=("nix-gc" "nix-optimize" "weekly-digest" "disk-cleanup" "ollama-serve" "health-api" "release-monitor" "beszel-agent")

for agent in "${COMMON_AGENTS[@]}"; do
    if echo "${LAUNCHCTL_OUTPUT}" | /usr/bin/grep -q "org.nixos.${agent}"; then
        print_status "ok" "${agent} LaunchAgent loaded"
    else
        print_status "warn" "${agent} LaunchAgent not loaded"
        echo "    → Run: darwin-rebuild switch"
    fi
done

# Power-profile LaunchAgents (detected by presence of icloud-sync agent)
if echo "${LAUNCHCTL_OUTPUT}" | /usr/bin/grep -q "org.nixos.icloud-sync"; then
    POWER_AGENTS=("rsync-backup-daily" "rsync-backup-weekly-sunday" "rsync-backup-weekly-wednesday" "icloud-sync")
    for agent in "${POWER_AGENTS[@]}"; do
        if echo "${LAUNCHCTL_OUTPUT}" | /usr/bin/grep -q "org.nixos.${agent}"; then
            print_status "ok" "${agent} LaunchAgent loaded"
        else
            print_status "warn" "${agent} LaunchAgent not loaded"
            echo "    → Run: darwin-rebuild switch"
        fi
    done
fi

# ---------------------------------------------------------------------------
# Check 11: Window management & status bar
# ---------------------------------------------------------------------------
echo "Checking window management..."

# SketchyBar (managed by Homebrew service)
if pgrep -x sketchybar > /dev/null 2>&1; then
    SKETCHYBAR_ITEMS=$(sketchybar --query bar 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(len(d.get('items', [])))
except:
    print('?')
" 2>/dev/null || echo "?")
    print_status "ok" "SketchyBar running (${SKETCHYBAR_ITEMS} items)"
else
    print_status "warn" "SketchyBar not running"
    echo "    → Run: brew services start sketchybar"
fi

# AeroSpace window manager
if command -v aerospace &> /dev/null; then
    if pgrep -x AeroSpace > /dev/null 2>&1; then
        WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null || echo "?")
        print_status "ok" "AeroSpace running (workspace: ${WORKSPACE})"
    else
        print_status "warn" "AeroSpace not running"
        echo "    → Launch AeroSpace from Applications or login items"
    fi
fi

# skhd hotkey daemon
if command -v skhd &> /dev/null; then
    if pgrep -x skhd > /dev/null 2>&1; then
        print_status "ok" "skhd hotkey daemon running"
    else
        print_status "warn" "skhd not running (hotkeys disabled)"
        echo "    → Run: brew services start skhd"
    fi
fi

# ---------------------------------------------------------------------------
# Check 12: Docker container runtime
# ---------------------------------------------------------------------------
echo "Checking Docker..."
if command -v docker &> /dev/null; then
    # Check Docker Desktop status
    if docker info > /dev/null 2>&1; then
        print_status "ok" "Docker Desktop running"

        # Container health summary
        RUNNING=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
        UNHEALTHY=$(docker ps --filter "health=unhealthy" -q 2>/dev/null | wc -l | tr -d ' ')
        HEALTHY=$(docker ps --filter "health=healthy" -q 2>/dev/null | wc -l | tr -d ' ')

        if [[ ${UNHEALTHY} -gt 0 ]]; then
            print_status "warn" "Docker containers: ${RUNNING} running (${HEALTHY} healthy, ${UNHEALTHY} unhealthy)"
            # List unhealthy containers
            docker ps --filter "health=unhealthy" --format '{{.Names}}' 2>/dev/null | while read -r name; do
                echo "    → Unhealthy: ${name}"
            done
        elif [[ ${RUNNING} -gt 0 ]]; then
            print_status "ok" "Docker containers: ${RUNNING} running (${HEALTHY} healthy)"
        else
            print_status "info" "Docker containers: none running"
        fi

        # Image count
        IMAGE_COUNT=$(docker images --format '{{.ID}}' 2>/dev/null | wc -l | tr -d ' ')
        print_status "info" "Docker images: ${IMAGE_COUNT}"

        # Disk usage (reclaimable space)
        DOCKER_DF=$(docker system df 2>/dev/null || true)
        if [[ -n "${DOCKER_DF}" ]]; then
            RECLAIMABLE=$(echo "${DOCKER_DF}" | /usr/bin/grep -i "Local Volumes\|Images" | awk '{for(i=1;i<=NF;i++) if($i ~ /\(/) print $i $(i+1)}' | head -1)
            if [[ -n "${RECLAIMABLE}" ]]; then
                print_status "info" "Docker reclaimable: ${RECLAIMABLE}"
            fi
        fi
    else
        print_status "info" "Docker Desktop not running (start Docker Desktop app)"
    fi
else
    print_status "info" "Docker not installed (container check skipped)"
fi

# ---------------------------------------------------------------------------
# Check 13: Ollama models
# ---------------------------------------------------------------------------
if command -v ollama &> /dev/null; then
    echo "Checking Ollama models..."

    # Check if Ollama daemon is running
    if ! pgrep -q ollama; then
        print_status "warn" "Ollama daemon not running"
        echo "    → Run: ollama serve"
    else
        print_status "ok" "Ollama daemon running"

        # Get installed models
        OLLAMA_LIST=$(ollama list 2>/dev/null || true)

        # Determine expected models based on profile (detected at top of script).
        # Fallback: detect via LaunchAgent presence
        if [[ -z "${PROFILE}" ]]; then
            if echo "${LAUNCHCTL_OUTPUT}" | /usr/bin/grep -q "org.nixos.icloud-sync"; then
                PROFILE="power"
            else
                PROFILE="standard"
            fi
        fi

        case "${PROFILE}" in
            power)
                EXPECTED_MODELS=("gemma4:e4b" "gemma4:26b" "nomic-embed-text")
                ;;
            ai-assistant)
                EXPECTED_MODELS=("nomic-embed-text")
                ;;
            *)
                EXPECTED_MODELS=("ministral-3:14b" "nomic-embed-text")
                PROFILE="standard"
                ;;
        esac

        MISSING=0
        for model in "${EXPECTED_MODELS[@]}"; do
            # Match on model name prefix (ollama list shows full tags like "phi4:14b")
            MODEL_BASE="${model%%:*}"
            if echo "${OLLAMA_LIST}" | /usr/bin/grep -q "${MODEL_BASE}"; then
                print_status "ok" "Ollama model: ${model}"
            else
                print_status "error" "Ollama model missing: ${model}"
                echo "    → Run: ollama pull ${model}"
                MISSING=$((MISSING + 1))
            fi
        done

        if [[ ${MISSING} -eq 0 ]]; then
            print_status "ok" "All ${#EXPECTED_MODELS[@]} expected models installed (${PROFILE} profile)"
        else
            print_status "warn" "${MISSING} model(s) missing for ${PROFILE} profile"
        fi

        # Show total disk usage
        OLLAMA_DIR="${HOME}/.ollama/models"
        if [[ -d "${OLLAMA_DIR}" ]]; then
            OLLAMA_SIZE=$(du -sh "${OLLAMA_DIR}" 2>/dev/null | cut -f1 || true)
            if [[ -n "${OLLAMA_SIZE}" ]]; then
                print_status "info" "Ollama models disk usage: ${OLLAMA_SIZE}"
            else
                print_status "info" "Ollama models disk usage: (timed out after 30s)"
            fi
        fi
    fi
else
    print_status "info" "Ollama not installed (model check skipped)"
fi

# ---------------------------------------------------------------------------
# Check 14: System metrics (Apple Silicon vitals via health-api /metrics)
# ---------------------------------------------------------------------------
echo "Checking system metrics..."
# --max-time must exceed health-api.py macmon subprocess timeout (4s) plus request
# overhead; 8s leaves comfortable headroom so curl never aborts before Python
# can write the response (issue #224, #226).
METRICS_JSON=$(curl -s --connect-timeout 3 --max-time 8 http://localhost:7780/metrics 2>/dev/null || true)
if [[ -n "${METRICS_JSON}" ]]; then
    METRICS_SUMMARY=$(echo "${METRICS_JSON}" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    if 'status' in d and d['status'] == 'error':
        print(f'error:{d.get(\"detail\", \"unknown\")}')
    else:
        cpu = d['cpu']['usage_percent']
        gpu = d['gpu']['usage_percent']
        mem_used = d['memory']['used_gb']
        mem_total = d['memory']['total_gb']
        thermal = d['thermal']['state']
        total_w = d['power']['total_watts']
        swap_used = d['memory'].get('swap_used_gb', 0)
        swap_flag = d.get('status_flags', {}).get('memory_swap', '')
        print(f'ok:CPU {cpu}% | GPU {gpu}% | Mem {mem_used:.0f}/{mem_total:.0f}GB | {total_w:.0f}W | Thermal: {thermal}|swap={swap_used}|swap_flag={swap_flag}')
except:
    print('parse_error')
" 2>/dev/null || echo "parse_error")

    case "${METRICS_SUMMARY}" in
        ok:*)
            # Parse trailing swap info (pipe-separated) out of the vitals line
            VITALS_FULL="${METRICS_SUMMARY#ok:}"
            VITALS="${VITALS_FULL%%|swap=*}"
            SWAP_USED="${VITALS_FULL#*|swap=}"; SWAP_USED="${SWAP_USED%%|*}"
            SWAP_FLAG="${VITALS_FULL##*|swap_flag=}"
            print_status "ok" "System vitals: ${VITALS}"
            if [[ "${SWAP_FLAG}" == "warn" ]]; then
                print_status "warn" "Memory pressure: swap in use ${SWAP_USED}GB (>${SWAP_WARNING_GB}GB) → consider ollama-evict or closing apps"
            fi
            ;;
        error:*)
            DETAIL="${METRICS_SUMMARY#error:}"
            print_status "warn" "System metrics unavailable: ${DETAIL}"
            ;;
        *)
            print_status "warn" "System metrics: could not parse response"
            ;;
    esac
else
    # Empty response from /metrics could mean two different things:
    #   1. The server is up but the request timed out (e.g. mactop slow)
    #   2. The port isn't listening at all (LaunchAgent down)
    # A quick /ping probe with a tight timeout distinguishes the two so the
    # operator gets actionable advice instead of a misleading generic error.
    if curl -s --connect-timeout 1 --max-time 2 http://localhost:7780/ping > /dev/null 2>&1; then
        print_status "warn" "System metrics: request timed out (server alive — see /tmp/health-api.err)"
    else
        print_status "info" "System metrics: health-api not responding on port 7780"
        echo "    → Run: launchctl start org.nixos.health-api"
    fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Health Check Complete ==="
echo ""
echo "Quick commands:"
echo "  gc           - Remove old user generations"
echo "  gc-system    - Remove old system generations (sudo)"
echo "  cleanup      - GC + store optimization"
echo "  disk-cleanup - Clean dev caches (uv, npm, Homebrew, Docker)"
echo "  rebuild      - Rebuild system configuration"
echo "  update       - Update flake.lock + rebuild"
echo "  brew-upgrade - Update all Homebrew packages"
echo "  btop         - Interactive system monitor"
echo ""
