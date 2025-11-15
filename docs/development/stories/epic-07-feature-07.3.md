# ABOUTME: Epic-07 Feature 07.3 (Troubleshooting Guide) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 07.3

# Epic-07 Feature 07.3: Troubleshooting Guide

## Feature Overview

**Feature ID**: Feature 07.3
**Feature Name**: Troubleshooting Guide
**Epic**: Epic-07
**Status**: 🔄 In Progress

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
