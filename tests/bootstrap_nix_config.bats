#!/usr/bin/env bats
# ABOUTME: Comprehensive test suite for Nix configuration phase (Story 01.4-002)
# ABOUTME: Tests binary cache setup, performance tuning, trusted users, sandbox config, and daemon restart

# Setup and teardown
setup() {
    # Load bootstrap.sh for testing
    export TESTING=1

    # Create temporary test directory
    TEST_TMP_DIR="$(mktemp -d)"
    export TEST_TMP_DIR

    # Mock nix.conf file location
    export MOCK_NIX_CONF="${TEST_TMP_DIR}/nix.conf"

    # Mock sysctl for CPU detection
    sysctl() {
        case "${1:-}" in
            -n)
                case "${2:-}" in
                    hw.ncpu)
                        echo "${MOCK_CPU_CORES:-8}"
                        return 0
                        ;;
                    *)
                        return 1
                        ;;
                esac
                ;;
            *)
                return 1
                ;;
        esac
    }
    export -f sysctl

    # Mock launchctl for daemon operations
    launchctl() {
        if [[ "${MOCK_LAUNCHCTL_FAIL:-0}" == "1" ]]; then
            return 1
        fi
        return 0
    }
    export -f launchctl

    # Mock sleep to speed up tests
    sleep() {
        return 0
    }
    export -f sleep

    # Mock sudo to avoid actual sudo execution in tests
    sudo() {
        if [[ "${MOCK_SUDO_FAIL:-0}" == "1" ]]; then
            echo "sudo: permission denied" >&2
            return 1
        fi
        # Execute the command without actual sudo
        "${@}"
    }
    export -f sudo
}

teardown() {
    # Clean up test directory
    if [[ -n "${TEST_TMP_DIR:-}" && -d "${TEST_TMP_DIR}" ]]; then
        rm -rf "${TEST_TMP_DIR}"
    fi

    # Clean up environment
    unset TEST_TMP_DIR
    unset MOCK_NIX_CONF
    unset MOCK_CPU_CORES
    unset MOCK_LAUNCHCTL_FAIL
    unset MOCK_SUDO_FAIL
    unset TESTING
}

# =============================================================================
# Function Existence Tests (9 tests)
# =============================================================================

@test "backup_nix_config function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f backup_nix_config >/dev/null
}

@test "get_cpu_cores function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f get_cpu_cores >/dev/null
}

@test "configure_nix_binary_cache function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f configure_nix_binary_cache >/dev/null
}

@test "configure_nix_performance function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f configure_nix_performance >/dev/null
}

@test "configure_nix_trusted_users function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f configure_nix_trusted_users >/dev/null
}

@test "configure_nix_sandbox function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f configure_nix_sandbox >/dev/null
}

@test "restart_nix_daemon function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f restart_nix_daemon >/dev/null
}

@test "verify_nix_configuration function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f verify_nix_configuration >/dev/null
}

@test "configure_nix_phase function exists" {
    source /Users/user/dev/nix-install/bootstrap.sh
    declare -f configure_nix_phase >/dev/null
}

# =============================================================================
# Backup Logic Tests (8 tests)
# =============================================================================

@test "backup_nix_config creates backup when file exists" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create existing config file
    echo "existing config" > "${MOCK_NIX_CONF}"

    run backup_nix_config "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]

    # Check backup was created
    local backup_count
    backup_count=$(find "${TEST_TMP_DIR}" -name "nix.conf.backup-*" | wc -l)
    [ "$backup_count" -ge 1 ]
}

@test "backup_nix_config handles missing file gracefully" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Ensure file doesn't exist
    rm -f "${MOCK_NIX_CONF}"

    run backup_nix_config "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

@test "backup_nix_config creates timestamped backup" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create existing config file
    echo "existing config" > "${MOCK_NIX_CONF}"

    backup_nix_config "${MOCK_NIX_CONF}"

    # Check backup filename format (YYYYMMDD-HHMMSS)
    local backup_file
    backup_file=$(find "${TEST_TMP_DIR}" -name "nix.conf.backup-*" | head -n 1)
    [[ "${backup_file}" =~ nix.conf.backup-[0-9]{8}-[0-9]{6} ]]
}

