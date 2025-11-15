# ABOUTME: Epic-02 Feature 02.1 (AI & LLM Tools Installation) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 02.1

# Epic-02 Feature 02.1: AI & LLM Tools Installation

## Feature Overview

**Feature ID**: Feature 02.1
**Feature Name**: AI & LLM Tools Installation
**Epic**: Epic-02
**Status**: 🔄 In Progress

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

