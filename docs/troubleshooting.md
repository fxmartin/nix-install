# ABOUTME: Troubleshooting guide for common issues with nix-darwin setup
# ABOUTME: Uses Symptom → Cause → Solution format for quick problem resolution

# Troubleshooting Guide

Common issues and their solutions. Each issue follows the format: **Symptom** → **Cause** → **Solution**.

**Quick Help**: Run `health-check` first — it diagnoses most common problems automatically.

---

## Table of Contents

1. [Build Failures](#1-build-failures)
2. [SSH & GitHub Issues](#2-ssh--github-issues)
3. [Homebrew Issues](#3-homebrew-issues)
4. [Podman Issues](#4-podman-issues)
5. [Nix Store Issues](#5-nix-store-issues)
6. [Application Issues](#6-application-issues)
7. [Shell & Terminal Issues](#7-shell--terminal-issues)
8. [System Preferences Issues](#8-system-preferences-issues)
9. [Rollback If Something Breaks](#9-rollback-if-something-breaks)
10. [LaunchAgent Issues](#10-launchagent-issues)

---

## 1. Build Failures

### 1.1 "error: attribute 'X' missing"

**Symptom**: Build fails with error about missing attribute or undefined variable.

```
error: attribute 'ghostty' missing, at /nix/store/.../homebrew.nix:42:5
```

**Cause**: Package name is incorrect or not available in nixpkgs/Homebrew.

**Solution**:
```bash
# Check if package exists in nixpkgs
nix search nixpkgs#<package-name>

# Check Homebrew cask availability
brew search <package-name>

# If renamed, update the package name in the relevant .nix file
```

---

### 1.2 "error: collision between X and Y"

**Symptom**: Build fails with file collision error between two packages.

```
error: collision between '/nix/store/.../bin/python' and '/nix/store/.../bin/python'
```

**Cause**: Two packages provide the same file (common with Python or Node.js).

**Solution**:
```bash
# Option 1: Use higher priority for preferred package
# In home.nix or configuration.nix:
home.packages = [
  (lib.hiPrio pkgs.python312)  # Higher priority
  pkgs.python311
];

# Option 2: Remove one of the conflicting packages
```

---

### 1.3 "error: hash mismatch"

**Symptom**: Build fails with hash mismatch for a downloaded package.

```
error: hash mismatch in fixed-output derivation '/nix/store/...'
  wanted: sha256-XXXX
  got:    sha256-YYYY
```

**Cause**: Upstream package changed, or network issues corrupted download.

**Solution**:
```bash
# Update flake to get new hashes
update

# If persists, clear Nix cache
sudo rm -rf /nix/var/nix/temproots/*
nix-collect-garbage

# Rebuild
rebuild
```

---

### 1.4 "error: Unexpected flake output 'darwinConfigurations'"

**Symptom**: Build fails saying it doesn't recognize darwinConfigurations.

**Cause**: Running wrong command or missing nix-darwin.

**Solution**:
```bash
# Use darwin-rebuild, not nix build
darwin-rebuild switch --flake .#standard

# Ensure nix-darwin is installed
nix-channel --list | grep darwin
```

---

### 1.5 Build hangs or times out

**Symptom**: `rebuild` or `update` hangs indefinitely.

**Cause**: Network issues, large downloads, or Nix daemon problems.

**Solution**:
```bash
# Check if Nix daemon is running
sudo launchctl list | grep nix

# Restart Nix daemon
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon

# Retry with verbose output
darwin-rebuild switch --flake .#standard --show-trace

# If stuck on specific package, check network
curl -I https://cache.nixos.org
```

---

## 2. SSH & GitHub Issues

### 2.1 "Permission denied (publickey)"

**Symptom**: Git operations fail with SSH permission error.

```
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
```

**Cause**: SSH key not added to GitHub or SSH agent not running.

**Solution**:
```bash
# Check if SSH key exists
ls -la ~/.ssh/id_ed25519.pub

# Add key to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Test GitHub connection
ssh -T git@github.com

# If key not on GitHub, copy and add:
cat ~/.ssh/id_ed25519.pub | pbcopy
# Then add at: https://github.com/settings/keys
```

---

### 2.2 SSH key not found after reboot

**Symptom**: SSH works until reboot, then stops.

**Cause**: SSH agent doesn't persist keys across reboots by default.

**Solution**:
```bash
# Add to macOS Keychain (persists across reboots)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Verify it's in keychain
ssh-add -l
```

---

### 2.3 "Host key verification failed"

**Symptom**: SSH connection fails with host key error.

**Cause**: GitHub's host key changed or known_hosts corrupted.

**Solution**:
```bash
# Remove old GitHub entry
ssh-keygen -R github.com

# Re-add GitHub's host key
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Test connection
ssh -T git@github.com
```

---

## 3. Homebrew Issues

### 3.1 "Error: Cask 'X' is not installed"

**Symptom**: Homebrew reports app not installed during rebuild.

**Cause**: App was manually removed or Homebrew lost track.

**Solution**:
```bash
# Force reinstall via rebuild
brew uninstall --cask <app-name> 2>/dev/null || true
rebuild

# If persists, clean Homebrew cache
brew cleanup --prune=all
rebuild
```

---

### 3.2 Homebrew cask installs wrong version

**Symptom**: App version doesn't match expected.

**Cause**: Homebrew cask has outdated formula.

**Solution**:
```bash
# Update Homebrew first
brew update

# Reinstall cask
brew reinstall --cask <app-name>

# Force specific version if needed
brew install --cask <app-name>@<version>
```

---

### 3.3 "Error: It seems there is already an App at '/Applications/X.app'"

**Symptom**: Cask install fails because app already exists.

**Cause**: App was installed manually or from another source.

**Solution**:
```bash
# Move existing app to trash
mv "/Applications/App Name.app" ~/.Trash/

# Reinstall via Homebrew
rebuild

# Or force overwrite
brew install --cask --force <app-name>
```

---

### 3.4 Mac App Store apps fail to install

**Symptom**: Apps from Mac App Store (via mas) fail during rebuild.

**Cause**: Not signed into Mac App Store, or app not previously purchased.

**Solution**:
```bash
# Check Mac App Store sign-in status
mas account

# If not signed in:
# 1. Open App Store.app
# 2. Sign in with Apple ID
# 3. Retry rebuild

# If "not previously purchased" error:
# 1. Open App Store.app
# 2. Search and install app manually first
# 3. Then rebuild will manage it
```

---

## 4. Podman Issues

### 4.1 "Cannot connect to Podman machine"

**Symptom**: Podman commands fail with connection errors.

```
Cannot connect to Podman. Please verify your connection to the Linux system...
```

**Cause**: Podman machine not running or not initialized.

**Solution**:
```bash
# Check machine status
podman machine list

# If not initialized
podman machine init

# Start the machine
podman machine start

# Verify
podman info
```

---

### 4.2 Podman machine won't start

**Symptom**: `podman machine start` fails or hangs.

**Cause**: Corrupted machine state or resource conflicts.

**Solution**:
```bash
# Stop any running machine
podman machine stop

# Remove and recreate
podman machine rm
podman machine init
podman machine start

# If persists, check system resources
# Podman needs ~2GB RAM for the VM
```

---

### 4.3 "Error: image not known"

**Symptom**: Can't pull or run container images.

**Cause**: Network issues or registry authentication required.

**Solution**:
```bash
# Test network connectivity
curl -I https://registry.hub.docker.com

# Try explicit pull
podman pull docker.io/library/<image>:<tag>

# For private registries, login first
podman login <registry-url>
```

---

### 4.4 Containers can't access network

**Symptom**: Containers start but can't reach internet.

**Cause**: DNS resolution or network mode issues.

**Solution**:
```bash
# Check Podman machine networking
podman machine ssh -- cat /etc/resolv.conf

# Use host network mode for testing
podman run --network=host <image>

# Restart machine to reset networking
podman machine stop && podman machine start
```

---

## 5. Nix Store Issues

### 5.1 "error: getting status of '/nix/store/...' : No such file or directory"

**Symptom**: Build fails because store path doesn't exist.

**Cause**: Nix store corruption or incomplete garbage collection.

**Solution**:
```bash
# Repair Nix store
sudo nix-store --verify --check-contents --repair

# If specific path, try rebuilding it
nix-store --realise <store-path>

# Full rebuild
rebuild
```

---

### 5.2 Disk space full (/nix partition)

**Symptom**: Builds fail with "No space left on device".

**Cause**: Too many old generations or large packages accumulated.

**Solution**:
```bash
# Run garbage collection
gc

# More aggressive cleanup
sudo nix-collect-garbage -d  # Deletes ALL old generations

# Check space freed
df -h /nix

# Full cleanup with optimization
cleanup
```

---

### 5.3 "error: cannot link '/nix/store/...' : Operation not permitted"

**Symptom**: Nix operations fail with permission errors.

**Cause**: Nix store permissions corrupted or SIP issues.

**Solution**:
```bash
# Fix Nix store permissions
sudo chown -R root:nixbld /nix/store
sudo chmod 1775 /nix/store
sudo chmod -R a+r /nix/store

# Restart Nix daemon
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon
```

---

## 6. Application Issues

### 6.1 App crashes on launch after update

**Symptom**: App worked before `update`, now crashes immediately.

**Cause**: Bad update or incompatible version.

**Solution**:
```bash
# Rollback to previous generation
darwin-rebuild --rollback

# List available generations
darwin-rebuild --list-generations

# Once working, wait for upstream fix before updating again
```

---

### 6.2 App settings reset after rebuild

**Symptom**: Application preferences lost after `rebuild`.

**Cause**: App stores settings in locations managed by Nix/Home Manager.

**Solution**:
```bash
# For Home Manager apps, settings should be in .nix files
# Check if app has a Home Manager module
ls ~/Documents/nix-install/home-manager/modules/

# Add persistent settings to the module
# Example for Zed:
# programs.zed.userSettings = { ... };

# For non-managed apps, settings persist in ~/Library/
# No action needed
```

---

### 6.3 Ollama models missing

**Symptom**: `ollama list` shows no models or missing expected models.

**Cause**: Model download didn't complete or models deleted.

**Solution**:
```bash
# Check current models
ollama list

# Re-pull missing models
ollama pull gpt-oss:20b

# For Power profile, pull all expected models:
ollama pull gpt-oss:20b
ollama pull qwen2.5-coder:32b
ollama pull llama3.1:70b
ollama pull deepseek-r1:32b

# Verify
ollama list
```

---

## 7. Shell & Terminal Issues

### 7.1 Starship prompt not showing

**Symptom**: Terminal shows basic prompt instead of Starship.

**Cause**: Starship not initialized in shell config.

**Solution**:
```bash
# Check if Starship is installed
which starship

# Verify .zshrc has Starship init
grep starship ~/.zshrc

# If missing, source zshrc or restart terminal
source ~/.zshrc

# Or run rebuild to regenerate configs
rebuild
```

---

### 7.2 Aliases not working

**Symptom**: Custom aliases like `rebuild`, `update` not found.

**Cause**: Shell config not sourced after changes.

**Solution**:
```bash
# Source the config
source ~/.zshrc

# Or open new terminal window

# Verify alias exists
alias | grep rebuild
```

---

### 7.3 FZF keybindings not working

**Symptom**: Ctrl+R, Ctrl+T don't trigger FZF.

**Cause**: FZF shell integration not loaded.

**Solution**:
```bash
# Check FZF is installed
which fzf

# Source FZF keybindings manually
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Verify by trying Ctrl+R in new terminal
# Should show FZF history search, not standard reverse-i-search
```

---

### 7.4 Ghostty theme doesn't match system appearance

**Symptom**: Ghostty shows light theme in dark mode (or vice versa).

**Cause**: Ghostty config not set to follow system appearance.

**Solution**:
```bash
# Check Ghostty config
cat ~/.config/ghostty/config | grep theme

# Should have: theme = auto (or similar)
# If not, rebuild to regenerate config
rebuild

# Restart Ghostty after rebuild
```

---

## 8. System Preferences Issues

### 8.1 Finder settings not applied

**Symptom**: Finder doesn't show hidden files, path bar, etc.

**Cause**: Settings require Finder restart or logout.

**Solution**:
```bash
# Kill Finder to apply settings
killall Finder

# If still not applied, check macos-defaults.nix was run
# Then logout/login to fully apply

# Verify settings
defaults read com.apple.finder AppleShowAllFiles
# Should output: 1
```

---

### 8.2 Dock changes not visible

**Symptom**: Dock size, position, or auto-hide not changed.

**Cause**: Dock needs restart after defaults changes.

**Solution**:
```bash
# Restart Dock
killall Dock

# Verify settings applied
defaults read com.apple.dock autohide
# Should output: 1
```

---

### 8.3 Trackpad gestures not working

**Symptom**: Three-finger drag or tap-to-click not working.

**Cause**: Accessibility settings for three-finger drag require manual enable.

**Solution**:
```bash
# Three-finger drag is in Accessibility, not Trackpad
# System Settings → Accessibility → Pointer Control → Trackpad Options
# Enable "Use trackpad for dragging" → "Three Finger Drag"

# For tap-to-click, verify:
defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking
# Should output: 1
```

---

## 9. Rollback If Something Breaks

Every `rebuild` or `update` creates a new "generation" — a complete snapshot of your system state. If an update breaks something, you can instantly rollback.

### 9.1 List Available Generations

**Symptom**: Need to see what generations are available to rollback to.

**Solution**:
```bash
darwin-rebuild --list-generations
```

Output shows generation numbers with timestamps:
```
12   2024-01-15 14:30   (current)
11   2024-01-14 09:15
10   2024-01-10 16:45
9    2024-01-08 11:20
```

The `(current)` marker shows your active generation.

---

### 9.2 Rollback to Previous Generation

**Symptom**: Latest update broke something, need to undo immediately.

**Solution**:
```bash
darwin-rebuild --rollback
```

This instantly switches back to the previous generation. No re-downloading — it just changes symlinks.

**Verify**:
```bash
health-check
darwin-rebuild --list-generations  # Previous generation now shows (current)
```

---

### 9.3 Rollback to Specific Generation

**Symptom**: Need to go back further than just the previous generation.

**Solution**:
```bash
# First, list available generations
darwin-rebuild --list-generations

# Then switch to a specific one (e.g., generation 10)
darwin-rebuild switch --generation 10
```

---

### 9.4 What Gets Reverted

When you rollback:
- **Apps**: Revert to versions from that generation
- **Configs**: All dotfiles and settings revert
- **System packages**: CLI tools revert to previous versions
- **Homebrew casks**: Managed apps revert
- **System preferences**: macOS defaults revert

What does NOT revert:
- **User data**: Your files in ~/Documents, ~/Downloads, etc.
- **App data**: Application preferences in ~/Library (not managed by Nix)
- **Browser data**: Bookmarks, history, extensions

---

### 9.5 After Rollback

Once you've rolled back:

1. **Verify system works**:
   ```bash
   health-check
   ```

2. **Test critical apps** that were broken

3. **Decide next steps**:
   - Stay on rolled-back version and wait for upstream fix
   - Try `update` again later when fix is available
   - Delete the broken generation (optional)

---

### 9.6 Delete Broken Generations (Optional)

After confirming rollback works, you can delete broken generations to save space:

```bash
# Delete a specific generation
nix-env --delete-generations 12

# Delete multiple generations
nix-env --delete-generations 11 12 13

# Delete all generations older than 30 days
nix-env --delete-generations 30d

# Run garbage collection to free disk space
gc
```

**Warning**: Deleted generations cannot be recovered. Only delete after confirming rollback works.

---

## 10. LaunchAgent Issues

### 10.1 LaunchAgent fails with "Operation not permitted" (Exit code 126)

**Symptom**: Scheduled tasks (weekly-digest, release-monitor) fail with exit code 126.

```bash
launchctl list | grep org.nixos
-    126    org.nixos.weekly-digest
```

Error log shows:
```
bash: /path/to/script.sh: Operation not permitted
```

**Cause**: macOS TCC (Transparency, Consent, Control) blocks LaunchAgents from accessing protected folders like `~/Documents`, `~/Desktop`, `~/Downloads`.

**Solution**: Scripts must be in a non-TCC-protected location like `~/.local/bin`.

```bash
# The fix is already implemented - just rebuild
rebuild

# This syncs scripts to ~/.local/bin via activation script
# and updates LaunchAgent plists to use the new path
```

If you manually copied scripts before the fix:
```bash
# Remove quarantine attributes
xattr -d com.apple.quarantine ~/.local/bin/*.sh 2>/dev/null || true
xattr -d com.apple.provenance ~/.local/bin/*.sh 2>/dev/null || true

# Ensure correct permissions
chmod 755 ~/.local/bin/*.sh

# Reload the LaunchAgent
launchctl unload ~/Library/LaunchAgents/org.nixos.weekly-digest.plist
launchctl load ~/Library/LaunchAgents/org.nixos.weekly-digest.plist

# Test manually
launchctl start org.nixos.weekly-digest

# Check result
launchctl list | grep weekly-digest
cat /tmp/weekly-digest.log
```

---

### 10.2 LaunchAgent runs but email not sent

**Symptom**: LaunchAgent shows exit code 0 but no email received.

```bash
launchctl list | grep org.nixos
-    0    org.nixos.weekly-digest
```

But `/tmp/weekly-digest.log` only shows partial output.

**Cause**: PATH in LaunchAgent environment doesn't include Nix profile paths needed for tools like `msmtp`.

**Solution**: Ensure PATH includes `/etc/profiles/per-user/<username>/bin`:

```bash
# Check if msmtp is accessible
which msmtp
# Should show: /etc/profiles/per-user/fxmartin/bin/msmtp

# Rebuild to get updated LaunchAgent plists with correct PATH
rebuild

# Test manually
~/.local/bin/weekly-maintenance-digest.sh your@email.com
```

---

### 10.3 LaunchAgent not running at scheduled time

**Symptom**: Scheduled task never runs, `launchctl list` shows `-` for PID (never started).

**Cause**: LaunchAgent not loaded, or schedule misconfigured.

**Solution**:
```bash
# Check if agent is loaded
launchctl list | grep org.nixos

# If not listed, load it
launchctl load ~/Library/LaunchAgents/org.nixos.weekly-digest.plist

# Check the plist schedule
cat ~/Library/LaunchAgents/org.nixos.weekly-digest.plist | grep -A5 StartCalendarInterval

# LaunchAgents use LOCAL timezone (your system timezone)
# Verify your timezone
date  # Shows current time and timezone

# To test immediately without waiting
launchctl start org.nixos.weekly-digest
```

---

### 10.4 Checking LaunchAgent status and logs

**Useful commands for debugging**:

```bash
# List all nix-install LaunchAgents with status
launchctl list | grep org.nixos

# Status columns: PID, Exit Code, Label
# -    0    = Not running, last run succeeded
# -    126  = Not running, last run failed (permission denied)
# 1234 -    = Currently running (PID 1234)

# View LaunchAgent plist
cat ~/Library/LaunchAgents/org.nixos.weekly-digest.plist

# Check logs
cat /tmp/weekly-digest.log      # stdout
cat /tmp/weekly-digest.err      # stderr
cat /tmp/release-monitor.log
cat /tmp/nix-gc.log
cat /tmp/nix-optimize.log

# Manually trigger a LaunchAgent
launchctl start org.nixos.weekly-digest

# Reload after config changes
launchctl unload ~/Library/LaunchAgents/org.nixos.weekly-digest.plist
launchctl load ~/Library/LaunchAgents/org.nixos.weekly-digest.plist
```

---

### 10.5 LaunchAgent schedule reference

| Agent | Schedule | Log File |
|-------|----------|----------|
| `nix-gc` | Daily 3:00 AM | `/tmp/nix-gc.log` |
| `nix-optimize` | Daily 3:30 AM | `/tmp/nix-optimize.log` |
| `weekly-digest` | Sunday 8:00 AM | `/tmp/weekly-digest.log` |
| `release-monitor` | Monday 7:00 AM | `/tmp/release-monitor.log` |

All times are in your **local timezone**.

---

## Quick Reference Commands

| Issue | First Command to Try |
|-------|---------------------|
| Any problem | `health-check` |
| Build failures | `darwin-rebuild switch --flake .#standard --show-trace` |
| Need to undo update | `darwin-rebuild --rollback` |
| Disk space issues | `gc` then `cleanup` |
| SSH not working | `ssh -T git@github.com` |
| Podman broken | `podman machine stop && podman machine start` |
| Shell broken | `source ~/.zshrc` |
| App broken | `brew reinstall --cask <app>` |
| LaunchAgent failing | `launchctl list \| grep org.nixos` then check logs |

---

## Getting Help

If these solutions don't resolve your issue:

1. Run `health-check` and note any warnings
2. Check the [GitHub Issues](https://github.com/fxmartin/nix-install/issues)
3. Search [NixOS Discourse](https://discourse.nixos.org/)
4. Check [nix-darwin issues](https://github.com/LnL7/nix-darwin/issues)

---

**See also**:
- [Post-Install Checklist](./post-install.md)
- [Licensed Apps Guide](./licensed-apps.md)
- [README Quick Start](../README.md)
