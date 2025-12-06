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
# Check 8: LaunchAgents status
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

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Health Check Complete ==="
echo ""
echo "Quick commands:"
echo "  gc        - Remove all old generations (aggressive cleanup)"
echo "  cleanup   - GC + store optimization"
echo "  rebuild   - Rebuild system configuration"
echo "  btop      - Interactive system monitor"
echo ""
