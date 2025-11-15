# ABOUTME: Epic-04 Feature 04.5 (Shell Aliases and Functions) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 04.5

# Epic-04 Feature 04.5: Shell Aliases and Functions

## Feature Overview

**Feature ID**: Feature 04.5
**Feature Name**: Shell Aliases and Functions
**Epic**: Epic-04
**Status**: 🔄 In Progress

### Feature 04.5: Shell Aliases and Functions
**Feature Description**: Configure useful shell aliases for Nix operations and daily tasks
**User Value**: Quick commands for rebuild, update, cleanup, and common operations
**Story Count**: 2
**Story Points**: 10
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 04.5-001: Core Nix Aliases
**User Story**: As FX, I want aliases for rebuild, update, and cleanup commands so that I can manage my system efficiently

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `rebuild`
- **Then** it executes `darwin-rebuild switch --flake ~/Documents/nix-install#$(hostname -s)`
- **And** applies current configuration changes
- **When** I run `update`
- **Then** it updates flake.lock and rebuilds (updates ALL apps and system)
- **When** I run `gc`
- **Then** it runs `nix-collect-garbage -d` (garbage collection)
- **When** I run `cleanup`
- **Then** it runs garbage collection + nix-store optimization
- **And** all aliases work in fresh terminal

**Additional Requirements**:
- rebuild: Apply config changes (uses current flake.lock)
- update: Update flake.lock + rebuild (updates packages)
- gc: Delete old generations
- cleanup: Full cleanup (gc + optimization)
- Aliases persist across terminals

**Technical Notes**:
- Add to home-manager/modules/aliases.nix:
  ```nix
  programs.zsh.shellAliases = {
    rebuild = "darwin-rebuild switch --flake ~/Documents/nix-install";
    update = "cd ~/Documents/nix-install && nix flake update && darwin-rebuild switch --flake .";
    gc = "nix-collect-garbage -d";
    cleanup = "nix-collect-garbage -d && nix-store --optimize";
    health-check = "~/Documents/nix-install/scripts/health-check.sh";  # From Epic-06
  };
  ```
- Note: `rebuild` and `update` are THE ONLY ways to update apps (no auto-updates)
- Test: Run `rebuild` (should apply config), `update` (should update flake.lock)

**Definition of Done**:
- [ ] Aliases configured in home-manager module
- [ ] rebuild command works
- [ ] update command works
- [ ] gc command works
- [ ] cleanup command works
- [ ] Aliases persist across terminals
- [ ] Tested in VM
- [ ] Documentation explains rebuild vs update

**Dependencies**:
- Story 04.1-001 (Zsh configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 04.5-002: General Shell Aliases
**User Story**: As FX, I want common shell aliases like ll, la, and grep colors so that daily terminal use is efficient

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `ll`
- **Then** it shows `ls -lah` (detailed list with hidden files)
- **When** I run `la`
- **Then** it shows `ls -A` (all files except . and ..)
- **When** I run grep
- **Then** matches are highlighted in color
- **And** all aliases work in fresh terminal

**Note**: Docker/Podman aliases (`docker`, `docker-compose`) are defined in Story 04.8-002

**Additional Requirements**:
- ll: Detailed list with human-readable sizes
- la: Show all files including hidden
- grep: Color output for visibility
- Persist across terminals

**Technical Notes**:
- Add to home-manager/modules/aliases.nix:
  ```nix
  programs.zsh.shellAliases = {
    ll = "ls -lah";
    la = "ls -A";
    l = "ls -CF";
    grep = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";
    ".." = "cd ..";
    "..." = "cd ../..";
  };
  ```
- May also use eza (modern ls replacement) if installed:
  ```nix
  ll = "eza -lah --git";  # If eza is in Nix packages
  ```
- Test: `ll` shows detailed list, `grep` shows colored output

**Definition of Done**:
- [ ] General aliases configured
- [ ] ll, la, l commands work
- [ ] grep shows colored output
- [ ] Navigation aliases (.., ...) work
- [ ] Aliases persist across terminals
- [ ] Tested in VM

**Dependencies**:
- Story 04.1-001 (Zsh configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

