# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository implements an automated, declarative MacBook configuration system using Nix, nix-darwin, and Home Manager. The goal is to transform a fresh macOS install into a fully configured development environment in <30 minutes with zero manual intervention (except license activations).

**Status**: ✅ **v1.0.0 Released** - All 7 epics complete, ~78 hours development effort

**Target User**: FX manages 3 MacBooks (1x MacBook Pro M3 Max, 2x MacBook Air) with periodic reinstalls. Split usage between Office 365 work and weekend Python development.

**Key Philosophy**:
- **Declarative**: Configuration IS the documentation (no drift)
- **Reproducible**: Same config → identical system state
- **Atomic**: All-or-nothing updates with instant rollback capability
- **No Auto-Updates**: All app updates controlled via `rebuild` command only

## Architecture

### Two-Tier Installation Profiles

1. **Standard Profile** (MacBook Air targets):
   - Core apps, single Ollama model (`gpt-oss:20b`)
   - No virtualization
   - ~35GB disk usage

2. **Power Profile** (MacBook Pro M3 Max target):
   - All Standard apps + Parallels Desktop
   - 2 Ollama models (`gpt-oss:20b`, `ministral-3:14b`)
   - ~120GB disk usage

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

### Claude Code + Get Shit Done (GSD)

The system includes **[Get Shit Done](https://github.com/glittercowboy/get-shit-done)** for spec-driven development:
- **Installation**: Automatic via `npx get-shit-done-cc --global` during darwin-rebuild
- **Location**: `~/.claude/commands/gsd/`
- **Key commands**: `/gsd:new-project`, `/gsd:create-roadmap`, `/gsd:plan-phase`, `/gsd:execute-phase`
- **Update**: `npx get-shit-done-cc@latest`

GSD solves context degradation by running each task in fresh subagent contexts (200k tokens each).

### Update Control Philosophy

**Critical**: All app updates ONLY via `rebuild` or `update` commands:
- `rebuild`: Apply config changes (uses versions from flake.lock)
- `update`: Update flake.lock (gets latest versions) + rebuild
- Auto-updates disabled via: `HOMEBREW_NO_AUTO_UPDATE=1`, app configs, system defaults

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
│   ├── maintenance.nix       # GC, optimization, LaunchAgents
│   └── stylix.nix            # Catppuccin theming
├── home-manager/modules/     # User-level dotfiles
│   ├── shell.nix             # Zsh + Oh My Zsh + Starship + FZF
│   ├── git.nix               # Git config + LFS
│   ├── ghostty.nix           # Terminal with Catppuccin
│   ├── zed.nix / vscode.nix  # Editor configs
│   ├── python.nix            # Python + uv + ruff
│   ├── podman.nix            # Container development
│   └── claude-code.nix       # Claude Code CLI + MCP servers + GSD
├── scripts/                  # Build and maintenance scripts
│   ├── build-bootstrap.sh    # Build bootstrap-dist.sh from modules
│   ├── health-check.sh       # System health validation
│   ├── release-monitor.sh    # AI-powered update checker
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

### Key Constraints

1. **No auto-updates**: Every app must have auto-update disabled. `rebuild` is the ONLY update mechanism.

2. **nixpkgs-unstable**: Use unstable channel for latest packages, flake.lock ensures reproducibility.

3. **Stylix theming**: Ghostty and Zed must use matching Catppuccin themes via Stylix.

4. **Two profiles only**: Standard (Air) and Power (Pro M3 Max). Don't create additional profiles without approval.

5. **Bootstrap synchronization**: When adding new .nix files, update the file download list in `lib/nix-darwin.sh`.

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
darwinConfigurations.power = {
  homebrew.casks = [ "parallels" ];  # Power-only
  system.activationScripts.pullOllamaModels = ''...'';  # Power-only
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
- **Epic**: epic-01 through epic-07, epic-nfr
- **Profile**: profile/standard, profile/power, profile/both

## Completed Milestones

| Date | Milestone |
|------|-----------|
| 2025-12-07 | v1.0.0 Released - MacBook Pro M3 Max running Power profile |
| 2025-12-07 | Epic-01 Complete - Modular Bootstrap Architecture |
| 2025-12-06 | Epics 02-07 Complete |

### Performance Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| Shell startup | <500ms | 259ms ✅ |
| Rebuild time | <5min | 14s ✅ |
| Bootstrap (clean) | <30min | ~25min ✅ |

### Development Effort

| Metric | Value |
|--------|-------|
| Total commits | 430+ |
| Active days | 18 |
| Estimated hours | ~78 |
| Issue completion | 83.3% |
