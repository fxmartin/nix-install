# ABOUTME: Epic-03 Feature 03.3 (Trackpad and Input Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 03.3

# Epic-03 Feature 03.3: Trackpad and Input Configuration

## Feature Overview

**Feature ID**: Feature 03.3
**Feature Name**: Trackpad and Input Configuration
**Epic**: Epic-03
**Status**: ✅ **COMPLETE** - Ready for VM Testing

### Feature 03.3: Trackpad and Input Configuration
**Feature Description**: Automate trackpad, mouse, and input device preferences
**User Value**: Three-finger drag and fast pointer configured without manual System Settings navigation
**Story Count**: 2
**Story Points**: 13
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 03.3-001: Trackpad Gestures and Speed
**User Story**: As FX, I want three-finger drag enabled, tap-to-click enabled, and fast pointer speed so that trackpad feels responsive

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I use the trackpad
- **Then** three-finger drag moves windows
- **And** tap-to-click is enabled
- **And** pointer speed is fast (close to maximum)
- **And** natural scrolling is disabled (standard scroll direction)
- **And** secondary click works with two-finger tap or bottom-right corner

**Additional Requirements**:
- Three-finger drag: Accessibility feature, critical for workflow
- Tap-to-click: Convenience over physical click
- Fast pointer: Efficient navigation
- Natural scrolling OFF: Match Mac-setup preference
- Secondary click: Two fingers or corner

**Technical Notes**:
- Add to darwin/macos-defaults.nix:
  ```nix
  system.defaults.trackpad = {
    Clicking = true;  # Tap to click
    TrackpadThreeFingerDrag = true;  # Three-finger drag
  };

  system.defaults.NSGlobalDomain = {
    "com.apple.trackpad.scaling" = 3.0;  # Fast pointer speed (0.0-3.0)
    "com.apple.swipescrolldirection" = false;  # Disable natural scrolling
  };

  # Three-finger drag requires Accessibility domain
  system.defaults."com.apple.AppleMultitouchTrackpad" = {
    TrackpadThreeFingerDrag = true;
  };
  system.defaults."com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
    TrackpadThreeFingerDrag = true;
  };
  ```
- Note: Three-finger drag is an Accessibility feature, may require additional settings
- Verify: Open System Settings → Trackpad, check all settings
- Test: Drag window with three fingers

**Definition of Done**:
- [x] Trackpad settings implemented in macos-defaults.nix
- [x] Three-finger drag works
- [x] Tap-to-click enabled
- [x] Pointer speed is fast
- [x] Natural scrolling disabled
- [x] Settings persist after reboot
- [x] Tested on hardware (MacBook Pro M3 Max - 2025-12-04)
- [x] Documentation notes trackpad configuration

**Implementation Details**:
- **Files Modified**:
  - `darwin/macos-defaults.nix`: Added trackpad configuration section
- **Configuration Added**:
  - `system.defaults.trackpad.Clicking = true`: Tap-to-click enabled
  - `system.defaults.trackpad.TrackpadThreeFingerDrag = true`: Three-finger drag
  - `system.defaults."com.apple.AppleMultitouchTrackpad".TrackpadThreeFingerDrag = true`: Accessibility domain
  - `system.defaults."com.apple.driver.AppleBluetoothMultitouch.trackpad".TrackpadThreeFingerDrag = true`: Bluetooth trackpad
  - `NSGlobalDomain."com.apple.trackpad.scaling" = 3.0`: Maximum trackpad speed
  - `NSGlobalDomain."com.apple.swipescrolldirection" = false`: Disable natural scrolling
- **Implementation Date**: 2025-12-04
- **Branch**: main

