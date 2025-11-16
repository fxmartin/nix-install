# ABOUTME: macOS Mail.app email account automation (Story 02.10-001)
# ABOUTME: Generates .mobileconfig profile for 5 email accounts (1 Gmail OAuth + 4 Gandi.net password auth)
{ config, pkgs, lib, ... }:

let
  # Import email addresses from email-config.nix (gitignored file)
  # This file is generated during bootstrap and contains real email addresses
  emailConfig = if builtins.pathExists ../email-config.nix
    then import ../email-config.nix
    else {
      # Fallback values if email-config.nix doesn't exist yet
      gmail = "your-gmail@gmail.com";
      gandi1 = "account1@yourdomain.com";
      gandi2 = "account2@yourdomain.com";
      gandi3 = "account3@yourdomain.com";
      gandi4 = "account4@yourdomain.com";
    };

  # Generate UUID for configuration profile
  # Note: In production, this should be a stable UUID, not regenerated on every rebuild
  profileUUID = "com.fx.email-accounts-2025";

in
{
  # macOS Mail.app Email Account Configuration
  # Installs configuration profile with email account settings
  # User must manually enter passwords/OAuth after first Mail.app launch
  system.activationScripts.configureMailAccounts = {
    text = ''
      echo "📧 Configuring macOS Mail.app accounts..."

      # Create temporary mobileconfig file
      MAIL_CONFIG="/tmp/email-accounts.mobileconfig"

      # Generate configuration profile
      cat > "$MAIL_CONFIG" <<'MOBILECONFIG_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <array>
    <!-- Gmail Account (OAuth2 Authentication) -->
    <dict>
      <key>PayloadType</key>
      <string>com.apple.mail.managed</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
      <key>PayloadIdentifier</key>
      <string>${profileUUID}.gmail</string>
      <key>PayloadUUID</key>
      <string>${profileUUID}-gmail-uuid</string>
      <key>PayloadDisplayName</key>
      <string>Gmail Account</string>
      <key>PayloadDescription</key>
      <string>Gmail email account configuration</string>
      <key>EmailAccountDescription</key>
      <string>Gmail</string>
      <key>EmailAccountName</key>
      <string>Gmail</string>
      <key>EmailAccountType</key>
      <string>EmailTypeIMAP</string>
      <key>EmailAddress</key>
      <string>${emailConfig.gmail}</string>
      <key>IncomingMailServerHostName</key>
      <string>imap.gmail.com</string>
      <key>IncomingMailServerPortNumber</key>
      <integer>993</integer>
      <key>IncomingMailServerUseSSL</key>
      <true/>
      <key>IncomingMailServerAuthentication</key>
      <string>EmailAuthPassword</string>
      <key>OutgoingMailServerHostName</key>
      <string>smtp.gmail.com</string>
      <key>OutgoingMailServerPortNumber</key>
      <integer>587</integer>
      <key>OutgoingMailServerUseSSL</key>
      <true/>
      <key>OutgoingMailServerAuthentication</key>
      <string>EmailAuthPassword</string>
      <key>OutgoingPasswordSameAsIncomingPassword</key>
      <true/>
      <key>PreventMove</key>
      <false/>
      <key>PreventAppSheet</key>
      <false/>
      <key>SMIMEEnabled</key>
      <false/>
    </dict>

    <!-- Gandi.net Account 1 (Password Authentication) -->
    <dict>
      <key>PayloadType</key>
      <string>com.apple.mail.managed</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
      <key>PayloadIdentifier</key>
      <string>${profileUUID}.gandi1</string>
      <key>PayloadUUID</key>
      <string>${profileUUID}-gandi1-uuid</string>
      <key>PayloadDisplayName</key>
      <string>Gandi Account 1</string>
      <key>PayloadDescription</key>
      <string>Gandi.net email account 1 configuration</string>
      <key>EmailAccountDescription</key>
      <string>Gandi 1</string>
      <key>EmailAccountName</key>
      <string>Gandi Account 1</string>
      <key>EmailAccountType</key>
      <string>EmailTypeIMAP</string>
      <key>EmailAddress</key>
      <string>${emailConfig.gandi1}</string>
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
      <key>OutgoingPasswordSameAsIncomingPassword</key>
      <true/>
      <key>PreventMove</key>
      <false/>
      <key>PreventAppSheet</key>
      <false/>
      <key>SMIMEEnabled</key>
      <false/>
    </dict>

    <!-- Gandi.net Account 2 (Password Authentication) -->
    <dict>
      <key>PayloadType</key>
      <string>com.apple.mail.managed</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
      <key>PayloadIdentifier</key>
      <string>${profileUUID}.gandi2</string>
      <key>PayloadUUID</key>
      <string>${profileUUID}-gandi2-uuid</string>
      <key>PayloadDisplayName</key>
      <string>Gandi Account 2</string>
      <key>PayloadDescription</key>
      <string>Gandi.net email account 2 configuration</string>
      <key>EmailAccountDescription</key>
      <string>Gandi 2</string>
      <key>EmailAccountName</key>
      <string>Gandi Account 2</string>
      <key>EmailAccountType</key>
      <string>EmailTypeIMAP</string>
      <key>EmailAddress</key>
      <string>${emailConfig.gandi2}</string>
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
      <key>OutgoingPasswordSameAsIncomingPassword</key>
      <true/>
      <key>PreventMove</key>
      <false/>
      <key>PreventAppSheet</key>
      <false/>
      <key>SMIMEEnabled</key>
      <false/>
    </dict>

    <!-- Gandi.net Account 3 (Password Authentication) -->
    <dict>
      <key>PayloadType</key>
      <string>com.apple.mail.managed</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
      <key>PayloadIdentifier</key>
      <string>${profileUUID}.gandi3</string>
      <key>PayloadUUID</key>
      <string>${profileUUID}-gandi3-uuid</string>
      <key>PayloadDisplayName</key>
      <string>Gandi Account 3</string>
      <key>PayloadDescription</key>
      <string>Gandi.net email account 3 configuration</string>
      <key>EmailAccountDescription</key>
      <string>Gandi 3</string>
      <key>EmailAccountName</key>
      <string>Gandi Account 3</string>
      <key>EmailAccountType</key>
      <string>EmailTypeIMAP</string>
      <key>EmailAddress</key>
      <string>${emailConfig.gandi3}</string>
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
      <key>OutgoingPasswordSameAsIncomingPassword</key>
      <true/>
      <key>PreventMove</key>
      <false/>
      <key>PreventAppSheet</key>
      <false/>
      <key>SMIMEEnabled</key>
      <false/>
    </dict>

    <!-- Gandi.net Account 4 (Password Authentication) -->
    <dict>
      <key>PayloadType</key>
      <string>com.apple.mail.managed</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
      <key>PayloadIdentifier</key>
      <string>${profileUUID}.gandi4</string>
      <key>PayloadUUID</key>
      <string>${profileUUID}-gandi4-uuid</string>
      <key>PayloadDisplayName</key>
      <string>Gandi Account 4</string>
      <key>PayloadDescription</key>
      <string>Gandi.net email account 4 configuration</string>
      <key>EmailAccountDescription</key>
      <string>Gandi 4</string>
      <key>EmailAccountName</key>
      <string>Gandi Account 4</string>
      <key>EmailAccountType</key>
      <string>EmailTypeIMAP</string>
      <key>EmailAddress</key>
      <string>${emailConfig.gandi4}</string>
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
      <key>OutgoingPasswordSameAsIncomingPassword</key>
      <true/>
      <key>PreventMove</key>
      <false/>
      <key>PreventAppSheet</key>
      <false/>
      <key>SMIMEEnabled</key>
      <false/>
    </dict>
  </array>

  <!-- Profile Metadata -->
  <key>PayloadDisplayName</key>
  <string>FX Email Accounts</string>
  <key>PayloadDescription</key>
  <string>Email account configuration for macOS Mail.app (1 Gmail + 4 Gandi.net accounts)</string>
  <key>PayloadIdentifier</key>
  <string>${profileUUID}</string>
  <key>PayloadType</key>
  <string>Configuration</string>
  <key>PayloadUUID</key>
  <string>${profileUUID}-root</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
  <key>PayloadRemovalDisallowed</key>
  <false/>
</dict>
</plist>
MOBILECONFIG_EOF

      # Install profile silently (adds to System Preferences > Profiles)
      # Note: User will still need to manually approve installation via System Preferences
      # and enter passwords/OAuth credentials when opening Mail.app
      echo "✓ Email configuration profile generated: $MAIL_CONFIG"
      echo "📝 Manual step: Open System Preferences > Profiles to install email accounts"
      echo "📝 Then open Mail.app and enter passwords for each account"
      echo ""
    '';
  };
}
