# ABOUTME: Epic-02 Feature 02.5 (Communication Tools) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 02.5

# Epic-02 Feature 02.5: Communication Tools

## Feature Overview

**Feature ID**: Feature 02.5
**Feature Name**: Communication Tools
**Epic**: Epic-02
**Status**: 🔄 In Progress

### Feature 02.5: Communication Tools
**Feature Description**: Install communication and meeting applications
**User Value**: Enables work and personal communication workflows
**Story Count**: 2
**Story Points**: 8
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 02.5-001: WhatsApp Installation
**User Story**: As FX, I want WhatsApp installed so that I can use messaging on my Mac

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch WhatsApp
- **Then** it opens and prompts for QR code scan
- **And** I can link my phone successfully
- **And** app is accessible from Spotlight/Raycast

**Additional Requirements**:
- Prefer mas (Mac App Store) if available
- Fallback to Homebrew Cask if not on mas
- Requires phone for QR code linking

**Technical Notes**:
- Check mas availability: `mas search WhatsApp`
- If available on mas:
  ```nix
  homebrew.masApps = {
    "WhatsApp" = 1147396723;  # App Store ID (verify)
  };
  ```
- If not on mas, use Homebrew cask:
  ```nix
  homebrew.casks = [ "whatsapp" ];
  ```
- Document QR code linking process

**Definition of Done**:
- [ ] WhatsApp installed via mas or Homebrew
- [ ] Launches successfully
- [ ] Shows QR code screen
- [ ] Tested in VM
- [ ] Documentation notes linking process

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew + mas managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.5-002: Zoom and Webex Installation
**User Story**: As FX, I want Zoom and Webex installed so that I can join work meetings

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Zoom
- **Then** it opens and prompts for sign-in or meeting join
- **And** auto-update is disabled (Preferences → General)
- **When** I launch Webex
- **Then** it opens and prompts for sign-in
- **And** auto-update is disabled
- **And** both apps are marked as licensed/requiring activation

**Additional Requirements**:
- Zoom: Homebrew Cask, may require license for full features
- Webex: Homebrew Cask, requires company account
- Auto-update disable documented for both
- Camera/microphone permissions expected on first use

**Technical Notes**:
- Homebrew casks: `zoom`, `webex`
- Add to darwin/homebrew.nix casks list
- Zoom auto-update: Preferences → General → "Update Zoom automatically when connected to Wi-Fi" (uncheck)
- Webex auto-update: Preferences → General (check for disable option)
- Document both as requiring sign-in in licensed-apps.md

**Definition of Done**:
- [ ] Both apps installed via homebrew.nix
- [ ] Zoom launches successfully
- [ ] Webex launches successfully
- [ ] Auto-update disable documented
- [ ] Sign-in process documented
- [ ] Marked as licensed apps in docs
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

