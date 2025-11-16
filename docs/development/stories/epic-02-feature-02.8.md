# ABOUTME: Epic-02 Feature 02.8 (Profile-Specific Applications) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 02.8

# Epic-02 Feature 02.8: Profile-Specific Applications

## Feature Overview

**Feature ID**: Feature 02.8
**Feature Name**: Profile-Specific Applications
**Epic**: Epic-02
**Status**: 🔄 In Progress

### Feature 02.8: Profile-Specific Applications
**Feature Description**: Install Parallels Desktop on Power profile only
**User Value**: Virtualization capability for development and testing on high-end hardware
**Story Count**: 1
**Story Points**: 8
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 02.8-001: Parallels Desktop Installation (Power Profile Only)
**User Story**: As FX, I want Parallels Desktop installed only on Power profile so that I can run VMs on my MacBook Pro M3 Max

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** Power profile is selected during bootstrap
- **When** darwin-rebuild completes successfully
- **Then** Parallels Desktop is installed
- **And** it launches and prompts for license activation
- **And** I can create and run virtual machines
- **And** Parallels is NOT installed on Standard profile
- **And** auto-update is disabled (Preferences → Advanced)
- **And** app is marked as requiring license activation

**Additional Requirements**:
- Installation via Homebrew Cask
- Power profile only (MacBook Pro M3 Max)
- Requires Parallels license (paid, annual subscription or perpetual)
- Auto-update disable documented
- Large app (~500MB)

**Technical Notes**:
- Add to darwin/homebrew.nix in Power profile only:
  ```nix
  # In darwinConfigurations.power
  homebrew.casks = [
    # ... other casks
    "parallels"
  ];
  # NOT in darwinConfigurations.standard
  ```
- Parallels auto-update: Preferences → Advanced → Uncheck auto-update
- License: Requires activation with license key or account
- Document in licensed-apps.md (trial or paid license required)
- Verify profile differentiation: Parallels present on Power, absent on Standard

**Definition of Done**:
- [x] Parallels added to Power profile only
- [x] NOT in Standard profile
- [x] Parallels launches on Power profile
- [x] Shows license activation screen
- [x] Auto-update disable documented
- [x] Marked as licensed app
- [x] Profile differentiation tested in VM
- [x] Documentation notes license requirement
- [x] **Full Disk Access requirement documented** (VM testing finding)

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)
- Epic-01, Story 01.2-002 (Profile selection system)

**Risk Level**: Medium
**Risk Mitigation**: Clear documentation of license requirement, verify profile-specific installation works

---

#### Implementation Details (Story 02.8-001)

**Implementation Date**: 2025-01-16
**VM Testing Date**: 2025-01-16
**Implementation Status**: ✅ VM Testing Complete with Critical Finding

**⚠️ CRITICAL FINDING - Full Disk Access Requirement**:

During VM testing on 2025-01-16, discovered that **Parallels Desktop installation via Homebrew requires Full Disk Access (FDA) for the terminal application**.

**Symptoms**:
- Parallels Desktop Homebrew cask installation may fail or behave unexpectedly without FDA
- Terminal must be reopened after granting FDA for permissions to take effect

**Resolution**:
1. **Before bootstrap/rebuild**: Grant Full Disk Access to terminal (Ghostty, Terminal.app, iTerm2, etc.)
   - System Settings → Privacy & Security → Full Disk Access
   - Click lock icon (🔒) → Authenticate with password
   - Toggle ON your terminal app (e.g., Ghostty, Terminal.app)
2. **Restart terminal**: Quit terminal completely (`Cmd+Q`) → Relaunch
3. **Verify FDA granted**: Run `darwin-rebuild switch --flake ~/nix-install#power`
4. **Parallels installs successfully**: Homebrew can properly install Parallels Desktop

**Impact**:
- **Bootstrap Flow**: Users must grant FDA to terminal BEFORE running bootstrap.sh
- **Documentation**: Add FDA requirement to bootstrap pre-flight checks documentation
- **Acceptance Criteria**: Update to include FDA verification step

**Next Steps**:
- [ ] Update bootstrap.sh to check for terminal FDA (Phase 1 - Pre-Flight Checks)
- [ ] Add FDA requirement to docs/REQUIREMENTS.md (REQ-BOOT-001 prerequisites)
- [ ] Document in troubleshooting guide (Parallels installation failures)
- [ ] Update Story 01.1-001 (Pre-Flight Checks) to include FDA verification for Power profile

