# Nix-Darwin MacBook Setup System

> **Status**: 🔄 Planning Complete - Implementation Starting
> **Version**: 0.1.0 (Pre-Release)
> **Last Updated**: 2025-11-11

Automated, declarative MacBook configuration system using Nix + nix-darwin + Home Manager. Transform a fresh macOS installation into a fully configured development environment in <30 minutes with zero manual intervention (except license activations).

---

## 🎯 Project Vision

**Problem**: Managing 3 MacBooks with periodic reinstalls is time-consuming (4-6 hours per install) and error-prone. Configuration drift occurs between machines, and there's no rollback mechanism when changes break the system.

**Solution**: Declarative configuration-as-code that reduces setup time by 90%, ensures 100% consistency across machines, and provides atomic updates with instant rollback capability.

**Target**: FX manages 3 MacBooks (1x MacBook Pro M3 Max, 2x MacBook Air) with periodic reinstalls. Split usage between Office 365 work and weekend Python development.

---

## 📊 Current Status

### Epic Overview Progress

| Epic ID | Epic Name | Total Stories | Total Points | Completed Stories | Completed Points | % Complete (Stories) | % Complete (Points) | Status |
|---------|-----------|---------------|--------------|-------------------|------------------|---------------------|-------------------|--------|
| **Epic-01** | Bootstrap & Installation System | 19 | 113 | **17** | **104** | 89.5% | 92.0% | 🟢 Functional |
| **Epic-02** | Application Installation | 25 | 118 | **17** | **79** | 68.0% | 66.9% | 🟡 In Progress |
| **Epic-03** | System Configuration | 12 | 68 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **Epic-04** | Development Environment | 18 | 97 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **Epic-05** | Theming & Visual Consistency | 8 | 42 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **Epic-06** | Maintenance & Monitoring | 10 | 55 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **Epic-07** | Documentation & User Experience | 8 | 34 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **NFR** | Non-Functional Requirements | 15 | 79 | 0 | 0 | 0% | 0% | ⚪ Not Started |
| **TOTAL** | **All Epics** | **115** | **606** | **34** | **183** | **29.6%** | **30.2%** | 🟡 In Progress |

### ✅ Completed
- **Requirements Definition** ([REQUIREMENTS.md](./docs/REQUIREMENTS.md)) - Comprehensive PRD with 1,700+ lines
- **User Story Breakdown** ([STORIES.md](./STORIES.md)) - 115 stories across 7 epics + NFR
- **Story Management Protocol** - Modular epic structure with detailed acceptance criteria
- **Requirements Baseline** - v1.1 approved (change control re-approval completed)
- **Project Architecture** - Two-tier profiles (Standard/Power), Stylix theming, nixpkgs-unstable

**Epic-01 Stories (17/19 complete - 89.5%)**:
- 01.1-001, 01.1-002, 01.2-001, 01.2-002, 01.2-003 ✅
- 01.3-001, 01.4-001, 01.4-002, 01.4-003 ✅
- 01.5-001, 01.5-002, 01.6-001, 01.6-002, 01.6-003 ✅
- 01.7-001, 01.7-002, 01.8-001 ✅
- All VM tested and validated

