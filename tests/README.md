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

# Phase 4: Nix installation
bats tests/bootstrap_nix_install.bats

# Phase 4 (continued): Nix configuration
bats tests/bootstrap_nix_config.bats

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

### Phase 4 (Continued): Nix Configuration for macOS

The `bootstrap_nix_config.bats` test suite validates:

1. **Function Existence** (9 tests)
   - backup_nix_config()
   - get_cpu_cores()
   - configure_nix_binary_cache()
   - configure_nix_performance()
   - configure_nix_trusted_users()
   - configure_nix_sandbox()
   - restart_nix_daemon()
   - verify_nix_configuration()
   - configure_nix_phase()

2. **Backup Logic** (8 tests)
   - Creates timestamped backup when file exists
   - Handles missing file gracefully
   - Backup filename format (YYYYMMDD-HHMMSS)
   - Preserves original file content
   - Allows multiple backups
   - Logs backup creation
   - Returns 0 on success
   - Handles empty file

3. **CPU Detection** (6 tests)
   - Detects CPU count using sysctl
   - Returns "auto" on sysctl failure
   - Handles various CPU counts (4, 8, 10, 12, 16)
   - Outputs numeric value or "auto"
   - Logs detection
   - Consistent across calls

4. **Binary Cache Configuration** (10 tests)
   - Adds substituters setting
   - Adds trusted-public-keys
   - Uses correct cache.nixos.org URL
   - Includes full public key
   - Returns 0 on success
   - Logs configuration
   - Handles existing config
   - Doesn't duplicate settings (idempotent)
   - Creates file if missing
   - Sets proper format (key = value)

5. **Performance Configuration** (8 tests)
   - Adds max-jobs setting
   - Adds cores setting
   - Uses detected CPU cores
   - Uses "auto" on CPU detection failure
   - Sets cores to 0 (use all)
   - Returns 0 on success
   - Logs configuration
   - Doesn't duplicate settings (idempotent)

6. **Trusted Users Configuration** (8 tests)
   - Adds trusted-users setting
   - Includes root
   - Includes current user
   - Uses correct format
   - Returns 0 on success
   - Logs configuration
   - Doesn't duplicate settings (idempotent)
   - Handles existing config

7. **Sandbox Configuration** (6 tests)
   - Adds sandbox setting
   - Uses macOS-appropriate value (relaxed or false)
   - Returns 0 on success
   - Logs configuration
   - Doesn't duplicate settings (idempotent)
   - Uses correct format

8. **Daemon Restart** (10 tests)
   - Calls launchctl kickstart
   - Uses correct service name (system/org.nixos.nix-daemon)
   - Waits after restart
   - Returns 0 on success
   - Returns 1 on launchctl failure
   - Logs restart action
   - Logs error on failure
   - Uses -k flag (kill and restart)
   - Requires sudo
   - Provides manual instructions on failure

9. **Verification** (8 tests)
   - Checks config file exists
   - Checks substituters present
   - Checks trusted-users present
   - Checks max-jobs present
   - Logs verification results
   - Returns 0 when config valid
   - Logs warning on missing settings
   - Handles missing file gracefully

10. **Orchestration** (8 tests)
    - Displays phase header
    - Calls backup function
    - Configures binary cache
    - Configures performance settings
    - Configures trusted users
    - Configures sandbox
    - Returns 0 on success
    - Logs completion message

11. **Error Handling** (10 tests)
    - Handles sudo failure gracefully
    - Handles daemon restart failure
    - Binary cache provides clear error on failure
    - Trusted users provides clear error on failure
    - Restart provides actionable error message
    - Performance logs warning on CPU detection failure
    - Sandbox logs warning on failure but continues
    - Backup handles permission errors gracefully
    - Verification doesn't fail bootstrap on warnings
    - Phase displays time estimate

12. **Integration Tests** (5 tests)
    - Creates complete valid config
    - Preserves existing settings (from Story 01.4-001)
    - Idempotent (safe to run multiple times)
    - Execution order is correct
    - Handles fresh install scenario

**Total: 399 automated tests** (54 Phase 2 user prompts + 96 Phase 2 profile selection + 83 Phase 3 user config generation + 70 Phase 3 Xcode CLI Tools + 96 Phase 4 Nix configuration)

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

### Phase 4 (Continued) Nix Configuration Manual Tests

