# ABOUTME: Historical development activity log archived from progress.md
# ABOUTME: Contains detailed story completion notes and testing results from v1.0.0 development

# Development Activity Log Archive

This file contains the detailed development activity log that was previously in `progress.md`.
Archived on 2025-12-07 during documentation compression for v1.0.0 release.

For current project status, see [progress.md](progress.md).
For release notes, see [CHANGELOG.md](../../CHANGELOG.md).

---

## Epic Story Completion Tables

### Epic-01 Completed Stories (18/19)

| Story ID | Story Name | Points | Status | Branch | Date Completed |
|----------|------------|--------|--------|--------|----------------|
| 01.1-001 | Pre-flight Environment Checks | 5 | ✅ Complete | feature/01.1-001 | 2025-11-08 |
| 01.1-002 | Idempotency Check (User Config) | 3 | ✅ Complete | main | 2025-11-10 |
| 01.1-003 | Progress Indicators | 3 | ✅ Complete | main | 2025-12-07 |
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

### Epic-05 Completed Stories (7/7) ✅ EPIC COMPLETE!

| Story ID | Story Name | Points | Status | Branch | Date Completed |
|----------|------------|--------|--------|--------|----------------|
| 05.1-001 | Stylix Installation and Base16 Scheme | 8 | ✅ Complete | main | 2025-12-06 |
| 05.1-002 | Auto Light/Dark Mode Switching | 5 | ✅ Complete | main | 2025-12-06 |
| 05.2-001 | JetBrains Mono Nerd Font Installation | 5 | ✅ Complete | main | 2025-12-06 |
| 05.2-002 | Font Ligature Configuration | 5 | ✅ Complete | main | 2025-12-06 |
| 05.3-001 | Ghostty Theme Integration | 5 | ✅ Complete | main | 2025-12-06 |
| 05.3-002 | Zed Theme Integration | 5 | ✅ Complete | main | 2025-12-06 |
| 05.4-001 | Theme Verification Script | 3 | ✅ Complete | main | 2025-12-06 |

### Epic-06 Completed Stories (18/18) ✅ EPIC COMPLETE!

| Story ID | Story Name | Points | Status | Branch | Date Completed |
|----------|------------|--------|--------|--------|----------------|
| 06.1-001 | Garbage Collection LaunchAgent | 8 | ✅ Complete | main | 2025-12-06 |
| 06.1-002 | Manual Garbage Collection Alias | 5 | ✅ Complete | main | 2025-12-06 |
| 06.1-003 | Garbage Collection Verification | 5 | ✅ Complete | main | 2025-12-06 |
| 06.2-001 | Store Optimization LaunchAgent | 5 | ✅ Complete | main | 2025-12-06 |
| 06.2-002 | Manual Store Optimization Alias | 3 | ✅ Complete | main | 2025-12-06 |
| 06.2-003 | Store Optimization Verification | 3 | ✅ Complete | main | 2025-12-06 |
| 06.3-001 | btop Installation | 3 | ✅ Complete | main | 2025-12-06 |
| 06.3-002 | gotop Installation | 3 | ✅ Complete | main | 2025-12-06 |
| 06.3-003 | macmon Installation | 3 | ✅ Complete | main | 2025-12-06 |
| 06.3-004 | iStat Menus Installation | 5 | ✅ Complete | main | 2025-12-06 |
| 06.4-001 | Health Check Script | 5 | ✅ Complete | main | 2025-12-06 |
| 06.4-002 | Health Check Alias | 3 | ✅ Complete | main | 2025-12-06 |
| 06.5-001 | msmtp Configuration | 8 | ✅ Complete | main | 2025-12-06 |
| 06.5-002 | Notification Script | 5 | ✅ Complete | main | 2025-12-06 |
| 06.5-003 | Weekly Digest LaunchAgent | 3 | ✅ Complete | main | 2025-12-06 |
| 06.6-001 | Release Note Fetcher Script | 5 | ✅ Complete | main | 2025-12-06 |
| 06.6-002 | Claude CLI Analysis Integration | 8 | ✅ Complete | main | 2025-12-06 |
| 06.6-003 | GitHub Issue Creation | 5 | ✅ Complete | main | 2025-12-06 |

### Epic-07 Completed Stories (8/8) ✅ EPIC COMPLETE!

| Story ID | Story Name | Points | Status | Branch | Date Completed |
|----------|------------|--------|--------|--------|----------------|
| 07.1-001 | README Quick Start Guide | 5 | ✅ Complete | main | 2025-12-06 |
| 07.1-002 | Update Philosophy Documentation | 5 | ✅ Complete | main | 2025-12-06 |
| 07.2-001 | Licensed App Documentation | 5 | ✅ Complete | main | 2025-12-06 |
| 07.2-002 | Post-Install Checklist | 3 | ✅ Complete | main | 2025-12-06 |
| 07.3-001 | Common Issues Documentation | 5 | ✅ Complete | main | 2025-12-06 |
| 07.3-002 | Rollback Documentation | 3 | ✅ Complete | main | 2025-12-06 |
| 07.4-001 | Adding Apps Documentation | 5 | ✅ Complete | main | 2025-12-06 |
| 07.4-002 | Configuration Examples | 3 | ✅ Complete | main | 2025-12-06 |

