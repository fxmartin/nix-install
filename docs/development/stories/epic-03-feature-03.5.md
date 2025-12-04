# ABOUTME: Epic-03 Feature 03.5 (Keyboard and Text Input) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 03.5

# Epic-03 Feature 03.5: Keyboard and Text Input

## Feature Overview

**Feature ID**: Feature 03.5
**Feature Name**: Keyboard and Text Input
**Epic**: Epic-03
**Status**: ✅ **COMPLETE** - Hardware Tested

**Complexity**: Low

#### Stories in This Feature

##### Story 03.5-001: Keyboard Repeat and Text Corrections
**User Story**: As FX, I want fast key repeat, short delay, and disabled auto-corrections so that typing feels responsive and predictable for coding

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I hold down a key (e.g., 'a')
- **Then** it repeats quickly after a short delay
- **And** key repeat rate is near maximum
- **And** delay until repeat is short
- **And** automatic capitalization is disabled
- **And** smart quotes are disabled (straight quotes only)
- **And** smart dashes are disabled
- **And** auto-correct/spelling correction is disabled

**Definition of Done**:
- [x] Keyboard settings implemented in macos-defaults.nix
- [x] Key repeat is fast (KeyRepeat = 2)
- [x] Delay until repeat is short (InitialKeyRepeat = 15)
- [x] Auto-capitalization disabled
- [x] Smart quotes/dashes disabled
- [x] Auto-correct disabled
- [x] Settings persist after reboot
- [x] Tested on hardware (MacBook Pro M3 Max - 2025-12-04)
- [x] Documentation notes keyboard configuration

**Implementation Details**:
- **Files Modified**:
  - `darwin/macos-defaults.nix`: Added keyboard settings section
- **Configuration Added**:
  ```nix
  system.defaults.NSGlobalDomain = {
    KeyRepeat = 2;  # Fast repeat (1 = fastest, 2 = very fast)
    InitialKeyRepeat = 15;  # Short delay (10 = shortest, 15 = short, 25 = default)
    NSAutomaticCapitalizationEnabled = false;  # Disable auto-caps
    NSAutomaticDashSubstitutionEnabled = false;  # Disable smart dashes
    NSAutomaticPeriodSubstitutionEnabled = false;  # Disable double-space period
    NSAutomaticQuoteSubstitutionEnabled = false;  # Disable curly quotes
    NSAutomaticSpellingCorrectionEnabled = false;  # Disable auto-correct
  };
  ```
- **Implementation Date**: 2025-12-04
- **Branch**: main

**Technical Notes**:
- **KeyRepeat**: Range 1-15, lower = faster. 2 is very fast (recommended for coding)
- **InitialKeyRepeat**: Range 10-120, lower = shorter delay. 15 is short (recommended)
- All NSAutomatic* settings: `false` disables the feature, essential for coding
- Smart quotes would turn `"hello"` into `"hello"` which breaks code
- Smart dashes would turn `--` into `—` which breaks command-line flags

**VM/Hardware Testing Guide**:
1. **After Rebuild**:
   - Open a text editor (Notes, TextEdit, or any app)
   - Hold down the 'a' key - should repeat quickly after short delay
2. **Verify Settings**:
   ```bash
   defaults read NSGlobalDomain KeyRepeat  # Should be 2
   defaults read NSGlobalDomain InitialKeyRepeat  # Should be 15
   defaults read NSGlobalDomain NSAutomaticCapitalizationEnabled  # Should be 0
   defaults read NSGlobalDomain NSAutomaticDashSubstitutionEnabled  # Should be 0
   defaults read NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled  # Should be 0
   defaults read NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled  # Should be 0
   defaults read NSGlobalDomain NSAutomaticSpellingCorrectionEnabled  # Should be 0
   ```
3. **Test Smart Quotes Disabled**:
   - Open TextEdit → Format → Make Plain Text
   - Type: `"hello"` - should stay as straight quotes, not curly
4. **Test Smart Dashes Disabled**:
   - Type: `--flag` - should stay as two hyphens, not em dash
5. **Test Auto-Correct Disabled**:
   - Type a misspelled word - should NOT auto-correct

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

## Feature 03.5 Summary

**Overall Status**: ✅ **COMPLETE** - Hardware Tested
**Total Story Points**: 5
**Stories Complete**: 1/1 (100%)

**Implementation Files Modified**:
- `darwin/macos-defaults.nix`: Keyboard settings in NSGlobalDomain

**What Works Automatically (via nix-darwin)**:
- ✅ Fast key repeat (KeyRepeat = 2)
- ✅ Short initial delay (InitialKeyRepeat = 15)
- ✅ Auto-capitalization disabled
- ✅ Smart quotes disabled (straight quotes preserved)
- ✅ Smart dashes disabled (-- stays as --)
- ✅ Auto-correct/spelling disabled

**Testing Checklist**:
- [x] Story 03.5-001: Key repeat is fast
- [x] Story 03.5-001: Initial delay is short
- [x] Story 03.5-001: All auto-corrections disabled
- [x] All settings persist after reboot

**Testing Results**:
- **Date**: 2025-12-04
- **Tested By**: FX (via Claude Code)
- **Environment**: MacBook Pro M3 Max (Physical Hardware)
- **Profile**: Power
- **Result**: All settings verified via `defaults read`
- **Conclusion**: Feature 03.5 COMPLETE

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
