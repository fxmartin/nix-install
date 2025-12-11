# macOS VM Setup in Parallels Desktop

This guide documents the steps to set up a fresh macOS virtual machine in Parallels Desktop for testing the nix-install bootstrap script.

## Prerequisites

- Parallels Desktop installed on your Mac
- macOS Sonoma 14.0+ (or the version you want to test)
- At least 100GB free disk space
- 8GB+ RAM available for the VM

## Creating the VM

1. Open Parallels Desktop
2. Click **File > New** or the **+** button
3. Select **Install macOS from the Recovery Partition** or download a macOS installer
4. Allocate resources:
   - **CPU**: 4+ cores (recommended)
   - **RAM**: 8GB minimum, 16GB recommended for Power profile testing
   - **Disk**: 100GB minimum (120GB recommended for Power profile)

## macOS Setup Assistant Steps

Once the VM boots, you'll go through the macOS Setup Assistant. Here are the recommended choices for testing:

### Step 1: Language Selection

Select your preferred language (e.g., **English**) and click the arrow to continue.

![Language Selection](images/01-language.png)

### Step 2: Country or Region

Select your country (e.g., **Luxembourg**) and click **Continue**.

![Country Selection](images/02-country.png)

### Step 3: Migration Assistant

Select **"Set up as new"** (important for clean testing) and click **Continue**.

![Migration Assistant](images/03-migration.png)

### Step 4: Input Sources (Keyboard)

Select your keyboard layout (e.g., **Swiss French**, **ABC**) and click **Continue**.

![Keyboard Layout](images/04-keyboard.png)

### Step 5: Dictation

Select your dictation language (e.g., **English (United Kingdom)**) and click **Continue**.

![Dictation](images/05-dictation.png)

### Step 6: Accessibility

Click **Not Now** (can be configured later).

![Accessibility](images/06-accessibility.png)

### Step 7: Data & Privacy

Review the privacy information and click **Continue**.

![Data & Privacy](images/07-privacy.png)

### Step 8: Create Mac Account

Fill in your account details:
- **Full Name**: Enter the same username you'll use for the bootstrap (e.g., `fxmartin`)
- **Account Name**: This becomes your home folder name (e.g., `fxmartin`)
- **Password**: Set a password you'll remember
- **Hint**: Optional

Click **Continue**.

![Create Account](images/08-account.png)

### Step 9: Apple Account Sign-In

Click **"Set Up Later"** for faster testing. Or sign in if you need iCloud/App Store features.

![Apple Account](images/09-apple-account.png)

### Step 10: Terms and Conditions

Review the macOS Software Licence Agreement and click **Agree**.

![Terms and Conditions](images/10-terms.png)

### Step 11: Location Services

Uncheck "Enable Location Services on this Mac" (optional for testing) and click **Continue**.

![Location Services](images/11-location.png)

### Step 12: Time Zone

Select your time zone (e.g., **Central European Standard Time**) and closest city (e.g., **Luxembourg - Luxembourg**). Click **Continue**.

![Time Zone](images/12-timezone.png)

### Step 13: Analytics

Uncheck "Share Mac Analytics with Apple" (recommended for testing) and click **Continue**.

![Analytics](images/13-analytics.png)

### Step 14: Screen Time

Click **Set Up Later**.

![Screen Time](images/14-screentime.png)

### Step 15: Siri

Uncheck "Enable Ask Siri" (optional for testing) and click **Continue**.

![Siri](images/15-siri.png)

### Step 16: Choose Your Look (Appearance)

Select **Light**, **Auto**, or **Dark** and click **Continue**.

![Appearance](images/16-appearance.png)

### Step 17: Software Updates

Click **"Only Download Automatically"** (recommended - we control updates via nix-darwin).

![Software Updates](images/17-updates.png)

## Post-Setup: Ready for Bootstrap

After completing the Setup Assistant:

1. The macOS desktop will appear
2. Open **Terminal** (Cmd+Space, type "Terminal")
3. Run the bootstrap command:

```bash
curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/setup.sh | bash
```

## Tips for VM Testing

- **Snapshots**: Create a snapshot after fresh macOS setup, before running bootstrap. This allows quick reset for re-testing.
- **Shared Clipboard**: Enable in Parallels settings for easy copy-paste
- **Screen Resolution**: Adjust VM display settings if needed
- **Network**: Ensure VM has internet access (Shared Network mode works well)

## Timing Reference

Based on the screenshots (November 16, 2025):
- Setup start: ~18:34
- Setup complete: ~18:39
- **Total macOS setup time**: ~5 minutes

The bootstrap script will then take approximately 25-30 minutes to complete.

## Related Documentation

- [Bootstrap Testing Guide](./vm-testing-guide.md)
- [Troubleshooting](../troubleshooting.md)
- [Quick Start Guide](../quick-start.md)