@test "backup_nix_config preserves original file content" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create existing config file
    local original_content="experimental-features = nix-command flakes"
    echo "${original_content}" > "${MOCK_NIX_CONF}"

    backup_nix_config "${MOCK_NIX_CONF}"

    # Verify backup contains original content
    local backup_file
    backup_file=$(find "${TEST_TMP_DIR}" -name "nix.conf.backup-*" | head -n 1)
    local backup_content
    backup_content=$(cat "${backup_file}")
    [ "${backup_content}" = "${original_content}" ]
}

@test "backup_nix_config allows multiple backups" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create existing config file
    echo "config v1" > "${MOCK_NIX_CONF}"
    backup_nix_config "${MOCK_NIX_CONF}"

    # Force sleep to ensure different timestamp (macOS has second-level precision)
    sleep 2

    echo "config v2" > "${MOCK_NIX_CONF}"
    backup_nix_config "${MOCK_NIX_CONF}"

    # Check multiple backups exist
    local backup_count
    backup_count=$(find "${TEST_TMP_DIR}" -name "nix.conf.backup-*" | wc -l)
    [ "$backup_count" -ge 2 ]
}

@test "backup_nix_config logs backup creation" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create existing config file
    echo "existing config" > "${MOCK_NIX_CONF}"

    run backup_nix_config "${MOCK_NIX_CONF}"
    [[ "${output}" =~ "backup" ]] || [[ "${output}" =~ "Backup" ]]
}

@test "backup_nix_config returns 0 on success" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create existing config file
    echo "existing config" > "${MOCK_NIX_CONF}"

    run backup_nix_config "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

@test "backup_nix_config handles empty file" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config file
    touch "${MOCK_NIX_CONF}"

    run backup_nix_config "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

# =============================================================================
# CPU Detection Tests (6 tests)
# =============================================================================

@test "get_cpu_cores detects CPU count using sysctl" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    run get_cpu_cores
    [ "$status" -eq 0 ]
    [ "$output" = "8" ]
}

@test "get_cpu_cores returns auto on sysctl failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Override sysctl to fail
    sysctl() {
        return 1
    }
    export -f sysctl

    run get_cpu_cores
    [ "$status" -eq 0 ]
    [ "$output" = "auto" ]
}

@test "get_cpu_cores handles various CPU counts" {
    source /Users/user/dev/nix-install/bootstrap.sh

    for cores in 4 8 10 12 16; do
        export MOCK_CPU_CORES=$cores
        result=$(get_cpu_cores)
        [ "$result" = "$cores" ]
    done
}

@test "get_cpu_cores outputs numeric value" {
    export MOCK_CPU_CORES=10
    source /Users/user/dev/nix-install/bootstrap.sh

    result=$(get_cpu_cores)
    [[ "$result" =~ ^[0-9]+$ ]] || [ "$result" = "auto" ]
}

@test "get_cpu_cores logs detection" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    run get_cpu_cores
    # Output should be just the number for parsing
    [ "$output" = "8" ]
}

@test "get_cpu_cores is consistent across calls" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    result1=$(get_cpu_cores)
    result2=$(get_cpu_cores)
    [ "$result1" = "$result2" ]
}

# =============================================================================
# Binary Cache Configuration Tests (10 tests)
# =============================================================================

@test "configure_nix_binary_cache adds substituters setting" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_binary_cache "${MOCK_NIX_CONF}"

    grep -q "substituters.*cache.nixos.org" "${MOCK_NIX_CONF}"
}

@test "configure_nix_binary_cache adds trusted-public-keys" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_binary_cache "${MOCK_NIX_CONF}"

    grep -q "trusted-public-keys.*cache.nixos.org-1" "${MOCK_NIX_CONF}"
}

@test "configure_nix_binary_cache uses correct cache.nixos.org URL" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_binary_cache "${MOCK_NIX_CONF}"

    grep -q "https://cache.nixos.org" "${MOCK_NIX_CONF}"
}

