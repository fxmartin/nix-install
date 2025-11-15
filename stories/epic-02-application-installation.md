# Epic 02: Application Installation

## Epic Overview
**Epic ID**: Epic-02
**Epic Description**: Comprehensive installation and configuration of all applications across both Standard and Power profiles using Nix, Homebrew Casks, and Mac App Store (mas). Implements profile-based differentiation (Parallels and Ollama models for Power only), ensures all GUI apps are properly themed, and disables auto-updates to enforce controlled update philosophy where only `rebuild` and `update` commands manage app versions.
**Business Value**: Provides complete application ecosystem for development, productivity, and communication workflows with zero manual installation
**User Impact**: FX gets all required tools installed automatically, correctly themed, and ready to use within the bootstrap process
**Success Metrics**:
- All 47+ apps installed successfully on Standard profile
- All 51+ apps installed successfully on Power profile (includes Parallels and extra Ollama models)
- 100% of apps launch without errors
- Auto-updates disabled for all apps that support it
- Licensed apps documented with clear activation instructions
- Email accounts (1 Gmail, 4 Gandi.net) configured and functional in macOS Mail.app

## Epic Scope
**Total Stories**: 26
**Total Story Points**: 126
**Completed Stories**: 7 (26.9%)
**Completed Points**: 36 (28.6%)
**MVP Stories**: 26 (100% of epic)
**Priority Level**: Must Have
**Target Release**: Phase 2-3 (Week 2-3)

## Features in This Epic

### Feature 02.1: AI & LLM Tools Installation
**Feature Description**: Install and configure AI/LLM applications and models
**User Value**: Enables AI-assisted development and research workflows
**Story Count**: 4
**Story Points**: 21
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 02.1-001: Claude Desktop and AI Chat Apps
**User Story**: As FX, I want Claude Desktop, ChatGPT Desktop, and Perplexity installed so that I can use multiple AI assistants for different tasks

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I check installed applications
- **Then** Claude Desktop is installed and launches
- **And** ChatGPT Desktop is installed and launches
- **And** Perplexity is installed and launches
- **And** all apps are accessible from Spotlight/Raycast
- **And** auto-update is disabled in each app's preferences where supported

**Additional Requirements**:
- Installation via Homebrew Casks
- Apps in /Applications directory
- First launch configuration prompts expected (sign-in required)
- Auto-update disable: Check app preferences, document if not configurable

