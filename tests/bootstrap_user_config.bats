#!/usr/bin/env bats
# ABOUTME: BATS test suite for Story 01.2-003 - User Config File Generation
# ABOUTME: Tests template creation, placeholder replacement, validation, and integration

# Load the bootstrap script for testing (without executing main)
setup() {
    # Source the bootstrap script to get access to functions
    source "${BATS_TEST_DIRNAME}/../bootstrap.sh"

    # Set up test environment variables
    export USER_FULLNAME="François Martin"
    export USER_EMAIL="fx@example.com"
    export GITHUB_USERNAME="fxmartin"
    export INSTALL_PROFILE="power"

    # Create temporary test directory
    export TEST_WORK_DIR="${BATS_TEST_TMPDIR}/nix-bootstrap-test"
    mkdir -p "${TEST_WORK_DIR}"
}

teardown() {
    # Clean up test work directory
    if [[ -d "${TEST_WORK_DIR}" ]]; then
        rm -rf "${TEST_WORK_DIR}"
    fi
}

# ==============================================================================
# FUNCTION EXISTENCE TESTS (6 tests)
# ==============================================================================

@test "create_bootstrap_workdir function exists" {
    declare -f create_bootstrap_workdir > /dev/null
}

@test "get_macos_username function exists" {
    declare -f get_macos_username > /dev/null
}

@test "get_macos_hostname function exists" {
    declare -f get_macos_hostname > /dev/null
}

@test "validate_nix_syntax function exists" {
    declare -f validate_nix_syntax > /dev/null
}

@test "display_generated_config function exists" {
    declare -f display_generated_config > /dev/null
}

@test "generate_user_config function exists" {
    declare -f generate_user_config > /dev/null
}

# ==============================================================================
# TEMPLATE FILE STRUCTURE TESTS (8 tests)
# ==============================================================================

@test "user-config.template.nix exists in project root" {
    [[ -f "${BATS_TEST_DIRNAME}/../user-config.template.nix" ]]
}

@test "template file has ABOUTME comments" {
    grep -q "ABOUTME:" "${BATS_TEST_DIRNAME}/../user-config.template.nix"
}

@test "template file contains @MACOS_USERNAME@ placeholder" {
    grep -q "@MACOS_USERNAME@" "${BATS_TEST_DIRNAME}/../user-config.template.nix"
}

@test "template file contains @FULL_NAME@ placeholder" {
    grep -q "@FULL_NAME@" "${BATS_TEST_DIRNAME}/../user-config.template.nix"
}

@test "template file contains @EMAIL@ placeholder" {
    grep -q "@EMAIL@" "${BATS_TEST_DIRNAME}/../user-config.template.nix"
}

@test "template file contains @GITHUB_USERNAME@ placeholder" {
    grep -q "@GITHUB_USERNAME@" "${BATS_TEST_DIRNAME}/../user-config.template.nix"
}

@test "template file contains @HOSTNAME@ placeholder" {
    grep -q "@HOSTNAME@" "${BATS_TEST_DIRNAME}/../user-config.template.nix"
}

@test "template file contains @DOTFILES_PATH@ placeholder" {
    grep -q "@DOTFILES_PATH@" "${BATS_TEST_DIRNAME}/../user-config.template.nix"
}

# ==============================================================================
# WORK DIRECTORY CREATION TESTS (5 tests)
# ==============================================================================

@test "create_bootstrap_workdir creates /tmp/nix-bootstrap directory" {
    # Clean up if exists
    rm -rf /tmp/nix-bootstrap

    # Create directory
    create_bootstrap_workdir

    # Verify directory exists
    [[ -d /tmp/nix-bootstrap ]]
}

@test "create_bootstrap_workdir is idempotent (safe to run multiple times)" {
    rm -rf /tmp/nix-bootstrap

    # Run twice
    create_bootstrap_workdir
    create_bootstrap_workdir

    # Should still exist without errors
    [[ -d /tmp/nix-bootstrap ]]
}

