# ABOUTME: Guide for setting up a fresh macOS VM in Parallels Desktop for bootstrap testing
# ABOUTME: Documents the macOS Setup Assistant steps with recommended choices

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
- Select your preferred language (e.g., **English**)
- Click the arrow to continue

### Step 2: Country or Region
- Select your country (e.g., **Luxembourg**)
- Click **Continue**

### Step 3: Migration Assistant
- Select **"Set up as new"** (important for clean testing)
- Click **Continue**

### Step 4: Input Sources (Keyboard)
- Select your keyboard layout (e.g., **Swiss French**, **ABC**)
- Click **Continue**

### Step 5: Dictation
- Select your dictation language (e.g., **English (United Kingdom)**)
- Click **Continue**

### Step 6: Accessibility
- Click **Not Now** (can be configured later)

### Step 7: Data & Privacy
- Review the privacy information
- Click **Continue**

### Step 8: Create Mac Account
- **Full Name**: Enter the same username you'll use for the bootstrap (e.g., `fxmartin`)
- **Account Name**: This becomes your home folder name (e.g., `fxmartin`)
- **Password**: Set a password you'll remember
- **Hint**: Optional
- Check/uncheck "Allow computer account password to be reset with your Apple Account"
- Click **Continue**

### Step 9: Apple Account Sign-In
- Click **"Set Up Later"** for faster testing
- Or sign in if you need iCloud/App Store features

### Step 10: Terms and Conditions
- Review the macOS Software Licence Agreement
- Click **Agree**

### Step 11: Location Services
- Uncheck "Enable Location Services on this Mac" (optional for testing)
- Click **Continue**

### Step 12: Time Zone
- Select your time zone (e.g., **Central European Standard Time**)
- Select closest city (e.g., **Luxembourg - Luxembourg**)
- Click **Continue**

### Step 13: Analytics
- Uncheck "Share Mac Analytics with Apple" (recommended for testing)
- Click **Continue**

### Step 14: Screen Time
- Click **Set Up Later**

### Step 15: Siri
- Uncheck "Enable Ask Siri" (optional for testing)
- Click **Continue**

### Step 16: Choose Your Look (Appearance)
- Select **Light**, **Auto**, or **Dark**
- Click **Continue**

### Step 17: Software Updates
- Click **"Only Download Automatically"** (recommended - we control updates via nix-darwin)
- Or click **Continue** for automatic updates

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
