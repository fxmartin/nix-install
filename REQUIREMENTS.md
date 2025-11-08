# Product Requirements Document: Nix-Darwin MacBook Setup System

## Executive Summary

**Problem**: Managing three MacBooks with frequent reinstalls is time-consuming and error-prone. Current manual setup process (documented in Mac-setup repo) requires hours of configuration, inconsistent results across machines, and no version control for system state.

**Solution**: Automated, declarative MacBook configuration system using Nix + nix-darwin with two installation profiles (Standard/Power), one-command bootstrap, and full reproducibility across all machines.

**Success Metrics**:
- Time to fully configured system: <30 minutes (vs 4+ hours manual)
- Configuration consistency: 100% identical setup across same-profile machines
- Adoption: All 3 MacBooks migrated within 30 days

---

## Context & Strategic Rationale

### Why Now?

1. **Pain Point Reached Critical Mass**: Managing 3+ MacBooks with periodic reinstalls has become unsustainable
2. **Existing Documentation Exists**: Mac-setup repo proves workflows are well-understood but need automation
3. **Reference Implementation Available**: mlgruby/dotfile-nix provides production-ready architecture to adapt
4. **Nix Ecosystem Maturity**: nix-darwin + Home Manager are stable, flakes are standard, community support is strong

### Strategic Rationale

- **Reproducibility**: Any machine can be rebuilt to identical state in <30 minutes
- **Version Control**: Entire system configuration in Git with atomic rollback capability
- **Time Savings**: 3-4 hours per reinstall → 30 minutes (90% reduction)
- **Consistency**: Eliminate "works on one Mac but not others" issues
- **Documentation as Code**: Configuration IS the documentation (no drift between docs and reality)

### Competitive Landscape

| Approach | Pros | Cons | Our Choice |
|---|---|---|---|
| **Manual Setup** | Simple, familiar | Error-prone, slow, no versioning | ❌ Current pain point |
| **Homebrew Brewfile** | Easy to learn, macOS-native | Not atomic, no rollback, limited system config | ❌ Insufficient |
| **Ansible/Chef** | Powerful automation | Imperative (describes steps not state), complex | ❌ Wrong paradigm |
| **Nix + nix-darwin** | Declarative, atomic, reproducible, rollback | Learning curve, smaller community | ✅ **Selected** |

---

## User Problems & Jobs-to-be-Done

### Primary Persona: FX (Power User with Multiple Machines)

**Demographics:**
- Manages 3 MacBooks (mix of Pro M3 Max and Air models)
- Reinstalls machines periodically for maintenance
- Split usage: Office 365 work + weekend Python development
- Values automation, consistency, and minimal manual intervention

**Pain Points (Current State):**

1. **"I spend 4+ hours setting up a Mac from scratch"**
   - Installing apps one by one
   - Configuring Finder, trackpad, security settings manually
   - Copying dotfiles and configs between machines
   - Remembering which tools to install

2. **"My three Macs drift out of sync"**
   - Different app versions across machines
   - Inconsistent shell configurations
   - Manual changes not replicated to other machines
   - No way to know what's different between machines

3. **"I forget to configure critical settings"**
   - FileVault encryption
   - Three-finger trackpad drag
   - Finder sidebar customization
   - System security preferences

4. **"Breaking my shell config is terrifying"**
   - No rollback mechanism
   - Manual backups are inconsistent
   - Testing changes is risky

5. **"Documentation gets out of date"**
   - Mac-setup repo documents what SHOULD happen
   - Reality diverges over time
   - No single source of truth

### Current Workarounds (Why They Suck)

**Mac-setup GitHub repo:**
- ✅ Good: Documents preferences and tools
- ❌ Bad: Requires manual execution of every step
- ❌ Bad: No version locking (packages change)
- ❌ Bad: No rollback if something breaks
- ❌ Bad: Documentation can drift from reality

**Manual Homebrew + dotfiles:**
- ✅ Good: Shell configs in version control
- ❌ Bad: System preferences not captured
- ❌ Bad: No atomic updates
- ❌ Bad: App installation is imperative (order matters)

### User Journey Map (Current State Friction Points)

```
New MacBook Reinstall Journey (Current)
├─ 1. Initial macOS Setup [15 min] ⚠️ Manual
├─ 2. Install Xcode CLI Tools [10 min] ⚠️ Manual
├─ 3. Install Homebrew [5 min] ⚠️ Manual
├─ 4. Install 60+ apps one-by-one [45 min] 🔴 Tedious, error-prone
├─ 5. Configure system preferences [30 min] 🔴 Refer to Mac-setup docs, easy to miss steps
├─ 6. Set up SSH keys [10 min] ⚠️ Manual, different process each time
├─ 7. Clone dotfiles, create symlinks [15 min] ⚠️ Manual
├─ 8. Configure shell (Zsh, Oh My Zsh, plugins) [20 min] 🔴 Complex
├─ 9. Configure each app individually [45 min] 🔴 Tedious
├─ 10. Install Python, dev tools [20 min] ⚠️ Version management unclear
├─ 11. Test everything works [30 min] ⚠️ Discovery of missed steps
└─ 12. Fix issues discovered [60+ min] 🔴 Troubleshooting, starting over

Total Time: 4-6 hours (optimistic)
Frustration Level: High 😤
Consistency: Low (different each time)
```

**Future State (With Nix Solution):**

```
New MacBook Reinstall Journey (Future)
├─ 1. Initial macOS Setup [15 min] ⚠️ Manual (unavoidable)
├─ 2. Run bootstrap command [2 min] ✅ Automated
├─ 3. Answer 3 questions (name, email, Standard/Power) [2 min] ✅ Guided
├─ 4. Add SSH key to GitHub [3 min] ✅ Guided (key displayed, wait for confirmation)
├─ 5. Wait for Nix to build system [15-20 min] ✅ Fully automated
└─ 6. Restart terminal, verify [3 min] ✅ Everything configured

Total Time: 25-30 minutes (hands-off after question answering)
Frustration Level: Minimal 😌
Consistency: 100% (declarative config)
```

---

## Solution Overview

### High-Level Approach

**Declarative MacBook configuration system** using Nix package manager + nix-darwin + Home Manager with:
- **Two installation profiles**: Standard (Air) and Power (Pro M3 Max)
- **One-command bootstrap**: Download and run script, answer 3 questions, walk away
- **Machine-specific configurations**: Parallels on Power, extra Ollama models on Power (1TB storage)
- **Full reproducibility**: Same config → identical system state
- **Public GitHub repo**: Configuration versioned, forkable, shareable

### Key Capabilities

1. **Automated Bootstrap**
   - Single curl command installation
   - Interactive prompts for user info (name, email, GitHub username)
   - Profile selection (Standard vs Power)
   - SSH key generation with guided GitHub upload
   - No Homebrew pre-installation required

2. **Declarative System Configuration**
   - All applications defined in code
   - macOS system preferences (Finder, trackpad, security, etc.)
   - Shell environment (Zsh, Oh My Zsh, fzf, completions)
   - Development tools (Python 3.12, uv, Podman, Git LFS)
   - Theming (Catppuccin with auto light/dark mode)

3. **Profile-Based Installation**
   - **Standard Profile**: Core apps, basic Ollama model, no virtualization
   - **Power Profile**: + Parallels Desktop, + additional Ollama models (qwen2.5-coder:32b, llama3.1:70b, deepseek-r1:32b)