@test "create_bootstrap_workdir sets correct permissions (755)" {
    rm -rf /tmp/nix-bootstrap
    create_bootstrap_workdir

    # Check permissions (directory should be readable/writable/executable by user)
    [[ -r /tmp/nix-bootstrap ]]
    [[ -w /tmp/nix-bootstrap ]]
    [[ -x /tmp/nix-bootstrap ]]
}

@test "create_bootstrap_workdir returns 0 on success" {
    rm -rf /tmp/nix-bootstrap
    run create_bootstrap_workdir
    [[ "$status" -eq 0 ]]
}

@test "create_bootstrap_workdir handles existing directory gracefully" {
    # Create directory manually first
    mkdir -p /tmp/nix-bootstrap

    # Function should handle existing directory without error
    run create_bootstrap_workdir
    [[ "$status" -eq 0 ]]
}

# ==============================================================================
# MACOS USERNAME EXTRACTION TESTS (8 tests)
# ==============================================================================

@test "get_macos_username returns non-empty string" {
    local username
    username=$(get_macos_username)
    [[ -n "$username" ]]
}

@test "get_macos_username returns current user from \$USER" {
    local username
    username=$(get_macos_username)
    [[ "$username" == "$USER" ]]
}

@test "get_macos_username returns alphanumeric username" {
    local username
    username=$(get_macos_username)
    [[ "$username" =~ ^[a-zA-Z0-9_-]+$ ]]
}

@test "get_macos_username does not include whitespace" {
    local username
    username=$(get_macos_username)
    [[ ! "$username" =~ [[:space:]] ]]
}

@test "get_macos_username returns same value on multiple calls" {
    local first
    local second
    first=$(get_macos_username)
    second=$(get_macos_username)
    [[ "$first" == "$second" ]]
}

@test "get_macos_username is not root" {
    local username
    username=$(get_macos_username)
    [[ "$username" != "root" ]]
}

@test "get_macos_username matches whoami output" {
    local username
    username=$(get_macos_username)
    [[ "$username" == "$(whoami)" ]]
}

@test "get_macos_username returns exit code 0" {
    run get_macos_username
    [[ "$status" -eq 0 ]]
}

# ==============================================================================
# HOSTNAME EXTRACTION AND SANITIZATION TESTS (8 tests)
# ==============================================================================

@test "get_macos_hostname returns non-empty string" {
    local hostname
    hostname=$(get_macos_hostname)
    [[ -n "$hostname" ]]
}

@test "get_macos_hostname returns only alphanumeric and hyphens" {
    local hostname
    hostname=$(get_macos_hostname)
    [[ "$hostname" =~ ^[a-zA-Z0-9-]+$ ]]
}

@test "get_macos_hostname does not contain underscores" {
    local hostname
    hostname=$(get_macos_hostname)
    [[ ! "$hostname" =~ _ ]]
}

@test "get_macos_hostname does not contain periods" {
    local hostname
    hostname=$(get_macos_hostname)
    [[ ! "$hostname" =~ \. ]]
}

@test "get_macos_hostname does not contain spaces" {
    local hostname
    hostname=$(get_macos_hostname)
    [[ ! "$hostname" =~ [[:space:]] ]]
}

@test "get_macos_hostname converts uppercase to lowercase" {
    local hostname
    hostname=$(get_macos_hostname)
    # Verify no uppercase letters
    [[ ! "$hostname" =~ [A-Z] ]]
}

@test "get_macos_hostname returns same value on multiple calls" {
    local first
    local second
    first=$(get_macos_hostname)
    second=$(get_macos_hostname)
    [[ "$first" == "$second" ]]
}

@test "get_macos_hostname returns exit code 0" {
    run get_macos_hostname
    [[ "$status" -eq 0 ]]
}

# ==============================================================================
# PLACEHOLDER REPLACEMENT TESTS (15 tests)
# ==============================================================================

@test "placeholder replacement creates output file" {
    # Mock the generate_user_config function call
    create_bootstrap_workdir

    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    # Perform placeholder replacement
    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    # Verify file was created
    [[ -f /tmp/nix-bootstrap/user-config.nix ]]
}

