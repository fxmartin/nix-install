# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository implements an automated, declarative MacBook configuration system using Nix, nix-darwin, and Home Manager. The goal is to transform a fresh macOS install into a fully configured development environment in <30 minutes with zero manual intervention (except license activations).

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
   - 4 Ollama models (`gpt-oss:20b`, `qwen2.5-coder:32b`, `llama3.1:70b`, `deepseek-r1:32b`)
   - ~120GB disk usage

### Package Management Strategy (Priority Order)

1. **Nix First** (via nixpkgs-unstable): CLI tools, dev tools, Python 3.12, uv, ruff, Podman, etc.
2. **Homebrew Casks**: GUI apps (Zed, Ghostty, Arc, Firefox, Claude Desktop, etc.)
3. **Mac App Store (mas)**: Only when no alternative (Kindle, WhatsApp)
4. **Manual**: Licensed software (Office 365)

**Why nixpkgs-unstable**: Latest packages, better macOS arm64 support, faster updates. Flake lock provides reproducibility despite "unstable" name.

### Theming System

**Stylix** manages system-wide theming:
- **Theme**: Catppuccin (Latte for light mode, Mocha for dark mode)
- **Font**: JetBrains Mono Nerd Font with ligatures
- **Auto-switch**: Follows macOS system appearance (light/dark)
- **Applies to**: Ghostty (terminal), Zed (editor), shell, and other Stylix-supported apps
- **Goal**: Visual consistency when switching between terminal and editor

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

Apps requiring auto-update disable: Homebrew, Zed, VSCode, Arc, Firefox, Dropbox, 1Password, Zoom, Webex, Raycast, Ghostty, macOS system updates.

## Development Workflow

### Testing Strategy (CRITICAL)

**DO NOT TEST ON PHYSICAL HARDWARE FIRST**. Always follow this sequence:

1. **VM Testing (Required)**: Test in Parallels macOS VM first
   - Create fresh macOS VM (4+ CPU cores, 8+ GB RAM, 100+ GB disk)
   - Test Power profile (matches MacBook Pro M3 Max complexity)
   - Iterate until bootstrap succeeds with zero manual intervention
   - Final validation: Destroy VM, rebuild from scratch (must be flawless)

2. **Physical Hardware**: Only after VM testing successful
   - First: MacBook Pro M3 Max (Power profile)
   - Then: MacBook Air #1 and #2 (Standard profile)

### Key Files

**Currently Implemented**:
- `REQUIREMENTS.md`: Comprehensive PRD (1600+ lines) - **THE SOURCE OF TRUTH**
- `README.md`: Quick start guide
- `config/config.ghostty`: Ghostty terminal configuration (Catppuccin theme)
- `setup.sh`: Legacy setup script (will be replaced by new bootstrap)
- `mlgruby-repo-for-reference/`: Reference implementation to learn from

**To Be Implemented** (per REQUIREMENTS.md):
- `flake.nix`: System definition with Standard/Power profiles
- `user-config.nix`: User personal info (created during bootstrap)
- `darwin/`: System-level configs (nix-darwin)
  - `configuration.nix`, `homebrew.nix`, `macos-defaults.nix`, `system-monitoring.nix`, `nix-settings.nix`
- `home-manager/`: User-level configs (dotfiles)
  - `modules/zsh.nix`, `modules/git.nix`, `modules/starship.nix`, `modules/aliases.nix`, etc.
- `scripts/bootstrap.sh`: New bootstrap script (6-phase installation)
- `docs/`: User documentation (quick-start, troubleshooting, customization)

### Implementation Phases (8-Week Plan)

**Phase 0-2** (Week 1-2): Foundation + bootstrap script
**Phase 3-5** (Week 3-4): Apps, system config, dev environment
**Phase 6-8** (Week 5-6): Theming, monitoring, documentation
**Phase 9** (Week 6): **VM Testing** (required before hardware)
**Phase 10** (Week 7): MacBook Pro M3 Max migration
**Phase 11** (Week 8): MacBook Air migrations

See REQUIREMENTS.md Implementation Plan section for detailed checklists.

## Working with This Codebase

### Understanding the mlgruby Reference

`mlgruby-repo-for-reference/dotfile-nix/` is a **production-grade reference implementation** to learn from:
- Proven architecture (nix-darwin + Home Manager + Stylix)
- 35+ Nix files showing modular design patterns
- Comprehensive documentation (50+ markdown files)
- **Do not copy blindly** - it has AWS-specific config, different app choices
- **Do copy patterns**: Module structure, flake setup, Stylix integration, Home Manager patterns

### Key Architectural Decisions

1. **No Homebrew Pre-Installation**: Bootstrap installs Nix first, then nix-darwin manages Homebrew declaratively
2. **Profile-Based Flake**: Single flake.nix with `darwinConfigurations.standard` and `darwinConfigurations.power`
3. **SSH Key Before Clone**: Generate SSH key, display to user, wait for GitHub upload, test connection, then clone repo
4. **Stylix for Consistency**: System-wide theming ensures Ghostty and Zed match visually
5. **Modular Home Manager**: One concern per file (zsh.nix, git.nix, etc.) not monolithic config

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

### Working with REQUIREMENTS.md

**REQUIREMENTS.md is the single source of truth** for:
- All P0 (must-have), P1 (should-have), P2 (nice-to-have) requirements
- Acceptance criteria for each feature
- App inventory with installation methods
- System preferences to automate (Finder, trackpad, security, etc.)
- Bootstrap flow diagrams
- Profile comparison tables
- Risk analysis and mitigation

**When implementing**: Cross-reference requirements (e.g., REQ-BOOT-001, REQ-APP-002) in code comments and commit messages.

## Configuration Preferences

### User Expectations (from ~/.claude/CLAUDE.md)

- Address user as **"FX"** (not "the user" or "the human")
- Simple, maintainable solutions over clever/complex
- **NEVER use --no-verify** when committing
- Match existing code style and formatting
- **NEVER remove code comments** unless provably false
- Test output must be pristine (no exceptions to testing policy)
- Prefer `uv` for Python package management
- Conventional commit format, imperative mood, present tense
- Always add `ABOUTME:` comment at top of new files

### Testing Requirements

- Unit tests, integration tests, AND end-to-end tests required (no exceptions without explicit authorization)
- TDD: Write tests before implementation
- Test output must be pristine - logs/errors must be captured and tested

### Git Commit Template

```
<type>: <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Important Constraints

1. **No auto-updates**: Every app must have auto-update disabled. `rebuild` is the ONLY update mechanism.
2. **VM testing required**: Never test directly on physical MacBooks until VM testing passes.
3. **nixpkgs-unstable**: Use unstable channel for latest packages, flake.lock ensures reproducibility.
4. **Stylix theming**: Ghostty and Zed must use matching Catppuccin themes via Stylix.
5. **Two profiles only**: Standard (Air) and Power (Pro M3 Max). Don't create additional profiles without approval.
6. **Public repo**: Configuration is public (exclude secrets, use SOPS/age for P1 phase).

## Reference Documentation

- **Primary**: `REQUIREMENTS.md` (comprehensive PRD)
- **Reference**: `mlgruby-repo-for-reference/dotfile-nix/` (production example)
- **User preferences**: `~/.claude/CLAUDE.md`, `~/.claude/docs/*.md`
- **Ghostty config**: `config/config.ghostty` (template for Home Manager)
