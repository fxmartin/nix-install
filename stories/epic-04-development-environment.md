# Epic 04: Development Environment & Shell Configuration

## Epic Overview
**Epic ID**: Epic-04
**Epic Description**: Complete shell and development environment setup including Zsh with Oh My Zsh, Starship prompt, FZF integration, Ghostty terminal configuration, useful shell aliases, Git configuration with LFS, Python 3.12 with uv and dev tools, Podman container environment, and editor configuration (Zed and VSCode). Creates a polished, efficient development workflow with consistent theming and fast startup times.
**Business Value**: Provides FX with a complete, optimized development environment for Python development, containerized applications, and version control workflows
**User Impact**: Terminal, shell, and editors are fast, beautiful, and productive from day one with zero manual configuration
**Success Metrics**:
- Shell startup time <500ms
- All dev tools (Python, Podman, Git) functional and accessible
- Aliases and shortcuts work in fresh terminal
- Zed and Ghostty themed consistently with Catppuccin
- FZF keybindings operational (Ctrl+R, Ctrl+T, Alt+C)

## Epic Scope
**Total Stories**: 18
**Total Story Points**: 97
**MVP Stories**: 18 (100% of epic)
**Priority Level**: Must Have
**Target Release**: Phase 4-5 (Week 4)

## Features in This Epic

### Feature 04.1: Zsh and Oh My Zsh Configuration
**Feature Description**: Configure Zsh shell with Oh My Zsh framework and essential plugins
**User Value**: Powerful shell with git integration, autosuggestions, and directory jumping
**Story Count**: 3
**Story Points**: 18
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 04.1-001: Zsh Shell Configuration
**User Story**: As FX, I want Zsh configured as my default shell via Home Manager so that I have a modern shell with powerful features

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I open a new terminal
- **Then** Zsh is the default shell
- **And** `echo $SHELL` shows `/bin/zsh` or Nix-managed zsh
- **And** shell history is enabled and working
- **And** completion is enabled for commands
- **And** shell startup time is <500ms

**Additional Requirements**:
- Zsh via macOS built-in or Nix (macOS built-in is fine)
- Managed by Home Manager
- History: Persistent, large history file
- Completion: Command and argument completion
- Fast startup: Lazy-load heavy plugins

**Technical Notes**:
- Add to home-manager/modules/zsh.nix:
  ```nix
  home-manager.users.fx = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      history = {
        size = 50000;
        path = "$HOME/.zsh_history";
        ignoreDups = true;
        share = true;
      };
    };
  };
  ```
- macOS default zsh is recent enough (5.8+)
- Test startup: `time zsh -i -c exit` (should be <500ms)

**Definition of Done**:
- [ ] Zsh configuration in home-manager module
- [ ] Zsh is default shell
- [ ] History works and persists
- [ ] Completion enabled
- [ ] Startup time <500ms
- [ ] Tested in VM
- [ ] Documentation notes shell configuration

**Dependencies**:
- Epic-01, Story 01.5-001 (Home Manager available)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 04.1-002: Oh My Zsh Installation and Plugin Configuration
**User Story**: As FX, I want Oh My Zsh installed with git, fzf, zsh-autosuggestions, and z plugins so that I have enhanced shell features

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I use the shell
- **Then** Oh My Zsh is installed and active
- **And** git plugin provides aliases (gst, gco, gcm, etc.)
- **And** zsh-autosuggestions shows grayed-out command suggestions
- **And** z plugin allows jumping to directories (e.g., `z nix-install`)
- **And** fzf plugin enables fuzzy finding (integrated in next story)
- **And** Oh My Zsh theme is NOT set (Starship handles prompt)
- **And** startup time is still <500ms (lazy loading)

**Additional Requirements**:
- Oh My Zsh via Home Manager (not manual sh install)
- Plugins: git, fzf, zsh-autosuggestions, z
- Theme: Empty or blank (Starship replaces Oh My Zsh themes)
- Fast startup: Lazy-load where possible

**Technical Notes**:
- Add to home-manager/modules/zsh.nix:
  ```nix
  programs.zsh = {
    oh-my-zsh = {
      enable = true;
      theme = "";  # No theme, using Starship
      plugins = [
        "git"
        "fzf"
        "zsh-autosuggestions"
        "z"
      ];
    };
  };
  ```
