# Nix-Darwin MacBook Setup System

> **Status**: 🔄 Planning Complete - Implementation Starting
> **Version**: 0.1.0 (Pre-Release)
> **Last Updated**: 2025-11-08

Automated, declarative MacBook configuration system using Nix + nix-darwin + Home Manager. Transform a fresh macOS installation into a fully configured development environment in <30 minutes with zero manual intervention (except license activations).

---

## 🎯 Project Vision

**Problem**: Managing 3 MacBooks with periodic reinstalls is time-consuming (4-6 hours per install) and error-prone. Configuration drift occurs between machines, and there's no rollback mechanism when changes break the system.

**Solution**: Declarative configuration-as-code that reduces setup time by 90%, ensures 100% consistency across machines, and provides atomic updates with instant rollback capability.

**Target**: FX manages 3 MacBooks (1x MacBook Pro M3 Max, 2x MacBook Air) with periodic reinstalls. Split usage between Office 365 work and weekend Python development.

---

## 📊 Current Status

### ✅ Completed
- **Requirements Definition** ([REQUIREMENTS.md](./REQUIREMENTS.md)) - Comprehensive PRD with 1,700+ lines
- **User Story Breakdown** ([STORIES.md](./STORIES.md)) - 108 stories across 7 epics + NFR
- **Story Management Protocol** - Modular epic structure with detailed acceptance criteria
- **Requirements Baseline** - v1.1 approved (change control re-approval completed)
- **Project Architecture** - Two-tier profiles (Standard/Power), Stylix theming, nixpkgs-unstable
- **Story 01.1-001** - Phase 1: Pre-flight System Validation (✅ Merged to main)
- **Story 01.2-001** - Phase 2: User Information Prompts (✅ Ready for VM testing)

### 🔄 In Progress
- **Story 01.2-001** - VM testing by FX (branch: `feature/01.2-001`)
- **Epic-01: Bootstrap System** (Week 1-2) - 2/15 stories complete

### 📅 Upcoming
- **Phase 1-2**: Core bootstrap implementation (Week 2)
- **Phase 3-5**: Applications, system config, dev environment (Week 3-4)
- **Phase 6-8**: Theming, monitoring, documentation (Week 5-6)
- **Phase 9**: VM testing in Parallels (Week 6)
- **Phase 10-11**: Physical hardware migrations (Week 7-8)

---

## 📚 Documentation

### Essential Reading

1. **[REQUIREMENTS.md](./REQUIREMENTS.md)** - Complete product requirements document
   - Business objectives and success metrics
   - Detailed functional and non-functional requirements
   - Profile comparison (Standard vs Power)
   - Bootstrap flow diagrams
   - 8-week implementation plan

2. **[STORIES.md](./STORIES.md)** - User story overview and epic navigation
   - 108 total stories, 577 story points
   - Epic summaries and metrics
   - Sprint planning guidance
   - Cross-epic dependencies

3. **[/stories/](./stories/)** - Detailed epic files (single source of truth)
   - Epic-01: Bootstrap & Installation (15 stories, 89 points)
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
curl -sSL https://raw.githubusercontent.com/fxmartin/nix-install/main/bootstrap.sh | bash
```

This will:
1. **Pre-flight Validation**: Check system requirements (Story 01.1-001 ✅)
2. **User Information**: Collect name, email, GitHub username with validation (Story 01.2-001 ✅)
3. Install Xcode Command Line Tools
4. Select installation profile (Standard or Power)
5. Install Nix package manager with flakes enabled
6. Install nix-darwin and Homebrew (managed declaratively)
7. Generate SSH key and guide GitHub upload
8. Clone this repository and apply full configuration
9. Display post-install checklist (license activations, etc.)

**Estimated Time**: <30 minutes (mostly hands-off)

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
- **Verification**: Run `./verify-requirements-integrity.sh` to validate integrity
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
├── bootstrap.sh                 # One-command installation script
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
