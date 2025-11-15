# ABOUTME: VM testing guide for Story 02.4-004 (Dropbox Installation)
# ABOUTME: Provides comprehensive test scenarios for FX to validate Dropbox functionality

# VM Testing Guide: Dropbox Installation (Story 02.4-004)

## Overview

This guide provides comprehensive test scenarios for validating Dropbox installation and configuration in the VM environment. All tests must pass before deploying to physical MacBooks.

**Story**: 02.4-004 - Dropbox Installation
**Points**: 3
**Epic**: Epic-02, Feature 02.4 (Productivity & Utilities)

---

## Prerequisites

1. VM running macOS with darwin-rebuild completed
2. Internet connection (required for Dropbox account sign-in and sync)
3. Dropbox account credentials (or ability to create test account)
4. Access to Dropbox web interface (https://www.dropbox.com)

---

## Test Scenario 1: Installation Verification

**Objective**: Verify Dropbox installed correctly via Homebrew

**Steps**:
1. Run `darwin-rebuild switch --flake ~/nix-install#power`
2. Wait for rebuild to complete
3. Check `/Applications/` folder for Dropbox.app
4. Verify application bundle is complete (not corrupted)

**Expected Outcome**:
- ✅ darwin-rebuild completes without errors
- ✅ Dropbox.app present in `/Applications/` folder
- ✅ Application launches when double-clicked

**Pass Criteria**: All expected outcomes met

---

## Test Scenario 2: First Launch and Account Sign-In

**Objective**: Verify Dropbox launches and prompts for account sign-in

**Steps**:
1. Launch Dropbox from Spotlight (`Cmd+Space`, type "Dropbox")
2. Observe welcome/sign-in screen
3. Sign in with existing Dropbox account:
   - Enter email address
   - Enter password
   - Complete two-factor authentication (if enabled)
4. Complete setup wizard (accept defaults or customize)
5. Wait for initial sync to begin

**Expected Outcome**:
- ✅ Dropbox launches successfully
- ✅ Welcome screen appears with sign-in prompt
- ✅ Account sign-in succeeds
- ✅ `~/Dropbox` folder created in Finder sidebar
- ✅ Menubar icon appears after sign-in
- ✅ Initial sync begins (rotating arrows icon)

**Pass Criteria**: All expected outcomes met

---

## Test Scenario 3: Dropbox Folder Creation and Sync

**Objective**: Verify Dropbox folder created and syncing works

**Steps**:
1. Verify `~/Dropbox` folder exists in Finder
2. Check Finder sidebar for Dropbox folder
3. Create test file in `~/Dropbox` folder:
   - Right-click in Dropbox folder → New Folder → "Test VM Sync"
   - Create text file inside: `echo "Test from VM" > ~/Dropbox/Test\ VM\ Sync/test.txt`
4. Observe Dropbox menubar icon sync status
5. Wait for sync to complete (blue checkmark icon)
6. Open Dropbox web interface (https://www.dropbox.com) in browser
7. Verify test file appears in web interface

**Expected Outcome**:
- ✅ `~/Dropbox` folder exists at `$HOME/Dropbox`
- ✅ Dropbox appears in Finder sidebar
- ✅ Test file created successfully
- ✅ Dropbox menubar icon shows syncing (rotating arrows)
- ✅ Sync completes (blue checkmark icon)
- ✅ Test file visible in Dropbox web interface

**Pass Criteria**: All expected outcomes met, file syncs to cloud

---

## Test Scenario 4: Auto-Update Disable (REQUIRED)

**Objective**: Verify auto-update can be disabled to maintain declarative configuration

**Steps**:
1. Click Dropbox menubar icon
2. Click Profile icon (top-right) → Preferences (or press `Cmd+,`)
3. Navigate to Account tab
4. Find Updates section
5. Verify "Automatically download and install updates" is **checked** (default)
6. **Uncheck** "Automatically download and install updates"
7. Close Preferences
8. Reopen Preferences → Account tab
9. Verify setting remains unchecked

**Expected Outcome**:
- ✅ Preferences opens successfully
- ✅ Account tab accessible
- ✅ Updates section visible
- ✅ "Automatically download and install updates" initially checked
- ✅ Can uncheck auto-update setting
- ✅ Setting persists after closing/reopening Preferences
- ✅ Auto-update now disabled

**Pass Criteria**: Auto-update successfully disabled and persists

---

## Test Scenario 5: Selective Sync Configuration

**Objective**: Verify Selective Sync allows choosing which folders sync locally

**Steps**:
1. Click Dropbox menubar icon → Preferences
2. Navigate to Sync tab
3. Click "Selective Sync" button
4. Observe folder list (may be empty if new account)
5. If folders exist:
   - Uncheck one folder (makes it cloud-only)
   - Click "Update"
   - Verify folder removed from `~/Dropbox` in Finder
   - Reopen Selective Sync
   - Re-check the folder
   - Click "Update"
   - Verify folder downloads to `~/Dropbox`

**Expected Outcome**:
- ✅ Sync tab accessible in Preferences
- ✅ Selective Sync button present
- ✅ Folder list displays (or empty list if new account)
- ✅ Unchecking folder removes it locally (still in cloud)
- ✅ Re-checking folder downloads it locally
- ✅ Selective Sync configuration working correctly

**Pass Criteria**: Selective Sync functionality working (or accessible if no folders yet)

---

## Test Scenario 6: File Sharing

**Objective**: Verify file sharing via link generation works

**Steps**:
1. Right-click test file in `~/Dropbox` folder
2. Select "Share..." from context menu
3. Choose "Copy Link" option
4. Paste link in Notes or browser
5. Verify link format (https://www.dropbox.com/s/...)
6. Open link in browser (logged out or incognito)
7. Verify file accessible via shared link

**Expected Outcome**:
- ✅ Right-click context menu shows "Share..." option
- ✅ Share dialog appears
- ✅ "Copy Link" generates shareable link
- ✅ Link copied to clipboard
- ✅ Link has correct Dropbox format
- ✅ Link accessible in browser (even when logged out)

**Pass Criteria**: File sharing link generation and access works

---

## Test Scenario 7: Menubar Icon Sync Status

**Objective**: Verify menubar icon displays correct sync status

**Steps**:
1. Create large file in `~/Dropbox` folder:
   - `dd if=/dev/zero of=~/Dropbox/largefile.bin bs=1m count=10` (10MB file)
2. Observe Dropbox menubar icon
3. Watch icon change during sync:
   - Rotating arrows (syncing)
   - Blue checkmark (synced)
4. Delete large file
5. Observe icon during deletion sync

**Expected Outcome**:
- ✅ Menubar icon visible at all times
- ✅ Icon shows rotating arrows during sync
- ✅ Icon shows blue checkmark when synced
- ✅ Icon responsive to file changes
- ✅ Clicking icon shows recent activity

**Pass Criteria**: Menubar icon accurately reflects sync status

---

## Test Scenario 8: Dropbox Preferences Accessibility

**Objective**: Verify all preference categories are accessible

**Steps**:
1. Open Dropbox Preferences (`Cmd+,` from menubar icon)
2. Navigate through all tabs:
   - General tab (notifications, startup behavior)
   - Account tab (account info, updates, unlink)
   - Sync tab (selective sync, bandwidth)
   - Backups tab (if available)
3. Verify each tab loads without errors
4. Close Preferences

**Expected Outcome**:
- ✅ Preferences window opens
- ✅ All tabs accessible
- ✅ General tab shows settings
- ✅ Account tab shows account info and update settings
- ✅ Sync tab shows selective sync and bandwidth options
- ✅ No errors or crashes when navigating tabs

**Pass Criteria**: All preference tabs accessible and functional

---

## Test Scenario 9: Account Information Display

**Objective**: Verify account information displayed correctly

**Steps**:
1. Open Dropbox Preferences → Account tab
2. Verify displayed information:
   - Account email address
   - Account plan (Basic, Plus, Professional, Family)
   - Storage usage (e.g., "5 MB of 2 GB used")
3. Note account plan matches expected (Free/Basic for test account)

**Expected Outcome**:
- ✅ Account email displayed correctly
- ✅ Account plan shown (Basic, Plus, etc.)
- ✅ Storage usage displayed
- ✅ Information matches Dropbox web interface

**Pass Criteria**: Account information accurate and displayed correctly

---

## Test Scenario 10: Dropbox Web Interface Consistency

**Objective**: Verify files sync between local and web interface

**Steps**:
1. Create file in `~/Dropbox` folder locally:
   - `echo "Local to web test" > ~/Dropbox/local-test.txt`
2. Wait for sync to complete (blue checkmark)
3. Open Dropbox web interface (https://www.dropbox.com)
4. Verify `local-test.txt` appears in web interface
5. Create file via web interface:
   - Click "Create" → "Text file" → Name it "web-test.txt"
6. Wait a few seconds for sync
7. Verify `web-test.txt` appears in `~/Dropbox` folder locally

**Expected Outcome**:
- ✅ Local file syncs to web interface
- ✅ Web-created file syncs to local folder
- ✅ Bidirectional sync working correctly
- ✅ No file conflicts or errors

**Pass Criteria**: Bidirectional sync works between local and web

---

## Test Scenario 11: Troubleshooting - Restart Dropbox

**Objective**: Verify Dropbox can be quit and restarted successfully

**Steps**:
1. Click Dropbox menubar icon
2. Click Profile icon → Quit Dropbox
3. Verify menubar icon disappears
4. Launch Dropbox from Applications
5. Verify menubar icon reappears
6. Verify sync resumes (check Recent activity)
7. Verify `~/Dropbox` folder still accessible

**Expected Outcome**:
- ✅ Dropbox quits cleanly
- ✅ Menubar icon removed
- ✅ Dropbox relaunches successfully
- ✅ Menubar icon reappears
- ✅ Sync resumes automatically
- ✅ No errors or data loss

**Pass Criteria**: Dropbox restarts cleanly without issues

---

## Test Scenario 12: Acceptance Criteria Validation

**Objective**: Validate all acceptance criteria from Story 02.4-004

**Acceptance Criteria Checklist**:
- [ ] Dropbox installed via darwin/homebrew.nix (verify via `brew list --cask | grep dropbox`)
- [ ] Launches and shows account sign-in screen on first launch
- [ ] Account sign-in succeeds (existing account or new account creation)
- [ ] `~/Dropbox` folder created and syncing files
- [ ] Auto-update disabled via Preferences → Account → Uncheck "Automatically download and install updates"
- [ ] Selective Sync accessible and functional (Preferences → Sync → Selective Sync)
- [ ] Menubar icon appears and shows sync status accurately
- [ ] File sharing works (right-click → Share → Copy Link)
- [ ] Account information displayed correctly in Preferences → Account
- [ ] Bidirectional sync working (local ↔ cloud ↔ web interface)

**Pass Criteria**: All 10 acceptance criteria met

---

## Summary Validation Checklist

After completing all test scenarios, verify:

**Installation**:
- [ ] Dropbox.app installed in `/Applications/`
- [ ] Launches successfully from Spotlight or Applications

**Account Setup**:
- [ ] Account sign-in successful (existing or new account)
- [ ] `~/Dropbox` folder created at `$HOME/Dropbox`
- [ ] Folder appears in Finder sidebar
- [ ] Menubar icon present after sign-in

**Core Functionality**:
- [ ] File sync working (local → cloud, cloud → local)
- [ ] Selective Sync accessible and functional
- [ ] File sharing via link generation works
- [ ] Menubar icon displays accurate sync status

**Configuration**:
- [ ] Auto-update disabled successfully (Preferences → Account)
- [ ] Account information displayed correctly
- [ ] All preference tabs accessible without errors

**Troubleshooting**:
- [ ] Dropbox can be quit and restarted cleanly
- [ ] No sync errors or file conflicts

**Documentation**:
- [ ] All post-install steps documented in app-post-install-configuration.md
- [ ] Troubleshooting guide covers common issues

---

## Test Results Template

```
Test Date: YYYY-MM-DD
VM Environment: macOS [version], [architecture]
Tester: FX

Scenario 1 (Installation): ✅ PASS / ❌ FAIL
Scenario 2 (Account Sign-In): ✅ PASS / ❌ FAIL
Scenario 3 (Folder & Sync): ✅ PASS / ❌ FAIL
Scenario 4 (Auto-Update Disable): ✅ PASS / ❌ FAIL
Scenario 5 (Selective Sync): ✅ PASS / ❌ FAIL
Scenario 6 (File Sharing): ✅ PASS / ❌ FAIL
Scenario 7 (Menubar Status): ✅ PASS / ❌ FAIL
Scenario 8 (Preferences): ✅ PASS / ❌ FAIL
Scenario 9 (Account Info): ✅ PASS / ❌ FAIL
Scenario 10 (Web Sync): ✅ PASS / ❌ FAIL
Scenario 11 (Restart): ✅ PASS / ❌ FAIL
Scenario 12 (Acceptance Criteria): ✅ PASS / ❌ FAIL

Overall Result: ✅ PASS / ❌ FAIL

Issues Encountered:
[List any issues found during testing]

Notes:
[Additional observations or recommendations]
```

---

## Recommended Test Sequence

1. **Day 1**: Scenarios 1-4 (Installation, sign-in, basic sync, auto-update disable)
2. **Day 1**: Scenarios 5-8 (Selective sync, file sharing, menubar, preferences)
3. **Day 2**: Scenarios 9-12 (Account info, web sync, restart, acceptance validation)

**Estimated Testing Time**: 45-60 minutes total

---

## Success Criteria

Story 02.4-004 is considered **VM TESTED** when:
- All 12 test scenarios pass
- All 10 acceptance criteria validated
- Auto-update successfully disabled and persists
- No critical bugs or errors found
- Documentation accurate and complete

---

**Next Steps After VM Testing**:
1. Update epic-02-feature-02.4.md with VM test results
2. Mark Story 02.4-004 as "VM Tested - Complete"
3. Deploy to physical MacBooks (MacBook Pro M3 Max first, then MacBook Airs)
4. Proceed to Story 02.4-005 (System Utilities - Onyx, flux)
