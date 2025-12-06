# ABOUTME: Epic and story progress tracking for the nix-install project
# ABOUTME: Contains epic overview table, completed stories, and recent activity log

## Epic Overview Progress Table

| Epic ID | Epic Name | Total Stories | Total Points | Completed Stories | Completed Points | % Complete (Stories) | % Complete (Points) | Status |
|---------|-----------|---------------|--------------|-------------------|------------------|---------------------|-------------------|--------|
| **Epic-01** | Bootstrap & Installation System | 19 | 113 | **17** | **104** | 89.5% | 92.0% | 🟢 Functional |
| **Epic-02** | Application Installation | 25 | 118 | **25** | **118** | 100% | 100% | ✅ Complete |
| **Epic-03** | System Configuration | 14 | 76 | **14** | **76** | 100% | 100% | ✅ Complete |
| **Epic-04** | Development Environment | 18 | 97 | **18** | **97** | 100% | 100% | ✅ Complete |
| **Epic-05** | Theming & Visual Consistency | 7 | 36 | **7** | **36** | 100% | 100% | ✅ Complete |
| **Epic-06** | Maintenance & Monitoring | 10 | 55 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **Epic-07** | Documentation & User Experience | 8 | 34 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **NFR** | Non-Functional Requirements | 15 | 79 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **TOTAL** | **All Epics** | **116** | **608** | **81** | **431** | **69.8%** | **70.9%** | 🟡 In Progress |

### Epic-01 Completed Stories (17/19)

| Story ID | Story Name | Points | Status | Branch | Date Completed |
|----------|------------|--------|--------|--------|----------------|
| 01.1-001 | Pre-flight Environment Checks | 5 | ✅ Complete | feature/01.1-001 | 2025-11-08 |
| 01.1-002 | Idempotency Check (User Config) | 3 | ✅ Complete | main | 2025-11-10 |
| 01.2-001 | User Information Prompts | 5 | ✅ Complete | feature/01.2-001-user-prompts | 2025-11-09 |
| 01.2-002 | Profile Selection System | 8 | ✅ Complete | feature/01.2-002-profile-selection | 2025-11-09 |
| 01.2-003 | User Config File Generation | 3 | ✅ Complete | feature/01.2-003-user-config-generation | 2025-11-09 |
| 01.3-001 | Xcode CLI Tools Installation | 5 | ✅ Complete | main | 2025-11-09 |
| 01.4-001 | Nix Multi-User Installation | 8 | ✅ Complete | main | 2025-11-09 |
| 01.4-002 | Nix Configuration for macOS | 5 | ✅ Complete | feature/01.4-002-nix-configuration | 2025-11-09 |
| 01.4-003 | Flake Infrastructure Setup | 8 | ✅ Complete | main | 2025-11-09 |
| 01.5-001 | Initial Nix-Darwin Build | 13 | ✅ Complete | feature/01.5-001-nix-darwin-build | 2025-11-09 |
| 01.5-002 | Post-Darwin System Validation | 5 | ✅ Complete | main | 2025-11-10 |
| 01.6-001 | SSH Key Generation | 5 | ✅ Complete | feature/01.6-001-ssh-key-generation | 2025-11-10 |
| 01.6-002 | GitHub SSH Key Upload (Automated) | 5 | ✅ Complete | main | 2025-11-11 |
| 01.6-003 | GitHub SSH Connection Test | 8 | ✅ Complete | feature/01.6-003-ssh-connection-test | 2025-11-11 |
| 01.7-001 | Full Repository Clone | 5 | ✅ Complete | feature/01.7-001-repo-clone | 2025-11-11 |
| 01.7-002 | Final Darwin Rebuild (Phase 8) | 8 | ✅ Complete | main | 2025-11-11 |
| 01.8-001 | Installation Summary & Next Steps | 3 | ✅ Complete | feature/01.8-001 | 2025-11-11 |

**Notes**:
- **2025-11-10**: Story 01.6-002 scope changed from manual approach (8 points) to automated GitHub CLI approach (5 points), reducing Epic-01 by 3 points
- **2025-11-11**: Story 01.1-004 added (Modular Bootstrap Architecture, 8 points), increasing Epic-01 by 8 points, **deferred to post-Epic-01**

### Epic-02 Completed Stories (25/25) ✅ EPIC COMPLETE!

| Story ID | Story Name | Points | Status | Branch | Date Completed |
|----------|------------|--------|--------|--------|----------------|
| 02.1-001 | Claude Desktop and AI Chat Apps | 3 | ✅ Complete | feature/02.1-001-ai-chat-apps | 2025-11-12 |
| 02.1-002 | Ollama Desktop App Installation | 3 | ✅ Complete | feature/02.1-001-ai-chat-apps | 2025-11-12 |
| 02.1-003 | Standard Profile Ollama Model | 2 | ✅ Complete | feature/02.1-001-ai-chat-apps | 2025-11-12 |
| 02.1-004 | Power Profile Additional Ollama Models | 8 | ✅ Complete | feature/02.1-001-ai-chat-apps | 2025-11-12 |
| 02.2-001 | Zed Editor Installation and Configuration | 12 | ✅ Complete | feature/02.2-001-zed-editor | 2025-11-12 |
| 02.2-002 | VSCode Installation with Auto Dark Mode | 3 | ✅ Complete | feature/02.2-002-vscode | 2025-11-12 |
| 02.2-003 | Ghostty Terminal Installation | 5 | ✅ Complete | feature/02.2-003-ghostty | 2025-11-12 |
| 02.2-004 | Python and Development Tools | 5 | ✅ Complete | feature/02.2-004-python-dev-tools | 2025-11-12 |
| 02.2-005 | Podman and Container Tools | 6 | ✅ Complete | feature/02.2-005-podman | 2025-11-15 |
| 02.2-006 | Claude Code CLI and MCP Servers | 8 | ✅ Complete | feature/02.2-006-claude-code | 2025-11-15 |
| 02.3-001 | Brave Browser Installation | 3 | ✅ Complete | feature/02.3-001-brave-browser | 2025-11-15 |
| 02.3-002 | Arc Browser Installation | 2 | ✅ Complete | feature/02.3-002-arc-browser | 2025-11-15 |
| 02.4-001 | Raycast Installation | 3 | ✅ Complete | feature/02.4-001-raycast | 2025-01-15 |
| 02.4-002 | 1Password Installation | 3 | ✅ Complete | main | 2025-01-15 |
| 02.4-003 | File Utilities (Calibre, Kindle, Keka, Marked 2) | 5 | ✅ Complete | main | 2025-01-15 |
| 02.4-005 | System Utilities (Onyx, f.lux) | 3 | ✅ Complete | feature/02.4-005-system-utilities | 2025-01-15 |
| 02.4-006 | System Monitoring (gotop, iStat Menus, macmon) | 5 | ✅ Complete | main | 2025-01-16 |
| 02.4-007 | Git and Git LFS | 5 | ✅ Complete | main | 2025-01-15 |
| 02.5-001 | WhatsApp Installation | 3 | ✅ Complete | main | 2025-01-15 |
| 02.5-002 | Zoom and Webex Installation | 5 | ✅ Complete | main | 2025-01-15 |
| 02.6-001 | VLC and GIMP Installation | 3 | ✅ Complete | main | 2025-01-15 |
| 02.8-001 | Parallels Desktop (Power Profile Only) | 8 | ✅ Complete | main | 2025-01-16 |
| 02.4-004 | Dropbox Installation | 3 | ✅ Complete | main | 2025-01-16 |
| 02.7-001 | NordVPN Installation | 5 | ✅ Complete | main | 2025-01-16 |
| 02.9-001 | Office 365 Installation | 5 | ✅ Complete | main | 2025-01-16 |

**Notes**:
- **2025-11-12**: Feature 02.1 (AI & LLM Tools) completed - all 4 stories VM tested by FX (16 points)
- **2025-11-12**: Story 02.2-001 (Zed Editor) completed - VM tested by FX, bidirectional sync implemented (12 points)
- **2025-11-12**: Story 02.2-002 (VSCode) completed - VM tested by FX, auto theme switching working (3 points)
- **2025-11-12**: Story 02.2-003 (Ghostty Terminal) completed - VM tested by FX, REQ-NFR-008 compliant config (5 points)
- **2025-11-12**: Story 02.2-004 (Python & Dev Tools) completed - Python 3.12 + uv + dev tools (ruff, black, isort, mypy, pylint) via Nix (5 points) ✅ VM tested
- **2025-11-12**: Epic-02 increased from 23 to 25 stories after story reconciliation (total points unchanged at 118)
- **2025-11-16**: Story 02.10-001 (Email Account Configuration) **CANCELLED** - Manual setup documented instead (automation proved confusing)
- **2025-11-16**: Stories 02.4-004 (Dropbox), 02.7-001 (NordVPN), 02.9-001 (Office 365) VM tested, pending documentation updates

### Epic-03 Completed Stories (14/14) ✅ EPIC COMPLETE!

| Story ID | Story Name | Points | Status | Branch | Date Completed |
|----------|------------|--------|--------|--------|----------------|
| 03.1-001 | Finder View and Display Settings | 5 | ✅ Complete | feature/03.1-001-finder-view-settings (merged) | 2025-11-19 |
| 03.1-002 | Finder Behavior Settings | 5 | ✅ Complete | main | 2025-12-04 |
| 03.1-003 | Finder Sidebar and Desktop | 8 | ✅ Complete | main | 2025-12-04 |
| 03.2-001 | Firewall Configuration | 5 | ✅ Complete | main | 2025-12-04 |
| 03.2-002 | FileVault Encryption Prompt | 8 | ✅ Complete | main | 2025-12-04 |
| 03.2-003 | Screen Lock and Password Policies | 5 | ✅ Complete | main | 2025-12-04 |
| 03.3-001 | Trackpad Gestures and Speed | 8 | ✅ Complete | main | 2025-12-04 |
| 03.3-002 | Mouse and Scroll Settings | 5 | ✅ Complete | main | 2025-12-04 |
| 03.4-001 | Auto Light/Dark Mode and Time Format | 5 | ✅ Complete | main | 2025-12-04 |
| 03.4-002 | Night Shift Scheduling | 5 | ✅ Complete | main | 2025-12-04 |
| 03.5-001 | Keyboard Repeat and Text Corrections | 5 | ✅ Complete | main | 2025-12-04 |
| 03.6-001 | Dock Behavior and Apps | 4 | ✅ Complete | main | 2025-12-04 |
| 03.7-001 | Time Machine Preferences & Exclusions | 5 | ✅ Complete | main | 2025-12-04 |
| 03.7-002 | Time Machine Destination Setup Prompt | 3 | ✅ Complete | main | 2025-12-05 |

