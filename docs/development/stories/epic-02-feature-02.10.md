# ABOUTME: Epic-02 Feature 02.10 (Email Account Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 02.10

# Epic-02 Feature 02.10: Email Account Configuration

## Feature Overview

**Feature ID**: Feature 02.10
**Feature Name**: Email Account Configuration
**Epic**: Epic-02
**Status**: 🔄 In Progress

### Feature 02.10: Email Account Configuration
**Feature Description**: Automated setup of email accounts in macOS Mail.app (1 Gmail with OAuth, 4 Gandi.net accounts with manual passwords)
**User Value**: Email accounts configured automatically during bootstrap, ready to use immediately
**Story Count**: 1
**Story Points**: 5
**Priority**: Must Have
**Complexity**: Medium

#### Stories in This Feature

##### Story 02.10-001: macOS Mail.app Email Account Automation
**User Story**: As FX, I want my 5 email accounts (1 Gmail, 4 Gandi.net) automatically configured in macOS Mail.app so that I can start using email immediately after first launch

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I open Mail.app for the first time
- **Then** all 5 email accounts are listed in the sidebar
- **And** Gmail account prompts for OAuth sign-in (expected manual step)
- **And** Gandi.net accounts prompt for password entry (expected manual step)
- **And** after entering credentials, all accounts sync successfully
- **And** I can send and receive email from all accounts
- **And** account configuration includes correct IMAP and SMTP settings

**Additional Requirements**:
- Gmail account: OAuth authentication (user must sign in)
- Gandi.net accounts (4): IMAP/SMTP with manual password entry
- Account details from user-config.nix or separate email-config.nix
- Configuration via macOS defaults, profiles, or activation scripts
- Both Standard and Power profiles

**Technical Notes**:
- **Approach 1 (Recommended)**: Configuration Profile (.mobileconfig)
  - Create .mobileconfig XML with account definitions
  - Install via `open` command or system activation script
  - Passwords left blank (user enters after first launch)
  - Gmail: Account type = EmailTypeIMAP with OAuth placeholder
  - Gandi: Account type = EmailTypeIMAP with server settings

- **Approach 2**: macOS defaults write
  - Use `defaults` commands to write Mail.app preferences
  - More fragile, may break across macOS versions

- **Approach 3**: AppleScript automation
  - Script Mail.app to add accounts programmatically
  - Complex, requires accessibility permissions