**Epic-02 Stories (17/25 complete - 68.0%)**:
- **Story 02.1-001** - Claude Desktop and AI Chat Apps (✅ Complete - 2025-11-12, 3 pts, VM TESTED)
- **Story 02.1-002** - Ollama Desktop App (✅ Complete - 2025-11-12, 3 pts, VM TESTED)
- **Story 02.1-003** - Standard Profile Ollama Model (✅ Complete - 2025-11-12, 2 pts, VM TESTED)
- **Story 02.1-004** - Power Profile Ollama Models (✅ Complete - 2025-11-12, 8 pts, VM TESTED)
- **Story 02.2-001** - Zed Editor with Bidirectional Sync (✅ Complete - 2025-11-12, 12 pts, VM TESTED)
- **Story 02.2-002** - VSCode with Auto Dark Mode (✅ Complete - 2025-11-12, 3 pts, VM TESTED)
- **Story 02.2-003** - Ghostty Terminal (✅ Complete - 2025-11-12, 5 pts, VM TESTED)
- **Story 02.2-004** - Python and Development Tools (✅ Complete - 2025-11-12, 5 pts, VM TESTED)
- **Story 02.2-005** - Podman and Container Tools (✅ Complete - 2025-11-15, 6 pts, VM TESTED)
- **Story 02.2-006** - Claude Code CLI & MCP Servers (✅ Complete - 2025-11-15, 8 pts, VM TESTED)
- **Story 02.3-001** - Brave Browser (✅ Complete - 2025-11-15, 3 pts, VM TESTED)
- **Story 02.3-002** - Arc Browser (✅ Complete - 2025-11-15, 2 pts, VM TESTED)
- **Story 02.4-001** - Raycast Installation (✅ Complete - 2025-01-15, 3 pts, VM TESTED)
- **Story 02.4-002** - 1Password Installation (✅ Complete - 2025-01-15, 3 pts, VM TESTED)
- **Story 02.4-003** - File Utilities (Calibre, Kindle, Keka, Marked 2) (✅ Complete - 2025-01-15, 5 pts, VM TESTED)
- **Story 02.4-004** - Dropbox Installation (✅ Complete - 2025-01-15, 3 pts, VM TESTED)
- **Story 02.4-007** - Git and Git LFS (✅ Complete - 2025-01-15, 5 pts, VM TESTED)
- **Story 02.4-005** - System Utilities (Onyx, f.lux) (✅ Complete - 2025-01-15, 3 pts, VM TESTED)
- **Story 02.5-001** - WhatsApp Installation (✅ Complete - 2025-01-15, 3 pts, VM TESTED)
- **Story 02.6-001** - VLC and GIMP (✅ Complete - 2025-01-15, 3 pts, VM TESTED)
- **Story 02.5-002** - Zoom and Webex (✅ Complete - 2025-01-15, 5 pts, VM TESTED)

### 🔄 In Progress
- **Epic-01: Bootstrap System** - 17/19 stories (89.5%), 104/113 points (92.0%) - **FUNCTIONAL** 🟢
- **Epic-02: Application Installation** - 20/25 stories (80.0%), 90/118 points (76.3%) - **IN PROGRESS** 🟡
- **Next Stories**: 02.4-006 (System Monitoring, 5 pts), 02.7-001 (NordVPN, 5 pts), 02.9-001 (Office 365, 5 pts)
- **Bootstrap Status**: ALL 9 phases working! Phases 1-8 VM tested and verified ✅
- **Recent Milestone**: Epic-02 Batch 1 (Quick Wins) COMPLETE - 4 stories (14 points) VM tested ✅

### 📅 Upcoming
- **Phase 1-2**: Core bootstrap implementation (Week 2)
- **Phase 3-5**: Applications, system config, dev environment (Week 3-4)
- **Phase 6-8**: Theming, monitoring, documentation (Week 5-6)
- **Phase 9**: VM testing in Parallels (Week 6)
- **Phase 10-11**: Physical hardware migrations (Week 7-8)

---

## 📊 Development Effort Analysis

### Time Investment Metrics

**Analysis Period**: November 8-12, 2025 (5 active days)

**Development Activity**:
- **203 git commits** (40.6 commits/day average)
- **20 GitHub issues** (18 closed, 90% completion rate)
- **241 total tracked activities**

**Velocity Metrics**:
- Activities per day: 48.2
- Development intensity: 48.2
- Issue completion rate: 90.0%

**Estimated Active Development Time**: **~34 hours** total

This represents approximately 34 hours of focused, productive development work over a 5-day period. The high commit rate (40.6/day) and strong issue closure rate (90%) indicate efficient, iterative development with robust progress tracking and quality control.

*Metrics generated via `python3 scripts/estimate_effort_v2.py`*

---

## 📚 Documentation

