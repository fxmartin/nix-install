# ABOUTME: Visual Studio Code post-installation configuration guide
# ABOUTME: Covers settings, extensions, themes, workspace configuration, and Python development setup

### VSCode

**Status**: Installed via Homebrew cask `visual-studio-code` (Story 02.2-002)

**✅ AUTO-CONFIGURED with BIDIRECTIONAL SYNC**: Settings symlinked to repo (REQ-NFR-008 compliant)

**How Bidirectional Sync Works**:
1. Settings file in repo: `config/vscode/settings.json` (version controlled)
2. On `darwin-rebuild`, activation script creates: `~/Library/Application Support/Code/User/settings.json` → `~/nix-install/config/vscode/settings.json`
3. Changes sync both ways:
   - **VSCode → Repo**: Modify settings in VSCode → Changes instantly appear in repo (git shows them)
   - **Repo → VSCode**: Pull updates or edit repo file → VSCode sees changes immediately
4. VSCode has full write access (symlink points to working directory, not read-only /nix/store)

**First Launch**:
1. Launch VSCode from Spotlight, Raycast, or `/Applications/Visual Studio Code.app`
2. Settings already configured from template
3. No sign-in required (optional: Sign in with GitHub for Settings Sync)

**Pre-Configured Settings** (from template):

The following settings are automatically configured from `config/vscode/settings.json`:

1. **Auto-Update Disabled** (CRITICAL):
   - `"update.mode": "none"`
   - `"extensions.autoUpdate": false`
   - `"extensions.autoCheckUpdates": false`
   - Updates only via `rebuild` or `update` commands
   - Ensures controlled update philosophy

2. **Catppuccin Theme**:
   - `"workbench.colorTheme": "Catppuccin Mocha"`
   - `"workbench.iconTheme": "catppuccin-mocha"`
   - **IMPORTANT**: Catppuccin theme extension must be installed manually (see Extensions section below)

3. **JetBrains Mono Font with Ligatures**:
   - `"editor.fontFamily": "JetBrains Mono, Menlo, Monaco, 'Courier New', monospace"`
   - `"editor.fontSize": 14`
   - `"editor.fontLigatures": true`
   - Consistent with terminal (Ghostty) and Zed font

4. **Telemetry Disabled**:
   - `"telemetry.telemetryLevel": "off"`
   - `"redhat.telemetry.enabled": false`
   - Privacy-focused configuration

5. **Git Integration Enabled**:
   - Auto-fetch disabled (controlled updates)
   - Smart commit enabled
   - Decorations enabled
   - Tree view mode for SCM panel

6. **Terminal Integration**:
   - Default shell: Zsh
   - Font: JetBrains Mono (matching editor)

7. **Language-Specific Settings**:
   - **Nix**: 2-space indentation, format on save
   - **Python**: 4-space indentation, Ruff formatter
   - **Markdown**: Word wrap enabled, suggestions disabled
   - **JSON/JSONC**: VSCode formatter

8. **Additional Settings**:
   - Format on save enabled
   - Trim trailing whitespace
   - Insert final newline
   - Bracket pair colorization
   - 80/120 character rulers
   - Explorer: Disable delete/drag confirmation

**Required Extensions**:

✅ **AUTOMATICALLY INSTALLED** during `darwin-rebuild`:

The following extensions are automatically installed via Home Manager activation script:

1. **Catppuccin Theme** (`Catppuccin.catppuccin-vsc`):
   - Provides both dark (Mocha) and light (Latte) themes
   - Auto-installed first (required for theme switching)
   - Theme activates automatically (already configured in settings.json)

