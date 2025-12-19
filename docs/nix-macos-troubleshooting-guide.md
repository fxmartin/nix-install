# Nix on macOS: Troubleshooting & Recovery Guide

A practical guide for diagnosing and fixing Nix/nix-darwin installations on macOS, based on real-world recovery scenarios.

## Quick Diagnosis

Run these commands to assess the situation:

```bash
# Check if Nix daemon is running
sudo launchctl list | grep nix

# Check if /nix exists and is mounted
ls -la /nix
mount | grep nix

# Check if Nix Store volume exists (even if unmounted)
diskutil list | grep -i nix

# Check synthetic.conf (creates /nix mount point)
cat /etc/synthetic.conf

# Test Nix command
nix --version
```

## Common Failure Modes

### 1. `/nix` Directory Missing

**Symptoms:**
- `❌ /nix directory not found`
- Nix commands fail with "command not found" or path errors

**Cause:** The `/nix` mount point doesn't exist. On macOS, this requires an entry in `/etc/synthetic.conf` because the root filesystem is read-only.

**Fix:**
```bash
# Check synthetic.conf
cat /etc/synthetic.conf

# If 'nix' line is missing, add it
echo 'nix' | sudo tee -a /etc/synthetic.conf

# Activate without reboot
sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t

# Verify /nix now exists (will be empty until volume is mounted)
ls -la /nix
```

### 2. Nix Store Volume Not Mounted

**Symptoms:**
- `/nix` exists but is empty
- `diskutil list` shows "Nix Store" volume exists

**Cause:** The APFS volume containing the Nix store isn't mounted.

**Fix:**
```bash
# Find the Nix Store volume
diskutil list | grep -i nix
# Note the disk identifier (e.g., disk3s7)

# Mount it
sudo diskutil mount disk3s7
```

### 3. Encrypted Nix Store Volume

**Symptoms:**
- `Volume on disk3s7 failed to mount`
- `This is an encrypted and locked APFS Volume`

**Cause:** Determinate Systems installer creates an encrypted volume. The passphrase is stored in Keychain.

**Fix:**
```bash
# Find the encryption passphrase in Keychain
security find-generic-password -s "Nix Store" -w

# If that doesn't work, try variations
security find-generic-password -a "Nix Store" -w
security find-generic-password -l "org.nixos.nix-installer" -w

# Broader search
security dump-keychain | grep -B5 -A5 -i nix

# Once you have the passphrase, unlock the volume
sudo diskutil apfs unlockVolume disk3s7 -passphrase "YOUR_PASSPHRASE_HERE"

# Verify it mounted
ls /nix/store | head -5
```

**Check crypto users if password doesn't work:**
```bash
diskutil apfs listCryptoUsers disk3s7
```

### 4. Nix Daemon Not Running

**Symptoms:**
- `❌ Nix daemon not running`
- Nix commands hang or fail

**Fix:**
```bash
# Restart the daemon
sudo launchctl kickstart -k system/org.nixos.nix-daemon

# Or load it if not loaded
sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist

# Verify
sudo launchctl list | grep nix
```

### 5. Nix Commands Not in PATH

**Symptoms:**
- `zsh: command not found: nix`
- But `/nix/store` exists and has content

**Fix:**
```bash
# Source the Nix profile manually
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Test
nix --version

# For darwin-rebuild specifically
/nix/var/nix/profiles/system/sw/bin/darwin-rebuild switch --flake ~/path/to/flake
```

**Permanent fix:** Ensure your shell RC file (`.zshrc` or `.bashrc`) sources the Nix profile:
```bash
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
```

## Full Recovery Procedure

When everything is broken, follow this sequence:

### Step 1: Verify the Nix Store Volume Exists

```bash
diskutil list | grep -i nix
```

If you see a "Nix Store" volume, your data is safe — it's just not accessible.

### Step 2: Fix the Mount Point

```bash
# Check synthetic.conf has 'nix' entry
cat /etc/synthetic.conf

# If missing, add it
echo 'nix' | sudo tee -a /etc/synthetic.conf

# Create mount point without reboot
sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t
```

### Step 3: Unlock and Mount the Volume

```bash
# Get passphrase from Keychain
PASSPHRASE=$(security find-generic-password -s "Nix Store" -w 2>/dev/null)
echo "Passphrase: $PASSPHRASE"

# Unlock (replace disk3s7 with your actual disk identifier)
sudo diskutil apfs unlockVolume disk3s7 -passphrase "$PASSPHRASE"

# Verify
ls /nix/store | head -5
```

### Step 4: Restart the Daemon

```bash
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

### Step 5: Get Nix in PATH

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix --version
```

### Step 6: Rebuild the System

```bash
# Find your flake
ls ~/Documents/nix-install/*.nix

# Check available configurations
grep "darwinConfigurations" ~/Documents/nix-install/flake.nix

# Rebuild (use sudo, specify config name if needed)
sudo /nix/var/nix/profiles/system/sw/bin/darwin-rebuild switch --flake ~/Documents/nix-install#power
```

### Step 7: Open Fresh Terminal

Close all terminals and open a new one. Run health check to verify.

## Preventing Future Issues

### Protect synthetic.conf

If you have custom nix-darwin modules that write to `/etc/synthetic.conf` (e.g., for NAS automounts), ensure they **always include the `nix` entry**:

```nix
# WRONG - overwrites and loses nix entry
environment.etc."synthetic.conf".text = ''
  Photos	/path/to/photos
'';

# RIGHT - include nix entry
environment.etc."synthetic.conf".text = ''
  nix
  Photos	/path/to/photos
'';

# BEST - let nix-darwin manage it, use different mechanism for custom mounts
```

### After macOS Updates

macOS updates can reset or modify system files. After major updates:

1. Run your health check script
2. Verify `/etc/synthetic.conf` still has the `nix` entry
3. If Nix is broken, follow the recovery procedure above

### Backup Your Flake

Your flake is the key to reproducibility. Keep it in git and pushed to a remote:

```bash
cd ~/Documents/nix-install
git status
git push
```

## Useful Commands Reference

| Command | Purpose |
|---------|---------|
| `diskutil list \| grep -i nix` | Find Nix Store volume |
| `diskutil mount disk3s7` | Mount a volume |
| `diskutil apfs unlockVolume disk3s7` | Unlock encrypted volume |
| `diskutil apfs listCryptoUsers disk3s7` | List who can unlock volume |
| `security find-generic-password -s "Nix Store" -w` | Get Nix encryption passphrase |
| `sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t` | Activate synthetic.conf without reboot |
| `sudo launchctl kickstart -k system/org.nixos.nix-daemon` | Restart Nix daemon |
| `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh` | Source Nix profile |
| `darwin-rebuild switch --flake PATH#CONFIG` | Rebuild nix-darwin |

## Time Machine Recovery (Last Resort)

If the Nix Store is truly corrupted or deleted, local snapshots might help:

```bash
# List available snapshots
tmutil listlocalsnapshots /

# Mount a snapshot to browse
mkdir /tmp/snapshot-mount
sudo mount_apfs -s com.apple.TimeMachine.2025-12-18-174709.local /dev/disk3s7 /tmp/snapshot-mount
```

If your flake is intact, a clean reinstall is often faster:

1. Uninstall Nix: `/nix/nix-installer uninstall` (or follow Determinate Systems docs)
2. Reinstall: `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh`
3. Rebuild: `darwin-rebuild switch --flake ~/Documents/nix-install#power`

---

*Guide created: December 2025*
*Based on recovery from synthetic.conf corruption causing unmounted encrypted Nix Store*
