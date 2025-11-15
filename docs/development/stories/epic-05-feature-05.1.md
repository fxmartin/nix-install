# ABOUTME: Epic-05 Feature 05.1 (Stylix System Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 05.1

# Epic-05 Feature 05.1: Stylix System Configuration

## Feature Overview

**Feature ID**: Feature 05.1
**Feature Name**: Stylix System Configuration
**Epic**: Epic-05
**Status**: 🔄 In Progress

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

