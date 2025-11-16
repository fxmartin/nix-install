# ABOUTME: Dropbox cloud storage and file synchronization configuration guide
# ABOUTME: Post-installation setup, account sign-in, auto-update disable, sync configuration, and file sharing

# Dropbox

**Status**: Installed via Homebrew cask `dropbox` (Story 02.4-004)

**Purpose**: Cloud storage and file synchronization service. Sync files across devices, share files via links, collaborate on documents, and backup important data to the cloud. Integrates with macOS Finder for seamless file management.

---

## First Launch and Account Sign-In

**Prerequisites**:
- Dropbox account (free or paid)
- Internet connection

**Steps**:
1. Launch Dropbox from Spotlight (`Cmd+Space`, type "Dropbox") or from `/Applications/Dropbox.app`
2. Welcome screen appears with sign-in options:
   - **Sign In**: Use existing Dropbox account
   - **Sign Up**: Create new account (opens web browser)
3. **Sign in with existing account**:
   - Enter email address
   - Enter password
   - Complete two-factor authentication if enabled (recommended for security)
4. **Setup wizard** appears after sign-in:
   - **Plan selection**: Free (2GB), Plus (2TB), Family (2TB shared), Professional (3TB)
   - **Dropbox folder location**: Default is `~/Dropbox` (recommended, or choose custom location)
   - **File sync preferences**: Choose which folders to sync initially
5. Click **Get Started** or **Continue**
6. Menubar icon appears (Dropbox logo)
7. Initial sync begins automatically (may take time depending on existing files)

**First Launch Notes**:
- Free accounts: 2GB storage limit
- `~/Dropbox` folder created automatically
- Dropbox appears in Finder sidebar for quick access
- Menubar icon shows sync status (rotating arrows = syncing, blue checkmark = synced)

---

## Auto-Update Configuration (REQUIRED)

⚠️ **CRITICAL**: Auto-updates must be disabled to maintain declarative configuration control via `rebuild` command.

**Steps to Disable Auto-Update**:
1. Click **Dropbox menubar icon** (top-right of screen)
2. Click **Profile icon** (top-right of Dropbox menu) → **Preferences** (or press `Cmd+,`)
3. Navigate to **Account** tab
4. Scroll to **Updates** section
5. **Uncheck** "Automatically download and install updates"
6. Close Preferences window
7. **Verification** (recommended):
   - Reopen Preferences → Account tab
   - Confirm "Automatically download and install updates" remains **unchecked**

**Why This Matters**:
- All app updates controlled via `rebuild` or `update` commands only
- Prevents unexpected application changes between rebuilds
- Maintains system reproducibility and predictability

---

## Dropbox Folder and Sync

### Dropbox Folder Location

**Default Location**: `~/Dropbox` (recommended)

**Accessible via**:
- Finder sidebar (Dropbox icon)
- `cd ~/Dropbox` in Terminal
- Spotlight search ("Dropbox folder")

### File Sync Behavior

**Automatic Sync**:
- Files added to `~/Dropbox` automatically sync to cloud
- Changes synced in real-time (when online)
- Deletions synced (file deleted locally = deleted in cloud)
- Conflicts handled gracefully (creates "conflicted copy")

**Sync Status Icons** (Finder badges):
- **Blue checkmark**: File synced successfully
- **Rotating arrows**: File currently syncing
- **Red X**: Sync error (check Dropbox menubar for details)
- **Gray minus**: Folder not synced locally (Selective Sync)

### Selective Sync

**Purpose**: Choose which folders sync locally to save disk space

**Steps to Configure**:
1. Click Dropbox menubar icon → Preferences
2. Navigate to **Sync** tab
3. Click **Selective Sync** button
4. Folder list appears with checkboxes:
   - **Checked**: Folder synced locally (takes disk space)
   - **Unchecked**: Folder cloud-only (accessible via web, no local disk usage)
