# ABOUTME: Master index for nix-install development documentation
# ABOUTME: Provides navigation, quick reference, and "what to read first" guidance

# Development Documentation

Welcome to the nix-install development documentation. This directory contains all implementation details, progress tracking, and development workflows.

## 📖 Quick Navigation

### Start Here
- **[progress.md](./progress.md)** - Epic overview, completed stories, recent activity
  - Current project status: **98.4% complete** (122/124 stories, 641/650 points)
  - 🎉 **MILESTONE (2025-12-07)**: MacBook Pro M3 Max successfully running Power profile!
  - 📝 **CHANGELOG.md**: Created 2025-12-07 - v1.0.0 release documented
  - Epic-01: **94.7% complete** (18/19 stories, 107/113 points) 🟢 Bootstrap functional
  - **Epic-02: 100% COMPLETE** (25/25 stories, 118/118 points) ✅ All apps delivered!
  - **Epic-03: 100% COMPLETE** (14/14 stories, 76/76 points) ✅ System config complete!
  - **Epic-04: 100% COMPLETE** (18/18 stories, 97/97 points) ✅ Development environment complete!
  - **Epic-05: 100% COMPLETE** (7/7 stories, 36/36 points) ✅ Theming & visual consistency complete!
  - **Epic-06: 100% COMPLETE** (18/18 stories, 97/97 points) ✅ Maintenance & monitoring complete!
  - **Epic-07: 100% COMPLETE** (8/8 stories, 34/34 points) ✅ Documentation & UX complete!
  - **NFR: 93% COMPLETE** (14/15 stories, 76/79 points) ✅ Nearly complete!
  - Next: MacBook Air migrations (Phase 11)

### Development Guides
- **[multi-agent-workflow.md](./multi-agent-workflow.md)** - Agent selection strategy and usage patterns
- **[tools-and-testing.md](./tools-and-testing.md)** - Tool installation, test execution, git workflow

### Reference Documentation
- **[hotfixes.md](./hotfixes.md)** - Production hotfix documentation
- **Story Implementations** (split by feature for maintainability - 44 feature files total):
  - **Epic-01** (8 files): Bootstrap system - Pre-flight, User Config, Xcode, Nix, Nix-Darwin, SSH/GitHub, Clone/Rebuild, Post-Install
  - **Epic-02** (10 files): Applications - AI Tools, Dev Apps, Browsers, Productivity, Communication, Media, Security, Profile-Specific, Office 365, Email
  - **Epic-03** (7 files): System Config - Finder, Security, Trackpad, Display, Keyboard, Dock, Time Machine
  - **Epic-04** (9 files): Dev Environment - Zsh, Starship, FZF, Ghostty, Aliases, Git, Python, Podman, Editors
  - **Epic-05** (4 files): Theming - Stylix, Fonts, App Theming, Theme Verification
  - **Epic-06** (4 files): Maintenance - Garbage Collection, Store Optimization, Monitoring Tools, Health Check
  - **Epic-07** (4 files): Documentation - Quick Start Docs, License Guide, Troubleshooting, Customization
  - All feature files in **[stories/](./stories/)** directory
  - Epic overviews in **[/stories/epic-XX-*.md](../../stories/)** with links to detailed implementations

## 🎯 Current Status (Quick Reference)

**Overall Project**: 98.4% complete (122/124 stories, 641/650 points) 🎉

**🎉 MILESTONE (2025-12-07)**: MacBook Pro M3 Max successfully running Power profile!
**📝 CHANGELOG.md**: Created 2025-12-07 - v1.0.0 release documented

**Epic-01: Bootstrap & Installation System** - 94.7% complete (18/19 stories, 107/113 points) 🟢
**Epic-02: Application Installation** - 100% COMPLETE (25/25 stories, 118/118 points) ✅
**Epic-03: System Configuration** - 100% COMPLETE (14/14 stories, 76/76 points) ✅
**Epic-04: Development Environment** - 100% COMPLETE (18/18 stories, 97/97 points) ✅
**Epic-05: Theming & Visual Consistency** - 100% COMPLETE (7/7 stories, 36/36 points) ✅
**Epic-06: Maintenance & Monitoring** - 100% COMPLETE (18/18 stories, 97/97 points) ✅
**Epic-07: Documentation & User Experience** - 100% COMPLETE (8/8 stories, 34/34 points) ✅
**NFR: Non-Functional Requirements** - 93% COMPLETE (14/15 stories, 76/79 points) ✅