4. **Maintenance Automation**
   - Daily garbage collection (cleanup old Nix generations)
   - Daily Nix store optimization (deduplication)
   - Health check commands
   - System monitoring (btop, iStat Menus, macmon)

5. **Version Control & Rollback**
   - Entire system configuration in Git
   - Atomic updates (all-or-nothing)
   - Rollback to previous generation if issues occur
   - Lock file for reproducible dependency versions

### What We're NOT Building

❌ **Not building**:
- Cloud backup/sync solution (use existing Dropbox)
- Secrets management system (manual license entry for paid apps)
- Multi-user configurations (single user per machine)
- Windows/Linux support (macOS only)
- Custom Nix packages (use existing nixpkgs + Homebrew)
- Migration tool from existing setup (fresh installs only)
- Auto-update mechanism (manual updates via rebuild command)

✅ **Building**:
- Configuration as code
- Automated installation
- System state management
- Reproducible environments

### Technical Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Public Repo                      │
│                  github.com/fxmartin/nix-config              │
│                                                             │
│  flake.nix (system definition)                              │
│  user-config.nix (personal info - filled during bootstrap)  │
│  darwin/ (system-level: packages, macOS defaults)           │
│  home-manager/ (user-level: dotfiles, aliases, configs)     │
│  scripts/ (bootstrap, maintenance, health checks)           │
│  config/ (ghostty, zed, etc.)                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Bootstrap: curl + bash
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Fresh MacBook (macOS)                      │
│                                                             │
│  Phase 1: Install Xcode CLI Tools                           │
│  Phase 2: User prompts + curl flake.nix from GitHub         │
│  Phase 3: Install Nix package manager                       │
│  Phase 4: Run nix-darwin (installs Homebrew as dependency)  │
│  Phase 5: SSH key setup + full repo clone                   │
│  Phase 6: Final rebuild with complete config                │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Result: Fully configured system
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Configured MacBook (Standard/Power)             │
│                                                             │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │  Nix Store       │  │  Homebrew Casks  │                │
│  │  (CLI tools,     │  │  (GUI apps)      │                │
│  │   Python, etc)   │  │                  │                │
│  └──────────────────┘  └──────────────────┘                │
│           │                      │                          │
│           └──────────┬───────────┘                          │
│                      ▼                                      │
│           ~/.config/ (symlinks to Nix store)                │
│           ~/.zshrc, ~/.ssh/config, etc.                     │
│                                                             │
│  System Preferences: All automated via nix-darwin           │
│  Applications: Installed and configured                     │
│  Development Environment: Python 3.12, Podman, Git LFS      │
│  Theming: Catppuccin (auto light/dark)                      │
└─────────────────────────────────────────────────────────────┘
```

**Package Management Strategy** (Preference Order):

1. **Nix First** (via nixpkgs)
   - CLI tools: curl, wget, git, python, etc.
   - Dev tools: uv, ruff, mypy, etc.
   - System utilities: btop, fzf, ripgrep, fd, jq, yq
   - Maximum reproducibility, version pinning

2. **Homebrew Casks** (for GUI apps that don't work well in Nix)
   - Applications: Arc, Firefox, Zed, Claude Desktop, etc.
   - System tools: Raycast, 1Password, iStat Menus
   - Managed declaratively via nix-darwin's homebrew module

3. **Mac App Store (mas)** (only when no alternative)
   - Kindle
   - WhatsApp (if not available via Homebrew)

---

## Detailed Requirements

### Must-Have Features (P0) - MVP for First MacBook Migration

#### 1. Bootstrap Installation System

**REQ-BOOT-001**: One-command installation
- User runs: `curl -sSL https://raw.githubusercontent.com/fxmartin/nix-config/main/bootstrap.sh | bash`
- Script must be idempotent (safe to re-run)
- Clear progress indicators at each phase
- Acceptance: Complete system setup from fresh macOS in <30 minutes

**REQ-BOOT-002**: Interactive user configuration
- Prompt for: Full name, Email, GitHub username
- Prompt for: Installation profile (Standard or Power)
- Validate inputs (no special characters in username, valid email format)
- Create user-config.nix from inputs
- Acceptance: Generated config passes Nix validation

**REQ-BOOT-003**: Profile selection system
- Two profiles: "Standard" (Air), "Power" (Pro M3 Max)
- Clear description of differences shown to user
- Profile determines: Parallels installation, Ollama models pulled
- Acceptance: Correct apps installed based on profile choice

**REQ-BOOT-004**: SSH key management
- Generate ed25519 SSH key for GitHub
- Display public key to user with clear instructions
- Wait for user confirmation after adding key to GitHub
- Test SSH connection before proceeding
- Acceptance: User can clone private repos after bootstrap

**REQ-BOOT-005**: No Homebrew pre-installation
- Do NOT install Homebrew in bootstrap phase
- Homebrew installed as Nix dependency via nix-darwin
- Sequence: Xcode → Nix → nix-darwin (includes Homebrew) → Apps
- Acceptance: Homebrew only appears after Nix is managing it

**REQ-BOOT-006**: Error handling and recovery
- Fail gracefully with clear error messages
- Resume capability if interrupted (detect partial state)
- Backup existing configs before overwriting
- Acceptance: User can understand and fix issues without developer help

#### 2. Application Installation

**REQ-APP-001**: AI/LLM Tools
- Standard + Power: Claude Desktop, ChatGPT Desktop, Perplexity, Ollama
- Standard: Ollama pull `gpt-oss:20b` only
- Power: Additional models `qwen2.5-coder:32b`, `llama3.1:70b`, `deepseek-r1:32b`
- Acceptance: Apps launch, Ollama models available via `ollama list`

**REQ-APP-002**: Development Environment
- Zed (text editor)
- VSCode (for Claude Code extension)
- Ghostty (terminal emulator) with config from `/config/config.ghostty`
- Python 3.12 (via Nix)
- uv (Python package manager via Nix)
- Podman + podman-compose + podman-desktop
- Git + Git LFS
- Acceptance: `python --version` shows 3.12.x, `podman --version` works, `git lfs` available

**REQ-APP-003**: Python Development Tools (Global)
- ruff (linter/formatter)
- black (formatter)
- isort (import sorter)
- mypy (type checker)
- pylint (linter)
- Acceptance: All tools available in PATH, callable from any directory

**REQ-APP-004**: Browsers
- Safari (built-in, no action needed)
- Firefox
- Arc
- Acceptance: All browsers launch, set Arc as default (or prompt user)

**REQ-APP-005**: Productivity & Utilities
- Raycast (launcher)
- 1Password (password manager) 🔒
- Calibre (ebook manager)
- Kindle (via mas)
- Dropbox 🔒
- Onyx (system maintenance)
- Keka (archiver)
- flux-app (f.lux - display color temperature)
- iStat Menus 🔒
- macmon (system monitoring)
- Acceptance: Apps installed, 🔒 apps documented as needing manual license activation

**REQ-APP-006**: Communication
- WhatsApp (via mas)
- Zoom 🔒
- Webex 🔒
- Acceptance: Apps installed and launchable

**REQ-APP-007**: Media & Creative
- VLC (video player)
- GIMP (image editor)
- Acceptance: Apps launch, can open files

**REQ-APP-008**: Security & VPN
- NordVPN 🔒
- Acceptance: App installed, requires manual login

