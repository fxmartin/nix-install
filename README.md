# Nix-Darwin MacBook Setup System

> **Status**: 80% Complete (94/119 stories) | **Version**: 0.1.0 (Pre-Release)

A **proactive, AI-assisted macOS configuration system** using Nix + nix-darwin + Home Manager.

**What it does**:
- Transforms a fresh macOS install into a fully configured dev environment in <30 minutes
- Ensures 100% consistency across multiple MacBooks with atomic, rollback-capable updates
- **Proactively monitors** 50+ tools for updates, security patches, breaking changes, and new Ollama models
- Creates prioritized GitHub issues with implementation plans via Claude Code integration

---

## Quick Start

```bash
# One-line installation (when ready)
curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/setup.sh | bash
```

**Requirements**: macOS Sonoma 14.0+, Mac App Store signed in, 35-120GB free disk space.

**After installation**, manage your system with:

| Command | Description |
|---------|-------------|
| `rebuild` | Apply config changes (uses locked versions) |
| `update` | Update all Nix packages + rebuild |
| `brew-upgrade` | Update all Homebrew packages |
| `health-check` | System health report |
| `release-monitor` | Run AI-powered update checker |

---

## Architecture

### Two Installation Profiles

| Profile | Target | Disk | Key Differences |
|---------|--------|------|-----------------|
| **Standard** | MacBook Air | ~35GB | Core apps, 1 Ollama model |
| **Power** | MacBook Pro M3 Max | ~120GB | + Parallels, 4 Ollama models |

### Package Management (Priority Order)

1. **Nix** (nixpkgs-unstable): CLI tools, Python 3.12, uv, ruff, Podman
2. **Homebrew Casks**: GUI apps (Zed, Ghostty, Arc, Claude Desktop, Office 365)
3. **Mac App Store**: Only when no alternative (Kindle, WhatsApp)

### Key Features

- **Declarative**: Configuration IS the documentation—no drift
- **Atomic Updates**: All-or-nothing with instant rollback via `darwin-rebuild --rollback`
- **No Auto-Updates**: All updates controlled via `rebuild`/`update` commands only
- **Stylix Theming**: System-wide Catppuccin (Mocha/Latte) with auto light/dark switching
- **AI Release Monitor**: Weekly scans for updates → prioritized GitHub issues → Claude Code slash commands

---

## Automated Maintenance

The system runs **automated maintenance** via LaunchAgents:

| Schedule | Task | Description |
|----------|------|-------------|
| Daily 3:00 AM | Garbage Collection | Removes old generations, frees disk space |
| Daily 3:30 AM | Store Optimization | Deduplicates Nix store via hard links |
| Sunday 7:00 AM | Release Monitor | AI-powered update analysis (see below) |
| Sunday 8:00 AM | Weekly Digest | Health report email |

### Weekly Maintenance Digest (Example)

```
========================================
Weekly Maintenance Digest - MacBook-Pro
========================================
Report Period: 2025-11-29 to 2025-12-06

MAINTENANCE ACTIVITY
--------------------
Garbage Collection Runs: 7
Store Optimization Runs: 7

SYSTEM STATE
------------
Nix Store Size: 45G
Disk Free (/nix): 380G
System Generations: 12

SECURITY STATUS
---------------
FileVault: Enabled ✅
Firewall: Enabled ✅

RECOMMENDATIONS
---------------
• No issues detected. System is healthy! ✅
```

---

## AI-Powered Release Monitor

A unique feature: the system **proactively suggests improvements** rather than just maintaining config.

**Weekly pipeline** (Sunday 7 AM):
1. **Fetch** release notes from Homebrew, Nix, tracked tools
2. **Analyze** with Claude CLI → categorize by priority
3. **Create GitHub issues** with smart deduplication
4. **Email summary** grouped by category

### Release Monitor Email (Example)

