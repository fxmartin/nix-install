# ABOUTME: 1Password post-installation configuration guide
# ABOUTME: Covers account setup, auto-update disable, browser extensions, password management, and security features

### 1Password

**Status**: Installed via Homebrew cask `1password` (Story 02.4-002)

**Purpose**: Password manager and secure vault. Manages passwords, secure notes, credit cards, identities, documents, and licenses across all devices with end-to-end encryption.

**First Launch**:
1. Launch 1Password from Spotlight (`Cmd+Space`, type "1Password") or from `/Applications/1Password.app`
2. Welcome screen appears with account setup wizard
3. Follow setup steps:
   - **Account Sign-In** (REQUIRED): Sign in with existing 1Password account
     - Enter your email address
     - Enter your Master Password
     - Enter your Secret Key (34-character code from account setup)
   - **OR Create New Account**: Create a new 1Password.com account
     - Choose account type (Individual, Family, Team)
     - Set up Master Password (CRITICAL: This cannot be recovered if lost)
     - Save Secret Key securely (needed for account recovery)
   - **Biometric Unlock** (Optional): Enable Touch ID for quick unlocking
   - **Browser Extension** (Recommended): Install browser extensions for autofill

**Account Sign-In Process**:

1Password requires a 1Password.com account (no separate license key needed).

**If You Already Have a 1Password Account**:
1. Launch 1Password
2. Click "Sign In to 1Password Account"
3. Enter your email address → Continue
4. Enter your Master Password
5. Enter your Secret Key (found in Emergency Kit or previous installation)
6. Click "Sign In"
7. 1Password syncs your vault from the cloud

**If You Need to Create a New Account**:
1. Launch 1Password
2. Click "Try 1Password Free" or "Create Account"
3. Choose account type:
   - **Individual**: $2.99/month (single user, unlimited devices)
   - **Families**: $4.99/month (5 family members, shared vaults)
   - **Teams**: Business pricing (team vaults, admin controls)
4. Enter email address → Continue
5. Create a **strong Master Password** (CRITICAL: Cannot be recovered if lost!)
   - Use a memorable but secure passphrase
   - Write it down in a safe physical location
   - This is the ONLY password you need to remember
6. Save your **Secret Key** (34-character code):
   - Download Emergency Kit PDF
   - Print Emergency Kit and store securely
   - Secret Key is required for account recovery and new device setup
7. Complete sign-up and billing information
8. 1Password creates your vault and syncs to the cloud

**Auto-Update Configuration** (REQUIRED):

1Password updates must be disabled to maintain declarative configuration control.

**Steps to Disable Auto-Update**:
1. Launch 1Password (or click menubar icon)
2. Click **1Password** in menu bar → **Settings...** (or press `Cmd+,`)
3. Navigate to **Advanced** tab
4. Find **Updates** section
5. **Uncheck** "Check for updates automatically"
6. Close Settings

**Verification**:
- Open 1Password Settings → Advanced
- Confirm "Check for updates automatically" is **unchecked**
- Updates will now only occur via `darwin-rebuild switch` (controlled by Homebrew)