FX should perform these manual tests in a VM to validate Nix configuration functionality:

1. **Fresh Nix Installation → Configuration Test**
   ```bash
   # In a fresh macOS VM after Phase 4 (Nix installation)
   ./bootstrap.sh
   # Complete through Nix installation (Story 01.4-001)
   # Expected: Phase 4 (continued) header displayed
   # Expected: Prompt for sudo password for /etc/nix/nix.conf modification
   # Action: Enter sudo password
   # Expected: Binary cache configured (cache.nixos.org)
   # Expected: Performance settings configured (max-jobs detected)
   # Expected: Trusted users configured (root, current user)
   # Expected: Sandbox configured (relaxed for macOS)
   # Expected: Nix daemon restarted successfully
   # Expected: "✓ Nix configuration phase complete"
   ```

2. **Verify Binary Cache Working Test**
   ```bash
   # After Nix configuration complete
   cat /etc/nix/nix.conf
   # Expected: Contains "substituters = https://cache.nixos.org"
   # Expected: Contains "trusted-public-keys = cache.nixos.org-1:..."

   # Test binary cache access (download a small package)
   nix-env -iA nixpkgs.hello
   # Expected: Package downloads from binary cache (fast, no compilation)
   # Expected: Output shows "copying path '/nix/store/...' from 'https://cache.nixos.org'"
   ```

3. **Verify Max-Jobs Matches CPU Cores Test**
   ```bash
   # Check detected CPU cores
   sysctl -n hw.ncpu
   # Example output: 8

   # Check nix.conf max-jobs setting
   grep "max-jobs" /etc/nix/nix.conf
   # Expected: "max-jobs = 8" (or "auto" if detection failed)
   # Expected: "cores = 0" (use all cores per job)
   ```

4. **Verify Trusted Users Test**
   ```bash
   # Check trusted users configuration
   grep "trusted-users" /etc/nix/nix.conf
   # Expected: "trusted-users = root username" (where username is current user)

   # Verify current user has Nix trust
   whoami
   # Note the username, should match trusted-users entry
   ```

5. **Verify Daemon Restart Successful Test**
   ```bash
   # Check nix-daemon is running
   sudo launchctl list | grep nix-daemon
   # Expected: Shows "org.nixos.nix-daemon" with PID (daemon running)

   # Test Nix command works (verifies daemon responsive)
   nix-store --version
   # Expected: Version output (e.g., "nix-store (Nix) 2.18.1")
   ```

6. **Re-run Bootstrap → Idempotent Test**
   ```bash
   # Run bootstrap again after Phase 4 complete
   ./bootstrap.sh
   # Complete through Nix configuration again
   # Expected: "Binary cache already configured" message
   # Expected: "Performance settings already configured" message
   # Expected: "Trusted users already configured" message
   # Expected: "Sandbox mode already configured" message
   # Expected: No duplicate settings in /etc/nix/nix.conf
   # Expected: Daemon still restarts successfully
   ```

7. **Manual nix.conf Inspection Test**
   ```bash
   # After successful Nix configuration
   sudo cat /etc/nix/nix.conf
   # Expected: Contains experimental-features from Story 01.4-001
   # Expected: Contains substituters = https://cache.nixos.org
   # Expected: Contains trusted-public-keys with full key
   # Expected: Contains trusted-users = root username
   # Expected: Contains max-jobs = <number or "auto">
   # Expected: Contains cores = 0
   # Expected: Contains sandbox = relaxed
   # Expected: No duplicate settings
   # Expected: Proper formatting (key = value)
   # Expected: Comments indicating Story 01.4-002
   ```

### Phase 5: Nix-Darwin Installation

The `bootstrap_nix_darwin.bats` test suite validates:

1. **Function Existence** (6 tests)
   - fetch_flake_from_github()
   - copy_user_config()
   - initialize_git_for_flake()
   - run_nix_darwin_build()
   - verify_nix_darwin_installed()
   - install_nix_darwin_phase()

