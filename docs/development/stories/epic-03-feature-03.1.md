# ABOUTME: Epic-03 Feature 03.1 (Finder Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 03.1

# Epic-03 Feature 03.1: Finder Configuration

## Feature Overview

**Feature ID**: Feature 03.1
**Feature Name**: Finder Configuration
**Epic**: Epic-03
**Status**: 🔄 In Progress

**Feature Description**: Automate Finder appearance, behavior, and view preferences
**User Value**: Finder matches familiar Mac-setup configuration without manual clicks
**Story Count**: 3
**Story Points**: 18
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 03.1-001: Finder View and Display Settings
**User Story**: As FX, I want Finder configured with list view, path bar, status bar, and hidden files visible so that I have maximum information when browsing files

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I open a new Finder window
- **Then** default view is list view (not icon or column view)
- **And** path bar is visible at bottom of window
- **And** status bar is visible at bottom of window
- **And** hidden files (dotfiles) are visible
- **And** file extensions are always shown
- **And** settings persist across Finder restarts

**Additional Requirements**:
- Default view: List view for all folders
- Path bar: Shows current folder path
- Status bar: Shows item count and available space
- Hidden files: Show files starting with `.`
- File extensions: Always visible, never hidden

**Technical Notes**:
- Use darwin/macos-defaults.nix with system.defaults:
  ```nix
  system.defaults.finder = {
    FXPreferredViewStyle = "Nlsv";  # List view
    ShowPathbar = true;
    ShowStatusBar = true;
    AppleShowAllFiles = true;  # Show hidden files
    AppleShowAllExtensions = true;
  };
  ```
- May also need NSGlobalDomain settings:
  ```nix
  system.defaults.NSGlobalDomain = {
    AppleShowAllExtensions = true;
  };
  ```
- Verify: Open Finder, check View menu shows path bar and status bar checked

**Definition of Done**:
- [x] Settings implemented in macos-defaults.nix
- [x] Finder shows list view by default
- [x] Path bar visible
- [x] Status bar visible
- [x] Hidden files visible
- [x] File extensions shown
- [x] Settings persist after rebuild
- [x] Tested in VM

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Implementation Details

**Status**: ✅ Complete - VM Tested & Merged to Main

**Implementation Date**: 2025-11-17
**Implemented By**: bash-zsh-macos-engineer (Claude Code)
**VM Testing Date**: 2025-11-19
**Branch**: `feature/03.1-001-finder-view-settings` (merged to main)

#### Changes Made

**File: darwin/macos-defaults.nix**
- ✅ Moved all system defaults from `configuration.nix` to `macos-defaults.nix` for better organization
- ✅ Implemented 5 required Finder view settings:
  - `FXPreferredViewStyle = "Nlsv"` - List view as default (changed from "clmv" column view)
  - `ShowPathbar = true` - Show path bar at bottom of Finder window
  - `ShowStatusBar = true` - Show status bar with item count and space info
  - `AppleShowAllFiles = true` - Show hidden files (dotfiles)
  - `AppleShowAllExtensions = true` - Show all file extensions
- ✅ Added `NSGlobalDomain.AppleShowAllExtensions = true` for system-wide consistency
- ✅ Preserved existing settings: 24-hour time, dark mode, fast key repeat, guest account disabled
- ✅ Added comprehensive comments explaining each setting
- ✅ Added section headers for future Epic-03 stories

**File: darwin/configuration.nix**
- ✅ Removed duplicate system.defaults block (moved to macos-defaults.nix)
- ✅ Added comment explaining migration to macos-defaults.nix

#### Technical Implementation

```nix
system.defaults = {
  finder = {
    FXPreferredViewStyle = "Nlsv";      # List view
    ShowPathbar = true;                 # Path bar visible
    ShowStatusBar = true;               # Status bar visible
    AppleShowAllFiles = true;           # Hidden files visible
    AppleShowAllExtensions = true;      # File extensions shown
  };

  NSGlobalDomain = {
    AppleShowAllExtensions = true;      # System-wide file extensions
    AppleICUForce24HourTime = true;     # 24-hour time (existing)
    AppleInterfaceStyle = "Dark";       # Dark mode (existing)
    KeyRepeat = 2;                      # Fast key repeat (existing)
  };

  loginwindow = {
    GuestEnabled = false;               # Disable guest account (existing)
  };
};
```

#### VM Testing Guide (For FX)

**Prerequisites**:
- Fresh macOS VM (Parallels or other)
- Git repository cloned
- Bootstrap completed successfully
- At least one `darwin-rebuild switch` completed

**Testing Steps**:

