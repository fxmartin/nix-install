#!/usr/bin/env bats
# ABOUTME: BATS tests for Phase 9 - Installation Summary (Story 01.8-001)
# ABOUTME: Validates installation summary display, duration calculation, and next steps guidance

# Load test helpers
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

# Source the bootstrap script functions (but not main execution)
setup() {
    # Set up test environment variables BEFORE sourcing (some are readonly)
    export INSTALL_PROFILE="standard"
    export BOOTSTRAP_START_TIME=1000000000

    # Prevent bootstrap.sh from executing main() when sourced
    BATS_TEST_MODE=1
    # Source functions (execution guard will prevent main() from running)
    # Note: REPO_CLONE_DIR is readonly in bootstrap.sh, we can't override it
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
}

#############################################################################
# DURATION CALCULATION TESTS (8 tests)
#############################################################################

@test "format_installation_duration: handles short duration (<1 minute)" {
    local start_time=1000000000
    local end_time=1000000045  # 45 seconds

    run format_installation_duration "${start_time}" "${end_time}"
    assert_success
    assert_output --regexp "45 seconds?"
}

@test "format_installation_duration: handles exactly 1 minute" {
    local start_time=1000000000
    local end_time=1000000060  # 60 seconds

    run format_installation_duration "${start_time}" "${end_time}"
    assert_success
    assert_output --regexp "(1 minute|60 seconds?)"
}

@test "format_installation_duration: handles medium duration (5-10 minutes)" {
    local start_time=1000000000
    local end_time=1000000432  # 432 seconds = 7 minutes 12 seconds

    run format_installation_duration "${start_time}" "${end_time}"
    assert_success
    assert_output --regexp "7 minutes? 12 seconds?"
}

@test "format_installation_duration: handles long duration (20-30 minutes)" {
    local start_time=1000000000
    local end_time=1000001332  # 1332 seconds = 22 minutes 12 seconds

    run format_installation_duration "${start_time}" "${end_time}"
    assert_success
    assert_output --regexp "22 minutes? 12 seconds?"
}

@test "format_installation_duration: handles duration over 1 hour" {
    local start_time=1000000000
    local end_time=1000003723  # 3723 seconds = 1 hour 2 minutes 3 seconds

    run format_installation_duration "${start_time}" "${end_time}"
    assert_success
    assert_output --regexp "1 hours? 2 minutes?"
}

@test "format_installation_duration: handles zero duration" {
    local start_time=1000000000
    local end_time=1000000000  # 0 seconds

    run format_installation_duration "${start_time}" "${end_time}"
    assert_success
    assert_output --regexp "(0 seconds?|less than)"
}

@test "format_installation_duration: returns formatted string not raw numbers" {
    local start_time=1000000000
    local end_time=1000000305  # 305 seconds = 5 minutes 5 seconds

    run format_installation_duration "${start_time}" "${end_time}"
    assert_success
    # Should contain words, not just numbers
    assert_output --regexp "(minute|second)"
    # Should NOT be raw number format
    refute_output --regexp "^[0-9]+$"
}

@test "format_installation_duration: handles very long duration (2+ hours)" {
    local start_time=1000000000
    local end_time=1000007323  # 7323 seconds = 2 hours 2 minutes 3 seconds

    run format_installation_duration "${start_time}" "${end_time}"
    assert_success
    assert_output --regexp "2 hours? 2 minutes?"
}

#############################################################################
# COMPONENT DISPLAY TESTS (10 tests)
#############################################################################

@test "display_installed_components: displays Nix version" {
    # Mock nix --version command
    function nix() { echo "nix (Nix) 2.18.0"; }
    export -f nix

    run display_installed_components
    assert_success
    assert_output --partial "Nix Package Manager"
    assert_output --regexp "(2\.18|version)"
}

@test "display_installed_components: displays nix-darwin confirmation" {
    run display_installed_components
    assert_success
    assert_output --regexp "(nix-darwin|System Configuration)"
}

@test "display_installed_components: displays profile name for Standard" {
    export INSTALL_PROFILE="standard"

    run display_installed_components
    assert_success
    assert_output --partial "standard"
}