### Essential Reading

1. **[REQUIREMENTS.md](./docs/REQUIREMENTS.md)** - Complete product requirements document
   - Business objectives and success metrics
   - Detailed functional and non-functional requirements
   - Profile comparison (Standard vs Power)
   - Bootstrap flow diagrams
   - 8-week implementation plan

2. **[STORIES.md](./STORIES.md)** - User story overview and epic navigation
   - 111 total stories, 596 story points
   - Epic summaries and metrics
   - Sprint planning guidance
   - Cross-epic dependencies

3. **[/stories/](./stories/)** - Detailed epic files (single source of truth)
   - Epic-01: Bootstrap & Installation (18 stories, 108 points)
   - Epic-02: Application Installation (22 stories, 113 points)
   - Epic-03: System Configuration (12 stories, 68 points)
   - Epic-04: Development Environment (18 stories, 97 points)
   - Epic-05: Theming & Visual Consistency (8 stories, 42 points)
   - Epic-06: Maintenance & Monitoring (10 stories, 55 points)
   - Epic-07: Documentation & UX (8 stories, 34 points)
   - Non-Functional Requirements (15 stories, 79 points)

4. **[CLAUDE.md](./CLAUDE.md)** - Developer guidance and architectural decisions
   - Project overview and philosophy
   - Story management protocol
   - Testing strategy (VM first, then hardware)
   - Key architectural decisions
   - Requirements change control process

---

## 🚀 Quick Start (Coming Soon)

> **Note**: The automated bootstrap script is currently under development. See [Epic-01](./stories/epic-01-bootstrap-installation.md) for implementation progress.

### System Requirements

Before running the bootstrap script, ensure your system meets these prerequisites:

#### Prerequisites
- **macOS Version**: Sonoma (14.0) or newer
- **Internet Connection**: Required for package downloads from nixos.org and github.com
- **User Permissions**: Run as regular user (not root) - script will request sudo when needed
- **Disk Space**:
  - Standard Profile: ~35GB free
  - Power Profile: ~120GB free
- **⚠️ Mac App Store Sign-In**: **REQUIRED BEFORE RUNNING BOOTSTRAP**
  - Open **App Store** app and sign in with your Apple ID
  - Some apps (e.g., Perplexity) are installed via Mac App Store CLI (`mas`)
  - `mas` cannot install apps without App Store authentication
  - Verify sign-in: `mas account` (should show your Apple ID email)
  - If not signed in, darwin-rebuild will fail during app installation

#### Pre-flight Validation
The bootstrap script automatically validates:
- ✅ macOS version compatibility (Sonoma 14.0+)
- ✅ Internet connectivity to nixos.org and github.com
- ✅ User is not running as root
- ✅ System meets minimum requirements

If any check fails, the script will display clear, actionable error messages and exit gracefully.

### Installation (Once Complete)

Setup will be as simple as:

```bash
# Recommended: One-line installation via setup.sh wrapper
curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/setup.sh | bash
```

Or, if you prefer to inspect the script first:

```bash
# Download and inspect before running
curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/setup.sh -o setup.sh
less setup.sh  # Review the script
bash setup.sh  # Run it
```

#### What Happens During Installation

The installation uses a **two-stage bootstrap pattern** for reliability:

**Stage 1 (setup.sh)**: Curl-pipeable wrapper
- Downloads the full bootstrap script to a temporary directory
- Executes it locally (not piped) to ensure interactive prompts work correctly

**Stage 2 (bootstrap.sh)**: Interactive installer
1. **Pre-flight Validation**: Check system requirements (Story 01.1-001 ✅)
2. **User Information**: Collect name, email, GitHub username with validation (Story 01.2-001 ✅)
3. **Profile Selection**: Choose Standard or Power profile (Story 01.2-002 ✅)
4. **User Config**: Generate user-config.nix from inputs (Story 01.2-003 ✅)
5. **Xcode CLI Tools**: Install Command Line Tools (Story 01.3-001 ✅)
6. **Nix Installation**: Install Nix package manager with flakes enabled (Story 01.4-001 ✅)
7. **Nix Configuration**: Configure binary cache, performance, trusted users, sandbox (Story 01.4-002 ✅)
8. Install nix-darwin and Homebrew (managed declaratively)
9. Generate SSH key and guide GitHub upload
10. Clone this repository and apply full configuration
11. Display post-install checklist (license activations, etc.)

