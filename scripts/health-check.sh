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
HEALTH_CHECK_VERSION="1.1.0"

# Shared thresholds (keep in sync with health-api.py)
GENERATION_WARNING_THRESHOLD=50  # Warn if more than N system generations
DISK_WARNING_GB=20               # Warn if less than N GB free
CACHE_WARNING_KB=1048576         # 1 GB — warn if any single cache exceeds this

# Expected Ollama models per profile (keep in sync with flake.nix ollamaModels)
# Power: llava:34b, ministral-3:14b, phi4:14b, nomic-embed-text
# Standard: ministral-3:14b, nomic-embed-text

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

echo ""
echo "=== System Health Check ==="
echo "Host: $(hostname)"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
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
    STORE_SIZE=$(timeout 30 du -sh /nix/store 2>/dev/null | cut -f1)
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
        timeout 15 du -sk "${path}" 2>/dev/null | cut -f1 || echo "0"
    else
        echo "0"
    fi
}

# Cache size threshold (uses shared CACHE_WARNING_KB from config section above)

# Check each cache
UV_CACHE_KB=$(get_cache_kb ~/.cache/uv)
UV_CACHE_SIZE=$(timeout 15 du -sh ~/.cache/uv 2>/dev/null | cut -f1 || echo "0B")
if [[ ${UV_CACHE_KB} -gt ${CACHE_WARNING_KB} ]]; then
    print_status "warn" "uv cache: ${UV_CACHE_SIZE} (large!)"
else
    print_status "info" "uv cache: ${UV_CACHE_SIZE}"
fi

BREW_CACHE_KB=$(get_cache_kb ~/Library/Caches/Homebrew)
BREW_CACHE_SIZE=$(timeout 15 du -sh ~/Library/Caches/Homebrew 2>/dev/null | cut -f1 || echo "0B")
if [[ ${BREW_CACHE_KB} -gt ${CACHE_WARNING_KB} ]]; then
    print_status "warn" "Homebrew cache: ${BREW_CACHE_SIZE} (large!)"
else
    print_status "info" "Homebrew cache: ${BREW_CACHE_SIZE}"
fi

NPM_CACHE_KB=$(get_cache_kb ~/.npm)
NPM_CACHE_SIZE=$(timeout 15 du -sh ~/.npm 2>/dev/null | cut -f1 || echo "0B")
if [[ ${NPM_CACHE_KB} -gt ${CACHE_WARNING_KB} ]]; then
    print_status "warn" "npm cache: ${NPM_CACHE_SIZE} (large!)"
else
    print_status "info" "npm cache: ${NPM_CACHE_SIZE}"
fi

# Total cache estimate
TOTAL_CACHE_KB=$((UV_CACHE_KB + BREW_CACHE_KB + NPM_CACHE_KB))
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
echo "Checking maintenance LaunchAgents..."
# Capture launchctl output once (avoids pipefail issues with repeated calls)
LAUNCHCTL_OUTPUT=$(launchctl list 2>/dev/null || true)

if echo "${LAUNCHCTL_OUTPUT}" | /usr/bin/grep -q "org.nixos.nix-gc"; then
    print_status "ok" "nix-gc LaunchAgent loaded"
else
    print_status "warn" "nix-gc LaunchAgent not loaded"
    echo "    → Run: darwin-rebuild switch"
fi

if echo "${LAUNCHCTL_OUTPUT}" | /usr/bin/grep -q "org.nixos.nix-optimize"; then
    print_status "ok" "nix-optimize LaunchAgent loaded"
else
    print_status "warn" "nix-optimize LaunchAgent not loaded"
    echo "    → Run: darwin-rebuild switch"
fi

if echo "${LAUNCHCTL_OUTPUT}" | /usr/bin/grep -q "org.nixos.weekly-digest"; then
    print_status "ok" "weekly-digest LaunchAgent loaded"
else
    print_status "warn" "weekly-digest LaunchAgent not loaded"
    echo "    → Run: darwin-rebuild switch"
fi

if echo "${LAUNCHCTL_OUTPUT}" | /usr/bin/grep -q "org.nixos.disk-cleanup"; then
    print_status "ok" "disk-cleanup LaunchAgent loaded (monthly)"
else
    print_status "warn" "disk-cleanup LaunchAgent not loaded"
    echo "    → Run: darwin-rebuild switch"
fi

