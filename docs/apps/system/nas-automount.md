# NAS SMB Automount Configuration

This document describes the automated NAS share mounting system using macOS autofs, managed declaratively via nix-darwin.

## Overview

The SMB automount system provides on-demand mounting of NAS shares:
- **Automatic**: Shares mount when accessed (e.g., `ls /Volumes/Photos`)
- **On-demand**: No persistent connections; unmounts after idle timeout
- **Secure**: Credentials stored in macOS Keychain, not in config files
- **Reproducible**: Configuration managed via nix-darwin

## Configuration

### Managed Files

The `darwin/smb-automount.nix` module manages:

| File | Purpose |
|------|---------|
| `/etc/auto_master` | Main autofs configuration |
| `/etc/auto_smb` | SMB share definitions |
| `/etc/synthetic.conf` | Mount point creation (Catalina+) |

### Current Shares

| Share | Mount Point | Purpose |
|-------|-------------|---------|
| `Photos` | `/Volumes/Photos` | Photo backup destination |
| `icloud` | `/Volumes/icloud` | iCloud Drive backup destination |

### NAS Details

- **Host**: `192.168.68.58` (IP used for reliability over mDNS)
- **mDNS**: `TNAS.local`
- **Username**: `fxmartin`

## Setup

### 1. First-Time Keychain Setup (Required)

After running `rebuild`, add your NAS credentials to Keychain:

```bash
security add-internet-password \
  -a "fxmartin" \
  -s "192.168.68.58" \
  -D "network password" \
  -r "smb " \
  -w "YOUR_NAS_PASSWORD" \
  -U -T ""
```

**Parameters**:
- `-a`: Username (account)
- `-s`: Server hostname/IP
- `-D`: Description
- `-r "smb "`: Protocol (note: 4 chars with space)
- `-w`: Password
- `-U`: Update if exists
- `-T ""`: Allow all apps to access

### 2. Rebuild System

```bash
rebuild
```

This will:
1. Create mount point directories in `/System/Volumes/Data/Volumes/`
2. Configure autofs with share definitions
3. Reload autofs daemon
4. Verify keychain credentials

### 3. Reboot (One-time)

A reboot is required for `synthetic.conf` changes to take effect:

```bash
sudo reboot
```

## Usage

### Access Shares

Simply navigate to the mount point - autofs handles mounting automatically:

```bash
# List photos share (triggers mount)
ls /Volumes/Photos

# Open in Finder
open /Volumes/Photos
```

### Check Mount Status

```bash
# View all mounts
mount | grep -E "(Photos|icloud)"

# Check autofs status
automount -cv
```

### Force Remount

If a share becomes stale:

```bash
# Unmount and remount
sudo umount /Volumes/Photos
ls /Volumes/Photos  # Triggers remount
```

## Troubleshooting

### Share Not Mounting

1. **Check NAS connectivity**:
   ```bash
   ping 192.168.68.58
   nc -z 192.168.68.58 445  # SMB port
   ```

2. **Verify keychain credentials**:
   ```bash
   security find-internet-password -s "192.168.68.58" -a "fxmartin"
   ```

3. **Check autofs logs**:
   ```bash
   log show --predicate 'subsystem == "com.apple.automountd"' --last 5m
   ```

4. **Reload autofs**:
   ```bash
   sudo automount -cv
   ```

### Permission Denied

Ensure your username matches the NAS share permissions:
```bash
# Test manual mount
mount_smbfs -N //fxmartin@192.168.68.58/Photos /Volumes/Photos
```

### Mount Point Missing

After macOS updates, synthetic.conf symlinks may be lost:
```bash
# Reboot to recreate synthetic.conf entries
sudo reboot
```

## How It Works

### autofs Flow

1. User accesses `/Volumes/Photos`
2. autofs intercepts the access (via `/etc/auto_master`)
3. autofs reads mount spec from `/etc/auto_smb`
4. macOS looks up credentials in Keychain
5. SMB connection established, share mounted
6. After idle timeout, share automatically unmounts

### synthetic.conf (macOS Catalina+)

Due to the read-only system volume in modern macOS:
- Physical directories created in `/System/Volumes/Data/Volumes/`
- `synthetic.conf` creates symlinks at root level (`/Volumes/share`)
- Requires reboot for changes to take effect

## Modifying Configuration

### Add a New Share

1. Edit `darwin/smb-automount.nix`:
   ```nix
   shares = [
     "Photos"
     "icloud"
     "new-share"  # Add here
   ];
   ```

2. Rebuild and reboot:
   ```bash
   rebuild
   sudo reboot
   ```

3. Add keychain credentials for new share (if different auth).

### Change NAS Host

Edit `darwin/smb-automount.nix`:
```nix
nasConfig = {
  host = "192.168.1.100";  # New IP
  hostname = "MyNAS.local";
  username = "myuser";
  shares = [ ... ];
};
```

## Integration with Backup Scripts

The `rsync-backup.sh` script works with autofs:
- If share is already mounted via autofs, rsync uses it
- If not mounted, the script's `mount_share()` function handles it
- Autofs provides seamless access for both manual and automated use

## References

- [macOS autofs Guide](https://gist.github.com/rudelm/7bcc905ab748ab9879ea)
- [Apple synthetic.conf man page](https://keith.github.io/xcode-man-pages/synthetic.conf.5.html)
- [Ctrl Blog: Auto-mounting on macOS](https://www.ctrl.blog/entry/automount-netshare-macos.html)
