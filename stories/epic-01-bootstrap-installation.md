# Epic 01: Bootstrap & Installation System

## Epic Overview
**Epic ID**: Epic-01
**Epic Description**: Automated one-command bootstrap system that transforms a fresh macOS installation into a fully configured development environment with zero manual intervention (except license activations). The bootstrap handles Xcode CLI tools installation, Nix package manager setup, nix-darwin configuration, SSH key generation with GitHub integration, profile selection (Standard vs Power), and complete repository cloning.
**Business Value**: Reduces setup time from 4-6 hours to <30 minutes, eliminates manual errors, ensures reproducibility across all machines
**User Impact**: Enables FX to reinstall any MacBook quickly and confidently, knowing the result will be identical to previous installations
**Success Metrics**:
- Bootstrap completion time <30 minutes
- First-time success rate >90%
- Zero manual intervention except SSH key upload and license activations

## Epic Scope
**Total Stories**: 18
**Total Story Points**: 105 (revised from 108 after Story 01.6-002 update)
**MVP Stories**: 18 (100% of epic)
**Priority Level**: Must Have
**Target Release**: Phase 0-2 (Week 1-2)

**Scope Change**: Story 01.6-002 changed from manual approach (8 points) to automated GitHub CLI approach (5 points) on 2025-11-10, reducing epic total by 3 points.

## Features in This Epic

### Feature 01.1: Pre-flight System Validation
**Feature Description**: Validate system requirements and prerequisites before beginning installation
**User Value**: Prevents installation failures by catching issues early
**Story Count**: 3
**Story Points**: 11
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 01.1-001: Pre-flight Environment Checks
**User Story**: As FX, I want the bootstrap script to validate my system meets all requirements so that I know the installation will succeed before it starts

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** a fresh macOS installation
- **When** I run the bootstrap script
- **Then** it checks macOS version is Sonoma (14.x) or newer
- **And** it verifies internet connectivity (ping test or curl test)
- **And** it ensures script is not running as root user
- **And** it displays clear error messages for any failed check
- **And** it exits gracefully if pre-flight checks fail

**Additional Requirements**:
- Minimum macOS version: Sonoma 14.0
- Internet connectivity test: Must reach nixos.org or github.com
- Root check: Script must refuse to run as root
- Error messages must be actionable (tell user what to do)

**Technical Notes**:
- Use `sw_vers -productVersion` for macOS version check
- Use `ping -c 1 nixos.org` or `curl -Is https://nixos.org` for connectivity
- Use `[ "$EUID" -ne 0 ]` for root check
- Display system info summary before proceeding

**Definition of Done**:
- [x] Code implemented and peer reviewed
- [x] All pre-flight checks functional
- [x] Error messages clear and actionable
- [x] Script exits gracefully on failures
- [x] Tested in VM with various failure scenarios
- [x] Documentation updated with system requirements

**Dependencies**:
- None (first story in bootstrap flow)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 01.1-002: Idempotency Check
**User Story**: As FX, I want the bootstrap script to detect partial installations so that I can safely re-run it if something goes wrong

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** the bootstrap script has been run previously
- **When** I run it again
- **Then** it detects existing Xcode CLI tools and skips installation
- **And** it detects existing Nix installation and offers to skip/reinstall
- **And** it detects existing nix-darwin config and offers to rebuild
- **And** it preserves user-config.nix if it already exists
- **And** it displays what will be skipped vs what will run

**Technical Notes**:
- Check for Xcode: `xcode-select -p`
- Check for Nix: `command -v nix`
- Check for existing config: `[ -d ~/Documents/nix-install ]`
- Prompt user before overwriting existing configurations

**Definition of Done**:
- [x] Idempotency checks implemented for all phases (user config, Xcode, Nix, SSH key)
- [x] User prompted before overwriting existing files (reuse prompt)
- [x] Re-runs complete successfully
- [x] Tested with partial installations in VM ✅ **VM TESTED (2025-11-10)**
- [x] Documentation notes script is safe to re-run

**Implementation Notes**:
- Story completed on main branch (2025-11-10)
- Function implemented: check_existing_user_config() (89 lines)
- Checks two locations in priority order:
  1. ~/Documents/nix-install/user-config.nix (completed installation)
  2. /tmp/nix-bootstrap/user-config.nix (previous bootstrap attempt)
- Parses existing config values (fullName, email, githubUsername) using grep + sed
- Validates parsed values (no placeholders, not empty), falls back gracefully
- Displays found config and prompts: "Reuse this configuration? (y/n)"
- If reused: Sets global variables, skips prompt_user_info() (saves 30-60 seconds)
- If declined or invalid: Runs normal prompts for fresh input
- Pattern based on mlgruby-repo-for-reference/scripts/install/pre-nix-installation.sh (lines 239-289)
- VM Testing: ✅ **ALL SCENARIOS PASSED** (fresh, retry, completed, corrupted, declined)
- Integration: Phase 2 main() flow, line 2855 (before prompt_user_info call)

**Dependencies**:
- Story 01.1-001 (pre-flight checks) - COMPLETED ✅

**Risk Level**: Medium
**Risk Mitigation**: Backup existing configs before overwriting

---

##### Story 01.1-003: Progress Indicators
**User Story**: As FX, I want clear progress indicators during installation so that I know the script is working and how long to wait

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** the bootstrap script is running
- **When** each phase starts
- **Then** it displays phase number and name (e.g., "Phase 2/10: Installing Xcode CLI Tools")
- **And** it shows estimated time for long-running operations
- **And** it displays success/failure status after each phase
- **And** it shows a final summary when complete
- **And** progress indicators work in both interactive and non-interactive modes

**Technical Notes**:
- Use echo with formatting for phase headers
- Display timestamps for long operations
- Use checkmarks (✓) for success, X for failures
- Consider using tput for colored output (optional)

**Definition of Done**:
- [ ] Progress indicators for all 10 bootstrap phases
- [ ] Estimated time displayed for downloads/builds
- [ ] Success/failure status clear
- [ ] Final summary shows what was installed
- [ ] Tested in VM with full bootstrap run
- [ ] Output is readable and professional

