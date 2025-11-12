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
  - [VSCode](#vscode)
  - [Ghostty Terminal](#ghostty-terminal)
  - [Python and Development Tools](#python-and-development-tools)

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

---
