# ABOUTME: Licensed application activation and sign-in guide
# ABOUTME: Documents apps requiring licenses, accounts, or activation after installation

# Licensed Applications and Account Requirements

This document provides guidance for applications that require licenses, subscriptions, or account activation after installation via nix-darwin.

**Estimated Time**: 15-20 minutes total to activate all apps

**Philosophy**: Some applications cannot be fully configured via nix-darwin and require manual activation, sign-in, or license key entry. This document tracks those apps and provides activation instructions.

---

## Quick Reference

| App | Type | Time | Priority |
|-----|------|------|----------|
| **1Password** | Sign-in | 2 min | High (password access) |
| **NordVPN** | Sign-in | 2 min | Medium (VPN access) |
| **iStat Menus** | License key | 1 min | Low (trial available) |
| **Little Snitch** | License key | 2 min | Low (trial available) |
| **Office 365** | Sign-in | 3 min | If needed |

**Recommended order**: 1Password first (to retrieve other credentials), then remaining apps.

---

## Overview

The following apps require manual setup after installation:

**Productivity & Security**:
- **1Password**: Requires account sign-in (subscription or license)
- **Microsoft Office 365**: Requires active subscription (Personal, Family, or Company)

**VPN & Security**:
- **NordVPN**: Requires active subscription (NO free tier, $3.99-$12.99/month)

**System Monitoring**:
- **iStat Menus**: Commercial software ($11.99 USD) with 14-day free trial

**Development Tools**:
- None currently (all dev tools are free/open source)

---

## Productivity & Security Apps

### 1Password

**Installation**: Installed via Homebrew cask `1password` (Story 02.4-002)

**License Requirement**: 1Password requires a **subscription** (individual or family plan) OR a **license key** (legacy standalone license, no longer sold).

**Account Options**:

1. **1Password Subscription** (Current Model):
   - **Individual**: $2.99/month - 1 account, unlimited devices, all features
   - **Families**: $4.99/month - 5 accounts, shared vaults, guest accounts
   - **Teams**: $7.99/user/month - Business features, admin controls
   - **Business**: $19.95/user/month - Advanced security, compliance, SSO
   - **Sign up**: https://1password.com/sign-up/

2. **Company-Provided License** (Teams/Business):
   - Employer provides 1Password account
   - Sign in with company email and master password
   - May include SSO integration (Google, Microsoft, Okta)
   - IT admin manages team settings and permissions

3. **Legacy Standalone License** (No Longer Sold):
   - One-time purchase license (v7 or earlier)
   - No subscription required
   - Limited to purchased version (no updates to v8+)
   - Sync via iCloud (not 1Password.com)

**Activation Steps**:

**Option A: New Subscription**
1. Launch 1Password from Spotlight (`Cmd+Space`, type "1Password")
2. Click **Get Started** or **Sign Up**
3. Visit https://1password.com/sign-up/ in browser
4. Choose plan: Individual ($2.99/month) or Families ($4.99/month)
5. Enter email, create master password (CRITICAL - store securely, cannot be recovered)
6. Complete payment information
7. Download Emergency Kit (PDF with account details - store safely)
8. Return to 1Password app → Sign in with:
   - **Email**: Your signup email
   - **Secret Key**: From Emergency Kit PDF
   - **Master Password**: Your chosen master password
9. 1Password unlocks → Begin adding passwords

**Option B: Company Account**
1. Receive invitation email from IT admin with subject "You've been invited to [Company Name]"
2. Click **Accept Invitation** link in email
3. Create master password (or use SSO if configured)
4. Download Emergency Kit (store safely)
5. Launch 1Password from Spotlight (`Cmd+Space`, type "1Password")
6. Sign in with company email and master password (or SSO)
7. 1Password unlocks → Company vaults appear