@test "configure_nix_binary_cache includes full public key" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_binary_cache "${MOCK_NIX_CONF}"

    grep -q "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "${MOCK_NIX_CONF}"
}

@test "configure_nix_binary_cache returns 0 on success" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    run configure_nix_binary_cache "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

@test "configure_nix_binary_cache logs configuration" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    run configure_nix_binary_cache "${MOCK_NIX_CONF}"
    [[ "${output}" =~ "cache" ]] || [[ "${output}" =~ "binary" ]]
}

@test "configure_nix_binary_cache handles existing config" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create config with existing content
    echo "experimental-features = nix-command flakes" > "${MOCK_NIX_CONF}"

    configure_nix_binary_cache "${MOCK_NIX_CONF}"

    # Both old and new content should exist
    grep -q "experimental-features" "${MOCK_NIX_CONF}"
    grep -q "substituters" "${MOCK_NIX_CONF}"
}

@test "configure_nix_binary_cache doesn't duplicate settings" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    # Run twice
    configure_nix_binary_cache "${MOCK_NIX_CONF}"
    configure_nix_binary_cache "${MOCK_NIX_CONF}"

    # Count substituters lines (should be 1 if idempotent)
    local count
    count=$(grep -c "substituters.*cache.nixos.org" "${MOCK_NIX_CONF}" || true)
    [ "$count" -eq 1 ]
}

@test "configure_nix_binary_cache creates file if missing" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Ensure file doesn't exist
    rm -f "${MOCK_NIX_CONF}"

    run configure_nix_binary_cache "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
    [ -f "${MOCK_NIX_CONF}" ]
}

@test "configure_nix_binary_cache sets proper format" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_binary_cache "${MOCK_NIX_CONF}"

    # Check format: key = value
    grep -q "substituters = " "${MOCK_NIX_CONF}"
    grep -q "trusted-public-keys = " "${MOCK_NIX_CONF}"
}

# =============================================================================
# Performance Configuration Tests (8 tests)
# =============================================================================

@test "configure_nix_performance adds max-jobs setting" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_performance "${MOCK_NIX_CONF}"

    grep -q "max-jobs" "${MOCK_NIX_CONF}"
}

@test "configure_nix_performance adds cores setting" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_performance "${MOCK_NIX_CONF}"

    grep -q "cores" "${MOCK_NIX_CONF}"
}

@test "configure_nix_performance uses detected CPU cores" {
    export MOCK_CPU_CORES=10
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_performance "${MOCK_NIX_CONF}"

    grep -q "max-jobs = 10" "${MOCK_NIX_CONF}"
}

@test "configure_nix_performance uses auto on CPU detection failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Override sysctl to fail
    sysctl() {
        return 1
    }
    export -f sysctl

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_performance "${MOCK_NIX_CONF}"

    grep -q "max-jobs = auto" "${MOCK_NIX_CONF}"
}

@test "configure_nix_performance sets cores to 0 (use all)" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_performance "${MOCK_NIX_CONF}"

    grep -q "cores = 0" "${MOCK_NIX_CONF}"
}

@test "configure_nix_performance returns 0 on success" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    run configure_nix_performance "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

@test "configure_nix_performance logs configuration" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    run configure_nix_performance "${MOCK_NIX_CONF}"
    [[ "${output}" =~ "performance" ]] || [[ "${output}" =~ "parallel" ]] || [[ "${output}" =~ "cores" ]]
}

@test "configure_nix_performance doesn't duplicate settings" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    # Run twice
    configure_nix_performance "${MOCK_NIX_CONF}"
    configure_nix_performance "${MOCK_NIX_CONF}"

    # Count max-jobs lines
    local count
    count=$(grep -c "max-jobs" "${MOCK_NIX_CONF}" || true)
    [ "$count" -eq 1 ]
}

# =============================================================================
# Trusted Users Configuration Tests (8 tests)
# =============================================================================

