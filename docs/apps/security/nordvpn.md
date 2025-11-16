# ABOUTME: NordVPN post-installation configuration guide
# ABOUTME: Covers subscription requirement, sign-in process, network extension permission, VPN features, and troubleshooting

# NordVPN - VPN Privacy and Security Service

**Status**: Installed via Homebrew cask `nordvpn` (Story 02.7-001)

**Purpose**: VPN (Virtual Private Network) service providing secure, encrypted connections for privacy protection, remote access, and bypassing geo-restrictions. Routes internet traffic through secure servers in 59+ countries.

---

## Installation Method

- **Homebrew Cask**: `nordvpn`
- **Story**: 02.7-001
- **App Location**: `/Applications/NordVPN.app`
- **Version**: Latest (managed by Homebrew)

---

## Subscription Requirement (CRITICAL)

**⚠️ NordVPN is a PAID SERVICE - NO FREE TIER**

NordVPN requires an **active subscription**. You cannot use NordVPN without a paid account (no free trial or freemium plan).

**Subscription Plans** (as of 2024):

1. **1-Month Plan**: $12.99/month
   - Month-to-month billing
   - Cancel anytime
   - Full features

2. **1-Year Plan**: $4.99/month ($59.88 billed annually)
   - Save 62% vs monthly
   - Full features
   - Auto-renewal (can disable)

3. **2-Year Plan**: $3.99/month ($95.76 billed every 2 years)
   - Best value (save 69% vs monthly)
   - Full features
   - Auto-renewal (can disable)

**Purchase Subscription**:
- Visit: https://nordvpn.com/pricing/
- Choose plan → Complete payment
- Create NordVPN account during checkout
- Receive login credentials via email

**Account Includes**:
- 6 simultaneous device connections
- Unlimited bandwidth
- All server locations (59+ countries)
- All VPN features (CyberSec, Kill Switch, Double VPN, etc.)
- 24/7 customer support
- 30-day money-back guarantee

---

## First Launch and Sign-In Process

### Account Requirements

Before launching NordVPN, you need:
- **Active NordVPN subscription** ($3.99-$12.99/month depending on plan)
- **Email address** (used during subscription signup)
- **Password** (set during account creation)
- **Two-factor authentication** (if enabled on your account)

### Sign-In Steps

**Step-by-Step Sign-In**:

1. **Launch NordVPN**:
   - Spotlight: `Cmd+Space`, type "NordVPN"
   - OR: Open `/Applications/NordVPN.app`
   - OR: Click NordVPN menubar icon (if already launched)

2. **Welcome Screen Appears**:
   - First launch shows NordVPN welcome screen
   - Click **"Log In"** button (center or top-right)

3. **Enter NordVPN Account Credentials**:
   - **Email**: Enter the email used for NordVPN subscription
   - **Password**: Enter your NordVPN account password
   - Click **"Log In"** or press `Enter`

4. **Two-Factor Authentication (if enabled)**:
   - If 2FA enabled on account: Enter 6-digit code from authenticator app
   - Check email for 2FA code if email-based 2FA
   - Enter code → Click **"Verify"**

5. **Grant Permissions** (System Prompts):
   - **Network Extension Permission** (REQUIRED):
     - macOS prompt: "NordVPN would like to add VPN configurations"
     - Click **"Allow"**
     - This permission enables NordVPN to create VPN tunnel
     - Without this, VPN connection will fail
   - **Notifications Permission** (Optional):
     - macOS prompt: "NordVPN would like to send you notifications"
     - Click **"Allow"** (recommended) or **"Don't Allow"**
     - Notifications inform you of connection status changes

6. **Sign-In Completes**:
   - NordVPN shows main interface
   - Menubar icon appears (gray shield when disconnected)
   - Ready to connect to VPN

### Network Extension Permission (REQUIRED)

**Why is this permission required?**
- NordVPN needs to install a **Network Extension** to route traffic through VPN
- macOS security requires explicit user approval for network-level changes
- Without this permission, NordVPN **cannot create VPN connection**