1. **Verify Nix Configuration Builds**:
   ```bash
   cd ~/dev/nix-install
   darwin-rebuild build --flake .#standard
   ```
   Expected: Build succeeds with no errors

2. **Apply Configuration**:
   ```bash
   darwin-rebuild switch --flake .#standard
   ```
   Expected: Switch succeeds, may see "restarting Finder" message

3. **Test Finder List View**:
   - Open Finder (Cmd+N or click Finder icon in Dock)
   - Navigate to any folder (e.g., Documents, Downloads)
   - **Expected**: View is displayed as a list (not icons or columns)
   - **Verify**: View menu → "as List" has checkmark (✓)

4. **Test Path Bar Visibility**:
   - Open Finder window
   - Look at bottom of window
   - **Expected**: Path bar is visible showing folder hierarchy (e.g., "MacintoshHD > Users > fx > Documents")
   - **Verify**: View menu → "Show Path Bar" has checkmark (✓)

5. **Test Status Bar Visibility**:
   - Open Finder window with multiple items
   - Look at bottom of window (below path bar if visible)
   - **Expected**: Status bar shows item count (e.g., "23 items, 1.5 GB available")
   - **Verify**: View menu → "Show Status Bar" has checkmark (✓)

6. **Test Hidden Files Visibility**:
   - Open Finder, navigate to Home directory (Cmd+Shift+H)
   - **Expected**: See hidden files like `.zshrc`, `.gitconfig`, `.bash_profile`
   - **Verify**: Look for files starting with `.` (dot)
   - **Shortcut**: Cmd+Shift+. should NOT be needed (already visible)

7. **Test File Extensions Always Shown**:
   - Open Finder, navigate to any folder with files
   - **Expected**: All files show extensions (e.g., `document.txt`, `image.png`, `script.sh`)
   - **Verify**: No files should hide their extensions
   - Check system preferences: Finder → Settings → Advanced → "Show all filename extensions" should be checked

8. **Test Persistence Across Finder Restarts**:
   ```bash
   killall Finder  # Force restart Finder
   ```
   - Finder will restart automatically
   - Open new Finder window
   - **Expected**: All settings (list view, path bar, status bar, hidden files, extensions) still active
   - Repeat tests 3-7 to verify

9. **Test Persistence Across System Reboots**:
   - Restart the macOS VM
   - After reboot, open Finder
   - **Expected**: All settings persist after reboot
   - Repeat tests 3-7 to verify

**Expected Results Summary**:

| Test | Expected Behavior | Pass/Fail |
|------|------------------|-----------|
| Build succeeds | `darwin-rebuild build` completes without errors | ☐ |
| Switch succeeds | `darwin-rebuild switch` applies configuration | ☐ |
| List view default | Finder opens in list view, not icon/column | ☐ |
| Path bar visible | Path hierarchy shown at bottom of Finder | ☐ |
| Status bar visible | Item count and space info shown | ☐ |
| Hidden files visible | Dotfiles (.zshrc, .gitconfig) are visible | ☐ |
| Extensions shown | All files show extensions (.txt, .png, .sh) | ☐ |
| Finder restart | Settings persist after `killall Finder` | ☐ |
| System reboot | Settings persist after macOS reboot | ☐ |

**Troubleshooting**:

| Issue | Possible Cause | Solution |
|-------|---------------|----------|
| Build fails | Syntax error in Nix files | Check error message, verify Nix syntax |
| Settings not applied | Finder didn't restart | Run `killall Finder` manually |
| List view not default | Setting not applied | Check `defaults read com.apple.finder FXPreferredViewStyle` should return "Nlsv" |
| Hidden files not visible | Setting not applied | Check `defaults read com.apple.finder AppleShowAllFiles` should return "1" or "true" |
| Extensions not shown | System override | Check Finder → Settings → Advanced, ensure "Show all filename extensions" is checked |

**Validation Commands** (optional debug):
```bash
# Verify Finder defaults were applied
defaults read com.apple.finder FXPreferredViewStyle    # Should be: Nlsv
defaults read com.apple.finder ShowPathbar             # Should be: 1
defaults read com.apple.finder ShowStatusBar           # Should be: 1
defaults read com.apple.finder AppleShowAllFiles       # Should be: 1
defaults read com.apple.finder AppleShowAllExtensions  # Should be: 1

# Verify global domain setting
defaults read NSGlobalDomain AppleShowAllExtensions    # Should be: 1
```

**Testing Outcome**: ✅ All Tests Passed
- [x] All acceptance criteria met
- [x] No regressions identified
- [x] Ready for deployment to physical hardware