**Update Process** (Controlled by Homebrew):
```bash
# To update 1Password (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Browser Extension Setup** (RECOMMENDED):

1Password browser extensions enable autofill and password generation in web browsers.

**Installing Browser Extensions**:

1. **Safari** (macOS built-in browser):
   - 1Password automatically detects Safari on first launch
   - Click "Install Extension" when prompted
   - OR: Safari → Settings → Extensions → Enable 1Password extension
   - Grant permissions when requested

2. **Brave Browser** (if installed):
   - Visit Chrome Web Store: https://chrome.google.com/webstore/detail/1password/aeblfdkhhhdcdjpifhhbdiojplfjncoa
   - Click "Add to Brave"
   - OR: 1Password → Settings → Browser → Click "Install Extension" next to Brave
   - Grant permissions when requested

3. **Arc Browser** (if installed):
   - Visit Chrome Web Store: https://chrome.google.com/webstore/detail/1password/aeblfdkhhhdcdjpifhhbdiojplfjncoa
   - Click "Add to Arc"
   - OR: 1Password → Settings → Browser → Click "Install Extension" next to Arc
   - Grant permissions when requested

4. **Firefox** (if installed):
   - Visit Firefox Add-ons: https://addons.mozilla.org/en-US/firefox/addon/1password-x-password-manager/
   - Click "Add to Firefox"
   - OR: 1Password → Settings → Browser → Click "Install Extension" next to Firefox
   - Grant permissions when requested

**Browser Extension Setup**:
1. Install extension for your browser(s)
2. Extension icon appears in browser toolbar
3. Click extension icon → Sign in to 1Password account
4. Extension connects to 1Password app on Mac
5. Now you can autofill passwords and generate secure passwords in browser

**Core Features**:

1Password provides comprehensive password and secure information management:

1. **Password Management**:
   - Store unlimited passwords with strong encryption
   - Autofill passwords in browsers and apps
   - Generate strong, random passwords
   - Password strength analysis (Watchtower)
   - Duplicate password detection
   - Reused password alerts

2. **Secure Notes**:
   - Store sensitive text information securely
   - Notes are encrypted end-to-end
   - Organize with tags and favorites
   - Support for Markdown formatting

3. **Credit Cards & Payment Methods**:
   - Store credit card details securely
   - Autofill payment information in browsers
   - Track expiration dates
   - Store multiple cards and accounts

4. **Identities & Personal Information**:
   - Store identity information (name, address, phone, etc.)
   - Autofill forms with personal data
   - Multiple identities (work, personal, etc.)
   - Driver's license, passport, social security storage

5. **Document Storage**:
   - Store secure documents (PDFs, images, licenses)
   - End-to-end encrypted file storage
   - Up to 1GB per document (Individual plan)
   - Access documents across all devices

6. **SSH Key Management**:
   - Store SSH private keys securely
   - Use SSH keys from 1Password in terminal
   - Integration with `ssh-agent`
   - GitHub, GitLab, Bitbucket SSH key support

7. **Watchtower** (Security Auditing):
   - Weak password detection
   - Reused password alerts
   - Compromised website monitoring (Have I Been Pwned integration)
   - Two-factor authentication availability alerts
   - Expiring credit card notifications

8. **Shared Vaults** (Family/Team plans):
   - Share passwords with family members or team
   - Shared vaults for common accounts
   - Individual vaults remain private
   - Admin controls for team accounts

**Basic Usage Examples**:

**Saving a New Password**:
1. Open 1Password app
2. Click "+" button → "Login"
3. Enter website URL, username, password
4. OR: Use browser extension "Save Login" when logging into website
5. Password saved to vault

**Autofilling a Password**:
1. Visit login page in browser
2. Click in username or password field
3. Browser extension icon appears in field
4. Click icon → Select account → Password autofilled
5. OR: Click browser extension toolbar icon → Search for site → Click to autofill

**Generating a Strong Password**:
1. When creating new account on website
2. Click in password field
3. Browser extension suggests strong password
4. Click "Use Suggested Password"
5. Password saved automatically to 1Password

**Searching for Items**:
1. Open 1Password app
2. Use search bar at top (or press `Cmd+F`)
3. Type website name, username, or keyword
4. Click result to view/copy password

**Quick Access** (Menubar):
1. Click 1Password icon in menubar
2. Search for password or item
3. Press Enter to copy password
4. OR: Click to open full item details

**Configuration Tips**:

1. **Organize with Tags**:
   - Add tags to items for better organization
   - Tag examples: "work", "personal", "banking", "social"
   - Filter by tag in sidebar

2. **Favorites**:
   - Star frequently used items
   - Favorites appear at top of search results
   - Quick access to most-used passwords

3. **Security Settings**:
   - Settings → Security
   - Enable Touch ID unlock (recommended)
   - Set auto-lock timeout (5 minutes recommended)
   - Require Master Password for sensitive actions

4. **Browser Integration**:
   - Settings → Browser
   - Enable autofill for all installed browsers
   - Configure keyboard shortcuts
   - Enable password generator

5. **Watchtower Monitoring**:
   - Settings → Watchtower
   - Enable "Check for vulnerable passwords"
   - Enable "Check for reused passwords"
   - Review Watchtower alerts regularly

6. **Two-Factor Authentication**:
   - Store 2FA codes in 1Password (one-time passwords)
   - Auto-copy 2FA code when autofilling password
   - Authenticator app replacement (optional)

**License Requirements**:

1Password is a **subscription-based service** (no separate license key):
- **Individual**: $2.99/month (single user, unlimited devices, 1GB documents)
- **Families**: $4.99/month (5 family members, shared vaults, 1GB per person)
- **Free Trial**: 14 days free trial available (no credit card required)
- **Account Required**: Sign in with 1Password.com account (created during first launch)

**Important**: Your 1Password subscription is managed through your 1Password.com account, not through the Mac App Store or a license file.

**Post-Install Checklist**:
- [ ] 1Password installed and launches
- [ ] Signed in with 1Password account (or created new account)
- [ ] Master Password set and saved securely
- [ ] Secret Key saved in Emergency Kit (if new account)
- [ ] Touch ID enabled for quick unlock (optional but recommended)
- [ ] Auto-update disabled (Settings → Advanced → Uncheck "Check for updates automatically")
- [ ] Browser extensions installed (Safari, Brave, Arc, Firefox)
- [ ] Browser extensions connected to 1Password app
- [ ] Can autofill passwords in browser
- [ ] Can generate strong passwords
- [ ] Watchtower enabled for security monitoring

**Testing Checklist**:
- [ ] 1Password app launches successfully
- [ ] Account sign-in works (or new account created)
- [ ] Master Password unlock works
- [ ] Touch ID unlock works (if enabled)
- [ ] Browser extension installed and working
- [ ] Can save new password via browser extension
- [ ] Can autofill password on website
- [ ] Can generate strong password
- [ ] Watchtower shows security status
- [ ] Auto-update disabled (Settings → Advanced)
- [ ] Menubar quick access works

**Documentation**:
- Official Support: https://support.1password.com/
- Getting Started Guide: https://support.1password.com/get-started/
- Browser Extension Guide: https://support.1password.com/getting-started-browser/
- SSH Keys Guide: https://developer.1password.com/docs/ssh/
- Security Whitepaper: https://1password.com/security/

**Troubleshooting**:

**Issue**: Browser extension not connecting to 1Password app
- **Solution**: Open 1Password app → Settings → Browser → Enable browser integration
- Verify extension is installed and enabled in browser settings

**Issue**: Can't remember Master Password
- **Solution**: Master Password CANNOT be recovered (by design)
- Use Emergency Kit Secret Key + account email to reset (if account recovery enabled)
- Contact 1Password support for account recovery options

**Issue**: Touch ID not working
- **Solution**: Settings → Security → Re-enable Touch ID
- May need to re-enter Master Password first

**Issue**: Autofill not working in specific app or website
- **Solution**: Try manually copying password from 1Password app
- Browser extension may need permissions for specific domain
- Check browser extension settings for blocked sites

---


## Related Documentation

- [Main Apps Index](../README.md) - Overview of all application documentation
- [Raycast Configuration](./raycast.md) - Productivity launcher setup
- [File Utilities Configuration](./file-utilities.md) - Calibre, Kindle, Keka, Marked 2
- [System Utilities Configuration](./system-utilities.md) - Onyx, f.lux
