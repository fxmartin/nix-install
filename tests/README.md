# ABOUTME: Test suite documentation and setup instructions
# ABOUTME: Explains how to install bats and run the bootstrap pre-flight tests

# Bootstrap Test Suite

This directory contains the test suite for the Nix-Darwin bootstrap script.

## Test Framework

We use [bats-core](https://github.com/bats-core/bats-core) (Bash Automated Testing System) for testing shell scripts.

### Installing bats

**Option 1: Using Homebrew (recommended)**
```bash
brew install bats-core
```

**Option 2: Using Nix (if already installed)**
```bash
nix-env -iA nixpkgs.bats
```

**Option 3: Manual installation**
```bash
git clone https://github.com/bats-core/bats-core.git /tmp/bats-core
cd /tmp/bats-core
sudo ./install.sh /usr/local
```

### Verifying Installation

```bash
bats --version
# Should output: Bats 1.x.x or newer
```

## Running Tests

### Run all tests
```bash
# Phase 1: Pre-flight checks
bats tests/bootstrap_preflight.bats

# Phase 2: User information prompts
bats tests/bootstrap_user_prompts.bats

# Phase 2: Profile selection
bats tests/bootstrap_profile_selection.bats

# Phase 3: User config file generation
bats tests/bootstrap_user_config.bats

# Phase 3: Xcode CLI Tools installation
bats tests/bootstrap_xcode.bats

# Run all test suites
bats tests/*.bats
```

### Run tests with verbose output
```bash
bats -t tests/bootstrap_preflight.bats
```

### Run specific test
```bash
bats -f "bootstrap.sh exists" tests/bootstrap_preflight.bats
```

## Test Coverage

### Phase 1: Pre-flight System Validation

The `bootstrap_preflight.bats` test suite validates:

1. **File Structure**
   - bootstrap.sh exists and is executable
   - Proper shebang (#!/usr/bin/env bash)
   - Strict error handling (set -euo pipefail)
   - ABOUTME documentation comments

2. **Required Functions**
   - check_macos_version()
   - check_not_root()
   - check_internet()
   - display_system_info()
   - preflight_checks()
   - main()
   - Logging functions (log_info, log_warn, log_error)

3. **macOS Version Validation**
   - Uses sw_vers for version detection
   - Checks for macOS 14 (Sonoma) or newer
   - Provides actionable error messages for old versions

4. **Root User Prevention**
   - Uses $EUID to detect root
   - Displays clear error message
   - Suggests running as regular user

5. **Internet Connectivity**
   - Tests connectivity to nixos.org
   - Falls back to github.com
   - Uses curl with timeout (5 seconds)
   - Provides actionable error messages

6. **System Information Display**
   - macOS version and build
   - Hostname
   - Current user
   - System architecture

7. **Error Handling**
   - Exits with code 1 on failures
   - Displays clear, actionable error messages
   - Graceful failure handling

### Phase 2: User Information Prompts

The `bootstrap_user_prompts.bats` test suite validates:

1. **Function Existence** (4 tests)
   - validate_email()
   - validate_github_username()
   - validate_name()
   - prompt_user_info()

2. **Email Validation** (23 tests)
   - Valid formats: simple, plus-addressing, dots, numbers, subdomains, multi-part TLDs
   - Invalid formats: missing @, missing domain, missing TLD, spaces, special characters
   - Edge cases: leading/trailing dots, multiple @ symbols

3. **GitHub Username Validation** (17 tests)
   - Valid formats: alphanumeric, hyphens, underscores, mixed case
   - Invalid formats: special characters (@, ., /, #, spaces)
   - Edge cases: leading/trailing hyphens (GitHub restriction)

4. **Name Validation** (11 tests)
   - Valid formats: simple names, accented characters, apostrophes, hyphens, periods, commas
   - Invalid formats: empty strings, whitespace-only strings

5. **Integration Tests** (3 tests)
   - Regex pattern correctness
   - Leading/trailing hyphen enforcement
   - Global variable declarations

### Phase 2: Profile Selection

The `bootstrap_profile_selection.bats` test suite validates:

1. **Function Existence** (4 tests)
   - select_installation_profile()
   - display_profile_options()
   - confirm_profile_choice()
   - get_profile_display_name()

2. **Profile Choice Validation** (11 tests)
   - Valid choices: 1 (Standard), 2 (Power)
   - Invalid choices: 0, 3, negative numbers, decimals, non-numeric, empty, whitespace
   - Special character rejection

3. **Profile Name Conversion** (5 tests)
   - Choice 1 → "standard"
   - Choice 2 → "power"
   - Invalid input defaults to "standard"
   - Empty input defaults to "standard"
   - Non-numeric defaults to "standard"

4. **Profile Description Display** (10 tests)
   - Standard profile description shown
   - Power profile description shown
   - Disk usage estimates (~35GB for Standard, ~120GB for Power)
   - Target hardware (MacBook Air vs MacBook Pro M3 Max)
   - Ollama model counts (1 vs 4)
   - Virtualization differences (no virtualization vs Parallels Desktop)

5. **Confirmation Flow** (3 tests)
   - Standard profile confirmation message
   - Power profile confirmation message
   - Unknown profile handling

6. **Integration Tests** (3 tests)
   - INSTALL_PROFILE variable declaration
   - Phase 2 execution order
   - Profile value format validation

### Phase 3: User Config File Generation

The `bootstrap_user_config.bats` test suite validates:

1. **Function Existence** (6 tests)
   - create_bootstrap_workdir()
   - get_macos_username()
   - get_macos_hostname()
   - validate_nix_syntax()
   - display_generated_config()
   - generate_user_config()

2. **Template File Structure** (8 tests)
   - Template file exists in project root
   - Contains ABOUTME documentation comments
   - Contains all 6 required placeholders (@MACOS_USERNAME@, @FULL_NAME@, @EMAIL@, @GITHUB_USERNAME@, @HOSTNAME@, @DOTFILES_PATH@)

3. **Work Directory Creation** (5 tests)
   - Creates /tmp/nix-bootstrap directory
   - Idempotent (safe to run multiple times)
   - Sets correct permissions (755)
   - Returns 0 on success
   - Handles existing directory gracefully

4. **macOS Username Extraction** (8 tests)
   - Returns non-empty string
   - Returns current user from $USER
   - Returns alphanumeric username
   - No whitespace
   - Consistent results
   - Not root user
   - Matches whoami output
   - Returns exit code 0

5. **Hostname Extraction and Sanitization** (8 tests)
   - Returns non-empty string
   - Only alphanumeric and hyphens
   - No underscores (converts to hyphens)
   - No periods (removes)
   - No spaces
   - Converts uppercase to lowercase
   - Consistent results
   - Returns exit code 0

6. **Placeholder Replacement** (15 tests)
   - Creates output file
   - Replaces all 6 placeholders correctly
   - No placeholders remain in output
   - Handles special characters (apostrophes, accented characters, hyphens)
   - Handles plus-addressing in email
   - Handles hyphens and underscores in GitHub username
   - Output file has proper Nix structure

7. **Nix Syntax Validation** (10 tests)
   - Accepts valid Nix config
   - Rejects empty file
   - Rejects unbalanced braces (missing closing, extra closing)
   - Accepts nested braces
   - Accepts comments
   - Rejects non-existent file
   - Accepts empty strings in values
   - Accepts semicolons
   - Displays error message for invalid syntax
   - Returns consistent exit codes

8. **Config Display** (5 tests)
   - Outputs file contents
   - Handles non-existent file
   - Preserves formatting
   - Handles special characters
   - Adds header/footer for clarity

9. **Integration Tests** (5 tests)
   - Creates work directory
   - Creates user-config.nix file
   - Sets USER_CONFIG_PATH global variable
   - Produces valid Nix syntax
   - Uses values from global variables

10. **Error Handling** (10 tests)
    - Fails gracefully if USER_FULLNAME not set
    - Fails gracefully if USER_EMAIL not set
    - Fails gracefully if GITHUB_USERNAME not set
    - Fails if template file does not exist
    - Handles permission errors gracefully
    - Provides helpful error for missing file
    - Handles hostname command failure gracefully
    - Handles sed failures gracefully
    - Returns consistent exit codes

11. **Global Variable Tests** (3 tests)
    - USER_CONFIG_PATH variable is declared
    - Points to /tmp/nix-bootstrap/user-config.nix
    - File exists after generation

### Phase 3: Xcode Command Line Tools Installation

The `bootstrap_xcode.bats` test suite validates:

1. **Function Existence** (6 tests)
   - check_xcode_installed()
   - install_xcode_cli_tools()
   - wait_for_xcode_installation()
   - accept_xcode_license()
   - verify_xcode_installation()
   - install_xcode_phase()

2. **Detection Logic** (10 tests)
   - Returns 0 when Xcode CLI Tools installed
   - Returns 1 when not installed
   - Logs installation path when installed
   - Logs "not installed" message
   - Handles xcode-select command failure gracefully
   - Detects valid installation path
   - Idempotent checks
   - Handles empty xcode-select output
   - Validates installation before returning success
   - Logs info-level messages (not errors)

3. **Installation Triggering** (8 tests)
   - Calls xcode-select --install
   - Returns 0 on successful trigger
   - Returns 1 on installation trigger failure
   - Logs starting message
   - Logs success message
   - Logs error on failure
   - Handles already-in-progress installation
   - Does not require sudo

4. **User Interaction** (8 tests)
   - Prompts user with clear instructions
   - Displays clear installation steps (1, 2, 3)
   - Mentions time estimate (5-10 minutes)
   - Returns 0 after user input
   - Waits for ENTER key
   - Displays header separator
   - Provides numbered steps
   - Non-blocking after user input

5. **License Acceptance** (8 tests)
   - Calls sudo xcodebuild -license accept
   - Returns 0 on successful acceptance
   - Returns 1 on license acceptance failure
   - Handles exit code 69 (already accepted)
   - Logs success message
   - Logs error with helpful message on failure
   - Handles already-accepted license gracefully
   - Includes exit code in error messages

6. **Verification Logic** (8 tests)
   - Returns 0 when installed
   - Returns 1 when not installed
   - Displays installation path
   - Logs success message
   - Logs error on verification failure
   - Provides troubleshooting guidance
   - Validates path format
   - Uses xcode-select -p

7. **Integration Tests** (5 tests)
   - Skips when already installed
   - Orchestrates full installation flow
   - Displays Phase 3/10 header
   - Returns 1 on installation failure
   - Returns 1 on verification failure

8. **Error Handling** (12 tests)
   - Handles missing xcode-select command
   - Handles installation dialog cancellation
   - Handles license acceptance denial (warning only)
   - Propagates installation trigger errors
   - Propagates verification errors
   - Error messages include actionable guidance
   - Error messages are clear and descriptive
   - Handles partial installation gracefully
   - License acceptance errors include exit codes
   - Verification errors suggest manual intervention
   - Installation errors do not expose stack traces
   - Phase errors return non-zero exit codes

9. **Idempotency** (5 tests)
   - Safe to run multiple times when installed
   - check_xcode_installed produces consistent results
   - Skips installation when already complete
   - verify_xcode_installation can be called multiple times
   - accept_xcode_license handles already-accepted scenario

**Total: 303 automated tests** (54 Phase 2 user prompts + 96 Phase 2 profile selection + 83 Phase 3 user config generation + 70 Phase 3 Xcode CLI Tools)

## Manual Testing

Some tests require manual validation by FX in a VM or on physical hardware:

1. **Root User Test**
   ```bash
   sudo ./bootstrap.sh
   # Expected: Error message and exit code 1
   ```

2. **Old macOS Version Test**
   - Test on macOS Ventura (13.x) or older
   - Expected: Clear error message about requiring Sonoma 14.0+

3. **No Internet Test**
   - Disable network connection
   - Run bootstrap.sh
   - Expected: Clear error message about network connectivity

4. **System Info Display**
   - Run bootstrap.sh on fresh system
   - Verify all system information is displayed correctly

5. **Graceful Exit**
   - Trigger various failure scenarios
   - Verify clean exit with appropriate error messages

### Phase 2 Manual Tests

FX should perform these manual tests in a VM to validate Phase 2 functionality:

1. **Normal Flow Test**
   ```bash
   ./bootstrap.sh
   # Enter: François Martin
   # Enter: fx@example.com
   # Enter: fxmartin
   # Confirm: y
   # Expected: Success message, proceed to Phase 3
   ```

2. **Invalid Email Test**
   - Try entering invalid emails: `invalid-email`, `user@`, `@example.com`
   - Expected: Error message with retry prompt
   - Finally enter valid email: `fx@example.com`

3. **Invalid GitHub Username Test**
   - Try entering invalid usernames: `user.name`, `user@name`, `-username`
   - Expected: Error message explaining allowed characters
   - Finally enter valid username: `fxmartin`

4. **Confirmation Rejection Test**
   - Enter all valid information
   - At confirmation prompt, enter: `n`
   - Expected: Re-prompt for all information from the beginning

5. **Special Characters in Name Test**
   - Enter names with special characters: `François Martin`, `John O'Brien`, `Dr. Smith, Jr.`
   - Expected: All accepted as valid

6. **Empty Input Test**
   - Try leaving name empty (just press Enter)
   - Try entering only spaces for name
   - Expected: Error message requiring non-empty name

### Phase 2 Profile Selection Manual Tests

FX should perform these manual tests in a VM to validate profile selection functionality:

1. **Standard Profile Selection Test**
   ```bash
   ./bootstrap.sh
   # Complete user info phase
   # Profile prompt: Enter 1
   # Confirm: y
   # Expected: INSTALL_PROFILE set to "standard", proceed to Phase 3
   ```

2. **Power Profile Selection Test**
   ```bash
   ./bootstrap.sh
   # Complete user info phase
   # Profile prompt: Enter 2
   # Confirm: y
   # Expected: INSTALL_PROFILE set to "power", proceed to Phase 3
   ```

3. **Invalid Profile Choice Test**
   - Try entering invalid choices: `0`, `3`, `99`, `-1`, `abc`, `1.5`
   - Expected: Error message "Invalid choice. Please enter 1 for Standard or 2 for Power."
   - Finally enter valid choice: `1` or `2`

4. **Profile Confirmation Rejection Test**
   - Enter valid choice: `1`
   - At confirmation prompt, enter: `n`
   - Expected: Re-prompt for profile selection from beginning

5. **Profile Display Validation Test**
   - Verify profile descriptions are clear and accurate:
     - Standard: MacBook Air, 1 Ollama model, no virtualization, ~35GB
     - Power: MacBook Pro M3 Max, 4 Ollama models, Parallels Desktop, ~120GB
   - Expected: All information matches REQUIREMENTS.md specifications

6. **Profile Variable Persistence Test**
   - Select a profile and confirm
   - Verify INSTALL_PROFILE variable is set correctly in subsequent phases
   - Expected: Variable persists throughout bootstrap execution

### Phase 3 User Config Generation Manual Tests

FX should perform these manual tests in a VM to validate user config generation functionality:

1. **Normal Config Generation Test**
   ```bash
   ./bootstrap.sh
   # Complete user info phase (name, email, GitHub username)
   # Complete profile selection phase (Standard or Power)
   # Expected: Config file generated at /tmp/nix-bootstrap/user-config.nix
   # Expected: Config displayed for review
   # Expected: All placeholders replaced with actual values
   # Expected: No errors reported
   ```

2. **Verify Generated Config File**
   ```bash
   # After running bootstrap.sh through config generation
   cat /tmp/nix-bootstrap/user-config.nix
   # Expected: Valid Nix syntax
   # Expected: All personal information present (name, email, GitHub username)
   # Expected: macOS username matches current user
   # Expected: Hostname is sanitized (lowercase, no special chars except hyphens)
   # Expected: Dotfiles path set to "Documents/nix-install"
   ```

3. **Special Characters in Name Test**
   - Enter name with special characters: `François O'Brien-Smith, Jr.`
   - Complete bootstrap through config generation
   - Verify generated config preserves special characters correctly
   - Expected: Name appears in config exactly as entered

4. **Complex Hostname Test**
   - Test on a Mac with hostname containing underscores or periods
   - Example hostname: `MacBook_Pro.local`
   - Expected: Hostname sanitized to `macbook-pro` (lowercase, hyphens only)
   - Verify in generated config file

5. **Work Directory Creation Test**
   ```bash
   # Before running bootstrap
   ls -la /tmp/nix-bootstrap
   # Expected: Directory does not exist (or empty from previous run)

   ./bootstrap.sh
   # Complete through config generation

   ls -la /tmp/nix-bootstrap
   # Expected: Directory exists with correct permissions (755)
   # Expected: user-config.nix file present
   ```

6. **Config File Permissions Test**
   ```bash
   # After config generation
   ls -la /tmp/nix-bootstrap/user-config.nix
   # Expected: File is readable (644 or similar)
   # Expected: Owner is current user
   ```

7. **Idempotent Run Test**
   ```bash
   # Run bootstrap twice in succession
   ./bootstrap.sh  # First run
   # Complete all phases

   ./bootstrap.sh  # Second run
   # Complete all phases again
   # Expected: No errors about existing work directory
   # Expected: Config file overwritten successfully
   # Expected: No permission issues
   ```

8. **Config Display Formatting Test**
   - Run bootstrap through config generation
   - Verify config display is readable and well-formatted
   - Expected: Clear header "Generated User Configuration"
   - Expected: Proper indentation preserved
   - Expected: Clear footer separators
   - Expected: All values visible and correct

### Phase 3 Xcode CLI Tools Installation Manual Tests

FX should perform these manual tests in a VM to validate Xcode CLI Tools installation functionality:

1. **Clean Install Test (Xcode Not Installed)**
   ```bash
   # In a fresh macOS VM without Xcode CLI Tools
   ./bootstrap.sh
   # Complete user info and profile selection phases
   # Expected: Phase 3 header displayed ("Phase 3/10: Xcode Command Line Tools")
   # Expected: "Xcode CLI Tools not installed" message
   # Expected: System dialog appears asking to install Xcode CLI Tools
   # Action: Click "Install" in the dialog
   # Action: Wait for installation to complete (5-10 minutes)
   # Action: Press ENTER when prompted
   # Expected: Verification passes
   # Expected: License acceptance succeeds (or shows warning if fails)
   # Expected: Success message "✓ Xcode CLI Tools installation phase complete"
   ```

2. **Already Installed Test (Xcode Pre-Installed)**
   ```bash
   # In a macOS VM with Xcode CLI Tools already installed
   # Verify first: xcode-select -p (should show path)
   ./bootstrap.sh
   # Complete user info and profile selection phases
   # Expected: Phase 3 header displayed
   # Expected: "Xcode CLI Tools already installed at: /Library/Developer/CommandLineTools" message
   # Expected: Skip installation message
   # Expected: No dialog appears
   # Expected: Proceeds directly to Phase 4 (future implementation)
   ```

3. **License Acceptance Test**
   ```bash
   # After Xcode CLI Tools installed but license not accepted
   ./bootstrap.sh
   # Complete through Xcode installation
   # Expected: Prompt for sudo password for license acceptance
   # Action: Enter sudo password
   # Expected: "✓ Xcode license accepted" message
   # OR: "License already accepted or not required" warning
   ```

4. **Installation Cancellation Test**
   ```bash
   # In a fresh VM without Xcode CLI Tools
   ./bootstrap.sh
   # Complete user info and profile selection phases
   # Expected: Xcode installation dialog appears
   # Action: Click "Cancel" in the dialog
   # Action: Press ENTER when prompted
   # Expected: Verification fails with error message
   # Expected: Bootstrap process terminates
   # Expected: Clear error: "Xcode CLI Tools installation verification failed"
   # Expected: Guidance: "Please try running: xcode-select --install"
   ```

5. **Verification Test (Post-Installation)**
   ```bash
   # After successful Xcode installation
   xcode-select -p
   # Expected output: /Library/Developer/CommandLineTools

   which git
   # Expected output: /Library/Developer/CommandLineTools/usr/bin/git (or similar)

   git --version
   # Expected: Git version displayed (e.g., "git version 2.39.3")
   ```

6. **Idempotency Test (Run Phase 3 Twice)**
   ```bash
   # Run bootstrap twice in succession
   ./bootstrap.sh  # First run
   # Complete through Xcode installation
   # Verify Xcode installed successfully

   ./bootstrap.sh  # Second run
   # Complete user info and profile selection again
   # Expected: Phase 3 skips installation
   # Expected: "already installed" message
   # Expected: No dialog appears
   # Expected: Proceeds to next phase immediately
   ```

## Testing Unmerged Branches in VM

To test the bootstrap script from a feature branch (before merging to main) in a VM:

### Option 1: Download and Inspect First (Recommended)
```bash
# Download the bootstrap script from feature branch
curl -o bootstrap.sh https://raw.githubusercontent.com/fxmartin/nix-install/feature/01.1-001/bootstrap.sh

# Make it executable
chmod +x bootstrap.sh

# Inspect it (optional but recommended for security)
less bootstrap.sh

# Run it
./bootstrap.sh
```

### Option 2: Direct Execution (One-Liner)
```bash
# Download and run directly from feature branch
curl -sSL https://raw.githubusercontent.com/fxmartin/nix-install/feature/01.1-001/bootstrap.sh | bash
```

**Note**: Replace `feature/01.1-001` with the appropriate branch name for the feature you're testing.

**Security Best Practice**: Option 1 is recommended because it allows you to inspect the script before execution.

## Test Driven Development (TDD) Workflow

1. Write tests first (tests fail - RED)
2. Implement code to pass tests (tests pass - GREEN)
3. Refactor while keeping tests green (REFACTOR)

This test suite was created BEFORE the bootstrap.sh implementation, following TDD best practices.

## Continuous Integration

These tests should be run:
- Before every commit
- In CI/CD pipeline (GitHub Actions)
- Before merging pull requests
- After every code review

## Test Maintenance

When adding new features to bootstrap.sh:
1. Add tests to appropriate .bats file FIRST
2. Run tests to confirm they fail
3. Implement the feature
4. Run tests to confirm they pass
5. Update this README if test coverage changes
