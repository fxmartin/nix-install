# ABOUTME: System utilities post-installation configuration guide
# ABOUTME: Covers Onyx (system maintenance tool) and f.lux (screen color temperature adjuster)

## Onyx

### Onyx

**Status**: Installed via Homebrew cask `onyx` (Story 02.4-005)

**Purpose**: Free system maintenance and optimization utility for macOS. Provides access to hidden system settings, maintenance tasks, cache clearing, and system information not available in System Settings.

**First Launch**:
1. Launch Onyx from Spotlight (`Cmd+Space`, type "Onyx") or from `/Applications/OnyX.app`
2. **EULA Agreement** appears on first launch:
   - Read End User License Agreement
   - Click **Accept** to continue (required)
3. **Disk Verification** runs automatically:
   - Onyx verifies startup disk structure
   - This ensures system integrity before maintenance tasks
   - Takes 1-2 minutes on average
   - If errors found, Onyx recommends Disk Utility repairs
4. **Main Interface** appears after verification:
   - Tabs: Verification, Maintenance, Cleaning, Utilities, Automation, Info
   - Each tab provides different system maintenance tools
   - Hover over options to see descriptions

**No Account or License Required**:
- Onyx is **free** and open source
- No sign-in, no registration, no license key
- Updates managed by Homebrew (no in-app auto-update)

**Core Features**:

Onyx provides comprehensive system maintenance tools organized into tabs:

1. **Verification Tab**:
   - **Startup Disk**: Verify system volume integrity (File System Check)
   - **Disk Permissions**: Verify and repair disk permissions
   - **SMART Status**: Check hard drive health (S.M.A.R.T. diagnostics)
   - Recommended: Run verification before major maintenance tasks

2. **Maintenance Tab**:
   - **Scripts**: Run maintenance scripts (daily, weekly, monthly)
     - macOS includes automated maintenance scripts that may not run if Mac is off
     - Manually running these scripts ensures system optimization
   - **Repair Permissions**: Fix permission issues on system files
   - **Rebuild Services**: Refresh macOS services database
   - **Rebuild Launch Services**: Fix "Open With" menu and default app associations
   - **Rebuild Spotlight Index**: Force re-indexing for search improvements
   - **Rebuild Dyld Cache**: Refresh shared library cache for performance

3. **Cleaning Tab**:
   - **System Cache**: Clear system-level caches (requires admin password)
   - **User Cache**: Clear user-level caches (browser, app caches)
   - **Font Cache**: Clear font rendering cache (fixes font display issues)
   - **Logs**: Remove old system and application logs
   - **Downloads**: Clear Downloads folder
   - **Trash**: Empty Trash securely
   - **Temporary Items**: Remove temporary files
   - **Web Browser Cache**: Clear Safari, Chrome, Firefox caches

4. **Utilities Tab**:
   - **Finder**: Access hidden Finder settings
     - Show hidden files and folders
     - Display full file extensions
     - Customize Finder behavior
   - **Dock**: Configure hidden Dock settings
     - Animation speed
     - Auto-hide delay
     - App indicator lights
   - **Safari**: Configure hidden Safari settings
   - **Spotlight**: Customize Spotlight indexing and search
   - **Login Items**: Manage startup applications
   - **File Associations**: Fix default app for file types

5. **Automation Tab**:
   - Create and schedule automated maintenance tasks
   - Combine multiple maintenance operations
   - Run tasks at specific times or intervals
   - Save automation configurations

6. **Info Tab**:
   - **System Information**: Hardware specs, macOS version
   - **Disk Information**: Disk usage, volumes, partitions
   - **Memory**: RAM usage and statistics
   - **Network**: Network configuration and interfaces
   - **Logs**: View system logs and diagnostics

**Common Use Cases**:

**1. Routine System Maintenance** (Monthly recommended):
1. Launch Onyx
2. Click **Maintenance** tab
3. Check options:
   - ✓ Run maintenance scripts (all three: daily, weekly, monthly)
   - ✓ Rebuild Launch Services database
   - ✓ Repair disk permissions (if applicable for macOS version)
4. Click **Execute** button
5. Enter admin password when prompted
6. Wait for completion (1-3 minutes)
7. Restart Mac if prompted

**2. Cache Clearing** (When experiencing app slowness):
1. Launch Onyx
2. Click **Cleaning** tab
3. Select caches to clear:
   - ✓ System cache (safe to clear, will regenerate)
   - ✓ User cache (safe to clear, apps will rebuild)
   - ✓ Font cache (fixes font rendering issues)
   - ✓ DNS cache (fixes network resolution issues)
   - ⚠️ **Avoid**: Application data, Downloads (unless intentional)