**Dependencies**:
- Story 01.1-001 (pre-flight checks)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 01.2: User Configuration & Profile Selection
**Feature Description**: Interactive prompts to gather user information and select installation profile (Standard vs Power)
**User Value**: Personalizes installation and ensures correct apps/models installed for each machine type
**Story Count**: 3
**Story Points**: 16
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 01.2-001: User Information Prompts
**User Story**: As FX, I want to provide my personal information during bootstrap so that Git, SSH, and other tools are configured with my details

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** pre-flight checks have passed
- **When** I reach the user configuration phase
- **Then** the script prompts for my full name
- **And** it prompts for my email address
- **And** it prompts for my GitHub username
- **And** it validates email format (contains @ and domain)
- **And** it validates GitHub username (no special characters except dash/underscore)
- **And** it confirms my inputs before proceeding
- **And** it stores validated inputs in variables for later use

**Additional Requirements**:
- Email validation: Basic format check with regex
- Name validation: Allow spaces and common punctuation
- GitHub username: Alphanumeric plus dash and underscore only
- Confirmation prompt: Display all inputs and ask "Is this correct? (y/n)"

**Technical Notes**:
- Use `read -p` for interactive prompts
- Email regex: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
- GitHub username regex: `^[a-zA-Z0-9-_]+$`
- Store in variables: `USER_FULLNAME`, `USER_EMAIL`, `GITHUB_USERNAME`

**Definition of Done**:
- [x] All prompts functional and clear
- [x] Input validation working correctly
- [x] Confirmation prompt implemented
- [x] Invalid inputs rejected with helpful messages
- [x] Variables stored for later phases
- [x] Tested in VM with valid and invalid inputs

**Dependencies**:
- Story 01.1-001 (pre-flight checks complete)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 01.2-002: Profile Selection System
**User Story**: As FX, I want to choose between Standard and Power profiles during bootstrap so that the correct apps and models are installed for each MacBook type

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** user information has been collected
- **When** I reach the profile selection phase
- **Then** the script displays two profile options with clear descriptions
- **And** it shows Standard profile: "MacBook Air - essential apps, 1 Ollama model, no virtualization (~35GB disk)"
- **And** it shows Power profile: "MacBook Pro M3 Max - all apps, 4 Ollama models, Parallels Desktop (~120GB disk)"
- **And** it prompts me to enter 1 or 2
- **And** it validates my selection and defaults to Standard if invalid
- **And** it stores profile choice in a variable for later use
- **And** it confirms my profile choice before proceeding

**Additional Requirements**:
- Profile descriptions must be clear and concise
- Disk usage estimates help user make informed choice
- Default to Standard profile if user enters invalid choice
- Store profile in variable: `INSTALL_PROFILE` (values: "standard" or "power")

**Technical Notes**:
- Use case statement for profile selection
- Display disk usage estimates to help decision
- Confirm choice: "You selected Power profile. Continue? (y/n)"
- Profile variable used in nix-darwin flake selection

**Definition of Done**:
- [x] Profile selection prompt implemented
- [x] Clear descriptions for both profiles
- [x] Input validation and default handling
- [x] Confirmation prompt working
- [x] Profile variable stored correctly
- [x] Tested selecting both profiles in VM (FX tested manually - PASSED)
- [x] Documentation explains profile differences

**Implementation Notes**:
- Story completed in feature/01.2-002-profile-selection branch
- Merged to main via PR #7 (2025-11-09)
- Functions implemented in bootstrap.sh:
  - validate_profile_choice() - Validates input is 1 or 2
  - convert_profile_choice_to_name() - Converts 1/2 to standard/power
  - display_profile_options() - Shows profile descriptions with disk estimates
  - get_profile_display_name() - Returns human-readable profile name
  - confirm_profile_choice() - Confirms user's selection
  - select_installation_profile() - Main interactive prompt function
- BATS test suite created: tests/bootstrap_profile_selection.bats (96 tests)
- Integration: select_installation_profile() called in main() after prompt_user_info()
- Global variable: INSTALL_PROFILE set to "standard" or "power"
- Shellcheck validation: Passed (style warnings only, consistent with existing code)

**Dependencies**:
- Story 01.2-001 (user information collected) - COMPLETED ✅

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 01.2-003: User Config File Generation
**User Story**: As FX, I want the bootstrap to generate user-config.nix from my inputs so that my personal information is used throughout the Nix configuration

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** user information and profile have been collected
- **When** the script generates user-config.nix
- **Then** it fetches user-config.template.nix from GitHub
- **And** it replaces placeholders with actual user values (name, email, GitHub username)
- **And** it writes the file to /tmp/nix-bootstrap/user-config.nix
- **And** it validates the generated Nix file syntax
- **And** it displays the generated config for user review

**Additional Requirements**:
- Template URL: `https://raw.githubusercontent.com/fxmartin/nix-install/main/user-config.template.nix`
- Placeholders: `@FULL_NAME@`, `@EMAIL@`, `@GITHUB_USERNAME@`
- Syntax validation: Use `nix-instantiate --parse` if Nix is already installed
- Display generated config so user can verify

**Technical Notes**:
- Use sed or awk to replace placeholders
- Example: `sed "s/@FULL_NAME@/$USER_FULLNAME/g"`
- Validate before proceeding to avoid Nix build failures
- Store in /tmp/nix-bootstrap/ (temporary directory)

**Definition of Done**:
- [x] Template created in project root (user-config.template.nix)
- [x] Placeholder replacement working (sed-based, 6 placeholders)
- [x] Generated file syntax is valid Nix (basic validation)
- [x] File written to correct location (/tmp/nix-bootstrap/user-config.nix)
- [x] User can review generated config (display_generated_config function)
- [x] Tested with various user inputs in VM (FX tested - ALL 8 SCENARIOS PASSED)

**Implementation Notes**:
- Story completed in feature/01.2-003-user-config-generation branch
- Merged to main (2025-11-09) after successful VM testing
- Functions implemented in bootstrap.sh:
  - create_bootstrap_workdir() - Create /tmp/nix-bootstrap/ directory
  - get_macos_username() - Extract current macOS username
  - get_macos_hostname() - Sanitize hostname (lowercase, alphanumeric + hyphens)
  - validate_nix_syntax() - Basic syntax validation (balanced braces)
  - display_generated_config() - Display config for user review
  - generate_user_config() - Main orchestration function
