# ABOUTME: Epic-04 Feature 04.9 (Editor Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 04.9

# Epic-04 Feature 04.9: Editor Configuration

## Feature Overview

**Feature ID**: Feature 04.9
**Feature Name**: Editor Configuration
**Epic**: Epic-04
**Status**: 🔄 In Progress

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

