# ABOUTME: Epic and story progress tracking for the nix-install project
# ABOUTME: Contains epic overview table, completed stories, and recent activity log

## Epic Overview Progress Table

| Epic ID | Epic Name | Total Stories | Total Points | Completed Stories | Completed Points | % Complete (Stories) | % Complete (Points) | Status |
|---------|-----------|---------------|--------------|-------------------|------------------|---------------------|-------------------|--------|
| **Epic-01** | Bootstrap & Installation System | 19 | 113 | **17** | **104** | 89.5% | 92.0% | 🟢 Functional |
| **Epic-02** | Application Installation | 25 | 118 | **22** | **103** | 88.0% | 87.3% | 🟡 In Progress |
| **Epic-03** | System Configuration | 12 | 68 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **Epic-04** | Development Environment | 18 | 97 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **Epic-05** | Theming & Visual Consistency | 8 | 42 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **Epic-06** | Maintenance & Monitoring | 10 | 55 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **Epic-07** | Documentation & User Experience | 8 | 34 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **NFR** | Non-Functional Requirements | 15 | 79 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **TOTAL** | **All Epics** | **115** | **606** | **39** | **207** | **33.9%** | **34.2%** | 🟡 In Progress |

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

### Epic-02 Completed Stories (22/25)

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

**Notes**:
- **2025-11-12**: Feature 02.1 (AI & LLM Tools) completed - all 4 stories VM tested by FX (16 points)
- **2025-11-12**: Story 02.2-001 (Zed Editor) completed - VM tested by FX, bidirectional sync implemented (12 points)
- **2025-11-12**: Story 02.2-002 (VSCode) completed - VM tested by FX, auto theme switching working (3 points)
- **2025-11-12**: Story 02.2-003 (Ghostty Terminal) completed - VM tested by FX, REQ-NFR-008 compliant config (5 points)
- **2025-11-12**: Story 02.2-004 (Python & Dev Tools) completed - Python 3.12 + uv + dev tools (ruff, black, isort, mypy, pylint) via Nix (5 points) ✅ VM tested
- **2025-11-12**: Epic-02 increased from 23 to 25 stories after story reconciliation (total points unchanged at 118)

### Overall Project Status

- **Total Project Scope**: 115 stories, 606 story points
- **Completed**: 39 stories (33.9%), 207 points (34.2%)
- **In Progress**:
  - Epic-01 Bootstrap & Installation (89.5% complete by stories, 92.0% by points) - **FUNCTIONAL**
  - Epic-02 Application Installation (88.0% complete by stories, 87.3% by points) - **IN PROGRESS**
- **Current Phase**: Phase 3-5 (Applications, System Config, Dev Environment, Week 3-4)
- **Next Stories**:
  - Epic-02: 02.4-004 (Dropbox - 3 pts), 02.7-001 (NordVPN - 5 pts), 02.9-001 (Office 365 - 5 pts), 02.10-001 (Email Config - 5 pts)
  - Epic-01: 01.1-003 (Progress Indicators - P1 optional), 01.1-004 (Modular Bootstrap - P1 deferred)
- **Recent Milestone**: Story 02.8-001 (Parallels Desktop - Power Profile Only) COMPLETE - 8 points, VM tested with FDA requirement documented ✅

### Recent Activity

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