4. Click **Execute** button
5. Enter admin password when prompted
6. Restart Mac to ensure clean state

**3. Fix "Open With" Menu Issues**:
1. Launch Onyx
2. Click **Maintenance** tab
3. Check **Rebuild Launch Services database**
4. Click **Execute** button
5. Restart Finder or Mac (fixes duplicate apps in Open With menu)

**4. Enable Hidden Finder Features**:
1. Launch Onyx
2. Click **Utilities** tab → **Finder** subtab
3. Configure hidden Finder settings:
   - Show hidden files and folders (dotfiles, system files)
   - Always show file extensions
   - Show full path in title bar
   - Disable .DS_Store file creation on network volumes
4. Click **Apply** button
5. Finder restarts with new settings

**5. Check Disk Health (SMART Status)**:
1. Launch Onyx
2. Click **Info** tab → **Disk** subtab
3. View **S.M.A.R.T. Status** indicator:
   - ✅ **Verified**: Disk is healthy
   - ⚠️ **Failing**: Disk issues detected, backup immediately and replace
4. View disk usage, read/write statistics, volume information

**Permission Notes** (Expected and Safe):

Onyx requires **admin password** for most maintenance tasks:
- System cache clearing
- Maintenance script execution
- Permission repairs
- System-level configuration changes

**Why admin access is needed**:
- Onyx modifies system-level files and settings
- Tasks like cache clearing access protected directories
- Permission repairs require elevated privileges

**This is expected and safe to approve**:
- Onyx is a trusted macOS utility (used since Mac OS X 10.2)
- Developed by Titanium Software (reputable Mac developer)
- Admin access is only requested for specific tasks (not background processes)
- You can review exactly which tasks run before clicking Execute

**Auto-Update Configuration**:

Onyx is a **free utility** with **no auto-update mechanism requiring disable**. Updates managed by Homebrew only.

