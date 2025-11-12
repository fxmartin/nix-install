# Epic 05: Theming & Visual Consistency

## Epic Overview
**Epic ID**: Epic-05
**Epic Description**: System-wide theming using Stylix to ensure visual consistency across Ghostty terminal, Zed editor, shell, and other supported applications. Implements Catppuccin color scheme (Latte for light mode, Mocha for dark mode) with automatic switching based on macOS system appearance, JetBrains Mono Nerd Font with ligatures across all tools, and cohesive visual experience when switching between terminal and editor.
**Business Value**: Creates a polished, professional appearance with zero manual theme configuration
**User Impact**: Beautiful, consistent interface across all development tools that adapts to ambient lighting automatically
**Success Metrics**:
- Visual consistency: Same Catppuccin theme across Ghostty and Zed
- Font consistency: JetBrains Mono in terminal and editors
- Auto-switching: Theme changes with macOS system appearance
- Ligature support: Programming ligatures render correctly

## Epic Scope
**Total Stories**: 8
**Total Story Points**: 42
**MVP Stories**: 8 (100% of epic)
**Priority Level**: Must Have
**Target Release**: Phase 6 (Week 5)

## Features in This Epic

### Feature 05.1: Stylix System Configuration
**Feature Description**: Install and configure Stylix for system-wide theming
**User Value**: Single source of truth for colors and fonts across all applications
**Story Count**: 2
**Story Points**: 13
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 05.1-001: Stylix Installation and Base16 Scheme
**User Story**: As FX, I want Stylix configured with Catppuccin Mocha as the base16 scheme so that all applications inherit consistent theming

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 7

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I check Stylix configuration
- **Then** Stylix is enabled in the system
- **And** base16 scheme is set to Catppuccin Mocha
- **And** Stylix applies theming to supported applications
- **And** I can verify theme via Stylix-managed config files
- **And** theme is consistent across all Stylix-supported apps
- **And** custom wallpaper from wallpaper/ directory is set as desktop background
- **And** wallpaper applies to all desktops/spaces

**Additional Requirements**:
- Stylix via nix-darwin flake input
- Base16 scheme: Catppuccin Mocha (dark theme primary)
- Support for Catppuccin Latte (light theme) for auto-switching
- Apply to: Ghostty, Zed (if supported), shell, other apps
- Custom wallpaper: User-provided image from wallpaper/ directory
- Wallpaper via Stylix: Applied via Stylix image setting
- Persist across rebuilds

**Technical Notes**:
- Add Stylix to flake.nix inputs:
  ```nix
  inputs.stylix.url = "github:danth/stylix";
  ```
- Add Stylix to darwin configuration:
  ```nix
  # In flake.nix outputs
  darwinConfigurations.standard = nix-darwin.lib.darwinSystem {
    modules = [
      stylix.darwinModules.stylix
      {
        stylix = {
          enable = true;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
          image = ./wallpaper/Ropey_Photo_by_Bob_Farrell.jpg;  # Custom wallpaper
        };
      }
    ];
  };
  ```
- Wallpaper handling:
  - File: `./wallpaper/Ropey_Photo_by_Bob_Farrell.jpg` (relative to flake.nix)
  - Stylix sets wallpaper via macOS defaults
  - Applies to all desktops/spaces automatically
  - Image copied to Nix store and referenced immutably
- Verify: Check ~/.config for Stylix-generated configs
- Test: Launch apps, verify colors match Catppuccin Mocha
- Test: Check desktop wallpaper is set correctly

**Definition of Done**:
- [ ] Stylix added to flake inputs
- [ ] Stylix enabled in darwin configuration
- [ ] Base16 scheme set to Catppuccin Mocha
- [ ] Wallpaper from wallpaper/ directory configured in Stylix
- [ ] Stylix applies theming to supported apps
- [ ] Theme verified across applications
- [ ] Wallpaper visible on desktop (all spaces)
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Medium
**Risk Mitigation**: Check Stylix documentation for macOS/nix-darwin compatibility, fallback to manual theming if needed

---