**Option C: Legacy Standalone License**
1. Launch 1Password from Spotlight (`Cmd+Space`, type "1Password")
2. Click **I have a license key**
3. Enter license key (from purchase email or license file)
4. Choose vault location:
   - **iCloud**: Sync via iCloud Drive
   - **Local**: No sync (Mac only)
5. Create master password for vault
6. 1Password unlocks → Ready to use

**Master Password Guidelines**:
- **CRITICAL**: Master password cannot be recovered if forgotten (1Password cannot reset it)
- Use 3-4 random words: e.g., "correct-horse-battery-staple" (easy to remember, hard to crack)
- Minimum 16 characters recommended for strong security
- Store Emergency Kit in safe place (physical safe, safety deposit box)
- Never share master password (1Password staff will never ask for it)

**License Verification**:
```bash
# Check subscription status
# Open 1Password → Settings → Accounts → Should show:
# - Subscription: "Individual", "Families", "Teams", "Business" with renewal date
# - Standalone: "1Password 7 Standalone" or earlier version
```

**Common Issues**:
- **Forgot master password**: Cannot be recovered (1Password has zero knowledge architecture)
  - Solution: Use Emergency Kit to verify Secret Key, try password variations
  - Last resort: Create new account (lose all data unless synced elsewhere)
- **Cannot sign in**: Verify email, Secret Key, and master password are all correct
- **Subscription expired**: Update payment method at https://1password.com (sign in on web)
- **Company account locked**: Contact IT admin (may be security policy or account suspension)

**Documentation**: For full 1Password usage, see `docs/apps/productivity/1password.md`.

---

### iStat Menus

**Installation**: Installed via Homebrew cask `istat-menus` (Story 02.4-006)

**License Requirement**: iStat Menus is **commercial software** requiring a paid license. Offers a 14-day free trial with full features.

**License Options**:

1. **Free Trial** (14 days):
   - Full features unlocked for 14 days
   - No credit card required
   - No account sign-up needed
   - Trial countdown visible in Preferences → License
   - After expiration: App becomes read-only (settings locked, displays still visible)

2. **Paid License** (One-time purchase):
   - **Price**: $11.99 USD (one-time, no subscription)
   - **Lifetime license**: No recurring fees
   - **Free updates**: Lifetime updates for current major version
   - **Multi-Mac**: Use on all your Macs (personal use)
   - **Purchase**: https://bjango.com/mac/istatmenus/

**Activation Steps**:

**Option A: Start Free Trial**
1. Launch iStat Menus from Spotlight (`Cmd+Space`, type "iStat Menus") or `/Applications/iStat Menus.app`
2. Welcome screen appears on first launch
3. Click **Start Free Trial** button
4. Trial activates immediately (no sign-up or credit card required)
5. All features unlocked for 14 days
6. Menubar icons appear for enabled sensors (CPU, Memory, Network, etc.)
7. Check trial status: Click any menubar icon → Preferences → License → "XX days remaining"

**Option B: Enter Existing License**
1. Launch iStat Menus
2. Welcome screen appears → Click **Enter License** button
3. Enter **License Name** (your name or email used during purchase, case-sensitive)
4. Enter **License Key** (from purchase confirmation email)
5. Click **Activate** button
6. License validates → App is permanently activated
7. Verify: Preferences → License → "Licensed to: [Your Name]"

**Option C: Purchase License**

**During Trial**:
1. Click any iStat Menus menubar icon (CPU, Memory, etc.)
2. Click **Preferences** at bottom of dropdown
3. Click **License** tab
4. Click **Buy Now** button
5. Browser opens to https://bjango.com/mac/istatmenus/
6. Complete purchase ($11.99 USD via credit card or PayPal)
7. License key sent to email within minutes
8. Return to iStat Menus → Enter license (see Option B above)

**From Website**:
1. Visit https://bjango.com/mac/istatmenus/ in browser
2. Click **Buy** button (top right or in pricing section)
3. Complete purchase ($11.99 USD)
4. License key sent to purchase email
5. Launch iStat Menus → Click **Enter License** → Enter details (see Option B)