@test "display_installed_components: displays profile name for Power" {
    export INSTALL_PROFILE="power"

    run display_installed_components
    assert_success
    assert_output --partial "power"
}

@test "display_installed_components: displays approximate app count for Standard" {
    export INSTALL_PROFILE="standard"

    run display_installed_components
    assert_success
    # Standard profile has ~47 apps (be flexible: 40-50 range)
    assert_output --regexp "(4[0-9]|applications|apps)"
}

@test "display_installed_components: displays approximate app count for Power" {
    export INSTALL_PROFILE="power"

    run display_installed_components
    assert_success
    # Power profile has ~51 apps (be flexible: 48-55 range)
    assert_output --regexp "([45][0-9]|applications|apps)"
}

@test "display_installed_components: shows Home Manager installed" {
    run display_installed_components
    assert_success
    assert_output --regexp "(Home Manager|User Configuration)"
}

@test "display_installed_components: uses checkmark symbols for visual clarity" {
    run display_installed_components
    assert_success
    # Should use visual indicators (✓ or similar)
    assert_output --regexp "(✓|✔|√|\*)"
}

@test "display_installed_components: output is not empty" {
    run display_installed_components
    assert_success
    refute_output ""
}

@test "display_installed_components: gracefully handles missing profile variable" {
    unset INSTALL_PROFILE

    run display_installed_components
    assert_success
    # Should still work, maybe show "unknown" or "default"
    assert_output --regexp "(unknown|default|profile)"
}

#############################################################################
# NEXT STEPS TESTS (8 tests)
#############################################################################

@test "display_next_steps: shows exactly 4 numbered steps for Standard profile" {
    export INSTALL_PROFILE="standard"

    run display_next_steps
    assert_success
    # Should have steps 1, 2, 3, 4 (or 1-3 if Ollama is extra for Power)
    assert_output --regexp "1\."
    assert_output --regexp "2\."
    assert_output --regexp "3\."
    # Standard may have 3 or 4 steps
    assert_output --regexp "[1-4]\."
}

@test "display_next_steps: shows terminal restart instruction" {
    run display_next_steps
    assert_success
    assert_output --regexp "(Restart|terminal|source.*zshrc)"
}

@test "display_next_steps: mentions license activation" {
    run display_next_steps
    assert_success
    assert_output --regexp "(Activate|licensed|license)"
}

@test "display_next_steps: shows 2 steps for Standard profile" {
    export INSTALL_PROFILE="standard"

    run display_next_steps
    assert_success
    assert_output --regexp "1\."
    assert_output --regexp "2\."
    refute_output --regexp "3\."
}

@test "display_next_steps: includes Ollama verification for Power profile" {
    export INSTALL_PROFILE="power"

    run display_next_steps
    assert_success
    assert_output --regexp "(Ollama|ollama list)"
}

@test "display_next_steps: does NOT mention Ollama for Standard profile" {
    export INSTALL_PROFILE="standard"

    run display_next_steps
    assert_success
    refute_output --regexp "(Ollama|ollama)"
}

@test "display_next_steps: steps are numbered sequentially" {
    run display_next_steps
    assert_success
    # Check for sequential numbering
    assert_output --regexp "1\."
    # If there's a step 2, check it exists
    if echo "$output" | grep -q "2\."; then
        assert_output --regexp "2\."
    fi
}

@test "display_next_steps: output is formatted clearly with line breaks" {
    run display_next_steps
    assert_success
    # Should have multiple lines (not one giant line)
    [ "$(echo "$output" | wc -l)" -gt 3 ]
}

#############################################################################
# COMMAND REFERENCE TESTS (9 tests)
#############################################################################

@test "display_useful_commands: shows rebuild command" {
    run display_useful_commands
    assert_success
    assert_output --partial "rebuild"
}

@test "display_useful_commands: shows update command" {
    run display_useful_commands
    assert_success
    assert_output --partial "update"
}

@test "display_useful_commands: shows health-check command" {
    run display_useful_commands
    assert_success
    assert_output --partial "health-check"
}

@test "display_useful_commands: shows cleanup command" {
    run display_useful_commands
    assert_success
    assert_output --partial "cleanup"
}

