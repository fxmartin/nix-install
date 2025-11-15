# ABOUTME: Epic-02 Feature 02.4 (Productivity & Utilities) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 02.4

# Epic-02 Feature 02.4: Productivity & Utilities

## Feature Overview

**Feature ID**: Feature 02.4
**Feature Name**: Productivity & Utilities
**Epic**: Epic-02
**Status**: 🔄 In Progress

### Feature 02.4: Productivity & Utilities
**Feature Description**: Install productivity apps, system utilities, and monitoring tools
**User Value**: Complete suite of tools for file management, archiving, system maintenance, and monitoring
**Story Count**: 7
**Story Points**: 27
**Priority**: High
**Complexity**: Low-Medium

#### Stories in This Feature

##### Story 02.4-001: Raycast Installation
**User Story**: As FX, I want Raycast installed as my application launcher and productivity tool so that I can quickly access apps and features

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I press the Raycast hotkey (configurable)
- **Then** Raycast launcher opens
- **And** I can search and launch applications
- **And** auto-update is disabled (Preferences → Advanced → Auto-update)
- **And** basic extensions are available

**Additional Requirements**:
- Installation via Homebrew Cask
- Auto-update disable documented
- First run configuration (hotkey setup)

**Technical Notes**:
- Homebrew cask: `raycast`
- Auto-update: Preferences → Advanced → Disable auto-update (manual step, document)
- Default hotkey: Usually Cmd+Space or configurable
- Extensions: User can add manually later

**Definition of Done**:
- [ ] Raycast installed via homebrew.nix
- [ ] Launches successfully
- [ ] Auto-update disable documented
- [ ] Tested in VM
- [ ] Documentation notes hotkey setup

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-002: 1Password Installation
**User Story**: As FX, I want 1Password installed so that I can manage passwords and licenses securely

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch 1Password
- **Then** it opens and prompts for account sign-in
- **And** auto-update is disabled (Preferences → Advanced)
- **And** Safari/browser extension prompts for installation
- **And** app is marked as requiring manual license activation

**Additional Requirements**:
- Installation via Homebrew Cask
- Licensed app (requires sign-in)
- Auto-update disable documented
- Browser extension setup documented

**Technical Notes**:
- Homebrew cask: `1password`
- Auto-update: Preferences → Advanced → Disable auto-update
- License: User signs in with 1Password account (no separate license key)
- Document in licensed-apps.md

**Definition of Done**:
- [ ] 1Password installed via homebrew.nix
- [ ] Launches successfully
- [ ] Auto-update disable documented
- [ ] Sign-in process documented
- [ ] Marked as licensed app in docs
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-003: File Utilities (Calibre, Kindle, Keka, Marked 2)
**User Story**: As FX, I want Calibre, Kindle, Keka, and Marked 2 installed so that I can manage ebooks, archives, and preview Markdown files

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I check installed applications
- **Then** Calibre is installed (ebook manager) and launches
- **And** Kindle is installed (via mas) and launches
- **And** Keka is installed (archiver) and launches
- **And** Marked 2 is installed (via mas) and launches
- **And** Keka is set as default for .zip, .rar files (or documented)
- **And** Calibre auto-update is disabled
- **And** Marked 2 auto-update is disabled (Preferences)

**Additional Requirements**:
- Calibre: Homebrew Cask
- Kindle: Mac App Store (mas)
- Keka: Homebrew Cask
- Marked 2: Mac App Store (mas) - Markdown preview app
- Auto-update disable for Calibre (Preferences → Misc)
- Auto-update disable for Marked 2 (Preferences → General)

**Technical Notes**:
- Add to darwin/homebrew.nix:
  ```nix
  homebrew.casks = [ "calibre" "keka" ];
  homebrew.masApps = {
    "Kindle" = 302584613;  # App Store ID
    "Marked 2" = 890031187;  # App Store ID
  };
  ```
- Auto-update:
  - Calibre → Preferences → Misc → Auto-update (disable)
  - Marked 2 → Preferences → General → Check for updates (disable)
- Keka: May need UTI association for file types (document if manual)
- Marked 2: Markdown preview with live reload, exports to PDF/HTML

**Definition of Done**:
- [ ] All four apps installed
- [ ] Each app launches successfully
- [ ] Calibre auto-update disabled
- [ ] Marked 2 auto-update disabled
- [ ] File associations documented
- [ ] Tested in VM
- [ ] Documentation notes Kindle requires sign-in

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew + mas managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-004: Dropbox Installation
**User Story**: As FX, I want Dropbox installed so that I can sync files across my Macs

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Dropbox
- **Then** it opens and prompts for account sign-in
- **And** auto-update is disabled (Preferences → General)
- **And** app is marked as requiring manual activation
- **And** menubar icon appears after sign-in

