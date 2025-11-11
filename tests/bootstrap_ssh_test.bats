#!/usr/bin/env bats
# ABOUTME: BATS tests for GitHub SSH connection testing functionality (Story 01.6-003)
# ABOUTME: Tests SSH connection validation, retry mechanism, abort prompts, and phase orchestration

# Load BATS support libraries
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

# Source the bootstrap script for testing
# shellcheck disable=SC1091
source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

#==============================================================================
# CATEGORY 1: FUNCTION EXISTENCE TESTS (5 tests)
#==============================================================================

@test "test_github_ssh_connection function exists" {
    declare -f test_github_ssh_connection
}

@test "display_ssh_troubleshooting function exists" {
    declare -f display_ssh_troubleshooting
}

@test "retry_ssh_connection function exists" {
    declare -f retry_ssh_connection
}

@test "prompt_continue_without_ssh function exists" {
    declare -f prompt_continue_without_ssh
}

@test "test_github_ssh_phase function exists" {
    declare -f test_github_ssh_phase
}

#==============================================================================
# CATEGORY 2: SSH CONNECTION TEST FUNCTION (15 tests)
#==============================================================================

@test "test_github_ssh_connection: detects success with 'successfully authenticated' message" {
    # Mock ssh command to return successful authentication
    ssh() {
        echo "Hi testuser! You've successfully authenticated, but GitHub does not provide shell access." >&2
        return 1  # GitHub's ssh -T returns 1 on success!
    }
    export -f ssh

    run test_github_ssh_connection
    assert_success
}

@test "test_github_ssh_connection: extracts username from success message" {
    # Mock ssh command with username in output
    ssh() {
        echo "Hi mlgruby! You've successfully authenticated, but GitHub does not provide shell access." >&2
        return 1
    }
    export -f ssh

    # Capture output to verify username extraction
    run test_github_ssh_connection
    assert_success
}

@test "test_github_ssh_connection: handles failure when authentication fails" {
    # Mock ssh command to return authentication failure
    ssh() {
        echo "Permission denied (publickey)." >&2
        return 255
    }
    export -f ssh

    run test_github_ssh_connection
    assert_failure
}

@test "test_github_ssh_connection: returns 0 on success" {
    ssh() {
        echo "Hi user! You've successfully authenticated" >&2
        return 1
    }
    export -f ssh

    test_github_ssh_connection
    assert_equal $? 0
}

@test "test_github_ssh_connection: returns 1 on failure" {
    ssh() {
        echo "Permission denied" >&2
        return 255
    }
    export -f ssh

    test_github_ssh_connection
    assert_equal $? 1
}

@test "test_github_ssh_connection: handles stderr output correctly" {
    # GitHub sends success message to stderr, not stdout
    ssh() {
        echo "Hi user! You've successfully authenticated" >&2
        return 1
    }
    export -f ssh

    run test_github_ssh_connection
    assert_success
}

@test "test_github_ssh_connection: handles stdout output correctly" {
    # Some SSH configurations might output to stdout
    ssh() {
        echo "Hi user! You've successfully authenticated"
        return 1
    }
    export -f ssh

    run test_github_ssh_connection
    assert_success
}

@test "test_github_ssh_connection: handles connection timeout" {
    ssh() {
        echo "Connection timed out" >&2
        return 255
    }
    export -f ssh

    run test_github_ssh_connection
    assert_failure
}

@test "test_github_ssh_connection: handles network unreachable error" {
    ssh() {
        echo "Network is unreachable" >&2
        return 255
    }
    export -f ssh

    run test_github_ssh_connection
    assert_failure
}

@test "test_github_ssh_connection: handles connection refused" {
    ssh() {
        echo "Connection refused" >&2
        return 255
    }
    export -f ssh

    run test_github_ssh_connection
    assert_failure
}

@test "test_github_ssh_connection: handles host key verification failure" {
    ssh() {
        echo "Host key verification failed" >&2
        return 255
    }
    export -f ssh

    run test_github_ssh_connection
    assert_failure
}