**Estimated Time**: <30 minutes (mostly hands-off)

> **Technical Note**: The two-stage pattern solves stdin redirection issues when scripts are executed via `curl | bash`. This ensures interactive prompts can properly read user input without requiring `/dev/tty` workarounds.

#### Environment Variables

**For Contributors/Developers**: When testing feature branches, use the `NIX_INSTALL_BRANCH` environment variable to ensure setup.sh downloads bootstrap.sh from the same branch:

```bash
# Testing a feature branch
NIX_INSTALL_BRANCH=feature/my-branch \
  curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/feature/my-branch/setup.sh | bash
```

**Why this is needed**: When setup.sh is executed via `curl | bash`, it cannot auto-detect which branch it was downloaded from. By default, it downloads bootstrap.sh from the `main` branch. The environment variable overrides this behavior for feature branch testing.

**Production users**: No environment variable needed - always use `main` branch as shown in installation instructions above.

#### Customizing Repository Clone Location

By default, the bootstrap script clones the nix-install repository to `~/Documents/nix-install`. You can customize this location using the `NIX_INSTALL_DIR` environment variable:

```bash
# Clone to home directory instead of Documents
NIX_INSTALL_DIR="${HOME}/nix-install" \
  curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/setup.sh | bash
```

**Common alternative locations**:
```bash
# Hidden directory in home
NIX_INSTALL_DIR="${HOME}/.nix-install" ...

# XDG config directory
NIX_INSTALL_DIR="${HOME}/.config/nix-install" ...

# Absolute path (outside home directory)
NIX_INSTALL_DIR="/opt/nix-install" ...
```

**Important notes**:
- The `NIX_INSTALL_DIR` variable must be set **before** running `setup.sh`
- If not specified, defaults to `~/Documents/nix-install` (maintains backward compatibility)
- The path should NOT end with a trailing slash
- Paths with spaces are supported but must be properly quoted
- **Note about `~/.config/*` paths**: Paths under `~/.config/` are fully supported as of Hotfix #10. The bootstrap script automatically detects and fixes any permission issues that may arise when Nix creates subdirectories like `~/.config/nix/`.
- The repository clone location affects:
  - Where the configuration files are stored
  - The `dotfiles_path` used in `user-config.nix`
  - The path shown in post-installation documentation

**Example with feature branch + custom location**:
```bash
# Testing feature branch with custom clone location
NIX_INSTALL_BRANCH=feature/my-branch \
NIX_INSTALL_DIR="${HOME}/.config/nix-install" \
  curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/feature/my-branch/setup.sh | bash
```

---

## 🏗️ Architecture Overview

### Two-Tier Installation Profiles

**Standard Profile** (MacBook Air targets):
- Core apps, single Ollama model (`gpt-oss:20b`)
- No virtualization
- ~35GB disk usage
- Target: MacBook Air #1 and #2

**Power Profile** (MacBook Pro M3 Max target):
- All Standard apps + Parallels Desktop
- 4 Ollama models (`gpt-oss:20b`, `qwen2.5-coder:32b`, `llama3.1:70b`, `deepseek-r1:32b`)
- ~120GB disk usage
- Target: MacBook Pro M3 Max

### Package Management Strategy

1. **Nix First** (via nixpkgs-unstable): CLI tools, dev tools, Python 3.12, uv, ruff, Podman
2. **Homebrew Casks**: GUI apps (Zed, Ghostty, Arc, Firefox, Claude Desktop, Office 365 via microsoft-office-businesspro)
3. **Mac App Store (mas)**: Only when no alternative (Kindle, WhatsApp)

