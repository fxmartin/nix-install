# msmtp Email Configuration

## Overview

msmtp is a lightweight SMTP client used for sending email notifications from maintenance jobs. It's configured to use Gandi email with credentials stored securely in macOS Keychain.

**Feature**: 06.5 (Email Notification System)
**Epic**: Epic-06 (Maintenance & Monitoring)

## Post-Install Setup

After running `darwin-rebuild switch`, you must configure the Gandi email password in Keychain:

### 1. Run Keychain Setup Script

```bash
./scripts/setup-msmtp-keychain.sh
```

This interactive script will:
- Prompt for your Gandi email address
- Prompt for your Gandi email password (hidden input)
- Store the password securely in macOS Keychain
- Test password retrieval

### 2. Manual Keychain Setup (Alternative)

If you prefer to set up manually:

```bash
# Store password in Keychain
security add-generic-password \
    -a "your-email@your-domain.com" \
    -s "msmtp-gandi" \
    -w "your-password"
```

### 3. Test Email Sending

```bash
echo "Test email from nix-install" | msmtp your-email@your-domain.com
```

## Configuration Details

msmtp is configured via Home Manager in `home-manager/modules/msmtp.nix`:

- **SMTP Server**: mail.gandi.net
- **Port**: 587 (STARTTLS)
- **Authentication**: Username/password
- **Credential Storage**: macOS Keychain via `passwordeval`
- **Log File**: ~/.local/log/msmtp.log

## Keychain Entry Details

- **Account**: Your Gandi email address
- **Service Name**: `msmtp-gandi`
- **Where**: Login keychain

## Usage

### Automated Notifications

Email notifications are sent automatically when:
- GC or store optimization jobs fail (issues only, no spam on success)
- Weekly digest runs (Sunday 8 AM)

### Manual Commands

```bash
# Send weekly digest manually
weekly-digest

# Test notification script
./scripts/send-notification.sh your@email.com "Test Subject" "Test body"
```

## Troubleshooting

### Check msmtp Log

```bash
tail -50 ~/.local/log/msmtp.log
```

### Test Keychain Access

```bash
security find-generic-password -a "your-email@your-domain.com" -s "msmtp-gandi" -w
```

### Common Issues

**"authentication failed"**
- Verify password in Keychain is correct
- Re-run `./scripts/setup-msmtp-keychain.sh` to update

**"connection timed out"**
- Check network connectivity
- Verify Gandi SMTP settings (mail.gandi.net:587)

**"msmtp: command not found"**
- Run `darwin-rebuild switch` to install msmtp

## Security Notes

- No passwords are stored in configuration files
- Password is retrieved at runtime from macOS Keychain
- Only your user can access the Keychain entry
- msmtp logs may contain email addresses but not passwords

## Updating Password

If you change your Gandi email password:

```bash
# Update Keychain entry
security delete-generic-password -a "your-email@your-domain.com" -s "msmtp-gandi"
./scripts/setup-msmtp-keychain.sh
```

Or use the `-U` flag (update) which the script uses automatically.
