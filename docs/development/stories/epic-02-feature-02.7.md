# ABOUTME: Epic-02 Feature 02.7 (Security & VPN) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 02.7

# Epic-02 Feature 02.7: Security & VPN

## Feature Overview

**Feature ID**: Feature 02.7
**Feature Name**: Security & VPN
**Epic**: Epic-02
**Status**: 🔄 In Progress

### Feature 02.7: Security & VPN
**Feature Description**: Install VPN client for secure connections
**User Value**: Secure remote access and privacy protection
**Story Count**: 1
**Story Points**: 5
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 02.7-001: NordVPN Installation
**User Story**: As FX, I want NordVPN installed so that I can connect to VPN for privacy and remote access

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch NordVPN
- **Then** it opens and prompts for account sign-in
- **And** menubar icon appears
- **And** I can sign in with my NordVPN account
- **And** auto-update is disabled (if configurable)
- **And** app is marked as requiring activation

**Additional Requirements**:
- Installation via Homebrew Cask
- Requires NordVPN subscription
- Auto-update disable documented if available
- Network extension permissions expected

**Technical Notes**:
- Homebrew cask: `nordvpn`
- Add to darwin/homebrew.nix casks list
- NordVPN: Menubar app, requires sign-in with account
- Auto-update: Check Preferences for disable option (document)
- Network extension: System prompt expected on first connect
- Document in licensed-apps.md (requires subscription)

**Definition of Done**:
- [ ] NordVPN installed via homebrew.nix
- [ ] Launches successfully
- [ ] Shows sign-in screen
- [ ] Menubar icon appears
- [ ] Auto-update documented
- [ ] Marked as licensed app
- [ ] Tested in VM
- [ ] Documentation notes sign-in process

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

#### Implementation Details (Story 02.7-001)

**Implementation Date**: 2025-01-16
**VM Testing Date**: Pending
**Implementation Status**: 🔄 Implementation Complete - VM Testing Pending

**Changes Made**:

1. **Homebrew Cask** (darwin/homebrew.nix):
   ```nix
   # Security & VPN (Story 02.7-001)
   # Auto-update: Check Preferences → Settings → Advanced during VM testing (may not be user-configurable)
   # License: Requires active NordVPN subscription (NO free tier)
   # Permissions: Network Extension permission required on first VPN connection
   "nordvpn" # NordVPN - VPN privacy and security service (subscription required)
   ```

2. **Documentation** (docs/apps/security/nordvpn.md):
   - Created comprehensive NordVPN guide (~900 lines)
   - **Subscription requirement**: NO free tier, paid service only ($3.99-$12.99/month)
   - **Sign-in process**: Email, password, 2FA (if enabled)
   - **Network Extension permission**: REQUIRED - macOS prompts on first connection, click "Allow"
   - **Auto-update research**: Check Settings → Advanced or General during VM testing
   - **Core features**:
     - Quick Connect (one-click VPN, auto-select best server)
     - Server selection (59+ countries, 5,000+ servers)
     - Kill Switch (blocks internet if VPN drops)
     - CyberSec/Threat Protection (ad/malware blocker)
     - Auto-Connect (Wi-Fi, Always, Never options)
     - Split Tunneling (bypass VPN for specific apps)
     - Double VPN (extra encryption layer)
     - Obfuscated servers (bypass VPN blocks)
   - **Protocols**: WireGuard (NordLynx - default), OpenVPN UDP/TCP
   - **Performance**: 70-90% of base internet speed, +10-50ms latency typical
   - **Security**: AES-256 encryption, no-logs policy (audited), DNS/IPv6 leak protection
   - **Menubar states**: Gray shield (disconnected), green (connected), yellow (connecting), red (error)
   - **Troubleshooting**: Connection issues, slow speed, network extension errors, Kill Switch, Split Tunneling
   - **Testing checklist**: Installation, sign-in, permission grant, Quick Connect, server selection, feature testing

