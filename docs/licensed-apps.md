# ABOUTME: Licensed application activation and sign-in guide
# ABOUTME: Documents apps requiring licenses, accounts, or activation after installation

# Licensed Applications and Account Requirements

This document provides guidance for applications that require licenses, subscriptions, or account activation after installation via nix-darwin.

**Philosophy**: Some applications cannot be fully configured via nix-darwin and require manual activation, sign-in, or license key entry. This document tracks those apps and provides activation instructions.

---

## Overview

The following apps require manual setup after installation:

**Productivity & Security**:
- **1Password**: Requires account sign-in (subscription or license)
- **Dropbox**: Requires Dropbox account (free or paid subscription)
- **Microsoft Office 365**: Requires active subscription (Personal, Family, or Company)

**Video Conferencing**:
- **Zoom**: Can use free account, but paid license may be needed for full features
- **Webex**: Requires company account or free Webex account

**VPN & Security**:
- **NordVPN**: Requires active subscription (NO free tier, $3.99-$12.99/month)

**System Monitoring**:
- **iStat Menus**: Commercial software ($11.99 USD) with 14-day free trial

**Development Tools**:
- None currently (all dev tools are free/open source)

---

## Video Conferencing Apps

### Zoom

**Installation**: Installed via Homebrew cask `zoom` (Story 02.5-002)

**Account Options**:

1. **Free Account** (No License Required):
   - **Sign up**: https://zoom.us/signup
   - **Meeting limits**: 40-minute limit for group meetings (3+ participants)
   - **Participant limits**: Up to 100 participants
   - **Features**: Join meetings, host short meetings, screen sharing, chat
   - **Cost**: Free forever (no credit card required)

2. **Licensed Account** (Paid Plans):
   - **Pro Plan**: $149.90/year - Unlimited meeting duration, cloud recording
   - **Business Plan**: $199.90/year/user - Admin controls, branding, managed domains
   - **Enterprise Plan**: Custom pricing - Unlimited cloud storage, dedicated support
   - **License source**: Provided by employer OR purchased at https://zoom.us/pricing

**Activation Steps**:

**Option A: Free Account**
1. Launch Zoom from Spotlight (`Cmd+Space`, type "Zoom")
2. Click **Sign Up Free** on sign-in screen
3. Enter email address → Click **Sign Up**
4. Check email for verification link → Click link
5. Create password and complete profile
6. Sign in to Zoom desktop app with new account
7. You can now join and host meetings (with 40-minute limit for groups)

**Option B: Licensed Account (Work/Purchased)**
1. Launch Zoom from Spotlight (`Cmd+Space`, type "Zoom")
2. Click **Sign In** on sign-in screen
3. Enter your work email or licensed account email
4. Enter password (or use SSO if company provides)
5. Sign in completes automatically
6. Verify license status: Zoom → Profile → Account Type (should show "Pro", "Business", or "Enterprise")

**Option C: Guest Mode (No Account)**
1. Launch Zoom from Spotlight (`Cmd+Space`, type "Zoom")
2. Click **Join a Meeting** (skip sign-in)
3. Enter Meeting ID from invite
4. Enter your name and click **Join**
5. You can join meetings but cannot host meetings

**License Verification**:
```bash
# Check if signed in
# Open Zoom → Click profile picture → Account should show:
# - Free: "Basic" (free account)
# - Licensed: "Pro", "Business", "Enterprise"
```

**Common Issues**:
- **Forgot password**: Click "Forgot password?" on sign-in screen → Reset via email
- **Cannot sign in with work email**: Contact IT admin (account may not be provisioned)
- **Meeting time limit**: Upgrade to paid plan or create multiple 40-minute sessions

**Documentation**: For full Zoom usage, see `docs/app-post-install-configuration.md` → Zoom section.

---

### Cisco Webex

**Installation**: Installed via Homebrew cask `webex` (Story 02.5-002)

**Account Requirement**: Webex **requires** an account. You cannot use Webex as a guest (unlike Zoom).

**Account Options**:

