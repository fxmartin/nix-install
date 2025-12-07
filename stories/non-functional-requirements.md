# Non-Functional Requirements (NFR)

## NFR Overview
**NFR ID**: NFR
**NFR Description**: Cross-cutting quality attributes and system-wide requirements that ensure performance, reliability, security, maintainability, usability, and compatibility of the nix-darwin MacBook configuration system. These requirements define HOW the system should behave rather than WHAT it should do.
**Business Value**: Ensures system is production-ready, maintainable long-term, secure, and provides excellent user experience
**User Impact**: Enables FX to trust the system for critical work, maintain configurations easily, and recover from failures quickly
**Success Metrics**:
- Bootstrap completion <30 minutes (95th percentile)
- Build success rate >95%
- Zero security incidents (no secrets leaked)
- Configuration updates applied in <5 minutes
- System usable by non-Nix users with documentation only

## NFR Scope
**Total Stories**: 15
**Total Story Points**: 79
**MVP Stories**: 15 (100% of NFR)
**Priority Level**: Must Have
**Target Release**: All Phases (Week 1-8)

## NFR Categories

### Category NFR.1: Performance Requirements
**Category Description**: System response times, resource usage, and throughput benchmarks
**User Value**: Fast, responsive system that doesn't waste time or resources
**Story Count**: 3
**Story Points**: 18
**Priority**: High
**Complexity**: Medium

#### Stories in This Category

##### Story NFR.1-001: Bootstrap Performance Budget
**User Story**: As FX, I want bootstrap to complete in under 30 minutes so that I can quickly reinstall machines without wasting hours

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** a fresh macOS installation with stable internet (50+ Mbps)
- **When** I run the bootstrap script from start to finish
- **Then** the total elapsed time is less than 30 minutes (95th percentile)
- **And** the script displays estimated time remaining for long operations
- **And** phase timings are logged for performance analysis
- **And** the script uses binary cache to avoid unnecessary compilation
- **And** parallel downloads are enabled where possible

**Additional Requirements**:
- Target: <30 minutes total (including user SSH key upload time ~3 min)
- Breakdown: Xcode (10 min), Nix install (3 min), nix-darwin build (15 min), final rebuild (2 min)
- Measurement: Log timestamps at phase boundaries
- Network dependency: Assumes 50+ Mbps download speed
- Binary cache hit rate: >80% for common packages

**Technical Notes**:
- Use `date +%s` to track phase start/end times
- Display estimated time based on phase benchmarks
- Configure Nix for parallel downloads: `max-jobs = auto`
- Use binary cache: `substituters = https://cache.nixos.org`
- Log timing data to ~/.nix-install-metrics.log for analysis
- Example timing display:
  ```
  Phase 5/10: Installing nix-darwin (estimated: 15 minutes)
  [████████████████████                    ] 40% (6 min elapsed)
  ```

**Definition of Done**:
- [ ] Bootstrap completes in <30 minutes in VM testing (5 runs)
- [ ] Timing logs implemented and accurate
- [ ] Estimated time displayed for phases >2 minutes
- [ ] Binary cache configured and working (>80% hit rate)
- [ ] Parallel downloads enabled
- [ ] Performance documented in README with breakdown
- [ ] Tested on MacBook Air and MacBook Pro M3 Max hardware

**Dependencies**:
- Epic-01: All bootstrap stories (timing tracked across all phases)
- NFR.6-001: nixpkgs-unstable binary cache availability

**Risk Level**: Medium
**Risk Mitigation**: Document network requirements, provide offline bootstrap option, measure actual timing during VM testing

---

##### Story NFR.1-002: Rebuild Performance Budget
**User Story**: As FX, I want configuration rebuilds to complete in under 5 minutes so that I can iterate quickly on config changes

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** the system is already configured (not first install)
- **When** I run `rebuild` command after making a config change
- **Then** the rebuild completes in less than 5 minutes
- **And** cached packages are reused (no re-downloading)
- **And** only changed packages are rebuilt
- **And** the rebuild time is displayed after completion
- **And** incremental builds work correctly

**Additional Requirements**:
- Target: <5 minutes for typical config changes
- Baseline: 2-3 minutes for simple changes (add alias, change setting)
- Maximum: 5 minutes for complex changes (add app, change theme)
- Measurement: Display elapsed time after rebuild
- Binary cache: Must be used for unchanged packages

**Technical Notes**:
- Use Nix's incremental build capabilities
- Only rebuild derivations that changed
- Binary cache prevents re-downloading
- Time rebuild: `time darwin-rebuild switch --flake ~/.config/nix-install#<profile>`
- Display timing in rebuild output:
  ```
  Rebuild complete in 2 minutes 34 seconds
  ```

**Definition of Done**:
- [ ] Rebuild completes in <5 minutes for 10 different config changes
- [ ] Timing displayed after each rebuild
- [ ] Binary cache hit rate >95% for rebuilds
- [ ] Only changed packages rebuilt (verified with nix build logs)
- [ ] Performance documented in customization guide
- [ ] Tested on both Standard and Power profiles

**Dependencies**:
- Epic-01: Bootstrap complete (nix-darwin installed)
- NFR.1-001: Binary cache configured
- Epic-07: rebuild alias implemented

**Risk Level**: Low
**Risk Mitigation**: Document typical rebuild times for different change types

---

##### Story NFR.1-003: Shell Startup Performance
**User Story**: As FX, I want my shell to start in under 500ms so that opening new terminal windows feels instant

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** the shell environment is fully configured
- **When** I open a new terminal window
- **Then** the shell is ready for input in less than 500ms
- **And** all plugins are loaded (Oh My Zsh, fzf, zsh-autosuggestions)
- **And** the Starship prompt appears immediately
- **And** shell startup time is measured and logged
- **And** lazy loading is used for heavy tools (if needed)

**Additional Requirements**:
- Target: <500ms from window open to ready for input
- Measurement: Use `zsh -i -c exit` timing or Zsh profiling
- Lazy loading: Load heavy tools (e.g., NVM, RVM) only when needed
- Plugin optimization: Minimize Oh My Zsh plugin overhead