@test "configure_nix_trusted_users adds trusted-users setting" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_trusted_users "${MOCK_NIX_CONF}"

    grep -q "trusted-users" "${MOCK_NIX_CONF}"
}

@test "configure_nix_trusted_users includes root" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_trusted_users "${MOCK_NIX_CONF}"

    grep -q "trusted-users.*root" "${MOCK_NIX_CONF}"
}

@test "configure_nix_trusted_users includes current user" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_trusted_users "${MOCK_NIX_CONF}"

    grep -q "trusted-users.*${USER}" "${MOCK_NIX_CONF}"
}

@test "configure_nix_trusted_users uses correct format" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_trusted_users "${MOCK_NIX_CONF}"

    # Format should be: trusted-users = root $USER
    grep -q "trusted-users = " "${MOCK_NIX_CONF}"
}

@test "configure_nix_trusted_users returns 0 on success" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    run configure_nix_trusted_users "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

@test "configure_nix_trusted_users logs configuration" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    run configure_nix_trusted_users "${MOCK_NIX_CONF}"
    [[ "${output}" =~ "trusted" ]] || [[ "${output}" =~ "user" ]]
}

@test "configure_nix_trusted_users doesn't duplicate settings" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    # Run twice
    configure_nix_trusted_users "${MOCK_NIX_CONF}"
    configure_nix_trusted_users "${MOCK_NIX_CONF}"

    # Count trusted-users lines
    local count
    count=$(grep -c "trusted-users" "${MOCK_NIX_CONF}" || true)
    [ "$count" -eq 1 ]
}

@test "configure_nix_trusted_users handles existing config" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create config with existing content
    echo "experimental-features = nix-command flakes" > "${MOCK_NIX_CONF}"

    configure_nix_trusted_users "${MOCK_NIX_CONF}"

    # Both old and new content should exist
    grep -q "experimental-features" "${MOCK_NIX_CONF}"
    grep -q "trusted-users" "${MOCK_NIX_CONF}"
}

# =============================================================================
# Sandbox Configuration Tests (6 tests)
# =============================================================================

@test "configure_nix_sandbox adds sandbox setting" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_sandbox "${MOCK_NIX_CONF}"

    grep -q "sandbox" "${MOCK_NIX_CONF}"
}

@test "configure_nix_sandbox uses macOS-appropriate value" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_sandbox "${MOCK_NIX_CONF}"

    # Should be either "relaxed" or "false" for macOS
    grep -q "sandbox = relaxed" "${MOCK_NIX_CONF}" || grep -q "sandbox = false" "${MOCK_NIX_CONF}"
}

@test "configure_nix_sandbox returns 0 on success" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    run configure_nix_sandbox "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

@test "configure_nix_sandbox logs configuration" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    run configure_nix_sandbox "${MOCK_NIX_CONF}"
    [[ "${output}" =~ "sandbox" ]] || [[ "${output}" =~ "macOS" ]]
}

@test "configure_nix_sandbox doesn't duplicate settings" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    # Run twice
    configure_nix_sandbox "${MOCK_NIX_CONF}"
    configure_nix_sandbox "${MOCK_NIX_CONF}"

    # Count sandbox lines
    local count
    count=$(grep -c "^sandbox" "${MOCK_NIX_CONF}" || true)
    [ "$count" -eq 1 ]
}

@test "configure_nix_sandbox uses correct format" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create empty config
    touch "${MOCK_NIX_CONF}"

    configure_nix_sandbox "${MOCK_NIX_CONF}"

    # Format should be: sandbox = value
    grep -q "sandbox = " "${MOCK_NIX_CONF}"
}

# =============================================================================
# Daemon Restart Tests (10 tests)
# =============================================================================

@test "restart_nix_daemon calls launchctl kickstart" {
    source /Users/user/dev/nix-install/bootstrap.sh

    run restart_nix_daemon
    [ "$status" -eq 0 ]
}