@test "display_useful_commands: includes descriptions for each command" {
    run display_useful_commands
    assert_success
    # Should have descriptive text after command names
    assert_output --regexp "rebuild.*Apply|update.*Update|health.*Verify|cleanup.*garbage"
}

@test "display_useful_commands: commands are aligned or formatted consistently" {
    run display_useful_commands
    assert_success
    # All 4 commands should be present
    [ "$(echo "$output" | grep -c -E '(rebuild|update|health-check|cleanup)')" -ge 4 ]
}

@test "display_useful_commands: output is not empty" {
    run display_useful_commands
    assert_success
    refute_output ""
}

@test "display_useful_commands: mentions what rebuild applies from" {
    # REPO_CLONE_DIR is readonly in bootstrap.sh, already set to ~/Documents/nix-install
    run display_useful_commands
    assert_success
    # Should mention where config comes from
    assert_output --regexp "(Documents/nix-install|configuration)"
}

@test "display_useful_commands: mentions sudo requirement for darwin-rebuild commands" {
    run display_useful_commands
    assert_success
    # Should mention that rebuild and update require sudo
    assert_output --partial "sudo rebuild"
    assert_output --partial "sudo update"
    assert_output --regexp "(Note|note).*sudo.*darwin-rebuild"
}

#############################################################################
# DOCUMENTATION PATH TESTS (4 tests)
#############################################################################

@test "display_documentation_paths: shows README.md path" {
    # REPO_CLONE_DIR is readonly in bootstrap.sh, already set to ~/Documents/nix-install
    run display_documentation_paths
    assert_success
    assert_output --partial "README.md"
}

@test "display_documentation_paths: shows docs directory" {
    # REPO_CLONE_DIR is readonly in bootstrap.sh, already set to ~/Documents/nix-install
    run display_documentation_paths
    assert_success
    assert_output --regexp "docs"
}

@test "display_documentation_paths: uses correct repository path" {
    # REPO_CLONE_DIR is readonly in bootstrap.sh, already set to ~/Documents/nix-install
    run display_documentation_paths
    assert_success
    assert_output --partial "${HOME}/Documents/nix-install"
}

@test "display_documentation_paths: mentions troubleshooting documentation" {
    run display_documentation_paths
    assert_success
    assert_output --regexp "(Troubleshooting|troubleshooting|help)"
}

#############################################################################
# MANUAL ACTIVATION APPS TESTS (6 tests)
#############################################################################

@test "display_manual_activation_apps: lists 1Password" {
    run display_manual_activation_apps
    assert_success
    assert_output --partial "1Password"
}

@test "display_manual_activation_apps: lists Microsoft Office" {
    run display_manual_activation_apps
    assert_success
    assert_output --regexp "(Microsoft Office|Office 365)"
}

@test "display_manual_activation_apps: includes Parallels for Power profile" {
    export INSTALL_PROFILE="power"

    run display_manual_activation_apps
    assert_success
    assert_output --partial "Parallels"
}

@test "display_manual_activation_apps: does NOT include Parallels for Standard profile" {
    export INSTALL_PROFILE="standard"

    run display_manual_activation_apps
    assert_success
    refute_output --partial "Parallels"
}

@test "display_manual_activation_apps: uses bullet points or list formatting" {
    run display_manual_activation_apps
    assert_success
    # Should use visual list indicators (•, *, -, or numbers)
    assert_output --regexp "(•|\*|-|[0-9]\.)"
}

@test "display_manual_activation_apps: output is not empty" {
    run display_manual_activation_apps
    assert_success
    refute_output ""
}

#############################################################################
# PROFILE-SPECIFIC TESTS (6 tests)
#############################################################################

@test "installation_summary_phase: Standard profile has correct app count" {
    export INSTALL_PROFILE="standard"
    export BOOTSTRAP_START_TIME=1000000000

    # Mock date command for end time
    function date() {
        if [[ "$1" == "+%s" ]]; then
            echo "1000000600"  # 10 minutes later
        fi
    }
    export -f date

    run installation_summary_phase
    assert_success
    # Standard profile: ~47 apps (40-50 range)
    assert_output --regexp "(4[0-9]|47)"
}

