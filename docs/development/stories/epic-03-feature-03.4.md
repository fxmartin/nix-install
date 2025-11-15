# ABOUTME: Epic-03 Feature 03.4 (Display and Appearance) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 03.4

# Epic-03 Feature 03.4: Display and Appearance

## Feature Overview

**Feature ID**: Feature 03.4
**Feature Name**: Display and Appearance
**Epic**: Epic-03
**Status**: 🔄 In Progress

**Complexity**: Low

#### Stories in This Feature

##### Story 03.4-001: Auto Light/Dark Mode and Time Format
**User Story**: As FX, I want auto light/dark mode enabled and 24-hour time format so that appearance follows system and time is unambiguous

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** macOS system appearance changes (sunset/sunrise)
- **Then** apps switch between light and dark mode automatically
- **And** menubar clock shows 24-hour format (e.g., 14:30 not 2:30 PM)
- **And** date format is standard (MM/DD/YYYY or configurable)
- **And** Stylix themes (Catppuccin Latte/Mocha) switch with system appearance

**Additional Requirements**:
- Auto appearance: Follow macOS system setting
- 24-hour time: Clarity and international standard
- Stylix integration: Themes should auto-switch
- Persist across reboots

**Technical Notes**:
- Add to darwin/macos-defaults.nix:
  ```nix
  system.defaults.NSGlobalDomain = {
    AppleICUForce24HourTime = true;  # 24-hour time
    # Auto appearance is default macOS behavior, no setting needed
  };
  ```
- Auto appearance: macOS handles this by default, Stylix should follow
- Stylix: Ensure base16Scheme switches with appearance (may need light/dark variants)
- Verify: Change System Settings → Appearance to Light/Dark, check menubar time format

**Definition of Done**:
- [ ] 24-hour time format implemented
- [ ] Menubar clock shows 24-hour time
- [ ] Auto light/dark mode works (default macOS behavior)
- [ ] Stylix themes switch with appearance
- [ ] Settings persist after reboot
- [ ] Tested in VM
- [ ] Documentation notes appearance settings

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)
- Epic-05, Story 05.1-001 (Stylix theming configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 03.4-002: Night Shift Scheduling
**User Story**: As FX, I want Night Shift scheduled from sunset to sunrise so that display color temperature reduces eye strain at night

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** sunset occurs
- **Then** Night Shift activates and warms display color temperature
- **When** sunrise occurs
- **Then** Night Shift deactivates and returns to normal color
- **And** schedule is set to "Sunset to Sunrise"
- **And** settings persist across reboots

**Additional Requirements**:
- Schedule: Automatic based on location and time
- Color warmth: Default or customizable
- Persist across reboots
- Optional: Allow manual override

**Technical Notes**:
- Night Shift settings are in CoreBrightness domain
- Add to darwin/macos-defaults.nix or activation script:
  ```bash
  # Night Shift may require defaults write command in activation script
  system.activationScripts.nightShift.text = ''
    # Enable Night Shift with sunset/sunrise schedule
    /usr/bin/defaults write com.apple.CoreBrightness "CBBlueReductionStatus" -dict-add "AutoBlueReductionEnabled" -bool YES
    /usr/bin/defaults write com.apple.CoreBrightness "CBBlueReductionStatus" -dict-add "BlueReductionMode" -int 1
    /usr/bin/defaults write com.apple.CoreBrightness "CBBlueReductionStatus" -dict-add "BlueReductionSunScheduleAllowed" -bool YES
  '';
  ```
- Verify: System Settings → Displays → Night Shift shows "Sunset to Sunrise"
- May require killall or restart of CoreBrightness daemon

**Definition of Done**:
- [ ] Night Shift settings implemented (activation script or defaults)
- [ ] Schedule set to sunset/sunrise
- [ ] Night Shift activates at sunset
- [ ] Settings persist after reboot
- [ ] Tested in VM (may need to test on hardware for actual schedule)
- [ ] Documentation notes Night Shift configuration

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: Document manual setup if automated approach doesn't work

---

### Feature 03.5: Keyboard and Text Input
**Feature Description**: Automate keyboard preferences for coding (fast repeat, no auto-correct)
**User Value**: Keyboard optimized for development without annoying auto-corrections
**Story Count**: 1
**Story Points**: 5
**Priority**: High
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

**Additional Requirements**:
- Fast repeat: Efficient editing
- Short delay: Responsive feel
- Disable auto-corrections: Critical for coding (no smart quotes in code)
- Straight quotes: Essential for programming
- Persist across reboots