**Technical Notes**:
- Homebrew cask names: `claude`, `chatgpt`
- Perplexity: Mac App Store only (App ID: 6714467650) - no Homebrew cask available
- Add to darwin/homebrew.nix: casks list (Claude, ChatGPT) + masApps (Perplexity)
- **CRITICAL**: `mas` CLI tool must be in brews list (Issue #25: mas not found on fresh Mac)
- **Fresh Machine Requirement** (Issue #26): Perplexity must be installed manually via App Store GUI first
  - Fresh macOS requires first Mac App Store install to be manual (initializes services)
  - After one manual install, `mas` CLI works normally for subsequent installs
  - Error without manual install: `PKInstallErrorDomain Code=201` - installation service cannot start
  - Workaround: Open App Store → Search "Perplexity" → Click cloud icon → Install → Then run bootstrap
- Auto-update: May require manual disable in app settings (document in post-install)
- Test: Verify apps launch and show sign-in screens
- **Hotfix #14 (Issue #24)**: Perplexity changed from Homebrew cask to Mac App Store installation
- **Hotfix #15 (Issue #25)**: Added `mas` to brews list (required for masApps installations)

**Definition of Done**:
- [x] Code implemented in homebrew.nix
- [x] `mas` CLI tool added to brews (Hotfix #15, Issue #25)
- [x] All three apps install successfully (VM testing by FX - 2025-11-12)
- [x] Apps launch without errors (VM testing by FX - 2025-11-12)
- [x] Auto-update preferences documented (docs/app-post-install-configuration.md)
- [x] Tested in VM with both profiles (VM testing by FX - 2025-11-12)
- [x] Documentation notes first-run sign-in required
- [x] Fresh machine manual install requirement documented (Issue #26)

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-11
**Branch**: feature/02.1-001-ai-chat-apps
**Files Changed**:
- darwin/homebrew.nix: Added `claude`, `chatgpt` casks + `Perplexity` masApp
- docs/app-post-install-configuration.md: Created post-install configuration guide

**Hotfixes**:
- **Hotfix #14 (Issue #24, 2025-11-11)**: Perplexity moved to Mac App Store
  - Removed `perplexity` from casks (does not exist in Homebrew)
  - Added `Perplexity` to masApps with App Store ID 6714467650
  - Updated documentation to reflect App Store installation
  - Branch: hotfix/issue-24-perplexity-mas

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.1-002: Ollama Desktop App Installation
**User Story**: As FX, I want Ollama Desktop App installed via Homebrew so that I can run local LLM models with a GUI and CLI interface

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Ollama Desktop App
- **Then** it opens and shows the menubar icon
- **And** I can run `ollama --version` in terminal
- **And** the Ollama daemon runs automatically in background
- **And** I can test with `ollama run llama2` (downloads small test model)
- **And** Ollama data stored in ~/Library/Application Support/Ollama
- **And** GUI shows installed models and settings
- **And** auto-update is disabled (check app preferences)

**Additional Requirements**:
- Installation via Homebrew Cask (Desktop App)
- GUI with menubar icon and model management
- Includes CLI tools (ollama command available)
- Background daemon runs automatically
- Models stored persistently
- Auto-update disable documented

**Technical Notes**:
- Homebrew cask: `ollama-app` (renamed from `ollama` as of 2025-11-12)
- Add to darwin/homebrew.nix casks list (NOT brews)
- Desktop app includes CLI tools bundled
- Daemon management: Automatic via desktop app
- Model storage: ~/Library/Application Support/Ollama
- Test command: `ollama pull llama2 && ollama run llama2 "test"`
- Auto-update: Check app preferences after first launch

**Definition of Done**:
- [x] Ollama Desktop App added to homebrew.nix casks
- [x] Desktop app launches successfully with menubar icon (VM testing by FX - 2025-11-12)
- [x] `ollama --version` works in terminal (VM testing by FX - 2025-11-12)
- [x] Can pull and run a test model (VM testing by FX - 2025-11-12)
- [x] Daemon runs automatically (VM testing by FX - 2025-11-12)
- [x] GUI shows model management interface (VM testing by FX - 2025-11-12)
- [x] Auto-update disable steps documented (docs/app-post-install-configuration.md)
- [x] Tested in VM (VM testing by FX - 2025-11-12)
- [x] Documentation notes model storage location

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-11 (Updated: 2025-11-12 - cask renamed to ollama-app)
**Branch**: feature/02.1-001-ai-chat-apps (combined with 02.1-001)
**Files Changed**:
- darwin/homebrew.nix: Added `ollama-app` cask (renamed from `ollama`)
- docs/app-post-install-configuration.md: Added Ollama Desktop section
- stories/epic-02-application-installation.md: Updated story from CLI to Desktop App

**Implementation Notes - Issue #25** (Fresh Mac Requirement):
- **Fresh Mac Limitation**: On brand new Macs, Ollama requires manual first launch before daemon/CLI works
- **Root Cause**: macOS Gatekeeper approval required for first GUI app launch
- **Workaround**: Launch Ollama Desktop → Approve Gatekeeper → Re-run darwin-rebuild
- **Documented**: docs/app-post-install-configuration.md (comprehensive fresh Mac section)
- **Similar Issue**: Issue #26 (Perplexity Mac App Store requirement)

**Future Enhancement** (Post-MVP):
- Consider home-manager `services.ollama` with darwin launchd support (merged Jan 24, 2025)
- Would provide declarative daemon management via launchd
- Still requires manual first launch for Gatekeeper, but cleaner service management
- See Issue #25 comment for full implementation details

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed by nix-darwin)

**Risk Level**: Low → Medium (fresh Mac Gatekeeper approval required)
**Risk Mitigation**: Documented manual first-run requirement in post-install guide

---

##### Story 02.1-003: Standard Profile Ollama Model
**User Story**: As FX, I want the `gpt-oss:20b` Ollama model automatically pulled on Standard profile so that I have a capable local LLM without excessive disk usage

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** Standard profile is selected during bootstrap
- **When** nix-darwin activation completes
- **Then** `ollama list` shows `gpt-oss:20b` model
- **And** the model is fully downloaded (~12GB)
- **And** I can run `ollama run gpt-oss:20b "Hello"` successfully
- **And** model download happens during first rebuild only (idempotent)

**Additional Requirements**:
- Model: `gpt-oss:20b` (good balance of capability and size)
- Size: ~12GB
- Pull during system activation (not user interaction)
- Only on Standard profile

**Technical Notes**:
- Use system.activationScripts in darwin configuration
- Check if model exists before pulling (idempotent):
  ```nix
  system.activationScripts.pullOllamaModel.text = ''
    if ! /opt/homebrew/bin/ollama list | grep -q "gpt-oss:20b"; then
      echo "Pulling Ollama model: gpt-oss:20b..."
      /opt/homebrew/bin/ollama pull gpt-oss:20b
    fi
  '';
  ```
- Profile-specific: Only in darwinConfigurations.standard

**Definition of Done**:
- [x] Activation script implemented for Standard profile
- [x] Model pulls during first rebuild (VM testing by FX - 2025-11-12)
- [x] Script is idempotent (doesn't re-pull)
- [x] `ollama list` shows model after rebuild (VM testing by FX - 2025-11-12)
- [x] Model runs successfully (VM testing by FX - 2025-11-12)
- [x] Tested in VM with Standard profile (VM testing by FX - 2025-11-12)

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-11
**Branch**: feature/02.1-001-ai-chat-apps (combined with 02.1-001 and 02.1-002)
**Files Changed**:
- flake.nix: Added system.activationScripts.pullOllamaModel to Standard profile

**Implementation Details**:
- Activation script checks for Ollama CLI availability
- Idempotent: Checks if model exists before pulling
- Graceful failure handling with clear warning messages
- Network-aware: Handles failures and provides manual fallback
- Standard profile only: NOT in Power profile (Power gets 4 models in Story 02.1-004)

**Dependencies**:
- Story 02.1-002 (Ollama installed)
- Issue #25 workaround: Manual Ollama Desktop first launch required on fresh Macs

**Risk Level**: Medium
**Risk Mitigation**:
- Check Ollama daemon is running before pulling
- Handle network failures gracefully
- Fresh Mac: Documented manual first-launch requirement (see docs/app-post-install-configuration.md)

---

##### Story 02.1-004: Power Profile Additional Ollama Models
**User Story**: As FX, I want `qwen2.5-coder:32b`, `llama3.1:70b`, and `deepseek-r1:32b` models pulled on Power profile so that I have multiple specialized LLMs for different tasks

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** Power profile is selected during bootstrap
- **When** nix-darwin activation completes
- **Then** `ollama list` shows all 4 models: `gpt-oss:20b`, `qwen2.5-coder:32b`, `llama3.1:70b`, `deepseek-r1:32b`
- **And** all models are fully downloaded (~80GB total)
- **And** I can run each model with `ollama run <model-name> "test"`
- **And** model downloads happen during first rebuild only (idempotent)
- **And** progress indicators show for each model download

**Additional Requirements**:
- Models: `gpt-oss:20b` (12GB), `qwen2.5-coder:32b` (20GB), `llama3.1:70b` (40GB), `deepseek-r1:32b` (18GB)
- Total size: ~90GB
- Pull sequentially with status updates
- Only on Power profile (MacBook Pro M3 Max with 1TB storage)

**Technical Notes**:
- Extend activation script for Power profile:
  ```nix
  system.activationScripts.pullOllamaModels.text = ''
    MODELS=("gpt-oss:20b" "qwen2.5-coder:32b" "llama3.1:70b" "deepseek-r1:32b")
    for model in "''${MODELS[@]}"; do
      if ! /opt/homebrew/bin/ollama list | grep -q "$model"; then
        echo "Pulling Ollama model: $model..."
        /opt/homebrew/bin/ollama pull "$model"
      fi
    done
  '';
  ```
- Profile-specific: Only in darwinConfigurations.power
- Duration: 15-30 minutes depending on network speed

**Definition of Done**:
- [x] Activation script implemented for Power profile
- [x] All 4 models pull during first rebuild (VM testing by FX - 2025-11-12)
- [x] Script is idempotent
- [x] `ollama list` shows all models (VM testing by FX - 2025-11-12)
- [x] Each model runs successfully (VM testing by FX - 2025-11-12)
- [x] Tested in VM with Power profile (VM testing by FX - 2025-11-12)
- [x] Documentation notes expected download time

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-11
**Branch**: feature/02.1-001-ai-chat-apps (combined with 02.1-001, 02.1-002, 02.1-003)
**Files Changed**:
- flake.nix: Added system.activationScripts.pullOllamaModels to Power profile

**Implementation Details**:
- Activation script checks for Ollama CLI availability
- Sequential model pull with progress tracking for each model
- Idempotent: Checks if each model exists before pulling
- Graceful failure handling with clear warning messages per model
- Network-aware: Handles failures and provides manual fallback for each model
- Power profile only: 4 models (Standard has only 1 model from Story 02.1-003)
- Models: gpt-oss:20b (12GB), qwen2.5-coder:32b (20GB), llama3.1:70b (40GB), deepseek-r1:32b (18GB)
- Total download: ~90GB (15-30 minutes depending on network)

**Dependencies**:
- Story 02.1-002 (Ollama installed)
- Story 02.1-003 (Standard model pull pattern established)
- Issue #25 workaround: Manual Ollama Desktop first launch required on fresh Macs

**Risk Level**: Medium
**Risk Mitigation**:
- Handle network interruptions, allow retry
- Document storage requirements (~90GB for Power profile)
- Fresh Mac: Documented manual first-launch requirement (see docs/app-post-install-configuration.md)

---

### Feature 02.2: Development Environment Applications
**Feature Description**: Install development editors, terminals, AI tooling (Claude Code CLI + MCP servers), and container tools
**User Value**: Complete development workflow support for Python, AI-assisted development with enhanced context, and containerized applications
**Story Count**: 6
**Story Points**: 32
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 02.2-001: Zed Editor Installation and Configuration
**User Story**: As FX, I want Zed editor installed and configured via Home Manager so that I have a fast, modern code editor with Catppuccin theming

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Zed
- **Then** it opens with Catppuccin theme (Latte for light, Mocha for dark)
- **And** it uses JetBrains Mono Nerd Font with ligatures
- **And** theme switches automatically with macOS system appearance
- **And** auto-update is disabled in Zed settings
- **And** Zed configuration is managed by Home Manager

**Additional Requirements**:
- Installation via Homebrew Cask
- Theming via Stylix integration
- Auto-update disabled: `"auto_update": false` in settings.json
- Configuration managed declaratively
- **REQ-NFR-008**: Settings file MUST use repository symlink pattern (not /nix/store)

**Technical Notes**:
- Homebrew cask: `zed`
- Stylix should automatically theme Zed if supported
- **REQ-NFR-008 Implementation**:
  - ❌ Do NOT use `programs.zed.settings = {...}` (creates read-only /nix/store symlink)
  - ✅ Use `home.activation` script to create symlink to repository:
    ```nix
    home.activation.zedConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ln -sf "$REPO_ROOT/config/zed/settings.json" "$HOME/.config/zed/settings.json"
    '';
    ```
  - Pattern: `~/.config/zed/settings.json` → `$REPO/config/zed/settings.json`
  - Enables bidirectional sync: changes in Zed appear in repo, git pull updates Zed
  - Reference implementation: `home-manager/modules/zed.nix`
- Verify theme switching with system appearance

**Definition of Done**:
- [x] Zed installed via homebrew.nix
- [x] Zed configuration in home-manager module (bidirectional sync via activation script)
- [x] Catppuccin theme applied (VM testing by FX - 2025-11-12)
- [x] JetBrains Mono font active (VM testing by FX - 2025-11-12)
- [x] Auto-update disabled (VM testing by FX - 2025-11-12)
- [x] Theme switches with system appearance (VM testing by FX - 2025-11-12)
- [x] Tested in VM (VM testing by FX - 2025-11-12)

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-11
**Branch**: feature/02.2-001-zed-editor
**Files Changed**:
- darwin/homebrew.nix: Added `zed` cask
- home-manager/modules/zed.nix: Created Zed configuration module with bidirectional sync
- home-manager/home.nix: Imported zed module
- config/zed/settings.json: Created template settings with Catppuccin theme
- config/README.md: Documented Zed settings sync approach
- docs/app-post-install-configuration.md: Added Zed configuration section

**Implementation Notes**:
- **REQ-NFR-008 Compliance**: ✅ Fully implements repository symlink pattern
- **Issue #26**: Resolved /nix/store write access issue with bidirectional sync
- **Hotfix #14**: Made repo path dynamic for custom NIX_INSTALL_DIR support
- **Activation Script**: Searches common locations, validates with flake.nix + config/zed/
- **Symlink**: ~/.config/zed/settings.json → $REPO_ROOT/config/zed/settings.json
- **Bidirectional**: Changes in Zed instantly appear in repo, pull updates apply to Zed
- **Theme**: Catppuccin Mocha (dark) and Latte (light) via system appearance
- **Font**: JetBrains Mono with ligatures enabled
- **Auto-update**: Disabled via "auto_update": false in settings.json
- **Reference**: This implementation serves as the pattern for all apps requiring config file management

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin + Home Manager)
- Epic-05, Story 05.1-001 (Stylix theming configured)

**Risk Level**: Low
**Risk Mitigation**: Manual theme configuration if Stylix doesn't support Zed

---

##### Story 02.2-002: VSCode Installation
**User Story**: As FX, I want VSCode installed so that I can use Claude Code extension and other VSCode-specific tools

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch VSCode
- **Then** it opens successfully
- **And** auto-update is disabled (`"update.mode": "none"` in settings)
- **And** I can install extensions manually
- **And** theme is Catppuccin (via Stylix if possible, otherwise manual)

**Additional Requirements**:
- Installation via Homebrew Cask
- Auto-update disabled globally
- Claude Code extension installation documented (manual step)
- Optional: Stylix theming if supported
- **REQ-NFR-008**: Settings file MUST use repository symlink pattern (not /nix/store)

**Technical Notes**:
- Homebrew cask: `visual-studio-code`
- **REQ-NFR-008 Implementation**:
  - ❌ **ANTI-PATTERN**: Do NOT use `programs.vscode.userSettings = {...}`
  - ❌ **Reason**: Creates read-only symlink to /nix/store, breaks VSCode write access
  - ✅ **CORRECT**: Use `home.activation` script to create repository symlink:
    ```nix
    home.activation.vscodeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Dynamically find repo location (same pattern as Zed)
      REPO_ROOT=$(find_repo_root)  # Search ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install
      mkdir -p "$HOME/Library/Application Support/Code/User"
      ln -sf "$REPO_ROOT/config/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
    '';
    ```
  - Pattern: `~/Library/Application Support/Code/User/settings.json` → `$REPO/config/vscode/settings.json`
  - Enables bidirectional sync: changes in VSCode appear in repo, git pull updates VSCode
  - Reference: `home-manager/modules/zed.nix` for complete implementation pattern
- Settings to include in config/vscode/settings.json:
  - `"update.mode": "none"` (disable auto-update)
  - `"workbench.colorTheme": "Catppuccin Mocha"` (theme)
- Document Claude Code extension install: Extensions → Search "Claude Code" → Install

**Definition of Done**:
- [x] VSCode installed via homebrew.nix
- [x] Settings symlinked to repository (REQ-NFR-008 compliant)
- [x] Auto-update disabled in settings
- [x] VSCode launches successfully (VM testing by FX - 2025-11-12)
- [x] Extension installation documented
- [x] Tested in VM (VM testing by FX - 2025-11-12)
- [x] Theme configured (automated Catppuccin + Auto Dark Mode extensions)
- [x] Bidirectional sync verified (VM testing by FX - 2025-11-12)
- [x] Auto theme switching works (Light → Latte, Dark → Mocha) (VM testing by FX - 2025-11-12)

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-12
**Branch**: feature/02.2-002-vscode (ready to merge to main)
**Files Changed**:
- darwin/homebrew.nix: Added `visual-studio-code` cask
- config/vscode/settings.json: Created comprehensive settings (3.5 KB) with auto-update disabled and Catppuccin theme
- home-manager/modules/vscode.nix: Created Home Manager module (4.8 KB) with REQ-NFR-008 compliant activation script
- home-manager/home.nix: Imported vscode module
- docs/app-post-install-configuration.md: Added VSCode section (180+ lines) with extension installation guide

**Implementation Details**:
- REQ-NFR-008 compliant: Bidirectional symlink to repository (NOT /nix/store)
- Settings location: `~/Library/Application Support/Code/User/settings.json` → `$REPO/config/vscode/settings.json`
- Auto-update disabled: `update.mode: "none"`, `extensions.autoUpdate: false`, `extensions.autoCheckUpdates: false`
- Theme: Catppuccin with auto-switching (Issue #28 resolution):
  - Extension 1: Catppuccin Theme (provides Mocha/Latte themes) - **AUTOMATICALLY INSTALLED**
  - Extension 2: Auto Dark Mode (monitors macOS appearance, switches themes automatically) - **AUTOMATICALLY INSTALLED**
  - Extensions auto-install via Home Manager activation script using VSCode CLI
  - Installation is idempotent (checks if already installed, skips if present)
  - Light Mode → Catppuccin Latte, Dark Mode → Catppuccin Mocha
  - Matches Zed editor behavior (system appearance sync)
  - Zero manual intervention (extensions installed during darwin-rebuild)
  - Required setting: `window.autoDetectColorScheme: true` (enables Auto Dark Mode extension)
- Font: JetBrains Mono with ligatures (matches Ghostty and Zed)
- Language-specific settings: Nix (2-space indent), Python (4-space indent, Ruff formatter), Markdown, JSON, YAML
- Privacy: Telemetry disabled, crash reporter disabled
- Git integration: Decorations, inline changes, autofetch disabled
- Terminal integration: Integrated terminal uses Zsh

**Issues Resolved**:
- **Issue #28**: VSCode theme auto-switching - Implemented Auto Dark Mode extension with window.autoDetectColorScheme setting
- **Issue #29**: VSCode CLI PATH issue - Multi-location CLI detection (/opt/homebrew/bin, /usr/local/bin, app bundle path)
- **Issue #30**: Duplicate of #28 (closed as duplicate)

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.2-003: Ghostty Terminal Installation
**User Story**: As FX, I want Ghostty terminal installed with my existing config from `config/ghostty/config` so that I have a fast GPU-accelerated terminal with Catppuccin theming

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Ghostty
- **Then** it opens with configuration from `config/ghostty/config`
- **And** Catppuccin theme is applied (Latte/Mocha auto-switch)
- **And** JetBrains Mono font with ligatures is active
- **And** 95% opacity with blur effect works
- **And** all keybindings from config are functional
- **And** auto-update is disabled (`auto-update = off` in config)

**Additional Requirements**:
- Installation via Homebrew Cask
- Configuration via Home Manager activation script (see Story 04.4-001)
- Theme consistency with Zed (same Catppuccin variant)
- Config location: ~/.config/ghostty/config
- **REQ-NFR-008**: Config MUST use repository symlink (see Story 04.4-001 for implementation)

**Technical Notes**:
- Homebrew cask: `ghostty`
- **Configuration implemented in Story 02.2-003** (This story)
- **REQ-NFR-008 Note**:
  - ❌ Do NOT use `xdg.configFile."ghostty/config".source = ...` (creates /nix/store symlink)
  - ✅ Use activation script pattern (same as Zed and VSCode)
  - Pattern: `~/.config/ghostty/config` → `$REPO/config/ghostty/config`
- Existing config already has Catppuccin theme and auto-update=off
- Verify: `ls -la ~/.config/ghostty/config` should show symlink to repository (not /nix/store)

**Definition of Done**:
- [x] Ghostty installed via homebrew.nix (already installed since Phase 5)
- [x] Home Manager module created for config symlink (home-manager/modules/ghostty.nix)
- [x] Module imported in home.nix
- [x] Documentation added to app-post-install-configuration.md
- [x] Ghostty launches with correct theme (VM tested by FX - 2025-11-12)
- [x] Font and ligatures working (VM tested by FX - 2025-11-12)
- [x] Opacity and blur effects active (VM tested by FX - 2025-11-12)
- [x] Keybindings functional (VM tested by FX - 2025-11-12)
- [x] Config symlink verified (VM tested by FX - 2025-11-12)
- [x] Tested in VM (VM tested by FX - 2025-11-12)

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-12
**VM Testing Date**: 2025-11-12
**Branch**: feature/02.2-003-ghostty (merged to main)

**Files Changed**:
- home-manager/modules/ghostty.nix: Created Home Manager module (117 lines) with REQ-NFR-008 compliant activation script
- home-manager/home.nix: Added ghostty module import
- docs/app-post-install-configuration.md: Added comprehensive Ghostty section (180+ lines)

**Implementation Details**:
- REQ-NFR-008 compliant: Bidirectional symlink to repository (NOT /nix/store)
- Config location: `~/.config/ghostty/config` → `$REPO/config/ghostty/config`
- Activation script pattern (same as Zed and VSCode):
  - Dynamically finds repo location (~/nix-install, ~/.config/nix-install, ~/Documents/nix-install)
  - Creates symlink on darwin-rebuild
  - Backs up existing config if found
  - Updates symlink target if changed
- Auto-update disabled: `auto-update = off` in config/config.ghostty
- Theme: Catppuccin with auto-switching (Latte for light mode, Mocha for dark mode)
- Font: JetBrains Mono with ligatures (consistent with Zed and VSCode)
- Configuration features:
  - Background opacity 95% with blur effect
  - Window padding 16px
  - Shell integration enabled
  - Comprehensive productivity keybindings
  - Clipboard security settings

**VM Testing Instructions** (for FX):
1. Run `darwin-rebuild switch` in VM
2. Verify symlink created: `ls -la ~/.config/ghostty/config`
3. Launch Ghostty and verify:
   - Theme is Catppuccin (Mocha for dark mode)
   - Font is JetBrains Mono with ligatures working
   - Background opacity and blur effect active
   - Window padding visible
   - Config reload works (Ctrl+Shift+,)
4. Test theme auto-switching:
   - Toggle macOS appearance (System Settings → Appearance)
   - Verify Ghostty switches between Latte (light) and Mocha (dark)
5. Test bidirectional sync:
   - Edit config/ghostty/config in repo
   - Reload config in Ghostty (Ctrl+Shift+,)
   - Verify changes apply

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew + Home Manager)
- Epic-05, Story 05.1-001 (Stylix provides consistent theme) - Optional dependency

**Risk Level**: Low
**Risk Mitigation**: Existing config.ghostty is proven to work, same pattern as Zed and VSCode

---

##### Story 02.2-004: Python and Development Tools
**User Story**: As FX, I want Python 3.12, uv, and essential Python dev tools installed via Nix so that I have a complete Python development environment

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `python --version`
- **Then** it shows Python 3.12.x
- **And** `uv --version` works
- **And** `ruff --version`, `black --version`, `isort --version`, `mypy --version`, `pylint --version` all work
- **And** all tools are in PATH globally
- **And** I can create a new Python project with `uv init test-project`

**Additional Requirements**:
- Python 3.12 via Nix (not Homebrew)
- uv for package management
- Global dev tools: ruff, black, isort, mypy, pylint
- All managed via nixpkgs

**Technical Notes**:
- Add to darwin/configuration.nix:
  ```nix
  environment.systemPackages = with pkgs; [
    python312
    uv
    ruff
    black
    python312Packages.isort
    python312Packages.mypy
    python312Packages.pylint
  ];
  ```
- Verify: `which python` shows /nix/store path
- Test: Create project with `uv init`, verify tools work

**Definition of Done**:
- [x] Python 3.12 installed via Nix
- [x] uv installed and functional
- [x] All dev tools installed and in PATH
- [x] Can create and manage Python projects
- [x] Tested in VM ✅ VM tested by FX - 2025-11-12
- [x] Documentation notes uv usage

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-12
**VM Testing Date**: 2025-11-12
**Branch**: feature/02.2-004-python-dev-tools (merged to main)
**Files Changed**:
- darwin/configuration.nix: Added Python 3.12 and development tools to systemPackages
- docs/app-post-install-configuration.md: Added comprehensive Python section (150+ lines)

**Implementation Details**:
- Python 3.12 via Nix (python312 package)
- uv package manager (fast pip replacement)
- Development tools: ruff, black, python312Packages.isort, python312Packages.mypy, python312Packages.pylint
- All tools globally accessible in PATH
- No configuration required (works out of the box)
- Documentation includes verification steps, usage examples, editor integration

**VM Testing Instructions** (for FX):
1. Run `darwin-rebuild switch` in VM
2. Verify Python version: `python --version` (should show 3.12.x)
3. Verify Python path: `which python` (should show /nix/store/...)
4. Test tools:
   ```bash
   uv --version
   ruff --version
   black --version
   isort --version
   mypy --version
   pylint --version
   ```
5. Create test project:
   ```bash
   uv init test-project
   cd test-project
   uv add requests
   echo 'import requests; print(requests.__version__)' > test.py
   uv run python test.py
   ```
6. Verify all commands work without errors

**Dependencies**:
- Epic-01, Story 01.4-001 (Nix installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.2-005: Podman and Container Tools
**User Story**: As FX, I want Podman, podman-compose, and Podman Desktop installed so that I can run containers without Docker

**Priority**: Must Have
**Story Points**: 6
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `podman --version`
- **Then** it shows Podman version
- **And** `podman-compose --version` works
- **And** Podman Desktop app is installed and launches
- **And** I can run `podman run hello-world` successfully
- **And** Podman machine is initialized and running
- **And** The Desktop App is also installed

**Additional Requirements**:
- Podman CLI via Nix
- podman-compose via Nix
- Podman Desktop via Nix
- Machine initialization automated or documented

**Technical Notes**:
- **Important**: All Podman tools installed via Homebrew (not Nix) for GUI integration
- Podman Desktop (GUI app) requires podman CLI in standard PATH
- GUI applications on macOS don't inherit shell PATH, so Nix packages may not be found
- Add to darwin/homebrew.nix:
  ```nix
  homebrew.brews = [
    "podman"          # Podman CLI
    "podman-compose"  # Docker Compose compatibility
  ];
  homebrew.casks = [
    "podman-desktop"  # Podman Desktop GUI
  ];
  ```
- Initialize Podman machine: `podman machine init && podman machine start`
- Machine initialization documented in post-install guide

**Definition of Done**:
- [x] Podman CLI installed via Nix
- [x] podman-compose installed
- [x] Podman Desktop installed via Homebrew
- [x] Can run containers successfully (pending VM test)
- [x] Machine initialization documented
- [ ] Tested in VM (pending FX validation)
- [x] Documentation includes setup steps

**Implementation Status**: ✅ **CODE COMPLETE** - Pending VM testing by FX
**Implementation Date**: 2025-11-15
**Branch**: feature/02.2-005-podman
**Files Changed**:
- darwin/homebrew.nix: Added podman, podman-compose brews + podman-desktop cask
- docs/app-post-install-configuration.md: Added comprehensive Podman section (240+ lines)

**Implementation Details**:
- Podman CLI via Homebrew brew (podman)
- podman-compose via Homebrew brew (podman-compose)
- Podman Desktop via Homebrew cask (podman-desktop)
- **Rationale for Homebrew**: GUI integration - Podman Desktop needs podman CLI in standard PATH
- Comprehensive documentation covering:
  - Machine initialization requirements (one-time setup)
  - Verification commands
  - Basic usage examples (run, compose, build)
  - Docker compatibility (aliases, drop-in replacement)
  - Troubleshooting guide
  - Resource management tips
- No Home Manager module needed (system-level packages only)

**VM Testing Instructions** (for FX):
1. Run `darwin-rebuild switch` in VM
2. Verify installations:
   ```bash
   podman --version
   podman-compose --version
   open -a "Podman Desktop"
   ```
3. Initialize Podman machine (with Docker compatibility):
   ```bash
   # Initialize and start in one command
   podman machine init --now --rootful=false

   # Verify machine is running
   podman machine list
   # Expected: Shows "Currently running"
   ```
4. Test container execution:
   ```bash
   podman run --rm hello-world
   podman run --rm -it alpine:latest echo "Podman works!"
   ```
5. Test Podman Desktop:
   - Launch app from Applications
   - Verify machine status shown
   - Check containers/images management UI
6. Test podman-compose:
   ```bash
   echo 'version: "3"
   services:
     web:
       image: nginx:latest
       ports:
         - "8080:80"' > docker-compose.yml
   podman-compose up -d
   curl localhost:8080
   podman-compose down
   ```

**Dependencies**:
- Epic-01, Story 01.4-001 (Nix installed)
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Medium
**Risk Mitigation**: Document machine initialization clearly, provide troubleshooting for common issues

---

##### Story 02.2-006: Claude Code CLI and MCP Servers
**User Story**: As FX, I want Claude Code CLI installed with Context7, GitHub, and Sequential Thinking MCP servers configured so that I can use AI-assisted development with enhanced context awareness, repository integration, and structured reasoning

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `claude --version`
- **Then** it shows Claude Code CLI version
- **And** I can run `claude` to start an interactive session
- **And** MCP servers are configured in `~/.config/claude/config.json`
- **And** Context7 MCP server is available and responds to context queries
- **And** GitHub MCP server is available and can query repositories
- **And** Sequential Thinking MCP server is available for structured reasoning
- **And** I can verify MCP servers with `claude mcp list`
- **And** `~/.claude/CLAUDE.md` is symlinked to repository (REQ-NFR-008)
- **And** `~/.claude/agents/` is symlinked to repository (REQ-NFR-008)
- **And** `~/.claude/commands/` is symlinked to repository (REQ-NFR-008)
- **And** Changes to repository files immediately appear in ~/.claude/ (bidirectional sync)
- **And** Claude Code CLI auto-update is disabled or documented

**Additional Requirements**:
- Claude Code CLI installed via Nix (using sadjow/claude-code-nix)
- MCP servers installed via Nix (using natsukium/mcp-servers-nix)
- Configuration file created at ~/.config/claude/config.json
- MCP servers: Context7, GitHub, Sequential Thinking
- All servers configured with appropriate permissions
- **REQ-NFR-008**: Claude Code configuration MUST use repository symlink pattern (not /nix/store)
  - ~/.claude/CLAUDE.md → $REPO/config/claude/CLAUDE.md
  - ~/.claude/agents/ → $REPO/config/claude/agents/
  - ~/.claude/commands/ → $REPO/config/claude/commands/
- Documentation for MCP server usage and authentication

**Technical Notes**:
- **Claude Code CLI Installation** (via Nix):
  - Use package from https://github.com/sadjow/claude-code-nix/
  - Add as flake input to flake.nix
  - Install via darwin/configuration.nix systemPackages

- **MCP Servers Installation** (via Nix):
  - Use packages from https://github.com/natsukium/mcp-servers-nix/
  - Add as flake input to flake.nix
  - Install via darwin/configuration.nix systemPackages
  - Fully declarative, no npm/npx needed

- **Flake Inputs** (add to flake.nix):
  ```nix
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";

    # Claude Code CLI
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MCP Servers
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  ```

- **System Packages** (darwin/configuration.nix):
  ```nix
  environment.systemPackages = [
    # Claude Code CLI
    inputs.claude-code-nix.packages.${system}.default

    # MCP Servers
    inputs.mcp-servers-nix.packages.${system}.mcp-server-context7
    inputs.mcp-servers-nix.packages.${system}.mcp-server-github
    inputs.mcp-servers-nix.packages.${system}.mcp-server-sequential-thinking

    # ... other packages
  ];
  ```

- **Configuration File** (~/.config/claude/config.json):
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
          "GITHUB_TOKEN": "${GITHUB_TOKEN}"
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
  Note: Command names reference the Nix-installed binaries directly (not npx)

- **Home Manager Module** (home-manager/modules/claude-code.nix):
  ```nix
  { config, lib, pkgs, ... }:

  {
    # Create Claude Code config and symlink repository files
    home.activation.claudeCodeSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Find repository location (same pattern as Zed, VSCode, Ghostty)
      REPO_ROOT=""
      for location in "$HOME/nix-install" "$HOME/.config/nix-install" "$HOME/Documents/nix-install"; do
        if [[ -d "$location" && -f "$location/flake.nix" && -d "$location/config/claude" ]]; then
          REPO_ROOT="$location"
          break
        fi
      done

      if [[ -z "$REPO_ROOT" ]]; then
        echo "⚠ WARNING: Could not find nix-install repository"
        echo "  Searched: ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install"
        echo "  Claude Code configuration will not be linked"
      else
        # Create ~/.claude directory
        mkdir -p "$HOME/.claude"

        # Symlink CLAUDE.md (REQ-NFR-008 compliant)
        if [[ -f "$REPO_ROOT/config/claude/CLAUDE.md" ]]; then
          ln -sf "$REPO_ROOT/config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
          echo "✓ Linked ~/.claude/CLAUDE.md → $REPO_ROOT/config/claude/CLAUDE.md"
        else
          echo "⚠ WARNING: $REPO_ROOT/config/claude/CLAUDE.md not found"
        fi

        # Symlink agents directory
        if [[ -d "$REPO_ROOT/config/claude/agents" ]]; then
          ln -sfn "$REPO_ROOT/config/claude/agents" "$HOME/.claude/agents"
          echo "✓ Linked ~/.claude/agents/ → $REPO_ROOT/config/claude/agents/"
        else
          echo "⚠ WARNING: $REPO_ROOT/config/claude/agents/ directory not found"
        fi

        # Symlink commands directory
        if [[ -d "$REPO_ROOT/config/claude/commands" ]]; then
          ln -sfn "$REPO_ROOT/config/claude/commands" "$HOME/.claude/commands"
          echo "✓ Linked ~/.claude/commands/ → $REPO_ROOT/config/claude/commands/"
        else
          echo "⚠ WARNING: $REPO_ROOT/config/claude/commands/ directory not found"
        fi
      fi

      # Create ~/.config/claude directory for MCP config
      mkdir -p "$HOME/.config/claude"

      # Create config.json with MCP servers (Nix-installed binaries)
      cat > "$HOME/.config/claude/config.json" <<'EOF'
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
              "GITHUB_TOKEN": "REPLACE_WITH_YOUR_GITHUB_TOKEN"
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
      EOF

      echo "✓ Claude Code MCP servers configured at ~/.config/claude/config.json"
      echo "  NOTE: Edit ~/.config/claude/config.json to add:"
      echo "  - GitHub personal access token (GITHUB_TOKEN)"
      echo "  - Get token at: https://github.com/settings/tokens"
      echo "  - Required scopes: repo, read:org, read:user"
    '';
  }
  ```

  **Key Changes**:
  - No Node.js dependency needed (MCP servers are Nix packages)
  - Commands use Nix binary names (`mcp-server-context7`, `mcp-server-github`)
  - No `npx` or npm package installation required
  - MCP servers already in PATH from systemPackages
  - **REQ-NFR-008 Compliance**: Symlinks ~/.claude/ files from repository
    - CLAUDE.md → bidirectional sync (edit in repo or in ~/.claude/)
    - agents/ directory → synced from repo
    - commands/ directory → synced from repo
  - Dynamic repo location detection (same pattern as Zed, VSCode, Ghostty)

- **Authentication Setup**:
  - **GitHub MCP**: Requires GitHub personal access token
    - Create at: https://github.com/settings/tokens
    - Scopes needed: `repo`, `read:org`, `read:user`
    - Store in ~/.config/claude/config.json or environment variable
  - **Context7 MCP**: No authentication required
  - **Sequential Thinking MCP**: No authentication required

- **Post-Install Configuration**:
  - Add to docs/app-post-install-configuration.md
  - Document GitHub token creation and configuration
  - Provide example queries for each MCP server

**Definition of Done**:
- [ ] claude-code-nix flake input added to flake.nix
- [ ] mcp-servers-nix flake input added to flake.nix
- [ ] Claude Code CLI installed via Nix and in PATH
- [ ] `claude --version` command works
- [ ] MCP servers (context7, github, sequential-thinking) installed via Nix and in PATH
- [ ] MCP servers configured in ~/.config/claude/config.json with Nix binary paths
- [ ] Context7 MCP server functional (test with `mcp-server-context7 --version`)
- [ ] GitHub MCP server functional (with token configured)
- [ ] Sequential Thinking MCP server functional (test with `mcp-server-sequential-thinking --version`)
- [ ] **REQ-NFR-008**: Repository symlinks verified:
  - [ ] `~/.claude/CLAUDE.md` → `$REPO/config/claude/CLAUDE.md` (bidirectional)
  - [ ] `~/.claude/agents/` → `$REPO/config/claude/agents/`
  - [ ] `~/.claude/commands/` → `$REPO/config/claude/commands/`
  - [ ] Verify: `ls -la ~/.claude/` shows symlinks to repository
- [ ] Configuration documented in app-post-install-configuration.md
- [ ] Token/credential setup documented (GitHub token creation guide)
- [ ] Tested in VM with all MCP servers responding
- [ ] Example queries documented for each MCP server (including sequential thinking use cases)
- [ ] Verified no npm/npx dependencies needed
- [ ] Bidirectional sync tested (edit in repo, changes visible in ~/.claude/)

**Implementation Status**: Not Started

**Dependencies**:
- Epic-01, Story 01.4-001 (Nix installed and flake.nix exists)
- Epic-01, Story 01.5-001 (Home Manager available)

**Risk Level**: Low
**Risk Mitigation**:
- Fully Nix-based installation (claude-code-nix + mcp-servers-nix)
- No npm/npx dependencies - everything via Nix packages
- Reproducible across all machines via flake.lock
- MCP servers as system packages (no runtime downloads)
- GitHub token stored in config file (document secure storage options)
- Test each MCP server independently with version checks
- Community-maintained Nix packages with active development

---

### Feature 02.3: Browsers
**Feature Description**: Install web browsers for development and daily use
**User Value**: Multiple browser options for testing and preference
**Story Count**: 2
**Story Points**: 5
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 02.3-001: Brave Browser Installation
**User Story**: As FX, I want Brave browser installed with auto-update disabled so that I have a privacy-focused browser with built-in ad blocking

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Brave
- **Then** it opens successfully
- **And** auto-update is disabled (via Brave preferences)
- **And** Brave is accessible from Spotlight/Raycast
- **And** I can set it as default browser if desired
- **And** Brave Shields (ad blocker) is enabled by default

**Additional Requirements**:
- Installation via Homebrew Cask
- Auto-update disabled via preferences
- Privacy-focused: Built-in ad/tracker blocking
- First run shows onboarding (expected)

**Technical Notes**:
- Homebrew cask: `brave-browser`
- Auto-update disable: Brave → Settings → About Brave → Uncheck "Automatically update Brave"
- Brave Shields: Enabled by default (blocks ads and trackers)
- Privacy features: HTTPS Everywhere, anti-fingerprinting
- Document manual disable: Settings → About Brave → Auto-update toggle

**Definition of Done**:
- [ ] Brave installed via homebrew.nix
- [ ] Auto-update disabled or documented
- [ ] Brave launches successfully
- [ ] Brave Shields working (test on ad-heavy site)
- [ ] Tested in VM
- [ ] Documentation notes update preferences

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: Document manual auto-update disable if automated method doesn't work

---

##### Story 02.3-002: Arc Browser Installation
**User Story**: As FX, I want Arc browser installed with auto-update disabled so that I have a modern, workspace-focused browser

**Priority**: Must Have
**Story Points**: 2
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Arc
- **Then** it opens successfully
- **And** auto-update is disabled (via Arc preferences)
- **And** Arc is accessible from Spotlight/Raycast
- **And** I can set it as default browser if desired

**Additional Requirements**:
- Installation via Homebrew Cask
- Auto-update disable documented (may require manual setting)
- First run shows onboarding (expected)

**Technical Notes**:
- Homebrew cask: `arc`
- Auto-update: Check Arc → Settings → Advanced → Auto-update
- Likely requires manual disable (document in post-install)

**Definition of Done**:
- [ ] Arc installed via homebrew.nix
- [ ] Auto-update disable steps documented
- [ ] Arc launches successfully
- [ ] Tested in VM
- [ ] Documentation notes preferences

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 02.4: Productivity & Utilities
**Feature Description**: Install productivity apps, system utilities, and monitoring tools
**User Value**: Complete suite of tools for file management, archiving, system maintenance, and monitoring
**Story Count**: 7
**Story Points**: 27
**Priority**: High
**Complexity**: Low-Medium

#### Stories in This Feature

##### Story 02.4-001: Raycast Installation
**User Story**: As FX, I want Raycast installed as my application launcher and productivity tool so that I can quickly access apps and features

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I press the Raycast hotkey (configurable)
- **Then** Raycast launcher opens
- **And** I can search and launch applications
- **And** auto-update is disabled (Preferences → Advanced → Auto-update)
- **And** basic extensions are available

**Additional Requirements**:
- Installation via Homebrew Cask
- Auto-update disable documented
- First run configuration (hotkey setup)

**Technical Notes**:
- Homebrew cask: `raycast`
- Auto-update: Preferences → Advanced → Disable auto-update (manual step, document)
- Default hotkey: Usually Cmd+Space or configurable
- Extensions: User can add manually later

**Definition of Done**:
- [ ] Raycast installed via homebrew.nix
- [ ] Launches successfully
- [ ] Auto-update disable documented
- [ ] Tested in VM
- [ ] Documentation notes hotkey setup

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-002: 1Password Installation
**User Story**: As FX, I want 1Password installed so that I can manage passwords and licenses securely

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch 1Password
- **Then** it opens and prompts for account sign-in
- **And** auto-update is disabled (Preferences → Advanced)
- **And** Safari/browser extension prompts for installation
- **And** app is marked as requiring manual license activation

**Additional Requirements**:
- Installation via Homebrew Cask
- Licensed app (requires sign-in)
- Auto-update disable documented
- Browser extension setup documented

**Technical Notes**:
- Homebrew cask: `1password`
- Auto-update: Preferences → Advanced → Disable auto-update
- License: User signs in with 1Password account (no separate license key)
- Document in licensed-apps.md

**Definition of Done**:
- [ ] 1Password installed via homebrew.nix
- [ ] Launches successfully
- [ ] Auto-update disable documented
- [ ] Sign-in process documented
- [ ] Marked as licensed app in docs
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-003: File Utilities (Calibre, Kindle, Keka, Marked 2)
**User Story**: As FX, I want Calibre, Kindle, Keka, and Marked 2 installed so that I can manage ebooks, archives, and preview Markdown files

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I check installed applications
- **Then** Calibre is installed (ebook manager) and launches
- **And** Kindle is installed (via mas) and launches
- **And** Keka is installed (archiver) and launches
- **And** Marked 2 is installed (via mas) and launches
- **And** Keka is set as default for .zip, .rar files (or documented)
- **And** Calibre auto-update is disabled
- **And** Marked 2 auto-update is disabled (Preferences)

**Additional Requirements**:
- Calibre: Homebrew Cask
- Kindle: Mac App Store (mas)
- Keka: Homebrew Cask
- Marked 2: Mac App Store (mas) - Markdown preview app
- Auto-update disable for Calibre (Preferences → Misc)
- Auto-update disable for Marked 2 (Preferences → General)

**Technical Notes**:
- Add to darwin/homebrew.nix:
  ```nix
  homebrew.casks = [ "calibre" "keka" ];
  homebrew.masApps = {
    "Kindle" = 302584613;  # App Store ID
    "Marked 2" = 890031187;  # App Store ID
  };
  ```
- Auto-update:
  - Calibre → Preferences → Misc → Auto-update (disable)
  - Marked 2 → Preferences → General → Check for updates (disable)
- Keka: May need UTI association for file types (document if manual)
- Marked 2: Markdown preview with live reload, exports to PDF/HTML

**Definition of Done**:
- [ ] All four apps installed
- [ ] Each app launches successfully
- [ ] Calibre auto-update disabled
- [ ] Marked 2 auto-update disabled
- [ ] File associations documented
- [ ] Tested in VM
- [ ] Documentation notes Kindle requires sign-in

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew + mas managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-004: Dropbox Installation
**User Story**: As FX, I want Dropbox installed so that I can sync files across my Macs

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Dropbox
- **Then** it opens and prompts for account sign-in
- **And** auto-update is disabled (Preferences → General)
- **And** app is marked as requiring manual activation
- **And** menubar icon appears after sign-in

**Additional Requirements**:
- Installation via Homebrew Cask
- Requires Dropbox account sign-in
- Auto-update disable documented
- Sync folder location configurable

**Technical Notes**:
- Homebrew cask: `dropbox`
- Auto-update: Preferences → General → Uncheck "Automatically update Dropbox"
- License: Free or paid account sign-in (no separate key)
- Document in licensed-apps.md (requires account)

**Definition of Done**:
- [ ] Dropbox installed via homebrew.nix
- [ ] Launches and shows sign-in
- [ ] Auto-update disable documented
- [ ] Sign-in process documented
- [ ] Tested in VM
- [ ] Marked as requiring account in docs

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-005: System Utilities (Onyx, flux)
**User Story**: As FX, I want Onyx and f.lux installed so that I can perform system maintenance and adjust display color temperature

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Onyx
- **Then** it opens and shows system maintenance options
- **And** I can run maintenance tasks (cache clearing, etc.)
- **When** I launch f.lux
- **Then** it starts and adds menubar icon
- **And** color temperature adjusts based on time of day
- **And** f.lux preferences are configurable

**Additional Requirements**:
- Onyx: Homebrew Cask (system maintenance)
- f.lux: Homebrew Cask (display color temperature)
- Both apps are free, no license needed

**Technical Notes**:
- Homebrew casks: `onyx`, `flux`
- Add to darwin/homebrew.nix casks list
- f.lux: May request accessibility permissions (expected)
- Onyx: May request admin password for maintenance tasks (expected)

**Definition of Done**:
- [ ] Both apps installed via homebrew.nix
- [ ] Onyx launches and shows maintenance tools
- [ ] f.lux launches and menubar icon appears
- [ ] Both apps functional
- [ ] Tested in VM
- [ ] Documentation notes permission requests

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-006: System Monitoring (btop, iStat Menus, macmon)
**User Story**: As FX, I want gotop, iStat Menus, and macmon installed so that I can monitor system performance

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `gotop`
- **Then** it shows interactive system monitor (CPU, RAM, disk, network)
- **When** I launch iStat Menus
- **Then** menubar icons appear showing system stats
- **And** iStat Menus prompts for license activation (marked as licensed app)
- **When** I launch macmon
- **Then** it shows system monitoring dashboard
- **And** auto-update is disabled for iStat Menus

**Additional Requirements**:
- gotop, macmon: Nix package (CLI tool)
- iStat Menus: Homebrew Cask (licensed app)
- Auto-update disable for iStat Menus

**Technical Notes**:
- Add to darwin/configuration.nix:
  ```nix
  environment.systemPackages = with pkgs; [ gotop macmon ];
  ```
- Add to darwin/homebrew.nix:
  ```nix
  homebrew.casks = [ "istat-menus" ];
  ```
- iStat Menus: Preferences → General → Disable auto-update
- Document iStat Menus in licensed-apps.md (trial or paid license)

**Definition of Done**:
- [ ] gotop and macmon installed via Nix
- [ ] iStat Menus installed via Homebrew
- [ ] gotop launches and shows system stats
- [ ] iStat Menus menubar icons appear
- [ ] macmon launches successfully
- [ ] Auto-update disabled for iStat Menus
- [ ] iStat Menus marked as licensed app
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.4-001 (Nix installed)
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.4-007: Git and Git LFS
**User Story**: As FX, I want Git and Git LFS installed so that I can manage code repositories and large files

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `git --version`
- **Then** it shows Git version (Nix-managed)
- **And** `git lfs --version` works
- **And** Git LFS is initialized globally (`git lfs install`)
- **And** I can clone repos with LFS files
- **And** Git config includes user name and email from user-config.nix

**Additional Requirements**:
- Git via Nix (not macOS default)
- Git LFS via Nix
- Git LFS initialized globally
- User config applied (name, email)

**Technical Notes**:
- Add to darwin/configuration.nix:
  ```nix
  environment.systemPackages = with pkgs; [ git git-lfs ];
  ```
- Git LFS init via activation script or Home Manager:
  ```nix
  home-manager.users.fx = {
    programs.git = {
      enable = true;
      userName = "François Martin";  # from user-config.nix
      userEmail = "fx@example.com";  # from user-config.nix
      lfs.enable = true;
    };
  };
  ```
- Verify: `git config user.name` shows correct name

**Definition of Done**:
- [ ] Git installed via Nix
- [ ] Git LFS installed and initialized
- [ ] User name and email configured
- [ ] Can clone repos with LFS files
- [ ] Tested in VM
- [ ] Documentation notes Git config

**Dependencies**:
- Epic-01, Story 01.4-001 (Nix installed)
- Epic-01, Story 01.2-003 (user-config.nix available)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 02.5: Communication Tools
**Feature Description**: Install communication and meeting applications
**User Value**: Enables work and personal communication workflows
**Story Count**: 2
**Story Points**: 8
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 02.5-001: WhatsApp Installation
**User Story**: As FX, I want WhatsApp installed so that I can use messaging on my Mac

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch WhatsApp
- **Then** it opens and prompts for QR code scan
- **And** I can link my phone successfully
- **And** app is accessible from Spotlight/Raycast

**Additional Requirements**:
- Prefer mas (Mac App Store) if available
- Fallback to Homebrew Cask if not on mas
- Requires phone for QR code linking

**Technical Notes**:
- Check mas availability: `mas search WhatsApp`
- If available on mas:
  ```nix
  homebrew.masApps = {
    "WhatsApp" = 1147396723;  # App Store ID (verify)
  };
  ```
- If not on mas, use Homebrew cask:
  ```nix
  homebrew.casks = [ "whatsapp" ];
  ```
- Document QR code linking process

**Definition of Done**:
- [ ] WhatsApp installed via mas or Homebrew
- [ ] Launches successfully
- [ ] Shows QR code screen
- [ ] Tested in VM
- [ ] Documentation notes linking process

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew + mas managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.5-002: Zoom and Webex Installation
**User Story**: As FX, I want Zoom and Webex installed so that I can join work meetings

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Zoom
- **Then** it opens and prompts for sign-in or meeting join
- **And** auto-update is disabled (Preferences → General)
- **When** I launch Webex
- **Then** it opens and prompts for sign-in
- **And** auto-update is disabled
- **And** both apps are marked as licensed/requiring activation

**Additional Requirements**:
- Zoom: Homebrew Cask, may require license for full features
- Webex: Homebrew Cask, requires company account
- Auto-update disable documented for both
- Camera/microphone permissions expected on first use

**Technical Notes**:
- Homebrew casks: `zoom`, `webex`
- Add to darwin/homebrew.nix casks list
- Zoom auto-update: Preferences → General → "Update Zoom automatically when connected to Wi-Fi" (uncheck)
- Webex auto-update: Preferences → General (check for disable option)
- Document both as requiring sign-in in licensed-apps.md

**Definition of Done**:
- [ ] Both apps installed via homebrew.nix
- [ ] Zoom launches successfully
- [ ] Webex launches successfully
- [ ] Auto-update disable documented
- [ ] Sign-in process documented
- [ ] Marked as licensed apps in docs
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 02.6: Media & Creative Tools
**Feature Description**: Install media players and image editing software
**User Value**: Support for media consumption and basic image editing
**Story Count**: 1
**Story Points**: 3
**Priority**: Medium
**Complexity**: Low

#### Stories in This Feature

##### Story 02.6-001: VLC and GIMP Installation
**User Story**: As FX, I want VLC and GIMP installed so that I can play videos and edit images

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch VLC
- **Then** it opens and can play video files
- **And** VLC auto-update is disabled (Preferences → General)
- **When** I launch GIMP
- **Then** it opens and I can edit images
- **And** both apps are accessible from Spotlight/Raycast

**Additional Requirements**:
- VLC: Homebrew Cask (media player)
- GIMP: Homebrew Cask (image editor)
- Auto-update disable for VLC

**Technical Notes**:
- Homebrew casks: `vlc`, `gimp`
- Add to darwin/homebrew.nix casks list
- VLC auto-update: Preferences → General → Uncheck "Automatically check for updates"
- GIMP: No auto-update to disable

**Definition of Done**:
- [ ] Both apps installed via homebrew.nix
- [ ] VLC launches and plays video
- [ ] GIMP launches and edits images
- [ ] VLC auto-update disabled
- [ ] Tested in VM
- [ ] Documentation notes basic usage

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 02.7: Security & VPN
**Feature Description**: Install VPN client for secure connections
**User Value**: Secure remote access and privacy protection
**Story Count**: 1
**Story Points**: 5
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 02.7-001: NordVPN Installation
**User Story**: As FX, I want NordVPN installed so that I can connect to VPN for privacy and remote access

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch NordVPN
- **Then** it opens and prompts for account sign-in
- **And** menubar icon appears
- **And** I can sign in with my NordVPN account
- **And** auto-update is disabled (if configurable)
- **And** app is marked as requiring activation

**Additional Requirements**:
- Installation via Homebrew Cask
- Requires NordVPN subscription
- Auto-update disable documented if available
- Network extension permissions expected

**Technical Notes**:
- Homebrew cask: `nordvpn`
- Add to darwin/homebrew.nix casks list
- NordVPN: Menubar app, requires sign-in with account
- Auto-update: Check Preferences for disable option (document)
- Network extension: System prompt expected on first connect
- Document in licensed-apps.md (requires subscription)

**Definition of Done**:
- [ ] NordVPN installed via homebrew.nix
- [ ] Launches successfully
- [ ] Shows sign-in screen
- [ ] Menubar icon appears
- [ ] Auto-update documented
- [ ] Marked as licensed app
- [ ] Tested in VM
- [ ] Documentation notes sign-in process

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 02.8: Profile-Specific Applications
**Feature Description**: Install Parallels Desktop on Power profile only
**User Value**: Virtualization capability for development and testing on high-end hardware
**Story Count**: 1
**Story Points**: 8
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 02.8-001: Parallels Desktop Installation (Power Profile Only)
**User Story**: As FX, I want Parallels Desktop installed only on Power profile so that I can run VMs on my MacBook Pro M3 Max

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** Power profile is selected during bootstrap
- **When** darwin-rebuild completes successfully
- **Then** Parallels Desktop is installed
- **And** it launches and prompts for license activation
- **And** I can create and run virtual machines
- **And** Parallels is NOT installed on Standard profile
- **And** auto-update is disabled (Preferences → Advanced)
- **And** app is marked as requiring license activation

**Additional Requirements**:
- Installation via Homebrew Cask
- Power profile only (MacBook Pro M3 Max)
- Requires Parallels license (paid, annual subscription or perpetual)
- Auto-update disable documented
- Large app (~500MB)

**Technical Notes**:
- Add to darwin/homebrew.nix in Power profile only:
  ```nix
  # In darwinConfigurations.power
  homebrew.casks = [
    # ... other casks
    "parallels"
  ];
  # NOT in darwinConfigurations.standard
  ```
- Parallels auto-update: Preferences → Advanced → Uncheck auto-update
- License: Requires activation with license key or account
- Document in licensed-apps.md (trial or paid license required)
- Verify profile differentiation: Parallels present on Power, absent on Standard

**Definition of Done**:
- [ ] Parallels added to Power profile only
- [ ] NOT in Standard profile
- [ ] Parallels launches on Power profile
- [ ] Shows license activation screen
- [ ] Auto-update disable documented
- [ ] Marked as licensed app
- [ ] Profile differentiation tested in VM
- [ ] Documentation notes license requirement

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)
- Epic-01, Story 01.2-002 (Profile selection system)

**Risk Level**: Medium
**Risk Mitigation**: Clear documentation of license requirement, verify profile-specific installation works

---

### Feature 02.9: Office 365 (Homebrew Cask Installation)
**Feature Description**: Automated installation of Microsoft Office 365 suite via Homebrew cask
**User Value**: Office apps installed automatically, only requires sign-in for activation
**Story Count**: 1
**Story Points**: 5
**Priority**: Must Have
**Complexity**: Medium

#### Stories in This Feature

##### Story 02.9-001: Office 365 Installation via Homebrew
**User Story**: As FX, I want Office 365 installed automatically via Homebrew cask so that I can start work immediately after signing in

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** nix-darwin homebrew configuration
- **When** the system is rebuilt
- **Then** Office 365 cask (microsoft-office-businesspro) is installed via Homebrew
- **And** Word, Excel, PowerPoint, Outlook, OneNote, and Teams are available in /Applications
- **And** apps launch successfully (but require sign-in)
- **And** licensed-apps.md documents the sign-in activation process
- **And** bootstrap summary notes Office 365 requires Microsoft account sign-in

**Additional Requirements**:
- Homebrew cask: `microsoft-office-businesspro`
- Automated installation via nix-darwin homebrew module
- Manual activation: User must sign in with Microsoft account
- No license key needed (subscription-based)
- All Office apps included: Word, Excel, PowerPoint, Outlook, OneNote, Teams

**Technical Notes**:
- Add to darwin/homebrew.nix casks list:
  ```nix
  homebrew.casks = [
    # ... other casks
    "microsoft-office-businesspro"  # Office 365 suite
  ];
  ```
- Add to docs/licensed-apps.md:
  ```markdown
  ## Office 365 (Sign-In Required)

  Office 365 is installed automatically but requires activation:

  1. Launch any Office app (Word, Excel, PowerPoint, etc.)
  2. Click "Sign In" when prompted
  3. Enter your Microsoft account (personal) or company Office 365 email
  4. Follow the authentication prompts
  5. Your subscription will activate automatically

  Note: Requires active Office 365 subscription (personal or company).
  ```
- Mark in bootstrap summary as "Installed - Activation Required"

**Definition of Done**:
- [ ] Homebrew cask added to darwin/homebrew.nix
- [ ] Office 365 apps install successfully via darwin-rebuild
- [ ] All apps (Word, Excel, PowerPoint, Outlook, OneNote, Teams) launch
- [ ] Sign-in documentation added to licensed-apps.md
- [ ] Bootstrap summary updated
- [ ] Tested in VM with successful installation
- [ ] Tested activation flow (sign-in) on physical hardware

**Dependencies**:
- Story 02.2-001 (Homebrew cask configuration)
- Epic-07, Story 07.2-001 (Licensed apps documentation)

**Risk Level**: Low
**Risk Mitigation**: Standard Homebrew cask, widely tested

---

### Feature 02.10: Email Account Configuration
**Feature Description**: Automated setup of email accounts in macOS Mail.app (1 Gmail with OAuth, 4 Gandi.net accounts with manual passwords)
**User Value**: Email accounts configured automatically during bootstrap, ready to use immediately
**Story Count**: 1
**Story Points**: 5
**Priority**: Must Have
**Complexity**: Medium

#### Stories in This Feature

##### Story 02.10-001: macOS Mail.app Email Account Automation
**User Story**: As FX, I want my 5 email accounts (1 Gmail, 4 Gandi.net) automatically configured in macOS Mail.app so that I can start using email immediately after first launch

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 4

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I open Mail.app for the first time
- **Then** all 5 email accounts are listed in the sidebar
- **And** Gmail account prompts for OAuth sign-in (expected manual step)
- **And** Gandi.net accounts prompt for password entry (expected manual step)
- **And** after entering credentials, all accounts sync successfully
- **And** I can send and receive email from all accounts
- **And** account configuration includes correct IMAP and SMTP settings

**Additional Requirements**:
- Gmail account: OAuth authentication (user must sign in)
- Gandi.net accounts (4): IMAP/SMTP with manual password entry
- Account details from user-config.nix or separate email-config.nix
- Configuration via macOS defaults, profiles, or activation scripts
- Both Standard and Power profiles

**Technical Notes**:
- **Approach 1 (Recommended)**: Configuration Profile (.mobileconfig)
  - Create .mobileconfig XML with account definitions
  - Install via `open` command or system activation script
  - Passwords left blank (user enters after first launch)
  - Gmail: Account type = EmailTypeIMAP with OAuth placeholder
  - Gandi: Account type = EmailTypeIMAP with server settings

- **Approach 2**: macOS defaults write
  - Use `defaults` commands to write Mail.app preferences
  - More fragile, may break across macOS versions

- **Approach 3**: AppleScript automation
  - Script Mail.app to add accounts programmatically
  - Complex, requires accessibility permissions

- **Recommended Implementation**:
  ```nix
  # In darwin/configuration.nix or home-manager module
  system.activationScripts.configureMailAccounts = {
    text = ''
      # Copy email configuration profile
      MAIL_CONFIG="/tmp/email-accounts.mobileconfig"
      cat > "$MAIL_CONFIG" <<'EOF'
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>PayloadContent</key>
        <array>
          <!-- Gmail Account -->
          <dict>
            <key>PayloadType</key>
            <string>com.apple.mail.managed</string>
            <key>EmailAccountDescription</key>
            <string>Gmail</string>
            <key>EmailAccountType</key>
            <string>EmailTypeIMAP</string>
            <key>EmailAddress</key>
            <string>${user.email.gmail}</string>
            <key>IncomingMailServerHostName</key>
            <string>imap.gmail.com</string>
            <key>IncomingMailServerPortNumber</key>
            <integer>993</integer>
            <key>IncomingMailServerUseSSL</key>
            <true/>
            <key>IncomingMailServerAuthentication</key>
            <string>EmailAuthOAuth2</string>
            <key>OutgoingMailServerHostName</key>
            <string>smtp.gmail.com</string>
            <key>OutgoingMailServerPortNumber</key>
            <integer>587</integer>
            <key>OutgoingMailServerUseSSL</key>
            <true/>
            <key>OutgoingMailServerAuthentication</key>
            <string>EmailAuthOAuth2</string>
          </dict>
          <!-- Gandi Account 1 -->
          <dict>
            <key>PayloadType</key>
            <string>com.apple.mail.managed</string>
            <key>EmailAccountDescription</key>
            <string>Gandi Account 1</string>
            <key>EmailAccountType</key>
            <string>EmailTypeIMAP</string>
            <key>EmailAddress</key>
            <string>${user.email.gandi1}</string>
            <key>IncomingMailServerHostName</key>
            <string>mail.gandi.net</string>
            <key>IncomingMailServerPortNumber</key>
            <integer>993</integer>
            <key>IncomingMailServerUseSSL</key>
            <true/>
            <key>IncomingMailServerAuthentication</key>
            <string>EmailAuthPassword</string>
            <key>OutgoingMailServerHostName</key>
            <string>mail.gandi.net</string>
            <key>OutgoingMailServerPortNumber</key>
            <integer>587</integer>
            <key>OutgoingMailServerUseSSL</key>
            <true/>
            <key>OutgoingMailServerAuthentication</key>
            <string>EmailAuthPassword</string>
          </dict>
          <!-- Repeat for Gandi accounts 2-4 -->
        </array>
        <key>PayloadDisplayName</key>
        <string>Email Accounts</string>
        <key>PayloadIdentifier</key>
        <string>com.fx.email-accounts</string>
        <key>PayloadType</key>
        <string>Configuration</string>
        <key>PayloadUUID</key>
        <string>$(uuidgen)</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
      </dict>
      </plist>
      EOF

      # Install profile (user will see system prompt)
      open "$MAIL_CONFIG"

      echo "Email accounts configured. Open Mail.app and enter passwords when prompted."
    '';
  };
  ```

- **Email Configuration File** (email-config.nix or in user-config.nix):
  ```nix
  {
    email = {
      gmail = "you@gmail.com";
      gandi1 = "account1@yourdomain.com";
      gandi2 = "account2@yourdomain.com";
      gandi3 = "account3@yourdomain.com";
      gandi4 = "account4@yourdomain.com";
    };
  }
  ```

- **Gandi.net Settings**:
  - IMAP: mail.gandi.net, port 993, SSL
  - SMTP: mail.gandi.net, port 587, STARTTLS
  - Authentication: Username = full email address, password required

- **Gmail Settings**:
  - IMAP: imap.gmail.com, port 993, SSL
  - SMTP: smtp.gmail.com, port 587, STARTTLS
  - Authentication: OAuth2 (user signs in via browser)
  - May require "Allow less secure apps" or app-specific password if OAuth fails

**Definition of Done**:
- [ ] Email configuration implementation chosen (profile, defaults, or script)
- [ ] Email addresses configurable in user-config.nix or email-config.nix
- [ ] Configuration profile or script created
- [ ] Activation script installs account configuration
- [ ] Tested in VM: Mail.app shows all 5 accounts
- [ ] Tested credential entry: Gmail OAuth and Gandi password prompts work
- [ ] All accounts sync successfully after credential entry
- [ ] Documentation added to post-install guide
- [ ] Bootstrap summary notes manual credential entry required
- [ ] Works on both Standard and Power profiles

**Implementation Status**: Not Started

**Dependencies**:
- Epic-01, Story 01.2-003 (user-config.nix created with user email addresses)
- Epic-07, Story 07.2-002 (Post-install configuration documentation)

**Risk Level**: Medium
**Risk Mitigation**:
- Configuration profiles are Apple-supported and stable
- Manual password entry is expected and acceptable
- Gmail OAuth may require troubleshooting (app-specific passwords as fallback)
- Test thoroughly in VM before physical hardware
- Document all manual steps clearly

---

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: All application installation depends on bootstrap completing (Nix, nix-darwin, Homebrew installed)
- **Epic-05 (Theming)**: Zed and Ghostty theming depends on Stylix configuration
- **Epic-07 (Documentation)**: Licensed app activation guide needed for post-install

### Stories This Epic Enables
- Epic-04, Story 04.X-XXX: Development workflow stories (depends on dev tools installed)
- Epic-05, Story 05.1-XXX: Theming stories (Zed and Ghostty theming)
- Epic-07, Story 07.2-001: Licensed apps documentation

### Stories This Epic Blocks
- Epic-04 development workflow stories (needs Python, Podman, Git installed)
- Epic-06 health check stories (needs btop, monitoring tools)

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 3 | 02.1-001 to 02.4-007 | 93 | AI tools, dev environment (inc. Claude Code + MCP), browsers, productivity apps, utilities |
| Sprint 4 | 02.5-001 to 02.10-001 | 33 | Communication tools, media apps, security, Parallels, Office 365, email accounts |

### Delivery Milestones
- **Milestone 1**: End Sprint 3 - Core apps installed (AI, dev tools, browsers, productivity)
- **Milestone 2**: End Sprint 4 - All apps installed, licensed apps documented
- **Epic Complete**: Week 3 - All apps functional, both profiles tested

### Risk Assessment
**High Risk Items**:
- Story 02.1-004 (Power Ollama models): Large downloads (80GB), network-dependent, long duration
  - Mitigation: Progress indicators, retry logic, document expected time
- Story 02.2-005 (Podman): Machine initialization may fail or require manual intervention
  - Mitigation: Clear documentation, troubleshooting steps, health check validation

**Medium Risk Items**:
- Story 02.8-001 (Parallels): Profile-specific installation must work correctly, license required
  - Mitigation: Test both profiles in VM, document license activation clearly

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 7 of 26 (26.9%)
- **Story Points Completed**: 36 of 126 (28.6%)
- **MVP Stories Completed**: 7 of 26 (26.9%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 3 | 93 | 36 | 7/18 | In Progress |
| Sprint 4 | 33 | 0 | 0/8 | Not Started |

### Recently Completed Stories (2025-11-12)
- ✅ **Story 02.1-001**: Claude Desktop and AI Chat Apps (3 points) - VM tested
- ✅ **Story 02.1-002**: Ollama Desktop App Installation (5 points) - VM tested
- ✅ **Story 02.1-003**: Standard Profile Ollama Model (5 points) - VM tested
- ✅ **Story 02.1-004**: Power Profile Additional Ollama Models (8 points) - VM tested
- ✅ **Story 02.2-001**: Zed Editor Installation and Configuration (5 points) - VM tested

## Epic Acceptance Criteria
- [ ] All MVP stories (26/26) completed and accepted
- [ ] All apps launch successfully on both profiles
- [ ] Profile differentiation verified (Parallels and Ollama models on Power only)
- [ ] Auto-updates disabled for all apps that support it
- [ ] Licensed apps documented with activation instructions
- [ ] All dev tools functional (Python, Podman, Git, editors, Claude Code CLI)
- [ ] Claude Code CLI with MCP servers (Context7, GitHub) configured and functional
- [ ] Browsers installed and configured
- [ ] Communication tools working
- [ ] Media apps functional
- [ ] Monitoring tools installed and reporting
- [ ] Email accounts configured in macOS Mail.app (5 accounts: 1 Gmail, 4 Gandi.net)
- [ ] Email accounts functional after credential entry
- [ ] VM testing successful for both profiles
- [ ] Physical hardware testing successful

## Story Validation Checklist

### Quality Assurance for Each Story
- [ ] Follows proper user story format ("As [persona], I want [functionality] so that [benefit]")
- [ ] Has clear, testable acceptance criteria (Given/When/Then format)
- [ ] Includes all necessary context and constraints
- [ ] Sized appropriately for single sprint
- [ ] Dependencies clearly identified
- [ ] Business value articulated
- [ ] Persona alignment verified (FX as primary user)
- [ ] Technical feasibility confirmed

### Epic Health Metrics
- **Story Readiness**: 100% of stories meet definition of ready
- **Dependency Coverage**: All dependencies identified and managed
- **Estimation Confidence**: High confidence in story point estimates
- **Acceptance Criteria Quality**: Clear, testable, and complete criteria for all stories