**Permission Prompt Location**:
- First connection attempt triggers the prompt
- Prompt says: "NordVPN would like to add VPN configurations"
- Options: **"Don't Allow"** or **"Allow"**
- **You MUST click "Allow"** for NordVPN to function

**If You Clicked "Don't Allow" By Mistake**:
1. Open **System Settings** (or System Preferences on older macOS)
2. Navigate to **Privacy & Security** → **General**
3. Look for NordVPN under "VPN & Device Management" or similar
4. Click **"Allow"** next to NordVPN
5. Return to NordVPN app → Try connecting again

**Security Note**:
- This permission is **safe to grant** - NordVPN is a legitimate VPN provider
- The permission allows NordVPN to manage VPN tunnel only (no other access)
- You can revoke permission later via System Settings if needed

---

## Auto-Update Disable (Research Required)

**⚠️ RESEARCH NEEDED DURING VM TESTING**

NordVPN may or may not have a user-facing auto-update toggle. **FX must verify during VM testing.**

**Possible Locations** (check during testing):
1. **NordVPN App**:
   - Click menubar icon → **Settings** or **Preferences**
   - Look for **Advanced** or **General** section
   - Check for "Automatically check for updates" or similar option

2. **If auto-update toggle exists**:
   - **Uncheck** "Automatically check for updates" or similar
   - Close settings → Verify setting persists on relaunch

3. **If NO auto-update toggle**:
   - NordVPN updates may be **Homebrew-controlled only**
   - Updates happen via `darwin-rebuild switch` command
   - **No action needed** - updates managed by nix-darwin

**FX Action Required**:
- During VM testing, launch NordVPN → Settings → Check all tabs
- **Document findings**:
  - If toggle found: Update this doc with exact path (e.g., "Settings → Advanced → Uncheck 'Auto-update'")
  - If no toggle: Confirm updates are Homebrew-managed only
- Update `docs/licensed-apps.md` with findings

---

## Core Features

### VPN Server Locations
- **59+ countries** with 5,000+ servers
- **Select by**:
  - Country (e.g., United States, United Kingdom, Canada)
  - City (major cities in each country)
  - Server number (specific server for advanced users)
- **Specialized servers**:
  - **P2P servers**: Optimized for torrenting/file sharing
  - **Obfuscated servers**: Bypass VPN blocks (China, Russia, etc.)
  - **Double VPN**: Route through two servers for extra encryption
  - **Onion over VPN**: Combine VPN + Tor network

### Quick Connect
- **One-click VPN**: Click "Quick Connect" → Auto-select best server
- **Algorithm**: Chooses server based on:
  - Proximity (closest country)
  - Server load (least crowded server)
  - Connection speed (fastest available)
- **Fastest connection**: Typically connects in 5-10 seconds

### CyberSec / Threat Protection
- **Ad/Malware Blocker**: Blocks ads, malware, trackers at DNS level
- **Phishing Protection**: Prevents access to known phishing sites
- **Botnet Protection**: Blocks communication with botnet command servers
- **DNS-based**: Works across all apps (browser, apps, system-wide)
- **Enable**: Settings → CyberSec or Threat Protection → Toggle ON
- **Note**: Name varies by app version ("CyberSec" on older, "Threat Protection" on newer)

### Kill Switch
- **Purpose**: Blocks internet if VPN disconnects (prevents IP leaks)
- **How it works**:
  - Monitors VPN connection status
  - If VPN drops: Immediately cuts all internet traffic
  - When VPN reconnects: Restores internet access
- **Use case**: Ensures IP address never exposed (privacy critical)
- **Enable**: Settings → General → Kill Switch → Toggle ON
- **Warning**: If enabled and VPN fails, you have NO internet until VPN reconnects or Kill Switch disabled

### Auto-Connect
- **Auto-connect on**:
  - **Wi-Fi**: Connects automatically when joining Wi-Fi networks
  - **Always**: Connects on every app launch / system startup
  - **Never**: Manual connection only (default)