```
=======================================================
        WEEKLY RELEASE MONITOR REPORT
=======================================================
Generated: Sun Dec 6 07:00:00 2025
Host: MacBook-Pro

STATUS: ATTENTION REQUIRED: Security updates found

SUMMARY
-------
🔴 Security Updates: 1
🟠 Breaking Changes: 0
🟢 New Features: 2
🤖 Ollama Models: 1
🔵 Notable Updates: 3

GITHUB ISSUES CREATED
---------------------
🔴 Security Updates:
  ca-certificates: https://github.com/fxmartin/nix-install/issues/64

🟢 New Features:
  ghostty: https://github.com/fxmartin/nix-install/issues/65

🔵 Notable Updates:
  python: https://github.com/fxmartin/nix-install/issues/66

NEXT STEPS
----------
  - Review security updates immediately
  - Consider adopting new features
```

### Claude Code Integration

```bash
/release-updates          # List pending updates
/plan-release-update 64   # Get implementation plan for issue #64
```

**Priority categories**: Security (HIGH) → Breaking Changes (HIGH) → New Features (MEDIUM) → Notable Updates (LOW)

---

## Project Structure

```
nix-install/
├── flake.nix                 # System definition (Standard/Power profiles)
├── bootstrap.sh              # Interactive installer (9 phases)
├── darwin/                   # System-level nix-darwin configs
│   ├── configuration.nix     # System packages, PATH
│   ├── homebrew.nix          # Casks, brews, Mac App Store
│   ├── macos-defaults.nix    # Finder, Dock, trackpad, security
│   ├── maintenance.nix       # GC, optimization, LaunchAgents
│   └── stylix.nix            # Catppuccin theming
├── home-manager/modules/     # User-level dotfiles
│   ├── shell.nix             # Zsh + Oh My Zsh + Starship + FZF
│   ├── git.nix               # Git config + LFS
│   ├── ghostty.nix           # Terminal with Catppuccin
│   ├── zed.nix / vscode.nix  # Editor configs
│   ├── python.nix            # Python + uv + ruff
│   ├── podman.nix            # Container development
│   └── claude-code.nix       # Claude Code CLI + MCP servers
├── scripts/                  # Maintenance & monitoring
│   ├── health-check.sh       # System health validation
│   ├── release-monitor.sh    # AI-powered update checker
│   └── weekly-maintenance-digest.sh
└── docs/                     # Documentation (Epic-07)
```

---

## Progress

| Epic | Focus | Status |
|------|-------|--------|
| **01** | Bootstrap & Installation | 🟢 89.5% (functional) |
| **02** | Application Installation | ✅ 100% |
| **03** | System Configuration | ✅ 100% |
| **04** | Development Environment | ✅ 100% |
| **05** | Theming & Visual Consistency | ✅ 100% |
| **06** | Maintenance & Monitoring | ✅ 100% |
| **07** | Documentation & UX | ⚪ Not Started |

**Next**: Epic-07 will add quick-start guides, troubleshooting docs, and customization guides.

---

## Documentation

| Document | Purpose |
|----------|---------|
| [REQUIREMENTS.md](./docs/REQUIREMENTS.md) | Complete PRD (1,700+ lines) |
| [STORIES.md](./STORIES.md) | Epic overview & story tracking |
| [/stories/](./stories/) | Detailed epic files (source of truth) |
| [CLAUDE.md](./CLAUDE.md) | Developer guidance & architecture |
| [/docs/apps/](./docs/apps/) | Per-app configuration guides |

---

## Technologies

- **[Nix](https://nixos.org/)** + **[nix-darwin](https://github.com/LnL7/nix-darwin)** + **[Home Manager](https://github.com/nix-community/home-manager)**: Declarative system & dotfile management
- **[Stylix](https://github.com/danth/stylix)**: System-wide theming
- **[Claude Code](https://claude.ai/code)**: AI-assisted development & release monitoring

---

## Acknowledgments

- **[mlgruby/dotfile-nix](https://github.com/mlgruby/dotfile-nix)**: Reference implementation
- **Nix Community**: For the incredible ecosystem

---

**Built with**: Nix + nix-darwin + Home Manager + Stylix + Claude Code
