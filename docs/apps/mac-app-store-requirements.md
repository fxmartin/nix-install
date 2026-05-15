# ABOUTME: Mac App Store prerequisites and requirements for nix-darwin installation
# ABOUTME: Documents critical setup steps needed before darwin-rebuild can install mas apps

# Mac App Store Requirements

## ⚠️ IMPORTANT: Mac App Store Requirements

### Requirement 1: Sign-In Required

**Before running darwin-rebuild**, you MUST sign in to the Mac App Store:

1. Open **App Store** app
2. Click **Sign In** at the bottom of the sidebar
3. Enter your Apple ID credentials
4. Complete authentication

**Why this is required:**
- Some apps (like Perplexity) are installed via Mac App Store using `mas` (Mac App Store CLI)
- `mas` cannot install apps unless you are signed into the App Store
- darwin-rebuild will fail if trying to install mas apps without authentication

**Verification:**
```bash
# Check if signed in to App Store
mas account
# Should show your Apple ID email

# If not signed in, you'll see:
# "Not signed in"
```

**If you see "Not signed in":**
- Sign in via App Store app GUI (cannot be done via CLI)
- Then verify: `mas account` shows your email

### Requirement 2: Fresh Machine First-Install (Issue #25, #26)

**⚠️ CRITICAL**: On **brand new Macs**, the Mac App Store requires **one manual GUI install** before `mas` CLI will work.

**Symptoms of Fresh Machine**:
- Bootstrap fails with: `Error Domain=PKInstallErrorDomain Code=201`
- Error message: `"The installation could not be started"`
- Homebrew bundle fails, blocking darwin-rebuild

**Solution - Manual First Install**:
1. Open **App Store** app
2. Search for any Mac App Store app (e.g., "Perplexity")
3. Click the **cloud download icon** (☁️↓) or **GET** button
4. Wait for installation to complete
5. **Then** re-run bootstrap or darwin-rebuild

**Why This Happens**:
- Fresh macOS needs to initialize App Store installation services
- First install must be manual to accept terms, set up cache, establish permissions
- After first manual install, `mas` CLI works normally
- This is a macOS limitation, not a nix-darwin bug

**Apps Requiring This Workaround**:
- Perplexity (6714467650)
- Kindle (302584613) - if added to masApps
- WhatsApp (if using mas instead of Homebrew)
- Any other Mac App Store apps in your masApps list

### Requirement 3: Terminal Full Disk Access for Homebrew Cleanup (Hotfix #18)

**⚠️ OPTIONAL**: When disabling or removing apps via darwin-rebuild, Homebrew may need **Full Disk Access** to completely uninstall applications.

**When This Is Needed**:
- You see a message: "Terminal needs Full Disk Access to complete uninstallation"
- You're removing/disabling apps via Homebrew configuration changes
- You want complete cleanup of removed applications

**Symptoms Without Permission**:
```
Warning: To complete uninstallation, grant Full Disk Access to your Terminal app
Settings → Privacy & Security → Full Disk Access
```

**What Happens Without Permission**:
- ✅ App is disabled in configuration
- ✅ darwin-rebuild completes successfully
- ✅ System works correctly
- ⚠️ Some app remnant files may remain in `/Applications/` or `~/Library/`

**Solution - Grant Full Disk Access (Optional)**:

1. **Open System Settings**:
   - Click **Apple menu** () → **System Settings**
   - Navigate to **Privacy & Security** → **Full Disk Access**

2. **Add Your Terminal App**:
   - Click the **lock icon** 🔒 and authenticate
   - Click the **+** button (plus sign)
   - Navigate to and select your terminal app:
     - **Ghostty**: `/Applications/Ghostty.app`
     - **Terminal**: `/Applications/Utilities/Terminal.app`
     - **iTerm2**: `/Applications/iTerm.app`
   - Click **Open**

3. **Enable the Toggle**:
   - Ensure the checkbox next to your terminal app is **ON** (blue)

4. **Re-run darwin-rebuild** (for complete cleanup):
   ```bash
   sudo darwin-rebuild switch --flake ~/nix-install#power
   # or
   sudo darwin-rebuild switch --flake ~/nix-install#standard
   ```

5. **Verify Cleanup**:
   - Homebrew should now complete uninstallation cleanly
   - No warning messages about Full Disk Access

**Why This Is Needed**:
- macOS privacy protection prevents apps from deleting certain files without explicit permission
- Homebrew needs access to `/Applications/`, `~/Library/`, and other system locations
- Full Disk Access allows Homebrew to completely remove disabled apps

**Is This Required?**:
- ✅ **NO** - Your system works without it
- ✅ **YES** - If you want perfectly clean uninstallation
- ✅ **Optional** - Grant permission only if you want complete cleanup

**Security Note**:
- Full Disk Access is a powerful permission
- Only grant to terminal apps you trust
- You can revoke it later in System Settings → Privacy & Security

**Example - VSCode Removal (Hotfix #18)**:
When VSCode was disabled due to Electron crashes:
1. darwin-rebuild disabled VSCode successfully ✅
2. Homebrew requested Full Disk Access for complete removal ⚠️
3. Granting access allowed Homebrew to clean up all VSCode files ✅
4. System works correctly with or without granting access ✅

---

## Related Documentation

- [Main Apps Index](README.md)
- [AI & LLM Tools](ai/ai-llm-tools.md)
- [Development Apps](dev/)
