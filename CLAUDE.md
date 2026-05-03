# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository implements an automated, declarative MacBook configuration system using Nix, nix-darwin, and Home Manager. The goal is to transform a fresh macOS install into a fully configured development environment in <30 minutes with zero manual intervention (except license activations).

**Status**: ✅ **v1.2.1 Released** - All 7 epics complete, ~78 hours development effort

**Target User**: FX manages 4 MacBooks (1x MacBook Pro M3 Max, 1x MacBook Pro M1 2021, 2x MacBook Air) with periodic reinstalls. Split usage between Office 365 work and weekend Python development.

**Key Philosophy**:
- **Declarative**: Configuration IS the documentation (no drift)
- **Reproducible**: Same config → identical system state
- **Atomic**: All-or-nothing updates with instant rollback capability
- **No Auto-Updates**: All app updates controlled via `rebuild` command only

## Architecture

### Three-Tier Installation Profiles

1. **Standard Profile** (MacBook Air targets):
   - Core apps, Ollama models (`ministral-3:14b`, `nomic-embed-text`)
   - No virtualization
   - ~35GB disk usage

2. **Power Profile** (MacBook Pro M3 Max target):
   - Same cask set as Standard, plus NAS backup (rsync), SMB automount, iCloud proposal sync
   - 3 Ollama models (`gemma4:e4b`, `gemma4:26b`, `nomic-embed-text`)
   - ~80GB disk usage (dominated by Ollama footprint)

3. **AI-Assistant Profile** (Older MacBook, personal AI assistant):
   - Minimal GUI: Ghostty, cmux, Claude, ChatGPT, Chrome, Zed, 1Password
   - No Docker, no LSPs, no Office, no video conferencing
   - 1 Ollama model (`nomic-embed-text` for RAG/search)
   - ~20GB disk usage

### Package Management Strategy (Priority Order)

1. **Nix First** (via nixpkgs-unstable): CLI tools, dev tools, Python 3.12, uv, ruff, Podman, etc.
2. **Homebrew Casks**: GUI apps (Zed, Ghostty, Arc, Firefox, Claude Desktop, etc.)
3. **Mac App Store (mas)**: Only when no alternative (Kindle, WhatsApp)
4. **Manual**: Licensed software (Office 365)

### Modular Bootstrap Architecture