**REQ-APP-009**: Profile-Specific Apps
- **Power Only**: Parallels Desktop 🔒
- Acceptance: Parallels NOT installed on Standard, IS installed on Power

**REQ-APP-010**: Office 365 (Manual Installation)
- Document in post-install instructions
- Not automated (requires Microsoft account, company policy)
- Acceptance: Clear instructions provided

#### 3. System Configuration (macOS Preferences)

**REQ-SYS-001**: Finder Configuration
- Default view: List view
- Show path bar and status bar
- Show hidden files
- Sidebar: Customize with smart folders (requires manual setup - document)
- Acceptance: Fresh terminal shows hidden files, path bar visible

**REQ-SYS-002**: Security Settings
- Enable FileVault disk encryption (or prompt to enable)
- Enable firewall with stealth mode
- Require password immediately after sleep/screensaver
- Disable guest login
- Touch ID for sudo
- Acceptance: `sudo` prompts for Touch ID, firewall active, FileVault enabled

**REQ-SYS-003**: Trackpad & Input
- Three-finger drag enabled
- Fast pointer speed
- Tap to click enabled
- Natural scrolling disabled (standard scroll direction)
- Acceptance: Three-finger drag works, scrolling is non-inverted

**REQ-SYS-004**: Display & Appearance
- Auto light/dark mode (follows system)
- 24-hour time format
- Night Shift scheduled (sunset to sunrise)
- Acceptance: System appearance switches at sunset, time shows 24h format

**REQ-SYS-005**: Keyboard & Text
- Fast key repeat rate
- Short delay until repeat
- Disable automatic capitalization
- Disable smart quotes/dashes (for coding)
- Acceptance: Holding 'a' key repeats quickly, no auto-caps when typing

**REQ-SYS-006**: Dock Configuration
- Minimize windows into app icon
- Auto-hide dock (optional, configurable)
- Remove all default apps, add custom set
- Acceptance: Dock has only configured apps

#### 4. Shell & Terminal Environment

**REQ-SHELL-001**: Zsh with Oh My Zsh
- Zsh as default shell
- Oh My Zsh framework installed
- Plugins: git, fzf, zsh-autosuggestions, z (jump to directories)
- Theme: Managed by Starship (not Oh My Zsh theme)
- Acceptance: `echo $SHELL` shows zsh, plugins active

**REQ-SHELL-002**: Starship Prompt
- Installed and configured
- Minimal, git-aware prompt
- Shows: directory, git branch/status, Python version (in venv)
- Acceptance: Prompt shows clean format, updates on git changes

**REQ-SHELL-003**: FZF Integration
- Ctrl+R: command history search
- Ctrl+T: file finder
- Alt+C: directory jump
- Acceptance: Keybindings work, fuzzy search functional

**REQ-SHELL-004**: Ghostty Terminal
- Configuration from `config/config.ghostty` applied
- Catppuccin theme (Latte/Mocha auto-switch)
- JetBrains Mono font
- 95% opacity with blur
- All keybindings from config active
- Acceptance: Ghostty opens with config applied, theme switches with system

**REQ-SHELL-005**: Useful Aliases
- `ll` → `ls -lah` (detailed list)
- `rebuild` → `darwin-rebuild switch --flake ~/.config/nix-config#$(hostname)`
- `update` → `cd ~/.config/nix-config && nix flake update && rebuild`
- `gc` → `nix-collect-garbage -d`
- `cleanup` → garbage collection + store optimization
- Acceptance: Aliases work in fresh terminal

#### 5. Theming & Fonts

**REQ-THEME-001**: Stylix System-Wide Theming
- Catppuccin Latte (light mode)
- Catppuccin Mocha (dark mode)
- Auto-switch based on macOS system appearance
- Apply to: Terminal, shell, supported apps
- Acceptance: Colors consistent across terminal, apps switch with system

**REQ-THEME-002**: Font Installation
- JetBrains Mono Nerd Font (primary)
- Size 12 for terminal (from ghostty config)
- Ligatures enabled
- Acceptance: `fc-list | grep JetBrains` shows font, ligatures render in terminal

#### 6. Development Workflow

**REQ-DEV-001**: Git Configuration
- User name and email from user-config.nix
- Default branch: main
- Git LFS installed and initialized
- SSH authentication for GitHub
- No GPG signing (not in MVP)
- Acceptance: `git config user.name` shows correct name, `git lfs` available

**REQ-DEV-002**: Python Environment
- System Python 3.12 (via Nix)
- uv available globally
- Project-specific Python via `uv venv`
- Acceptance: `python --version` = 3.12.x, `uv --version` works

**REQ-DEV-003**: Container Environment
- Podman (replaces Docker)
- podman-compose (docker-compose equivalent)
- podman-desktop (GUI)
- Acceptance: `podman run hello-world` works, podman-desktop launches

**REQ-DEV-004**: Editor Configuration
- Zed with default settings (no custom config in MVP)
- VSCode for Claude Code extension (manual extension install documented)
- Acceptance: Both editors launch, can open files

#### 7. Maintenance & Monitoring

**REQ-MAINT-001**: Automated Garbage Collection
- Daily: `nix-collect-garbage --delete-older-than 30d`
- Keep last 30 days of generations for rollback
- Run at 3 AM (low usage time)
- Acceptance: Old generations cleaned, cron job active

**REQ-MAINT-002**: Automated Store Optimization
- Daily: `nix-store --optimize` (deduplication)
- Run at 3:30 AM
- Acceptance: Disk space recovered, job runs successfully

**REQ-MAINT-003**: System Monitoring Tools
- btop (CLI system monitor)
- iStat Menus (GUI menubar monitor) 🔒
- macmon (GUI monitoring)
- Acceptance: All tools installed, btop shows CPU/memory, iStat in menubar

**REQ-MAINT-004**: Health Check Commands
- `health-check` alias: validates system state
- Checks: Nix daemon running, Homebrew healthy, disk space
- Acceptance: Command runs, reports system status

#### 8. Documentation

**REQ-DOC-001**: README with Quick Start
- One-command installation instructions
- Profile descriptions (Standard vs Power)
- Post-install checklist (license activation)
- Common commands (rebuild, update, rollback)
- Acceptance: Non-technical user can follow and complete install

**REQ-DOC-002**: Licensed App Activation Guide
- List of apps requiring manual activation: 1Password, iStat Menus, NordVPN, Zoom, Webex, Parallels, Dropbox
- Step-by-step for each app
- Acceptance: User can activate all licenses within 15 minutes

**REQ-DOC-003**: Troubleshooting Guide
- Common issues and solutions
- How to rollback to previous generation
- How to rebuild if build fails
- Acceptance: User can self-service common issues

**REQ-DOC-004**: Customization Guide
- How to add new apps
- How to modify system preferences
- How to change theme/fonts
- Acceptance: User can add an app and rebuild successfully

---

### Should-Have Features (P1) - Post-MVP Enhancements

**REQ-P1-001**: Secrets Management
- SOPS + age for encrypted secrets in repo
- Store: API keys, license keys, Wi-Fi passwords
- Acceptance: Secrets in repo are encrypted, decrypted at build time

**REQ-P1-002**: GPG Commit Signing
- Generate GPG key during bootstrap
- Configure Git to sign commits
- Upload public key to GitHub
- Acceptance: Commits show "Verified" badge on GitHub