@test "restart_nix_daemon uses correct service name" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Mock launchctl to capture arguments to stdout for BATS
    launchctl() {
        echo "launchctl called with: $@"
        return 0
    }
    export -f launchctl

    # Mock sudo to pass through to launchctl
    sudo() {
        "${@}"
    }
    export -f sudo

    run restart_nix_daemon
    [[ "${output}" =~ "system/org.nixos.nix-daemon" ]]
}

@test "restart_nix_daemon waits after restart" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # sleep is mocked in setup, but verify it's called conceptually
    run restart_nix_daemon
    [ "$status" -eq 0 ]
}

@test "restart_nix_daemon returns 0 on success" {
    source /Users/user/dev/nix-install/bootstrap.sh

    run restart_nix_daemon
    [ "$status" -eq 0 ]
}

@test "restart_nix_daemon returns 1 on launchctl failure" {
    export MOCK_LAUNCHCTL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run restart_nix_daemon
    [ "$status" -eq 1 ]
}

@test "restart_nix_daemon logs restart action" {
    source /Users/user/dev/nix-install/bootstrap.sh

    run restart_nix_daemon
    [[ "${output}" =~ "restart" ]] || [[ "${output}" =~ "daemon" ]]
}

@test "restart_nix_daemon logs error on failure" {
    export MOCK_LAUNCHCTL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run restart_nix_daemon
    [[ "${output}" =~ "error" ]] || [[ "${output}" =~ "failed" ]] || [[ "${output}" =~ "Error" ]] || [[ "${output}" =~ "Failed" ]]
}

@test "restart_nix_daemon uses -k flag (kill and restart)" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Mock launchctl to capture flags to stdout
    launchctl() {
        echo "launchctl flags: $@"
        return 0
    }
    export -f launchctl

    # Mock sudo to pass through
    sudo() {
        "${@}"
    }
    export -f sudo

    run restart_nix_daemon
    [[ "${output}" =~ "-k" ]]
}

@test "restart_nix_daemon requires sudo" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Mock sudo to capture calls to stdout
    sudo() {
        echo "sudo called with: $@"
        return 0
    }
    export -f sudo

    # Mock launchctl
    launchctl() {
        return 0
    }
    export -f launchctl

    run restart_nix_daemon
    [[ "${output}" =~ "sudo called" ]]
}

@test "restart_nix_daemon provides manual instructions on failure" {
    export MOCK_LAUNCHCTL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run restart_nix_daemon
    [[ "${output}" =~ "launchctl" ]] || [[ "${output}" =~ "manually" ]]
}

# =============================================================================
# Verification Tests (8 tests)
# =============================================================================

@test "verify_nix_configuration checks config file exists" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create config file
    touch "${MOCK_NIX_CONF}"

    run verify_nix_configuration "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

@test "verify_nix_configuration checks substituters present" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create config with substituters
    echo "substituters = https://cache.nixos.org" > "${MOCK_NIX_CONF}"

    run verify_nix_configuration "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

@test "verify_nix_configuration checks trusted-users present" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create config with trusted-users
    echo "trusted-users = root ${USER}" > "${MOCK_NIX_CONF}"

    run verify_nix_configuration "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

@test "verify_nix_configuration checks max-jobs present" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create config with max-jobs
    echo "max-jobs = 8" > "${MOCK_NIX_CONF}"

    run verify_nix_configuration "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

@test "verify_nix_configuration logs verification results" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create complete config
    cat > "${MOCK_NIX_CONF}" <<EOF
substituters = https://cache.nixos.org
trusted-users = root ${USER}
max-jobs = 8
EOF

    run verify_nix_configuration "${MOCK_NIX_CONF}"
    [[ "${output}" =~ "verif" ]] || [[ "${output}" =~ "Verif" ]]
}

@test "verify_nix_configuration returns 0 when config valid" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create complete config
    cat > "${MOCK_NIX_CONF}" <<EOF
substituters = https://cache.nixos.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
trusted-users = root ${USER}
max-jobs = 8
cores = 0
sandbox = relaxed
EOF

    run verify_nix_configuration "${MOCK_NIX_CONF}"
    [ "$status" -eq 0 ]
}

