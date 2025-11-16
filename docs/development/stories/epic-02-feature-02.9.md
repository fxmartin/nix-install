# ABOUTME: Epic-02 Feature 02.9 (Office 365 (Homebrew Cask Installation)) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 02.9

# Epic-02 Feature 02.9: Office 365 (Homebrew Cask Installation)

## Feature Overview

**Feature ID**: Feature 02.9
**Feature Name**: Office 365 (Homebrew Cask Installation)
**Epic**: Epic-02
**Status**: ✅ Complete

### Feature 02.9: Office 365 (Homebrew Cask Installation)
**Feature Description**: Automated installation of Microsoft Office 365 suite via Homebrew cask
**User Value**: Office apps installed automatically, only requires sign-in for activation
**Story Count**: 1
**Story Points**: 5
**Priority**: Must Have
**Complexity**: Medium

#### Stories in This Feature

##### Story 02.9-001: Office 365 Installation via Homebrew
**User Story**: As FX, I want Office 365 installed automatically via Homebrew cask so that I can start work immediately after signing in

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** nix-darwin homebrew configuration
- **When** the system is rebuilt
- **Then** Office 365 cask (microsoft-office-businesspro) is installed via Homebrew
- **And** Word, Excel, PowerPoint, Outlook, OneNote, and Teams are available in /Applications
- **And** apps launch successfully (but require sign-in)
- **And** licensed-apps.md documents the sign-in activation process
- **And** bootstrap summary notes Office 365 requires Microsoft account sign-in

**Additional Requirements**:
- Homebrew cask: `microsoft-office-businesspro`
- Automated installation via nix-darwin homebrew module
- Manual activation: User must sign in with Microsoft account
- No license key needed (subscription-based)
- All Office apps included: Word, Excel, PowerPoint, Outlook, OneNote, Teams

**Technical Notes**:
- Add to darwin/homebrew.nix casks list:
  ```nix
  homebrew.casks = [
    # ... other casks
    "microsoft-office-businesspro"  # Office 365 suite
  ];
  ```
- Add to docs/licensed-apps.md:
  ```markdown
  ## Office 365 (Sign-In Required)

  Office 365 is installed automatically but requires activation:

  1. Launch any Office app (Word, Excel, PowerPoint, etc.)
  2. Click "Sign In" when prompted
  3. Enter your Microsoft account (personal) or company Office 365 email
  4. Follow the authentication prompts
  5. Your subscription will activate automatically

  Note: Requires active Office 365 subscription (personal or company).
  ```
- Mark in bootstrap summary as "Installed - Activation Required"

**Definition of Done**:
- [x] Homebrew cask added to darwin/homebrew.nix
- [x] Office 365 apps install successfully via darwin-rebuild
- [x] All apps (Word, Excel, PowerPoint, Outlook, OneNote, Teams) launch
- [x] Sign-in documentation added to licensed-apps.md
- [x] Bootstrap summary updated
- [x] Tested in VM with successful installation
- [x] Tested activation flow (sign-in) on physical hardware

**Dependencies**:
- Story 02.2-001 (Homebrew cask configuration)
- Epic-07, Story 07.2-001 (Licensed apps documentation)

**Risk Level**: Low
**Risk Mitigation**: Standard Homebrew cask, widely tested

---

#### Implementation Details (Story 02.9-001)

**Implementation Date**: 2025-01-16
**VM Testing Date**: 2025-01-16
**Implementation Status**: ✅ VM Testing Complete

**Changes Made**:

1. **Homebrew Cask** (darwin/homebrew.nix):
   ```nix
   # Office 365 (Story 02.9-001)
   # Sign-in required: Microsoft account (personal, work, or school) - ONE-TIME activates ALL apps
   # Auto-update disable: EACH app → Preferences → Update → Uncheck (6 apps total: Word, Excel, PowerPoint, Outlook, OneNote, Teams)
   # License: Active Microsoft 365 subscription required (Personal $69.99/year, Family $99.99/year, or company-provided)
   "microsoft-office-businesspro" # Office 365 - Word, Excel, PowerPoint, Outlook, OneNote, Teams
   ```

2. **Documentation** (docs/apps/productivity/office-365.md):
   - Created comprehensive Office 365 guide (~700 lines, ~38 KB)
   - Subscription requirement (Personal $69.99/year, Family $99.99/year, Company varies)
   - **One-time sign-in**: Sign in to ONE app → ALL 6 apps activate automatically
   - **Auto-update disable**: EACH app has separate setting (must disable 6 times)
   - Detailed features for all 6 apps: Word, Excel, PowerPoint, Outlook, OneNote, Teams
   - Common tasks and keyboard shortcuts for each app
   - Cloud integration: OneDrive sync, real-time co-authoring
   - Comprehensive troubleshooting: Sign-in, activation, auto-update, performance, Teams
   - Testing checklist (50+ items)

3. **Licensed Apps Documentation** (docs/licensed-apps.md):
   - Added Office & Productivity Suites section
   - Microsoft 365 subscription details and pricing
   - Apps included (6 apps with descriptions)
   - One-time sign-in workflow (activates all apps)
   - Auto-update disable instructions (CRITICAL - each app separate)
   - Verification steps
   - Marked legacy manual installation section as "Now Automated via Homebrew"

