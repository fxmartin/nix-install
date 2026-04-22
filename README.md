# Nix-Darwin MacBook Setup System

> **Status**: 98.0% Complete (144/147 stories) | **Version**: 1.0.0 + Epic-08 | **🎉 2 MacBooks Running!**

**Four MacBooks. One config. Zero drift.**

I got tired of my machines slowly becoming strangers — different tools here, tweaked settings there, no idea what I changed six months ago. So I built this.

One git repo defines everything. Push a change, rebuild, and all machines stay perfectly in sync. Fresh MacBook? 30 minutes to identical setup.

The stack: **Nix + nix-darwin + Home Manager** for declarative, atomic, rollback-capable configuration — plus an AI-powered release monitor that opens GitHub issues before I even know updates exist.

![Rebuild in action](./docs/images/rebuild-screenshot.png)
*A `rebuild` in action — Ghostty terminal with Catppuccin theme, iStat Menus monitoring, and system-wide consistency.*

---

## Quick Start

Run this single command on a fresh macOS installation:

```bash
curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/setup.sh | bash
```

**Installation time**: ~30 minutes (mostly automated, a few prompts)

### What happens during installation

1. **Pre-flight checks** — Verifies macOS version, disk space, internet
2. **User prompts** — Enter your name, email, and GitHub username
3. **Profile selection** — Choose Standard (MacBook Air), Power (MacBook Pro), or AI-Assistant (personal AI machine)
4. **Xcode CLI tools** — Installs automatically if needed
5. **Nix installation** — Multi-user Nix with flakes enabled
6. **SSH key setup** — Generates key, you add it to GitHub (prompted with instructions)
7. **Repository clone** — Clones this repo to `~/.config/nix-install`
8. **System build** — Runs `darwin-rebuild` to configure everything
9. **Post-install summary** — Shows next steps for license activation

### Requirements

- **macOS**: Sonoma 14.0+ (Apple Silicon or Intel)
- **Disk space**: 20GB (AI-Assistant), 35GB (Standard), or 120GB (Power profile)
- **Internet**: Required throughout installation
- **GitHub account**: For SSH key authentication

### Manual steps after installation

1. **Restart Terminal** or run `source ~/.zshrc`
2. **Enable FileVault** if not already enabled (System Settings → Privacy & Security)
3. **Mac App Store apps** (if you skipped during install):
   ```bash
   # Note: mas 4.0+ requires sudo for install commands (auto-prompts)
   mas install 6714467650  # Perplexity
   mas install 302584613   # Kindle
   mas install 890031187   # Marked 2
   mas install 310633997   # WhatsApp
   ```
4. **Activate licenses** — See [Licensed Apps Guide](./docs/licensed-apps.md):
   - 1Password, Dropbox, NordVPN (sign in)
   - iStat Menus, Parallels (enter license key)
   - Zoom, Webex (sign in)
   - Office 365 (Microsoft account sign-in)

---

## Common Commands

After installation, manage your system with these aliases:

| Command | Description |
|---------|-------------|
| `rebuild` | Apply config changes (refuses if free disk <10 GB; `--force` bypasses) |
| `update` | Update flake.lock + rebuild (the ONLY way to update apps) |
| `gc` | User-profile garbage collection |
| `gc-system` | System-profile garbage collection (runs weekly as root LaunchDaemon) |
| `cleanup` | Full cleanup (GC + store optimization) |
| `disk-cleanup` | Prune Huggingface / browser / Docker / `~/.claude/projects` caches |
| `health-check` | System health report |
| `curl localhost:7780/metrics` | Apple Silicon metrics (CPU per-cluster, GPU, ANE, memory, power, thermal, top-5 processes) |
| `ollama-warm <model>` | Pin an Ollama model in RAM until evicted |
| `ollama-evict [model]` | Unload one model (or all loaded) |
| `ollama-lru` | Report Ollama models not used in >30 days (opt-in `--prune`) |
| `audit-launchagents` | Sample median RSS of all managed LaunchAgents |
| `brew-upgrade` | Update Homebrew packages |
| `release-monitor` | Run AI-powered update checker |