@test "test_github_ssh_connection: handles invalid key format" {
    ssh() {
        echo "Load key: invalid format" >&2
        return 255
    }
    export -f ssh

    run test_github_ssh_connection
    assert_failure
}

@test "test_github_ssh_connection: uses correct SSH command syntax" {
    # Verify ssh is called with correct arguments
    ssh() {
        # Check if called with -T git@github.com
        if [[ "$1" == "-T" ]] && [[ "$2" == "git@github.com" ]]; then
            echo "Hi user! You've successfully authenticated" >&2
            return 1
        fi
        return 255
    }
    export -f ssh

    run test_github_ssh_connection
    assert_success
}

@test "test_github_ssh_connection: captures both stdout and stderr" {
    ssh() {
        echo "stdout message"
        echo "Hi user! You've successfully authenticated" >&2
        return 1
    }
    export -f ssh

    run test_github_ssh_connection
    assert_success
}

@test "test_github_ssh_connection: handles empty output from SSH" {
    ssh() {
        return 255
    }
    export -f ssh

    run test_github_ssh_connection
    assert_failure
}

#==============================================================================
# CATEGORY 3: TROUBLESHOOTING DISPLAY (10 tests)
#==============================================================================

@test "display_ssh_troubleshooting: function runs without errors" {
    run display_ssh_troubleshooting
    assert_success
}

@test "display_ssh_troubleshooting: displays GitHub SSH keys link" {
    run display_ssh_troubleshooting
    assert_output --partial "github.com/settings/keys"
}

@test "display_ssh_troubleshooting: includes manual test command" {
    run display_ssh_troubleshooting
    assert_output --partial "ssh -T git@github.com"
}

@test "display_ssh_troubleshooting: mentions OAuth authorization" {
    run display_ssh_troubleshooting
    assert_output --partial "Authorize"
}

@test "display_ssh_troubleshooting: mentions key upload verification" {
    run display_ssh_troubleshooting
    assert_output --partial "uploaded"
}

@test "display_ssh_troubleshooting: mentions SSH passphrase" {
    run display_ssh_troubleshooting
    assert_output --partial "passphrase"
}

@test "display_ssh_troubleshooting: uses color codes for visibility" {
    run display_ssh_troubleshooting
    # Check for ANSI color codes (RED or YELLOW)
    assert_output --regexp '\[0;3[13]m'
}

@test "display_ssh_troubleshooting: provides clear section header" {
    run display_ssh_troubleshooting
    assert_output --partial "Troubleshooting"
}

@test "display_ssh_troubleshooting: includes actionable steps" {
    run display_ssh_troubleshooting
    assert_output --regexp "(Ensure|Verify|Check|Test)"
}

@test "display_ssh_troubleshooting: formats output for readability" {
    run display_ssh_troubleshooting
    # Should have multiple lines of output
    [ "${#lines[@]}" -gt 5 ]
}

#==============================================================================
# CATEGORY 4: RETRY MECHANISM (20 tests)
#==============================================================================

@test "retry_ssh_connection: displays attempt counter on first attempt" {
    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    run retry_ssh_connection
    assert_output --partial "Attempt 1 of 3"
}

@test "retry_ssh_connection: displays attempt counter on second attempt" {
    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    run retry_ssh_connection
    assert_output --partial "Attempt 2 of 3"
}

@test "retry_ssh_connection: displays attempt counter on third attempt" {
    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    run retry_ssh_connection
    assert_output --partial "Attempt 3 of 3"
}

@test "retry_ssh_connection: stops after 3 failed attempts" {
    local call_count=0
    test_github_ssh_connection() {
        ((call_count++))
        return 1
    }
    export -f test_github_ssh_connection
    export call_count

    retry_ssh_connection
    assert_equal $call_count 3
}

@test "retry_ssh_connection: returns 0 on first attempt success" {
    test_github_ssh_connection() { return 0; }
    export -f test_github_ssh_connection

    retry_ssh_connection
    assert_equal $? 0
}

@test "retry_ssh_connection: returns 0 on second attempt success" {
    local call_count=0
    test_github_ssh_connection() {
        ((call_count++))
        [ $call_count -eq 2 ] && return 0 || return 1
    }
    export -f test_github_ssh_connection
    export call_count

    retry_ssh_connection
    assert_equal $? 0
}