The bootstrap system uses a modular architecture:
- **`lib/`**: 10 library modules (~5,000 lines total), one per installation phase
- **`bootstrap.sh`**: Orchestrator that sources lib/*.sh files (~360 lines)
- **`bootstrap-dist.sh`**: Built standalone version for curl-pipe installation (~5,135 lines)
- **`scripts/build-bootstrap.sh`**: Build script that concatenates modules

**For curl installation**: `setup.sh` downloads `bootstrap-dist.sh` (the standalone version)

### Theming System

**Stylix** manages system-wide theming:
- **Theme**: Catppuccin (Latte for light mode, Mocha for dark mode)
- **Font**: JetBrains Mono Nerd Font with ligatures
- **Auto-switch**: Follows macOS system appearance (light/dark)
- **Applies to**: Ghostty (terminal), Zed (editor), shell, and other Stylix-supported apps

### Shell Environment

- **Zsh** with **Oh My Zsh** (plugins: git, fzf, zsh-autosuggestions, z)
- **Starship** prompt (NOT Oh My Zsh themes - `ZSH_THEME=""`)
- **FZF** integration (Ctrl+R history, Ctrl+T files, Alt+C directories)
- **Ghostty** terminal with config from `config/config.ghostty`

### Update Control Philosophy

**Critical**: All app updates ONLY via `rebuild` or `update` commands:
- `rebuild`: Apply config changes (uses versions from flake.lock)
- `update`: Update flake.lock (gets latest versions) + rebuild
- Auto-updates disabled via: `HOMEBREW_NO_AUTO_UPDATE=1`, app configs, system defaults

### Release Versioning

Release numbering continues from the existing `v1.0.0` tag and uses semantic
versioning.

- `VERSION` is the repo-local release version mirror.
- `README.md` and this file must contain the same version as `VERSION`.
- Git tag `vX.Y.Z` is the release authority.
- Bump minor (`X.Y.0`) when a release contains feature enrichment.
- Bump patch (`X.Y.Z`) when a release contains only fixes.
- Never decrement versions.
- Breaking changes before a future `v2.0.0` may ship in minor releases, but
  they must be called out in the annotated tag message and release notes.
- Run `make bump-minor` for feature releases.
- Run `make bump-patch` for fix-only releases.
- Run `make verify-version` before tagging.
- Run `make release-tag` to create the annotated tag.
- `make release-tag` refuses dirty trees, non-`main` branches, duplicate tags,
  and version drift.
- Tag pushes stay manual: `git push origin main --tags`.
- Run `make install-hooks` once per clone to enable the tracked local pre-push
  version drift gate. The tracked pre-commit hook delegates to the Home Manager
  gitleaks hook when present.
- GitHub Actions also runs the same version drift check on PRs and `main`.

## Project Structure

```
nix-install/
├── flake.nix                 # System definition (Standard/Power profiles)
├── bootstrap.sh              # Modular orchestrator (sources lib/*.sh)
├── bootstrap-dist.sh         # Built standalone version for installation
├── setup.sh                  # Curl-pipeable wrapper
├── lib/                      # Modular library files
│   ├── common.sh             # Shared logging and utilities
│   ├── preflight.sh          # Phase 1: Pre-flight checks
│   ├── user-config.sh        # Phase 2: User configuration
│   ├── xcode.sh              # Phase 3: Xcode CLI tools
│   ├── nix-install.sh        # Phase 4: Nix installation
│   ├── nix-darwin.sh         # Phase 5: nix-darwin setup
│   ├── ssh-github.sh         # Phase 6: SSH key and GitHub
│   ├── repo-clone.sh         # Phase 7: Repository clone
│   ├── darwin-rebuild.sh     # Phase 8: Final rebuild
│   └── summary.sh            # Phase 9: Installation summary
├── darwin/                   # System-level nix-darwin configs
│   ├── configuration.nix     # System packages, PATH
│   ├── homebrew.nix          # Casks, brews, Mac App Store
│   ├── macos-defaults.nix    # Finder, Dock, trackpad, security
│   ├── maintenance.nix       # User-level LaunchAgents (GC, digest, Ollama, pressure-guard, claude-cleanup)
│   ├── maintenance-system.nix # Root LaunchDaemons (system-level nix-gc, Sunday 04:00)
│   ├── monitoring.nix        # Beszel agent LaunchAgent (port 45876) + custom sensors
│   ├── health-api.nix        # Health API HTTP server (port 7780)
│   └── stylix.nix            # Catppuccin theming
├── home-manager/modules/     # User-level dotfiles
│   ├── shell.nix             # Zsh + Oh My Zsh + Starship + FZF + ollama-warm/evict + rebuild guard
│   ├── git.nix               # Git config + LFS
│   ├── ghostty.nix           # Terminal with Catppuccin
│   ├── zed.nix / vscode.nix  # Editor configs
│   ├── python.nix            # Python + uv + ruff
│   ├── podman.nix            # Container development
│   └── claude-code.nix       # Claude Code CLI + MCP servers
├── config/sketchybar/        # Status bar (Epic-08 telemetry)
│   ├── sketchybarrc          # Bar layout, subscribes items to system_metrics_update
│   └── plugins/              # system.sh (aggregator), cpu_cluster, gpu, ane, power, temp, memory, vitals
├── scripts/                  # Build and maintenance scripts
│   ├── build-bootstrap.sh    # Build bootstrap-dist.sh from modules
│   ├── health-api.py         # /metrics endpoint (macmon on background thread, top-5 processes)
│   ├── health-check.sh       # System health validation
│   ├── release-monitor.sh    # AI-powered update checker
│   ├── disk-cleanup.sh       # HF / browser / Docker / claude-projects pruning (Epic-08 08.1)
│   ├── ollama-lru.sh         # LRU-based stale Ollama model pruning (Epic-08 08.1-004)
│   ├── ollama-pressure-guard.sh # Memory-pressure auto-unload (Epic-08 08.2-002)
│   ├── audit-launchagents.sh # Steady-state RSS audit over 10 samples (Epic-08 08.2-004)
│   ├── claude-cleanup.sh     # Orphan kill + --prune-old (Epic-08 08.1-006)
│   ├── weekly-maintenance-digest.sh # +collect_disk_metrics (Epic-08 08.1-008)
│   ├── beszel-sensors/       # Custom Beszel sensors (power.sh, temp.sh, temp_gpu.sh; Epic-08 08.4-002)
│   └── estimate_effort_v2.py # Development effort analysis
└── docs/                     # Documentation
```

## Development Guidelines

### Testing Strategy

**Claude's role**: Write code, configuration, and documentation.
**FX's role**: All testing, execution, and validation.

**Static analysis tools ARE allowed** (safe, read-only):
- `shellcheck` - Shell script linter
- `bash -n` - Syntax validation
- `bats` - Bash test framework (for read-only checks)

### Shell & Script Gotchas

Two foot-guns that have already bitten twice during Epic-08 work. Internalize before writing any new diagnostic snippet or maintenance script.

**1. FX's zsh aliases rewrite common binaries in interactive shells** (`home-manager/modules/shell.nix`):

| Typed | Actually runs |
|-------|---------------|
| `grep` | `rg` (ripgrep) — `-E` means `--engine`, **not** "extended regex" |
| `find` | `fd` — `-type f` parses as `-t ype f` and errors silently |
| `cat` | `bat` |
| `ls` | `eza --icons --group-directories-first` |

Escapes: `oldgrep` / `oldfind` / `oldcat` / `oldls`, `command <name>`, or an absolute path like `/usr/bin/find`. Bash subshells (scripts in `scripts/`) are unaffected — aliases are zsh interactive-only. **But any diagnostic one-liner pasted into FX's terminal must survive them.** When in doubt: `type grep` in the target shell.

**2. `set -euo pipefail` scripts must guard pipelines whose commands legitimately exit non-zero.** Under `pipefail`, any non-zero step kills the script even when the "failure" is the expected normal path. Common offenders in this codebase:

- `launchctl print gui/$UID/org.nixos.<label>` → non-zero when service not loaded (normal for scheduled one-shots)
- `ps -o rss= -p <pid>` → non-zero when pid has exited
- `grep <pat>` → non-zero on no-match
- `sed -nE 's/…/p'` → zero exit but empty stdout; downstream arithmetic on `""` then bombs

Rule: end every such pipeline with `|| true`, or wrap in `if … ; then`. For variable assignments from potentially-empty pipelines, default with `${var:-0}` before any arithmetic. Don't ship on `bash -n` alone — smoke-test with both a loaded and unloaded target before claiming done.

### Key Constraints

1. **No auto-updates**: Every app must have auto-update disabled. `rebuild` is the ONLY update mechanism.

2. **nixpkgs-unstable**: Use unstable channel for latest packages, flake.lock ensures reproducibility.

3. **Stylix theming**: Ghostty and Zed must use matching Catppuccin themes via Stylix.

4. **Three profiles**: Standard (Air), Power (Pro M3 Max), AI-Assistant (older MacBook). Don't create additional profiles without approval.

5. **Bootstrap synchronization**: When adding new .nix files, update the file download list in `lib/nix-darwin.sh`.

6. **Submodule discipline**: Never commit a parent pointer that ends in `-dirty`. Always land changes inside the submodule first, then bump the parent pointer. See workflow below.

### Git Submodule Workflow

This repo uses four submodules (see `.gitmodules`):

| Submodule | Type | Notes |
|-----------|------|-------|
| `config/claude-code-config` | **FX-owned, writable** | Claude Code hooks/settings/skills (`git@github.com:fxmartin/claude-code-config.git`). Edits originate here. |
| `config/oh-my-zsh-custom/plugins/zsh-autosuggestions` | Upstream, read-only | Bump only via `git submodule update --remote`. |
| `config/oh-my-zsh-custom/plugins/zsh-syntax-highlighting` | Upstream, read-only | Bump only via `git submodule update --remote`. |
| `config/oh-my-zsh-custom/themes/powerlevel10k` | Upstream, read-only | Bump only via `git submodule update --remote`. |

**Detecting a dirty submodule**: `git status` in the parent shows `modified: config/<name> (modified content, untracked content)` and `git diff` shows the SHA suffixed with `-dirty`. That suffix means there are uncommitted changes *inside* the submodule — do **not** stage that pointer until those are landed upstream.

**Commit & push workflow (FX-owned submodule)**:

```bash
SM=config/claude-code-config

# 1. Inspect what changed inside the submodule
git -C "$SM" status
git -C "$SM" diff

# 2. Commit inside the submodule (split unrelated changes into separate commits)
git -C "$SM" add <files>
git -C "$SM" commit -m "..."

# 3. Push — if rejected because remote moved (FX commits from another machine),
#    rebase onto origin/main rather than merge to keep linear history
git -C "$SM" fetch origin
git -C "$SM" rebase origin/main
git -C "$SM" push

# 4. Bump the pointer in the parent and commit
git add "$SM"
git commit -m "chore: bump claude-code-config submodule"
git push
```

**Rules:**
- Use `git -C <path>` from the parent repo root, **not** `cd` — the shell cwd can drift across chained commands and silently break the next step.
- Split unrelated submodule changes into separate logical commits before bumping the parent pointer (e.g. one feature + one doc tweak = two commits).
- On push rejection from the submodule, **rebase** (`git rebase origin/main`), do not merge.
- Pre-commit hooks (gitleaks, etc.) live inside the submodule's own repo and run on its commits — respect failures there as you would in the parent.

### Git Commit Template

```
<type>: <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### Common Nix Patterns

**Flake structure**:
```nix
inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs";  # Pin to same nixpkgs
```

**Profile differentiation**:
```nix
darwinConfigurations.power = mkDarwinConfiguration {
  isPowerProfile = true;
  profileName = "power";
  modules = [
    ./darwin/smb-automount.nix    # NAS mounts — Power-only
    ./darwin/rsync-backup.nix     # NAS backup — Power-only
    ./darwin/icloud-sync.nix      # Proposal sync — Power-only
    # ...postActivation pulls ollamaModels.power (3 models)
  ];
};
```

**Auto-update disable**:
```nix
environment.variables.HOMEBREW_NO_AUTO_UPDATE = "1";
programs.vscode.userSettings."update.mode" = "none";
```

## Configuration Preferences

- Address user as **"FX"** (not "the user" or "the human")
- Simple, maintainable solutions over clever/complex
- **NEVER use --no-verify** when committing
- Match existing code style and formatting
- **NEVER remove code comments** unless provably false
- Prefer `uv` for Python package management
- Conventional commit format, imperative mood, present tense
- Always add `ABOUTME:` comment at top of new files

## Reference Documentation

- **Primary**: `docs/REQUIREMENTS.md` (comprehensive PRD)
- **Progress**: `docs/development/progress.md` (metrics and milestones)
- **Stories**: `STORIES.md` + `/stories/epic-*.md` (detailed stories)
- **Apps**: `docs/apps/` (per-app configuration guides)
- **Reference**: `mlgruby-repo-for-reference/dotfile-nix/` (production example)

## GitHub Labels

Labels are managed via `scripts/setup-github-labels.sh`. Key categories:
- **Severity**: critical, high, medium, low
- **Type**: bug, enhancement, documentation, refactor
- **Epic**: epic-01 through epic-08, epic-nfr
- **Profile**: profile/standard, profile/power, profile/both

## Completed Milestones

| Date | Milestone |
|------|-----------|
| 2026-04-22 | Epic-08 SketchyBar Deep Telemetry shipped (Sprint 13, 7/8 stories; 08.3-008 validation pending) |
| 2026-04-21 | Epic-08 Disk Optimization + Memory Mitigation + Observability Polish shipped (Sprints 11, 12, 14) |
| 2025-12-07 | v1.0.0 Released - MacBook Pro M3 Max running Power profile |
| 2025-12-07 | Epic-01 Complete - Modular Bootstrap Architecture |
| 2025-12-06 | Epics 02-07 Complete |

### Performance Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| Shell startup | <500ms | 259ms ✅ |
| Rebuild time | <5min | 14s ✅ |
| Bootstrap (clean) | <30min | ~25min ✅ |
| `/metrics` p95 latency | <2s | sub-second (post #285) ✅ |
| System generation count (Power) | <20 | <20 after weekly system-GC daemon ✅ |

### Development Effort

| Metric | Value |
|--------|-------|
| Total commits | 735 (+218 since v1.0.0) |
| Active days | ~20 (v1.0.0) + 2 (Epic-08) |
| Estimated hours | ~96 (78 v1.0.0 + 18 Epic-08) |
| Issue completion | 83.3% (v1.0.0) / 96% (Epic-08) |