**Rollback** if something breaks:
```bash
darwin-rebuild --rollback  # Instant rollback to previous generation
```

---

## Update Philosophy

**All app updates are controlled via commands only. Auto-updates are disabled everywhere.**

### Why No Auto-Updates?

| Benefit | Explanation |
|---------|-------------|
| **Reproducibility** | Same config = same versions = identical system state across machines |
| **Control** | You choose when to update, not apps updating randomly |
| **Testing** | Update one machine first, verify it works, then update others |
| **Rollback** | If an update breaks something, instant rollback to previous state |
| **No Surprises** | Apps don't change behavior unexpectedly mid-workday |

### rebuild vs update

```
┌─────────────────────────────────────────────────────────────────┐
│  rebuild                           │  update                    │
├─────────────────────────────────────────────────────────────────┤
│  • Uses current flake.lock         │  • Updates flake.lock      │
│  • Same package versions           │  • Gets latest versions    │
│  • Fast (packages cached)          │  • Downloads new packages  │
│  • For config changes only         │  • THE way to update apps  │
└─────────────────────────────────────────────────────────────────┘
```

**`rebuild`** — Apply configuration changes
- Use after editing any `.nix` file
- Adds/removes apps, changes settings, updates dotfiles
- Package versions stay the same (from `flake.lock`)
- Fast because most packages are already cached

**`update`** — Update all packages and rebuild
- Updates `flake.lock` to latest versions from nixpkgs
- Then runs a rebuild with new versions
- This is the **ONLY** way apps update
- Run weekly or when you want latest versions

### Checking for Available Updates

```bash
cd ~/Documents/nix-install
nix flake metadata                      # See current input versions
nix flake update --dry-run              # Preview what would update
```

### Rollback if Something Breaks

Every `rebuild` creates a new "generation" you can rollback to:

```bash
darwin-rebuild --list-generations       # List all available generations
darwin-rebuild --rollback               # Rollback to previous generation
```

Rollback is instant — no re-downloading, just switches symlinks.

### Multi-Machine Update Strategy

1. Run `update` on **one machine** first (e.g., MacBook Pro)
2. Test for a day — verify apps work, no regressions
3. If good, run `update` on other machines
4. If broken, `rollback` and wait for fix upstream

---

## What Gets Installed

### Applications (50+ apps)

**AI & LLM Tools**:
- Claude Desktop, Claude Code CLI, ChatGPT, Perplexity
- Ollama (Power profile: `gemma4:e4b` + `gemma4:26b` + `nomic-embed-text`; Standard: `ministral-3:14b` + `nomic-embed-text`; AI-Assistant: `nomic-embed-text`)
- LM Studio (local LLM GUI)

**Development**:
- Zed Editor (GPU-accelerated, Catppuccin themed)
- Ghostty terminal (Catppuccin themed)
- Python 3.12 + uv + ruff + black + mypy + pylint
- Podman + Podman Desktop (rootless containers)
- Git + Git LFS + GitHub CLI
- Node.js (for npx/npm tooling)
- Language servers (pyright, typescript, bash, yaml, etc.)

**Browsers**: Brave

**Productivity**:
- 1Password + 1Password for Safari
- Obsidian (knowledge base / notes)
- Plaud (AI voice recorder and transcription)
- Dropbox (cloud storage)
- Calibre, Kindle, Marked 2, Keka
- Office 365 (Word, Excel, PowerPoint, Outlook, OneNote, Teams)
- reMarkable desktop

**Communication**: WhatsApp, Zoom, Webex

**Media**: VLC

**Security**: NordVPN, Tailscale, Little Snitch

**System**: iStat Menus, OnyX, f.lux, btop, gotop, macmon

**Power Profile Only**: Parallels Desktop, additional Ollama models