**Recent Change (v1.1)**: Office 365 installation method changed from manual to Homebrew cask (`microsoft-office-businesspro`). Installation is now automated, but activation still requires manual Microsoft account sign-in.

### Key Features

- **Declarative Configuration**: System state defined in code, not manual steps
- **Atomic Updates**: All-or-nothing updates with instant rollback via `darwin-rebuild`
- **Version Control**: Entire system configuration in Git with flake.lock for reproducibility
- **Stylix Theming**: System-wide Catppuccin theme (Latte/Mocha) with auto light/dark switching
- **No Auto-Updates**: All app updates controlled via `rebuild` command only
- **Modular Design**: One concern per Nix file for maintainability

---

## 🛠️ Development Workflow

### For Contributors

**Story Management**:
- All stories tracked in [/stories/](./stories/) epic files (single source of truth)
- Reference story IDs in commits (e.g., "Implements Story 01.2-001")
- Update story completion status in epic files after deployment
- See [Story Management Protocol](./CLAUDE.md#story-management-protocol) for details

**Testing Strategy**:
- **Phase 9**: VM testing in Parallels macOS VM first (mandatory)
- **Phase 10-11**: Physical hardware testing only after VM success
- Never test directly on production MacBooks until VM-validated

**Commit Format**:
```
<type>: <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Requirements Change Control

Requirements are baselined and change-controlled:
- **Current Version**: v1.1 (Change Control Re-Approval completed 2025-11-08)
- **Baseline Hash**: `ed51883bb71d31dbae500606ac42ed9e81f853ff8ed3e720c3e9a5ac1be6d5b0`
- **Verification**: Run `./scripts/verify-requirements-integrity.sh` to validate integrity
- **Changes**: Must follow change control process (see CLAUDE.md)
- **Tracking**: All changes logged in REQUIREMENTS.md Post-Approval Change Log
- **Audit Trail**: Complete version history maintained in `requirements-integrity.json`

**Latest Change (v1.1)**:
- Office 365 installation method: Manual → Homebrew cask (`microsoft-office-businesspro`)
- Impact: Low - simplifies installation, activation still manual
- Approved by: FX (Product Owner)

---

## 📦 Project Structure (Planned)

```
nix-install/
├── flake.nix                    # System definition (Standard/Power profiles)
├── flake.lock                   # Dependency lock file
├── user-config.nix              # User personal info (created during bootstrap)
├── user-config.template.nix     # Template for new users
├── setup.sh                     # Stage 1: Curl-pipeable wrapper script
├── bootstrap.sh                 # Stage 2: Full interactive installer
│
├── darwin/                      # System-level configs (nix-darwin)
│   ├── configuration.nix        # Main darwin config
│   ├── homebrew.nix             # Homebrew packages/casks
│   ├── macos-defaults.nix       # macOS system preferences
│   ├── system-monitoring.nix    # GC, optimization, health checks
│   └── nix-settings.nix         # Nix daemon configuration
│
├── home-manager/                # User-level configs (dotfiles)
│   ├── default.nix              # Main home-manager entry
│   ├── modules/
│   │   ├── zsh.nix              # Zsh + Oh My Zsh config
│   │   ├── git.nix              # Git configuration
│   │   ├── ssh.nix              # SSH config
│   │   ├── starship.nix         # Shell prompt
│   │   ├── fzf.nix              # Fuzzy finder
│   │   └── aliases.nix          # Shell aliases & functions
│   └── configs/
│       └── ghostty/             # Ghostty terminal config
│
├── config/                      # Standalone config files
│   └── config.ghostty           # Original ghostty config
│
├── scripts/                     # Automation & utilities
│   ├── health-check.sh          # System health validation
│   ├── cleanup.sh               # Manual GC + optimization
│   └── backup-before-rebuild.sh # Safety backup
│
├── docs/                        # User documentation
│   ├── quick-start.md           # Installation guide
│   ├── licensed-apps.md         # Activation instructions
│   ├── customization.md         # How to modify config
│   └── troubleshooting.md       # Common issues & fixes
│
└── stories/                     # User stories & sprint planning
    ├── epic-01-*.md             # Bootstrap stories
    ├── epic-02-*.md             # Application stories
    └── ...                      # Other epics
```

---

## 🎯 Success Metrics

**Time Savings**:
- Setup time: 4-6 hours → <30 minutes (90% reduction)
- Time saved per reinstall: 3-4 hours

**Quality**:
- Configuration consistency: 100% across same-profile machines
- Bootstrap success rate: >90% first-time success
- Rollback capability: Instant via `darwin-rebuild --rollback`

**Adoption**:
- Target: All 3 MacBooks migrated within 30 days
- User confidence: >8/10 "I can rebuild my Mac confidently"

---

## 🔗 Key Technologies

- **[Nix](https://nixos.org/)**: Declarative package management with reproducibility
- **[nix-darwin](https://github.com/LnL7/nix-darwin)**: Nix-based macOS system configuration
- **[Home Manager](https://github.com/nix-community/home-manager)**: Declarative dotfile and user environment management
- **[Stylix](https://github.com/danth/stylix)**: System-wide theming framework
- **[nixpkgs-unstable](https://github.com/NixOS/nixpkgs)**: Latest packages with flake.lock reproducibility
- **Homebrew**: GUI application management (declaratively controlled by nix-darwin)

---

## 📋 Implementation Phases

| Phase | Timeline | Focus | Status |
|-------|----------|-------|--------|
| Phase 0 | Week 1 | Foundation & repository structure | 🔄 In Progress |
| Phase 1-2 | Week 1-2 | Core bootstrap script | 📅 Planned |
| Phase 3-5 | Week 3-4 | Apps, system config, dev environment | 📅 Planned |
| Phase 6-8 | Week 5-6 | Theming, monitoring, documentation | 📅 Planned |
| Phase 9 | Week 6 | VM testing (Parallels) | 📅 Planned |
| Phase 10 | Week 7 | MacBook Pro M3 Max migration | 📅 Planned |
| Phase 11 | Week 8 | MacBook Air migrations | 📅 Planned |

---

## ⚠️ Important Notes

### Testing Policy
- **Claude's Role**: Write code, configuration, and documentation ONLY
- **FX's Role**: ALL testing, execution, and validation
- **Never**: Run bootstrap scripts, nix-darwin commands, or test on production hardware
- **Always**: Test in VM first, then physical hardware

### Update Philosophy
- **All app updates** controlled via `rebuild` or `update` commands only
- **No auto-updates** for any application (Homebrew, Zed, VSCode, Arc, etc.)
- **Reproducibility**: Same config version = same app versions guaranteed

### Security
- **No secrets in Git**: License keys and API tokens managed separately
- **SSH keys**: Generated locally, never transmitted
- **FileVault**: Encryption enforced on all machines
- **Firewall**: Enabled by default with stealth mode

---

## 🤝 Contributing

This is primarily a personal configuration repository, but contributions and suggestions are welcome:

1. Review [REQUIREMENTS.md](./REQUIREMENTS.md) for project scope
2. Check [STORIES.md](./STORIES.md) for current implementation status
3. Reference story IDs in pull request descriptions
4. Follow [Story Management Protocol](./CLAUDE.md#story-management-protocol)
5. Ensure changes align with project philosophy (declarative, reproducible, maintainable)

---

## 📄 License

This project is open source and available for reference and adaptation. See individual package licenses for third-party software installed via this configuration.

---

## 🙏 Acknowledgments

- **[mlgruby/dotfile-nix](https://github.com/mlgruby/dotfile-nix)**: Reference implementation for architecture patterns
- **Nix Community**: For nix-darwin, Home Manager, and Stylix
- **Claude Code**: Development assistance and documentation

---

**Built with**: Nix + nix-darwin + Home Manager + Stylix + Catppuccin + ❤️
