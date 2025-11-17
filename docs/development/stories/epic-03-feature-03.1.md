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
- [ ] Finder shows list view by default
- [ ] Path bar visible
- [ ] Status bar visible
- [ ] Hidden files visible
- [ ] File extensions shown
- [ ] Settings persist after rebuild
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Implementation Details

**Status**: ✅ Code Complete - Ready for VM Testing

**Implementation Date**: 2025-11-17
**Implemented By**: bash-zsh-macos-engineer (Claude Code)
**Branch**: `feature/03.1-001-finder-view-settings`

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

**Testing Outcome**: (To be filled by FX after VM testing)
- [ ] All acceptance criteria met
- [ ] No regressions identified
- [ ] Ready for deployment to physical hardware

**Notes from Testing**: (To be filled by FX)

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
