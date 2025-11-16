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

### Implementation Details

**Implementation Date**: 2025-01-15

**Changes Made**:
1. **darwin/homebrew.nix**:
   - Added WhatsApp to `masApps` section with App ID 1147396723
   - Added comment: "Communication Tools (Story 02.5-001)"
   - Added comment: "WhatsApp Desktop - Messaging app requiring phone QR code linking"

2. **docs/app-post-install-configuration.md**:
   - Added comprehensive WhatsApp documentation section (285 lines)
   - Documented QR code linking process with detailed phone setup instructions
   - Covered permissions (notifications, microphone, camera, contacts)
   - Documented core features (messaging, media, calls, groups, sync, privacy)
   - Added usage examples (sending messages, files, calls, groups, search)
   - Included troubleshooting guide (QR code issues, sync problems, call failures)
   - Added 14-item testing checklist

3. **docs/development/stories/epic-02-feature-02.5.md**:
   - Added implementation details section with date and summary
   - Created VM testing checklist (20 items)

4. **docs/development/progress.md**:
   - Added Story 02.5-001 to "Recently Completed Stories" section
   - Marked as implementation complete, awaiting VM test

**Key Decisions**:
- Confirmed Mac App Store distribution (App ID 1147396723 verified)
- Followed Kindle pattern for Mac App Store app documentation
- Documented QR code linking requirement prominently (phone required)
- Emphasized that WhatsApp Desktop mirrors phone (no standalone account)
- Documented all required and optional permissions with recommendations
- Included comprehensive troubleshooting for common issues

**VM Testing Checklist** (Story 02.5-001):
- [ ] darwin-rebuild switch completes successfully
- [ ] WhatsApp installed to /Applications/WhatsApp.app
- [ ] App launches from Spotlight (`Cmd+Space`, type "WhatsApp")
- [ ] App launches from Raycast (if installed)
- [ ] QR code screen appears on first launch
- [ ] QR code linking instructions visible and clear
- [ ] Can link to iPhone via QR code scan (Settings → Linked Devices)
- [ ] Conversations sync from phone after linking (recent messages appear)
- [ ] Can send text message from desktop
- [ ] Can receive messages on desktop (send from phone → appears on Mac)
- [ ] Notifications permission prompt appears (System Settings integration)
- [ ] Microphone permission prompt appears when attempting voice call
- [ ] Camera permission prompt appears when attempting video call
- [ ] Can send photo/file via paperclip icon or drag-and-drop
- [ ] Can create new group chat (menu → New Group)
- [ ] Can search messages (search icon → type query → results)
- [ ] Can pin/unpin chats (right-click chat → Pin/Unpin)
- [ ] Can archive chats (right-click chat → Archive)
- [ ] App stays synced when phone is locked (messages deliver to desktop)
- [ ] Documentation in app-post-install-configuration.md is accurate and complete

**Post-VM Testing Actions**:
- [ ] Mark story as "Done" in epic file
- [ ] Update progress.md with completion date
- [ ] Update Epic-02 Feature 02.5 status to reflect completion
- [ ] Commit changes with conventional commit message

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

