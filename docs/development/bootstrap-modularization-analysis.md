# Bootstrap.sh Modularization Analysis

**Total Lines**: 5,081 lines
**Total Functions**: 105 functions
**Current Status**: Monolithic file with 9 phases

---

## Function Distribution by Module

### lib/common.sh (12 functions, ~500 lines)
**Purpose**: Logging, colors, utilities, system info

| Function | Lines | Description |
|----------|-------|-------------|
| log_info() | 76-78 | Info logging with green color |
| log_warn() | 80-82 | Warning logging with yellow color |
| log_error() | 84-86 | Error logging with red color |
| log_success() | 88-90 | Success logging with green color |
| read_input() | 95-111 | Read user input with /dev/tty fallback |
| log_phase() | 116-131 | Phase progress indicator |
| log_phase_complete() | 135-143 | Phase completion indicator |
| check_macos_version() | 146-163 | Validate macOS version (14.0+) |
| check_not_root() | 165-176 | Ensure not running as root |
| check_internet() | 178-203 | Test internet connectivity |
| check_terminal_full_disk_access() | 205-278 | Verify terminal has full disk access |
| display_system_info() | 280-292 | Show system information |

**Estimated Lines**: ~500 (includes color constants, globals, helper functions)

---

### lib/preflight.sh (1 function, ~50 lines)
**Purpose**: Phase 1 - Pre-flight validation orchestrator

| Function | Lines | Description |
|----------|-------|-------------|
| preflight_checks() | 981-1023 | Run all pre-flight validation checks |

**Note**: This module orchestrates common.sh validation functions

**Estimated Lines**: ~50

---

### lib/user-config.sh (17 functions, ~800 lines)
**Purpose**: Phase 2 - User configuration and profile selection

| Function | Lines | Description |
|----------|-------|-------------|
| validate_email() | 301-318 | Validate email format |
| validate_github_username() | 320-343 | Validate GitHub username |
| validate_name() | 345-360 | Validate full name |
| check_existing_user_config() | 376-457 | Check for existing user config (idempotency) |
| prompt_user_info() | 459-558 | Interactive user information prompts |
| create_bootstrap_workdir() | 560-572 | Create work directory |
| get_macos_username() | 574-580 | Get current macOS username |
| get_macos_hostname() | 582-603 | Get macOS hostname |
| validate_nix_syntax() | 605-643 | Validate generated Nix config syntax |
| display_generated_config() | 645-672 | Display generated config preview |
| generate_user_config() | 674-785 | Generate user-config.nix file |
| validate_profile_choice() | 787-806 | Validate profile selection input |
| convert_profile_choice_to_name() | 808-829 | Convert choice to profile name |
| display_profile_options() | 831-855 | Display Standard/Power profile options |
| get_profile_display_name() | 857-874 | Get human-readable profile name |
| confirm_profile_choice() | 876-896 | Confirm profile selection |
| select_installation_profile() | 898-943 | Interactive profile selection |
| prompt_mas_apps_preference() | 945-978 | Ask about Mac App Store apps |

**Estimated Lines**: ~800

---

### lib/xcode.sh (5 functions, ~100 lines)
**Purpose**: Phase 3 - Xcode CLI Tools installation

| Function | Lines | Description |
|----------|-------|-------------|
| check_xcode_installed() | 1035-1043 | Check if Xcode CLI Tools installed |
| install_xcode_cli_tools() | 1047-1059 | Trigger installation dialog |
| wait_for_xcode_installation() | 1064-1088 | Wait for user to complete install |
| verify_xcode_installation() | 1090-1111 | Verify successful installation |
| install_xcode_phase() | 1113-1151 | Phase orchestrator |

**Estimated Lines**: ~120

---

### lib/nix-install.sh (15 functions, ~850 lines)
**Purpose**: Phase 4 - Nix package manager installation + configuration

| Function | Lines | Description |
|----------|-------|-------------|
| check_nix_installed() | 1168-1180 | Check if Nix already installed |
| download_nix_installer() | 1190-1224 | Download official Nix installer |
| install_nix_multi_user() | 1226-1264 | Run multi-user Nix installation |
| enable_nix_flakes() | 1266-1310 | Enable experimental flakes feature |
| source_nix_environment() | 1312-1344 | Source Nix environment variables |
| verify_nix_installation() | 1346-1407 | Verify Nix installation success |
| install_nix_phase() | 1409-1461 | Phase 4 orchestrator (installation) |
| backup_nix_config() | 1478-1504 | Backup existing nix.conf |
| get_cpu_cores() | 1506-1521 | Detect CPU core count |
| configure_nix_binary_cache() | 1523-1551 | Configure binary cache settings |
| configure_nix_performance() | 1553-1584 | Configure performance tuning |
| configure_nix_trusted_users() | 1586-1613 | Add user to trusted-users |
| configure_nix_sandbox() | 1615-1642 | Configure sandbox settings |
| restart_nix_daemon() | 1644-1662 | Restart nix-daemon |
| verify_nix_configuration() | 1664-1700 | Verify configuration applied |
| configure_nix_phase() | 1702-1752 | Phase 4 orchestrator (configuration) |

