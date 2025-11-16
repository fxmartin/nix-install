# ABOUTME: Email configuration template for macOS Mail.app automation
# ABOUTME: Placeholders replaced during bootstrap to generate email-config.nix (Story 02.10-001)
# ABOUTME: Generated file (email-config.nix) is gitignored for privacy
{
  # Gmail Account (OAuth2 authentication)
  # User must sign in via browser after first Mail.app launch
  gmail = "@EMAIL_GMAIL@";

  # Gandi.net Accounts (IMAP/SMTP with password authentication)
  # User must enter passwords manually after first Mail.app launch
  # Server: mail.gandi.net (IMAP port 993 SSL, SMTP port 587 STARTTLS)
  gandi1 = "@EMAIL_GANDI1@";
  gandi2 = "@EMAIL_GANDI2@";
  gandi3 = "@EMAIL_GANDI3@";
  gandi4 = "@EMAIL_GANDI4@";
}