- **Recommended Implementation**:
  ```nix
  # In darwin/configuration.nix or home-manager module
  system.activationScripts.configureMailAccounts = {
    text = ''
      # Copy email configuration profile
      MAIL_CONFIG="/tmp/email-accounts.mobileconfig"
      cat > "$MAIL_CONFIG" <<'EOF'
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>PayloadContent</key>
        <array>
          <!-- Gmail Account -->
          <dict>
            <key>PayloadType</key>
            <string>com.apple.mail.managed</string>
            <key>EmailAccountDescription</key>
            <string>Gmail</string>
            <key>EmailAccountType</key>
            <string>EmailTypeIMAP</string>
            <key>EmailAddress</key>
            <string>${user.email.gmail}</string>
            <key>IncomingMailServerHostName</key>
            <string>imap.gmail.com</string>
            <key>IncomingMailServerPortNumber</key>
            <integer>993</integer>
            <key>IncomingMailServerUseSSL</key>
            <true/>
            <key>IncomingMailServerAuthentication</key>
            <string>EmailAuthOAuth2</string>
            <key>OutgoingMailServerHostName</key>
            <string>smtp.gmail.com</string>
            <key>OutgoingMailServerPortNumber</key>
            <integer>587</integer>
            <key>OutgoingMailServerUseSSL</key>
            <true/>
            <key>OutgoingMailServerAuthentication</key>
            <string>EmailAuthOAuth2</string>
          </dict>
          <!-- Gandi Account 1 -->
          <dict>
            <key>PayloadType</key>
            <string>com.apple.mail.managed</string>
            <key>EmailAccountDescription</key>
            <string>Gandi Account 1</string>
            <key>EmailAccountType</key>
            <string>EmailTypeIMAP</string>
            <key>EmailAddress</key>
            <string>${user.email.gandi1}</string>
            <key>IncomingMailServerHostName</key>
            <string>mail.gandi.net</string>
            <key>IncomingMailServerPortNumber</key>
            <integer>993</integer>
            <key>IncomingMailServerUseSSL</key>
            <true/>
            <key>IncomingMailServerAuthentication</key>
            <string>EmailAuthPassword</string>
            <key>OutgoingMailServerHostName</key>
            <string>mail.gandi.net</string>
            <key>OutgoingMailServerPortNumber</key>
            <integer>587</integer>
            <key>OutgoingMailServerUseSSL</key>
            <true/>
            <key>OutgoingMailServerAuthentication</key>
            <string>EmailAuthPassword</string>
          </dict>
          <!-- Repeat for Gandi accounts 2-4 -->
        </array>
        <key>PayloadDisplayName</key>
        <string>Email Accounts</string>
        <key>PayloadIdentifier</key>
        <string>com.fx.email-accounts</string>
        <key>PayloadType</key>
        <string>Configuration</string>
        <key>PayloadUUID</key>
        <string>$(uuidgen)</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
      </dict>
      </plist>
      EOF

      # Install profile (user will see system prompt)
      open "$MAIL_CONFIG"

      echo "Email accounts configured. Open Mail.app and enter passwords when prompted."
    '';
  };
  ```

- **Email Configuration File** (email-config.nix or in user-config.nix):
  ```nix
  {
    email = {
      gmail = "you@gmail.com";
      gandi1 = "account1@yourdomain.com";
      gandi2 = "account2@yourdomain.com";
      gandi3 = "account3@yourdomain.com";
      gandi4 = "account4@yourdomain.com";
    };
  }
  ```

- **Gandi.net Settings**:
  - IMAP: mail.gandi.net, port 993, SSL
  - SMTP: mail.gandi.net, port 587, STARTTLS
  - Authentication: Username = full email address, password required

- **Gmail Settings**:
  - IMAP: imap.gmail.com, port 993, SSL
  - SMTP: smtp.gmail.com, port 587, STARTTLS
  - Authentication: OAuth2 (user signs in via browser)
  - May require "Allow less secure apps" or app-specific password if OAuth fails

**Definition of Done**:
- [ ] Email configuration implementation chosen (profile, defaults, or script)
- [ ] Email addresses configurable in user-config.nix or email-config.nix
- [ ] Configuration profile or script created
- [ ] Activation script installs account configuration
- [ ] Tested in VM: Mail.app shows all 5 accounts
- [ ] Tested credential entry: Gmail OAuth and Gandi password prompts work
- [ ] All accounts sync successfully after credential entry
- [ ] Documentation added to post-install guide
- [ ] Bootstrap summary notes manual credential entry required
- [ ] Works on both Standard and Power profiles

**Implementation Status**: ✅ **CODE COMPLETE** (Ready for VM Testing)

**Dependencies**:
- Epic-01, Story 01.2-003 (user-config.nix created with user email addresses) ✅
- Epic-07, Story 07.2-002 (Post-install configuration documentation) - N/A (documentation created in Story 02.10-001)

**Risk Level**: Medium
**Risk Mitigation**:
- Configuration profiles are Apple-supported and stable
- Manual password entry is expected and acceptable
- Gmail OAuth may require troubleshooting (app-specific passwords as fallback)
- Test thoroughly in VM before physical hardware ⏳
- Document all manual steps clearly ✅

---

## Implementation Details

### Code Changes Summary

**Files Created**:
1. **email-config.template.nix** (16 lines) - Template with email placeholders (tracked in git)
2. **darwin/email-accounts.nix** (327 lines) - Nix-darwin module generating .mobileconfig profile
3. **docs/apps/productivity/email-configuration.md** (410 lines) - Comprehensive user documentation