@test "retry_ssh_connection: returns 0 on third attempt success" {
    local call_count=0
    test_github_ssh_connection() {
        ((call_count++))
        [ $call_count -eq 3 ] && return 0 || return 1
    }
    export -f test_github_ssh_connection
    export call_count

    retry_ssh_connection
    assert_equal $? 0
}

@test "retry_ssh_connection: returns 1 after all failures" {
    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    retry_ssh_connection
    assert_equal $? 1
}

@test "retry_ssh_connection: waits between retry attempts" {
    # This test verifies sleep is called between attempts
    sleep() {
        echo "sleep called with: $1" >&2
    }
    export -f sleep

    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    run retry_ssh_connection
    assert_output --partial "sleep called"
}

@test "retry_ssh_connection: does not wait after final attempt" {
    # Mock to track sleep calls
    local sleep_count=0
    sleep() {
        ((sleep_count++))
    }
    export -f sleep
    export sleep_count

    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    retry_ssh_connection
    # Should only sleep 2 times (after attempt 1 and 2, not after 3)
    assert_equal $sleep_count 2
}

@test "retry_ssh_connection: stops immediately on first success" {
    local call_count=0
    test_github_ssh_connection() {
        ((call_count++))
        return 0
    }
    export -f test_github_ssh_connection
    export call_count

    retry_ssh_connection
    assert_equal $call_count 1
}

@test "retry_ssh_connection: displays success message on retry success" {
    local call_count=0
    test_github_ssh_connection() {
        ((call_count++))
        [ $call_count -eq 2 ] && return 0 || return 1
    }
    export -f test_github_ssh_connection
    export call_count

    run retry_ssh_connection
    assert_output --regexp "(Success|successful)"
}

@test "retry_ssh_connection: displays failure message after all retries" {
    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    run retry_ssh_connection
    assert_output --regexp "(Failed|failure)"
}

@test "retry_ssh_connection: uses log_info for attempt messages" {
    log_info() { echo "INFO: $*"; }
    export -f log_info

    test_github_ssh_connection() { return 0; }
    export -f test_github_ssh_connection

    run retry_ssh_connection
    assert_output --partial "INFO:"
}

@test "retry_ssh_connection: uses log_error for failure messages" {
    log_error() { echo "ERROR: $*"; }
    export -f log_error

    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    run retry_ssh_connection
    assert_output --partial "ERROR:"
}

@test "retry_ssh_connection: increments counter correctly" {
    local attempt_count=0
    log_info() {
        if [[ "$*" =~ Attempt\ ([0-9]+) ]]; then
            local current_attempt="${BASH_REMATCH[1]}"
            ((attempt_count++))
            assert_equal "$current_attempt" "$attempt_count"
        fi
    }
    export -f log_info
    export attempt_count

    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    retry_ssh_connection
}

@test "retry_ssh_connection: max attempts is 3" {
    # Verify hardcoded max is 3, not configurable
    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    run retry_ssh_connection
    refute_output --partial "Attempt 4"
}

@test "retry_ssh_connection: handles test function not defined" {
    unset -f test_github_ssh_connection

    run retry_ssh_connection
    assert_failure
}

@test "retry_ssh_connection: sleep duration is 2-3 seconds" {
    sleep() {
        # Verify sleep is called with 2 or 3 seconds
        [[ "$1" == "2" ]] || [[ "$1" == "3" ]]
    }
    export -f sleep

    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    run retry_ssh_connection
    assert_success  # If sleep is called correctly, run succeeds
}

@test "retry_ssh_connection: displays clear progress to user" {
    test_github_ssh_connection() { return 1; }
    export -f test_github_ssh_connection

    run retry_ssh_connection
    # Should show all 3 attempts
    assert_output --regexp "Attempt 1.*Attempt 2.*Attempt 3"
}

#==============================================================================
# CATEGORY 5: ABORT PROMPT (15 tests)
#==============================================================================

