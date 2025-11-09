#!/usr/bin/env bats
# ABOUTME: Test suite for Phase 2 user information prompts and validation
# ABOUTME: Tests email, GitHub username, and name validation functions

# Load the bootstrap script for testing
setup() {
    # Source the bootstrap script to access functions
    # Skip main() execution by sourcing
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
}

# =============================================================================
# FUNCTION EXISTENCE TESTS
# =============================================================================

@test "validate_email function exists" {
    declare -f validate_email > /dev/null
}

@test "validate_github_username function exists" {
    declare -f validate_github_username > /dev/null
}

@test "validate_name function exists" {
    declare -f validate_name > /dev/null
}

@test "prompt_user_info function exists" {
    declare -f prompt_user_info > /dev/null
}

# =============================================================================
# EMAIL VALIDATION TESTS - Valid Formats
# =============================================================================

@test "validate_email accepts simple valid email" {
    run validate_email "user@example.com"
    [ "$status" -eq 0 ]
}

@test "validate_email accepts email with plus addressing" {
    run validate_email "user+tag@example.com"
    [ "$status" -eq 0 ]
}

@test "validate_email accepts email with dots in local part" {
    run validate_email "first.last@example.com"
    [ "$status" -eq 0 ]
}

@test "validate_email accepts email with numbers" {
    run validate_email "user123@example456.com"
    [ "$status" -eq 0 ]
}

@test "validate_email accepts email with subdomain" {
    run validate_email "user@mail.example.com"
    [ "$status" -eq 0 ]
}

@test "validate_email accepts email with multi-part TLD" {
    run validate_email "user@example.co.uk"
    [ "$status" -eq 0 ]
}

@test "validate_email accepts complex valid email" {
    run validate_email "first.last+tag@mail.example.co.uk"
    [ "$status" -eq 0 ]
}

@test "validate_email accepts email with underscore" {
    run validate_email "user_name@example.com"
    [ "$status" -eq 0 ]
}

@test "validate_email accepts email with hyphen in domain" {
    run validate_email "user@my-domain.com"
    [ "$status" -eq 0 ]
}

# =============================================================================
# EMAIL VALIDATION TESTS - Invalid Formats
# =============================================================================

@test "validate_email rejects email without @ symbol" {
    run validate_email "userexample.com"
    [ "$status" -eq 1 ]
}

@test "validate_email rejects email without domain" {
    run validate_email "user@"
    [ "$status" -eq 1 ]
}

@test "validate_email rejects email without local part" {
    run validate_email "@example.com"
    [ "$status" -eq 1 ]
}

@test "validate_email rejects email without TLD" {
    run validate_email "user@example"
    [ "$status" -eq 1 ]
}

@test "validate_email rejects email with spaces" {
    run validate_email "user name@example.com"
    [ "$status" -eq 1 ]
}

@test "validate_email rejects email with multiple @ symbols" {
    run validate_email "user@@example.com"
    [ "$status" -eq 1 ]
}

@test "validate_email rejects empty string" {
    run validate_email ""
    [ "$status" -eq 1 ]
}

@test "validate_email rejects email with invalid characters" {
    run validate_email "user!#$%@example.com"
    [ "$status" -eq 1 ]
}

@test "validate_email rejects email ending with dot" {
    run validate_email "user@example.com."
    [ "$status" -eq 1 ]
}

@test "validate_email rejects email starting with dot" {
    run validate_email ".user@example.com"
    [ "$status" -eq 1 ]
}

# =============================================================================
# GITHUB USERNAME VALIDATION TESTS - Valid Formats
# =============================================================================

@test "validate_github_username accepts simple username" {
    run validate_github_username "fxmartin"
    [ "$status" -eq 0 ]
}

@test "validate_github_username accepts username with hyphen" {
    run validate_github_username "user-name"
    [ "$status" -eq 0 ]
}

@test "validate_github_username accepts username with underscore" {
    run validate_github_username "user_name"
    [ "$status" -eq 0 ]
}

@test "validate_github_username accepts username with numbers" {
    run validate_github_username "user123"
    [ "$status" -eq 0 ]
}

@test "validate_github_username accepts username with mixed separators" {
    run validate_github_username "user-name_123"
    [ "$status" -eq 0 ]
}

