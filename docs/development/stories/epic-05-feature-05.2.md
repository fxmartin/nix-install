# ABOUTME: Epic-05 Feature 05.2 (Font Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 05.2

# Epic-05 Feature 05.2: Font Configuration

## Feature Overview

**Feature ID**: Feature 05.2
**Feature Name**: Font Configuration
**Epic**: Epic-05
**Status**: 🔄 In Progress

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
- Zed config: See Story 02.2-001 for REQ-NFR-008 compliant implementation
  - Settings managed via repository symlink (config/zed/settings.json)
  - Ligatures enabled via "buffer_font_features": {"liga": true, "calt": true}
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