**Files Modified**:
1. **bootstrap.sh** (+102 lines):
   - Phase 2: Email address prompts (already existed, lines 493-579)
   - Phase 2: `generate_email_config()` function (new, lines 805-848)
   - Phase 2: Call `generate_email_config()` after `generate_user_config()` (lines 4684-4690)
   - Phase 4: Download `email-config.template.nix` from GitHub (lines 1840-1849)
   - Phase 4: Download `darwin/email-accounts.nix` module (line 1857 - changed from email-config.nix)
   - Phase 7: `copy_email_config_to_repo()` function (new, lines 3929-3969)
   - Phase 7: Call `copy_email_config_to_repo()` in two places (lines 4092-4098, 4139-4145)
2. **.gitignore** (+4 lines): Added `email-config.nix` to ignore private email addresses
3. **flake.nix** (+3 lines): Import `./darwin/email-accounts.nix` module in commonModules (line 139)

### Implementation Approach

**Chosen Solution**: Configuration Profile (.mobileconfig)
- Most reliable and Apple-supported method
- Less fragile than `defaults write` commands
- Simpler than AppleScript automation
- macOS handles profile installation via System Preferences

**Architecture**:
```
Bootstrap Phase 2
  ↓
Prompts for 5 emails → Generates email-config.nix (gitignored)
  ↓
darwin-rebuild (darwin/email-accounts.nix)
  ↓
Reads email-config.nix → Generates .mobileconfig XML
  ↓
Saves to /tmp/email-accounts.mobileconfig
  ↓
User manually installs via System Preferences → Profiles
  ↓
User opens Mail.app → Enters passwords/OAuth credentials
  ↓
All 5 accounts sync and ready to use
```

**Security Design**:
- **email-config.nix**: Gitignored (contains real email addresses) - private data never in git
- **email-config.template.nix**: Tracked (contains `@EMAIL_*@` placeholders) - safe to share
- **Passwords**: NEVER stored anywhere - entered manually each time by user
- **macOS Keychain**: Stores passwords securely (encrypted, Touch ID protected)

### Technical Implementation

#### 1. Template File (email-config.template.nix)

```nix
{
  gmail = "@EMAIL_GMAIL@";
  gandi1 = "@EMAIL_GANDI1@";
  gandi2 = "@EMAIL_GANDI2@";
  gandi3 = "@EMAIL_GANDI3@";
  gandi4 = "@EMAIL_GANDI4@";
}
```

#### 2. Bootstrap Function (generate_email_config)

**Location**: bootstrap.sh lines 805-848
**Purpose**: Generates email-config.nix from template with real email addresses
**Execution**: Phase 2, after `generate_user_config()`
**Validation**: Uses existing `validate_nix_syntax()` function

Key features:
- Reads email-config.template.nix
- Replaces placeholders with `${EMAIL_GMAIL}` etc.
- Writes to `/tmp/nix-bootstrap/email-config.nix`
- Validates Nix syntax (balanced braces, non-empty, readable)

#### 3. Darwin Module (darwin/email-accounts.nix)

**Location**: darwin/email-accounts.nix (327 lines)
**Purpose**: Reads email-config.nix and generates .mobileconfig XML profile
**Execution**: During `darwin-rebuild switch`
**Output**: `/tmp/email-accounts.mobileconfig`

Key features:
- Imports `../email-config.nix` with fallback to placeholder values
- Generates XML configuration profile with 5 email account payloads
- Gmail: EmailAuthPassword (OAuth2 via browser redirect + app-specific password support)
- Gandi (4x): EmailAuthPassword (standard IMAP/SMTP password auth)
- Profile metadata: UUID, display name, description
- No passwords stored (users enter manually)

#### 4. Configuration Profile Structure

