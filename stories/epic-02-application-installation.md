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

## Epic Scope
**Total Stories**: 22
**Total Story Points**: 113
**MVP Stories**: 22 (100% of epic)
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
- Homebrew cask names: `claude`, `chatgpt`, `perplexity`
- Add to darwin/homebrew.nix casks list
- Auto-update: May require manual disable in app settings (document in post-install)
- Test: Verify apps launch and show sign-in screens

**Definition of Done**:
- [x] Code implemented in homebrew.nix
- [ ] All three apps install successfully (VM testing by FX)
- [ ] Apps launch without errors (VM testing by FX)
- [x] Auto-update preferences documented (docs/app-post-install-configuration.md)
- [ ] Tested in VM with both profiles (VM testing by FX)
- [x] Documentation notes first-run sign-in required

**Implementation Status**: ✅ **CODE COMPLETE** - Ready for VM testing by FX
**Implementation Date**: 2025-11-11
**Branch**: feature/02.1-001-ai-chat-apps
**Files Changed**:
- darwin/homebrew.nix: Added `claude`, `chatgpt`, `perplexity` casks
- docs/app-post-install-configuration.md: Created post-install configuration guide

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
- Homebrew cask: `ollama`
- Add to darwin/homebrew.nix casks list (NOT brews)
- Desktop app includes CLI tools bundled
- Daemon management: Automatic via desktop app
- Model storage: ~/Library/Application Support/Ollama
- Test command: `ollama pull llama2 && ollama run llama2 "test"`
- Auto-update: Check app preferences after first launch

**Definition of Done**:
- [x] Ollama Desktop App added to homebrew.nix casks
- [ ] Desktop app launches successfully with menubar icon (VM testing by FX)
- [ ] `ollama --version` works in terminal (VM testing by FX)
- [ ] Can pull and run a test model (VM testing by FX)
- [ ] Daemon runs automatically (VM testing by FX)
- [ ] GUI shows model management interface (VM testing by FX)
- [x] Auto-update disable steps documented (docs/app-post-install-configuration.md)
- [ ] Tested in VM (VM testing by FX)
- [x] Documentation notes model storage location

**Implementation Status**: ✅ **CODE COMPLETE** - Ready for VM testing by FX
**Implementation Date**: 2025-11-11
**Branch**: feature/02.1-001-ai-chat-apps (combined with 02.1-001)
**Files Changed**:
- darwin/homebrew.nix: Added `ollama` cask
- docs/app-post-install-configuration.md: Added Ollama Desktop section
- stories/epic-02-application-installation.md: Updated story from CLI to Desktop App

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed by nix-darwin)