1. **Company Account** (Most Common):
   - **Provided by**: Your employer for work meetings
   - **Sign-in**: Company email and password (or SSO)
   - **Features**: May include licensed features (cloud recording, large meetings)
   - **IT-managed**: Policies, features, and restrictions may be controlled by IT
   - **Activation**: No activation needed - sign in with company credentials

2. **Free Webex Account**:
   - **Sign up**: https://www.webex.com/pricing/free-trial.html
   - **Meeting limits**: 50-minute limit for meetings
   - **Participant limits**: Up to 100 participants
   - **Features**: Host meetings, screen sharing, whiteboard, chat
   - **Cost**: Free forever

3. **Paid Plans** (Licensed):
   - **Webex Meet**: $14.50/month - Unlimited meeting duration, 100 participants
   - **Webex Suite**: $25/month - Calling, messaging, polling, cloud storage
   - **Enterprise**: Custom pricing - Advanced features and support
   - **Purchase**: https://www.webex.com/pricing/

**Activation Steps**:

**Option A: Company Account**
1. Launch Webex from Spotlight (`Cmd+Space`, type "Webex")
2. **Sign In** screen appears
3. Enter your **company email address**
4. Click **Next** or **Sign In**
5. Enter password OR use **SSO** if prompted:
   - **SSO**: Browser opens → Sign in via company portal (Google, Microsoft, Okta, etc.)
   - **Password**: Enter company password directly
6. Sign-in completes → Webex shows main interface with upcoming meetings
7. Verify: Your company email should appear in top-right profile section

**Option B: Free Account**
1. Visit https://www.webex.com/pricing/free-trial.html in browser
2. Click **Sign Up Free** (no credit card required)
3. Enter email address → Click **Next**
4. Check email for verification code → Enter code
5. Create password and complete profile
6. Launch Webex from Spotlight (`Cmd+Space`, type "Webex")
7. Sign in with email and password
8. You can now host and join meetings (with 50-minute limit)

**Option C: Paid Plan**
1. Visit https://www.webex.com/pricing/ in browser
2. Choose plan: Webex Meet ($14.50/month) or Webex Suite ($25/month)
3. Click **Buy Now** → Complete payment
4. Create account or sign in with existing account
5. License activates automatically
6. Launch Webex desktop app → Sign in with account
7. Verify license: Webex → Profile → Account should show "Meet" or "Suite"

**Sign-In Troubleshooting**:
- **Company Account**:
  - Verify email is correct (use full company email)
  - Try **SSO**: Select "Sign in with company portal" if available
  - Contact IT admin if account not found (may need provisioning)
  - Check if VPN required (some companies require VPN for Webex sign-in)

- **Free/Paid Account**:
  - Verify email and password are correct
  - Check email for verification link (may be in spam folder)
  - Reset password: Click "Forgot password?" on sign-in screen
  - Contact Webex support if issues persist: https://help.webex.com/

**License Verification**:
```bash
# Check account type and license
# Open Webex → Click profile picture/icon → Settings → Account
# Should show:
# - Free: "Webex Free" or "Free Plan"
# - Licensed: "Webex Meet", "Webex Suite", or "Enterprise"
```

**Common Issues**:
- **Cannot sign in with company email**: Contact IT admin (account may not exist or may be locked)
- **SSO not working**: Ensure company SSO portal is accessible (may require VPN)
- **"Account not found"**: Sign up for free account first OR contact IT to provision company account
- **Meeting time limit (50 minutes)**: Upgrade to paid plan for unlimited duration

**Documentation**: For full Webex usage, see `docs/app-post-install-configuration.md` → Cisco Webex section.

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
   - Sync via iCloud/Dropbox (not 1Password.com)

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
   - **Dropbox**: Sync via Dropbox
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

### Dropbox

**Installation**: Installed via Homebrew cask `dropbox` (Story 02.4-004)

**Account Requirement**: Dropbox requires a Dropbox account (free or paid subscription) for file synchronization.

**Account Plans**:

