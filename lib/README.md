# Bootstrap Library Modules

This directory contains the modular components of the bootstrap installer system.

## Overview

The bootstrap system has been split into 10 focused modules, each responsible for a specific phase or concern. The modules are sourced by `bootstrap.sh` in dependency order.

## Module Structure

Each module follows this pattern:

```bash
# ABOUTME: Brief description of module purpose
# ABOUTME: Additional context about dependencies
# ABOUTME: Depends on: list of required modules

# Guard against double-sourcing
[[ -n "${_MODULE_NAME_SH_LOADED:-}" ]] && return 0
readonly _MODULE_NAME_SH_LOADED=1

# Module functions...
```

## Module Directory

### Core Infrastructure

**common.sh** (282 lines, 12 functions)
- Color codes and global constants
- Logging functions (log_info, log_warn, log_error, log_success)
- Input handling (read_input with /dev/tty fallback)
- Phase progress indicators
- System validation (macOS version, not root, internet, Full Disk Access)
- **Required by**: All other modules
- **Dependencies**: None

### Phase Modules

**preflight.sh** (58 lines, 1 function)
- Phase 1: Pre-flight system validation orchestrator
- Runs all system checks before starting installation
- **Dependencies**: common.sh

**user-config.sh** (698 lines, 17 functions)
- Phase 2: User information and profile selection
- Email, GitHub username, name validation
- Idempotency check for existing user-config.nix
- Interactive prompts for user data
- Profile selection (Standard vs Power)
- user-config.nix file generation
- **Dependencies**: common.sh

**xcode.sh** (136 lines, 5 functions)
- Phase 3: Xcode Command Line Tools installation
- Check if already installed
- Trigger installation dialog
- Wait for completion
- Verify installation
- **Dependencies**: common.sh

**nix-install.sh** (609 lines, 16 functions)
- Phase 4: Nix package manager installation and configuration
- Download official Nix installer
- Multi-user installation
- Enable experimental flakes feature
- Binary cache configuration
- Performance tuning (CPU cores, parallel builds)
- Trusted users setup
- Sandbox configuration
- **Dependencies**: common.sh

**nix-darwin.sh** (1,090 lines, 13 functions)
- Phase 5: nix-darwin installation and validation
- Download flake files from GitHub (50+ files)
- Initialize Git repository for flake
- Backup /etc files
- Run darwin-rebuild switch
- Validate installation (darwin-rebuild, Homebrew, core apps, nix-daemon)
- **Dependencies**: common.sh, nix-install.sh

**ssh-github.sh** (1,038 lines, 19 functions)
- Phase 6: SSH key generation and GitHub authentication
- Ensure ~/.ssh directory with proper permissions
- Check for existing SSH keys
- Generate new ed25519 SSH key
- Start ssh-agent and add key
- Authenticate GitHub CLI
- Upload SSH key to GitHub (via gh CLI or manual fallback)
- Test SSH connection to GitHub
- **Dependencies**: common.sh, nix-darwin.sh (requires gh CLI from Homebrew)

**repo-clone.sh** (374 lines, 8 functions)
- Phase 7: Repository cloning
- Create ~/Documents directory
- Check for existing repository
- Clone nix-install repository via SSH
- Copy user-config.nix to repository
- Verify clone success
- **Dependencies**: common.sh, ssh-github.sh (requires SSH key)

**darwin-rebuild.sh** (290 lines, 5 functions)
- Phase 8: Final darwin-rebuild with full configuration
- Load selected profile from user-config.nix
- Run final darwin-rebuild switch --flake
- Verify Home Manager symlinks
- Display success message
- **Dependencies**: common.sh, repo-clone.sh (requires repository)

**summary.sh** (298 lines, 9 functions)
- Phase 9: Installation summary and next steps
- Format installation duration
- Display installed components
- Check FileVault status
- Display next steps and useful commands
- List apps requiring manual activation
- Show documentation paths
- **Dependencies**: common.sh

## Dependency Graph

```
common.sh (required by all)
    ├── preflight.sh
    ├── user-config.sh
    ├── xcode.sh
    ├── nix-install.sh
    │   └── nix-darwin.sh
    │       └── ssh-github.sh
    │           └── repo-clone.sh
    │               └── darwin-rebuild.sh
    └── summary.sh
```

## Sourcing Order

Modules must be sourced in this order (as done in bootstrap.sh):