**Notes**:
- **2025-12-04**: Feature 03.3 (Trackpad and Input) and Feature 03.4 (Display and Appearance) **COMPLETE**
  - Story 03.3-001: Trackpad gestures (tap-to-click, three-finger drag, fast speed, natural scrolling disabled) ✅ Hardware Tested
  - Story 03.3-002: Mouse settings (fast speed, scroll direction matches trackpad) ✅ Hardware Tested
  - Story 03.4-001: Auto Light/Dark mode + 24-hour time format ✅ Hardware Tested
  - Story 03.4-002: Night Shift scheduling ✅ Documented (manual config required - CoreBrightness limitation)
  - **Technical Notes**:
    - Mouse scaling uses `.GlobalPreferences` domain (not NSGlobalDomain)
    - Auto appearance uses `CustomUserPreferences.NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically`
    - Three-finger drag handled via `system.defaults.trackpad.TrackpadThreeFingerDrag`
- **2025-12-04**: Feature 03.1 (Finder Configuration) and Feature 03.2 (Security Configuration) **COMPLETE**
  - Story 03.1-002: Finder behavior settings (folders first, search scope, extension warning) ✅ VM Tested
  - Story 03.1-003: Finder sidebar/desktop (new window target, external drives on desktop) ✅ VM Tested
  - Story 03.2-001: Firewall with stealth mode (migrated to `networking.applicationFirewall`) ✅ VM Tested
  - Story 03.2-002: FileVault encryption prompt in bootstrap Phase 9 ✅ Implemented
  - Story 03.2-003: Screen lock policies (Touch ID sudo, guest login disabled) ✅ VM Tested
  - **Known Limitation**: `askForPasswordDelay` deprecated by Apple since macOS 10.13 - manual config required
- **2025-11-19**: Story 03.1-001 **VM TESTED & COMPLETE** - All 8 test cases passed successfully ✅
  - Finder configured with list view, path bar, status bar, hidden files visible, and file extensions shown (5 points)
  - All acceptance criteria met: list view default, path bar, status bar, hidden files, file extensions
  - Settings persisted across Finder restart and system reboot
  - Ready for physical hardware deployment
- **Implementation Details**: Migrated all system defaults from `configuration.nix` to `macos-defaults.nix` for better organization

### Epic-04 Completed Stories (18/18) ✅ EPIC COMPLETE!

| Story ID | Story Name | Points | Status | Branch | Date Completed |
|----------|------------|--------|--------|--------|----------------|
| 04.1-001 | Zsh Shell Configuration | 5 | ✅ Complete | main | 2025-12-05 |
| 04.1-002 | Oh My Zsh Installation and Plugin Configuration | 8 | ✅ Complete | main | 2025-12-05 |
| 04.1-003 | Zsh Environment and Options | 5 | ✅ Complete | main | 2025-12-05 |
| 04.2-001 | Starship Prompt Installation and Configuration | 5 | ✅ Complete | main | 2025-12-05 |
| 04.3-001 | FZF Installation and Keybindings | 5 | ✅ Complete | main | 2025-12-05 |
| 04.4-001 | Ghostty Configuration Integration | 5 | ✅ Complete | main | 2025-12-05 |
| 04.5-001 | Core Nix Aliases | 5 | ✅ Complete | main | 2025-12-05 |
| 04.5-002 | General Shell Aliases | 5 | ✅ Complete | main | 2025-12-05 |
| 04.5-003 | Modern CLI Tool Replacements | 8 | ✅ Complete | main | 2025-12-05 |
| 04.6-001 | Git User Configuration | 5 | ✅ Complete | main | 2025-12-05 |
| 04.6-002 | Git LFS Configuration | 5 | ✅ Complete | main | 2025-12-05 |
| 04.6-003 | Git SSH Configuration | 8 | ✅ Complete | main | 2025-12-05 |
| 04.7-001 | Python and uv Configuration | 8 | ✅ Complete | main | 2025-12-05 |
| 04.7-002 | Python Dev Tools Configuration | 5 | ✅ Complete | main | 2025-12-05 |
| 04.8-001 | Podman Machine Initialization | 8 | ✅ Complete | main | 2025-12-05 |
| 04.8-002 | Podman Aliases and Docker Compatibility | 5 | ✅ Complete | main | 2025-12-05 |
| 04.9-001 | Zed Editor Theming | 1 | ✅ Complete | Epic-02 | 2025-11-12 |
| 04.9-002 | VSCode Configuration | 1 | ✅ Complete | Epic-02 | 2025-11-12 |

**Notes**:
- **2025-12-05**: Features 04.1, 04.2, 04.3, 04.4, and 04.5 **HARDWARE TESTED** ✅
  - Story 04.1-001: Zsh shell with history, completion, session variables ✅ Hardware Tested
  - Story 04.1-002: Oh My Zsh with git plugin, autosuggestions, syntax highlighting ✅ Hardware Tested
  - Story 04.1-003: Shell options (AUTO_PUSHD, EXTENDED_GLOB, etc.) and PATH setup ✅ Hardware Tested
  - Story 04.2-001: Starship prompt with Nerd Font icons, git status, 2-line format ✅ Hardware Tested
  - Story 04.3-001: FZF via Home Manager programs.fzf (not Oh My Zsh plugin) ✅ Hardware Tested
  - Story 04.4-001: Ghostty config symlinked to repo (REQ-NFR-008 compliant) ✅ Hardware Tested
  - Story 04.5-001: Core Nix aliases (rebuild, update, gc, cleanup) ✅ Code Complete
  - Story 04.5-002: General aliases (ll, la, .., ...) ✅ Code Complete
  - Story 04.5-003: Modern CLI tools (ripgrep, bat, eza, zoxide, httpie, tldr) ✅ Code Complete
  - Story 04.6-001: Git user config (name, email from user-config.nix) ✅ Code Complete
  - Story 04.6-002: Git LFS enabled via Home Manager ✅ Code Complete
  - Story 04.6-003: SSH config with macOS Keychain integration ✅ Code Complete
  - Story 04.7-001: Python and uv configuration with environment variables ✅ Code Complete
  - Story 04.7-002: Python dev tools with shell aliases ✅ Code Complete
  - Story 04.8-001: Podman machine initialization with guidance ✅ Code Complete
  - Story 04.8-002: Docker → Podman aliases and container workflow shortcuts ✅ Code Complete
  - Story 04.9-001: Zed editor theming (already implemented in Epic-02) ✅ Code Complete
  - Story 04.9-002: VSCode configuration (already implemented in Epic-02) ✅ Code Complete
  - **Hotfix #19**: Fixed .zshrc conflict and FZF plugin path error (documented in hotfixes.md)
  - **Technical Notes**:
    - Home Manager's programs.fzf preferred over Oh My Zsh fzf plugin (handles Nix paths correctly)
    - Starship os.symbols must be nested inside os block (not separate key)
    - Bootstrap Phase 8 now backs up and removes existing .zshrc before rebuild
    - fzf, fd, starship, ripgrep, bat, eza, zoxide, httpie, tldr installed via Nix
    - Legacy tools accessible via oldgrep, oldcat, oldfind, oldls aliases
    - FZF enhanced with bat preview for files, eza preview for directories

### Overall Project Status

- **Total Project Scope**: 116 stories, 608 story points
- **Completed**: 81 stories (69.8%), 431 points (70.9%)
- **In Progress**:
  - Epic-01 Bootstrap & Installation (89.5% complete by stories, 92.0% by points) - **FUNCTIONAL** 🟢
  - **Epic-02 Application Installation (100% complete)** - ✅ **COMPLETE**
  - **Epic-03 System Configuration (100% complete)** - ✅ **COMPLETE**
  - **Epic-04 Development Environment (100% complete)** - ✅ **COMPLETE**
  - **Epic-05 Theming & Visual Consistency (100% complete)** - ✅ **COMPLETE** 🎉
- **Current Phase**: Phase 6-8 (Theming, Monitoring, Docs, Week 5-6)
- **Next Stories**:
  - **Epic-06: Maintenance & Monitoring (0% complete)** - Next epic
    - ⚪ Feature 06.1: Nix Store Maintenance
    - ⚪ Feature 06.2: System Health Monitoring
    - ⚪ Feature 06.3: Garbage Collection Automation
  - Epic-01: 01.1-003 (Progress Indicators - P1 optional), 01.1-004 (Modular Bootstrap - P1 deferred)
- **Recent Milestone**: 🎉 **EPIC-05 COMPLETE!** 81/116 stories, 431/608 points (70.9%)

### Recent Activity

- **2025-12-06**: 🎉 **EPIC-05 THEMING & VISUAL CONSISTENCY - 100% COMPLETE!** (81/116 stories, 431/608 points)
  - **All Features VM TESTED by FX** ✅
    - ✅ Feature 05.1: Stylix Theme Configuration (2 stories, 13 pts) - **VM TESTED**
    - ✅ Feature 05.2: Nerd Font Configuration (2 stories, 10 pts) - **VM TESTED**
    - ✅ Feature 05.3: App-Specific Theming (2 stories, 10 pts) - **VM TESTED**
    - ✅ Feature 05.4: Theme Verification (1 story, 3 pts) - **VM TESTED**
  - **Key Results**:
    - Catppuccin Mocha (dark) and Latte (light) themes working
    - Auto-switching with macOS appearance confirmed
    - JetBrains Mono Nerd Font with ligatures working
    - Ghostty and Zed colors match (visual consistency verified)
  - **Architecture Decision**: Native app theming (not Stylix polarity switching)
    - Stylix doesn't support dynamic polarity switching without rebuild
    - Ghostty and Zed use their native auto-switching capabilities
    - Best user experience - instant theme switching
  - **Epic-05 Progress**: 100% complete (7/7 stories, 36/36 pts) 🎉
  - **Five Epics Now Complete**: Epic-01 (Functional), Epic-02, Epic-03, Epic-04, Epic-05
  - **Next Epic**: Epic-06 (Maintenance & Monitoring) - 10 stories, 55 pts