**License Verification**:
```bash
# Check license status
# Click any iStat Menus menubar icon → Preferences → License tab
# Should show one of:
# - "Trial: XX days remaining" (trial period active)
# - "Licensed to: [Your Name]" (license activated)
# - "Trial expired - Purchase required" (trial ended, need license)
```

**Auto-Update Disable** (CRITICAL):
iStat Menus has automatic updates **enabled by default**. You **MUST** disable auto-update:

1. Click any iStat Menus menubar icon → **Preferences**
2. Click **General** tab (top of Preferences window)
3. Scroll down to **Updates** section
4. **Uncheck** "Automatically check for updates"
5. Close Preferences → Setting is saved
6. Verify: Reopen Preferences → General → Updates → Checkbox should remain unchecked

**Why disable auto-update**:
- All app updates controlled by `darwin-rebuild switch` (Homebrew version pinning)
- Ensures reproducible system state (no surprise updates)
- Prevents automatic app restarts during updates

**What Happens After Trial Expires**:
- iStat Menus becomes **read-only**:
  - Menubar displays **still visible** (can view stats)
  - **Cannot change settings** (Preferences menu locked)
  - **Cannot customize** sensors or display format
- To regain full functionality:
  - Purchase license ($11.99 USD)
  - Enter license key (see Option B above)
  - All settings immediately unlocked

**License Benefits**:
- **Lifetime license**: Pay once, use forever (no subscription)
- **Free updates**: All updates for current major version (iStat Menus 7.x)
- **Multiple Macs**: Install on all your personal Macs (license allows personal use across devices)
- **Offline activation**: License verified offline after initial activation (no internet required)
- **Support**: Email support at support@bjango.com

**Common Issues**:

**License Key Not Accepted**:
- **Cause**: Typo in license name or key, extra spaces
- **Solution**:
  - Verify license name matches purchase email **exactly** (case-sensitive)
  - Copy license key from email (avoid manual typing)
  - Check for spaces at start/end of license name/key
  - Try entering on different Mac (license is multi-Mac compatible)

**License Key Lost**:
- **Solution**: Contact Bjango support
  - Email: support@bjango.com
  - Subject: "License key recovery"
  - Include: Purchase email address, transaction ID (if available)
  - Response time: Usually within 24 hours
  - Bjango will resend license key to purchase email

**Trial Expired, Can't Afford License**:
- **No free alternative in iStat Menus** (commercial software)
- **Free alternatives** (if license not feasible):
  - **btop**: Free terminal system monitor (installed via Home Manager)
  - **Activity Monitor**: Built-in macOS app (Utilities → Activity Monitor)
  - **Note**: Free alternatives lack menubar integration and some advanced features

**Auto-Update Still Enabled After Disabling**:
- **Solution**:
  - Verify: Preferences → General → Updates → "Automatically check for updates" is **unchecked**
  - If checked: Uncheck again → Close Preferences → Reopen to confirm persistence
  - Also check: System Settings → App Store → Uncheck "Automatic Updates" (system-wide)
  - If installed via Homebrew (our setup): Updates only via `darwin-rebuild switch`

**Menubar Icons Not Appearing**:
- **Cause**: Sensors disabled in Preferences
- **Solution**:
  - Preferences → Menubar Items
  - Enable desired sensors: CPU, Memory, Network, Disk, Battery, Sensors
  - Check "Show in menubar" for each enabled sensor
  - Icons appear immediately after enabling

**Documentation**: For full iStat Menus usage and configuration, see `docs/apps/system/system-monitoring.md` → iStat Menus section.

---

## Office & Productivity Suites

### Microsoft Office 365

**Installation Method**: Individual Homebrew casks (`microsoft-word`, `microsoft-excel`, `microsoft-powerpoint`)
**Story**: 02.9-001
**License Requirement**: Active Microsoft 365 subscription (NO perpetual license)
**License Type**: Subscription-based ($69.99-$99.99/year or $6.99-$9.99/month)

