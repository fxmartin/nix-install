# ABOUTME: Epic-07 Feature 07.1 (Quick Start Documentation) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 07.1

# Epic-07 Feature 07.1: Quick Start Documentation

## Feature Overview

**Feature ID**: Feature 07.1
**Feature Name**: Quick Start Documentation
**Epic**: Epic-07
**Status**: 🔄 In Progress

**Feature Description**: Create README with installation instructions and update philosophy
**User Value**: Clear, concise guide to get started quickly
**Story Count**: 2
**Story Points**: 10
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 07.1-001: README Quick Start Guide
**User Story**: As FX, I want a clear README with one-command installation instructions so that I can bootstrap a fresh Mac quickly

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** README.md exists in repository root
- **When** I read the README
- **Then** it shows one-command bootstrap installation
- **And** it explains Standard vs Power profiles with clear differences
- **And** it lists what gets installed (apps, config, settings)
- **And** it shows expected installation time (~30 minutes)
- **And** it notes manual steps (SSH key upload, FileVault, license activation)
- **And** it's written for non-Nix users (clear, jargon-free)

**Additional Requirements**:
- Bootstrap command: `curl -sSL https://raw.githubusercontent.com/fxmartin/nix-install/main/bootstrap.sh | bash`
- Profile comparison: Table or list showing differences
- Time estimate: Set expectations (30 minutes)
- Prerequisites: macOS Sonoma 14.x+, internet connection
- Approachable: Non-technical language

**Technical Notes**:
- README structure:
  ```markdown
  # Nix-Darwin MacBook Setup System

  Automated, declarative MacBook configuration using Nix + nix-darwin.

  ## Quick Start

  Run this command on a fresh macOS installation:

  \`\`\`bash
  curl -sSL https://raw.githubusercontent.com/fxmartin/nix-install/main/bootstrap.sh | bash
  \`\`\`

  Follow the prompts:
  1. Enter your name, email, GitHub username
  2. Choose profile (Standard or Power)
  3. Add SSH key to GitHub when prompted
  4. Wait ~30 minutes for installation

  ## What Gets Installed

  - 47+ applications (Standard) / 51+ (Power)
  - Development tools (Python, Podman, Git LFS, Zed, VSCode)
  - AI/LLM tools (Claude, ChatGPT, Perplexity, Ollama)
  - Productivity apps (Raycast, 1Password, Dropbox, etc.)
  - System preferences (Finder, security, trackpad, etc.)
  - Shell environment (Zsh, Oh My Zsh, Starship, FZF)
  - Catppuccin theming (Ghostty, Zed)

  ## Profiles

  | Feature | Standard | Power |
  |---------|----------|-------|
  | Target | MacBook Air | MacBook Pro M3 Max |
  | Apps | 47+ | 51+ |
  | Ollama Models | 1 (~12GB) | 4 (~80GB) |
  | Parallels | No | Yes |
  | Disk Usage | ~35GB | ~120GB |

  ## Post-Install Steps

  See [docs/post-install.md](docs/post-install.md) for:
  - License activation (1Password, iStat Menus, etc.)
  - Office 365 installation
  - Ollama model verification

  ## Common Commands

  - `rebuild` - Apply config changes
  - `update` - Update packages and rebuild (ONLY way to update apps)
  - `gc` - Garbage collection
  - `cleanup` - Full cleanup (GC + optimization)
  - `health-check` - Verify system health
  ```

**Definition of Done**:
- [ ] README.md created
- [ ] Quick start section complete
- [ ] Profile comparison clear
- [ ] What gets installed listed
- [ ] Post-install steps linked
- [ ] Common commands documented
- [ ] Written for non-Nix users
- [ ] Reviewed for clarity

**Dependencies**:
- Epic-01 (Bootstrap process to document)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 07.1-002: Update Philosophy Documentation
**User Story**: As FX, I want documentation explaining the update philosophy so that I understand how app updates work

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** README or docs/update-philosophy.md exists
- **When** I read the update documentation
- **Then** it explains that `rebuild` applies config changes (uses current flake.lock)
- **And** it explains that `update` updates flake.lock + rebuilds (updates all apps)
- **And** it clarifies that `update` is the ONLY way apps update (no auto-updates)
- **And** it explains why auto-updates are disabled (reproducibility, control)
- **And** it shows how to check for updates (`nix flake metadata`)
- **And** it explains rollback capability if update breaks something