### ✅ Completed Stories (122)

#### Epic-01 Stories (17)
1. **01.1-001** - Pre-flight Environment Checks (5 pts) - 2025-11-08
2. **01.1-002** - Idempotency Check (3 pts) - 2025-11-10
3. **01.2-001** - User Information Prompts (5 pts) - 2025-11-09
4. **01.2-002** - Profile Selection System (8 pts) - 2025-11-09
5. **01.2-003** - User Config File Generation (3 pts) - 2025-11-09
6. **01.3-001** - Xcode CLI Tools Installation (5 pts) - 2025-11-09
7. **01.4-001** - Nix Multi-User Installation (8 pts) - 2025-11-09
8. **01.4-002** - Nix Configuration for macOS (5 pts) - 2025-11-09
9. **01.4-003** - Flake Infrastructure Setup (8 pts) - 2025-11-09
10. **01.5-001** - Initial Nix-Darwin Build (13 pts) - 2025-11-09
11. **01.5-002** - Post-Darwin System Validation (5 pts) - 2025-11-10
12. **01.6-001** - SSH Key Generation (5 pts) - 2025-11-10
13. **01.6-002** - GitHub SSH Key Upload (Automated) (5 pts) - 2025-11-11
14. **01.6-003** - GitHub SSH Connection Test (8 pts) - 2025-11-11
15. **01.7-001** - Full Repository Clone (5 pts) - 2025-11-11
16. **01.7-002** - Final Darwin Rebuild (8 pts) - 2025-11-11
17. **01.8-001** - Installation Summary & Next Steps (3 pts) - 2025-11-11

#### Epic-02 Stories (25) ✅ EPIC COMPLETE!
18. **02.1-001** - Claude Desktop and AI Chat Apps (3 pts) - 2025-11-12 (VM tested)
19. **02.1-002** - Ollama Desktop App Installation (3 pts) - 2025-11-12 (VM tested)
20. **02.1-003** - Standard Profile Ollama Model (2 pts) - 2025-11-12 (VM tested)
21. **02.1-004** - Power Profile Additional Ollama Models (8 pts) - 2025-11-12 (VM tested)
22. **02.2-001** - Zed Editor Installation and Configuration (12 pts) - 2025-11-12 (VM tested)
23. **02.2-002** - VSCode Installation with Auto Dark Mode (3 pts) - 2025-11-12 (VM tested)
24. **02.2-003** - Ghostty Terminal Installation (5 pts) - 2025-11-12 (VM tested)
25. **02.2-004** - Python and Development Tools (5 pts) - 2025-11-12 (VM tested)
26. **02.2-005** - Podman and Container Tools (6 pts) - 2025-11-15 (VM tested)
27. **02.2-006** - Claude Code CLI and MCP Servers (8 pts) - 2025-11-15 (VM tested)
28. **02.3-001** - Brave Browser Installation (3 pts) - 2025-11-15 (VM tested)
29. **02.3-002** - Arc Browser Installation (2 pts) - 2025-11-15 (VM tested)
30. **02.4-001** - Raycast Installation (3 pts) - 2025-01-15 (VM tested)
31. **02.4-002** - 1Password Installation (3 pts) - 2025-01-15 (VM tested)
32. **02.4-003** - File Utilities (Calibre, Kindle, Keka, Marked 2) (5 pts) - 2025-01-15 (VM tested)
33. **02.4-005** - System Utilities (Onyx, f.lux) (3 pts) - 2025-01-15 (VM tested)
34. **02.4-006** - System Monitoring (gotop, iStat Menus, macmon) (5 pts) - 2025-01-16 (VM tested)
35. **02.4-007** - Git and Git LFS (5 pts) - 2025-01-15 (VM tested)
36. **02.5-001** - WhatsApp Installation (3 pts) - 2025-01-15 (VM tested)
37. **02.5-002** - Zoom and Webex Installation (5 pts) - 2025-01-15 (VM tested)
38. **02.6-001** - VLC and GIMP Installation (3 pts) - 2025-01-15 (VM tested)
39. **02.8-001** - Parallels Desktop (Power Profile Only) (8 pts) - 2025-01-16 (VM tested)
40. **02.4-004** - Dropbox Installation (3 pts) - 2025-01-16 (VM tested)
41. **02.7-001** - NordVPN Installation (5 pts) - 2025-01-16 (VM tested)
42. **02.9-001** - Office 365 Installation (5 pts) - 2025-01-16 (VM tested)