**REQ-P1-003**: Automatic Dotfile Backup
- Pre-install: Backup existing dotfiles to `~/dotfiles-backup-YYYYMMDD/`
- Allows comparison and migration
- Acceptance: Old configs preserved, easy to reference

**REQ-P1-004**: Brewfile Import
- Parse existing `Brewfile` from Mac-setup repo
- Suggest apps to add to Nix config
- Acceptance: Migration from Brewfile to Nix assisted

**REQ-P1-005**: Advanced Finder Customization
- Automated sidebar configuration
- Custom smart folders
- Default view per folder
- Acceptance: Finder matches Mac-setup preferences exactly

**REQ-P1-006**: Raycast Extensions & Snippets
- Pre-configure Raycast extensions
- Import snippets from existing setup
- Acceptance: Raycast has useful extensions on first launch

**REQ-P1-007**: Multi-Profile Support
- Add more profiles: "Travel" (minimal apps), "Development-Only"
- Allow profile switching post-install
- Acceptance: User can switch profiles and rebuild

**REQ-P1-008**: Desktop Widgets Configuration
- Fantastical Calendar widget
- HomeKit controls
- Weather, battery widgets
- Acceptance: Desktop widgets match Mac-setup preferences

---

### Nice-to-Have Features (P2) - Future Enhancements

**REQ-P2-001**: GitHub Actions CI/CD
- Validate config on every commit
- Test flake builds
- Auto-generate changelog
- Acceptance: Failed configs blocked from merging

**REQ-P2-002**: Network Configuration
- Known Wi-Fi networks with encrypted passwords
- VPN configurations (NordVPN auto-connect)
- DNS settings (Cloudflare 1.1.1.1)
- Acceptance: WiFi auto-connects on boot

**REQ-P2-003**: Keyboard Remapping (Karabiner-Elements)
- Custom keyboard shortcuts
- Caps Lock → Escape/Control
- Acceptance: Custom keybinds active

**REQ-P2-004**: Window Management
- Rectangle (window snapping)
- Custom shortcuts
- Acceptance: Window snapping via keyboard shortcuts

**REQ-P2-005**: Notification Rules
- Do Not Disturb schedule
- App-specific notification settings
- Acceptance: Notifications managed automatically

**REQ-P2-006**: Automatic Updates
- Weekly check for flake updates
- Notification of available updates
- One-command update + rebuild
- Acceptance: System suggests updates weekly

**REQ-P2-007**: Remote Machine Management
- SSH into any of 3 Macs
- Push config updates to all machines
- Acceptance: Config change deploys to all machines with one command

**REQ-P2-008**: Performance Monitoring Dashboard
- Web dashboard showing all 3 Macs' status
- Disk space, running services, generation count
- Acceptance: Dashboard shows health of all machines

---

### Non-Functional Requirements

**REQ-NFR-001**: Performance
- Bootstrap completion: <30 minutes (excluding downloads)
- Rebuild time: <5 minutes (subsequent rebuilds with binary cache)
- Shell startup time: <500ms (with lazy loading for heavy tools)

**REQ-NFR-002**: Reliability
- Build success rate: >95% (failed builds must rollback cleanly)
- Idempotent operations: All scripts safe to re-run
- Backup before destructive operations

**REQ-NFR-003**: Security
- No secrets in Git (plaintext)
- SSH keys never transmitted (only generated locally)
- FileVault encryption enforced
- Firewall enabled by default

**REQ-NFR-004**: Maintainability
- Modular Nix configs (one concern per file)
- Comments explaining non-obvious choices
- Changelog for all breaking changes
- Nix version locked in flake

**REQ-NFR-005**: Usability
- Error messages actionable (tell user what to do)
- Progress indicators during long operations
- Confirmation prompts before destructive actions
- Documentation written for non-Nix users

**REQ-NFR-006**: Compatibility
- macOS Sonoma (14.x) minimum
- Apple Silicon (M-series) primary, Intel secondary
- Nix 2.18+ with flakes

---

## Success Criteria & Metrics

### Leading Indicators (Usage & Adoption)

| Metric | Target | Measurement Method |
|---|---|---|
| **Bootstrap Success Rate** | >90% first-time success | User survey + error logs |
| **Time to Configured System** | <30 minutes | Timed from bootstrap start to ready state |
| **MacBooks Migrated** | 3/3 within 30 days | Manual tracking |
| **Rebuild Frequency** | 2+ per week (active usage) | Git commit count to nix-config repo |
| **User Confidence Score** | >8/10 "I can rebuild my Mac confidently" | Post-migration survey |

### Lagging Indicators (Value & Quality)

| Metric | Target | Measurement Method |
|---|---|---|
| **Time Savings per Reinstall** | 3-4 hours saved (4-6h → 30min) | Self-reported |
| **Configuration Drift** | 0 differences between same-profile machines | `diff` of running configs |
| **Manual Interventions** | <5 manual steps post-bootstrap | Checklist completion |
| **Rollback Usage** | 0 rollbacks needed (stable config) | Nix generations list |
| **Documentation Quality** | 0 unanswered questions after 30 days | FAQ additions post-launch |

### Definition of "Done"

**✅ MVP Complete When:**

1. **All 3 MacBooks migrated** to Nix-based config
2. **Bootstrap script works** on fresh macOS without manual intervention (except license entry)
3. **Documentation complete**: Non-technical user can follow README and succeed
4. **All P0 requirements met**: Apps installed, system configured, shell working
5. **First rebuild successful**: User can make a config change and rebuild without help
6. **No blockers**: All critical workflows functional (Python dev, Office 365 work, AI tools)

**🎯 Success Declared When:**

- User hasn't touched Mac-setup repo in 30 days (replaced by Nix config)
- User can reinstall any Mac in <30 minutes
- User makes config changes weekly (actively using the system)
- No "I miss the old manual setup" sentiment

---

## Implementation Plan

### Phased Rollout Approach

#### Phase 0: Foundation (Week 1)
**Goal**: Set up repository structure and basic Nix flake

- [ ] Create GitHub repo: `fxmartin/nix-config`
- [ ] Initialize flake.nix based on mlgruby reference
- [ ] Create user-config.nix template
- [ ] Define Standard and Power profiles in flake
- [ ] Basic darwin configuration (minimal apps)
- [ ] Test: Nix flake checks pass

**Deliverable**: Buildable flake with 5 essential apps (Ghostty, Zed, Arc, Firefox, Claude Desktop)

---

#### Phase 1: Core Bootstrap (Week 2)
**Goal**: Get bootstrap script working end-to-end

- [ ] Write bootstrap.sh (phases: Xcode → Nix → nix-darwin)
- [ ] Interactive prompts (name, email, profile selection)
- [ ] SSH key generation and GitHub upload flow
- [ ] Test on VM or spare Mac: Fresh macOS → configured system
- [ ] Error handling and resume capability

**Deliverable**: Working bootstrap script that installs Nix + core apps

---

#### Phase 2: Application Installation (Week 2-3)
**Goal**: Add all required applications to both profiles

- [ ] Map all apps to Nix/Homebrew/mas (see Package Strategy table below)
- [ ] Configure Homebrew module in darwin config
- [ ] Add mas apps (Kindle, WhatsApp)
- [ ] Test app launches after rebuild
- [ ] Document licensed apps needing manual activation

**Deliverable**: All apps from REQ-APP-* installed correctly