1. **Free Account** (2GB storage):
   - **Sign up**: https://www.dropbox.com/register
   - **Storage**: 2GB
   - **Cost**: Free forever
   - **Features**: File sync, mobile access, basic file sharing, 30-day file recovery
   - **Limitations**: Limited storage, no advanced sharing features

2. **Plus Plan** (2TB storage):
   - **Storage**: 2TB (2,000GB)
   - **Cost**: $11.99/month or $119.88/year
   - **Features**: All free features + advanced sharing, 180-day file recovery, priority support

3. **Family Plan** (2TB shared):
   - **Storage**: 2TB shared among up to 6 users
   - **Cost**: $19.99/month or $199.99/year
   - **Features**: Plus features + family room for shared content

4. **Professional Plan** (3TB storage):
   - **Storage**: 3TB
   - **Cost**: $19.99/month or $199.99/year
   - **Features**: Advanced admin controls, eSignature requests, full-text search, Dropbox Transfer (up to 100GB)

**Activation Steps**:

1. **Launch Dropbox**:
   - Open from Spotlight (`Cmd+Space`, type "Dropbox")
   - Or launch from `/Applications/Dropbox.app`

2. **Sign In or Create Account**:
   - **Existing account**: Click "Sign In" → Enter email and password
   - **New account**: Click "Sign Up" (opens browser) → Create account at dropbox.com
   - Complete two-factor authentication if enabled (recommended)

3. **Setup Wizard**:
   - Choose plan (Free or paid)
   - Select Dropbox folder location (default: `~/Dropbox`, recommended)
   - Choose initial sync preferences (all folders or selective)
   - Click "Get Started"

4. **Verify Installation**:
   - Menubar icon appears (Dropbox logo)
   - `~/Dropbox` folder created in home directory
   - Dropbox appears in Finder sidebar
   - Initial sync begins automatically

5. **Disable Auto-Update** (REQUIRED):
   - Click Dropbox menubar icon → Profile icon → Preferences
   - Navigate to **Account** tab
   - **Uncheck** "Automatically download and install updates"
   - Close Preferences

**Activation Time**: ~2 minutes (account sign-in + setup wizard)

**Testing**:
- [ ] Dropbox launches successfully
- [ ] Account sign-in completes
- [ ] `~/Dropbox` folder exists in Finder
- [ ] Menubar icon visible and shows sync status
- [ ] Auto-update disabled (Account → Updates unchecked)
- [ ] Test file sync: Create file in `~/Dropbox`, verify appears in web interface

**Troubleshooting**:
- **Sign-in fails**: Verify email/password correct, check internet connection
- **No menubar icon**: Quit Dropbox (Activity Monitor) and relaunch
- **Sync not working**: Check account storage not full (Preferences → Account → Storage usage)
- **"Can't sync" error**: Click menubar icon for error details, common causes:
  - Invalid filename characters (rename file)
  - File path too long (shorten folder names)
  - Permission issues (check folder permissions)

**Documentation**: For full Dropbox usage and configuration, see `docs/apps/productivity/dropbox.md`.

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
  - **gotop**: Free CLI system monitor (installed, see Story 02.4-006)
  - **macmon**: Free CLI system info tool (installed, see Story 02.4-006)
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

**Installation Method**: Homebrew Cask (`microsoft-office-businesspro`)
**Story**: 02.9-001
**License Requirement**: Active Microsoft 365 subscription (NO perpetual license)
**License Type**: Subscription-based ($69.99-$99.99/year or $6.99-$9.99/month)

**Apps Included** (6 apps):
- Microsoft Word (documents)
- Microsoft Excel (spreadsheets)
- Microsoft PowerPoint (presentations)
- Microsoft Outlook (email/calendar)
- Microsoft OneNote (notes)
- Microsoft Teams (meetings/chat)

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
8. **Result**: All 6 Office apps activate automatically (no need to sign in to each app)