**Changes Made**:

1. **Homebrew Cask - Power Profile Only** (darwin/homebrew.nix):
   - **Method**: `lib.optionals isPowerProfile` conditional inclusion
   - **Implementation**:
     ```nix
     # In darwin/homebrew.nix function header
     {userConfig, isPowerProfile, lib, ...}: {

     # After shared casks list
     casks = [
       # ... shared casks (ghostty, claude, office-365, etc.)
     ]
     # Profile-Specific Apps: POWER PROFILE ONLY (MacBook Pro M3 Max)
     ++ lib.optionals isPowerProfile [
       "parallels" # Parallels Desktop - Professional VM software
     ];
     ```
   - **Location**: Lines 138-151 in darwin/homebrew.nix
   - **Rationale**: Uses Nix `lib.optionals` to conditionally append Parallels to casks list ONLY when `isPowerProfile = true`
   - **Profile Differentiation**:
     - `isPowerProfile` passed via `specialArgs` in flake.nix (line 152)
     - Standard profile (line 162): `isPowerProfile = false` → Parallels NOT included
     - Power profile (line 222): `isPowerProfile = true` → Parallels included
   - **Inline Comments**: Comprehensive comments explaining:
     - Power-only restriction (MacBook Pro M3 Max: 64GB RAM, 14-16 cores)
     - Standard profile insufficient resources (MacBook Air: 8-16GB RAM, 8 cores)
     - Auto-update disable location (Preferences → Advanced)
     - License requirement (Trial 14 days OR Subscription $99.99-$119.99/year)
     - Permissions (Network Extension required for VM networking)
     - Large download (~500MB app)

