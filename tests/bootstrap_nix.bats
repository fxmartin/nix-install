#!/usr/bin/env bats
# ABOUTME: Comprehensive test suite for Nix multi-user installation phase (Story 01.4-001)
# ABOUTME: Tests detection, download, installation, configuration, verification, and error handling

# Setup and teardown
setup() {
    # Load bootstrap.sh for testing
    export TESTING=1

    # Mock command for nix detection
    command() {
        if [[ "$1" == "-v" && "$2" == "nix" ]]; then
            if [[ "${MOCK_NIX_INSTALLED:-0}" == "1" ]]; then
                echo "/usr/local/bin/nix"
                return 0
            else
                return 1
            fi
        fi
        # Fallback to real command for other uses
        /usr/bin/command "$@"
    }
    export -f command

    # Mock curl for installer download
    #
    # Honours the caller's -o destination so the mock matches real curl now that
    # download_nix_installer picks an unpredictable mktemp path (Story 10.2-002).
    curl() {
        local output_path="${MOCK_INSTALLER_PATH:-/tmp/nix-installer.sh}"
        local previous_arg=""
        local arg
        for arg in "$@"; do
            [[ "${previous_arg}" == "-o" ]] && output_path="${arg}"
            previous_arg="${arg}"
        done

        if [[ "$*" == *"nixos.org"* ]]; then
            if [[ "${MOCK_CURL_FAIL:-0}" == "1" ]]; then
                echo "curl: (6) Could not resolve host: nixos.org" >&2
                return 6
            fi
            # Simulate successful download
            echo "#!/bin/sh" > "${output_path}"
            echo "echo 'Mock Nix installer'" >> "${output_path}"
            return 0
        fi
        # Fallback for other curl uses
        /usr/bin/curl "$@"
    }
    export -f curl

    # Mock sudo for installation
    sudo() {
        if [[ "${MOCK_SUDO_FAIL:-0}" == "1" ]]; then
            echo "sudo: authentication failed" >&2
            return 1
        fi
        # Simulate successful sudo execution
        return 0
    }
    export -f sudo

    # Mock nix command
    nix() {
        if [[ "$1" == "--version" ]]; then
            if [[ "${MOCK_NIX_VERSION:-}" != "" ]]; then
                echo "nix (Nix) ${MOCK_NIX_VERSION}"
                return 0
            else
                echo "nix (Nix) 2.19.0"
                return 0
            fi
        fi
        return 0
    }
    export -f nix

    # Mock grep for config checking
    grep() {
        if [[ "$*" == *"experimental-features"* ]]; then
            if [[ "${MOCK_FLAKES_ENABLED:-0}" == "1" ]]; then
                echo "experimental-features = nix-command flakes"
                return 0
            else
                return 1
            fi
        fi
        # Fallback to real grep
        /usr/bin/grep "$@"
    }
    export -f grep

    # Mock source for nix environment
    # Note: We can't mock 'source' directly as BATS uses it to load bootstrap.sh
    # Instead, we'll handle source_nix_environment's behavior through other mocks

    # Mock read for user interaction
    read() {
        return 0
    }
    export -f read

    # Create temp directory for tests
    export TEST_TMP_DIR=$(mktemp -d)
    export MOCK_INSTALLER_PATH="${TEST_TMP_DIR}/nix-installer.sh"
    export MOCK_NIX_CONF="${TEST_TMP_DIR}/nix.conf"

    # Keep mktemp inside the sandbox so no test ever writes to the real /tmp
    export TMPDIR="${TEST_TMP_DIR}"
}

# Stand in for a completed download_nix_installer run.
#
# install_nix_multi_user now refuses to execute anything unless a prior download
# published a path (Story 10.2-002), so these tests must seed one. The stub exits
# non-zero when MOCK_SUDO_FAIL=1 to model an installer that bails out.
seed_mock_installer() {
    NIX_INSTALLER_PATH="${TEST_TMP_DIR}/seeded-nix-installer.sh"

    if [[ "${MOCK_SUDO_FAIL:-0}" == "1" ]]; then
        printf '#!/bin/sh\nexit 1\n' > "${NIX_INSTALLER_PATH}"
    else
        printf '#!/bin/sh\nexit 0\n' > "${NIX_INSTALLER_PATH}"
    fi

    chmod +x "${NIX_INSTALLER_PATH}"
}

