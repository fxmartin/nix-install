# ABOUTME: Epic-07 Feature 07.2 (Licensed App Activation Guide) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 07.2

# Epic-07 Feature 07.2: Licensed App Activation Guide

## Feature Overview

**Feature ID**: Feature 07.2
**Feature Name**: Licensed App Activation Guide
**Epic**: Epic-07
**Status**: 🔄 In Progress

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

