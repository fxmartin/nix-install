# NAS SMB Mount Configuration

This document describes the automated NAS share mounting system, managed declaratively via nix-darwin.

## Why not autofs

Earlier releases mounted the NAS shares on demand through macOS autofs: `darwin/smb-automount.nix` generated `/etc/auto_master` plus a credentialed `/etc/auto_smb` direct map and reloaded them with `automount -vc`.

**macOS 26 no longer honors custom `/etc/auto_master` maps.** `automount -vc` exits 0, prints nothing, and creates no trigger directories, so `/Volumes/Photos` and friends never mounted while every rebuild reported success ([#407](https://github.com/fxmartin/nix-install/issues/407)). Apple-internal automount uses (Time Machine's `/Volumes/.timemachine`) still work; custom maps do not, and no configuration brings them back.

The shares are now mounted by a user LaunchAgent that calls `mount_smbfs` directly.

## Overview

- **At login and on a timer**: the `org.nixos.smb-mount-nas` LaunchAgent mounts every configured share at login (`RunAtLoad`) and retries every 15 minutes (`StartInterval`), so shares come back after the laptop rejoins the network
- **Idempotent**: shares already mounted are skipped; re-running is a no-op
- **Soft fail**: when the NAS is unreachable the run exits cleanly and waits for the next tick — no `KeepAlive` respawn loop
- **Credential stays in memory**: the password is read from `~/.config/smb-nas/password` at mount time, URL-encoded, and never written to disk or into the LaunchAgent plist
- **Reproducible**: configuration managed via nix-darwin (Power profile only)

## Configuration

### Managed Files

The `darwin/smb-automount.nix` module manages:

| File | Purpose |
|------|---------|
| `~/.config/smb-nas/shares.conf` | Generated share list (host, username, mount root, shares), mode 600 |
| `~/.local/bin/smb-mount-nas.sh` | Mount script, copied from `scripts/smb-mount-nas.sh` |
| `~/Library/LaunchAgents/org.nixos.smb-mount-nas.plist` | The mount agent |
| `~/NAS/` | Mount root |

The module also deletes any leftover `/etc/auto_smb` and strips the `auto_smb` line from `/etc/auto_master` on the first rebuild after the switch — that retired map held the NAS password in plaintext.

### Current Shares

| Share | Mount Point | Purpose |
|-------|-------------|---------|
| `Photos` | `~/NAS/Photos` | Photo backup destination |
| `icloud` | `~/NAS/icloud` | iCloud Drive backup destination |
| `calibre` | `~/NAS/calibre` | Calibre ebook library |

Mount points live under `$HOME` rather than `/Volumes` because a user LaunchAgent cannot create directories at the root of `/Volumes` without admin-group handling, and ownership of the mount point stays unambiguous in the home directory.

### NAS Details

- **Host**: `tnas.local` (mDNS — resilient to IP changes)
- **Web UI**: `http://tnas.local:8181` (TerraMaster TOS admin, HTTPS on port 5443)
- **Username**: taken from `userConfig.username`

## Setup

### 1. Create the password file (one-time)

```bash
mkdir -p ~/.config/smb-nas
echo "YOUR_NAS_PASSWORD" > ~/.config/smb-nas/password
chmod 600 ~/.config/smb-nas/password
```

This is the same contract the autofs implementation used — an existing password file needs no changes.

### 2. Rebuild

```bash
rebuild
```

This will:

1. Generate `~/.config/smb-nas/shares.conf`
2. Install `~/.local/bin/smb-mount-nas.sh`
3. Create `~/NAS/`
4. Load the `org.nixos.smb-mount-nas` LaunchAgent

No reboot is required.

## Usage

### Access Shares

```bash
ls ~/NAS/Photos
open ~/NAS/Photos
```

### Mount Now

```bash
~/.local/bin/smb-mount-nas.sh
```

Or ask launchd to run the agent:

```bash
launchctl kickstart -k "gui/$UID/org.nixos.smb-mount-nas"
```

### Check Mount Status

```bash
mount | grep NAS
tail -20 /tmp/smb-mount-nas.log
```

### Unmount

```bash
umount ~/NAS/Photos
```

The next agent tick remounts it.

## Troubleshooting

### Share Not Mounting

1. **Run the script by hand** — it logs every decision it makes:

   ```bash
   ~/.local/bin/smb-mount-nas.sh
   ```

2. **Check NAS connectivity** (the script's own reachability probe):

   ```bash
   nc -z -w 5 tnas.local 445
   ```

3. **Check the credential**:

   ```bash
   ls -l ~/.config/smb-nas/password   # must exist, mode 600, non-empty
   ```

4. **Check the agent is loaded**:

   ```bash
   launchctl print "gui/$UID/org.nixos.smb-mount-nas" | head -20
   ```

   A scheduled one-shot that is not currently running exits non-zero here; that is normal.

5. **Check the logs**:

   ```bash
   tail -50 /tmp/smb-mount-nas.log
   tail -50 /tmp/smb-mount-nas.err
   ```

The script never logs the password. If `mount_smbfs` echoes the URL back on a parse failure, the message is replaced with `(suppressed: mount_smbfs output contained the credential)`.

### Permission Denied

Ensure the username matches the NAS share permissions:

```bash
# Test a manual mount with an interactive password prompt
mount_smbfs "//fxmartin@tnas.local/Photos" ~/NAS/Photos
```

### Mount Point Busy

`mount_smbfs` refuses to mount over a non-empty directory. If a previous mount left files behind:

```bash
ls -la ~/NAS/Photos    # should be empty when unmounted
```

## How It Works

1. launchd starts `~/.local/bin/smb-mount-nas.sh` at login and every 15 minutes
2. The script sources `~/.config/smb-nas/shares.conf` for host, username, mount root, and share list
3. It probes `tnas.local:445`; if unreachable it logs and exits 0
4. It reads `~/.config/smb-nas/password`, URL-encodes it in memory
5. For each share: skip if `mount` already reports it, create the mount point, then `mount_smbfs "//user:password@tnas.local/<share>" ~/NAS/<share>`
6. A failure on one share never blocks the others; the run always exits 0 so launchd does not treat a transient NAS outage as a crash loop

### Credential handling

The password is URL-encoded before it goes into the SMB URL (`%`, `@`, `:`, `/`, `#`, `?`, `&`, space, `+`, `;`), with `%` encoded first so the other escape sequences are not double-encoded. It exists only in the script's memory and in `mount_smbfs`'s argument vector for the lifetime of that call — unlike the retired autofs map, nothing persists it.

## Modifying Configuration

### Add a New Share

1. Edit `darwin/smb-automount.nix`:

   ```nix
   shares = [
     "Photos"
     "icloud"
     "calibre"
     "new-share"  # Add here
   ];
   ```

2. Rebuild:

   ```bash
   rebuild
   ```

The next agent tick mounts it; run the script by hand to mount immediately.

### Change NAS Host

Edit `darwin/smb-automount.nix`:

```nix
nasConfig = {
  host = "othernas.local";
  hostname = "othernas.local";
  username = userConfig.username;
  shares = [ ... ];
};
```

## Integration with Backup Scripts

`rsync-backup.sh` does **not** depend on these mounts. When `useRsyncDaemon = true` in `rsync-backup-config.nix` (the current setting), backups use the native rsync protocol on port 873, which is 2-5x faster on LAN than SMB and was unaffected by the autofs breakage. Its SMB fallback path mounts shares itself under `/Volumes/<Share>`.

The NAS reachability check verifies both host connectivity (ping or SMB port 445) **and** rsync daemon availability (port 873) before starting backup jobs. If the daemon is down, the backup fails immediately with a clear error instead of exhausting all retry attempts.

To troubleshoot rsync daemon issues:

```bash
# Check if rsync daemon is responding
nc -z -w 10 tnas.local 873

# Check NAS connectivity (SMB)
nc -z -w 5 tnas.local 445

# Run backup manually
~/.local/bin/rsync-backup.sh
```

## References

- [Apple mount_smbfs man page](https://keith.github.io/xcode-man-pages/mount_smbfs.8.html)
- [Issue #407 — autofs broken on macOS 26](https://github.com/fxmartin/nix-install/issues/407)
- [Issue #396 — credential write race and URL-encoding hardening](https://github.com/fxmartin/nix-install/issues/396)