- **2025-12-06**: 🔄 **EPIC-05 THEMING & VISUAL CONSISTENCY - 50% COMPLETE!** (78/117 stories, 418/614 points)
  - **Feature 05.1 (Stylix System Configuration) COMPLETE** ✅
    - ✅ Story 05.1-001: Stylix Installation and Base16 Scheme (8 pts)
      - Created dedicated `darwin/stylix.nix` module
      - Catppuccin Mocha as base16 scheme with `polarity = "dark"`
      - Custom wallpaper from `wallpaper/Ropey_Photo_by_Bob_Farrell.jpg`
      - Emoji font: Noto Color Emoji
    - ✅ Story 05.1-002: Auto Light/Dark Mode Switching (5 pts)
      - **Key Discovery**: Stylix doesn't support dynamic polarity switching ([Issue #447](https://github.com/danth/stylix/issues/447))
      - **Solution**: Native app support (Ghostty, Zed have built-in auto-switching)
      - Ghostty: `theme = "light:Catppuccin Latte,dark:Catppuccin Mocha"`
      - Zed: `theme.mode = "system"` with light/dark variants
  - **Feature 05.2 (Font Configuration) COMPLETE** ✅
    - ✅ Story 05.2-001: JetBrains Mono Nerd Font Installation (5 pts)
      - `pkgs.nerd-fonts.jetbrains-mono` in Stylix fonts.monospace
      - Inter for sans-serif, Source Serif 4 for serif
      - Font sizes: terminal=12, applications=11, desktop=10, popups=10
    - ✅ Story 05.2-002: Font Ligature Configuration (5 pts)
      - Ghostty: `font-feature = +liga, +calt, +dlig`
      - Zed: `buffer_font_features.calt = true`
  - **Files Created/Modified**:
    - NEW: `darwin/stylix.nix` - Dedicated Stylix configuration module
    - MODIFIED: `flake.nix` - Added `./darwin/stylix.nix` to commonModules
    - MODIFIED: `darwin/configuration.nix` - Removed inline Stylix config
    - MODIFIED: `bootstrap.sh` - Added `darwin/stylix.nix` and wallpaper to Phase 4
  - **Build Verification**: `nix flake check` PASSED, both profiles build successfully
  - **Epic-05 Progress**: 50% complete (4/8 stories, 23/42 pts)
  - **Next**: Feature 05.3 (App-Specific Theming) - 3 stories, 11 pts
- **2025-12-05**: 🎉 **EPIC-04 DEVELOPMENT ENVIRONMENT - 100% COMPLETE!** (74/117 stories, 395/614 points)
  - **Feature 04.9 (Editor Configuration) COMPLETE** ✅
    - ✅ Story 04.9-001: Zed Editor Theming (1 pt) - Already implemented in Epic-02
      - Catppuccin Latte/Mocha with system mode
      - JetBrains Mono Nerd Font with ligatures
      - Auto-update disabled, bidirectional sync
    - ✅ Story 04.9-002: VSCode Configuration (1 pt) - Already implemented in Epic-02
      - Catppuccin with Auto Dark Mode extension
      - JetBrains Mono font, auto-update disabled
      - Extension auto-installation on rebuild
  - **EPIC-04 COMPLETE**: 18/18 stories, 97/97 pts 🎉
  - **Four Epics Now Complete**: Epic-01 (Functional), Epic-02, Epic-03, Epic-04
  - **Next Epic**: Epic-05 (Theming & Visual Consistency) - 8 stories, 42 pts
- **2025-12-05**: 🎉 **EPIC-04 PROGRESS - 64.0% PROJECT COMPLETE!** (72/117 stories, 393/614 points)
  - **Feature 04.8 (Container Development Environment) COMPLETE** ✅
    - ✅ Story 04.8-001: Podman Machine Initialization (8 pts)
      - Created podman.nix Home Manager module
      - Post-install guidance for machine initialization (idempotent)
      - Machine status detection and startup instructions
    - ✅ Story 04.8-002: Podman Aliases and Docker Compatibility (5 pts)
      - Docker compatibility: docker → podman, docker-compose → podman-compose
      - Container workflow aliases: dps, dpsa, dim, dex, dlogs, dstop, drm, drmi, dprune
      - Podman machine management: pmstart, pmstop, pmstatus
      - Quick execution: drun, dalpine
  - **Epic-04 Progress**: 88.9% complete (16/18 stories, 95/97 pts)
  - **Next**: Feature 04.9 (Editor Configuration) - 2 stories, 2 pts
- **2025-12-05**: 🎉 **EPIC-04 PROGRESS - 61.9% PROJECT COMPLETE!** (70/117 stories, 380/614 points)
  - **Feature 04.7 (Python Development Environment) COMPLETE** ✅
    - ✅ Story 04.7-001: Python and uv Configuration (8 pts)
      - Created python.nix Home Manager module
      - Environment variables: PYTHONDONTWRITEBYTECODE, PYTHONUNBUFFERED, UV_SYSTEM_PYTHON, UV_NATIVE_TLS
      - Enabled direnv with nix-direnv for per-project environments
    - ✅ Story 04.7-002: Python Dev Tools Configuration (5 pts)
      - Added uv workflow aliases: uvnew, uvrun, uvsync, uvadd, uvremove, uvlock, uvtree
      - Quick Python execution: py (uv run python), ipy (interactive)
      - Linting/formatting aliases: lint, lintfix, fmt, fmtcheck, typecheck, sortimports
      - Combined QA commands: qa (full check), fix (auto-fix all)
      - Virtual environment shortcuts: venv, activate
  - **Epic-04 Progress**: 77.8% complete (14/18 stories, 82/97 pts)
  - **Next**: Feature 04.8 (Container Development Environment) - 2 stories, 11 pts
- **2025-12-05**: 🎉 **EPIC-04 PROGRESS - 59.8% PROJECT COMPLETE!** (68/117 stories, 367/614 points)
  - **Feature 04.6 (Git Configuration) COMPLETE** ✅
    - ✅ Story 04.6-001: Git User Configuration (5 pts) - user identity from user-config.nix
    - ✅ Story 04.6-002: Git LFS Configuration (5 pts) - enabled via Home Manager
    - ✅ Story 04.6-003: Git SSH Configuration (8 pts) - macOS Keychain integration
  - **Epic-04 Progress**: 66.7% complete (12/18 stories, 69/97 pts)
  - **Next**: Feature 04.7 (Python Development Environment) - 2 stories, 8 pts
- **2025-12-05**: 🎉 **EPIC-04 PROGRESS - 56.8% PROJECT COMPLETE!** (65/117 stories, 349/614 points)
  - **Feature 04.4 (Ghostty) and Feature 04.5 (Shell Aliases) COMPLETE** ✅
    - ✅ Feature 04.4: Ghostty Terminal Configuration (1 story, 5 pts) - REQ-NFR-008 compliant
    - ✅ Feature 04.5: Shell Aliases and Modern CLI Tools (3 stories, 18 pts)
      - Installed: ripgrep, bat, eza, zoxide, httpie, tldr
      - Aliased: grep→rg, cat→bat, find→fd, ls→eza
      - FZF enhanced with bat preview for files, eza preview for directories
      - Zoxide initialized for frecency-based directory jumping
  - **Hotfix**: Fixed Starship Nerd Font icons (Apple, Linux, Windows symbols restored)
  - **Epic-04 Progress**: 50% complete (9/18 stories, 51/97 pts)
  - **Next**: Feature 04.6 (Git Configuration) - 4 stories, 17 pts
- **2025-12-05**: 🎉 **EPIC-04 PROGRESS - 53% PROJECT COMPLETE!** (61/117 stories, 326/614 points - 53.1%)
  - **Features 04.1, 04.2, and 04.3 HARDWARE TESTED** ✅
    - ✅ Feature 04.1: Zsh and Oh My Zsh Configuration (3 stories, 18 pts)
    - ✅ Feature 04.2: Starship Prompt Configuration (1 story, 5 pts)
    - ✅ Feature 04.3: FZF Fuzzy Finder Integration (1 story, 5 pts)
  - **Hotfix #19**: Fixed Home Manager .zshrc conflict and FZF plugin path error
- **2025-12-05**: 🎉 **EPIC-03 SYSTEM CONFIGURATION - 100% COMPLETE!** (14/14 stories, 76/76 points)
  - **All Features VM Tested by FX** ✅
    - ✅ Feature 03.1: Finder Configuration (3 stories, 18 pts)
    - ✅ Feature 03.2: Security Configuration (3 stories, 18 pts)
    - ✅ Feature 03.3: Trackpad and Input (2 stories, 13 pts)
    - ✅ Feature 03.4: Display and Appearance (2 stories, 10 pts)
    - ✅ Feature 03.5: Keyboard and Text Input (1 story, 5 pts)
    - ✅ Feature 03.6: Dock Configuration (1 story, 4 pts)
    - ✅ Feature 03.7: Time Machine (2 stories, 8 pts)
  - **Story 03.7-002**: Time Machine Destination Setup Prompt ✅ Complete (3 pts)
  - **Three Epics Now Complete**: Epic-01 (Functional), Epic-02 (Complete), Epic-03 (Complete)
  - **Overall Progress**: 47.9% complete (56/117 stories, 298/614 points)
  - **Next Epic**: Epic-04 Development Environment (18 stories, 97 pts)
- **2025-12-04**: ✅ **STORY 03.7-001 COMPLETE!** Time Machine Preferences & Exclusions - 5 points
  - **Story 03.7-001**: Time Machine configuration via activation script ✅ Hardware Tested
    - DoNotOfferNewDisksForBackup preference set (no annoying prompts)
    - /nix excluded from backups (~20-50GB saved)
    - User caches excluded (~/Library/Caches, Homebrew, npm, yarn, pip, uv)
    - Trash, Downloads, and system temp files excluded
    - All exclusions persist across rebuilds via `tmutil addexclusion -p`
  - **Story 03.7-002**: Bootstrap destination prompt **DEFERRED** (optional feature)
  - **Epic-03 Progress**: 92.9% complete (13/14 stories, 73/76 points)
  - **Overall Progress**: 47.0% complete (55/117 stories, 295/614 points)
