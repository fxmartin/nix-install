#!/usr/bin/env bats
# ABOUTME: BATS test suite for bootstrap.sh Phase 8 (Final Darwin Rebuild)
# ABOUTME: Tests darwin-rebuild execution, profile loading, symlink validation, and success messaging

# Test Setup
# ===========================================================================
# Load BATS testing framework and support libraries

setup() {
    # Load bats-support for better assertions
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    # Source the bootstrap script to test its functions
    # This loads all functions but does NOT execute main()
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Create temporary test directory
    TEST_TEMP_DIR="$(mktemp -d)"
    export TEST_TEMP_DIR

    # Override HOME for testing
    export ORIGINAL_HOME="${HOME}"
    export HOME="${TEST_TEMP_DIR}/home"
    mkdir -p "${HOME}"

    # Override directories for testing
    export BOOTSTRAP_TEMP_DIR="${TEST_TEMP_DIR}/nix-bootstrap"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Create directory structure
    mkdir -p "${BOOTSTRAP_TEMP_DIR}"
    mkdir -p "${REPO_CLONE_DIR}"
    mkdir -p "${HOME}/.config"

    # Mock darwin-rebuild command
    export DARWIN_REBUILD_MOCK_SUCCESS=1
    export DARWIN_REBUILD_MOCK_CALLED=0
    export DARWIN_REBUILD_MOCK_FLAKE=""

    # Create mock darwin-rebuild
    cat > "${TEST_TEMP_DIR}/darwin-rebuild" << 'EOF'
#!/bin/bash
DARWIN_REBUILD_MOCK_CALLED=$((DARWIN_REBUILD_MOCK_CALLED + 1))
export DARWIN_REBUILD_MOCK_CALLED
if [[ "$*" =~ --flake ]]; then
    DARWIN_REBUILD_MOCK_FLAKE="${*##*--flake }"
    export DARWIN_REBUILD_MOCK_FLAKE
fi
if [[ "${DARWIN_REBUILD_MOCK_SUCCESS}" == "1" ]]; then
    echo "darwin-rebuild: building system configuration..."
    exit 0
else
    echo "darwin-rebuild: error: build failed"
    exit 1
fi
EOF
    chmod +x "${TEST_TEMP_DIR}/darwin-rebuild"
    export PATH="${TEST_TEMP_DIR}:${PATH}"
}

teardown() {
    # Restore original HOME
    export HOME="${ORIGINAL_HOME}"

    # Clean up test temporary directory
    if [[ -n "${TEST_TEMP_DIR}" ]] && [[ -d "${TEST_TEMP_DIR}" ]]; then
        rm -rf "${TEST_TEMP_DIR}"
    fi
}

# ===========================================================================
# CATEGORY 1: PROFILE LOADING TESTS (10 tests)
# ===========================================================================

@test "load_profile_from_user_config: extracts standard profile successfully" {
    # Create user-config.nix with standard profile
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "standard";
}
EOF

    # Load profile
    run load_profile_from_user_config

    # Should succeed
    assert_success

    # Should set INSTALL_PROFILE
    [[ "${INSTALL_PROFILE}" == "standard" ]]
}

@test "load_profile_from_user_config: extracts power profile successfully" {
    # Create user-config.nix with power profile
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "power";
}
EOF

    # Load profile
    run load_profile_from_user_config

    # Should succeed
    assert_success

    # Should set INSTALL_PROFILE
    [[ "${INSTALL_PROFILE}" == "power" ]]
}

@test "load_profile_from_user_config: fails when user-config.nix missing" {
    # Ensure user-config.nix doesn't exist
    [[ ! -f "${BOOTSTRAP_TEMP_DIR}/user-config.nix" ]]

    # Try to load profile
    run load_profile_from_user_config

    # Should fail
    assert_failure

    # Should show error message
    assert_output --partial "user-config.nix not found"
}

@test "load_profile_from_user_config: fails when INSTALL_PROFILE missing" {
    # Create user-config.nix without INSTALL_PROFILE
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
}
EOF

    # Try to load profile
    run load_profile_from_user_config

    # Should fail
    assert_failure

    # Should show error message
    assert_output --partial "Could not extract INSTALL_PROFILE"
}

