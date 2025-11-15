# ABOUTME: Epic-04 Feature 04.1 (Zsh and Oh My Zsh Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 04.1

# Epic-04 Feature 04.1: Zsh and Oh My Zsh Configuration

## Feature Overview

**Feature ID**: Feature 04.1
**Feature Name**: Zsh and Oh My Zsh Configuration
**Epic**: Epic-04
**Status**: 🔄 In Progress

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