**Technical Notes**:
- Measure with: `time zsh -i -c exit`
- Profile with: `zsh -xv` or Zsh profiling plugins
- Lazy load example:
  ```zsh
  # Don't load NVM on startup, load when 'node' is called
  node() {
    unset -f node
    source /opt/homebrew/opt/nvm/nvm.sh
    node "$@"
  }
  ```
- Oh My Zsh optimization: Only load essential plugins
- Starship: Fast by design, minimal config for speed

**Definition of Done**:
- [ ] Shell startup time <500ms measured with `time zsh -i -c exit`
- [ ] All required plugins loaded
- [ ] Starship prompt appears immediately
- [ ] Lazy loading implemented for non-essential tools
- [ ] Startup time documented in shell config
- [ ] Tested on both MacBook Air and MacBook Pro M3 Max
- [ ] No noticeable lag when opening new terminals

**Dependencies**:
- Epic-04: Shell environment configured (Zsh, Oh My Zsh, Starship, plugins)

**Risk Level**: Low
**Risk Mitigation**: Profile shell startup, disable slow plugins, implement lazy loading

---

### Category NFR.2: Reliability Requirements
**Category Description**: System stability, error handling, idempotency, and recovery mechanisms
**User Value**: Trustworthy system that handles failures gracefully and recovers easily
**Story Count**: 3
**Story Points**: 16
**Priority**: High
**Complexity**: Medium

#### Stories in This Category

##### Story NFR.2-001: Build Success Rate Target
**User Story**: As FX, I want the build success rate to exceed 95% so that I can trust the system to work reliably

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** the system is properly configured (flake.nix valid)
- **When** I run bootstrap or rebuild 20 times in testing
- **Then** at least 19 builds succeed (>95% success rate)
- **And** failures are caused by external factors (network, GitHub) not config errors
- **And** failed builds rollback cleanly without breaking the system
- **And** error messages clearly identify the cause of failure
- **And** the system state is unchanged after a failed build

**Additional Requirements**:
- Target: >95% build success rate in controlled testing
- Failures allowed: Network issues, GitHub downtime, user error (invalid config)
- Failures NOT allowed: Config bugs, Nix errors, missing dependencies
- Rollback: Failed builds must not leave system in broken state
- Error messages: Must be actionable ("Check internet connection", "Fix syntax error in flake.nix")

**Technical Notes**:
- Track success/failure in CI/CD (future) or manual testing log
- Rollback mechanism: Nix automatically keeps previous generation
- Test rollback: `darwin-rebuild --rollback`
- Error handling: Catch common failures and display helpful messages
- Example error message:
  ```
  ERROR: Failed to fetch flake from GitHub
  Possible causes:
  - Internet connection lost (check: ping github.com)
  - GitHub is down (check: https://status.github.com)
  - Repository URL incorrect (verify: git@github.com:fxmartin/nix-install.git)

  System is unchanged. Safe to retry after fixing issue.
  ```

**Definition of Done**:
- [ ] 20 bootstrap runs in VM: >95% success rate
- [ ] 20 rebuild runs with config changes: >95% success rate
- [ ] Failed builds rollback cleanly (system unchanged)
- [ ] Error messages clear and actionable
- [ ] Success rate documented in README
- [ ] Common failure modes identified and handled

**Dependencies**:
- Epic-01: Bootstrap error handling implemented
- NFR.2-002: Idempotency verified
- NFR.5-001: Error messages actionable

**Risk Level**: Medium
**Risk Mitigation**: Test extensively in VM, handle common failure modes, document troubleshooting

---

##### Story NFR.2-002: Idempotency Guarantee
**User Story**: As FX, I want all scripts and rebuilds to be idempotent so that I can safely re-run them without breaking the system

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** the bootstrap or rebuild has been run successfully
- **When** I run it again without changes
- **Then** the script completes successfully (no errors)
- **And** the system state is identical to before (no drift)
- **And** no duplicate configurations are created
- **And** existing files are not overwritten unless explicitly confirmed
- **And** the script displays "No changes needed" or "Already up to date" messages

**Additional Requirements**:
- Idempotent operations: All system changes must be repeatable without side effects
- File overwrites: Prompt user before overwriting existing configs
- State detection: Check current state before making changes
- Duplicate prevention: Don't create duplicate entries (e.g., multiple PATH additions)

**Technical Notes**:
- Check before act pattern:
  ```bash
  if [ -f ~/.zshrc ]; then
    echo "~/.zshrc already exists, skipping"
  else
    ln -s /nix/store/.../.zshrc ~/.zshrc
  fi
  ```
- Nix is naturally idempotent (declarative, pure)
- Home Manager symlinks are idempotent
- Test idempotency: Run script 3 times, verify identical state
- Use `diff` to compare system state before/after re-run

**Definition of Done**:
- [ ] Bootstrap can be re-run 3 times without errors
- [ ] Rebuild can be re-run 3 times without errors
- [ ] System state identical after re-runs (verified with diff)
- [ ] No duplicate configurations created
- [ ] User prompted before overwriting files
- [ ] "No changes needed" messages displayed
- [ ] Tested in VM with multiple re-runs
- [ ] Idempotency documented in README

**Dependencies**:
- Epic-01: Bootstrap implementation
- Story 01.1-002: Idempotency check in bootstrap

**Risk Level**: Low
**Risk Mitigation**: Test extensively with re-runs, verify state with diff

---

##### Story NFR.2-003: Backup Before Destructive Operations
**User Story**: As FX, I want the system to backup existing configurations before overwriting them so that I can recover if something goes wrong

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** I am running bootstrap on a machine with existing dotfiles
- **When** the script would overwrite existing configurations
- **Then** it creates a backup directory at ~/dotfiles-backup-YYYYMMDD-HHMMSS/
- **And** it copies all existing dotfiles to the backup directory
- **And** it displays the backup location to the user
- **And** it confirms the backup before proceeding
- **And** the backup can be used to restore previous state