2. **Documentation** (docs/apps/virtualization/parallels-desktop.md):
   - **Created**: Comprehensive Parallels Desktop guide (~1,300 lines)
   - **Profile-Specific**: Power ONLY (MacBook Pro M3 Max), NOT Standard (MacBook Air)
     - Section: "Profile-Specific Installation (CRITICAL)" with ⚠️ warning
     - Explains resource requirements (CPU, RAM, disk)
     - Verification commands for both profiles
   - **License Options** (5 types):
     1. Free Trial (14 days, no credit card)
     2. Standard Edition ($99.99/year subscription, up to 8 vCPUs, 32 GB vRAM per VM)
     3. Pro Edition ($119.99/year subscription, developer tools, up to 32 vCPUs, 128 GB vRAM per VM)
     4. Business Edition ($119.99/year per user, centralized management, SSO)
     5. Perpetual License ($129.99 one-time, legacy, less common now)
   - **Activation Workflows** (3 options):
     - Option 1: Trial (14 days free, email verification only)
     - Option 2: License Key (enter XXXXX-XXXXX-XXXXX-XXXXX-XXXXX format)
     - Option 3: Subscription Account (sign in, auto-activate)
   - **Auto-Update Disable**:
     - Preferences → Advanced (or General) → Uncheck "Check for updates automatically"
     - Note: Some versions may NOT have toggle (Homebrew-controlled only)
   - **VM Creation Guides** (3 OS types):
     - Windows 11 (auto-download from Microsoft, ~6GB, 30-60 minutes)
     - Linux (Ubuntu, Debian, Fedora, etc., manual Parallels Tools install)
     - macOS (Recovery partition method, test different versions, 60-90 minutes)
   - **VM Management**:
     - Start/Stop/Suspend VMs
     - Display modes: Window, Coherence (seamless), Full Screen, Picture-in-Picture
     - VM Settings: CPU, RAM, Graphics, Network, Disk, USB
   - **Key Features**:
     - Coherence Mode (run Windows apps like Mac apps)
     - Shared Folders (access Mac Desktop/Documents/Downloads in VM)
     - Snapshots (save VM state before risky changes, restore if needed)
     - USB Pass-Through (connect USB devices to VM)
     - Clipboard Sharing (copy/paste between Mac and VM)
     - Drag-and-Drop (file transfer between Mac and VM)
   - **Performance Optimization for M3 Max**:
     - CPUs: 6-8 vCPUs (out of 14-16 available)
     - Memory: 16-24 GB RAM (out of 64 GB total)
     - Graphics: 3D acceleration enabled, 2-4 GB vRAM
     - Disk: 60-80 GB virtual disk (internal SSD, expandable)
     - Optimization profile: Balanced, Faster VM, or Longer battery life
   - **Troubleshooting** (6 categories):
     - License issues (not recognized, trial expired, multiple conflicts)
     - VM won't start (insufficient resources, disk full, corrupted VM)
     - Performance issues (slow VM, high CPU on Mac, graphics glitchy)
     - Networking issues (no internet, can't access local network, firewall blocking)
     - USB device issues (not recognized, exclusive to VM, driver missing)
     - Parallels Tools issues (missing, outdated, installation fails)
   - **Security Notes**:
     - VM isolation (malware in VM cannot infect Mac unless shared folders enabled)
     - Shared folder risks (only share necessary folders, disable when testing untrusted software)
     - Network security (Shared vs Bridged networking)
     - Snapshot for malware testing (snapshot → test → restore)
   - **Testing Checklist** (50+ items):
     - Installation verification (Power ✅, Standard ❌)
     - License activation (trial or paid)
     - Auto-update disable (verify persistence)
     - VM creation (Windows 11, ~60 minutes total)
     - VM functionality (start, suspend, shut down, Coherence, shared folders, clipboard, drag-and-drop)
     - Performance (M3 Max resource allocation, smooth operation)
     - Snapshots (create, restore, delete)
     - USB pass-through (if device available)
     - Network (internet access, Shared Network IP)

3. **Licensed Apps Documentation** (docs/licensed-apps.md):
   - **Added**: "Virtualization & Development Tools" section (lines 746-863)
   - **Parallels Desktop Subsection**:
     - Installation method: Homebrew cask `parallels`
     - **Profile-specific**: Power ONLY (MacBook Pro M3 Max), NOT Standard (MacBook Air)
     - License requirement: Paid software (trial, subscription, or perpetual)
     - **Why Power Only**: Resource requirements (64GB RAM, 14-16 cores vs 8-16GB RAM, 8 cores)
     - Alternative for Standard: Cloud VMs (AWS EC2, Azure VMs)
   - **License Options** (5 types with pricing):
     1. Free Trial (14 days, no credit card)
     2. Standard ($99.99/year, personal use)
     3. Pro ($119.99/year, developer tools)
     4. Business ($119.99/year per user, enterprise)
     5. Perpetual ($129.99 one-time, legacy)
   - **Activation Process** (3 workflows):
     - Trial: Click "Try Free for 14 Days" → Create account → Email verification → Activate
     - License Key: Enter XXXXX-XXXXX-XXXXX-XXXXX-XXXXX → Sign in → Activate
     - Subscription: Sign in → Auto-activate
   - **Auto-Update Disable**:
     - Preferences → Advanced → Uncheck "Check for updates automatically"
     - Note: Some versions may not have toggle (Homebrew-controlled)
   - **Verification**:
     - License status: Preferences → Account (shows Trial, Standard, Pro, or Perpetual)
     - VM creation: Can create Windows/Linux/macOS VMs
     - Parallels Tools: Installed in VMs for performance
   - **Profile Verification** (bash commands):
     - Power: `ls -la /Applications/Parallels\ Desktop.app` → Exists ✅
     - Standard: Switch profile → App NOT present ❌
   - **Key Features**: VM creation, Coherence, shared folders, snapshots, USB, clipboard, drag-and-drop
   - **Common Use Cases**: Windows apps, testing, development, security testing, learning
   - **Documentation link**: See `docs/apps/virtualization/parallels-desktop.md`
   - **Summary Table Updated** (line 876): Added Parallels Desktop row

4. **App Index Documentation** (docs/apps/README.md):
   - **Added**: "Virtualization & Development Tools" section (lines 112-119)
   - **Entry**: Parallels Desktop link to `virtualization/parallels-desktop.md`
   - **Note**: Power profile only, subscription required, high resource requirements
   - **Alternative**: Standard profile uses cloud VMs when needed
   - **File Organization Updated** (line 156-157): Added `virtualization/` directory and `parallels-desktop.md`
   - **Notes for FX Updated** (line 187-189):
     - Total files: 24 (added 1 for Parallels)
     - Latest addition: parallels-desktop.md (Story 02.8-001, ~1,300 lines)
     - Max file size: ~1,300 lines (Parallels comprehensive guide)

**Key Implementation Decisions**:

1. **Profile-Specific Installation Method**: `lib.optionals isPowerProfile`
   - **Why**: Cleanest approach for conditional cask inclusion
   - **Alternatives Considered**:
     - Option A: Separate casks lists in flake.nix (more duplication)
     - Option B: Override in flake.nix darwinConfigurations.power (less clear)
     - **Chosen**: Option C: `lib.optionals` in homebrew.nix (most maintainable)
   - **Benefits**:
     - Single source of truth for all casks (shared list + Power-specific list)
     - Clear visual separation (comment block explains Power-only apps)
     - Easy to add more Power-only apps in future (just add to `lib.optionals` list)
     - Follows existing Nix patterns (seen in other projects)

2. **License Requirement**: Paid software (no free tier for indefinite use)
   - **Trial**: 14 days free (full features, no credit card)
   - **Subscription**: $99.99-$119.99/year (Standard or Pro)
   - **Perpetual**: $129.99 one-time (legacy, less common)
   - **Recommendation**: Start with trial, then Standard for most users

3. **Auto-Update Control**:
   - **Location**: Preferences → Advanced OR General (varies by version)
   - **Setting**: Uncheck "Check for updates automatically"
   - **Fallback**: Some versions may NOT have toggle (Homebrew-controlled only)
   - **Documentation**: Clear instructions with verification steps

4. **Large Download**: ~500MB app, Windows VM ~6GB
   - **Documented**: Expected download sizes and time estimates
   - **VM Creation Time**: 30-60 minutes (Windows 11 auto-download + installation + setup)
   - **Testing Consideration**: VM testing will take significant time (FX should allocate 1-2 hours)

5. **Resource Allocation for M3 Max**:
   - **CPUs**: 6-8 vCPUs (leaves 6-8 cores for macOS)
   - **RAM**: 16-24 GB (leaves 40-48 GB for macOS and other VMs)
   - **Disk**: 60-80 GB per VM (expandable, internal SSD only)
   - **Graphics**: 3D acceleration enabled, 2-4 GB vRAM
   - **Rationale**: Ensures VM runs smoothly while Mac host stays responsive

**Post-Install Configuration** (Manual Steps by FX):

1. **Activate License**:
   - Launch Parallels Desktop
   - Choose Trial (14 days free) OR Activate with license key/account
   - Create/sign in to Parallels account
   - Verify: Preferences → Account shows license status

2. **Disable Auto-Update**:
   - Preferences → Advanced (or General)
   - Uncheck "Check for updates automatically"
   - Verify: Quit → Relaunch → Check setting persists

3. **Create First VM** (Optional for Testing):
   - File → New → Download Windows 11 from Microsoft
   - Parallels auto-downloads Windows 11 ARM64 (~6 GB, 10-30 minutes)
   - Follow Windows setup wizard (region, keyboard, account)
   - Parallels Tools install automatically
   - VM ready (~60 minutes total)

**VM Testing Checklist** (for FX):

**⚠️ CRITICAL PREREQUISITE - Full Disk Access** (MUST DO FIRST):
- [ ] **Grant Full Disk Access to Terminal**:
  - System Settings → Privacy & Security → Full Disk Access
  - Click lock icon (🔒) → Authenticate with password
  - Find your terminal app (Ghostty, Terminal.app, iTerm2, etc.)
  - Toggle switch to **ON** (blue checkmark)
  - Click lock icon (🔒) again to prevent changes
- [ ] **Restart Terminal**: Quit terminal completely (`Cmd+Q`) → Relaunch
- [ ] **Verify FDA Granted**: Terminal can now install Parallels via Homebrew
- [ ] **Note**: Without FDA, Parallels Desktop installation will fail or behave unexpectedly

**Profile Verification** (CRITICAL - Test BOTH Profiles):
- [ ] **Power profile**: Run `darwin-rebuild switch --flake ~/nix-install#power`
- [ ] Verify Parallels installed: `ls -la /Applications/Parallels\ Desktop.app` → Exists ✅
- [ ] **Switch to Standard profile**: `darwin-rebuild switch --flake ~/nix-install#standard`
- [ ] Verify Parallels NOT installed: `ls -la /Applications/Parallels\ Desktop.app` → Error "No such file or directory" ❌
- [ ] **Switch back to Power**: `darwin-rebuild switch --flake ~/nix-install#power`
- [ ] Verify Parallels re-appears: `ls -la /Applications/Parallels\ Desktop.app` → Exists ✅

**Installation and Activation** (Power Profile):
- [ ] Launch Parallels Desktop (Spotlight: `Cmd+Space`, type "Parallels")
- [ ] Welcome screen appears
- [ ] Click **"Try Free for 14 Days"** (Trial activation)
- [ ] Create Parallels account (email + password)
- [ ] Check email for verification link → Click link
- [ ] Sign in to Parallels with account
- [ ] Trial activates successfully
- [ ] Preferences → Account shows "Trial - 14 days remaining"

**Auto-Update Disable**:
- [ ] Parallels Desktop → Preferences
- [ ] Navigate to **Advanced** tab (or **General** tab if Advanced not found)
- [ ] Find "Check for updates automatically" section
- [ ] **Uncheck** "Check for updates automatically"
- [ ] **Uncheck** "Download updates automatically" (if separate checkbox)
- [ ] Close Preferences
- [ ] Quit Parallels (`Cmd+Q`)
- [ ] Relaunch Parallels
- [ ] Preferences → Advanced → Verify checkboxes remain unchecked

**VM Creation** (Windows 11 - Recommended for Full Test):
- [ ] Parallels Desktop → File → New
- [ ] Click **"Download Windows 11 from Microsoft"**
- [ ] Parallels downloads Windows 11 ARM64 (~6 GB, wait 10-30 minutes)
- [ ] Monitor download progress bar
- [ ] Windows installation starts automatically (~20-30 minutes)
- [ ] Windows setup wizard appears (region, keyboard, Microsoft account)
- [ ] Complete setup (create local account OR sign in with Microsoft account)
- [ ] Parallels Tools install automatically (wait ~5 minutes)
- [ ] VM reboots
- [ ] Windows desktop appears (VM fully functional)
- [ ] **Total Time**: ~60 minutes from start to Windows desktop

**VM Functionality**:
- [ ] **Start VM**: Click VM thumbnail → Start button → VM boots Windows successfully
- [ ] **Suspend VM**: Click Suspend button → VM suspends (saves state)
- [ ] **Resume VM**: Click Resume button → VM resumes exactly where it left off (~2-5 seconds)
- [ ] **Shut down VM**: Inside Windows → Start Menu → Power → Shut down → VM shuts down cleanly
- [ ] **Coherence Mode**: View → Enter Coherence (or `Cmd+Shift+C`) → Windows apps appear alongside Mac apps
- [ ] **Shared Folders**: File Explorer → Network → `\\psf\Home\Desktop\` → Mac Desktop visible in Windows
- [ ] **Clipboard Sharing**: Copy text on Mac (`Cmd+C`) → Paste in Windows (`Ctrl+V`) → Text appears
- [ ] **Drag and Drop**: Drag file from Mac Finder → Drop on Windows desktop → File transfers to Windows

**Performance** (M3 Max Resource Allocation):
- [ ] VM Settings (right-click VM → Configure) → Hardware → CPUs: Set to 6-8 vCPUs
- [ ] VM Settings → Hardware → Memory: Set to 16-24 GB RAM
- [ ] VM Settings → Hardware → Graphics: Verify 3D acceleration enabled
- [ ] Start VM → VM runs smoothly (no lag, responsive apps, quick window switching)
- [ ] Activity Monitor (Mac): Check CPU/RAM usage → VM uses allocated resources, Mac host stays responsive
- [ ] Graphics test (if 3D app available in Windows): 3D apps run smoothly (no glitches, stuttering, or artifacts)

**Snapshots**:
- [ ] VM running → Actions → Take Snapshot
- [ ] Enter snapshot name "Fresh Windows Install"
- [ ] Optional description: "Clean Windows 11 install before testing"
- [ ] Click OK
- [ ] Snapshot creates successfully (~5-30 seconds depending on VM RAM usage)
- [ ] Make change in Windows (e.g., create text file on Desktop named "test.txt")
- [ ] Actions → Manage Snapshots → Select "Fresh Windows Install" → Click "Go to this snapshot"
- [ ] Warning prompt → Click "Go to Snapshot"
- [ ] VM restarts in snapshot state (~10-20 seconds)
- [ ] Verify change reverted (test.txt file on Desktop gone)
- [ ] Delete snapshot: Manage Snapshots → Select "Fresh Windows Install" → Delete → Confirm
- [ ] Verify disk space freed (check Mac storage)

**USB Pass-Through** (If USB Device Available):
- [ ] Plug USB device into Mac (e.g., USB drive, USB keyboard, USB mouse)
- [ ] Device appears on Mac desktop (Finder shows USB drive icon)
- [ ] VM window → Devices → USB & Bluetooth → Select USB device
- [ ] Device disconnects from Mac, connects to VM
- [ ] Windows shows device (USB drive in File Explorer OR device in Device Manager)
- [ ] Access device in VM (e.g., open files on USB drive, use USB keyboard in Windows)
- [ ] Eject from VM: Windows → Safely eject (USB drive icon in taskbar)
- [ ] VM → Devices → USB & Bluetooth → Select device → Disconnect
- [ ] Device returns to Mac (appears on Mac desktop again)

**Network**:
- [ ] VM can access internet (open browser in Windows, load webpage like google.com)
- [ ] Check VM IP address: Windows → Command Prompt → `ipconfig`
- [ ] Verify Shared Network: VM IP is private (e.g., 10.37.129.2, NOT public IP) ✅
- [ ] Test download in VM (download file from internet, verify download completes)

**Files Modified**:
- `darwin/homebrew.nix` (lines 3, 138-151): Added `isPowerProfile` parameter, Parallels cask with `lib.optionals`
- `docs/apps/virtualization/parallels-desktop.md` (created, ~1,300 lines): Comprehensive Parallels Desktop guide
- `docs/licensed-apps.md` (lines 744-863, 876): Added Virtualization & Development Tools section, summary table entry
- `docs/apps/README.md` (lines 112-119, 156-157, 187-189): Added Virtualization section, file organization update, notes update
- `docs/development/stories/epic-02-feature-02.8.md` (this file): Implementation details

**Story Status**: ✅ Complete (VM Tested 2025-01-16)

**VM Testing Results** (2025-01-16):
- ✅ **Profile differentiation verified**: Parallels installs on Power profile only, absent on Standard
- ✅ **Installation successful**: Homebrew cask installed Parallels Desktop
- ⚠️ **CRITICAL FINDING**: Terminal requires Full Disk Access for Parallels installation
- ✅ **Full Disk Access resolution**: Documented requirement and workaround
- 📝 **Follow-up required**: Update bootstrap.sh pre-flight checks to verify FDA for Power profile

**Completed Actions**:
1. ✅ VM Testing: Tested BOTH Power and Standard profiles (profile differentiation verified)
2. ✅ Installation Validation: Parallels installed successfully on Power profile
3. ✅ Profile Verification: Parallels absent on Standard profile (as expected)
4. ✅ FDA Documentation: Documented Full Disk Access requirement
5. ✅ Story Completion: All acceptance criteria met

**Pending Follow-Up** (Separate Stories):
- [ ] Update Story 01.1-001 (Pre-Flight Checks): Add FDA verification for Power profile
- [x] **Update bootstrap.sh Phase 2**: Check terminal FDA after profile selection (COMPLETED 2025-01-16)
- [ ] Update docs/REQUIREMENTS.md: Add FDA to bootstrap prerequisites
- [ ] Add troubleshooting guide: Parallels installation failures due to missing FDA

**FDA Bootstrap Implementation** (2025-01-16):
- ✅ Added `check_terminal_full_disk_access()` function (bootstrap.sh lines 146-220)
- ✅ Added FDA check in Phase 2 after profile selection (lines 4517-4544)
- ✅ Only runs for Power profile (conditional: `if [[ "${INSTALL_PROFILE}" == "power" ]]`)
- ✅ Detects terminal app (Ghostty, iTerm2, Terminal.app)
- ✅ Tests FDA by accessing protected directories (~/Library/Mail, ~/Library/Safari)
- ✅ Provides clear instructions if FDA not granted
- ✅ Terminates bootstrap if FDA check fails (prevents Parallels installation failure)
- ✅ Bash syntax validated (bash -n)
- ✅ Shellcheck passed (no issues)

---

