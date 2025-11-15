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
- [ ] Settings implemented in macos-defaults.nix
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