- **Recommended**: Set to **Wi-Fi** (protects on public/untrusted networks)
- **Configure**: Settings → General → Auto-connect → Select option

### Split Tunneling
- **Purpose**: Route specific apps **outside** the VPN tunnel
- **Use cases**:
  - Local network apps (printers, NAS, SMB shares)
  - Streaming services (some detect VPN and block content)
  - Banking apps (some block VPN connections)
- **Configure**:
  1. Settings → Split Tunneling → Enable
  2. Click **"Add Application"**
  3. Select app to bypass VPN (e.g., Safari, Netflix)
  4. Click **"Save"**
- **Result**: Selected apps use direct internet (bypass VPN), others use VPN

### Obfuscated Servers
- **Purpose**: Hide the fact you're using a VPN
- **Use cases**:
  - Countries that block VPN (China, Russia, Iran, UAE)
  - Networks that detect and block VPN traffic (some corporate networks)
  - ISPs that throttle VPN connections
- **How it works**: Disguises VPN traffic as regular HTTPS traffic
- **Enable**: Settings → Advanced → Obfuscated servers → Toggle ON
- **Availability**: Only certain servers support obfuscation (fewer options)

### Double VPN
- **Purpose**: Route traffic through **two** VPN servers for extra encryption
- **How it works**:
  1. Your Mac → First VPN server (encrypts)
  2. First VPN server → Second VPN server (encrypts again)
  3. Second VPN server → Internet (double encryption)
- **Use cases**: Maximum privacy (journalists, activists, sensitive work)
- **Trade-off**: Slower connection speed (two encryption layers)
- **Enable**: Menubar → Server list → Select "Double VPN" category → Choose server pair

### Protocols
- **WireGuard** (NordLynx - default):
  - Fastest protocol (modern, lightweight)
  - Best performance on macOS
  - Recommended for most users
- **OpenVPN UDP/TCP**:
  - Older protocol, more compatibility
  - Slightly slower than WireGuard
  - Use if WireGuard fails
- **Change protocol**: Settings → Connection → VPN Protocol → Select option

---

## Menubar Icon and Controls

### Menubar Icon States
- **Gray shield**: Disconnected (no VPN)
- **Green shield**: Connected (VPN active)
- **Yellow shield**: Connecting (VPN establishing)
- **Red shield**: Error (connection failed or blocked)

### Menubar Quick Actions
Click menubar icon to access:
- **Quick Connect**: One-click connect to best server
- **Disconnect**: Disconnect current VPN connection
- **Server List**: Browse all countries and servers
- **Recent Servers**: Quick access to recently used servers
- **Favorite Servers**: Star servers for quick access
- **Settings**: Open full settings/preferences window
- **Pause VPN**: Temporarily pause for 5/10/15 minutes (premium feature)

### Status Information (When Connected)
Menubar dropdown shows:
- **Connection status**: "Connected" or "Disconnected"
- **Current server**: Country, city, server number
- **Your IP address**: Current public IP (VPN IP when connected)
- **Protocol**: WireGuard, OpenVPN UDP/TCP
- **Uptime**: How long VPN has been connected
- **Data transfer**: Upload/download stats (if enabled in settings)

---

## VPN Connection Usage

### Quick Connect (Recommended)
**Fastest way to connect**:
1. Click NordVPN **menubar icon**
2. Click **"Quick Connect"** button (large button at top)
3. Wait 5-10 seconds for connection
4. Menubar icon turns **green** (connected)
5. Verify: Menubar shows "Connected" + server name + IP address

**What Quick Connect does**:
- Auto-selects best server based on proximity and load
- Usually connects to nearest country with low server load
- No configuration needed - just click and go

### Connect to Specific Server

**Connect to a specific country**:
1. Click NordVPN **menubar icon**
2. Browse **server list** (scrollable list of countries)
3. Click desired **country** (e.g., "United States")
4. Wait for connection (~5-10 seconds)
5. Verify: Menubar icon green, status shows "Connected to United States"