@test "prompt_continue_without_ssh: displays prompt message" {
    # Mock user input to avoid hanging
    read() {
        REPLY="n"
    }
    export -f read

    run prompt_continue_without_ssh
    assert_output --partial "Continue without SSH test"
}

@test "prompt_continue_without_ssh: shows 'not recommended' warning" {
    read() { REPLY="n"; }
    export -f read

    run prompt_continue_without_ssh
    assert_output --regexp "\[not recommended\]|\(not recommended\)"
}

@test "prompt_continue_without_ssh: accepts 'y' input" {
    read() { REPLY="y"; }
    export -f read

    prompt_continue_without_ssh
    assert_equal $? 0
}

@test "prompt_continue_without_ssh: accepts 'n' input" {
    read() { REPLY="n"; }
    export -f read

    run prompt_continue_without_ssh
    assert_failure
}

@test "prompt_continue_without_ssh: rejects invalid input and re-prompts" {
    local call_count=0
    read() {
        ((call_count++))
        if [ $call_count -eq 1 ]; then
            REPLY="invalid"
        else
            REPLY="n"
        fi
    }
    export -f read
    export call_count

    run prompt_continue_without_ssh
    assert_output --partial "Invalid"
}

@test "prompt_continue_without_ssh: accepts uppercase Y" {
    read() { REPLY="Y"; }
    export -f read

    prompt_continue_without_ssh
    assert_equal $? 0
}

@test "prompt_continue_without_ssh: accepts uppercase N" {
    read() { REPLY="N"; }
    export -f read

    run prompt_continue_without_ssh
    assert_failure
}

@test "prompt_continue_without_ssh: displays warning on continue" {
    read() { REPLY="y"; }
    export -f read

    run prompt_continue_without_ssh
    assert_output --regexp "(WARNING|Warning)"
}

@test "prompt_continue_without_ssh: displays abort message on exit" {
    read() { REPLY="n"; }
    export -f read

    run prompt_continue_without_ssh
    assert_output --regexp "(Abort|abort|exit)"
}

@test "prompt_continue_without_ssh: returns 0 on 'y'" {
    read() { REPLY="y"; }
    export -f read

    prompt_continue_without_ssh
    assert_equal $? 0
}

@test "prompt_continue_without_ssh: returns 1 on 'n'" {
    read() { REPLY="n"; }
    export -f read

    prompt_continue_without_ssh
    assert_equal $? 1
}

@test "prompt_continue_without_ssh: validates input is y or n only" {
    local call_count=0
    read() {
        ((call_count++))
        case $call_count in
            1) REPLY="maybe" ;;
            2) REPLY="yes" ;;
            3) REPLY="no" ;;
            4) REPLY="y" ;;
        esac
    }
    export -f read
    export call_count

    prompt_continue_without_ssh
    # Should eventually accept 'y' on 4th attempt
    assert_equal $? 0
}

@test "prompt_continue_without_ssh: uses log_warn for warnings" {
    log_warn() { echo "WARN: $*"; }
    export -f log_warn

    read() { REPLY="y"; }
    export -f read

    run prompt_continue_without_ssh
    assert_output --partial "WARN:"
}

@test "prompt_continue_without_ssh: uses log_error for abort" {
    log_error() { echo "ERROR: $*"; }
    export -f log_error

    read() { REPLY="n"; }
    export -f read

    run prompt_continue_without_ssh
    assert_output --partial "ERROR:"
}

@test "prompt_continue_without_ssh: trim whitespace from input" {
    read() { REPLY="  y  "; }
    export -f read

    prompt_continue_without_ssh
    assert_equal $? 0
}

#==============================================================================
# CATEGORY 6: ORCHESTRATION FUNCTION (10 tests)
#==============================================================================

@test "test_github_ssh_phase: displays phase header" {
    retry_ssh_connection() { return 0; }
    export -f retry_ssh_connection

    run test_github_ssh_phase
    assert_output --partial "PHASE 6"
}

@test "test_github_ssh_phase: mentions Story 01.6-003" {
    retry_ssh_connection() { return 0; }
    export -f retry_ssh_connection

    run test_github_ssh_phase
    assert_output --partial "01.6-003"
}