**Additional Requirements**:
- Backup location: ~/dotfiles-backup-YYYYMMDD-HHMMSS/ (timestamped)
- Backup scope: All dotfiles and configs that will be overwritten
- User confirmation: Display backup location and ask "Proceed with overwrite? (y/n)"
- Restore documentation: README notes how to restore from backup

**Technical Notes**:
- Create backup directory:
  ```bash
  BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  ```
- Backup files:
  ```bash
  [ -f ~/.zshrc ] && cp ~/.zshrc "$BACKUP_DIR/"
  [ -d ~/.config/ghostty ] && cp -r ~/.config/ghostty "$BACKUP_DIR/"
  ```
- Display:
  ```
  Existing dotfiles backed up to: ~/dotfiles-backup-20250108-143022/
  Proceed with overwrite? (y/n)
  ```

**Definition of Done**:
- [ ] Backup directory created before overwrites
- [ ] All existing dotfiles copied to backup
- [ ] Backup location displayed to user
- [ ] User confirmation before proceeding
- [ ] Restore process documented in README
- [ ] Tested in VM with existing dotfiles
- [ ] Backup can be used to restore successfully

**Dependencies**:
- Epic-01: Bootstrap implementation
- Story 01.1-002: Idempotency check

**Risk Level**: Low
**Risk Mitigation**: Test backup/restore process in VM

---

### Category NFR.3: Security Requirements
**Category Description**: Protection of secrets, secure authentication, encryption, and security best practices
**User Value**: Safe system that protects sensitive information and follows security best practices
**Story Count**: 4
**Story Points**: 18
**Priority**: High
**Complexity**: Medium

#### Stories in This Category

##### Story NFR.3-001: No Secrets in Git
**User Story**: As FX, I want to ensure no secrets are committed to Git so that my passwords, API keys, and license keys remain private

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** the nix-install repository contains configuration files
- **When** I commit and push to GitHub
- **Then** no secrets are present in the commit history
- **And** .gitignore excludes sensitive files (user-config.nix with secrets, .env files)
- **And** a pre-commit hook scans for potential secrets
- **And** documentation warns against committing secrets
- **And** secret placeholders are used in templates (e.g., @SECRET@)

**Additional Requirements**:
- Excluded files: user-config.nix (if contains secrets), *.env, credentials.json, etc.
- Secret detection: Use tools like git-secrets or gitleaks (optional pre-commit hook)
- Templates: Use placeholders for sensitive values
- Documentation: README.md security section warns about secrets

**Technical Notes**:
- .gitignore entries:
  ```
  # Secrets and sensitive files
  .env
  .env.*
  **/credentials.json
  **/secrets.yaml
  ```
- Optional pre-commit hook (future P1 enhancement):
  ```bash
  #!/bin/bash
  # Check for common secret patterns
  if git diff --cached | grep -E "password|secret|api_key"; then
    echo "WARNING: Potential secret detected in commit"
    exit 1
  fi
  ```
- user-config.nix: Only contains non-sensitive info (name, email, username)

**Definition of Done**:
- [ ] .gitignore excludes sensitive files
- [ ] No secrets in repository commit history (verified)
- [ ] Template files use placeholders
- [ ] README security section warns against committing secrets
- [ ] Optional pre-commit hook implemented (future)
- [ ] Tested by attempting to commit .env file (should be ignored)

**Dependencies**:
- Epic-01: Repository structure created
- Epic-07: Documentation includes security warnings

**Risk Level**: Medium
**Risk Mitigation**: Document best practices, use .gitignore, consider pre-commit hooks (P1)

---

##### Story NFR.3-002: SSH Keys Local Only
**User Story**: As FX, I want SSH keys to be generated locally and never transmitted so that my private keys remain secure

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** the bootstrap generates an SSH key
- **When** the key is created
- **Then** the private key never leaves the local machine
- **And** only the public key is displayed to the user
- **And** the private key has 600 permissions (owner read/write only)
- **And** the bootstrap never uploads the private key anywhere
- **And** the user manually uploads the public key to GitHub

**Additional Requirements**:
- Private key location: ~/.ssh/id_ed25519 (600 permissions)
- Public key location: ~/.ssh/id_ed25519.pub (644 permissions)
- Key type: ed25519 (secure, modern)
- No passphrase: Documented security trade-off for automation
- Never transmitted: Private key stays on disk only

**Technical Notes**:
- Generate key:
  ```bash
  ssh-keygen -t ed25519 -C "$USER_EMAIL" -f ~/.ssh/id_ed25519 -N ""
  ```
- Set permissions:
  ```bash
  chmod 600 ~/.ssh/id_ed25519
  chmod 644 ~/.ssh/id_ed25519.pub
  ```
- Display only public key:
  ```bash
  cat ~/.ssh/id_ed25519.pub
  ```
- Never display or upload private key

**Definition of Done**:
- [ ] SSH key generated locally
- [ ] Private key never displayed or transmitted
- [ ] Private key permissions set to 600
- [ ] Public key permissions set to 644
- [ ] Only public key shown to user for GitHub upload
- [ ] Documentation notes security model (no passphrase trade-off)
- [ ] Tested in VM, verified private key security

**Dependencies**:
- Epic-01: SSH key generation (Story 01.6-001)

**Risk Level**: Low
**Risk Mitigation**: Clear documentation of security model, proper permissions

---

##### Story NFR.3-003: FileVault Encryption Enforcement
**User Story**: As FX, I want FileVault disk encryption enabled so that my data is protected if my MacBook is lost or stolen

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** the system configuration is applied
- **When** macOS preferences are set
- **Then** FileVault is enabled (or user is prompted to enable if not already)
- **And** the bootstrap checks FileVault status
- **And** if FileVault is disabled, it displays clear instructions to enable
- **And** if FileVault requires restart, it warns the user
- **And** FileVault status is verified after system configuration

**Additional Requirements**:
- FileVault check: Automated detection of current status
- Enable prompt: If disabled, warn user and provide enable instructions
- Manual enable: User must enable via System Preferences (requires restart)
- Verification: Check status after configuration applied

**Technical Notes**:
- Check FileVault status:
  ```bash
  fdesetup status
  # Output: "FileVault is On." or "FileVault is Off."
  ```