**VM Testing Guide**:
1. **Before Rebuild**: Check System Settings → Trackpad (note current settings)
2. **Run Rebuild**: `darwin-rebuild switch --flake .#power` (or .#standard)
3. **After Rebuild**:
   - Open System Settings → Trackpad → Point & Click
   - Verify tap-to-click is ON
   - Verify tracking speed is at maximum (rightmost position)
   - Open System Settings → Trackpad → Scroll & Zoom
   - Verify Natural Scrolling is OFF
4. **Test Three-Finger Drag**:
   - Open System Settings → Accessibility → Motor → Pointer Control → Trackpad Options
   - Verify "Dragging style" shows "Three Finger Drag"
   - Test by dragging a Finder window with three fingers
5. **Test Tap-to-Click**:
   - Tap (don't press) on trackpad - should register as click
6. **Test Scroll Direction**:
   - Two-finger scroll down - content should move DOWN (standard behavior)
7. **Test Persistence**:
   - Restart Mac
   - Verify all trackpad settings remain

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Medium
**Risk Mitigation**: Test on physical hardware, provide manual steps if automation fails

---

##### Story 03.3-002: Mouse and Scroll Settings
**User Story**: As FX, I want fast mouse tracking speed and natural scrolling disabled for external mice so that external input devices are comfortable

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I connect an external mouse
- **Then** pointer speed is fast
- **And** scroll direction is standard (not natural/inverted)
- **And** secondary click works with right-click button
- **And** settings apply to all connected mice

**Additional Requirements**:
- Fast mouse speed: Efficient pointer movement
- Standard scrolling: Matches trackpad preference
- Right-click: Secondary button
- Apply to all mice: Universal setting

**Technical Notes**:
- Add to darwin/macos-defaults.nix:
  ```nix
  system.defaults.NSGlobalDomain = {
    "com.apple.mouse.scaling" = 3.0;  # Fast mouse speed
    "com.apple.swipescrolldirection" = false;  # Already set for trackpad
  };
  ```
- Mouse settings may share NSGlobalDomain with trackpad
- Verify: Connect external mouse, test speed and scrolling
- Test: Right-click should work

**Definition of Done**:
- [x] Mouse settings implemented in macos-defaults.nix
- [x] Mouse speed is fast
- [x] Scroll direction is standard
- [x] Right-click works
- [x] Settings persist after reboot
- [x] Tested on hardware (MacBook Pro M3 Max - 2025-12-04)
- [x] Documentation notes mouse configuration

**Implementation Details**:
- **Files Modified**:
  - `darwin/macos-defaults.nix`: Added mouse speed to NSGlobalDomain
- **Configuration Added**:
  - `NSGlobalDomain."com.apple.mouse.scaling" = 3.0`: Maximum mouse speed
  - Natural scrolling setting (`com.apple.swipescrolldirection = false`) applies to both trackpad and mice
- **Implementation Date**: 2025-12-04
- **Branch**: main

**VM Testing Guide**:
1. **Before Rebuild**: Connect external mouse, note current settings
2. **Run Rebuild**: `darwin-rebuild switch --flake .#power` (or .#standard)
3. **After Rebuild**:
   - Open System Settings → Mouse
   - Verify tracking speed is at maximum (rightmost position)
   - Verify Natural Scrolling is OFF
4. **Test Mouse Speed**:
   - Move mouse - cursor should move quickly across screen
5. **Test Scroll Direction**:
   - Scroll wheel down - content should move DOWN (standard behavior)
6. **Test Right-Click**:
   - Right mouse button should open context menus
7. **Test Persistence**:
   - Restart Mac
   - Verify all mouse settings remain

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)
- Story 03.3-001 (Trackpad settings share some NSGlobalDomain keys)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

## Feature 03.3 Summary

**Overall Status**: ✅ **COMPLETE** - Ready for VM/Hardware Testing
**Total Story Points**: 13 (8 + 5)
**Stories Complete**: 2/2 (100% code complete)

**Implementation Files Modified**:
- `darwin/macos-defaults.nix`: Trackpad + mouse configuration

**Testing Checklist**:
- [x] Story 03.3-001: Tap-to-click enabled ✅
- [x] Story 03.3-001: Three-finger drag works ✅
- [x] Story 03.3-001: Trackpad speed at maximum ✅
- [x] Story 03.3-001: Natural scrolling disabled ✅
- [x] Story 03.3-002: Mouse speed at maximum ✅
- [x] Story 03.3-002: Mouse scroll direction standard ✅
- [x] All settings persist after reboot ✅

**Testing Results**:
- **Date**: 2025-12-04
- **Tested By**: FX
- **Environment**: MacBook Pro M3 Max (Physical Hardware)
- **Profile**: Power
- **Result**: All test cases passed
- **Conclusion**: Feature 03.3 COMPLETE

---

### Feature 03.4: Display and Appearance
**Feature Description**: Automate display preferences including light/dark mode, time format, and Night Shift
**User Value**: Consistent appearance settings across all machines
**Story Count**: 2
**Story Points**: 10
**Priority**: Medium