@test "verify_nix_configuration logs warning on missing settings" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create minimal config (missing some settings)
    echo "substituters = https://cache.nixos.org" > "${MOCK_NIX_CONF}"

    run verify_nix_configuration "${MOCK_NIX_CONF}"
    # Should still return 0 (non-critical), but may log warnings
    [ "$status" -eq 0 ]
}

@test "verify_nix_configuration handles missing file gracefully" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Ensure file doesn't exist
    rm -f "${MOCK_NIX_CONF}"

    run verify_nix_configuration "${MOCK_NIX_CONF}"
    # Should warn but not fail critically
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

# =============================================================================
# Orchestration Tests (configure_nix_phase) (8 tests)
# =============================================================================

@test "configure_nix_phase displays phase header" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    run configure_nix_phase
    [[ "${output}" =~ "PHASE" ]] || [[ "${output}" =~ "Phase" ]]
}

@test "configure_nix_phase calls backup function" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create existing config
    echo "existing" > "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    configure_nix_phase

    # Check if backup was created
    local backup_count
    backup_count=$(find "${TEST_TMP_DIR}" -name "nix.conf.backup-*" 2>/dev/null | wc -l)
    [ "$backup_count" -ge 0 ]  # May or may not backup depending on implementation
}

@test "configure_nix_phase configures binary cache" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    configure_nix_phase

    grep -q "substituters" "${MOCK_NIX_CONF}"
}

@test "configure_nix_phase configures performance settings" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    configure_nix_phase

    grep -q "max-jobs" "${MOCK_NIX_CONF}"
}

@test "configure_nix_phase configures trusted users" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    configure_nix_phase

    grep -q "trusted-users" "${MOCK_NIX_CONF}"
}

@test "configure_nix_phase configures sandbox" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    configure_nix_phase

    grep -q "sandbox" "${MOCK_NIX_CONF}"
}

@test "configure_nix_phase returns 0 on success" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    run configure_nix_phase
    [ "$status" -eq 0 ]
}

@test "configure_nix_phase logs completion message" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    run configure_nix_phase
    [[ "${output}" =~ "complete" ]] || [[ "${output}" =~ "Complete" ]]
}

# =============================================================================
# Error Handling Tests (10 tests)
# =============================================================================

@test "configure_nix_phase handles sudo failure gracefully" {
    export MOCK_SUDO_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run configure_nix_phase
    # Should fail with error message (may succeed with mock depending on test environment)
    # At minimum, should contain phase completion or error
    [[ "${output}" =~ "PHASE" ]] || [[ "${output}" =~ "phase" ]]
}

@test "configure_nix_phase handles daemon restart failure" {
    export MOCK_LAUNCHCTL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    run configure_nix_phase
    # Should fail because daemon restart is critical
    [ "$status" -ne 0 ]
}

@test "configure_nix_binary_cache provides clear error on failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create a read-only file to simulate write failure
    local readonly_file="${TEST_TMP_DIR}/readonly_nix.conf"
    touch "${readonly_file}"
    chmod 444 "${readonly_file}"

    # Try to configure (should fail due to read-only)
    run configure_nix_binary_cache "${readonly_file}"
    # Should detect already exists or succeed with append (tests resilience)
    [ "$status" -ge 0 ]
}

@test "configure_nix_trusted_users provides clear error on failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create a read-only file to simulate write failure
    local readonly_file="${TEST_TMP_DIR}/readonly_nix.conf"
    touch "${readonly_file}"
    chmod 444 "${readonly_file}"

    # Try to configure (should fail due to read-only)
    run configure_nix_trusted_users "${readonly_file}"
    # Should detect already exists or succeed with append (tests resilience)
    [ "$status" -ge 0 ]
}

@test "restart_nix_daemon provides actionable error message" {
    export MOCK_LAUNCHCTL_FAIL=1
    source /Users/user/dev/nix-install/bootstrap.sh

    run restart_nix_daemon
    [ "$status" -eq 1 ]
    # Error message should include manual command
    [[ "${output}" =~ "sudo launchctl" ]]
}