---

#### Phase 3: System Preferences (Week 3)
**Goal**: Automate macOS system configuration

- [ ] Finder settings (defaults write commands)
- [ ] Trackpad settings (three-finger drag, speed, etc.)
- [ ] Security settings (FileVault prompt, firewall, Touch ID sudo)
- [ ] Display settings (auto light/dark, Night Shift)
- [ ] Keyboard settings (key repeat, disable auto-caps)
- [ ] Test: Fresh install has all preferences configured

**Deliverable**: macOS preferences match Mac-setup repo exactly

---

#### Phase 4: Shell & Terminal (Week 4)
**Goal**: Perfect shell environment with Zsh + Oh My Zsh + Ghostty

- [ ] Home Manager config for Zsh
- [ ] Oh My Zsh installation and plugins (fzf, zsh-autosuggestions)
- [ ] Starship prompt configuration
- [ ] Ghostty config integration (use existing config/config.ghostty)
- [ ] Aliases and shell functions
- [ ] Test: Shell startup time <500ms, all features work

**Deliverable**: Polished terminal experience matching requirements

---

#### Phase 5: Development Environment (Week 4)
**Goal**: Python + Podman + Git LFS fully configured

- [ ] Python 3.12 installation
- [ ] uv package manager
- [ ] Python dev tools (ruff, black, mypy, isort, pylint)
- [ ] Podman + podman-compose + podman-desktop
- [ ] Git configuration with LFS
- [ ] Test: Create Python project with uv, run in Podman container

**Deliverable**: Working Python + container dev environment

---

#### Phase 6: Theming & Fonts (Week 5)
**Goal**: Consistent Catppuccin theming across system

- [ ] Stylix configuration with Catppuccin (Latte/Mocha)
- [ ] JetBrains Mono Nerd Font installation
- [ ] Auto light/dark mode switching
- [ ] Apply theme to terminal, supported apps
- [ ] Test: Theme switches at sunset, colors consistent

**Deliverable**: Beautiful, consistent theming

---

#### Phase 7: Maintenance & Monitoring (Week 5)
**Goal**: Automated cleanup and monitoring tools

- [ ] Daily garbage collection (launchd job)
- [ ] Daily store optimization (launchd job)
- [ ] Install btop, iStat Menus, macmon
- [ ] Health check alias/script
- [ ] Test: GC runs overnight, health-check reports status

**Deliverable**: Self-maintaining system with monitoring

---

#### Phase 8: Documentation & Polish (Week 6)
**Goal**: Make it usable by non-Nix users

- [ ] README.md with quick start
- [ ] Licensed app activation guide
- [ ] Troubleshooting guide
- [ ] Customization guide (how to add apps, change settings)
- [ ] Video walkthrough (optional)
- [ ] Test: Non-technical friend can follow README and succeed

**Deliverable**: Complete documentation package

---

#### Phase 9: First MacBook Migration (Week 6)
**Goal**: Migrate MacBook #1 (choose Standard or Power)

- [ ] Backup current MacBook (Time Machine + manual)
- [ ] Fresh macOS reinstall
- [ ] Run bootstrap script
- [ ] Document any issues encountered
- [ ] Fix issues, update config
- [ ] Verify all workflows functional (work + dev)
- [ ] Use for 1 week, iterate on issues

**Deliverable**: First MacBook fully migrated, stable for daily use

---

#### Phase 10: Remaining MacBooks Migration (Week 7-8)
**Goal**: Migrate MacBooks #2 and #3

- [ ] Apply learnings from MacBook #1
- [ ] Migrate MacBook #2 (opposite profile from #1)
- [ ] Test profile differences (Parallels, Ollama models)
- [ ] Migrate MacBook #3
- [ ] Verify consistency across machines
- [ ] Document any machine-specific quirks

**Deliverable**: All 3 MacBooks migrated and consistent

---

### Key Milestones & Dependencies

| Milestone | Target Date | Dependencies | Success Criteria |
|---|---|---|---|
| **M1: Buildable Flake** | End Week 1 | None | `nix flake check` passes |
| **M2: Working Bootstrap** | End Week 2 | M1 | Fresh Mac → configured in <30min |
| **M3: All Apps Installed** | End Week 3 | M2 | All REQ-APP-* requirements met |
| **M4: System Config Done** | End Week 3 | M3 | All REQ-SYS-* requirements met |
| **M5: Shell Perfected** | End Week 4 | M4 | Shell startup <500ms, features work |
| **M6: Dev Env Ready** | End Week 4 | M5 | Python + Podman workflows functional |
| **M7: First Mac Migrated** | End Week 6 | M1-M6 | Daily use for 1 week without issues |
| **M8: All Macs Migrated** | End Week 8 | M7 | 3/3 MacBooks on Nix config |

---

### Resource Requirements

**Time Investment:**
- **FX (User)**:
  - Active: 10-15 hours (testing, feedback, migrations)
  - Passive: 8 weeks duration (feedback cycles, daily use testing)

- **Developer (if not FX)**:
  - Week 1-6: 20-30 hours (implementation, testing)
  - Week 7-8: 5-10 hours (migration support, bug fixes)

**Infrastructure:**
- GitHub account (free tier sufficient)
- 3 MacBooks for testing (already owned)
- Optional: macOS VM for testing (UTM or Parallels)

**Knowledge Requirements:**
- Nix/NixOS basics (can learn during implementation)
- Bash scripting (for bootstrap script)
- macOS system administration
- Git/GitHub workflows

**External Dependencies:**
- nixpkgs (community package repository)
- nix-darwin (macOS support for Nix)
- Home Manager (user environment management)
- Homebrew (for GUI apps)

---

## Risks & Mitigation

### Technical Risks

**RISK-TECH-001: Nix Learning Curve Too Steep**
- **Probability**: Medium
- **Impact**: High (blocks adoption)
- **Mitigation**:
  - Use mlgruby repo as reference (proven architecture)
  - Start with simple config, add complexity gradually
  - Document every non-obvious Nix pattern
  - Fallback: Hybrid approach (Nix for some, Homebrew for rest)