2. **GitHub Fetch Logic** (15 tests)
   - Creates darwin/ directory
   - Creates home-manager/modules/ directory structure
   - Fetches flake.nix from GitHub main branch
   - Fetches flake.lock from GitHub main branch
   - Fetches all darwin/*.nix configuration files
   - Fetches all home-manager/*.nix files
   - Validates all downloaded files are non-empty
   - Handles curl failures gracefully with clear error messages
   - Uses correct GitHub repository URLs (fxmartin/nix-install)
   - Exits on fetch failure (CRITICAL)
   - Logs progress messages during downloads
   - Validates all required files present after fetch
   - Fetches from main branch specifically
   - Logs errors with actionable guidance

3. **User Config Copy** (10 tests)
   - Validates source file exists before copying
   - Copies user-config.nix to flake directory correctly
   - Preserves file permissions during copy
   - Validates destination file is readable
   - Handles missing source file with clear error
   - Exits on copy failure (CRITICAL)
   - Logs success message with source/destination paths
   - Validates file content preserved (checks for expected content)
   - Handles existing destination file (overwrites)
   - Logs error with helpful guidance on failure

4. **Git Initialization** (8 tests)
   - Runs git init in correct directory ($WORK_DIR)
   - Adds all files with git add .
   - Creates initial commit with descriptive message
   - Handles git command not found (warning, not failure)
   - Idempotent - safe to run multiple times
   - Logs warning on git failure (NON-CRITICAL)
   - Continues execution even if git fails
   - Logs success message when git initialized

5. **Nix-Darwin Build** (12 tests)
   - Uses correct profile (standard) from $INSTALL_PROFILE
   - Uses correct profile (power) from $INSTALL_PROFILE
   - Changes to work directory before build
   - Runs nix run nix-darwin -- switch command
   - Uses flake path format (.#standard or .#power)
   - Displays progress messages during 10-20 minute build
   - Shows Nix build output (not suppressed)
   - Exits on build failure (CRITICAL)
   - Returns 0 on successful build
   - Displays build duration estimate prominently
   - Mentions Homebrew installation in progress output
   - Logs clear error with troubleshooting guidance on failure

6. **Verification Logic** (10 tests)
   - Checks darwin-rebuild command exists
   - Checks Homebrew exists at /opt/homebrew/bin/brew
   - Exits on missing darwin-rebuild (CRITICAL)
   - Exits on missing Homebrew (CRITICAL)
   - Logs success message when all verifications pass
   - Uses command -v for darwin-rebuild detection
   - Checks executable flag on Homebrew binary
   - Logs clear error on darwin-rebuild missing
   - Logs clear error on Homebrew missing
   - Returns 0 only when all verifications succeed

7. **Orchestration** (10 tests)
   - Calls fetch_flake_from_github first
   - Calls copy_user_config second
   - Calls initialize_git_for_flake third
   - Calls run_nix_darwin_build fourth
   - Calls verify_nix_darwin_installed fifth
   - Logs phase start with timestamp
   - Logs phase end with duration and summary
   - Exits on any CRITICAL function failure
   - Returns 0 on all functions succeeding
   - Includes phase duration calculation and display

8. **Error Handling** (10 tests)
   - fetch_flake_from_github is CRITICAL (exits on failure)
   - copy_user_config is CRITICAL (exits on failure)
   - initialize_git_for_flake is NON-CRITICAL (logs warning)
   - run_nix_darwin_build is CRITICAL (exits on failure)
   - verify_nix_darwin_installed is CRITICAL (exits on failure)
   - Clear error messages for all failure scenarios
   - Actionable guidance in all error messages
   - Error messages include troubleshooting steps
   - Exit codes consistently indicate success/failure

9. **Integration Tests** (5 tests)
   - Phase 5 variables available ($INSTALL_PROFILE, etc.)
   - Work directory accessible and writable
   - user-config.nix available from Phase 2
   - All functions callable from main()
   - End-to-end phase execution succeeds

**Total Phase 5 Tests: 86**

### Phase 5 Nix-Darwin Installation Manual Tests

FX should perform these manual tests in a VM to validate Phase 5 functionality:

1. **Standard Profile Build Test**
   ```bash
   ./bootstrap.sh
   # Complete Phases 1-4 (user info, profile selection, Xcode, Nix)
   # Profile selection: Enter 1 (Standard)
   # Expected: Fetches flake configuration from GitHub
   # Expected: Displays "Estimated time: 10-20 minutes" warning
   # Expected: Shows Nix build progress with download messages
   # Expected: Installs Homebrew automatically
   # Expected: darwin-rebuild command available after completion
   # Expected: /opt/homebrew/bin/brew exists and is executable
   # Expected: Phase completes in 10-25 minutes
   # Expected: Success message with phase duration displayed
   ```

2. **Power Profile Build Test**
   ```bash
   ./bootstrap.sh
   # Complete Phases 1-4
   # Profile selection: Enter 2 (Power)
   # Expected: Builds with Power profile (.#power)
   # Expected: All Standard profile expectations apply
   # Expected: May take longer due to additional packages
   ```

3. **GitHub Fetch Validation Test**
   ```bash
   # After Phase 5 starts
   ls -la /tmp/nix-bootstrap/
   # Expected: Directory structure created:
   #   - flake.nix
   #   - flake.lock
   #   - user-config.nix
   #   - darwin/configuration.nix
   #   - darwin/homebrew.nix
   #   - darwin/macos-defaults.nix
   #   - home-manager/home.nix
   #   - home-manager/modules/shell.nix
   #   - .git/ (Git repository initialized)
   ```

4. **Build Progress Observation Test**
   - Watch build output carefully
   - Expected messages:
     - "Fetching flake configuration from GitHub..."
     - "Starting nix-darwin build (this will take 10-20 minutes)..."
     - "Downloading packages from cache.nixos.org..."
     - "Building system configuration..."
     - "Installing Homebrew and applications..."
     - Many "building..." and "downloading..." messages (normal)
     - "nix-darwin build completed successfully!"

5. **Build Failure Recovery Test**
   ```bash
   # Simulate network disconnection during Phase 5
   # Turn off Wi-Fi or disconnect ethernet after build starts
   # Expected: Build fails with clear error message
   # Expected: Error indicates network connectivity issue
   # Expected: Troubleshooting guidance displayed
   # Expected: Bootstrap exits cleanly with error code

   # Reconnect network and retry
   ./bootstrap.sh
   # Expected: Resumes from Phase 5 (previous phases completed)
   # Expected: Build succeeds on retry
   ```

6. **Installation Verification Test**
   ```bash
   # After Phase 5 completes successfully

   # Check darwin-rebuild availability
   which darwin-rebuild
   # Expected: /run/current-system/sw/bin/darwin-rebuild

   darwin-rebuild --version
   # Expected: Version information displayed

   # Check Homebrew installation
   /opt/homebrew/bin/brew --version
   # Expected: Homebrew version displayed

   # Check system configuration
   ls -la /run/current-system/
   # Expected: System generation directories visible

   # Verify nix-darwin flake
   cd /tmp/nix-bootstrap
   nix flake show
   # Expected: Shows darwinConfigurations.standard and .power
   ```

7. **Git Repository Validation Test**
   ```bash
   # After Phase 5 completes
   cd /tmp/nix-bootstrap

   # Check Git status
   git status
   # Expected: Clean working tree, initial commit exists

   # Check Git log
   git log --oneline
   # Expected: "Initial flake setup for nix-darwin installation"

   # Verify all files tracked
   git ls-files
   # Expected: All .nix files listed
   ```

## Test Summary

**Total Automated Tests: 485 tests** (399 + 86 Phase 5 tests)

**Test Distribution:**
- Phase 1 (Pre-flight): 65 tests (bootstrap_preflight.bats)
- Phase 2 (User Prompts): 61 tests (bootstrap_user_prompts.bats)
- Phase 2 (Profile Selection): 51 tests (bootstrap_profile_selection.bats)
- Phase 2 (User Config): 63 tests (bootstrap_user_config.bats)
- Phase 3 (Xcode CLI Tools): 65 tests (bootstrap_xcode.bats)
- Phase 4 (Nix Installation): 52 tests (bootstrap_nix.bats)
- Phase 4 (Nix Configuration): 62 tests (bootstrap_nix_config.bats)
- Phase 5 (Nix-Darwin Installation): 86 tests (bootstrap_nix_darwin.bats)

**Manual VM Test Scenarios: 46 scenarios**
- Phase 1: 5 scenarios
- Phase 2 (User Info): 6 scenarios
- Phase 2 (Profile Selection): 6 scenarios
- Phase 2 (User Config): 7 scenarios
- Phase 3 (Xcode): 7 scenarios
- Phase 4 (Nix Installation): 5 scenarios
- Phase 4 (Nix Configuration): 7 scenarios
- Phase 5 (Nix-Darwin): 7 scenarios

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