- **2025-12-04**: ✅ **FEATURE 03.6 COMPLETE!** Dock Configuration - 1 story, 4 points
  - **Story 03.6-001**: Dock behavior and apps ✅ Hardware Tested
    - Minimize windows into app icon (minimize-to-application = true)
    - Auto-hide enabled with instant show (autohide = true, delay = 0)
    - Fast hide animation (autohide-time-modifier = 0.2)
    - Dock at bottom, 48px icons, no magnification
    - Scale minimize effect (faster than genie)
    - Launch animation disabled, process indicators shown
    - Recent apps hidden, MRU Spaces disabled
  - **All 12 Dock settings verified** via `defaults read com.apple.dock`
  - **Epic-03 Progress**: 85.7% complete (12/14 stories, 68/76 points)
  - **Epic-03 FUNCTIONALLY COMPLETE** - Only Time Machine stories remain (deferred/optional)
  - **Overall Progress**: 46.2% complete (54/117 stories, 290/614 points)
- **2025-12-04**: ✅ **FEATURE 03.5 COMPLETE!** Keyboard and Text Input - 1 story, 5 points
  - **Story 03.5-001**: Keyboard repeat and text corrections ✅ Hardware Tested
    - Fast key repeat (KeyRepeat = 2) and short initial delay (InitialKeyRepeat = 15)
    - All auto-corrections disabled: capitalization, smart quotes, smart dashes, spelling
    - Essential for coding: prevents curly quotes and em dashes breaking code
  - **Epic-03 Progress**: 78.6% complete (11/14 stories, 64/76 points)
  - **Overall Progress**: 45.3% complete (53/117 stories, 286/614 points)
- **2025-12-04**: ✅ **FEATURE 03.3 + 03.4 COMPLETE!** Trackpad/Input and Display/Appearance - 4 stories, 23 points
  - **Story 03.3-001**: Trackpad gestures and speed ✅ Hardware Tested
    - Tap-to-click, three-finger drag, fast tracking speed (3.0), natural scrolling disabled
    - Settings: `system.defaults.trackpad`, `NSGlobalDomain."com.apple.trackpad.scaling"`
  - **Story 03.3-002**: Mouse and scroll settings ✅ Hardware Tested
    - Fast mouse speed (3.0), scroll direction standard
    - **Key Finding**: Mouse scaling uses `.GlobalPreferences` domain, not NSGlobalDomain
  - **Story 03.4-001**: Auto Light/Dark mode + 24-hour time ✅ Hardware Tested
    - Auto appearance: `CustomUserPreferences.NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true`
    - 24-hour time: `NSGlobalDomain.AppleICUForce24HourTime = true`
    - Removed forced `AppleInterfaceStyle = "Dark"` to allow auto switching
  - **Story 03.4-002**: Night Shift scheduling ✅ Documented
    - **Known Limitation**: CoreBrightness domain requires manual configuration
    - Manual setup: System Settings → Displays → Night Shift → Schedule: "Sunset to Sunrise"
  - **Epic-03 Progress**: 71.4% complete (10/14 stories, 59/76 points)
  - **Overall Progress**: 44.4% complete (52/117 stories, 281/614 points)
- **2025-12-04**: ✅ **FEATURE 03.1 + 03.2 COMPLETE!** Finder and Security Configuration - 6 stories, 36 points
  - **nix-darwin flake update**: Updated nixpkgs, home-manager, stylix, claude-code-nix, mcp-servers-nix
  - **Breaking changes fixed**:
    - `WarnOnEmptyTrash` removed from nix-darwin (Dec 2025)
    - `NewWindowTarget` syntax changed from `"PfHm"` to `"Home"`
    - `users.users.fxmartin.uid` now required by home-manager
    - `system.defaults.alf.*` migrated to `networking.applicationFirewall.*`
    - `stylix.enableReleaseChecks = false` added to suppress version mismatch warnings
  - **Story 03.1-002**: Finder behavior (folders first, search scope) ✅ VM Tested
  - **Story 03.1-003**: Finder sidebar/desktop (new window target, drives on desktop) ✅ VM Tested
  - **Story 03.2-001**: Firewall with stealth mode ✅ VM Tested
  - **Story 03.2-002**: FileVault encryption prompt in bootstrap ✅ Implemented
  - **Story 03.2-003**: Screen lock (Touch ID sudo, guest disabled) ✅ VM Tested
    - **Known Limitation**: `askForPasswordDelay` deprecated by Apple - manual config required
- **2025-11-19**: ✅ **STORY 03.1-001 COMPLETE!** Finder View and Display Settings - **VM TESTED & MERGED** (5 points)
  - **All 8 VM test cases PASSED** ✅
    - Build and switch succeeded
    - List view default confirmed
    - Path bar visible at bottom of Finder
    - Status bar showing item count and space info
    - Hidden files (.dotfiles) visible in Home directory
    - File extensions shown for all files
    - Settings persisted after `killall Finder`
    - Settings persisted after system reboot
  - **Testing Environment**: macOS VM (Parallels), Standard profile
  - **Testing Date**: 2025-11-19
  - **Conclusion**: Ready for physical hardware deployment
  - Branch `feature/03.1-001-finder-view-settings` merged to main and deleted
  - **Next Story**: 03.1-002 (Finder Behavior Settings - 5 points) 🎯
- **2025-11-17**: 🚀 **EPIC-03 STARTED!** Story 03.1-001 (Finder View and Display Settings) code complete - Ready for VM testing (5 points)
  - Migrated all system defaults from `configuration.nix` to `macos-defaults.nix` for better organization
  - Implemented 5 Finder view settings: list view, path bar, status bar, hidden files, file extensions
  - Created comprehensive VM testing guide with 9 test scenarios
  - Branch: `feature/03.1-001-finder-view-settings` (commit: fc2beaa)
- **2025-11-17**: 🎉 **EPIC-02 APPLICATION INSTALLATION - 100% COMPLETE!** (25/25 stories, 118/118 points)
  - Final 3 stories marked complete: 02.4-004 (Dropbox), 02.7-001 (NordVPN), 02.9-001 (Office 365)
  - All applications VM tested and documented ✅
  - **Dropbox**: Cloud storage with account sign-in, auto-update disabled, file sync validated
  - **NordVPN**: VPN service with subscription sign-in, Network Extension permission, kill switch enabled
  - **Office 365**: Complete productivity suite (Word, Excel, PowerPoint, Outlook, OneNote, Teams) with one-time activation
  - **Epic-02 Achievement**: 47+ apps on Standard profile, 51+ apps on Power profile
  - **Overall Project Progress**: 36.5% complete (42/115 stories, 220/606 points)
  - **Next Epic**: Epic-03 System Configuration (14 stories, 76 points) 🚀
  - Story 02.10-001 (Email Configuration) remains **CANCELLED** - manual setup documented
- **2025-11-16**: 📝 **Feature 03.7 CREATED** - Time Machine Backup Configuration (2 stories, 8 points)
  - Story 03.7-001: Time Machine Preferences & Exclusions (5 points)
  - Story 03.7-002: Time Machine Destination Setup Prompt (3 points)
  - Epic-03 increased from 12 stories/68 points to 14 stories/76 points
  - Total project scope: 117 stories, 614 story points
  - Smart exclusions: /nix, caches, trash, downloads, temp directories
  - Bootstrap prompt for optional backup destination configuration
- **2025-01-16**: 🎉 **Stories 02.4-004, 02.7-001, 02.9-001 VM TESTED COMPLETE** - Dropbox, NordVPN, Office 365 (13 points)
  - **Story 02.4-004**: Dropbox cloud storage ✅ VM tested and validated
    - Account sign-in working (Dropbox account required - free or paid)
    - Auto-update disabled successfully (Account → Updates unchecked)
    - File sync validated (local → cloud and cloud → local)
    - Menubar icon sync status indicators working
    - Selective Sync functional
    - All acceptance criteria met
  - **Story 02.7-001**: NordVPN security ✅ VM tested and validated
    - Subscription sign-in working (NordVPN account required - NO free tier)
    - Network Extension permission granted successfully
    - Quick Connect validated (auto-selects best server)
    - Server selection working (59+ countries, 5,000+ servers)
    - Kill Switch enabled and functional
    - Auto-Connect configured (Wi-Fi mode tested)
    - CyberSec/Threat Protection working
    - Auto-update setting researched and documented
    - All acceptance criteria met
  - **Story 02.9-001**: Office 365 suite ✅ VM tested and validated
    - All 6 apps installed (Word, Excel, PowerPoint, Outlook, OneNote, Teams)
    - One-time sign-in working (activates ALL apps automatically)
    - Microsoft account authentication successful (email + password + 2FA)
    - Auto-update disable validated (EACH app separately - 6 times)
    - OneDrive sync working
    - All apps launch and function correctly
    - All acceptance criteria met
  - **Epic-02 Progress**: 96.0% complete (24/25 stories, 116/118 points)
  - **Overall Project**: 35.7% complete (41/115 stories, 220/606 points)
  - **MILESTONE**: Only 1 Epic-02 story remaining (02.10-001 Email Configuration - 5 pts)

- **2025-01-16**: 🎉 **Story 02.8-001 COMPLETED** - Parallels Desktop (Power Profile Only) (8 points)
  - **Story 02.8-001**: Parallels Desktop installation ✅ VM tested and validated
  - Profile-specific installation (Power only, NOT Standard)
  - **CRITICAL FINDING**: Terminal requires Full Disk Access (FDA) for Parallels installation
  - Implemented FDA check in bootstrap.sh Phase 2 (Power profile only)
  - Comprehensive documentation (~1,300 lines) covering installation, licensing, VM creation, troubleshooting
  - FDA requirement documented in REQUIREMENTS.md, bootstrap flow diagram updated
  - Bootstrap now checks terminal FDA after profile selection, terminates gracefully if missing
  - Clear step-by-step instructions for granting FDA and relaunching terminal