Each account payload includes:
- `EmailAccountDescription`: Account display name
- `EmailAccountType`: `EmailTypeIMAP`
- `EmailAddress`: From email-config.nix
- `IncomingMailServerHostName`: imap.gmail.com or mail.gandi.net
- `IncomingMailServerPortNumber`: 993 (SSL)
- `OutgoingMailServerHostName`: smtp.gmail.com or mail.gandi.net
- `OutgoingMailServerPortNumber`: 587 (STARTTLS)
- `OutgoingPasswordSameAsIncomingPassword`: true

### Documentation Created

**docs/apps/productivity/email-configuration.md** (410 lines):

**Sections**:
1. **Overview** (20 lines): Story ID, installation method, license
2. **What Gets Installed** (18 lines): 5 accounts with server settings
3. **How It Works** (35 lines): Bootstrap → rebuild → manual steps
4. **Post-Install Configuration** (85 lines):
   - Step 1: Install profile (System Preferences)
   - Step 2: Enter credentials (Gmail OAuth + Gandi passwords)
   - Step 3: Verify all accounts
5. **Configuration File Structure** (45 lines): email-config.nix, template, module
6. **Mail.app Usage Tips** (50 lines): Multiple accounts, shortcuts, preferences
7. **Troubleshooting** (95 lines): 5 common issues with solutions
8. **Advanced Configuration** (35 lines): Changing addresses, removing accounts
9. **Security & Privacy** (30 lines): Data storage, best practices
10. **Verification Checklist** (12 lines): 11-item validation list
11. **Related Documentation** (5 lines): Cross-references
12. **References** (10 lines): Official Apple/Gmail/Gandi docs

### Testing Strategy

**VM Testing Required** (NOT yet performed by FX):

**Scenario 1: Fresh Install - Standard Profile**
- Bootstrap with 5 email addresses
- darwin-rebuild switch
- Profile appears in System Preferences
- Install profile manually
- Mail.app shows 5 accounts
- Enter credentials for all accounts
- Verify send/receive works

**Scenario 2: Fresh Install - Power Profile**
- Same as Scenario 1 (email setup identical for both profiles)

**Scenario 3: Gmail OAuth Flow**
- Test App-Specific Password method
- Test browser redirect OAuth method (if supported)
- Verify 2FA integration

**Scenario 4: Gandi Password Entry**
- Test password entry for all 4 Gandi accounts
- Verify IMAP and SMTP use same password
- Test "forgot password" recovery flow

**Scenario 5: Existing email-config.nix**
- Run bootstrap twice (should preserve existing email-config.nix)
- Verify no overwrite of email addresses

**Scenario 6: Email Address Change**
- Edit email-config.nix directly
- darwin-rebuild
- Reinstall profile
- Verify new addresses appear in Mail.app

**Scenario 7: Profile Removal**
- Remove profile via System Preferences
- Verify accounts removed from Mail.app

**Scenario 8: Cross-Device Sync**
- Send email from Mac
- Verify appears in Sent folder on iPhone/iPad
- Verify IMAP sync working

### Lessons Learned (During Implementation)