@test "validate_github_username accepts all lowercase" {
    run validate_github_username "lowercase"
    [ "$status" -eq 0 ]
}

@test "validate_github_username accepts all uppercase" {
    run validate_github_username "UPPERCASE"
    [ "$status" -eq 0 ]
}

@test "validate_github_username accepts mixed case" {
    run validate_github_username "MixedCase"
    [ "$status" -eq 0 ]
}

# =============================================================================
# GITHUB USERNAME VALIDATION TESTS - Invalid Formats
# =============================================================================

@test "validate_github_username rejects username with @ symbol" {
    run validate_github_username "user@name"
    [ "$status" -eq 1 ]
}

@test "validate_github_username rejects username with period" {
    run validate_github_username "user.name"
    [ "$status" -eq 1 ]
}

@test "validate_github_username rejects username with space" {
    run validate_github_username "user name"
    [ "$status" -eq 1 ]
}

@test "validate_github_username rejects username with special characters" {
    run validate_github_username "user!name"
    [ "$status" -eq 1 ]
}

@test "validate_github_username rejects username with hash" {
    run validate_github_username "user#name"
    [ "$status" -eq 1 ]
}

@test "validate_github_username rejects empty string" {
    run validate_github_username ""
    [ "$status" -eq 1 ]
}

@test "validate_github_username rejects username starting with hyphen" {
    run validate_github_username "-username"
    [ "$status" -eq 1 ]
}

@test "validate_github_username rejects username ending with hyphen" {
    run validate_github_username "username-"
    [ "$status" -eq 1 ]
}

@test "validate_github_username rejects username with slash" {
    run validate_github_username "user/name"
    [ "$status" -eq 1 ]
}

# =============================================================================
# NAME VALIDATION TESTS - Valid Formats
# =============================================================================

@test "validate_name accepts simple name" {
    run validate_name "John Doe"
    [ "$status" -eq 0 ]
}

@test "validate_name accepts name with accents" {
    run validate_name "François Martin"
    [ "$status" -eq 0 ]
}

@test "validate_name accepts name with apostrophe" {
    run validate_name "John O'Brien"
    [ "$status" -eq 0 ]
}

@test "validate_name accepts name with hyphen" {
    run validate_name "Mary-Jane Watson"
    [ "$status" -eq 0 ]
}

@test "validate_name accepts name with period" {
    run validate_name "Dr. John Smith"
    [ "$status" -eq 0 ]
}

@test "validate_name accepts single word name" {
    run validate_name "Madonna"
    [ "$status" -eq 0 ]
}

@test "validate_name accepts multiple middle names" {
    run validate_name "John Paul George Smith"
    [ "$status" -eq 0 ]
}

@test "validate_name accepts name with comma" {
    run validate_name "Smith, John"
    [ "$status" -eq 0 ]
}

# =============================================================================
# NAME VALIDATION TESTS - Invalid Formats
# =============================================================================

@test "validate_name rejects empty string" {
    run validate_name ""
    [ "$status" -eq 1 ]
}

@test "validate_name rejects whitespace-only string" {
    run validate_name "   "
    [ "$status" -eq 1 ]
}

@test "validate_name rejects tabs and newlines only" {
    run validate_name "$(printf '\t\n')"
    [ "$status" -eq 1 ]
}

# =============================================================================
# INTEGRATION TESTS
# =============================================================================

@test "validate_email is called with correct regex pattern" {
    # This tests the regex pattern itself
    # Valid email pattern: ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$

    # Test edge cases for the regex
    run validate_email "a@b.co"  # Minimum valid length
    [ "$status" -eq 0 ]
}

@test "validate_github_username enforces no leading/trailing hyphens" {
    # GitHub doesn't allow usernames to start or end with hyphens
    run validate_github_username "-test"
    [ "$status" -eq 1 ]

    run validate_github_username "test-"
    [ "$status" -eq 1 ]
}

@test "prompt_user_info function declares global variables" {
    # This test verifies the function sets up the right variable scope
    # We'll check that USER_FULLNAME, USER_EMAIL, GITHUB_USERNAME are mentioned
    declare -f prompt_user_info | grep -q "USER_FULLNAME\|USER_EMAIL\|GITHUB_USERNAME"
}