**Risk Level**: Low
**Risk Mitigation**: N/A

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
- [ ] Model pulls during first rebuild (VM testing by FX)
- [x] Script is idempotent (doesn't re-pull)
- [ ] `ollama list` shows model after rebuild (VM testing by FX)
- [ ] Model runs successfully (VM testing by FX)
- [ ] Tested in VM with Standard profile (VM testing by FX)

**Implementation Status**: ✅ **CODE COMPLETE** - Ready for VM testing by FX
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

**Risk Level**: Medium
**Risk Mitigation**: Check Ollama daemon is running before pulling, handle network failures gracefully

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
- [ ] Activation script implemented for Power profile
- [ ] All 4 models pull during first rebuild
- [ ] Script is idempotent
- [ ] `ollama list` shows all models
- [ ] Each model runs successfully
- [ ] Tested in VM with Power profile
- [ ] Documentation notes expected download time

**Dependencies**:
- Story 02.1-002 (Ollama installed)
- Story 02.1-003 (Standard model pull pattern established)

**Risk Level**: Medium
**Risk Mitigation**: Handle network interruptions, allow retry, document storage requirements

---

### Feature 02.2: Development Environment Applications
**Feature Description**: Install development editors, terminals, and container tools
**User Value**: Complete development workflow support for Python and containerized applications
**Story Count**: 5
**Story Points**: 24
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

**Technical Notes**:
- Homebrew cask: `zed`
- Stylix should automatically theme Zed if supported
- If not, manual config via Home Manager:
  ```nix
  home-manager.users.fx = {
    programs.zed = {
      enable = true;
      settings = {
        auto_update = false;
        theme = "Catppuccin Mocha";
        buffer_font_family = "JetBrains Mono";
        # ... other settings
      };
    };
  };
  ```
- Verify theme switching with system appearance

**Definition of Done**:
- [ ] Zed installed via homebrew.nix
- [ ] Zed configuration in home-manager module
- [ ] Catppuccin theme applied
- [ ] JetBrains Mono font active
- [ ] Auto-update disabled
- [ ] Theme switches with system appearance
- [ ] Tested in VM

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

**Technical Notes**:
- Homebrew cask: `visual-studio-code`
- Auto-update disable via Home Manager settings:
  ```nix
  programs.vscode = {
    enable = true;
    userSettings = {
      "update.mode" = "none";
      "workbench.colorTheme" = "Catppuccin Mocha";
    };
  };
  ```
- Document Claude Code extension install: Extensions → Search "Claude Code" → Install

**Definition of Done**:
- [ ] VSCode installed via homebrew.nix
- [ ] Auto-update disabled in settings
- [ ] VSCode launches successfully
- [ ] Extension installation documented
- [ ] Tested in VM
- [ ] Theme configured (Stylix or manual)

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.2-003: Ghostty Terminal Installation
**User Story**: As FX, I want Ghostty terminal installed with my existing config from `config/config.ghostty` so that I have a fast GPU-accelerated terminal with Catppuccin theming

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Ghostty
- **Then** it opens with configuration from `config/config.ghostty`
- **And** Catppuccin theme is applied (Latte/Mocha auto-switch)
- **And** JetBrains Mono font with ligatures is active
- **And** 95% opacity with blur effect works
- **And** all keybindings from config are functional
- **And** auto-update is disabled (`auto-update = off` in config)

**Additional Requirements**:
- Installation via Homebrew Cask
- Configuration via Home Manager (copy existing config)
- Theme consistency with Zed (same Catppuccin variant)
- Config location: ~/.config/ghostty/config

**Technical Notes**:
- Homebrew cask: `ghostty`
- Home Manager config:
  ```nix
  xdg.configFile."ghostty/config".source = ../config/config.ghostty;
  ```
- Existing config already has Catppuccin theme and auto-update=off
- Verify: `ls -la ~/.config/ghostty/config` should be symlink to Nix store

**Definition of Done**:
- [ ] Ghostty installed via homebrew.nix
- [ ] Config symlinked to ~/.config/ghostty/
- [ ] Ghostty launches with correct theme
- [ ] Font and ligatures working
- [ ] Opacity and blur effects active
- [ ] Keybindings functional
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew + Home Manager)
- Epic-05, Story 05.1-001 (Stylix provides consistent theme)

**Risk Level**: Low
**Risk Mitigation**: Existing config.ghostty is proven to work

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
- [ ] Python 3.12 installed via Nix
- [ ] uv installed and functional
- [ ] All dev tools installed and in PATH
- [ ] Can create and manage Python projects
- [ ] Tested in VM
- [ ] Documentation notes uv usage

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

**Additional Requirements**:
- Podman CLI via Nix
- podman-compose via Nix
- Podman Desktop via Homebrew Cask (GUI app)
- Machine initialization automated or documented

**Technical Notes**:
- Add to darwin/configuration.nix:
  ```nix
  environment.systemPackages = with pkgs; [
    podman
    podman-compose
  ];
  ```
- Add to darwin/homebrew.nix:
  ```nix
  homebrew.casks = [ "podman-desktop" ];
  ```
- Initialize Podman machine: `podman machine init && podman machine start`
- May need activation script or user documentation

**Definition of Done**:
- [ ] Podman CLI installed via Nix
- [ ] podman-compose installed
- [ ] Podman Desktop installed via Homebrew
- [ ] Can run containers successfully
- [ ] Machine initialization documented
- [ ] Tested in VM
- [ ] Documentation includes setup steps

**Dependencies**:
- Epic-01, Story 01.4-001 (Nix installed)
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Medium
**Risk Mitigation**: Document machine initialization clearly, provide troubleshooting for common issues

---

### Feature 02.3: Browsers
**Feature Description**: Install web browsers for development and daily use
**User Value**: Multiple browser options for testing and preference
**Story Count**: 2
**Story Points**: 5
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 02.3-001: Firefox Installation
**User Story**: As FX, I want Firefox installed with auto-update disabled so that I have a privacy-focused browser with version control

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Firefox
- **Then** it opens successfully
- **And** auto-update is disabled (`app.update.auto = false` preference)
- **And** Firefox is accessible from Spotlight/Raycast
- **And** I can set it as default browser if desired