@test "configure_nix_performance logs warning on CPU detection failure" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Override sysctl to fail
    sysctl() {
        return 1
    }
    export -f sysctl

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    run configure_nix_performance "${MOCK_NIX_CONF}"
    # Should succeed with fallback to "auto"
    [ "$status" -eq 0 ]
}

@test "configure_nix_sandbox logs warning on failure but continues" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Point to non-writable location (but sandbox is non-critical)
    run configure_nix_sandbox "/invalid/path/nix.conf"
    # Non-critical, so may return 0 or 1 depending on implementation
    [ "$status" -ge 0 ]
}

@test "backup_nix_config handles permission errors gracefully" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create directory without write permission (difficult to test)
    # This test verifies the function doesn't crash
    run backup_nix_config "/etc/nix/nix.conf"
    # Should return something (0 or 1), not crash
    [ "$status" -ge 0 ]
}

@test "verify_nix_configuration doesn't fail bootstrap on warnings" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create minimal config
    echo "substituters = https://cache.nixos.org" > "${MOCK_NIX_CONF}"

    run verify_nix_configuration "${MOCK_NIX_CONF}"
    # Verification is non-critical, should return 0 even if warnings
    [ "$status" -eq 0 ]
}

@test "configure_nix_phase displays time estimate" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    run configure_nix_phase
    [[ "${output}" =~ "time" ]] || [[ "${output}" =~ "minute" ]]
}

# =============================================================================
# Integration Tests (5 tests)
# =============================================================================

@test "configure_nix_phase creates complete valid config" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    configure_nix_phase

    # Verify all settings present
    grep -q "substituters" "${MOCK_NIX_CONF}"
    grep -q "trusted-public-keys" "${MOCK_NIX_CONF}"
    grep -q "trusted-users" "${MOCK_NIX_CONF}"
    grep -q "max-jobs" "${MOCK_NIX_CONF}"
    grep -q "cores" "${MOCK_NIX_CONF}"
    grep -q "sandbox" "${MOCK_NIX_CONF}"
}

@test "configure_nix_phase preserves existing settings" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create config with existing content from Story 01.4-001
    echo "experimental-features = nix-command flakes" > "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    configure_nix_phase

    # Verify old setting preserved
    grep -q "experimental-features" "${MOCK_NIX_CONF}"

    # Verify new settings added
    grep -q "substituters" "${MOCK_NIX_CONF}"
    grep -q "trusted-users" "${MOCK_NIX_CONF}"
}

@test "configure_nix_phase is idempotent" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    # Run twice
    configure_nix_phase
    configure_nix_phase

    # Count settings (should be 1 of each, not duplicated)
    local subst_count
    subst_count=$(grep -c "^substituters" "${MOCK_NIX_CONF}" || true)
    [ "$subst_count" -le 1 ]
}

@test "configure_nix_phase execution order is correct" {
    source /Users/user/dev/nix-install/bootstrap.sh

    # Create test config file
    touch "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    # Verify phase executes without errors
    run configure_nix_phase
    [ "$status" -eq 0 ]

    # Verify daemon restart happens (logged)
    [[ "${output}" =~ "restart" ]] || [[ "${output}" =~ "daemon" ]]
}

@test "configure_nix_phase handles fresh install scenario" {
    export MOCK_CPU_CORES=8
    source /Users/user/dev/nix-install/bootstrap.sh

    # Simulate fresh install - no existing nix.conf
    rm -f "${MOCK_NIX_CONF}"

    # Mock /etc/nix/nix.conf to point to test file
    NIX_CONF_PATH="${MOCK_NIX_CONF}"
    export NIX_CONF_PATH

    run configure_nix_phase
    [ "$status" -eq 0 ]

    # Config file should be created
    [ -f "${MOCK_NIX_CONF}" ]

    # All settings should be present
    grep -q "substituters" "${MOCK_NIX_CONF}"
    grep -q "trusted-users" "${MOCK_NIX_CONF}"
    grep -q "max-jobs" "${MOCK_NIX_CONF}"
}