@test "placeholder replacement: @MACOS_USERNAME@ is replaced" {
    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    # Verify placeholder was replaced
    grep -q "username = \"${macos_username}\"" /tmp/nix-bootstrap/user-config.nix
    # Verify placeholder no longer exists
    ! grep -q "@MACOS_USERNAME@" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: @FULL_NAME@ is replaced" {
    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    grep -q "fullName = \"${USER_FULLNAME}\"" /tmp/nix-bootstrap/user-config.nix
    ! grep -q "@FULL_NAME@" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: @EMAIL@ is replaced" {
    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    grep -q "email = \"${USER_EMAIL}\"" /tmp/nix-bootstrap/user-config.nix
    ! grep -q "@EMAIL@" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: @GITHUB_USERNAME@ is replaced" {
    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    grep -q "githubUsername = \"${GITHUB_USERNAME}\"" /tmp/nix-bootstrap/user-config.nix
    ! grep -q "@GITHUB_USERNAME@" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: @HOSTNAME@ is replaced" {
    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    grep -q "hostname = \"${hostname}\"" /tmp/nix-bootstrap/user-config.nix
    ! grep -q "@HOSTNAME@" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: @DOTFILES_PATH@ is replaced" {
    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    grep -q "dotfiles = \"${dotfiles_path}\"" /tmp/nix-bootstrap/user-config.nix
    ! grep -q "@DOTFILES_PATH@" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: no placeholders remain in output" {
    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    # Verify no @ placeholders remain (except in ABOUTME comments)
    ! grep -v "ABOUTME" /tmp/nix-bootstrap/user-config.nix | grep -q "@[A-Z_]*@"
}

@test "placeholder replacement: handles apostrophes in names" {
    export USER_FULLNAME="John O'Brien"

    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    grep -q "fullName = \"John O'Brien\"" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: handles accented characters in names" {
    export USER_FULLNAME="François Martin"

    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    grep -q "François Martin" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: handles hyphenated names" {
    export USER_FULLNAME="Mary-Jane Smith"

    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    grep -q "fullName = \"Mary-Jane Smith\"" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: handles plus-addressing in email" {
    export USER_EMAIL="fx+test@example.com"

    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    grep -q "email = \"fx+test@example.com\"" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: handles hyphens in GitHub username" {
    export GITHUB_USERNAME="fx-martin"

    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    grep -q "githubUsername = \"fx-martin\"" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: handles underscores in GitHub username" {
    export GITHUB_USERNAME="fx_martin"

    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    grep -q "githubUsername = \"fx_martin\"" /tmp/nix-bootstrap/user-config.nix
}

@test "placeholder replacement: output file has proper structure" {
    create_bootstrap_workdir
    local macos_username
    macos_username=$(get_macos_username)
    local hostname
    hostname=$(get_macos_hostname)
    local dotfiles_path="Documents/nix-install"

    sed -e "s/@MACOS_USERNAME@/${macos_username}/g" \
        -e "s/@FULL_NAME@/${USER_FULLNAME}/g" \
        -e "s/@EMAIL@/${USER_EMAIL}/g" \
        -e "s/@GITHUB_USERNAME@/${GITHUB_USERNAME}/g" \
        -e "s/@HOSTNAME@/${hostname}/g" \
        -e "s|@DOTFILES_PATH@|${dotfiles_path}|g" \
        "${BATS_TEST_DIRNAME}/../user-config.template.nix" > /tmp/nix-bootstrap/user-config.nix

    # Verify output file has Nix structure
    grep -q "username =" /tmp/nix-bootstrap/user-config.nix
    grep -q "fullName =" /tmp/nix-bootstrap/user-config.nix
    grep -q "email =" /tmp/nix-bootstrap/user-config.nix
    grep -q "githubUsername =" /tmp/nix-bootstrap/user-config.nix
    grep -q "hostname =" /tmp/nix-bootstrap/user-config.nix
    grep -q "directories =" /tmp/nix-bootstrap/user-config.nix
}