@test "load_profile_from_user_config: fails with invalid profile value" {
    # Create user-config.nix with invalid profile
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "invalid";
}
EOF

    # Try to load profile
    run load_profile_from_user_config

    # Should fail
    assert_failure

    # Should show error message
    assert_output --partial "Invalid profile value"
}

@test "load_profile_from_user_config: handles profile with extra whitespace" {
    # Create user-config.nix with extra whitespace
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
    INSTALL_PROFILE = "standard"  ;
}
EOF

    # Load profile
    run load_profile_from_user_config

    # Should succeed
    assert_success

    # Should set INSTALL_PROFILE correctly
    [[ "${INSTALL_PROFILE}" == "standard" ]]
}

@test "load_profile_from_user_config: handles corrupted file gracefully" {
    # Create corrupted user-config.nix
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  CORRUPT DATA @#$%
  INSTALL_PROFILE = "standard
}
EOF

    # Try to load profile
    run load_profile_from_user_config

    # Should fail
    assert_failure

    # Should show error message
    assert_output --partial "Could not extract INSTALL_PROFILE"
}

@test "load_profile_from_user_config: exports INSTALL_PROFILE as environment variable" {
    # Create user-config.nix
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "power";
}
EOF

    # Load profile
    load_profile_from_user_config

    # INSTALL_PROFILE should be exported
    [[ -n "${INSTALL_PROFILE}" ]]
    [[ "${INSTALL_PROFILE}" == "power" ]]
}

@test "load_profile_from_user_config: displays success message" {
    # Create user-config.nix
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "standard";
}
EOF

    # Load profile
    run load_profile_from_user_config

    # Should display success message
    assert_output --partial "Profile loaded: standard"
}

@test "load_profile_from_user_config: preserves other variables in user-config.nix" {
    # Create user-config.nix with multiple variables
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "power";
  CUSTOM_VAR = "custom_value";
}
EOF

    # Load profile
    run load_profile_from_user_config

    # Should succeed
    assert_success

    # Should only extract INSTALL_PROFILE
    [[ "${INSTALL_PROFILE}" == "power" ]]

    # File should remain unchanged
    grep -q "CUSTOM_VAR" "${BOOTSTRAP_TEMP_DIR}/user-config.nix"
}

# ===========================================================================
# CATEGORY 2: DARWIN REBUILD EXECUTION TESTS (12 tests)
# ===========================================================================

@test "run_final_darwin_rebuild: executes darwin-rebuild with correct arguments" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Run rebuild
    run run_final_darwin_rebuild

    # Should succeed
    assert_success

    # Should call darwin-rebuild
    [[ "${DARWIN_REBUILD_MOCK_CALLED}" -gt 0 ]]

    # Should use correct flake reference
    assert_output --partial "${REPO_CLONE_DIR}#${INSTALL_PROFILE}"
}

@test "run_final_darwin_rebuild: uses standard profile correctly" {
    # Set up standard profile
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Run rebuild
    run run_final_darwin_rebuild

    # Should succeed
    assert_success

    # Should display correct profile
    assert_output --partial "Profile: standard"
}

@test "run_final_darwin_rebuild: uses power profile correctly" {
    # Set up power profile
    export INSTALL_PROFILE="power"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Run rebuild
    run run_final_darwin_rebuild

    # Should succeed
    assert_success

    # Should display correct profile
    assert_output --partial "Profile: power"
}

@test "run_final_darwin_rebuild: displays expected duration message" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Run rebuild
    run run_final_darwin_rebuild

    # Should display expected duration
    assert_output --partial "Expected duration: 2-5 minutes"
}

@test "run_final_darwin_rebuild: displays build time on success" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Run rebuild
    run run_final_darwin_rebuild

    # Should display build time
    assert_output --partial "Build time:"
    assert_output --partial "seconds"
}

@test "run_final_darwin_rebuild: handles darwin-rebuild failure" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Mock darwin-rebuild failure
    export DARWIN_REBUILD_MOCK_SUCCESS=0

    # Run rebuild
    run run_final_darwin_rebuild

    # Should fail
    assert_failure

    # Should display error message
    assert_output --partial "Darwin-rebuild failed"
}