**Update Process** (Controlled by Homebrew):
```bash
# To update Onyx (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Configuration Tips**:
- **Regular Maintenance**: Run monthly to keep system optimized
- **Before Major Updates**: Run verification and maintenance before macOS updates
- **After Problems**: Use when experiencing app crashes, slowness, or odd behavior
- **Cache Issues**: Clear font cache if fonts look wrong, DNS cache if network resolution fails
- **Backup First**: While Onyx is safe, always backup before major system changes

**Safety Notes**:
- ✅ **Safe to use**: Onyx has been trusted by Mac users since 2001
- ✅ **Non-destructive**: Most operations are reversible (caches regenerate)
- ⚠️ **Admin password required**: Expected for system maintenance tasks
- ⚠️ **Restart recommended**: Some changes require restart to take effect
- ⚠️ **Read descriptions**: Hover over options to understand what each task does

**Testing Checklist**:
- [ ] Onyx installed and launches
- [ ] EULA accepted on first launch
- [ ] Disk verification completes successfully
- [ ] Main interface appears with 6 tabs (Verification, Maintenance, Cleaning, Utilities, Automation, Info)
- [ ] Can navigate between tabs
- [ ] Verification tab shows startup disk and SMART status
- [ ] Maintenance tab shows scripts and rebuild options
- [ ] Cleaning tab shows cache and log clearing options
- [ ] Utilities tab shows Finder, Dock, Safari settings
- [ ] Info tab shows system information
- [ ] Admin password prompt appears when executing tasks (expected)
- [ ] Maintenance scripts run successfully (test with "Run maintenance scripts")
- [ ] System information displays correctly (Info tab)

**Documentation**:
- Official Website: https://titanium-software.fr/en/onyx.html
- User Manual: https://titanium-software.fr/en/onyx_userguide.html
- FAQ: https://titanium-software.fr/en/onyx_faq.html

---


## f.lux

### f.lux

**Status**: Installed via Homebrew cask `flux-app` (Story 02.4-005)

**Purpose**: Free utility that automatically adjusts your display's color temperature based on time of day. Reduces blue light exposure at night, making the screen warmer in the evening and cooler during the day to reduce eye strain and improve sleep quality.

**First Launch**:
1. Launch f.lux from Spotlight (`Cmd+Space`, type "flux") or from `/Applications/Flux.app`
2. **Location Setup** appears on first launch:
   - f.lux needs your location to calculate sunrise/sunset times
   - **Recommended**: Click "Locate Me" (uses macOS Location Services)
   - **OR**: Type your city name (e.g., "London", "New York", "Tokyo")
   - **OR**: Enter coordinates manually (latitude/longitude)
   - Click **Continue**
3. **Menubar Icon** appears (🌙 or ☀️ symbol depending on time of day):
   - f.lux runs in the menubar (no main window)
   - Icon changes color throughout the day (warmer at night, cooler during day)
   - Click menubar icon to access preferences and controls
4. **Color Temperature Adjusts Automatically**:
   - f.lux begins adjusting display immediately based on local time
   - Transition is gradual over ~60 minutes at sunset/sunrise
   - Screen becomes warmer (more orange/yellow) in the evening

**No Account or License Required**:
- f.lux is **free** and open source
- No sign-in, no registration, no license key
- Updates managed by Homebrew (no in-app auto-update to disable)

**Location Services Permission** (Expected and Safe):

f.lux may request **Location Services** permission to automatically detect your location:

**Why location is needed**:
- Calculate local sunrise and sunset times
- Automatically adjust color temperature based on time of day at your location
- Eliminates need for manual schedule configuration

**Granting Location Permission** (Optional but Recommended):
1. When f.lux requests location, click **OK** to allow
2. **OR** later: System Settings → Privacy & Security → Location Services
3. Scroll to **f.lux** → Check the box to enable
4. f.lux will now auto-detect your location

**If you don't grant location permission**:
- You can still use f.lux by entering location manually
- Click menubar icon → **Preferences** → Change Location → Enter city or coordinates

**Accessibility Permission** (May Be Requested):

f.lux may request **Accessibility** permission for advanced color adjustment:

**Why accessibility is needed**:
- Some macOS versions require this for low-level display control
- Allows f.lux to adjust color temperature across all displays
- Enables smooth color transitions

**Granting Accessibility Permission** (Safe to Approve):
1. When f.lux requests accessibility, click **Open System Settings**
2. System Settings → Privacy & Security → Accessibility
3. Click the **lock icon** 🔒 and authenticate
4. Find **f.lux** in the list → Check the box to enable
5. Close System Settings
6. f.lux will now have full display control

**Core Features**:

f.lux provides automatic display color temperature management:

1. **Automatic Color Adjustment**:
   - **Daytime** (after sunrise): Cooler colors (6500K - bluish/white light)
   - **Sunset** (~1 hour transition): Gradually warmer colors
   - **Nighttime** (after sunset): Warm colors (2700K-3400K - orange/yellow light)
   - **Sunrise** (~1 hour transition): Gradually cooler colors
   - Smooth transitions prevent jarring color changes

2. **Color Temperature Control**:
   - **Daytime**: Default 6500K (matches sunlight)
   - **Nighttime**: Adjustable 2700K-4200K (warmer = less blue light)
   - **Custom**: Set your preferred warmth levels
   - Menubar icon → Preferences → Adjust sliders

3. **Manual Override**:
   - **Disable for 1 hour**: Menubar icon → Disable for one hour
   - **Disable until sunrise**: Menubar icon → Disable until sunrise
   - Useful for color-critical work (photo editing, design)
   - Re-enables automatically after specified time

4. **Movie Mode**:
   - Temporarily disable color adjustment for color-accurate viewing
   - Menubar icon → Movie mode (2.5 hours)
   - Automatically re-enables after timeout

5. **Darkroom Mode**:
   - Extreme red/orange tint for nighttime use
   - Menubar icon → Preferences → Options → Darkroom
   - Minimal blue light for astronomy, photography, late night work

6. **Custom Schedule**:
   - Override automatic sunrise/sunset detection
   - Set custom "wake time" and "bedtime"
   - Menubar icon → Preferences → Custom Schedule
   - Useful for night shift workers or custom sleep schedules

**Basic Usage**:

**Normal Daily Use** (No Interaction Needed):
1. f.lux runs automatically in the background
2. Color temperature adjusts throughout the day
3. No user interaction required
4. Menubar icon shows current color temperature status

**Temporarily Disable** (For Color Work):
1. Click f.lux menubar icon (🌙 or ☀️)
2. Choose:
   - **Disable for one hour** (temporary disable)
   - **Disable until sunrise** (overnight disable)
   - **Movie mode** (2.5 hour disable for movies)
3. f.lux pauses color adjustment
4. Re-enables automatically after chosen duration

**Adjust Nighttime Warmth** (Make Screen Warmer/Cooler at Night):
1. Click f.lux menubar icon → **Preferences**
2. Find **Color Temperature** section
3. Drag **Sunset** slider:
   - Left (2700K): Very warm, strong blue light reduction (recommended for better sleep)
   - Right (4200K): Less warm, more natural colors (easier to read, less sleep benefit)
4. f.lux applies changes immediately
5. Test at night to find your preferred warmth

**Change Location** (After Moving or Traveling):
1. Click f.lux menubar icon → **Preferences**
2. Click **Change Location** button
3. Options:
   - **Locate Me**: Auto-detect via Location Services (recommended)
   - **Search**: Type city name
   - **Coordinates**: Enter latitude/longitude manually
4. f.lux recalculates sunrise/sunset for new location

**Set Custom Schedule** (For Non-Standard Sleep Schedule):
1. Click f.lux menubar icon → **Preferences**
2. Find **Schedule** section
3. Choose **Custom Schedule** (instead of automatic sunrise/sunset)
4. Set your **wake time** (when screen should be cooler)
5. Set your **bedtime** (when screen should be warmer)
6. f.lux adjusts based on your custom schedule instead of sun times

**Configuration Tips**:

**Recommended Settings for Most Users**:
- **Daytime**: 6500K (default, matches sunlight)
- **Nighttime**: 2700K-3400K (warmer = better sleep, cooler = easier to read)
- **Transition Speed**: 60 minutes (default, gradual change)
- **Location**: Auto-detect via Location Services (most accurate)
- **Schedule**: Automatic (follows local sunrise/sunset)

**Settings for Late Night Workers**:
- **Nighttime**: 2700K (strong blue light reduction)
- **Enable Darkroom Mode**: Extreme red tint for very late work
- **Custom Schedule**: Set wake/bedtime to match your actual sleep schedule

**Settings for Designers/Photographers**:
- **Disable during color work**: Menubar icon → Disable for one hour
- **OR**: Use Movie mode for color-accurate viewing
- **Shortcut**: Add keyboard shortcut in Preferences → Hotkeys
- Re-enable f.lux when color work is complete

**Settings for Better Sleep**:
- **Nighttime**: 2700K (strongest recommended warmth)
- **Extended Day**: Preferences → Options → Extra hour of sleep (shifts schedule earlier)
- **Disable blue light 2-3 hours before bed** for best effect
- Combine with Night Shift mode on iPhone/iPad for consistency

**Auto-Update Configuration**:

f.lux is a **free utility** with **no auto-update mechanism requiring disable**. Updates managed by Homebrew only.

**Update Process** (Controlled by Homebrew):
```bash
# To update f.lux (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**How It Works** (Technical Background):

