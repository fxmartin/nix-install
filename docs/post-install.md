# ABOUTME: Post-install checklist for completing MacBook setup after bootstrap
# ABOUTME: Ordered list of manual steps with checkboxes for tracking completion

# Post-Install Checklist

After bootstrap completes successfully, complete these steps to finalize your setup.

**Estimated Time**: 10-15 minutes (excluding Office 365 download)

---

## 1. Immediate Steps (Required)

- [ ] **Restart Terminal** or run `source ~/.zshrc`
  - Opens a new shell with all configurations loaded
  - Alternatively, quit and reopen Terminal/Ghostty

- [ ] **Verify shell prompt**
  - Should show Starship prompt with directory and git info
  - If not, check: `echo $STARSHIP_SHELL` (should output path)

- [ ] **Run health check**
  ```bash
  health-check
  ```
  - Verifies Nix daemon, Homebrew, disk space, security settings
  - Address any warnings shown

---

## 2. Security (Required)

- [ ] **Enable FileVault** (if not already enabled)
  1. System Settings → Privacy & Security → FileVault
  2. Click "Turn On FileVault"
  3. Choose recovery method:
     - **Recommended**: Use iCloud account (easiest recovery)
     - **Alternative**: Create recovery key (save to 1Password)
  4. Restart to begin encryption (runs in background)
  5. Verify: `fdesetup status` should show "FileVault is On"

---

## 3. Licensed Apps (Required)

Activate apps requiring sign-in or license keys. See [Licensed Apps Guide](./licensed-apps.md) for detailed steps.

**Sign-in Apps** (~5 minutes):
- [ ] **1Password** - Sign in with email + Secret Key + master password
- [ ] **Dropbox** - Sign in, choose sync folder (default: ~/Dropbox)
- [ ] **NordVPN** - Sign in, grant network extension permission
- [ ] **Zoom** - Sign in (or use free account)
- [ ] **Webex** - Sign in with company credentials

**License Key Apps** (~2 minutes):
- [ ] **iStat Menus** - Enter license key (or start 14-day trial)
- [ ] **Parallels Desktop** (Power profile only) - Enter license key

**Disable Auto-Updates** (CRITICAL):
- [ ] Each app above: Preferences → disable auto-update
- [ ] This ensures updates only via `rebuild` command

---

## 4. Optional Steps

### Office 365 (If Needed)

- [ ] **Install Office 365** manually
  1. Visit https://office.com or company portal
  2. Sign in with Microsoft account
  3. Click "Install Office" → Download installer
  4. Run installer and wait for completion (~10-15 min download)
  5. Launch any Office app → Sign in to activate
  6. **Disable auto-update** in each Office app:
     - Word/Excel/etc → Preferences → AutoUpdate → Uncheck

### Ollama Models (Power Profile)

- [ ] **Verify Ollama models installed**
  ```bash
  ollama list
  ```
  Expected models:
  - `gpt-oss:20b` (~12GB)
  - `qwen2.5-coder:32b` (~20GB)
  - `llama3.1:70b` (~40GB)
  - `deepseek-r1:32b` (~20GB)

- [ ] **Test a model**
  ```bash
  ollama run gpt-oss:20b "Hello, how are you?"
  ```

### Raycast Configuration

- [ ] **Set Raycast hotkey**
  1. Launch Raycast (Spotlight: Cmd+Space, type "Raycast")
  2. Preferences → General → Raycast Hotkey
  3. Recommended: `Opt+Space` (keeps Cmd+Space for Spotlight)

### Default Browser

- [ ] **Set default browser** (optional)
  1. System Settings → Desktop & Dock → Default web browser
  2. Choose Arc or Brave

---

## 5. Verify Installation

Run these commands to confirm everything works:

### Shell Environment
```bash
# Starship prompt working
echo $STARSHIP_SHELL

# FZF working (Ctrl+R for history)
echo "test" | fzf

# Modern CLI tools
bat --version      # Better cat
eza --version      # Better ls
rg --version       # ripgrep
zoxide --version   # Better cd
```

### Development Tools
```bash
# Python
python --version   # Should show 3.12.x
uv --version       # Python package manager
ruff --version     # Python linter

# Git
git config user.name
git config user.email

# Podman
podman --version
podman machine list  # Should show default machine
```

### Applications
- [ ] Open **Ghostty** terminal - should have Catppuccin theme
- [ ] Open **Zed** editor - theme should match system (light/dark)
- [ ] Open **Arc** browser - should launch without issues
- [ ] Run `podman run hello-world` - should complete successfully

---

## 6. Learn Common Commands

Your new aliases (see full list with `alias`):

| Command | Description |
|---------|-------------|
| `rebuild` | Apply config changes |
| `update` | Update all packages + rebuild |
| `gc` | Garbage collection |
| `cleanup` | Full cleanup (gc + optimize) |
| `health-check` | System health report |

---

## Done!

Your Mac is now fully configured.

**Next steps**:
- Read the [README](../README.md) for common commands
- Run `update` weekly to keep packages current
- Use `health-check` to diagnose issues

**If something breaks**:
```bash
darwin-rebuild --rollback  # Instant rollback to previous generation
```