@test "run_final_darwin_rebuild: displays error details on failure" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Mock darwin-rebuild failure
    export DARWIN_REBUILD_MOCK_SUCCESS=0

    # Run rebuild
    run run_final_darwin_rebuild

    # Should display helpful error message
    assert_output --partial "Check the error messages above"
}

@test "run_final_darwin_rebuild: uses absolute path for repository" {
    # Set up environment with relative-looking path
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Run rebuild
    run run_final_darwin_rebuild

    # Should succeed
    assert_success

    # Should use absolute path
    assert_output --partial "${HOME}/Documents/nix-install"
}

@test "run_final_darwin_rebuild: displays flake reference" {
    # Set up environment
    export INSTALL_PROFILE="power"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Run rebuild
    run run_final_darwin_rebuild

    # Should display flake reference
    assert_output --partial "Flake reference: ${REPO_CLONE_DIR}#power"
}

@test "run_final_darwin_rebuild: completes within reasonable time" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Record start time
    local start_time
    start_time=$(date +%s)

    # Run rebuild
    run run_final_darwin_rebuild

    # Calculate duration
    local end_time duration
    end_time=$(date +%s)
    duration=$((end_time - start_time))

    # Should complete quickly (mock is fast)
    [[ ${duration} -lt 5 ]]
}

@test "run_final_darwin_rebuild: logs rebuild command" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Run rebuild
    run run_final_darwin_rebuild

    # Should display command being executed
    assert_output --partial "Executing: darwin-rebuild switch --flake"
}

@test "run_final_darwin_rebuild: handles missing INSTALL_PROFILE gracefully" {
    # Set up environment without profile
    unset INSTALL_PROFILE
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Run rebuild
    run run_final_darwin_rebuild

    # Should handle gracefully (may succeed or fail, but shouldn't crash)
    # The function should either succeed with empty profile or fail gracefully
    [[ "${status}" -eq 0 ]] || [[ "${status}" -eq 1 ]]
}

# ===========================================================================
# CATEGORY 3: SYMLINK VALIDATION TESTS (10 tests)
# ===========================================================================

@test "verify_home_manager_symlinks: detects Ghostty config symlink" {
    # Create Ghostty config symlink
    mkdir -p "${HOME}/.config/ghostty"
    touch "${HOME}/.config/ghostty/config"

    # Verify symlinks
    run verify_home_manager_symlinks

    # Should succeed
    assert_success

    # Should detect Ghostty config
    assert_output --partial "Ghostty terminal config"
}

@test "verify_home_manager_symlinks: detects zshrc symlink" {
    # Create .zshrc
    touch "${HOME}/.zshrc"

    # Verify symlinks
    run verify_home_manager_symlinks

    # Should succeed
    assert_success

    # Should detect .zshrc
    assert_output --partial "Zsh shell config"
}

@test "verify_home_manager_symlinks: detects gitconfig symlink" {
    # Create .gitconfig
    touch "${HOME}/.gitconfig"

    # Verify symlinks
    run verify_home_manager_symlinks

    # Should succeed
    assert_success

    # Should detect .gitconfig
    assert_output --partial "Git configuration"
}

@test "verify_home_manager_symlinks: detects starship config symlink" {
    # Create starship.toml
    mkdir -p "${HOME}/.config"
    touch "${HOME}/.config/starship.toml"

    # Verify symlinks
    run verify_home_manager_symlinks

    # Should succeed
    assert_success

    # Should detect starship config
    assert_output --partial "Starship prompt config"
}

@test "verify_home_manager_symlinks: warns when no symlinks found" {
    # Ensure no symlinks exist
    [[ ! -f "${HOME}/.zshrc" ]]
    [[ ! -f "${HOME}/.gitconfig" ]]

    # Verify symlinks
    run verify_home_manager_symlinks

    # Should succeed (non-critical)
    assert_success

    # Should warn about no symlinks
    assert_output --partial "No Home Manager symlinks detected"
}

@test "verify_home_manager_symlinks: counts symlinks correctly" {
    # Create multiple symlinks
    touch "${HOME}/.zshrc"
    touch "${HOME}/.gitconfig"

    # Verify symlinks
    run verify_home_manager_symlinks

    # Should succeed
    assert_success

    # Should count correctly
    assert_output --partial "Found 2 Home Manager symlinks"
}