- Enable FileVault (requires GUI - cannot be fully automated):
  ```
  System Preferences → Privacy & Security → FileVault → Turn On
  ```
- Warning message if disabled:
  ```
  WARNING: FileVault disk encryption is disabled.

  For security, enable FileVault:
  1. Open System Preferences
  2. Go to Privacy & Security
  3. Click FileVault
  4. Click "Turn On FileVault"
  5. Follow the prompts and restart when required

  Press ENTER to continue (or Ctrl+C to abort and enable now)
  ```

**Definition of Done**:
- [ ] FileVault status check implemented
- [ ] Warning displayed if FileVault disabled
- [ ] Instructions clear and actionable
- [ ] Status verified after configuration
- [ ] Documentation notes FileVault requirement
- [ ] Tested on VM with FileVault disabled
- [ ] User can enable FileVault and continue

**Dependencies**:
- Epic-03: System security configuration (Story 03.2-001)

**Risk Level**: Low
**Risk Mitigation**: Clear instructions, document manual enable process

---

##### Story NFR.3-004: Firewall Configuration
**User Story**: As FX, I want the firewall enabled with stealth mode so that my MacBook is protected from network attacks

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** system security preferences are configured
- **When** the bootstrap applies settings
- **Then** the macOS firewall is enabled
- **And** stealth mode is enabled (don't respond to ping/port scans)
- **And** firewall settings are verified after configuration
- **And** essential apps are allowed through firewall (Dropbox, Zoom, etc.)
- **And** firewall status is displayed to user

**Additional Requirements**:
- Firewall enabled: Block incoming connections by default
- Stealth mode: Don't respond to ICMP ping requests
- App exceptions: Allow signed apps to receive connections
- Verification: Check status after configuration

**Technical Notes**:
- Enable firewall via nix-darwin:
  ```nix
  system.defaults.alf = {
    globalstate = 1; # Enable firewall
    stealthenabled = 1; # Enable stealth mode
    allowsignedenabled = 1; # Allow signed apps
  };
  ```
- Verify with command:
  ```bash
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode
  ```
- Display status:
  ```
  Firewall: Enabled
  Stealth Mode: Enabled
  Signed Apps: Allowed
  ```

**Definition of Done**:
- [ ] Firewall enabled via nix-darwin configuration
- [ ] Stealth mode enabled
- [ ] Signed apps allowed
- [ ] Status verification implemented
- [ ] Firewall settings displayed to user
- [ ] Tested on VM and physical hardware
- [ ] Documentation notes firewall configuration

**Dependencies**:
- Epic-03: System security configuration (Story 03.2-001)

**Risk Level**: Low
**Risk Mitigation**: Test app connectivity, document exceptions

---

### Category NFR.4: Maintainability Requirements
**Category Description**: Code quality, documentation, modularity, and long-term maintenance ease
**User Value**: Easy-to-understand, modify, and extend configuration system
**Story Count**: 3
**Story Points**: 13
**Priority**: Medium
**Complexity**: Medium

#### Stories in This Category

##### Story NFR.4-001: Modular Configuration Architecture
**User Story**: As FX, I want Nix configurations organized into logical modules so that I can easily understand and modify specific aspects of the system

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** the nix-install repository structure
- **When** I navigate the codebase
- **Then** configurations are organized into logical directories (darwin/, home-manager/, modules/)
- **And** each module has a single, clear responsibility (one concern per file)
- **And** file names clearly indicate their purpose (zsh.nix, git.nix, homebrew.nix)
- **And** modules are imported in a clear hierarchy (flake.nix → configuration.nix → modules/)
- **And** each module has a brief comment explaining its purpose

**Additional Requirements**:
- Directory structure:
  ```
  nix-install/
  ├── flake.nix (main entry point)
  ├── darwin/ (system-level configs)
  │   ├── configuration.nix
  │   ├── homebrew.nix
  │   ├── macos-defaults.nix
  │   ├── system-monitoring.nix
  │   └── nix-settings.nix
  ├── home-manager/ (user-level configs)
  │   ├── default.nix
  │   └── modules/
  │       ├── zsh.nix
  │       ├── git.nix
  │       ├── starship.nix
  │       ├── fzf.nix
  │       └── aliases.nix
  ```
- One concern per file: zsh.nix only contains Zsh config, not Git or other tools
- File comments: Each file starts with brief explanation (ABOUTME: comment)

**Technical Notes**:
- Module pattern:
  ```nix
  # ABOUTME: Zsh shell configuration with Oh My Zsh and plugins
  # ABOUTME: Manages shell environment, aliases, and completions
  { config, pkgs, ... }:
  {
    programs.zsh = {
      enable = true;
      # ... configuration
    };
  }
  ```
- Import in configuration.nix:
  ```nix
  imports = [
    ./homebrew.nix
    ./macos-defaults.nix
    ./system-monitoring.nix
  ];
  ```

**Definition of Done**:
- [ ] Directory structure follows planned architecture
- [ ] Each module has single, clear responsibility
- [ ] File names are descriptive
- [ ] Module hierarchy is clear and logical
- [ ] Each file has ABOUTME comment (2 lines)
- [ ] Documentation explains module structure
- [ ] Tested: Can modify one module without touching others

**Dependencies**:
- Epic-01: Repository structure created
- All implementation epics: Modules created during implementation

**Risk Level**: Low
**Risk Mitigation**: Follow reference implementation (mlgruby), document module structure

---

##### Story NFR.4-002: Code Comments and Documentation
**User Story**: As FX, I want non-obvious configuration choices explained in comments so that I understand why decisions were made

**Priority**: Must Have
**Story Points**: 3
**Sprint**: All Sprints (ongoing)

**Acceptance Criteria**:
- **Given** any Nix configuration file
- **When** I read the code
- **Then** non-obvious choices have comments explaining the rationale
- **And** complex Nix expressions have explanatory comments
- **And** workarounds have comments explaining the issue and solution
- **And** TODO comments are used for future improvements
- **And** comments are concise and helpful (not redundant)

**Additional Requirements**:
- Comment non-obvious choices: Explain WHY, not WHAT (code shows WHAT)
- Complex expressions: Break down complex Nix logic with comments
- Workarounds: Document issues and solutions
- TODOs: Mark future improvements with TODO comments
- Avoid redundant comments: Don't comment obvious code

**Technical Notes**:
- Good comment examples:
  ```nix
  # Use nixpkgs-unstable for latest Zed, Ghostty, and AI tools
  # Stable channel lags 6+ months behind for fast-moving apps
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  # Disable auto-update to ensure reproducibility
  # Updates ONLY via 'rebuild' command (controlled by flake.lock)
  environment.variables.HOMEBREW_NO_AUTO_UPDATE = "1";

  # TODO: Add SOPS for encrypted secrets (P1 feature)
  ```
- Bad comment examples:
  ```nix
  # Enable Zsh
  programs.zsh.enable = true; # Redundant - code is self-explanatory
  ```

**Definition of Done**:
- [ ] All non-obvious choices have comments
- [ ] Complex expressions explained
- [ ] Workarounds documented
- [ ] TODOs marked for future work
- [ ] No redundant comments
- [ ] Code review confirms comments are helpful
- [ ] Documentation notes commenting standards

**Dependencies**:
- All implementation stories: Comments added during implementation

**Risk Level**: Low
**Risk Mitigation**: Code review process checks for adequate comments

---

##### Story NFR.4-003: Changelog and Version Locking
**User Story**: As FX, I want a changelog documenting breaking changes and version locking for dependencies so that I can track what changed and when

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** the nix-install repository
- **When** I make breaking changes to the configuration
- **Then** I document the change in CHANGELOG.md
- **And** the changelog entry includes: date, change description, migration steps, affected files
- **And** flake.lock pins all dependency versions for reproducibility
- **And** the changelog explains how to update dependencies (`nix flake update`)
- **And** major version milestones are tagged in Git

**Additional Requirements**:
- Changelog format: Keep a Changelog (https://keepachangelog.com)
- Version locking: flake.lock ensures reproducibility
- Git tags: Use semantic versioning for major milestones (v1.0.0, v1.1.0)
- Update documentation: Explain how to update dependencies

**Technical Notes**:
- CHANGELOG.md format:
  ```markdown
  # Changelog

  ## [Unreleased]

  ## [1.1.0] - 2025-01-15
  ### Added
  - SOPS for encrypted secrets (P1 feature)

  ### Changed
  - **BREAKING**: Moved user-config.nix to config/user-config.nix
    - Migration: Run `mv user-config.nix config/user-config.nix`

  ### Fixed
  - Ghostty theme not switching with system appearance

  ## [1.0.0] - 2025-01-08
  ### Added
  - Initial release with bootstrap, apps, system config
  ```
- Version locking: `nix flake update` updates flake.lock
- Git tags: `git tag -a v1.0.0 -m "Initial release"`

**Definition of Done**:
- [ ] CHANGELOG.md created and follows standard format
- [ ] Breaking changes documented with migration steps
- [ ] flake.lock committed to Git (version locking)
- [ ] Update documentation explains `nix flake update`
- [ ] Major milestones tagged in Git
- [ ] Changelog reviewed for completeness
- [ ] Documentation references changelog

**Dependencies**:
- Epic-01: Repository structure and flake.nix created
- Epic-07: Documentation structure created

**Risk Level**: Low
**Risk Mitigation**: Use standard changelog format, document process

---

### Category NFR.5: Usability Requirements
**Category Description**: Error messages, progress indicators, documentation quality, and ease of use
**User Value**: System that is easy to use, understand, and troubleshoot
**Story Count**: 2
**Story Points**: 8
**Priority**: High
**Complexity**: Low

#### Stories in This Category

##### Story NFR.5-001: Actionable Error Messages
**User Story**: As FX, I want clear, actionable error messages when something goes wrong so that I can fix issues without developer help

**Priority**: Must Have
**Story Points**: 5
**Sprint**: All Sprints (ongoing)

**Acceptance Criteria**:
- **Given** an error occurs during bootstrap or rebuild
- **When** the error is displayed to the user
- **Then** the message clearly states what went wrong
- **And** it explains possible causes of the error
- **And** it provides specific steps to resolve the issue
- **And** it includes relevant context (file name, line number if applicable)
- **And** it suggests where to find more help (docs, GitHub issues)

**Additional Requirements**:
- Error format: Clear statement + possible causes + resolution steps
- Context: Include relevant details (file, command, phase)
- Help resources: Link to docs or GitHub issues
- No jargon: Use plain language, avoid technical acronyms

**Technical Notes**:
- Good error message example:
  ```
  ERROR: Failed to build nix-darwin configuration

  Cause: Syntax error in flake.nix at line 42

  The Nix expression has a syntax error. Common issues:
  - Missing semicolon at end of line
  - Unmatched braces or parentheses
  - Invalid attribute name

  Resolution:
  1. Open flake.nix and check line 42
  2. Fix the syntax error
  3. Validate with: nix flake check
  4. Re-run: darwin-rebuild switch --flake ~/.config/nix-install#<profile>

  If you need help, see: ~/.config/nix-install/docs/troubleshooting.md
  Or open an issue: https://github.com/fxmartin/nix-install/issues
  ```
- Bad error message example:
  ```
  Error: build failed
  ```

**Definition of Done**:
- [ ] All error messages follow actionable format
- [ ] Possible causes listed for common errors
- [ ] Resolution steps provided
- [ ] Help resources referenced
- [ ] Error messages tested in VM (trigger errors, verify messages)
- [ ] Code review confirms error quality
- [ ] Documentation includes common errors and solutions

**Dependencies**:
- All implementation stories: Error handling added during implementation
- Epic-07: Troubleshooting documentation created

**Risk Level**: Low
**Risk Mitigation**: Test error scenarios in VM, improve messages based on feedback

---

##### Story NFR.5-002: Progress Indicators and Confirmations
**User Story**: As FX, I want progress indicators during long operations and confirmations before destructive actions so that I stay informed and avoid mistakes

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** a long-running operation (>30 seconds)
- **When** the operation is executing
- **Then** a progress indicator shows the operation is running
- **And** estimated time remaining is displayed (if known)
- **And** phase/step name is shown (e.g., "Downloading packages...")
- **And** destructive operations (delete, overwrite) prompt for confirmation
- **And** confirmations default to safe option (no/abort)

**Additional Requirements**:
- Progress indicators: For operations >30 seconds
- Estimated time: Display if known (e.g., "Estimated: 15 minutes")
- Phase names: Clear description of current operation
- Confirmations: Required for destructive operations
- Safe defaults: Confirmation defaults to "no" or "abort"

**Technical Notes**:
- Progress indicator examples:
  ```bash
  Phase 5/10: Installing nix-darwin (estimated: 15 minutes)
  [████████████████████                    ] 40% (6 min elapsed)

  Downloading packages... (234 of 500 packages)

  Building system configuration... (this may take 10-20 minutes)
  ```
- Confirmation example:
  ```bash
  WARNING: This will delete existing ~/.config/nix-install directory

  Are you sure you want to continue? (y/N): _
  # Default to 'N' (safe option)
  ```

**Definition of Done**:
- [ ] Progress indicators for all operations >30 seconds
- [ ] Estimated time displayed where possible
- [ ] Phase names clear and descriptive
- [ ] Confirmations before destructive operations
- [ ] Safe defaults (no/abort) used
- [ ] Tested in VM with all long operations
- [ ] User feedback confirms clarity

**Dependencies**:
- Epic-01: Bootstrap progress indicators (Story 01.1-003)
- All implementation stories: Confirmations added where needed

**Risk Level**: Low
**Risk Mitigation**: Test UX in VM, iterate based on feedback

---

### Category NFR.6: Compatibility Requirements
**Category Description**: macOS version support, hardware compatibility, Nix version requirements
**User Value**: System works reliably across different MacBook models and macOS versions
**Story Count**: 3
**Story Points**: 13
**Priority**: High
**Complexity**: Medium

#### Stories in This Category

##### Story NFR.6-001: macOS Version Compatibility
**User Story**: As FX, I want the system to work on macOS Sonoma (14.x) and newer so that I can use it on current and future macOS versions

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** a MacBook running macOS Sonoma (14.x) or newer
- **When** I run the bootstrap
- **Then** all system configurations apply successfully
- **And** macOS defaults are set correctly
- **And** all apps launch and function properly
- **And** the system checks macOS version before starting
- **And** unsupported macOS versions are rejected with clear error

**Additional Requirements**:
- Minimum version: macOS Sonoma 14.0
- Target version: macOS Sonoma 14.x (latest stable)
- Future compatibility: Design for macOS 15+ (Sequoia)
- Version check: Validate before bootstrap starts

**Technical Notes**:
- Check macOS version:
  ```bash
  MACOS_VERSION=$(sw_vers -productVersion)
  MACOS_MAJOR=$(echo "$MACOS_VERSION" | cut -d. -f1)

  if [ "$MACOS_MAJOR" -lt 14 ]; then
    echo "ERROR: macOS Sonoma (14.x) or newer required"
    echo "Current version: $MACOS_VERSION"
    exit 1
  fi
  ```
- Test on multiple macOS versions (14.0, 14.5, 15.0 if available)
- Document tested versions in README

**Definition of Done**:
- [ ] macOS version check implemented in bootstrap
- [ ] Tested on macOS Sonoma 14.x
- [ ] All features work on Sonoma
- [ ] Unsupported versions rejected with error
- [ ] Documentation lists supported macOS versions
- [ ] Future macOS versions considered (design decisions)

**Dependencies**:
- Epic-01: Bootstrap pre-flight checks (Story 01.1-001)

**Risk Level**: Medium
**Risk Mitigation**: Test on multiple macOS versions, design for future compatibility

---

##### Story NFR.6-002: Apple Silicon and Intel Compatibility
**User Story**: As FX, I want the system to work on Apple Silicon (M-series) and Intel Macs so that I can use it on different hardware

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** an Apple Silicon Mac (M1, M2, M3) or Intel Mac
- **When** I run the bootstrap
- **Then** the correct architecture packages are installed (arm64 for Apple Silicon, x86_64 for Intel)
- **And** Homebrew is installed at the correct location (/opt/homebrew for Apple Silicon, /usr/local for Intel)
- **And** all apps run natively on the architecture
- **And** the system detects architecture automatically

**Additional Requirements**:
- Primary support: Apple Silicon (M-series) - MacBook Pro M3 Max, MacBook Air M2/M3
- Secondary support: Intel Macs (for legacy support)
- Architecture detection: Automatic detection and configuration
- Native apps: Prefer native binaries over Rosetta 2 emulation

**Technical Notes**:
- Detect architecture:
  ```bash
  ARCH=$(uname -m)
  if [ "$ARCH" = "arm64" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
  ```
- Nix flake system configuration:
  ```nix
  darwinConfigurations.standard = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin"; # Apple Silicon
    # or "x86_64-darwin" for Intel
  };
  ```
- Test on both architectures (if available)

**Definition of Done**:
- [ ] Architecture detection implemented
- [ ] Correct packages installed for each architecture
- [ ] Homebrew at correct location for each architecture
- [ ] Tested on Apple Silicon (M3 Max, M2 Air)
- [ ] Intel support verified (if possible)
- [ ] Documentation notes architecture support

**Dependencies**:
- Epic-01: Bootstrap and Nix installation
- Epic-02: Homebrew configuration

**Risk Level**: Medium
**Risk Mitigation**: Primary focus on Apple Silicon (FX's hardware), Intel as best-effort

---

##### Story NFR.6-003: Nix Version and Binary Cache Requirements
**User Story**: As FX, I want the system to use Nix 2.18+ with nixpkgs-unstable and binary cache so that builds are fast and reliable

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** the bootstrap installs Nix
- **When** Nix is configured
- **Then** it installs Nix 2.18 or newer
- **And** it enables experimental features (flakes, nix-command)
- **And** it uses nixpkgs-unstable channel for latest packages
- **And** it configures binary cache (cache.nixos.org) for fast builds
- **And** binary cache hit rate exceeds 80% for common packages

**Additional Requirements**:
- Minimum Nix version: 2.18+ (stable flakes support)
- Channel: nixpkgs-unstable (not stable - see REQ-NFR-006)
- Binary cache: cache.nixos.org (official NixOS cache)
- Cache hit rate: >80% for common packages (Python, CLI tools, etc.)

**Technical Notes**:
- Check Nix version after install:
  ```bash
  NIX_VERSION=$(nix --version | awk '{print $3}')
  echo "Installed Nix version: $NIX_VERSION"
  ```
- Configure nixpkgs-unstable in flake.nix:
  ```nix
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  ```
- Configure binary cache in nix.conf:
  ```
  substituters = https://cache.nixos.org
  trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
  ```
- Measure cache hit rate: Check Nix build logs for "copying path" vs "building"

**Definition of Done**:
- [ ] Nix 2.18+ installed
- [ ] Experimental features enabled
- [ ] nixpkgs-unstable configured
- [ ] Binary cache configured and working
- [ ] Cache hit rate >80% verified in testing
- [ ] Documentation explains channel choice (unstable vs stable)

**Dependencies**:
- Epic-01: Nix installation (Story 01.4-001, 01.4-002)
- NFR.1-001: Bootstrap performance (depends on binary cache)

**Risk Level**: Low
**Risk Mitigation**: Document channel choice rationale, monitor cache hit rate

---

### Category NFR.7: Update Control Requirements
**Category Description**: Reproducibility, version locking, and controlled updates (no auto-updates)
**User Value**: Predictable system state, updates only when user decides
**Story Count**: 2
**Story Points**: 13
**Priority**: High
**Complexity**: High

#### Stories in This Category

##### Story NFR.7-001: Disable All Auto-Updates
**User Story**: As FX, I want all automatic updates disabled so that updates only happen when I run the 'update' command

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 2

**Acceptance Criteria**:
- **Given** the system is fully configured
- **When** apps are running
- **Then** no apps auto-update (Homebrew, Zed, VSCode, Arc, Firefox, etc.)
- **And** macOS system updates are manual only
- **And** Homebrew auto-update is disabled (HOMEBREW_NO_AUTO_UPDATE=1)
- **And** app-specific auto-update settings are disabled
- **And** documentation clearly explains update philosophy
- **And** the 'update' command is the ONLY way to update packages

**Additional Requirements**:
- Homebrew: `HOMEBREW_NO_AUTO_UPDATE=1` in environment
- Zed: `"auto_update": false` in settings
- VSCode: `"update.mode": "none"` in settings
- Arc: Disable auto-update in app preferences
- Firefox: `app.update.auto = false` in config
- Dropbox, 1Password, Zoom, Webex, Raycast: Disable in app settings
- Ghostty: `auto-update = off` (already in config)
- macOS: Manual system updates only (System Preferences setting)

**Technical Notes**:
- Environment variable in shell config:
  ```zsh
  export HOMEBREW_NO_AUTO_UPDATE=1
  ```
- Zed config (Home Manager):
  ```nix
  programs.zed.userSettings = {
    auto_update = false;
  };
  ```
- VSCode config (Home Manager):
  ```nix
  programs.vscode.userSettings = {
    "update.mode" = "none";
  };
  ```
- Firefox config (user.js or Home Manager):
  ```javascript
  user_pref("app.update.auto", false);
  ```
- macOS system update disable:
  ```nix
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
  ```
- Document in README:
  ```markdown
  ## Update Philosophy

  All app updates are controlled via the `update` command ONLY.
  No automatic updates occur.

  - `rebuild`: Apply configuration changes (uses versions from flake.lock)
  - `update`: Update flake.lock (gets latest versions) + rebuild

  This ensures reproducibility: same flake.lock = same app versions.
  ```

**Definition of Done**:
- [ ] HOMEBREW_NO_AUTO_UPDATE=1 in environment
- [ ] All app auto-updates disabled via configuration
- [ ] macOS auto-update disabled
- [ ] Update philosophy documented in README
- [ ] `update` command implemented (alias or script)
- [ ] Tested: Apps do NOT auto-update after 1 week of daily use
- [ ] Verified: `update` command successfully updates all packages

**Dependencies**:
- Epic-02: All apps installed
- Epic-03: System preferences configured
- Epic-04: Shell aliases implemented
- Epic-07: Documentation (README) created

**Risk Level**: High
**Risk Mitigation**: Test thoroughly over time, document update process clearly

---

##### Story NFR.7-002: Version Locking and Reproducibility
**User Story**: As FX, I want flake.lock to pin all dependency versions so that rebuilding produces identical results

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 1

**Acceptance Criteria**:
- **Given** the flake.lock file is committed to Git
- **When** I run `rebuild` on any machine
- **Then** the exact same package versions are installed (from flake.lock)
- **And** rebuilding 10 times produces identical results
- **And** different machines with same profile get identical package versions
- **And** flake.lock is updated ONLY when `update` command is run
- **And** documentation explains flake.lock purpose and usage

**Additional Requirements**:
- flake.lock: Committed to Git, updated only via `nix flake update`
- Reproducibility: Same flake.lock = same package versions
- Update control: User decides when to update via `update` command
- Documentation: Explain flake.lock, how to update, how to rollback

**Technical Notes**:
- flake.lock is auto-generated by Nix, contains all dependency versions
- Commit flake.lock to Git:
  ```bash
  git add flake.lock
  git commit -m "chore: update flake.lock"
  ```
- Update dependencies:
  ```bash
  cd ~/.config/nix-install
  nix flake update  # Updates flake.lock
  darwin-rebuild switch --flake .#<profile>  # Rebuilds with new versions
  ```
- `update` alias:
  ```zsh
  alias update='cd ~/.config/nix-install && nix flake update && darwin-rebuild switch --flake .#$(hostname) && cd -'
  ```
- Verify reproducibility:
  ```bash
  # Build 10 times, compare outputs
  for i in {1..10}; do
    darwin-rebuild build --flake .#standard > /tmp/build-$i.log
  done
  diff /tmp/build-*.log  # Should be identical
  ```

**Definition of Done**:
- [ ] flake.lock committed to Git
- [ ] Rebuilds produce identical results (10 runs tested)
- [ ] Same profile on different machines gets same versions
- [ ] `update` command/alias implemented
- [ ] Documentation explains flake.lock and update process
- [ ] Tested: Rollback to previous flake.lock works

**Dependencies**:
- Epic-01: flake.nix and repository structure created
- Epic-04: Shell aliases (update command)
- Epic-07: Documentation

**Risk Level**: Low
**Risk Mitigation**: Commit flake.lock to Git, document update process

---

## NFR Dependencies

### Dependencies on Functional Epics
- **Epic-01 (Bootstrap)**: NFR stories implemented during bootstrap development
- **Epic-02 (Applications)**: Auto-update disable for all apps
- **Epic-03 (System Config)**: Security settings (FileVault, firewall)
- **Epic-04 (Dev Environment)**: Shell performance, aliases
- **Epic-05 (Theming)**: N/A (no NFR dependencies)
- **Epic-06 (Maintenance)**: Reliability requirements
- **Epic-07 (Documentation)**: Usability and maintainability documentation

### Stories This NFR Enables
- All epics depend on NFR being met (performance, reliability, security, etc.)
- VM testing (Phase 9) validates NFR compliance
- Physical hardware migration (Phase 10-11) proves NFR success

### Stories This NFR Blocks
- None (NFR implemented alongside functional stories)

## NFR Progress Tracking

### Completion Status
- **Stories Completed**: 0 of 15 (0%)
- **Story Points Completed**: 0 of 79 (0%)
- **MVP Stories Completed**: 0 of 15 (0%)

### Category Progress
| Category | Stories | Points | Completed | Status |
|----------|---------|--------|-----------|--------|
| Performance | 3 | 18 | 0 | Not Started |
| Reliability | 3 | 16 | 0 | Not Started |
| Security | 4 | 18 | 0 | Not Started |
| Maintainability | 3 | 13 | 0 | Not Started |
| Usability | 2 | 8 | 0 | Not Started |
| Compatibility | 3 | 13 | 0 | Not Started |
| Update Control | 2 | 13 | 0 | Not Started |

## Testing Strategy

### Performance Testing
- **Bootstrap Performance**: Time 10 bootstrap runs in VM, measure each phase
- **Rebuild Performance**: Time 20 rebuilds with different config changes
- **Shell Performance**: Measure startup time with `time zsh -i -c exit` (100 runs)
- **Metrics Collection**: Log timing data to ~/.nix-install-metrics.log
- **Targets**: Bootstrap <30min, rebuild <5min, shell <500ms

### Reliability Testing
- **Build Success Rate**: 20 bootstrap runs + 20 rebuild runs in VM (target >95% success)
- **Idempotency Testing**: Run bootstrap 3 times, verify identical state with `diff`
- **Backup/Restore Testing**: Test backup creation and restoration process
- **Error Handling**: Trigger common failures, verify error messages actionable

### Security Testing
- **Secret Scanning**: Run `git log --all --pretty=format: -p | grep -E "password|secret|api_key"`
- **SSH Key Security**: Verify private key never transmitted, permissions correct (600)
- **FileVault Status**: Check `fdesetup status` after configuration
- **Firewall Status**: Check firewall and stealth mode enabled

### Maintainability Testing
- **Module Structure**: Code review of module organization and separation of concerns
- **Comment Quality**: Code review of comments for clarity and helpfulness
- **Changelog**: Review changelog for completeness and clarity

### Usability Testing
- **Error Message Quality**: Trigger errors in VM, verify messages actionable
- **Progress Indicators**: Observe bootstrap run, verify progress clear
- **Documentation Clarity**: Non-technical user reviews README and attempts installation

### Compatibility Testing
- **macOS Versions**: Test on macOS Sonoma 14.x
- **Hardware**: Test on Apple Silicon (M3 Max, M2 Air) and Intel (if available)
- **Nix Version**: Verify Nix 2.18+ installed, binary cache working

### Update Control Testing
- **Auto-Update Verification**: Use system for 1 week, verify NO auto-updates occur
- **Manual Update**: Run `update` command, verify all packages update
- **Reproducibility**: Rebuild 10 times, verify identical results

## NFR Acceptance Criteria
- [ ] All NFR stories (15/15) completed and accepted
- [ ] Performance targets met: Bootstrap <30min, rebuild <5min, shell <500ms
- [ ] Reliability targets met: Build success >95%, idempotency verified, backups working
- [ ] Security targets met: No secrets in Git, SSH keys local only, FileVault enabled, firewall enabled
- [ ] Maintainability targets met: Modular architecture, comments clear, changelog maintained
- [ ] Usability targets met: Error messages actionable, progress indicators clear, documentation excellent
- [ ] Compatibility targets met: Works on macOS Sonoma 14.x+, Apple Silicon and Intel, Nix 2.18+
- [ ] Update control targets met: No auto-updates, version locking working, reproducibility verified
- [ ] All testing completed and passing
- [ ] VM testing validates NFR compliance
- [ ] Physical hardware migration confirms NFR success

## NFR Validation Checklist

### Quality Assurance for Each Story
- [ ] Follows proper user story format ("As [persona], I want [functionality] so that [benefit]")
- [ ] Has clear, testable acceptance criteria (Given/When/Then format)
- [ ] Includes measurable targets (e.g., <30min, >95%, <500ms)
- [ ] Has testing strategy defined
- [ ] Dependencies clearly identified
- [ ] Business value articulated
- [ ] Persona alignment verified (FX as primary user)
- [ ] Technical feasibility confirmed

### NFR Health Metrics
- **Story Readiness**: 100% of stories meet definition of ready
- **Measurement Coverage**: All targets are measurable and testable
- **Dependency Coverage**: All dependencies identified and managed
- **Testing Coverage**: Testing strategy defined for each category
- **Acceptance Criteria Quality**: Clear, testable, and complete criteria for all stories
