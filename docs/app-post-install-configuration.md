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

### Requirement 3: Terminal Full Disk Access for Homebrew Cleanup (Hotfix #18)

**⚠️ OPTIONAL**: When disabling or removing apps via darwin-rebuild, Homebrew may need **Full Disk Access** to completely uninstall applications.

**When This Is Needed**:
- You see a message: "Terminal needs Full Disk Access to complete uninstallation"
- You're removing/disabling apps via Homebrew configuration changes
- You want complete cleanup of removed applications

**Symptoms Without Permission**:
```
Warning: To complete uninstallation, grant Full Disk Access to your Terminal app
Settings → Privacy & Security → Full Disk Access
```

**What Happens Without Permission**:
- ✅ App is disabled in configuration
- ✅ darwin-rebuild completes successfully
- ✅ System works correctly
- ⚠️ Some app remnant files may remain in `/Applications/` or `~/Library/`

**Solution - Grant Full Disk Access (Optional)**:

1. **Open System Settings**:
   - Click **Apple menu** () → **System Settings**
   - Navigate to **Privacy & Security** → **Full Disk Access**

2. **Add Your Terminal App**:
   - Click the **lock icon** 🔒 and authenticate
   - Click the **+** button (plus sign)
   - Navigate to and select your terminal app:
     - **Ghostty**: `/Applications/Ghostty.app`
     - **Terminal**: `/Applications/Utilities/Terminal.app`
     - **iTerm2**: `/Applications/iTerm.app`
   - Click **Open**

3. **Enable the Toggle**:
   - Ensure the checkbox next to your terminal app is **ON** (blue)

4. **Re-run darwin-rebuild** (for complete cleanup):
   ```bash
   sudo darwin-rebuild switch --flake ~/nix-install#power
   # or
   sudo darwin-rebuild switch --flake ~/nix-install#standard
   ```

5. **Verify Cleanup**:
   - Homebrew should now complete uninstallation cleanly
   - No warning messages about Full Disk Access

**Why This Is Needed**:
- macOS privacy protection prevents apps from deleting certain files without explicit permission
- Homebrew needs access to `/Applications/`, `~/Library/`, and other system locations
- Full Disk Access allows Homebrew to completely remove disabled apps

**Is This Required?**:
- ✅ **NO** - Your system works without it
- ✅ **YES** - If you want perfectly clean uninstallation
- ✅ **Optional** - Grant permission only if you want complete cleanup

**Security Note**:
- Full Disk Access is a powerful permission
- Only grant to terminal apps you trust
- You can revoke it later in System Settings → Privacy & Security