**Notes from Testing**:
- **Date**: 2025-11-19
- **Tested By**: FX
- **Environment**: macOS VM (Parallels)
- **Profile**: Standard
- **Result**: All 8 test cases passed successfully
  - ✅ Build and switch succeeded
  - ✅ List view default confirmed
  - ✅ Path bar visible
  - ✅ Status bar visible
  - ✅ Hidden files (.dotfiles) visible
  - ✅ File extensions shown for all files
  - ✅ Settings persisted after Finder restart
  - ✅ Settings persisted after system reboot
- **Conclusion**: Story 03.1-001 COMPLETE. Ready for physical hardware deployment.

---

##### Story 03.1-002: Finder Behavior Settings
**User Story**: As FX, I want Finder configured to show warning before emptying trash, keep folders on top, and use current directory for search so that Finder behaves predictably

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I use Finder
- **Then** it shows warning before emptying trash
- **And** folders appear before files when sorting by name
- **And** search defaults to current folder (not "This Mac")
- **And** Finder shows warning before changing file extension
- **And** settings persist across Finder restarts

**Additional Requirements**:
- Trash warning: Safety feature to prevent accidental deletion
- Folders on top: Consistent with Mac-setup preferences
- Search scope: Current folder more useful than whole Mac
- Extension warning: Prevent accidental file corruption

**Technical Notes**:
- Add to darwin/macos-defaults.nix:
  ```nix
  system.defaults.finder = {
    WarnOnEmptyTrash = true;
    _FXSortFoldersFirst = true;
    FXDefaultSearchScope = "SCcf";  # Current folder
    FXEnableExtensionChangeWarning = true;
  };
  ```
- Verify: Try emptying trash (should warn), check folder sort order

**Definition of Done**:
- [ ] Settings implemented in macos-defaults.nix
- [ ] Trash emptying shows warning
- [ ] Folders sort before files
- [ ] Search defaults to current folder
- [ ] Extension change shows warning
- [ ] Settings persist after rebuild
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Implementation Details

**Status**: ✅ Code Complete - Ready for VM Testing

**Implementation Date**: 2025-11-19
**Implemented By**: bash-zsh-macos-engineer (Claude Code)
**Branch**: `feature/03.1-002-finder-behavior`

#### Changes Made

**File: darwin/macos-defaults.nix**
- ✅ Added 4 required Finder behavior settings to existing finder block:
  - `WarnOnEmptyTrash = true` - Show confirmation dialog before permanent deletion
  - `_FXSortFoldersFirst = true` - Keep folders at top when sorting by name
  - `FXDefaultSearchScope = "SCcf"` - Search current folder by default (not "This Mac")
  - `FXEnableExtensionChangeWarning = true` - Warn before changing file extensions
- ✅ Added comprehensive comments explaining each setting and options
- ✅ Removed placeholder comment from "Future Epic-03 Settings" section
- ✅ Settings build on Story 03.1-001 foundation (same finder block)

#### Technical Implementation

```nix
finder = {
  # Story 03.1-001 settings (existing)
  FXPreferredViewStyle = "Nlsv";
  ShowPathbar = true;
  ShowStatusBar = true;
  AppleShowAllFiles = true;
  AppleShowAllExtensions = true;

  # Story 03.1-002: Finder Behavior Settings (NEW)
  WarnOnEmptyTrash = true;
  _FXSortFoldersFirst = true;
  FXDefaultSearchScope = "SCcf";  # Current folder
  FXEnableExtensionChangeWarning = true;
};
```

#### VM Testing Guide (For FX)

**Prerequisites**:
- macOS VM from Story 03.1-001 testing (or fresh VM)
- Git repository cloned
- Bootstrap completed successfully
- Story 03.1-001 settings already applied (or will be applied together)

**Testing Steps**:

1. **Verify Nix Configuration Builds**:
   ```bash
   cd ~/dev/nix-install
   darwin-rebuild build --flake .#standard
   ```
   Expected: Build succeeds with no errors

2. **Apply Configuration**:
   ```bash
   darwin-rebuild switch --flake .#standard
   ```
   Expected: Switch succeeds, may see "restarting Finder" message

3. **Test Empty Trash Warning**:
   - Create a test file on Desktop or in Documents
   - Drag file to Trash (Cmd+Delete)
   - Right-click Trash icon in Dock → "Empty Trash"
   - **Expected**: Warning dialog appears: "Are you sure you want to permanently erase the items in the Trash?"
   - **Verify**: Must click "Empty Trash" button to confirm (Cancel button available)
   - Test both: Cancel (trash not emptied) and Confirm (trash emptied)