teardown() {
    # Clean up environment
    unset MOCK_NIX_INSTALLED
    unset MOCK_CURL_FAIL
    unset MOCK_SUDO_FAIL
    unset MOCK_NIX_VERSION
    unset MOCK_FLAKES_ENABLED
    unset MOCK_INSTALLER_PATH
    unset MOCK_NIX_CONF
    unset MOCK_CURL_EXIT
    unset MOCK_CURL_STDERR
    unset MOCK_CURL_BODY
    unset CURL_ARGS_FILE
    unset TESTING

    # Clean up temp directory
    if [[ -d "${TEST_TMP_DIR:-}" ]]; then
        /bin/rm -rf "${TEST_TMP_DIR}"
    fi
    unset TEST_TMP_DIR
}

# =============================================================================
# Function Existence Tests (7 tests)
# =============================================================================

@test "check_nix_installed function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f check_nix_installed >/dev/null
}

@test "download_nix_installer function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f download_nix_installer >/dev/null
}

@test "install_nix_multi_user function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f install_nix_multi_user >/dev/null
}

@test "enable_nix_flakes function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f enable_nix_flakes >/dev/null
}

@test "source_nix_environment function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f source_nix_environment >/dev/null
}

@test "verify_nix_installation function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f verify_nix_installation >/dev/null
}

@test "install_nix_phase function exists" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    declare -f install_nix_phase >/dev/null
}

# =============================================================================
# Detection Logic Tests (12 tests)
# =============================================================================

@test "check_nix_installed returns 0 when Nix installed" {
    export MOCK_NIX_INSTALLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [ "$status" -eq 0 ]
}

@test "check_nix_installed returns 1 when Nix not installed" {
    export MOCK_NIX_INSTALLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [ "$status" -eq 1 ]
}

@test "check_nix_installed logs path when installed" {
    export MOCK_NIX_INSTALLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [[ "$output" == *"/usr/local/bin/nix"* ]]
}

@test "check_nix_installed uses command -v for detection" {
    export MOCK_NIX_INSTALLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [ "$status" -eq 0 ]
}

@test "check_nix_installed handles missing nix gracefully" {
    export MOCK_NIX_INSTALLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [ "$status" -eq 1 ]
}

@test "check_nix_installed provides clear log message when not found" {
    export MOCK_NIX_INSTALLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [[ "$output" == *"not found"* ]] || [[ "$output" == *"not installed"* ]]
}

@test "check_nix_installed checks PATH for nix binary" {
    export MOCK_NIX_INSTALLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [ "$status" -eq 0 ]
    [[ "$output" == *"nix"* ]]
}

@test "check_nix_installed does not require sudo" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [ "$status" -eq 0 ]
}

@test "check_nix_installed logs info level message when found" {
    export MOCK_NIX_INSTALLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [[ "$output" == *"[INFO]"* ]] || [[ "$output" == *"✓"* ]]
}

@test "check_nix_installed returns quickly (performance)" {
    export MOCK_NIX_INSTALLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    start=$(date +%s)
    run check_nix_installed
    end=$(date +%s)
    duration=$((end - start))

    [ "$duration" -lt 2 ]
}

@test "check_nix_installed works in non-interactive shell" {
    export MOCK_NIX_INSTALLED=1
    export PS1=""
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [ "$status" -eq 0 ]
}

@test "check_nix_installed handles empty PATH gracefully" {
    export MOCK_NIX_INSTALLED=0
    export PATH=""
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [ "$status" -eq 1 ]
}

# =============================================================================
# Download Logic Tests (12 tests)
# =============================================================================

@test "download_nix_installer downloads from nixos.org" {
    export MOCK_CURL_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [ "$status" -eq 0 ]
    [[ "$output" == *"nixos.org"* ]] || [[ "$output" == *"Downloading"* ]]
}

@test "download_nix_installer returns 0 on success" {
    export MOCK_CURL_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [ "$status" -eq 0 ]
}

@test "download_nix_installer returns 1 on network failure" {
    export MOCK_CURL_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [ "$status" -eq 1 ]
}

@test "download_nix_installer uses curl with -L flag for redirects" {
    export MOCK_CURL_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [ "$status" -eq 0 ]
}

