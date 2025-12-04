# ABOUTME: Epic-03 Feature 03.2 (Security Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 03.2

# Epic-03 Feature 03.2: Security Configuration

## Feature Overview

**Feature ID**: Feature 03.2
**Feature Name**: Security Configuration
**Epic**: Epic-03
**Status**: 🔄 In Progress

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
**Status**: ✅ **IMPLEMENTED** (Pending VM Testing)

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

**Implementation Details**:
- **Files Modified**:
  - `darwin/macos-defaults.nix`: Added `system.defaults.alf` configuration block
- **Configuration Added**:
  - `globalstate = 1`: Enables firewall (0=off, 1=on, 2=block all)
  - `stealthenabled = 1`: Enables stealth mode (no ping/port scan responses)
  - `allowsignedenabled = 1`: Auto-allows code-signed applications
- **Comments**: Comprehensive explanations for each setting and their values
- **Location**: After loginwindow settings, within system.defaults block
- **Branch**: `feature/03.2-001-firewall-configuration`

**Definition of Done**:
- [x] Firewall settings implemented in macos-defaults.nix
- [ ] Firewall enabled after rebuild (FX to test)
- [ ] Stealth mode active (FX to test)
- [ ] Signed apps auto-allowed (FX to test)
- [ ] Settings persist after reboot (FX to test)
- [ ] Tested in VM (FX to test)
- [ ] Documentation notes firewall enabled

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

**VM Testing Guide**:
1. **Before Rebuild**: Check System Settings → Network → Firewall (should be off/default)
2. **Run Rebuild**: `darwin-rebuild switch --flake .#power` (or .#standard)
3. **After Rebuild**:
   - Open System Settings → Network → Firewall
   - Verify firewall shows "On"
   - Verify stealth mode is enabled
   - Verify "Automatically allow signed software to receive incoming connections" is checked
4. **Test Stealth Mode**:
   - Get Mac's IP address: `ipconfig getifaddr en0`
   - From another machine on same network: `ping <mac-ip>` (should timeout/fail)
   - From Mac itself: `ping localhost` (should work - stealth only blocks external)
5. **Test Persistence**:
   - Restart Mac
   - Verify firewall settings remain after reboot
6. **Test Signed App Behavior**:
   - Install a signed app (e.g., from Homebrew)
   - Verify no firewall prompt appears when app tries to accept connections

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
