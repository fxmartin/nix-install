# ABOUTME: Epic-05 Feature 05.1 (Stylix System Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 05.1

# Epic-05 Feature 05.1: Stylix System Configuration

## Feature Overview

**Feature ID**: Feature 05.1
**Feature Name**: Stylix System Configuration
**Epic**: Epic-05
**Status**: 🔄 In Progress (Story 05.1-001 complete, Story 05.1-002 complete)

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
- [x] Stylix added to flake inputs
- [x] Stylix enabled in darwin configuration
- [x] Base16 scheme set to Catppuccin Mocha
- [x] Wallpaper from wallpaper/ directory configured in Stylix
- [x] Stylix applies theming to supported apps
- [ ] Theme verified across applications (pending VM testing by FX)
- [ ] Wallpaper visible on desktop (all spaces) (pending VM testing by FX)
- [ ] Tested in VM (pending FX testing)

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Medium
**Risk Mitigation**: Check Stylix documentation for macOS/nix-darwin compatibility, fallback to manual theming if needed

### Implementation Notes (2025-12-06)

**Files Created/Modified:**
- `darwin/stylix.nix` - New dedicated Stylix configuration module
- `flake.nix` - Added `./darwin/stylix.nix` to commonModules
- `darwin/configuration.nix` - Removed inline Stylix config, added import reference
- `bootstrap.sh` - Added `darwin/stylix.nix` and wallpaper to Phase 4 downloads

**Architecture Decisions:**
1. **Separate module file**: Created `darwin/stylix.nix` for better maintainability vs inline config
2. **Stylix + Native App Theming**: Key insight - Stylix provides base16 scheme for apps without native support, while Ghostty and Zed use their own Catppuccin implementations with auto light/dark switching
3. **nix-darwin limitations**: Stylix's `cursor` and `opacity` options are NixOS-only, not available for nix-darwin
4. **Font configuration**: Comprehensive font setup with JetBrains Mono Nerd Font (monospace), Inter (sans-serif), Source Serif 4 (serif), and Noto Color Emoji
5. **Wallpaper via activation script**: Stylix's `image` setting doesn't set macOS desktop wallpaper directly - added `system.activationScripts.setWallpaper` using osascript to set wallpaper for all desktops

**Configuration Summary:**
```nix
stylix = {
  enable = true;
  enableReleaseChecks = false;
  base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  polarity = "dark";
  image = ../wallpaper/Ropey_Photo_by_Bob_Farrell.jpg;
  fonts = { ... };  # JetBrains Mono, Inter, Source Serif 4, Noto Emoji
};

# Activation script to set macOS wallpaper
system.activationScripts.setWallpaper.text = ''
  # Copies wallpaper to ~/.local/share/wallpaper/current.jpg
  # Uses osascript to set desktop picture for all desktops
'';
```

**Build Verification:**
- `nix flake check` - PASSED
- `nix build .#darwinConfigurations.standard.system --dry-run` - PASSED
- `nix build .#darwinConfigurations.power.system --dry-run` - PASSED

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
- [x] Auto light/dark switching configured
- [x] Catppuccin Latte applied in light mode (via Ghostty/Zed native support)
- [x] Catppuccin Mocha applied in dark mode (via Ghostty/Zed native support)
- [x] Switching automatic (follows macOS)
- [ ] Ghostty and Zed switch correctly (pending VM testing by FX)
- [ ] Tested in VM with appearance changes (pending FX testing)

**Dependencies**:
- Story 05.1-001 (Stylix configured)
- Epic-03, Story 03.4-001 (Auto appearance setting)

**Risk Level**: Medium
**Risk Mitigation**: Manual theme switching scripts if Stylix doesn't support auto-detection

### Implementation Notes (2025-12-06)

**Key Discovery: Stylix does NOT support dynamic polarity switching**