**Connect to a specific city**:
1. Click NordVPN **menubar icon**
2. Find country → Click **expand arrow** (if available)
3. Select **city** (e.g., "New York", "Los Angeles")
4. Wait for connection
5. Verify: Status shows city name

**Connect to a specific server number**:
1. Open NordVPN full app (click menubar icon → Settings → Or open from Applications)
2. Navigate to **Map** or **Server List** view
3. Search for server number (e.g., "us1234")
4. Click **Connect**
5. Useful for: Consistent IP address (same server = same IP)

### Disconnect

**Disconnect from VPN**:
1. Click NordVPN **menubar icon**
2. Click **"Disconnect"** button (appears when connected)
3. Connection drops immediately
4. Menubar icon turns **gray** (disconnected)
5. Your real IP address is now visible

**Keyboard shortcut** (if configured):
- Check Settings → General → Keyboard shortcuts
- Set custom shortcut for quick disconnect

---

## Performance

### Connection Speed
- **Expected speed**: 70-90% of your base internet speed
- **Factors affecting speed**:
  - Server load percentage (aim for <50% load)
  - Distance to server (closer = faster)
  - VPN protocol (WireGuard fastest, OpenVPN slower)
  - Your base internet speed (1 Gbps → ~700-900 Mbps on VPN)

### Latency (Ping)
- **Normal latency increase**: +10-50ms typical
- **Nearby servers**: +10-20ms (e.g., US East from New York)
- **Far servers**: +50-200ms (e.g., Japan from US)
- **Gaming**: Use nearest server, avoid Double VPN
- **Check latency**: Server list shows ping in milliseconds

### Server Load
- **Server load indicator**: Shows percentage (0-100%)
- **Optimal load**: 0-50% (best performance)
- **Acceptable load**: 50-75% (slight slowdown)
- **High load**: 75-100% (slower connection, may disconnect)
- **Tip**: If slow, switch to server with lower load percentage

### Speed Test
**Test VPN speed**:
1. **Before VPN**: Visit https://speedtest.net → Run test → Note download/upload speed
2. **Connect to VPN**: NordVPN → Quick Connect
3. **After VPN**: Visit https://speedtest.net → Run test → Compare speed
4. **Expected**: 70-90% of original speed

**If speed is very slow (<50%)**:
- Try different server (lower load percentage)
- Switch to WireGuard protocol (Settings → Connection → VPN Protocol)
- Check server list for "fastest server" recommendation
- Contact NordVPN support (may be server issue)

---

## Usage Examples

### Example 1: Quick VPN for Privacy
**Goal**: Connect to VPN quickly for general privacy
1. Click menubar icon → **Quick Connect**
2. Wait ~5 seconds → Green shield appears
3. Browse internet securely (traffic encrypted)

### Example 2: Access US Content from Abroad
**Goal**: Access US streaming services while traveling
1. Click menubar icon → Server list
2. Select **"United States"** → Click city (e.g., "New York")
3. Wait for connection → Verify "Connected to United States"
4. Visit streaming service (appears as if browsing from US)

### Example 3: Enable Kill Switch for Maximum Privacy
**Goal**: Ensure IP never leaks even if VPN drops
1. Click menubar icon → **Settings**
2. Navigate to **General** tab
3. **Kill Switch** → Toggle **ON**
4. Connect to VPN → Browse internet
5. If VPN fails: Internet blocked until VPN reconnects (prevents IP leak)

### Example 4: Auto-Connect on Public Wi-Fi
**Goal**: Automatically connect to VPN when joining Wi-Fi
1. Click menubar icon → **Settings**
2. Navigate to **General** tab
3. **Auto-connect** → Select **"Wi-Fi"**
4. Next time you join Wi-Fi: NordVPN auto-connects
5. Recommended for coffee shops, airports, hotels