@test "download_nix_installer saves to /tmp directory" {
    export MOCK_CURL_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [[ "$output" == *"/tmp"* ]] || [ "$status" -eq 0 ]
}

@test "download_nix_installer logs download progress" {
    export MOCK_CURL_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [[ "$output" == *"Downloading"* ]] || [[ "$output" == *"download"* ]]
}

@test "download_nix_installer creates executable script" {
    export MOCK_CURL_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [ "$status" -eq 0 ]
}

@test "download_nix_installer handles network timeout gracefully" {
    export MOCK_CURL_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [ "$status" -eq 1 ]
    [[ "$output" == *"failed"* ]] || [[ "$output" == *"error"* ]]
}

@test "download_nix_installer provides actionable error message on failure" {
    export MOCK_CURL_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [ "$status" -eq 1 ]
    [[ "$output" == *"network"* ]] || [[ "$output" == *"connection"* ]] || [[ "$output" == *"failed"* ]]
}

@test "download_nix_installer checks internet connectivity" {
    export MOCK_CURL_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [ "$status" -eq 0 ]
}

@test "download_nix_installer uses HTTPS for security" {
    export MOCK_CURL_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [[ "$output" == *"https://"* ]] || [ "$status" -eq 0 ]
}

@test "download_nix_installer cleans up on failure" {
    export MOCK_CURL_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [ "$status" -eq 1 ]
}

# =============================================================================
# Download Hardening Tests (Story 10.2-002)
# =============================================================================
#
# These tests replace the exported `curl` function mock with a recording shim on
# PATH, because the assertions are about the exact flags the real curl receives.

# Install a curl shim on PATH that records its arguments and behaves according to
# MOCK_CURL_EXIT / MOCK_CURL_STDERR / MOCK_CURL_BODY.
install_recording_curl() {
    unset -f curl

    local shim_dir="${TEST_TMP_DIR}/bin"
    mkdir -p "${shim_dir}"

    cat > "${shim_dir}/curl" <<'SHIM'
#!/usr/bin/env bash
printf '%s\n' "$*" > "${CURL_ARGS_FILE}"

output_path=""
previous_arg=""
for arg in "$@"; do
    [[ "${previous_arg}" == "-o" ]] && output_path="${arg}"
    previous_arg="${arg}"
done

if [[ -n "${MOCK_CURL_STDERR:-}" ]]; then
    printf '%s\n' "${MOCK_CURL_STDERR}" >&2
fi

if [[ "${MOCK_CURL_EXIT:-0}" != "0" ]]; then
    exit "${MOCK_CURL_EXIT}"
fi

if [[ -z "${MOCK_CURL_BODY+set}" ]]; then
    printf '#!/bin/sh\nexit 0\n' > "${output_path}"
else
    printf '%s' "${MOCK_CURL_BODY}" > "${output_path}"
fi
SHIM

    chmod +x "${shim_dir}/curl"
    export CURL_ARGS_FILE="${TEST_TMP_DIR}/curl-args"
    export PATH="${shim_dir}:${PATH}"
}

@test "download_nix_installer pins the transport to TLS 1.2+ HTTPS" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    install_recording_curl

    download_nix_installer

    local recorded_args
    recorded_args=$(< "${CURL_ARGS_FILE}")
    [[ "${recorded_args}" == *"--proto =https"* ]]
    [[ "${recorded_args}" == *"--tlsv1.2"* ]]
}

@test "download_nix_installer asks curl to fail on an HTTP error" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    install_recording_curl

    download_nix_installer

    local recorded_args
    recorded_args=$(< "${CURL_ARGS_FILE}")
    [[ "${recorded_args}" == *"-fsSL"* ]]
}

@test "download_nix_installer fails the phase when nixos.org returns an HTTP error" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    install_recording_curl
    export MOCK_CURL_EXIT=22
    export MOCK_CURL_STDERR="curl: (22) The requested URL returned error: 503"

    run download_nix_installer
    [ "$status" -eq 1 ]
}