**Note**: Story 02.10-001 (Email Account Configuration, 5 pts) was **CANCELLED**. Manual setup documented instead.

#### Epic-03 Stories (14) ✅ EPIC COMPLETE!
43. **03.1-001** - Finder View and Display Settings (5 pts) - 2025-11-19 (VM tested)
44. **03.1-002** - Finder Behavior Settings (5 pts) - 2025-12-04 (VM tested)
45. **03.1-003** - Finder Sidebar and Desktop (8 pts) - 2025-12-04 (VM tested)
46. **03.2-001** - Firewall Configuration (5 pts) - 2025-12-04 (VM tested)
47. **03.2-002** - FileVault Encryption Prompt (8 pts) - 2025-12-04 (Implemented)
48. **03.2-003** - Screen Lock and Password Policies (5 pts) - 2025-12-04 (VM tested)
49. **03.3-001** - Trackpad Gestures and Speed (8 pts) - 2025-12-04 (Hardware tested)
50. **03.3-002** - Mouse and Scroll Settings (5 pts) - 2025-12-04 (Hardware tested)
51. **03.4-001** - Auto Light/Dark Mode and Time Format (5 pts) - 2025-12-04 (Hardware tested)
52. **03.4-002** - Night Shift Scheduling (5 pts) - 2025-12-04 (Documented)
53. **03.5-001** - Keyboard Repeat and Text Corrections (5 pts) - 2025-12-04 (Hardware tested)
54. **03.6-001** - Dock Behavior and Apps (4 pts) - 2025-12-04 (Hardware tested)
55. **03.7-001** - Time Machine Preferences & Exclusions (5 pts) - 2025-12-04 (Hardware tested)
56. **03.7-002** - Time Machine Destination Setup Prompt (3 pts) - 2025-12-05 (Complete)

#### Epic-04 Stories (18/18 complete - 100%) ✅ EPIC COMPLETE!
57. **04.1-001** - Zsh Shell Configuration (5 pts) - 2025-12-05 (Hardware tested)
58. **04.1-002** - Oh My Zsh Installation and Plugin Configuration (8 pts) - 2025-12-05 (Hardware tested)
59. **04.1-003** - Zsh Environment and Options (5 pts) - 2025-12-05 (Hardware tested)
60. **04.2-001** - Starship Prompt Installation and Configuration (5 pts) - 2025-12-05 (Hardware tested)
61. **04.3-001** - FZF Installation and Keybindings (5 pts) - 2025-12-05 (Hardware tested)
62. **04.4-001** - Ghostty Configuration Integration (5 pts) - 2025-12-05 (Hardware tested)
63. **04.5-001** - Core Nix Aliases (5 pts) - 2025-12-05 (Hardware tested)
64. **04.5-002** - General Shell Aliases (5 pts) - 2025-12-05 (Hardware tested)
65. **04.5-003** - Modern CLI Tool Replacements (8 pts) - 2025-12-05 (Hardware tested)
66. **04.6-001** - Git Configuration (5 pts) - 2025-12-05 (Hardware tested)
67. **04.6-002** - Git Aliases (5 pts) - 2025-12-05 (Hardware tested)
68. **04.6-003** - SSH Configuration (7 pts) - 2025-12-05 (Hardware tested)
69. **04.7-001** - Python Environment Variables (3 pts) - 2025-12-05 (Hardware tested)
70. **04.7-002** - Python Dev Tools Configuration (5 pts) - 2025-12-05 (Hardware tested)
71. **04.8-001** - Podman Machine Initialization (8 pts) - 2025-12-05 (Hardware tested)
72. **04.8-002** - Docker Compatibility Aliases (5 pts) - 2025-12-05 (Hardware tested)
73. **04.9-001** - Zed Editor Theming (1 pt) - 2025-11-12 (Already in Epic-02)
74. **04.9-002** - VSCode Configuration (1 pt) - 2025-11-12 (Already in Epic-02)

