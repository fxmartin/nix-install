# Epic 03: System Configuration

## Epic Overview
**Epic ID**: Epic-03
**Epic Description**: Automated configuration of macOS system preferences and settings using nix-darwin's `system.defaults` module and `defaults write` commands. Covers Finder preferences, security settings, trackpad/input configuration, display/appearance, keyboard/text settings, and Dock customization to match the Mac-setup repository preferences exactly.
**Business Value**: Eliminates 30+ minutes of manual system preference clicking, ensures consistency across all machines, prevents forgotten security settings
**User Impact**: FX gets a fully configured macOS system with all preferences set automatically during bootstrap, matching familiar Mac-setup configuration
**Success Metrics**:
- All system preferences automated (>90% coverage)
- Zero manual System Preferences clicks required (except FileVault confirmation)
- Settings identical across same-profile machines
- Settings persist across macOS updates and rebuilds

## Epic Scope
**Total Stories**: 12
**Total Story Points**: 68
**MVP Stories**: 12 (100% of epic)
**Priority Level**: Must Have
**Target Release**: Phase 3 (Week 3)

## Features in This Epic

### Feature 03.1: Finder Configuration
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
- Smart folders: Require manual setup (document in customization guide)

**Technical Notes**:
- Add to darwin/macos-defaults.nix:
  ```nix
  system.defaults.finder = {
    ShowExternalHardDrivesOnDesktop = true;
    ShowRemovableMediaOnDesktop = true;
    ShowMountedServersOnDesktop = true;
    NewWindowTarget = "PfHm";  # Home directory
    NewWindowTargetPath = "file://$\{HOME}/";
  };
  ```
- Sidebar customization: Complex, may require mysides tool or manual (document in customization guide)
- Smart folders: Not automatable, document in REQ-DOC-004 (customization guide)

**Definition of Done**:
- [ ] Settings implemented in macos-defaults.nix
- [ ] Sidebar shows common locations
- [ ] Desktop shows external disks
- [ ] New windows open to Home
- [ ] Smart folder customization documented
- [ ] Settings persist after rebuild
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)
- Epic-07, Story 07.4-001 (Customization guide for smart folders)

**Risk Level**: Medium
**Risk Mitigation**: Document manual steps for advanced sidebar customization

---

### Feature 03.2: Security Configuration
**Feature Description**: Automate critical security settings including FileVault, firewall, and password policies
**User Value**: Ensures MacBook is secure by default without manual configuration
**Story Count**: 3
**Story Points**: 18
**Priority**: Critical
**Complexity**: High

#### Stories in This Feature