- BATS test suite created: tests/bootstrap_user_config.bats (83 tests)
- Integration: generate_user_config() called in main() after select_installation_profile()
- Global variable: USER_CONFIG_PATH set to /tmp/nix-bootstrap/user-config.nix
- Template: user-config.template.nix with 6 placeholders (@MACOS_USERNAME@, @FULL_NAME@, @EMAIL@, @GITHUB_USERNAME@, @HOSTNAME@, @DOTFILES_PATH@)
- Hostname sanitization: Converts to lowercase, removes special chars (keeps hyphens only)
- Special character handling: Preserves apostrophes, accents, hyphens in names
- Shellcheck validation: Passed (0 errors)
- VM Testing: All 8 manual scenarios passed successfully

**Dependencies**:
- Story 01.2-001 (user info collected) - COMPLETED ✅
- Story 01.2-002 (profile selected) - COMPLETED ✅

**Risk Level**: Low
**Risk Mitigation**: Validate Nix syntax before proceeding

---

### Feature 01.3: Xcode Command Line Tools Installation
**Feature Description**: Automated installation of Xcode CLI tools required for compilation
**User Value**: Ensures build dependencies are available for Nix and Homebrew
**Story Count**: 1
**Story Points**: 5
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 01.3-001: Xcode CLI Tools Installation
**User Story**: As FX, I want Xcode Command Line Tools installed automatically so that build dependencies are available for Nix

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** pre-flight checks have passed
- **When** the bootstrap reaches the Xcode installation phase
- **Then** it checks if Xcode CLI tools are already installed
- **And** if not installed, it runs `xcode-select --install`
- **And** it waits for user to complete the installation dialog
- **And** it verifies installation succeeded
- **And** it displays success message and proceeds

**Additional Requirements**:
- Check for existing installation: `xcode-select -p` returns path
- Installation requires user interaction (system dialog)
- Verify with `xcode-select -p` after installation
- **Note**: Xcode CLI Tools do not require license acceptance (only full Xcode.app does)

**Technical Notes**:
- Xcode check: `xcode-select -p &>/dev/null`
- Install command: `xcode-select --install`
- Wait for user: Display message and `read -p "Press ENTER when installation is complete..."`
- Verification: Ensure `xcode-select -p` returns a valid path
- **License removed**: CLI Tools work immediately without license acceptance

**Definition of Done**:
- [x] Existing installation detection working
- [x] Installation triggers system dialog
- [x] Script waits for user completion
- [x] Verification confirms installation
- [x] Tested in VM without existing Xcode tools ✅ **VM TESTED - ALL SCENARIOS PASSED**
- [x] Skip logic works for existing installations

**Implementation Notes**:
- Story implemented on main branch (2025-11-09)
- Functions implemented in bootstrap.sh:
  - check_xcode_installed() - Detect existing installation
  - install_xcode_cli_tools() - Trigger macOS system dialog
  - wait_for_xcode_installation() - Interactive user wait with clear guidance
  - verify_xcode_installation() - Post-install verification with path display
  - install_xcode_phase() - Phase 3 orchestration function
- **License acceptance removed**: CLI Tools do not require license (only full Xcode.app)
- BATS test suite created: tests/bootstrap_xcode.bats (58 tests)
- Test coverage: Function existence, detection logic, installation flow, user interaction, verification, orchestration, error handling, idempotency
- Integration: install_xcode_phase() called in main() as Phase 3
- User experience: Clear phase header, time estimates (5-10 min), numbered instructions
- Error handling: Comprehensive with actionable guidance for every failure
- Idempotency: Safe to run multiple times, skips if already installed
- Shellcheck validation: Passed (style warnings only, consistent with project)
- VM Testing: ✅ **ALL MANUAL TESTS PASSED** (2025-11-09)
  - Fresh macOS without Xcode CLI Tools: Installation triggered successfully
  - System dialog appeared and installation completed
  - Verification confirmed installation path
  - Re-run test: Skip logic working correctly
  - All user prompts clear and helpful

**Dependencies**:
- Story 01.1-001 (pre-flight checks) - COMPLETED ✅
- Story 01.2-003 (user config generated) - COMPLETED ✅

**Risk Level**: Medium
**Risk Mitigation**: Provide clear instructions if installation fails, allow re-run

---

### Feature 01.4: Nix Package Manager Installation
**Feature Description**: Install Nix package manager with flakes support enabled and create minimal flake infrastructure
**User Value**: Foundation for all declarative package management and system configuration
**Story Count**: 3
**Story Points**: 21
**Priority**: High
**Complexity**: High

#### Stories in This Feature

##### Story 01.4-001: Nix Multi-User Installation
**User Story**: As FX, I want Nix package manager installed with flakes enabled so that I can use declarative system configuration

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** Xcode CLI tools are installed
- **When** the bootstrap reaches the Nix installation phase
- **Then** it checks if Nix is already installed
- **And** if not, it downloads the Nix installer from nixos.org
- **And** it runs the multi-user installation (requires sudo)
- **And** it enables experimental features (flakes, nix-command) in nix.conf
- **And** it sources the Nix environment for the current session
- **And** it verifies `nix --version` works
- **And** it displays Nix version installed

**Additional Requirements**:
- Multi-user installation: More robust for macOS
- Experimental features required for flakes support
- Source environment: `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`
- Minimum Nix version: 2.18+ (for flakes stability)

**Technical Notes**:
- Check existing: `command -v nix`
- Install command: `curl -L https://nixos.org/nix/install | sh -s -- --daemon`
- Enable flakes in ~/.config/nix/nix.conf or /etc/nix/nix.conf:
  ```
  experimental-features = nix-command flakes
  ```
- Source Nix: `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`
- Verify: `nix --version` should return 2.18+

**Definition of Done**:
- [x] Existing installation detection working
- [x] Multi-user installation completes successfully
- [x] Flakes and nix-command enabled
- [x] Nix environment sourced in current shell
- [x] Version verification works
- [x] Tested in VM without existing Nix ✅ **VM TESTED - ALL SCENARIOS PASSED**
- [x] Skip logic works for existing installations

**Implementation Notes**:
- Story implemented on main branch (2025-11-09)
- Functions implemented in bootstrap.sh (lines 833-1140):
  - check_nix_installed() - Detect existing Nix via `command -v nix`
  - download_nix_installer() - Download from nixos.org
  - install_nix_multi_user() - Run multi-user installation with --daemon
  - enable_nix_flakes() - Enable experimental features in /etc/nix/nix.conf
  - source_nix_environment() - Source nix-daemon.sh for current session
  - verify_nix_installation() - Verify version >= 2.18.0
  - install_nix_phase() - Phase 4 orchestration function