#### Epic-05 Stories (7/7 complete - 100%) ✅ EPIC COMPLETE!
75. **05.1-001** - Stylix Installation and Base16 Scheme (8 pts) - 2025-12-06 (VM Tested)
76. **05.1-002** - Auto Light/Dark Mode Switching (5 pts) - 2025-12-06 (VM Tested)
77. **05.2-001** - JetBrains Mono Nerd Font Installation (5 pts) - 2025-12-06 (VM Tested)
78. **05.2-002** - Font Ligature Configuration (5 pts) - 2025-12-06 (VM Tested)
79. **05.3-001** - Ghostty Terminal Theming (5 pts) - 2025-12-06 (VM Tested)
80. **05.3-002** - Zed Editor Theming (5 pts) - 2025-12-06 (VM Tested)
81. **05.4-001** - Visual Consistency and Switching Verification (3 pts) - 2025-12-06 (VM Tested)

#### Epic-06 Stories (18/18 complete - 100%) ✅ EPIC COMPLETE!
82. **06.1-001** - Nix Store Garbage Collection LaunchAgent (5 pts) - 2025-12-06
83. **06.1-002** - Garbage Collection Manual Trigger Alias (3 pts) - 2025-12-06
84. **06.2-001** - Nix Store Optimization LaunchAgent (5 pts) - 2025-12-06
85. **06.2-002** - Store Optimization Manual Trigger Alias (3 pts) - 2025-12-06
86. **06.3-001** - btop Terminal Monitor Installation (3 pts) - 2025-12-06
87. **06.3-002** - gotop Terminal Monitor Installation (3 pts) - 2025-12-06
88. **06.3-003** - macmon macOS-specific Monitor Installation (3 pts) - 2025-12-06
89. **06.4-001** - iStat Menus Installation (3 pts) - 2025-12-06
90. **06.5-001** - health-check Script Implementation (8 pts) - 2025-12-06
91. **06.5-002** - health-check Alias Integration (2 pts) - 2025-12-06
92. **06.6-001** - Weekly Maintenance Digest Script (8 pts) - 2025-12-06
93. **06.6-002** - Maintenance Digest LaunchAgent (5 pts) - 2025-12-06
94. **06.6-003** - Maintenance Digest Email Configuration (3 pts) - 2025-12-06
95. **06.7-001** - Release Monitor Core Script (13 pts) - 2025-12-06
96. **06.7-002** - Release Monitor GitHub Integration (8 pts) - 2025-12-06
97. **06.7-003** - Release Monitor Email Reports (5 pts) - 2025-12-06
98. **06.7-004** - Release Monitor LaunchAgent (5 pts) - 2025-12-06
99. **06.7-005** - Release Monitor Claude Code Commands (5 pts) - 2025-12-06

#### Epic-07 Stories (8/8 complete - 100%) ✅ EPIC COMPLETE!
100. **07.1-001** - README Quick Start Guide (5 pts) - 2025-12-06
101. **07.1-002** - Update Philosophy Documentation (5 pts) - 2025-12-06
102. **07.2-001** - Licensed App Documentation (5 pts) - 2025-12-06
103. **07.2-002** - Post-Install Checklist (3 pts) - 2025-12-06
104. **07.3-001** - Common Issues Documentation (5 pts) - 2025-12-06
105. **07.3-002** - Rollback Documentation (3 pts) - 2025-12-06
106. **07.4-001** - Adding Apps Documentation (5 pts) - 2025-12-06
107. **07.4-002** - Configuration Examples (3 pts) - 2025-12-06

### 🚧 Remaining Stories

**Epic-01 Cleanup** (Optional enhancements):
- **01.1-003** - Progress Indicators (3 pts) - P1 optional enhancement
- **01.1-004** - Modular Bootstrap Architecture (8 pts) - P1, deferred to post-Epic-01

**NFR Stories** (15 stories, 79 points):
- Non-functional requirements for security, performance, error handling

### ⏳ Summary
- **Epic-01**: 2 stories remaining (01.1-003, 01.1-004) - both P1 optional/deferred
- **Epic-02**: ✅ **COMPLETE** (25/25 stories, 100%)
- **Epic-03**: ✅ **COMPLETE** (14/14 stories, 100%)
- **Epic-04**: ✅ **COMPLETE** (18/18 stories, 100%)
- **Epic-05**: ✅ **COMPLETE** (7/7 stories, 100%)
- **Epic-06**: ✅ **COMPLETE** (18/18 stories, 100%)
- **Epic-07**: ✅ **COMPLETE** (8/8 stories, 100%)

