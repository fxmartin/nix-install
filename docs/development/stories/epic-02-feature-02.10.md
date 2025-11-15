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

**Implementation Status**: Not Started

**Dependencies**:
- Epic-01, Story 01.2-003 (user-config.nix created with user email addresses)
- Epic-07, Story 07.2-002 (Post-install configuration documentation)

**Risk Level**: Medium
**Risk Mitigation**:
- Configuration profiles are Apple-supported and stable
- Manual password entry is expected and acceptable
- Gmail OAuth may require troubleshooting (app-specific passwords as fallback)
- Test thoroughly in VM before physical hardware
- Document all manual steps clearly

---