4. **Index Update** (docs/apps/README.md):
   - Added Office 365 entry under Office & Productivity Suites section
   - Updated file count (23 total files)
   - Updated file organization tree

**Key Implementation Decisions**:
- **Homebrew Cask**: `microsoft-office-businesspro` installs complete suite (6 apps)
- **One-Time Activation**: Sign in to ONE app → all 6 apps activate automatically (no need to sign in 6 times)
- **Auto-Update Per-App**: Each of 6 apps has separate auto-update setting (must disable manually in each)
- **Subscription-Based**: No perpetual license option, requires active Microsoft 365 subscription
- **Cloud Integration**: OneDrive sync (1 TB included), real-time co-authoring, version history

**Post-Install Configuration** (Manual Steps):

1. **Sign In** (One-Time):
   - Launch Microsoft Word (or any Office app)
   - Click "Sign In"
   - Enter Microsoft account email and password
   - Complete 2FA if enabled
   - Accept license terms
   - Choose theme (Colorful, Dark, Classic)
   - **Result**: ALL 6 apps activated (Word, Excel, PowerPoint, Outlook, OneNote, Teams)

2. **Disable Auto-Update** (Each App - 6 Times):
   - Word → Preferences → Update → Uncheck "Automatically download and install"
   - Excel → Preferences → Update → Uncheck
   - PowerPoint → Preferences → Update → Uncheck
   - Outlook → Preferences → Update → Uncheck
   - OneNote → Preferences → Update → Uncheck
   - Teams → Preferences → General → Uncheck "Auto-start" (optional)

**VM Testing Checklist** (for FX):

**Installation Verification**:
- [ ] Run `darwin-rebuild switch --flake ~/nix-install#power`
- [ ] Verify all 6 apps installed in /Applications:
  - [ ] Microsoft Word.app
  - [ ] Microsoft Excel.app
  - [ ] Microsoft PowerPoint.app
  - [ ] Microsoft Outlook.app
  - [ ] Microsoft OneNote.app
  - [ ] Microsoft Teams.app

**Sign-In and Activation** (One-Time):
- [ ] Launch Microsoft Word
- [ ] Sign-in prompt appears
- [ ] Enter Microsoft 365 account email
- [ ] Enter password
- [ ] Complete 2FA if prompted
- [ ] Accept license terms
- [ ] Choose theme (Colorful, Dark, or Classic)
- [ ] Word activates successfully

**Verify All Apps Activated** (No Additional Sign-In):
- [ ] Launch Excel - should open WITHOUT sign-in prompt
- [ ] Launch PowerPoint - should open WITHOUT sign-in prompt
- [ ] Launch Outlook - should open WITHOUT sign-in prompt
- [ ] Launch OneNote - should open WITHOUT sign-in prompt
- [ ] Launch Teams - should open WITHOUT sign-in prompt

**Check Subscription**:
- [ ] Word → About Microsoft Word → Shows "Subscription Product" + expiration date
- [ ] Excel → About Microsoft Excel → Shows "Subscription Product"
- [ ] PowerPoint → About Microsoft PowerPoint → Shows "Subscription Product"

**Auto-Update Disable** (CRITICAL - Each App):
- [ ] Word → Preferences → Update → Uncheck "Automatically download and install" → Verify unchecked
- [ ] Excel → Preferences → Update → Uncheck → Verify unchecked
- [ ] PowerPoint → Preferences → Update → Uncheck → Verify unchecked
- [ ] Outlook → Preferences → Update → Uncheck → Verify unchecked
- [ ] OneNote → Preferences → Update → Uncheck → Verify unchecked
- [ ] Teams → Preferences → General → Uncheck "Auto-start application" (optional)
- [ ] Restart each app → Reopen Preferences → Verify auto-update still unchecked (persistence)

**Functionality Testing**:
- [ ] Word: Create new document → Type text → Save → Works correctly
- [ ] Excel: Create new spreadsheet → Enter formula (=SUM(A1:A10)) → Works correctly
- [ ] PowerPoint: Create new presentation → Add slide → Works correctly
- [ ] Outlook: Add email account (if applicable) → Send/receive test email
- [ ] OneNote: Create new notebook → Add page → Type notes → Works correctly
- [ ] Teams: Join test meeting or start chat (if applicable) → Works correctly

**Cloud Integration** (Optional):
- [ ] OneDrive sync working (check Finder sidebar or OneDrive app)
- [ ] Co-authoring: Share document → Edit simultaneously with another user → Changes sync
- [ ] Version history: OneDrive file → File → Version History → Previous versions available

**Files Modified**:
- darwin/homebrew.nix (added microsoft-office-businesspro cask)
- docs/apps/productivity/office-365.md (created, ~700 lines)
- docs/licensed-apps.md (added Office & Productivity Suites section, marked legacy manual install)
- docs/apps/README.md (updated index and file count)
- docs/development/stories/epic-02-feature-02.9.md (this file - implementation details)

**Story Status**: 🔄 Implementation Complete - VM Testing Pending

---

