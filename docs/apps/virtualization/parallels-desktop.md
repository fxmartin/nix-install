# ABOUTME: Parallels Desktop post-installation configuration guide
# ABOUTME: Covers license activation, VM creation, performance optimization, and troubleshooting

# Parallels Desktop - Virtualization Software

**Status**: Installed via Homebrew cask `parallels` (Story 02.8-001)
**Profile**: **POWER ONLY** (MacBook Pro M3 Max) - NOT installed on Standard profile
**Purpose**: Professional virtualization software for running Windows, Linux, and other operating systems in virtual machines on macOS. Optimized for Apple Silicon (M1/M2/M3) with ARM64 virtual machines.

---

## Installation Method

- **Homebrew Cask**: `parallels`
- **Story**: 02.8-001
- **Profile**: **Power profile ONLY** (MacBook Pro M3 Max)
- **App Location**: `/Applications/Parallels Desktop.app`
- **Version**: Latest (managed by Homebrew)
- **Download Size**: ~500 MB

---

## Profile-Specific Installation (CRITICAL)

**⚠️ Parallels Desktop is installed ONLY on Power profile (MacBook Pro M3 Max)**

**Why Power Profile Only?**
Virtualization requires significant system resources (CPU cores, RAM, disk space) that are only available on high-end hardware.

**Power Profile** (MacBook Pro M3 Max):
- **Installed**: Parallels Desktop ✅
- **CPU**: 14-16 cores (M3 Max) - Can allocate 6-8 vCPUs to VMs
- **RAM**: 64GB - Can allocate 16-24GB to VMs comfortably
- **Disk**: 1TB+ SSD - Room for large VM images (60-100GB per VM)
- **Use Case**: Development, testing, Windows apps, multiple OS environments

**Standard Profile** (MacBook Air):
- **NOT Installed**: Parallels Desktop ❌
- **CPU**: 8 cores (M3/M2/M1) - Limited for VM workloads
- **RAM**: 8-16GB - Insufficient for running VMs alongside macOS
- **Disk**: 256-512GB SSD - Constrained storage for large VMs
- **Use Case**: Lightweight work, no virtualization needed
- **Alternative**: Use cloud VMs (AWS EC2, Azure VMs) or remote development when needed

**Verification**:
```bash
# Power profile: Verify Parallels installed
ls -la /Applications/Parallels\ Desktop.app
# Expected: App directory exists

# Standard profile: Verify Parallels NOT installed
ls -la /Applications/Parallels\ Desktop.app
# Expected: No such file or directory

# Check current profile (in nix-install directory)
darwin-rebuild switch --flake ~/nix-install#power   # Power profile
darwin-rebuild switch --flake ~/nix-install#standard # Standard profile
```

---

## ⚠️ Installation Prerequisites - Full Disk Access (CRITICAL)

**IMPORTANT**: Before installing Parallels Desktop via Homebrew, your terminal application MUST have Full Disk Access permissions.

**Discovered During**: VM testing (2025-01-16, Story 02.8-001)
**Impact**: Parallels Desktop installation via Homebrew may fail or behave unexpectedly without Full Disk Access
**Required For**: Power profile installations (MacBook Pro M3 Max)

### Grant Full Disk Access to Terminal

**Step 1: Open System Settings**
```bash
# Open System Settings → Privacy & Security
open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
```

**Step 2: Grant Full Disk Access**
1. System Settings → Privacy & Security → Full Disk Access
2. Click lock icon (🔒) → Authenticate with your password
3. Find your terminal app:
   - **Ghostty** (if installed via bootstrap)
   - **Terminal.app** (macOS default)
   - **iTerm2** (if using)
4. Toggle switch to **ON** (blue checkmark appears)
5. Click lock icon (🔒) again to prevent changes

**Step 3: Restart Terminal** (CRITICAL)
```bash
# Quit terminal completely
# Keyboard: Cmd+Q
# OR: Right-click dock icon → Quit
```

**Step 4: Relaunch Terminal**
- Open terminal again (Spotlight: `Cmd+Space`, type terminal name)
- Full Disk Access now active

**Step 5: Verify and Install**
```bash
# Now run bootstrap or darwin-rebuild
darwin-rebuild switch --flake ~/nix-install#power

# Parallels Desktop should install successfully
ls -la /Applications/Parallels\ Desktop.app
# Expected: App directory exists
```

### Why Full Disk Access is Required

Parallels Desktop needs to:
- Create and manage large VM disk images (60-100GB per VM)
- Access various system locations for VM configuration
- Interact with macOS system frameworks for virtualization
- Homebrew requires FDA to properly install Parallels to `/Applications/`

### Troubleshooting FDA Issues

**Symptom**: Parallels installation fails or doesn't launch properly

**Solution**:
1. Verify FDA is granted: System Settings → Privacy & Security → Full Disk Access → Terminal app is **ON**
2. Ensure terminal was restarted after granting FDA (quit and relaunch)
3. Try installation again: `darwin-rebuild switch --flake ~/nix-install#power`
4. If still failing: Revoke FDA → Reboot Mac → Grant FDA again → Restart terminal → Retry

