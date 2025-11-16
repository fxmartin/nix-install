# Email Account Configuration (Manual Setup)

**Story**: 02.10-001 - macOS Mail.app Email Configuration
**Status**: ❌ **CANCELLED** - Automation abandoned, manual setup required
**Category**: Productivity / Email
**Automation Level**: Manual (configuration profile automation proved too complex)
**License**: Free (macOS built-in Mail.app)

## Overview

This guide covers manual setup of 5 email accounts in macOS Mail.app:
- 1 Gmail account (OAuth2 authentication)
- 4 Gandi.net accounts (password authentication)

**Why Manual Setup?**

Configuration profile automation was attempted but cancelled due to:
- macOS profile installation complexity (credential prompts unclear for multiple accounts)
- Conflicts with existing account configurations
- Better user experience with manual setup (clearer which account is being configured)
- Manual setup takes ~5 minutes vs. debugging profile installation issues

## Prerequisites

Before starting, gather:
- **Gmail**: Email address and App-Specific Password (https://myaccount.google.com/apppasswords)
- **Gandi**: 4 email addresses and their mailbox passwords

## Manual Setup Instructions

### Step 1: Add Gmail Account

1. **Open Mail.app**: `open -a Mail`
2. **Open Mail Preferences**: Mail → Settings (Cmd+,)
3. **Click Accounts tab**
4. **Click + button** (bottom left)
5. **Select Google** from provider list
6. **Sign in with your Gmail address**
7. **Enter password**:
   - **Option A (Recommended)**: Use App-Specific Password
     - Visit https://myaccount.google.com/apppasswords
     - Select "Mail" and "Mac"
     - Copy 16-character password
     - Paste in Mail.app
   - **Option B**: Use regular password + OAuth
     - Enter Gmail password
     - Complete 2FA if enabled
     - Authorize Mail.app via browser
8. **Click Done**
9. **Verify**: Gmail account appears in left sidebar

### Step 2: Add Gandi Account 1 (mail@fxmartin.me)

1. **Click + button** (bottom left in Accounts preferences)
2. **Select "Add Other Mail Account..."**
3. **Enter account information**:
   - **Name**: Your full name (e.g., "François-Xavier Martin")
   - **Email Address**: `mail@fxmartin.me` (or your primary Gandi email)
   - **Password**: Your Gandi mailbox password
4. **Click Sign In**
5. **If manual server configuration required**:
   - **Account Type**: IMAP
   - **Incoming Mail Server**: `mail.gandi.net`
   - **User Name**: `mail@fxmartin.me` (full email address)
   - **Password**: Your Gandi mailbox password
   - **Outgoing Mail Server**: `mail.gandi.net`
   - **User Name**: `mail@fxmartin.me`
   - **Password**: Same as incoming
   - ✅ Check "Use same password for outgoing mail"
6. **Click Sign In** / **Create**
7. **Verify**: Account appears in left sidebar

### Step 3: Add Remaining Gandi Accounts

Repeat Step 2 for each remaining Gandi account:
- `contact@fxmartin.me` (or your second Gandi email)
- `pub@fxmartin.me` (or your third Gandi email)
- `server@fxmartin.me` (or your fourth Gandi email)

**Server settings are the same for all Gandi accounts:**
- IMAP: `mail.gandi.net` (port 993, SSL)
- SMTP: `mail.gandi.net` (port 587, STARTTLS)
- Username: Full email address
- Password: Mailbox password for that specific account

### Step 4: Verify All Accounts

After adding all 5 accounts, verify in Mail.app:

**Check accounts list:**
1. Mail → Settings → Accounts
2. Should see 6 accounts total:
   - iCloud (your existing account)
   - Gmail (martinfxavier@gmail.com or your Gmail)
   - Gandi 1 (mail@fxmartin.me or equivalent)
   - Gandi 2 (contact@fxmartin.me or equivalent)
   - Gandi 3 (pub@fxmartin.me or equivalent)
   - Gandi 4 (server@fxmartin.me or equivalent)

**Test receiving:**
1. Send test email to each account from another device
2. Verify emails appear in Mail.app inbox
3. Check IMAP sync is working

**Test sending:**
1. Compose new email (Cmd+N)
2. Use **From:** dropdown to select each account
3. Send test email to yourself
4. Verify email sends successfully
5. Check "Sent" folder syncs to server

## Mail.app Usage Tips

### Managing Multiple Accounts

**Unified Inbox:**
- Mail.app shows all accounts in one view by default
- Use sidebar to view individual account folders

**Composing from Specific Account:**
1. Click **New Message** (Cmd+N)
2. Use **From:** dropdown to select account
3. Set default: Mail → Preferences → Composing → Send new messages from

**Organizing with Folders:**
- Gmail: Uses labels (auto-synced via IMAP)
- Gandi: Create folders with right-click → New Mailbox

### Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| New Message | `Cmd+N` |
| Reply | `Cmd+R` |
| Reply All | `Cmd+Shift+R` |
| Forward | `Cmd+Shift+F` |
| Delete | `Cmd+Delete` |
| Archive | `Cmd+Ctrl+A` |
| Mark as Read | `Cmd+Shift+L` |
| Mark as Unread | `Cmd+Shift+U` |
| Search | `Cmd+Option+F` |

### Preferences to Configure

**Mail → Preferences → General:**
- ✅ Check for new messages: Every 5 minutes (or as desired)
- ✅ Downloads folder: ~/Downloads
- ✅ Remove unedited downloads: After Message is Deleted

**Mail → Preferences → Accounts:**
- ✅ Verify all accounts are listed and enabled
- ✅ Set mailbox behaviors (Drafts, Sent, Junk, Trash)

**Mail → Preferences → Junk Mail:**
- ✅ Enable junk mail filtering
- ✅ Move junk to Junk mailbox
- ⚠️ Gmail: Use Gmail's web filters (more effective)

**Mail → Preferences → Composing:**
- ✅ Message Format: Rich Text or Plain Text
- ✅ Send new messages from: Select default account
- ✅ Reply using same account: Enabled

## Troubleshooting

### Gmail Authentication Fails

**Symptoms**: "Cannot verify account" or "Invalid credentials"

**Solutions:**
1. **Use App-Specific Password** (recommended):
   - Visit https://myaccount.google.com/apppasswords
   - Generate new password for Mail
   - Use 16-character password in Mail.app
2. **Enable 2FA** if not already enabled
3. **Check Google Account Activity**:
   - Visit https://myaccount.google.com/notifications
   - Approve Mail.app access if blocked

### Gandi Account Shows "Cannot Connect"

**Symptoms**: IMAP/SMTP connection fails

**Solutions:**
1. **Verify password**: Try logging in at https://mail.gandi.net/
2. **Check mailbox status**:
   - Log in to Gandi.net admin panel
   - Navigate to Email → Mailboxes
   - Verify mailbox is "Active"
3. **Test connection manually**:
   ```bash
   # Test IMAP (port 993)
   openssl s_client -connect mail.gandi.net:993 -crlf

   # Test SMTP (port 587)
   openssl s_client -connect mail.gandi.net:587 -starttls smtp
   ```

### Emails Not Syncing Across Devices

**Symptoms**: Emails on Mac don't appear on iPhone/iPad

**Solution:**
1. **Check IMAP folders**:
   - Mail → Preferences → Accounts → [Account] → Mailbox Behaviors
   - Verify "Store sent messages on server" is enabled
   - Verify "Store junk messages on server" is enabled
2. **Force sync**:
   - Mailbox → Synchronize All Accounts (Cmd+Ctrl+Shift+K)
3. **Rebuild mailbox**:
   - Right-click account → Rebuild

### Cannot Send Emails (SMTP Errors)

**Symptoms**: "Cannot send message" or "SMTP server not responding"

**Solutions:**
1. **Re-enter SMTP password**:
   - Mail → Preferences → Accounts → [Account] → Server Settings
   - Outgoing Mail Server → Edit Server List
   - Re-enter password
2. **Verify SMTP settings**:
   - Gmail: smtp.gmail.com, port 587, TLS
   - Gandi: mail.gandi.net, port 587, TLS
3. **Test with VPN disabled** (some VPNs block SMTP)

## Server Settings Reference

### Gmail Account Settings

- **Email**: martinfxavier@gmail.com (or your Gmail address)
- **Incoming (IMAP)**:
  - Server: `imap.gmail.com`
  - Port: 993
  - Security: SSL/TLS
  - Auth: OAuth2 or App-Specific Password
- **Outgoing (SMTP)**:
  - Server: `smtp.gmail.com`
  - Port: 587
  - Security: STARTTLS
  - Auth: Same as incoming

### Gandi Account Settings (All 4 Accounts)

- **Email**: mail@fxmartin.me, contact@fxmartin.me, pub@fxmartin.me, server@fxmartin.me
- **Incoming (IMAP)**:
  - Server: `mail.gandi.net`
  - Port: 993
  - Security: SSL/TLS
  - Auth: Password
  - Username: Full email address
- **Outgoing (SMTP)**:
  - Server: `mail.gandi.net`
  - Port: 587
  - Security: STARTTLS
  - Auth: Password
  - Username: Full email address

## Security & Privacy

### Best Practices

1. **Use App-Specific Passwords** for Gmail (not your main password)
2. **Enable 2FA** on all accounts (Gmail, Gandi)
3. **Backup macOS Keychain** (contains saved passwords)
4. **Keep macOS updated** for security patches
5. **Never share passwords** via email or unencrypted channels

### Where Passwords Are Stored

- ✅ **macOS Keychain**: Passwords stored securely by Mail.app
- ✅ **Encrypted**: With macOS keychain encryption
- ✅ **Access Control**: Only accessible with macOS login password or Touch ID

## Why Automation Was Cancelled

**Original Plan**: Use macOS Configuration Profiles (.mobileconfig) to automate email account setup

**Issues Encountered:**
1. **Credential Prompt Confusion**: Profile installation prompts for credentials sequentially without clearly indicating which account (e.g., 4 Gandi accounts sharing mail.gandi.net server were indistinguishable)
2. **Existing Account Conflicts**: "Account already exists" errors when partial/broken account data present
3. **Poor User Experience**: Manual setup via Mail.app UI provides better visibility and control
4. **Time Trade-off**: 5 minutes to manually configure < time spent debugging profile issues

**Lessons Learned:**
- Configuration profiles work well for enterprise MDM scenarios with pre-shared credentials
- For personal/home use, manual Mail.app setup is more user-friendly
- macOS automation complexity sometimes exceeds manual effort for infrequent tasks

**Recommendation**: For future MacBook setups, continue using manual email configuration. The 5-minute manual setup is acceptable for a task performed once per machine.

## Verification Checklist

After completing manual setup:

- [ ] All 5 email accounts appear in Mail.app sidebar
- [ ] Gmail account can receive email (send test from another device)
- [ ] Gmail account can send email (send to yourself)
- [ ] Gandi account 1-4 can receive email
- [ ] Gandi account 1-4 can send email
- [ ] Emails sync across devices (Mac, iPhone, iPad)
- [ ] IMAP folders sync correctly (Sent, Drafts, Trash)
- [ ] Junk mail filtering works
- [ ] Search works across all accounts
- [ ] Attachments download correctly
- [ ] Compose from correct account works (From: dropdown)

## Related Documentation

- **Licensed Apps Guide**: [docs/licensed-apps.md](../../licensed-apps.md)
- **Bootstrap Documentation**: [docs/REQUIREMENTS.md](../../REQUIREMENTS.md)
- **Productivity Apps**: [docs/apps/productivity/README.md](./README.md)

## References

- **macOS Mail.app**: Built-in macOS application
- **Gmail IMAP Settings**: https://support.google.com/mail/answer/7126229
- **Gmail App Passwords**: https://myaccount.google.com/apppasswords
- **Gandi Email Documentation**: https://docs.gandi.net/en/gandimail/

---

**Story**: 02.10-001 (5 points) - **CANCELLED**
**Epic**: Epic-02 (Application Installation)
**Implementation**: Manual setup required (automation abandoned)
**Estimated Time**: 5 minutes for manual configuration
**Rationale**: Manual setup provides better UX than configuration profile automation