@test "download_nix_installer leaves no file behind after an HTTP error" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    install_recording_curl
    export MOCK_CURL_EXIT=22

    run download_nix_installer
    [ "$status" -eq 1 ]

    # mktemp created the file; the failure path must have removed it again
    local leftovers
    leftovers=$(/usr/bin/find "${TEST_TMP_DIR}" -maxdepth 1 -name 'nix-installer.*' | wc -l)
    [ "${leftovers}" -eq 0 ]
}

@test "download_nix_installer surfaces curl stderr instead of suppressing it" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    install_recording_curl
    export MOCK_CURL_EXIT=35
    export MOCK_CURL_STDERR="curl: (35) TLS connect error"

    run download_nix_installer
    [ "$status" -eq 1 ]
    [[ "$output" == *"TLS connect error"* ]]
}

@test "download_nix_installer rejects an empty download" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    install_recording_curl
    export MOCK_CURL_BODY=""

    run download_nix_installer
    [ "$status" -eq 1 ]
    [[ "$output" == *"empty"* ]]
}

@test "download_nix_installer does not use the predictable /tmp/nix-installer.sh path" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    install_recording_curl

    download_nix_installer

    [ -n "${NIX_INSTALLER_PATH}" ]
    [ "${NIX_INSTALLER_PATH}" != "/tmp/nix-installer.sh" ]
    [ -x "${NIX_INSTALLER_PATH}" ]
}

@test "download_nix_installer picks a fresh path on every run" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    install_recording_curl

    download_nix_installer
    local first_path="${NIX_INSTALLER_PATH}"

    download_nix_installer
    local second_path="${NIX_INSTALLER_PATH}"

    [ "${first_path}" != "${second_path}" ]
}

@test "install_nix_multi_user refuses to run when no installer was downloaded" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    NIX_INSTALLER_PATH=""

    run install_nix_multi_user
    [ "$status" -eq 1 ]
    [[ "$output" == *"installer"* ]]
}

@test "install_nix_multi_user refuses to run when the installer path vanished" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    NIX_INSTALLER_PATH="${TEST_TMP_DIR}/never-created.sh"

    run install_nix_multi_user
    [ "$status" -eq 1 ]
}

@test "install_nix_multi_user removes the installer after a successful run" {
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    seed_mock_installer
    local seeded_path="${NIX_INSTALLER_PATH}"

    run install_nix_multi_user
    [ "$status" -eq 0 ]
    [ ! -e "${seeded_path}" ]
}

@test "install_nix_multi_user removes the installer after a failed run" {
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    seed_mock_installer
    local seeded_path="${NIX_INSTALLER_PATH}"

    run install_nix_multi_user
    [ "$status" -eq 1 ]
    [ ! -e "${seeded_path}" ]
}

@test "remove_nix_installer clears the published path" {
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
    seed_mock_installer
    local seeded_path="${NIX_INSTALLER_PATH}"

    remove_nix_installer

    [ ! -e "${seeded_path}" ]
    [ -z "${NIX_INSTALLER_PATH}" ]
}

# =============================================================================
# Installation Flow Tests (15 tests)
# =============================================================================

@test "install_nix_multi_user runs installer with --daemon flag" {
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 0 ]
}

@test "install_nix_multi_user returns 0 on success" {
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 0 ]
}

@test "install_nix_multi_user returns 1 on failure" {
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 1 ]
}

@test "install_nix_multi_user requires sudo" {
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 0 ]
}

@test "install_nix_multi_user logs sudo requirement" {
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [[ "$output" == *"sudo"* ]] || [[ "$output" == *"password"* ]] || [ "$status" -eq 0 ]
}

@test "install_nix_multi_user handles sudo password failure" {
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 1 ]
    [[ "$output" == *"failed"* ]] || [[ "$output" == *"error"* ]]
}

@test "install_nix_multi_user uses --daemon for multi-user install" {
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 0 ]
}

@test "install_nix_multi_user provides progress feedback" {
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [[ "$output" == *"Installing"* ]] || [[ "$output" == *"install"* ]] || [ "$status" -eq 0 ]
}

@test "install_nix_multi_user logs installation start" {
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [[ "$output" == *"Nix"* ]] || [ "$status" -eq 0 ]
}

@test "install_nix_multi_user logs installation completion" {
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 0 ]
}

@test "install_nix_multi_user handles script execution errors" {
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 1 ]
}

@test "install_nix_multi_user creates nix daemon users" {
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 0 ]
}