### Example 5: Bypass VPN for Local Apps (Split Tunneling)
**Goal**: Use VPN for browsing but bypass for local network printer
1. Click menubar icon → **Settings**
2. Navigate to **Split Tunneling** → Enable
3. Click **"Add Application"**
4. Select **Printer Utility** or local network app
5. Click **"Save"** → App now uses direct internet, others use VPN

---

## Troubleshooting

### Cannot Connect to VPN

**Issue**: Click "Quick Connect" but connection fails

**Solutions**:
1. **Check internet connection**:
   - Disconnect VPN → Test internet (browse any website)
   - If no internet: Fix internet first (VPN needs active internet)

2. **Try different server**:
   - Quick Connect may select overloaded server
   - Manually select different country → Try connecting

3. **Restart NordVPN app**:
   - Quit NordVPN (menubar icon → Quit)
   - Relaunch from Applications or Spotlight
   - Try connecting again

4. **Check Network Extension permission**:
   - System Settings → Privacy & Security → General
   - Look for NordVPN → Verify "Allow" is selected
   - If blocked: Click "Allow" → Retry connection

5. **Reinstall network extension**:
   - NordVPN Settings → Advanced → "Reinstall network extension"
   - Approve system prompt → Try connecting

### Slow VPN Speed

**Issue**: Internet speed very slow when connected to VPN

**Solutions**:
1. **Switch to less loaded server**:
   - Menubar → Server list → Check load percentage
   - Select server with <50% load → Connect

2. **Change VPN protocol**:
   - Settings → Connection → VPN Protocol → Select **WireGuard** (fastest)
   - Disconnect and reconnect → Test speed

3. **Connect to closer server**:
   - Quick Connect chooses based on algorithm
   - Manually select **nearest country** → Better speed

4. **Disable CyberSec/Threat Protection** (temporarily):
   - Settings → CyberSec/Threat Protection → Disable
   - May improve speed (but less ad blocking)

5. **Check server status**:
   - Visit https://nordvpn.com/servers/ → Check server status
   - Some servers may be under maintenance

### Network Extension Error

**Issue**: macOS says "NordVPN network extension could not start"

**Solutions**:
1. **Grant permission**:
   - System Settings → Privacy & Security → General
   - Find NordVPN → Click **"Allow"**

2. **Restart Mac**:
   - Sometimes macOS needs reboot after denying permission
   - Restart → Try connecting again

3. **Reinstall extension**:
   - NordVPN Settings → Advanced → "Reinstall network extension"
   - Approve permission prompt → Retry

4. **Check System Integrity Protection (SIP)**:
   - SIP enabled may block some extensions
   - Usually not an issue, but verify: `csrutil status` in Terminal
   - Should show "System Integrity Protection status: enabled"

### Kill Switch Blocks Internet After Disconnect

**Issue**: Disconnected VPN but internet still blocked

**Solutions**:
1. **Disable Kill Switch**:
   - Open NordVPN → Settings → General
   - **Kill Switch** → Toggle **OFF**
   - Internet should restore immediately

2. **Reconnect to VPN**:
   - If Kill Switch enabled: Reconnect to VPN first
   - Then disable Kill Switch
   - Then disconnect VPN → Internet restored

3. **Check macOS network settings**:
   - System Settings → Network → Wi-Fi/Ethernet
   - Verify connection active (green dot)
   - Remove any VPN profiles: Settings → VPN & Device Management

### Split Tunneling Not Working

**Issue**: Added app to Split Tunneling but still routes through VPN

**Solutions**:
1. **Restart NordVPN app**:
   - Split Tunneling requires app restart
   - Quit NordVPN → Relaunch → Reconnect to VPN

2. **Restart the bypassed app**:
   - Close app added to Split Tunneling
   - Reconnect to VPN
   - Launch app → Should bypass VPN

3. **Verify Split Tunneling enabled**:
   - Settings → Split Tunneling → Ensure **enabled**
   - Check app is in bypass list
   - Click **"Save"** if changes made

