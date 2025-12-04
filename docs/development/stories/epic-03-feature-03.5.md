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
**Status**: ✅ **COMPLETE** - Hardware Tested

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

**Definition of Done**:
- [x] Dock settings implemented in macos-defaults.nix
- [x] Windows minimize into app icon
- [x] Auto-hide works
- [x] Dock position correct (bottom)
- [x] Recent apps not shown
- [x] Settings persist after reboot
- [x] Tested on hardware (MacBook Pro M3 Max - 2025-12-04)
- [x] Documentation notes Dock configuration

**Implementation Details**:
- **Files Modified**:
  - `darwin/macos-defaults.nix`: Added dock configuration section
- **Configuration Added**:
  ```nix
  system.defaults.dock = {
    minimize-to-application = true;  # Minimize into app icon
    autohide = true;  # Auto-hide Dock
    autohide-time-modifier = 0.2;  # Fast hide animation
    autohide-delay = 0.0;  # No delay before showing
    orientation = "bottom";  # Dock position
    show-recents = false;  # Don't show recent apps
    tilesize = 48;  # Icon size
    magnification = false;  # No magnification on hover
    mineffect = "scale";  # Scale effect (faster than genie)
    launchanim = false;  # No bounce animation on launch
    show-process-indicators = true;  # Show dots for running apps
    mru-spaces = false;  # Don't rearrange Spaces automatically
  };
  ```
- **Implementation Date**: 2025-12-04
- **Branch**: main

**Technical Notes**:
- **minimize-to-application**: Windows minimize into their app icon instead of creating separate Dock icons
- **autohide**: Dock hides automatically, appears when mouse moves to screen edge
- **autohide-time-modifier**: Animation speed (0.2 = fast, default ~0.5)
- **autohide-delay**: Time before Dock appears (0 = instant)
- **mineffect**: "scale" is faster/cleaner than "genie"
- **launchanim**: Disabling removes the bouncing icon effect
- **mru-spaces**: Prevents automatic workspace reordering based on recent use

**VM/Hardware Testing Guide**:
1. **After Rebuild**:
   - Dock should auto-hide (move mouse to bottom of screen to show)
   - Minimize a window (Cmd+M) - should go into app icon, not separate icon
2. **Verify Settings**:
   ```bash
   defaults read com.apple.dock minimize-to-application  # Should be 1
   defaults read com.apple.dock autohide  # Should be 1
   defaults read com.apple.dock autohide-time-modifier  # Should be 0.2
   defaults read com.apple.dock autohide-delay  # Should be 0
   defaults read com.apple.dock orientation  # Should be bottom
   defaults read com.apple.dock show-recents  # Should be 0
   defaults read com.apple.dock tilesize  # Should be 48
   defaults read com.apple.dock mineffect  # Should be scale
   defaults read com.apple.dock launchanim  # Should be 0
   defaults read com.apple.dock mru-spaces  # Should be 0
   ```
3. **Test Minimize Behavior**:
   - Open Finder, minimize window (Cmd+M)
   - Window should minimize INTO the Finder icon, not create separate icon
4. **Test Auto-Hide**:
   - Move mouse away from bottom - Dock should hide quickly
   - Move mouse to bottom - Dock should appear instantly (no delay)

**Note on Custom Dock Apps**:
Customizing which apps appear in the Dock requires `dockutil` or manual configuration.
This is documented separately as it involves personal preferences.
Use: `brew install dockutil` then `dockutil --add /Applications/YourApp.app`

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

## Feature 03.6 Summary

**Overall Status**: ✅ **COMPLETE** - Hardware Tested
**Total Story Points**: 4
**Stories Complete**: 1/1 (100%)

**Implementation Files Modified**:
- `darwin/macos-defaults.nix`: Dock settings in system.defaults.dock

**What Works Automatically (via nix-darwin)**:
- ✅ Minimize windows into app icon (cleaner Dock)
- ✅ Auto-hide enabled with instant show (no delay)
- ✅ Fast hide animation (0.2s)
- ✅ Dock at bottom position
- ✅ Recent apps hidden
- ✅ 48px icon size
- ✅ Scale minimize effect (faster than genie)
- ✅ Launch animation disabled (no bouncing)
- ✅ Process indicators shown (dots for running apps)
- ✅ MRU Spaces disabled (predictable workspace order)

**Testing Checklist**:
- [x] Story 03.6-001: Minimize into app icon works
- [x] Story 03.6-001: Auto-hide works with instant show
- [x] Story 03.6-001: Dock position at bottom
- [x] Story 03.6-001: Recent apps not shown
- [x] All settings persist after reboot

**Testing Results**:
- **Date**: 2025-12-04
- **Tested By**: FX (via Claude Code)
- **Environment**: MacBook Pro M3 Max (Physical Hardware)
- **Profile**: Power
- **Result**: All 12 settings verified via `defaults read com.apple.dock`
- **Conclusion**: Feature 03.6 COMPLETE

---

## Epic-03 Complete Summary

**Epic-03 Status**: ✅ **COMPLETE** (All 12 Stories)
**Total Story Points**: 76
**All Features Complete**:
- ✅ Feature 03.1: Finder Configuration (3 stories, 18 pts)
- ✅ Feature 03.2: Security Configuration (3 stories, 18 pts)
- ✅ Feature 03.3: Trackpad and Input (2 stories, 13 pts)
- ✅ Feature 03.4: Display and Appearance (2 stories, 10 pts)
- ✅ Feature 03.5: Keyboard and Text Input (1 story, 5 pts)
- ✅ Feature 03.6: Dock Configuration (1 story, 4 pts)

**Note**: Epic-03 originally had 14 stories (76 pts). Stories 03.7-001 and 03.7-002 (Time Machine - 8 pts) are deferred/optional.

---

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: All system configuration depends on nix-darwin installed
- **Epic-05 (Theming)**: Display appearance settings interact with Stylix theming
- **Epic-06 (Maintenance)**: FileVault and security settings verified in health-check
- **Epic-07 (Documentation)**: Finder sidebar customization documented, FileVault instructions

### Stories This Epic Enables