5. Select/deselect folders as needed
6. Click **Update**
7. Unchecked folders removed from `~/Dropbox` (still in cloud)
8. Re-checking downloads folder again

**Use Cases**:
- MacBook Air (limited storage): Uncheck large folders like "Videos" or "Photos"
- MacBook Pro (ample storage): Sync everything locally
- Temporary storage savings: Uncheck folders until needed

---

## File Sharing

### Share via Link

**Steps**:
1. Right-click file in `~/Dropbox` folder
2. Select **Share...** from context menu
3. Choose **Copy Link** option
4. Link copied to clipboard (format: `https://www.dropbox.com/s/...`)
5. Paste link in email, Slack, Messages, etc.
6. Recipients can access file without Dropbox account

**Link Options**:
- **Anyone with link**: Public access (no Dropbox account needed)
- **Link expiration**: Set expiration date (paid plans)
- **Password protection**: Require password for access (paid plans)

### Shared Folders

**Purpose**: Collaborate on folders with other Dropbox users

**Steps**:
1. Right-click folder in `~/Dropbox`
2. Select **Share...** → **Invite to folder**
3. Enter email addresses of collaborators
4. Choose permissions:
   - **Can edit**: Full read/write access
   - **Can view**: Read-only access
5. Send invitation
6. Collaborators receive email invitation
7. Shared folder appears in their Dropbox after accepting

---

## Menubar Icon and Features

### Menubar Icon Sync Status

- **Blue Dropbox logo with checkmark**: Everything synced, up to date
- **Rotating arrows**: Currently syncing files
- **Pause icon**: Sync paused (can resume manually)
- **X or warning**: Sync error (click for details)

### Menubar Menu Options

Click Dropbox menubar icon to access:
- **Recent files**: Quick access to recently modified files
- **Notifications**: Sync activity and shared file updates
- **Pause sync**: Temporarily pause syncing (useful on metered connections)
- **Preferences**: Open Dropbox settings (`Cmd+,`)
- **Help**: Documentation and support
- **Quit Dropbox**: Stop Dropbox daemon (sync stops, menubar icon removed)

---

## Account Plans

### Free Plan (2GB)
- **Storage**: 2GB
- **Cost**: Free
- **Features**: Basic sync, file sharing, mobile access
- **Limitations**: No advanced sharing features, no extended version history

### Plus Plan (2TB)
- **Storage**: 2TB (2,000GB)
- **Cost**: $11.99/month or $119.88/year
- **Features**: Advanced sharing, 30-day file recovery, priority support

### Family Plan (2TB shared)
- **Storage**: 2TB shared among up to 6 users
- **Cost**: $19.99/month or $199.99/year
- **Features**: Plus features + family room sharing

### Professional Plan (3TB)
- **Storage**: 3TB
- **Cost**: $19.99/month or $199.99/year
- **Features**: Advanced admin controls, eSignature requests, full-text search

**Plan Management**:
- Upgrade: Dropbox menubar → Preferences → Account → Upgrade
- Downgrade: Manage via https://www.dropbox.com/account/plan

---

## Configuration Options

### Preferences → General

- **Start Dropbox on system startup**: Checked (recommended for automatic sync)
- **Enable desktop notifications**: Toggle based on preference
- **Language**: System default or custom

### Preferences → Sync

- **Selective Sync**: Choose folders to sync locally
- **LAN Sync**: Sync files from other computers on local network (faster than cloud download)
- **Smart Sync** (paid plans): Automatically free up space by making files online-only

### Preferences → Account

- **Account info**: Email, plan, storage usage
- **Updates**: Disable auto-updates (REQUIRED - see Auto-Update Configuration section)
- **Unlink this Dropbox**: Sign out and stop syncing

### Preferences → Bandwidth

- **Upload rate**: Limit bandwidth (useful on slow connections)
- **Download rate**: Limit bandwidth
- **Enable LAN sync**: Sync from nearby devices (faster)

---

## Testing Checklist