4. **Test Folders Sort Before Files**:
   - Open Finder, navigate to a folder with both files and folders (e.g., Documents)
   - If needed, create test structure:
     ```bash
     cd ~/Documents
     mkdir test-folder-a test-folder-z
     touch test-file-a.txt test-file-z.txt
     ```
   - In Finder, ensure View → Sort By → Name is selected
   - **Expected**: All folders appear before all files
     - test-folder-a
     - test-folder-z
     - test-file-a.txt
     - test-file-z.txt
   - **Verify**: Folders grouped at top regardless of alphabetical order

5. **Test Search Scope Defaults to Current Folder**:
   - Open Finder, navigate to Documents folder
   - Click in search box (top right) or press Cmd+F
   - **Expected**: Search scope below search box shows "Documents" (current folder name)
   - **Verify**: Search does NOT default to "This Mac"
   - Type a search term and confirm search is scoped to current folder only

6. **Test Extension Change Warning**:
   - Create a test file:
     ```bash
     cd ~/Documents
     echo "test" > test-extension-warning.txt
     ```
   - In Finder, select the file
   - Click on filename to edit → Change extension from `.txt` to `.md`
   - Press Enter
   - **Expected**: Warning dialog appears: "Are you sure you want to change the extension from '.txt' to '.md'?"
   - **Verify**: Must choose "Use .md" or "Keep .txt"
   - Test both options to ensure warning works correctly

7. **Test Settings Persistence Across Finder Restarts**:
   ```bash
   killall Finder  # Force restart Finder
   ```
   - Finder will restart automatically
   - **Expected**: All settings persist
   - Repeat tests 3-6 to verify:
     - Empty trash still warns
     - Folders still sort first
     - Search still defaults to current folder
     - Extension changes still warn

8. **Test Settings Persistence Across System Reboots**:
   - Restart the macOS VM
   - After reboot, verify all settings persist
   - Repeat tests 3-6 one more time to confirm:
     - Trash warning works
     - Folders sort first
     - Search scoped to current folder
     - Extension change warnings appear

**Expected Results Summary**:

| Test | Expected Behavior | Pass/Fail |
|------|------------------|-----------|
| Build succeeds | `darwin-rebuild build` completes without errors | ☐ |
| Switch succeeds | `darwin-rebuild switch` applies configuration | ☐ |
| Empty trash warning | Confirmation dialog before permanent deletion | ☐ |
| Folders sort first | Folders appear before files when sorted by name | ☐ |
| Search current folder | Search defaults to current folder, not "This Mac" | ☐ |
| Extension warning | Warning dialog when changing file extension | ☐ |
| Finder restart | Settings persist after `killall Finder` | ☐ |
| System reboot | Settings persist after macOS reboot | ☐ |

**Troubleshooting**:

| Issue | Possible Cause | Solution |
|-------|---------------|----------|
| Build fails | Syntax error in Nix files | Check error message, verify Nix syntax |
| Settings not applied | Finder didn't restart | Run `killall Finder` manually |
| No trash warning | Setting not applied | Check `defaults read com.apple.finder WarnOnEmptyTrash` should return "1" or "true" |
| Folders not sorting first | Setting not applied | Check `defaults read com.apple.finder _FXSortFoldersFirst` should return "1" or "true" |
| Search wrong scope | Setting not applied | Check `defaults read com.apple.finder FXDefaultSearchScope` should return "SCcf" |
| No extension warning | Setting not applied | Check `defaults read com.apple.finder FXEnableExtensionChangeWarning` should return "1" or "true" |

**Validation Commands** (optional debug):
```bash
# Verify Finder defaults were applied
defaults read com.apple.finder WarnOnEmptyTrash                 # Should be: 1
defaults read com.apple.finder _FXSortFoldersFirst              # Should be: 1
defaults read com.apple.finder FXDefaultSearchScope             # Should be: SCcf
defaults read com.apple.finder FXEnableExtensionChangeWarning   # Should be: 1
```

**Testing Outcome**: (To be filled by FX after VM testing)
- [ ] All acceptance criteria met
- [ ] No regressions identified
- [ ] Ready for deployment to physical hardware

**Notes from Testing**: (To be filled by FX)

---

##### Story 03.1-003: Finder Sidebar and Desktop
**User Story**: As FX, I want Finder sidebar and desktop configured with useful defaults so that I have quick access to important locations

**Priority**: Should Have
**Story Points**: 8
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I open Finder
- **Then** sidebar shows common locations (Home, Documents, Downloads, Applications)
- **And** sidebar shows external disks
- **And** desktop shows external disks and removable media
- **And** new Finder windows open to Home directory
- **And** sidebar customization is documented for manual smart folders

**Additional Requirements**:
- Sidebar: Home, Documents, Downloads, Applications, external disks
- Desktop: External disks, CDs/DVDs, connected servers
- New windows: Open to Home (~/)