Based on research ([GitHub Issue #447](https://github.com/danth/stylix/issues/447)), Stylix cannot automatically switch between light and dark themes based on macOS system appearance. A rebuild would be required to change the base16 scheme.

**Solution: Native Application Auto-Switching**

Both Ghostty and Zed have excellent built-in support for auto-switching:

1. **Ghostty** (`config/ghostty/config`):
   ```
   theme = "light:Catppuccin Latte,dark:Catppuccin Mocha"
   window-theme = auto
   ```

2. **Zed** (`config/zed/settings.json`):
   ```json
   "theme": {
     "mode": "system",
     "light": "Catppuccin Latte",
     "dark": "Catppuccin Mocha"
   }
   ```

**Architecture Decision:**
- Stylix provides base16 Catppuccin Mocha for apps that don't have native theme support
- Ghostty and Zed use their own native auto-switching (configured in Epic-02/04)
- This approach gives the best user experience without requiring system rebuilds

**Acceptance Criteria Met:**
- Auto-switching IS configured - via native app support
- Apps DO follow macOS appearance automatically
- No rebuild required to switch between light/dark

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
- [x] JetBrains Mono Nerd Font installed via Nix
- [x] Stylix configured with font
- [ ] Font visible in fc-list (pending VM testing by FX)
- [ ] Ghostty uses JetBrains Mono (pending VM testing by FX)
- [ ] Zed uses JetBrains Mono (pending VM testing by FX)
- [x] Font sizes configured
- [ ] Tested in VM (pending FX testing)

**Dependencies**:
- Story 05.1-001 (Stylix configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

### Implementation Notes (2025-12-06)

**Font Configuration in `darwin/stylix.nix`:**

```nix
fonts = {
  monospace = {
    package = pkgs.nerd-fonts.jetbrains-mono;
    name = "JetBrainsMono Nerd Font";
  };
  sansSerif = {
    package = pkgs.inter;
    name = "Inter";
  };
  serif = {
    package = pkgs.source-serif;
    name = "Source Serif 4";
  };
  emoji = {
    package = pkgs.noto-fonts-color-emoji;
    name = "Noto Color Emoji";
  };
  sizes = {
    terminal = 12;
    desktop = 10;
    applications = 11;
    popups = 10;
  };
};
```

**Font Package Note:**
- Using `pkgs.nerd-fonts.jetbrains-mono` (current nixpkgs-unstable syntax)
- Previous syntax `pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }` is deprecated

**Ghostty Font Configuration** (in `config/ghostty/config`):
```
font-family = JetBrainsMono Nerd Font
font-size = 12
font-feature = +liga
font-feature = +calt
font-feature = +dlig
```

**Zed Font Configuration** (in `config/zed/settings.json`):
```json
"buffer_font_family": "JetBrains Mono",
"buffer_font_size": 14,
"buffer_font_features": {"calt": true},
"ui_font_family": "JetBrains Mono",
"ui_font_size": 14
```

---

##### Story 05.2-002: Font Ligature Configuration
**User Story**: As FX, I want font ligatures enabled in Ghostty and Zed so that programming symbols like `->`, `>=`, `!=` render as single glyphs

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 7

**Acceptance Criteria**:
- **Given** JetBrains Mono Nerd Font is installed
- **When** I type ligature sequences like `->`, `=>`, `!=`, `<=`, `>=`
- **Then** they render as connected ligature glyphs
- **And** Ghostty shows ligatures
- **And** Zed shows ligatures
- **And** ligatures don't break code navigation/selection

**Additional Requirements**:
- Enable common programming ligatures
- Support: `->`, `=>`, `!=`, `<=`, `>=`, `::`, `++`, `--`
- Don't enable ligatures that might confuse (e.g., `===` vs `==`)

**Technical Notes**:
- Ghostty: `font-feature = +liga`, `+calt`, `+dlig`
- Zed: `buffer_font_features.calt = true`
- JetBrains Mono includes programming ligatures by default

**Definition of Done**:
- [x] Ghostty ligatures enabled via font-feature settings
- [x] Zed ligatures enabled via buffer_font_features
- [ ] Ligatures render correctly (pending VM testing by FX)
- [ ] Code navigation/selection works with ligatures (pending VM testing by FX)
- [ ] Tested in VM (pending FX testing)

**Dependencies**:
- Story 05.2-001 (JetBrains Mono installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

### Implementation Notes (2025-12-06)

**Ligatures Already Configured in Epic-04:**

Font ligatures were already configured during Epic-04 Development Environment setup:

1. **Ghostty** (`config/ghostty/config`):
   ```
   font-feature = +liga   # Standard ligatures
   font-feature = +calt   # Contextual alternates
   font-feature = +dlig   # Discretionary ligatures
   ```

2. **Zed** (`config/zed/settings.json`):
   ```json
   "buffer_font_features": {"calt": true}
   ```

**Status**: Configuration complete, awaiting VM testing by FX.

---

## Feature Progress Summary

| Story | Status | Points | Completion |
|-------|--------|--------|------------|
| 05.1-001 Stylix + Base16 | ✅ Implemented | 8 | Config complete, pending VM test |
| 05.1-002 Auto Light/Dark | ✅ Implemented | 5 | Via native app support |
| 05.2-001 Font Installation | ✅ Implemented | 5 | Config complete, pending VM test |
| 05.2-002 Font Ligatures | ✅ Implemented | 5 | Config complete, pending VM test |

**Total Feature Points**: 23 (implemented) / 23 (planned) = 100% code complete
**VM Testing Status**: Pending FX manual testing