## 🛠️ What to Read First?

**New to the project?**
1. Read `../../README.md` (project quick start)
2. Read `../../docs/REQUIREMENTS.md` (comprehensive PRD - THE SOURCE OF TRUTH)
3. Read `./progress.md` (current status and recent activity)
4. Read `./tools-and-testing.md` (set up development environment)

**Starting a new story?**
1. Read `./progress.md` (check "Next Story" section)
2. Read `/stories/epic-*.md` for detailed story definition
3. Read `./multi-agent-workflow.md` (select appropriate agent)
4. Read `./tools-and-testing.md` (review TDD workflow)

**Reviewing a story implementation?**
1. Read `/stories/epic-XX-*.md` (find story section in epic overview)
2. Follow link to `./stories/epic-XX-feature-XX.X.md` (detailed implementation)
3. Check implementation details, testing results, VM validation
4. Review code quality metrics and acceptance criteria

**Fixing a production issue?**
1. Read `./hotfixes.md` (check for similar issues)
2. Create hotfix branch following git workflow
3. Document hotfix in `hotfixes.md` after resolution

## 📊 Development Metrics

### Test Coverage
- **Automated BATS tests**: 729+ tests across all stories
- **Manual VM scenarios**: 76 documented test cases
- **Shellcheck validation**: 0 errors, 0 warnings on Phase 9 code

### Code Quality
- **TDD Approach**: All stories developed with tests-first methodology
- **Multi-Agent Review**: senior-code-reviewer validates all implementations
- **VM Testing**: 16 Epic-01 stories validated in Parallels macOS VM

### Bootstrap Script Growth
- **Current Size**: 4,506 lines (from initial 168 lines in Story 01.1-001)
- **Phases Implemented**: 9 phases (Pre-flight through Installation Summary)
- **Functions**: 67+ functions across 9 phases
- **Status**: ✅ **FUNCTIONALLY COMPLETE** - All core phases implemented!

## 🔗 File Organization