**Estimated Lines**: ~850

---

### lib/nix-darwin.sh (10 functions, ~1100 lines)
**Purpose**: Phase 5 - nix-darwin installation and validation

| Function | Lines | Description |
|----------|-------|-------------|
| fetch_flake_from_github() | 1763-2175 | Download flake files from GitHub (MASSIVE) |
| copy_user_config() | 2177-2222 | Copy user-config.nix to flake dir |
| initialize_git_for_flake() | 2224-2277 | Initialize Git repo for flake |
| backup_etc_files_for_darwin() | 2279-2335 | Backup /etc files before darwin |
| run_nix_darwin_build() | 2337-2409 | Run darwin-rebuild switch |
| verify_nix_darwin_installed() | 2411-2449 | Verify nix-darwin installation |
| install_nix_darwin_phase() | 2451-2509 | Phase 5 orchestrator |
| check_darwin_rebuild() | 2520-2555 | Validate darwin-rebuild available |
| check_homebrew_installed() | 2557-2596 | Verify Homebrew installed |
| check_core_apps_present() | 2598-2640 | Verify core apps installed |
| check_nix_daemon_running() | 2642-2682 | Verify nix-daemon running |
| display_validation_summary() | 2684-2749 | Display validation results |
| validate_nix_darwin_phase() | 2751-2834 | Phase 5 validation orchestrator |

**Note**: `fetch_flake_from_github()` is 413 lines - may need further breakdown

**Estimated Lines**: ~1100

---

### lib/ssh-github.sh (17 functions, ~1050 lines)
**Purpose**: Phase 6 - SSH key generation + GitHub authentication

| Function | Lines | Description |
|----------|-------|-------------|
| ensure_ssh_directory() | 2849-2888 | Create ~/.ssh with proper permissions |
| check_existing_ssh_key() | 2890-2906 | Check for existing SSH key |
| prompt_use_existing_key() | 2908-2947 | Ask to use existing key |
| generate_ssh_key() | 2949-3013 | Generate new ed25519 SSH key |
| set_ssh_key_permissions() | 3015-3084 | Set restrictive file permissions |
| start_ssh_agent_and_add_key() | 3086-3205 | Start ssh-agent and add key |
| display_ssh_key_summary() | 3207-3249 | Display key generation summary |
| setup_ssh_key_phase() | 3251-3320 | Phase 6 orchestrator (key setup) |
| check_github_cli_authenticated() | 3322-3334 | Check gh CLI auth status |
| authenticate_github_cli() | 3336-3483 | Authenticate with GitHub CLI |
| check_key_exists_on_github() | 3485-3517 | Check if key already on GitHub |
| upload_ssh_key_to_github() | 3519-3558 | Upload key via gh CLI |
| fallback_manual_key_upload() | 3560-3612 | Manual key upload instructions |
| upload_github_key_phase() | 3614-3677 | Phase 6 orchestrator (key upload) |
| test_github_ssh_connection() | 3679-3707 | Test SSH connection to GitHub |
| display_ssh_troubleshooting() | 3709-3747 | SSH troubleshooting help |
| retry_ssh_connection() | 3749-3787 | Retry SSH connection with delay |
| prompt_continue_without_ssh() | 3789-3835 | Ask to continue without SSH |
| test_github_ssh_phase() | 3837-3865 | Phase 6 orchestrator (SSH test) |

**Estimated Lines**: ~1050

---

### lib/repo-clone.sh (8 functions, ~350 lines)
**Purpose**: Phase 7 - Repository cloning

| Function | Lines | Description |
|----------|-------|-------------|
| create_documents_directory() | 3874-3896 | Ensure ~/Documents exists |
| check_existing_repo_directory() | 3898-3907 | Check for existing repo |
| prompt_remove_existing_repo() | 3909-3941 | Ask to remove existing repo |
| remove_existing_repo_directory() | 3943-3967 | Remove existing repo dir |
| clone_repository() | 3969-4012 | Git clone repository |
| copy_user_config_to_repo() | 4014-4064 | Copy user config to cloned repo |
| verify_repository_clone() | 4066-4117 | Verify clone success |
| display_clone_success_message() | 4119-4136 | Display success message |
| clone_repository_phase() | 4138-4231 | Phase 7 orchestrator |

