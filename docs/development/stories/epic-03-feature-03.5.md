# ABOUTME: Epic-03 Feature 03.5 (Keyboard and Text Input) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 03.5

# Epic-03 Feature 03.5: Keyboard and Text Input

## Feature Overview

**Feature ID**: Feature 03.5
**Feature Name**: Keyboard and Text Input
**Epic**: Epic-03
**Status**: 🔄 In Progress


**Technical Notes**:
- Add to darwin/macos-defaults.nix:
  ```nix
  system.defaults.NSGlobalDomain = {
    KeyRepeat = 2;  # Fast repeat (1 is fastest, 2 is very fast)
    InitialKeyRepeat = 15;  # Short delay (10 is shortest, 15 is short)
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
  };
  ```
- Verify: System Settings → Keyboard, check all settings
- Test: Hold 'a' key, should repeat quickly
- Test: Type quotes in editor, should be straight not curly

**Definition of Done**:
- [ ] Keyboard settings implemented in macos-defaults.nix
- [ ] Key repeat is fast
- [ ] Delay until repeat is short
- [ ] Auto-capitalization disabled
- [ ] Smart quotes/dashes disabled
- [ ] Auto-correct disabled
- [ ] Settings persist after reboot
- [ ] Tested in VM
- [ ] Documentation notes keyboard configuration

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 03.6: Dock Configuration
**Feature Description**: Automate Dock preferences and app management
**User Value**: Clean, minimal Dock with custom apps
**Story Count**: 1
**Story Points**: 4
**Priority**: Medium
**Complexity**: Low

#### Stories in This Feature

##### Story 03.6-001: Dock Behavior and Apps
**User Story**: As FX, I want Dock configured to minimize windows into app icons and optionally auto-hide so that screen space is maximized

**Priority**: Should Have
**Story Points**: 4
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I minimize a window
- **Then** it minimizes into the app icon (not separate Dock icon)
- **And** Dock auto-hide is enabled (optional, configurable)
- **And** Dock shows only running apps (or custom set)
- **And** Dock position is at bottom (or configurable: left, bottom, right)
- **And** settings persist across reboots

**Additional Requirements**:
- Minimize into app icon: Cleaner Dock
- Auto-hide: Optional, saves screen space
- Dock position: Bottom (default) or configurable
- Custom apps: Advanced feature, may require dockutil (document)

**Technical Notes**:
- Add to darwin/macos-defaults.nix:
  ```nix
  system.defaults.dock = {
    minimize-to-application = true;  # Minimize into app icon
    autohide = true;  # Auto-hide Dock (optional, set to false if unwanted)
    orientation = "bottom";  # Dock position (bottom, left, right)
    show-recents = false;  # Don't show recent apps
    tilesize = 48;  # Icon size (configurable)
  };
  ```
- Custom Dock apps: Requires dockutil or manual (document in customization guide)
- Verify: Minimize window (goes into app icon), hide Dock appears on hover
- Test: Check Dock position and size

**Definition of Done**:
- [ ] Dock settings implemented in macos-defaults.nix
- [ ] Windows minimize into app icon
- [ ] Auto-hide works (if enabled)
- [ ] Dock position correct
- [ ] Recent apps not shown
- [ ] Settings persist after reboot
- [ ] Tested in VM
- [ ] Documentation notes Dock configuration

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: All system configuration depends on nix-darwin installed
- **Epic-05 (Theming)**: Display appearance settings interact with Stylix theming
- **Epic-06 (Maintenance)**: FileVault and security settings verified in health-check
- **Epic-07 (Documentation)**: Finder sidebar customization documented, FileVault instructions

### Stories This Epic Enables