# ---------------------------------------------------------------------------
# Check 11: Podman container runtime
# ---------------------------------------------------------------------------
echo "Checking Podman..."
if command -v podman &> /dev/null; then
    # Check Podman machine status
    PODMAN_MACHINES=$(podman machine list --format '{{.Name}} {{.Running}}' 2>/dev/null || true)
    if [[ -n "${PODMAN_MACHINES}" ]]; then
        RUNNING_MACHINE=$(echo "${PODMAN_MACHINES}" | /usr/bin/grep -i "true" | head -1 | awk '{print $1}')
        if [[ -n "${RUNNING_MACHINE}" ]]; then
            print_status "ok" "Podman machine running: ${RUNNING_MACHINE}"
        else
            print_status "info" "Podman machine not running (start with: pmstart)"
        fi
    else
        print_status "info" "No Podman machines configured"
    fi

    # Image count (only if machine is running)
    if [[ -n "${RUNNING_MACHINE:-}" ]]; then
        IMAGE_COUNT=$(podman images --format '{{.ID}}' 2>/dev/null | wc -l | tr -d ' ')
        print_status "info" "Podman images: ${IMAGE_COUNT}"

        # Disk usage (reclaimable space)
        PODMAN_DF=$(podman system df 2>/dev/null || true)
        if [[ -n "${PODMAN_DF}" ]]; then
            RECLAIMABLE=$(echo "${PODMAN_DF}" | /usr/bin/grep -i "Local Volumes\|Images" | awk '{for(i=1;i<=NF;i++) if($i ~ /\(/) print $i $(i+1)}' | head -1)
            if [[ -n "${RECLAIMABLE}" ]]; then
                print_status "info" "Podman reclaimable: ${RECLAIMABLE}"
            fi
        fi
    fi
else
    print_status "info" "Podman not installed (container check skipped)"
fi

# ---------------------------------------------------------------------------
# Check 12: Qwen3-TTS server (Power profile only)
# ---------------------------------------------------------------------------
if echo "${LAUNCHCTL_OUTPUT}" | /usr/bin/grep -q "com.qwen3tts.server"; then
    echo "Checking Qwen3-TTS server..."
    print_status "ok" "qwen3-tts LaunchAgent loaded"

    # Check if the server responds on localhost:8765
    TTS_HEALTH=$(curl -s --connect-timeout 5 --max-time 10 http://localhost:8765/health 2>/dev/null || true)
    if [[ -n "${TTS_HEALTH}" ]]; then
        # Parse model statuses using python (available via nix)
        TTS_STATUS=$(echo "${TTS_HEALTH}" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    models = d.get('models', {})
    ok = sum(1 for m in models.values() if m.get('status') == 'ok')
    total = len(models)
    failed = [n for n, m in models.items() if m.get('status') != 'ok']
    if ok == total:
        print(f'ok:{ok}')
    else:
        print(f'degraded:{ok}/{total}:' + ','.join(failed))
except:
    print('parse_error')
" 2>/dev/null || echo "parse_error")

        case "${TTS_STATUS}" in
            ok:*)
                MODEL_COUNT="${TTS_STATUS#ok:}"
                print_status "ok" "Qwen3-TTS server healthy (${MODEL_COUNT} models loaded)"
                ;;
            degraded:*)
                INFO="${TTS_STATUS#degraded:}"
                COUNTS="${INFO%%:*}"
                FAILED="${INFO#*:}"
                print_status "warn" "Qwen3-TTS server degraded (${COUNTS} models ok, failed: ${FAILED})"
                echo "    → Run: launchctl stop com.qwen3tts.server && launchctl start com.qwen3tts.server"
                ;;
            *)
                print_status "warn" "Qwen3-TTS server responded but health parse failed"
                ;;
        esac
    else
        print_status "error" "Qwen3-TTS server not responding on localhost:8765"
        echo "    → Run: launchctl start com.qwen3tts.server"
        echo "    → Logs: /tmp/qwen3-tts-serve.err"
    fi
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

        # Determine expected models based on profile
        # Power profile has the qwen3tts LaunchAgent; Standard does not
        if echo "${LAUNCHCTL_OUTPUT}" | /usr/bin/grep -q "com.qwen3tts.server"; then
            EXPECTED_MODELS=("llava:34b" "ministral-3:14b" "phi4:14b" "nomic-embed-text")
            PROFILE="Power"
        else
            EXPECTED_MODELS=("ministral-3:14b" "nomic-embed-text")
            PROFILE="Standard"
        fi

        MISSING=0
        for model in "${EXPECTED_MODELS[@]}"; do
            # Match on model name prefix (ollama list shows full tags like "llava:34b")
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
            OLLAMA_SIZE=$(timeout 30 du -sh "${OLLAMA_DIR}" 2>/dev/null | cut -f1)
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
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Health Check Complete ==="
echo ""
echo "Quick commands:"
echo "  gc           - Remove old user generations"
echo "  gc-system    - Remove old system generations (sudo)"
echo "  cleanup      - GC + store optimization"
echo "  disk-cleanup - Clean dev caches (uv, npm, Homebrew, Podman)"
echo "  rebuild      - Rebuild system configuration"
echo "  update       - Update flake.lock + rebuild"
echo "  brew-upgrade - Update all Homebrew packages"
echo "  btop         - Interactive system monitor"
echo ""
