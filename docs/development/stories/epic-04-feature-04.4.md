# ABOUTME: Epic-04 Feature 04.4 (Ghostty Terminal Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 04.4

# Epic-04 Feature 04.4: Ghostty Terminal Configuration

## Feature Overview

**Feature ID**: Feature 04.4
**Feature Name**: Ghostty Terminal Configuration
**Epic**: Epic-04
**Status**: 🔄 In Progress

### Feature 04.4: Ghostty Terminal Configuration
**Feature Description**: Apply existing Ghostty configuration via Home Manager
**User Value**: Beautiful, fast terminal with Catppuccin theme and custom keybindings
**Story Count**: 1
**Story Points**: 5
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 04.4-001: Ghostty Configuration Integration
**User Story**: As FX, I want my existing Ghostty config applied via Home Manager so that terminal is configured automatically

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Ghostty
- **Then** configuration from config/config.ghostty is applied
- **And** Catppuccin theme is active (Latte for light, Mocha for dark)
- **And** JetBrains Mono Nerd Font is used
- **And** 95% opacity with blur effect works
- **And** all keybindings work (new tab, close tab, etc.)
- **And** auto-update is disabled (`auto-update = off` in config)
- **And** theme switches with macOS system appearance

**Additional Requirements**:
- Configuration via Home Manager activation script (NOT xdg.configFile)
- Existing config: config/config.ghostty (already proven to work)
- Theme: Catppuccin Latte/Mocha (auto-switch)
- Font: JetBrains Mono Nerd Font with ligatures
- Opacity and blur: Visual aesthetics
- **REQ-NFR-008**: Config file MUST use repository symlink pattern (not /nix/store)

**Technical Notes**:
- **REQ-NFR-008 Implementation**:
  - ❌ **ANTI-PATTERN**: Do NOT use `xdg.configFile."ghostty/config".source = ...`
  - ❌ **Reason**: Creates read-only symlink to /nix/store, prevents Ghostty config changes
  - ✅ **CORRECT**: Use `home.activation` script to create repository symlink:
    ```nix
    home.activation.ghosttyConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Dynamically find repo location (same pattern as Zed)
      REPO_ROOT=""
      for candidate in "$HOME/nix-install" "$HOME/.config/nix-install" "$HOME/Documents/nix-install"; do
        if [ -f "$candidate/flake.nix" ] && [ -f "$candidate/config/config.ghostty" ]; then
          REPO_ROOT="$candidate"
          break
        fi
      done
      [ -z "$REPO_ROOT" ] && REPO_ROOT="$HOME/nix-install"

      mkdir -p "$HOME/.config/ghostty"
      ln -sf "$REPO_ROOT/config/config.ghostty" "$HOME/.config/ghostty/config"
    '';
    ```
  - Pattern: `~/.config/ghostty/config` → `$REPO/config/config.ghostty`
  - Enables bidirectional sync: changes in Ghostty appear in repo, git pull updates Ghostty
  - Reference: `home-manager/modules/zed.nix` for complete implementation pattern
- Existing config already has Catppuccin theme and auto-update=off
- Verify: `ls -la ~/.config/ghostty/config` shows symlink to repository (not /nix/store)
- Test: Launch Ghostty, check theme and font, modify config and verify changes appear in repo

**Definition of Done**:
- [ ] Ghostty config symlinked to repository (REQ-NFR-008 compliant, NOT /nix/store)
- [ ] Ghostty launches with correct theme
- [ ] JetBrains Mono font active
- [ ] Opacity and blur working
- [ ] Keybindings functional
- [ ] Auto-update disabled
- [ ] Theme switches with system appearance
- [ ] Bidirectional sync verified (changes in Ghostty appear in repo)
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.2-003 (Ghostty installed)
- Epic-05, Story 05.1-001 (Stylix theming for consistency)

**Risk Level**: Low
**Risk Mitigation**: Existing config is proven, direct copy should work

---

