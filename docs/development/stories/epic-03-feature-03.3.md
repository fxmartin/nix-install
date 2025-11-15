# ABOUTME: Epic-03 Feature 03.3 (Trackpad and Input Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 03.3

# Epic-03 Feature 03.3: Trackpad and Input Configuration

## Feature Overview

**Feature ID**: Feature 03.3
**Feature Name**: Trackpad and Input Configuration
**Epic**: Epic-03
**Status**: 🔄 In Progress


  # Touch ID for sudo: Requires adding to /etc/pam.d/sudo
  security.pam.enableSudoTouchIdAuth = true;

  # Disable guest login
  system.defaults.loginwindow.GuestEnabled = false;
  ```
- Touch ID sudo: nix-darwin has built-in support via `security.pam.enableSudoTouchIdAuth`
- Verify: Lock Mac, try to wake (should require password immediately)
- Test sudo: Run `sudo ls` (should prompt for Touch ID)

**Definition of Done**:
- [ ] Screen lock settings implemented
- [ ] Password required immediately after sleep
- [ ] Touch ID for sudo enabled
- [ ] Guest login disabled
- [ ] Settings persist after reboot
- [ ] Tested in VM (Touch ID may not work in VM, test on hardware)
- [ ] Documentation notes security settings

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

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
- [ ] Trackpad settings implemented in macos-defaults.nix
- [ ] Three-finger drag works
- [ ] Tap-to-click enabled
- [ ] Pointer speed is fast
- [ ] Natural scrolling disabled
- [ ] Settings persist after reboot
- [ ] Tested on hardware (VM may not support trackpad fully)
- [ ] Documentation notes trackpad configuration

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
- [ ] Mouse settings implemented in macos-defaults.nix
- [ ] Mouse speed is fast
- [ ] Scroll direction is standard
- [ ] Right-click works
- [ ] Settings persist after reboot
- [ ] Tested with external mouse on hardware
- [ ] Documentation notes mouse configuration

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)
- Story 03.3-001 (Trackpad settings share some NSGlobalDomain keys)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 03.4: Display and Appearance
**Feature Description**: Automate display preferences including light/dark mode, time format, and Night Shift
**User Value**: Consistent appearance settings across all machines
**Story Count**: 2
**Story Points**: 10
**Priority**: Medium