**Additional Requirements**:
- Installation via Homebrew Cask
- Auto-update disabled via user.js or policies
- First run shows onboarding (expected)

**Technical Notes**:
- Homebrew cask: `firefox`
- Auto-update disable options:
  1. Via policies.json in Firefox.app/Contents/Resources/
  2. Via user.js in profile (requires knowing profile path)
  3. Document manual disable: Preferences → General → Firefox Updates → "Never check for updates"
- May need activation script to set policy file

**Definition of Done**:
- [ ] Firefox installed via homebrew.nix
- [ ] Auto-update disabled or documented
- [ ] Firefox launches successfully
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

##### Story 02.4-003: File Utilities (Calibre, Kindle, Keka)
**User Story**: As FX, I want Calibre, Kindle, and Keka installed so that I can manage ebooks and archives

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I check installed applications
- **Then** Calibre is installed (ebook manager) and launches
- **And** Kindle is installed (via mas) and launches
- **And** Keka is installed (archiver) and launches
- **And** Keka is set as default for .zip, .rar files (or documented)
- **And** Calibre auto-update is disabled

**Additional Requirements**:
- Calibre: Homebrew Cask
- Kindle: Mac App Store (mas)
- Keka: Homebrew Cask
- Auto-update disable for Calibre (Preferences → Misc)

**Technical Notes**:
- Add to darwin/homebrew.nix:
  ```nix
  homebrew.casks = [ "calibre" "keka" ];
  homebrew.masApps = {
    "Kindle" = 302584613;  # App Store ID
  };
  ```
- Auto-update: Calibre → Preferences → Misc → Auto-update (disable)
- Keka: May need UTI association for file types (document if manual)

**Definition of Done**:
- [ ] All three apps installed
- [ ] Each app launches successfully
- [ ] Calibre auto-update disabled
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
**User Story**: As FX, I want btop, iStat Menus, and macmon installed so that I can monitor system performance

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `btop`
- **Then** it shows interactive system monitor (CPU, RAM, disk, network)
- **When** I launch iStat Menus
- **Then** menubar icons appear showing system stats
- **And** iStat Menus prompts for license activation (marked as licensed app)
- **When** I launch macmon
- **Then** it shows system monitoring dashboard
- **And** auto-update is disabled for iStat Menus

**Additional Requirements**:
- btop: Nix package (CLI tool)
- iStat Menus: Homebrew Cask (licensed app)
- macmon: Homebrew Cask
- Auto-update disable for iStat Menus

**Technical Notes**:
- Add to darwin/configuration.nix:
  ```nix
  environment.systemPackages = with pkgs; [ btop ];
  ```
- Add to darwin/homebrew.nix:
  ```nix
  homebrew.casks = [ "istat-menus" "macmon" ];
  ```
- iStat Menus: Preferences → General → Disable auto-update
- Document iStat Menus in licensed-apps.md (trial or paid license)

**Definition of Done**:
- [ ] btop installed via Nix
- [ ] iStat Menus and macmon installed via Homebrew
- [ ] btop launches and shows system stats
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
| Sprint 3 | 02.1-001 to 02.4-007 | 85 | AI tools, dev environment, browsers, productivity apps, utilities |
| Sprint 4 | 02.5-001 to 02.9-001 | 28 | Communication tools, media apps, security, Parallels, Office 365 installation |

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
- **Stories Completed**: 0 of 22 (0%)
- **Story Points Completed**: 0 of 110 (0%)
- **MVP Stories Completed**: 0 of 22 (0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 3 | 85 | 0 | 0/17 | Not Started |
| Sprint 4 | 25 | 0 | 0/5 | Not Started |

## Epic Acceptance Criteria
- [ ] All MVP stories (22/22) completed and accepted
- [ ] All apps launch successfully on both profiles
- [ ] Profile differentiation verified (Parallels and Ollama models on Power only)
- [ ] Auto-updates disabled for all apps that support it
- [ ] Licensed apps documented with activation instructions
- [ ] All dev tools functional (Python, Podman, Git, editors)
- [ ] Browsers installed and configured
- [ ] Communication tools working
- [ ] Media apps functional
- [ ] Monitoring tools installed and reporting
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