- **2025-01-16**: 🎉 **Story 02.4-006 COMPLETED** - System Monitoring (gotop, iStat Menus, macmon) (5 points)
  - **Story 02.4-006**: System monitoring tools ✅ VM tested and validated
  - Installed via mixed methods: Nix (gotop, macmon) + Homebrew (iStat Menus)
  - Comprehensive documentation (~670 lines total) covering all three monitoring tools
  - **gotop** (~150 lines): Interactive CLI system monitor with TUI
    - Features: CPU, memory, disk I/O, network, temperature, processes
    - Usage: Launch with `gotop`, keybindings for sorting/filtering
    - No auto-update mechanism (Nix-controlled)
  - **macmon** (~100 lines): macOS system monitoring CLI tool
    - Features: Hardware specs, sensors, battery health, network info
    - Usage: `macmon` for quick system check, scriptable output
    - No auto-update mechanism (Nix-controlled)
  - **iStat Menus** (~275 lines): Professional menubar system monitoring (LICENSED APP)
    - **Auto-Update Disable (CRITICAL)**: Preferences → General → Updates → Uncheck "Automatically check for updates"
    - License: 14-day free trial (no credit card), $11.99 USD for license
    - Trial activation: Click "Start Free Trial" → Menubar icons appear immediately
    - Core features: CPU, memory, disk, network, sensors, battery monitoring in menubar
    - Configuration: Customize which sensors appear, update intervals, alert thresholds
    - Permissions: Accessibility (for system monitoring - safe to approve)
  - **licensed-apps.md updated** (~145 lines):
    - iStat Menus section with trial/purchase workflows
    - Auto-update disable instructions (step-by-step with verification)
    - License benefits (lifetime, multi-Mac, offline activation)
    - Common issues and troubleshooting
  - All 68 VM test items passed ✅ (25 gotop + 14 macmon + 29 iStat Menus)
  - Auto-update successfully disabled for iStat Menus ✅
  - Trial activation working (no credit card required) ✅
  - All three tools launch and function correctly ✅
  - **Feature 02.4 Progress**: 89% complete (6/7 stories, 24/27 points)
  - **Epic-02 Progress**: 84.0% complete (21/25 stories, 95/118 points)
  - **Overall Project**: 33.0% complete (38/115 stories, 199/606 points)

- **2025-01-15**: 🎉 **Story 02.5-002 COMPLETED** - Zoom and Webex Installation (5 points)
  - **Story 02.5-002**: Video conferencing apps (Zoom + Webex) ✅ VM tested and validated
  - **Epic-02 Batch 1 (Quick Wins) COMPLETE**: 4 stories, 14 points (Raycast, 1Password, File Utilities, Zoom/Webex)
  - Installed via Homebrew Casks: `zoom`, `webex`
  - Comprehensive documentation (~609 lines total) for both video conferencing platforms
  - **Zoom** (~302 lines): Full-featured video conferencing with free and paid options
    - **Auto-Update Disable (CRITICAL)**: Settings → General → Uncheck "Update Zoom automatically when connected to Wi-Fi"
    - Account options: Free account (40-min group limit), Licensed ($149.90+/year), Guest mode (no account)
    - Core features: HD video, gallery/speaker view, screen sharing, breakout rooms, recording, chat, reactions
    - Permissions: Microphone, camera, screen recording, accessibility (optional), notifications
    - Detailed usage examples: Joining meetings, hosting, screen sharing, chat, recording
    - 15+ keyboard shortcuts, troubleshooting guide for common issues
  - **Webex** (~307 lines): Enterprise video conferencing with company or free account
    - **Auto-Update Disable (IF AVAILABLE)**: Preferences → General/Updates → Disable if not IT-managed
    - Account requirement: No guest mode - company account, free account, or paid plan required
    - Free account: 50-min limit, 100 participants; Paid: $14.50+/month for unlimited
    - Core features: HD video, whiteboard, polling, Q&A, breakout sessions, noise removal, cloud recording
    - Permissions: Microphone, camera, screen recording, accessibility (optional), notifications
    - Detailed usage examples: Joining, hosting, screen sharing, whiteboard, chat, reactions
    - 8+ keyboard shortcuts, troubleshooting including SSO/VPN issues
  - **NEW FILE: docs/licensed-apps.md** (~400 lines):
    - Comprehensive licensed app activation and sign-in guide
    - Video Conferencing Apps section: Zoom and Webex activation steps
    - Zoom: Free vs. licensed account setup, license verification, common issues
    - Webex: Company SSO, free account signup, paid plan activation, troubleshooting
    - Productivity & Security Apps: 1Password, Office 365 activation (existing apps)
    - Summary table comparing all licensed apps (cost, account types, activation)
  - All 28 VM test items added to epic-02-feature-02.5.md covering both apps
  - Epic-02 progress: 20/25 stories (80.0%), 90/118 points (76.3%)

- **2025-01-15**: 🎉 **Story 02.6-001 COMPLETED** - VLC and GIMP Installation (3 points)
  - **Story 02.6-001**: VLC media player and GIMP image editor ✅ VM tested and validated
  - Installed via Homebrew Casks: `vlc`, `gimp`
  - Comprehensive documentation (~590 lines total) covering both applications
  - **VLC Media Player** (~275 lines): Universal media player supporting 100+ formats
    - **Auto-Update Disable (CRITICAL)**: Preferences → General → Uncheck "Automatically check for updates"
    - Detailed verification steps to ensure updates controlled via Homebrew only
    - Core features: Universal format support (video, audio, subtitles, DVD/Blu-ray, streaming, playlists)
    - Playback controls: Speed control, frame-by-frame, A-B loop, bookmarks, resume
    - Audio/video adjustments: Volume boost, equalizer, sync, adjustments, deinterlacing
    - Subtitle management: Auto-detection, delay sync, font customization
    - Advanced features: Video conversion, screen recording, audio visualization, screenshots
    - Common use cases: Playing videos/DVDs, loading subtitles, audio/video sync, streaming, default player setup
    - 15 essential keyboard shortcuts documented
    - Configuration tips: Interface, resume playback, file association, performance, subtitle font
    - Troubleshooting guide: Codec issues, subtitles, sync, performance, DVD encryption, streams
    - 14-item testing checklist
  - **GIMP** (~315 lines): Free image editor (Photoshop alternative)
    - **No Auto-Update to Disable**: Open source, Homebrew-controlled (no in-app mechanism)
    - First launch: Interface layout (Toolbox, Canvas, Docks), single-window mode recommended
    - Interface components: Toolbox panel (left), Canvas area (center), Docks panel (right)
    - Core features: Layer management (blend modes, opacity, masks, groups), selection tools (8 tools), painting/drawing (8 tools), filters/effects (40+ filters), color correction (7 tools), text tools
    - File format support: Native XCF, import (PNG, JPG, GIF, BMP, TIFF, PSD, PDF, SVG, WebP), export (PNG, JPEG, GIF, TIFF, PDF, PSD)
    - Common use cases: Photo editing, cropping, resizing, background removal, text addition, color adjustment, new image creation, batch processing
    - Interface customization: Single-window mode, dark theme, toolbox customization, keyboard shortcuts
    - 13 essential keyboard shortcuts documented
    - Learning resources: Built-in help, official tutorials, third-party resources (YouTube, GIMPTalk, books)
    - Troubleshooting guide: Performance, text quality, export issues, layers, color picker, brush problems
    - 15-item testing checklist
  - Testing checklists: 14 items for VLC, 15 items for GIMP
  - 25-item VM testing checklist in epic file (comprehensive validation)
  - **Feature 02.6 Progress**: 1/1 stories complete (3/3 points, 100%)
  - **Epic-02 Progress**: 76.0% complete (19/25 stories, 85/118 points)
  - **Overall Project**: 31.3% complete (36/115 stories, 189/606 points)
- **2025-01-15**: 🎉 **Story 02.5-001 COMPLETED** - WhatsApp Installation (3 points)
  - **Story 02.5-001**: WhatsApp Desktop messaging app ✅ VM tested and validated
  - Installed via Mac App Store (mas) - App ID 310633997
  - Comprehensive documentation (~285 lines) covering QR code linking and full features
  - **QR Code Linking Process** (REQUIRED):
    - WhatsApp Desktop requires linking to WhatsApp on phone
    - No standalone desktop account - Mac app mirrors phone
    - Detailed instructions for iPhone and Android phone linking
    - Multi-device support (up to 4 linked devices simultaneously)
  - **Permissions Documented**:
    - Notifications (required for message alerts)
    - Microphone (optional, for voice calls)
    - Camera (optional, for video calls)
    - Contacts (optional, syncs from phone anyway)
  - **Core Features**: Messaging, media sharing (up to 2GB files), voice/video calls, group chats (up to 1024 members), sync/backup, end-to-end encryption, disappearing messages
  - **Usage Examples**: Sending messages/files, making calls, creating groups, searching, archiving, pinning chats
  - **Troubleshooting Guide**: QR code not scanning, messages not syncing, calls not working, phone connection issues
  - Auto-update controlled by Mac App Store (no in-app setting)
  - No license required (free from Meta, no subscription)
  - 14-item testing checklist in documentation
  - 20-item VM testing checklist in epic file
  - **Feature 02.5 Progress**: 1/2 stories complete (3/8 points, 37.5%)
  - **Epic-02 Progress**: 72.0% complete (18/25 stories, 82/118 points)
  - **Overall Project**: 30.4% complete (35/115 stories, 186/606 points)
- **2025-01-15**: 🎉 **Story 02.4-005 COMPLETED** - System Utilities (Onyx, f.lux) (3 points)
  - **Story 02.4-005**: System maintenance and display color temperature utilities ✅ VM tested and validated
  - Installed via Homebrew Casks: `onyx`, `flux-app`
  - Comprehensive documentation (430+ lines total) covering both applications
  - **Onyx** (204 lines): Free system maintenance and optimization utility
    - EULA and automatic disk verification on first launch (1-2 minutes)
    - 6 tabs: Verification, Maintenance, Cleaning, Utilities, Automation, Info
    - Common use cases: Routine maintenance, cache clearing, fixing "Open With" menu, hidden Finder features, SMART disk health
    - Permission notes: Admin password required for system tasks (expected and safe)
    - Safety assured: Trusted utility since Mac OS X 10.2, developed by Titanium Software
    - No auto-update mechanism (Homebrew-controlled)
  - **f.lux** (223 lines): Free display color temperature adjustment utility
    - Location setup on first launch (auto-detect via Location Services or manual entry)
    - Automatic sunrise/sunset tracking with gradual color transitions (~60 minutes)
    - Color temperature: Daytime 6500K (cool), Nighttime 2700K-4200K (warm, adjustable)
    - Manual override modes: Disable for 1 hour, movie mode (2.5 hours), darkroom mode (extreme red)
    - Custom schedule support for non-standard sleep patterns
    - Permission notes: Location Services (optional but recommended), Accessibility (may be required)
    - Research-based recommendations for better sleep (blue light reduction)
    - No auto-update mechanism (Homebrew-controlled)
  - Testing checklists provided: 13 items for Onyx, 13 items for f.lux, plus permission and functional testing
  - Documentation includes safety notes, configuration tips, and usage examples
  - **Feature 02.4 Progress**: 5/7 stories complete (19/27 points, 70.4%)
  - **Epic-02 Progress**: 68.0% complete (17/25 stories, 79/118 points)
  - **Overall Project**: 29.6% complete (34/115 stories, 183/606 points)
  - Branch: feature/02.4-005-system-utilities
  - Commits: e8598d7, 6015f04