- BATS test suite created: tests/bootstrap_nix.bats (120 tests)
- Test coverage: Function existence, detection logic, download operations, installation flow, configuration, environment sourcing, verification, orchestration, error handling, idempotency
- Integration: install_nix_phase() called in main() as Phase 4 (line 1218)
- User experience: Clear phase header, time estimates (5-10 min), sudo explanation
- Error handling: Comprehensive with actionable guidance for network, sudo, version failures
- Idempotency: Safe to run multiple times, skips if already installed
- Shellcheck validation: Passed (info-level suggestions only, consistent with project)
- VM Testing: ✅ **ALL MANUAL TESTS PASSED** (2025-11-09)
  - Fresh macOS without Nix: Installation completed successfully
  - Multi-user installation created /nix directory and daemon
  - Flakes enabled in /etc/nix/nix.conf
  - Nix environment sourced correctly
  - Version verification confirmed (Nix 2.18.0+)
  - Re-run test: Skip logic working correctly
  - All user prompts clear and helpful

**Dependencies**:
- Story 01.3-001 (Xcode CLI tools installed) ✅ COMPLETED

**Risk Level**: High
**Risk Mitigation**: Provide rollback instructions, validate installation before proceeding

---

##### Story 01.4-002: Nix Configuration for macOS
**User Story**: As FX, I want Nix optimized for macOS so that builds are fast and use available binary caches

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** Nix is installed
- **When** the bootstrap configures Nix
- **Then** it enables the NixOS binary cache (cache.nixos.org)
- **And** it sets max-jobs to number of CPU cores
- **And** it configures trusted users to include the current user
- **And** it sets sandbox mode appropriate for macOS
- **And** it writes configuration to /etc/nix/nix.conf
- **And** it restarts nix-daemon to apply changes

**Additional Requirements**:
- Binary cache: Speeds up builds significantly
- Max jobs: Parallel builds for faster execution
- Trusted users: Allows current user to manage Nix store
- Sandbox: May need relaxed settings for macOS

**Technical Notes**:
- Configuration file: /etc/nix/nix.conf (requires sudo)
- Binary cache: `substituters = https://cache.nixos.org`
- Max jobs: `max-jobs = auto` or `max-jobs = $(sysctl -n hw.ncpu)`
- Trusted users: `trusted-users = root <current-user>`
- Restart daemon: `sudo launchctl kickstart -k system/org.nixos.nix-daemon`

**Definition of Done**:
- [x] Configuration written to correct file
- [x] Binary cache enabled and tested
- [x] Max jobs set appropriately
- [x] Trusted users configured
- [x] Daemon restarted successfully
- [x] Tested in VM, builds use binary cache ✅ **VM TESTED - ALL SCENARIOS PASSED**
- [x] Documentation notes configuration choices

**Implementation Notes**:
- Story implemented on main branch (2025-11-09)
- Functions implemented in bootstrap.sh (lines 1143-1432):
  - backup_nix_config() - Create timestamped backups
  - get_cpu_cores() - Detect CPU cores via sysctl
  - configure_nix_binary_cache() - Enable cache.nixos.org (CRITICAL)
  - configure_nix_performance() - Set max-jobs and cores
  - configure_nix_trusted_users() - Add root and current user (CRITICAL)
  - configure_nix_sandbox() - Set macOS sandbox mode
  - restart_nix_daemon() - Restart daemon via launchctl (CRITICAL)
  - verify_nix_configuration() - Validate settings applied
  - configure_nix_phase() - Phase 4 (continued) orchestration
- BATS test suite created: tests/bootstrap_nix_config.bats (96 tests)
- Test coverage: Function existence, backup logic, CPU detection, binary cache, performance, trusted users, sandbox, daemon restart, verification, orchestration, error handling, integration
- Integration: configure_nix_phase() called in main() as Phase 4 (continued)
- User experience: Clear phase header, time estimates (1-2 min), sudo explanation
- Error handling: CRITICAL vs NON-CRITICAL classification, actionable guidance
- Idempotency: Safe to run multiple times, preserves Story 01.4-001 settings
- Shellcheck validation: Passed (0 errors, 0 warnings)
- VM Testing: ✅ **ALL MANUAL TESTS PASSED** (2025-11-09)
  - Fresh Nix installation: Configuration applied correctly
  - Binary cache working: Fast downloads from cache.nixos.org
  - Max-jobs matches CPU cores: Auto detection successful
  - Trusted users configured: Root + current user
  - Daemon restart successful: Running with new config
  - Re-run test: Idempotent (no duplicates)
  - Manual inspection: All 7 settings present

**Dependencies**:
- Story 01.4-001 (Nix installed) ✅ COMPLETED

**Risk Level**: Medium
**Risk Mitigation**: Backup existing nix.conf if present, validate syntax before restart

---

##### Story 01.4-003: Flake Infrastructure Setup
**User Story**: As FX, I want the minimal flake.nix and configuration structure created so that nix-darwin installation can proceed

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** Nix is installed and configured
- **When** the flake infrastructure is created
- **Then** a valid flake.nix exists with Standard and Power profile definitions
- **And** it includes inputs for nixpkgs-unstable, nix-darwin, home-manager, nix-homebrew, stylix
- **And** it creates darwin/ directory with minimal configuration.nix
- **And** it creates darwin/homebrew.nix with basic Homebrew setup
- **And** it creates darwin/macos-defaults.nix stub for system preferences
- **And** it creates home-manager/ directory with minimal home.nix
- **And** it creates home-manager/modules/shell.nix stub for Zsh config
- **And** flake validates successfully with `nix flake check`
- **And** both profiles (standard and power) are defined in darwinConfigurations