**Estimated Lines**: ~350

---

### lib/darwin-rebuild.sh (6 functions, ~350 lines)
**Purpose**: Phase 8 - Final darwin-rebuild

| Function | Lines | Description |
|----------|-------|-------------|
| load_profile_from_user_config() | 4243-4283 | Load selected profile from config |
| run_final_darwin_rebuild() | 4285-4348 | Run final darwin-rebuild switch |
| verify_home_manager_symlinks() | 4350-4387 | Verify Home Manager dotfiles |
| display_rebuild_success_message() | 4389-4454 | Display success message |
| final_darwin_rebuild_phase() | 4456-4513 | Phase 8 orchestrator |

**Estimated Lines**: ~260

---

### lib/summary.sh (9 functions, ~350 lines)
**Purpose**: Phase 9 - Installation summary and next steps

| Function | Lines | Description |
|----------|-------|-------------|
| format_installation_duration() | 4527-4592 | Format time duration |
| display_installed_components() | 4594-4625 | List installed components |
| check_filevault_status() | 4627-4641 | Check FileVault encryption |
| display_filevault_prompt() | 4643-4684 | Prompt to enable FileVault |
| display_next_steps() | 4686-4708 | Display next steps |
| display_useful_commands() | 4710-4727 | Display useful commands |
| display_manual_activation_apps() | 4729-4748 | List apps needing activation |
| display_documentation_paths() | 4750-4764 | Show documentation paths |
| installation_summary_phase() | 4766-4803 | Phase 9 orchestrator |

**Estimated Lines**: ~280

---

### bootstrap.sh (Main orchestrator, ~200 lines)
**Purpose**: Main entry point, phase orchestration

| Function | Lines | Description |
|----------|-------|-------------|
| main() | 4805-5081 | Main orchestrator calling all phases |

**Contents**:
- Shebang and header comments (1-73)
- Global constants and variables (49-73)
- Source all library modules (new)
- main() function (orchestrator)

**Estimated Lines**: ~200

---

## Module Size Summary

| Module | Functions | Est. Lines | Complexity |
|--------|-----------|------------|------------|
| lib/common.sh | 12 | ~500 | Low |
| lib/preflight.sh | 1 | ~50 | Low |
| lib/user-config.sh | 17 | ~800 | Medium |
| lib/xcode.sh | 5 | ~120 | Low |
| lib/nix-install.sh | 16 | ~850 | Medium |
| lib/nix-darwin.sh | 13 | ~1100 | High |
| lib/ssh-github.sh | 19 | ~1050 | High |
| lib/repo-clone.sh | 8 | ~350 | Medium |
| lib/darwin-rebuild.sh | 5 | ~260 | Low |
| lib/summary.sh | 9 | ~280 | Low |
| bootstrap.sh (main) | 1 | ~200 | Low |
| **TOTAL** | **106** | **~5560** | - |

**Note**: Estimated ~5560 lines vs actual 5081 lines due to overlap in section headers, comments, and spacing. Actual module sizes will be smaller when deduplicated.

---

## Critical Dependencies

### Inter-Module Dependencies
- **All modules depend on**: lib/common.sh (logging, colors, system checks)
- **lib/nix-install.sh requires**: lib/common.sh
- **lib/nix-darwin.sh requires**: lib/common.sh, lib/nix-install.sh (Nix must be installed)
- **lib/ssh-github.sh requires**: lib/common.sh, lib/nix-darwin.sh (gh CLI installed via Homebrew)
- **lib/repo-clone.sh requires**: lib/common.sh, lib/ssh-github.sh (SSH key needed)
- **lib/darwin-rebuild.sh requires**: lib/common.sh, lib/repo-clone.sh (repo must exist)
- **lib/summary.sh requires**: lib/common.sh

### Source Order (in bootstrap.sh)
```bash
# Source libraries in dependency order
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/preflight.sh"
source "${SCRIPT_DIR}/lib/user-config.sh"
source "${SCRIPT_DIR}/lib/xcode.sh"
source "${SCRIPT_DIR}/lib/nix-install.sh"
source "${SCRIPT_DIR}/lib/nix-darwin.sh"
source "${SCRIPT_DIR}/lib/ssh-github.sh"
source "${SCRIPT_DIR}/lib/repo-clone.sh"
source "${SCRIPT_DIR}/lib/darwin-rebuild.sh"
source "${SCRIPT_DIR}/lib/summary.sh"
```

---

## Functions Requiring Special Attention

### Massive Functions (>200 lines)
1. **fetch_flake_from_github()** (1763-2175): 413 lines
   - Downloads ~50 individual files from GitHub
   - May benefit from sub-functions or data-driven approach
   - Consider: array of files with loop instead of 50 curl commands