- **2025-01-15**: 🎉 **Story 02.4-003 COMPLETED** - File Utilities (Calibre, Kindle, Keka, Marked 2) (5 points)
  - **Story 02.4-003**: File utilities for ebooks, archives, and Markdown ✅ VM tested and validated
  - Installed via mixed methods: Homebrew (Calibre, Keka) + Mac App Store (Kindle, Marked 2)
  - Comprehensive documentation (~640 lines) covering all 4 applications
  - **Calibre** (~150 lines): Free/open source ebook library manager
    - Auto-update disable: Preferences → Miscellaneous → Uncheck "Automatically check for updates"
    - Features: Library management, format conversion (EPUB/MOBI/PDF), metadata editing, device sync
    - Supported formats: 20+ input, 10+ output
  - **Kindle** (~175 lines): Free Amazon ebook reader
    - Amazon account sign-in required (email, password, 2FA)
    - Auto-update: System-wide Mac App Store control
    - Features: Whispersync cloud sync, X-Ray, notes/highlights, library management
  - **Keka** (~150 lines): Free/open source archive utility
    - File association setup documented (two methods: Keka Preferences batch OR Finder Get Info per-file)
    - Features: Archive creation (7 formats), extraction (20+ formats), password protection (AES-256)
    - No auto-update (Homebrew-controlled)
  - **Marked 2** (~165 lines): Paid ($14.99) Markdown preview and export app
    - Auto-update disable: Preferences → General → Uncheck "Check for updates automatically"
    - System-wide App Store auto-update also disabled
    - Features: Live preview, export to PDF/HTML/RTF/DOCX, custom CSS, MathJax, Mermaid
  - All 40 VM test steps passed ✅
  - All 4 apps launched successfully
  - Auto-update successfully disabled (Calibre, Marked 2, system-wide App Store)
  - Amazon account sign-in working (Kindle)
  - File associations configured (Keka)
  - All core features validated
  - No issues found during VM testing
  - **Feature 02.4 Progress**: 4/7 stories complete (16/27 points, 59.3%)
  - **Epic-02 Progress**: 64.0% complete (16/25 stories, 76/118 points)
  - **Overall Project**: 28.7% complete (33/115 stories, 180/606 points)
  - Commit: 1562738
- **2025-01-15**: 🎉 **Story 02.4-002 COMPLETED** - 1Password Installation (3 points)
  - **Story 02.4-002**: 1Password password manager ✅ VM tested and validated
  - Installed via Homebrew Cask
  - Comprehensive documentation (~305 lines) covering account setup, security, and browser integration
  - Account sign-in process (existing account + new account creation)
  - Auto-update disable instructions (Settings → Advanced → Uncheck "Check for updates automatically")
  - Browser extension setup documented for Safari, Brave, Arc, Firefox
  - Core features: Password management, secure notes, credit cards, identities, document storage, SSH keys, Watchtower security auditing, shared vaults
  - License requirements: Subscription-based ($2.99/month Individual, $4.99/month Families, 14-day free trial)
  - Post-install checklist (11 items) and testing checklist (11 items)
  - Troubleshooting guide (4 common issues)
  - All 24 VM test steps passed ✅
  - Touch ID setup and unlock working perfectly
  - Browser extensions working in Safari, Brave, Arc
  - Password autofill and generation tested successfully
  - Menubar quick access working
  - Watchtower security monitoring active
  - All core features validated
  - No issues found during VM testing
  - **Feature 02.4 Progress**: 3/7 stories complete (11/27 points, 40.7%)
  - **Epic-02 Progress**: 60.0% complete (15/25 stories, 71/118 points)
  - **Overall Project**: 27.8% complete (32/115 stories, 175/606 points)
  - Commit: cbdc19f
- **2025-01-15**: 🎉 **Story 02.4-001 COMPLETED** - Raycast Installation (3 points)
  - **Story 02.4-001**: Raycast application launcher ✅ VM tested and validated
  - Installed via Homebrew Cask
  - Comprehensive documentation (~150 lines) with hotkey setup and auto-update disable
  - All core features tested: launcher, clipboard history, window management, calculator, extensions
  - Auto-update successfully disabled (Preferences → Advanced)
  - Hotkey configured (`Option+Space` preserves Spotlight)
  - No license required (free for personal use)
  - **Feature 02.4 Progress**: 2/7 stories complete (8/27 points)
  - **Epic-02 Progress**: 56.0% complete (14/25 stories, 68/118 points)
  - **Overall Project**: 27.0% complete (31/115 stories, 172/606 points)
  - Commits: 18d75b0 (implementation), 380d785 (merge)
- **2025-01-15**: 🎉 **Story 02.4-007 COMPLETED** - Git and Git LFS (5 points)
  - **Story 02.4-007**: Git version control with Git LFS ✅ VM tested and validated
  - Git and Git LFS installed via Nix systemPackages
  - Home Manager module created (home-manager/modules/git.nix)
  - User identity from user-config.nix (fullName, email, githubUsername)
  - Git LFS enabled globally via `lfs.enable = true`
  - Modern `settings` attribute structure (no deprecation warnings)
  - Configuration includes: user identity, default branch (main), macOS Keychain credential helper
  - Global .gitignore patterns (macOS, editors, Nix, language artifacts)
  - Useful aliases (st, co, br, ci, unstage, last, visual)
  - Commits: ffaa1ba (implementation), 755597c (VM testing complete)
- **2025-11-15**: 🎉 **Feature 02.3 COMPLETED** - Browsers (2 stories, 5 points)
  - **Story 02.3-001**: Brave Browser ✅ VM tested and validated
  - **Story 02.3-002**: Arc Browser ✅ VM tested and validated
  - Brave: Privacy-focused with built-in Shields (ad/tracker blocking)
  - Arc: Modern workspace-focused browser with unique features
  - Both installed via Homebrew, updates controlled by nix-darwin
  - **Feature 02.3 Progress**: 100% complete (2/2 stories, 5/5 points)
  - **Epic-02 Progress**: 48.0% complete (12/25 stories, 60/118 points)
  - Commits: f604c12 (Brave), 7a8a8e6 (Arc), 6ea8325 (Feature complete)
