#!/bin/bash
# ABOUTME: Cryptographic integrity verification script for REQUIREMENTS.md
# ABOUTME: Validates document against external hash to detect tampering

echo "Requirements Document Integrity Verification"
echo "==========================================="

# Check if integrity file exists
if [ ! -f "requirements-integrity.json" ]; then
    echo "❌ INTEGRITY FILE MISSING: requirements-integrity.json not found"
    exit 1
fi

# Check if requirements file exists
if [ ! -f "REQUIREMENTS.md" ]; then
    echo "❌ REQUIREMENTS FILE MISSING: REQUIREMENTS.md not found"
    exit 1
fi

# Extract stored hash from integrity file
STORED_HASH=$(grep '"final_document"' requirements-integrity.json | cut -d'"' -f4)
APPROVAL_DATE=$(grep '"approval_timestamp"' requirements-integrity.json | cut -d'"' -f4)
APPROVED_BY=$(grep '"approved_by"' requirements-integrity.json | cut -d'"' -f4)

# Calculate current document hash
CURRENT_HASH=$(shasum -a 256 REQUIREMENTS.md | cut -d' ' -f1)

echo "Document: REQUIREMENTS.md"
echo "Approved By: $APPROVED_BY"
echo "Approval Date: $APPROVAL_DATE"
echo "Stored Hash:  $STORED_HASH"
echo "Current Hash: $CURRENT_HASH"
echo ""

# Verify integrity
if [ "$STORED_HASH" = "$CURRENT_HASH" ]; then
    echo "Status: ✅ INTEGRITY VERIFIED"
    echo "Document unchanged since stakeholder approval"
    echo "Development authorized to proceed"
    exit 0
else
    echo "Status: ❌ INTEGRITY COMPROMISED"
    echo "Document has been modified since approval"
    echo "Change control process required"
    echo "Development authorization REVOKED"
    exit 1
fi