**RISK-TECH-002: App Incompatibility with Nix**
- **Probability**: Medium
- **Impact**: Medium (some apps won't work)
- **Mitigation**:
  - Prefer Homebrew casks for GUI apps (better compatibility)
  - Test critical apps early (Claude Desktop, Office 365, Parallels)
  - Maintain escape hatch: manual installation instructions
  - Accept: Not everything needs to be in Nix

**RISK-TECH-003: macOS Updates Break Config**
- **Probability**: Low (but inevitable over time)
- **Impact**: High (system unbootable)
- **Mitigation**:
  - Pin macOS version in documentation
  - Test on macOS beta before upgrading production machines
  - Nix rollback capability (previous generation)
  - Community: nix-darwin is actively maintained

**RISK-TECH-004: Binary Cache Unavailable (Slow Builds)**
- **Probability**: Low
- **Impact**: Medium (30min install → 2+ hours)
- **Mitigation**:
  - Use official NixOS binary cache (cache.nixos.org)
  - Accept: First build may be slow, rebuilds are fast
  - Document: "First install takes longer, be patient"

**RISK-TECH-005: SSH Key Upload Fails (No GitHub Auth)**
- **Probability**: Medium
- **Impact**: Medium (manual intervention required)
- **Mitigation**:
  - Clear instructions shown to user
  - Test SSH connection before proceeding
  - Fallback: Manual key upload via GitHub web UI
  - Accept: Some manual steps are okay

**RISK-TECH-006: Flake Lock Conflicts (Multi-Machine Updates)**
- **Probability**: Medium
- **Impact**: Low (merge conflicts in flake.lock)
- **Mitigation**:
  - Update one machine at a time
  - Pull before rebuild on each machine
  - Document merge conflict resolution
  - Accept: Occasional conflicts are normal with Git

### Market/Competitive Risks

**RISK-MKT-001: Nix Ecosystem Abandonment**
- **Probability**: Very Low
- **Impact**: Critical (entire solution obsolete)
- **Mitigation**:
  - Nix has strong community, growing adoption (Determinate Systems investment)
  - nix-darwin actively maintained (1000+ commits/year)
  - Worst case: Fork and maintain, or migrate to Brewfile
  - Timeline: 5+ year horizon, plenty of warning

**RISK-MKT-002: Better Solution Emerges**
- **Probability**: Low-Medium (DevBox, Flox, etc.)
- **Impact**: Low (sunk cost, but new solution may be better)
- **Mitigation**:
  - Nix is foundational tech (others build on it)
  - Config is portable (easy to adapt)
  - Accept: Technology changes, migration is normal

### Operational Risks

**RISK-OPS-001: Time Investment Exceeds Budget**
- **Probability**: Medium
- **Impact**: Medium (delayed migration)
- **Mitigation**:
  - Start with one MacBook (prove value before full commitment)
  - Timebox implementation (6 weeks max for MVP)
  - Accept partial automation (80/20 rule: automate most painful parts first)
  - Fallback: Keep Mac-setup repo as backup

**RISK-OPS-002: Lost Productivity During Migration**
- **Probability**: Medium
- **Impact**: Medium (work disruption)
- **Mitigation**:
  - Migrate personal MacBook first (less critical)
  - Keep old machine available during migration
  - Migrate during low-workload period (weekend, holiday)
  - Backup everything before migration

**RISK-OPS-003: Forgotten Critical App/Setting**
- **Probability**: High (inevitable)
- **Impact**: Low-Medium (manual fix required)
- **Mitigation**:
  - Use Mac-setup repo as checklist
  - Parallel run: Use Nix Mac for 1 week while keeping old Mac available
  - Iterative approach: Add forgotten items to config over time
  - Accept: Perfection is impossible, iteration is normal

**RISK-OPS-004: Licensed App Activation Tedious**
- **Probability**: High (certainty)
- **Impact**: Low (annoying but manageable)
- **Mitigation**:
  - Clear documentation of activation steps
  - Store license keys in 1Password (already used)
  - Accept: Some manual steps are unavoidable
  - Future: P1 feature to automate with SOPS

**RISK-OPS-005: Multi-Machine Config Drift**
- **Probability**: Medium
- **Impact**: Medium (defeats purpose of Nix)
- **Mitigation**:
  - Enforce: "All changes go in Git, then rebuild"
  - Periodic audits: Compare machine states
  - Health check script: Detects drift
  - Accept: Some drift is okay if intentional (machine-specific needs)

---

## Appendices

### Appendix A: Package Management Strategy Matrix

| Application | Installation Method | Rationale |
|---|---|---|
| **Development Tools** | | |
| Python 3.12 | Nix (nixpkgs.python312) | Version pinning, reproducibility |
| uv | Nix (nixpkgs.uv) | CLI tool, Nix-friendly |
| ruff, black, mypy, etc. | Nix (python312Packages.*) | Integrate with system Python |
| Podman | Nix (nixpkgs.podman) | Better Nix support than Docker |
| podman-compose | Nix (nixpkgs.podman-compose) | CLI tool |
| podman-desktop | Homebrew Cask | GUI app, frequent updates |
| Git | Nix (nixpkgs.git) | Core tool, Nix-managed |
| Git LFS | Nix (nixpkgs.git-lfs) | Extension of git |
| **Editors & IDEs** | | |
| Zed | Homebrew Cask | GUI app, fast release cycle |
| VSCode | Homebrew Cask (visual-studio-code) | GUI app, extensions ecosystem |
| **Terminals** | | |
| Ghostty | Homebrew Cask | GUI app, bleeding-edge |
| **Browsers** | | |
| Safari | Built-in (macOS) | No installation needed |
| Firefox | Homebrew Cask | GUI app |
| Arc | Homebrew Cask | GUI app |
| **AI/LLM Tools** | | |
| Claude Desktop | Homebrew Cask | GUI app |
| ChatGPT Desktop | Homebrew Cask (chatgpt) | GUI app |
| Perplexity | Homebrew Cask | GUI app |
| Ollama | Homebrew (ollama CLI) | Better macOS integration |
| **Productivity** | | |
| Raycast | Homebrew Cask | GUI app |
| 1Password | Homebrew Cask | GUI app, auto-updates |
| Calibre | Homebrew Cask | GUI app |
| Kindle | mas (Mac App Store) | Only available on App Store |
| Dropbox | Homebrew Cask | GUI app |
| Onyx | Homebrew Cask (onyx) | GUI app |
| Keka | Homebrew Cask | GUI app |
| flux | Homebrew Cask (flux) | GUI app |
| **Monitoring** | | |
| btop | Nix (nixpkgs.btop) | CLI tool, Nix-friendly |
| iStat Menus | Homebrew Cask | GUI app |
| macmon | Homebrew Cask | GUI app |
| **Communication** | | |
| WhatsApp | mas (Mac App Store) OR Homebrew Cask | Prefer mas if available |
| Zoom | Homebrew Cask | GUI app |
| Webex | Homebrew Cask (webex) | GUI app |
| **Media** | | |
| VLC | Homebrew Cask | GUI app |
| GIMP | Homebrew Cask | GUI app |
| **Security** | | |
| NordVPN | Homebrew Cask (nordvpn) | GUI app |
| **Virtualization** | | |
| Parallels Desktop | Homebrew Cask (parallels) | GUI app, Power profile only |
| **Shell & CLI Tools** | | |
| Zsh | Built-in (macOS) | Already included |
| Oh My Zsh | Home Manager | Managed declaratively |
| fzf | Nix (nixpkgs.fzf) | CLI tool |
| zsh-autosuggestions | Home Manager (Oh My Zsh plugin) | Shell plugin |
| Starship | Nix (nixpkgs.starship) | CLI tool, cross-platform |
| ripgrep | Nix (nixpkgs.ripgrep) | CLI tool |
| fd | Nix (nixpkgs.fd) | CLI tool |
| jq | Nix (nixpkgs.jq) | CLI tool |
| yq | Nix (nixpkgs.yq) | CLI tool |
| bat | Nix (nixpkgs.bat) | CLI tool |
| eza | Nix (nixpkgs.eza) | CLI tool (ls replacement) |
| **Fonts** | | |
| JetBrains Mono Nerd Font | Nix (nixpkgs.nerdfonts) | Managed with system |
| **Office & Work** | | |
| Office 365 | Manual Installation | Requires Microsoft account, company policy |

**Installation Method Priority:**
1. ✅ **Nix** - For CLI tools, development tools, reproducible packages
2. ✅ **Homebrew Cask** - For GUI apps, apps with frequent updates
3. ✅ **mas** (Mac App Store) - Only when no Homebrew/Nix option
4. ✅ **Manual** - For licensed/corporate software (Office 365)

---

### Appendix B: Bootstrap Script Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  User runs: curl ... | bash                                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 1: Pre-flight Checks                                 │
│  - Verify macOS version (Sonoma 14.x+)                      │
│  - Check internet connectivity                              │
│  - Ensure not running as root                               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 2: Install Xcode Command Line Tools                  │
│  - Check if already installed                               │
│  - If not: xcode-select --install                           │
│  - Wait for completion (user confirms)                      │
│  - Accept license: sudo xcodebuild -license accept          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 3: User Configuration Prompts                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Enter your full name: ________________               │  │
│  │ Enter your email: ____________________               │  │
│  │ Enter your GitHub username: __________               │  │
│  │                                                       │  │
│  │ Select installation profile:                         │  │
│  │   [1] Standard (MacBook Air - essential apps)        │  │
│  │   [2] Power (MacBook Pro - Parallels + extra models) │  │
│  │                                                       │  │
│  │ Choice: __                                            │  │
│  └──────────────────────────────────────────────────────┘  │
│  - Validate inputs (email format, no special chars)         │
│  - Store in variables for later                             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 4: Fetch Flake from GitHub                           │
│  - URL: https://raw.githubusercontent.com/fxmartin/         │
│         nix-config/main/flake.nix                           │
│  - curl flake.nix to /tmp/nix-bootstrap/                    │
│  - curl user-config.template.nix                            │
│  - Populate user-config.nix with user inputs                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 5: Install Nix Package Manager                       │
│  - Check if Nix already installed (command -v nix)          │
│  - If not: curl -L https://nixos.org/nix/install | sh       │
│  - Multi-user installation (requires sudo)                  │
│  - Enable experimental features (flakes)                    │
│  - Source nix profile: source /nix/var/.../set-environment  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 6: Install nix-darwin                                │
│  - Export NIX_CONFIG="experimental-features = flakes"       │
│  - Run: nix run nix-darwin -- switch --flake                │
│         /tmp/nix-bootstrap#standard  (or #power)            │
│  - This installs Homebrew as a Nix-managed dependency       │
│  - Installs core apps defined in flake                      │
│  - Applies system preferences (Finder, trackpad, etc.)      │
│  - Duration: 10-20 minutes (downloads + builds)             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 7: SSH Key Setup                                     │
│  - Check for existing ~/.ssh/id_ed25519 key                 │
│  - If exists: "Use existing key? (y/n)"                     │
│  - If not or user says no:                                  │
│    ssh-keygen -t ed25519 -C "user@email.com" -f ~/.ssh/...  │
│  - Start ssh-agent, add key                                 │
│  - Display public key:                                      │
│    ┌────────────────────────────────────────────────────┐  │
│    │ Your SSH public key:                               │  │
│    │ ssh-ed25519 AAAAC3... user@email.com               │  │
│    │                                                     │  │
│    │ 1. Go to: https://github.com/settings/keys         │  │
│    │ 2. Click "New SSH key"                             │  │
│    │ 3. Paste the above key                             │  │
│    │ 4. Click "Add SSH key"                             │  │
│    │                                                     │  │
│    │ Press ENTER when you've added the key...           │  │
│    └────────────────────────────────────────────────────┘  │
│  - Wait for user confirmation                               │
│  - Test: ssh -T git@github.com (should authenticate)        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 8: Clone Full Dotfiles Repository                    │
│  - git clone git@github.com:fxmartin/nix-config.git         │
│         ~/Documents/nix-config/                             │
│  - Copy user-config.nix from /tmp to repo                   │
│  - cd ~/Documents/nix-config                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 9: Final System Rebuild                              │
│  - darwin-rebuild switch --flake                            │
│         ~/Documents/nix-config#standard (or #power)         │
│  - Applies complete configuration with all modules          │
│  - Symlinks configs: ~/.config/ghostty, ~/.zshrc, etc.      │
│  - Duration: 2-5 minutes (most cached from Phase 6)         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 10: Post-Install Summary & Next Steps                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ ✅ Installation Complete!                            │  │
│  │                                                       │  │
│  │ What was installed:                                  │  │
│  │  • Nix package manager                               │  │
│  │  • nix-darwin system configuration                   │  │
│  │  • 47 applications (Standard) / 51 (Power)           │  │
│  │  • System preferences configured                     │  │
│  │  • Shell environment (Zsh + Oh My Zsh)               │  │
│  │  • Development tools (Python, Podman, Git LFS)       │  │
│  │                                                       │  │
│  │ Next Steps:                                          │  │
│  │  1. Restart your terminal (or run: source ~/.zshrc)  │  │
│  │  2. Activate licensed apps:                          │  │
│  │     - 1Password (sign in)                            │  │
│  │     - NordVPN (sign in)                              │  │
│  │     - iStat Menus (enter license)                    │  │
│  │     - [Full list: ~/Documents/nix-config/docs/       │  │
│  │        licensed-apps.md]                             │  │
│  │  3. Install Office 365 manually (if needed for work) │  │
│  │  4. Verify Ollama: ollama list (should show models)  │  │
│  │                                                       │  │
│  │ Useful Commands:                                     │  │
│  │  • rebuild - Apply config changes                    │  │
│  │  • update - Update packages and rebuild              │  │
│  │  • health-check - Verify system health               │  │
│  │  • cleanup - Run garbage collection                  │  │
│  │                                                       │  │
│  │ Documentation: ~/Documents/nix-config/README.md      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                     │
                     ▼
                  [DONE]
```

---

### Appendix C: Profile Comparison

| Feature/App | Standard Profile | Power Profile |
|---|---|---|
| **Target Hardware** | MacBook Air (512GB storage typical) | MacBook Pro M3 Max (1TB storage) |
| **Use Case** | Portable, travel, light dev work | Main development machine, VM work |
| **Virtualization** | None | Parallels Desktop |
| **Ollama Models** | `gpt-oss:20b` only (~12GB) | `gpt-oss:20b`, `qwen2.5-coder:32b`, `llama3.1:70b`, `deepseek-r1:32b` (~80GB total) |
| **Development Tools** | ✅ Same (Python, Podman, Git LFS) | ✅ Same |
| **AI Apps** | ✅ Same (Claude, ChatGPT, Perplexity) | ✅ Same |
| **Browsers** | ✅ Same (Safari, Firefox, Arc) | ✅ Same |
| **Productivity** | ✅ Same (Raycast, 1Password, etc.) | ✅ Same |
| **Communication** | ✅ Same (Zoom, Webex, WhatsApp) | ✅ Same |
| **Media** | ✅ Same (VLC, GIMP) | ✅ Same |
| **Monitoring** | ✅ Same (btop, iStat, macmon) | ✅ Same |
| **System Config** | ✅ Same (Finder, trackpad, security) | ✅ Same |
| **Shell Environment** | ✅ Same (Zsh, Oh My Zsh, Ghostty) | ✅ Same |
| **Theming** | ✅ Same (Catppuccin) | ✅ Same |
| **Total App Count** | ~47 apps | ~51 apps (+ Parallels + extra Ollama models) |
| **Estimated Disk Usage (Apps)** | ~35GB (with 1 Ollama model) | ~120GB (with Parallels + 4 Ollama models) |

**Profile Selection Logic in Bootstrap:**
```bash
echo "Select installation profile:"
echo "  [1] Standard - MacBook Air (essential apps, light storage)"
echo "      • Core development tools"
echo "      • 1 Ollama model (gpt-oss:20b)"
echo "      • No virtualization"
echo ""
echo "  [2] Power - MacBook Pro M3 Max (full suite, heavy storage)"
echo "      • All development tools"
echo "      • 4 Ollama models (~80GB)"
echo "      • Parallels Desktop for VMs"
echo ""
read -p "Enter choice [1-2]: " profile_choice

case $profile_choice in
  1)
    PROFILE="standard"
    ;;
  2)
    PROFILE="power"
    ;;
  *)
    echo "Invalid choice, defaulting to Standard"
    PROFILE="standard"
    ;;