- [ ] Dropbox launches successfully from Spotlight or Applications
- [ ] Account sign-in completes (email + password + 2FA if enabled)
- [ ] `~/Dropbox` folder created in home directory
- [ ] Dropbox appears in Finder sidebar with icon
- [ ] Menubar icon appears after sign-in
- [ ] Auto-update disabled (Preferences → Account → Updates unchecked)
- [ ] Auto-update setting persists after restarting Dropbox
- [ ] Test file sync: Create file in `~/Dropbox`, verify in web interface
- [ ] Test file download: Create file in web interface, verify in `~/Dropbox`
- [ ] Selective Sync accessible (Preferences → Sync → Selective Sync)
- [ ] File sharing works (Right-click file → Share → Copy Link)
- [ ] Menubar icon shows sync status correctly (rotating arrows → checkmark)
- [ ] Preferences accessible via menubar (`Cmd+,`)
- [ ] Can pause/resume sync via menubar

---

## Use Cases

**Cross-Device File Sync**:
- Work on document on MacBook Pro, continue on MacBook Air
- Automatic sync ensures latest version available everywhere

**Backup Critical Files**:
- Store important documents in `~/Dropbox/Documents`
- Cloud backup protects against hardware failure

**Photo/Video Sharing**:
- Share vacation photos via link (no need for recipient to have Dropbox)
- Large file transfer without email attachment limits

**Collaboration**:
- Share folder with team members
- Everyone sees real-time updates
- No email attachments or version confusion

**Selective Sync for Storage Management**:
- MacBook Air (256GB): Sync only "Work" and "Documents" folders
- MacBook Pro (2TB): Sync everything locally
- Access cloud-only files via web when needed

---

## Troubleshooting

### Dropbox Not Syncing

**Symptoms**: Files not uploading, menubar icon stuck on syncing
**Solutions**:
1. Check internet connection
2. Click menubar icon → Check for sync errors
3. Restart Dropbox: Menubar → Quit Dropbox, then relaunch
4. Verify account storage not full (Preferences → Account → Storage usage)
5. Check Selective Sync settings (folder may be unchecked)

### Menubar Icon Missing

**Symptoms**: Dropbox running but no menubar icon
**Solutions**:
1. Quit Dropbox (Activity Monitor → Dropbox → Quit)
2. Relaunch from Applications folder
3. Check System Settings → General → Login Items → Dropbox is allowed
4. If still missing, reinstall via `rebuild` command

### "Can't Sync" Error

**Symptoms**: Red X on menubar icon, "Can't sync" message
**Solutions**:
1. Click menubar icon → View error details
2. Common causes:
   - Invalid filename characters (fix: rename file)
   - File path too long (fix: shorten folder names)
   - Permission issues (fix: check folder permissions in Finder)
3. Resolve specific error shown in Dropbox menu

### Conflicted Copies

**Symptoms**: Files named "file (Conflicted Copy).txt"
**Solutions**:
1. Occurs when same file edited on multiple devices simultaneously
2. Review both versions
3. Merge changes manually or keep one version
4. Delete unwanted conflicted copy
5. Prevent: Ensure files sync before editing on another device

---

## Keyboard Shortcuts

- `Cmd+,` - Open Preferences
- `Cmd+Q` - Quit Dropbox (stops sync)

---

## Related Documentation

- [Main Apps Index](../README.md)
- [Raycast](raycast.md) - Can integrate with Dropbox for file search
- [1Password](1password.md) - Can sync via Dropbox (legacy vaults)
- [Licensed Apps Guide](../../licensed-apps.md) - Account activation details

---

## Resources

- **Official Website**: https://www.dropbox.com
- **Help Center**: https://help.dropbox.com
- **System Requirements**: macOS 10.13 (High Sierra) or later
- **Support**: https://www.dropbox.com/support
- **Community Forum**: https://www.dropboxforum.com
- **Status Page**: https://status.dropbox.com (check for service outages)