```bash
1. lib/common.sh      # Required by all modules
2. lib/preflight.sh   # Uses common.sh
3. lib/user-config.sh # Uses common.sh
4. lib/xcode.sh       # Uses common.sh
5. lib/nix-install.sh # Uses common.sh
6. lib/nix-darwin.sh  # Uses common.sh + nix-install.sh
7. lib/ssh-github.sh  # Uses common.sh + nix-darwin.sh (gh CLI)
8. lib/repo-clone.sh  # Uses common.sh + ssh-github.sh
9. lib/darwin-rebuild.sh # Uses common.sh + repo-clone.sh
10. lib/summary.sh    # Uses common.sh
```

## Usage Patterns

### In Bootstrap Script

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all modules
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/preflight.sh"
source "${SCRIPT_DIR}/lib/user-config.sh"
# ... etc

# Use functions
log_info "Starting installation"
preflight_checks
install_xcode_phase
```

### In Custom Scripts

```bash
#!/usr/bin/env bash
set -euo pipefail

# Source only needed modules
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/nix-install.sh"

# Use module functions
log_info "Checking Nix installation"
check_nix_installed || install_nix_phase
```

### Standalone Usage

```bash
# Source module for one-off commands
source lib/common.sh
log_success "Test message"

# Or use in pipeline
source lib/common.sh
source lib/nix-install.sh
check_nix_installed && echo "Nix is installed"
```

## Building Standalone Version

Use `scripts/build-bootstrap.sh` to concatenate all modules into a single file:

```bash
./scripts/build-bootstrap.sh

# Generates: bootstrap-dist.sh (5,135 lines)
# - All modules concatenated
# - Double-sourcing guards removed
# - Module headers added
# - Syntax validated with bash -n
```

## Testing Individual Modules

```bash
# Syntax validation
bash -n lib/common.sh

# ShellCheck (if installed)
shellcheck lib/common.sh

# Function existence test
bash -c 'source lib/common.sh && type log_info'

# BATS tests (when implemented)
bats tests/lib/common.bats
```

## Module Conventions

### Naming
- Use snake_case for function names
- Prefix phase functions with phase name: `install_xcode_phase`
- Group related functions: `check_*`, `install_*`, `verify_*`

### Documentation
- ABOUTME comments at top of file
- Function comments explaining purpose and parameters
- Return value documentation (0 = success, 1 = failure)

### Error Handling
- Use `return 1` for errors, not `exit 1` (allows caller to handle)
- Log errors with `log_error` before returning
- Use shellcheck disables sparingly with explanations

### Global Variables
- Use `readonly` for constants defined in common.sh
- Use local variables in functions: `local var_name`
- Document global variables used across modules

## Contributing

When modifying modules:

1. **Preserve signatures**: Don't change function names or parameters
2. **Test syntax**: Run `bash -n` before committing
3. **Update dependencies**: Document new inter-module dependencies
4. **Rebuild dist**: Run `./scripts/build-bootstrap.sh` to update bootstrap-dist.sh
5. **Follow conventions**: Match existing code style

## Troubleshooting

### Module Not Found Error

```bash
ERROR: lib/common.sh not found. Cannot continue.
```

**Cause**: bootstrap.sh can't find lib/ directory
**Solution**: Run from project root or set SCRIPT_DIR correctly

### Sourcing Fails

```bash
Failed to source lib/user-config.sh
```

**Cause**: Syntax error in module or dependency missing
**Solution**: Run `bash -n lib/user-config.sh` to check syntax

### Function Not Defined

```bash
bash: log_info: command not found
```

**Cause**: common.sh not sourced or sourcing failed
**Solution**: Ensure `source lib/common.sh` runs before calling function

### Double-Sourcing Warning

If you see duplicate function definitions, check for:
- Missing double-sourcing guard
- Incorrect guard variable name
- Sourcing same module twice

## References

- **Main Bootstrap**: /Users/fxmartin/Documents/nix-install/bootstrap.sh
- **Build Script**: /Users/fxmartin/Documents/nix-install/scripts/build-bootstrap.sh
- **Monolithic Backup**: /Users/fxmartin/Documents/nix-install/bootstrap.sh.monolithic
- **Documentation**: /Users/fxmartin/Documents/nix-install/docs/development/modularization-summary.md

## Version History

- **v1.0.0** (2025-12-07): Initial modularization (Story 01.1-004)
  - Split 5,081-line monolithic script into 10 modules
  - Created build system for standalone distribution
  - All 105 functions preserved with identical signatures