esac
```

---

### Appendix D: Nix Flake Structure

**Simplified flake.nix outline:**

```nix
{
  description = "FX's macOS Nix-Darwin Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, stylix, ... }: {

    # Standard Profile (MacBook Air)
    darwinConfigurations.standard = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # Apple Silicon
      modules = [
        ./darwin/configuration.nix
        ./darwin/homebrew.nix
        ./darwin/macos-defaults.nix
        ./darwin/system-monitoring.nix
        home-manager.darwinModules.home-manager
        stylix.darwinModules.stylix
        {
          # User config
          users.users.fx = import ./user-config.nix;

          # Profile-specific settings
          environment.systemPackages = [
            # Common packages for both profiles
          ];

          homebrew.casks = [
            # Standard profile casks (no Parallels)
          ];

          # Stylix theming
          stylix = {
            enable = true;
            base16Scheme = "${nixpkgs}/catppuccin-mocha";
            fonts.monospace = {
              package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
              name = "JetBrains Mono Nerd Font";
            };
          };
        }
      ];
    };

    # Power Profile (MacBook Pro M3 Max)
    darwinConfigurations.power = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./darwin/configuration.nix
        ./darwin/homebrew.nix
        ./darwin/macos-defaults.nix
        ./darwin/system-monitoring.nix
        home-manager.darwinModules.home-manager
        stylix.darwinModules.stylix
        {
          # User config
          users.users.fx = import ./user-config.nix;

          # Profile-specific settings
          environment.systemPackages = [
            # Common packages + power-specific
          ];

          homebrew.casks = [
            # Standard casks + Parallels
            "parallels"
          ];

          # Power profile: Pull extra Ollama models
          system.activationScripts.postActivation.text = ''
            # Pull Ollama models
            /opt/homebrew/bin/ollama pull gpt-oss:20b
            /opt/homebrew/bin/ollama pull qwen2.5-coder:32b
            /opt/homebrew/bin/ollama pull llama3.1:70b
            /opt/homebrew/bin/ollama pull deepseek-r1:32b
          '';

          # Stylix theming (same as Standard)
          stylix = { ... };
        }
      ];
    };
  };
}
```

**Directory structure:**
```
nix-config/
├── flake.nix                    # Main system definition (profiles)
├── flake.lock                   # Dependency lock file
├── user-config.nix              # User personal info (git-ignored or template)
├── user-config.template.nix     # Template for new users
├── README.md                    # Quick start guide
├── bootstrap.sh                 # One-command installation script
│
├── darwin/                      # System-level (nix-darwin)
│   ├── configuration.nix        # Main darwin config
│   ├── homebrew.nix             # Homebrew packages/casks
│   ├── macos-defaults.nix       # macOS system preferences
│   ├── system-monitoring.nix    # GC, optimization, health checks
│   └── nix-settings.nix         # Nix daemon configuration
│
├── home-manager/                # User-level (dotfiles)
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
└── docs/                        # Documentation
    ├── quick-start.md           # Installation guide
    ├── licensed-apps.md         # Activation instructions
    ├── customization.md         # How to modify config
    └── troubleshooting.md       # Common issues & fixes
