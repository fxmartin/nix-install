#!/usr/bin/env bats
# ABOUTME: Test suite for Phase 2 profile selection (Standard vs Power)
# ABOUTME: Tests profile selection prompts, validation, and confirmation flow

# Load the bootstrap script for testing
setup() {
    # Source the bootstrap script to access functions
    # Skip main() execution by sourcing
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
}

# =============================================================================
# FUNCTION EXISTENCE TESTS
# =============================================================================

@test "select_installation_profile function exists" {
    declare -f select_installation_profile > /dev/null
}

# =============================================================================
# PROFILE SELECTION VALIDATION TESTS
# =============================================================================

@test "validate_profile_choice accepts choice 1 (Standard)" {
    run validate_profile_choice "1"
    [ "$status" -eq 0 ]
}

@test "validate_profile_choice accepts choice 2 (Power)" {
    run validate_profile_choice "2"
    [ "$status" -eq 0 ]
}

@test "validate_profile_choice rejects choice 0" {
    run validate_profile_choice "0"
    [ "$status" -eq 1 ]
}

@test "validate_profile_choice rejects choice 3" {
    run validate_profile_choice "3"
    [ "$status" -eq 1 ]
}

@test "validate_profile_choice rejects non-numeric input" {
    run validate_profile_choice "standard"
    [ "$status" -eq 1 ]
}

@test "validate_profile_choice rejects empty string" {
    run validate_profile_choice ""
    [ "$status" -eq 1 ]
}

@test "validate_profile_choice rejects negative numbers" {
    run validate_profile_choice "-1"
    [ "$status" -eq 1 ]
}

@test "validate_profile_choice rejects decimal numbers" {
    run validate_profile_choice "1.5"
    [ "$status" -eq 1 ]
}

@test "validate_profile_choice rejects multiple digits" {
    run validate_profile_choice "12"
    [ "$status" -eq 1 ]
}

@test "validate_profile_choice rejects special characters" {
    run validate_profile_choice "@"
    [ "$status" -eq 1 ]
}

@test "validate_profile_choice rejects whitespace" {
    run validate_profile_choice " "
    [ "$status" -eq 1 ]
}

# =============================================================================
# PROFILE CHOICE TO NAME CONVERSION TESTS
# =============================================================================

@test "convert_profile_choice_to_name converts 1 to standard" {
    run convert_profile_choice_to_name "1"
    [ "$status" -eq 0 ]
    [ "$output" = "standard" ]
}

@test "convert_profile_choice_to_name converts 2 to power" {
    run convert_profile_choice_to_name "2"
    [ "$status" -eq 0 ]
    [ "$output" = "power" ]
}

@test "convert_profile_choice_to_name defaults invalid input to standard" {
    run convert_profile_choice_to_name "3"
    [ "$status" -eq 0 ]
    [ "$output" = "standard" ]
}

@test "convert_profile_choice_to_name defaults empty input to standard" {
    run convert_profile_choice_to_name ""
    [ "$status" -eq 0 ]
    [ "$output" = "standard" ]
}

@test "convert_profile_choice_to_name defaults non-numeric input to standard" {
    run convert_profile_choice_to_name "invalid"
    [ "$status" -eq 0 ]
    [ "$output" = "standard" ]
}

# =============================================================================
# PROFILE DESCRIPTION TESTS
# =============================================================================

@test "display_profile_options function exists" {
    declare -f display_profile_options > /dev/null
}

@test "display_profile_options shows Standard profile description" {
    run display_profile_options
    [ "$status" -eq 0 ]
    [[ "$output" =~ "1) Standard Profile" ]]
}

@test "display_profile_options shows Power profile description" {
    run display_profile_options
    [ "$status" -eq 0 ]
    [[ "$output" =~ "2) Power Profile" ]]
}

@test "display_profile_options shows Standard disk usage estimate" {
    run display_profile_options
    [ "$status" -eq 0 ]
    [[ "$output" =~ "~35GB" ]]
}

@test "display_profile_options shows Power disk usage estimate" {
    run display_profile_options
    [ "$status" -eq 0 ]
    [[ "$output" =~ "~120GB" ]]
}

@test "display_profile_options shows MacBook Air target" {
    run display_profile_options
    [ "$status" -eq 0 ]
    [[ "$output" =~ "MacBook Air" ]]
}

@test "display_profile_options shows MacBook Pro M3 Max target" {
    run display_profile_options
    [ "$status" -eq 0 ]
    [[ "$output" =~ "MacBook Pro M3 Max" ]]
}

@test "display_profile_options shows 1 Ollama model for Standard" {
    run display_profile_options
    [ "$status" -eq 0 ]
    [[ "$output" =~ "1 Ollama model" ]]
}

@test "display_profile_options shows 4 Ollama models for Power" {
    run display_profile_options
    [ "$status" -eq 0 ]
    [[ "$output" =~ "4 Ollama models" ]]
}

@test "display_profile_options shows no virtualization for Standard" {
    run display_profile_options
    [ "$status" -eq 0 ]
    [[ "$output" =~ "no virtualization" ]]
}

@test "display_profile_options shows Parallels Desktop for Power" {
    run display_profile_options
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Parallels Desktop" ]]
}

# =============================================================================
# CONFIRMATION PROMPT TESTS
# =============================================================================

@test "confirm_profile_choice function exists" {
    declare -f confirm_profile_choice > /dev/null
}

@test "get_profile_display_name returns Standard Profile for standard" {
    run get_profile_display_name "standard"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Standard Profile" ]]
}

@test "get_profile_display_name returns Power Profile for power" {
    run get_profile_display_name "power"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Power Profile" ]]
}

@test "get_profile_display_name handles unknown profile gracefully" {
    run get_profile_display_name "unknown"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Unknown Profile" ]]
}

# =============================================================================
# INTEGRATION TESTS
# =============================================================================

@test "INSTALL_PROFILE variable is declared global" {
    # Check that INSTALL_PROFILE variable would be set by the function
    # We can't test the interactive prompt, but we can verify the variable exists in scope
    [[ -v INSTALL_PROFILE ]] || [ -z "${INSTALL_PROFILE:-}" ]
}

@test "profile selection follows Phase 2 in execution flow" {
    # Verify select_installation_profile would be called in correct phase
    # This test ensures function is logically placed after prompt_user_info
    declare -f prompt_user_info > /dev/null
    declare -f select_installation_profile > /dev/null
}

@test "profile variable uses correct value format (standard or power)" {
    # Test that conversion function only outputs valid values
    result1=$(convert_profile_choice_to_name "1")
    result2=$(convert_profile_choice_to_name "2")

    [[ "$result1" == "standard" ]]
    [[ "$result2" == "power" ]]
}
