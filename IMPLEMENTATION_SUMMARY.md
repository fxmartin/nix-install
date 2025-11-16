# Story 02.2-002: VSCode Installation - Implementation Summary

## Overview
Successfully implemented VSCode installation and configuration for the nix-darwin MacBook automation system following the REQ-NFR-008 compliant pattern from Story 02.2-001 (Zed Editor).

## Implementation Date
2025-11-12

## Story Details
- **Story ID**: 02.2-002
- **Priority**: Must Have
- **Story Points**: 3
- **Sprint**: Sprint 3
- **Status**: ✅ Code Complete (awaiting VM testing by FX)

## Files Created/Modified

### Created Files:
1. **config/vscode/settings.json** (3,591 bytes)
   - VSCode settings template with Catppuccin theme
   - Auto-update disabled (update.mode: none)
   - JetBrains Mono font with ligatures
   - Language-specific settings for Nix, Python, Markdown, JSON
   - Privacy-focused (telemetry disabled)
   - Git and terminal integration configured

2. **home-manager/modules/vscode.nix** (4,883 bytes)
   - REQ-NFR-008 compliant activation script
   - Bidirectional sync via symlink to repo
   - Dynamic repo location detection (~/nix-install, ~/.config/nix-install, ~/Documents/nix-install)
   - Automatic backup of existing settings.json
   - Symlink verification and update logic

### Modified Files:
1. **darwin/homebrew.nix**
   - Added `"visual-studio-code"` to casks array
   - Added inline comment documenting Story 02.2-002

2. **home-manager/home.nix**
   - Added `./modules/vscode.nix` to imports list

3. **docs/apps/dev/vscode.md** (originally in docs/app-post-install-configuration.md)
   - Added VSCode section to Application Configuration Index
   - Added comprehensive VSCode configuration documentation (180+ lines)
   - Documented bidirectional sync workflow
   - Documented required extensions (Catppuccin, Claude Code)
   - Documented optional extensions (Nix IDE, Ruff, markdownlint, etc.)
   - Added testing checklist
   - Updated Story Tracking section

## Architecture Pattern: REQ-NFR-008 Compliance

### Why This Pattern?
VSCode requires write access to its settings.json file. Home Manager's `programs.vscode.userSettings` creates read-only symlinks to /nix/store, which breaks VSCode's ability to save settings.

### Solution: Bidirectional Sync
1. Settings template stored in repo: `config/vscode/settings.json`
2. Home Manager activation script creates symlink:
   - Source: `~/nix-install/config/vscode/settings.json` (repo working directory)
   - Target: `~/Library/Application Support/Code/User/settings.json` (VSCode config)
3. Bidirectional sync enabled:
   - Changes in VSCode → Instantly visible in repo (git tracks changes)
   - Changes in repo → Instantly apply to VSCode
4. Version control benefits: Can commit, revert, and sync settings across machines

### Activation Script Features:
- Dynamic repo location detection (works with any NIX_INSTALL_DIR)
- Automatic config directory creation
- Automatic backup of existing settings.json
- Symlink verification and update on rebuild
- Informative output messages for debugging

## Key Configuration Features

### Auto-Update Disabled (CRITICAL):
```json
"update.mode": "none"
"extensions.autoUpdate": false
"extensions.autoCheckUpdates": false
```

### Catppuccin Theme:
```json
"workbench.colorTheme": "Catppuccin Mocha"
"workbench.iconTheme": "catppuccin-mocha"
```
**Note**: Requires manual installation of Catppuccin extension (documented in post-install guide)

### JetBrains Mono Font:
```json
"editor.fontFamily": "JetBrains Mono, Menlo, Monaco, 'Courier New', monospace"
"editor.fontSize": 14
"editor.fontLigatures": true
```

### Language-Specific Settings:
- **Nix**: 2-space indentation, format on save
- **Python**: 4-space indentation, Ruff formatter (charliermarsh.ruff)
- **Markdown**: Word wrap, suggestions disabled
- **JSON/JSONC**: VSCode formatter

### Privacy Settings:
```json
"telemetry.telemetryLevel": "off"
"redhat.telemetry.enabled": false
```

## Testing Requirements (FOR FX ONLY)

### VM Testing Checklist:
- [ ] VSCode installed successfully via Homebrew
- [ ] Settings symlink created at ~/Library/Application Support/Code/User/settings.json
- [ ] Symlink points to repo: ~/nix-install/config/vscode/settings.json
- [ ] Install Catppuccin theme extension (Cmd+Shift+X → "Catppuccin")
- [ ] Theme applies correctly (Catppuccin Mocha)
- [ ] Font is JetBrains Mono with ligatures (→ ≠ ≥ ≤ etc.)
- [ ] Auto-update disabled (no update prompts)
- [ ] Install Claude Code extension (Cmd+Shift+X → "Claude Code")
- [ ] Terminal integration works (Zsh opens in integrated terminal)
- [ ] Git integration works (decorations, inline changes)
- [ ] Language-specific settings apply (test .nix, .py, .md files)
- [ ] Bidirectional sync: Edit in VSCode (Cmd+,), verify git shows changes
- [ ] Bidirectional sync: Edit repo file, verify VSCode sees changes (may need restart)
- [ ] Format on save works
- [ ] Ruler guides appear at 80/120 characters
- [ ] Bracket colorization works

## Required Manual Steps (Post-Install)

