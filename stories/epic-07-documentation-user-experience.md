# Epic 07: Documentation & User Experience

## Epic Overview
**Epic ID**: Epic-07
**Epic Description**: Comprehensive documentation covering quick start guide, licensed app activation, troubleshooting, and customization. Creates a complete documentation package that enables FX to use, maintain, and extend the Nix-based system confidently without external help. Includes README, post-install guides, troubleshooting steps, and customization examples.
**Business Value**: Reduces learning curve, enables self-service support, makes system approachable for non-Nix users
**User Impact**: FX can understand, troubleshoot, and customize the system without needing to be a Nix expert
**Success Metrics**:
- Non-technical user can follow README and complete install
- All licensed apps can be activated within 15 minutes using guide
- Common issues have documented solutions
- User can add new app and rebuild successfully following customization guide

## Epic Scope
**Total Stories**: 8
**Total Story Points**: 34
**MVP Stories**: 8 (100% of epic)
**Priority Level**: Must Have
**Target Release**: Phase 8 (Week 6)

## Features in This Epic

### Feature 07.1: Quick Start Documentation
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

  - [ ] Open Ghostty terminal - theme should match system appearance
  - [ ] Open Zed editor - theme should match Ghostty
  - [ ] Run `python --version` - should show 3.12.x
  - [ ] Run `podman run hello-world` - should work
  - [ ] Run `git config user.name` - should show your name

  ## Done!

  Your Mac is now fully configured. See [README.md](../README.md) for common commands.
  ```

**Definition of Done**:
- [ ] docs/post-install.md created
- [ ] Checklist complete and ordered
- [ ] All manual steps included
- [ ] Links to other docs
- [ ] Checkbox format for tracking
- [ ] Reviewed for completeness

**Dependencies**:
- Story 07.2-001 (Licensed apps guide)
- Epic-01 (Bootstrap completion)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 07.3: Troubleshooting Guide
**Feature Description**: Common issues and solutions for self-service support
**User Value**: Quick resolution of common problems without external help
**Story Count**: 2
**Story Points**: 8
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 07.3-001: Common Issues Documentation
**User Story**: As FX, I want documentation for common issues so that I can troubleshoot problems myself

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** docs/troubleshooting.md exists
- **When** I encounter a problem
- **Then** I can find it in the troubleshooting guide
- **And** solution steps are clear and actionable
- **And** guide covers: build failures, app issues, network problems, SSH errors, Podman issues
- **And** each issue has: symptom, cause, solution
- **And** solutions reference health-check command where applicable

**Additional Requirements**:
- Common issues: Build failures, SSH, Homebrew, Podman, app crashes
- Format: Symptom → Cause → Solution
- Actionable: Step-by-step fixes
- Health check: Reference where relevant
- Examples: Real error messages

**Technical Notes**:
- Create docs/troubleshooting.md:
  ```markdown
  # Troubleshooting Guide

  ## Build Failures

  ### Symptom: darwin-rebuild fails with "error: collision between..."

  **Cause**: Two packages trying to install the same file

  **Solution**:
  1. Check error message for conflicting packages
  2. Remove one package from configuration or use environment.pathsToLink
  3. Rebuild

  ### Symptom: "error: unable to download..."

  **Cause**: Network issue or nixpkgs cache unavailable

  **Solution**:
  1. Check internet connection
  2. Try again in a few minutes (cache may be updating)
  3. If persistent: `nix flake lock --update-input nixpkgs`

  ## Homebrew Issues

  ### Symptom: Homebrew commands not found

  **Cause**: PATH not including Homebrew

  **Solution**:
  1. Run `source ~/.zshrc`
  2. Verify: `which brew` shows `/opt/homebrew/bin/brew`
  3. If not, run `health-check` to diagnose

  ### Symptom: "Error: Another active Homebrew update process is already in progress"

  **Cause**: Homebrew update lock file stuck

  **Solution**:
  ```bash
  rm -f /opt/homebrew/var/homebrew/locks/update
  ```

  ## SSH and Git Issues

  ### Symptom: git clone fails with "Permission denied (publickey)"

  **Cause**: SSH key not added to GitHub or ssh-agent

  **Solution**:
  1. Verify key exists: `ls ~/.ssh/id_ed25519`
  2. Test connection: `ssh -T git@github.com`
  3. If fails, re-add key to GitHub: https://github.com/settings/keys
  4. Add to ssh-agent: `ssh-add ~/.ssh/id_ed25519`

  ## Podman Issues

  ### Symptom: podman run fails with "cannot connect to Podman"

  **Cause**: Podman machine not initialized or not running

  **Solution**:
  ```bash
  podman machine init
  podman machine start
  podman run hello-world
  ```

  ### Symptom: Podman machine won't start

  **Cause**: Conflicting VM or networking issue

  **Solution**:
  1. Stop and remove machine: `podman machine stop && podman machine rm`
  2. Re-initialize: `podman machine init && podman machine start`

  ## App Issues

  ### Symptom: App crashes on launch

  **Cause**: Missing dependencies or corrupted installation

  **Solution**:
  1. Reinstall via rebuild: Add app to config, `rebuild`
  2. Check logs: Console.app → filter by app name
  3. If Homebrew app: `brew reinstall <app-name>`

  ## System Issues

  ### Symptom: health-check shows warnings

  **Cause**: Various (check specific warning)

  **Solution**: Follow recommendations in health-check output

  ### Symptom: Slow terminal startup

  **Cause**: Oh My Zsh plugins or heavy initialization

  **Solution**:
  1. Profile startup: `time zsh -i -c exit`
  2. Disable heavy plugins in zsh.nix
  3. Use lazy-loading for infrequently used tools

  ## Still Stuck?

  1. Check nix-darwin documentation: https://github.com/LnL7/nix-darwin
  2. Check Nix manual: https://nixos.org/manual/nix/stable/
  3. Search GitHub issues: nix-darwin, Home Manager
  4. Run `health-check` for system diagnosis
  ```

**Definition of Done**:
- [ ] docs/troubleshooting.md created
- [ ] Common issues documented
- [ ] Symptom → Cause → Solution format
- [ ] Solutions actionable
- [ ] health-check referenced
- [ ] Reviewed for accuracy

**Dependencies**:
- Epic-06, Story 06.4-001 (health-check command)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 07.3-002: Rollback Documentation
**User Story**: As FX, I want clear documentation on how to rollback if an update breaks something so that I can recover quickly

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** docs/troubleshooting.md or README includes rollback section
- **When** an update breaks my system
- **Then** I can find rollback instructions quickly
- **And** instructions show how to list generations
- **And** instructions show how to rollback to previous generation
- **And** instructions show how to rollback to specific generation by number
- **And** rollback process is quick (<1 minute)

**Additional Requirements**:
- Rollback: darwin-rebuild --rollback
- List generations: darwin-rebuild --list-generations
- Specific generation: darwin-rebuild switch --flake .#<profile> --rollback-to <generation>
- Recovery: Fast and reliable

**Technical Notes**:
- Add to docs/troubleshooting.md or README:
  ```markdown
  ## Rollback to Previous Generation

  If an update breaks your system, rollback is instant:

  ### Quick Rollback (to previous generation)

  ```bash
  darwin-rebuild --rollback
  ```

  ### Rollback to Specific Generation

  1. List generations:
     ```bash
     darwin-rebuild --list-generations
     ```

  2. Note the generation number you want (e.g., 42)

  3. Rollback to that generation:
     ```bash
     darwin-rebuild switch --flake ~/Documents/nix-install#<profile> --profile-name <generation>
     ```

  ### Verify Rollback

  - Apps, configs, and settings revert to selected generation
  - Check with `health-check`
  - If satisfied, continue using rolled-back state
  - If ready to try update again, run `update`

  ### Delete Broken Generation (optional)

  After rolling back, you can delete the broken generation:

  ```bash
  nix-env --delete-generations <generation-number>
  ```
  ```

**Definition of Done**:
- [ ] Rollback documented in troubleshooting or README
- [ ] List generations command shown
- [ ] Rollback command shown
- [ ] Specific generation rollback shown
- [ ] Quick and clear
- [ ] Reviewed for accuracy

**Dependencies**:
- Story 07.3-001 (Troubleshooting guide)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 07.4: Customization Guide
**Feature Description**: Documentation for adding apps, changing settings, and extending config
**User Value**: Empowers FX to customize and extend the system independently
**Story Count**: 2
**Story Points**: 8
**Priority**: Medium
**Complexity**: Low

#### Stories in This Feature

##### Story 07.4-001: Adding Apps Documentation
**User Story**: As FX, I want documentation showing how to add new apps so that I can extend my system

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** docs/customization.md exists
- **When** I want to add a new app
- **Then** guide shows how to add via Nix, Homebrew, or mas
- **And** provides examples for each method
- **And** explains when to use each method (Nix vs Homebrew vs mas)
- **And** shows full workflow: edit config → rebuild → verify

**Additional Requirements**:
- Three methods: Nix, Homebrew Cask, mas
- Examples: Real apps (e.g., add Notion, Spotify)
- Decision guide: Which method to use
- Full workflow: Edit → rebuild → verify
- Testing: How to verify app installed

**Technical Notes**:
- Create docs/customization.md:
  ```markdown
  # Customization Guide

  ## Adding New Applications

  ### Method 1: Nix (for CLI tools and dev tools)

  **When to use**: Command-line tools, libraries, programming languages

  **Example**: Adding `ripgrep` (fast grep alternative)

  1. Edit `darwin/configuration.nix`:
     ```nix
     environment.systemPackages = with pkgs; [
       # ... existing packages
       ripgrep  # Add new package
     ];
     ```

  2. Rebuild:
     ```bash
     rebuild
     ```

  3. Verify:
     ```bash
     which rg  # Should show /nix/store/... path
     rg --version
     ```

  ### Method 2: Homebrew Cask (for GUI apps)

  **When to use**: GUI applications, apps with frequent updates

  **Example**: Adding Notion

  1. Edit `darwin/homebrew.nix`:
     ```nix
     homebrew.casks = [
       # ... existing casks
       "notion"  # Add new cask
     ];
     ```

  2. Rebuild:
     ```bash
     rebuild
     ```

  3. Verify:
     ```bash
     ls /Applications/Notion.app  # Should exist
     open -a Notion  # Launch app
     ```

  ### Method 3: Mac App Store (mas)

  **When to use**: Apps only available on Mac App Store

  **Example**: Adding Pages (App Store ID: 409201541)

  1. Find App Store ID:
     ```bash
     mas search Pages
     # Returns: 409201541 Pages
     ```

  2. Edit `darwin/homebrew.nix`:
     ```nix
     homebrew.masApps = {
       # ... existing apps
       "Pages" = 409201541;
     };
     ```

  3. Rebuild:
     ```bash
     rebuild
     ```

  4. Verify:
     ```bash
     mas list | grep Pages
     ```

  ## Modifying System Preferences

  Edit `darwin/macos-defaults.nix` and rebuild:

  ```nix
  system.defaults.dock = {
    autohide = true;  # Auto-hide dock
    tilesize = 64;    # Larger icons
  };
  ```

  ## Changing Theme or Fonts

  Edit Stylix config in `flake.nix`:

  ```nix
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox.yaml";  # Different theme
    fonts.monospace.name = "Fira Code";  # Different font
  };
  ```

  ## Adding Shell Aliases

  Edit `home-manager/modules/aliases.nix`:

  ```nix
  programs.zsh.shellAliases = {
    # ... existing aliases
    ports = "lsof -i -P";  # Show open ports
  };
  ```
  ```

**Definition of Done**:
- [ ] docs/customization.md created
- [ ] Adding apps via Nix documented
- [ ] Adding apps via Homebrew documented
- [ ] Adding apps via mas documented
- [ ] Examples provided
- [ ] Decision guide (when to use each method)
- [ ] Full workflow shown
- [ ] Reviewed for clarity

**Dependencies**:
- Epic-02 (Application installation methods)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 07.4-002: Configuration Examples
**User Story**: As FX, I want examples of common customizations so that I can modify my system confidently

**Priority**: Should Have
**Story Points**: 3
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** docs/customization.md includes examples section
- **When** I want to customize something
- **Then** guide provides real-world examples: adding aliases, changing Dock settings, adding Finder sidebar items, configuring startup apps
- **And** examples are copy-paste ready
- **And** examples explain what each setting does
- **And** examples reference relevant config files

**Additional Requirements**:
- Real examples: Common customizations
- Copy-paste ready: Working code snippets
- Explanations: What each setting does
- File references: Where to make changes
- Safe: Examples won't break system

**Technical Notes**:
- Add to docs/customization.md:
  ```markdown
  ## Common Customization Examples

  ### Add More Shell Aliases

  File: `home-manager/modules/aliases.nix`

  ```nix
  programs.zsh.shellAliases = {
    # Git shortcuts
    glog = "git log --oneline --graph --decorate";
    gd = "git diff";

    # Navigation
    proj = "cd ~/Projects";
    dots = "cd ~/Documents/nix-install";

    # System
    flush-dns = "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
  };
  ```

  ### Configure Dock Apps

  File: `darwin/macos-defaults.nix`

  ```nix
  system.defaults.dock = {
    autohide = true;              # Auto-hide dock
    show-recents = false;          # Don't show recent apps
    tilesize = 48;                 # Icon size (pixels)
    orientation = "bottom";        # Position: bottom, left, right
    minimize-to-application = true; # Minimize into app icon
  };
  ```

  ### Add Startup Apps (Login Items)

  File: `darwin/configuration.nix`

  ```nix
  system.startup.chime = false;  # Disable startup chime

  # For login items, use System Settings or:
  launchd.user.agents.my-startup-app = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/MyApp.app/Contents/MacOS/MyApp" ];
      RunAtLoad = true;
    };
  };
  ```

  ### Customize Finder Sidebar (Advanced)

  Manual setup required - automated sidebar customization is complex. To customize:

  1. Open Finder → Preferences → Sidebar
  2. Check/uncheck items manually
  3. For smart folders, create manually and add to sidebar

  Nix can configure some Finder settings, but full sidebar automation requires third-party tools like `mysides`.

  ## After Making Changes

  Always rebuild and test:

  ```bash
  rebuild
  # Test your changes
  # If broken, rollback:
  darwin-rebuild --rollback
  ```
  ```

**Definition of Done**:
- [ ] Examples section added to customization.md
- [ ] Multiple real-world examples provided
- [ ] Examples are copy-paste ready
- [ ] Explanations included
- [ ] File references clear
- [ ] Reviewed for safety and accuracy

**Dependencies**:
- Story 07.4-001 (Customization guide base)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: Bootstrap process to document
- **Epic-02 (Applications)**: Licensed apps to document
- **Epic-03 (System Config)**: System preferences to document
- **Epic-04 (Dev Environment)**: Shell and aliases to document
- **Epic-05 (Theming)**: Theming customization to document
- **Epic-06 (Maintenance)**: health-check and maintenance to document

### Stories This Epic Enables
- None (documentation is final epic)

### Stories This Epic Blocks
- None (documentation doesn't block other work)

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 9 | 07.1-001 to 07.4-002 | 34 | Complete documentation package (README, guides, troubleshooting, customization) |

### Delivery Milestones
- **Milestone 1**: End Sprint 9 - All documentation written and reviewed
- **Epic Complete**: Week 6 - Documentation tested by following guides, polish complete

### Risk Assessment
**Low Risk Items**:
- All documentation stories are low risk (writing, no code changes)

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 0 of 8 (0%)
- **Story Points Completed**: 0 of 34 (0%)
- **MVP Stories Completed**: 0 of 8 (0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 9 | 34 | 0 | 0/8 | Not Started |

## Epic Acceptance Criteria
- [ ] All MVP stories (8/8) completed and accepted
- [ ] README complete with quick start and profile comparison
- [ ] Update philosophy clearly explained
- [ ] Licensed apps activation guide complete
- [ ] Post-install checklist comprehensive
- [ ] Troubleshooting guide covers common issues
- [ ] Rollback process documented
- [ ] Customization guide with examples
- [ ] All documentation reviewed for clarity and accuracy
- [ ] Non-technical user can follow and succeed
- [ ] Documentation tested by following guides

## Story Validation Checklist

### Quality Assurance for Each Story
- [ ] Follows proper user story format ("As [persona], I want [functionality] so that [benefit]")
- [ ] Has clear, testable acceptance criteria (Given/When/Then format)
- [ ] Includes all necessary context and constraints
- [ ] Sized appropriately for single sprint
- [ ] Dependencies clearly identified
- [ ] Business value articulated
- [ ] Persona alignment verified (FX as primary user)
- [ ] Technical feasibility confirmed

### Epic Health Metrics
- **Story Readiness**: 100% of stories meet definition of ready
- **Dependency Coverage**: All dependencies identified and managed
- **Estimation Confidence**: High confidence in story point estimates
- **Acceptance Criteria Quality**: Clear, testable, and complete criteria for all stories