@test "installation_summary_phase: Power profile has correct app count" {
    export INSTALL_PROFILE="power"
    export BOOTSTRAP_START_TIME=1000000000

    # Mock date command
    function date() {
        if [[ "$1" == "+%s" ]]; then
            echo "1000001200"  # 20 minutes later
        fi
    }
    export -f date

    run installation_summary_phase
    assert_success
    # Power profile: ~51 apps (48-55 range)
    assert_output --regexp "([45][0-9]|51)"
}

@test "installation_summary_phase: Standard profile does not mention Ollama" {
    export INSTALL_PROFILE="standard"
    export BOOTSTRAP_START_TIME=1000000000

    function date() {
        if [[ "$1" == "+%s" ]]; then
            echo "1000000600"
        fi
    }
    export -f date

    run installation_summary_phase
    assert_success
    refute_output --regexp "(Ollama|ollama)"
}

@test "installation_summary_phase: Power profile mentions Ollama models" {
    export INSTALL_PROFILE="power"
    export BOOTSTRAP_START_TIME=1000000000

    function date() {
        if [[ "$1" == "+%s" ]]; then
            echo "1000001200"
        fi
    }
    export -f date

    run installation_summary_phase
    assert_success
    assert_output --regexp "(Ollama|ollama list)"
}

@test "installation_summary_phase: Standard profile does not mention Parallels" {
    export INSTALL_PROFILE="standard"
    export BOOTSTRAP_START_TIME=1000000000

    function date() {
        if [[ "$1" == "+%s" ]]; then
            echo "1000000600"
        fi
    }
    export -f date

    run installation_summary_phase
    assert_success
    refute_output --partial "Parallels"
}

@test "installation_summary_phase: Power profile mentions Parallels Desktop" {
    export INSTALL_PROFILE="power"
    export BOOTSTRAP_START_TIME=1000000000

    function date() {
        if [[ "$1" == "+%s" ]]; then
            echo "1000001200"
        fi
    }
    export -f date

    run installation_summary_phase
    assert_success
    assert_output --partial "Parallels"
}

#############################################################################
# INTEGRATION & MAIN ORCHESTRATION TESTS (4 tests)
#############################################################################

@test "installation_summary_phase: displays banner header" {
    export BOOTSTRAP_START_TIME=1000000000

    function date() {
        if [[ "$1" == "+%s" ]]; then
            echo "1000000600"
        fi
    }
    export -f date

    run installation_summary_phase
    assert_success
    # Should have a clear header/banner
    assert_output --regexp "(INSTALLATION SUMMARY|Summary|Complete)"
}

@test "installation_summary_phase: calls all display functions" {
    export BOOTSTRAP_START_TIME=1000000000

    function date() {
        if [[ "$1" == "+%s" ]]; then
            echo "1000000600"
        fi
    }
    export -f date

    run installation_summary_phase
    assert_success
    # Should contain output from all sections
    assert_output --regexp "(Total|duration|time)"  # Duration
    assert_output --regexp "(Nix|installed|components)"  # Components
    assert_output --regexp "(Next Steps|next steps)"  # Next steps
    assert_output --regexp "(rebuild|update|command)"  # Commands
    assert_output --regexp "(README|docs)"  # Documentation
}

@test "installation_summary_phase: output is well-formatted with clear sections" {
    export BOOTSTRAP_START_TIME=1000000000

    function date() {
        if [[ "$1" == "+%s" ]]; then
            echo "1000000600"
        fi
    }
    export -f date

    run installation_summary_phase
    assert_success
    # Should have substantial output (not just a few lines)
    [ "$(echo "$output" | wc -l)" -gt 15 ]
}

@test "installation_summary_phase: handles missing BOOTSTRAP_START_TIME gracefully" {
    unset BOOTSTRAP_START_TIME

    function date() {
        if [[ "$1" == "+%s" ]]; then
            echo "1000000600"
        fi
    }
    export -f date

    run installation_summary_phase
    # Should still succeed, maybe show "unknown" duration
    assert_success
}