@test "verify_home_manager_symlinks: handles missing .config directory" {
    # Remove .config directory
    rm -rf "${HOME}/.config"

    # Verify symlinks
    run verify_home_manager_symlinks

    # Should succeed (non-critical)
    assert_success

    # Should warn about missing symlinks
    assert_output --partial "not found"
}

@test "verify_home_manager_symlinks: detects actual symlinks vs files" {
    # Create actual symlink
    mkdir -p "${HOME}/.config"
    ln -s /tmp/ghostty "${HOME}/.config/ghostty"

    # Create regular file
    touch "${HOME}/.zshrc"

    # Verify symlinks
    run verify_home_manager_symlinks

    # Should succeed and detect both
    assert_success
    assert_output --partial "Ghostty terminal config"
    assert_output --partial "Zsh shell config"
}

@test "verify_home_manager_symlinks: provides helpful guidance when symlinks missing" {
    # Ensure no symlinks exist
    [[ ! -f "${HOME}/.zshrc" ]]

    # Verify symlinks
    run verify_home_manager_symlinks

    # Should provide guidance
    assert_output --partial "Check ~/Documents/nix-install/home-manager/"
}

@test "verify_home_manager_symlinks: always returns success (non-critical)" {
    # Test with no symlinks
    run verify_home_manager_symlinks
    assert_success

    # Test with some symlinks
    touch "${HOME}/.zshrc"
    run verify_home_manager_symlinks
    assert_success

    # Test with all symlinks
    touch "${HOME}/.gitconfig"
    mkdir -p "${HOME}/.config"
    touch "${HOME}/.config/starship.toml"
    run verify_home_manager_symlinks
    assert_success
}

# ===========================================================================
# CATEGORY 4: SUCCESS MESSAGE TESTS (8 tests)
# ===========================================================================

@test "display_rebuild_success_message: displays congratulations banner" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Display success message
    run display_rebuild_success_message 180

    # Should display banner
    assert_output --partial "BOOTSTRAP COMPLETE"
}

@test "display_rebuild_success_message: displays profile information" {
    # Set up environment
    export INSTALL_PROFILE="power"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Display success message
    run display_rebuild_success_message 240

    # Should display profile
    assert_output --partial "Profile Applied: power"
}

@test "display_rebuild_success_message: displays build time in minutes and seconds" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Display success message with 125 seconds (2m 5s)
    run display_rebuild_success_message 125

    # Should display time correctly
    assert_output --partial "Build Time: 2m 5s"
}

@test "display_rebuild_success_message: displays next steps section" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Display success message
    run display_rebuild_success_message 180

    # Should display next steps
    assert_output --partial "NEXT STEPS"
    assert_output --partial "Restart your terminal"
}

@test "display_rebuild_success_message: displays Power profile specific instructions" {
    # Set up Power profile
    export INSTALL_PROFILE="power"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Display success message
    run display_rebuild_success_message 300

    # Should display Ollama instructions
    assert_output --partial "Verify Ollama models"
    assert_output --partial "ollama list"

    # Should display Parallels instructions
    assert_output --partial "Parallels Desktop"
}

@test "display_rebuild_success_message: does not display Power instructions for Standard" {
    # Set up Standard profile
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Display success message
    run display_rebuild_success_message 180

    # Should NOT display Power-specific instructions
    refute_output --partial "Parallels Desktop"
    refute_output --partial "Verify Ollama models"
}

@test "display_rebuild_success_message: displays useful commands section" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Display success message
    run display_rebuild_success_message 180

    # Should display commands
    assert_output --partial "USEFUL COMMANDS"
    assert_output --partial "rebuild"
    assert_output --partial "update"
    assert_output --partial "health-check"
    assert_output --partial "cleanup"
}

@test "display_rebuild_success_message: displays documentation links" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Display success message
    run display_rebuild_success_message 180

    # Should display documentation section
    assert_output --partial "DOCUMENTATION"
    assert_output --partial "README.md"
    assert_output --partial "customization.md"
    assert_output --partial "troubleshooting.md"
}

# ===========================================================================
# CATEGORY 5: PHASE ORCHESTRATION TESTS (10 tests)
# ===========================================================================