**Example - VSCode Removal (Hotfix #18)**:
When VSCode was disabled due to Electron crashes:
1. darwin-rebuild disabled VSCode successfully ✅
2. Homebrew requested Full Disk Access for complete removal ⚠️
3. Granting access allowed Homebrew to clean up all VSCode files ✅
4. System works correctly with or without granting access ✅

---

## Table of Contents

- [AI & LLM Tools](#ai--llm-tools)
  - [Claude Desktop](#claude-desktop)
  - [ChatGPT Desktop](#chatgpt-desktop)
  - [Perplexity](#perplexity)
  - [Ollama Desktop](#ollama-desktop)
- [Development Environment Applications](#development-environment-applications)
  - [Zed Editor](#zed-editor)
  - [VSCode](#vscode)
  - [Ghostty Terminal](#ghostty-terminal)
  - [Python and Development Tools](#python-and-development-tools)
  - [Podman and Container Tools](#podman-and-container-tools)
- [Browsers](#browsers)
  - [Brave Browser](#brave-browser)
  - [Arc Browser](#arc-browser)
- [Productivity & Utilities](#productivity--utilities)
  - [Raycast](#raycast)
  - [1Password](#1password)
  - [Calibre](#calibre)
  - [Kindle](#kindle)
  - [Keka](#keka)
  - [Marked 2](#marked-2)
  - [Onyx](#onyx)
  - [f.lux](#flux)

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

**✅ AUTO-CONFIGURED with BIDIRECTIONAL SYNC**: Settings symlinked to repo (Issue #26 resolution)

**How Bidirectional Sync Works**:
1. Settings file in repo: `config/zed/settings.json` (version controlled)
2. On `darwin-rebuild`, activation script creates: `~/.config/zed/settings.json` → `~/nix-install/config/zed/settings.json`
3. Changes sync both ways:
   - **Zed → Repo**: Modify settings in Zed → Changes instantly appear in repo (git shows them)
   - **Repo → Zed**: Pull updates or edit repo file → Zed sees changes immediately
4. Zed has full write access (symlink points to working directory, not read-only /nix/store)

**First Launch**:
1. Launch Zed from Spotlight, Raycast, or `/Applications/Zed.app`
2. Settings already configured from template
3. No sign-in required (Zed is free and open source)

**Pre-Configured Settings** (from template):

The following settings are automatically configured from `config/zed/settings.json`:

1. **Auto-Update Disabled** (CRITICAL):
   - `"auto_update": false`
   - Updates only via `rebuild` or `update` commands
   - Ensures controlled update philosophy

2. **Catppuccin Theme with System Appearance**:
   - `"theme": { "mode": "system", "light": "Catppuccin Latte", "dark": "Catppuccin Mocha" }`
   - Automatically follows macOS system appearance (light/dark mode)
   - Instant theme switching when macOS appearance changes

3. **JetBrains Mono Font with Ligatures**:
   - `"buffer_font_family": "JetBrains Mono"`
   - `"buffer_font_size": 14`
   - `"buffer_font_features": { "calt": true }` - Enables ligatures (→ ≠ ≥ ≤ etc.)
   - Consistent with terminal (Ghostty) font

4. **Telemetry Disabled**:
   - `"telemetry": { "diagnostics": false, "metrics": false }`
   - Privacy-focused configuration

5. **Git Integration Enabled**:
   - `"git": { "git_gutter": "tracked_files", "inline_blame": { "enabled": true } }`
   - Shows git changes in gutter
   - Displays inline blame information

6. **Additional Settings**:
   - Tab size: 2 spaces
   - Soft wrap at editor width
   - Terminal integration with Zsh
   - Project panel docked left (240px width)
   - Vim mode disabled (set to `true` if preferred)

**Viewing/Modifying Settings**:
- **View current settings**: Press `Cmd+,` or click **Zed → Settings**
- **Settings location**: `~/.config/zed/settings.json` (symlinked to `~/nix-install/config/zed/settings.json`)
- **Modify anytime**: Zed has full write access, changes instantly sync to repo
- **Version controlled**: Settings tracked by git, can commit/revert changes

**Workflow Options**:

1. **Edit in Zed** (most common):
   ```bash
   # 1. Open Zed settings (Cmd+,)
   # 2. Modify settings.json
   # 3. Save (Cmd+S)
   # 4. Check git status to see changes:
   git status
   # Shows: modified: config/zed/settings.json

   # 5. Commit your changes:
   git add config/zed/settings.json
   git commit -m "feat(zed): enable vim mode"
   git push
   ```

2. **Edit in repo** (for bulk changes):
   ```bash
   # 1. Edit directly in repo
   vim ~/nix-install/config/zed/settings.json

   # 2. Zed sees changes immediately (if running)
   # 3. Commit and push
   git add config/zed/settings.json
   git commit -m "feat(zed): update theme preferences"
   git push
   ```

3. **Pull updates** (sync from other machines):
   ```bash
   # Pull changes from repo
   git pull

   # Zed automatically uses updated settings (if running, may need restart)
   ```

**Theme Switching Verification**:
- **Light Mode**: System Settings → Appearance → Light → Zed should use Catppuccin Latte
- **Dark Mode**: System Settings → Appearance → Dark → Zed should use Catppuccin Mocha
- Theme switches automatically when macOS appearance changes

**Testing**:
- [ ] Launch Zed successfully
- [ ] Theme matches macOS system appearance (Catppuccin Latte/Mocha)
- [ ] Font is JetBrains Mono with ligatures working (→ ≠ ≥ ≤ etc.)
- [ ] Auto-update disabled (no update prompts in Zed menu)
- [ ] Theme switches when toggling macOS light/dark mode
- [ ] Settings.json saved successfully at ~/.config/zed/settings.json
- [ ] Zed recognizes common file types (nix, md, py, sh, json)

**Optional Features** (can be enabled later):
- **AI Assistant**: Zed supports AI features via API keys (add `"assistant": { "enabled": true }`)
- **Vim Mode**: Set `"vim_mode": true` in settings.json if desired
- **Language Servers**: Epic-04 will add LSP servers for Python, Nix, Bash, etc.

**Known Issues**:
- **Issue #26**: ✅ **RESOLVED** - Settings symlinked to repo for bidirectional sync
  - Previous issue: Home Manager symlinks to /nix/store were read-only
  - Current solution: Symlink to repo working directory (not /nix/store)
  - Benefits: Bidirectional sync, version control, git tracking
  - Changes in Zed instantly appear in repo, pull updates instantly apply to Zed
- If Catppuccin theme not available:
  - Check **Zed → Extensions** and install "Catppuccin" theme
  - Theme should be built-in as of Zed 0.130+

**Resources**:
- Zed Documentation: https://zed.dev/docs
- Zed Settings Reference: https://zed.dev/docs/configuring-zed
- Catppuccin Theme: https://github.com/catppuccin/zed
- JetBrains Mono Font: https://www.jetbrains.com/lp/mono/

---

### VSCode

**Status**: Installed via Homebrew cask `visual-studio-code` (Story 02.2-002)

**✅ AUTO-CONFIGURED with BIDIRECTIONAL SYNC**: Settings symlinked to repo (REQ-NFR-008 compliant)

**How Bidirectional Sync Works**:
1. Settings file in repo: `config/vscode/settings.json` (version controlled)
2. On `darwin-rebuild`, activation script creates: `~/Library/Application Support/Code/User/settings.json` → `~/nix-install/config/vscode/settings.json`
3. Changes sync both ways:
   - **VSCode → Repo**: Modify settings in VSCode → Changes instantly appear in repo (git shows them)
   - **Repo → VSCode**: Pull updates or edit repo file → VSCode sees changes immediately
4. VSCode has full write access (symlink points to working directory, not read-only /nix/store)

**First Launch**:
1. Launch VSCode from Spotlight, Raycast, or `/Applications/Visual Studio Code.app`
2. Settings already configured from template
3. No sign-in required (optional: Sign in with GitHub for Settings Sync)

**Pre-Configured Settings** (from template):

The following settings are automatically configured from `config/vscode/settings.json`:

1. **Auto-Update Disabled** (CRITICAL):
   - `"update.mode": "none"`
   - `"extensions.autoUpdate": false`
   - `"extensions.autoCheckUpdates": false`
   - Updates only via `rebuild` or `update` commands
   - Ensures controlled update philosophy

2. **Catppuccin Theme**:
   - `"workbench.colorTheme": "Catppuccin Mocha"`
   - `"workbench.iconTheme": "catppuccin-mocha"`
   - **IMPORTANT**: Catppuccin theme extension must be installed manually (see Extensions section below)

3. **JetBrains Mono Font with Ligatures**:
   - `"editor.fontFamily": "JetBrains Mono, Menlo, Monaco, 'Courier New', monospace"`
   - `"editor.fontSize": 14`
   - `"editor.fontLigatures": true`
   - Consistent with terminal (Ghostty) and Zed font

4. **Telemetry Disabled**:
   - `"telemetry.telemetryLevel": "off"`
   - `"redhat.telemetry.enabled": false`
   - Privacy-focused configuration

5. **Git Integration Enabled**:
   - Auto-fetch disabled (controlled updates)
   - Smart commit enabled
   - Decorations enabled
   - Tree view mode for SCM panel

6. **Terminal Integration**:
   - Default shell: Zsh
   - Font: JetBrains Mono (matching editor)

7. **Language-Specific Settings**:
   - **Nix**: 2-space indentation, format on save
   - **Python**: 4-space indentation, Ruff formatter
   - **Markdown**: Word wrap enabled, suggestions disabled
   - **JSON/JSONC**: VSCode formatter

8. **Additional Settings**:
   - Format on save enabled
   - Trim trailing whitespace
   - Insert final newline
   - Bracket pair colorization
   - 80/120 character rulers
   - Explorer: Disable delete/drag confirmation

**Required Extensions**:

✅ **AUTOMATICALLY INSTALLED** during `darwin-rebuild`:

The following extensions are automatically installed via Home Manager activation script:

1. **Catppuccin Theme** (`Catppuccin.catppuccin-vsc`):
   - Provides both dark (Mocha) and light (Latte) themes
   - Auto-installed first (required for theme switching)
   - Theme activates automatically (already configured in settings.json)

2. **Auto Dark Mode** (`LinusU.auto-dark-mode`):
   - Automatically switches VSCode theme based on macOS system appearance
   - Auto-installed second (requires Catppuccin to be installed first)
   - **Behavior**:
     - macOS Light Mode → Catppuccin Latte (light theme)
     - macOS Dark Mode → Catppuccin Mocha (dark theme)
   - **Configuration**: Already pre-configured in settings.json (Issue #28 resolution)
     - `autoDarkMode.darkTheme: "Catppuccin Mocha"`
     - `autoDarkMode.lightTheme: "Catppuccin Latte"`
     - `window.autoDetectColorScheme: true` (REQUIRED - enables the extension)
   - **Why**: Matches Zed editor behavior (system appearance sync)
   - **Test**: Toggle macOS appearance (System Settings → Appearance) and VSCode will switch themes automatically
   - **✅ VM Tested**: Confirmed working on 2025-11-12

**How Auto-Installation Works**:
- Extensions install during `darwin-rebuild` via VSCode CLI (`code --install-extension`)
- Installation is idempotent (safe to run multiple times)
- If extensions already installed, script skips them
- If VSCode CLI not available, displays instructions for manual installation

**First-Time Setup Requirement**:
If this is your first VSCode installation:
1. Launch VSCode once (this registers the `code` CLI command)
2. Quit VSCode
3. Run `darwin-rebuild switch` again
4. Extensions will auto-install
5. Launch VSCode - themes active!

**Manual Installation (Fallback)**:

If auto-installation fails for any reason, install manually **IN ORDER**:

1. **Catppuccin Theme** (REQUIRED - Install First):
   - Open Extensions panel (Cmd+Shift+X)
   - Search: "Catppuccin"
   - Install: "Catppuccin for VSCode" by Catppuccin

2. **Auto Dark Mode** (REQUIRED - Install Second):
   - Open Extensions panel (Cmd+Shift+X)
   - Search: "Auto Dark Mode"
   - Install: "Auto Dark Mode" by LinusU
   - Version: 0.1.7 (macOS-specific)

**Optional Extensions**:

3. **Claude Code** (RECOMMENDED for AI pair programming):
   - Open Extensions panel (Cmd+Shift+X)
   - Search: "Claude Code"
   - Install: "Claude Code" by Anthropic
   - Sign in with Anthropic account when prompted
   - Note: Not auto-installed (license/account required)

**Optional Extensions** (can be installed later):

- **Nix IDE** - Nix language support (syntax highlighting, LSP)
- **Ruff** - Python linting and formatting (charliermarsh.ruff)
- **markdownlint** - Markdown linting and style checking
- **shellcheck** - Shell script linting
- **GitLens** - Enhanced Git integration
- **Error Lens** - Inline error/warning highlighting
- **Path Intellisense** - File path autocompletion
- **Todo Tree** - Highlight and track TODO comments

**Viewing/Modifying Settings**:
- **View current settings**: Press `Cmd+,` or click **Code → Settings → Settings**
- **Settings location**: `~/Library/Application Support/Code/User/settings.json` (symlinked to `~/nix-install/config/vscode/settings.json`)
- **Modify anytime**: VSCode has full write access, changes instantly sync to repo
- **Version controlled**: Settings tracked by git, can commit/revert changes

**Workflow Options**:

1. **Edit in VSCode** (most common):
   ```bash
   # 1. Open VSCode settings (Cmd+,)
   # 2. Switch to JSON view (click {} icon in top-right)
   # 3. Modify settings.json
   # 4. Save (Cmd+S)
   # 5. Check git status to see changes:
   git status
   # Shows: modified: config/vscode/settings.json

   # 6. Commit your changes:
   git add config/vscode/settings.json
   git commit -m "feat(vscode): add custom keybindings"
   git push
   ```

2. **Edit in repo** (for bulk changes):
   ```bash
   # 1. Edit directly in repo
   vim ~/nix-install/config/vscode/settings.json

   # 2. VSCode sees changes immediately (if running)
   # 3. Commit and push
   git add config/vscode/settings.json
   git commit -m "feat(vscode): update language settings"
   git push
   ```

3. **Pull updates** (sync from other machines):
   ```bash
   # Pull changes from repo
   git pull

   # VSCode automatically uses updated settings (may need restart)
   ```

**Testing**:
- [ ] Launch VSCode successfully
- [ ] Settings symlink created at ~/Library/Application Support/Code/User/settings.json
- [ ] Install Catppuccin theme extension
- [ ] Theme applies correctly (Catppuccin Mocha)
- [ ] Font is JetBrains Mono with ligatures working (→ ≠ ≥ ≤ etc.)
- [ ] Auto-update disabled (no update prompts in VSCode)
- [ ] Install Claude Code extension
- [ ] Terminal integration works (opens Zsh)
- [ ] Git integration works (shows changes, decorations)
- [ ] Language-specific settings apply (test .nix, .py, .md files)
- [ ] Bidirectional sync: Edit in VSCode, verify git shows changes
- [ ] Bidirectional sync: Edit repo file, verify VSCode sees changes

**Known Issues**:
- **Theme not applied**: Install Catppuccin theme extension first (Extensions panel)
- **Settings not syncing**: Verify symlink exists at ~/Library/Application Support/Code/User/settings.json
- If symlink broken: Re-run `darwin-rebuild switch` to recreate

**Resources**:
- VSCode Documentation: https://code.visualstudio.com/docs
- VSCode Settings Reference: https://code.visualstudio.com/docs/getstarted/settings
- Catppuccin Theme: https://github.com/catppuccin/vscode
- Claude Code Extension: https://marketplace.visualstudio.com/items?itemName=Anthropic.claude-code
- JetBrains Mono Font: https://www.jetbrains.com/lp/mono/

---

### Ghostty Terminal

**Status**: Installed via Homebrew cask `ghostty` (Story 02.2-003)

**✅ AUTO-CONFIGURED with BIDIRECTIONAL SYNC**: Config symlinked to repo (REQ-NFR-008 compliant)

**How Bidirectional Sync Works**:
1. Config file in repo: `config/ghostty/config` (version controlled)
2. On `darwin-rebuild`, activation script creates: `~/.config/ghostty/config` → `~/nix-install/config/ghostty/config`
3. Changes sync both ways:
   - **Repo → Ghostty**: Pull updates or edit repo file → Ghostty sees changes on reload (Cmd+Shift+,)
   - **Manual edits**: Any direct edits to config file appear in repo
4. Ghostty can read config from working directory (not read-only /nix/store)

**First Launch**:
1. Launch Ghostty from Spotlight, Raycast, or `/Applications/Ghostty.app`
2. Config already loaded from `~/.config/ghostty/config`
3. No sign-in required, ready to use immediately

**Pre-Configured Settings** (from template):

The following settings are automatically configured from `config/ghostty/config`:

1. **Catppuccin Theme with Auto-Switching**:
   - `theme = "light:Catppuccin Latte,dark:Catppuccin Mocha"`
   - Automatically switches based on macOS system appearance
   - Light Mode → Catppuccin Latte (light theme)
   - Dark Mode → Catppuccin Mocha (dark theme)
   - Matches Zed and VSCode theme switching behavior

2. **JetBrains Mono Font with Ligatures**:
   - `font-family = JetBrains Mono`
   - `font-size = 12`
   - `font-feature = +liga` (ligatures enabled)
   - `font-feature = +calt` (contextual alternates)
   - `font-feature = +dlig` (discretionary ligatures)
   - Consistent with Zed and VSCode font configuration

3. **Modern Appearance**:
   - `background-opacity = 0.95` (95% opacity)
   - `background-blur = 10` (blur effect)
   - `window-padding-x = 16` (16px horizontal padding)
   - `window-padding-y = 16` (16px vertical padding)
   - `window-theme = auto` (follows system light/dark mode)
   - `macos-titlebar-style = transparent` (native macOS appearance)

4. **Auto-Update Disabled** (CRITICAL):
   - `auto-update = off`
   - Updates only via `rebuild` or `update` commands
   - Ensures controlled update philosophy

5. **Shell Integration**:
   - `shell-integration = detect` (auto-detect shell)
   - `shell-integration-features = cursor,sudo,title`
   - Cursor shape changes, sudo detection, dynamic title

6. **Productivity Keybindings**:
   - **Tabs**: Ctrl+Shift+T (new tab), Ctrl+Tab (next tab)
   - **Splits**: Ctrl+Shift+Enter (right split), Ctrl+Shift+D (down split)
   - **Navigation**: Ctrl+Shift+H/J/L (navigate splits)
   - **Font Size**: Ctrl+Plus/Minus (adjust), Ctrl+0 (reset)
   - **Copy/Paste**: Ctrl+Shift+C/V (clipboard)
   - **Config Reload**: Ctrl+Shift+, (reload config)
   - **Jump to Prompts**: Ctrl+Shift+Up/Down (requires shell integration)

7. **Clipboard & Security**:
   - `clipboard-read = ask` (prompt before reading)
   - `clipboard-write = allow` (allow writing)
   - `clipboard-paste-protection = true` (prevent paste jacking)
   - `copy-on-select = true` (auto-copy on selection)

8. **Performance**:
   - `scrollback-limit = 100000000` (~100MB scrollback)
   - `gtk-single-instance = desktop` (faster subsequent launches)
   - `linux-cgroup = single-instance` (cgroup isolation)

**Configuration Management**:

Ghostty's configuration is managed through the symlinked file:

```bash
# View config location
ls -la ~/.config/ghostty/config
# Should show: ~/.config/ghostty/config -> ~/nix-install/config/ghostty/config

# Edit config in repo
vim ~/nix-install/config/ghostty/config

# Or edit directly (same file due to symlink)
vim ~/.config/ghostty/config

# Reload config in Ghostty
# Press: Ctrl+Shift+, (comma)
# Or restart Ghostty
```

**Viewing/Modifying Settings**:
- **Config location**: `~/.config/ghostty/config` (symlinked to `~/nix-install/config/ghostty/config`)
- **Modify anytime**: Edit the config file (in repo or via symlink)
- **Reload config**: Press `Ctrl+Shift+,` in Ghostty (no restart needed)
- **Version controlled**: Settings tracked by git, can commit/revert changes

**Workflow Options**:

1. **Edit in repo** (recommended):
   ```bash
   # 1. Edit directly in repo
   vim ~/nix-install/config/ghostty/config

   # 2. Reload in Ghostty (Ctrl+Shift+,)
   # 3. Commit your changes:
   git add config/ghostty/config
   git commit -m "feat(ghostty): update keybindings"
   git push
   ```

2. **Edit via symlink** (alternative):
   ```bash
   # 1. Edit directly via symlink
   vim ~/.config/ghostty/config

   # 2. Reload in Ghostty (Ctrl+Shift+,)
   # 3. Changes appear in repo automatically
   git status
   # Shows: modified: config/ghostty/config
   ```

3. **Pull updates** (sync from other machines):
   ```bash
   # Pull changes from repo
   git pull

   # Reload Ghostty config (Ctrl+Shift+,)
   ```

**Available Themes**:

To see all available themes:
```bash
ghostty +list-themes
```

To change theme, edit `config/ghostty/config`:
```bash
# Current (auto-switching)
theme = "light:Catppuccin Latte,dark:Catppuccin Mocha"

# Or use a single theme (examples):
# theme = "TokyoNight"
# theme = "Nord"
# theme = "Dracula"
```

**Testing**:
- [ ] Launch Ghostty successfully
- [ ] Config symlink created at ~/.config/ghostty/config
- [ ] Theme is Catppuccin (Mocha for dark mode, Latte for light mode)
- [ ] Font is JetBrains Mono with ligatures working (→ ≠ ≥ ≤ etc.)
- [ ] Background opacity and blur effect working
- [ ] Window padding visible (16px on all sides)
- [ ] Auto-update disabled (no update prompts)
- [ ] Keybindings work (test splits, tabs, font size, copy/paste)
- [ ] Config reload works (Ctrl+Shift+,)
- [ ] Shell integration working (prompt detection, cursor shape changes)
- [ ] Theme auto-switches when toggling macOS appearance
- [ ] Bidirectional sync: Edit config, verify git shows changes

**Known Issues**:
- **Theme not applied**: Verify theme name is correct (use `ghostty +list-themes`)
- **Config not loading**: Verify symlink exists at ~/.config/ghostty/config
- If symlink broken: Re-run `darwin-rebuild switch` to recreate

**Resources**:
- Ghostty Documentation: https://ghostty.org/docs
- Ghostty Configuration Reference: https://ghostty.org/docs/config
- Catppuccin Theme: https://github.com/catppuccin/ghostty
- JetBrains Mono Font: https://www.jetbrains.com/lp/mono/

---

### Python and Development Tools

**Status**: Installed via Nix packages (Story 02.2-004)

**Installed Tools**:
- **Python 3.12**: Primary Python interpreter
- **uv**: Fast Python package installer and resolver (replaces pip, pip-tools, virtualenv)
- **ruff**: Extremely fast Python linter and formatter (replaces flake8, isort, pyupgrade)
- **black**: Python code formatter
- **isort**: Import statement organizer
- **mypy**: Static type checker for Python
- **pylint**: Comprehensive Python linter

**No Configuration Required**:
These tools are installed globally and automatically available in your PATH. They require no post-install configuration.

**Verification**:

```bash
# Check Python version
python --version
# Expected: Python 3.12.x

# Verify Python path (should be from Nix)
which python
# Expected: /nix/store/.../bin/python

# Check uv
uv --version
# Expected: uv x.y.z

# Check development tools
ruff --version
black --version
isort --version
mypy --version
pylint --version
```

**Creating a New Python Project**:

Using **uv** (recommended):
```bash
# Initialize a new project
uv init my-project
cd my-project

# Add dependencies
uv add requests httpx

# Run Python scripts
uv run python script.py

# Run tests
uv run pytest
```

Traditional approach:
```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install requests
```

**Tool Usage Examples**:

1. **Ruff** (Linting and Formatting):
   ```bash
   # Lint your code
   ruff check .

   # Format your code
   ruff format .

   # Fix issues automatically
   ruff check --fix .
   ```

2. **Black** (Code Formatting):
   ```bash
   # Format a file
   black script.py

   # Format entire project
   black .

   # Check formatting without modifying
   black --check .
   ```

3. **isort** (Import Sorting):
   ```bash
   # Sort imports in a file
   isort script.py

   # Sort all imports
   isort .
   ```

4. **mypy** (Type Checking):
   ```bash
   # Type check your code
   mypy script.py

   # Check entire project
   mypy .
   ```

5. **pylint** (Comprehensive Linting):
   ```bash
   # Lint a file
   pylint script.py

   # Lint entire project
   pylint src/
   ```

**Integration with Editors**:

These tools integrate with VSCode and Zed:

- **VSCode**: Extensions available for ruff, black, mypy, pylint
- **Zed**: Built-in support for ruff, black, and other formatters

**uv vs pip**:

We use **uv** instead of pip because:
- ✅ 10-100× faster than pip
- ✅ Built-in virtualenv management
- ✅ Better dependency resolution
- ✅ Compatible with pip requirements.txt
- ✅ No need for pip-tools (compile/sync)

**Update Philosophy**:
- ✅ All tools updated ONLY via `rebuild` or `update` commands
- ✅ Versions controlled by flake.lock (reproducible)
- ⚠️ Do NOT use `pip install --upgrade` or `brew upgrade` for these tools
- ✅ Use nix-darwin for system-wide tool management

**Testing**:
- [ ] Python 3.12 installed and accessible
- [ ] `which python` shows /nix/store path
- [ ] uv works and can create projects
- [ ] All dev tools (ruff, black, isort, mypy, pylint) work
- [ ] Can create a test project with `uv init`
- [ ] Tools integrate with VSCode/Zed

**Known Issues**:
- **Tool not found**: Re-run `darwin-rebuild switch` to ensure environment is updated
- **Wrong Python version**: Verify `which python` points to Nix path (not system Python)

**Resources**:
- uv Documentation: https://docs.astral.sh/uv/
- ruff Documentation: https://docs.astral.sh/ruff/
- black Documentation: https://black.readthedocs.io/
- mypy Documentation: https://mypy.readthedocs.io/

---

### Podman and Container Tools

**Status**: Installed via Homebrew (Story 02.2-005)

**Installed Tools**:
- **Podman CLI**: Container engine (Docker alternative) - via Homebrew
- **podman-compose**: Docker Compose compatibility for Podman - via Homebrew
- **Podman Desktop**: GUI application for managing containers - via Homebrew cask

**Note**: All Podman tools installed via Homebrew (not Nix) for better GUI integration. Podman Desktop requires podman CLI in standard PATH, which Homebrew provides but Nix installations may not (GUI apps don't inherit shell PATH).

**✅ CRITICAL: Podman Machine Initialization Required**

Before running containers, you must initialize and start a Podman machine (VM):

```bash
# Initialize the default Podman machine with Docker compatibility (one-time setup)
# The --now flag starts the machine immediately after initialization
podman machine init --now --rootful=false

# If already initialized without --now, start manually:
# podman machine start

# Verify machine is running
podman machine list
# Expected: NAME        VM TYPE     CREATED      LAST UP          CPUS        MEMORY      DISK SIZE
#           podman-machine-default  qemu      X minutes ago  Currently running  2           2GiB        10GiB
```

**Important Flags Explained**:
- `--now`: Starts the machine immediately after initialization
- `--rootful=false`: Runs containers in rootless mode (better security, default behavior)

**If You See "Docker socket is not disguised correctly" Error**:
```bash
# Remove the misconfigured machine
podman machine stop
podman machine rm podman-machine-default

# Re-initialize with correct flags
podman machine init --now --rootful=false
```

**Why Machine Initialization is Needed**:
- Podman on macOS runs containers inside a lightweight Linux VM
- The VM provides the Linux kernel required for container execution
- First-time initialization creates the VM and configures networking
- This is a one-time setup per machine

**Verification**:

```bash
# Check Podman version
podman --version
# Expected: podman version 4.x.x or higher

# Check podman-compose version
podman-compose --version
# Expected: podman-compose version x.y.z

# Test container execution
podman run --rm hello-world
# Expected: "Hello from Docker!" message (Podman is Docker-compatible)

# Test with a more complex example
podman run --rm -it alpine:latest echo "Podman works!"
# Expected: "Podman works!" output
```

**Podman Desktop First Launch**:

1. Launch **Podman Desktop** from Applications folder or Spotlight
2. If prompted, allow Podman Desktop to manage machines
3. Desktop app will show machine status and running containers
4. No sign-in required (open source application)

**Podman Desktop Features**:
- Visual container management (start, stop, remove)
- Image management (pull, build, push)
- Pod management (Kubernetes-style pod support)
- Volume and network management
- Machine status and configuration
- Logs and shell access to running containers

**Basic Usage Examples**:

1. **Running a Container**:
   ```bash
   # Run a simple container
   podman run --rm -d --name nginx -p 8080:80 nginx:latest

   # Check running containers
   podman ps

   # Stop the container
   podman stop nginx
   ```

2. **Using podman-compose**:
   ```bash
   # Create docker-compose.yml (or compose.yaml)
   cat > docker-compose.yml <<EOF
   version: '3'
   services:
     web:
       image: nginx:latest
       ports:
         - "8080:80"
   EOF

   # Start services
   podman-compose up -d

   # Stop services
   podman-compose down
   ```

3. **Building Images**:
   ```bash
   # Create a Containerfile (or Dockerfile)
   cat > Containerfile <<EOF
   FROM alpine:latest
   RUN apk add --no-cache curl
   CMD ["curl", "--version"]
   EOF

   # Build the image
   podman build -t myimage:latest .

   # Run the built image
   podman run --rm myimage:latest
   ```

4. **Managing Machines**:
   ```bash
   # List machines
   podman machine list

   # Stop machine (when not needed)
   podman machine stop

   # Start machine again
   podman machine start

   # Remove machine (careful - deletes all containers/images!)
   podman machine rm podman-machine-default
   ```

**Podman vs Docker**:
- ✅ Rootless by default (better security)
- ✅ Daemonless architecture (no background daemon)
- ✅ Drop-in Docker CLI replacement (docker → podman)
- ✅ Fully Docker-compatible (can use Dockerfiles, docker-compose.yml)
- ✅ Built-in pod support (Kubernetes-style)
- ✅ Free and open source (no licensing concerns)

**Common Workflows**:

1. **Docker Compose Replacement**:
   ```bash
   # Most docker-compose commands work with podman-compose
   alias docker-compose='podman-compose'

   # Use existing docker-compose.yml files
   podman-compose up -d
   podman-compose logs -f
   podman-compose down
   ```

2. **Docker CLI Alias**:
   ```bash
   # Add to ~/.zshrc for Docker compatibility
   alias docker='podman'

   # Now docker commands work with Podman
   docker run nginx
   docker ps
   docker images
   ```

**Machine Management**:
- Machine starts automatically on first `podman` command
- Stop machine to free resources: `podman machine stop`
- Machine uses ~2GB RAM when running
- Disk space configured during init (default: 10GB, expandable)

**Troubleshooting**:

1. **"Cannot connect to Podman" error**:
   ```bash
   # Start the machine
   podman machine start
   ```

2. **"Docker socket is not disguised correctly" error** (Podman Desktop):
   ```bash
   # Remove the misconfigured machine
   podman machine stop
   podman machine rm podman-machine-default

   # Re-initialize with correct flags
   podman machine init --now --rootful=false

   # Verify
   podman machine list
   # Restart Podman Desktop
   ```

3. **Machine won't start**:
   ```bash
   # Check machine status
   podman machine list

   # If machine is corrupted, recreate it
   podman machine stop
   podman machine rm podman-machine-default
   podman machine init --now --rootful=false
   ```

3. **Port conflicts**:
   ```bash
   # Check what's using the port
   lsof -i :8080

   # Use different port mapping
   podman run -p 8081:80 nginx
   ```

4. **Disk space issues**:
   ```bash
   # Clean up unused images and containers
   podman system prune -a

   # Check disk usage
   podman system df
   ```

**Integration with Development**:
- **Epic-04**: Will add Podman configuration to shell (aliases, completion)
- **Epic-05**: Podman Desktop may receive Catppuccin theming
- **Projects**: Use Containerfiles instead of Dockerfiles (OCI-compliant)

**Update Philosophy**:
- ✅ All Podman tools updated via Homebrew (`rebuild` or `update` commands)
- ✅ Versions controlled by Homebrew (auto-update disabled globally)
- ⚠️ Do NOT use `brew upgrade podman` or `brew upgrade podman-desktop` manually
- ✅ Updates ONLY via darwin-rebuild (Homebrew managed by nix-darwin)

**Testing Checklist**:
- [ ] Podman CLI installed and version shows
- [ ] podman-compose installed and version shows
- [ ] Podman Desktop installed and launches
- [ ] Podman machine initialized successfully
- [ ] Podman machine starts and shows as "Currently running"
- [ ] Can run `podman run hello-world` successfully
- [ ] Podman Desktop GUI shows machine status
- [ ] Can manage containers from Desktop app
- [ ] podman-compose can start/stop services

**Known Issues**:
- **Machine initialization required**: First-time setup needs manual `podman machine init --now --rootful=false`
- **Docker socket error**: If you see "Docker socket is not disguised correctly", reinitialize machine with correct flags (see Troubleshooting)
- **Resource usage**: Machine consumes ~2GB RAM when running (stop with `podman machine stop` if not needed)
- **Slow first pulls**: Initial image downloads may be slow depending on network

**Resources**:
- Podman Documentation: https://podman.io/docs
- Podman Desktop: https://podman-desktop.io/
- podman-compose: https://github.com/containers/podman-compose
- Containerfile Spec: https://github.com/containers/common/blob/main/docs/Containerfile.5.md

---

## Claude Code CLI and MCP Servers

### Claude Code CLI with MCP Servers (Context7, GitHub, Sequential Thinking)

**Status**: Installed via Nix (Story 02.2-006)
- Claude Code CLI: `claude-code-nix` flake input
- MCP Servers: `mcp-servers-nix` flake input (Context7, GitHub, Sequential Thinking)
- All packages installed to `darwin/configuration.nix` systemPackages
- Configuration managed by Home Manager (`home-manager/modules/claude-code.nix`)
- **REQ-NFR-008 Compliant**: Bidirectional sync via repository symlinks

**Purpose**: AI-assisted development with Claude Code CLI and Model Context Protocol (MCP) servers for enhanced context awareness, repository integration, and structured reasoning capabilities.

**What is MCP?**:
Model Context Protocol (MCP) allows Claude Code to access external data sources and tools:
- **Context7 MCP**: Provides enhanced context awareness across your development environment
- **GitHub MCP**: Integrates with GitHub repositories for code search, PR reviews, and issue tracking
- **Sequential Thinking MCP**: Enables structured, step-by-step reasoning for complex problems

#### Installation Details

**Packages Installed**:
- `claude` (Claude Code CLI) - AI-assisted development tool
- `mcp-server-context7` - Context awareness server
- `mcp-server-github` - GitHub integration server
- `mcp-server-sequential-thinking` - Structured reasoning server

**All packages installed via Nix** (no Node.js or npm dependencies):
```bash
# Verify installations
claude --version
mcp-server-context7 --version
mcp-server-github --version
mcp-server-sequential-thinking --version
```

**Configuration Files** (REQ-NFR-008 compliant bidirectional sync):
- `~/.claude/CLAUDE.md` → symlinked to `$REPO/config/claude/CLAUDE.md`
- `~/.claude/agents/` → symlinked to `$REPO/config/claude/agents/`
- `~/.claude/commands/` → symlinked to `$REPO/config/claude/commands/`
- `~/.config/claude/config.json` → MCP server configuration (created by Home Manager)

Changes in repository instantly appear in Claude Code (bidirectional sync).

#### Required Post-Install Configuration

**CRITICAL**: GitHub MCP server requires a GitHub Personal Access Token.

**Step 1: Create GitHub Personal Access Token**

1. Visit https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Token settings:
   - **Name**: `Claude Code MCP Server`
   - **Expiration**: Choose expiration (90 days recommended)
   - **Scopes** (check these boxes):
     - ✅ `repo` (Full control of private repositories)
     - ✅ `read:org` (Read org and team membership)
     - ✅ `read:user` (Read user profile data)
4. Click **"Generate token"**
5. **Copy the token immediately** (you won't see it again!)

**Step 2: Add Token to Claude Code Configuration**

Edit the MCP configuration file:
```bash
# Open config file in your editor
code ~/.config/claude/config.json
# or
zed ~/.config/claude/config.json
```

Replace `REPLACE_WITH_YOUR_GITHUB_TOKEN` with your actual token:
```json
{
  "mcpServers": {
    "context7": {
      "command": "mcp-server-context7",
      "args": [],
      "enabled": true
    },
    "github": {
      "command": "mcp-server-github",
      "args": [],
      "env": {
        "GITHUB_TOKEN": "ghp_YourActualTokenHere123456789"
      },
      "enabled": true
    },
    "sequential-thinking": {
      "command": "mcp-server-sequential-thinking",
      "args": [],
      "enabled": true
    }
  }
}
```

Save the file.

**Step 3: Verify MCP Servers**

```bash
# List configured MCP servers
claude mcp list

# Expected output:
# ✓ context7 (enabled)
# ✓ github (enabled)
# ✓ sequential-thinking (enabled)
```

#### Usage Examples

**Starting Claude Code CLI**:
```bash
# Start interactive session
claude

# Start with specific file context
claude README.md

# Start with directory context
claude src/
```

**Example Queries with MCP Servers**:

**Context7 MCP** (Enhanced context awareness):
```bash
claude
> What are the main components of this project?
> Analyze the architecture of the codebase
> Find all API endpoints in the project
```

**GitHub MCP** (Repository integration):
```bash
claude
> Show me open pull requests in this repository
> What issues are labeled as "bug"?
> Search for implementations of authentication in organization repos
> Summarize recent commits to main branch
```

**Sequential Thinking MCP** (Structured reasoning):
```bash
claude
> Let's think step-by-step about how to implement user authentication
> Break down the problem of optimizing database queries
> Analyze this code and reason through potential bugs
```

**Combined MCP Usage**:
```bash
claude
> Using GitHub MCP, find similar authentication implementations,
  then use Sequential Thinking to design our implementation step-by-step
```

#### Configuration Customization

**Custom Agents** (repository-synced):
Create custom agent definitions in `config/claude/agents/`:
```bash
# Agents are version controlled in repo
ls -la config/claude/agents/

# Changes sync automatically to ~/.claude/agents/
```

**Custom Commands** (repository-synced):
Create slash commands in `config/claude/commands/`:
```bash
# Commands are version controlled in repo
ls -la config/claude/commands/

# Changes sync automatically to ~/.claude/commands/
```

**CLAUDE.md** (repository-synced):
Global instructions for Claude Code in `config/claude/CLAUDE.md`:
```bash
# Edit in repo
code config/claude/CLAUDE.md

# Changes instantly visible to Claude Code via symlink
```

#### Verification

**Check Claude Code Installation**:
```bash
claude --version
# Expected: Claude Code CLI version X.X.X
```

**Check MCP Server Installations**:
```bash
which mcp-server-context7
which mcp-server-github
which mcp-server-sequential-thinking

# All should show /nix/store/... paths
```

**Verify Configuration Symlinks** (REQ-NFR-008):
```bash
ls -la ~/.claude/
# Should show:
# lrwxr-xr-x CLAUDE.md -> /path/to/nix-install/config/claude/CLAUDE.md
# lrwxr-xr-x agents -> /path/to/nix-install/config/claude/agents/
# lrwxr-xr-x commands -> /path/to/nix-install/config/claude/commands/
```

**Verify MCP Config Created**:
```bash
cat ~/.config/claude/config.json
# Should show JSON with three MCP servers configured
```

**Test MCP Servers**:
```bash
# Test Context7 MCP
mcp-server-context7 --version

# Test GitHub MCP (requires token configured)
# Will be tested when running claude CLI

# Test Sequential Thinking MCP
mcp-server-sequential-thinking --version
```

#### Troubleshooting

**Issue**: `claude: command not found`
**Solution**:
```bash
# Verify Nix package installed
nix-env -q | grep claude
# If not found, rebuild
darwin-rebuild switch --flake ~/nix-install#standard  # or #power

# Check PATH includes Nix
echo $PATH | grep nix
# Should include /nix/var/nix/profiles/default/bin or similar
```

**Issue**: GitHub MCP server not working
**Solution**:
1. Verify token configured: `cat ~/.config/claude/config.json | grep GITHUB_TOKEN`
2. Check token not placeholder: Should be `ghp_...`, not `REPLACE_WITH_YOUR_GITHUB_TOKEN`
3. Verify token scopes at https://github.com/settings/tokens
4. Test token: `curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user`
5. Restart Claude Code session after token update

**Issue**: MCP servers show as disabled
**Solution**:
```bash
# Edit config.json and ensure "enabled": true for all servers
code ~/.config/claude/config.json

# Check for syntax errors
cat ~/.config/claude/config.json | jq .
# Should parse successfully without errors
```

**Issue**: Configuration changes not appearing in Claude Code
**Solution**:
```bash
# Verify symlinks are correct
ls -la ~/.claude/

# If symlinks broken, rebuild
darwin-rebuild switch --flake ~/nix-install#standard  # or #power

# Symlinks should point to working directory, NOT /nix/store/
# Correct: ~/.claude/CLAUDE.md -> /Users/fx/nix-install/config/claude/CLAUDE.md
# Wrong: ~/.claude/CLAUDE.md -> /nix/store/.../CLAUDE.md
```

**Issue**: Want to update MCP server configuration
**Solution**:
```bash
# Edit config.json directly (NOT managed by Nix)
code ~/.config/claude/config.json

# Add new MCP server, change settings, etc.
# File is NOT overwritten by darwin-rebuild (preserves user customizations)
```

#### Security Considerations

**GitHub Token Storage**:
- Token stored in `~/.config/claude/config.json` (plain text)
- File has user-only permissions (600)
- **DO NOT** commit config.json to public repositories
- Consider using environment variables for shared configurations:
  ```json
  "env": {
    "GITHUB_TOKEN": "${GITHUB_TOKEN}"
  }
  ```
  Then export in shell: `export GITHUB_TOKEN=ghp_...`

**Token Rotation**:
- Rotate tokens every 90 days (set expiration when creating)
- Revoke old tokens at https://github.com/settings/tokens
- Update config.json with new token

**Least Privilege**:
- Only grant scopes needed: `repo`, `read:org`, `read:user`
- Don't grant `admin:org`, `delete_repo`, or other destructive scopes

#### Update Philosophy

- ✅ Claude Code CLI updated via Nix flake (`update` command updates flake.lock)
- ✅ MCP servers updated via Nix flake (same flake.lock update)
- ✅ All versions reproducible via flake.lock
- ⚠️ Do NOT use `npm install` or `npx` for MCP servers (Nix manages them)
- ✅ Updates ONLY via darwin-rebuild (Nix-managed packages)

**Update Process**:
```bash
# Update flake.lock (gets latest versions)
cd ~/nix-install
nix flake update

# Rebuild with new versions
darwin-rebuild switch --flake ~/nix-install#standard  # or #power

# Verify new versions
claude --version
mcp-server-context7 --version
mcp-server-github --version
mcp-server-sequential-thinking --version
```

#### Testing Checklist

- [ ] Claude Code CLI installed and `claude --version` works
- [ ] All three MCP server binaries installed and on PATH
- [ ] `~/.claude/CLAUDE.md` symlinked to repository (bidirectional sync)
- [ ] `~/.claude/agents/` symlinked to repository
- [ ] `~/.claude/commands/` symlinked to repository
- [ ] `~/.config/claude/config.json` created with three MCP servers
- [ ] GitHub Personal Access Token created with correct scopes
- [ ] Token added to config.json (replaces placeholder)
- [ ] `claude mcp list` shows all three servers as enabled
- [ ] Can start Claude Code CLI with `claude` command
- [ ] Context7 MCP responds to context queries
- [ ] GitHub MCP can query repositories (token configured)
- [ ] Sequential Thinking MCP enables structured reasoning
- [ ] Configuration changes in repo appear in `~/.claude/` (bidirectional sync)
- [ ] Symlinks point to working directory, NOT /nix/store

#### Resources

- Claude Code CLI: https://github.com/anthropics/claude-code
- MCP Specification: https://modelcontextprotocol.io/
- Context7 MCP: https://github.com/natsukium/mcp-servers-nix (community maintained)
- GitHub MCP: https://github.com/natsukium/mcp-servers-nix (community maintained)
- Sequential Thinking MCP: https://github.com/natsukium/mcp-servers-nix (community maintained)
- GitHub Token Management: https://github.com/settings/tokens

---

## Browsers

### Brave Browser

**Status**: Installed via Homebrew cask `brave-browser` (Story 02.3-001)

**Purpose**: Privacy-focused browser with built-in ad/tracker blocking via Brave Shields. No extensions needed for ad blocking.

**First Launch**:
1. Launch Brave Browser from Spotlight, Raycast, or `/Applications/Brave Browser.app`
2. Welcome screen appears with onboarding wizard
3. Follow onboarding steps (optional):
   - Choose Brave as default browser (optional)
   - Import bookmarks and settings from other browsers (optional - Chrome, Safari, Firefox, Edge)
   - Choose search engine (DuckDuckGo default, can change to Google, Brave Search, etc.)
4. No sign-in required (optional: Sync across devices with Brave Sync)

**Update Management** (IMPORTANT):

Brave updates are **controlled by Homebrew**, not by in-app settings.

**How Brave Updates Work**:
- ✅ Brave updates are managed by Homebrew (installed via `brave-browser` cask)
- ✅ Updates ONLY occur when you run `darwin-rebuild switch` (rebuild command)
- ✅ Version is controlled by the Homebrew cask formula (managed by nix-darwin)
- ⚠️ **No in-app auto-update setting available** - Homebrew-managed apps don't expose this setting
- ⚠️ **Do NOT use "Check for updates" in Brave's About menu** - This is disabled for Homebrew installations

**Why No In-App Auto-Update Control?**:
- Homebrew-installed applications receive updates through Homebrew, not the app's built-in updater
- The app's auto-update mechanism is typically disabled or non-functional for Homebrew cask installations
- This is the **correct behavior** - it ensures updates are controlled via your declarative configuration

**Update Process**:
```bash
# To update Brave (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Brave Shields Configuration**:

Brave Shields is the built-in ad/tracker blocker. It's **enabled by default** and requires no configuration.

**How to Verify Shields is Working**:
1. Look for the **Brave Shields icon** (lion logo) in the address bar (right side)
2. Click the Shields icon to see:
   - **Trackers & ads blocked** (count)
   - **Upgrade connections to HTTPS** (on by default)
   - **Block scripts** (off by default, can enable for stricter blocking)
   - **Block fingerprinting** (Standard by default)
   - **Block cookies** (Cross-site by default)
3. Test on an ad-heavy website (e.g., news sites, YouTube):
   - Ads should be blocked automatically
   - Shield icon will show count of blocked items
   - Page loads faster with fewer trackers

**Per-Site Shields Settings**:
- Click Shields icon on any website to adjust settings for that specific site
- **Advanced View** button shows detailed controls:
  - Trackers & ads blocking (Aggressive/Standard/Allow)
  - Upgrade connections to HTTPS (On/Off)
  - Block scripts (On/Off - may break some sites)
  - Block fingerprinting (Strict/Standard/Allow)
  - Block cookies (All/Cross-site/Allow)

**Privacy Features**:

Brave includes several privacy features by default:

1. **HTTPS Everywhere** (Built-in):
   - Automatically upgrades HTTP connections to HTTPS
   - Enabled by default via Brave Shields
   - No extension needed

2. **Anti-Fingerprinting**:
   - Prevents websites from tracking you via browser fingerprinting
   - Randomizes browser attributes
   - Set to "Standard" by default (Settings → Shields → Fingerprinting blocking)

3. **Tracker/Ad Blocking via Shields**:
   - Blocks ads and trackers using built-in filter lists
   - Updates automatically (separate from browser updates)
   - More efficient than extension-based blockers

4. **Additional Privacy Settings**:
   - Navigate to **Settings** → **Privacy and security**
   - **WebRTC IP Handling**: Default Public IP only (prevents IP leak)
   - **Safe Browsing**: Standard protection (warns about dangerous sites)
   - **Send a "Do Not Track" request**: Can be enabled (optional)
   - **Clear browsing data on exit**: Can be configured (optional)

**Setting Brave as Default Browser** (Optional):

If you want Brave as your default browser:

1. Open **Brave** → **Settings** (Cmd+,)
2. Navigate to **Get started** or **Appearance** section
3. Click **Make Brave the default browser** button
4. macOS will prompt: "Do you want to change your default web browser?"
5. Click **Use "Brave"**

**Alternative Method**:
1. Open **System Settings** → **Desktop & Dock**
2. Scroll down to **Default web browser**
3. Select **Brave Browser** from dropdown

**Brave Sync** (Optional):

Brave Sync allows syncing bookmarks, extensions, history, and settings across devices:

1. Open **Brave** → **Settings** (Cmd+,)
2. Navigate to **Sync** (in left sidebar)
3. Click **Start a new Sync Chain**
4. Choose what to sync: Bookmarks, Extensions, History, Settings, Themes, Open Tabs, Passwords, Addresses
5. Use QR code or sync code to connect other devices
6. No account required (uses blockchain-based sync)

**Brave Rewards** (Optional):

Brave Rewards allows earning BAT cryptocurrency for viewing privacy-respecting ads:

1. Click **Brave Rewards** icon (triangle) in address bar
2. Click **Start using Brave Rewards**
3. Configure ad settings:
   - Ads per hour (0-10)
   - Ad notification preferences
4. Optional: Connect a wallet to withdraw earnings
5. **Note**: Not required for basic browser functionality

**Testing Checklist**:
- [ ] Launch Brave Browser successfully
- [ ] Complete onboarding wizard (import settings optional)
- [ ] Brave Shields icon visible in address bar
- [ ] Verify updates controlled by Homebrew (About Brave shows version, no auto-update toggle)
- [ ] Shields working: Test on ad-heavy site (YouTube, news site)
- [ ] Verify blocked ad/tracker count in Shields icon
- [ ] HTTPS upgrade working (visit HTTP site, check for HTTPS redirect)
- [ ] Privacy settings accessible and configured
- [ ] Can set as default browser (if desired)
- [ ] Accessible from Spotlight/Raycast

**Common Use Cases**:

1. **Daily Browsing with Ad Blocking**:
   - Brave Shields blocks ads and trackers automatically
   - No extension installation needed
   - Faster page loads, less data usage

2. **Privacy-Focused Research**:
   - Enable Private Window (Cmd+Shift+N)
   - Use Brave Search (built-in, privacy-respecting search engine)
   - Strict Shields settings for maximum privacy

3. **YouTube Without Ads**:
   - Brave blocks YouTube ads automatically
   - No YouTube Premium needed
   - Works in both standard and Private windows

4. **Cross-Browser Compatibility**:
   - Chromium-based (same engine as Chrome/Edge)
   - Compatible with Chrome extensions
   - Can import Chrome bookmarks and passwords

**Keyboard Shortcuts** (Same as Chrome):
- `Cmd+T` - New tab
- `Cmd+W` - Close tab
- `Cmd+Shift+T` - Reopen closed tab
- `Cmd+Shift+N` - New private window
- `Cmd+L` - Focus address bar
- `Cmd+R` - Reload page
- `Cmd+Shift+B` - Show/hide bookmarks bar
- `Cmd+,` - Settings

**Troubleshooting**:

1. **Shields breaking a website**:
   - Click Shields icon
   - Toggle "Shields" to **Down** for that specific site
   - Or adjust individual settings (allow scripts, cookies, etc.)
   - Add site to exceptions if permanently needed

2. **Updates not working as expected**:
   - **Expected behavior**: Brave updates are controlled by Homebrew, NOT by in-app settings
   - About Brave menu will show current version but no auto-update toggle (this is correct)
   - To update Brave: Run `darwin-rebuild switch` or `nix flake update && darwin-rebuild switch`
   - Do NOT use "Check for updates" button in About Brave (disabled for Homebrew installations)

3. **Import not working**:
   - Brave → Settings → Get Started → Import bookmarks and settings
   - Choose source browser (Chrome, Safari, Firefox, Edge)
   - Select items to import
   - Click "Import"

4. **Extensions not installing**:
   - Visit Chrome Web Store (Brave is Chromium-based)
   - Install extensions like normal Chrome browser
   - Most Chrome extensions work in Brave

**Integration with Development Workflow**:
- **Web development**: Chromium DevTools (same as Chrome)
- **Extension support**: Install from Chrome Web Store
- **Testing**: Cross-browser testing (Chromium engine)
- **Privacy**: Built-in ad blocking reduces dev noise

**Update Philosophy**:
- ✅ Brave updates ONLY via Homebrew (`rebuild` or `update` commands)
- ✅ In-app auto-update not available (Homebrew-managed installation)
- ✅ Versions controlled by Homebrew (managed by nix-darwin)
- ⚠️ Do NOT use "Check for updates" in About Brave menu (disabled for Homebrew installations)
- ✅ Brave Shields filter lists update automatically (separate from browser updates, this is expected)

**Brave Shields Filter Lists**:
- **Note**: Brave Shields uses ad/tracker filter lists that update independently
- These filter list updates are **separate** from browser updates
- Filter lists update automatically in the background (this is expected and safe)
- Browser version updates are still controlled by Homebrew only

**Known Issues**:
- **Shields too aggressive**: Some sites may break with default Shields settings (disable per-site)
- **Compatibility**: Chromium-based, so Chrome-specific bugs may affect Brave too
- **Memory usage**: Similar to Chrome (can be high with many tabs)

**Resources**:
- Brave Documentation: https://support.brave.com/
- Brave Shields Guide: https://support.brave.com/hc/en-us/articles/360022973471-What-is-Shields-
- Privacy Features: https://brave.com/privacy-features/
- Brave Search: https://search.brave.com/
- Chrome Web Store (extensions): https://chrome.google.com/webstore

### Arc Browser

**Status**: Installed via Homebrew cask `arc` (Story 02.3-002)

**Purpose**: Modern, workspace-focused browser with unique vertical sidebar UI, Spaces feature for context separation, and innovative command palette for power users.

**First Launch**:
1. Launch Arc from Spotlight, Raycast, or `/Applications/Arc.app`
2. Welcome screen appears with onboarding wizard
3. **Account Required**: Arc requires sign-in for sync features and full functionality
   - Sign in with email (creates Arc account)
   - Or sign in with Google account
4. Complete onboarding steps:
   - Choose your workspace name (e.g., "Work", "Personal")
   - Import bookmarks from other browsers (optional - Chrome, Safari, Firefox, Brave)
   - Watch Arc tutorial (recommended for first-time users)
5. Arc will display sidebar with Spaces and vertical tabs

**Update Management** (IMPORTANT):

Arc updates are **controlled by Homebrew**, not by in-app settings.

**How Arc Updates Work**:
- ✅ Arc updates are managed by Homebrew (installed via `arc` cask)
- ✅ Updates ONLY occur when you run `darwin-rebuild switch` (rebuild command)
- ✅ Version is controlled by the Homebrew cask formula (managed by nix-darwin)
- ⚠️ **No in-app auto-update setting available** - Homebrew-managed apps don't expose this setting
- ⚠️ **Do NOT use "Check for updates" in Arc's About menu** - This is disabled for Homebrew installations

**Why No In-App Auto-Update Control?**:
- Homebrew-installed applications receive updates through Homebrew, not the app's built-in updater
- The app's auto-update mechanism is typically disabled or non-functional for Homebrew cask installations
- This is the **correct behavior** - it ensures updates are controlled via your declarative configuration

**Update Process**:
```bash
# To update Arc (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Arc Features**:

Arc introduces several unique features that differentiate it from traditional browsers:

1. **Spaces** (Workspaces for different contexts):
   - Create separate Spaces for Work, Personal, Projects, etc.
   - Each Space has its own set of tabs, favorites, and appearance
   - Switch between Spaces using Cmd+S or sidebar
   - Keeps contexts separate (e.g., Work Gmail vs Personal Gmail)

2. **Vertical Sidebar with Tabs**:
   - Tabs displayed vertically on left side (more screen space for content)
   - Auto-hide sidebar (moves out of the way when not needed)
   - Pin frequently used tabs at top of sidebar
   - Unpinned tabs auto-archive after 12 hours (configurable)

3. **Command Palette** (Cmd+T):
   - Quick access to tabs, history, bookmarks, settings
   - Type to search open tabs, recently closed tabs, bookmarks
   - Perform actions (create new tab, switch Space, etc.)
   - Similar to VSCode/Zed command palette for browsers

4. **Split View**:
   - View multiple tabs side-by-side
   - Drag tabs to split screen horizontally or vertically
   - Resize splits dynamically
   - Great for research, documentation, development

5. **Boosts** (Customize any website):
   - Custom CSS/JavaScript for any website
   - Change appearance, hide elements, add features
   - Share Boosts with others
   - Power user customization

6. **Built-in Note Taking**:
   - Create "Easel" notes directly in Arc
   - Capture screenshots, links, text
   - Organize alongside tabs
   - No external note-taking app needed

7. **Tab Management**:
   - **Pinned Tabs**: Always visible at top of sidebar
   - **Favorites**: Frequently accessed sites (live previews)
   - **Today Tabs**: Unpinned tabs auto-archive after 12 hours (customizable)
   - **Little Arc**: Minimal browser window for quick searches (Cmd+Shift+N)

**First-Time Setup**:

After launching Arc for the first time:

1. **Create Account** (Required):
   - Sign in with email or Google account
   - Account enables sync across devices
   - No paid tier required for core features

2. **Set Up First Space**:
   - Name your first Space (e.g., "Work", "Personal")
   - Choose a color/icon for the Space
   - Add favorite websites to sidebar

3. **Import from Other Browsers** (Optional):
   - Arc → Settings → Import
   - Select source browser (Chrome, Safari, Firefox, Brave)
   - Choose what to import: Bookmarks, Passwords, History
   - Click "Import"

4. **Configure Tab Auto-Archive** (Optional):
   - Arc → Settings → General → Archive Tabs
   - Default: Archive unpinned tabs after 12 hours
   - Options: Never, 1 day, 7 days, 30 days
   - Pinned tabs never auto-archive

5. **Set as Default Browser** (Optional):
   - Arc → Settings → General
   - Click "Set Arc as Default Browser"
   - macOS will prompt for confirmation
   - Click "Use Arc"

**Using Spaces (Workspaces)**:

Spaces are Arc's killer feature - separate workspaces for different contexts:

**Creating a New Space**:
1. Click **+** button at bottom of sidebar
2. Or press **Cmd+S** → "Create New Space"
3. Name the Space (e.g., "Personal", "Side Projects", "Learning")
4. Choose color and icon
5. Add favorite sites to the Space

**Switching Spaces**:
- Press **Cmd+S** → Select Space from list
- Or click Space icon at bottom of sidebar
- Each Space maintains its own tabs and favorites

**Use Cases for Spaces**:
- **Work vs Personal**: Separate professional and personal browsing
- **Projects**: Dedicated Space for each client or project
- **Learning**: Space for courses, documentation, tutorials
- **Shopping**: Temporary Space for research and comparisons
- **Banking/Finance**: Isolated Space for sensitive sites

**Command Palette** (Power User Feature):

Press **Cmd+T** to open the command palette:

**What You Can Do**:
- **Search open tabs**: Type tab title to switch instantly
- **Search history**: Access recently closed or visited tabs
- **Search bookmarks**: Find saved sites quickly
- **Quick actions**: "New Space", "New Incognito Window", "Settings"
- **URL entry**: Type URL or search query directly

**Keyboard Shortcuts**:
- `Cmd+T` - Open command palette (tabs, history, bookmarks)
- `Cmd+S` - Switch Spaces
- `Cmd+Option+N` - New Space
- `Cmd+Shift+N` - Little Arc (minimal browser window)
- `Cmd+W` - Close tab
- `Cmd+Shift+T` - Reopen closed tab
- `Cmd+L` - Focus address bar
- `Cmd+Shift+D` - Split view (horizontal)
- `Cmd+Shift+\` - Split view (vertical)
- `Cmd+1/2/3...` - Switch to pinned tab 1, 2, 3, etc.
- `Cmd+Option+Up/Down` - Navigate between tabs
- `Cmd+,` - Settings

**Setting Arc as Default Browser** (Optional):

If you want Arc as your default browser:

**Method 1: Via Arc Settings**:
1. Open **Arc** → **Settings** (Cmd+,)
2. Navigate to **General** section
3. Click **Set Arc as Default Browser** button
4. macOS will prompt: "Do you want to change your default web browser to Arc?"
5. Click **Use "Arc"**

**Method 2: Via macOS System Settings**:
1. Open **System Settings** → **Desktop & Dock**
2. Scroll down to **Default web browser**
3. Select **Arc** from dropdown

**Arc Sync** (Automatic):

Arc Sync is built-in and automatic (requires account sign-in):

**What Syncs**:
- Spaces and their configurations
- Tabs (pinned and unpinned)
- Favorites
- Boosts (custom website modifications)
- Settings and preferences
- Browsing history
- Passwords (via iCloud Keychain integration)

**How to Verify Sync**:
1. Arc → Settings → Account
2. Shows: "Syncing to [your email]"
3. Sync happens automatically when changes are made

**Privacy and Security**:

Arc includes several privacy features:

1. **Tracking Prevention**:
   - Blocks third-party trackers by default
   - Similar to Safari's Intelligent Tracking Prevention
   - Arc → Settings → Privacy → Tracking Prevention (on by default)

2. **Ad Blocking**:
   - **Note**: Arc does NOT have built-in ad blocking like Brave
   - Use extensions: uBlock Origin, AdGuard, etc. (from Chrome Web Store)
   - Arc is Chromium-based, so Chrome extensions work

3. **HTTPS Enforcement**:
   - Automatically upgrades to HTTPS when available
   - Warns about insecure connections

4. **Incognito Mode**:
   - Press **Cmd+Shift+N** for Little Arc (minimal private window)
   - Or create Incognito Space: Arc → New Incognito Space
   - No browsing history or cookies saved

**Extension Support**:

Arc is Chromium-based and supports Chrome extensions:

1. Visit **Chrome Web Store**: https://chrome.google.com/webstore
2. Search for extension (e.g., "uBlock Origin", "1Password", "Grammarly")
3. Click "Add to Chrome" (works for Arc)
4. Extension appears in Arc toolbar

**Recommended Extensions for Privacy**:
- **uBlock Origin**: Ad and tracker blocking
- **Privacy Badger**: Automatic tracker blocking
- **HTTPS Everywhere**: Force HTTPS (Arc has this built-in, but extension adds more)
- **Bitwarden** or **1Password**: Password management

**Testing Checklist**:
- [ ] Launch Arc successfully
- [ ] Account sign-in completes (email or Google)
- [ ] Onboarding wizard completes
- [ ] Create first Space (name, color, icon)
- [ ] Add pinned tabs to sidebar
- [ ] Test Command Palette (Cmd+T) - search tabs, history
- [ ] Create second Space to test workspace switching
- [ ] Test Split View (Cmd+Shift+D or Cmd+Shift+\)
- [ ] Verify updates controlled by Homebrew (About Arc shows version, no auto-update toggle)
- [ ] Import bookmarks from another browser (optional test)
- [ ] Test tab auto-archive (unpinned tabs archived after 12 hours)
- [ ] Verify accessible from Spotlight/Raycast
- [ ] Set as default browser (optional)

**Common Use Cases**:

1. **Work and Personal Separation**:
   - **Work Space**: Gmail (work), Slack, GitHub, AWS Console
   - **Personal Space**: Gmail (personal), YouTube, Reddit, Social Media
   - Switch with Cmd+S, keep contexts completely separate

2. **Multi-Project Development**:
   - **Client A Space**: Jira, GitHub repos, documentation, staging site
   - **Client B Space**: Different repos, tools, production sites
   - **Side Project Space**: Personal GitHub, localhost, docs
   - No tab confusion, instant context switching

3. **Research and Learning**:
   - **Learning Space**: Course platform, documentation, tutorials, notes
   - Split view for video + code editor (or notes)
   - Archive tabs automatically after completing lessons

4. **Content Creation**:
   - **Writing Space**: Google Docs, research tabs, references
   - **Design Space**: Figma, inspiration sites, resources
   - Boosts to customize tools (hide distractions, custom CSS)

**Troubleshooting**:

1. **Tabs disappearing (auto-archived)**:
   - Default: Unpinned tabs auto-archive after 12 hours
   - **Fix**: Pin important tabs (drag to "Pinned" section at top of sidebar)
   - **Or change setting**: Arc → Settings → General → Archive Tabs → Never (or longer duration)
   - **Access archived tabs**: Command Palette (Cmd+T) → Search history

2. **Updates not working as expected**:
   - **Expected behavior**: Arc updates are controlled by Homebrew, NOT by in-app settings
   - About Arc menu will show current version but no auto-update toggle (this is correct)
   - To update Arc: Run `darwin-rebuild switch` or `nix flake update && darwin-rebuild switch`
   - Do NOT use "Check for updates" button in About Arc (disabled for Homebrew installations)

3. **Sync not working**:
   - Verify signed in: Arc → Settings → Account (should show email)
   - Check internet connection
   - Sign out and sign back in: Arc → Settings → Account → Sign Out → Sign In

4. **Extensions not working**:
   - Arc is Chromium-based - use Chrome Web Store
   - Some Firefox-only extensions won't work
   - Most Chrome extensions are compatible

5. **Sidebar auto-hiding too aggressively**:
   - Arc → Settings → Appearance → Sidebar → "Always show sidebar" (optional)
   - Or hover over left edge to reveal sidebar
   - Pinned: Cmd+S (keeps sidebar visible)

6. **Account sign-in required (cannot skip)**:
   - Arc requires account for full functionality
   - Unlike Brave/Chrome, no anonymous mode for main browser
   - Use Little Arc (Cmd+Shift+N) for quick anonymous browsing

**Integration with Development Workflow**:
- **Web development**: Chromium DevTools (same as Chrome/Brave)
- **Spaces for environments**: Dev Space, Staging Space, Production Space
- **Split view**: Code + preview side-by-side
- **Boosts**: Custom CSS for local development sites
- **Extension support**: React DevTools, Vue DevTools, Redux DevTools (from Chrome Web Store)

**Update Philosophy**:
- ✅ Arc updates ONLY via Homebrew (`rebuild` or `update` commands)
- ✅ In-app auto-update not available (Homebrew-managed installation)
- ✅ Versions controlled by Homebrew (managed by nix-darwin)
- ⚠️ Do NOT use "Check for updates" in About Arc menu (disabled for Homebrew installations)
- ✅ Account sync happens automatically (separate from app updates, this is expected)

**Arc vs Other Browsers**:

**Arc vs Brave**:
- **Privacy**: Brave has stronger built-in privacy (Shields, ad blocking) | Arc requires extensions
- **Workspaces**: Arc Spaces are superior | Brave has traditional tab groups
- **UI**: Arc has unique vertical sidebar | Brave is traditional Chrome-like
- **Updates**: Both controlled by Homebrew (no in-app settings)
- **Account**: Arc requires sign-in | Brave is optional

**Arc vs Chrome**:
- **UI**: Arc vertical sidebar + Spaces | Chrome traditional horizontal tabs
- **Privacy**: Arc has better default privacy | Chrome tracks more
- **Features**: Arc has Boosts, Easel, Little Arc | Chrome is minimal
- **Performance**: Both Chromium-based (similar performance)
- **Extensions**: Both support Chrome Web Store

**Arc vs Safari**:
- **Privacy**: Safari has superior privacy (Apple's ITP) | Arc is good but not Safari-level
- **Features**: Arc has Spaces, Boosts, Split View | Safari is simpler
- **Performance**: Safari better battery life | Arc uses more resources
- **Cross-platform**: Arc (Mac, Windows, iOS, Android) | Safari (Apple only)

**Known Issues**:
- **Account required**: Cannot use Arc without signing in (unlike other browsers)
- **Tab auto-archive**: Unpinned tabs disappear after 12 hours (pin important tabs to prevent)
- **Resource usage**: Chromium-based, similar memory usage to Chrome (can be high with many tabs)
- **Learning curve**: Unique UI takes adjustment (vertical sidebar, Spaces concept)
- **No built-in ad blocking**: Requires extensions (unlike Brave Shields)

**Resources**:
- Arc Documentation: https://resources.arc.net/
- Arc Keyboard Shortcuts: https://resources.arc.net/en/articles/6680315-keyboard-shortcuts-and-hotkeys
- Arc Community: https://community.arc.net/
- Chrome Web Store (extensions): https://chrome.google.com/webstore
- Arc Feature Guides: https://resources.arc.net/en/collections/3125050-features

---

## Productivity & Utilities

### Raycast

**Status**: Installed via Homebrew cask `raycast` (Story 02.4-001)

**Purpose**: Application launcher and productivity tool. Modern alternative to Spotlight/Alfred with powerful features like clipboard history, window management, snippets, and extensions.

**First Launch**:
1. Launch Raycast from Spotlight (`Cmd+Space`, type "Raycast") or from `/Applications/Raycast.app`
2. Welcome screen appears with onboarding wizard
3. Follow onboarding steps:
   - **Hotkey Setup** (REQUIRED): Choose your preferred launch hotkey
     - **Recommended**: `Option+Space` (leaves Cmd+Space for Spotlight)
     - **Alternative**: `Cmd+Space` (replaces Spotlight as default launcher)
     - Can be changed later in Preferences → General → Raycast Hotkey
   - Sign in with Raycast account (optional - enables sync across devices)
   - Complete onboarding tour (learn about commands, extensions, etc.)

**Hotkey Configuration**:

The hotkey is the primary way to invoke Raycast. It must be configured on first launch.

**Recommended Setup**:
- **Raycast**: `Option+Space` (or `Cmd+Space` if replacing Spotlight entirely)
- **Spotlight** (if keeping): `Cmd+Space` (or disable if using Raycast as full replacement)

**To Change Hotkey Later**:
1. Open Raycast (use current hotkey or launch from Applications)
2. Open Preferences: Type "Preferences" in Raycast search → **General**
3. Click on **Raycast Hotkey** field
4. Press your desired key combination
5. Click away or press Enter to save

**Note**: If you choose `Cmd+Space` for Raycast, macOS may warn you that Spotlight uses that key. You can:
- Replace Spotlight hotkey (System Settings → Keyboard → Keyboard Shortcuts → Spotlight → Change hotkey)
- Keep both (macOS will prioritize Raycast if set up first)

**Auto-Update Configuration** (REQUIRED):

Raycast updates must be disabled to maintain declarative configuration control.

**Steps to Disable Auto-Update**:
1. Launch Raycast (press your configured hotkey)
2. Search for "Preferences" and press Enter
3. Navigate to **Advanced** tab
4. Find **Updates** section
5. **Uncheck** "Automatically download and install updates"
6. Close Preferences

**Verification**:
- Open Raycast Preferences → Advanced
- Confirm "Automatically download and install updates" is **unchecked**
- Updates will now only occur via `darwin-rebuild switch` (controlled by Homebrew)

**Update Process** (Controlled by Homebrew):
```bash
# To update Raycast (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Core Features**:

Raycast is a powerful productivity tool with many built-in features:

1. **Application Launcher**:
   - Press hotkey → Type app name → Press Enter
   - Faster than Spotlight with better search
   - Recently used apps appear first

2. **File Search**:
   - Type filename or press `Space` to search by name
   - Integrates with macOS Spotlight index
   - Faster than Finder search

3. **Clipboard History**:
   - Search command: "Clipboard History"
   - View and paste from clipboard history
   - Searchable text snippets
   - Can pin frequently used items

4. **Window Management**:
   - Search command: "Window Management"
   - Quickly resize/move windows (left half, right half, maximize, etc.)
   - Keyboard-driven window tiling

5. **Snippets**:
   - Create text snippets with shortcuts
   - Auto-expand when you type abbreviation
   - Great for email templates, code snippets, etc.

6. **Extensions**:
   - Browse and install extensions: Search "Store" in Raycast
   - Extensions available for GitHub, Slack, Jira, Notion, etc.
   - User can add manually after installation (optional)

7. **Calculator**:
   - Type math expression directly in Raycast
   - Instant calculation results
   - Copy result to clipboard

8. **System Commands**:
   - Search "Quit All Applications", "Empty Trash", "Sleep", etc.
   - Quick access to common system tasks

**Basic Usage Examples**:
- Launch app: Press hotkey → Type "Brave" → Enter
- Search file: Press hotkey → Type filename → Enter
- View clipboard: Press hotkey → Type "Clipboard History" → Enter
- Window management: Press hotkey → Type "Left Half" → Enter (resizes active window)
- Calculator: Press hotkey → Type "2+2" → See result

**Configuration Tips**:
- Customize appearance: Preferences → Appearance (Light/Dark theme)
- Add favorite commands: Star commands to pin them to the top
- Keyboard shortcuts: Most actions have keyboard shortcuts (shown on right side)
- Organize extensions: Preferences → Extensions (enable/disable as needed)

**No License Required**:
- Raycast is **free** for personal use (no license key needed)
- Optional Raycast Pro subscription available (sync, advanced features)
- Pro features are optional - base functionality is fully free

**Setting as Default Launcher** (Optional):
- If using `Cmd+Space` hotkey for Raycast, it becomes your default launcher
- Spotlight can still be accessed via:
  - Menu Bar → Spotlight icon
  - System Settings → Keyboard → Keyboard Shortcuts → Spotlight → Set different hotkey
  - Or keep Spotlight disabled if Raycast is preferred

**Testing Checklist**:
- [ ] Raycast installed and launches
- [ ] Hotkey configured (Option+Space or Cmd+Space)
- [ ] Can launch applications via Raycast
- [ ] Can search files via Raycast
- [ ] Auto-update disabled (Preferences → Advanced)
- [ ] Extensions available (Store accessible)
- [ ] Clipboard history works
- [ ] Window management commands available

**Documentation**:
- Official Docs: https://manual.raycast.com/
- Extension Store: https://www.raycast.com/store
- Keyboard Shortcuts Guide: https://manual.raycast.com/hotkeys

---

### 1Password

**Status**: Installed via Homebrew cask `1password` (Story 02.4-002)

**Purpose**: Password manager and secure vault. Manages passwords, secure notes, credit cards, identities, documents, and licenses across all devices with end-to-end encryption.

**First Launch**:
1. Launch 1Password from Spotlight (`Cmd+Space`, type "1Password") or from `/Applications/1Password.app`
2. Welcome screen appears with account setup wizard
3. Follow setup steps:
   - **Account Sign-In** (REQUIRED): Sign in with existing 1Password account
     - Enter your email address
     - Enter your Master Password
     - Enter your Secret Key (34-character code from account setup)
   - **OR Create New Account**: Create a new 1Password.com account
     - Choose account type (Individual, Family, Team)
     - Set up Master Password (CRITICAL: This cannot be recovered if lost)
     - Save Secret Key securely (needed for account recovery)
   - **Biometric Unlock** (Optional): Enable Touch ID for quick unlocking
   - **Browser Extension** (Recommended): Install browser extensions for autofill

**Account Sign-In Process**:

1Password requires a 1Password.com account (no separate license key needed).

**If You Already Have a 1Password Account**:
1. Launch 1Password
2. Click "Sign In to 1Password Account"
3. Enter your email address → Continue
4. Enter your Master Password
5. Enter your Secret Key (found in Emergency Kit or previous installation)
6. Click "Sign In"
7. 1Password syncs your vault from the cloud

**If You Need to Create a New Account**:
1. Launch 1Password
2. Click "Try 1Password Free" or "Create Account"
3. Choose account type:
   - **Individual**: $2.99/month (single user, unlimited devices)
   - **Families**: $4.99/month (5 family members, shared vaults)
   - **Teams**: Business pricing (team vaults, admin controls)
4. Enter email address → Continue
5. Create a **strong Master Password** (CRITICAL: Cannot be recovered if lost!)
   - Use a memorable but secure passphrase
   - Write it down in a safe physical location
   - This is the ONLY password you need to remember
6. Save your **Secret Key** (34-character code):
   - Download Emergency Kit PDF
   - Print Emergency Kit and store securely
   - Secret Key is required for account recovery and new device setup
7. Complete sign-up and billing information
8. 1Password creates your vault and syncs to the cloud

**Auto-Update Configuration** (REQUIRED):

1Password updates must be disabled to maintain declarative configuration control.

**Steps to Disable Auto-Update**:
1. Launch 1Password (or click menubar icon)
2. Click **1Password** in menu bar → **Settings...** (or press `Cmd+,`)
3. Navigate to **Advanced** tab
4. Find **Updates** section
5. **Uncheck** "Check for updates automatically"
6. Close Settings

**Verification**:
- Open 1Password Settings → Advanced
- Confirm "Check for updates automatically" is **unchecked**
- Updates will now only occur via `darwin-rebuild switch` (controlled by Homebrew)

**Update Process** (Controlled by Homebrew):
```bash
# To update 1Password (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Browser Extension Setup** (RECOMMENDED):

1Password browser extensions enable autofill and password generation in web browsers.

**Installing Browser Extensions**:

1. **Safari** (macOS built-in browser):
   - 1Password automatically detects Safari on first launch
   - Click "Install Extension" when prompted
   - OR: Safari → Settings → Extensions → Enable 1Password extension
   - Grant permissions when requested

2. **Brave Browser** (if installed):
   - Visit Chrome Web Store: https://chrome.google.com/webstore/detail/1password/aeblfdkhhhdcdjpifhhbdiojplfjncoa
   - Click "Add to Brave"
   - OR: 1Password → Settings → Browser → Click "Install Extension" next to Brave
   - Grant permissions when requested

3. **Arc Browser** (if installed):
   - Visit Chrome Web Store: https://chrome.google.com/webstore/detail/1password/aeblfdkhhhdcdjpifhhbdiojplfjncoa
   - Click "Add to Arc"
   - OR: 1Password → Settings → Browser → Click "Install Extension" next to Arc
   - Grant permissions when requested

4. **Firefox** (if installed):
   - Visit Firefox Add-ons: https://addons.mozilla.org/en-US/firefox/addon/1password-x-password-manager/
   - Click "Add to Firefox"
   - OR: 1Password → Settings → Browser → Click "Install Extension" next to Firefox
   - Grant permissions when requested

**Browser Extension Setup**:
1. Install extension for your browser(s)
2. Extension icon appears in browser toolbar
3. Click extension icon → Sign in to 1Password account
4. Extension connects to 1Password app on Mac
5. Now you can autofill passwords and generate secure passwords in browser

**Core Features**:

1Password provides comprehensive password and secure information management:

1. **Password Management**:
   - Store unlimited passwords with strong encryption
   - Autofill passwords in browsers and apps
   - Generate strong, random passwords
   - Password strength analysis (Watchtower)
   - Duplicate password detection
   - Reused password alerts

2. **Secure Notes**:
   - Store sensitive text information securely
   - Notes are encrypted end-to-end
   - Organize with tags and favorites
   - Support for Markdown formatting

3. **Credit Cards & Payment Methods**:
   - Store credit card details securely
   - Autofill payment information in browsers
   - Track expiration dates
   - Store multiple cards and accounts

4. **Identities & Personal Information**:
   - Store identity information (name, address, phone, etc.)
   - Autofill forms with personal data
   - Multiple identities (work, personal, etc.)
   - Driver's license, passport, social security storage

5. **Document Storage**:
   - Store secure documents (PDFs, images, licenses)
   - End-to-end encrypted file storage
   - Up to 1GB per document (Individual plan)
   - Access documents across all devices

6. **SSH Key Management**:
   - Store SSH private keys securely
   - Use SSH keys from 1Password in terminal
   - Integration with `ssh-agent`
   - GitHub, GitLab, Bitbucket SSH key support

7. **Watchtower** (Security Auditing):
   - Weak password detection
   - Reused password alerts
   - Compromised website monitoring (Have I Been Pwned integration)
   - Two-factor authentication availability alerts
   - Expiring credit card notifications

8. **Shared Vaults** (Family/Team plans):
   - Share passwords with family members or team
   - Shared vaults for common accounts
   - Individual vaults remain private
   - Admin controls for team accounts

**Basic Usage Examples**:

**Saving a New Password**:
1. Open 1Password app
2. Click "+" button → "Login"
3. Enter website URL, username, password
4. OR: Use browser extension "Save Login" when logging into website
5. Password saved to vault

**Autofilling a Password**:
1. Visit login page in browser
2. Click in username or password field
3. Browser extension icon appears in field
4. Click icon → Select account → Password autofilled
5. OR: Click browser extension toolbar icon → Search for site → Click to autofill

**Generating a Strong Password**:
1. When creating new account on website
2. Click in password field
3. Browser extension suggests strong password
4. Click "Use Suggested Password"
5. Password saved automatically to 1Password

**Searching for Items**:
1. Open 1Password app
2. Use search bar at top (or press `Cmd+F`)
3. Type website name, username, or keyword
4. Click result to view/copy password

**Quick Access** (Menubar):
1. Click 1Password icon in menubar
2. Search for password or item
3. Press Enter to copy password
4. OR: Click to open full item details

**Configuration Tips**:

1. **Organize with Tags**:
   - Add tags to items for better organization
   - Tag examples: "work", "personal", "banking", "social"
   - Filter by tag in sidebar

2. **Favorites**:
   - Star frequently used items
   - Favorites appear at top of search results
   - Quick access to most-used passwords

3. **Security Settings**:
   - Settings → Security
   - Enable Touch ID unlock (recommended)
   - Set auto-lock timeout (5 minutes recommended)
   - Require Master Password for sensitive actions

4. **Browser Integration**:
   - Settings → Browser
   - Enable autofill for all installed browsers
   - Configure keyboard shortcuts
   - Enable password generator

5. **Watchtower Monitoring**:
   - Settings → Watchtower
   - Enable "Check for vulnerable passwords"
   - Enable "Check for reused passwords"
   - Review Watchtower alerts regularly

6. **Two-Factor Authentication**:
   - Store 2FA codes in 1Password (one-time passwords)
   - Auto-copy 2FA code when autofilling password
   - Authenticator app replacement (optional)

**License Requirements**:

1Password is a **subscription-based service** (no separate license key):
- **Individual**: $2.99/month (single user, unlimited devices, 1GB documents)
- **Families**: $4.99/month (5 family members, shared vaults, 1GB per person)
- **Free Trial**: 14 days free trial available (no credit card required)
- **Account Required**: Sign in with 1Password.com account (created during first launch)

**Important**: Your 1Password subscription is managed through your 1Password.com account, not through the Mac App Store or a license file.

**Post-Install Checklist**:
- [ ] 1Password installed and launches
- [ ] Signed in with 1Password account (or created new account)
- [ ] Master Password set and saved securely
- [ ] Secret Key saved in Emergency Kit (if new account)
- [ ] Touch ID enabled for quick unlock (optional but recommended)
- [ ] Auto-update disabled (Settings → Advanced → Uncheck "Check for updates automatically")
- [ ] Browser extensions installed (Safari, Brave, Arc, Firefox)
- [ ] Browser extensions connected to 1Password app
- [ ] Can autofill passwords in browser
- [ ] Can generate strong passwords
- [ ] Watchtower enabled for security monitoring

**Testing Checklist**:
- [ ] 1Password app launches successfully
- [ ] Account sign-in works (or new account created)
- [ ] Master Password unlock works
- [ ] Touch ID unlock works (if enabled)
- [ ] Browser extension installed and working
- [ ] Can save new password via browser extension
- [ ] Can autofill password on website
- [ ] Can generate strong password
- [ ] Watchtower shows security status
- [ ] Auto-update disabled (Settings → Advanced)
- [ ] Menubar quick access works

**Documentation**:
- Official Support: https://support.1password.com/
- Getting Started Guide: https://support.1password.com/get-started/
- Browser Extension Guide: https://support.1password.com/getting-started-browser/
- SSH Keys Guide: https://developer.1password.com/docs/ssh/
- Security Whitepaper: https://1password.com/security/

**Troubleshooting**:

**Issue**: Browser extension not connecting to 1Password app
- **Solution**: Open 1Password app → Settings → Browser → Enable browser integration
- Verify extension is installed and enabled in browser settings

**Issue**: Can't remember Master Password
- **Solution**: Master Password CANNOT be recovered (by design)
- Use Emergency Kit Secret Key + account email to reset (if account recovery enabled)
- Contact 1Password support for account recovery options

**Issue**: Touch ID not working
- **Solution**: Settings → Security → Re-enable Touch ID
- May need to re-enter Master Password first

**Issue**: Autofill not working in specific app or website
- **Solution**: Try manually copying password from 1Password app
- Browser extension may need permissions for specific domain
- Check browser extension settings for blocked sites

---

### Calibre

**Status**: Installed via Homebrew cask `calibre` (Story 02.4-003)

**Purpose**: Comprehensive ebook library manager and converter. Manages ebook collections, converts between formats (EPUB, MOBI, AZW3, PDF, etc.), reads ebooks, syncs to ebook readers, and edits metadata.

**First Launch**:
1. Launch Calibre from Spotlight (`Cmd+Space`, type "Calibre") or from `/Applications/calibre.app`
2. Welcome wizard appears on first launch
3. Follow setup steps:
   - **Choose Library Location**: Select or create folder for ebook library (default: `~/Calibre Library`)
   - **Choose E-reader Device** (Optional): Select if you have a Kindle, Kobo, or other e-reader
   - **Complete Setup**: Calibre creates library database

**Auto-Update Configuration** (REQUIRED):

Calibre updates must be disabled to maintain declarative configuration control.

**Steps to Disable Auto-Update**:
1. Launch Calibre
2. Click **Calibre** in menu bar → **Preferences**
3. Navigate to **Miscellaneous** section (bottom of sidebar)
4. Find **Updates** section
5. **Uncheck** "Automatically check for updates"
6. Click **Apply** → **Close**

**Verification**:
- Open Calibre Preferences → Miscellaneous
- Confirm "Automatically check for updates" is **unchecked**
- Updates will now only occur via `darwin-rebuild switch` (controlled by Homebrew)

**Update Process** (Controlled by Homebrew):
```bash
# To update Calibre (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Core Features**:

Calibre is a powerful ebook management suite with comprehensive features:

1. **Library Management**:
   - Organize unlimited ebooks in searchable library
   - Support for all major formats (EPUB, MOBI, AZW3, PDF, TXT, HTML, etc.)
   - Metadata editing (title, author, series, tags, cover, description)
   - Smart collections and saved searches
   - Duplicate detection
   - Virtual libraries (filtered views)

2. **Format Conversion**:
   - Convert between any ebook formats
   - Batch conversion support
   - Preserve metadata during conversion
   - Custom conversion settings per format
   - Common conversions: PDF → EPUB, MOBI → EPUB, EPUB → AZW3

3. **Ebook Reading**:
   - Built-in ebook reader with customizable display
   - Annotations and highlights
   - Dictionary lookup
   - Table of contents navigation
   - Bookmarks and reading position sync

4. **Device Sync**:
   - Sync library to Kindle, Kobo, Nook, and other e-readers
   - USB device detection and automatic sync
   - Wireless sync support (for compatible devices)
   - Send books via email to Kindle

5. **Metadata Editing**:
   - Download metadata from online sources (Amazon, Google Books, etc.)
   - Bulk metadata editing
   - Custom cover download and editing
   - Series management with reading order
   - Tag and category organization

6. **News Download**:
   - Download news from websites as ebooks
   - Schedule automatic news downloads
   - Send news to e-reader devices

**Basic Usage Examples**:

**Adding Ebooks to Library**:
1. Drag and drop ebook files into Calibre window
2. OR: Click "Add books" button → Select files
3. Calibre imports and adds to library

**Converting Ebook Formats**:
1. Select book in library
2. Click "Convert books" button
3. Choose output format (EPUB, MOBI, AZW3, PDF)
4. Click "OK" → Conversion starts
5. Converted book appears in book details

**Reading Ebooks**:
1. Double-click book in library
2. OR: Right-click → Open with → E-book viewer
3. Calibre reader opens with customizable font, size, colors

**Sending to Kindle**:
1. Connect Kindle via USB (Calibre detects automatically)
2. Select books to send
3. Click "Send to device" button
4. Books transfer to Kindle

**Editing Metadata**:
1. Select book in library
2. Click "Edit metadata" button
3. Update title, author, series, tags, cover, etc.
4. Click "OK" to save changes

**Configuration Tips**:
- **Library Location**: Store in Dropbox or iCloud for cross-device sync
- **Metadata Sources**: Preferences → Sharing → Metadata download (configure sources)
- **Reading Preferences**: E-book viewer → Preferences (font, colors, margins)
- **Device Setup**: Preferences → Sharing → Sharing books by email (for Kindle email delivery)
- **Virtual Libraries**: Right sidebar → Virtual libraries → Create filtered views by tag, author, series

**No License Required**:
- Calibre is **free and open source** (no license key needed)
- All features available without payment
- Developed and maintained by Kovid Goyal

**Supported Formats**:
- **Input**: EPUB, MOBI, AZW, AZW3, AZW4, PRC, PDF, TXT, HTML, RTF, LIT, LRF, FB2, PDB, RB, SNB, TCR, and more
- **Output**: EPUB, MOBI, AZW3, PDF, TXT, HTML, FB2, PDB, LIT, LRF, TCR, SNB

**Testing Checklist**:
- [ ] Calibre installed and launches
- [ ] Welcome wizard completes successfully
- [ ] Library created at chosen location
- [ ] Can add ebook to library (drag/drop or Add books button)
- [ ] Can view book details and metadata
- [ ] Can convert between formats (e.g., PDF → EPUB)
- [ ] E-book viewer opens and displays book correctly
- [ ] Auto-update disabled (Preferences → Miscellaneous)
- [ ] Can edit metadata (title, author, cover)

**Documentation**:
- Official User Manual: https://manual.calibre-ebook.com/
- Format Conversion Guide: https://manual.calibre-ebook.com/conversion.html
- E-reader Device Guide: https://manual.calibre-ebook.com/devices.html

---

### Kindle

**Status**: Installed via Mac App Store (mas) `302584613` (Story 02.4-003)

**Purpose**: Official Amazon Kindle ebook reader for macOS. Read Kindle books purchased from Amazon, sync reading position across devices, access X-Ray features, take notes and highlights, and use Whispersync.

**First Launch**:
1. Launch Kindle from Spotlight (`Cmd+Space`, type "Kindle") or from `/Applications/Kindle.app`
2. Sign-in screen appears
3. Sign in with Amazon account:
   - Enter Amazon email/username
   - Enter Amazon password
   - Complete two-factor authentication if enabled
4. Library syncs from Amazon cloud
5. Downloaded books appear in "Downloaded" tab

**Account Sign-In** (REQUIRED):

Kindle requires an Amazon account (no separate license needed).

**Sign-In Process**:
1. Launch Kindle app
2. Click "Sign In"
3. Enter your **Amazon account** email/username
4. Enter your **Amazon password**
5. Complete **two-factor authentication** if enabled (code sent to phone/email)
6. Click "Sign In"
7. Kindle syncs your library from Amazon cloud (books you own appear automatically)

**If You Don't Have an Amazon Account**:
1. Visit https://www.amazon.com/
2. Click "Create your Amazon account"
3. Follow account creation steps
4. No special Kindle subscription needed - use regular Amazon account
5. Then sign in to Kindle app with new Amazon credentials

**Auto-Update Configuration**:

Kindle updates are **managed by the Mac App Store system preferences** (no in-app setting).

**System-Wide Auto-Update Control**:
- Mac App Store auto-updates controlled via System Settings
- To disable App Store auto-updates globally:
  1. Open **System Settings**
  2. Navigate to **App Store**
  3. **Uncheck** "Automatic Updates"
- This affects ALL Mac App Store apps (Kindle, Marked 2, Perplexity, etc.)

**Update Process** (Controlled by Mac App Store):
```bash
# Kindle updates managed by mas (Mac App Store CLI)
# Updates applied during darwin-rebuild when new version available
darwin-rebuild switch  # Checks for App Store app updates

# Manual update check:
mas upgrade  # Updates all outdated App Store apps
```

**Core Features**:

Kindle for Mac provides comprehensive ebook reading features:

1. **Ebook Reading**:
   - Read Kindle books with customizable fonts, sizes, and backgrounds
   - Full-screen reading mode
   - Page flip animations
   - Table of contents navigation
   - Bookmarks and annotations
   - Dictionary lookup (built-in dictionaries)

2. **Cloud Sync (Whispersync)**:
   - Reading position syncs across all devices (iPhone, iPad, Kindle e-reader, etc.)
   - Bookmarks and highlights sync
   - Notes sync
   - Last page read remembered

3. **X-Ray Features**:
   - Character and theme exploration
   - See all mentions of characters, places, themes
   - Wikipedia and Shelfari integration
   - Available for supported books

4. **Notes & Highlights**:
   - Highlight text passages
   - Add notes to highlighted text
   - View all notes and highlights
   - Export notes and highlights
   - Sync across devices via Whispersync

5. **Library Management**:
   - View all Kindle books owned
   - Download books for offline reading
   - Remove downloaded books (frees space, keeps in cloud)
   - Sort by title, author, recent
   - Search library

6. **Collections**:
   - Organize books into collections
   - Create custom collections
   - Collections sync to Kindle e-readers

**Basic Usage Examples**:

**Reading a Book**:
1. Open Kindle app
2. Click on book cover in Library
3. Book downloads (if not already downloaded) and opens
4. Click/swipe to turn pages
5. Reading position syncs automatically

**Adding Books to Library**:
- Books purchased from Amazon Kindle Store appear automatically
- Personal documents can be sent via Send to Kindle email
- No manual import of non-Amazon ebooks (use Calibre for that)

**Adjusting Reading Settings**:
1. Open a book
2. Click **Aa** button (top toolbar)
3. Adjust:
   - Font family
   - Font size
   - Line spacing
   - Margins
   - Background color (white, sepia, black)

**Taking Notes and Highlights**:
1. Select text with cursor
2. Click "Highlight" or "Note" from popup menu
3. Highlights appear in yellow (customizable color)
4. Notes saved with highlighted text
5. View all notes: Menu → View → Notes & Marks

**Syncing Reading Position**:
- Whispersync happens automatically when online
- Close book on Mac → Open on iPhone/iPad → Resume at same page
- Works across all Kindle devices and apps

**Configuration Tips**:
- **Download Books**: Right-click book → Download (for offline reading)
- **Remove Downloads**: Right-click book → Remove from Device (keeps in cloud, frees space)
- **Organize Collections**: Right-click book → Add to Collection
- **Dictionary**: Select word → Dictionary definition appears automatically
- **X-Ray**: Tap X-Ray button (if book supports it) → Explore characters, themes

**No License Required**:
- Kindle app is **free** (included with Amazon account)
- No subscription needed for basic use
- **Kindle Unlimited** subscription optional (monthly fee for unlimited reading of participating books)
- Read books you purchase from Amazon Kindle Store

**Supported Formats**:
- **Kindle formats**: AZW, AZW3, KFX, MOBI (Amazon proprietary formats)
- **Personal documents**: PDF, TXT, MOBI (via Send to Kindle email)
- **NOT supported**: EPUB (use Calibre to convert EPUB → MOBI first)

**Testing Checklist**:
- [ ] Kindle installed and launches
- [ ] Sign-in with Amazon account successful
- [ ] Library syncs from cloud (owned books appear)
- [ ] Can download a book for offline reading
- [ ] Can open and read a book
- [ ] Page navigation works (click/swipe)
- [ ] Reading settings adjustable (font, size, background)
- [ ] Can highlight text and add notes
- [ ] X-Ray feature works (if book supports it)
- [ ] Whispersync syncs reading position across devices

**Documentation**:
- Kindle for Mac Help: https://www.amazon.com/gp/help/customer/display.html?nodeId=G8XYGXFCRXT5W6WW
- Send to Kindle Guide: https://www.amazon.com/sendtokindle
- Kindle Unlimited (optional): https://www.amazon.com/kindle-unlimited

---

### Keka

**Status**: Installed via Homebrew cask `keka` (Story 02.4-003)

**Purpose**: Archive utility for macOS. Create and extract archives in multiple formats (zip, 7z, tar, gzip, rar, etc.) with password protection, compression level control, and macOS integration.

**First Launch**:
1. Launch Keka from Spotlight (`Cmd+Space`, type "Keka") or from `/Applications/Keka.app`
2. Main window appears showing drop zone
3. No configuration wizard (ready to use immediately)
4. Optionally set as default archive handler for file types

**File Association Setup** (OPTIONAL):

Keka can be set as the default application for opening archive files (.zip, .rar, .7z, etc.).

**Setting as Default Archive Handler**:

**Method 1: Via Keka Preferences**:
1. Launch Keka
2. Click **Keka** in menu bar → **Preferences**
3. Navigate to **Extraction** tab
4. Click **Set Keka as default application for** section
5. Check file types you want Keka to handle:
   - `□` zip
   - `□` rar
   - `□` 7z
   - `□` tar
   - `□` gzip
   - `□` bzip2
   - etc.
6. Click **Apply** or close Preferences (settings save automatically)

**Method 2: Via Finder (per file type)**:
1. Right-click any `.zip` file in Finder
2. Select **Get Info** (or press `Cmd+I`)
3. Expand **Open with:** section
4. Choose **Keka** from dropdown
5. Click **Change All...** (applies to all .zip files)
6. Repeat for other archive types (.rar, .7z, etc.)

**Auto-Update Configuration**:

Keka is **free and open source** with no auto-update mechanism requiring disable. Updates managed by Homebrew only.

**Update Process** (Controlled by Homebrew):
```bash
# To update Keka (along with all other apps):
darwin-rebuild switch  # Uses current flake.lock versions

# OR to get latest versions first:
nix flake update      # Updates flake.lock with latest package versions
darwin-rebuild switch # Applies the updates
```

**Core Features**:

Keka provides comprehensive archive management:

1. **Archive Creation**:
   - Drag and drop files/folders onto Keka window
   - Creates compressed archives in multiple formats
   - Supported output formats: 7z, zip, tar, gzip, bzip2, dmg, iso
   - Compression level control (store, fast, normal, good, ultra)
   - Split archives into multiple volumes
   - Password protection (AES-256 encryption for 7z and zip)

2. **Archive Extraction**:
   - Double-click archive → Extracts automatically
   - Right-click → Open with Keka
   - Drag and drop archive onto Keka window
   - Supported input formats: 7z, zip, rar, tar, gzip, bzip2, dmg, iso, lzma, xz, cab, msi, pkg, deb, rpm, and more
   - Password-protected archive support

3. **Compression Control**:
   - Choose compression method per archive
   - Balance between file size and compression time
   - Format-specific options (solid compression for 7z, etc.)

4. **Password Protection**:
   - Encrypt archives with password (AES-256)
   - Protect sensitive files
   - Works with 7z and zip formats

5. **macOS Integration**:
   - Drag and drop interface
   - Finder context menu integration
   - Quick Look support for archive contents
   - Notification Center integration

**Basic Usage Examples**:

**Creating a Zip Archive**:
1. Launch Keka (or drag files directly onto Keka icon in Dock)
2. Drag file(s) or folder(s) into Keka window
3. Choose format (zip, 7z, tar.gz, etc.) from dropdown
4. Click "Compress" or drag onto format button
5. Archive created in same location as original files

**Extracting an Archive**:
1. Double-click archive file (if Keka is default handler)
2. OR: Right-click archive → Open with → Keka
3. OR: Drag archive onto Keka window
4. Archive extracts to folder in same location

**Creating Password-Protected Archive**:
1. Drag files into Keka window
2. Choose **7z** or **zip** format (password support)
3. Click 🔒 (lock icon) → Enter password
4. Click "Compress"
5. Archive created with AES-256 encryption

**Extracting Password-Protected Archive**:
1. Double-click password-protected archive
2. Keka prompts for password
3. Enter password → Click OK
4. Archive extracts if password correct

**Configuration Tips**:
- **Default Format**: Preferences → Compression → Default format (zip, 7z, etc.)
- **Compression Level**: Preferences → Compression → Default compression method
- **Extraction Location**: Preferences → Extraction → Extract to (same folder, custom location, ask each time)
- **File Associations**: Preferences → Extraction → Set Keka as default for archive types
- **Password Manager Integration**: Use 1Password to generate and store archive passwords

**No License Required**:
- Keka is **free and open source** (no license key needed)
- Mac App Store version is paid ($4.99) to support development
- Homebrew version is free (official distribution method)
- All features available in both versions

**Supported Formats**:
- **Create**: 7z, zip, tar, gzip, bzip2, dmg, iso
- **Extract**: 7z, zip, rar, tar, gzip, bzip2, dmg, iso, lzma, xz, cab, msi, pkg, deb, rpm, exe (self-extracting), and more

**Testing Checklist**:
- [ ] Keka installed and launches
- [ ] Can create zip archive (drag files → choose zip → compress)
- [ ] Can extract zip archive (double-click .zip file)
- [ ] Can create 7z archive
- [ ] Can extract rar archive (if available)
- [ ] Password protection works (create password-protected 7z)
- [ ] Can extract password-protected archive
- [ ] File associations configurable (Preferences → Extraction)
- [ ] Compression level adjustable (Preferences → Compression)

**Documentation**:
- Official Website: https://www.keka.io/
- GitHub Repository: https://github.com/aonez/Keka
- Supported Formats List: https://www.keka.io/en/

---

### Marked 2

**Status**: Installed via Mac App Store (mas) `890031187` (Story 02.4-003)

**Purpose**: Markdown preview and export application. Live preview of Markdown files with syntax highlighting, export to PDF/HTML, custom CSS styling, multi-Markdown syntax support, and statistics.

**First Launch**:
1. Launch Marked 2 from Spotlight (`Cmd+Space`, type "Marked 2") or from `/Applications/Marked 2.app`
2. Main preview window appears
3. No sign-in required (purchased via Mac App Store)
4. Drag .md file into window or open via File → Open

**Auto-Update Configuration** (REQUIRED):

Marked 2 updates must be disabled to maintain declarative configuration control.

**Steps to Disable Auto-Update**:
1. Launch Marked 2
2. Click **Marked 2** in menu bar → **Preferences** (or press `Cmd+,`)
3. Navigate to **General** tab
4. Find **Updates** section
5. **Uncheck** "Check for updates automatically"
6. Close Preferences

**Verification**:
- Open Marked 2 Preferences → General
- Confirm "Check for updates automatically" is **unchecked**
- Updates will now only occur via `darwin-rebuild switch` (controlled by Mac App Store)

**Note**: Since Marked 2 is a Mac App Store app, system-wide App Store auto-updates should also be disabled:
1. Open **System Settings** → **App Store**
2. **Uncheck** "Automatic Updates" (affects all Mac App Store apps)

**Update Process** (Controlled by Mac App Store):
```bash
# Marked 2 updates managed by mas (Mac App Store CLI)
darwin-rebuild switch  # Checks for App Store app updates

# Manual update check:
mas upgrade  # Updates all outdated App Store apps
```

**Core Features**:

Marked 2 is a powerful Markdown preview and export tool:

1. **Live Markdown Preview**:
   - Real-time preview of Markdown files
   - Auto-refresh on file save (monitors file changes)
   - Syntax highlighting for code blocks
   - Support for GitHub Flavored Markdown (GFM)
   - Multi-Markdown (MMD) syntax support
   - Tables, footnotes, definition lists, task lists

2. **Export Capabilities**:
   - Export to **PDF** (print-quality, customizable)
   - Export to **HTML** (standalone or snippet)
   - Export to **RTF** (Rich Text Format)
   - Export to **DOCX** (Microsoft Word via Pandoc)
   - Custom CSS styling for exports
   - Include/exclude table of contents

3. **Custom Styling**:
   - Choose from built-in themes (GitHub, Swiss, Antique, etc.)
   - Custom CSS support (load your own stylesheets)
   - Preview with different CSS in real-time
   - Font size and family control

4. **Document Statistics**:
   - Word count, character count
   - Reading time estimate
   - Keyword frequency analysis
   - Readability scores (Flesch, Gunning Fog, etc.)

5. **Advanced Preview Features**:
   - Scroll sync (editor and preview in sync)
   - Mini-map navigation (see document structure)
   - Table of contents generation
   - MathJax support (LaTeX math rendering)
   - Mermaid diagram support
   - Critic Markup (track changes)

6. **Integration**:
   - Works with any text editor (VSCode, Zed, Vim, etc.)
   - File watcher monitors external edits
   - Drag and drop Markdown files
   - Open .md files directly from Finder

**Basic Usage Examples**:

**Previewing a Markdown File**:
1. Launch Marked 2
2. Drag `.md` file into Marked 2 window
3. OR: Click **File** → **Open** → Select .md file
4. Preview appears with rendered Markdown
5. Edit file in your text editor (Zed, VSCode, etc.) → Marked 2 auto-refreshes

**Exporting to PDF**:
1. Open Markdown file in Marked 2
2. Click **File** → **Export** → **PDF**
3. Choose export options:
   - Include table of contents
   - Custom CSS
   - Page size and margins
4. Click **Save** → PDF created

**Changing Preview Style**:
1. Open Markdown file in Marked 2
2. Click **Marked 2** menu → **Style** → Choose theme
3. Options: GitHub, Swiss, Antique, Manuscript, etc.
4. Preview updates with new CSS instantly

**Viewing Document Statistics**:
1. Open Markdown file in Marked 2
2. Click **Statistics** button (toolbar) OR **Marked 2** → **Statistics**
3. Panel shows:
   - Word count
   - Character count
   - Reading time
   - Readability scores

**Configuration Tips**:
- **Default Style**: Preferences → Style → Choose default preview CSS
- **Auto-Refresh**: Preferences → General → File refresh (on save, on focus, etc.)
- **Code Highlighting**: Preferences → Style → Choose syntax theme for code blocks
- **Export Defaults**: Preferences → Export → Default format, include TOC, etc.
- **Multi-Markdown**: Preferences → Processor → Enable MultiMarkdown features
- **MathJax/Mermaid**: Preferences → Advanced → Enable rendering engines

**License Requirements**:

Marked 2 is a **paid application** purchased via Mac App Store.

- **Price**: $14.99 (one-time purchase)
- **No subscription**: Pay once, use forever
- **License**: Tied to Apple ID (Mac App Store handles licensing)
- **Multiple Macs**: Install on all Macs using same Apple ID

**Supported Syntax**:
- **Standard Markdown**: Headings, lists, links, images, emphasis, code blocks
- **GitHub Flavored Markdown (GFM)**: Task lists, tables, strikethrough, fenced code blocks
- **MultiMarkdown (MMD)**: Footnotes, definition lists, tables, metadata, cross-references
- **Critic Markup**: Track changes and suggestions
- **MathJax**: LaTeX math equations
- **Mermaid**: Diagrams and flowcharts

**Testing Checklist**:
- [ ] Marked 2 installed and launches
- [ ] Can open .md file (drag/drop or File → Open)
- [ ] Markdown preview renders correctly
- [ ] Live reload works (edit file in Zed → Marked 2 updates)
- [ ] Can change preview style (Marked 2 → Style → Choose theme)
- [ ] Can export to PDF (File → Export → PDF)
- [ ] Can export to HTML (File → Export → HTML)
- [ ] Statistics panel shows word count, reading time
- [ ] Auto-update disabled (Preferences → General)
- [ ] Code blocks have syntax highlighting
- [ ] Tables render correctly (GFM syntax)

**Documentation**:
- Official User Guide: https://marked2app.com/help/
- Markdown Syntax Reference: https://marked2app.com/help/Markdown_Syntax.html
- Export Guide: https://marked2app.com/help/Export.html
- Custom CSS Guide: https://marked2app.com/help/Custom_CSS.html

---

### WhatsApp

**Status**: Installed via Mac App Store (mas) `1147396723` (Story 02.5-001)

**Purpose**: Official WhatsApp desktop messaging application. Send and receive WhatsApp messages from your Mac, sync conversations with phone, make voice/video calls, share files, and stay connected without constant phone access.

**First Launch**:
1. Launch WhatsApp from Spotlight (`Cmd+Space`, type "WhatsApp") or from `/Applications/WhatsApp.app`
2. **QR Code screen** appears with link instructions
3. **Phone Required**: WhatsApp Desktop requires linking to WhatsApp on your phone
4. No independent desktop account - Mac app mirrors phone WhatsApp

**Account Linking** (REQUIRED):

WhatsApp Desktop **requires** an existing WhatsApp account on your phone. You cannot create a WhatsApp account on Mac - phone setup is mandatory.

**QR Code Linking Process**:
1. **Ensure Phone Has WhatsApp**:
   - Install WhatsApp on your **iPhone** or **Android phone** (free from App Store/Play Store)
   - Set up WhatsApp on phone with phone number verification
   - Must have active WhatsApp account before linking desktop

2. **Link WhatsApp Desktop to Phone**:
   - Launch WhatsApp Desktop on Mac (QR code appears)
   - On your **phone**, open WhatsApp app
   - **iPhone**: Tap **Settings** (bottom right) → **Linked Devices** → **Link a Device**
   - **Android**: Tap **⋮** (three dots, top right) → **Linked Devices** → **Link a Device**
   - Phone camera opens in QR scanner mode

3. **Scan QR Code**:
   - Point phone camera at QR code on Mac screen
   - Phone scans code automatically
   - Wait for "Linked!" confirmation on phone
   - WhatsApp Desktop syncs conversations (may take 1-2 minutes)

4. **Verification Complete**:
   - WhatsApp Desktop shows your conversations
   - Messages sync between phone and Mac
   - Desktop app is now fully functional

**If You Don't Have WhatsApp on Phone**:
1. Download WhatsApp from App Store (iPhone) or Google Play (Android)
2. Launch WhatsApp app on phone
3. Verify phone number with SMS code
4. Set up profile (name, photo)
5. **Then** link WhatsApp Desktop via QR code

**Auto-Update Configuration**:

WhatsApp updates are **managed by the Mac App Store system preferences** (no in-app auto-update setting).

**System-Wide Auto-Update Control**:
- Mac App Store auto-updates controlled via System Settings
- To disable App Store auto-updates globally:
  1. Open **System Settings**
  2. Navigate to **App Store**
  3. **Uncheck** "Automatic Updates"
- This affects ALL Mac App Store apps (WhatsApp, Kindle, Marked 2, Perplexity, etc.)

**Update Process** (Controlled by Mac App Store):
```bash
# WhatsApp updates managed by mas (Mac App Store CLI)
# Updates applied during darwin-rebuild when new version available
darwin-rebuild switch  # Checks for App Store app updates

# Manual update check:
mas upgrade  # Updates all outdated App Store apps
```

**Permissions Required**:

WhatsApp Desktop requests several macOS permissions for full functionality:

1. **Notifications** (Required):
   - **Purpose**: Show message notifications on Mac
   - **Prompt**: Appears on first launch
   - **Recommendation**: **Allow** (essential for message alerts)
   - **Manual Enable**: System Settings → Notifications → WhatsApp → Enable

2. **Microphone** (Optional, for Voice/Video Calls):
   - **Purpose**: Make voice and video calls from Mac
   - **Prompt**: Appears when attempting first call
   - **Recommendation**: **Allow** if using calls (deny if messaging only)
   - **Manual Enable**: System Settings → Privacy & Security → Microphone → Enable WhatsApp

3. **Camera** (Optional, for Video Calls):
   - **Purpose**: Make video calls from Mac
   - **Prompt**: Appears when attempting first video call
   - **Recommendation**: **Allow** if using video calls (deny if not needed)
   - **Manual Enable**: System Settings → Privacy & Security → Camera → Enable WhatsApp

4. **Contacts** (Optional):
   - **Purpose**: See contact names instead of phone numbers
   - **Prompt**: May appear during setup
   - **Recommendation**: **Optional** (contacts sync from phone anyway)
   - **Manual Enable**: System Settings → Privacy & Security → Contacts → Enable WhatsApp

**Core Features**:

WhatsApp Desktop provides comprehensive messaging and communication features:

1. **Messaging**:
   - Send and receive text messages
   - Reply to specific messages (quote/reply)
   - Forward messages to other chats
   - Delete messages (for everyone or just you)
   - Edit sent messages (within 15 minutes)
   - Star important messages for quick access
   - Search conversations (by contact, message content, date)

2. **Media Sharing**:
   - Send photos and videos
   - Share documents (PDF, DOCX, ZIP, etc.) up to 2GB per file
   - Send voice messages (record via microphone)
   - Share contacts from phone
   - Share location (via map link)
   - Drag and drop files into chat window

3. **Voice and Video Calls**:
   - Voice calls (one-on-one or group)
   - Video calls (one-on-one or group)
   - Screen sharing during calls
   - Call encryption (end-to-end)
   - Call history syncs with phone

4. **Group Chats**:
   - Create groups (up to 1024 members)
   - Group admin controls (add/remove members, change settings)
   - Group descriptions and icons
   - Mute group notifications
   - Broadcast lists (send message to multiple contacts without group)

5. **Sync and Backup**:
   - **Real-time sync**: Messages appear on both phone and Mac instantly
   - **Message history**: Syncs recent conversations from phone
   - **Backup**: WhatsApp backup managed on phone (iCloud for iPhone, Google Drive for Android)
   - **Media download**: Choose to auto-download media or manual download only

6. **Privacy and Security**:
   - **End-to-end encryption**: All messages and calls encrypted
   - **Two-step verification**: Optional PIN for account security (set up on phone)
   - **Disappearing messages**: Set messages to auto-delete after 24h/7d/90d
   - **View once media**: Send photos/videos that disappear after viewing
   - **Block contacts**: Block unwanted contacts (sync across devices)

**Basic Usage Examples**:

**Sending a Message**:
1. Open WhatsApp Desktop
2. Click on contact or group in left sidebar
3. Type message in text field at bottom
4. Press **Enter** to send (or **Shift+Enter** for new line)

**Sending a File/Photo**:
1. Open chat with contact or group
2. Click **📎** (paperclip) icon OR drag file into chat window
3. Choose file type:
   - **Photos & Videos**: Browse photos/videos
   - **Documents**: Browse documents (PDF, DOCX, ZIP, etc.)
4. Select file → Click **Send**
5. File uploads and sends (progress bar shows upload status)

**Making a Voice/Video Call**:
1. Open chat with contact
2. Click **📞** (phone) icon for voice call OR **🎥** (video camera) for video call
3. Call connects (requires microphone/camera permissions)
4. During call:
   - **Mute**: Click 🎤 icon to mute/unmute
   - **Video toggle**: Click 📹 to turn video on/off
   - **End call**: Click red phone icon

**Creating a Group**:
1. Click **☰** (menu) in top left → **New Group**
2. Select contacts to add (search or scroll)
3. Click **→** (next arrow)
4. Set group name and optional icon
5. Click **✓** (checkmark) to create group
6. Group appears in chat list

**Searching Messages**:
1. Click **🔍** (search) icon at top
2. Type search query (contact name, message text, etc.)
3. Results appear with context (message preview, date)
4. Click result to jump to that message in chat

**Archiving Chats**:
1. Right-click chat in sidebar (or swipe left on trackpad)
2. Click **Archive chat**
3. Chat moves to Archive (hidden from main list)
4. View archived chats: Scroll to top of chat list → **Archived** section

**Pinning Important Chats**:
1. Right-click chat in sidebar
2. Click **Pin chat**
3. Chat stays at top of chat list (up to 3 pinned chats)
4. Unpin: Right-click pinned chat → **Unpin chat**

**Configuration Tips**:
- **Notifications**: WhatsApp → Settings → Notifications → Customize sound, badges, previews
- **Theme**: WhatsApp → Settings → Theme → Light/Dark/System (follows macOS appearance)
- **Privacy**: WhatsApp → Settings → Privacy → Last seen, profile photo, about visibility
- **Keyboard Shortcuts**: WhatsApp → Settings → Keyboard Shortcuts → Customize shortcuts
- **Download Location**: WhatsApp → Settings → Storage → Change download folder
- **Media Auto-Download**: Settings → Storage → Disable auto-download to save bandwidth/space

**Linking Multiple Devices**:

WhatsApp supports **up to 4 linked devices** simultaneously (in addition to your phone):
- Mac, iPad, another Mac, etc.
- Each device requires separate QR code linking
- All devices stay in sync (messages appear everywhere)
- Linked devices work even when phone is offline (after initial linking)

**To Link Another Device**:
1. On phone: WhatsApp → Settings/Menu → **Linked Devices**
2. Tap **Link a Device**
3. Scan QR code on other device
4. Device links and syncs

**To Unlink WhatsApp Desktop**:
1. On phone: WhatsApp → Settings/Menu → **Linked Devices**
2. Find "WhatsApp on Mac" in linked devices list
3. Tap device → **Log Out**
4. Desktop app disconnects (shows QR code screen again)

**No License Required**:
- WhatsApp is **free** (no subscription, no ads)
- Owned by Meta (Facebook parent company)
- No premium features or paid tiers
- Unlimited messaging, calls, and media sharing

**Data and Privacy**:
- **End-to-end encryption**: Meta cannot read messages/calls
- **Message storage**: Messages stored on phone (not in cloud)
- **Backup**: Optional backup to iCloud (iPhone) or Google Drive (Android)
- **Desktop sync**: Recent messages sync to desktop (deleted when unlinking)
- **Metadata**: Meta collects usage metadata (who you message, when, frequency)

**Troubleshooting**:

**QR Code Not Scanning**:
- Ensure phone WhatsApp is up to date
- Restart WhatsApp Desktop (quit and relaunch)
- Refresh QR code (click "Click to reload QR code" link)
- Clean phone camera lens
- Ensure good lighting (QR code must be clearly visible)

**Messages Not Syncing**:
- Check internet connection on both phone and Mac
- Ensure phone WhatsApp is running (doesn't need to be foreground)
- Unlink and re-link desktop: Phone → Linked Devices → Log Out → Link again

**Calls Not Working**:
- Check microphone/camera permissions (System Settings → Privacy & Security)
- Test microphone: System Settings → Sound → Input → Speak and check levels
- Restart WhatsApp Desktop
- Update WhatsApp on both phone and desktop

**Desktop Shows "Phone Not Connected"**:
- Ensure phone has internet connection (Wi-Fi or cellular)
- Open WhatsApp on phone (wake it up)
- Check phone battery saver isn't killing WhatsApp background process
- Re-link if issue persists

**Testing Checklist**:
- [ ] WhatsApp installed and launches
- [ ] QR code screen appears on first launch
- [ ] Can link to phone via QR code scan
- [ ] Conversations sync from phone (recent messages appear)
- [ ] Can send text message from desktop
- [ ] Can receive messages on desktop (send from phone → appears on Mac)
- [ ] Can send photo/file (click paperclip → select file → send)
- [ ] Can make voice call (microphone permission granted)
- [ ] Can make video call (camera + microphone permissions granted)
- [ ] Notifications work (send message to self → notification appears)
- [ ] Can create new group chat
- [ ] Can search messages (click search → type query → results appear)
- [ ] App accessible from Spotlight/Raycast
- [ ] App stays synced when phone is locked (messages still deliver)

**Documentation**:
- WhatsApp Desktop Help: https://faq.whatsapp.com/1317564615384230/
- Linking Devices Guide: https://faq.whatsapp.com/1317564615384230/#link
- Privacy & Security: https://www.whatsapp.com/security/
- Desktop Features: https://faq.whatsapp.com/478868410920146/

---

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
**Story 02.2-002**: VSCode - ✅ Installation and configuration implemented
  - ✅ Homebrew cask added to darwin/homebrew.nix (visual-studio-code)
  - ✅ Home Manager module created (home-manager/modules/vscode.nix)
  - ✅ Settings template created (config/vscode/settings.json)
  - ✅ Catppuccin Mocha theme configured (requires manual extension install)
  - ✅ JetBrains Mono font with ligatures enabled
  - ✅ Auto-update disabled (update.mode: none, extensions.autoUpdate: false)
  - ✅ REQ-NFR-008 compliant: Bidirectional sync via symlink to repo
  - ⚠️ VM testing pending: Theme application (after extension install), font rendering, bidirectional sync verification
**Story 02.2-004**: Python and Development Tools - ✅ Installation implemented
  - ✅ Python 3.12 added to darwin/configuration.nix
  - ✅ uv package installer added
  - ✅ Development tools added: ruff, black, isort, mypy, pylint
  - ✅ Documentation added to app-post-install-configuration.md
  - ⚠️ VM testing pending: Tool installation, version verification, uv project creation
**Story 02.3-001**: Brave Browser - ✅ Installation and documentation implemented
  - ✅ Homebrew cask added to darwin/homebrew.nix (brave-browser)
  - ✅ Comprehensive documentation added to app-post-install-configuration.md
  - ✅ Auto-update disable instructions documented
  - ✅ Brave Shields configuration and verification steps documented
  - ✅ Privacy features, default browser setup, and troubleshooting documented
  - ⚠️ VM testing pending: Installation verification, auto-update disable, Shields functionality
**Story 02.2-006**: Claude Code CLI and MCP Servers - ✅ Installation and configuration implemented
  - ✅ claude-code-nix flake input added to flake.nix
  - ✅ mcp-servers-nix flake input added to flake.nix
  - ✅ Claude Code CLI added to darwin/configuration.nix systemPackages
  - ✅ MCP servers added to systemPackages: context7, github, sequential-thinking
  - ✅ Home Manager module created (home-manager/modules/claude-code.nix)
  - ✅ REQ-NFR-008 compliant bidirectional sync via repository symlinks
  - ✅ `~/.claude/CLAUDE.md` → `$REPO/config/claude/CLAUDE.md`
  - ✅ `~/.claude/agents/` → `$REPO/config/claude/agents/`
  - ✅ `~/.claude/commands/` → `$REPO/config/claude/commands/`
  - ✅ MCP config created: `~/.config/claude/config.json`
  - ✅ Comprehensive documentation added to app-post-install-configuration.md (370+ lines)
  - ✅ VM testing guide created: docs/testing-claude-code-cli.md (7 scenarios)
  - ✅ bootstrap.sh Phase 4 updated to download claude-code.nix module
  - ⚠️ VM testing pending: Installation verification, MCP server functionality, bidirectional sync verification
  - ⚠️ GitHub Personal Access Token configuration required (post-install manual step)
**Story 02.3-001**: Brave Browser - ✅ Installation and documentation implemented
  - ✅ Homebrew cask added to darwin/homebrew.nix (brave-browser)
  - ✅ Comprehensive documentation added to app-post-install-configuration.md
  - ✅ Auto-update disable instructions documented
  - ✅ Brave Shields configuration and verification steps documented
  - ✅ Privacy features, default browser setup, and troubleshooting documented
  - ⚠️ VM testing pending: Installation verification, auto-update disable, Shields functionality
**Story 02.3-002**: Arc Browser - ✅ Installation and documentation implemented
  - ✅ Homebrew cask added to darwin/homebrew.nix (arc)
  - ✅ Comprehensive documentation added to app-post-install-configuration.md
  - ✅ Update management documented (Homebrew-controlled, no in-app setting)
  - ✅ Arc Spaces (workspaces) feature documentation
  - ✅ Command Palette, Split View, Boosts, and unique features documented
  - ✅ Account requirement, sync, privacy features, and troubleshooting documented
  - ⚠️ VM testing pending: Installation verification, Spaces functionality, account sign-in
**Story 02.4-001**: Raycast - ✅ Installation and documentation implemented
  - ✅ Homebrew cask added to darwin/homebrew.nix (raycast)
  - ✅ Comprehensive documentation added to app-post-install-configuration.md
  - ✅ Hotkey configuration documented (Option+Space recommended, Cmd+Space alternative)
  - ✅ Auto-update disable instructions documented (Preferences → Advanced → Uncheck "Automatically download and install updates")
  - ✅ Core features documented: Application launcher, file search, clipboard history, window management, snippets, extensions, calculator, system commands
  - ✅ Configuration tips and usage examples provided
  - ✅ No license required (free for personal use, optional Raycast Pro)
  - ⚠️ VM testing pending: Installation verification, hotkey setup, auto-update disable, feature testing
**Story 02.4-002**: 1Password - ✅ Installation and documentation implemented
  - ✅ Homebrew cask added to darwin/homebrew.nix (1password)
  - ✅ Comprehensive documentation added to app-post-install-configuration.md (300+ lines)
  - ✅ Account sign-in process documented (existing account vs new account creation)
  - ✅ Auto-update disable instructions documented (Settings → Advanced → Uncheck "Check for updates automatically")
  - ✅ Browser extension setup documented (Safari, Brave, Arc, Firefox)
  - ✅ Core features documented: Password management, secure notes, credit cards, identities, documents, SSH keys, Watchtower security auditing, shared vaults
  - ✅ Configuration tips: Tags, favorites, security settings, browser integration, Watchtower monitoring, 2FA
  - ✅ License requirements documented: Subscription-based ($2.99/month Individual, $4.99/month Families)
  - ✅ Troubleshooting guide included (browser extension, Master Password recovery, Touch ID, autofill issues)
  - ⚠️ VM testing pending: Installation verification, account sign-in, auto-update disable, browser extension setup
**Story 02.4-003**: File Utilities (Calibre, Kindle, Keka, Marked 2) - ✅ Installation and documentation implemented
  - ✅ Homebrew casks added to darwin/homebrew.nix: calibre, keka
  - ✅ Mac App Store apps added to darwin/homebrew.nix masApps: Kindle (302584613), Marked 2 (890031187)
  - ✅ Comprehensive documentation added to app-post-install-configuration.md (640+ lines total)
  - ✅ Calibre documentation: Auto-update disable (Preferences → Miscellaneous), library management, format conversion, ebook reading, device sync, metadata editing
  - ✅ Kindle documentation: Amazon account sign-in, Whispersync, X-Ray features, notes/highlights, library management, supported formats
  - ✅ Keka documentation: File association setup (two methods), archive creation/extraction, password protection, compression control, format support
  - ✅ Marked 2 documentation: Auto-update disable (Preferences → General), live Markdown preview, export to PDF/HTML/RTF/DOCX, custom CSS, statistics, GFM/MMD support
  - ✅ License requirements documented: Calibre (free/open source), Kindle (free with Amazon account), Keka (free/open source), Marked 2 (paid $14.99 Mac App Store)
  - ✅ Table of contents updated with all four apps
  - ⚠️ VM testing pending: All four apps installation, auto-update disable (Calibre, Marked 2), file association setup (Keka), Amazon sign-in (Kindle)
**Story 02.4-005**: System Utilities (Onyx, f.lux) - ✅ Installation and documentation implemented
  - ✅ Homebrew casks added to darwin/homebrew.nix: onyx, flux-app
  - ✅ Comprehensive documentation added to app-post-install-configuration.md (430+ lines total)
  - ✅ Onyx documentation: EULA and disk verification on first launch, 6 tabs (Verification, Maintenance, Cleaning, Utilities, Automation, Info), admin password requirements, system maintenance tasks, cache clearing, hidden settings access
  - ✅ f.lux documentation: Location setup (auto-detect or manual), color temperature adjustment (2700K-4200K), automatic sunrise/sunset tracking, manual override modes, movie mode, darkroom mode, custom schedules, Location Services and Accessibility permissions
  - ✅ Permission notes documented: Onyx requires admin password for system tasks (expected and safe), f.lux may request Location Services and Accessibility (optional but recommended)
  - ✅ Auto-update configuration: No auto-update mechanism requiring disable (both free utilities, Homebrew-controlled)
  - ✅ Testing checklists provided: 13 items for Onyx, 13 items for f.lux
  - ⚠️ VM testing pending: Installation verification, first-run setup, permission requests, core functionality testing

---