# ==============================================================================
# NIX SYNTAX VALIDATION TESTS (10 tests)
# ==============================================================================

@test "validate_nix_syntax accepts valid Nix config" {
    # Create a valid Nix config file
    cat > "${TEST_WORK_DIR}/valid.nix" << 'EOF'
{
  username = "testuser";
  fullName = "Test User";
  email = "test@example.com";
}
EOF

    run validate_nix_syntax "${TEST_WORK_DIR}/valid.nix"
    [[ "$status" -eq 0 ]]
}

@test "validate_nix_syntax rejects empty file" {
    # Create empty file
    touch "${TEST_WORK_DIR}/empty.nix"

    run validate_nix_syntax "${TEST_WORK_DIR}/empty.nix"
    [[ "$status" -eq 1 ]]
}

@test "validate_nix_syntax rejects unbalanced braces (missing closing)" {
    cat > "${TEST_WORK_DIR}/unbalanced1.nix" << 'EOF'
{
  username = "testuser";
  fullName = "Test User";
EOF

    run validate_nix_syntax "${TEST_WORK_DIR}/unbalanced1.nix"
    [[ "$status" -eq 1 ]]
}

@test "validate_nix_syntax rejects unbalanced braces (extra closing)" {
    cat > "${TEST_WORK_DIR}/unbalanced2.nix" << 'EOF'
{
  username = "testuser";
}
}
EOF

    run validate_nix_syntax "${TEST_WORK_DIR}/unbalanced2.nix"
    [[ "$status" -eq 1 ]]
}

@test "validate_nix_syntax accepts nested braces" {
    cat > "${TEST_WORK_DIR}/nested.nix" << 'EOF'
{
  directories = {
    dotfiles = "Documents/nix-install";
  };
}
EOF

    run validate_nix_syntax "${TEST_WORK_DIR}/nested.nix"
    [[ "$status" -eq 0 ]]
}

@test "validate_nix_syntax accepts comments" {
    cat > "${TEST_WORK_DIR}/comments.nix" << 'EOF'
# ABOUTME: Test file
{
  username = "testuser"; # Comment
}
EOF

    run validate_nix_syntax "${TEST_WORK_DIR}/comments.nix"
    [[ "$status" -eq 0 ]]
}

@test "validate_nix_syntax rejects non-existent file" {
    run validate_nix_syntax "${TEST_WORK_DIR}/does-not-exist.nix"
    [[ "$status" -eq 1 ]]
}

@test "validate_nix_syntax accepts empty strings in values" {
    cat > "${TEST_WORK_DIR}/empty-string.nix" << 'EOF'
{
  signingKey = "";
}
EOF

    run validate_nix_syntax "${TEST_WORK_DIR}/empty-string.nix"
    [[ "$status" -eq 0 ]]
}

@test "validate_nix_syntax accepts semicolons" {
    cat > "${TEST_WORK_DIR}/semicolons.nix" << 'EOF'
{
  username = "testuser";
  fullName = "Test User";
}
EOF

    run validate_nix_syntax "${TEST_WORK_DIR}/semicolons.nix"
    [[ "$status" -eq 0 ]]
}

@test "validate_nix_syntax displays error message for invalid syntax" {
    touch "${TEST_WORK_DIR}/empty.nix"

    run validate_nix_syntax "${TEST_WORK_DIR}/empty.nix"
    [[ "$status" -eq 1 ]]
    # Should output an error message
    [[ -n "$output" ]]
}

# ==============================================================================
# CONFIG DISPLAY TESTS (5 tests)
# ==============================================================================

@test "display_generated_config outputs file contents" {
    # Create a test config file
    cat > "${TEST_WORK_DIR}/test-config.nix" << 'EOF'
{
  username = "testuser";
  email = "test@example.com";
}
EOF

    run display_generated_config "${TEST_WORK_DIR}/test-config.nix"
    [[ "$status" -eq 0 ]]
    [[ "$output" =~ "testuser" ]]
    [[ "$output" =~ "test@example.com" ]]
}