##### Story 03.2-001: Firewall Configuration
**User Story**: As FX, I want the firewall enabled with stealth mode so that my Mac is protected from network attacks

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I check System Settings → Network → Firewall
- **Then** firewall is enabled
- **And** stealth mode is enabled (Mac doesn't respond to ping/port scans)
- **And** firewall starts automatically on boot
- **And** signed applications are automatically allowed

**Additional Requirements**:
- Firewall enabled by default
- Stealth mode: Drop ping requests, hide from port scans
- Auto-allow signed apps: Reduces prompts for trusted apps
- Persist across reboots

**Technical Notes**:
- Add to darwin/macos-defaults.nix:
  ```nix
  system.defaults.alf = {
    globalstate = 1;  # Enable firewall
    stealthenabled = 1;  # Enable stealth mode
    allowsignedenabled = 1;  # Auto-allow signed apps
  };
  ```
- Verify: System Settings → Network → Firewall shows "On" and stealth mode enabled
- Test: External ping should fail (no response)

**Definition of Done**:
- [ ] Firewall settings implemented in macos-defaults.nix
- [ ] Firewall enabled after rebuild
- [ ] Stealth mode active
- [ ] Signed apps auto-allowed
- [ ] Settings persist after reboot
- [ ] Tested in VM
- [ ] Documentation notes firewall enabled

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 03.2-002: FileVault Encryption Prompt
**User Story**: As FX, I want to be prompted to enable FileVault during bootstrap so that disk encryption is enabled on fresh installs

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** FileVault is not already enabled
- **When** bootstrap completes
- **Then** I receive a clear prompt/message to enable FileVault
- **And** instructions show how to enable it (System Settings → Privacy & Security → FileVault)
- **And** I can enable FileVault and restart
- **Or** if FileVault is already enabled, no prompt appears
- **And** FileVault status is verified in health-check command

**Additional Requirements**:
- Cannot automate FileVault (requires user password and recovery key)
- Must prompt user clearly
- Document in post-install checklist
- Verify in health-check script

**Technical Notes**:
- FileVault cannot be enabled non-interactively (requires user password)
- Add to bootstrap summary or post-install checklist:
  ```bash
  echo "⚠️  IMPORTANT: Enable FileVault disk encryption"
  echo "   1. Open System Settings → Privacy & Security → FileVault"
  echo "   2. Click 'Turn On FileVault'"
  echo "   3. Save recovery key securely (1Password recommended)"
  echo "   4. Restart to complete encryption"
  ```
- Add to health-check script:
  ```bash
  if fdesetup status | grep -q "FileVault is Off"; then
    echo "⚠️  WARNING: FileVault is not enabled (disk not encrypted)"
  else
    echo "✅ FileVault enabled"
  fi
  ```

**Definition of Done**:
- [ ] FileVault prompt added to bootstrap summary
- [ ] Instructions clear and actionable
- [ ] health-check verifies FileVault status
- [ ] Documentation in post-install checklist
- [ ] Tested in VM (prompt appears)
- [ ] Tested with FileVault enabled (no prompt)

**Dependencies**:
- Epic-01, Story 01.8-001 (Bootstrap summary)
- Epic-06, Story 06.4-001 (Health check command)

**Risk Level**: Medium
**Risk Mitigation**: Clear instructions, health-check validation, document recovery key storage

---

##### Story 03.2-003: Screen Lock and Password Policies
**User Story**: As FX, I want password required immediately after sleep/screensaver and Touch ID for sudo so that my Mac is secure when unattended

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** Mac goes to sleep or screensaver activates
- **Then** password is required immediately upon wake
- **And** no grace period (0 seconds delay)
- **When** I run a `sudo` command in terminal
- **Then** I'm prompted for Touch ID (if available)
- **And** I can authenticate with Touch ID or password
- **And** guest user login is disabled

**Additional Requirements**:
- Immediate lock: No delay after sleep/screensaver
- Touch ID for sudo: Convenience with security
- Guest login disabled: Prevent unauthorized access
- Persist across reboots

**Technical Notes**:
- Add to darwin/macos-defaults.nix:
  ```nix
  system.defaults.screensaver = {
    askForPassword = true;
    askForPasswordDelay = 0;  # Immediate
  };

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
- Epic-05, Story 05.1-001: Display appearance settings support Stylix auto-switching
- Epic-06, Story 06.4-001: Health check validates security settings (FileVault, firewall)
- Epic-07, Story 07.4-001: Customization guide documents manual steps (sidebar, Dock apps)

### Stories This Epic Blocks
- None (system configuration is independent)

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 4 | 03.1-001 to 03.6-001 | 68 | All macOS system preferences automated |

### Delivery Milestones
- **Milestone 1**: End Sprint 4 - All system preferences configured
- **Epic Complete**: Week 3 - Settings verified on both profiles in VM and hardware

### Risk Assessment
**Medium Risk Items**:
- Story 03.2-002 (FileVault): Cannot automate, requires clear user prompt and documentation
  - Mitigation: Clear instructions, health-check validation, document recovery key storage
- Story 03.3-001 (Three-finger drag): Accessibility feature, may require additional settings or manual step
  - Mitigation: Test on physical hardware, provide manual instructions if automation fails

**Low Risk Items**:
- Most other stories use standard system.defaults module with low failure risk

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 0 of 12 (0%)
- **Story Points Completed**: 0 of 68 (0%)
- **MVP Stories Completed**: 0 of 12 (0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 4 | 68 | 0 | 0/12 | Not Started |

## Epic Acceptance Criteria
- [ ] All MVP stories (12/12) completed and accepted
- [ ] All system preferences automated (>90% coverage)
- [ ] Zero manual System Settings clicks required (except FileVault and manual customizations)
- [ ] Settings identical across same-profile machines
- [ ] Settings persist across macOS updates and rebuilds
- [ ] FileVault prompt clear and actionable
- [ ] Three-finger drag works on physical hardware
- [ ] Keyboard optimized for coding (no auto-corrections)
- [ ] Security settings enforced (firewall, screen lock, Touch ID sudo)
- [ ] VM testing successful
- [ ] Physical hardware testing successful

## Story Validation Checklist

### Quality Assurance for Each Story
- [ ] Follows proper user story format ("As [persona], I want [functionality] so that [benefit]")
- [ ] Has clear, testable acceptance criteria (Given/When/Then format)
- [ ] Includes all necessary context and constraints
- [ ] Sized appropriately for single sprint
- [ ] Dependencies clearly identified
- [ ] Business value articulated
- [ ] Persona alignment verified (FX as primary user)
- [ ] Technical feasibility confirmed

### Epic Health Metrics
- **Story Readiness**: 100% of stories meet definition of ready
- **Dependency Coverage**: All dependencies identified and managed
- **Estimation Confidence**: High confidence in story point estimates
- **Acceptance Criteria Quality**: Clear, testable, and complete criteria for all stories