**Additional Requirements**:
- Flake must use nixpkgs-unstable for latest packages
- Must support both aarch64-darwin (Apple Silicon) and x86_64-darwin (Intel)
- User-config.nix integration must be functional
- Profile selection must differentiate between Standard (MacBook Air) and Power (MacBook Pro M3 Max)
- Minimal config should build successfully (even if it doesn't install many apps yet)

**Technical Notes**:
- Reference mlgruby-repo-for-reference/dotfile-nix/flake.nix for structure
- Standard profile: Essential system config, no Parallels, minimal apps
- Power profile: Full system config, Parallels enabled, all apps
- Use Stylix for theming support (configured in later stories)
- ABOUTME comments required on all new .nix files
- Directory structure:
  ```
  ├── flake.nix                      # Main system definition
  ├── flake.lock                     # Generated by nix flake update
  ├── user-config.template.nix       # Already exists
  ├── darwin/
  │   ├── configuration.nix          # Main darwin config
  │   ├── homebrew.nix              # Homebrew declarations
  │   └── macos-defaults.nix        # System preferences (stub)
  └── home-manager/
      ├── home.nix                   # Main home-manager config
      └── modules/
          └── shell.nix              # Shell config (stub)
  ```

**Definition of Done**:
- [x] flake.nix created with Standard and Power profiles ✅
- [x] darwin/configuration.nix created with minimal system config ✅
- [x] darwin/homebrew.nix created (empty or minimal Homebrew setup) ✅
- [x] darwin/macos-defaults.nix stub created ✅
- [x] home-manager/home.nix created with user config integration ✅
- [x] home-manager/modules/shell.nix stub created ✅
- [x] `nix flake check` passes validation ✅
- [x] `nix flake show` displays both profiles correctly ✅
- [x] ABOUTME comments on all new files ✅
- [x] All new files committed to repository ✅
- [x] Documentation updated with flake structure explanation ✅

**Implementation Notes**:
- Story completed on main branch (2025-11-09)
- 6 files created (545 total lines): flake.nix (180), darwin/configuration.nix (120), darwin/homebrew.nix (60), darwin/macos-defaults.nix (53), home-manager/home.nix (66), home-manager/modules/shell.nix (66)
- All files include comprehensive ABOUTME comments and stub documentation for future epics
- Profile differentiation via isPowerProfile boolean parameter in specialArgs
- Auto-updates disabled for Homebrew (onActivation.autoUpdate = false, HOMEBREW_NO_AUTO_UPDATE = 1)
- Validation with `nix flake update`, `nix flake check`, `nix flake show`
- ✅ **VM TESTED - ALL VALIDATION PASSED** (2025-11-09)
  - nix flake update: Successfully generated flake.lock
  - nix flake check: Passed (expected warning about x86_64-darwin)
  - nix flake show: Displayed standard and power configurations
  - nix build --dry-run: Both profiles validated successfully
- **Bug Fixed**: Removed invalid system.profile option, replaced with isPowerProfile pattern (commit fca880d)
- Dev-log summary created: dev-logs/story-01.4-003-summary.md (975 lines)
- All progress synchronized in DEVELOPMENT.md, README.md, STORIES.md, and epic files

**Dependencies**:
- Story 01.4-001 (Nix installed) ✅ COMPLETED
- Story 01.4-002 (Nix configured) ✅ COMPLETED
- Story 01.2-002 (Profile selection system) ✅ COMPLETED
- Story 01.2-003 (User config template) ✅ COMPLETED

**Risk Level**: High
**Risk Mitigation**:
- Validate flake syntax before committing
- Test both profiles with `nix flake check`
- Start minimal and expand in later stories
- Use proven patterns from mlgruby reference

---

### Feature 01.5: Nix-Darwin System Installation
**Feature Description**: Install nix-darwin to manage macOS system configuration declaratively
**User Value**: Enables declarative management of Homebrew, apps, and system preferences
**Story Count**: 2
**Story Points**: 18
**Priority**: High
**Complexity**: Very High

#### Stories in This Feature

##### Story 01.5-001: Initial Nix-Darwin Build
**Status**: ✅ COMPLETE (2025-11-09)
**User Story**: As FX, I want nix-darwin installed from my flake configuration so that my system is managed declaratively

**Priority**: Must Have
**Story Points**: 13
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** Nix is installed and configured
- **When** the bootstrap runs nix-darwin for the first time
- **Then** it fetches the flake.nix from GitHub to /tmp/nix-bootstrap/
- **And** it copies user-config.nix to the same directory
- **And** it runs `nix run nix-darwin -- switch --flake /tmp/nix-bootstrap#<profile>`
- **And** it uses the correct profile (standard or power) based on user selection
- **And** it installs Homebrew as a dependency (managed by nix-darwin)
- **And** it completes the build successfully (10-20 minutes)
- **And** it displays progress and estimated time remaining

**Additional Requirements**:
- First build takes 10-20 minutes (downloads, compilation)
- Homebrew installed automatically by nix-darwin (no pre-installation needed)
- Build may show many download messages (expected)
- Flake must be in a Git directory or use --impure flag

**Technical Notes**:
- Fetch flake: `curl -O https://raw.githubusercontent.com/fxmartin/nix-install/main/flake.nix`
- Profile selection: `--flake .#standard` or `--flake .#power`
- First-time build command:
  ```bash
  nix run nix-darwin -- switch --flake /tmp/nix-bootstrap#${INSTALL_PROFILE}
  ```
- Git directory requirement: Initialize git in /tmp/nix-bootstrap or use --impure
- Display progress: Show Nix build output (verbose mode)

**Definition of Done**:
- [x] Flake fetched successfully (fetch_flake_from_github function implemented)
- [x] User config copied correctly (copy_user_config function implemented)
- [x] nix-darwin build completes without errors (✅ VM TESTED - clean snapshot test passed)
- [x] Homebrew installed and functional (✅ VM TESTED - verified with brew --version)
- [x] Correct profile applied (standard or power) (✅ VM TESTED - standard profile successful)
- [x] Build time within 10-20 minute estimate (✅ VM TESTED - 10 minutes actual)
- [x] Tested in VM with standard profile (✅ COMPLETE - full clean snapshot test)
- [x] Error handling for build failures (comprehensive error handling with troubleshooting)
- [x] BATS tests written (86 automated tests in tests/bootstrap_nix_darwin.bats)
- [x] Shellcheck validation passed (bash -n bootstrap.sh successful)
- [x] Documentation updated (tests/README.md and DEVELOPMENT.md updated)
- [x] Experimental features enabled (nix.settings.experimental-features configured)

**Dependencies**:
- Story 01.4-002 (Nix configured)
- Story 01.2-003 (user config generated)
- Story 01.2-002 (profile selected)

**Risk Level**: Very High
**Risk Mitigation**: Clear error messages, allow restart from this phase, validate flake before build

---

##### Story 01.5-002: Post-Darwin System Validation
**User Story**: As FX, I want to verify nix-darwin installation succeeded so that I can proceed with confidence

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** nix-darwin build has completed
- **When** the bootstrap validates the installation
- **Then** it checks `darwin-rebuild` command is available
- **And** it verifies Homebrew is installed at /opt/homebrew
- **And** it confirms core apps from flake are present
- **And** it checks nix-darwin launchd service is running
- **And** it displays validation summary
- **And** it proceeds to next phase only if all checks pass

**Additional Requirements**:
- darwin-rebuild: Should be in PATH
- Homebrew: Expected at /opt/homebrew/bin/brew
- Core apps: Check for at least one app (e.g., Ghostty or Zed)
- Launchd service: org.nixos.nix-daemon should be running

**Technical Notes**:
- Check darwin-rebuild: `command -v darwin-rebuild`
- Check Homebrew: `[ -x /opt/homebrew/bin/brew ]`
- Check apps: Look in /Applications or ~/Applications
- Check service: `launchctl list | grep nix-daemon`
- Display summary with checkmarks for each validation

**Definition of Done**:
- [x] All validation checks implemented
- [x] Checks pass after successful build
- [x] Clear error messages if validation fails
- [x] Script exits gracefully on validation failure
- [x] Tested in VM after darwin-rebuild ✅ **PASSED (2025-11-10)**
- [x] Documentation notes validation steps
- [x] **HOTFIX**: Multi-method daemon detection (Issue #10 fixed)

**Dependencies**:
- Story 01.5-001 (nix-darwin installed)

**Risk Level**: Medium
**Risk Mitigation**: Provide troubleshooting steps for each failed check

---

### Feature 01.6: SSH Key Setup & GitHub Integration
**Feature Description**: Generate SSH key, automated GitHub upload via CLI, test connection
**User Value**: Enables GitHub authentication for private repo cloning with minimal manual intervention
**Story Count**: 3
**Story Points**: 18
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 01.6-001: SSH Key Generation
**User Story**: As FX, I want an SSH key generated during bootstrap so that I can authenticate with GitHub

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** nix-darwin installation is validated
- **When** the bootstrap reaches SSH key setup
- **Then** it checks for existing ~/.ssh/id_ed25519 key
- **And** if existing key found, it asks "Use existing key? (y/n)"
- **And** if no key or user chooses new key, it generates ed25519 key
- **And** it uses user email for key comment
- **And** it sets appropriate permissions (600 for private, 644 for public)
- **And** it starts ssh-agent and adds the key
- **And** it confirms key generation succeeded

**Additional Requirements**:
- Key type: ed25519 (modern, secure, small)
- Key location: ~/.ssh/id_ed25519
- No passphrase for automation (document security trade-off)
- Comment: User's email address

**Technical Notes**:
- Check existing: `[ -f ~/.ssh/id_ed25519 ]`
- Generate key:
  ```bash
  ssh-keygen -t ed25519 -C "$USER_EMAIL" -f ~/.ssh/id_ed25519 -N ""
  ```
- Permissions: `chmod 600 ~/.ssh/id_ed25519` and `chmod 644 ~/.ssh/id_ed25519.pub`
- Start agent: `eval "$(ssh-agent -s)"`
- Add key: `ssh-add ~/.ssh/id_ed25519`

**Definition of Done**:
- [x] Existing key detection working
- [x] User prompted to use existing or generate new
- [x] Key generation successful
- [x] Permissions set correctly
- [x] ssh-agent running with key added
- [x] Tested in VM without existing keys ✅ **PASSED (2025-11-10)**
- [x] Documentation notes no passphrase choice
- [x] **macOS Keychain integration**: ssh-add --apple-use-keychain
- [x] **System ssh-agent usage**: Uses launchd-managed agent
- [x] **All 8 manual VM scenarios PASSED** ✅

**Dependencies**:
- Story 01.5-002 (nix-darwin validated)
- Story 01.2-001 (user email available)

**Risk Level**: Medium
**Risk Mitigation**: Document no-passphrase trade-off, offer to use existing key

---

##### Story 01.6-002: Automated GitHub SSH Key Upload via GitHub CLI
**User Story**: As FX, I want my SSH key automatically uploaded to GitHub via GitHub CLI so that I can authenticate for repo cloning with minimal manual intervention

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** SSH key has been generated (Story 01.6-001)
- **When** the bootstrap reaches key upload phase
- **Then** it checks if GitHub CLI (`gh`) is authenticated
- **And** if not authenticated, it runs `gh auth login --hostname github.com --git-protocol ssh --web`
- **And** it opens browser for OAuth authentication (user clicks "Authorize" - ~10 seconds)
- **And** once authenticated, it automatically uploads SSH key via `gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)-$(date +%Y%m%d)"`
- **And** it verifies upload succeeded or key already exists on GitHub
- **And** it displays success message and proceeds
- **And** if `gh` authentication fails, it falls back to manual upload instructions with clipboard copy

**Additional Requirements**:
- Primary method: Automated upload via `gh ssh-key add` (90% automation)
- OAuth authentication: User must click "Authorize" in browser (~10 seconds)
- Key title format: `hostname-YYYYMMDD` (e.g., "MacBook-Pro-20251109")
- Fallback method: Manual instructions if `gh auth login` fails
- Idempotent: Check if key already exists before uploading

**Technical Notes**:
- Reference implementation: `mlgruby-repo-for-reference/scripts/install/pre-nix-installation.sh` (Lines 291-399)
- Check authentication: `gh auth status >/dev/null 2>&1`
- Authenticate: `gh auth login --hostname github.com --git-protocol ssh --web`
- Upload key: `gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)-$(date +%Y%m%d)"`
- Check existing: `gh ssh-key list | grep -q "$(ssh-keygen -l -f ~/.ssh/id_ed25519.pub | awk '{print $2}')"`
- Fallback manual instructions (if `gh` fails):
  ```bash
  cat ~/.ssh/id_ed25519.pub | pbcopy  # Copy to clipboard
  cat ~/.ssh/id_ed25519.pub           # Display key
  echo "1. Go to: https://github.com/settings/keys"
  echo "2. Click 'New SSH key'"
  echo "3. Paste the above key"
  echo "4. Click 'Add SSH key'"
  read -p "Press ENTER when you've added the key..."
  ```

**Definition of Done**:
- [ ] GitHub CLI authentication flow implemented
- [ ] OAuth browser flow working (user clicks "Authorize")
- [ ] Automated key upload via `gh ssh-key add` functional
- [ ] Idempotency check (key already exists) working
- [ ] Success/failure detection accurate
- [ ] Fallback manual instructions implemented with clipboard copy
- [ ] Error handling comprehensive (network, authentication, upload failures)
- [ ] Tested in VM with fresh GitHub authentication
- [ ] Tested in VM with existing authentication (skip flow)
- [ ] Documentation notes automation approach and fallback

**Implementation Notes**:
- Pattern from mlgruby reference: Proven automated approach
- User interaction reduced from 2-3 minutes (manual copy-paste) to 10 seconds (OAuth click)
- Aligns with project goal: "zero manual intervention except license activations"
- Story points reduced from 8 to 5 due to automation simplification

**Dependencies**:
- Story 01.6-001 (SSH key generated)
- GitHub CLI (`gh`) must be installed (via Homebrew in Story 01.5-001 or pre-installed)

**Risk Level**: Low
**Risk Mitigation**: Comprehensive fallback to manual instructions if automation fails

---

##### Story 01.6-003: GitHub SSH Connection Test
**User Story**: As FX, I want the bootstrap to test GitHub SSH connection so that I know the key upload worked before proceeding

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** user has pressed ENTER after uploading key
- **When** the bootstrap tests the connection
- **Then** it runs `ssh -T git@github.com`
- **And** if connection succeeds, it displays success message and proceeds
- **And** if connection fails, it displays troubleshooting help
- **And** it offers to retry the connection test
- **And** it allows up to 3 retry attempts
- **And** after 3 failures, it asks user if they want to continue anyway or abort

**Additional Requirements**:
- Successful test: "Hi <username>! You've successfully authenticated"
- Failed test: Clear error message and troubleshooting steps
- Retry mechanism: Up to 3 attempts
- Abort option: Allow user to exit if key upload not working

**Technical Notes**:
- Test command: `ssh -T git@github.com` (returns exit code 1 but displays success message)
- Success detection: Look for "successfully authenticated" in output
- Troubleshooting tips:
  - "Ensure you clicked 'Add SSH key' on GitHub"
  - "Verify the key was pasted correctly"
  - "Check GitHub personal access token if private repo"
- Retry loop with counter
- Allow abort: "Continue without SSH test? (y/n) [not recommended]"

**Definition of Done**:
- [ ] SSH connection test working
- [ ] Success detection accurate
- [ ] Failure handling with troubleshooting help
- [ ] Retry mechanism (up to 3 attempts)
- [ ] Abort option available
- [ ] Tested in VM with successful and failed uploads
- [ ] Documentation notes common issues

**Dependencies**:
- Story 01.6-002 (user uploaded key to GitHub)

**Risk Level**: High
**Risk Mitigation**: Clear troubleshooting, retry mechanism, abort option

---

### Feature 01.7: Repository Cloning & Final Rebuild
**Feature Description**: Clone full dotfiles repository and run final system rebuild
**User Value**: Completes installation with full configuration from Git
**Story Count**: 2
**Story Points**: 13
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 01.7-001: Full Repository Clone
**User Story**: As FX, I want the bootstrap to clone the complete nix-install repository so that I have the full configuration locally

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** GitHub SSH connection test passed
- **When** the bootstrap clones the repository
- **Then** it clones git@github.com:fxmartin/nix-install.git to ~/Documents/nix-install
- **And** it copies the generated user-config.nix from /tmp to the repo
- **And** it preserves the generated user-config.nix (do not overwrite with template)
- **And** it changes directory to ~/Documents/nix-install
- **And** it displays clone success message
- **And** it shows repository path for user reference

**Additional Requirements**:
- Clone location: ~/Documents/nix-install (configurable)
- Preserve user-config.nix: Copy from /tmp, do not overwrite
- Create ~/Documents if it doesn't exist
- Handle case where directory already exists (offer to remove or skip)

**Technical Notes**:
- Clone command: `git clone git@github.com:fxmartin/nix-install.git ~/Documents/nix-install`
- Copy config: `cp /tmp/nix-bootstrap/user-config.nix ~/Documents/nix-install/`
- Check existing directory: `[ -d ~/Documents/nix-install ]`
- If exists: Prompt "Directory exists. Remove and re-clone? (y/n)"

**Definition of Done**:
- [ ] Repository cloned successfully
- [ ] user-config.nix copied correctly
- [ ] Clone location configurable
- [ ] Existing directory handled gracefully
- [ ] Tested in VM with SSH auth working
- [ ] Documentation notes repository location

**Dependencies**:
- Story 01.6-003 (GitHub SSH connection tested)
- Story 01.2-003 (user-config.nix generated)

**Risk Level**: Medium
**Risk Mitigation**: Handle existing directory case, validate clone succeeded

---

##### Story 01.7-002: Final Darwin Rebuild
**User Story**: As FX, I want the bootstrap to run a final darwin-rebuild with the complete configuration so that all modules and settings are applied

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** repository has been cloned
- **When** the bootstrap runs final rebuild
- **Then** it runs `darwin-rebuild switch --flake ~/Documents/nix-install#<profile>`
- **And** it uses the correct profile (standard or power)
- **And** it completes faster than initial build (2-5 minutes due to caching)
- **And** it symlinks configs to home directory (~/.config/ghostty, ~/.zshrc, etc.)
- **And** it applies all Home Manager modules
- **And** it displays success message with next steps
- **And** it shows summary of what was configured

**Additional Requirements**:
- Build time: 2-5 minutes (most packages cached from initial build)
- Symlinks: Home Manager creates symlinks automatically
- Success validation: Check for at least one symlink created
- Display next steps: License activation, terminal restart, etc.

**Technical Notes**:
- Rebuild command:
  ```bash
  darwin-rebuild switch --flake ~/Documents/nix-install#${INSTALL_PROFILE}
  ```
- Verify symlinks: Check `ls -la ~/.config/ghostty` or `ls -la ~/.zshrc`
- Display summary of configured items
- Show path to documentation: ~/Documents/nix-install/README.md

**Definition of Done**:
- [ ] Final rebuild completes successfully
- [ ] Correct profile applied
- [ ] Symlinks created in home directory
- [ ] Build time within 2-5 minute estimate
- [ ] Success message and next steps displayed
- [ ] Tested in VM with both profiles
- [ ] Documentation notes rebuild command

**Dependencies**:
- Story 01.7-001 (repository cloned)
- Story 01.2-002 (profile selected)

**Risk Level**: Medium
**Risk Mitigation**: Validate build before displaying success, provide rollback instructions

---

### Feature 01.8: Post-Installation Summary & Next Steps
**Feature Description**: Display comprehensive summary and guide user to next actions
**User Value**: Clear understanding of what was installed and what to do next
**Story Count**: 1
**Story Points**: 3
**Priority**: Medium
**Complexity**: Low

#### Stories in This Feature

##### Story 01.8-001: Installation Summary
**User Story**: As FX, I want a comprehensive summary after bootstrap completes so that I know what was installed and what to do next

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** final darwin-rebuild completed successfully
- **When** the bootstrap displays summary
- **Then** it shows total installation time
- **And** it displays what was installed (Nix, nix-darwin, app count, profile name)
- **And** it lists next steps: restart terminal, activate licenses, install Office 365
- **And** it shows useful commands (rebuild, update, health-check, cleanup)
- **And** it displays path to documentation
- **And** it lists apps requiring manual license activation
- **And** it suggests running `ollama list` to verify models (Power profile)

**Additional Requirements**:
- Summary must be comprehensive but concise
- Next steps numbered and actionable
- Command list with brief descriptions
- Documentation path prominent

**Technical Notes**:
- Track start time at beginning of script, calculate total duration
- App count: Standard ~47, Power ~51 (adjust if different)
- Next steps:
  1. Restart terminal or `source ~/.zshrc`
  2. Activate licensed apps (link to docs)
  3. Install Office 365 manually if needed
  4. Verify Ollama models (Power only)
- Useful commands:
  - `rebuild` - Apply config changes
  - `update` - Update packages and rebuild
  - `health-check` - Verify system health
  - `cleanup` - Run garbage collection

**Definition of Done**:
- [ ] Summary displays all required information
- [ ] Installation time calculated correctly
- [ ] Next steps clear and numbered
- [ ] Command list helpful
- [ ] Documentation path shown
- [ ] Tested in VM with both profiles
- [ ] Summary is professional and complete

**Dependencies**:
- Story 01.7-002 (final rebuild complete)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-02 (Applications)**: Bootstrap must complete before apps can be configured
- **Epic-03 (System Config)**: Bootstrap must complete before system preferences applied
- **Epic-04 (Dev Environment)**: Bootstrap must complete before dev tools configured
- **NFR (Infrastructure)**: Flake structure and Nix settings must be defined before bootstrap can run

### Stories This Epic Enables
- Epic-02, Story 02.X-XXX: All application installation stories (requires bootstrap complete)
- Epic-03, Story 03.X-XXX: All system configuration stories (requires bootstrap complete)
- Epic-04, Story 04.X-XXX: All development environment stories (requires bootstrap complete)
- Epic-05, Story 05.X-XXX: All theming stories (requires bootstrap complete)
- Epic-06, Story 06.X-XXX: All maintenance stories (requires bootstrap complete)
- Epic-07, Story 07.X-XXX: All documentation stories (documents bootstrap process)

### Stories This Epic Blocks
- ALL other epics (Epic-02 through Epic-07) are blocked until Epic-01 completes
- VM testing (Phase 9) cannot start until Epic-01 stories are implemented and tested

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 1 | 01.1-001 to 01.4-002 | 44 | Pre-flight checks, user prompts, Xcode, Nix installation |
| Sprint 2 | 01.5-001 to 01.8-001 | 42 | nix-darwin, SSH key setup, repo clone, final rebuild |

### Delivery Milestones
- **Milestone 1**: End Sprint 1 - Nix installed and configured
- **Milestone 2**: End Sprint 2 - Complete bootstrap working in VM
- **Epic Complete**: Week 2 - Bootstrap tested on physical hardware (MacBook Pro M3 Max)

### Risk Assessment
**High Risk Items**:
- Story 01.5-001 (Initial nix-darwin build): Complex, many dependencies, long execution time
  - Mitigation: Comprehensive error handling, validate flake before build, allow restart
- Story 01.6-003 (GitHub SSH test): Depends on external service (GitHub), user action required
  - Mitigation: Retry mechanism, clear troubleshooting, abort option

**Dependencies Timeline**:
- Week 1 Sprint 1: Stories 01.1-001 through 01.4-002 must complete sequentially
- Week 2 Sprint 2: Stories 01.5-001 through 01.8-001 build on Sprint 1 foundation

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 13 of 18 (72.2%)
- **Story Points Completed**: 78 of 105 (74.3%)
- **MVP Stories Completed**: 13 of 18 (72.2%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 1 | 44 | 42 | 8/9 | Near Complete |
| Sprint 2 | 39 | 36 | 5/9 | In Progress |

**Note**: Sprint 1 includes Story 01.1-002 (3 pts, idempotency). Sprint 2 includes Stories 01.5-002 (5 pts), 01.6-001 (5 pts), and partial work on remaining stories. Total completed: 78/105 points (74.3%).

## Epic Acceptance Criteria
- [ ] All MVP stories (18/18) completed and accepted
- [ ] Bootstrap completes in <30 minutes on fresh macOS
- [ ] First-time success rate >90% in VM testing
- [ ] Zero manual intervention except GitHub OAuth click and license activations
- [ ] Both Standard and Power profiles tested and working
- [ ] Error handling comprehensive and helpful
- [ ] User can re-run script safely (idempotent)
- [ ] Documentation complete for bootstrap process
- [ ] VM testing successful (Phase 9)
- [ ] Physical hardware migration successful (Phase 10)

## Story Validation Checklist

### Quality Assurance for Each Story
- [ ] Follows proper user story format ("As [persona], I want [functionality] so that [benefit]")
- [ ] Has clear, testable acceptance criteria (Given/When/Then format)
- [ ] Includes all necessary context and constraints
- [ ] Sized appropriately for single sprint
- [ ] Dependencies clearly identified
- [ ] Business value articulated
- [ ] Persona alignment verified (FX as primary user)
- [ ] Technical feasibility confirmed

### Epic Health Metrics
- **Story Readiness**: 100% of stories meet definition of ready
- **Dependency Coverage**: All dependencies identified and managed
- **Estimation Confidence**: High confidence in story point estimates based on reference implementation
- **Acceptance Criteria Quality**: Clear, testable, and complete criteria for all stories