- **2025-11-15**: 🎉 **Story 02.2-006 COMPLETED** - Claude Code CLI and MCP Servers (8 points)
  - **Story 02.2-006**: Claude Code CLI with 3 MCP servers ✅ VM tested and validated
  - Installed Claude Code CLI via Nix (sadjow/claude-code-nix)
  - Configured 3 MCP servers: Context7, GitHub, Sequential Thinking
  - Separate configs for Claude Desktop (no GitHub) vs CLI (with GitHub)
  - REQ-NFR-008 compliant: ~/.claude/ symlinked to repository
  - All 3 MCP servers working perfectly in VM
  - **Feature 02.2 Progress**: 100% complete (6/6 stories, 39/39 points)
  - **Epic-02 Progress**: 48.0% complete (12/25 stories, 60/118 points)
  - Commits: d75706e (PR #34), ab24883 (VM testing complete)
- **2025-11-15**: 🎉 **Story 02.2-005 COMPLETED** - Podman and Container Tools (6 points)
  - **Story 02.2-005**: Podman CLI, podman-compose, and Podman Desktop ✅ VM tested and validated
  - All tools installed via Homebrew for GUI integration
  - Comprehensive documentation (240+ lines) with machine initialization guide
  - **Issues Encountered & Resolved**:
    - **Issue #33**: Podman Desktop extension not detected → Moved CLI tools to Homebrew (GUI PATH integration)
    - **Issue #34**: Docker socket error → Added proper initialization flags (--now --rootful=false)
  - **VM Testing**: All manual tests successful (CLI, GUI, containers, compose)
  - **Epic-02 Progress**: 48.0% complete (12/25 stories, 60/118 points)
  - **Overall Project**: 25.2% complete (29/115 stories, 164/606 points)
  - Commits: 8fdf763 (initial), b03bc37 (Homebrew fix), 15648d4 (socket fix), PR #32 merged
- **2025-11-12**: 🎉 **Story 02.2-004 COMPLETED** - Python and Development Tools (5 points)
  - **Story 02.2-004**: Python 3.12 and development tools via Nix ✅ VM tested and validated
  - Added Python 3.12 interpreter to darwin/configuration.nix
  - Added uv (fast Python package installer, 10-100× faster than pip)
  - Added development tools: ruff, black, isort, mypy, pylint
  - Created comprehensive documentation section (150+ lines)
  - All tools globally accessible in PATH
  - Zero configuration required (works out of the box)
  - Update philosophy: nix-darwin controlled (no pip/brew upgrades)
  - **VM Testing**: All manual tests successful - Python, uv, and all dev tools working perfectly
  - **Epic-02 Progress**: 32.0% complete (8/25 stories, 41/118 points)
  - **Overall Project**: 21.7% complete (25/115 stories, 145/606 points)
  - Commit: aa896b1, PR #31 merged
- **2025-11-12**: 🎉 **Story 02.2-003 COMPLETED** - Ghostty Terminal Installation (5 points)
  - **Story 02.2-003**: Ghostty Terminal with REQ-NFR-008 compliant bidirectional sync ✅ VM tested
  - Created home-manager/modules/ghostty.nix (108 lines)
  - Config symlink: ~/.config/ghostty/config → ~/nix-install/config/ghostty/config
  - Catppuccin theme with auto-switching (Latte/Mocha)
  - JetBrains Mono font with ligatures
  - All keybindings, opacity, blur, and shell integration working
  - **Hotfix #17 (Issue #31)**: Bootstrap missing Home Manager modules
    - Added zed.nix, vscode.nix, ghostty.nix to Phase 4 download list
    - Bootstrap was only downloading shell.nix and github.nix
    - Nix build failed with "Path does not exist in Git repository"
    - Fixed and validated in VM
  - **Epic-02 Progress**: 28.0% complete (7/25 stories, 36/118 points)
  - Commits: 7b6bb26, 24fe4c5 (Ghostty), 268060c (Hotfix #17)
- **2025-11-12**: 🎉 **Feature 02.1 & Stories 02.2-001, 02.2-002 COMPLETED** - AI Tools, Zed, and VSCode (6 stories, 31 points)
  - **Story 02.1-001**: Claude Desktop and AI Chat Apps ✅ VM tested
  - **Story 02.1-002**: Ollama Desktop App Installation ✅ VM tested
  - **Story 02.1-003**: Standard Profile Ollama Model (gpt-oss:20b) ✅ VM tested
  - **Story 02.1-004**: Power Profile Additional Ollama Models (4 models, ~90GB) ✅ VM tested
  - **Story 02.2-001**: Zed Editor with Catppuccin theme and bidirectional sync ✅ VM tested
  - **Story 02.2-002**: VSCode with Auto Dark Mode extension and bidirectional sync ✅ VM tested
  - **Hotfix #14**: Made Zed settings path dynamic for custom NIX_INSTALL_DIR support
  - **Issue #26 Resolution**: Zed bidirectional sync (symlink to working directory, not /nix/store)
  - **Issue #28 Resolution**: VSCode auto theme switching (Auto Dark Mode + window.autoDetectColorScheme)
  - **Issue #29 Resolution**: VSCode CLI PATH detection (multi-location fallback)
  - **Epic-02 Progress**: 24.0% complete (6/25 stories, 31/118 points)
  - All stories validated by FX in VM testing on both Standard and Power profiles
  - Commits: 578c13c, f2d10dd, b989484, b719d7e, 6498145, 96d5c98, b932aae (VSCode merge)
- **2025-11-12**: 📝 **Story Updates & Hotfixes** - Configuration enhancements and fresh Mac workarounds
  - **Story 02.10-001 ADDED**: Email Account Configuration (5 points, Feature 02.10)
    - macOS Mail.app automation with 1 Gmail (OAuth) + 4 Gandi.net accounts (password)
    - Configuration via .mobileconfig profiles
    - Epic-02 increased from 22 to 23 stories, 113 to 118 points
  - **Story 02.3-001 UPDATED**: Firefox → Brave browser (privacy-focused, built-in ad blocking)
  - **Story 02.4-003 UPDATED**: Added Marked 2 (Mac App Store, ID: 890031187) for Markdown preview
  - **Story 05.1-001 UPDATED**: Wallpaper configuration added to Stylix setup
    - References wallpaper/Ropey_Photo_by_Bob_Farrell.jpg
    - Applied via Stylix to all desktops/spaces
  - **Story 04.2-001 UPDATED**: Starship prompt configuration adapted from p10k
    - Analyzed config/p10k.zsh (88KB, lean 2-line style)
    - Created config/starship.toml matching p10k layout
    - Features: os_icon, directory, git, comprehensive right prompt (status, duration, languages, cloud, nix_shell)
    - Saved reference files: config/p10k.zsh, config/zshrc, config/zprofile, config/oh-my-zsh-custom/
  - **Hotfix #15 (Issue #25)**: Added `mas` to Homebrew brews list
    - Bootstrap failed on fresh MacBook Pro M3 Max: "mas: command not found"
    - Root cause: mas CLI required for masApps installations but not in brews list
    - Solution: Added "mas" to darwin/homebrew.nix brews array
    - Commit: 6626074
  - **Hotfix #16 (Issue #26)**: Documented fresh Mac Perplexity workaround
    - Error: PKInstallErrorDomain Code=201 - installation service cannot start
    - Root cause: Fresh macOS requires first Mac App Store install to be manual (GUI)
    - Solution: Manual install from App Store (click cloud icon), then mas CLI works
    - Updated docs/apps/ai/ai-llm-tools.md with "Requirement 2: Fresh Machine First-Install"
    - Tested by FX on fresh MacBook Pro M3 Max - workaround successful
    - Commit: cdf75ad
  - **Project Totals Updated**: 113 stories (was 112), 606 points (was 601)
  - Commits: 9e42be0, 76a6bed, a3fc681, d97e4ac, 031f778, 6626074, cdf75ad
- **2025-11-11**: 🎉 **COMPLETED Feature 02.1** (AI & LLM Tools) - All 4 stories CODE COMPLETE!
  - Created feature branch: feature/02.1-001-ai-chat-apps
  - **Story 02.1-001**: Added AI chat apps (Claude, ChatGPT, Perplexity) - 3 points ✅
  - **Story 02.1-002**: Added Ollama Desktop App (changed from CLI to Desktop) - 5 points ✅
  - **Story 02.1-003**: Added Standard profile Ollama model auto-pull (gpt-oss:20b) - 5 points ✅
  - **Story 02.1-004**: Added Power profile Ollama models auto-pull (4 models, ~90GB) - 8 points ✅
  - Created docs/app-post-install-configuration.md (NOTE: This file was later split into organized docs/apps/ structure) for post-install steps
  - **Status**: FEATURE 02.1 COMPLETE (21 points) - Ready for VM testing by FX
  - Epic-02 now **0% complete** (0/22 stories, 0/113 points) but Feature 02.1 done (4 stories, 21 points)
- **2025-11-11**: 🔧 **HOTFIXES #10-#13**: Custom clone location & darwin-rebuild issues - **ALL VM TESTED & VERIFIED** ✅
  - **Hotfix #10 (Issue #16)**: Directory ownership/permission fixes for custom paths (PR #17)
    - Added ownership checks for ~/.config when using custom NIX_INSTALL_DIR
    - Fixed permissions for gh config directory
    - **Result**: Misdiagnosed root cause, didn't solve actual problem
  - **Hotfix #11 (Issue #18)**: Remove programs.gh.settings (PR #19)
    - Identified correct root cause: Home Manager creates read-only symlink to Nix store
    - Removed settings block from home-manager/modules/github.nix
    - Prevents new symlinks but doesn't fix existing systems
    - **Result**: Long-term fix for fresh systems
  - **Hotfix #12 (Issue #20)**: Bootstrap symlink detection (PR #21)
    - Added pre-auth check to detect and remove existing symlinks
    - Complements Hotfix #11 for existing systems with legacy state
    - **Result**: Complete fix for all systems (fresh + existing)
  - **Hotfix #13 (Issue #22)**: darwin-rebuild PATH with sudo (PR #23)
    - Phase 8 failed with "sudo: darwin-rebuild: command not found"
    - Root user doesn't inherit user's PATH
    - Solution: Find full path with `command -v`, execute with absolute path
    - **Result**: Phase 8 now completes successfully
  - **Timeline**: 4 hotfixes in rapid succession, iterative problem solving
  - **Lesson Learned**: Always verify file structure with `ls -la`, avoid assumptions
  - **Bootstrap Status**: ALL phases 1-8 now working! 🎉
  - Commits: 442bbfd, e8846b6, [PR #17], [PR #19], [PR #21], [PR #23]
- **2025-11-11**: ✅ **COMPLETED Story 01.8-001** (Installation Summary & Next Steps - 3 points) - **READY FOR VM TESTING**
  - Added Phase 9 to bootstrap.sh (7 functions, ~242 lines)
  - 54 comprehensive BATS tests (TDD methodology) in tests/09-installation-summary.bats
  - Installation duration tracking and human-readable formatting
  - Comprehensive component summary (Nix, nix-darwin, Home Manager, profile, app count)
  - Numbered next steps with profile-aware messaging
  - Useful command reference (rebuild, update, health-check, cleanup)
  - Manual activation app list (1Password, Office 365, Parallels for Power)
  - Documentation path display
  - Function breakdown:
    - `format_installation_duration()`: Time calculation and formatting (64 lines)
    - `display_installed_components()`: Component summary display (30 lines)
    - `display_next_steps()`: Profile-aware next steps (20 lines)
    - `display_useful_commands()`: Command reference (12 lines)
    - `display_manual_activation_apps()`: Licensed app list (14 lines)
    - `display_documentation_paths()`: Documentation locations (10 lines)
    - `installation_summary_phase()`: Orchestration function (45 lines)
  - **All 54 BATS tests PASSED** ✅
  - Shellcheck validation: **0 errors, 0 warnings** (Phase 9 code) ✅
  - Bash syntax check: **PASSED** ✅
  - Created comprehensive VM testing guide: docs/testing-installation-summary.md (10 scenarios)
  - **Profile-specific content**: Ollama verification for Power profile only
  - **Professional formatting**: Clean banner-based summary display
  - Commit: 32fe3b6 (feature/01.8-001 branch)
  - Epic-01 now **92.0% complete** (104/113 points) 🎉
  - Bootstrap.sh size: 4,222 → 4,506 lines (+284 lines)
  - **BOOTSTRAP SCRIPT NOW FUNCTIONALLY COMPLETE** - All 9 phases implemented! 🚀
- **2025-11-11**: ✅ **COMPLETED Story 01.7-002** (Final Darwin Rebuild - 8 points) - **VM TESTED & VERIFIED**
  - Added Phase 8 to bootstrap.sh (5 functions, ~260 lines)
  - 50 comprehensive BATS tests (TDD methodology) in tests/08-final-darwin-rebuild.bats
  - Profile loading from user-config.nix (standard or power)
  - darwin-rebuild switch execution from cloned repository
  - Home Manager symlink validation (non-critical checks)
  - Comprehensive success message with profile-specific next steps
  - Function breakdown:
    - `load_profile_from_user_config()`: Extract profile value from user-config.nix
    - `run_final_darwin_rebuild()`: Execute darwin-rebuild with sudo
    - `verify_home_manager_symlinks()`: Validate Home Manager symlinks created
    - `display_rebuild_success_message()`: Show next steps and useful commands
    - `final_darwin_rebuild_phase()`: Orchestration function for Phase 8
  - **All 6 VM test scenarios PASSED** ✅
  - **Hotfix #4 (a4a63f5)**: Profile persistence - Added installProfile field to template
  - **Hotfix #5 (ac36f56)**: darwin-rebuild sudo - Added sudo to Phase 8 rebuild command
  - **Hotfix #6 (f5f7ed6)**: Profile extraction regex - Fixed greedy pattern bug
  - **Hotfix #7 (442bbfd)**: Git tracking for flakes - Auto git-add user-config.nix
  - Bash syntax check: **PASSED** ✅
  - Phase execution time: **~180 seconds** ⚡
  - Commits: Initial + 4 hotfixes merged to main
  - Epic-01 now **89.4% complete** (101/113 points) 🎉
  - Bootstrap.sh size: 3,964 → 4,222 lines (+258 lines)
- **2025-11-11**: ✅ **COMPLETED Story 01.7-001** (Full Repository Clone - 5 points) - **VM TESTED & VERIFIED**
  - Added Phase 7 to bootstrap.sh (9 functions, ~400 lines)
  - 118 comprehensive BATS tests (TDD methodology) in tests/bootstrap_repo_clone_test.bats
  - Git clone via SSH to ~/Documents/nix-install with idempotent handling
  - Existing directory detection with interactive prompt (remove/skip)
  - user-config.nix preservation (no overwrite if exists in repo)
  - Repository integrity validation (4-point check: .git, flake.nix, user-config.nix, git status)
  - Disk space check before clone (warns if <500MB available)
  - Function breakdown:
    - `create_documents_directory()`: Ensures ~/Documents exists
    - `check_existing_repo_directory()`: Detects existing repository
    - `prompt_remove_existing_repo()`: Interactive prompt for existing dir
    - `remove_existing_repo_directory()`: Removes existing directory safely
    - `clone_repository()`: Core git clone with disk space check
    - `copy_user_config_to_repo()`: Copies config, preserves existing
    - `verify_repository_clone()`: Multi-point validation
    - `display_clone_success_message()`: Success banner
    - `clone_repository_phase()`: Main orchestration function
  - Created comprehensive VM testing guide: docs/testing-repo-clone-phase.md (8 scenarios)
  - **All 8 VM tests PASSED** ✅
  - **Hotfix #2 (3 commits)**: GitHub CLI availability and permissions
    - **Commit a4e210c**: Moved gh installation from Home Manager to Homebrew (immediate PATH availability)
    - **Commit 4f97c59**: Improved config directory permission handling
    - **Commit aa4f344**: Added PATH update after Phase 5 (eliminates shell reload requirement)
  - Shellcheck validation: **0 errors, 0 warnings** ✅
  - Bash syntax check: **PASSED** ✅
  - Phase execution time: **2 seconds** ⚡
  - Repository cloned to: /Users/fxmartin/Documents/nix-install
  - Commits: a4f161a (initial) + 186b1df + e8846b6 + a4e210c + e577f93 + 4f97c59 + aa4f344 (hotfixes) merged to main
  - Epic-01 now **82.3% complete** (93/113 points) 🎉
  - Bootstrap.sh size: 3518 → 3908 lines (+390 lines)
- **2025-11-11**: ✅ **COMPLETED Story 01.6-003** (GitHub SSH Connection Test - 8 points) - **VM TESTED & VERIFIED**
  - Added Phase 6 (continued) to bootstrap.sh (5 functions, ~234 lines)
  - 80 comprehensive BATS tests (TDD methodology) in tests/bootstrap_ssh_test.bats
  - SSH connection test with `ssh -T git@github.com` (handles exit code 1 = success!)
  - Retry mechanism: Up to 3 attempts with 2-second delays
  - Troubleshooting display: 5 categories of common issues with actionable steps
  - Abort prompt: User choice to continue or abort after 3 failed attempts
  - Function breakdown:
    - `test_github_ssh_connection()`: Core SSH test, username extraction (41 lines)
    - `display_ssh_troubleshooting()`: Formatted help display (35 lines)
    - `retry_ssh_connection()`: 3-attempt retry loop with progress (35 lines)
    - `prompt_continue_without_ssh()`: Interactive abort/continue prompt (42 lines)
    - `test_github_ssh_phase()`: Orchestration function for Phase 6 (continued) (48 lines)
  - Integration: Added to main() flow after upload_github_key_phase() (line 3480)
  - Shellcheck validation: **0 errors, 0 warnings** ✅
  - Bash syntax check: **PASSED** ✅
  - Created comprehensive VM testing guide: docs/testing-ssh-connection-phase.md (7 scenarios)
  - **All 7 VM tests PASSED** ✅
  - Commit df82606 + 39c642e (testing docs) merged to main
  - Epic-01 now **77.9% complete** (88/113 points) 🎉
  - Bootstrap.sh size: 3284 → 3518 lines (+234 lines)
- **2025-11-11**: ✅ **COMPLETED Story 01.6-002** (Automated GitHub SSH Key Upload - 5 points) - **VM TESTED & VERIFIED**
  - Added Phase 6 (continued) to bootstrap.sh (6 functions, ~306 lines with hotfix)
  - 82 comprehensive BATS tests (TDD methodology) + 7 manual VM scenarios
  - OAuth authentication flow via gh auth login --web
  - Automated key upload via gh ssh-key add with idempotency check
  - ~90% automation achieved (user clicks "Authorize" in browser - 10 seconds) ✅
  - Graceful fallback to manual instructions with clipboard copy
  - **Hotfix #1 (aa7d2d6)**: Fixed permission denied error (gh config directory creation)
  - **Commit d8cb577** (initial) + **aa7d2d6** (hotfix) pushed to origin/main
  - **All VM tests PASSED** ✅
  - Epic-01 now **71.4% complete** (75/105 points) 🎉
- **2025-11-10**: ✅ **COMPLETED Story 01.1-002** (Idempotency Check - 3 points) - **VM TESTED & VERIFIED**
  - Added `check_existing_user_config()` function (89 lines) to bootstrap.sh
  - Checks two locations: ~/Documents/nix-install/ (completed) and /tmp/nix-bootstrap/ (previous run)
  - Parses existing user-config.nix and prompts: "Reuse this configuration? (y/n)"
  - Validates parsed values (no placeholders, not empty), falls back gracefully if invalid
  - Skips user prompts if config reused, saving 30-60 seconds per VM testing iteration
  - Based on mlgruby reference pattern (lines 239-289)
  - **All VM tests PASSED**: Fresh install, retry, completed install, corrupted config, user decline scenarios ✅
  - Epic-01 now **74.3% complete** (78/105 points) 🎉
- **2025-11-10**: ✅ **COMPLETED Story 01.6-001** (SSH Key Generation - 5 points) - **VM TESTED & VERIFIED**
  - Added Phase 6 to bootstrap.sh (8 functions, ~420 lines)
  - 100 automated BATS tests (TDD methodology) + 8 manual VM scenarios
  - macOS Keychain integration: ssh-add --apple-use-keychain
  - System ssh-agent usage (launchd-managed)
  - **All 8 manual VM tests PASSED** ✅
  - Hotfix #1 (1e3f9a1): Keychain integration for key persistence
  - Hotfix #2 (1b4429c): System ssh-agent instead of new instance
  - Epic-01 now **71.4% complete** (75/105 points) 🎉
- **2025-11-10**: 📝 **UPDATED Story 01.6-002** (GitHub SSH Key Upload) - **SCOPE CHANGED**
  - Changed from manual upload (8 points) to automated GitHub CLI approach (5 points)
  - Now uses `gh auth login` + `gh ssh-key add` for ~90% automation
  - User interaction reduced from 2-3 minutes to 10 seconds (OAuth click)
  - Epic-01 total: **108 → 105 points** (3-point reduction)
  - Aligns with project goal: "zero manual intervention except license activations"
  - Created home-manager/modules/github.nix for GitHub CLI configuration
  - Updated bootstrap.sh to download github.nix during flake fetch
- **2025-11-10**: 🔧 **HOTFIX**: Issue #10 fixed (nix-daemon detection) - VM TESTED & VERIFIED ✅
  - Added multi-method daemon detection (system domain + process check)
  - Commit ef583a4 pushed and validated
  - Story 01.5-002 now fully complete and VM tested
- **2025-11-10**: ✅ **COMPLETED Story 01.5-002** (Post-Darwin System Validation - 5 points) - **VM TESTED**
  - Added Phase 5 (continued) validation to bootstrap.sh (6 functions, ~310 lines)
  - 60 automated BATS tests (TDD methodology) + 7 manual VM scenarios
  - Validates darwin-rebuild, Homebrew, apps, nix-daemon (CRITICAL vs NON-CRITICAL)
  - Comprehensive error handling with troubleshooting steps
  - Epic-01 now **61.9% complete** (65/105 points) 🎉
- **2025-11-09**: ✅ **COMPLETED Story 01.5-001** (Initial Nix-Darwin Build - 13 points) - **VM TESTED & VALIDATED**
  - Full clean VM test from snapshot: **10 minutes** (within 10-20min estimate!)
  - Standard profile tested and working
  - All acceptance criteria met: darwin-rebuild, Homebrew, experimental features
  - Fixed nix.settings configuration for experimental-features
  - 10 bug fix iterations during VM testing (all resolved)
  - Epic-01 now **62% complete** (67/108 points) 🎉
- **2025-11-09**: ✅ Implemented Story 01.5-001 (Initial Nix-Darwin Build - 13 points)
  - Added Phase 5 to bootstrap.sh (6 functions, ~400 lines)
  - 86 automated BATS tests + 7 manual VM scenarios
- **2025-11-09**: ✅ Completed Story 01.4-003 (Flake Infrastructure Setup - 8 points) - VM TESTED & VALIDATED
  - Created flake.nix with Standard and Power profiles
  - Fixed invalid system.profile bug (commit fca880d)
  - nix flake check: PASSED
  - Both profiles build successfully in dry-run mode
- **2025-11-09**: 📝 Created Story 01.4-003 (Flake Infrastructure Setup - 8 points) - CRITICAL BLOCKER identified and documented
- **2025-11-09**: ✅ Completed Story 01.4-002 (Nix Configuration for macOS) - VM tested, all scenarios passed
- **2025-11-09**: ✅ Completed Story 01.4-001 (Nix Multi-User Installation) - VM tested, all scenarios passed
- **2025-11-09**: ✅ Completed Story 01.3-001 (Xcode CLI Tools) - VM tested, all scenarios passed
- **2025-11-09**: Fixed Xcode test suite (removed obsolete license tests, 58 tests passing)
- **2025-11-09**: Fixed critical bootstrap template file bug (#8)
- **2025-11-09**: Completed Story 01.2-003 (User Config Generation) - VM tested ✅
- **2025-11-09**: Completed Story 01.2-002 (Profile Selection) - VM tested ✅
- **2025-11-09**: Completed Story 01.2-001 (User Prompts) - VM tested ✅
- **2025-11-08**: Completed Story 01.1-001 (Pre-flight Checks) ✅

---

