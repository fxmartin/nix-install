# ABOUTME: System monitoring tools post-installation configuration guide
# ABOUTME: Covers mactop, gotop, macmon, and iStat Menus for comprehensive system monitoring

# System Monitoring Tools

This guide covers four system monitoring tools installed for different use cases:

- **mactop**: Apple Silicon monitor with CPU/GPU/ANE metrics (TUI - Homebrew)
- **gotop**: Interactive CLI system monitor (TUI - Terminal User Interface)
- **macmon**: macOS system monitoring CLI tool (hardware specs, sensors)
- **iStat Menus**: Professional menubar system monitoring (licensed app)

**Philosophy**: System monitoring is essential for performance optimization, troubleshooting, and resource management. mactop provides Apple Silicon-specific metrics, gotop provides interactive terminal monitoring, macmon offers CLI system inspection, and iStat Menus delivers always-visible menubar metrics.

---

## Table of Contents

- [mactop](#mactop)
  - [Features](#mactop-features)
  - [Usage](#mactop-usage)
  - [Testing Checklist](#mactop-testing-checklist)
- [gotop](#gotop)
  - [Features](#gotop-features)
  - [Usage](#gotop-usage)
  - [Configuration](#gotop-configuration)
  - [Testing Checklist](#gotop-testing-checklist)
- [macmon](#macmon)
  - [Features](#macmon-features)
  - [Usage](#macmon-usage)
  - [Testing Checklist](#macmon-testing-checklist)
- [iStat Menus](#istat-menus)
  - [First Launch](#istat-menus-first-launch)
  - [License Activation](#istat-menus-license-activation)
  - [Core Features](#istat-menus-core-features)
  - [Auto-Update Disable](#istat-menus-auto-update-disable)
  - [Configuration Tips](#istat-menus-configuration-tips)
  - [Testing Checklist](#istat-menus-testing-checklist)
  - [Troubleshooting](#istat-menus-troubleshooting)

---

## mactop

### mactop

**Status**: Installed via Homebrew brew `mactop`

**Purpose**: Real-time Apple Silicon monitor "top" designed to display CPU, GPU, and ANE (Apple Neural Engine) metrics specific to Apple Silicon chips. Shows E-Cores and P-Cores usage, power consumption, GPU frequency, temperatures, and other Apple Silicon-specific metrics.

**Installation**: Homebrew formula (not available in nixpkgs)

**Auto-Update**: No mechanism requiring disable (Homebrew-controlled only, updates via `darwin-rebuild switch`)

**No License Required**: Free and open source (MIT license)

**Apple Silicon Only**: Requires arm64 architecture (M1, M2, M3 chips)

---

### mactop Features

mactop provides comprehensive Apple Silicon monitoring in a terminal interface:

**CPU Monitoring**:
- **E-Cores**: Efficiency cores usage and frequency
- **P-Cores**: Performance cores usage and frequency
- **Per-core breakdown**: Individual core utilization
- **CPU power consumption**: Real-time wattage

**GPU Monitoring**:
- **GPU usage percentage**: Real-time GPU utilization
- **GPU frequency**: Current GPU clock speed
- **GPU power consumption**: Real-time wattage

**Apple Neural Engine (ANE)**:
- **ANE usage**: Neural Engine utilization percentage
- **ANE power**: Power consumption by ANE

**System Metrics**:
- **Temperature readings**: CPU and GPU temperatures
- **Total power consumption**: System-wide power draw
- **Memory bandwidth**: Unified memory utilization

**Process Management**:
- **Process list**: Top CPU/GPU consuming processes
- **Kill processes**: Terminate processes directly (F9)
- **Process filter**: Search processes by name (/)

**Output Formats**:
- **Interactive TUI**: Default terminal interface
- **Headless mode**: JSON output for scripting
- **Multiple formats**: JSON, YAML, XML, CSV, TOON

---

### mactop Usage

**Basic Launch**:
```bash
# Launch mactop with default settings
mactop

# Launch with specific refresh rate (milliseconds)
mactop --interval 1000

# Launch in headless mode (JSON output)
mactop --headless

# Output in specific format
mactop --headless --format json
mactop --headless --format yaml
mactop --headless --format csv
```

**Keybindings** (while running):
- **q**: Quit mactop
- **/**: Filter processes by name
- **F9**: Kill selected process (with confirmation)
- **↑/↓**: Navigate process list
- **j/k**: Vim-style navigation
- **Tab**: Cycle between sections

**Common Use Cases**:

**1. Monitor Apple Silicon Performance**:
```bash
# Launch mactop to see Apple Silicon metrics
mactop

# Watch for:
# - E-Core vs P-Core balance (efficiency vs performance)
# - GPU utilization during graphics tasks
# - ANE usage during ML workloads
# - Power consumption under load
```

**2. Debug Performance Issues**:
```bash
# Launch during performance problems
mactop

# Identify:
# - CPU cores hitting thermal throttling
# - GPU bottlenecks in graphics apps
# - High power consumption causing battery drain
# - Processes overusing resources
```

**3. Monitor Power Consumption**:
```bash
# Check power usage on battery
mactop

# Useful for:
# - Identifying power-hungry processes
# - Optimizing battery life
# - Understanding workload impact on power
```

**4. Script Integration**:
```bash
# Output JSON for scripting
mactop --headless --format json > metrics.json

# Parse with jq
mactop --headless --format json | jq '.cpu.power'

# Log metrics over time
while true; do
    mactop --headless --format json >> power-log.json
    sleep 60
done
```

**5. Compare E-Cores vs P-Cores**:
```bash
# Launch mactop during workload
mactop

# Observe:
# - Light tasks: E-Cores active, P-Cores idle
# - Heavy tasks: P-Cores ramp up
# - Background tasks: E-Cores preferred
# - macOS scheduler efficiency
```

---

### mactop Testing Checklist

**Installation Verification** (3 tests):
- [ ] Run `which mactop` - should show `/opt/homebrew/bin/mactop`
- [ ] Run `mactop --version` - should show version number
- [ ] Run `mactop --help` - should show usage help

**Basic Functionality** (8 tests):
- [ ] Launch mactop: `mactop` - should show TUI with Apple Silicon metrics
- [ ] Verify CPU section shows E-Cores and P-Cores usage
- [ ] Verify GPU section shows GPU utilization percentage
- [ ] Verify power consumption displays (CPU, GPU, total)
- [ ] Verify temperature readings appear
- [ ] Verify process list shows running processes
- [ ] Press 'q' to quit - should exit cleanly
- [ ] Verify terminal returns to normal after quit

**Interactive Features** (5 tests):
- [ ] Navigate process list with arrow keys - selection moves
- [ ] Press '/' to filter processes - filter prompt appears
- [ ] Press 'F9' on process - kill confirmation appears
- [ ] Vim navigation (j/k) works for process list
- [ ] Tab cycles between UI sections

**Headless Mode** (3 tests):
- [ ] Run `mactop --headless --format json` - outputs valid JSON
- [ ] Run `mactop --headless --format yaml` - outputs valid YAML
- [ ] Run `mactop --headless --format csv` - outputs valid CSV

**Apple Silicon Specific** (4 tests):
- [ ] E-Cores and P-Cores show separate metrics
- [ ] ANE (Apple Neural Engine) usage displays
- [ ] Unified memory bandwidth appears
- [ ] GPU frequency displays current clock speed

**Story Status**: Implementation Complete - Testing Pending

---

## gotop

### gotop

**Status**: Installed via Nix systemPackages `gotop` (Story 02.4-006)

**Purpose**: Interactive CLI system monitor with real-time graphs and process management. Displays CPU, memory, disk I/O, network, temperature, and processes in a colorful terminal interface.

**Installation**: Nix package manager (systemPackages)

**Auto-Update**: No mechanism requiring disable (Nix-controlled only, updates via `darwin-rebuild switch`)

**No License Required**: Free and open source (MIT license)

---

### gotop Features

gotop provides comprehensive system monitoring in a terminal interface:

**Monitoring Metrics**:
- **CPU**: Per-core usage graphs with history
- **Memory**: RAM and swap usage with breakdown
- **Disk I/O**: Read/write activity per disk
- **Network**: Upload/download bandwidth per interface
- **Temperature**: Sensor readings (if available)
- **Processes**: Top processes by CPU or memory usage
- **Battery**: Battery percentage and status (laptops)

**Interactive Features**:
- **Process Management**: Kill processes directly from interface
- **Sorting**: Sort processes by CPU, memory, PID, or command
- **Search**: Search processes by name
- **Zoom**: Expand/collapse individual panels
- **Themes**: Multiple color schemes available

**Benefits**:
- **Real-time monitoring**: Updates every second
- **Visual graphs**: Historical trends at a glance
- **Low resource usage**: Minimal CPU/RAM overhead
- **Keyboard-driven**: No mouse required
- **SSH-friendly**: Works over remote connections

---

### gotop Usage

**Basic Launch**:
```bash
# Launch gotop with default settings
gotop

# Launch with minimal layout (processes only)
gotop -m

# Launch with battery widget (laptops)
gotop -b

# Launch with specified update interval (seconds)
gotop -r 2

# Launch with specific color scheme
gotop -c monokai
```

**Keybindings** (while running):
- **q**: Quit gotop
- **<Tab>**: Cycle between process sort options (CPU → memory → PID → command)
- **m**: Sort processes by memory usage
- **c**: Sort processes by CPU usage
- **p**: Sort processes by PID
- **n**: Sort processes by process name
- **<Enter>**: Select process for details
- **dd**: Kill selected process (requires confirmation)
- **h**: Show help (keybindings reference)
- **?**: Toggle help overlay

**Common Use Cases**:

**1. Monitor System Performance** (general usage):
```bash
# Launch with default layout
gotop

# Watch CPU-intensive tasks
# - Check CPU graph for spikes
# - Sort by CPU usage (press 'c')
# - Identify resource hogs

# Monitor memory usage
# - Check memory graph for trends
# - Sort by memory usage (press 'm')
# - Find memory leaks
```

**2. Identify Resource Bottlenecks**:
```bash
# Launch gotop during performance issues
gotop

# Look for:
# - CPU at 100%: Compute-bound workload
# - Memory near max: Memory pressure
# - Disk I/O spikes: Storage bottleneck
# - Network saturation: Bandwidth limit
# - High temperatures: Thermal throttling
```

**3. Kill Runaway Processes**:
```bash
# Launch gotop
gotop

# Steps:
# 1. Sort by CPU usage (press 'c') or memory (press 'm')
# 2. Navigate to problematic process (arrow keys)
# 3. Press 'dd' to kill process
# 4. Confirm kill (press 'y')
# 5. Process terminates immediately
```

**4. Monitor Long-Running Tasks**:
```bash
# Launch gotop before starting task
gotop

# Use cases:
# - Video encoding: Watch CPU and disk I/O
# - File downloads: Monitor network bandwidth
# - Compilation: Track CPU and RAM usage
# - Data processing: Check for memory leaks
```

**5. Remote System Monitoring** (SSH):
```bash
# SSH into remote Mac
ssh user@remote-mac

# Launch gotop on remote system
gotop

# Benefits:
# - Monitor remote Mac from anywhere
# - Works in terminal (no GUI needed)
# - Low bandwidth (text-based)
```

---

### gotop Configuration

**Color Schemes** (available themes):
```bash
# Available color schemes
gotop -l    # List all available color schemes

# Popular themes:
gotop -c default     # Default theme
gotop -c monokai     # Monokai color scheme
gotop -c solarized   # Solarized theme
gotop -c vice        # Vice theme
```

**Layout Options**:
```bash
# Minimal layout (processes only)
gotop -m

# Show battery widget (laptops)
gotop -b

# Custom update interval (1-60 seconds)
gotop -r 5    # Update every 5 seconds (default: 1)
```

**Persistent Configuration** (optional):
```bash
# Create config file at ~/.config/gotop/gotop.conf
mkdir -p ~/.config/gotop
cat > ~/.config/gotop/gotop.conf <<EOF
# gotop configuration
colorscheme=monokai
updateinterval=2
battery=true
EOF

# Now 'gotop' uses config file settings automatically
```

**CPU Averaging**:
```bash
# Show average CPU usage (not per-core)
gotop -a

# Useful for systems with many cores (simplifies display)
```

**Process Filtering**:
gotop does not support process filtering (shows all processes). For filtered monitoring, use `top` or `htop`.

---

### gotop Testing Checklist

**Installation Verification** (3 tests):
- [ ] Run `which gotop` - should show `/nix/store/.../bin/gotop`
- [ ] Run `gotop --version` - should show version number
- [ ] Run `gotop --help` - should show usage help

**Basic Functionality** (8 tests):
- [ ] Launch gotop: `gotop` - should show TUI with graphs
- [ ] Verify CPU graph displays (per-core or averaged)
- [ ] Verify memory graph shows RAM and swap usage
- [ ] Verify disk I/O graph shows read/write activity
- [ ] Verify network graph shows upload/download bandwidth
- [ ] Verify process list shows running processes
- [ ] Press 'q' to quit - should exit cleanly
- [ ] Verify terminal returns to normal after quit

**Interactive Features** (7 tests):
- [ ] Sort by CPU: Press 'c' - processes sorted by CPU usage
- [ ] Sort by memory: Press 'm' - processes sorted by memory
- [ ] Sort by PID: Press 'p' - processes sorted by PID
- [ ] Sort by name: Press 'n' - processes sorted alphabetically
- [ ] Toggle help: Press 'h' or '?' - help overlay appears
- [ ] Navigate process list with arrow keys - selection moves
- [ ] Launch test process (e.g., `yes > /dev/null &`) - appears in gotop, kill with 'dd'

**Configuration Options** (5 tests):
- [ ] Launch with color scheme: `gotop -c monokai` - colors change
- [ ] Launch with minimal layout: `gotop -m` - shows processes only
- [ ] Launch with battery: `gotop -b` - battery widget appears (laptops)
- [ ] Launch with update interval: `gotop -r 5` - updates every 5 seconds
- [ ] List color schemes: `gotop -l` - shows available themes

**Performance Monitoring** (2 tests):
- [ ] Start CPU-intensive task - gotop shows CPU spike
- [ ] Start memory-intensive task - gotop shows memory increase

**Story Status**: Implementation Complete - VM Testing Pending

---

## macmon

### macmon

**Status**: Installed via Nix systemPackages `macmon` (Story 02.4-006)

**Purpose**: macOS system monitoring CLI tool that displays hardware specifications, sensor readings, and system information in a clean terminal interface. Useful for quick system checks and hardware inspection.

**Installation**: Nix package manager (systemPackages)

**Auto-Update**: No mechanism requiring disable (Nix-controlled only, updates via `darwin-rebuild switch`)

**No License Required**: Free and open source (MIT license)

---

### macmon Features

macmon provides comprehensive system information in a clean terminal output:

**System Information**:
- **Hardware**: Model, CPU, GPU, memory, storage
- **Software**: macOS version, kernel, uptime
- **Network**: Interfaces, IP addresses, MAC addresses
- **Sensors**: Temperature, fan speed, power consumption (if available)
- **Battery**: Health, cycle count, charge status (laptops)
- **Displays**: Resolution, refresh rate, color depth

**Benefits**:
- **One-command overview**: All system info in single output
- **Non-interactive**: Run and view (no TUI like gotop)
- **Script-friendly**: Parse output in automation scripts
- **Snapshot**: Capture system state at a point in time
- **No configuration needed**: Works out of the box

---

### macmon Usage

**Basic Launch**:
```bash
# Display all system information
macmon

# Output includes:
# - Hardware model and specs
# - macOS version and kernel
# - CPU details (model, cores, architecture)
# - Memory (total, used, available)
# - Storage (disks, volumes, capacity)
# - Network interfaces and addresses
# - Sensor readings (temperature, fans)
# - Battery info (if laptop)
```

**Example Output**:
```
╭─────────────────────────────────────────────╮
│ macmon - macOS System Monitor               │
╰─────────────────────────────────────────────╯

System Information:
  Model: MacBook Pro (16-inch, M3 Max, 2023)
  macOS: macOS 15.1 (24B83)
  Kernel: Darwin 24.1.0
  Uptime: 2 days, 14 hours, 32 minutes

Hardware:
  CPU: Apple M3 Max (16 cores: 12 performance, 4 efficiency)
  GPU: 40-core GPU
  Memory: 128 GB Unified Memory
  Storage: 2 TB SSD

Network:
  en0: Wi-Fi (10.0.1.42, aa:bb:cc:dd:ee:ff)
  en1: Ethernet (not connected)

Sensors:
  CPU Temperature: 45°C
  GPU Temperature: 43°C
  Fan Speed: 1200 RPM

Battery:
  Status: Charging
  Charge: 87%
  Health: Normal (98%)
  Cycle Count: 42
```

**Common Use Cases**:

**1. Quick System Check**:
```bash
# Run macmon to get system overview
macmon

# Use cases:
# - Verify hardware specs (CPU, RAM, storage)
# - Check macOS version and uptime
# - Inspect network configuration
# - Monitor temperatures and fan speed
# - Check battery health (laptops)
```

**2. Hardware Inventory**:
```bash
# Capture system specs for documentation
macmon > system-specs.txt

# Use cases:
# - Document Mac hardware configuration
# - Compare specs across multiple Macs
# - Verify upgrade compatibility
# - Support tickets (attach system info)
```

**3. Temperature Monitoring**:
```bash
# Check current temperatures
macmon | grep -i temperature

# Use cases:
# - Diagnose thermal throttling
# - Monitor under heavy load
# - Verify cooling system health
# - Check for overheating issues
```

**4. Battery Health Check**:
```bash
# View battery status and health
macmon | grep -A 5 "Battery"

# Use cases:
# - Check battery cycle count
# - Verify battery health percentage
# - Monitor charging status
# - Diagnose battery issues
```

**5. Network Configuration**:
```bash
# Display network interfaces
macmon | grep -A 10 "Network"

# Use cases:
# - Verify IP address assignments
# - Check interface connectivity
# - Document MAC addresses
# - Troubleshoot network issues
```

**Integration with Scripts**:
```bash
# Parse macmon output in scripts
#!/bin/bash

# Get CPU temperature
cpu_temp=$(macmon | grep "CPU Temperature" | awk '{print $3}')

# Alert if temperature exceeds threshold
if [[ ${cpu_temp%°C} -gt 80 ]]; then
    echo "WARNING: CPU temperature high: $cpu_temp"
fi

# Get battery health
battery_health=$(macmon | grep "Health:" | awk '{print $2}')
echo "Battery health: $battery_health"
```

---

### macmon Testing Checklist

**Installation Verification** (2 tests):
- [ ] Run `which macmon` - should show `/nix/store/.../bin/macmon`
- [ ] Run `macmon --version` or `macmon --help` - should show version or usage

**Basic Functionality** (8 tests):
- [ ] Launch macmon: `macmon` - should display system information
- [ ] Verify hardware section shows model and CPU
- [ ] Verify software section shows macOS version
- [ ] Verify memory information displays (total RAM)
- [ ] Verify storage information displays (disks and capacity)
- [ ] Verify network section shows interfaces and IP addresses
- [ ] Verify sensor readings appear (temperatures, fan speed)
- [ ] Verify battery info appears (if laptop)

**Output Verification** (3 tests):
- [ ] Output is clean and readable (no errors or garbled text)
- [ ] All sections are populated with data (no empty sections)
- [ ] Run `macmon > test.txt` - output saved successfully

**Grep Filtering** (3 tests):
- [ ] `macmon | grep -i temperature` - shows temperature readings
- [ ] `macmon | grep -i battery` - shows battery info
- [ ] `macmon | grep -i network` - shows network interfaces

**Story Status**: Implementation Complete - VM Testing Pending

---

## iStat Menus

### iStat Menus

**Status**: Installed via Homebrew cask `istat-menus` (Story 02.4-006)

**Purpose**: Professional menubar system monitoring application. Displays real-time CPU, memory, disk, network, battery, and sensor stats in the macOS menubar for always-visible system monitoring.

**Installation**: Homebrew cask

**License**: **REQUIRED** - Commercial software with 14-day free trial
- **Trial**: 14 days, full features, no credit card required
- **License**: $11.99 USD (one-time purchase, lifetime license)
- **Purchase**: https://bjango.com/mac/istatmenus/

**Auto-Update**: **MUST DISABLE** - See [Auto-Update Disable](#istat-menus-auto-update-disable) section

**Permissions**: May request **Accessibility** permissions for system monitoring (safe to approve)

---

### iStat Menus First Launch

**1. Launch iStat Menus**:
```bash
# Launch from Spotlight
# Press Cmd+Space, type "iStat Menus", press Enter

# Or launch from Applications
open /Applications/iStat\ Menus.app
```

**2. Welcome Screen**:
- iStat Menus welcome screen appears
- Options:
  - **Start Free Trial**: 14-day trial with full features (no credit card required)
  - **Enter License**: If you already purchased a license
  - **Buy Now**: Purchase license ($11.99 USD)

**3. Start Free Trial**:
1. Click **Start Free Trial** button
2. Trial activates immediately (no account needed)
3. Full access to all features for 14 days
4. Trial countdown displayed in Preferences → License

**4. Menubar Icons Appear**:
After trial activation, menubar icons appear for enabled sensors:
- **CPU**: CPU usage percentage or graph
- **Memory**: RAM usage or pressure indicator
- **Disk**: Disk activity or usage
- **Network**: Upload/download bandwidth
- **Sensors**: Temperature and fan speed
- **Battery**: Battery percentage and time remaining (laptops)

**5. Import Pre-Configured Settings** (RECOMMENDED):
A pre-configured settings file is available with FX's preferred configuration:

1. Open iStat Menus Preferences (click any menubar icon → Preferences)
2. Click **General** tab
3. Click **Import Settings** button
4. Navigate to the nix-install repository:
   - `~/Documents/nix-install/config/istat-menus/iStat Menus Settings.ismp7`
   - OR `~/.config/nix-install/config/istat-menus/iStat Menus Settings.ismp7`
5. Select the `.ismp7` file → Click **Open**
6. Settings are applied immediately (menubar icons update)

**What's Pre-Configured**:
- Menubar items: CPU, Memory, Network (minimal, non-cluttering)
- Update interval: 3 seconds (balanced performance)
- Auto-update: **DISABLED** (critical for update control policy)
- Display formats: Optimized for readability

**6. Manual Configuration** (Alternative):
If not importing settings:
1. Click any menubar icon to open dropdown
2. Click **Preferences** to customize settings
3. Enable/disable desired menubar items
4. Customize display format (percentage, graph, text)
5. **CRITICAL**: Disable auto-update (see [Auto-Update Disable](#istat-menus-auto-update-disable))

---

### iStat Menus License Activation

**Option A: Free Trial** (14 days):
1. Launch iStat Menus → Click **Start Free Trial**
2. Trial activates immediately (no sign-up required)
3. All features unlocked for 14 days
4. Trial countdown: Preferences → License → "XX days remaining"
5. After 14 days: Purchase license or app becomes read-only

**Option B: Enter Existing License**:
1. Launch iStat Menus → Click **Enter License**
2. Enter **License Name** (your name or email used during purchase)
3. Enter **License Key** (received via email after purchase)
4. Click **Activate** → License validates
5. App is now permanently activated

**Option C: Purchase License**:
1. **During Trial**:
   - Click any menubar icon → Preferences → License
   - Click **Buy Now** button
   - Browser opens to https://bjango.com/mac/istatmenus/
   - Complete purchase ($11.99 USD)
   - License key sent via email
   - Enter license (see Option B above)

2. **From Website**:
   - Visit https://bjango.com/mac/istatmenus/
   - Click **Buy** button
   - Complete purchase ($11.99 USD)
   - License key sent via email
   - Launch iStat Menus → Enter License (see Option B)

**License Verification**:
```bash
# Check license status
# Open iStat Menus Preferences → License tab
# Should show one of:
# - "Trial: XX days remaining" (trial period)
# - "Licensed to: [Your Name]" (activated license)
# - "Trial expired" (purchase required)
```

**License Benefits**:
- **Lifetime license**: No subscription, no recurring fees
- **Free updates**: Lifetime updates for current major version
- **Multiple Macs**: License can be used on all your Macs (personal use)
- **No internet required**: License verified offline after activation

**What Happens After Trial Expires**:
- iStat Menus becomes **read-only**
- Menubar displays still visible
- **Cannot change settings** (Preferences locked)
- **Cannot customize** display format or sensors
- **Must purchase license** to regain full functionality

---

### iStat Menus Core Features

iStat Menus provides comprehensive system monitoring with menubar integration:

**CPU Monitoring**:
- **Menubar display**: CPU usage percentage or mini-graph
- **Dropdown details**:
  - Per-core usage graphs
  - Top CPU-consuming processes
  - CPU frequency and temperature
  - Load averages (1m, 5m, 15m)
- **Customization**: Show total CPU, per-core, or graph
- **Alerts**: Notify when CPU exceeds threshold

**Memory Monitoring**:
- **Menubar display**: RAM usage or pressure indicator
- **Dropdown details**:
  - Used, cached, free memory breakdown
  - Memory pressure graph (green/yellow/red)
  - Swap usage
  - Top memory-consuming processes
- **Customization**: Show as percentage, GB, or pressure
- **Alerts**: Notify when memory pressure is high

**Disk Monitoring**:
- **Menubar display**: Disk activity or usage percentage
- **Dropdown details**:
  - Read/write activity per disk
  - Disk space usage (per volume)
  - S.M.A.R.T. status (disk health)
  - Top disk-using processes
- **Customization**: Show activity or space usage
- **Alerts**: Notify when disk space low

**Network Monitoring**:
- **Menubar display**: Upload/download bandwidth
- **Dropdown details**:
  - Real-time bandwidth graph
  - Data transferred today/week/month
  - Active connections
  - Public and local IP addresses
- **Customization**: Show bandwidth or total data
- **Alerts**: Notify on network activity

**Sensor Monitoring**:
- **Menubar display**: Temperature or fan speed
- **Dropdown details**:
  - CPU, GPU, and component temperatures
  - Fan speeds (RPM)
  - Power consumption (watts)
  - Voltage readings
- **Customization**: Show specific sensor or hottest
- **Alerts**: Notify when temperature exceeds threshold

**Battery Monitoring** (laptops):
- **Menubar display**: Battery percentage or time remaining
- **Dropdown details**:
  - Charge percentage and time to full/empty
  - Battery health and cycle count
  - Power source (battery or AC)
  - Apps using significant energy
  - Battery temperature
- **Customization**: Show percentage, time, or health
- **Alerts**: Notify at low battery or full charge

**Time & Date** (bonus feature):
- **Menubar display**: Custom date/time format
- **Dropdown details**:
  - Calendar with events
  - World clocks (multiple timezones)
  - Fuzzy clock (natural language time)
- **Customization**: Format with templates (e.g., "EEE MMM d h:mm a")

---

### iStat Menus Auto-Update Disable

**CRITICAL**: iStat Menus has automatic updates **enabled by default**. You **MUST disable** auto-update to comply with update control policy (all updates via `darwin-rebuild switch` only).

**Step-by-Step Auto-Update Disable**:

1. **Open iStat Menus Preferences**:
   - Click any iStat Menus menubar icon (CPU, Memory, etc.)
   - Click **Preferences** at bottom of dropdown
   - OR: Open System Settings → iStat Menus

2. **Navigate to Updates Settings**:
   - Click **General** tab (top of Preferences window)
   - Scroll down to **Updates** section

3. **Disable Automatic Updates**:
   - **Uncheck** "Automatically check for updates"
   - This prevents iStat Menus from checking for or installing updates

4. **Verify Auto-Update Disabled**:
   - "Automatically check for updates" checkbox should be **unchecked**
   - iStat Menus will no longer check for updates automatically
   - Updates controlled by Homebrew version pinning only

5. **Close Preferences**:
   - Click "X" or press Cmd+W to close Preferences
   - Auto-update disable is now persistent

**Verification**:
```bash
# Check auto-update status
# Open iStat Menus Preferences → General → Updates
# Should show:
# ☐ Automatically check for updates (UNCHECKED)
```

**Manual Update Process** (when desired):
```bash
# Update iStat Menus via Homebrew
darwin-rebuild switch --flake ~/nix-install#power

# Homebrew updates iStat Menus to latest version
# No in-app update checking needed
```

**Why This Matters**:
- **Update control**: All app updates centralized in darwin-rebuild
- **No surprises**: Updates only when you run rebuild command
- **Reproducibility**: System state controlled by flake.lock
- **No auto-restarts**: iStat Menus won't restart itself for updates

**IMPORTANT**: This setting is **MANDATORY** for all licensed apps. Do not skip this step.

---

### iStat Menus Configuration Tips

**Essential Setup Steps**:

**1. Choose Menubar Items** (declutter menubar):
- **Preferences → Menubar Items**
- Enable only needed sensors:
  - **Recommended**: CPU, Memory, Network (most useful)
  - **Optional**: Disk, Sensors, Battery (laptops)
  - **Disable**: Time (macOS built-in clock is sufficient)
- Save menubar space by showing only critical stats

**2. Customize Display Format**:
- **CPU**: Show as graph (visual trend) or percentage (precise)
- **Memory**: Show as pressure indicator (green/yellow/red) or GB used
- **Network**: Show as bandwidth (real-time) or data transferred (cumulative)
- **Battery**: Show as percentage or time remaining

**3. Set Update Intervals**:
- **Preferences → Each sensor → Update Frequency**
- **Default**: 1 second (real-time, higher CPU usage)
- **Recommended**: 2-3 seconds (good balance)
- **Battery-friendly**: 5 seconds (lower power usage)

**4. Configure Alerts** (optional):
- **CPU**: Alert when CPU > 80% for 60 seconds
- **Memory**: Alert when memory pressure is red
- **Disk**: Alert when disk space < 10 GB
- **Battery**: Alert at 15% and 5% charge

**5. Organize Dropdown Menus**:
- **Preferences → Each sensor → Display tab**
- Enable/disable specific dropdown sections
- Reorder items by dragging (most important items at top)
- Show/hide graphs, process lists, and details

**Advanced Customization**:

**Color Schemes**:
- **Preferences → Appearance**
- **Light mode**: White menubar icons (for dark menu bar)
- **Dark mode**: Black menubar icons (for light menu bar)
- **Auto-switch**: Match macOS appearance setting

**Hotkeys** (quick access):
- **Preferences → Hotkeys**
- Assign keyboard shortcuts to:
  - Show specific dropdown (e.g., Cmd+Shift+C for CPU)
  - Toggle menubar items on/off
  - Launch iStat Menus Preferences

**Historical Graphs**:
- **Preferences → Each sensor → History tab**
- Show longer time ranges in dropdown graphs
- Options: 1 minute, 5 minutes, 15 minutes, 1 hour, 1 day
- Useful for trend analysis

**Export Settings** (multi-Mac setup):
- **Preferences → General → Export Settings**
- Save settings to file → Transfer to other Macs
- **Import Settings** → Load saved configuration
- Ensures consistent setup across all MacBooks

**Pre-Configured Settings Available**:
- A pre-configured settings file is included at `config/istat-menus/iStat Menus Settings.ismp7`
- This file contains FX's preferred configuration (menubar items, update intervals, display formats)
- **Import on new Mac**: Preferences → General → Import Settings → Select the `.ismp7` file
- Settings file is version-controlled, so changes can be tracked across rebuilds

**Network Interface Selection**:
- **Preferences → Network → Interface**
- Choose which interface to monitor:
  - **Automatic**: Monitor active interface (Wi-Fi or Ethernet)
  - **Specific**: Choose en0 (Wi-Fi), en1 (Ethernet), etc.
- Useful for tracking specific connection bandwidth

---

### iStat Menus Testing Checklist

**Installation Verification** (3 tests):
- [ ] iStat Menus installed at `/Applications/iStat Menus.app`
- [ ] Launch iStat Menus from Spotlight or Applications
- [ ] Welcome screen appears with trial/license options

**License Activation** (4 tests):
- [ ] Click **Start Free Trial** - trial activates immediately
- [ ] Verify trial countdown: Preferences → License → "14 days remaining"
- [ ] Menubar icons appear after trial activation
- [ ] Trial works without account sign-up or credit card

**Settings Import** (4 tests):
- [ ] Verify settings file exists at `config/istat-menus/iStat Menus Settings.ismp7`
- [ ] Preferences → General → Import Settings → Select the `.ismp7` file
- [ ] Settings import successfully (no error message)
- [ ] Menubar icons update to reflect imported configuration

**Auto-Update Disable** (CRITICAL - 5 tests):
- [ ] Click any menubar icon → Preferences
- [ ] Navigate to General tab
- [ ] Scroll to Updates section
- [ ] Verify "Automatically check for updates" is **checked** (default)
- [ ] **Uncheck** "Automatically check for updates" → Verify unchecked
- [ ] Close Preferences → Reopen → Verify still unchecked (persistent)

**Menubar Display** (6 tests):
- [ ] CPU menubar icon appears and shows current usage
- [ ] Memory menubar icon appears and shows current usage
- [ ] Network menubar icon appears and shows bandwidth
- [ ] Disk menubar icon appears (if enabled)
- [ ] Battery menubar icon appears (if laptop)
- [ ] Sensor menubar icon appears (if enabled)

**Dropdown Functionality** (7 tests):
- [ ] Click CPU icon → Dropdown shows per-core usage and top processes
- [ ] Click Memory icon → Dropdown shows RAM breakdown and pressure
- [ ] Click Network icon → Dropdown shows bandwidth graph and data transferred
- [ ] Click Disk icon → Dropdown shows activity and space usage
- [ ] Click Battery icon → Dropdown shows health and cycle count (laptops)
- [ ] Dropdown updates in real-time (values change)
- [ ] Click outside dropdown → Closes cleanly

**Customization** (5 tests):
- [ ] Open Preferences → Menubar Items → Disable Time → Time icon removed
- [ ] Open Preferences → CPU → Display → Change format → Menubar icon updates
- [ ] Open Preferences → Memory → Display → Change to pressure indicator → Updates
- [ ] Open Preferences → Network → Update Frequency → Change to 3 seconds
- [ ] Export Settings → Save to file → File created successfully

**Permissions** (2 tests):
- [ ] Accessibility permission request may appear (safe to approve)
- [ ] If prompted: System Settings → Privacy & Security → Accessibility → Enable iStat Menus

**Performance Impact** (2 tests):
- [ ] Launch gotop or Activity Monitor - verify iStat Menus CPU usage is low (<5%)
- [ ] Run for 5 minutes - verify no performance degradation

**Story Status**: Implementation Complete - VM Testing Pending

---

### iStat Menus Troubleshooting

**Common Issues and Solutions**:

**1. License Issues**:

**Problem**: "Trial expired" message after 14 days
- **Solution**: Purchase license ($11.99 USD) at https://bjango.com/mac/istatmenus/
- **Workaround**: None (trial is limited to 14 days)
- **Note**: Settings are locked after trial expiration

**Problem**: License key not accepted
- **Cause**: Typo in license name or key
- **Solution**:
  - Verify license name matches purchase email exactly (case-sensitive)
  - Copy license key from email (avoid manual typing)
  - Check for extra spaces at start/end
  - Try entering on different Mac (license is multi-Mac)

**Problem**: License key lost
- **Solution**: Contact Bjango support with purchase email
  - Email: support@bjango.com
  - Subject: "License key recovery"
  - Include: Purchase email, transaction ID (if available)
  - Response: Usually within 24 hours

**2. Menubar Display Issues**:

**Problem**: Menubar icons not appearing
- **Cause**: Menubar items disabled in Preferences
- **Solution**:
  - Open Preferences → Menubar Items
  - Enable desired sensors (CPU, Memory, Network, etc.)
  - Check "Show in menubar" for each enabled sensor
  - Icons appear immediately after enabling

**Problem**: Menubar icons show "---" or no data
- **Cause**: Sensor data not available or permissions denied
- **Solution**:
  - Grant Accessibility permissions: System Settings → Privacy & Security → Accessibility → Enable iStat Menus
  - Restart iStat Menus: Quit (menubar icon → Quit) → Relaunch
  - Reset sensor: Preferences → Sensor → Restore Defaults

**Problem**: Menubar too crowded with icons
- **Solution**:
  - Disable less-important sensors: Preferences → Menubar Items
  - Combine sensors: Use single icon for multiple stats
  - Hide in Control Center: macOS Sonoma+ allows hiding overflow items

**3. Performance Issues**:

**Problem**: iStat Menus using high CPU (>10%)
- **Cause**: Update frequency too high (1 second default)
- **Solution**:
  - Increase update interval: Preferences → Each sensor → Update Frequency → 3-5 seconds
  - Disable unused sensors: Preferences → Menubar Items → Disable unnecessary items
  - Reduce graph history: Preferences → Each sensor → History → Shorter time range (1 minute)

**Problem**: Battery drain on laptop
- **Cause**: Real-time monitoring consumes power
- **Solution**:
  - Increase update frequency to 5 seconds (less frequent checks)
  - Disable Sensors monitoring (temperature/fan polling is power-hungry)
  - Quit iStat Menus when on battery (menubar icon → Quit)

**4. Auto-Update Issues**:

**Problem**: iStat Menus updates automatically despite disabling
- **Cause**: Setting not saved or macOS App Store auto-update enabled
- **Solution**:
  - Re-verify: Preferences → General → Updates → Ensure "Automatically check for updates" is **unchecked**
  - Close and reopen Preferences to confirm setting persists
  - Disable macOS App Store auto-update: System Settings → App Store → Uncheck "Automatic Updates"
  - If installed via Homebrew (our setup): Updates only occur via `darwin-rebuild switch`

**Problem**: Can't find auto-update setting
- **Location**: Preferences → General tab → Scroll down to "Updates" section
- **Note**: Not in Menubar Items or individual sensor settings

**Problem**: Update notification appears after disabling
- **Cause**: Notification was queued before disabling
- **Solution**: Dismiss notification, won't appear again after setting disabled

**5. Dropdown Issues**:

**Problem**: Dropdown doesn't show when clicking menubar icon
- **Cause**: iStat Menus process hung or crashed
- **Solution**:
  - Force quit: Activity Monitor → Search "iStat Menus" → Quit Process
  - Relaunch: Open from Applications or Spotlight
  - If recurring: Reset Preferences → Preferences → General → Restore Defaults

**Problem**: Dropdown shows incorrect data
- **Cause**: Sensor data cached or stale
- **Solution**:
  - Refresh: Click menubar icon to close/reopen dropdown
  - Restart: Quit iStat Menus → Relaunch
  - Reset sensor: Preferences → Sensor → Restore Defaults

**6. Support Resources**:

- **Official Support**: https://bjango.com/help/istatmenus7/
- **Email Support**: support@bjango.com
- **Known Issues**: https://bjango.com/help/istatmenus7/knownissues/
- **User Forum**: https://bjango.com/forums/

---

## Summary Table

| Tool | Installation | License | Auto-Update | Purpose |
|------|-------------|---------|-------------|---------|
| **mactop** | Homebrew brew | Free (MIT) | Homebrew-controlled | Apple Silicon CPU/GPU/ANE monitor (TUI) |
| **gotop** | Nix package | Free (MIT) | Nix-controlled | Interactive CLI system monitor (TUI) |
| **macmon** | Nix package | Free (MIT) | Nix-controlled | CLI system info and sensor readings |
| **iStat Menus** | Homebrew cask | **$11.99 USD** (14-day trial) | **MUST DISABLE** (Preferences → General → Updates) | Professional menubar system monitoring |

---

## Use Case Recommendations

**When to Use mactop**:
- Apple Silicon-specific metrics (E-Cores, P-Cores, ANE)
- GPU monitoring on Apple Silicon Macs
- Power consumption analysis (CPU, GPU, total wattage)
- Performance tuning for M1/M2/M3 workloads
- Understanding macOS scheduler behavior (E-Core vs P-Core allocation)
- ML/AI workload monitoring (ANE usage)
- Battery optimization (identify power-hungry processes)

**When to Use gotop**:
- Real-time system monitoring in terminal
- SSH remote monitoring (no GUI needed)
- Identifying resource bottlenecks interactively
- Killing runaway processes from CLI
- Monitoring long-running tasks (encoding, compilation)

**When to Use macmon**:
- Quick hardware spec check (one-command snapshot)
- System inventory documentation
- Temperature and sensor readings
- Battery health checks (laptops)
- Network configuration inspection
- Scripting and automation (parse output)

**When to Use iStat Menus**:
- Always-visible system monitoring (menubar)
- At-a-glance performance checks (no app launch needed)
- Historical trend analysis (dropdown graphs)
- Multiple metric monitoring (CPU + RAM + Network simultaneously)
- Alert notifications (high CPU, low disk space, etc.)
- Professional workflow (developers, sysadmins)

---

## Story Tracking

**Story**: 02.4-006 - System Monitoring (mactop, gotop, iStat Menus, macmon)
**Status**: Implementation Complete - VM Testing Pending
**Implementation Date**: 2025-01-16
**Updated**: 2025-01-30 - Added mactop

**Changes Made**:
- darwin/configuration.nix: Added gotop and macmon to systemPackages (Story 02.4-006)
- darwin/homebrew.nix: Added istat-menus Homebrew cask with license note (Story 02.4-006)
- darwin/homebrew.nix: Added mactop Homebrew brew for Apple Silicon monitoring (2025-01-30)
- docs/apps/system/system-monitoring.md: Created comprehensive system monitoring documentation
- docs/licensed-apps.md: Added iStat Menus section to Productivity & System Apps (Story 02.4-006)
- docs/development/stories/epic-02-feature-02.4.md: Updated story progress (Story 02.4-006)

**Key Decisions**:
- mactop via Homebrew (not available in nixpkgs, Apple Silicon-specific)
- gotop and macmon via Nix (CLI tools, system-wide availability)
- iStat Menus via Homebrew (GUI app, official distribution)
- Comprehensive auto-update disable documentation for iStat Menus (CRITICAL requirement)
- License activation documented (trial vs. purchase workflows)
- Use case recommendations for each tool (when to use which tool)

**VM Testing Required**:
- Verify mactop launches and displays Apple Silicon metrics (E-Cores, P-Cores, GPU, ANE)
- Verify gotop launches and displays system metrics
- Verify macmon outputs system information
- Verify iStat Menus installs, launches, and trial activation works
- CRITICAL: Verify auto-update disable process works for iStat Menus
- Test menubar icons appear and dropdowns function
- Test permissions requests (Accessibility for iStat Menus)