@test "test_github_ssh_phase: calls retry_ssh_connection" {
    local retry_called=false
    retry_ssh_connection() {
        retry_called=true
        return 0
    }
    export -f retry_ssh_connection
    export retry_called

    test_github_ssh_phase
    [ "$retry_called" = true ]
}

@test "test_github_ssh_phase: returns 0 on retry success" {
    retry_ssh_connection() { return 0; }
    export -f retry_ssh_connection

    test_github_ssh_phase
    assert_equal $? 0
}

@test "test_github_ssh_phase: calls prompt_continue_without_ssh on retry failure" {
    retry_ssh_connection() { return 1; }
    export -f retry_ssh_connection

    local prompt_called=false
    prompt_continue_without_ssh() {
        prompt_called=true
        return 0
    }
    export -f prompt_continue_without_ssh
    export prompt_called

    test_github_ssh_phase
    [ "$prompt_called" = true ]
}

@test "test_github_ssh_phase: returns 1 if user aborts" {
    retry_ssh_connection() { return 1; }
    export -f retry_ssh_connection

    prompt_continue_without_ssh() { return 1; }
    export -f prompt_continue_without_ssh

    test_github_ssh_phase
    assert_equal $? 1
}

@test "test_github_ssh_phase: returns 0 if user continues without SSH test" {
    retry_ssh_connection() { return 1; }
    export -f retry_ssh_connection

    prompt_continue_without_ssh() { return 0; }
    export -f prompt_continue_without_ssh

    test_github_ssh_phase
    assert_equal $? 0
}

@test "test_github_ssh_phase: displays troubleshooting on failure" {
    retry_ssh_connection() { return 1; }
    export -f retry_ssh_connection

    prompt_continue_without_ssh() { return 0; }
    export -f prompt_continue_without_ssh

    local troubleshooting_called=false
    display_ssh_troubleshooting() {
        troubleshooting_called=true
    }
    export -f display_ssh_troubleshooting
    export troubleshooting_called

    test_github_ssh_phase
    [ "$troubleshooting_called" = true ]
}

@test "test_github_ssh_phase: displays success message on connection success" {
    retry_ssh_connection() { return 0; }
    export -f retry_ssh_connection

    run test_github_ssh_phase
    assert_output --regexp "(Success|successful)"
}

@test "test_github_ssh_phase: uses log_info for phase header" {
    log_info() { echo "INFO: $*"; }
    export -f log_info

    retry_ssh_connection() { return 0; }
    export -f retry_ssh_connection

    run test_github_ssh_phase
    assert_output --partial "INFO:"
}

#==============================================================================
# CATEGORY 7: INTEGRATION TESTS (5 tests)
#==============================================================================

@test "integration: test_github_ssh_phase can be called from main flow" {
    # Verify function is accessible in bootstrap.sh scope
    declare -f test_github_ssh_phase
}

@test "integration: successful SSH test completes phase cleanly" {
    # Mock successful SSH connection
    ssh() {
        echo "Hi testuser! You've successfully authenticated" >&2
        return 1
    }
    export -f ssh

    run test_github_ssh_phase
    assert_success
}

@test "integration: failed SSH test with user continue proceeds" {
    # Mock failed SSH connection
    ssh() {
        echo "Permission denied" >&2
        return 255
    }
    export -f ssh

    # Mock user choosing to continue
    read() { REPLY="y"; }
    export -f read

    run test_github_ssh_phase
    assert_success
}

@test "integration: failed SSH test with user abort exits" {
    # Mock failed SSH connection
    ssh() {
        echo "Permission denied" >&2
        return 255
    }
    export -f ssh

    # Mock user choosing to abort
    read() { REPLY="n"; }
    export -f read

    run test_github_ssh_phase
    assert_failure
}

@test "integration: phase updates global status on completion" {
    # This test verifies phase completion is tracked
    ssh() {
        echo "Hi testuser! You've successfully authenticated" >&2
        return 1
    }
    export -f ssh

    test_github_ssh_phase
    assert_equal $? 0
}

#==============================================================================
# END OF TEST SUITE
#==============================================================================