2. **Auto Dark Mode** (`LinusU.auto-dark-mode`):
   - Automatically switches VSCode theme based on macOS system appearance
   - Auto-installed second (requires Catppuccin to be installed first)
   - **Behavior**:
     - macOS Light Mode → Catppuccin Latte (light theme)
     - macOS Dark Mode → Catppuccin Mocha (dark theme)
   - **Configuration**: Already pre-configured in settings.json (Issue #28 resolution)
     - `autoDarkMode.darkTheme: "Catppuccin Mocha"`
     - `autoDarkMode.lightTheme: "Catppuccin Latte"`
     - `window.autoDetectColorScheme: true` (REQUIRED - enables the extension)
   - **Why**: Matches Zed editor behavior (system appearance sync)
   - **Test**: Toggle macOS appearance (System Settings → Appearance) and VSCode will switch themes automatically
   - **✅ VM Tested**: Confirmed working on 2025-11-12

**How Auto-Installation Works**:
- Extensions install during `darwin-rebuild` via VSCode CLI (`code --install-extension`)
- Installation is idempotent (safe to run multiple times)
- If extensions already installed, script skips them
- If VSCode CLI not available, displays instructions for manual installation

**First-Time Setup Requirement**:
If this is your first VSCode installation:
1. Launch VSCode once (this registers the `code` CLI command)
2. Quit VSCode
3. Run `darwin-rebuild switch` again
4. Extensions will auto-install
5. Launch VSCode - themes active!

**Manual Installation (Fallback)**:

If auto-installation fails for any reason, install manually **IN ORDER**:

1. **Catppuccin Theme** (REQUIRED - Install First):
   - Open Extensions panel (Cmd+Shift+X)
   - Search: "Catppuccin"
   - Install: "Catppuccin for VSCode" by Catppuccin

2. **Auto Dark Mode** (REQUIRED - Install Second):
   - Open Extensions panel (Cmd+Shift+X)
   - Search: "Auto Dark Mode"
   - Install: "Auto Dark Mode" by LinusU
   - Version: 0.1.7 (macOS-specific)

**Optional Extensions**:

3. **Claude Code** (RECOMMENDED for AI pair programming):
   - Open Extensions panel (Cmd+Shift+X)
   - Search: "Claude Code"
   - Install: "Claude Code" by Anthropic
   - Sign in with Anthropic account when prompted
   - Note: Not auto-installed (license/account required)

**Optional Extensions** (can be installed later):

- **Nix IDE** - Nix language support (syntax highlighting, LSP)
- **Ruff** - Python linting and formatting (charliermarsh.ruff)
- **markdownlint** - Markdown linting and style checking
- **shellcheck** - Shell script linting
- **GitLens** - Enhanced Git integration
- **Error Lens** - Inline error/warning highlighting
- **Path Intellisense** - File path autocompletion
- **Todo Tree** - Highlight and track TODO comments

**Viewing/Modifying Settings**:
- **View current settings**: Press `Cmd+,` or click **Code → Settings → Settings**
- **Settings location**: `~/Library/Application Support/Code/User/settings.json` (symlinked to `~/nix-install/config/vscode/settings.json`)
- **Modify anytime**: VSCode has full write access, changes instantly sync to repo
- **Version controlled**: Settings tracked by git, can commit/revert changes

**Workflow Options**:

1. **Edit in VSCode** (most common):
   ```bash
   # 1. Open VSCode settings (Cmd+,)
   # 2. Switch to JSON view (click {} icon in top-right)
   # 3. Modify settings.json
   # 4. Save (Cmd+S)
   # 5. Check git status to see changes:
   git status
   # Shows: modified: config/vscode/settings.json

   # 6. Commit your changes:
   git add config/vscode/settings.json
   git commit -m "feat(vscode): add custom keybindings"
   git push
   ```

2. **Edit in repo** (for bulk changes):
   ```bash
   # 1. Edit directly in repo
   vim ~/nix-install/config/vscode/settings.json

   # 2. VSCode sees changes immediately (if running)
   # 3. Commit and push
   git add config/vscode/settings.json
   git commit -m "feat(vscode): update language settings"
   git push
   ```

3. **Pull updates** (sync from other machines):
   ```bash
   # Pull changes from repo
   git pull

   # VSCode automatically uses updated settings (may need restart)
   ```

**Testing**:
- [ ] Launch VSCode successfully
- [ ] Settings symlink created at ~/Library/Application Support/Code/User/settings.json
- [ ] Install Catppuccin theme extension
- [ ] Theme applies correctly (Catppuccin Mocha)
- [ ] Font is JetBrains Mono with ligatures working (→ ≠ ≥ ≤ etc.)
- [ ] Auto-update disabled (no update prompts in VSCode)
- [ ] Install Claude Code extension
- [ ] Terminal integration works (opens Zsh)
- [ ] Git integration works (shows changes, decorations)
- [ ] Language-specific settings apply (test .nix, .py, .md files)
- [ ] Bidirectional sync: Edit in VSCode, verify git shows changes
- [ ] Bidirectional sync: Edit repo file, verify VSCode sees changes

**Known Issues**:
- **Theme not applied**: Install Catppuccin theme extension first (Extensions panel)
- **Settings not syncing**: Verify symlink exists at ~/Library/Application Support/Code/User/settings.json
- If symlink broken: Re-run `darwin-rebuild switch` to recreate

**Resources**:
- VSCode Documentation: https://code.visualstudio.com/docs
- VSCode Settings Reference: https://code.visualstudio.com/docs/getstarted/settings
- Catppuccin Theme: https://github.com/catppuccin/vscode
- Claude Code Extension: https://marketplace.visualstudio.com/items?itemName=Anthropic.claude-code
- JetBrains Mono Font: https://www.jetbrains.com/lp/mono/

---


---

## Related Documentation

- [Main Apps Index](../README.md)
- [Zed Editor Configuration](./zed-editor.md)
- [Python Tools Configuration](./python-tools.md)
- [Claude Code CLI](./claude-code-cli.md)