4. **Test IP address**:
   - In bypassed app: Visit https://whatismyip.com
   - Should show **real IP** (not VPN IP)
   - In other apps: Should show **VPN IP**

### Account Sign-In Issues

**Issue**: Cannot sign in to NordVPN account

**Solutions**:
1. **Verify email and password**:
   - Check email matches subscription signup
   - Try logging in at https://nordvpn.com → If works, credentials correct
   - Reset password: https://nordvpn.com/forgot-password/

2. **Check 2FA code** (if enabled):
   - Open authenticator app (Google Authenticator, Authy, etc.)
   - Enter current 6-digit code (codes change every 30 seconds)
   - If email-based 2FA: Check email for code

3. **Verify subscription active**:
   - Log in at https://nordvpn.com → Dashboard
   - Check subscription status (should show "Active")
   - If expired: Renew subscription → Try signing in again

4. **Internet connection**:
   - Sign-in requires internet
   - Test: Browse any website without VPN
   - If no internet: Fix connection first

5. **Contact NordVPN support**:
   - Live chat: https://nordvpn.com/contact-us/ (24/7 support)
   - Email: support@nordvpn.com
   - Provide: Account email, issue description

---

## Security Notes

### No-Logs Policy
- **Independently audited**: Third-party audits confirm no-logs claim
- **What is NOT logged**:
  - Browsing history
  - Traffic data
  - IP addresses
  - Connection timestamps
  - DNS queries
- **What IS logged** (minimal):
  - Email address (account management)
  - Payment info (billing)
  - Server load (performance optimization)

### Encryption
- **AES-256 encryption**: Military-grade encryption standard
- **Perfect Forward Secrecy**: Unique encryption key per session
- **Result**: Traffic unreadable even if intercepted

### VPN Protocols
- **WireGuard (NordLynx)**: Modern, secure, fast (default)
- **OpenVPN UDP/TCP**: Widely tested, very secure
- **IKEv2/IPSec**: Legacy protocol (macOS native)
- **Recommendation**: Use WireGuard for best security + speed

### DNS Leak Protection
- **Built-in**: All DNS queries routed through VPN
- **Result**: ISP cannot see websites you visit
- **Test DNS leak**: https://dnsleaktest.com/ (should show NordVPN servers)

### IPv6 Leak Protection
- **Built-in**: IPv6 traffic blocked or routed through VPN
- **Result**: No IP leaks via IPv6
- **Test**: https://ipv6leak.com/ (should show VPN IP or "no IPv6")

### Kill Switch
- **Prevents IP leaks**: Blocks internet if VPN drops
- **Recommended**: Enable for maximum privacy
- **Trade-off**: No internet if VPN fails (manual reconnect required)

---

## License Verification

### Check Subscription Status

**In NordVPN App**:
1. Click menubar icon → **Settings**
2. Navigate to **Account** tab
3. Check **Subscription** section:
   - **Active until**: [Date] (subscription expiration)
   - **Plan**: 1-month, 1-year, 2-year
   - **Devices**: X/6 (how many devices using account)

**On NordVPN Website**:
1. Visit https://nordvpn.com/
2. Click **"Log In"** (top right)
3. Enter email and password → Sign in
4. Navigate to **Dashboard** → **Subscriptions**
5. Shows:
   - Subscription plan and billing cycle
   - Next billing date
   - Payment method
   - Auto-renewal status (on/off)

### Manage Subscription

**Change Payment Method**:
1. Log in at https://nordvpn.com/
2. Dashboard → **Subscriptions** → **Billing**
3. Update credit card or PayPal

**Cancel Auto-Renewal**:
1. Log in at https://nordvpn.com/
2. Dashboard → **Subscriptions** → **Auto-renewal**
3. Click **"Turn off auto-renewal"**
4. Subscription expires at end of current billing cycle (no refund for remaining time)