---

## Activity Log (November-December 2025)

### 2025-12-07

- **MAJOR MILESTONE - MACBOOK PRO M3 MAX RUNNING POWER PROFILE!**
  - Bootstrap successfully tested in VM (Standard profile)
  - MacBook Pro M3 Max now running with Power profile
  - All 27 Homebrew dependencies installed (including Parallels - Power only)
  - All 5 Ollama models verified
  - Shell startup: **259ms** (target <500ms) ✅
  - Rebuild time: **14 seconds** (target <5min) ✅
  - NFR completion: 87% (13/15 stories verified)
  - Fixed profile detection in update-system.sh (reads from user-config.nix)
  - Ghostty theme auto-switching working (light/dark mode)
  - **Next**: MacBook Air migrations (Phase 11)

### 2025-12-06

- **FEATURE 07.4 COMPLETE** - Customization Guide (2 stories, 8 pts)
  - Story 07.4-001: Adding Apps Documentation (docs/customization.md)
  - Story 07.4-002: Configuration Examples (4 real-world examples)

- **FEATURE 07.3 COMPLETE** - Troubleshooting Guide (2 stories, 8 pts)
  - Story 07.3-001: Common Issues Documentation (docs/troubleshooting.md, 9 sections, 25+ issues)
  - Story 07.3-002: Rollback Documentation (Section 9 with 6 subsections)

- **FEATURE 07.2 COMPLETE** - Licensed App Activation Guide (2 stories, 8 pts)
  - Story 07.2-001: Licensed App Documentation (enhanced existing)
  - Story 07.2-002: Post-Install Checklist (new docs/post-install.md)

- **FEATURE 07.1 COMPLETE** - Quick Start Documentation (2 stories, 10 pts)
  - Story 07.1-001: README Quick Start Guide
  - Story 07.1-002: Update Philosophy Documentation

- **EPIC-07 COMPLETE** - Documentation & User Experience (8 stories, 34 pts)

- **EPIC-06 COMPLETE** - Maintenance & Monitoring (18 stories, 97 pts)
  - All Features verified in code: GC LaunchAgent, Store Optimization, Monitoring Tools, Health Check, Email, Release Monitor
  - All LaunchAgents in darwin/maintenance.nix
  - All scripts in scripts/ directory

- **FEATURE 06.6 COMPLETE** - Release Monitoring & Improvement Suggestions (5 stories, 26 pts)
  - All 5 scripts created and tested
  - Bug fixed: Deduplication was failing due to truncated search terms
  - Email tested and working via msmtp
  - 11 GitHub issues created for Homebrew, Nix, and Ollama updates

- **EPIC-05 THEMING & VISUAL CONSISTENCY - 100% COMPLETE!**
  - All Features VM TESTED by FX
  - Key Results: Catppuccin themes working, auto-switching confirmed, JetBrains Mono Nerd Font with ligatures
  - Architecture Decision: Native app theming (not Stylix polarity switching)

### 2025-12-05

- **EPIC-04 DEVELOPMENT ENVIRONMENT - 100% COMPLETE!** (18/18 stories, 97/97 points)
  - Feature 04.9 (Editor Configuration) COMPLETE
  - Feature 04.8 (Container Development Environment) COMPLETE
  - Feature 04.7 (Python Development Environment) COMPLETE
  - Feature 04.6 (Git Configuration) COMPLETE
  - Feature 04.4 (Ghostty) and Feature 04.5 (Shell Aliases) COMPLETE
  - Features 04.1, 04.2, and 04.3 HARDWARE TESTED
  - Hotfix #19: Fixed Home Manager .zshrc conflict and FZF plugin path error

- **EPIC-03 SYSTEM CONFIGURATION - 100% COMPLETE!** (14/14 stories, 76/76 points)
  - All Features VM Tested by FX
  - Story 03.7-002: Time Machine Destination Setup Prompt Complete

### 2025-12-04

- **STORY 03.7-001 COMPLETE** - Time Machine Preferences & Exclusions (5 points)
  - DoNotOfferNewDisksForBackup preference set
  - /nix excluded from backups (~20-50GB saved)
  - User caches excluded

- **FEATURE 03.6 COMPLETE** - Dock Configuration (1 story, 4 points)
  - All 12 Dock settings verified

- **FEATURE 03.5 COMPLETE** - Keyboard and Text Input (1 story, 5 points)
  - Fast key repeat, all auto-corrections disabled

- **FEATURE 03.3 + 03.4 COMPLETE** - Trackpad/Input and Display/Appearance (4 stories, 23 points)
  - Known Limitation: CoreBrightness domain requires manual configuration for Night Shift

