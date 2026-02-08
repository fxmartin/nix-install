# ABOUTME: Epic-04 Feature 04.6 (Git Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 04.6

# Epic-04 Feature 04.6: Git Configuration

## Feature Overview

**Feature ID**: Feature 04.6
**Feature Name**: Git Configuration
**Epic**: Epic-04
**Status**: 🔄 In Progress

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