1. **Gitignore Critical for Privacy**: email-config.nix must be gitignored to prevent email addresses in public repo
2. **Separate Template from Data**: email-config.template.nix (tracked) vs email-config.nix (gitignored) separation works well
3. **Bootstrap Synchronization**: Must add new files to Phase 4 download list (Hotfix #17 lesson applied)
4. **Shellcheck Validation**: All new functions passed shellcheck with 0 errors
5. **Configuration Profiles Are Stable**: Apple-supported method, less likely to break across macOS versions
6. **OAuth Complexity**: Gmail OAuth requires app-specific passwords for Mail.app (browser redirect not fully supported)
7. **User Manual Steps Acceptable**: Profile installation and credential entry are reasonable manual steps
8. **Documentation Depth Matches Other Apps**: 410 lines similar to Zoom (302) + Webex (307) = ~600 lines for complex apps

### Known Limitations

1. **Manual Profile Installation**: Cannot auto-install .mobileconfig without MDM (requires user action in System Preferences)
2. **Manual Credential Entry**: Passwords cannot be pre-filled (security limitation, by design)
3. **Gmail OAuth Friction**: May require app-specific password instead of browser OAuth
4. **No Auto-Discovery**: Cannot auto-detect IMAP/SMTP settings (must be pre-configured)
5. **macOS Mail.app Only**: Other email clients (Thunderbird, Outlook) require manual setup

### Future Enhancements (Not in Scope)

- P2: Auto-open System Preferences → Profiles after rebuild
- P2: Generate per-account .mobileconfig profiles (for selective installation)
- P2: Thunderbird/Outlook configuration file generation
- P2: Email signature management via Nix
- P2: Mail rules/filters automation

---

## VM Testing Checklist

**Prerequisites**:
- [ ] Clean macOS VM snapshot (fresh install)
- [ ] Network access (for Gmail OAuth and IMAP/SMTP testing)
- [ ] Gmail account with 2FA enabled and app-specific password ready
- [ ] Gandi.net account credentials ready (4 accounts)

**Testing Steps**:

### Phase 1: Bootstrap & Config Generation
- [ ] Run bootstrap.sh
- [ ] Enter 5 email addresses when prompted
- [ ] Verify email addresses displayed for confirmation
- [ ] Confirm email addresses
- [ ] Check `/tmp/nix-bootstrap/email-config.nix` exists and contains correct addresses
- [ ] Verify email-config.nix syntax is valid Nix
- [ ] Complete bootstrap (all phases)

### Phase 2: Repository Clone & File Copy
- [ ] Verify `email-config.nix` copied to `~/Documents/nix-install/`
- [ ] Verify `email-config.template.nix` downloaded to `~/Documents/nix-install/`
- [ ] Verify `darwin/email-accounts.nix` downloaded
- [ ] Check `git status` - email-config.nix should NOT appear (gitignored)
- [ ] Check `git status` - email-config.template.nix SHOULD be tracked

### Phase 3: darwin-rebuild Execution
- [ ] Run `darwin-rebuild switch --flake ~/Documents/nix-install#standard`
- [ ] Verify "📧 Configuring macOS Mail.app accounts..." message appears
- [ ] Check `/tmp/email-accounts.mobileconfig` file exists
- [ ] Verify .mobileconfig contains all 5 email addresses
- [ ] Verify .mobileconfig XML is valid (no syntax errors)

### Phase 4: Configuration Profile Installation
- [ ] Open System Preferences/Settings
- [ ] Navigate to Profiles section
- [ ] Verify "FX Email Accounts" profile appears
- [ ] Click profile → view details
- [ ] Verify 5 email accounts listed
- [ ] Click Install
- [ ] Enter macOS password when prompted
- [ ] Verify profile installs successfully
- [ ] Check profile status: "Installed"

### Phase 5: Mail.app First Launch
- [ ] Open Mail.app
- [ ] Verify all 5 accounts appear in sidebar:
  - [ ] Gmail
  - [ ] Gandi 1
  - [ ] Gandi 2
  - [ ] Gandi 3
  - [ ] Gandi 4

### Phase 6: Gmail Credential Entry
- [ ] Click Gmail account
- [ ] Enter password (app-specific password recommended)
- [ ] Complete OAuth flow if prompted
- [ ] Wait for initial sync (~1-5 minutes)
- [ ] Verify inbox loads successfully
- [ ] Verify folder structure appears (Sent, Drafts, Trash)

### Phase 7: Gandi Credential Entry (All 4 Accounts)
For each Gandi account:
- [ ] Click account in sidebar
- [ ] Enter password when prompted
- [ ] Verify "Same password for outgoing" checkbox is checked
- [ ] Wait for initial sync
- [ ] Verify inbox loads
- [ ] Verify folder structure appears

### Phase 8: Send/Receive Testing
- [ ] **Gmail**: Send test email to yourself → verify received
- [ ] **Gmail**: Reply to test email → verify sent
- [ ] **Gandi 1**: Send test email → verify sent
- [ ] **Gandi 2**: Send test email → verify sent
- [ ] **Gandi 3**: Send test email → verify sent
- [ ] **Gandi 4**: Send test email → verify sent
- [ ] Verify all sent messages appear in Sent folder
- [ ] Verify IMAP sync working (Sent folder syncs to server)

### Phase 9: Multi-Account Compose
- [ ] Click New Message (Cmd+N)
- [ ] Use From: dropdown
- [ ] Verify all 5 accounts appear in dropdown
- [ ] Compose test email from each account
- [ ] Verify correct account used for sending

### Phase 10: Cross-Device Sync (If Available)
- [ ] Send email from Mac Mail.app
- [ ] Check iPhone/iPad Mail.app
- [ ] Verify email appears in Sent folder on mobile
- [ ] Send email from mobile
- [ ] Verify appears in Mac Mail.app Sent folder

### Phase 11: Profile Removal
- [ ] Open System Preferences → Profiles
- [ ] Select "FX Email Accounts" profile
- [ ] Click Remove (minus button)
- [ ] Confirm removal
- [ ] Open Mail.app
- [ ] Verify all 5 accounts removed from sidebar
- [ ] Verify Mail.app works with empty account list

### Phase 12: Documentation Validation
- [ ] Open `docs/apps/productivity/email-configuration.md`
- [ ] Follow Step 1 (Install Profile) - verify accuracy
- [ ] Follow Step 2 (Gmail setup) - verify accuracy
- [ ] Follow Step 3 (Gandi setup) - verify accuracy
- [ ] Test troubleshooting steps for at least 2 common issues
- [ ] Verify all keyboard shortcuts work
- [ ] Check all hyperlinks in documentation are valid

### Phase 13: Error Handling
- [ ] Test wrong Gmail password → verify error message
- [ ] Test wrong Gandi password → verify error message
- [ ] Test network disconnect during sync → verify recovery
- [ ] Test profile installation with wrong macOS password → verify retry

### Expected Results

**All tests MUST pass** before marking Story 02.10-001 as VM Tested ✅

**Success Criteria**:
- ✅ All 5 accounts appear in Mail.app after profile installation
- ✅ Gmail OAuth or app-specific password flow works
- ✅ All 4 Gandi accounts authenticate successfully
- ✅ Send/receive works for all accounts
- ✅ Cross-device IMAP sync works
- ✅ Profile removal cleanly removes all accounts
- ✅ Documentation accurately reflects setup process
- ✅ All 13 VM test phases pass without errors

**If ANY test fails**:
1. Document failure details in this file
2. Create GitHub issue with "vm-testing" label
3. Fix issue
4. Rerun ALL 13 test phases from beginning
5. Only mark as VM Tested ✅ after ALL phases pass

---

## Post-Implementation Notes

**Implementation Date**: 2025-01-16
**Implemented By**: Claude Code (bash-zsh-macos-engineer agent guidance)
**Code Review**: Self-reviewed (senior-code-reviewer validation required in PR)
**VM Testing**: ⏳ **PENDING** (FX will test manually in Parallels VM)
**Physical Testing**: ⏳ **NOT STARTED** (after VM validation)

**Next Steps for FX**:
1. ✅ Review code changes (verify implementation correctness)
2. ⏳ Create Parallels VM snapshot for testing
3. ⏳ Run all 13 VM test phases
4. ⏳ Document any issues found
5. ⏳ Iterate on fixes if needed
6. ⏳ Mark story as VM Tested ✅ after all tests pass
7. ⏳ Test on physical MacBook Pro M3 Max (Power profile)
8. ⏳ Test on physical MacBook Air (Standard profile)
9. ⏳ Mark story as Complete ✅ after physical validation

---