3. **Licensed Apps Documentation** (docs/licensed-apps.md):
   - Added **VPN & Security Apps** section with NordVPN
   - **Subscription plans**:
     - 1-month: $12.99/month
     - 1-year: $4.99/month ($59.88 annually, save 62%)
     - 2-year: $3.99/month ($95.76 every 2 years, save 69%, best value)
   - **Account includes**: 6 devices, unlimited bandwidth, all servers (59+ countries), all features
   - **Sign-in workflow**: Launch → Log In → Email/password → 2FA → Network Extension permission → Menubar icon
   - **Network Extension permission** (CRITICAL):
     - macOS prompt: "NordVPN would like to add VPN configurations"
     - Click "Allow" (REQUIRED for VPN to function)
     - If denied: System Settings → Privacy & Security → General → Find NordVPN → Allow
   - **Auto-update research**: Check Settings → Advanced or General during VM testing (document if toggle exists)
   - **Verification**: Installation, launch, sign-in, permission grant, Quick Connect test, IP change verification
   - **Core features to test**: Quick Connect, server selection, Kill Switch, Auto-Connect, CyberSec, Split Tunneling
   - Updated **Overview section** to include NordVPN under "VPN & Security"
   - Updated **Summary Table** with NordVPN entry

4. **App Documentation Index** (docs/apps/README.md):
   - Added **Security & VPN** section (new category)
   - Added NordVPN entry with link to nordvpn.md
   - Updated **File Organization** tree to include `security/` directory
   - Updated **Notes for FX**: 21 total files (added nordvpn.md, ~900 lines)

**Key Implementation Decisions**:
- **Homebrew Cask**: Official NordVPN macOS app distribution
- **Subscription Required**: NO free tier - active subscription mandatory for any VPN usage
- **Network Extension Permission**: macOS security prompt required on first connection (click "Allow")
- **Auto-Update Research**: Investigate during VM testing (may not be user-configurable, Homebrew-controlled)
- **Comprehensive Documentation**: 900-line guide covering all features, troubleshooting, security notes

**Post-Install Configuration** (Manual Steps for VM Testing):
1. Launch NordVPN from Applications or Spotlight
2. Click **"Log In"** button on welcome screen
3. Enter NordVPN account **email** and **password**
4. Complete **2FA** if enabled (6-digit code from authenticator app)
5. Grant **Network Extension permission** when macOS prompts (click "Allow" - REQUIRED)
6. Grant **Notifications permission** (optional but recommended)
7. Menubar icon appears (gray shield when disconnected)
8. Configure settings:
   - **Kill Switch**: Settings → General → Enable (recommended for privacy)
   - **Auto-Connect**: Settings → General → Select "Wi-Fi" (recommended for public networks)
   - **CyberSec/Threat Protection**: Settings → Enable for ad/malware blocking
   - **Auto-Update**: **RESEARCH** - Check Settings → Advanced or General for auto-update toggle
9. Test VPN connection:
   - Click menubar → **Quick Connect**
   - Wait 5-10 seconds → Icon turns green shield (connected)
   - Visit https://whatismyip.com → Verify IP changed to VPN IP
   - Disconnect → Icon returns to gray shield

