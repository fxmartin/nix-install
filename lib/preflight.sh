# ABOUTME: Phase 1 - Pre-flight system validation orchestrator
# ABOUTME: Runs all system validation checks before starting installation
# ABOUTME: Depends on: lib/common.sh for validation functions

# Guard against double-sourcing
[[ -n "${_PREFLIGHT_SH_LOADED:-}" ]] && return 0
readonly _PREFLIGHT_SH_LOADED=1

# ==============================================================================
# PHASE 1: PRE-FLIGHT SYSTEM VALIDATION
# ==============================================================================

# Run all pre-flight validation checks
# Validates: macOS version, not root, internet connectivity
# Returns: 0 if all checks pass, 1 if any check fails
preflight_checks() {
    local phase_start
    phase_start=$(date +%s)

    log_phase 1 "Pre-flight System Validation"

    # shellcheck disable=SC2310  # Intentional: capture failures to show all errors

    # Display system information first
    display_system_info
    echo ""

    # Run individual checks
    local all_passed=true

    # shellcheck disable=SC2310  # Intentional: Using ! with functions to capture all failures
    if ! check_macos_version; then
        all_passed=false
    fi

    # shellcheck disable=SC2310
    if ! check_not_root; then
        all_passed=false
    fi

    # shellcheck disable=SC2310
    if ! check_internet; then
        all_passed=false
    fi

    echo ""

    if [[ "${all_passed}" == "false" ]]; then
        log_error "One or more pre-flight checks failed"
        log_error "Please resolve the issues above and try again"
        return 1
    fi

    local phase_end
    phase_end=$(date +%s)
    log_phase_complete 1 "Pre-flight System Validation" $((phase_end - phase_start))
    return 0
}
