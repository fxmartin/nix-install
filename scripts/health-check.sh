#!/usr/bin/env bash
# ABOUTME: System health check script for nix-darwin configuration (Feature 06.4)
# ABOUTME: Validates Nix daemon, Homebrew, disk space, security settings, and generations

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Version
HEALTH_CHECK_VERSION="1.0.0"

# Thresholds
GENERATION_WARNING_THRESHOLD=50
DISK_WARNING_GB=20

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
# Check 3: Disk space on /nix
# ---------------------------------------------------------------------------
echo "Checking disk space..."
if [[ -d /nix ]]; then
    # Get available space in GB
    DISK_FREE_KB=$(df -k /nix | tail -1 | awk '{print $4}')
    DISK_FREE_GB=$((DISK_FREE_KB / 1024 / 1024))
    DISK_FREE_HUMAN=$(df -h /nix | tail -1 | awk '{print $4}')

    if [[ ${DISK_FREE_GB} -lt ${DISK_WARNING_GB} ]]; then
        print_status "warn" "Disk free on /nix: ${DISK_FREE_HUMAN} (low space!)"
        echo "    → Run: gc  # to remove old generations"
    else
        print_status "info" "Disk free on /nix: ${DISK_FREE_HUMAN}"
    fi
else
    print_status "error" "/nix directory not found"
fi

# Home directory space
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
    STORE_SIZE=$(du -sh /nix/store 2>/dev/null | cut -f1)
    print_status "info" "Nix store size: ${STORE_SIZE}"
fi

# ---------------------------------------------------------------------------
# Check 8: Development cache sizes
# ---------------------------------------------------------------------------
echo "Checking development caches..."

# Helper to get cache size in KB for comparison
get_cache_kb() {
    local path="${1}"
    if [[ -d "${path}" ]]; then
        du -sk "${path}" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

# Cache size threshold (1GB = 1048576 KB)
CACHE_WARNING_KB=1048576

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
