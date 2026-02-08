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
├── darwinConfigurations.standard  ──┐
│                                    ├── commonModules
├── darwinConfigurations.power  ─────┘
│
└── helpers
    ├── ollamaModels { standard, power }
    ├── mkOllamaModelScript (generates pull scripts)
    └── mkDarwinConfiguration (shared builder)
```

## Module Dependency Graph

```
                         flake.nix
                            │
              ┌─────────────┼─────────────────┐
              │             │                  │
              ▼             ▼                  ▼
     commonModules    standard-only      power-only
              │                          │
    ┌─────────┼──────────┐     ┌────────┼────────┼────────┐
    │         │          │     │        │        │        │
    ▼         ▼          ▼     ▼        ▼        ▼        ▼
 darwin/   darwin/    darwin/ darwin/  darwin/  darwin/  darwin/
 config    homebrew   macos   smb-    rsync-   tts-     stt-
 .nix      .nix       def.   auto    backup   serve    serve
                      nix    mount    .nix     .nix     .nix
    │         │
    │         ├── darwin/maintenance.nix ──── mkScheduledAgent
    │         │   ├── nix-gc           (6 LaunchAgents)
    │         │   ├── nix-optimize
    │         │   ├── weekly-digest
    │         │   ├── release-monitor
    │         │   ├── disk-cleanup
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
         ├── modules/vscode.nix    (backup editor)
         ├── modules/python.nix    (uv, ruff, mypy)
         ├── modules/podman.nix    (container runtime)
         ├── modules/claude-code.nix (CLI + MCP servers + GSD)
         └── modules/ssh.nix       (SSH config, known hosts)
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
                    │  (Python, JSON)  │   Accessible via Tailscale
                    └──────────────────┘
                              │
                    Checks performed:
                    ├── Nix daemon
                    ├── Homebrew
                    ├── Disk space (Finder metric)
                    ├── FileVault / Firewall
                    ├── System generations
                    ├── Nix store size
                    ├── Podman machine/images
                    ├── Ollama models (profile-aware)
                    ├── TTS server (Power only)
                    ├── STT server (Power only)
                    ├── LaunchAgents
                    └── Dev caches (uv, npm, Homebrew)
```

## Profile Comparison

| Feature | Standard | Power |
|---------|----------|-------|
| Target | MacBook Air | MacBook Pro M3 Max |
| Disk usage | ~35GB | ~120GB |
| Ollama models | 2 (ministral-3, nomic-embed-text) | 4 (+llava, phi4) |
| Parallels | No | Yes |
| NAS mounts | No | SMB automount |
| Backups | No | rsync to NAS, iCloud sync |
| TTS server | No | Qwen3-TTS on port 8765 |
| STT server | No | Whisper STT on port 8766 |