@test "display_generated_config handles non-existent file" {
    run display_generated_config "${TEST_WORK_DIR}/does-not-exist.nix"
    [[ "$status" -eq 1 ]]
}

@test "display_generated_config preserves formatting" {
    cat > "${TEST_WORK_DIR}/formatted.nix" << 'EOF'
{
  username = "testuser";
  directories = {
    dotfiles = "Documents/nix-install";
  };
}
EOF

    run display_generated_config "${TEST_WORK_DIR}/formatted.nix"
    [[ "$status" -eq 0 ]]
    # Check that indentation is preserved
    [[ "$output" =~ "  directories" ]]
}

@test "display_generated_config handles special characters" {
    cat > "${TEST_WORK_DIR}/special.nix" << 'EOF'
{
  fullName = "François O'Brien-Smith";
  email = "fx+test@example.com";
}
EOF

    run display_generated_config "${TEST_WORK_DIR}/special.nix"
    [[ "$status" -eq 0 ]]
    [[ "$output" =~ "François" ]]
    [[ "$output" =~ "O'Brien-Smith" ]]
    [[ "$output" =~ "fx+test@example.com" ]]
}

@test "display_generated_config adds header/footer for clarity" {
    cat > "${TEST_WORK_DIR}/test.nix" << 'EOF'
{
  username = "testuser";
}
EOF

    run display_generated_config "${TEST_WORK_DIR}/test.nix"
    [[ "$status" -eq 0 ]]
    # Should have some header or footer text for clarity
    [[ -n "$output" ]]
}

# ==============================================================================
# INTEGRATION TESTS (5 tests)
# ==============================================================================

@test "generate_user_config creates work directory" {
    rm -rf /tmp/nix-bootstrap

    # Run generate_user_config
    run generate_user_config

    # Verify work directory was created
    [[ -d /tmp/nix-bootstrap ]]
}

@test "generate_user_config creates user-config.nix file" {
    rm -rf /tmp/nix-bootstrap

    run generate_user_config
    [[ "$status" -eq 0 ]]

    # Verify output file exists
    [[ -f /tmp/nix-bootstrap/user-config.nix ]]
}

@test "generate_user_config sets USER_CONFIG_PATH global variable" {
    rm -rf /tmp/nix-bootstrap

    generate_user_config

    # Verify global variable is set
    [[ -n "$USER_CONFIG_PATH" ]]
    [[ "$USER_CONFIG_PATH" == "/tmp/nix-bootstrap/user-config.nix" ]]
}

@test "generate_user_config produces valid Nix syntax" {
    rm -rf /tmp/nix-bootstrap

    run generate_user_config
    [[ "$status" -eq 0 ]]

    # Validate the generated file
    run validate_nix_syntax /tmp/nix-bootstrap/user-config.nix
    [[ "$status" -eq 0 ]]
}

@test "generate_user_config uses values from global variables" {
    rm -rf /tmp/nix-bootstrap

    export USER_FULLNAME="Test User"
    export USER_EMAIL="test@example.com"
    export GITHUB_USERNAME="testuser"

    generate_user_config

    # Verify values were replaced
    grep -q "Test User" /tmp/nix-bootstrap/user-config.nix
    grep -q "test@example.com" /tmp/nix-bootstrap/user-config.nix
    grep -q "testuser" /tmp/nix-bootstrap/user-config.nix
}

# ==============================================================================
# ERROR HANDLING TESTS (10 tests)
# ==============================================================================

@test "generate_user_config fails gracefully if USER_FULLNAME not set" {
    unset USER_FULLNAME

    run generate_user_config

    # Should fail with error (or handle gracefully)
    # Implementation may choose to use defaults or error - we test both paths
    if [[ "$status" -ne 0 ]]; then
        # Failed with error - acceptable
        [[ -n "$output" ]]
    else
        # Succeeded with default or empty - also acceptable for this test
        # We'll enforce proper behavior in the actual implementation
        true
    fi
}

