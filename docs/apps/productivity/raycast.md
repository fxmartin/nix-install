# ABOUTME: Raycast post-installation configuration guide
# ABOUTME: Covers first launch, hotkey setup, auto-update disable, core features, and usage examples

### Raycast

**Status**: Installed via Homebrew cask `raycast` (Story 02.4-001)

**Purpose**: Application launcher and productivity tool. Modern alternative to Spotlight/Alfred with powerful features like clipboard history, window management, snippets, and extensions.

**First Launch**:
1. Launch Raycast from Spotlight (`Cmd+Space`, type "Raycast") or from `/Applications/Raycast.app`
2. Welcome screen appears with onboarding wizard
3. Follow onboarding steps:
   - **Hotkey Setup** (REQUIRED): Choose your preferred launch hotkey
     - **Recommended**: `Option+Space` (leaves Cmd+Space for Spotlight)
     - **Alternative**: `Cmd+Space` (replaces Spotlight as default launcher)
     - Can be changed later in Preferences → General → Raycast Hotkey
   - Sign in with Raycast account (optional - enables sync across devices)
   - Complete onboarding tour (learn about commands, extensions, etc.)

**Hotkey Configuration**:

The hotkey is the primary way to invoke Raycast. It must be configured on first launch.

**Recommended Setup**:
- **Raycast**: `Option+Space` (or `Cmd+Space` if replacing Spotlight entirely)
- **Spotlight** (if keeping): `Cmd+Space` (or disable if using Raycast as full replacement)

**To Change Hotkey Later**:
1. Open Raycast (use current hotkey or launch from Applications)
2. Open Preferences: Type "Preferences" in Raycast search → **General**
3. Click on **Raycast Hotkey** field
4. Press your desired key combination
5. Click away or press Enter to save

**Note**: If you choose `Cmd+Space` for Raycast, macOS may warn you that Spotlight uses that key. You can:
- Replace Spotlight hotkey (System Settings → Keyboard → Keyboard Shortcuts → Spotlight → Change hotkey)
- Keep both (macOS will prioritize Raycast if set up first)

**Auto-Update Configuration** (REQUIRED):

Raycast updates must be disabled to maintain declarative configuration control.

**Steps to Disable Auto-Update**:
1. Launch Raycast (press your configured hotkey)
2. Search for "Preferences" and press Enter
3. Navigate to **Advanced** tab
4. Find **Updates** section
5. **Uncheck** "Automatically download and install updates"
6. Close Preferences

**Verification**:
- Open Raycast Preferences → Advanced
- Confirm "Automatically download and install updates" is **unchecked**
- Updates will now only occur via `darwin-rebuild switch` (controlled by Homebrew)

**Update Process** (Controlled by Homebrew):
```bash
# To update Raycast (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Core Features**:

Raycast is a powerful productivity tool with many built-in features:

1. **Application Launcher**:
   - Press hotkey → Type app name → Press Enter
   - Faster than Spotlight with better search
   - Recently used apps appear first

2. **File Search**:
   - Type filename or press `Space` to search by name
   - Integrates with macOS Spotlight index
   - Faster than Finder search

3. **Clipboard History**:
   - Search command: "Clipboard History"
   - View and paste from clipboard history
   - Searchable text snippets
   - Can pin frequently used items

4. **Window Management**:
   - Search command: "Window Management"
   - Quickly resize/move windows (left half, right half, maximize, etc.)
   - Keyboard-driven window tiling

5. **Snippets**:
   - Create text snippets with shortcuts
   - Auto-expand when you type abbreviation
   - Great for email templates, code snippets, etc.

6. **Extensions**:
   - Browse and install extensions: Search "Store" in Raycast
   - Extensions available for GitHub, Slack, Jira, Notion, etc.
   - User can add manually after installation (optional)

7. **Calculator**:
   - Type math expression directly in Raycast
   - Instant calculation results
   - Copy result to clipboard

8. **System Commands**:
   - Search "Quit All Applications", "Empty Trash", "Sleep", etc.
   - Quick access to common system tasks

**Basic Usage Examples**:
- Launch app: Press hotkey → Type "Brave" → Enter
- Search file: Press hotkey → Type filename → Enter
- View clipboard: Press hotkey → Type "Clipboard History" → Enter
- Window management: Press hotkey → Type "Left Half" → Enter (resizes active window)
- Calculator: Press hotkey → Type "2+2" → See result

**Configuration Tips**:
- Customize appearance: Preferences → Appearance (Light/Dark theme)
- Add favorite commands: Star commands to pin them to the top
- Keyboard shortcuts: Most actions have keyboard shortcuts (shown on right side)
- Organize extensions: Preferences → Extensions (enable/disable as needed)

**No License Required**:
- Raycast is **free** for personal use (no license key needed)
- Optional Raycast Pro subscription available (sync, advanced features)
- Pro features are optional - base functionality is fully free

**Setting as Default Launcher** (Optional):
- If using `Cmd+Space` hotkey for Raycast, it becomes your default launcher
- Spotlight can still be accessed via:
  - Menu Bar → Spotlight icon
  - System Settings → Keyboard → Keyboard Shortcuts → Spotlight → Set different hotkey
  - Or keep Spotlight disabled if Raycast is preferred

**Testing Checklist**:
- [ ] Raycast installed and launches
- [ ] Hotkey configured (Option+Space or Cmd+Space)
- [ ] Can launch applications via Raycast
- [ ] Can search files via Raycast
- [ ] Auto-update disabled (Preferences → Advanced)
- [ ] Extensions available (Store accessible)
- [ ] Clipboard history works
- [ ] Window management commands available

**Documentation**:
- Official Docs: https://manual.raycast.com/
- Extension Store: https://www.raycast.com/store
- Keyboard Shortcuts Guide: https://manual.raycast.com/hotkeys

---

## Related Documentation

- [Main Apps Index](../README.md) - Overview of all application documentation
- [1Password Configuration](./1password.md) - Password manager setup
- [File Utilities Configuration](./file-utilities.md) - Calibre, Kindle, Keka, Marked 2
- [System Utilities Configuration](./system-utilities.md) - Onyx, f.lux