2. **prompt_user_info()** (459-558): 100 lines
   - Interactive prompts for user data
   - Could be split into: prompt_email(), prompt_github(), prompt_name()

3. **generate_user_config()** (674-785): 112 lines
   - Template generation for user-config.nix
   - Could use heredoc or separate template file

### Functions with External Dependencies
- **authenticate_github_cli()**: Requires `gh` binary (installed via Homebrew/nix-darwin)
- **upload_ssh_key_to_github()**: Requires `gh` binary
- **check_key_exists_on_github()**: Requires `gh` binary
- **run_nix_darwin_build()**: Requires nix-darwin installed
- **run_final_darwin_rebuild()**: Requires repository cloned

---

## Modularization Benefits

### Maintainability
- **Single Responsibility**: Each module has one clear purpose
- **Easier Testing**: Test individual modules in isolation
- **Code Reuse**: Libraries can be sourced by other scripts
- **Reduced Cognitive Load**: ~500-1100 lines per module vs 5081 lines

### Debugging
- **Isolated Failures**: Easier to identify which phase/module failed
- **Granular Logging**: Module-specific log prefixes
- **Faster Iteration**: Modify one module without affecting others

### Collaboration
- **Parallel Development**: Multiple developers can work on different modules
- **Code Review**: Smaller, focused PRs per module
- **Documentation**: Each module can have dedicated README

---

## Next Steps (Story 01.9-001 Implementation)

### Phase 1: Create lib/ Directory Structure
```bash
mkdir -p lib
```

### Phase 2: Extract Common Functions (lib/common.sh)
- Move logging functions (log_info, log_warn, log_error, log_success)
- Move color constants (RED, GREEN, YELLOW, NC)
- Move global variables (BOOTSTRAP_VERSION, MIN_MACOS_VERSION, etc.)
- Move system check functions (check_macos_version, check_not_root, etc.)
- Add module header with ABOUTME comment

### Phase 3: Extract Phase-Specific Modules (in order)
1. lib/user-config.sh (Phase 2 functions)
2. lib/xcode.sh (Phase 3 functions)
3. lib/nix-install.sh (Phase 4 functions)
4. lib/nix-darwin.sh (Phase 5 functions)
5. lib/ssh-github.sh (Phase 6 functions)
6. lib/repo-clone.sh (Phase 7 functions)
7. lib/darwin-rebuild.sh (Phase 8 functions)
8. lib/summary.sh (Phase 9 functions)

### Phase 4: Create Simplified bootstrap.sh
- Keep main() function
- Source all library modules
- Minimal orchestration logic
- Preserve original bootstrap.sh as bootstrap.sh.monolithic

### Phase 5: Testing Strategy
- ShellCheck validation for each module
- BATS test for each module's functions
- Integration test for full bootstrap flow
- VM testing (FX only)

---

## Risks and Mitigations

### Risk: Sourcing Order Dependencies
**Mitigation**: Strict source order, add dependency comments in each module

### Risk: Global Variable Conflicts
**Mitigation**: Use readonly for constants, namespace variables if needed

### Risk: Breaking Existing Functionality
**Mitigation**: Keep bootstrap.sh.monolithic as backup, extensive testing

### Risk: Increased Complexity for Users
**Mitigation**: bootstrap.sh remains single entry point, libraries are transparent

---

## Success Criteria (Story 01.9-001 Acceptance)

- [ ] All 10 library modules created in lib/ directory
- [ ] bootstrap.sh reduced to <300 lines (main orchestrator only)
- [ ] All 105 functions relocated to appropriate modules
- [ ] ShellCheck passes for all modules
- [ ] BATS tests cover all modules
- [ ] VM test succeeds with modular structure
- [ ] Original bootstrap.sh preserved as bootstrap.sh.monolithic
- [ ] Documentation updated (README.md, CLAUDE.md)

---

## File Size Verification

```bash
# Current monolithic file
$ wc -l bootstrap.sh
5081 bootstrap.sh

# Expected modular structure total (with overhead)
$ wc -l lib/*.sh bootstrap.sh
  500 lib/common.sh
   50 lib/preflight.sh
  800 lib/user-config.sh
  120 lib/xcode.sh
  850 lib/nix-install.sh
 1100 lib/nix-darwin.sh
 1050 lib/ssh-github.sh
  350 lib/repo-clone.sh
  260 lib/darwin-rebuild.sh
  280 lib/summary.sh
  200 bootstrap.sh
 5560 total
```

**Note**: Actual total will be ~5200-5400 lines due to module headers, documentation, and some code deduplication.

