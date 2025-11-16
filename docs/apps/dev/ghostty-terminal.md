# ABOUTME: Ghostty Terminal post-installation configuration guide
# ABOUTME: Covers terminal settings, themes, font configuration, and integration with shell environment

### Ghostty Terminal

**Status**: Installed via Homebrew cask `ghostty` (Story 02.2-003)

**✅ AUTO-CONFIGURED with BIDIRECTIONAL SYNC**: Config symlinked to repo (REQ-NFR-008 compliant)

**How Bidirectional Sync Works**:
1. Config file in repo: `config/ghostty/config` (version controlled)
2. On `darwin-rebuild`, activation script creates: `~/.config/ghostty/config` → `~/nix-install/config/ghostty/config`
3. Changes sync both ways:
   - **Repo → Ghostty**: Pull updates or edit repo file → Ghostty sees changes on reload (Cmd+Shift+,)
   - **Manual edits**: Any direct edits to config file appear in repo
4. Ghostty can read config from working directory (not read-only /nix/store)

**First Launch**:
1. Launch Ghostty from Spotlight, Raycast, or `/Applications/Ghostty.app`
2. Config already loaded from `~/.config/ghostty/config`
3. No sign-in required, ready to use immediately

**Pre-Configured Settings** (from template):

The following settings are automatically configured from `config/ghostty/config`:

1. **Catppuccin Theme with Auto-Switching**:
   - `theme = "light:Catppuccin Latte,dark:Catppuccin Mocha"`
   - Automatically switches based on macOS system appearance
   - Light Mode → Catppuccin Latte (light theme)
   - Dark Mode → Catppuccin Mocha (dark theme)
   - Matches Zed and VSCode theme switching behavior

2. **JetBrains Mono Font with Ligatures**:
   - `font-family = JetBrains Mono`
   - `font-size = 12`
   - `font-feature = +liga` (ligatures enabled)
   - `font-feature = +calt` (contextual alternates)
   - `font-feature = +dlig` (discretionary ligatures)
   - Consistent with Zed and VSCode font configuration

3. **Modern Appearance**:
   - `background-opacity = 0.95` (95% opacity)
   - `background-blur = 10` (blur effect)
   - `window-padding-x = 16` (16px horizontal padding)
   - `window-padding-y = 16` (16px vertical padding)
   - `window-theme = auto` (follows system light/dark mode)
   - `macos-titlebar-style = transparent` (native macOS appearance)

4. **Auto-Update Disabled** (CRITICAL):
   - `auto-update = off`
   - Updates only via `rebuild` or `update` commands
   - Ensures controlled update philosophy

5. **Shell Integration**:
   - `shell-integration = detect` (auto-detect shell)
   - `shell-integration-features = cursor,sudo,title`
   - Cursor shape changes, sudo detection, dynamic title

6. **Productivity Keybindings**:
   - **Tabs**: Ctrl+Shift+T (new tab), Ctrl+Tab (next tab)
   - **Splits**: Ctrl+Shift+Enter (right split), Ctrl+Shift+D (down split)
   - **Navigation**: Ctrl+Shift+H/J/L (navigate splits)
   - **Font Size**: Ctrl+Plus/Minus (adjust), Ctrl+0 (reset)
   - **Copy/Paste**: Ctrl+Shift+C/V (clipboard)
   - **Config Reload**: Ctrl+Shift+, (reload config)
   - **Jump to Prompts**: Ctrl+Shift+Up/Down (requires shell integration)

7. **Clipboard & Security**:
   - `clipboard-read = ask` (prompt before reading)
   - `clipboard-write = allow` (allow writing)
   - `clipboard-paste-protection = true` (prevent paste jacking)
   - `copy-on-select = true` (auto-copy on selection)

8. **Performance**:
   - `scrollback-limit = 100000000` (~100MB scrollback)
   - `gtk-single-instance = desktop` (faster subsequent launches)
   - `linux-cgroup = single-instance` (cgroup isolation)

**Configuration Management**:

Ghostty's configuration is managed through the symlinked file:

```bash
# View config location
ls -la ~/.config/ghostty/config
# Should show: ~/.config/ghostty/config -> ~/nix-install/config/ghostty/config

# Edit config in repo
vim ~/nix-install/config/ghostty/config

# Or edit directly (same file due to symlink)
vim ~/.config/ghostty/config

# Reload config in Ghostty
# Press: Ctrl+Shift+, (comma)
# Or restart Ghostty
```

**Viewing/Modifying Settings**:
- **Config location**: `~/.config/ghostty/config` (symlinked to `~/nix-install/config/ghostty/config`)
- **Modify anytime**: Edit the config file (in repo or via symlink)
- **Reload config**: Press `Ctrl+Shift+,` in Ghostty (no restart needed)
- **Version controlled**: Settings tracked by git, can commit/revert changes

**Workflow Options**:

1. **Edit in repo** (recommended):
   ```bash
   # 1. Edit directly in repo
   vim ~/nix-install/config/ghostty/config

   # 2. Reload in Ghostty (Ctrl+Shift+,)
   # 3. Commit your changes:
   git add config/ghostty/config
   git commit -m "feat(ghostty): update keybindings"
   git push
   ```

2. **Edit via symlink** (alternative):
   ```bash
   # 1. Edit directly via symlink
   vim ~/.config/ghostty/config

   # 2. Reload in Ghostty (Ctrl+Shift+,)
   # 3. Changes appear in repo automatically
   git status
   # Shows: modified: config/ghostty/config
   ```

3. **Pull updates** (sync from other machines):
   ```bash
   # Pull changes from repo
   git pull

   # Reload Ghostty config (Ctrl+Shift+,)
   ```

**Available Themes**:

To see all available themes:
```bash
ghostty +list-themes
```

To change theme, edit `config/ghostty/config`:
```bash
# Current (auto-switching)
theme = "light:Catppuccin Latte,dark:Catppuccin Mocha"

# Or use a single theme (examples):
# theme = "TokyoNight"
# theme = "Nord"
# theme = "Dracula"
```

**Testing**:
- [ ] Launch Ghostty successfully
- [ ] Config symlink created at ~/.config/ghostty/config
- [ ] Theme is Catppuccin (Mocha for dark mode, Latte for light mode)
- [ ] Font is JetBrains Mono with ligatures working (→ ≠ ≥ ≤ etc.)
- [ ] Background opacity and blur effect working
- [ ] Window padding visible (16px on all sides)
- [ ] Auto-update disabled (no update prompts)
- [ ] Keybindings work (test splits, tabs, font size, copy/paste)
- [ ] Config reload works (Ctrl+Shift+,)
- [ ] Shell integration working (prompt detection, cursor shape changes)
- [ ] Theme auto-switches when toggling macOS appearance
- [ ] Bidirectional sync: Edit config, verify git shows changes

**Known Issues**:
- **Theme not applied**: Verify theme name is correct (use `ghostty +list-themes`)
- **Config not loading**: Verify symlink exists at ~/.config/ghostty/config
- If symlink broken: Re-run `darwin-rebuild switch` to recreate

**Resources**:
- Ghostty Documentation: https://ghostty.org/docs
- Ghostty Configuration Reference: https://ghostty.org/docs/config
- Catppuccin Theme: https://github.com/catppuccin/ghostty
- JetBrains Mono Font: https://www.jetbrains.com/lp/mono/

---


---

## Related Documentation

- [Main Apps Index](../README.md)
- [Zed Editor Configuration](./zed-editor.md)
- [VS Code Configuration](./vscode.md)
- [Python Tools Configuration](./python-tools.md)
