# ABOUTME: Epic-04 Feature 04.2 (Starship Prompt Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 04.2

# Epic-04 Feature 04.2: Starship Prompt Configuration

## Feature Overview

**Feature ID**: Feature 04.2
**Feature Name**: Starship Prompt Configuration
**Epic**: Epic-04
**Status**: 🔄 In Progress

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
- [ ] Starship installed via Nix
- [ ] Configuration in home-manager module
- [ ] Custom config/starship.toml used (adapted from p10k)
- [ ] Prompt shows os_icon, directory, and git status
- [ ] Right prompt shows status, duration, jobs, Python, Node, cloud (aws/gcloud/azure/k8s), nix_shell
- [ ] Icons display correctly (Nerd Font v3)
- [ ] Colors match Catppuccin theme (via Stylix)
- [ ] Transient prompt works (previous prompts collapse)
- [ ] Git status updates immediately
- [ ] Startup time <100ms (Starship is very fast)
- [ ] Tested in VM and in git repo with various contexts

**Dependencies**:
- Story 04.1-001 (Zsh configured)
- Epic-02, Story 02.2-004 (Python installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