**Auto-Update Disable** (REQUIRED for EACH App):
**⚠️ Each app has separate auto-update setting - must disable 6 times**
1. Open app → Menu bar → [App Name] → Preferences
2. Click **Update** or **AutoUpdate** tab
3. **Uncheck** "Automatically download and install updates"
4. **Repeat for ALL apps**: Word, Excel, PowerPoint, Outlook, OneNote
5. **Teams**: Preferences → General → Uncheck "Auto-start application" (optional)

**Verification**:
- All 6 apps in `/Applications/Microsoft [App].app`
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

### Parallels Desktop

**Installation Method**: Homebrew Cask (`parallels`)
**Story**: 02.8-001
**Profile**: **POWER ONLY** (MacBook Pro M3 Max) - NOT installed on Standard profile
**License Requirement**: Paid software (trial, subscription, or perpetual license)
**License Type**: Subscription ($99.99-$119.99/year) or Perpetual ($129.99 one-time, older versions)

**Why Power Profile Only?**
Virtualization requires significant system resources (CPU cores, RAM, disk space):
- **MacBook Pro M3 Max** (Power): 64GB RAM, 14-16 cores, 1TB+ SSD → Can run VMs comfortably
- **MacBook Air** (Standard): 8-16GB RAM, 8 cores, 256-512GB SSD → Insufficient for VMs
- **Alternative for Standard**: Use cloud VMs (AWS EC2, Azure VMs) when virtualization needed

**License Options**:

1. **Free Trial** (14 Days):
   - Full features unlocked for 14 days
   - No credit card required
   - No account sign-up needed (just email verification)
   - Expires after 14 days → Becomes read-only (can view VMs but cannot start/modify)

2. **Standard Edition** (Subscription):
   - **Price**: $99.99/year (annual billing)
   - **Features**: Core virtualization (Windows, Linux, macOS VMs), up to 8 vCPUs per VM, up to 32 GB vRAM per VM
   - **Best For**: Personal use, home users, students

3. **Pro Edition** (Subscription):
   - **Price**: $119.99/year (annual billing)
   - **Features**: All Standard features PLUS developer tools (Vagrant, Docker, Kubernetes), Visual Studio plugin, up to 32 vCPUs and 128 GB vRAM per VM
   - **Best For**: Developers, IT professionals, advanced users

4. **Business Edition** (Subscription):
   - **Price**: $119.99/year per user (volume licensing available)
   - **Features**: All Pro features PLUS centralized license management, mass deployment, SSO integration
   - **Best For**: Companies, IT departments, enterprise deployments

5. **Perpetual License** (Legacy, Less Common):
   - **Price**: $129.99 one-time (older versions only)
   - **Features**: Lifetime license for purchased version (no recurring fees)
   - **Limitations**: No automatic updates (must purchase upgrades), no cloud features, older versions may not support latest macOS/ARM VMs
   - **Note**: Parallels shifted to subscription model (perpetual licenses rare now)

**Activation Process**:

**Option 1: Trial** (14 Days Free)
1. Launch Parallels Desktop (Spotlight: `Cmd+Space`, type "Parallels")
2. Welcome screen → Click **"Try Free for 14 Days"**
3. Create Parallels account (email + password)
4. Check email for verification link → Click to verify
5. Sign in to Parallels
6. Trial activates immediately (no credit card)

**Option 2: License Key** (Purchased License)
1. Launch Parallels Desktop
2. Welcome screen → Click **"Activate"** or **"I have a license key"**
3. Enter license key: `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX` (from purchase email)
4. Sign in with Parallels account (or create account)
5. License activates

**Option 3: Subscription Account**
1. Launch Parallels Desktop
2. Welcome screen → Click **"Sign In"**
3. Enter Parallels account email and password
4. Subscription auto-activates (no license key needed)

**Auto-Update Disable**:
1. Parallels Desktop → Preferences (or `Cmd+,`)
2. Click **Advanced** tab (or **General** tab, location varies by version)
3. Find **"Check for updates automatically"** checkbox
4. **Uncheck** "Check for updates automatically"
5. **Uncheck** "Download updates automatically" (if separate)
6. Close Preferences
7. Verify: Quit Parallels → Relaunch → Preferences → Verify checkboxes remain unchecked