**Symptom**: FDA toggle is grayed out (can't click)

**Solution**:
1. Click lock icon (🔒) at bottom of Privacy & Security window
2. Authenticate with admin password
3. Toggle should now be clickable
4. Grant FDA → Lock again

---

## License Requirement (CRITICAL)

**⚠️ Parallels Desktop is PAID SOFTWARE - NO free version for full features**

Parallels requires a license (trial, subscription, or perpetual). You cannot use Parallels indefinitely without paying.

**License Options**:

### 1. Free Trial (14 Days)
- **Duration**: 14 days with full features
- **Cost**: Free (no credit card required)
- **Features**: All Standard Edition features unlocked
- **Limitations**: Expires after 14 days, becomes read-only (can view VMs but cannot start/modify)
- **How to Activate**: Launch Parallels → Click "Try Free for 14 Days"
- **Best For**: Testing before purchase, short-term projects

### 2. Parallels Desktop Standard Edition (Subscription)
- **Price**: $99.99/year (annual billing)
- **Payment**: Credit card, PayPal, Apple Pay
- **Features**:
  - Run Windows, Linux, macOS VMs on Apple Silicon
  - Up to 8 vCPUs per VM
  - Up to 32 GB vRAM per VM
  - Coherence mode (run Windows apps like Mac apps)
  - Shared folders, clipboard, drag-and-drop
  - Snapshots (save VM states)
  - USB device pass-through
  - Automatic updates for 1 year
- **Best For**: Personal use, home users, students

### 3. Parallels Desktop Pro Edition (Subscription)
- **Price**: $119.99/year (annual billing)
- **Payment**: Credit card, PayPal, Apple Pay
- **Features**: All Standard features PLUS:
  - **Developer Tools**: Vagrant, Docker, Kubernetes integration
  - **Visual Studio Plugin**: Run Visual Studio in VM, debug on Mac
  - **Advanced Resources**: Up to 32 vCPUs and 128 GB vRAM per VM
  - **Network Simulation**: Test apps under different network conditions
  - **Support for Legacy OS**: Run older macOS, Windows, Linux versions
  - **Priority Support**: Faster response times
- **Best For**: Developers, IT professionals, advanced users

### 4. Parallels Desktop Business Edition
- **Price**: $119.99/year per user (volume licensing available)
- **Payment**: Purchase order, credit card, invoice
- **Features**: All Pro features PLUS:
  - **Centralized License Management**: IT admin controls licenses
  - **Mass Deployment Tools**: Deploy Parallels to multiple Macs
  - **Single Sign-On (SSO)**: Integrate with company identity systems
  - **Advanced Security**: BitLocker support, encryption controls
  - **Priority Support**: Dedicated support for business customers
- **Best For**: Companies, IT departments, enterprise deployments

### 5. Perpetual License (Legacy, Less Common)
- **Price**: $129.99 one-time (older versions only)
- **Payment**: One-time purchase (no recurring fees)
- **Features**: Lifetime license for purchased version
- **Limitations**:
  - No automatic updates (must purchase upgrades separately)
  - No cloud features (subscription-only)
  - Older versions may not support latest macOS or ARM VMs
- **Availability**: Parallels shifted to subscription model (perpetual licenses rare now)
- **Best For**: Users who prefer one-time purchases, no ongoing costs

**Recommendation**:
- **Trial First**: Start with 14-day trial to test compatibility and performance
- **Standard**: Best for most users ($99.99/year)
- **Pro**: If you need developer tools or >8 vCPUs per VM ($119.99/year)
- **Business**: If company needs centralized management and support

---

## First Launch and License Activation

### Activation Steps

**Option 1: Trial Activation** (14 Days Free)

1. **Launch Parallels Desktop**:
   - Spotlight: `Cmd+Space`, type "Parallels"
   - Or: `/Applications/Parallels Desktop.app`

2. **Welcome Screen**:
   - First launch shows welcome wizard
   - Click **"Try Free for 14 Days"** button

3. **Create Parallels Account** (Required):
   - Enter email address
   - Create password (8+ characters)
   - Click **"Create Account"**
   - Check email for verification link → Click to verify

4. **Sign In**:
   - Return to Parallels app
   - Sign in with email and password
   - Trial activates immediately

5. **Verify Trial**:
   - Parallels Desktop → Preferences → Account
   - Shows: "Trial - X days remaining"

**Option 2: License Key Activation** (Purchased License)

1. **Launch Parallels Desktop**:
   - Spotlight: `Cmd+Space`, type "Parallels"

2. **Welcome Screen**:
   - Click **"Activate"** or **"I have a license key"**

3. **Enter License Key**:
   - Format: `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX` (5 groups of 5 characters)
   - Copy from purchase confirmation email
   - Paste into license key field
   - Click **"Activate"**

4. **Sign In with Parallels Account**:
   - Enter email and password (create account if needed)
   - License binds to account

5. **Verify License**:
   - Parallels Desktop → Preferences → Account
   - Shows: "Standard Edition" or "Pro Edition" with expiration date

**Option 3: Parallels Account Activation** (Subscription)

1. **Launch Parallels Desktop**:
   - Spotlight: `Cmd+Space`, type "Parallels"

2. **Welcome Screen**:
   - Click **"Sign In"** button

3. **Sign In**:
   - Enter Parallels account email
   - Enter password
   - Click **"Sign In"**

4. **Auto-Activation**:
   - Subscription linked to account activates automatically
   - No license key needed

5. **Verify Subscription**:
   - Parallels Desktop → Preferences → Account
   - Shows: "Standard Edition" or "Pro Edition" with renewal date

**Verify License Status**:
```bash
# Check license activation
# Parallels Desktop → Preferences → Account
# Should show:
# - Trial: "Trial - X days remaining"
# - Subscription: "Standard Edition" or "Pro Edition" + renewal date
# - Perpetual: "Parallels Desktop [Version]" + license key (no expiration)
```

---

## Auto-Update Disable (CRITICAL)

**Why Disable Auto-Update**:
All application updates are controlled via `darwin-rebuild switch` (Homebrew version pinning) to ensure reproducible system state. Parallels must NOT auto-update.

**Steps to Disable**:

1. **Launch Parallels Desktop**:
   - Spotlight: `Cmd+Space`, type "Parallels"

2. **Open Preferences**:
   - Menu bar → **Parallels Desktop** → **Preferences** (or `Cmd+,`)

3. **Navigate to Advanced Tab**:
   - Click **Advanced** tab (left sidebar)
   - OR: Click **General** tab (location varies by version)

4. **Find Auto-Update Setting**:
   - Look for **"Check for updates automatically"** checkbox
   - OR: **"Download updates automatically"** section

5. **Uncheck Auto-Update**:
   - **Uncheck** "Check for updates automatically"
   - **Uncheck** "Download updates automatically" (if separate)
   - Close Preferences (settings save automatically)

6. **Verify Setting Persists**:
   - Quit Parallels Desktop (`Cmd+Q`)
   - Relaunch Parallels
   - Preferences → Advanced → Verify checkboxes remain unchecked

**Note**: Some Parallels versions may NOT have user-facing auto-update toggle (controlled by Homebrew only). If you cannot find the setting, updates are managed by Homebrew exclusively.

**Update Control**:
```bash
# Update Parallels (and all Homebrew apps) via darwin-rebuild
darwin-rebuild switch --flake ~/nix-install#power

# OR: Update Homebrew package versions first, then rebuild
cd ~/nix-install
nix flake update  # Updates flake.lock with latest Homebrew versions
darwin-rebuild switch --flake .#power
```

---

## Virtual Machine Creation

### Create Windows 11 VM (Most Common)

**Prerequisites**:
- Parallels Desktop activated (trial or license)
- At least 30 GB free disk space (60GB recommended)
- Internet connection (for Windows download)
- macOS Ventura 13.0+ for best compatibility

**Steps**:

1. **Launch New VM Wizard**:
   - Parallels Desktop → **File** → **New**
   - OR: Click **"+"** icon in main window

2. **Installation Assistant**:
   - Screen shows installation source options

3. **Choose Installation Source**:
   - **Option A** (Recommended): **"Download Windows 11 from Microsoft"**
     - Parallels auto-downloads Windows 11 ARM64 (~6 GB)
     - Official Microsoft image, fully licensed (30-day trial)
     - Click **Continue**

   - **Option B**: **"Install Windows or another OS from a DVD or image file"**
     - If you have Windows 11 ARM64 ISO file
     - Click **Choose an Image File**
     - Select `.iso` file from disk
     - Click **Continue**

   - **Option C**: **"Import Windows from PC"**
     - If migrating from another Windows PC
     - Requires Parallels Transporter tool

4. **Windows Download** (Option A only):
   - Parallels downloads Windows 11 ARM64 (~6 GB)
   - Progress bar shows download status
   - Time: 10-30 minutes depending on internet speed
   - Download saves to: `~/Parallels/Windows 11.pvm`

5. **Windows Installation** (Automatic):
   - Windows installation begins automatically
   - No user interaction needed for first ~10 minutes
   - Windows setup wizard appears

6. **Windows Setup Wizard**:
   - **Region**: Select your country/region
   - **Keyboard Layout**: Select keyboard (US, UK, etc.)
   - **Microsoft Account**:
     - **Option A**: Sign in with Microsoft account (email + password)
     - **Option B**: Create local account (click "Sign-in options" → "Offline account")
   - **Privacy Settings**: Choose privacy preferences (telemetry, location, etc.)
   - Click **Accept** to complete setup

7. **Parallels Tools Installation** (Automatic):
   - After Windows setup completes, Parallels Tools install automatically
   - Parallels Tools = drivers for better performance (graphics, network, clipboard, etc.)
   - VM reboots after Parallels Tools install
   - Time: ~5 minutes

8. **Windows Ready**:
   - Windows desktop appears
   - VM is fully functional
   - You can now install Windows apps, configure settings, etc.

**VM Configuration** (During Creation):
- **Name**: "Windows 11" (default, you can rename)
- **Location**: `~/Parallels/` (default, you can change)
- **Purpose**: Select use case (affects resource allocation):
  - **Productivity**: Office apps, web browsing (4 GB RAM, 2 vCPUs)
  - **Gaming**: Games, 3D apps (8 GB RAM, 4 vCPUs, 3D acceleration)
  - **Development**: IDEs, compilers, Docker (8 GB RAM, 4 vCPUs)
  - **Software Testing**: QA, multiple apps (4 GB RAM, 2 vCPUs)
- **Resources**: Auto-configured based on purpose (adjustable later in VM Settings)

**Total Time**: ~30-60 minutes (download + installation + setup)

### Create Linux VM (Ubuntu, Debian, Fedora, etc.)

**Steps**:

1. **Launch New VM Wizard**:
   - Parallels Desktop → **File** → **New**

2. **Choose Installation Source**:
   - **Option A** (Easiest): **"Download Ubuntu Linux"** (or Debian, Fedora, etc.)
     - Parallels download center shows popular distros
     - Select distro (e.g., Ubuntu 22.04 LTS ARM64)
     - Click **Continue**
     - Parallels downloads ISO (~3-4 GB)

   - **Option B**: **"Install from image file"**
     - Download ARM64 ISO from distro website (e.g., ubuntu.com)
     - Click **Choose an Image File**
     - Select `.iso` file
     - Click **Continue**

3. **VM Creation**:
   - Parallels creates VM with optimal settings
   - Name: "Ubuntu Linux" (default, you can rename)
   - Location: `~/Parallels/Ubuntu Linux.pvm`
   - Resources: 4 GB RAM, 2 vCPUs (adjustable)

4. **Linux Installation Wizard**:
   - Linux installer starts (varies by distro)
   - **Ubuntu Example**:
     - **Language**: Select language
     - **Installation Type**: "Install Ubuntu" (default)
     - **Updates**: Download updates during installation (recommended)
     - **Installation Type**: "Erase disk and install Ubuntu" (VM disk only, safe)
     - **Timezone**: Select timezone
     - **User Account**: Create username and password
     - Installation proceeds (~10-20 minutes)

5. **Parallels Tools Installation** (Required):
   - After Linux boots, Parallels prompts to install Parallels Tools
   - **Ubuntu/Debian**:
     - Click **Install Parallels Tools**
     - Open Terminal in VM
     - Run: `sudo ./install` (in mounted CD-ROM)
     - Enter password
     - Wait for installation (~2-3 minutes)
     - Reboot VM

   - **Manual Installation** (if auto-mount fails):
     ```bash
     # In Linux VM terminal
     cd /media/$USER/Parallels\ Tools/
     sudo ./install
     # Enter password, wait for completion
     sudo reboot
     ```

6. **Linux VM Ready**:
   - Linux desktop appears
   - Parallels Tools provide:
     - Shared folders (access Mac files from Linux)
     - Clipboard sharing (copy/paste between Mac and Linux)
     - Dynamic resolution (VM adapts to window size)
     - Drag-and-drop (files between Mac and Linux)

**Popular Linux Distros for ARM64**:
- **Ubuntu 22.04/24.04 LTS**: Most popular, best support, large community
- **Debian 11/12**: Stable, minimal, good for servers
- **Fedora 38+**: Cutting-edge, latest packages, Red Hat ecosystem
- **Arch Linux ARM**: Bleeding-edge, rolling release, advanced users
- **Kali Linux ARM**: Security testing, penetration testing, ethical hacking

**Total Time**: ~30-45 minutes (download + installation + Parallels Tools)

### Create macOS VM (for Testing Different macOS Versions)

**Purpose**: Test apps on different macOS versions without dual-booting

**Steps**:

1. **Launch New VM Wizard**:
   - Parallels Desktop → **File** → **New**

2. **Choose macOS Installation**:
   - Click **"Install macOS using the recovery partition"**
   - Parallels uses macOS Recovery to download and install macOS

3. **Select macOS Version**:
   - Parallels shows available macOS versions (e.g., Ventura, Sonoma, Sequoia)
   - Select desired version
   - Click **Continue**

4. **VM Creation**:
   - Parallels creates VM with optimal settings
   - Name: "macOS Ventura" (or selected version)
   - Location: `~/Parallels/macOS Ventura.pvm`
   - Resources: 8 GB RAM, 4 vCPUs (recommended for macOS)

5. **macOS Download and Installation**:
   - Parallels downloads macOS from Apple servers (~12-15 GB)
   - Installation proceeds automatically (~30-60 minutes)
   - VM reboots several times during installation

6. **macOS Setup Wizard**:
   - **Country/Region**: Select country
   - **Language**: Select language
   - **Migration**: Skip migration (new install)
   - **Apple ID**: Sign in or skip (can sign in later)
   - **Terms**: Accept license agreement
   - **User Account**: Create username and password
   - **Settings**: Choose privacy preferences

7. **macOS VM Ready**:
   - macOS desktop appears
   - Parallels Tools pre-installed (macOS VMs have built-in support)
   - You can now test apps on different macOS versions

**Use Cases**:
- Test apps on older macOS versions (e.g., Ventura on Sequoia Mac)
- Test apps on newer macOS betas (e.g., Sequoia beta on Ventura Mac)
- Verify compatibility before upgrading main macOS installation
- Development: Test macOS-specific features across versions

**Total Time**: ~60-90 minutes (download + installation + setup)

---

## VM Management

### Start/Stop VM

**Start VM**:
1. Open Parallels Desktop
2. Main window shows all VMs (thumbnails)
3. Click VM thumbnail → Click **Start** button (▶️ icon)
4. OR: Double-click VM thumbnail
5. VM boots (~10-30 seconds depending on VM)

**Suspend VM** (Save State):
1. VM window → Click **Suspend** button (⏸️ icon)
2. OR: Close VM window → Select **Suspend**
3. OR: Menu bar → **Actions** → **Suspend**
4. VM saves current state to disk (all apps, windows, RAM state preserved)
5. Resume: Click **Resume** button → VM continues exactly where it left off
6. Time: Instant resume (~2-5 seconds)

**Shut Down VM** (Clean Shutdown):
1. **From Inside VM**:
   - Windows: Start Menu → Power → Shut down
   - Linux: Power icon → Shut down
   - macOS: Apple menu → Shut Down
2. **From Parallels**:
   - VM window → Click **Stop** dropdown → **Shut Down**
   - OR: Menu bar → **Actions** → **Shut Down**
3. VM shuts down gracefully (saves all work, closes apps properly)
4. Time: ~10-30 seconds

**Force Stop VM** (Emergency):
1. VM window → **Actions** → **Stop**
2. OR: Click **Stop** button (⏹️ icon) and hold
3. Select **Power Off** (equivalent to pulling power plug)
4. **Warning**: Can cause data loss, corrupted files (use only if VM frozen)

### VM Display Modes

Parallels offers 4 display modes for different workflows:

**1. Window Mode** (Default)
- VM runs in separate window (like any Mac app)
- Window has Parallels toolbar (Start, Suspend, Devices, etc.)
- You can resize window, minimize, move to different desktop
- Keyboard shortcuts: Mac shortcuts (Cmd+C, Cmd+V work on Mac, not in VM)
- **Best For**: General use, switching between Mac and VM frequently

**2. Coherence Mode** (Seamless Integration)
- VM desktop disappears (invisible)
- VM apps appear as Mac apps (in macOS Dock, windows alongside Mac apps)
- Windows Start Menu appears in macOS menu bar
- VM apps have Mac-style window controls (traffic lights: red, yellow, green)
- **Activate**: VM window → View → **Enter Coherence** (or `Cmd+Shift+C`)
- **Exit**: View → **Exit Coherence** (or `Cmd+Shift+C`)
- **Best For**: Running Windows apps like Mac apps (Office, browsers, utilities)

**3. Full Screen Mode** (Immersive)
- VM takes over entire screen (like dual-booting)
- No Parallels toolbar visible (hidden until you hover at top)
- Mac menu bar hidden (VM OS menu bar visible)
- **Activate**: VM window → View → **Enter Full Screen** (or green traffic light)
- **Exit**: Move cursor to top → Click green traffic light → **Exit Full Screen**
- **Best For**: Focus on VM work, gaming, presentations

**4. Picture-in-Picture (Modality)**
- VM window floats above all other windows (always on top)
- Small, draggable window (resizable)
- Stays visible while working in Mac apps
- **Activate**: VM window → View → **Enter Picture in Picture**
- **Exit**: View → **Exit Picture in Picture**
- **Best For**: Monitoring VM while working on Mac (e.g., watching build logs)

**Switch Modes**:
- View menu → Select mode
- Keyboard shortcuts: `Cmd+Shift+C` (Coherence), `Cmd+Shift+F` (Full Screen)

### VM Settings (Adjust Resources)

**Access VM Settings**:
1. VM must be stopped or suspended (cannot change while running)
2. Right-click VM thumbnail → **Configure**
3. OR: Select VM → Menu bar → **Actions** → **Configure**

**Hardware Tab** (Performance Tuning):

**CPUs (vCPUs)**:
- **Slider**: 1 to max available (14-16 cores on M3 Max)
- **Recommended**: 2-8 vCPUs depending on workload
  - Light use (web, Office): 2-4 vCPUs
  - Development (IDEs, compilers): 4-6 vCPUs
  - Heavy use (VMs inside VM, 3D apps): 6-8 vCPUs
- **Impact**: More vCPUs = faster VM, but less for Mac host
- **License Limit**: Standard (8 vCPUs max), Pro (32 vCPUs max)

**Memory (RAM)**:
- **Slider**: 2 GB to max available (64 GB on M3 Max)
- **Recommended**: 4-24 GB depending on workload
  - Light use (web, Office): 4-8 GB
  - Development (IDEs, Docker): 8-16 GB
  - Heavy use (multiple VMs, large datasets): 16-24 GB
- **Impact**: More RAM = smoother VM, but less for Mac host
- **License Limit**: Standard (32 GB max per VM), Pro (128 GB max per VM)

**Graphics**:
- **3D Acceleration**: Enable for games, 3D apps, CAD software
- **Video Memory**: 256 MB to 4 GB (auto-configured)
- **Note**: Apple Silicon VMs use Metal API (excellent 3D performance)

**Network**:
- **Shared Network** (Default): VM shares Mac's network connection (NAT)
  - VM gets internet via Mac (behind Mac's firewall)
  - VM IP: Private (e.g., 10.37.129.2)
  - **Best For**: Most use cases (web, updates, downloads)
- **Bridged Network**: VM gets own IP on local network (like separate device)
  - VM visible on local network (other devices can access VM)
  - VM IP: Same subnet as Mac (e.g., 192.168.1.50)
  - **Best For**: Network testing, servers, services accessed by other devices
- **Host-Only Network**: VM can only talk to Mac (isolated)
  - No internet access for VM
  - **Best For**: Security testing, isolated environments

**Hard Disk**:
- **Resize Disk**: Increase VM disk size (cannot shrink without backup/restore)
- **Add Disk**: Add second virtual disk to VM (for data separation)
- **Disk Type**: Expanding (grows as needed) or Plain (fixed size)

**USB & Bluetooth**:
- **USB Devices**: Pass-through USB devices to VM (printers, scanners, drives)
- **Bluetooth**: Share Mac's Bluetooth with VM (keyboards, mice, headphones)

**CD/DVD**:
- **Connect Image**: Mount ISO files as virtual CD/DVD
- **Use Mac Drive**: Share Mac's physical CD/DVD drive with VM

**Sound**:
- **Output**: VM audio plays through Mac speakers
- **Input**: VM can use Mac microphone

**Options Tab** (Behavior & Integration):

**Optimization**:
- **Faster virtual machine**: Prioritize VM performance (use more Mac resources)
- **Longer battery life**: Reduce VM resource usage (save battery on laptops)
- **Balanced**: Auto-adjust based on workload (recommended)

**Sharing**:
- **Share Mac folders**: Share Mac Desktop, Documents, Downloads, Pictures with VM
  - Access in Windows: Network Locations → `\\psf\Home\Desktop\`
  - Access in Linux: `/media/psf/Home/Desktop/`
- **Custom folders**: Add specific Mac folders to share with VM
- **Clipboard sharing**: Enable copy/paste between Mac and VM
- **Drag and drop**: Enable file drag-and-drop between Mac and VM windows

**Applications** (Coherence Mode Settings):
- **Show Windows applications in Mac Dock**: Windows apps appear in macOS Dock
- **Windows Start Menu**: Add Windows Start Menu to Mac menu bar
- **Share Windows applications**: Open Mac files with Windows apps (e.g., open `.docx` with Windows Word)

**Security**:
- **Isolate VM from Mac**: Disable all sharing (folders, clipboard, network)
- **Encrypt VM**: Password-protect VM (requires password to start VM)
- **Custom Password**: Set VM encryption password

**Backup**:
- **Time Machine**: Include VM in Time Machine backups (Warning: VMs are large, 60-100 GB)
- **SmartGuard**: Auto-snapshots (save VM state periodically)
  - Frequency: Hourly, Daily, Weekly
  - Retention: Keep last X snapshots

---

## Key Features

### Coherence Mode (Seamless Windows Integration)

**Purpose**: Run Windows apps alongside Mac apps (no Windows desktop visible)

**Activate Coherence**:
1. Start Windows VM (Window Mode)
2. Menu bar → View → **Enter Coherence** (or `Cmd+Shift+C`)
3. Windows desktop disappears
4. Windows apps appear as Mac apps

**What Happens in Coherence**:
- **Windows Apps**: Appear in macOS Dock (taskbar icons become Dock icons)
- **Windows Start Menu**: Appears in macOS menu bar (top-right)
- **Windows Notifications**: Appear as macOS notifications
- **Windows Desktop**: Hidden (access via File Explorer → Desktop)
- **Mac-Style Windows**: Windows apps have macOS window controls (red, yellow, green buttons)

**Usage**:
- Click Windows app in Dock → App opens in separate window
- Click Start Menu icon in menu bar → Open Windows apps, settings, etc.
- Copy/paste works between Mac and Windows apps
- Drag files from Mac Finder to Windows app windows

**Exit Coherence**:
- Menu bar → View → **Exit Coherence** (or `Cmd+Shift+C`)
- Windows desktop reappears in Window Mode

**Best For**:
- Using Windows Office apps (Word, Excel, PowerPoint) alongside Mac apps
- Running Windows-only utilities (tools, scripts, legacy apps)
- Seamless workflow (switch between Mac and Windows apps without context switching)

### Shared Folders (Access Mac Files in VM)

**Default Shared Folders**:
By default, Parallels shares these Mac folders with VMs:
- **Desktop**: `~/Desktop`
- **Documents**: `~/Documents`
- **Downloads**: `~/Downloads`
- **Pictures**: `~/Pictures`

**Access Shared Folders**:

**Windows**:
1. Open **File Explorer**
2. Navigate to **Network** (left sidebar)
3. Open **`\\psf\Home\`** (Parallels Shared Folders)
4. Folders appear: Desktop, Documents, Downloads, Pictures
5. Use like local folders (open files, save files, etc.)

**Linux**:
1. Open **Files** (file manager)
2. Navigate to **`/media/psf/Home/`**
3. Folders appear: Desktop, Documents, Downloads, Pictures
4. Use like local folders

**Add Custom Shared Folders**:
1. Stop or suspend VM
2. Right-click VM → **Configure**
3. Click **Options** tab → **Sharing**
4. Under "Share Mac folders", click **"+"** button
5. Select Mac folder to share (e.g., `~/Projects`)
6. Click **Add**
7. Custom folder appears in VM under `\\psf\Home\Projects\` (Windows) or `/media/psf/Home/Projects/` (Linux)

**Disable Shared Folders** (Security):
1. VM Configure → Options → Sharing
2. Uncheck "Share Mac folders"
3. VM becomes isolated from Mac filesystem (safer for untrusted VMs)

**Use Cases**:
- **Share Files**: Transfer files between Mac and VM without network
- **Collaborate**: Mac saves file → Windows app opens and edits it
- **Backup**: Save VM work directly to Mac folders (included in Time Machine)

### Snapshots (Save VM States)

**Purpose**: Save VM state at specific point in time (backup before risky changes)

**Create Snapshot**:
1. VM must be running or suspended
2. Menu bar → **Actions** → **Take Snapshot**
3. Enter snapshot name (e.g., "Fresh Windows Install", "Before Software Update")
4. Optional: Add description (what you're about to do)
5. Click **OK**
6. Snapshot saves in ~5-30 seconds (depending on VM size)

**What's Saved in Snapshot**:
- **All RAM**: Current running apps, open windows, unsaved work
- **Disk State**: All files, settings, installed apps
- **Network State**: Active connections (restored on snapshot restore)
- **Time**: Exact moment in time (like "freezing" the VM)

**Restore Snapshot**:
1. Menu bar → **Actions** → **Manage Snapshots**
2. Snapshot list appears (chronological order)
3. Select snapshot to restore
4. Click **Go to this snapshot**
5. Warning: "This will revert VM to snapshot state. Current state will be lost."
6. Click **Go to Snapshot**
7. VM restarts in snapshot state (~10-20 seconds)

**Delete Snapshot** (Free Disk Space):
1. Menu bar → **Actions** → **Manage Snapshots**
2. Select snapshot to delete
3. Click **Delete**
4. Warning: "Snapshot cannot be recovered after deletion."
5. Click **Delete**
6. Disk space freed (~2-10 GB per snapshot depending on VM size)

**Snapshot Best Practices**:
- **Before risky changes**: Installing software, updating OS, changing settings
- **After stable state**: Fresh install, successful configuration, working setup
- **Clean up old snapshots**: Delete snapshots after confirming changes work (free disk space)
- **Name descriptively**: "Before Windows 11 24H2 Update" (not "Snapshot 1")

**Use Cases**:
- **Software Testing**: Install app → Test → If breaks, restore snapshot
- **OS Updates**: Snapshot before Windows Update → Update → If issues, restore
- **Malware Testing**: Snapshot clean VM → Test suspicious file → Restore snapshot (remove malware)
- **Learning**: Snapshot before configuration changes → Experiment → Restore if mistakes

### USB Device Pass-Through

**Purpose**: Connect USB devices (printers, scanners, drives, phones) to VM (disconnect from Mac)

**Connect USB Device to VM**:
1. Plug USB device into Mac (physically)
2. Device appears on Mac desktop (e.g., USB drive icon in Finder)
3. VM window → Menu bar → **Devices** → **USB & Bluetooth** → Select device
4. Device disconnects from Mac, connects to VM
5. Device appears in VM (e.g., Windows shows "USB Drive" in File Explorer)

**Disconnect USB Device from VM** (Return to Mac):
1. **In VM**: Safely eject device (e.g., Windows: Eject icon in taskbar)
2. VM window → **Devices** → **USB & Bluetooth** → Select device → **Disconnect**
3. Device returns to Mac
4. Device appears on Mac desktop again

**Auto-Connect USB Devices** (Specific Devices Always Connect to VM):
1. VM Configure → **Hardware** → **USB & Bluetooth**
2. Under "Connected devices", click **"+"** button
3. Select USB device from list
4. Choose behavior:
   - **Connect to Mac**: Always stay on Mac (never auto-connect to VM)
   - **Connect to Windows**: Always auto-connect to VM when plugged in
   - **Ask what to do**: Prompt on each connection
5. Click **OK**
6. Future connections follow configured behavior

**Use Cases**:
- **USB Printers**: Connect printer to Windows VM (use Windows drivers)
- **USB Scanners**: Scan documents in Windows app
- **USB Drives**: Access USB drive files in Windows File Explorer
- **Smartphones**: Connect iPhone/Android to Windows (iTunes, ADB, file transfer)
- **USB Security Keys**: Use hardware 2FA keys in Windows apps

**Limitations**:
- Device exclusive to either Mac OR VM (not both simultaneously)
- Some devices may not work in VM (drivers, compatibility)
- USB-C hubs: Connect hub to VM, all devices on hub connect to VM

### Drag and Drop (File Transfer)

**Purpose**: Transfer files between Mac and VM by dragging windows

**How It Works**:
1. Drag file from Mac Finder window
2. Drop onto VM window (Windows desktop, Linux desktop, app window)
3. File copies to VM
4. Reverse: Drag from VM window → Drop on Mac Finder → File copies to Mac

**Supported Modes**:
- **Window Mode**: Drag between Mac Finder and VM window
- **Coherence Mode**: Drag between Mac Finder and Windows app windows

**Enable/Disable**:
1. VM Configure → **Options** → **Sharing**
2. Under "Sharing", check/uncheck **"Enable drag and drop"**
3. Default: Enabled

**What Can Be Dragged**:
- Files (documents, images, videos, etc.)
- Folders (entire directories)
- Text (drag selected text from Mac app → Drop in VM text field)
- URLs (drag URL from browser → Drop in VM browser)

**Use Cases**:
- **Quick Transfer**: Drag Mac file to Windows desktop → Open in Windows app
- **Collaboration**: Drag VM file to Mac → Edit in Mac app → Drag back to VM
- **Screenshots**: Drag screenshot from VM → Drop in Mac folder

### Clipboard Sharing (Copy/Paste)

**Purpose**: Copy text/files on Mac → Paste in VM (and vice versa)

**How It Works**:
1. **Mac to VM**:
   - Copy text on Mac (`Cmd+C`)
   - Switch to VM window
   - Paste in VM app (`Ctrl+V` on Windows/Linux)
   - Text appears in VM
2. **VM to Mac**:
   - Copy text in VM (`Ctrl+C` on Windows/Linux)
   - Switch to Mac
   - Paste in Mac app (`Cmd+V`)
   - Text appears on Mac

**What Can Be Copied**:
- **Text**: Any text (emails, documents, URLs, code)
- **Images**: Copy image on Mac → Paste in Windows Paint → Image appears
- **Files**: Copy file on Mac (`Cmd+C`) → Paste in Windows Explorer (`Ctrl+V`) → File transfers

**Enable/Disable**:
1. VM Configure → **Options** → **Sharing**
2. Under "Sharing", check/uncheck **"Share Mac clipboard"**
3. Default: Enabled

**Use Cases**:
- **Copy Commands**: Copy terminal command on Mac → Paste in Windows PowerShell
- **Copy URLs**: Copy URL in Mac Safari → Paste in Windows Chrome
- **Copy Code**: Copy code snippet in Mac Xcode → Paste in Windows Visual Studio

---

## Performance Optimization

### Recommended Settings for M3 Max (Power Profile)

**Hardware Configuration**:

**CPUs**: 6-8 vCPUs (out of 14-16 available on M3 Max)
- **Rationale**: Leaves 6-8 cores for macOS host (ensures Mac stays responsive)
- **Workload-Based**:
  - **Light** (Office, web): 2-4 vCPUs
  - **Medium** (Development, IDEs): 4-6 vCPUs
  - **Heavy** (VMs inside VM, compiling): 6-8 vCPUs

**Memory**: 16-24 GB RAM (out of 64 GB total on M3 Max)
- **Rationale**: Leaves 40-48 GB for macOS host (room for multiple VMs or Mac apps)
- **Workload-Based**:
  - **Light** (Office, web): 4-8 GB
  - **Medium** (Development, Docker): 8-16 GB
  - **Heavy** (Multiple apps, large datasets): 16-24 GB

**Graphics**: 3D acceleration enabled, 2-4 GB vRAM
- **Enable**: VM Configure → Hardware → Graphics → Check "Accelerate 3D graphics"
- **vRAM**: 2-4 GB (auto-configured, no manual adjustment needed)
- **Use Cases**: Games, CAD software, video editing, 3D rendering

**Disk**: 60-80 GB virtual disk (expandable)
- **Initial Size**: 60 GB (enough for Windows + Office + apps)
- **Expandable**: Disk grows as needed (up to limit)
- **Location**: Internal SSD (NOT external drive for best performance)
- **Format**: APFS (macOS default, fast, efficient)

**Network**: Shared Network (default)
- **Bandwidth**: Unlimited (VM shares Mac's network speed)
- **Latency**: Low (NAT adds minimal latency)

**Optimization Profile**:
- **Development/Testing**: Balanced or Faster VM
- **Office Work**: Longer battery life (if on battery)
- **Gaming**: Faster VM + 3D acceleration

### Performance Tips

**Close Unused VMs**:
- Running VMs consume resources even when idle (RAM, CPU)
- **Suspend** VMs not in use (frees CPU, keeps RAM)
- **Shut down** VMs you won't use for hours (frees both RAM and CPU)

**Install Parallels Tools** (CRITICAL):
- Parallels Tools = drivers for VM (graphics, network, clipboard, etc.)
- **Performance Boost**: 30-50% faster with Parallels Tools installed
- **Windows**: Auto-installs after first boot
- **Linux**: Manual install required (see VM Creation section)
- **Verify**: VM running → Actions → Install Parallels Tools (should be grayed out if installed)

**Disable Unneeded Features**:
- VM Configure → Options → Sharing
- **If you don't use**:
  - Shared folders → Uncheck "Share Mac folders"
  - Clipboard → Uncheck "Share Mac clipboard"
  - Drag-and-drop → Uncheck "Enable drag and drop"
- **Impact**: Minor performance gain, better security (VM isolation)

**Use Internal SSD** (NOT External Drive):
- VMs stored on internal SSD: Fast read/write, low latency
- VMs on external drive: Slow (USB 3.0/Thunderbolt), high latency
- **Recommendation**: Keep VMs in `~/Parallels/` (internal SSD)
- **Exception**: Archive old VMs to external drive (free space)

**Regular Snapshot Cleanup**:
- Snapshots consume disk space (2-10 GB each)
- **Review**: Actions → Manage Snapshots → Delete old snapshots
- **Recommendation**: Keep only recent/critical snapshots (delete "Before X" after X succeeds)

**Disk Space Monitoring**:
- Check VM disk usage: VM Configure → Hardware → Hard Disk
- **Windows**: Use Disk Cleanup (free space in VM)
- **Linux**: Use `sudo apt autoremove`, `sudo apt clean` (free space)
- **macOS**: Storage Management → Delete unneeded files

---

## Troubleshooting

### License Issues

**License Not Recognized**:
- **Symptom**: Parallels shows "Enter License Key" even after activation
- **Cause**: License key typo, account mismatch, expired subscription
- **Solution**:
  1. Verify license key correct (copy/paste from email, avoid typos)
  2. Check license status at https://my.parallels.com (sign in with account)
  3. Verify email used for license matches Parallels account email
  4. Contact Parallels support: support@parallels.com (include purchase email)

**Trial Expired**:
- **Symptom**: "Trial expired - Purchase required" message
- **Solution**: Purchase subscription or perpetual license
  1. Visit https://www.parallels.com/products/desktop/buy/
  2. Choose plan: Standard ($99.99/year) or Pro ($119.99/year)
  3. Complete purchase → License key sent to email
  4. Parallels Desktop → Enter license key (see Activation section)

**Multiple Licenses Conflict**:
- **Symptom**: Parallels shows wrong license (e.g., Personal instead of Pro)
- **Cause**: Multiple Parallels accounts with different licenses
- **Solution**:
  1. Sign out: Parallels Desktop → Preferences → Account → Sign Out
  2. Sign in with correct account (the one with desired license)
  3. Verify: Preferences → Account → Shows correct license (Standard, Pro, Business)

**Subscription Auto-Renewal Failed**:
- **Symptom**: "Subscription expired" message
- **Cause**: Payment method declined (expired card, insufficient funds)
- **Solution**:
  1. Visit https://my.parallels.com
  2. Sign in → Billing → Update payment method
  3. Re-subscribe or update credit card
  4. Relaunch Parallels → License re-activates

### VM Won't Start

**Insufficient Resources**:
- **Symptom**: "Not enough memory to start VM" or "VM start failed"
- **Cause**: VM configured with more RAM/CPUs than Mac has available
- **Solution**:
  1. Close other apps (free RAM)
  2. Stop/suspend other VMs (free resources)
  3. VM Configure → Hardware → Reduce RAM allocation (e.g., 16 GB → 8 GB)
  4. VM Configure → Hardware → Reduce vCPU count (e.g., 8 vCPUs → 4 vCPUs)
  5. Try starting VM again

**Disk Space Full**:
- **Symptom**: "Not enough disk space" or "VM disk error"
- **Cause**: macOS disk full (VMs need space to expand)
- **Solution**:
  1. Check Mac storage: System Settings → General → Storage
  2. Free up space: Delete large files, empty Trash, remove old apps
  3. Move old VMs to external drive (if not using frequently)
  4. Delete old snapshots: Actions → Manage Snapshots → Delete
  5. Try starting VM again

**Corrupted VM**:
- **Symptom**: "VM configuration corrupt" or "VM won't boot"
- **Cause**: Disk error, incomplete snapshot restore, crash during VM operation
- **Solution**:
  1. **Restore from snapshot**: Actions → Manage Snapshots → Restore earlier snapshot
  2. **Repair VM**:
     - Right-click VM → Show in Finder
     - Right-click `.pvm` file → Show Package Contents
     - Look for `.pvs` files (snapshots) → Delete corrupted snapshot
  3. **Last resort**: Delete VM, restore from Time Machine backup
  4. **Prevention**: Regular snapshots before risky changes

**macOS Update Broke VM**:
- **Symptom**: VM worked before macOS update, now fails to start
- **Cause**: macOS update changed kernel extensions, security settings
- **Solution**:
  1. Update Parallels Desktop: Homebrew updates Parallels to macOS-compatible version
     ```bash
     darwin-rebuild switch --flake ~/nix-install#power
     ```
  2. Reboot Mac (kernel extensions require reboot)
  3. Try starting VM again
  4. Check Parallels blog: https://www.parallels.com/blogs/ (known issues, workarounds)

### Performance Issues

**VM Slow/Laggy**:
- **Symptom**: VM sluggish, apps take long to open, typing delayed
- **Cause**: Insufficient resources, missing Parallels Tools, too many VMs running
- **Solution**:
  1. **Reduce VM resource allocation**:
     - VM Configure → Hardware → Reduce vCPU count (8 → 4)
     - VM Configure → Hardware → Reduce RAM (16 GB → 8 GB)
  2. **Close other VMs**: Suspend or shut down VMs not in use
  3. **Install Parallels Tools**: Actions → Install Parallels Tools (if not installed)
  4. **Change optimization**: VM Configure → Options → Optimization → "Faster virtual machine"
  5. **Close Mac apps**: Free resources on host (quit Safari, Slack, etc.)

**High CPU Usage on Mac**:
- **Symptom**: Mac fans loud, Mac slow, Activity Monitor shows high CPU
- **Cause**: VM using too many vCPUs, VM running heavy workload
- **Solution**:
  1. **Reduce vCPUs**: VM Configure → Hardware → CPUs → Reduce to 2-4
  2. **Change optimization**: VM Configure → Options → Optimization → "Longer battery life"
  3. **Check VM workload**: What's running in VM? (Task Manager on Windows, `top` on Linux)
  4. **Suspend VM**: If not actively using, suspend to free CPU

**Graphics Glitchy** (Flickering, Artifacts):
- **Symptom**: VM screen flickers, graphics corruption, black rectangles
- **Cause**: Graphics driver issue, 3D acceleration conflict
- **Solution**:
  1. **Update Parallels Tools**: Actions → Reinstall Parallels Tools
  2. **Disable 3D acceleration** (temporary):
     - Stop VM → VM Configure → Hardware → Graphics
     - Uncheck "Accelerate 3D graphics"
     - Start VM → Test if issue resolved
  3. **Update VM OS**: Windows Update, Linux package updates (includes graphics drivers)
  4. **Increase vRAM**: VM Configure → Hardware → Graphics → Increase Video Memory (2 GB → 4 GB)

### Networking Issues

**VM Can't Access Internet**:
- **Symptom**: VM shows "No internet", cannot browse web, cannot download
- **Cause**: Network settings wrong, Mac network issue
- **Solution**:
  1. **Check Mac internet**: Verify Mac can access internet (Safari, ping google.com)
  2. **VM network settings**:
     - Stop VM → VM Configure → Hardware → Network
     - Set to **"Shared Network"** (default)
     - Start VM → Test internet (open browser in VM)
  3. **Restart VM networking**:
     - Windows: Network icon → Troubleshoot → Reset network
     - Linux: `sudo systemctl restart NetworkManager`
  4. **Restart Parallels**: Quit Parallels (`Cmd+Q`) → Relaunch → Start VM

**Can't Access Mac Network** (Printers, NAS, Shared Drives):
- **Symptom**: VM cannot see Mac's local network devices
- **Cause**: Network mode set to "Shared Network" (NAT isolates VM)
- **Solution**:
  1. Stop VM → VM Configure → Hardware → Network
  2. Change to **"Bridged Network"** (VM gets own IP on local network)
  3. Start VM
  4. VM now visible on local network (other devices can access VM)
  5. **Trade-off**: Less secure (VM exposed to network, not behind Mac firewall)

**Windows Firewall Blocking**:
- **Symptom**: Some apps work, others don't (e.g., web works but Remote Desktop doesn't)
- **Cause**: Windows Firewall blocking app
- **Solution**:
  1. **In Windows VM**:
     - Settings → Privacy & Security → Windows Security → Firewall & network protection
     - Click **Allow an app through firewall**
     - Find app in list → Check "Private" and "Public" → OK
  2. **Temporary test**: Turn off firewall → Test if app works → If yes, add firewall exception
  3. **Long-term**: Add firewall rule for specific app/port

### USB Device Issues

**USB Not Recognized in VM**:
- **Symptom**: Plug USB device → VM doesn't see it
- **Cause**: Device still connected to Mac (not passed to VM)
- **Solution**:
  1. Unplug USB device from Mac
  2. Plug back in
  3. VM window → Devices → USB & Bluetooth → Select device
  4. Device connects to VM (appears in VM, e.g., Windows "USB Drive" in File Explorer)

**USB Exclusive to VM** (Can't Use on Mac):
- **Symptom**: USB device stuck in VM, cannot use on Mac
- **Cause**: USB device auto-connects to VM (configured in VM settings)
- **Solution**:
  1. **In VM**: Safely eject USB device (e.g., Windows: Eject icon in taskbar)
  2. VM window → Devices → USB & Bluetooth → Select device → **Disconnect**
  3. Device returns to Mac (appears on Mac desktop)
  4. **Change auto-connect behavior**:
     - VM Configure → Hardware → USB & Bluetooth
     - Find device in list → Set to **"Connect to Mac"** (always stay on Mac)

**USB Device Not Working in VM** (Driver Issue):
- **Symptom**: USB device connects to VM but doesn't work (no driver found)
- **Cause**: VM OS missing driver for device
- **Solution**:
  1. **Install driver in VM**:
     - Download driver from manufacturer website (in VM browser)
     - Install driver in VM
     - Reboot VM
  2. **Windows**: Device Manager → Right-click device → Update driver
  3. **Linux**: Install driver package (e.g., `sudo apt install cups` for printers)

### Parallels Tools Not Working

**Parallels Tools Missing/Outdated**:
- **Symptom**: Poor performance, no clipboard sharing, no shared folders
- **Cause**: Parallels Tools not installed or outdated
- **Solution**:
  1. **Reinstall Parallels Tools**:
     - VM window → Actions → **Install Parallels Tools**
     - **Windows**: AutoPlay appears → Run `setup.exe` → Follow wizard → Reboot
     - **Linux**: Mount CD-ROM → Open terminal → `cd /media/$USER/Parallels\ Tools/` → `sudo ./install` → Reboot
  2. **Verify installation**:
     - Windows: Parallels icon in system tray (bottom-right)
     - Linux: `lsmod | grep prl` (should show Parallels kernel modules)

**Parallels Tools Installation Fails**:
- **Symptom**: Parallels Tools installer crashes or shows errors
- **Cause**: Incompatible VM OS version, installer corruption
- **Solution**:
  1. **Update VM OS**: Windows Update, Linux package updates
  2. **Download Parallels Tools manually**:
     - Visit https://www.parallels.com/products/desktop/resources/
     - Download Parallels Tools ISO for your VM OS
     - VM Configure → Hardware → CD/DVD → Connect Image → Select downloaded ISO
     - Run installer from CD/DVD in VM
  3. **Check compatibility**: Older VM OSes may not support latest Parallels Tools
     - Windows 7: May need older Parallels Desktop version
     - Linux distros: Check Parallels documentation for supported versions

---

## Security Notes

**VM Isolation**:
- VMs are isolated from Mac (sandboxed)
- Malware in VM **cannot** directly infect macOS (unless shared folders enabled)
- VM has no access to Mac files (unless explicitly shared)

**Shared Folders - Security Risk**:
- **Risk**: If VM is compromised, malware can access shared Mac folders
- **Mitigation**:
  - Only share necessary folders (e.g., `~/Downloads`, NOT `~/` home directory)
  - Disable shared folders when running untrusted software in VM
  - Use snapshots: Snapshot clean VM → Test untrusted software → Restore snapshot

**Network Security**:
- **Shared Network** (NAT): Safer (VM behind Mac firewall, isolated from local network)
- **Bridged Network**: Less safe (VM exposed to local network, visible to other devices)
- **Recommendation**: Use Shared Network unless you need VM accessible on network

**Snapshots for Malware Testing**:
1. Create clean VM snapshot ("Fresh Install")
2. Run suspicious file in VM
3. Observe behavior (monitor Task Manager, network activity)
4. **After testing**: Restore snapshot (removes malware, returns VM to clean state)
5. VM is clean again (malware gone)

**Windows Updates in VM**:
- Keep Windows updated inside VM (separate from Parallels updates)
- Windows VM: Settings → Windows Update → Check for updates
- Security patches critical (Windows has vulnerabilities exploited by malware)

---

## License Verification

**Check License Status**:

1. **Open Preferences**:
   - Parallels Desktop → Menu bar → **Parallels Desktop** → **Preferences**

2. **Navigate to Account Tab**:
   - Click **Account** (left sidebar)

3. **Verify License Info**:
   - **License Type**: Trial, Standard, Pro, Business, or Perpetual
   - **Status**: Active, Expired, or Trial (X days remaining)
   - **Expiration Date**: Renewal date (if subscription)
   - **License Key**: Displayed (if perpetual license)

**Expected Status**:

**Trial**:
- Shows: "Trial - 14 days remaining" (or X days)
- Click **Buy Now** to purchase subscription

**Standard/Pro Subscription**:
- Shows: "Standard Edition" or "Pro Edition"
- Renewal date: "Next billing date: YYYY-MM-DD"
- Status: "Active"

**Perpetual License**:
- Shows: "Parallels Desktop [Version]"
- License key: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
- No expiration date (one-time purchase)

**Manage Subscription**:
- Visit https://my.parallels.com
- Sign in with Parallels account
- Manage subscriptions, billing, download history

---

## Testing Checklist

**Installation Verification**:
- [ ] Run `darwin-rebuild switch --flake ~/nix-install#power`
- [ ] Verify Parallels Desktop installed at `/Applications/Parallels Desktop.app`
- [ ] **Power profile**: Parallels present ✅ (`ls -la /Applications/Parallels\ Desktop.app`)
- [ ] **Switch to Standard profile**: `darwin-rebuild switch --flake ~/nix-install#standard`
- [ ] **Standard profile**: Parallels NOT present ❌ (`ls -la /Applications/Parallels\ Desktop.app` → Error)
- [ ] **Switch back to Power**: `darwin-rebuild switch --flake ~/nix-install#power`

**License Activation**:
- [ ] Launch Parallels Desktop (Spotlight: `Cmd+Space`, type "Parallels")
- [ ] Activation screen appears (Welcome wizard)
- [ ] Click **"Try Free for 14 Days"** (Trial activation)
- [ ] Create Parallels account (email + password)
- [ ] Check email for verification link → Click link
- [ ] Sign in to Parallels with account
- [ ] Trial activates successfully
- [ ] Preferences → Account shows "Trial - 14 days remaining"

**Auto-Update Disable**:
- [ ] Parallels Desktop → Preferences → Advanced (or General tab)
- [ ] Find "Check for updates automatically" section
- [ ] Uncheck "Check for updates automatically"
- [ ] Uncheck "Download updates automatically" (if separate)
- [ ] Close Preferences
- [ ] Quit Parallels (`Cmd+Q`) → Relaunch
- [ ] Preferences → Advanced → Verify checkboxes remain unchecked

**VM Creation (Windows 11)**:
- [ ] Parallels Desktop → File → New
- [ ] Click "Download Windows 11 from Microsoft"
- [ ] Parallels downloads Windows 11 ARM64 (~6 GB, wait 10-30 minutes)
- [ ] Windows installation starts automatically (~20-30 minutes)
- [ ] Windows setup wizard appears (region, keyboard, account)
- [ ] Complete setup (create local account or sign in with Microsoft account)
- [ ] Parallels Tools install automatically (wait ~5 minutes)
- [ ] VM reboots
- [ ] Windows desktop appears (VM fully functional)

**VM Functionality**:
- [ ] **Start VM**: Click VM thumbnail → Start button → VM boots successfully
- [ ] **Suspend VM**: Click Suspend button → VM suspends → Click Resume → VM resumes
- [ ] **Shut down VM**: Inside Windows → Start Menu → Power → Shut down → VM shuts down cleanly
- [ ] **Coherence mode**: View → Enter Coherence → Windows apps appear alongside Mac apps
- [ ] **Shared folders**: File Explorer → Network → `\\psf\Home\Desktop\` → Mac Desktop visible
- [ ] **Clipboard sharing**: Copy text on Mac (`Cmd+C`) → Paste in Windows (`Ctrl+V`) → Text appears
- [ ] **Drag and drop**: Drag file from Mac Finder → Drop on Windows desktop → File transfers

**Performance (M3 Max)**:
- [ ] VM Settings → Hardware → CPUs: Set to 6-8 vCPUs
- [ ] VM Settings → Hardware → Memory: Set to 16-24 GB RAM
- [ ] VM Settings → Hardware → Graphics: 3D acceleration enabled
- [ ] VM runs smoothly (no lag, responsive apps)
- [ ] Activity Monitor (Mac): Check CPU/RAM usage (VM uses allocated resources, Mac host responsive)
- [ ] Graphics test (if 3D app available): 3D apps run smoothly (no glitches)

**Snapshots**:
- [ ] VM running → Actions → Take Snapshot
- [ ] Enter snapshot name "Fresh Windows Install" → OK
- [ ] Snapshot creates successfully (~5-30 seconds)
- [ ] Make change in Windows (e.g., create file on Desktop)
- [ ] Actions → Manage Snapshots → Select "Fresh Windows Install" → Go to this snapshot
- [ ] VM restores to snapshot state (~10-20 seconds)
- [ ] Verify change reverted (file on Desktop gone)
- [ ] Delete snapshot: Manage Snapshots → Select → Delete → Disk space freed

**USB Pass-Through** (If USB Device Available):
- [ ] Plug USB device into Mac (e.g., USB drive)
- [ ] Device appears on Mac desktop (Finder shows USB drive)
- [ ] VM window → Devices → USB & Bluetooth → Select USB device
- [ ] Device disconnects from Mac, connects to VM
- [ ] Windows shows "USB Drive" in File Explorer (or Linux shows in `/media/`)
- [ ] Access files on USB drive in VM
- [ ] Eject from VM: Safely eject → Devices → USB → Disconnect
- [ ] Device returns to Mac (appears on Mac desktop again)

**Network**:
- [ ] VM can access internet (open browser in VM, load webpage)
- [ ] Check IP address in VM: `ipconfig` (Windows) or `ip addr` (Linux)
- [ ] Shared Network: VM IP is private (e.g., 10.37.129.2) ✅
- [ ] Test download in VM (download file from internet)

---

## Additional Resources

**Parallels Support**:
- **Knowledge Base**: https://kb.parallels.com
  - How-to guides, troubleshooting, known issues
- **Community Forums**: https://forum.parallels.com
  - Ask questions, share solutions, connect with other users
- **Contact Support**: https://www.parallels.com/support
  - Email support, live chat (business/pro customers)
  - Submit ticket: Include VM config, error messages, screenshots

**Account Management**:
- **My Parallels Portal**: https://my.parallels.com
  - Manage subscriptions, billing, licenses
  - Download Parallels Desktop, Parallels Tools
  - View purchase history, invoices
- **License Key Recovery**: support@parallels.com
  - Include purchase email, transaction ID

**Documentation**:
- **User Guide**: https://www.parallels.com/products/desktop/resources/
  - Official documentation (PDF, online)
  - Getting started, advanced features, troubleshooting
- **Video Tutorials**: Parallels YouTube channel
  - Step-by-step guides, feature demos
- **Blog**: https://www.parallels.com/blogs/
  - macOS updates, new features, tips & tricks
  - Known issues, workarounds

**Download Resources**:
- **Windows VMs**: https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/
  - Free Windows 10/11 development VMs (90-day evaluation)
- **Linux ISOs**: Download from official distro websites
  - Ubuntu: https://ubuntu.com/download/desktop (select ARM64)
  - Debian: https://www.debian.org/distrib/ (select ARM64)
  - Fedora: https://getfedora.org/en/workstation/download/ (select ARM64)

---

**Last Updated**: 2025-01-XX (Story 02.8-001)
**Maintainer**: FX
**Related Documentation**:
- `docs/licensed-apps.md` → Parallels Desktop subscription/license info
- `docs/REQUIREMENTS.md` → Story 02.8-001 requirements
- `docs/development/stories/epic-02-feature-02.8.md` → Implementation details
