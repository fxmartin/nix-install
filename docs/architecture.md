# ABOUTME: Architecture overview with module dependency diagrams
# ABOUTME: Visual reference for understanding how flake, darwin, and home-manager modules connect

# Architecture Overview

## Flake Structure

```
flake.nix
├── inputs
│   ├── nixpkgs (nixpkgs-unstable)
│   ├── nix-darwin
│   ├── home-manager
│   ├── nix-homebrew
│   ├── stylix (Catppuccin theming)
│   ├── claude-code-nix
│   └── mcp-servers-nix
│
├── darwinConfigurations.standard      ──┐
│                                        ├── commonModules
├── darwinConfigurations.power      ─────┤
│                                        │
├── darwinConfigurations.ai-assistant ───┘
│
└── helpers
    ├── ollamaModels { standard, power, ai-assistant }
    ├── mkOllamaModelScript (generates pull scripts)
    └── mkDarwinConfiguration (shared builder, passes profileName)
```

## Module Dependency Graph

```
                         flake.nix
                            │
              ┌─────────────┼─────────────────┬──────────────┐
              │             │                  │              │
              ▼             ▼                  ▼              ▼
     commonModules    standard-only      power-only    ai-assistant-only
                                                       (embeddings model)
              │                          │
    ┌─────────┼──────────┐     ┌────────┼────────┼────────┐
    │         │          │     │        │        │        │
    ▼         ▼          ▼     ▼        ▼        ▼        ▼
 darwin/   darwin/    darwin/ darwin/  darwin/  darwin/
 config    homebrew   macos   smb-    rsync-   icloud-
 .nix      .nix       def.   auto    backup   sync
                      nix    mount    .nix     .nix
    │         │
    │         ├── darwin/maintenance.nix ──── mkScheduledAgent
    │         │   ├── nix-gc           (7 LaunchAgents)
    │         │   ├── nix-optimize
    │         │   ├── weekly-digest
    │         │   ├── release-monitor
    │         │   ├── disk-cleanup
    │         │   ├── claude-code-cleanup  (StartInterval: 90min)
    │         │   └── ollama-serve
    │         │
    │         ├── darwin/health-api.nix
    │         ├── darwin/stylix.nix
    │         └── darwin/calibre.nix
    │
    └── home-manager/home.nix
         │
         ├── modules/shell.nix     (zsh, oh-my-zsh, starship, fzf, aliases)
         ├── modules/git.nix       (git, lfs, delta)
         ├── modules/ghostty.nix   (terminal config, Catppuccin theme)
         ├── modules/zed.nix       (editor settings, extensions)
         ├── modules/python.nix    (uv, ruff, mypy)
         ├── modules/claude-code.nix (CLI + MCP servers)
         ├── modules/ssh.nix       (SSH config, known hosts)
         ├── modules/docker.nix    (container runtime — not ai-assistant)
         └── modules/sketchybar.nix (status bar — not ai-assistant)
```

## Bootstrap Flow

```
setup.sh (curl-pipeable)
    │
    ▼
bootstrap-dist.sh (standalone, built from lib/*.sh)
    │
    ├── Phase 1: lib/preflight.sh      Pre-flight checks (macOS, disk, network)
    ├── Phase 2: lib/user-config.sh    Interactive user configuration
    ├── Phase 3: lib/xcode.sh          Xcode CLI tools
    ├── Phase 4: lib/nix-install.sh    Nix multi-user installation
    ├── Phase 5: lib/nix-darwin.sh     Download flake, first darwin-rebuild
    ├── Phase 6: lib/ssh-github.sh     SSH key + GitHub authentication
    ├── Phase 7: lib/repo-clone.sh     Clone repository
    ├── Phase 8: lib/darwin-rebuild.sh  Final rebuild from cloned repo
    └── Phase 9: lib/summary.sh        Installation summary
                                        │
                                  lib/common.sh (shared by all phases)
```

## Package Management Priority

```
┌─────────────────────────────────────────────────┐
│  1. Nix (nixpkgs-unstable)                      │
│     CLI tools, dev tools, Python, uv, ruff,     │
│     Podman, bat, ripgrep, fd, eza, etc.         │
├─────────────────────────────────────────────────┤
│  2. Homebrew Casks (via nix-homebrew)            │
│     GUI apps: Zed, Ghostty, Arc, Brave,         │
│     Claude Desktop, Ollama, etc.                │
├─────────────────────────────────────────────────┤
│  3. Mac App Store (via mas)                      │
│     Kindle, WhatsApp, 1Password Safari          │
├─────────────────────────────────────────────────┤
│  4. Manual                                       │
│     Office 365 (license activation)             │
└─────────────────────────────────────────────────┘
```

## Health Monitoring

```
                    ┌──────────────────┐
                    │  health-check.sh │ ← Interactive CLI (health-check alias)
                    │  (bash, colored) │
                    └──────────────────┘
                              │
                    Shared thresholds:
                    • GENERATION_WARNING: 50
                    • DISK_WARNING_GB: 20
                    • CACHE_WARNING_KB: 1MB
                              │
                    ┌──────────────────┐
                    │  health-api.py   │ ← HTTP JSON API (port 7780)
                    │  (Python, JSON)  │   /health, /metrics, /ping
                    └──────────────────┘   Accessible via Tailscale
                              │
                    Endpoints:
                    ├── /health  — Full system diagnostics
                    ├── /metrics — Apple Silicon stats (via macmon)
                    │   └── CPU, GPU, memory, thermal, power
                    └── /ping    — Liveness check
                              │
                    Health checks performed:
                    ├── Nix daemon
                    ├── Homebrew
                    ├── Disk space (Finder metric)
                    ├── FileVault / Firewall
                    ├── System generations
                    ├── Nix store size
                    ├── Podman machine/images
                    ├── Ollama models (profile-aware)
                    ├── LaunchAgents
                    └── Dev caches (uv, npm, Homebrew)
```

## Profile Comparison

| Feature | AI-Assistant | Standard | Power |
|---------|-------------|----------|-------|
| Target | Older MacBook (AI) | MacBook Air | MacBook Pro M3 Max |
| Disk usage | ~20GB | ~35GB | ~120GB |
| Ollama models | 1 (nomic-embed-text) | 2 (+ministral-3) | 4 (+phi4, gemma4) |
| Docker | No | Yes | Yes |
| LSPs | No | Yes | Yes |
| Office/Comms | No | Yes | Yes |
| Parallels | No | No | Yes |
| NAS mounts | No | No | SMB automount |
| Backups | No | No | rsync to NAS, iCloud sync |