**Apps Included** (3 apps):
- Microsoft Word (documents)
- Microsoft Excel (spreadsheets)
- Microsoft PowerPoint (presentations)

**Subscription Plans**:
- **Personal**: $69.99/year or $6.99/month (1 user, 1 TB OneDrive)
- **Family**: $99.99/year or $9.99/month (6 users, 1 TB OneDrive each)
- **Company/Education**: Varies by organization (provided by employer/school)

**Sign-In Process** (One-Time for All Apps):
1. Launch any Office app (e.g., Microsoft Word)
2. Click "Sign In" when prompted
3. Enter Microsoft account email (personal, work, or school)
4. Enter password
5. Complete multi-factor authentication (2FA) if enabled
6. Accept license terms
7. Choose theme preference (Colorful, Dark, Classic)
8. **Result**: Word, Excel, and PowerPoint activate automatically

**Auto-Update Disable** (REQUIRED for EACH App):
**⚠️ Each app has a separate auto-update setting - disable it in all three apps**
1. Open app → Menu bar → [App Name] → Preferences
2. Click **Update** or **AutoUpdate** tab
3. **Uncheck** "Automatically download and install updates"
4. **Repeat for all managed apps**: Word, Excel, PowerPoint

**Verification**:
- Word, Excel, and PowerPoint are present in `/Applications`
- About [App] shows "Subscription Product" with expiration date
- Launch any app - should NOT prompt for sign-in after initial activation
- Auto-update disabled in all apps (check Preferences → Update)

**Documentation**: See `docs/apps/productivity/office-365.md` for comprehensive configuration guide

---

### Office 365 (Legacy Documentation - Now Automated via Homebrew)

**Installation**: **Automated via Homebrew** (previously required manual installation)

**License Requirement**: Office 365 requires an **active subscription** (Microsoft 365 plan).

**Subscription Options**:

1. **Microsoft 365 Personal**: $69.99/year
   - 1 person, 5 devices (PC, Mac, tablet, phone)
   - Word, Excel, PowerPoint, Outlook, OneNote, OneDrive (1TB)
   - Premium features and monthly updates

2. **Microsoft 365 Family**: $99.99/year
   - Up to 6 people, 5 devices each (30 devices total)
   - Same apps as Personal + 1TB OneDrive per person
   - Shared family calendar and locations

3. **Company-Provided License** (Business/Enterprise):
   - Employer provides Office 365 license
   - Sign in with company email (Microsoft 365 Business/Enterprise)
   - IT-managed licenses and policies
   - May include Teams, SharePoint, Exchange

**Manual Installation Steps**:

**Option A: Personal/Family Subscription**
1. **Purchase subscription**:
   - Visit https://www.microsoft.com/en-us/microsoft-365/buy/compare-all-microsoft-365-products
   - Choose Personal or Family plan
   - Complete purchase with Microsoft account

2. **Download Office**:
   - Sign in to https://account.microsoft.com/services/
   - Click **Install Office** button
   - Download Office installer (`Office365Installer.pkg`)

3. **Install**:
   - Open downloaded `.pkg` file
   - Follow installation wizard
   - Apps install to `/Applications/` (Word, Excel, PowerPoint, Outlook, OneNote)

4. **Activate**:
   - Launch any Office app (e.g., Word)
   - Sign in with Microsoft account email and password
   - Office activates automatically (verifies subscription)
   - All Office apps are now licensed

**Option B: Company License**
1. **Receive invitation**: IT admin sends Office 365 invitation to company email
2. **Download Office**:
   - Sign in to https://portal.office.com with company email
   - Click **Install Office** button (top right)
   - Download Office installer

3. **Install and activate**: Same as Option A step 3-4, but use company email for sign-in