```
docs/development/
├── README.md                          # This file - master index
├── progress.md                        # Epic overview, story completion, recent activity
├── multi-agent-workflow.md            # Agent selection and workflow patterns
├── tools-and-testing.md               # Dev tools, testing, git workflow
├── hotfixes.md                        # Production hotfix documentation
└── stories/                           # Feature implementation details (44 files)
    ├── epic-01-feature-01.1-01.2.md   # Epic-01: Pre-flight & User Config
    ├── epic-01-feature-01.3.md        # Epic-01: Xcode CLI Tools
    ├── epic-01-feature-01.4.md        # Epic-01: Nix Installation
    ├── epic-01-feature-01.5.md        # Epic-01: Nix-Darwin Installation
    ├── epic-01-feature-01.6.md        # Epic-01: SSH Setup & GitHub
    ├── epic-01-feature-01.7.md        # Epic-01: Repository Clone & Rebuild
    ├── epic-01-feature-01.8.md        # Epic-01: Installation Summary
    ├── epic-02-feature-02.1.md        # Epic-02: AI & LLM Tools
    ├── epic-02-feature-02.2.md        # Epic-02: Dev Environment Apps
    ├── epic-02-feature-02.3.md        # Epic-02: Browsers
    ├── epic-02-feature-02.4.md        # Epic-02: Productivity & Utilities
    ├── epic-02-feature-02.5.md        # Epic-02: Communication Tools
    ├── epic-02-feature-02.6.md        # Epic-02: Media & Creative Tools
    ├── epic-02-feature-02.7.md        # Epic-02: Security & VPN
    ├── epic-02-feature-02.8.md        # Epic-02: Profile-Specific Apps
    ├── epic-02-feature-02.9.md        # Epic-02: Office 365
    ├── epic-02-feature-02.10.md       # Epic-02: Email Configuration
    ├── epic-03-feature-03.1.md        # Epic-03: Finder Configuration
    ├── epic-03-feature-03.2.md        # Epic-03: Security Configuration
    ├── epic-03-feature-03.3.md        # Epic-03: Trackpad & Input
    ├── epic-03-feature-03.4.md        # Epic-03: Display & Appearance
    ├── epic-03-feature-03.5.md        # Epic-03: Keyboard & Text Input
    ├── epic-03-feature-03.6.md        # Epic-03: Dock Configuration
    ├── epic-04-feature-04.1.md        # Epic-04: Zsh & Oh My Zsh
    ├── epic-04-feature-04.2.md        # Epic-04: Starship Prompt
    ├── epic-04-feature-04.3.md        # Epic-04: FZF Integration
    ├── epic-04-feature-04.4.md        # Epic-04: Ghostty Terminal
    ├── epic-04-feature-04.5.md        # Epic-04: Shell Aliases
    ├── epic-04-feature-04.6.md        # Epic-04: Git Configuration
    ├── epic-04-feature-04.7.md        # Epic-04: Python Environment
    ├── epic-04-feature-04.8.md        # Epic-04: Container Environment
    ├── epic-04-feature-04.9.md        # Epic-04: Editor Configuration
    ├── epic-05-feature-05.1.md        # Epic-05: Stylix System
    ├── epic-05-feature-05.2.md        # Epic-05: Font Configuration
    ├── epic-05-feature-05.3.md        # Epic-05: App-Specific Theming
    ├── epic-05-feature-05.4.md        # Epic-05: Theme Verification
    ├── epic-06-feature-06.1.md        # Epic-06: Garbage Collection
    ├── epic-06-feature-06.2.md        # Epic-06: Store Optimization
    ├── epic-06-feature-06.3.md        # Epic-06: System Monitoring
    ├── epic-06-feature-06.4.md        # Epic-06: Health Check
    ├── epic-07-feature-07.1.md        # Epic-07: Quick Start Docs
    ├── epic-07-feature-07.2.md        # Epic-07: License Activation Guide
    ├── epic-07-feature-07.3.md        # Epic-07: Troubleshooting Guide
    └── epic-07-feature-07.4.md        # Epic-07: Customization Guide

../../stories/                          # Epic overviews (link to feature files)
├── epic-01-bootstrap-installation.md  # Epic-01 overview (60K → 60K, already split)
├── epic-02-application-installation.md # Epic-02 overview (85K → 9.1K)
├── epic-03-system-configuration.md    # Epic-03 overview (29K → 6.6K)
├── epic-04-development-environment.md # Epic-04 overview (40K → 7.6K)
├── epic-05-theming-visual-consistency.md # Epic-05 overview (21K → 5.8K)
├── epic-06-maintenance-monitoring.md  # Epic-06 overview (21K → 5.3K)
└── epic-07-documentation-user-experience.md # Epic-07 overview (30K → 5.3K)
```

## 🚀 Quick Commands

### Run All Tests
```bash
bats tests/*.bats
```

### Validate Bootstrap Script
```bash
shellcheck bootstrap.sh
bash -n bootstrap.sh
```

### Check Current Progress
```bash
# See completed stories
cat docs/development/progress.md | grep "✅ Complete"

# See next story
cat docs/development/progress.md | grep "Next Story"
```

### Start New Story
```bash
# Create feature branch
git checkout -b feature/STORY-ID

# Check story details
cat /stories/epic-*.md | grep -A 20 "STORY-ID"
```

## 📝 Notes

- **Modular Structure**: Epic files split into feature-specific files for better maintainability (44 feature files total)
- **Epic Overviews**: `/stories/epic-XX-*.md` files provide high-level summaries with links to detailed feature implementations
- **Feature Details**: `docs/development/stories/epic-XX-feature-XX.X.md` files contain full implementation details, testing results, and lessons learned
- **Buffer Size Constraint**: Large epic files (up to 85K) reduced to manageable sizes (5-10K) by extracting features
- **Single Source of Truth**: This directory structure preserves all development documentation while staying within buffer limits
- **Master Index**: This README.md provides navigation and quick reference across all files

## 🔍 Related Documentation

- **Requirements**: `../../docs/REQUIREMENTS.md` (comprehensive PRD)
- **Story Tracking**: `../../STORIES.md` + `/stories/epic-*.md` (epic and story definitions)
- **Quick Start**: `../../README.md` (user-facing quick start guide)
- **CLAUDE.md**: `../../CLAUDE.md` (Claude Code project instructions)