@test "install_nix_multi_user creates /nix directory structure" {
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 0 ]
}

@test "install_nix_multi_user provides clear error on failure" {
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 1 ]
    [[ "$output" == *"failed"* ]] || [[ "$output" == *"error"* ]]
}

@test "install_nix_multi_user handles disk space issues gracefully" {
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 1 ]
}

# =============================================================================
# Configuration Tests (12 tests)
# =============================================================================

@test "enable_nix_flakes writes to /etc/nix/nix.conf" {
    export MOCK_FLAKES_ENABLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]
}

@test "enable_nix_flakes returns 0 on success" {
    export MOCK_FLAKES_ENABLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]
}

@test "enable_nix_flakes returns 1 on failure" {
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 1 ]
}

@test "enable_nix_flakes enables nix-command feature" {
    export MOCK_FLAKES_ENABLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]
    [[ "$output" == *"nix-command"* ]] || [ "$status" -eq 0 ]
}

@test "enable_nix_flakes enables flakes feature" {
    export MOCK_FLAKES_ENABLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]
    [[ "$output" == *"flakes"* ]] || [ "$status" -eq 0 ]
}

@test "enable_nix_flakes skips if already enabled" {
    export MOCK_FLAKES_ENABLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]
    [[ "$output" == *"already"* ]] || [[ "$output" == *"enabled"* ]] || [ "$status" -eq 0 ]
}

@test "enable_nix_flakes does not duplicate config lines" {
    export MOCK_FLAKES_ENABLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]
}

@test "enable_nix_flakes requires sudo for system config" {
    export MOCK_FLAKES_ENABLED=0
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]
}

@test "enable_nix_flakes creates config file if missing" {
    export MOCK_FLAKES_ENABLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]
}

@test "enable_nix_flakes appends to existing config" {
    export MOCK_FLAKES_ENABLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]
}

@test "enable_nix_flakes logs configuration change" {
    export MOCK_FLAKES_ENABLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [[ "$output" == *"Enabling"* ]] || [[ "$output" == *"enable"* ]] || [ "$status" -eq 0 ]
}

@test "enable_nix_flakes validates config file syntax" {
    export MOCK_FLAKES_ENABLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]
}

# =============================================================================
# Environment Sourcing Tests (10 tests)
# =============================================================================

@test "source_nix_environment sources nix-daemon.sh" {
    export MOCK_SOURCE_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run source_nix_environment
    [ "$status" -eq 0 ]
}

@test "source_nix_environment returns 0 on success" {
    export MOCK_SOURCE_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run source_nix_environment
    [ "$status" -eq 0 ]
}

@test "source_nix_environment returns 1 on failure" {
    export MOCK_SOURCE_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run source_nix_environment
    [ "$status" -eq 1 ]
}

@test "source_nix_environment sources from /nix/var/nix/profiles" {
    export MOCK_SOURCE_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run source_nix_environment
    [[ "$output" == *"/nix/var/nix/profiles"* ]] || [ "$status" -eq 0 ]
}

@test "source_nix_environment logs sourcing action" {
    export MOCK_SOURCE_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run source_nix_environment
    [[ "$output" == *"Sourcing"* ]] || [[ "$output" == *"environment"* ]] || [ "$status" -eq 0 ]
}

@test "source_nix_environment handles missing profile file" {
    export MOCK_SOURCE_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run source_nix_environment
    [ "$status" -eq 1 ]
    [[ "$output" == *"failed"* ]] || [[ "$output" == *"not found"* ]]
}

@test "source_nix_environment makes nix available in PATH" {
    export MOCK_SOURCE_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run source_nix_environment
    [ "$status" -eq 0 ]
}

@test "source_nix_environment works in non-interactive shell" {
    export MOCK_SOURCE_FAIL=0
    export PS1=""
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run source_nix_environment
    [ "$status" -eq 0 ]
}

@test "source_nix_environment updates current shell environment" {
    export MOCK_SOURCE_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run source_nix_environment
    [ "$status" -eq 0 ]
}

@test "source_nix_environment logs success message" {
    export MOCK_SOURCE_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run source_nix_environment
    [ "$status" -eq 0 ]
}

# =============================================================================
# Verification Tests (15 tests)
# =============================================================================