**Additional Requirements**:
- Clear distinction: `rebuild` vs `update`
- Philosophy: Controlled updates, no surprises
- Rationale: Reproducibility, testing before production
- Rollback: Safety net for bad updates
- Check updates: Optional command to see available updates

**Technical Notes**:
- Add to README or separate docs/update-philosophy.md:
  ```markdown
  ## Update Philosophy

  **All app updates are controlled via rebuild commands only. Auto-updates are disabled.**

  ### Commands

  - **`rebuild`** - Apply configuration changes
    - Uses current flake.lock (package versions)
    - Applies config edits (new apps, settings changes)
    - Fast (most packages cached)

  - **`update`** - Update packages and rebuild
    - Updates flake.lock (gets latest package versions)
    - Rebuilds system with new versions
    - This is the ONLY way apps update
    - Test in VM before production if concerned

  ### Why Disable Auto-Updates?

  - **Reproducibility**: Same config = same versions = same system state
  - **Control**: You choose when to update, not apps
  - **Testing**: Update one machine first, verify, then others
  - **Rollback**: If update breaks something, rollback to previous generation

  ### Checking for Updates

  \`\`\`bash
  cd ~/Documents/nix-install
  nix flake metadata  # Shows current inputs
  nix flake lock --update-input nixpkgs  # Preview available updates
  \`\`\`

  ### Rollback if Needed

  \`\`\`bash
  darwin-rebuild --list-generations  # List available generations
  darwin-rebuild --rollback  # Rollback to previous generation
  \`\`\`
  ```

**Definition of Done**:
- [ ] Update philosophy documented
- [ ] rebuild vs update explained
- [ ] Rationale for disabled auto-updates clear
- [ ] Check for updates command shown
- [ ] Rollback process documented
- [ ] Reviewed for clarity

**Dependencies**:
- Epic-04, Story 04.5-001 (rebuild and update aliases)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 07.2: Licensed App Activation Guide
**Feature Description**: Step-by-step activation instructions for licensed apps
**User Value**: Quick, painless license activation for all paid apps
**Story Count**: 2
**Story Points**: 8
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 07.2-001: Licensed App Documentation
**User Story**: As FX, I want a guide listing all licensed apps with activation steps so that I can activate licenses quickly

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** docs/licensed-apps.md exists
- **When** I read the guide
- **Then** it lists all apps requiring activation: 1Password, iStat Menus, NordVPN, Zoom, Webex, Parallels, Dropbox
- **And** it provides step-by-step activation for each app
- **And** it notes which apps require license keys vs account sign-in
- **And** it estimates 15 minutes total activation time
- **And** it links to vendor documentation for detailed help

**Additional Requirements**:
- Complete list: All licensed apps from Epic-02
- Categorization: License key vs sign-in
- Steps: Clear, numbered instructions
- Time estimate: Set expectations
- External links: Vendor docs for troubleshooting