**License Verification**:
```bash
# Check Office activation status
# Open Word → Word menu → About Word
# Should show: "Product Activated" with subscription type
# If shows "Unlicensed Product", sign in again: Word → Sign In (top right)
```

**Common Issues**:
- **"Unlicensed Product" error**:
  - Sign in to Office app: Word → Sign In → Enter Microsoft account
  - Verify subscription active: Visit https://account.microsoft.com/services/
  - Check internet connection (Office verifies license online every 30 days)

- **Cannot sign in**:
  - Verify Microsoft account email and password correct
  - Check if account has active subscription (may have expired)
  - Company accounts: Contact IT admin (account may not be provisioned)

- **Subscription expired**:
  - Renew at https://account.microsoft.com/services/
  - Enter payment information to reactivate
  - Relaunch Office apps to re-verify license

**Auto-Update Configuration**:
- Office 365 has **automatic updates enabled by default**
- To disable (not recommended for security):
  1. Open any Office app (e.g., Word)
  2. Click **Word** menu → **Preferences**
  3. Navigate to **AutoUpdate** (under "Personal Settings")
  4. Uncheck "Automatically download and install" (or set to "Manual")
  5. Click **Update Options** → Choose "Disable Updates" (WARNING: Security risk)

**Note**: Disabling Office auto-updates is **NOT recommended** due to security vulnerabilities. Office security patches are critical. Consider allowing auto-updates for Office even if other apps are controlled via darwin-rebuild.

**Documentation**:
- Office 365 Help: https://support.microsoft.com/en-us/office
- Activation Guide: https://support.microsoft.com/en-us/office/activate-office-5bd38f38-db92-448b-a982-ad170b1e187e
- Subscription Management: https://account.microsoft.com/services/

---

## VPN & Security Apps

### NordVPN

**Installation Method**: Homebrew Cask (`nordvpn`)
**Story**: 02.7-001
**License Requirement**: Active NordVPN subscription (paid service, NO free tier)
**License Type**: Subscription-based ($3.99-$12.99/month depending on plan)

**Subscription Plans** (as of 2024):
- **1-month**: $12.99/month (month-to-month billing, cancel anytime)
- **1-year**: $4.99/month ($59.88 billed annually, save 62%)
- **2-year**: $3.99/month ($95.76 billed every 2 years, save 69%, best value)

**Purchase Subscription**:
- Visit: https://nordvpn.com/pricing/
- Choose plan → Complete payment
- Create NordVPN account during checkout
- Login credentials sent via email

**Account Includes**:
- 6 simultaneous device connections
- Unlimited bandwidth
- All server locations (59+ countries, 5,000+ servers)
- All features (CyberSec/Threat Protection, Kill Switch, Double VPN, Split Tunneling)
- 24/7 customer support
- 30-day money-back guarantee

**Sign-In Process**:
1. Launch NordVPN from Applications or Spotlight
2. Click **"Log In"** button
3. Enter NordVPN account **email** and **password**
4. Complete **2FA** if enabled (6-digit code from authenticator app)
5. Grant **Network Extension permission** when prompted (REQUIRED):
   - macOS prompt: "NordVPN would like to add VPN configurations"
   - Click **"Allow"**
   - This permission enables VPN tunnel functionality
   - Without this, VPN connection will fail
6. Grant **Notifications permission** (optional but recommended)
7. Menubar icon appears (gray shield when disconnected)

**Network Extension Permission** (CRITICAL):
- **Required**: macOS prompts on first VPN connection attempt
- **System Prompt**: "NordVPN would like to add VPN configurations"
- **Action**: Click **"Allow"** (required for VPN to function)
- **Purpose**: Allows NordVPN to create VPN tunnel and route traffic
- **If denied by mistake**:
  1. System Settings → Privacy & Security → General
  2. Find NordVPN under "VPN & Device Management"
  3. Click **"Allow"**
  4. Return to NordVPN → Try connecting again

