# Terramaster NAS SMB Optimization Guide

> Optimizing Time Machine backups and rsync performance on Terramaster F8 NAS

**Author:** FX Martin  
**Date:** December 2025  
**NAS Model:** Terramaster F8  
**TOS Version:** 6.x

---

## Table of Contents

1. [Problem Diagnosis](#problem-diagnosis)
2. [SMB Configuration Optimization](#smb-configuration-optimization)
3. [macOS Client-Side Tweaks](#macos-client-side-tweaks)
4. [rsync Best Practices](#rsync-best-practices)
5. [Complete smb.conf Reference](#complete-smbconf-reference)
6. [Service Management](#service-management)
7. [Testing & Validation](#testing--validation)
8. [Troubleshooting](#troubleshooting)

---

## Problem Diagnosis

### Root Causes of Slow Performance

#### 1. Time Machine + SMB = fsync() Overhead
Time Machine issues a sync after **every single file write** to the server. This causes painfully low performance with many small files over SMB.

#### 2. rsync over SMB is Architecturally Wrong
When running rsync over a mounted SMB share:
- Builds a complete file list scanning every directory
- Re-scans everything after remounting
- Checksum calculations happen on the client side, requiring data transfer

#### 3. Default TOS SMB Configuration
Terramaster's default SMB settings aren't optimized for macOS clients. Key VFS modules like `fruit` may not be enabled by default.

---

## SMB Configuration Optimization

### Key VFS Modules for macOS

The Samba `fruit` VFS module provides enhanced compatibility with macOS/Apple clients:

```ini
vfs objects = catia fruit streams_xattr
```

| Module | Purpose |
|--------|---------|
| `catia` | Character translation for special characters in filenames |
| `fruit` | Apple-specific SMB extensions (AAPL) |
| `streams_xattr` | Stores alternate data streams in extended attributes |

### Essential fruit Parameters

```ini
# Core fruit settings
fruit:encoding = native
fruit:metadata = stream
fruit:nfs_aces = no
fruit:aapl = yes

# Cleanup settings
fruit:wipe_intentionally_left_blank_rfork = yes
fruit:delete_empty_adfiles = yes

# For Time Machine shares only
fruit:time machine = yes
```

### Parameter Explanations

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `fruit:encoding` | `native` | Use native NFD Unicode encoding |
| `fruit:metadata` | `stream` | Store metadata in streams (efficient for macOS) |
| `fruit:nfs_aces` | `no` | Disable NFS ACE translation (avoid permission issues) |
| `fruit:aapl` | `yes` | Enable Apple SMB2+ extensions |
| `fruit:time machine` | `yes` | Advertise share as Time Machine target |

### Performance Settings

```ini
[global]
# Async I/O - set to 0 for auto-tuning
aio read size = 0
aio write size = 0

# Socket optimization
socket options = TCP_NODELAY SO_KEEPALIVE IPTOS_LOWDELAY

# Sendfile for efficient large file transfers
use sendfile = Yes
```

### Veto Files (Block macOS Cruft)

```ini
[global]
veto files = /.AppleDB/.AppleDouble/.AppleDesktop/Network Trash Folder/Temporary Items/._*/.DS_Store/Thumbs.db/.safe/
delete veto files = Yes
```

---

## macOS Client-Side Tweaks

### 1. Disable I/O Throttling (Temporary Speed Boost)

macOS throttles Time Machine to run at low priority. Disable temporarily for large backups:

```bash
# Disable throttling (run before backup)
sudo sysctl debug.lowpri_throttle_enabled=0

# Re-enable after backup completes
sudo sysctl debug.lowpri_throttle_enabled=1
```

⚠️ **Warning:** This affects all low-priority I/O operations, not just Time Machine. Always re-enable after backup.

### 2. Stop .DS_Store Pollution on Network Shares

```bash
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
```

Requires logout/login to take effect.

### 3. Time Machine Exclusions

Exclude these paths from Time Machine to speed up backups:
- `~/Library/Caches`
- Browser caches
- Adobe Media Cache folders
- Virtual machines
- Docker containers
- Node.js `node_modules` folders

### 4. SMB Client Configuration (Optional)

Create or edit `~/Library/Preferences/nsmb.conf`:

```ini
[default]
# Soft mount for better handling of disconnects
soft=yes

# Enable multi-channel if supported
mc_on=yes
mc_prefer_wired=yes

# Disable directory cache for real-time updates
dir_cache_off=yes

# Extended timeout for slow connections
max_resp_timeout=600
```

---

## rsync Best Practices

### ❌ Don't: rsync Over Mounted SMB Share

```bash
# SLOW - Avoid this pattern
rsync -avz /source/ /Volumes/NAS_Share/destination/
```

### ✅ Do: rsync Over SSH

```bash
# FAST - Direct SSH connection
rsync -av --progress /source/ user@nas_ip:/destination/
```

### ✅ Best: Native rsync Daemon

```bash
# FASTEST - Native rsync protocol
rsync -av --progress /source/ rsync://nas_ip/module_name/
```

### Performance Comparison

| Method | Checksum Calculation | Data Transfer | Speed |
|--------|---------------------|---------------|-------|
| rsync over SMB | Client (requires transfer) | Unencrypted | Slow |
| rsync over SSH | Server (no transfer) | Encrypted | Fast |
| rsync daemon | Server (no transfer) | Unencrypted | Fastest |

### rsync Flags to Avoid on Fast Networks

```bash
# DON'T use -z (compression) on LAN - creates CPU bottleneck
rsync -avz ...  # ❌

# DO use -W (whole file) for initial syncs
rsync -av --whole-file ...  # ✅
```

---

## Complete smb.conf Reference

### Global Section

```ini
[global]
    client min protocol = CORE
    config file = /etc/samba/smb.conf
    enhanced browsing = No
    guest account = guest
    local master = No
    max log size = 100
    min receivefile size = 4096
    ntlm auth = ntlmv1-permitted
    obey pam restrictions = Yes
    os level = 200
    passdb backend = smbpasswd
    security = USER
    server min protocol = NT1
    server multi channel support = No
    server string = TNAS
    smb passwd file = /etc/samba/smbp
    socket options = TCP_NODELAY SO_KEEPALIVE IPTOS_LOWDELAY
    unix extensions = No
    
    # Character mapping for special characters
    catia:mappings = 0x003a:0x2236,0x003f:0x0294,0x002a:0x2217,0x003c:0x276e,0x003e:0x276f,0x0022:0x02ba,0x007c:0x2223,0x005c:0x29f9
    
    full_audit:syslog = false
    idmap config * : backend = tdb
    access based share enum = Yes
    aio read size = 0
    case sensitive = Yes
    create mask = 0666
    delete veto files = Yes
    directory mask = 0777
    follow symlinks = No
    force create mode = 0666
    force directory mode = 0777
    hide files = /~$*.doc?/~$*.xls?/~$*.ppt?
    map hidden = Yes
    map readonly = yes
    map system = Yes
    
    # Block macOS metadata files
    veto files = /.AppleDB/.AppleDouble/.AppleDesktop/Network Trash Folder/Temporary Items/._*/.DS_Store/Thumbs.db/.safe/
    
    vfs objects = catia
```

### Time Machine Share (Backup)

```ini
[Backup]
    aio write size = 0
    map acl inherit = Yes
    path = /Volume1/Backup
    read only = No
    use sendfile = Yes
    
    # VFS modules for macOS compatibility
    vfs objects = catia fruit streams_xattr acl_xattr recycle
    
    acl_xattr:ignore system acls = no
    
    # Recycle bin settings
    recycle:exclude = ~$*,*.tmp
    recycle:exclude_dir = #recycle
    recycle:maxsixe = 0
    recycle:versions = Yes
    recycle:directory_mode = 0777
    recycle:keeptree = Yes
    recycle:repository = ./#recycle
    
    # Apple fruit module settings
    fruit:metadata = stream
    fruit:encoding = native
    fruit:nfs_aces = no
    fruit:wipe_intentionally_left_blank_rfork = yes
    fruit:delete_empty_adfiles = yes
    fruit:aapl = yes
    fruit:time machine = yes
    
    catia:mappings = 0x003a:0x2236,0x003f:0x0294,0x002a:0x2217,0x003c:0x276e,0x003e:0x276f,0x0022:0x02ba,0x007c:0x2223,0x005c:0x29f9
```

### Standard Data Share Template

```ini
[Data]
    aio write size = 0
    map acl inherit = Yes
    path = /Volume1/Data
    read only = No
    use sendfile = Yes
    
    vfs objects = catia fruit streams_xattr acl_xattr recycle
    
    acl_xattr:ignore system acls = no
    
    recycle:exclude = ~$*,*.tmp
    recycle:exclude_dir = #recycle
    recycle:maxsixe = 0
    recycle:versions = Yes
    recycle:directory_mode = 0777
    recycle:keeptree = Yes
    recycle:repository = ./#recycle
    
    fruit:metadata = stream
    fruit:encoding = native
    fruit:nfs_aces = no
    fruit:wipe_intentionally_left_blank_rfork = yes
    fruit:delete_empty_adfiles = yes
    fruit:aapl = yes
```

---

## Service Management

### Validating Configuration

Always validate before restarting:

```bash
testparm -s
```

This will show any syntax errors or warnings.

### Restarting SMB Service

Try these commands in order until one works:

```bash
# Option 1: systemctl (modern TOS)
sudo systemctl restart smbd

# Option 2: service command
sudo service smbd restart

# Option 3: Signal reload
sudo killall -HUP smbd

# Option 4: Full restart via kill
sudo killall smbd
sudo smbd
```

### Verifying Service Status

```bash
# Check running connections
smbstatus

# Check if service is active
systemctl status smbd

# View recent logs
journalctl -u smbd -n 50
```

---

## Testing & Validation

### 1. Verify SMB Connection from macOS

```bash
# Check how macOS is connecting
smbutil statshares -a
```

### 2. Quick Transfer Benchmark

Copy a folder with many small files and time it:

```bash
# On macOS
time cp -R ~/test_folder /Volumes/NAS_Share/
```

### 3. Time Machine Test

1. Disconnect and reconnect NAS shares
2. Start Time Machine backup
3. Monitor with: `tmutil status`

### 4. Network Throughput Test

Install and run iperf3:

```bash
# On NAS (server mode)
iperf3 -s

# On Mac (client mode)
iperf3 -c NAS_IP_ADDRESS
```

Expected results on Gigabit: ~940 Mbps  
Expected results on 2.5GbE: ~2.35 Gbps

---

## Troubleshooting

### Common Issues

#### "hosts allow = *" Warning

The `*` wildcard is invalid. Use either:
```ini
# Remove the line entirely (allows all by default)
# Or use proper subnet notation:
hosts allow = 192.168.1.0/24
```

#### Config Changes Don't Persist

TOS may overwrite `smb.conf` when settings are changed via GUI. Look for:
```bash
/etc/samba/smb-customize.conf
```
Some TOS versions read custom settings from this file.

#### Slow After macOS Update

Apple occasionally changes SMB behavior. Try:
1. Delete and recreate Time Machine backup
2. Reset SMB configuration on Mac:
   ```bash
   sudo rm /var/db/samba/*
   ```

#### "Weak crypto is allowed" Warning

This is informational only. If you want to enforce stronger protocols:
```ini
[global]
server min protocol = SMB2
client min protocol = SMB2
```

⚠️ This may break compatibility with older devices.

### Log Locations

| Log | Location |
|-----|----------|
| Samba logs | `/var/log/samba/` |
| System logs | `journalctl -u smbd` |
| TOS logs | TOS Control Panel → System Logs |

---

## Quick Reference Card

### Speed Up Time Machine (Temporary)

```bash
# Before backup
sudo sysctl debug.lowpri_throttle_enabled=0

# After backup
sudo sysctl debug.lowpri_throttle_enabled=1
```

### Validate & Restart SMB

```bash
testparm -s && sudo systemctl restart smbd
```

### Stop .DS_Store on Network

```bash
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
```

### Fast rsync to NAS

```bash
rsync -av --progress /source/ user@nas:/dest/
```

---

## References

- [Samba fruit VFS Module Documentation](https://www.samba.org/samba/docs/current/man-html/vfs_fruit.8.html)
- [Apple Time Machine SMB Spec](https://developer.apple.com/library/archive/releasenotes/NetworkingInternetWeb/Time_Machine_SMB_Spec/)
- [45Drives macOS Samba Optimization](https://knowledgebase.45drives.com/kb/macos-samba-optimization/)
- [Terramaster TOS Documentation](https://toshelp.terra-master.com/)

---

*Last updated: December 2025*