**Note**: Some Parallels versions may NOT have user-facing auto-update toggle (updates controlled by Homebrew only).

**Verification**:
- **License Status**: Preferences → Account shows:
  - Trial: "Trial - X days remaining"
  - Subscription: "Standard Edition" or "Pro Edition" with renewal date
  - Perpetual: "Parallels Desktop [Version]" with license key
- **VM Creation**: Can create and run Windows/Linux/macOS virtual machines
- **Parallels Tools**: Install in VMs for better performance (graphics, clipboard, shared folders)

**Profile Verification**:
```bash
# Power profile: Verify Parallels installed
ls -la /Applications/Parallels\ Desktop.app
# Expected: App directory exists ✅

# Standard profile: Verify Parallels NOT installed
darwin-rebuild switch --flake ~/nix-install#standard
ls -la /Applications/Parallels\ Desktop.app
# Expected: No such file or directory ❌
```

**Key Features**:
- **VM Creation**: Windows 11, Linux (Ubuntu, Debian, Fedora, etc.), macOS VMs
- **Coherence Mode**: Run Windows apps alongside Mac apps (seamless integration)
- **Shared Folders**: Access Mac files from VM (Desktop, Documents, Downloads shared by default)
- **Snapshots**: Save VM state before risky changes, restore if needed
- **USB Pass-Through**: Connect USB devices (printers, drives, phones) to VM
- **Clipboard Sharing**: Copy/paste between Mac and VM
- **Drag-and-Drop**: Transfer files by dragging between Mac and VM windows
- **Performance**: Optimized for Apple Silicon (M1/M2/M3) with ARM64 VMs

**Common Use Cases**:
- Run Windows apps (Office, legacy software, Windows-only tools)
- Test apps on different OS versions (macOS, Windows, Linux)
- Development: Test apps on multiple platforms
- Security testing: Run untrusted software in isolated VM
- Learning: Experiment with different OSes without dual-booting

**Documentation**: For full Parallels Desktop usage, VM creation, and troubleshooting, see `docs/apps/virtualization/parallels-desktop.md`.

---

## Summary Table

| App | Installation | Account Type | Cost | Activation Required |
|-----|-------------|--------------|------|---------------------|
| **Zoom** | Homebrew cask | Free or Licensed | Free or $149.90+/year | Yes (or guest mode) |
| **Webex** | Homebrew cask | Company or Free | Free or $14.50+/month | Yes (required) |
| **1Password** | Homebrew cask | Subscription or License | $2.99+/month or legacy | Yes (required) |
| **iStat Menus** | Homebrew cask | One-time purchase | $11.99 USD (14-day trial) | Yes (trial or license) |
| **NordVPN** | Homebrew cask | Subscription | $3.99-$12.99/month | Yes (required) |
| **Office 365** | Manual install | Subscription | $69.99+/year or company | Yes (required) |
| **Parallels Desktop** | Homebrew cask (Power only) | Trial or Subscription | Free trial 14 days or $99.99-$119.99/year | Yes (trial or license) |

---

## Next Steps After Activation

After activating licensed apps:

1. **Verify functionality**: Launch each app and confirm sign-in successful
2. **Configure settings**: See `docs/app-post-install-configuration.md` for detailed setup
3. **Test core features**: Ensure licenses unlock expected features (e.g., Zoom recording, 1Password sync)
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
- **Zoom**: https://zoom.us/account (sign in → Billing)
- **Webex**: https://www.webex.com/ (sign in → Account → Subscription)
- **1Password**: https://1password.com/ (sign in → Billing)
- **Office 365**: https://account.microsoft.com/services/ (Manage subscription)

**Support Contacts**:
- **Zoom Support**: https://support.zoom.us/hc/en-us
- **Webex Support**: https://help.webex.com/
- **1Password Support**: https://support.1password.com/
- **Office 365 Support**: https://support.microsoft.com/en-us/office