**Additional Requirements**:
- Installation via Homebrew Cask
- Requires Dropbox account sign-in
- Auto-update disable documented
- Sync folder location configurable

**Technical Notes**:
- Homebrew cask: `dropbox`
- Auto-update: Preferences → General → Uncheck "Automatically update Dropbox"
- License: Free or paid account sign-in (no separate key)
- Document in licensed-apps.md (requires account)

**Definition of Done**:
- [ ] Dropbox installed via homebrew.nix
- [ ] Launches and shows sign-in
- [ ] Auto-update disable documented
- [ ] Sign-in process documented
- [ ] Tested in VM
- [ ] Marked as requiring account in docs

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-005: System Utilities (Onyx, flux)
**User Story**: As FX, I want Onyx and f.lux installed so that I can perform system maintenance and adjust display color temperature

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Onyx
- **Then** it opens and shows system maintenance options
- **And** I can run maintenance tasks (cache clearing, etc.)
- **When** I launch f.lux
- **Then** it starts and adds menubar icon
- **And** color temperature adjusts based on time of day
- **And** f.lux preferences are configurable

**Additional Requirements**:
- Onyx: Homebrew Cask (system maintenance)
- f.lux: Homebrew Cask (display color temperature)
- Both apps are free, no license needed

**Technical Notes**:
- Homebrew casks: `onyx`, `flux`
- Add to darwin/homebrew.nix casks list
- f.lux: May request accessibility permissions (expected)
- Onyx: May request admin password for maintenance tasks (expected)

**Definition of Done**:
- [ ] Both apps installed via homebrew.nix
- [ ] Onyx launches and shows maintenance tools
- [ ] f.lux launches and menubar icon appears
- [ ] Both apps functional
- [ ] Tested in VM
- [ ] Documentation notes permission requests

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-006: System Monitoring (btop, iStat Menus, macmon)
**User Story**: As FX, I want gotop, iStat Menus, and macmon installed so that I can monitor system performance

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `gotop`
- **Then** it shows interactive system monitor (CPU, RAM, disk, network)
- **When** I launch iStat Menus
- **Then** menubar icons appear showing system stats
- **And** iStat Menus prompts for license activation (marked as licensed app)
- **When** I launch macmon
- **Then** it shows system monitoring dashboard
- **And** auto-update is disabled for iStat Menus

**Additional Requirements**:
- gotop, macmon: Nix package (CLI tool)
- iStat Menus: Homebrew Cask (licensed app)
- Auto-update disable for iStat Menus

**Technical Notes**:
- Add to darwin/configuration.nix:
  ```nix
  environment.systemPackages = with pkgs; [ gotop macmon ];
  ```
- Add to darwin/homebrew.nix:
  ```nix
  homebrew.casks = [ "istat-menus" ];
  ```
- iStat Menus: Preferences → General → Disable auto-update
- Document iStat Menus in licensed-apps.md (trial or paid license)

**Definition of Done**:
- [ ] gotop and macmon installed via Nix
- [ ] iStat Menus installed via Homebrew
- [ ] gotop launches and shows system stats
- [ ] iStat Menus menubar icons appear
- [ ] macmon launches successfully
- [ ] Auto-update disabled for iStat Menus
- [ ] iStat Menus marked as licensed app
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.4-001 (Nix installed)
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-007: Git and Git LFS
**User Story**: As FX, I want Git and Git LFS installed so that I can manage code repositories and large files

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `git --version`
- **Then** it shows Git version (Nix-managed)
- **And** `git lfs --version` works
- **And** Git LFS is initialized globally (`git lfs install`)
- **And** I can clone repos with LFS files
- **And** Git config includes user name and email from user-config.nix

**Additional Requirements**:
- Git via Nix (not macOS default)
- Git LFS via Nix
- Git LFS initialized globally
- User config applied (name, email)

**Technical Notes**:
- Add to darwin/configuration.nix:
  ```nix
  environment.systemPackages = with pkgs; [ git git-lfs ];
  ```
- Git LFS init via activation script or Home Manager:
  ```nix
  home-manager.users.fx = {
    programs.git = {
      enable = true;
      userName = "François Martin";  # from user-config.nix
      userEmail = "fx@example.com";  # from user-config.nix
      lfs.enable = true;
    };
  };
  ```
- Verify: `git config user.name` shows correct name

**Definition of Done**:
- [ ] Git installed via Nix
- [ ] Git LFS installed and initialized
- [ ] User name and email configured
- [ ] Can clone repos with LFS files
- [ ] Tested in VM
- [ ] Documentation notes Git config

**Dependencies**:
- Epic-01, Story 01.4-001 (Nix installed)
- Epic-01, Story 01.2-003 (user-config.nix available)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