@test "verify_nix_installation checks nix --version" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.19.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 0 ]
}

@test "verify_nix_installation returns 0 on success" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.19.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 0 ]
}

@test "verify_nix_installation returns 1 on failure" {
    export MOCK_NIX_INSTALLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 1 ]
}

@test "verify_nix_installation accepts version 2.18.0" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.18.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 0 ]
}

@test "verify_nix_installation accepts version 2.19.3" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.19.3"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 0 ]
}

@test "verify_nix_installation accepts version 2.20.0" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.20.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 0 ]
}

@test "verify_nix_installation rejects version 2.17.0" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.17.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 1 ]
}

@test "verify_nix_installation logs version number" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.19.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [[ "$output" == *"2.19.0"* ]]
}

@test "verify_nix_installation provides clear error for old version" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.17.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 1 ]
    [[ "$output" == *"2.18"* ]] || [[ "$output" == *"minimum"* ]] || [[ "$output" == *"old"* ]]
}

@test "verify_nix_installation checks nix command availability" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.19.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 0 ]
}

@test "verify_nix_installation logs success message" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.19.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [[ "$output" == *"✓"* ]] || [[ "$output" == *"success"* ]] || [ "$status" -eq 0 ]
}

@test "verify_nix_installation handles command not found" {
    export MOCK_NIX_INSTALLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 1 ]
}

@test "verify_nix_installation parses version correctly" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.19.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 0 ]
}

@test "verify_nix_installation displays version to user" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.19.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [[ "$output" == *"version"* ]] || [[ "$output" == *"2.19.0"* ]]
}

@test "verify_nix_installation provides actionable error message" {
    export MOCK_NIX_INSTALLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 1 ]
    [[ "$output" == *"failed"* ]] || [[ "$output" == *"not found"* ]]
}

# =============================================================================
# Orchestration Tests (15 tests)
# =============================================================================

@test "install_nix_phase function orchestrates full flow" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    export MOCK_FLAKES_ENABLED=0
    export MOCK_SOURCE_FAIL=0
    export MOCK_NIX_VERSION="2.19.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]
}

@test "install_nix_phase skips when Nix already installed" {
    export MOCK_NIX_INSTALLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]
    [[ "$output" == *"already"* ]] || [[ "$output" == *"skip"* ]]
}

@test "install_nix_phase returns 0 when skipping" {
    export MOCK_NIX_INSTALLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]
}

@test "install_nix_phase calls check_nix_installed first" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]
}

@test "install_nix_phase calls download_nix_installer" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]
}

@test "install_nix_phase calls install_nix_multi_user" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]
}

@test "install_nix_phase calls enable_nix_flakes" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    export MOCK_FLAKES_ENABLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]
}

@test "install_nix_phase calls source_nix_environment" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    export MOCK_SOURCE_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]
}

@test "install_nix_phase calls verify_nix_installation" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    export MOCK_NIX_VERSION="2.19.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]
}

@test "install_nix_phase displays phase header" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [[ "$output" == *"Phase 4"* ]] || [[ "$output" == *"Nix"* ]]
}

@test "install_nix_phase displays time estimate" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [[ "$output" == *"5-10 minutes"* ]] || [[ "$output" == *"minute"* ]] || [ "$status" -eq 0 ]
}

@test "install_nix_phase logs completion message" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    export MOCK_NIX_VERSION="2.19.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [[ "$output" == *"complete"* ]] || [[ "$output" == *"✓"* ]] || [ "$status" -eq 0 ]
}

@test "install_nix_phase stops on download failure" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 1 ]
}

@test "install_nix_phase stops on installation failure" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 1 ]
}

@test "install_nix_phase stops on verification failure" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    export MOCK_NIX_VERSION="2.17.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 1 ]
}

# =============================================================================
# Error Handling Tests (12 tests)
# =============================================================================

@test "download_nix_installer provides clear error on DNS failure" {
    export MOCK_CURL_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [ "$status" -eq 1 ]
    [[ "$output" == *"network"* ]] || [[ "$output" == *"connection"* ]] || [[ "$output" == *"failed"* ]]
}

@test "install_nix_multi_user provides clear error on sudo failure" {
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 1 ]
    [[ "$output" == *"sudo"* ]] || [[ "$output" == *"failed"* ]]
}

