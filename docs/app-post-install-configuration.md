# ABOUTME: Post-installation configuration steps for installed applications
# ABOUTME: Documents manual settings that cannot be automated (auto-update disable, preferences, etc.)

# Application Post-Install Configuration Guide

This document provides step-by-step instructions for configuring applications after nix-darwin installation completes.

**Philosophy**: All app updates are controlled via `rebuild` or `update` commands only. Auto-updates must be disabled for all apps that support this setting.

---

## ⚠️ IMPORTANT: Mac App Store Requirements

### Requirement 1: Sign-In Required

**Before running darwin-rebuild**, you MUST sign in to the Mac App Store:

1. Open **App Store** app
2. Click **Sign In** at the bottom of the sidebar
3. Enter your Apple ID credentials
4. Complete authentication

**Why this is required:**
- Some apps (like Perplexity) are installed via Mac App Store using `mas` (Mac App Store CLI)
- `mas` cannot install apps unless you are signed into the App Store
- darwin-rebuild will fail if trying to install mas apps without authentication

**Verification:**
```bash
# Check if signed in to App Store
mas account
# Should show your Apple ID email

# If not signed in, you'll see:
# "Not signed in"
```

**If you see "Not signed in":**
- Sign in via App Store app GUI (cannot be done via CLI)
- Then verify: `mas account` shows your email

### Requirement 2: Fresh Machine First-Install (Issue #25, #26)

**⚠️ CRITICAL**: On **brand new Macs**, the Mac App Store requires **one manual GUI install** before `mas` CLI will work.

**Symptoms of Fresh Machine**:
- Bootstrap fails with: `Error Domain=PKInstallErrorDomain Code=201`
- Error message: `"The installation could not be started"`
- Homebrew bundle fails, blocking darwin-rebuild

**Solution - Manual First Install**:
1. Open **App Store** app
2. Search for any Mac App Store app (e.g., "Perplexity")
3. Click the **cloud download icon** (☁️↓) or **GET** button
4. Wait for installation to complete
5. **Then** re-run bootstrap or darwin-rebuild

**Why This Happens**:
- Fresh macOS needs to initialize App Store installation services
- First install must be manual to accept terms, set up cache, establish permissions
- After first manual install, `mas` CLI works normally
- This is a macOS limitation, not a nix-darwin bug

**Apps Requiring This Workaround**:
- Perplexity (6714467650)
- Kindle (302584613) - if added to masApps
- WhatsApp (if using mas instead of Homebrew)
- Any other Mac App Store apps in your masApps list

---

## Table of Contents