**Technical Notes**:
- Create docs/licensed-apps.md:
  ```markdown
  # Licensed App Activation Guide

  The following apps require manual activation or sign-in. Estimated time: 15 minutes.

  ## Apps Requiring Account Sign-In

  ### 1Password
  1. Launch 1Password
  2. Click "Sign In"
  3. Enter your 1Password account email
  4. Follow authentication flow
  5. Safari/browser extension will prompt for installation (optional)

  ### Dropbox
  1. Launch Dropbox
  2. Click "Sign In"
  3. Enter your Dropbox account email/password
  4. Choose sync folder location (default: ~/Dropbox)
  5. Wait for initial sync to complete

  ### NordVPN
  1. Launch NordVPN
  2. Click "Sign In"
  3. Enter your NordVPN account email/password
  4. Grant network extension permission when prompted
  5. Connect to preferred server

  ### Zoom
  1. Launch Zoom
  2. Click "Sign In"
  3. Enter your work/personal Zoom account
  4. Grant camera/microphone permissions when prompted

  ### Webex
  1. Launch Webex
  2. Click "Sign In"
  3. Enter your company Webex account
  4. Grant permissions when prompted

  ## Apps Requiring License Keys

  ### iStat Menus
  1. Launch iStat Menus
  2. Trial mode starts automatically (14 days)
  3. To activate:
     - iStat Menus menu → "Registration"
     - Enter license key from email or 1Password
     - Click "Register"
  4. Configure menubar items: Preferences → Menubar

  ### Parallels Desktop (Power Profile Only)
  1. Launch Parallels Desktop
  2. Trial mode starts automatically (14 days)
  3. To activate:
     - Parallels Desktop menu → "Account & License"
     - Enter license key from email or 1Password
     - Click "Activate"
  4. Create VMs as needed

  ## Apps Not Requiring Activation

  All other apps are free or require no license activation.

  ## Troubleshooting

  If activation fails:
  - 1Password: Visit https://support.1password.com
  - iStat Menus: Visit https://bjango.com/help/istatmenus/
  - NordVPN: Visit https://support.nordvpn.com
  - Parallels: Visit https://kb.parallels.com
  ```

**Definition of Done**:
- [ ] docs/licensed-apps.md created
- [ ] All licensed apps listed
- [ ] Activation steps for each app
- [ ] Categorized by sign-in vs license key
- [ ] Time estimate included
- [ ] Vendor links provided
- [ ] Reviewed for accuracy

**Dependencies**:
- Epic-02 (Applications requiring licenses)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 07.2-002: Post-Install Checklist
**User Story**: As FX, I want a post-install checklist so that I don't forget critical steps after bootstrap

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** docs/post-install.md exists
- **When** I read the checklist
- **Then** it lists all post-install tasks in order
- **And** includes restarting terminal or sourcing ~/.zshrc
- **And** includes activating licensed apps (link to licensed-apps.md)
- **And** includes enabling FileVault if not enabled
- **And** includes verifying Ollama models (Power profile)
- **And** includes installing Office 365 manually (if needed)
- **And** includes running health-check command
- **And** uses checkboxes for easy tracking

**Additional Requirements**:
- Checklist format: Markdown checkboxes
- Ordered: Logical sequence
- Complete: All manual steps
- Links: Reference other docs
- Quick: 5-10 minutes to complete (excluding Office 365)

**Technical Notes**:
- Create docs/post-install.md:
  ```markdown
  # Post-Install Checklist

  After bootstrap completes, complete these steps:

  ## Immediate Steps

  - [ ] Restart terminal or run `source ~/.zshrc`
  - [ ] Verify shell prompt shows Starship (directory, git info)
  - [ ] Run `health-check` to verify system health

  ## Security

  - [ ] Enable FileVault if not enabled:
    - System Settings → Privacy & Security → FileVault
    - Turn On, save recovery key to 1Password
    - Restart to complete encryption

  ## Licensed Apps

  - [ ] Activate licensed apps (see [licensed-apps.md](licensed-apps.md)):
    - 1Password (sign in)
    - Dropbox (sign in)
    - NordVPN (sign in)
    - Zoom (sign in)
    - Webex (sign in)
    - iStat Menus (enter license key)
    - Parallels Desktop - Power only (enter license key)

  ## Optional Steps

  - [ ] Install Office 365 manually (if needed for work):
    - Visit https://office.com or company portal
    - Sign in and download installer
    - Install and activate

  - [ ] Verify Ollama models (Power profile only):
    - Run `ollama list`
    - Should show: gpt-oss:20b, qwen2.5-coder:32b, llama3.1:70b, deepseek-r1:32b
    - Test: `ollama run gpt-oss:20b "Hello"`

  - [ ] Configure Raycast hotkey:
    - Launch Raycast
    - Preferences → General → Hotkey
    - Set to Cmd+Space or preferred shortcut

  - [ ] Set default browser (if desired):
    - System Settings → Desktop & Dock → Default web browser
    - Choose Firefox or Arc

  ## Verify Installation