**Request Refund** (30-day money-back guarantee):
1. Contact support: https://nordvpn.com/contact-us/ (live chat or email)
2. Request refund within 30 days of purchase
3. Provide reason (optional)
4. Refund processed in 3-5 business days

---

## Testing Checklist

Use this checklist during VM testing to verify NordVPN installation and functionality:

- [ ] **Installation**: NordVPN installed at `/Applications/NordVPN.app`
- [ ] **Launch**: Launch NordVPN from Applications or Spotlight
- [ ] **Sign-In Prompt**: Sign-in screen appears on first launch
- [ ] **Sign-In Success**: Enter NordVPN account credentials → Sign in successful
- [ ] **Network Extension Permission**: macOS prompts for permission → Click "Allow"
- [ ] **Menubar Icon**: Gray shield icon appears in menubar
- [ ] **Quick Connect**: Click menubar → Quick Connect → Connects in 5-10 seconds
- [ ] **Connection Status**: Menubar icon turns **green shield** (connected)
- [ ] **Server Display**: Menubar shows server name, country, IP address
- [ ] **IP Verification**: Visit https://whatismyip.com → IP changed to VPN IP (different from real IP)
- [ ] **Disconnect**: Click menubar → Disconnect → Gray shield returns
- [ ] **Reconnect to Specific Server**: Menubar → Select "United States" → Connects successfully
- [ ] **Server List Browsing**: Can browse and select different countries/servers
- [ ] **Kill Switch**: Settings → General → Kill Switch toggle available
- [ ] **Auto-Connect**: Settings → General → Auto-connect options available (Wi-Fi, Always, Never)
- [ ] **CyberSec/Threat Protection**: Settings → Toggle available for ad/malware blocking
- [ ] **Split Tunneling**: Settings → Split Tunneling available → Can add apps
- [ ] **Auto-Update Setting**: **RESEARCH** - Check Settings → Advanced or General → Document if auto-update toggle exists
  - [ ] If found: **Uncheck** auto-update → Update this doc with exact path
  - [ ] If NOT found: Note updates are Homebrew-controlled → Update this doc
- [ ] **Subscription Display**: Settings → Account → Shows active subscription + expiration date
- [ ] **VPN Protocols**: Settings → Connection → Can switch between WireGuard and OpenVPN
- [ ] **Menubar States**: Verify gray (disconnected), green (connected), yellow (connecting) states
- [ ] **Disconnect and Reconnect**: Multiple connect/disconnect cycles work reliably

---

## Additional Resources

- **NordVPN Website**: https://nordvpn.com/
- **Support Center**: https://support.nordvpn.com/
- **Live Chat Support**: https://nordvpn.com/contact-us/ (24/7 availability)
- **Server Status**: https://nordvpn.com/servers/
- **What Is My IP**: https://whatismyip.com/ (verify VPN IP)
- **DNS Leak Test**: https://dnsleaktest.com/ (verify DNS protection)
- **Speed Test**: https://speedtest.net/ (test VPN speed)

---

## Summary

**NordVPN Key Points**:
- **Paid subscription required** (NO free tier)
- **Network Extension permission** required on first connection
- **Quick Connect** for fastest one-click VPN
- **59+ countries**, 5,000+ servers
- **Kill Switch** prevents IP leaks
- **CyberSec/Threat Protection** blocks ads/malware
- **Split Tunneling** bypasses VPN for specific apps
- **Auto-update**: Research needed (check Settings during VM testing)

**Post-Install Actions**:
1. Launch NordVPN → Sign in with subscription account
2. Grant Network Extension permission (click "Allow" on system prompt)
3. Configure Kill Switch (Settings → General → Enable)
4. Set Auto-connect preferences (Settings → General → Wi-Fi recommended)
5. **Research auto-update setting** (Settings → Check all tabs → Document findings)
6. Test Quick Connect → Verify IP changed on https://whatismyip.com

**For FX**: During VM testing, please verify auto-update setting location and update this documentation + `docs/licensed-apps.md` with findings.