##### Story 05.1-002: Auto Light/Dark Mode Switching
**User Story**: As FX, I want Stylix to switch between Catppuccin Latte (light) and Mocha (dark) based on macOS system appearance so that theme adapts to ambient lighting

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 7

**Acceptance Criteria**:
- **Given** Stylix is configured
- **When** macOS system appearance is set to light mode
- **Then** Stylix applies Catppuccin Latte theme
- **And** Ghostty and Zed use light theme
- **When** macOS system appearance is set to dark mode
- **Then** Stylix applies Catppuccin Mocha theme
- **And** Ghostty and Zed use dark theme
- **And** switching happens automatically at sunrise/sunset (or manually)

**Additional Requirements**:
- Auto-detection of macOS appearance
- Catppuccin Latte for light mode
- Catppuccin Mocha for dark mode
- Automatic switching (no manual intervention)
- Persist across reboots

**Technical Notes**:
- Stylix may need configuration for light/dark variants:
  ```nix
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    # Light mode variant (if Stylix supports auto-switching)
    polarity = "auto";  # or specific light/dark scheme per appearance
  };
  ```
- If Stylix doesn't auto-switch, use macOS defaults or manual script
- Alternative: Set both themes and detect system appearance with script
- Verify: Change System Settings → Appearance to Light/Dark, check app themes
- Test: Ghostty and Zed should switch themes automatically

**Definition of Done**:
- [ ] Auto light/dark switching configured
- [ ] Catppuccin Latte applied in light mode
- [ ] Catppuccin Mocha applied in dark mode
- [ ] Switching automatic (follows macOS)
- [ ] Ghostty and Zed switch correctly
- [ ] Tested in VM with appearance changes

**Dependencies**:
- Story 05.1-001 (Stylix configured)
- Epic-03, Story 03.4-001 (Auto appearance setting)

**Risk Level**: Medium
**Risk Mitigation**: Manual theme switching scripts if Stylix doesn't support auto-detection

---

### Feature 05.2: Font Configuration
**Feature Description**: Install and configure JetBrains Mono Nerd Font with ligatures
**User Value**: Professional, readable font with programming ligatures across all tools
**Story Count**: 2
**Story Points**: 10
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 05.2-001: JetBrains Mono Nerd Font Installation
**User Story**: As FX, I want JetBrains Mono Nerd Font installed and configured via Stylix so that all applications use the same font

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 7

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `fc-list | grep JetBrains`
- **Then** it shows JetBrains Mono Nerd Font installed
- **And** Stylix configures JetBrains Mono as the monospace font
- **And** Ghostty uses JetBrains Mono
- **And** Zed uses JetBrains Mono
- **And** terminal and editor fonts match

**Additional Requirements**:
- JetBrains Mono Nerd Font via Nix (not Homebrew)
- Nerd Font variant: Includes icons and symbols
- Stylix manages font configuration
- Apply to all monospace contexts (terminal, editor, code)

**Technical Notes**:
- Add to Stylix configuration:
  ```nix
  stylix = {
    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        name = "JetBrainsMono Nerd Font";
      };
      sizes = {
        terminal = 12;
        desktop = 10;
        applications = 11;
      };
    };
  };
  ```
- Nerdfonts package: Includes JetBrains Mono with Nerd Font patches
- Verify: `fc-list | grep -i jetbrains` shows font
- Test: Open Ghostty and Zed, check font is JetBrains Mono

**Definition of Done**:
- [ ] JetBrains Mono Nerd Font installed via Nix
- [ ] Stylix configured with font
- [ ] Font visible in fc-list
- [ ] Ghostty uses JetBrains Mono
- [ ] Zed uses JetBrains Mono
- [ ] Font sizes configured
- [ ] Tested in VM

