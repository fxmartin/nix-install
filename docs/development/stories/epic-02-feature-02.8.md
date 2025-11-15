# ABOUTME: Epic-02 Feature 02.8 (Profile-Specific Applications) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 02.8

# Epic-02 Feature 02.8: Profile-Specific Applications

## Feature Overview

**Feature ID**: Feature 02.8
**Feature Name**: Profile-Specific Applications
**Epic**: Epic-02
**Status**: 🔄 In Progress

### Feature 02.8: Profile-Specific Applications
**Feature Description**: Install Parallels Desktop on Power profile only
**User Value**: Virtualization capability for development and testing on high-end hardware
**Story Count**: 1
**Story Points**: 8
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 02.8-001: Parallels Desktop Installation (Power Profile Only)
**User Story**: As FX, I want Parallels Desktop installed only on Power profile so that I can run VMs on my MacBook Pro M3 Max

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** Power profile is selected during bootstrap
- **When** darwin-rebuild completes successfully
- **Then** Parallels Desktop is installed
- **And** it launches and prompts for license activation
- **And** I can create and run virtual machines
- **And** Parallels is NOT installed on Standard profile
- **And** auto-update is disabled (Preferences → Advanced)
- **And** app is marked as requiring license activation

**Additional Requirements**:
- Installation via Homebrew Cask
- Power profile only (MacBook Pro M3 Max)
- Requires Parallels license (paid, annual subscription or perpetual)
- Auto-update disable documented
- Large app (~500MB)

**Technical Notes**:
- Add to darwin/homebrew.nix in Power profile only:
  ```nix
  # In darwinConfigurations.power
  homebrew.casks = [
    # ... other casks
    "parallels"
  ];
  # NOT in darwinConfigurations.standard
  ```
- Parallels auto-update: Preferences → Advanced → Uncheck auto-update
- License: Requires activation with license key or account
- Document in licensed-apps.md (trial or paid license required)
- Verify profile differentiation: Parallels present on Power, absent on Standard

**Definition of Done**:
- [ ] Parallels added to Power profile only
- [ ] NOT in Standard profile
- [ ] Parallels launches on Power profile
- [ ] Shows license activation screen
- [ ] Auto-update disable documented
- [ ] Marked as licensed app
- [ ] Profile differentiation tested in VM
- [ ] Documentation notes license requirement

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)
- Epic-01, Story 01.2-002 (Profile selection system)

**Risk Level**: Medium
**Risk Mitigation**: Clear documentation of license requirement, verify profile-specific installation works

---