f.lux adjusts color temperature by:
1. **Detecting Your Location**: Uses Location Services or manual entry
2. **Calculating Sun Position**: Determines sunrise/sunset times for your location
3. **Color Temperature Curve**: Creates smooth transition curve throughout day
4. **Display Adjustment**: Applies color filter to reduce blue light at night
5. **Health Benefits**: Less blue light exposure at night improves melatonin production and sleep quality

**Research-Based Recommendations**:
- **Blue Light and Sleep**: Studies show blue light suppresses melatonin (sleep hormone)
- **Recommended Warmth**: 2700K-3400K for 2-3 hours before sleep
- **Transition Time**: 60-minute gradual change is less jarring than instant shift
- **Combine with Habits**: Also reduce screen time 1 hour before bed for best sleep

**Testing Checklist**:
- [ ] f.lux installed and launches
- [ ] Menubar icon appears (🌙 or ☀️ symbol)
- [ ] Location setup completed (auto-detect or manual entry)
- [ ] Color temperature adjusts based on time of day
- [ ] Screen is warmer (orange/yellow) in evening (if testing at night)
- [ ] Screen is cooler (white/blue) during day (if testing during day)
- [ ] Can open Preferences via menubar icon
- [ ] Can disable for 1 hour (menubar icon → Disable for one hour)
- [ ] Can adjust nighttime warmth (Preferences → Sunset slider)
- [ ] Can change location (Preferences → Change Location)
- [ ] Can enable Movie mode (menubar icon → Movie mode)
- [ ] Location Services permission granted (optional but recommended)
- [ ] Accessibility permission granted if requested (may be required for some macOS versions)

**Documentation**:
- Official Website: https://justgetflux.com/
- FAQ: https://justgetflux.com/faq.html
- Research: https://justgetflux.com/research.html
- Support Forum: https://forum.justgetflux.com/

---


## Related Documentation

- [Main Apps Index](../README.md) - Overview of all application documentation
- [Raycast Configuration](./raycast.md) - Productivity launcher setup
- [1Password Configuration](./1password.md) - Password manager setup
- [File Utilities Configuration](./file-utilities.md) - Calibre, Kindle, Keka, Marked 2