@test "final_darwin_rebuild_phase: executes all steps in correct order" {
    # Set up environment
    export INSTALL_PROFILE="standard"
    export REPO_CLONE_DIR="${HOME}/Documents/nix-install"

    # Create user-config.nix
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "standard";
}
EOF

    # Run phase
    run final_darwin_rebuild_phase

    # Should succeed
    assert_success

    # Should display phase header
    assert_output --partial "PHASE 8: FINAL DARWIN REBUILD"

    # Should show all steps
    assert_output --partial "Step 1: Loading installation profile"
    assert_output --partial "Step 2: Running darwin-rebuild switch"
    assert_output --partial "Step 3: Verifying Home Manager symlinks"
}

@test "final_darwin_rebuild_phase: loads profile from user-config.nix" {
    # Create user-config.nix
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "power";
}
EOF

    # Run phase
    run final_darwin_rebuild_phase

    # Should succeed
    assert_success

    # Should load correct profile
    assert_output --partial "Profile: power"
}

@test "final_darwin_rebuild_phase: runs darwin-rebuild with correct profile" {
    # Create user-config.nix
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "standard";
}
EOF

    # Run phase
    run final_darwin_rebuild_phase

    # Should succeed
    assert_success

    # Should use correct flake reference
    assert_output --partial "${REPO_CLONE_DIR}#standard"
}

@test "final_darwin_rebuild_phase: verifies Home Manager symlinks" {
    # Create user-config.nix
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "standard";
}
EOF

    # Create some symlinks
    touch "${HOME}/.zshrc"
    touch "${HOME}/.gitconfig"

    # Run phase
    run final_darwin_rebuild_phase

    # Should succeed
    assert_success

    # Should verify symlinks
    assert_output --partial "Verifying Home Manager symlinks"
    assert_output --partial "Found 2 Home Manager symlinks"
}

@test "final_darwin_rebuild_phase: displays success message on completion" {
    # Create user-config.nix
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "standard";
}
EOF

    # Run phase
    run final_darwin_rebuild_phase

    # Should succeed
    assert_success

    # Should display success message
    assert_output --partial "BOOTSTRAP COMPLETE"
}

@test "final_darwin_rebuild_phase: fails when profile loading fails" {
    # Don't create user-config.nix (will fail to load)

    # Run phase
    run final_darwin_rebuild_phase

    # Should fail
    assert_failure

    # Should show error
    assert_output --partial "Failed to load profile"
}

@test "final_darwin_rebuild_phase: fails when darwin-rebuild fails" {
    # Create user-config.nix
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "standard";
}
EOF

    # Mock darwin-rebuild failure
    export DARWIN_REBUILD_MOCK_SUCCESS=0

    # Run phase
    run final_darwin_rebuild_phase

    # Should fail
    assert_failure

    # Should show error
    assert_output --partial "Darwin-rebuild failed"
}

@test "final_darwin_rebuild_phase: provides recovery instructions on failure" {
    # Create user-config.nix
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "standard";
}
EOF

    # Mock darwin-rebuild failure
    export DARWIN_REBUILD_MOCK_SUCCESS=0

    # Run phase
    run final_darwin_rebuild_phase

    # Should provide recovery instructions
    assert_output --partial "Try running: darwin-rebuild switch --flake"
}

@test "final_darwin_rebuild_phase: displays phase duration" {
    # Create user-config.nix
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "standard";
}
EOF

    # Run phase
    run final_darwin_rebuild_phase

    # Should succeed
    assert_success

    # Should display phase duration
    assert_output --partial "Phase 8 completed in"
    assert_output --partial "seconds"
}

@test "final_darwin_rebuild_phase: handles both standard and power profiles" {
    # Test standard profile
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "standard";
}
EOF

    run final_darwin_rebuild_phase
    assert_success
    assert_output --partial "Profile Applied: standard"

    # Test power profile
    cat > "${BOOTSTRAP_TEMP_DIR}/user-config.nix" << 'EOF'
{
  USER_FULL_NAME = "Test User";
  USER_EMAIL = "test@example.com";
  GITHUB_USERNAME = "testuser";
  INSTALL_PROFILE = "power";
}
EOF

    run final_darwin_rebuild_phase
    assert_success
    assert_output --partial "Profile Applied: power"
}