**Auto-Update Disable** (RESEARCH REQUIRED):
- **Research Note**: Check during VM testing if NordVPN has user-facing auto-update toggle
- **Possible Location**: Preferences → Settings → Advanced (verify during testing)
- **If no toggle exists**: Updates controlled by Homebrew only (`darwin-rebuild switch`)
- **FX Action**: During VM testing, check all Settings tabs and document findings

**Verification**:
- **Installation**: `/Applications/NordVPN.app` exists
- **Launch**: NordVPN shows sign-in screen on first launch
- **Sign-in**: Account credentials work → Menubar icon appears (gray shield)
- **Network Permission**: System prompt appears → Click "Allow"
- **Connection Test**:
  1. Click menubar icon → **Quick Connect**
  2. Wait 5-10 seconds → Icon turns **green shield** (connected)
  3. Visit https://whatismyip.com → Verify IP changed to VPN IP
  4. Disconnect → Icon returns to gray shield
- **Subscription Status**: Settings → Account → Shows active subscription + expiration date
- **Auto-Update**: Check Settings → Advanced or General → Document if toggle exists

**Core Features to Test**:
- **Quick Connect**: One-click VPN (menubar → Quick Connect)
- **Server Selection**: Browse and connect to specific countries/servers
- **Kill Switch**: Settings → General → Kill Switch toggle (blocks internet if VPN drops)
- **Auto-Connect**: Settings → General → Auto-connect on Wi-Fi/Always/Never
- **CyberSec/Threat Protection**: Settings → Toggle for ad/malware blocking
- **Split Tunneling**: Settings → Add apps to bypass VPN (e.g., local network apps)

**Documentation**: See `docs/apps/security/nordvpn.md` for full configuration guide

---

## Virtualization & Development Tools

Parallels Desktop was removed from all profiles; on-device virtualization is
handled implicitly by Apple Virtualization.framework (used by Claude Desktop's
sandbox). Orphaned VM processes are monitored by the notify-only watchdog at
`scripts/virt-vm-orphan-watch.sh`, added after the 2026-04-22 kernel panic.

If you still need a traditional desktop hypervisor, Parallels / UTM / VMware
Fusion are all available outside the declarative config — install manually
with full knowledge that updates are no longer managed by `rebuild`.

---

## Summary Table

| App | Installation | Account Type | Cost | Activation Required |
|-----|-------------|--------------|------|---------------------|
| **1Password** | Homebrew cask | Subscription or License | $2.99+/month or legacy | Yes (required) |
| **iStat Menus** | Homebrew cask | One-time purchase | $11.99 USD (14-day trial) | Yes (trial or license) |
| **NordVPN** | Homebrew cask | Subscription | $3.99-$12.99/month | Yes (required) |
| **Office 365** | Manual install | Subscription | $69.99+/year or company | Yes (required) |

---

## Next Steps After Activation

After activating licensed apps:

1. **Verify functionality**: Launch each app and confirm sign-in successful
2. **Configure settings**: See `docs/app-post-install-configuration.md` for detailed setup
3. **Test core features**: Ensure licenses unlock the expected features
4. **Store credentials safely**: Save license keys, Emergency Kits, and recovery codes in secure location
5. **Set calendar reminders**: Add renewal reminders 30 days before subscription expiration

---

## Troubleshooting Licensed Apps

**General License Issues**:
- Check internet connection (apps verify licenses online)
- Sign out and sign back in (refresh license validation)
- Verify subscription active (check payment method, expiration date)
- Contact support or IT admin (may be account issue or provisioning delay)

**Subscription Management**:
- **1Password**: https://1password.com/ (sign in → Billing)
- **Office 365**: https://account.microsoft.com/services/ (Manage subscription)

**Support Contacts**:
- **1Password Support**: https://support.1password.com/
- **Office 365 Support**: https://support.microsoft.com/en-us/office
