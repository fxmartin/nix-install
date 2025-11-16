# ABOUTME: Zed Editor post-installation configuration guide
# ABOUTME: Covers settings, extensions, themes, keyboard shortcuts, and integration with Nix-managed tools

### Zed Editor

**Status**: Installed via Homebrew cask `zed` (Story 02.2-001)

**✅ AUTO-CONFIGURED with BIDIRECTIONAL SYNC**: Settings symlinked to repo (Issue #26 resolution)

**How Bidirectional Sync Works**:
1. Settings file in repo: `config/zed/settings.json` (version controlled)
2. On `darwin-rebuild`, activation script creates: `~/.config/zed/settings.json` → `~/nix-install/config/zed/settings.json`
3. Changes sync both ways:
   - **Zed → Repo**: Modify settings in Zed → Changes instantly appear in repo (git shows them)
   - **Repo → Zed**: Pull updates or edit repo file → Zed sees changes immediately
4. Zed has full write access (symlink points to working directory, not read-only /nix/store)

**First Launch**:
1. Launch Zed from Spotlight, Raycast, or `/Applications/Zed.app`
2. Settings already configured from template
3. No sign-in required (Zed is free and open source)

**Pre-Configured Settings** (from template):

The following settings are automatically configured from `config/zed/settings.json`:

1. **Auto-Update Disabled** (CRITICAL):
   - `"auto_update": false`
   - Updates only via `rebuild` or `update` commands
   - Ensures controlled update philosophy

2. **Catppuccin Theme with System Appearance**:
   - `"theme": { "mode": "system", "light": "Catppuccin Latte", "dark": "Catppuccin Mocha" }`
   - Automatically follows macOS system appearance (light/dark mode)
   - Instant theme switching when macOS appearance changes

3. **JetBrains Mono Font with Ligatures**:
   - `"buffer_font_family": "JetBrains Mono"`
   - `"buffer_font_size": 14`
   - `"buffer_font_features": { "calt": true }` - Enables ligatures (→ ≠ ≥ ≤ etc.)
   - Consistent with terminal (Ghostty) font

4. **Telemetry Disabled**:
   - `"telemetry": { "diagnostics": false, "metrics": false }`
   - Privacy-focused configuration

5. **Git Integration Enabled**:
   - `"git": { "git_gutter": "tracked_files", "inline_blame": { "enabled": true } }`
   - Shows git changes in gutter
   - Displays inline blame information

6. **Additional Settings**:
   - Tab size: 2 spaces
   - Soft wrap at editor width
   - Terminal integration with Zsh
   - Project panel docked left (240px width)
   - Vim mode disabled (set to `true` if preferred)

**Viewing/Modifying Settings**:
- **View current settings**: Press `Cmd+,` or click **Zed → Settings**
- **Settings location**: `~/.config/zed/settings.json` (symlinked to `~/nix-install/config/zed/settings.json`)
- **Modify anytime**: Zed has full write access, changes instantly sync to repo
- **Version controlled**: Settings tracked by git, can commit/revert changes

**Workflow Options**:

1. **Edit in Zed** (most common):
   ```bash
   # 1. Open Zed settings (Cmd+,)
   # 2. Modify settings.json
   # 3. Save (Cmd+S)
   # 4. Check git status to see changes:
   git status
   # Shows: modified: config/zed/settings.json

   # 5. Commit your changes:
   git add config/zed/settings.json
   git commit -m "feat(zed): enable vim mode"
   git push
   ```

2. **Edit in repo** (for bulk changes):
   ```bash
   # 1. Edit directly in repo
   vim ~/nix-install/config/zed/settings.json

   # 2. Zed sees changes immediately (if running)
   # 3. Commit and push
   git add config/zed/settings.json
   git commit -m "feat(zed): update theme preferences"
   git push
   ```

3. **Pull updates** (sync from other machines):
   ```bash
   # Pull changes from repo
   git pull

   # Zed automatically uses updated settings (if running, may need restart)
   ```

**Theme Switching Verification**:
- **Light Mode**: System Settings → Appearance → Light → Zed should use Catppuccin Latte
- **Dark Mode**: System Settings → Appearance → Dark → Zed should use Catppuccin Mocha
- Theme switches automatically when macOS appearance changes

**Testing**:
- [ ] Launch Zed successfully
- [ ] Theme matches macOS system appearance (Catppuccin Latte/Mocha)
- [ ] Font is JetBrains Mono with ligatures working (→ ≠ ≥ ≤ etc.)
- [ ] Auto-update disabled (no update prompts in Zed menu)
- [ ] Theme switches when toggling macOS light/dark mode
- [ ] Settings.json saved successfully at ~/.config/zed/settings.json
- [ ] Zed recognizes common file types (nix, md, py, sh, json)

**Optional Features** (can be enabled later):
- **AI Assistant**: Zed supports AI features via API keys (add `"assistant": { "enabled": true }`)
- **Vim Mode**: Set `"vim_mode": true` in settings.json if desired
- **Language Servers**: Epic-04 will add LSP servers for Python, Nix, Bash, etc.

**Known Issues**:
- **Issue #26**: ✅ **RESOLVED** - Settings symlinked to repo for bidirectional sync
  - Previous issue: Home Manager symlinks to /nix/store were read-only
  - Current solution: Symlink to repo working directory (not /nix/store)
  - Benefits: Bidirectional sync, version control, git tracking
  - Changes in Zed instantly appear in repo, pull updates instantly apply to Zed
- If Catppuccin theme not available:
  - Check **Zed → Extensions** and install "Catppuccin" theme
  - Theme should be built-in as of Zed 0.130+

**Resources**:
- Zed Documentation: https://zed.dev/docs
- Zed Settings Reference: https://zed.dev/docs/configuring-zed
- Catppuccin Theme: https://github.com/catppuccin/zed
- JetBrains Mono Font: https://www.jetbrains.com/lp/mono/

---


---

## Related Documentation

- [Main Apps Index](../README.md)
- [VS Code Configuration](./vscode.md)
- [Ghostty Terminal Configuration](./ghostty-terminal.md)
- [Claude Code CLI](./claude-code-cli.md)