- zsh-autosuggestions: May need to install separately via Nix if not in Oh My Zsh
- Test: `gst` should run `git status`, typing partial command shows suggestion
- z: Run `z <partial-directory-name>` to jump

**Definition of Done**:
- [ ] Oh My Zsh enabled in Home Manager
- [ ] All plugins active
- [ ] git aliases work (gst, gco, etc.)
- [ ] Autosuggestions appear when typing
- [ ] z plugin jumps to directories
- [ ] No Oh My Zsh theme set
- [ ] Startup time <500ms
- [ ] Tested in VM

**Dependencies**:
- Story 04.1-001 (Zsh configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 04.1-003: Zsh Environment and Options
**User Story**: As FX, I want Zsh configured with useful options and environment variables so that shell behavior is optimal for development

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I use the shell
- **Then** cd auto-pushd is enabled (directory stack)
- **And** extended globbing is enabled (advanced patterns)
- **And** HOMEBREW_NO_AUTO_UPDATE=1 is set (disable Homebrew auto-update)
- **And** EDITOR is set to vim or zed (configurable)
- **And** PATH includes Nix, Homebrew, and local bins
- **And** shell options persist across terminals

**Additional Requirements**:
- Auto-pushd: `cd` adds to directory stack, `popd` to go back
- Extended glob: Powerful file matching patterns
- HOMEBREW_NO_AUTO_UPDATE: Critical for update control
- EDITOR: Default text editor for git, etc.
- PATH: Nix store, /opt/homebrew/bin, ~/.local/bin

**Technical Notes**:
- Add to home-manager/modules/zsh.nix:
  ```nix
  programs.zsh = {
    initExtra = ''
      # Shell options
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt EXTENDED_GLOB
      setopt INTERACTIVE_COMMENTS

      # Environment variables
      export HOMEBREW_NO_AUTO_UPDATE=1
      export EDITOR="zed --wait"  # or vim
      export PATH="$HOME/.local/bin:$PATH"
    '';
    sessionVariables = {
      HOMEBREW_NO_AUTO_UPDATE = "1";
      EDITOR = "zed --wait";
    };
  };
  ```
- PATH: Nix and Homebrew added automatically by nix-darwin
- Test: `echo $HOMEBREW_NO_AUTO_UPDATE` shows 1, `which python` shows Nix path

**Definition of Done**:
- [ ] Shell options configured
- [ ] Environment variables set
- [ ] HOMEBREW_NO_AUTO_UPDATE=1 active
- [ ] EDITOR set
- [ ] PATH includes all necessary paths
- [ ] Options persist across terminals
- [ ] Tested in VM

**Dependencies**:
- Story 04.1-001 (Zsh configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 04.2: Starship Prompt Configuration
**Feature Description**: Install and configure Starship for a beautiful, fast, git-aware prompt
**User Value**: Clean, informative prompt showing directory, git status, and Python version
**Story Count**: 1
**Story Points**: 5
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 04.2-001: Starship Prompt Installation and Configuration
**User Story**: As FX, I want Starship prompt configured with minimal, git-aware design so that I have a beautiful and informative shell prompt

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I open a new terminal
- **Then** Starship prompt is active
- **And** prompt shows current directory (abbreviated for long paths)
- **And** prompt shows git branch and status (if in git repo)
- **And** prompt shows Python version when in virtual environment
- **And** prompt is minimal and fast (no unnecessary info)
- **And** prompt updates immediately on git changes
- **And** startup time is <500ms

**Additional Requirements**:
- Starship via Nix (not manual install)
- Minimal config: Directory, git, Python, optional AWS/Docker
- Git-aware: Branch name, dirty/clean status
- Python version: Show when venv active
- Fast: No slow API calls or network checks

**Technical Notes**:
- Add to home-manager/modules/starship.nix:
  ```nix
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$directory$git_branch$git_status$python$character";
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = {
        format = " [$symbol$branch]($style) ";
      };
      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
      };
      python = {
        format = " [\\($virtualenv\\)]($style) ";
      };
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
  ```
- Integration: `enableZshIntegration` adds init to .zshrc
- Test: Navigate to git repo (shows branch), activate venv (shows Python version)

**Definition of Done**:
- [ ] Starship installed via Nix
- [ ] Configuration in home-manager module
- [ ] Prompt shows directory, git, Python
- [ ] Prompt is minimal and fast
- [ ] Git status updates immediately
- [ ] Startup time <500ms
- [ ] Tested in VM and in git repo

**Dependencies**:
- Story 04.1-001 (Zsh configured)
- Epic-02, Story 02.2-004 (Python installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 04.3: FZF Fuzzy Finder Integration
**Feature Description**: Configure FZF with Zsh keybindings for command history, file finding, and directory navigation
**User Value**: Fast, fuzzy search for commands, files, and directories with keyboard shortcuts
**Story Count**: 1
**Story Points**: 5
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 04.3-001: FZF Installation and Keybindings
**User Story**: As FX, I want FZF integrated with Zsh keybindings so that I can quickly search history, files, and directories

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I press Ctrl+R
- **Then** FZF shows command history search
- **And** I can type to fuzzy-search history
- **When** I press Ctrl+T
- **Then** FZF shows file finder in current directory
- **And** I can select a file to paste into command line
- **When** I press Alt+C (or Option+C)
- **Then** FZF shows directory finder
- **And** I can select a directory to cd into
- **And** all keybindings work consistently

**Additional Requirements**:
- FZF via Nix (not Homebrew or manual)
- Keybindings: Ctrl+R (history), Ctrl+T (files), Alt+C (dirs)
- Zsh integration via Oh My Zsh plugin and Home Manager
- Fast and responsive

**Technical Notes**:
- FZF installed via Nix (already in Oh My Zsh plugins)
- Add to home-manager/modules/fzf.nix:
  ```nix
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";  # Use fd for faster search
    defaultOptions = [
      "--height 40%"
      "--reverse"
      "--border"
    ];
  };
  ```
- May need fd (find alternative) for faster searches: Add to Nix packages
- Test: Ctrl+R shows history, Ctrl+T shows files, Alt+C shows directories

**Definition of Done**:
- [ ] FZF installed via Nix
- [ ] Configuration in home-manager module
- [ ] Ctrl+R (history search) works
- [ ] Ctrl+T (file finder) works
- [ ] Alt+C (directory jump) works
- [ ] fd installed for faster searches
- [ ] Tested in VM

**Dependencies**:
- Story 04.1-002 (Oh My Zsh with fzf plugin)
- Epic-02 (fd tool installed if not already)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 04.4: Ghostty Terminal Configuration
**Feature Description**: Apply existing Ghostty configuration via Home Manager
**User Value**: Beautiful, fast terminal with Catppuccin theme and custom keybindings
**Story Count**: 1
**Story Points**: 5
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 04.4-001: Ghostty Configuration Integration
**User Story**: As FX, I want my existing Ghostty config applied via Home Manager so that terminal is configured automatically

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Ghostty
- **Then** configuration from config/config.ghostty is applied
- **And** Catppuccin theme is active (Latte for light, Mocha for dark)
- **And** JetBrains Mono Nerd Font is used
- **And** 95% opacity with blur effect works
- **And** all keybindings work (new tab, close tab, etc.)
- **And** auto-update is disabled (`auto-update = off` in config)
- **And** theme switches with macOS system appearance

**Additional Requirements**:
- Configuration via Home Manager xdg.configFile
- Existing config: config/config.ghostty (already proven to work)
- Theme: Catppuccin Latte/Mocha (auto-switch)
- Font: JetBrains Mono Nerd Font with ligatures
- Opacity and blur: Visual aesthetics

**Technical Notes**:
- Add to home-manager/modules/ghostty.nix (or in zsh.nix):
  ```nix
  xdg.configFile."ghostty/config".source = ../../config/config.ghostty;
  ```
- Existing config already has Catppuccin theme and auto-update=off
- Symlink: ~/.config/ghostty/config → Nix store copy
- Verify: `ls -la ~/.config/ghostty/config` shows symlink
- Test: Launch Ghostty, check theme and font

**Definition of Done**:
- [ ] Ghostty config symlinked via Home Manager
- [ ] Ghostty launches with correct theme
- [ ] JetBrains Mono font active
- [ ] Opacity and blur working
- [ ] Keybindings functional
- [ ] Auto-update disabled
- [ ] Theme switches with system appearance
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.2-003 (Ghostty installed)
- Epic-05, Story 05.1-001 (Stylix theming for consistency)

**Risk Level**: Low
**Risk Mitigation**: Existing config is proven, direct copy should work

---

### Feature 04.5: Shell Aliases and Functions
**Feature Description**: Configure useful shell aliases for Nix operations and daily tasks
**User Value**: Quick commands for rebuild, update, cleanup, and common operations
**Story Count**: 2
**Story Points**: 10
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 04.5-001: Core Nix Aliases
**User Story**: As FX, I want aliases for rebuild, update, and cleanup commands so that I can manage my system efficiently

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `rebuild`
- **Then** it executes `darwin-rebuild switch --flake ~/Documents/nix-install#$(hostname -s)`
- **And** applies current configuration changes
- **When** I run `update`
- **Then** it updates flake.lock and rebuilds (updates ALL apps and system)
- **When** I run `gc`
- **Then** it runs `nix-collect-garbage -d` (garbage collection)
- **When** I run `cleanup`
- **Then** it runs garbage collection + nix-store optimization
- **And** all aliases work in fresh terminal

**Additional Requirements**:
- rebuild: Apply config changes (uses current flake.lock)
- update: Update flake.lock + rebuild (updates packages)
- gc: Delete old generations
- cleanup: Full cleanup (gc + optimization)
- Aliases persist across terminals

**Technical Notes**:
- Add to home-manager/modules/aliases.nix:
  ```nix
  programs.zsh.shellAliases = {
    rebuild = "darwin-rebuild switch --flake ~/Documents/nix-install";
    update = "cd ~/Documents/nix-install && nix flake update && darwin-rebuild switch --flake .";
    gc = "nix-collect-garbage -d";
    cleanup = "nix-collect-garbage -d && nix-store --optimize";
    health-check = "~/Documents/nix-install/scripts/health-check.sh";  # From Epic-06
  };
  ```
- Note: `rebuild` and `update` are THE ONLY ways to update apps (no auto-updates)
- Test: Run `rebuild` (should apply config), `update` (should update flake.lock)

**Definition of Done**:
- [ ] Aliases configured in home-manager module
- [ ] rebuild command works
- [ ] update command works
- [ ] gc command works
- [ ] cleanup command works
- [ ] Aliases persist across terminals
- [ ] Tested in VM
- [ ] Documentation explains rebuild vs update

**Dependencies**:
- Story 04.1-001 (Zsh configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 04.5-002: General Shell Aliases
**User Story**: As FX, I want common shell aliases like ll, la, and grep colors so that daily terminal use is efficient

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `ll`
- **Then** it shows `ls -lah` (detailed list with hidden files)
- **When** I run `la`
- **Then** it shows `ls -A` (all files except . and ..)
- **When** I run grep
- **Then** matches are highlighted in color
- **And** all aliases work in fresh terminal

**Additional Requirements**:
- ll: Detailed list with human-readable sizes
- la: Show all files including hidden
- grep: Color output for visibility
- Persist across terminals

**Technical Notes**:
- Add to home-manager/modules/aliases.nix:
  ```nix
  programs.zsh.shellAliases = {
    ll = "ls -lah";
    la = "ls -A";
    l = "ls -CF";
    grep = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";
    ".." = "cd ..";
    "..." = "cd ../..";
  };
  ```
- May also use eza (modern ls replacement) if installed:
  ```nix
  ll = "eza -lah --git";  # If eza is in Nix packages
  ```
- Test: `ll` shows detailed list, `grep` shows colored output

**Definition of Done**:
- [ ] General aliases configured
- [ ] ll, la, l commands work
- [ ] grep shows colored output
- [ ] Navigation aliases (.., ...) work
- [ ] Aliases persist across terminals
- [ ] Tested in VM

**Dependencies**:
- Story 04.1-001 (Zsh configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 04.6: Git Configuration
**Feature Description**: Configure Git with user information, LFS, and SSH authentication
**User Value**: Git ready to use for all version control workflows
**Story Count**: 3
**Story Points**: 18
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 04.6-001: Git User Configuration
**User Story**: As FX, I want Git configured with my name and email from user-config.nix so that commits are properly attributed

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `git config user.name`
- **Then** it shows my full name from user-config.nix
- **And** `git config user.email` shows my email
- **And** `git config init.defaultBranch` shows "main"
- **And** configuration is global (applies to all repos)
- **And** I can make commits with proper attribution

**Additional Requirements**:
- User name and email from user-config.nix
- Default branch: main (not master)
- Global config: ~/.gitconfig
- Persist across rebuilds

**Technical Notes**:
- Add to home-manager/modules/git.nix:
  ```nix
  programs.git = {
    enable = true;
    userName = "François Martin";  # From user-config.nix import
    userEmail = "fx@example.com";  # From user-config.nix import
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
  ```
- Import user config values from user-config.nix
- Verify: `git config --list --global` shows name, email, defaultBranch

**Definition of Done**:
- [ ] Git config in home-manager module
- [ ] User name and email set correctly
- [ ] Default branch is main
- [ ] Config is global
- [ ] Can make commits
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.2-003 (user-config.nix available)
- Epic-02, Story 02.4-007 (Git installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 04.6-002: Git LFS Configuration
**User Story**: As FX, I want Git LFS installed and initialized globally so that I can work with repos containing large files

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `git lfs --version`
- **Then** it shows Git LFS version
- **And** Git LFS is initialized globally (`git lfs install`)
- **And** I can clone repos with LFS files
- **And** LFS files are automatically pulled
- **And** `.gitattributes` with LFS patterns works correctly

**Additional Requirements**:
- Git LFS via Nix (already installed in Epic-02)
- Global initialization: `git lfs install`
- Auto-pull LFS files: Default behavior
- Persist across rebuilds

**Technical Notes**:
- Git LFS already installed in Epic-02, Story 02.4-007
- Add to home-manager/modules/git.nix:
  ```nix
  programs.git = {
    lfs.enable = true;  # Home Manager handles init
  };
  ```
- Home Manager's `lfs.enable` runs `git lfs install` automatically
- Verify: `git lfs env` shows LFS config
- Test: Clone repo with LFS files (should auto-pull)

**Definition of Done**:
- [ ] Git LFS enabled in home-manager module
- [ ] `git lfs --version` works
- [ ] LFS initialized globally
- [ ] Can clone repos with LFS files
- [ ] LFS files pulled automatically
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.4-007 (Git LFS installed)
- Story 04.6-001 (Git configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 04.6-003: Git SSH Configuration
**User Story**: As FX, I want Git configured to use SSH for GitHub authentication so that I can push/pull from private repos

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I clone a GitHub repo with SSH URL
- **Then** it uses my SSH key for authentication
- **And** I can push and pull without password prompts
- **And** SSH config includes github.com host
- **And** SSH agent is running and has key added
- **And** `ssh -T git@github.com` succeeds with authentication message

**Additional Requirements**:
- SSH key: Generated in Epic-01 bootstrap
- SSH config: ~/.ssh/config with github.com settings
- SSH agent: Running and key added
- GitHub authentication: Key uploaded in bootstrap

**Technical Notes**:
- SSH key already generated in Epic-01, Story 01.6-001
- Add to home-manager/modules/ssh.nix:
  ```nix
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
        user = "git";
      };
    };
  };
  ```
- SSH agent: macOS Keychain handles ssh-agent by default
- Verify: `ssh -T git@github.com` shows "Hi username! You've successfully authenticated"
- Test: Clone private repo with SSH URL

**Definition of Done**:
- [ ] SSH config in home-manager module
- [ ] github.com host configured
- [ ] SSH key authentication works
- [ ] Can clone/push/pull via SSH
- [ ] `ssh -T git@github.com` succeeds
- [ ] Tested in VM and on GitHub

**Dependencies**:
- Epic-01, Story 01.6-001 (SSH key generated)
- Epic-01, Story 01.6-003 (SSH connection tested)
- Story 04.6-001 (Git configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 04.7: Python Development Environment
**Feature Description**: Configure Python 3.12 with uv and dev tools for project management
**User Value**: Complete Python development environment ready for project work
**Story Count**: 2
**Story Points**: 13
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 04.7-001: Python and uv Configuration
**User Story**: As FX, I want Python 3.12 and uv configured so that I can create and manage Python projects

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `python --version`
- **Then** it shows Python 3.12.x
- **And** `which python` shows Nix store path
- **And** `uv --version` works
- **And** I can create a new project with `uv init test-project`
- **And** I can add dependencies with `uv add requests`
- **And** I can run project with `uv run python main.py`
- **And** Python and uv are in PATH globally

**Additional Requirements**:
- Python 3.12 via Nix (not macOS system Python)
- uv for package management (replaces pip/poetry)
- Global availability: All users, all directories
- Fast uv operations

**Technical Notes**:
- Python and uv already installed in Epic-02, Story 02.2-004
- Verify installation and PATH:
  ```bash
  which python  # Should show /nix/store/.../bin/python
  which uv      # Should show /nix/store/.../bin/uv
  python --version  # 3.12.x
  ```
- Test workflow:
  ```bash
  uv init test-project
  cd test-project
  uv add requests
  uv run python -c "import requests; print(requests.__version__)"
  ```
- No additional config needed if Epic-02 completed correctly

**Definition of Done**:
- [ ] Python 3.12 accessible globally
- [ ] uv accessible globally
- [ ] Can create projects with uv
- [ ] Can add dependencies
- [ ] Can run projects
- [ ] PATH includes Nix Python/uv
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.2-004 (Python and uv installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 04.7-002: Python Dev Tools Configuration
**User Story**: As FX, I want ruff, black, mypy, isort, and pylint available globally so that I can lint and format code in any project

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `ruff --version`
- **Then** it shows ruff version
- **And** `black --version`, `mypy --version`, `isort --version`, `pylint --version` all work
- **And** I can run `ruff check .` in any Python project
- **And** I can run `black .` to format code
- **And** all tools are globally available (not project-specific)

**Additional Requirements**:
- Global dev tools: ruff, black, mypy, isort, pylint
- Installed via Nix (not pip/uv)
- Accessible from any directory
- Fast execution

**Technical Notes**:
- Tools already installed in Epic-02, Story 02.2-004
- Verify installation:
  ```bash
  which ruff   # /nix/store/.../bin/ruff
  which black  # /nix/store/.../bin/black
  # etc.
  ```
- Test: Create Python file with issues, run `ruff check`, should report issues
- Test: Run `black` on file, should format

**Definition of Done**:
- [ ] All dev tools accessible globally
- [ ] ruff, black, mypy, isort, pylint work
- [ ] Can lint and format code
- [ ] Tools are fast and responsive
- [ ] Tested in VM with sample Python code

**Dependencies**:
- Epic-02, Story 02.2-004 (Python dev tools installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 04.8: Container Development Environment
**Feature Description**: Configure Podman for container workflows
**User Value**: Docker alternative ready for running and managing containers
**Story Count**: 2
**Story Points**: 13
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 04.8-001: Podman Machine Initialization
**User Story**: As FX, I want Podman machine initialized automatically so that I can run containers immediately

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `podman --version`
- **Then** it shows Podman version
- **And** Podman machine is initialized
- **And** Podman machine is running
- **And** I can run `podman run hello-world` successfully
- **And** machine initialization is idempotent (doesn't re-init if exists)

**Additional Requirements**:
- Podman installed via Nix (Epic-02)
- Machine init: `podman machine init`
- Machine start: `podman machine start`
- Idempotent: Check if machine exists before init
- Auto-start: Machine starts on boot or on-demand

**Technical Notes**:
- Podman and podman-compose already installed in Epic-02, Story 02.2-005
- Add activation script or launchd service for machine init:
  ```nix
  system.activationScripts.podmanMachine.text = ''
    if ! /nix/store/.../bin/podman machine list | grep -q "podman-machine-default"; then
      echo "Initializing Podman machine..."
      /nix/store/.../bin/podman machine init
      /nix/store/.../bin/podman machine start
    fi
  '';
  ```
- Or document manual init in post-install (simpler)
- Test: `podman run hello-world` should pull and run container

**Definition of Done**:
- [ ] Podman machine initialized (automated or documented)
- [ ] Machine is running
- [ ] Can run containers
- [ ] Initialization is idempotent
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.2-005 (Podman installed)

**Risk Level**: Medium
**Risk Mitigation**: Document manual initialization if automation is complex, provide troubleshooting

---

##### Story 04.8-002: Podman Aliases and Docker Compatibility
**User Story**: As FX, I want `docker` aliased to `podman` so that docker commands work seamlessly

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `docker --version`
- **Then** it shows Podman version (aliased)
- **And** I can run `docker run hello-world` (actually uses podman)
- **And** I can run `docker-compose` (actually uses podman-compose)
- **And** Docker compatibility mode is documented

**Additional Requirements**:
- docker → podman alias
- docker-compose → podman-compose alias
- Compatibility: Most docker commands work
- Document limitations (not 100% compatible)

**Technical Notes**:
- Add to home-manager/modules/aliases.nix:
  ```nix
  programs.zsh.shellAliases = {
    docker = "podman";
    docker-compose = "podman-compose";
  };
  ```
- Test: `docker run hello-world` (should use podman)
- Document: Podman is mostly Docker-compatible but not identical

**Definition of Done**:
- [ ] docker and docker-compose aliases configured
- [ ] docker commands work (via podman)
- [ ] docker-compose commands work
- [ ] Compatibility documented
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.2-005 (Podman and podman-compose installed)
- Story 04.8-001 (Podman machine initialized)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 04.9: Editor Configuration
**Feature Description**: Configure Zed and VSCode with proper theming and settings
**User Value**: Editors match terminal theme and are optimized for development
**Story Count**: 3
**Story Points**: 15
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 04.9-001: Zed Editor Theming via Stylix
**User Story**: As FX, I want Zed themed via Stylix with Catppuccin and JetBrains Mono so that it matches Ghostty terminal

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 6

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Zed
- **Then** it uses Catppuccin theme (Latte for light, Mocha for dark)
- **And** it uses JetBrains Mono Nerd Font with ligatures
- **And** theme switches with macOS system appearance
- **And** font size and editor settings are comfortable
- **And** auto-update is disabled

**Additional Requirements**:
- Theming via Stylix (automatic if Stylix supports Zed)
- Manual config if Stylix doesn't support Zed
- Catppuccin Latte/Mocha variants
- JetBrains Mono with ligatures
- Auto-update disabled

**Technical Notes**:
- Check if Stylix supports Zed natively
- If yes, Stylix auto-applies theme
- If no, add to home-manager/modules/zed.nix:
  ```nix
  programs.zed = {
    enable = true;
    settings = {
      theme = "Catppuccin Mocha";
      buffer_font_family = "JetBrains Mono";
      buffer_font_size = 14;
      auto_update = false;
      # ... other settings
    };
  };
  ```
- Test: Open Zed, check theme matches Ghostty, switch system appearance

**Definition of Done**:
- [ ] Zed themed with Catppuccin
- [ ] JetBrains Mono font active
- [ ] Theme switches with system appearance
- [ ] Auto-update disabled
- [ ] Visual consistency with Ghostty
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.2-001 (Zed installed)
- Epic-05, Story 05.1-001 (Stylix configured)

**Risk Level**: Low
**Risk Mitigation**: Manual config if Stylix doesn't support Zed

---

##### Story 04.9-002: VSCode Configuration
**User Story**: As FX, I want VSCode configured with Catppuccin theme and auto-update disabled so that it's ready for Claude Code extension

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 6

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch VSCode
- **Then** it uses Catppuccin theme (Mocha or Latte)
- **And** auto-update is disabled (`update.mode: none`)
- **And** I can install Claude Code extension manually
- **And** basic settings are configured (font, theme, etc.)

**Additional Requirements**:
- Theme: Catppuccin (via Stylix or manual)
- Auto-update: Disabled
- Claude Code extension: Documented for manual install
- Basic settings: Font, theme, editor preferences

**Technical Notes**:
- Add to home-manager/modules/vscode.nix (or existing config in Epic-02):
  ```nix
  programs.vscode = {
    enable = true;
    userSettings = {
      "update.mode" = "none";
      "workbench.colorTheme" = "Catppuccin Mocha";
      "editor.fontFamily" = "JetBrains Mono";
      "editor.fontSize" = 14;
      "editor.fontLigatures" = true;
    };
  };
  ```
- Catppuccin extension: May need to install manually or via Home Manager extensions
- Document Claude Code extension install: Extensions → Search "Claude Code"

**Definition of Done**:
- [ ] VSCode configured in home-manager module
- [ ] Catppuccin theme applied
- [ ] Auto-update disabled
- [ ] JetBrains Mono font set
- [ ] Claude Code extension install documented
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.2-002 (VSCode installed)
- Epic-05, Story 05.1-001 (Stylix configured, if applicable)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 04.9-003: Editor Extensions Documentation
**User Story**: As FX, I want documentation for recommended editor extensions so that I can enhance Zed and VSCode for my workflows

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 6

**Acceptance Criteria**:
- **Given** documentation is complete
- **When** I read the customization guide
- **Then** it lists recommended Zed extensions
- **And** it lists recommended VSCode extensions (beyond Claude Code)
- **And** it explains how to install extensions in each editor
- **And** it notes which extensions are must-have vs optional

**Additional Requirements**:
- Zed extensions: Language support, linters, etc.
- VSCode extensions: Claude Code (must-have), Python, Docker, etc.
- Installation: Manual steps or Home Manager config
- Categorization: Must-have, recommended, optional

**Technical Notes**:
- Add to docs/customization.md or post-install.md:
  ```markdown
  ## Recommended Editor Extensions

  ### Zed Extensions
  - Python (built-in)
  - Nix language support
  - Git integration (built-in)

  ### VSCode Extensions (Must-Have)
  - Claude Code (manual install required)

  ### VSCode Extensions (Recommended)
  - Python (ms-python.python)
  - Docker (ms-azuretools.vscode-docker)
  - GitLens (eamodio.gitlens)
  - Catppuccin theme (catppuccin.catppuccin-vsc)

  To install: Extensions → Search extension name → Install
  ```

**Definition of Done**:
- [ ] Documentation written
- [ ] Zed extensions listed
- [ ] VSCode extensions listed
- [ ] Installation steps explained
- [ ] Categorized by priority
- [ ] Reviewed for clarity

**Dependencies**:
- Epic-07, Story 07.4-001 (Customization guide)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: All shell/dev environment depends on nix-darwin and Home Manager
- **Epic-02 (Applications)**: Requires Python, Podman, Git, Zed, VSCode, Ghostty installed
- **Epic-05 (Theming)**: Stylix theming for Zed, Ghostty, and visual consistency
- **Epic-06 (Maintenance)**: health-check alias references Epic-06 scripts
- **Epic-07 (Documentation)**: Editor extensions and customization documentation

### Stories This Epic Enables
- Epic-05, Story 05.1-001: Stylix theming applies to shell and editors configured here
- Epic-06, Story 06.4-001: Health check uses aliases defined here
- Epic-07, Story 07.4-001: Customization guide documents shell and editor config

### Stories This Epic Blocks
- None (development environment is foundational but doesn't block other epics)

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 5 | 04.1-001 to 04.8-002 | 82 | Shell, prompt, FZF, aliases, Git, Python, Podman |
| Sprint 6 | 04.9-001 to 04.9-003 | 15 | Editor configuration and documentation |

### Delivery Milestones
- **Milestone 1**: End Sprint 5 - Shell and dev tools fully configured
- **Milestone 2**: End Sprint 6 - Editors themed and documented
- **Epic Complete**: Week 4 - Complete development environment tested in VM and hardware

### Risk Assessment
**Medium Risk Items**:
- Story 04.8-001 (Podman machine init): May require manual initialization, complex to automate
  - Mitigation: Document manual steps, provide troubleshooting, test in VM thoroughly

**Low Risk Items**:
- Most stories use proven Home Manager patterns with low failure risk

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 0 of 18 (0%)
- **Story Points Completed**: 0 of 97 (0%)
- **MVP Stories Completed**: 0 of 18 (0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 5 | 82 | 0 | 0/15 | Not Started |
| Sprint 6 | 15 | 0 | 0/3 | Not Started |

## Epic Acceptance Criteria
- [ ] All MVP stories (18/18) completed and accepted
- [ ] Shell startup time <500ms
- [ ] All dev tools (Python, Podman, Git) functional
- [ ] Aliases work in fresh terminal (rebuild, update, gc, cleanup, ll, etc.)
- [ ] Zed and Ghostty themed consistently with Catppuccin
- [ ] FZF keybindings operational (Ctrl+R, Ctrl+T, Alt+C)
- [ ] Git config includes user info, LFS, SSH
- [ ] Python and uv ready for project work
- [ ] Podman machine initialized and running
- [ ] Editors (Zed, VSCode) configured and themed
- [ ] VM testing successful
- [ ] Physical hardware testing successful

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