### 1. Install Catppuccin Theme Extension:
```
1. Open VSCode
2. Press Cmd+Shift+X (Extensions panel)
3. Search: "Catppuccin"
4. Install: "Catppuccin for VSCode" by Catppuccin
5. Theme will activate automatically (already configured in settings.json)
```

### 2. Install Claude Code Extension:
```
1. Open Extensions panel (Cmd+Shift+X)
2. Search: "Claude Code"
3. Install: "Claude Code" by Anthropic
4. Sign in with Anthropic account when prompted
```

### 3. Optional Extensions:
- Nix IDE (syntax highlighting, LSP)
- Ruff (Python linting/formatting)
- markdownlint (Markdown linting)
- shellcheck (Shell script linting)
- GitLens (Enhanced Git integration)

## Integration with Existing System

### Consistency with Other Tools:
- **Font**: JetBrains Mono (matches Ghostty terminal and Zed editor)
- **Theme**: Catppuccin Mocha (matches Ghostty and Zed)
- **Philosophy**: Auto-update disabled (matches system-wide update control)
- **Pattern**: Bidirectional sync (matches Zed implementation from Story 02.2-001)

### Nix-Darwin Integration:
- Installed via Homebrew (declared in darwin/homebrew.nix)
- Configured via Home Manager (home-manager/modules/vscode.nix)
- Settings version controlled (config/vscode/settings.json)

## Acceptance Criteria Status

✅ **All acceptance criteria met**:
- [x] VSCode installed via Homebrew cask (`visual-studio-code`)
- [x] Settings symlinked to repository using REQ-NFR-008 compliant pattern
- [x] Auto-update disabled: `"update.mode": "none"`
- [x] Catppuccin theme configured: `"workbench.colorTheme": "Catppuccin Mocha"`
- [x] Claude Code extension installation documented
- [x] Bidirectional sync verified (implementation complete, VM testing pending)

## Next Steps

### For FX (Testing):
1. Checkout feature branch: `git checkout feature/02.2-002-vscode`
2. Review implementation in VM environment
3. Run `darwin-rebuild switch` to apply changes
4. Follow VM Testing Checklist (see above)
5. Verify bidirectional sync works correctly
6. Test Claude Code extension installation
7. Document any issues or improvements needed

### For Development (If VM Testing Passes):
1. Merge to main branch
2. Update progress tracking:
   - Mark Story 02.2-002 as completed in stories/epic-02-application-installation.md
   - Update docs/development/progress.md with completion status
   - Update STORIES.md overview
3. Consider similar implementation for Cursor editor (Story 02.2-003)

## Lessons Learned

### What Worked Well:
- Reusing REQ-NFR-008 pattern from Story 02.2-001 (Zed) was efficient
- Dynamic repo location detection makes bootstrap flexible
- Bidirectional sync provides best user experience
- Comprehensive documentation reduces confusion about manual steps

### Considerations:
- Catppuccin theme requires manual extension install (cannot be automated)
- Claude Code extension requires manual install (no declarative VSCode extension management)
- Settings.json changes in VSCode will show up as git modifications (this is intentional)
- Future: Consider adding keybindings.json if needed (same pattern)

## References

### Documentation:
- docs/REQUIREMENTS.md (REQ-NFR-008: Configuration File Symlink Management)
- docs/apps/dev/vscode.md (VSCode configuration guide)
- docs/apps/README.md (Application Configuration Index)
- STORIES.md (Story 02.2-002 details)

### Code:
- darwin/homebrew.nix (Homebrew cask installation)
- home-manager/modules/vscode.nix (Home Manager activation script)
- config/vscode/settings.json (Settings template)

### Previous Implementation:
- Story 02.2-001: Zed Editor (reference pattern)
- Issue #26: Zed settings symlink resolution (problem context)

## Git Commit Message (Suggested)

```
feat(vscode): implement VSCode installation with REQ-NFR-008 compliant config

Implements Story 02.2-002: VSCode Installation and Configuration

Installation:
- Add visual-studio-code Homebrew cask to darwin/homebrew.nix
- Install alongside Zed as second code editor option

Configuration (REQ-NFR-008 Compliant):
- Create config/vscode/settings.json template with:
  - Auto-update disabled (update.mode: none)
  - Catppuccin Mocha theme (requires manual extension install)
  - JetBrains Mono font with ligatures
  - Privacy-focused (telemetry disabled)
  - Language-specific settings (Nix, Python, Markdown, JSON)
  - Git and terminal integration

Home Manager Integration:
- Create home-manager/modules/vscode.nix with activation script
- Bidirectional sync via symlink to repo (not /nix/store)
- Dynamic repo location detection (~/nix-install, ~/.config/nix-install, ~/Documents/nix-install)
- Symlink: ~/Library/Application Support/Code/User/settings.json -> ~/nix-install/config/vscode/settings.json
- Changes in VSCode appear in repo, changes in repo apply to VSCode

Documentation:
- Add VSCode section to docs/apps/dev/vscode.md (Application Configuration Index)
- Document Catppuccin and Claude Code extension installation
- Document bidirectional sync workflow
- Add comprehensive testing checklist

Acceptance Criteria:
✅ VSCode installed via Homebrew cask
✅ Settings symlinked to repo (REQ-NFR-008 pattern)
✅ Auto-update disabled
✅ Catppuccin theme configured
✅ Claude Code extension installation documented
✅ Bidirectional sync enabled

Testing: VM testing pending (FX to validate)

Story Points: 3
Sprint: Sprint 3

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

**Implementation Status**: ✅ Code Complete
**Next Phase**: VM Testing by FX
**Estimated Testing Time**: 15-20 minutes