**VM Testing Checklist** (for FX):
- [ ] Run `darwin-rebuild switch --flake ~/nix-install#power` (or #standard)
- [ ] Verify NordVPN installed at `/Applications/NordVPN.app`
- [ ] Launch NordVPN - sign-in screen appears
- [ ] Sign in with NordVPN subscription account (email + password)
- [ ] Complete 2FA if enabled (6-digit code from authenticator app)
- [ ] **Grant Network Extension permission** when macOS prompts (click "Allow")
- [ ] Verify menubar icon appears (gray shield when disconnected)
- [ ] Click menubar → **Quick Connect**
- [ ] Wait for connection (~5-10 seconds)
- [ ] Verify menubar icon turns **green shield** (connected)
- [ ] Check menubar dropdown shows: "Connected" + server name + VPN IP
- [ ] Visit https://whatismyip.com in browser
- [ ] **Verify IP address changed** to VPN IP (different from real IP)
- [ ] Disconnect VPN (menubar → Disconnect)
- [ ] Verify menubar icon returns to **gray shield** (disconnected)
- [ ] Test specific server: Menubar → Select "United States" → Connect
- [ ] Verify connection successful (green shield, status shows "United States")
- [ ] Disconnect → Reconnect to different server (e.g., "United Kingdom")
- [ ] Test **Kill Switch**: Settings → General → Kill Switch → Enable
- [ ] Verify Kill Switch enabled (may need to disconnect/reconnect VPN to test)
- [ ] Test **Auto-Connect**: Settings → General → Auto-connect → Select "Wi-Fi"
- [ ] Test **CyberSec/Threat Protection**: Settings → Toggle ON
- [ ] Test **Split Tunneling**: Settings → Split Tunneling → Enable → Add app (e.g., Safari)
- [ ] **RESEARCH AUTO-UPDATE SETTING** (CRITICAL):
   - [ ] Check Settings → **Advanced** tab → Look for auto-update toggle
   - [ ] Check Settings → **General** tab → Look for auto-update toggle
   - [ ] **If auto-update toggle found**:
     - [ ] Note exact location (e.g., "Settings → Advanced → Auto-update")
     - [ ] **Uncheck** auto-update toggle
     - [ ] Update docs/apps/security/nordvpn.md with exact path
     - [ ] Update docs/licensed-apps.md with findings
   - [ ] **If NO auto-update toggle found**:
     - [ ] Confirm updates are Homebrew-controlled only
     - [ ] Update docs/apps/security/nordvpn.md to note Homebrew-only updates
     - [ ] Update docs/licensed-apps.md to note Homebrew-only updates
- [ ] Check Settings → **Account** tab → Verify shows active subscription
- [ ] Verify subscription expiration date displayed
- [ ] Test menubar icon states:
   - [ ] Gray shield = disconnected
   - [ ] Green shield = connected
   - [ ] Yellow shield = connecting (if visible during connection)
- [ ] Test multiple connect/disconnect cycles (at least 3 times)
- [ ] Verify VPN reconnects reliably after each disconnect
- [ ] Check server load percentages in server list (aim for <50% load)
- [ ] Test VPN speed: Run https://speedtest.net before and after VPN connection
- [ ] Verify speed is 70-90% of base internet speed (acceptable performance)
- [ ] Test connection to different regions:
   - [ ] North America (e.g., United States, Canada)
   - [ ] Europe (e.g., United Kingdom, Germany)
   - [ ] Asia (e.g., Japan, Singapore)
- [ ] Verify each region connection successful
- [ ] Check protocol setting: Settings → Connection → VPN Protocol
- [ ] Verify WireGuard (NordLynx) is default protocol
- [ ] Test protocol switch: Change to OpenVPN UDP → Disconnect → Reconnect → Verify works
- [ ] Switch back to WireGuard → Verify works
- [ ] Verify menubar dropdown shows:
   - [ ] Connection status (Connected/Disconnected)
   - [ ] Current server (country, city, server number)
   - [ ] Your IP address (VPN IP when connected)
   - [ ] Protocol (WireGuard/OpenVPN)
- [ ] **Document all findings** in VM testing notes (especially auto-update setting)

**Files Modified**:
- darwin/homebrew.nix (added `nordvpn` cask with subscription note and permissions note)
- docs/apps/security/nordvpn.md (created, ~900 lines - comprehensive VPN guide)
- docs/licensed-apps.md (added VPN & Security Apps section + NordVPN details)
- docs/apps/README.md (added Security & VPN section + updated file organization)
- docs/development/stories/epic-02-feature-02.7.md (this file - implementation details)

**Research Items for VM Testing**:
1. **Auto-update setting location** (CRITICAL):
   - Check: Settings → Advanced tab
   - Check: Settings → General tab
   - Document: Exact toggle location if exists, or note Homebrew-controlled if not
2. **Network Extension permission prompt** (verify exact wording on macOS)
3. **Menubar icon states** (verify colors: gray, green, yellow, red)
4. **CyberSec vs Threat Protection naming** (app version dependent, verify current name)
5. **Server load percentages** (verify displayed in server list)
6. **VPN speed performance** (verify 70-90% of base speed typical)

**Story Status**: 🔄 Implementation Complete - VM Testing Pending

**Next Steps**:
1. FX performs VM testing following checklist above
2. FX **documents auto-update setting** (critical research item)
3. FX verifies all acceptance criteria met
4. FX updates documentation if needed based on findings
5. FX marks story as "VM Tested" when complete
6. Story points earned: 5 (Feature 02.7 complete - 5/5 points)

---