- **FEATURE 03.1 + 03.2 COMPLETE** - Finder and Security Configuration (6 stories, 36 points)
  - nix-darwin flake update with breaking changes fixed

### 2025-11-19

- **STORY 03.1-001 COMPLETE** - Finder View and Display Settings - VM TESTED & MERGED (5 points)
  - All 8 VM test cases PASSED

### 2025-11-17

- **EPIC-03 STARTED** - Story 03.1-001 code complete
- **EPIC-02 APPLICATION INSTALLATION - 100% COMPLETE!** (25/25 stories, 118/118 points)

### 2025-11-16

- **Feature 03.7 CREATED** - Time Machine Backup Configuration (2 stories, 8 points)
- **Stories 02.4-004, 02.7-001, 02.9-001 VM TESTED** - Dropbox, NordVPN, Office 365
- **Story 02.8-001 COMPLETED** - Parallels Desktop (8 points)
  - CRITICAL FINDING: Terminal requires Full Disk Access for Parallels installation
- **Story 02.4-006 COMPLETED** - System Monitoring (5 points)

### 2025-11-15

- **Story 02.5-002 COMPLETED** - Zoom and Webex Installation (5 points)
- **Story 02.6-001 COMPLETED** - VLC and GIMP Installation (3 points)
- **Story 02.5-001 COMPLETED** - WhatsApp Installation (3 points)
- **Story 02.4-003 COMPLETED** - File Utilities (5 points)
- **Story 02.4-002 COMPLETED** - 1Password Installation (3 points)
- **Story 02.4-001 COMPLETED** - Raycast Installation (3 points)

### 2025-11-12

- **Feature 02.1 (AI & LLM Tools) COMPLETE** - all 4 stories VM tested (16 points)
- **Story 02.2-001 COMPLETE** - Zed Editor (12 points)
- **Story 02.2-002 COMPLETE** - VSCode (3 points)
- **Story 02.2-003 COMPLETE** - Ghostty Terminal (5 points)
- **Story 02.2-004 COMPLETE** - Python & Dev Tools (5 points)

### 2025-11-11

- **Story 01.8-001 COMPLETE** - Installation Summary & Next Steps (3 points)
- **Story 01.7-002 COMPLETE** - Final Darwin Rebuild (8 points)
- **Story 01.7-001 COMPLETE** - Full Repository Clone (5 points)
- **Story 01.6-003 COMPLETE** - GitHub SSH Connection Test (8 points)
- **Story 01.6-002 COMPLETE** - GitHub SSH Key Upload (5 points)

### 2025-11-10

- **Story 01.6-001 COMPLETE** - SSH Key Generation (5 points)
- **Story 01.5-002 COMPLETE** - Post-Darwin System Validation (5 points)
- **Story 01.1-002 COMPLETE** - Idempotency Check (3 points)

### 2025-11-09

- **Story 01.5-001 COMPLETE** - Initial Nix-Darwin Build (13 points)
- **Story 01.4-003 COMPLETE** - Flake Infrastructure Setup (8 points)
- **Story 01.4-002 COMPLETE** - Nix Configuration for macOS (5 points)
- **Story 01.4-001 COMPLETE** - Nix Multi-User Installation (8 points)
- **Story 01.3-001 COMPLETE** - Xcode CLI Tools Installation (5 points)
- **Story 01.2-003 COMPLETE** - User Config File Generation (3 points)
- **Story 01.2-002 COMPLETE** - Profile Selection System (8 points)
- **Story 01.2-001 COMPLETE** - User Information Prompts (5 points)

### 2025-11-08

- **Story 01.1-001 COMPLETE** - Pre-flight Environment Checks (5 points)
- **Project Started** - Initial bootstrap.sh development

---

## Technical Notes

### Key Discoveries During Development

1. **Stylix Limitation**: Doesn't support dynamic polarity switching without rebuild ([Issue #447](https://github.com/danth/stylix/issues/447)). Solution: Use native app auto-switching.

2. **Mouse Scaling**: Uses `.GlobalPreferences` domain, not NSGlobalDomain.

3. **Auto Appearance**: Uses `CustomUserPreferences.NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically`.

4. **Night Shift**: CoreBrightness domain requires manual configuration.

5. **askForPasswordDelay**: Deprecated by Apple since macOS 10.13.

6. **Full Disk Access**: Terminal requires FDA for Parallels Desktop installation (Power profile).

7. **Home Manager FZF**: Use `programs.fzf` instead of Oh My Zsh fzf plugin (handles Nix paths correctly).

8. **Starship Config**: `os.symbols` must be nested inside `os` block, not separate key.

### Breaking Changes Fixed (Dec 2025)

- `WarnOnEmptyTrash` removed from nix-darwin
- `NewWindowTarget` syntax changed from `"PfHm"` to `"Home"`
- `users.users.fxmartin.uid` now required by home-manager
- `system.defaults.alf.*` migrated to `networking.applicationFirewall.*`
- `stylix.enableReleaseChecks = false` added for version mismatch warnings
