# ABOUTME: Epic-04 Feature 04.2 (Starship Prompt Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 04.2

# Epic-04 Feature 04.2: Starship Prompt Configuration

## Feature Overview

**Feature ID**: Feature 04.2
**Feature Name**: Starship Prompt Configuration
**Epic**: Epic-04
**Status**: ✅ **IMPLEMENTED** - Pending Hardware Testing

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
    # Use custom config adapted from p10k lean style
    configFile = ../config/starship.toml;
  };
  ```
- Custom config at config/starship.toml:
  - Adapted from existing p10k.zsh configuration (config/p10k.zsh)
  - 2-line prompt: os_icon, directory, git | prompt_char
  - Comprehensive right prompt: status, cmd_duration, jobs, language versions, cloud (aws/gcloud/azure/kubernetes), nix_shell, context
  - Nerd Font v3 icons matching p10k style
  - Transient prompt support (collapse previous prompts)
  - Clean, disconnected lean style (no segment separators)
  - Matches p10k LEFT_PROMPT_ELEMENTS and RIGHT_PROMPT_ELEMENTS
- Integration: `enableZshIntegration` adds init to .zshrc
- Test: Navigate to git repo (shows branch), activate venv (shows Python version), check right prompt modules

**Definition of Done**:
- [x] Starship installed via Nix (via Home Manager programs.starship)
- [x] Configuration in home-manager module (shell.nix)
- [x] Custom config adapted from p10k (inline in shell.nix)
- [x] Prompt shows os_icon, directory, and git status
- [x] Right prompt shows status, duration, jobs, Python, Node, cloud (aws/gcloud/azure/k8s), nix_shell
- [x] Icons display correctly (Nerd Font v3)
- [ ] Colors match Catppuccin theme (via Stylix) - Pending Epic-05
- [ ] Transient prompt works (previous prompts collapse) - Requires shell setup
- [ ] Git status updates immediately (FX to test)
- [ ] Startup time <100ms (FX to test)
- [ ] Tested on hardware (FX to test)

**Dependencies**:
- Story 04.1-001 (Zsh configured) ✅ Complete
- Epic-02, Story 02.2-004 (Python installed) ✅ Complete

**Risk Level**: Low
**Risk Mitigation**: N/A

**Implementation Details**:
- **Files Modified**:
  - `home-manager/modules/shell.nix`: Added comprehensive `programs.starship` configuration
- **Implementation Date**: 2025-12-05
- **Branch**: main

**Configuration Applied**:
```nix
programs.starship = {
  enable = true;
  enableZshIntegration = true;
  settings = {
    add_newline = false;
    format = "$os$directory$git_branch$git_status\n$character";
    right_format = "$status$cmd_duration$jobs$python$nodejs$aws$gcloud$azure$kubernetes$nix_shell...";
    # ... comprehensive module configuration
  };
};
```

**Key Features**:
1. **2-line prompt**: OS icon, directory, git branch/status on line 1; prompt character on line 2
2. **Right prompt**: Command status, duration, jobs, language versions (Python, Node, Go, Rust, Ruby), cloud contexts (AWS, GCloud, Azure, K8s), Nix shell indicator
3. **Nerd Font v3 icons**: Consistent iconography matching p10k lean style
4. **Git-aware**: Shows branch name and status (modified, staged, untracked, ahead/behind)
5. **Fast**: Starship is written in Rust, typically <100ms startup

**Note**: Configuration is inline in shell.nix rather than using external config/starship.toml for better Home Manager integration. The external file remains as a reference.

---

## Manual Testing Guide

### Test Commands (FX to run after rebuild)

```bash
# 1. Rebuild to apply Starship configuration
cd ~/Documents/nix-install
git add -A
sudo darwin-rebuild switch --flake .#power

# 2. Start new shell (or source config)
exec zsh

# 3. Verify Starship is active
starship --version
# Expected: starship 1.x.x

# 4. Check prompt shows OS icon and directory
# Expected: macOS icon () followed by current directory

# 5. Navigate to git repo and check git status
cd ~/Documents/nix-install
# Expected: Branch name ( main) and status indicators

# 6. Make a modification and check status update
echo "test" > /tmp/test-file
# Expected: Git status should NOT change (not in git repo)

# 7. Check Python version in Python project
cd /path/to/python/project  # Any directory with pyproject.toml
# Expected: Python version ( 3.12.x) appears in right prompt

# 8. Check startup time
time zsh -i -c exit
# Expected: <500ms total (Starship adds <100ms)

# 9. Run a slow command to check duration
sleep 3
# Expected: "3s" appears in right prompt after command completes

# 10. Check error status
ls /nonexistent-path
# Expected: Red ❯ prompt character and error status in right prompt
```

---