- [AI & LLM Tools](#ai--llm-tools)
  - [Claude Desktop](#claude-desktop)
  - [ChatGPT Desktop](#chatgpt-desktop)
  - [Perplexity](#perplexity)
  - [Ollama Desktop](#ollama-desktop)
- [Development Environment Applications](#development-environment-applications)
  - [Zed Editor](#zed-editor)

---

## AI & LLM Tools

### Claude Desktop

**Status**: Installed via Homebrew cask `claude` (Story 02.1-001)

**First Launch**:
1. Launch Claude Desktop from Spotlight or Raycast
2. Sign in with your Anthropic account
3. Complete the onboarding flow

**Auto-Update Configuration**:
- **Current Status**: ⚠️ **Requires Manual Check**
- **Steps to Disable** (if available):
  1. Open Claude Desktop
  2. Navigate to **Preferences** (Cmd+,) or **Settings**
  3. Look for **General** or **Updates** section
  4. Disable automatic update checking if option exists
  5. Document actual steps after first VM test

**Testing**:
- [ ] Launch Claude Desktop successfully
- [ ] Sign-in flow completes
- [ ] Accessible from Spotlight/Raycast
- [ ] Check for auto-update setting in preferences

---

### ChatGPT Desktop

**Status**: Installed via Homebrew cask `chatgpt` (Story 02.1-001)

**First Launch**:
1. Launch ChatGPT Desktop from Spotlight or Raycast
2. Sign in with your OpenAI account
3. Complete the onboarding flow

**Auto-Update Configuration**:
- **Current Status**: ⚠️ **Requires Manual Check**
- **Steps to Disable** (if available):
  1. Open ChatGPT Desktop
  2. Navigate to **Preferences** (Cmd+,) or **Settings**
  3. Look for **General** or **Updates** section
  4. Disable automatic update checking if option exists
  5. Document actual steps after first VM test

**Testing**:
- [ ] Launch ChatGPT Desktop successfully
- [ ] Sign-in flow completes
- [ ] Accessible from Spotlight/Raycast
- [ ] Check for auto-update setting in preferences

---

### Perplexity

**Status**: Installed via **Mac App Store** (App ID: 6714467650) - Story 02.1-001

**⚠️ CRITICAL - FRESH MACHINE REQUIREMENT**: On brand new Macs, Perplexity MUST be installed manually via App Store GUI first, then darwin-rebuild can manage it.

**First-Time Installation on Fresh Mac** (Issue #25, #26):
1. Open **App Store** app
2. Search for **"Perplexity"** or navigate to your Purchased apps
3. Click the **cloud download icon** (☁️↓) to install manually
4. Wait for installation to complete
5. **Then** run darwin-rebuild (mas CLI will work after first manual install)

**Why Manual Install Required**:
- Fresh macOS installations require the first App Store install to be manual (GUI-based)
- This initializes Mac App Store services and permissions
- The `mas` CLI tool (used by nix-darwin) cannot install apps on completely fresh systems
- Error: `Code=201 "The installation could not be started"`
- After one manual install, `mas` works normally for all subsequent installs

**⚠️ PREREQUISITE**: You must be signed into the Mac App Store BEFORE running darwin-rebuild (see prerequisite section above)

**Important Notes**:
- Perplexity is distributed via Mac App Store, not Homebrew
- Released as native macOS app on October 24, 2024
- **Installation requires**: Mac App Store sign-in (mas authentication)
- **Fresh machines**: Manual GUI install required first (see above)
- Auto-updates managed by App Store preferences (not app-level settings)

**First Launch**:
1. Launch Perplexity from Spotlight or Raycast
2. Sign in with your Perplexity account (optional for basic features)
3. Complete the onboarding flow
4. Free tier: 5 Pro Searches per day
5. Pro tier: $20/month for 600 Pro Searches daily

**Auto-Update Configuration**:
- **Managed by**: macOS App Store (system-level)
- **To disable App Store auto-updates**:
  1. Open **System Settings** → **App Store**
  2. Uncheck **Automatic Updates** for all apps
  3. Or manage per-app: Right-click app in Launchpad → **Options** → **Turn Off Automatic Updates**
- **Note**: App Store updates are system-wide, not per-app for Mac App Store installations

**Testing**:
- [ ] Launch Perplexity successfully (installed from App Store)
- [ ] Sign-in flow completes (optional, not required)
- [ ] Accessible from Spotlight/Raycast
- [ ] Verify App Store update settings are disabled system-wide

**Features**:
- Pro Search with advanced AI models (GPT-4, Claude 3)
- Voice input for hands-free queries
- Threaded conversations with context
- Library feature for archived searches
- All responses include cited sources

---

### Ollama Desktop

**Status**: Installed via Homebrew cask `ollama-app` (Story 02.1-002)

**⚠️ CRITICAL - FRESH MACHINE REQUIREMENT** (Issue #25):

On **brand new Macs**, Ollama requires **manual first launch** before the daemon and CLI will work properly.

**Symptoms of Fresh Machine**:
- Activation scripts fail to pull Ollama models during darwin-rebuild
- `ollama list` prompts for Gatekeeper validation
- `ollama pull` commands fail silently or return errors
- Ollama daemon cannot start programmatically

**Solution - Manual First Launch**:
1. Launch **Ollama Desktop** from Applications folder (or Spotlight)
2. Approve macOS Gatekeeper dialog when prompted
3. Wait for menubar icon to appear (llama icon)
4. Verify daemon is running: `ollama list` (should return empty list or models)
5. **Then** re-run `darwin-rebuild switch` to pull models automatically

**Why This Happens**:
- Fresh macOS requires first launch of GUI apps to approve Gatekeeper
- Activation scripts cannot interact with GUI security prompts
- Once manually launched, daemon can start automatically in future
- This is a macOS security limitation, not a nix-darwin bug

**Models Requiring This Workaround**:
- Standard Profile: `gpt-oss:20b` (Story 02.1-003)
- Power Profile: `gpt-oss:20b`, `qwen2.5-coder:32b`, `llama3.1:70b`, `deepseek-r1:32b` (Story 02.1-004)

**Future Enhancement**: Consider using home-manager `services.ollama` with launchd (merged Jan 2025) for declarative daemon management. See Issue #25 for details.

**First Launch**:
1. Launch Ollama Desktop from Spotlight or Raycast
2. Menubar icon appears (llama icon in top-right)
3. Click menubar icon to access model management
4. No sign-in required (runs locally)

**CLI Verification**:
```bash
# Verify Ollama CLI is available
ollama --version

# Test with small model (optional)
ollama run llama2 "Hello, world!"
```

**Auto-Update Configuration**:
- **Current Status**: ⚠️ **Requires Manual Check**
- **Steps to Disable** (if available):
  1. Click Ollama menubar icon
  2. Look for **Preferences** or **Settings**
  3. Check for **Updates** or **General** section
  4. Disable automatic update checking if option exists
  5. Document actual steps after first VM test

**Daemon Management**:
- Ollama daemon runs automatically when desktop app launches
- Check daemon status: `ollama list` (lists installed models)
- Daemon starts on login automatically

**Model Storage**:
- Models stored in: `~/Library/Application Support/Ollama`
- Can be large (12GB-70GB per model)
- Storage location managed by Ollama automatically

**Testing**:
- [ ] Launch Ollama Desktop successfully
- [ ] Menubar icon appears
- [ ] `ollama --version` works in terminal
- [ ] Can pull a test model: `ollama pull llama2`
- [ ] Can run model: `ollama run llama2 "test"`
- [ ] GUI shows model list
- [ ] Check for auto-update setting in preferences

**Notes**:
- No account/sign-in required
- Runs models locally on your Mac
- Storage: Stories 02.1-003 and 02.1-004 will pull specific models automatically

---

## Development Environment Applications

### Zed Editor

**Status**: Installed via Homebrew cask `zed` (Story 02.2-001)

**Configuration**: Managed declaratively via Home Manager (`home-manager/modules/zed.nix`)

**Key Features Configured**:
- **Theme**: Catppuccin (Mocha for dark mode, Latte for light mode)
- **Font**: JetBrains Mono Nerd Font with ligatures enabled
- **Auto-Update**: Disabled in settings.json (updates via `rebuild` command only)
- **System Theme Sync**: Automatically follows macOS system appearance (light/dark)

**First Launch**:
1. Launch Zed from Spotlight, Raycast, or `/Applications/Zed.app`
2. Zed should open with Catppuccin theme already applied
3. Font should be JetBrains Mono with ligatures
4. No sign-in required (Zed is free and open source)

**Configuration Verification**:
```bash
# Check Zed settings.json (managed by Home Manager)
cat ~/.config/zed/settings.json

# Expected to see:
# - "auto_update": false
# - "theme": { "mode": "system", "light": "Catppuccin Latte", "dark": "Catppuccin Mocha" }
# - "buffer_font_family": "JetBrains Mono"
# - "buffer_font_features": { "calt": true }
```

**Auto-Update Configuration**:
- **Status**: ✅ **Disabled via settings.json**
- **Implementation**: Home Manager writes `"auto_update": false` to settings.json
- **Verification**: Check **Zed → Settings** (Cmd+,) → should NOT see update prompts
- **Note**: If Zed shows update notifications, check that settings.json is present

**Theme Switching**:
- **Light Mode**: macOS System Settings → Appearance → Light → Zed uses Catppuccin Latte
- **Dark Mode**: macOS System Settings → Appearance → Dark → Zed uses Catppuccin Mocha
- **Automatic**: Theme switches instantly when macOS appearance changes

**Customization**:
- Edit `home-manager/modules/zed.nix` to modify settings
- Run `darwin-rebuild switch` to apply changes
- Zed will automatically reload settings.json changes

**Testing**:
- [ ] Launch Zed successfully
- [ ] Theme matches macOS system appearance (Catppuccin Latte/Mocha)
- [ ] Font is JetBrains Mono with ligatures working (→ ≠ ≥ ≤ etc.)
- [ ] Auto-update disabled (no update prompts)
- [ ] Theme switches when toggling macOS light/dark mode
- [ ] Settings.json exists at ~/.config/zed/settings.json
- [ ] Zed recognizes common file types (nix, md, py, sh, json)

**Optional Features** (can be enabled later):
- **AI Assistant**: Zed supports AI features via API keys (disabled by default)
- **Vim Mode**: Set `"vim_mode": true` in zed.nix if desired
- **Language Servers**: Epic-04 will add LSP servers for Python, Nix, Bash, etc.

**Known Issues**:
- None currently known
- If theme doesn't apply, verify Catppuccin theme is installed in Zed
  - Check: **Zed → Extensions** for "Catppuccin" theme
  - Theme should be built-in as of Zed 0.130+

**Resources**:
- Zed Documentation: https://zed.dev/docs
- Catppuccin Theme: https://github.com/catppuccin/zed
- JetBrains Mono Font: https://www.jetbrains.com/lp/mono/

---

## Notes for FX

**VM Testing Workflow**:
1. After `darwin-rebuild switch`, verify all apps are installed in `/Applications`
2. Launch each app and complete the first-run setup
3. Check preferences for auto-update settings
4. Document actual steps found during testing
5. Update this file with confirmed steps

**Update Control Philosophy**:
- ✅ All app updates ONLY via `rebuild` or `update` commands
- ✅ Homebrew auto-update disabled globally (`HOMEBREW_NO_AUTO_UPDATE=1`)
- ⚠️ Some apps may not expose auto-update toggle (document as "no setting available")
- ✅ Apps without auto-update settings will still be controlled via Homebrew version pinning

**Common Auto-Update Locations**:
- Preferences → General → Updates
- Settings → Advanced → Auto-update
- Menu Bar → App Name → Preferences → Updates
- Some apps use system Sparkle updater (check "Check for updates" menu item)

---

## Story Tracking

**Story 02.1-001**: Claude Desktop, ChatGPT, Perplexity - ✅ Installation implemented
  - **Hotfix #14 (Issue #24)**: Perplexity moved to Mac App Store (no Homebrew cask available)
  - ⚠️ Auto-update configuration pending VM test (Claude, ChatGPT)
  - ℹ️ Perplexity auto-updates managed by App Store system preferences
**Story 02.1-002**: Ollama Desktop App - ✅ Installation implemented, ⚠️ CLI and GUI testing pending VM test
**Story 02.2-001**: Zed Editor - ✅ Installation and configuration implemented
  - ✅ Homebrew cask added to darwin/homebrew.nix
  - ✅ Home Manager module created (home-manager/modules/zed.nix)
  - ✅ Catppuccin theming configured (Latte/Mocha with system appearance sync)
  - ✅ JetBrains Mono font with ligatures enabled
  - ✅ Auto-update disabled in settings.json
  - ⚠️ VM testing pending: Theme application, font rendering, auto-update behavior

---
