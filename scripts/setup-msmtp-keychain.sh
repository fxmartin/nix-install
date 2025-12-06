#!/usr/bin/env bash
# ABOUTME: Setup script for msmtp Keychain credential storage (Story 06.5-001)
# ABOUTME: Securely stores Gandi email password in macOS Keychain for msmtp

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

KEYCHAIN_SERVICE="msmtp-gandi"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# =============================================================================
# MAIN SCRIPT
# =============================================================================

echo ""
echo "=== msmtp Keychain Setup ==="
echo ""
echo "This script stores your Gandi email password securely in macOS Keychain."
echo "The password will be used by msmtp for sending email notifications."
echo ""
echo "Provider: Gandi (mail.gandi.net:587)"
echo "Keychain service name: ${KEYCHAIN_SERVICE}"
echo ""

# Get email address
read -r -p "Enter your Gandi email address: " email

# Validate email format (basic check)
if [[ ! "${email}" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo -e "${RED}Error: Invalid email format${NC}"
    exit 1
fi

# Check if entry already exists
if security find-generic-password -a "${email}" -s "${KEYCHAIN_SERVICE}" &>/dev/null; then
    echo ""
    echo -e "${YELLOW}Warning: A password for ${email} already exists in Keychain.${NC}"
    read -r -p "Do you want to update it? (y/N): " update_choice
    if [[ ! "${update_choice}" =~ ^[Yy]$ ]]; then
        echo "Aborting. Existing password unchanged."
        exit 0
    fi
fi

# Get password (hidden input)
echo ""
read -r -s -p "Enter your Gandi email password: " password
echo ""

# Validate password not empty
if [[ -z "${password}" ]]; then
    echo -e "${RED}Error: Password cannot be empty${NC}"
    exit 1
fi

# Store in Keychain (-U flag updates if exists)
if security add-generic-password \
    -a "${email}" \
    -s "${KEYCHAIN_SERVICE}" \
    -w "${password}" \
    -U 2>/dev/null; then
    echo ""
    echo -e "${GREEN}✅ Password stored in Keychain successfully${NC}"
    echo ""
    echo "Keychain entry details:"
    echo "  Account: ${email}"
    echo "  Service: ${KEYCHAIN_SERVICE}"
    echo ""
else
    echo -e "${RED}Error: Failed to store password in Keychain${NC}"
    exit 1
fi

# Test retrieval
echo "Testing password retrieval..."
if retrieved=$(security find-generic-password -a "${email}" -s "${KEYCHAIN_SERVICE}" -w 2>/dev/null); then
    if [[ "${retrieved}" == "${password}" ]]; then
        echo -e "${GREEN}✅ Password retrieval test passed${NC}"
    else
        echo -e "${RED}❌ Password retrieval test failed (mismatch)${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Password retrieval test failed${NC}"
    exit 1
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Test email sending with:"
echo "  echo 'Test email from nix-install' | msmtp ${email}"
echo ""
echo "If you need to update the password later, run this script again."
echo ""
