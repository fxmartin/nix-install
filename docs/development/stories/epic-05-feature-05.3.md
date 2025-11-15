# ABOUTME: Epic-05 Feature 05.3 (Application-Specific Theming) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 05.3

# Epic-05 Feature 05.3: Application-Specific Theming

## Feature Overview

**Feature ID**: Feature 05.3
**Feature Name**: Application-Specific Theming
**Epic**: Epic-05
**Status**: 🔄 In Progress


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
- **Zed configuration handled in Story 02.2-001** (Epic-02 Applications)
- **REQ-NFR-008 Compliance**: Zed uses repository symlink pattern, NOT programs.zed.settings
- Configuration file: config/zed/settings.json (managed via Home Manager activation script)
- Theme settings already configured:
  - Catppuccin Mocha (dark) / Latte (light)
  - System appearance auto-switching
  - JetBrains Mono font
- **Do NOT use programs.zed.settings** - creates read-only /nix/store symlink
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