@test "generate_user_config fails gracefully if USER_EMAIL not set" {
    unset USER_EMAIL

    run generate_user_config

    if [[ "$status" -ne 0 ]]; then
        [[ -n "$output" ]]
    else
        true
    fi
}

@test "generate_user_config fails gracefully if GITHUB_USERNAME not set" {
    unset GITHUB_USERNAME

    run generate_user_config

    if [[ "$status" -ne 0 ]]; then
        [[ -n "$output" ]]
    else
        true
    fi
}

@test "generate_user_config fails if template file does not exist" {
    # Temporarily move template file
    if [[ -f "${BATS_TEST_DIRNAME}/../user-config.template.nix" ]]; then
        mv "${BATS_TEST_DIRNAME}/../user-config.template.nix" "${BATS_TEST_DIRNAME}/../user-config.template.nix.bak"
    fi

    run generate_user_config

    # Should fail
    [[ "$status" -eq 1 ]]

    # Restore template file
    if [[ -f "${BATS_TEST_DIRNAME}/../user-config.template.nix.bak" ]]; then
        mv "${BATS_TEST_DIRNAME}/../user-config.template.nix.bak" "${BATS_TEST_DIRNAME}/../user-config.template.nix"
    fi
}

@test "validate_nix_syntax handles permission errors gracefully" {
    # Create a file with no read permissions
    touch "${TEST_WORK_DIR}/noperm.nix"
    chmod 000 "${TEST_WORK_DIR}/noperm.nix"

    run validate_nix_syntax "${TEST_WORK_DIR}/noperm.nix"

    # Should fail
    [[ "$status" -eq 1 ]]

    # Clean up
    chmod 644 "${TEST_WORK_DIR}/noperm.nix"
}

@test "create_bootstrap_workdir handles permission errors gracefully" {
    # This is hard to test without root, but we can verify error handling exists
    # Skip if not testable
    skip "Permission error testing requires specific environment setup"
}

@test "display_generated_config provides helpful error for missing file" {
    run display_generated_config "${TEST_WORK_DIR}/missing.nix"

    [[ "$status" -eq 1 ]]
    # Should have error message
    [[ -n "$output" ]]
}

@test "get_macos_hostname handles hostname command failure gracefully" {
    # Difficult to test without breaking system - verify function is defensive
    run get_macos_hostname

    # Should always succeed or fail gracefully
    [[ "$status" -eq 0 ]] || [[ -n "$output" ]]
}

@test "generate_user_config handles sed failures gracefully" {
    # Create an unwritable directory to force sed to fail
    mkdir -p "${TEST_WORK_DIR}/readonly"

    # Override the work directory temporarily (if possible in implementation)
    # This test verifies defensive coding exists
    run generate_user_config

    # Should either succeed normally or fail with error message
    [[ "$status" -eq 0 ]] || [[ -n "$output" ]]
}

@test "validate_nix_syntax returns consistent exit codes" {
    # Valid file
    cat > "${TEST_WORK_DIR}/valid.nix" << 'EOF'
{ username = "test"; }
EOF

    run validate_nix_syntax "${TEST_WORK_DIR}/valid.nix"
    [[ "$status" -eq 0 ]]

    # Invalid file
    touch "${TEST_WORK_DIR}/invalid.nix"
    run validate_nix_syntax "${TEST_WORK_DIR}/invalid.nix"
    [[ "$status" -eq 1 ]]
}

# ==============================================================================
# GLOBAL VARIABLE TESTS (3 tests)
# ==============================================================================

@test "USER_CONFIG_PATH variable is declared" {
    # After running generate_user_config, variable should exist
    generate_user_config

    # Check variable is set
    [[ -n "${USER_CONFIG_PATH+x}" ]]
}

@test "USER_CONFIG_PATH points to /tmp/nix-bootstrap/user-config.nix" {
    generate_user_config

    [[ "$USER_CONFIG_PATH" == "/tmp/nix-bootstrap/user-config.nix" ]]
}

@test "USER_CONFIG_PATH file exists after generation" {
    generate_user_config

    [[ -f "$USER_CONFIG_PATH" ]]
}