### System Configuration

- **Finder**: List view, show hidden files, path bar, status bar
- **Dock**: Auto-hide, small icons, no recent apps
- **Trackpad**: Tap-to-click, three-finger drag, natural scrolling off
- **Security**: Firewall enabled, stealth mode, FileVault prompt
- **Keyboard**: Fast key repeat, no auto-correct

### Shell Environment

- **Zsh** with Oh My Zsh (git plugin) + zsh-autosuggestions + syntax highlighting
- **Starship** prompt with Nerd Font icons (replaces Oh My Zsh themes)
- **FZF** fuzzy finder (Ctrl+R history, Ctrl+T files, Alt+C directories)
- **Zoxide** for smart directory jumping (frecency-based `z` command)
- **Modern CLI**: ripgrep, bat, eza, fd, httpie, tldr, mosh, scc
- **Document generation**: typst (markup → PDF)

### Theming

- **Catppuccin** Mocha (dark) and Latte (light)
- Auto-switches with macOS appearance
- Consistent across Ghostty, Zed, and shell

---

## Three Installation Profiles

| Feature | AI-Assistant | Standard | Power |
|---------|-------------|----------|-------|
| **Target** | Older MacBook (AI) | MacBook Air | MacBook Pro M3 Max |
| **Apps** | ~25 (minimal) | 47+ | 51+ |
| **Ollama Models** | 1 (embeddings) | 2 (~9GB) | 4 (~21GB) |
| **Docker** | No | Yes | Yes |
| **LSPs** | No | Yes | Yes |
| **Office/Video Conf** | No | Yes | Yes |
| **Parallels Desktop** | No | No | Yes |
| **Disk Usage** | ~20GB | ~35GB | ~120GB |

### Package Sources (Priority Order)

1. **Nix** (nixpkgs-unstable): CLI tools, Python, Podman, dev tools
2. **Homebrew Casks**: GUI apps (Zed, Ghostty, Arc, Claude Desktop)
3. **Mac App Store**: Only when no alternative (Kindle, WhatsApp)

### Key Design Principles

- **Declarative**: Configuration IS the documentation—no drift
- **Atomic Updates**: All-or-nothing with instant rollback
- **No Auto-Updates**: All updates via `rebuild`/`update` only
- **Stylix Theming**: System-wide Catppuccin with auto light/dark
- **AI Release Monitor**: Weekly scans → GitHub issues → Claude Code integration

---

## Automated Maintenance

The system runs **automated maintenance** via LaunchAgents/LaunchDaemons:

| Schedule | Task | Description |
|----------|------|-------------|
| Daily 3:00 AM | Garbage Collection | Removes old generations, frees disk space |
| Daily 3:30 AM | Store Optimization | Deduplicates Nix store via hard links |
| Sunday 4:00 AM | System-Level GC (daemon) | Root-owned `nix-collect-garbage --delete-older-than 30d` — keeps system generations <20 |
| Sunday 7:00 AM | Release Monitor | AI-powered update analysis (see below) |
| Sunday 8:00 AM | Weekly Digest | Health report email with week-over-week disk growth per consumer |
| Weekly | Claude Projects Prune | `~/.claude/projects/*` archived after 90 days (memory preserved) |
| Monthly | Disk Cleanup | Huggingface / browser / Docker caches pruned with retention windows |
| Quarterly | Docker Deep Prune | `docker system prune -a --volumes` on the 1st of each quarter |
| Every 60s | Ollama Pressure Guard | Auto-unloads Ollama models on `warn`/`critical` memory pressure (when no active request) |

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
├── flake.nix                 # System definition (Standard/Power/AI-Assistant profiles)
├── bootstrap.sh              # Interactive installer (9 phases)
├── darwin/                   # System-level nix-darwin configs
│   ├── configuration.nix     # System packages, PATH
│   ├── homebrew.nix          # Casks, brews, Mac App Store
│   ├── macos-defaults.nix    # Finder, Dock, trackpad, security
│   ├── maintenance.nix       # User-level LaunchAgents (GC, digest, Ollama)
│   ├── maintenance-system.nix # Root-level LaunchDaemons (system GC)
│   ├── monitoring.nix        # Beszel agent + custom sensors
│   ├── health-api.nix        # Health API HTTP server (port 7780)
│   └── stylix.nix            # Catppuccin theming
├── home-manager/modules/     # User-level dotfiles
│   ├── shell.nix             # Zsh + Oh My Zsh + Starship + FZF + ollama-warm/evict
│   ├── git.nix               # Git config + LFS
│   ├── ghostty.nix           # Terminal with Catppuccin
│   ├── zed.nix / vscode.nix  # Editor configs
│   ├── python.nix            # Python + uv + ruff
│   ├── podman.nix            # Container development
│   └── claude-code.nix       # Claude Code CLI + MCP servers
├── config/sketchybar/        # Status bar (Epic-08)
│   └── plugins/              # system.sh, cpu_cluster, gpu, ane, power, temp, memory, vitals
├── scripts/                  # Maintenance & monitoring
│   ├── health-api.py         # /metrics endpoint (macmon background thread)
│   ├── health-check.sh       # System health validation
│   ├── release-monitor.sh    # AI-powered update checker
│   ├── disk-cleanup.sh       # HF / browser / Docker / claude-projects pruning
│   ├── ollama-lru.sh         # Stale Ollama model reporter / pruner
│   ├── ollama-pressure-guard.sh  # Memory-pressure auto-unload
│   ├── audit-launchagents.sh # Steady-state RSS audit
│   ├── claude-cleanup.sh     # Orphan kill + --prune-old
│   ├── beszel-sensors/       # Custom Beszel sensors (power, temp_cpu, temp_gpu)
│   └── weekly-maintenance-digest.sh
└── docs/                     # Documentation (Epic-07)
```

---

## Progress

| Epic | Focus | Status |
|------|-------|--------|
| **01** | Bootstrap & Installation | ✅ 100% |
| **02** | Application Installation | ✅ 100% |
| **03** | System Configuration | ✅ 100% |
| **04** | Development Environment | ✅ 100% |
| **05** | Theming & Visual Consistency | ✅ 100% |
| **06** | Maintenance & Monitoring | ✅ 100% |
| **07** | Documentation & UX | ✅ 100% |
| **08** | Resource Optimization & Deep Telemetry | 🟢 96% (22/23) |
| **NFR** | Non-Functional Requirements | 🟢 87% |

**🎉 Milestone (2025-12-07)**: MacBook Pro M3 Max successfully running Power profile!
- Shell startup: 259ms (target <500ms) ✅
- Rebuild time: 14 seconds (target <5min) ✅
- All 27 Homebrew apps installed, 5 Ollama models verified

**🎉 Milestone (2026-04-22)**: Epic-08 — Resource Optimization & Deep Telemetry, 22/23 stories shipped in ~18 hours across 24 PRs. SketchyBar now exposes per-cluster E/P CPU, GPU + ANE, power (W), silicon temps (°C) and a full mactop-replacement vitals popup — all driven by a single `/metrics` poll per tick.

### Project Statistics

| Category | Metric |
|----------|--------|
| **Commits** | 735 (+218 since v1.0.0) |
| **Development** | ~20 active days (v1.0.0) + 2 days (Epic-08 sprint), ~96 hours total |
| **Code** | 19K lines (Nix + Shell + Python) |
| **Tests** | 1,140 test cases (16 BATS files) |
| **Documentation** | 46K lines across 137 markdown files |
| **GitHub Issues** | Epic-08 #236–#258 (23 stories) + follow-up fixes #269–#285 |
| **Packages** | 26 casks, 4 brews, 4 MAS, 50+ Nix |

**Next**: MacBook Air migrations (Phase 11) · Story 08.3-008 (one-day mactop-free validation)

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