**Dependencies**:
- Story 05.1-001 (Stylix configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 05.2-002: Font Ligature Configuration
**User Story**: As FX, I want font ligatures enabled in Ghostty and Zed so that programming symbols like `->`, `>=`, `!=` render as single glyphs

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 7

**Acceptance Criteria**:
- **Given** JetBrains Mono Nerd Font is installed
- **When** I type ligature sequences in Ghostty or Zed
- **Then** they render as single glyphs (e.g., `->` becomes →)
- **And** ligatures work in terminal (Ghostty)
- **And** ligatures work in editor (Zed)
- **And** common programming ligatures render correctly: `->`, `=>`, `>=`, `<=`, `!=`, `===`, `!==`

**Additional Requirements**:
- Ligatures in Ghostty: Enabled in config
- Ligatures in Zed: Enabled in settings
- JetBrains Mono supports ligatures natively
- Verify rendering with test file

**Technical Notes**:
- Ghostty config (config/config.ghostty):
  ```
  font-family = "JetBrainsMono Nerd Font"
  font-feature = "+liga"  # Enable ligatures
  ```
- Zed config (Home Manager or Stylix):
  ```nix
  programs.zed.settings = {
    buffer_font_features = {
      liga = true;
      calt = true;
    };
  };
  ```
- Test: Create file with ligatures:
  ```python
  if x >= 10 and y != 5:
      result -> True
      arrow => value
  ```
- Verify ligatures render as single glyphs

**Definition of Done**:
- [ ] Ligatures enabled in Ghostty config
- [ ] Ligatures enabled in Zed config
- [ ] Common ligatures render correctly
- [ ] Tested with sample code file
- [ ] Tested in VM

**Dependencies**:
- Story 05.2-001 (JetBrains Mono installed)
- Epic-02, Story 02.2-001 (Zed installed)
- Epic-02, Story 02.2-003 (Ghostty installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 05.3: Application-Specific Theming
**Feature Description**: Ensure Ghostty and Zed are properly themed via Stylix
**User Value**: Consistent colors and fonts between terminal and editor
**Story Count**: 2
**Story Points**: 10
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 05.3-001: Ghostty Terminal Theming
**User Story**: As FX, I want Ghostty themed via Stylix so that terminal colors match Catppuccin and auto-switch with system appearance

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 7

**Acceptance Criteria**:
- **Given** Stylix is configured
- **When** I launch Ghostty in dark mode
- **Then** it uses Catppuccin Mocha colors
- **When** I switch to light mode
- **Then** it uses Catppuccin Latte colors
- **And** colors are applied via Stylix (not manual config)
- **And** existing Ghostty config (config/config.ghostty) is preserved for other settings
- **And** theme switching is automatic

**Additional Requirements**:
- Stylix manages Ghostty colors
- Existing config.ghostty preserved for non-theme settings (keybindings, opacity, etc.)
- Catppuccin Latte/Mocha colors
- Auto-switching with macOS appearance

**Technical Notes**:
- Stylix should generate Ghostty theme config
- Existing config.ghostty may need to import Stylix-generated colors:
  ```
  # In config.ghostty
  # Theme colors managed by Stylix
  # Other settings:
  window-opacity = 0.95
  background-blur-radius = 20
  auto-update = off
  # ... keybindings, etc.
  ```
- Stylix may create separate theme file: Check Stylix output
- Verify: Open Ghostty, check colors match Catppuccin
- Test: Switch system appearance, Ghostty colors update

**Definition of Done**:
- [ ] Ghostty themed via Stylix
- [ ] Catppuccin colors applied
- [ ] Existing config.ghostty settings preserved
- [ ] Auto-switching works
- [ ] Tested in VM with appearance changes

**Dependencies**:
- Story 05.1-001 (Stylix configured)
- Story 05.1-002 (Auto light/dark switching)
- Epic-02, Story 02.2-003 (Ghostty installed)
- Epic-04, Story 04.4-001 (Ghostty config applied)

**Risk Level**: Medium
**Risk Mitigation**: Manual Catppuccin config if Stylix doesn't support Ghostty

---

##### Story 05.3-002: Zed Editor Theming
**User Story**: As FX, I want Zed themed via Stylix so that editor colors match Ghostty terminal

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 7

**Acceptance Criteria**:
- **Given** Stylix is configured
- **When** I launch Zed in dark mode
- **Then** it uses Catppuccin Mocha theme
- **When** I switch to light mode
- **Then** it uses Catppuccin Latte theme
- **And** colors match Ghostty terminal
- **And** theme switching is automatic
- **And** JetBrains Mono font is applied

**Additional Requirements**:
- Stylix manages Zed theme (if supported)
- Manual Catppuccin theme if Stylix doesn't support Zed
- Color consistency with Ghostty
- Auto-switching with macOS appearance
- JetBrains Mono font

**Technical Notes**:
- Check if Stylix supports Zed natively
- If yes, Stylix auto-applies theme
- If no, configure manually in Home Manager:
  ```nix
  programs.zed.settings = {
    theme = {
      mode = "system";  # Follow macOS appearance
      light = "Catppuccin Latte";
      dark = "Catppuccin Mocha";
    };
    buffer_font_family = "JetBrainsMono Nerd Font";
  };
  ```
- May need to install Catppuccin extension for Zed
- Verify: Open Zed, check theme matches Ghostty
- Test: Switch system appearance, Zed theme updates

**Definition of Done**:
- [ ] Zed themed with Catppuccin
- [ ] Colors match Ghostty
- [ ] Auto-switching works
- [ ] JetBrains Mono font applied
- [ ] Tested in VM with appearance changes
- [ ] Visual consistency verified

**Dependencies**:
- Story 05.1-001 (Stylix configured)
- Story 05.1-002 (Auto light/dark switching)
- Story 05.2-001 (JetBrains Mono installed)
- Epic-02, Story 02.2-001 (Zed installed)
- Epic-04, Story 04.9-001 (Zed editor configuration)

**Risk Level**: Medium
**Risk Mitigation**: Manual Catppuccin theme config if Stylix doesn't support Zed

---

### Feature 05.4: Theme Verification and Testing
**Feature Description**: Validate theme consistency and appearance switching
**User Value**: Ensures theming works correctly and consistently across all tools
**Story Count**: 2
**Story Points**: 9
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 05.4-001: Visual Consistency Testing
**User Story**: As FX, I want to verify that Ghostty and Zed have matching colors and fonts so that switching between terminal and editor is visually seamless

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 7

**Acceptance Criteria**:
- **Given** Stylix theming is configured
- **When** I compare Ghostty and Zed side-by-side
- **Then** background colors match
- **And** foreground (text) colors match
- **And** accent colors (selections, highlights) are consistent
- **And** both use JetBrains Mono font
- **And** font sizes are comfortable (12pt for terminal, 14pt for editor)
- **And** visual transition between apps feels cohesive

**Additional Requirements**:
- Color matching: Background, foreground, accents, ANSI colors
- Font matching: Same font family, similar sizes
- Professional appearance: Polished, consistent look
- User experience: Switching feels natural

**Technical Notes**:
- Visual comparison: Open Ghostty and Zed side-by-side
- Test code:
  ```python
  # Compare syntax highlighting in Zed vs terminal output
  def hello_world():
      print("Hello, World!")  # Comment
  ```
- Check colors:
  - Background: Same shade
  - Text: Same foreground color
  - Strings: Same green (or pink in Catppuccin)
  - Comments: Same gray
- Document any discrepancies, adjust configs as needed

**Definition of Done**:
- [ ] Ghostty and Zed compared side-by-side
- [ ] Colors match across both apps
- [ ] Font is JetBrains Mono in both
- [ ] Visual consistency verified
- [ ] Any discrepancies documented and fixed
- [ ] Tested in VM

**Dependencies**:
- Story 05.3-001 (Ghostty themed)
- Story 05.3-002 (Zed themed)
- Story 05.2-001 (JetBrains Mono installed)

**Risk Level**: Low
**Risk Mitigation**: Adjust configs manually if automated theming has inconsistencies

---

##### Story 05.4-002: Appearance Switching Testing
**User Story**: As FX, I want to verify that theme switching works correctly when macOS appearance changes so that I can trust automatic light/dark mode

**Priority**: Must Have
**Story Points**: 4
**Sprint**: Sprint 7

**Acceptance Criteria**:
- **Given** system is in dark mode
- **When** I switch to light mode in System Settings
- **Then** Ghostty switches to Catppuccin Latte within seconds
- **And** Zed switches to Catppuccin Latte within seconds
- **And** both apps are readable and visually consistent
- **When** I switch back to dark mode
- **Then** both apps revert to Catppuccin Mocha
- **And** switching happens automatically without restart

**Additional Requirements**:
- Fast switching: <5 seconds for theme change
- No restart required: Apps update live
- Both themes tested: Light and dark
- Readability: Both themes are comfortable to use

**Technical Notes**:
- Test procedure:
  1. System Settings → Appearance → Light
  2. Check Ghostty (should be Catppuccin Latte)
  3. Check Zed (should be Catppuccin Latte)
  4. System Settings → Appearance → Dark
  5. Check Ghostty (should be Catppuccin Mocha)
  6. Check Zed (should be Catppuccin Mocha)
- May require app reload/relaunch: Document if necessary
- Verify both light and dark themes are usable

**Definition of Done**:
- [ ] Light mode tested (Ghostty + Zed)
- [ ] Dark mode tested (Ghostty + Zed)
- [ ] Switching works automatically
- [ ] Both themes are readable
- [ ] Timing acceptable (<5 seconds)
- [ ] Tested in VM
- [ ] Documentation notes switching behavior

**Dependencies**:
- Story 05.1-002 (Auto light/dark switching)
- Story 05.3-001 (Ghostty themed)
- Story 05.3-002 (Zed themed)

**Risk Level**: Low
**Risk Mitigation**: Document manual theme switching if auto-detection doesn't work

---

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: Requires nix-darwin and Home Manager installed
- **Epic-02 (Applications)**: Requires Ghostty, Zed installed
- **Epic-03 (System Config)**: Auto appearance setting in macOS
- **Epic-04 (Dev Environment)**: Ghostty and Zed configs defined

### Stories This Epic Enables
- Epic-04, Story 04.4-001: Ghostty config integrated with theming
- Epic-04, Story 04.9-001: Zed theming via Stylix
- Epic-07 (Documentation): Theme customization documented

### Stories This Epic Blocks
- None (theming is enhancement, not blocker)

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 7 | 05.1-001 to 05.4-002 | 42 | Complete Stylix theming with Catppuccin and JetBrains Mono |

### Delivery Milestones
- **Milestone 1**: End Sprint 7 - Stylix configured, all apps themed
- **Epic Complete**: Week 5 - Visual consistency verified, auto-switching tested

### Risk Assessment
**Medium Risk Items**:
- Story 05.1-001 (Stylix installation): macOS/nix-darwin support may vary
  - Mitigation: Check Stylix docs, fallback to manual theming if needed
- Story 05.1-002 (Auto light/dark): Stylix may not support macOS appearance detection
  - Mitigation: Manual scripts or configs if auto-detection unavailable
- Story 05.3-002 (Zed theming): Stylix may not support Zed natively
  - Mitigation: Manual Catppuccin theme installation in Zed

**Low Risk Items**:
- Font installation and configuration (proven Nix patterns)
- Visual testing (manual verification)

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 0 of 8 (0%)
- **Story Points Completed**: 0 of 42 (0%)
- **MVP Stories Completed**: 0 of 8 (0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 7 | 42 | 0 | 0/8 | Not Started |

## Epic Acceptance Criteria
- [ ] All MVP stories (8/8) completed and accepted
- [ ] Stylix configured with Catppuccin base16 scheme
- [ ] JetBrains Mono Nerd Font installed and applied
- [ ] Ghostty themed with Catppuccin (Latte/Mocha)
- [ ] Zed themed with Catppuccin (Latte/Mocha)
- [ ] Visual consistency verified (colors and fonts match)
- [ ] Auto light/dark mode switching works
- [ ] Ligatures render correctly in terminal and editor
- [ ] Both light and dark themes are readable and professional
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
- **Estimation Confidence**: Medium-high confidence (Stylix macOS support is unknown)
- **Acceptance Criteria Quality**: Clear, testable, and complete criteria for all stories