```

---

### Appendix E: Success Metrics Dashboard (Post-Launch)

**Week 1-2 Tracking:**
```
┌─────────────────────────────────────────────────────────────┐
│ Nix-Darwin Migration Progress                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ MacBooks Migrated:           [1/3] 33%  ▓▓▓▓▓░░░░░░░░░░░   │
│ Bootstrap Success Rate:      [1/1] 100% ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   │
│ Time to Configured System:   [28 min]  ✅ Under 30min goal │
│                                                             │
│ Blocker Issues:              [0] 🎉 None                    │
│ Minor Issues:                [2] ⚠️  (documented below)     │
│                                                             │
│ User Satisfaction:           [9/10] 😊 "Love it!"          │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ Issues Log:                                                 │
│ • Ghostty window transparency not working → Fixed in config │
│ • iStat Menus license activation unclear → Doc updated     │
└─────────────────────────────────────────────────────────────┘
```

**Week 8 (Final) Tracking:**
```
┌─────────────────────────────────────────────────────────────┐
│ Nix-Darwin Migration Final Report                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ MacBooks Migrated:           [3/3] 100% ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   │
│ Bootstrap Success Rate:      [3/3] 100% ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   │
│ Avg Time to Configured:      [26 min]  ✅ 13% under goal   │
│                                                             │
│ Total Time Saved:            12 hours  (3 reinstalls × 4h)  │
│ Config Drift Detected:       [0] ✅ Perfect consistency     │
│                                                             │
│ Rebuild Frequency:           2.3/week  ✅ Active usage      │
│ Rollbacks Needed:            [0] ✅ Stable config           │
│                                                             │
│ User Confidence:             [9/10] 😊 "Can rebuild anytime"│
│ Would Recommend:             [10/10] 🎉 "Absolutely"       │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ Success Criteria Met:                                       │
│ ✅ All 3 MacBooks migrated                                  │
│ ✅ Bootstrap works without manual intervention              │
│ ✅ Documentation complete and usable                        │
│ ✅ All P0 requirements implemented                          │
│ ✅ First rebuild successful without help                    │
│ ✅ All critical workflows functional                        │
│                                                             │
│ 🎯 SUCCESS DECLARED 🎯                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This PRD defines a comprehensive, automated MacBook configuration system using Nix + nix-darwin to solve the real problem of managing multiple machines with frequent reinstalls. The solution balances automation (one-command bootstrap), reproducibility (declarative config), and pragmatism (Homebrew for GUI apps, manual steps for licensed software).

**Key Differentiators from Current Mac-setup Approach:**
- ⏱️ **Time**: 4-6 hours → 30 minutes (90% reduction)
- 🔄 **Reproducibility**: Manual checklist → Declarative code (100% consistent)
- 📝 **Version Control**: Docs drift from reality → Config IS reality
- 🎯 **Rollback**: No safety net → Atomic updates with instant rollback
- 🔧 **Maintenance**: Manual updates → Automated GC and optimization

**Next Steps:**
1. Review and approve PRD
2. Create GitHub repository
3. Begin Phase 0 implementation (Foundation)
4. Iterate based on real-world usage

**Questions for Stakeholder (FX):**
- Does this match your vision and requirements?
- Are the two profiles (Standard/Power) sufficient, or do you need more granularity?
- Is the 8-week timeline realistic for your availability?
- Any critical apps or preferences missing from the requirements?

---

**Document Version**: 1.0
**Last Updated**: 2025-01-08
**Author**: Product Manager (Claude)
**Stakeholder**: FX (François)
**Status**: Draft - Awaiting Approval