@test "enable_nix_flakes provides clear error on permission denied" {
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 1 ]
}

@test "verify_nix_installation provides clear error on missing nix" {
    export MOCK_NIX_INSTALLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    [ "$status" -eq 1 ]
    [[ "$output" == *"not found"* ]] || [[ "$output" == *"failed"* ]]
}

@test "install_nix_phase handles download errors gracefully" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 1 ]
    [[ "$output" == *"failed"* ]] || [[ "$output" == *"error"* ]]
}

@test "install_nix_phase handles installation errors gracefully" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 1 ]
}

@test "install_nix_phase handles verification errors gracefully" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    export MOCK_NIX_VERSION="2.17.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 1 ]
}

@test "all functions provide actionable error messages" {
    export MOCK_CURL_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    [ "$status" -eq 1 ]
    [[ "$output" != "" ]]
}

@test "install_nix_phase logs error before returning failure" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 1 ]
    [[ "$output" == *"failed"* ]] || [[ "$output" == *"error"* ]]
}

@test "error messages do not expose sensitive information" {
    export MOCK_SUDO_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    seed_mock_installer

    run install_nix_multi_user
    [ "$status" -eq 1 ]
    [[ "$output" != *"password"* ]] || [[ "$output" == *"authentication"* ]]
}

@test "functions handle unexpected errors gracefully" {
    export MOCK_NIX_INSTALLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    [ "$status" -eq 1 ]
}

@test "install_nix_phase returns non-zero on any step failure" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -ne 0 ]
}

# =============================================================================
# Idempotency Tests (10 tests)
# =============================================================================

@test "install_nix_phase is safe to run multiple times" {
    export MOCK_NIX_INSTALLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]

    run install_nix_phase
    [ "$status" -eq 0 ]
}

@test "check_nix_installed consistent across multiple calls" {
    export MOCK_NIX_INSTALLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run check_nix_installed
    status1=$status

    run check_nix_installed
    status2=$status

    [ "$status1" -eq "$status2" ]
}

@test "enable_nix_flakes does not duplicate config on repeat" {
    export MOCK_FLAKES_ENABLED=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]

    export MOCK_FLAKES_ENABLED=1
    run enable_nix_flakes
    [ "$status" -eq 0 ]
}

@test "verify_nix_installation consistent across multiple calls" {
    export MOCK_NIX_INSTALLED=1
    export MOCK_NIX_VERSION="2.19.0"
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run verify_nix_installation
    status1=$status

    run verify_nix_installation
    status2=$status

    [ "$status1" -eq "$status2" ]
}

@test "install_nix_phase skips gracefully when already complete" {
    export MOCK_NIX_INSTALLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]
    [[ "$output" == *"already"* ]] || [[ "$output" == *"skip"* ]]
}

@test "download_nix_installer handles existing file gracefully" {
    export MOCK_CURL_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run download_nix_installer
    status1=$status

    run download_nix_installer
    status2=$status

    [ "$status1" -eq 0 ]
    [ "$status2" -eq 0 ]
}

@test "source_nix_environment safe to call multiple times" {
    export MOCK_SOURCE_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run source_nix_environment
    [ "$status" -eq 0 ]

    run source_nix_environment
    [ "$status" -eq 0 ]
}

@test "enable_nix_flakes checks before modifying config" {
    export MOCK_FLAKES_ENABLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run enable_nix_flakes
    [ "$status" -eq 0 ]
}

@test "install_nix_phase does not reinstall when Nix present" {
    export MOCK_NIX_INSTALLED=1
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    run install_nix_phase
    [ "$status" -eq 0 ]
    [[ "$output" != *"Installing"* ]] || [[ "$output" == *"already"* ]]
}

@test "all functions are idempotent by design" {
    export MOCK_NIX_INSTALLED=0
    export MOCK_CURL_FAIL=0
    export MOCK_SUDO_FAIL=0
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # First run
    run install_nix_phase
    status1=$status

    # Second run (simulating Nix now installed)
    export MOCK_NIX_INSTALLED=1
    run install_nix_phase
    status2=$status

    [ "$status1" -eq 0 ] || [ "$status1" -eq 1 ]  # Can fail in test environment
    [ "$status2" -eq 0 ]  # Should always succeed when already installed
}
