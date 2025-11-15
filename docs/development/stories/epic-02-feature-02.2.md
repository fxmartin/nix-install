# ABOUTME: Epic-02 Feature 02.2 (Development Environment Applications) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 02.2

# Epic-02 Feature 02.2: Development Environment Applications

## Feature Overview

**Feature ID**: Feature 02.2
**Feature Name**: Development Environment Applications
**Epic**: Epic-02
**Status**: 🔄 In Progress

### Feature 02.2: Development Environment Applications
**Feature Description**: Install development editors, terminals, AI tooling (Claude Code CLI + MCP servers), and container tools
**User Value**: Complete development workflow support for Python, AI-assisted development with enhanced context, and containerized applications
**Story Count**: 6
**Story Points**: 32
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 02.2-001: Zed Editor Installation and Configuration
**User Story**: As FX, I want Zed editor installed and configured via Home Manager so that I have a fast, modern code editor with Catppuccin theming

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Zed
- **Then** it opens with Catppuccin theme (Latte for light, Mocha for dark)
- **And** it uses JetBrains Mono Nerd Font with ligatures
- **And** theme switches automatically with macOS system appearance
- **And** auto-update is disabled in Zed settings
- **And** Zed configuration is managed by Home Manager

**Additional Requirements**:
- Installation via Homebrew Cask
- Theming via Stylix integration
- Auto-update disabled: `"auto_update": false` in settings.json
- Configuration managed declaratively
- **REQ-NFR-008**: Settings file MUST use repository symlink pattern (not /nix/store)

**Technical Notes**:
- Homebrew cask: `zed`
- Stylix should automatically theme Zed if supported
- **REQ-NFR-008 Implementation**:
  - ❌ Do NOT use `programs.zed.settings = {...}` (creates read-only /nix/store symlink)
  - ✅ Use `home.activation` script to create symlink to repository:
    ```nix
    home.activation.zedConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ln -sf "$REPO_ROOT/config/zed/settings.json" "$HOME/.config/zed/settings.json"
    '';
    ```
  - Pattern: `~/.config/zed/settings.json` → `$REPO/config/zed/settings.json`
  - Enables bidirectional sync: changes in Zed appear in repo, git pull updates Zed
  - Reference implementation: `home-manager/modules/zed.nix`
- Verify theme switching with system appearance

**Definition of Done**:
- [x] Zed installed via homebrew.nix
- [x] Zed configuration in home-manager module (bidirectional sync via activation script)
- [x] Catppuccin theme applied (VM testing by FX - 2025-11-12)
- [x] JetBrains Mono font active (VM testing by FX - 2025-11-12)
- [x] Auto-update disabled (VM testing by FX - 2025-11-12)
- [x] Theme switches with system appearance (VM testing by FX - 2025-11-12)
- [x] Tested in VM (VM testing by FX - 2025-11-12)

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-11
**Branch**: feature/02.2-001-zed-editor
**Files Changed**:
- darwin/homebrew.nix: Added `zed` cask
- home-manager/modules/zed.nix: Created Zed configuration module with bidirectional sync
- home-manager/home.nix: Imported zed module
- config/zed/settings.json: Created template settings with Catppuccin theme
- config/README.md: Documented Zed settings sync approach
- docs/app-post-install-configuration.md: Added Zed configuration section

**Implementation Notes**:
- **REQ-NFR-008 Compliance**: ✅ Fully implements repository symlink pattern
- **Issue #26**: Resolved /nix/store write access issue with bidirectional sync
- **Hotfix #14**: Made repo path dynamic for custom NIX_INSTALL_DIR support
- **Activation Script**: Searches common locations, validates with flake.nix + config/zed/
- **Symlink**: ~/.config/zed/settings.json → $REPO_ROOT/config/zed/settings.json
- **Bidirectional**: Changes in Zed instantly appear in repo, pull updates apply to Zed
- **Theme**: Catppuccin Mocha (dark) and Latte (light) via system appearance
- **Font**: JetBrains Mono with ligatures enabled
- **Auto-update**: Disabled via "auto_update": false in settings.json
- **Reference**: This implementation serves as the pattern for all apps requiring config file management

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin + Home Manager)
- Epic-05, Story 05.1-001 (Stylix theming configured)

**Risk Level**: Low
**Risk Mitigation**: Manual theme configuration if Stylix doesn't support Zed

---

##### Story 02.2-002: VSCode Installation
**User Story**: As FX, I want VSCode installed so that I can use Claude Code extension and other VSCode-specific tools

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch VSCode
- **Then** it opens successfully
- **And** auto-update is disabled (`"update.mode": "none"` in settings)
- **And** I can install extensions manually
- **And** theme is Catppuccin (via Stylix if possible, otherwise manual)

**Additional Requirements**:
- Installation via Homebrew Cask
- Auto-update disabled globally
- Claude Code extension installation documented (manual step)
- Optional: Stylix theming if supported
- **REQ-NFR-008**: Settings file MUST use repository symlink pattern (not /nix/store)

**Technical Notes**:
- Homebrew cask: `visual-studio-code`
- **REQ-NFR-008 Implementation**:
  - ❌ **ANTI-PATTERN**: Do NOT use `programs.vscode.userSettings = {...}`
  - ❌ **Reason**: Creates read-only symlink to /nix/store, breaks VSCode write access
  - ✅ **CORRECT**: Use `home.activation` script to create repository symlink:
    ```nix
    home.activation.vscodeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Dynamically find repo location (same pattern as Zed)
      REPO_ROOT=$(find_repo_root)  # Search ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install
      mkdir -p "$HOME/Library/Application Support/Code/User"
      ln -sf "$REPO_ROOT/config/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
    '';
    ```
  - Pattern: `~/Library/Application Support/Code/User/settings.json` → `$REPO/config/vscode/settings.json`
  - Enables bidirectional sync: changes in VSCode appear in repo, git pull updates VSCode
  - Reference: `home-manager/modules/zed.nix` for complete implementation pattern
- Settings to include in config/vscode/settings.json:
  - `"update.mode": "none"` (disable auto-update)
  - `"workbench.colorTheme": "Catppuccin Mocha"` (theme)
- Document Claude Code extension install: Extensions → Search "Claude Code" → Install

**Definition of Done**:
- [x] VSCode installed via homebrew.nix
- [x] Settings symlinked to repository (REQ-NFR-008 compliant)
- [x] Auto-update disabled in settings
- [x] VSCode launches successfully (VM testing by FX - 2025-11-12)
- [x] Extension installation documented
- [x] Tested in VM (VM testing by FX - 2025-11-12)
- [x] Theme configured (automated Catppuccin + Auto Dark Mode extensions)
- [x] Bidirectional sync verified (VM testing by FX - 2025-11-12)
- [x] Auto theme switching works (Light → Latte, Dark → Mocha) (VM testing by FX - 2025-11-12)

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-12
**Branch**: feature/02.2-002-vscode (ready to merge to main)
**Files Changed**:
- darwin/homebrew.nix: Added `visual-studio-code` cask
- config/vscode/settings.json: Created comprehensive settings (3.5 KB) with auto-update disabled and Catppuccin theme
- home-manager/modules/vscode.nix: Created Home Manager module (4.8 KB) with REQ-NFR-008 compliant activation script
- home-manager/home.nix: Imported vscode module
- docs/app-post-install-configuration.md: Added VSCode section (180+ lines) with extension installation guide

**Implementation Details**:
- REQ-NFR-008 compliant: Bidirectional symlink to repository (NOT /nix/store)
- Settings location: `~/Library/Application Support/Code/User/settings.json` → `$REPO/config/vscode/settings.json`
- Auto-update disabled: `update.mode: "none"`, `extensions.autoUpdate: false`, `extensions.autoCheckUpdates: false`
- Theme: Catppuccin with auto-switching (Issue #28 resolution):
  - Extension 1: Catppuccin Theme (provides Mocha/Latte themes) - **AUTOMATICALLY INSTALLED**
  - Extension 2: Auto Dark Mode (monitors macOS appearance, switches themes automatically) - **AUTOMATICALLY INSTALLED**
  - Extensions auto-install via Home Manager activation script using VSCode CLI
  - Installation is idempotent (checks if already installed, skips if present)
  - Light Mode → Catppuccin Latte, Dark Mode → Catppuccin Mocha
  - Matches Zed editor behavior (system appearance sync)
  - Zero manual intervention (extensions installed during darwin-rebuild)
  - Required setting: `window.autoDetectColorScheme: true` (enables Auto Dark Mode extension)
- Font: JetBrains Mono with ligatures (matches Ghostty and Zed)
- Language-specific settings: Nix (2-space indent), Python (4-space indent, Ruff formatter), Markdown, JSON, YAML
- Privacy: Telemetry disabled, crash reporter disabled
- Git integration: Decorations, inline changes, autofetch disabled
- Terminal integration: Integrated terminal uses Zsh

**Issues Resolved**:
- **Issue #28**: VSCode theme auto-switching - Implemented Auto Dark Mode extension with window.autoDetectColorScheme setting
- **Issue #29**: VSCode CLI PATH issue - Multi-location CLI detection (/opt/homebrew/bin, /usr/local/bin, app bundle path)
- **Issue #30**: Duplicate of #28 (closed as duplicate)

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.2-003: Ghostty Terminal Installation
**User Story**: As FX, I want Ghostty terminal installed with my existing config from `config/ghostty/config` so that I have a fast GPU-accelerated terminal with Catppuccin theming

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch Ghostty
- **Then** it opens with configuration from `config/ghostty/config`
- **And** Catppuccin theme is applied (Latte/Mocha auto-switch)
- **And** JetBrains Mono font with ligatures is active
- **And** 95% opacity with blur effect works
- **And** all keybindings from config are functional
- **And** auto-update is disabled (`auto-update = off` in config)

**Additional Requirements**:
- Installation via Homebrew Cask
- Configuration via Home Manager activation script (see Story 04.4-001)
- Theme consistency with Zed (same Catppuccin variant)
- Config location: ~/.config/ghostty/config
- **REQ-NFR-008**: Config MUST use repository symlink (see Story 04.4-001 for implementation)

**Technical Notes**:
- Homebrew cask: `ghostty`
- **Configuration implemented in Story 02.2-003** (This story)
- **REQ-NFR-008 Note**:
  - ❌ Do NOT use `xdg.configFile."ghostty/config".source = ...` (creates /nix/store symlink)
  - ✅ Use activation script pattern (same as Zed and VSCode)
  - Pattern: `~/.config/ghostty/config` → `$REPO/config/ghostty/config`
- Existing config already has Catppuccin theme and auto-update=off
- Verify: `ls -la ~/.config/ghostty/config` should show symlink to repository (not /nix/store)

**Definition of Done**:
- [x] Ghostty installed via homebrew.nix (already installed since Phase 5)
- [x] Home Manager module created for config symlink (home-manager/modules/ghostty.nix)
- [x] Module imported in home.nix
- [x] Documentation added to app-post-install-configuration.md
- [x] Ghostty launches with correct theme (VM tested by FX - 2025-11-12)
- [x] Font and ligatures working (VM tested by FX - 2025-11-12)
- [x] Opacity and blur effects active (VM tested by FX - 2025-11-12)
- [x] Keybindings functional (VM tested by FX - 2025-11-12)
- [x] Config symlink verified (VM tested by FX - 2025-11-12)
- [x] Tested in VM (VM tested by FX - 2025-11-12)

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-12
**VM Testing Date**: 2025-11-12
**Branch**: feature/02.2-003-ghostty (merged to main)

**Files Changed**:
- home-manager/modules/ghostty.nix: Created Home Manager module (117 lines) with REQ-NFR-008 compliant activation script
- home-manager/home.nix: Added ghostty module import
- docs/app-post-install-configuration.md: Added comprehensive Ghostty section (180+ lines)

**Implementation Details**:
- REQ-NFR-008 compliant: Bidirectional symlink to repository (NOT /nix/store)
- Config location: `~/.config/ghostty/config` → `$REPO/config/ghostty/config`
- Activation script pattern (same as Zed and VSCode):
  - Dynamically finds repo location (~/nix-install, ~/.config/nix-install, ~/Documents/nix-install)
  - Creates symlink on darwin-rebuild
  - Backs up existing config if found
  - Updates symlink target if changed
- Auto-update disabled: `auto-update = off` in config/config.ghostty
- Theme: Catppuccin with auto-switching (Latte for light mode, Mocha for dark mode)
- Font: JetBrains Mono with ligatures (consistent with Zed and VSCode)
- Configuration features:
  - Background opacity 95% with blur effect
  - Window padding 16px
  - Shell integration enabled
  - Comprehensive productivity keybindings
  - Clipboard security settings

**VM Testing Instructions** (for FX):
1. Run `darwin-rebuild switch` in VM
2. Verify symlink created: `ls -la ~/.config/ghostty/config`
3. Launch Ghostty and verify:
   - Theme is Catppuccin (Mocha for dark mode)
   - Font is JetBrains Mono with ligatures working
   - Background opacity and blur effect active
   - Window padding visible
   - Config reload works (Ctrl+Shift+,)
4. Test theme auto-switching:
   - Toggle macOS appearance (System Settings → Appearance)
   - Verify Ghostty switches between Latte (light) and Mocha (dark)
5. Test bidirectional sync:
   - Edit config/ghostty/config in repo
   - Reload config in Ghostty (Ctrl+Shift+,)
   - Verify changes apply

**Dependencies**:
- Epic-01, Story 01.5-001 (Homebrew + Home Manager)
- Epic-05, Story 05.1-001 (Stylix provides consistent theme) - Optional dependency

**Risk Level**: Low
**Risk Mitigation**: Existing config.ghostty is proven to work, same pattern as Zed and VSCode

---

##### Story 02.2-004: Python and Development Tools
**User Story**: As FX, I want Python 3.12, uv, and essential Python dev tools installed via Nix so that I have a complete Python development environment

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `python --version`
- **Then** it shows Python 3.12.x
- **And** `uv --version` works
- **And** `ruff --version`, `black --version`, `isort --version`, `mypy --version`, `pylint --version` all work
- **And** all tools are in PATH globally
- **And** I can create a new Python project with `uv init test-project`

**Additional Requirements**:
- Python 3.12 via Nix (not Homebrew)
- uv for package management
- Global dev tools: ruff, black, isort, mypy, pylint
- All managed via nixpkgs

**Technical Notes**:
- Add to darwin/configuration.nix:
  ```nix
  environment.systemPackages = with pkgs; [
    python312
    uv
    ruff
    black
    python312Packages.isort
    python312Packages.mypy
    python312Packages.pylint
  ];
  ```
- Verify: `which python` shows /nix/store path
- Test: Create project with `uv init`, verify tools work

**Definition of Done**:
- [x] Python 3.12 installed via Nix
- [x] uv installed and functional
- [x] All dev tools installed and in PATH
- [x] Can create and manage Python projects
- [x] Tested in VM ✅ VM tested by FX - 2025-11-12
- [x] Documentation notes uv usage

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-12
**VM Testing Date**: 2025-11-12
**Branch**: feature/02.2-004-python-dev-tools (merged to main)
**Files Changed**:
- darwin/configuration.nix: Added Python 3.12 and development tools to systemPackages
- docs/app-post-install-configuration.md: Added comprehensive Python section (150+ lines)

**Implementation Details**:
- Python 3.12 via Nix (python312 package)
- uv package manager (fast pip replacement)
- Development tools: ruff, black, python312Packages.isort, python312Packages.mypy, python312Packages.pylint
- All tools globally accessible in PATH
- No configuration required (works out of the box)
- Documentation includes verification steps, usage examples, editor integration

**VM Testing Instructions** (for FX):
1. Run `darwin-rebuild switch` in VM
2. Verify Python version: `python --version` (should show 3.12.x)
3. Verify Python path: `which python` (should show /nix/store/...)
4. Test tools:
   ```bash
   uv --version
   ruff --version
   black --version
   isort --version
   mypy --version
   pylint --version
   ```
5. Create test project:
   ```bash
   uv init test-project
   cd test-project
   uv add requests
   echo 'import requests; print(requests.__version__)' > test.py
   uv run python test.py
   ```
6. Verify all commands work without errors

**Dependencies**:
- Epic-01, Story 01.4-001 (Nix installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 02.2-005: Podman and Container Tools
**User Story**: As FX, I want Podman, podman-compose, and Podman Desktop installed so that I can run containers without Docker

**Priority**: Must Have
**Story Points**: 6
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `podman --version`
- **Then** it shows Podman version
- **And** `podman-compose --version` works
- **And** Podman Desktop app is installed and launches
- **And** I can run `podman run hello-world` successfully
- **And** Podman machine is initialized and running
- **And** The Desktop App is also installed

**Additional Requirements**:
- Podman CLI via Nix
- podman-compose via Nix
- Podman Desktop via Nix
- Machine initialization automated or documented

**Technical Notes**:
- **Important**: All Podman tools installed via Homebrew (not Nix) for GUI integration
- Podman Desktop (GUI app) requires podman CLI in standard PATH
- GUI applications on macOS don't inherit shell PATH, so Nix packages may not be found
- Add to darwin/homebrew.nix:
  ```nix
  homebrew.brews = [
    "podman"          # Podman CLI
    "podman-compose"  # Docker Compose compatibility
  ];
  homebrew.casks = [
    "podman-desktop"  # Podman Desktop GUI
  ];
  ```
- Initialize Podman machine: `podman machine init && podman machine start`
- Machine initialization documented in post-install guide

**Definition of Done**:
- [x] Podman CLI installed via Homebrew
- [x] podman-compose installed via Homebrew
- [x] Podman Desktop installed via Homebrew cask
- [x] Can run containers successfully ✅ VM tested
- [x] Machine initialization documented
- [x] Tested in VM ✅ All manual tests successful (2025-11-15)
- [x] Documentation includes setup steps

**Implementation Status**: ✅ **COMPLETE** - VM tested and validated by FX
**Implementation Date**: 2025-11-15
**VM Testing Date**: 2025-11-15
**Branch**: feature/02.2-005-podman
**Files Changed**:
- darwin/homebrew.nix: Added podman, podman-compose brews + podman-desktop cask
- docs/app-post-install-configuration.md: Added comprehensive Podman section (240+ lines)

**Implementation Details**:
- Podman CLI via Homebrew brew (podman)
- podman-compose via Homebrew brew (podman-compose)
- Podman Desktop via Homebrew cask (podman-desktop)
- **Rationale for Homebrew**: GUI integration - Podman Desktop needs podman CLI in standard PATH
- Comprehensive documentation covering:
  - Machine initialization requirements (one-time setup)
  - Verification commands
  - Basic usage examples (run, compose, build)
  - Docker compatibility (aliases, drop-in replacement)
  - Troubleshooting guide
  - Resource management tips
- No Home Manager module needed (system-level packages only)

**Issues Encountered and Resolved**:
- **Issue #33**: Podman Desktop "extension not detected" error
  - Root cause: Podman CLI via Nix not in GUI app PATH
  - Resolution: Moved all Podman tools to Homebrew (commit b03bc37)
- **Issue #34**: "Docker socket is not disguised correctly" error
  - Root cause: Machine initialized without proper Docker compatibility flags
  - Resolution: Use `podman machine init --now --rootful=false` (commit 15648d4)

**VM Testing Results** (FX - 2025-11-15):
- ✅ Podman CLI installed and accessible (/opt/homebrew/bin/podman)
- ✅ podman-compose installed and functional
- ✅ Podman Desktop launches without errors
- ✅ Podman extension detected correctly
- ✅ Machine initializes with correct flags (--now --rootful=false)
- ✅ Docker socket configured properly (no errors)
- ✅ Container execution successful (hello-world, alpine)
- ✅ podman-compose works with docker-compose.yml files
- ✅ All troubleshooting scenarios documented and tested

**VM Testing Instructions** (for FX):
1. Run `darwin-rebuild switch` in VM
2. Verify installations:
   ```bash
   podman --version
   podman-compose --version
   open -a "Podman Desktop"
   ```
3. Initialize Podman machine (with Docker compatibility):
   ```bash
   # Initialize and start in one command
   podman machine init --now --rootful=false

   # Verify machine is running
   podman machine list
   # Expected: Shows "Currently running"
   ```
4. Test container execution:
   ```bash
   podman run --rm hello-world
   podman run --rm -it alpine:latest echo "Podman works!"
   ```
5. Test Podman Desktop:
   - Launch app from Applications
   - Verify machine status shown
   - Check containers/images management UI
6. Test podman-compose:
   ```bash
   echo 'version: "3"
   services:
     web:
       image: nginx:latest
       ports:
         - "8080:80"' > docker-compose.yml
   podman-compose up -d
   curl localhost:8080
   podman-compose down
   ```

**Dependencies**:
- Epic-01, Story 01.4-001 (Nix installed)
- Epic-01, Story 01.5-001 (Homebrew managed)

**Risk Level**: Medium
**Risk Mitigation**: Document machine initialization clearly, provide troubleshooting for common issues

---

##### Story 02.2-006: Claude Code CLI and MCP Servers
**User Story**: As FX, I want Claude Code CLI installed with Context7, GitHub, and Sequential Thinking MCP servers configured so that I can use AI-assisted development with enhanced context awareness, repository integration, and structured reasoning

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 3

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `claude --version`
- **Then** it shows Claude Code CLI version
- **And** I can run `claude` to start an interactive session
- **And** MCP servers are configured in `~/.config/claude/config.json`
- **And** Context7 MCP server is available and responds to context queries
- **And** GitHub MCP server is available and can query repositories
- **And** Sequential Thinking MCP server is available for structured reasoning
- **And** I can verify MCP servers with `claude mcp list`
- **And** `~/.claude/CLAUDE.md` is symlinked to repository (REQ-NFR-008)
- **And** `~/.claude/agents/` is symlinked to repository (REQ-NFR-008)
- **And** `~/.claude/commands/` is symlinked to repository (REQ-NFR-008)
- **And** Changes to repository files immediately appear in ~/.claude/ (bidirectional sync)
- **And** Claude Code CLI auto-update is disabled or documented

**Additional Requirements**:
- Claude Code CLI installed via Nix (using sadjow/claude-code-nix)
- MCP servers installed via Nix (using natsukium/mcp-servers-nix)
- Configuration file created at ~/.config/claude/config.json
- MCP servers: Context7, GitHub, Sequential Thinking
- All servers configured with appropriate permissions
- **REQ-NFR-008**: Claude Code configuration MUST use repository symlink pattern (not /nix/store)
  - ~/.claude/CLAUDE.md → $REPO/config/claude/CLAUDE.md
  - ~/.claude/agents/ → $REPO/config/claude/agents/
  - ~/.claude/commands/ → $REPO/config/claude/commands/
- Documentation for MCP server usage and authentication

**Technical Notes**:
- **Claude Code CLI Installation** (via Nix):
  - Use package from https://github.com/sadjow/claude-code-nix/
  - Add as flake input to flake.nix
  - Install via darwin/configuration.nix systemPackages

- **MCP Servers Installation** (via Nix):
  - Use packages from https://github.com/natsukium/mcp-servers-nix/
  - Add as flake input to flake.nix
  - Install via darwin/configuration.nix systemPackages
  - Fully declarative, no npm/npx needed

- **Flake Inputs** (add to flake.nix):
  ```nix
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";

    # Claude Code CLI
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MCP Servers
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  ```

- **System Packages** (darwin/configuration.nix):
  ```nix
  environment.systemPackages = [
    # Claude Code CLI
    inputs.claude-code-nix.packages.${system}.default

    # MCP Servers
    inputs.mcp-servers-nix.packages.${system}.mcp-server-context7
    inputs.mcp-servers-nix.packages.${system}.mcp-server-github
    inputs.mcp-servers-nix.packages.${system}.mcp-server-sequential-thinking

    # ... other packages
  ];
  ```

- **Configuration File** (~/.config/claude/config.json):
  ```json
  {
    "mcpServers": {
      "context7": {
        "command": "mcp-server-context7",
        "args": [],
        "enabled": true
      },
      "github": {
        "command": "mcp-server-github",
        "args": [],
        "env": {
          "GITHUB_TOKEN": "${GITHUB_TOKEN}"
        },
        "enabled": true
      },
      "sequential-thinking": {
        "command": "mcp-server-sequential-thinking",
        "args": [],
        "enabled": true
      }
    }
  }
  ```
  Note: Command names reference the Nix-installed binaries directly (not npx)

- **Home Manager Module** (home-manager/modules/claude-code.nix):
  ```nix
  { config, lib, pkgs, ... }:

  {
    # Create Claude Code config and symlink repository files
    home.activation.claudeCodeSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Find repository location (same pattern as Zed, VSCode, Ghostty)
      REPO_ROOT=""
      for location in "$HOME/nix-install" "$HOME/.config/nix-install" "$HOME/Documents/nix-install"; do
        if [[ -d "$location" && -f "$location/flake.nix" && -d "$location/config/claude" ]]; then
          REPO_ROOT="$location"
          break
        fi
      done

      if [[ -z "$REPO_ROOT" ]]; then
        echo "⚠ WARNING: Could not find nix-install repository"
        echo "  Searched: ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install"
        echo "  Claude Code configuration will not be linked"
      else
        # Create ~/.claude directory
        mkdir -p "$HOME/.claude"

        # Symlink CLAUDE.md (REQ-NFR-008 compliant)
        if [[ -f "$REPO_ROOT/config/claude/CLAUDE.md" ]]; then
          ln -sf "$REPO_ROOT/config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
          echo "✓ Linked ~/.claude/CLAUDE.md → $REPO_ROOT/config/claude/CLAUDE.md"
        else
          echo "⚠ WARNING: $REPO_ROOT/config/claude/CLAUDE.md not found"
        fi

        # Symlink agents directory
        if [[ -d "$REPO_ROOT/config/claude/agents" ]]; then
          ln -sfn "$REPO_ROOT/config/claude/agents" "$HOME/.claude/agents"
          echo "✓ Linked ~/.claude/agents/ → $REPO_ROOT/config/claude/agents/"
        else
          echo "⚠ WARNING: $REPO_ROOT/config/claude/agents/ directory not found"
        fi

        # Symlink commands directory
        if [[ -d "$REPO_ROOT/config/claude/commands" ]]; then
          ln -sfn "$REPO_ROOT/config/claude/commands" "$HOME/.claude/commands"
          echo "✓ Linked ~/.claude/commands/ → $REPO_ROOT/config/claude/commands/"
        else
          echo "⚠ WARNING: $REPO_ROOT/config/claude/commands/ directory not found"
        fi
      fi

      # Create ~/.config/claude directory for MCP config
      mkdir -p "$HOME/.config/claude"

      # Create config.json with MCP servers (Nix-installed binaries)
      cat > "$HOME/.config/claude/config.json" <<'EOF'
      {
        "mcpServers": {
          "context7": {
            "command": "mcp-server-context7",
            "args": [],
            "enabled": true
          },
          "github": {
            "command": "mcp-server-github",
            "args": [],
            "env": {
              "GITHUB_TOKEN": "REPLACE_WITH_YOUR_GITHUB_TOKEN"
            },
            "enabled": true
          },
          "sequential-thinking": {
            "command": "mcp-server-sequential-thinking",
            "args": [],
            "enabled": true
          }
        }
      }
      EOF

      echo "✓ Claude Code MCP servers configured at ~/.config/claude/config.json"
      echo "  NOTE: Edit ~/.config/claude/config.json to add:"
      echo "  - GitHub personal access token (GITHUB_TOKEN)"
      echo "  - Get token at: https://github.com/settings/tokens"
      echo "  - Required scopes: repo, read:org, read:user"
    '';
  }
  ```

  **Key Changes**:
  - No Node.js dependency needed (MCP servers are Nix packages)
  - Commands use Nix binary names (`mcp-server-context7`, `mcp-server-github`)
  - No `npx` or npm package installation required
  - MCP servers already in PATH from systemPackages
  - **REQ-NFR-008 Compliance**: Symlinks ~/.claude/ files from repository
    - CLAUDE.md → bidirectional sync (edit in repo or in ~/.claude/)
    - agents/ directory → synced from repo
    - commands/ directory → synced from repo
  - Dynamic repo location detection (same pattern as Zed, VSCode, Ghostty)

- **Authentication Setup**:
  - **GitHub MCP**: Requires GitHub personal access token
    - Create at: https://github.com/settings/tokens
    - Scopes needed: `repo`, `read:org`, `read:user`
    - Store in ~/.config/claude/config.json or environment variable
  - **Context7 MCP**: No authentication required
  - **Sequential Thinking MCP**: No authentication required

- **Post-Install Configuration**:
  - Add to docs/app-post-install-configuration.md
  - Document GitHub token creation and configuration
  - Provide example queries for each MCP server

**Definition of Done**:
- [ ] claude-code-nix flake input added to flake.nix
- [ ] mcp-servers-nix flake input added to flake.nix
- [ ] Claude Code CLI installed via Nix and in PATH
- [ ] `claude --version` command works
- [ ] MCP servers (context7, github, sequential-thinking) installed via Nix and in PATH
- [ ] MCP servers configured in ~/.config/claude/config.json with Nix binary paths
- [ ] Context7 MCP server functional (test with `mcp-server-context7 --version`)
- [ ] GitHub MCP server functional (with token configured)
- [ ] Sequential Thinking MCP server functional (test with `mcp-server-sequential-thinking --version`)
- [ ] **REQ-NFR-008**: Repository symlinks verified:
  - [ ] `~/.claude/CLAUDE.md` → `$REPO/config/claude/CLAUDE.md` (bidirectional)
  - [ ] `~/.claude/agents/` → `$REPO/config/claude/agents/`
  - [ ] `~/.claude/commands/` → `$REPO/config/claude/commands/`
  - [ ] Verify: `ls -la ~/.claude/` shows symlinks to repository
- [ ] Configuration documented in app-post-install-configuration.md
- [ ] Token/credential setup documented (GitHub token creation guide)
- [ ] Tested in VM with all MCP servers responding
- [ ] Example queries documented for each MCP server (including sequential thinking use cases)
- [ ] Verified no npm/npx dependencies needed
- [ ] Bidirectional sync tested (edit in repo, changes visible in ~/.claude/)

**Implementation Status**: Not Started

**Dependencies**:
- Epic-01, Story 01.4-001 (Nix installed and flake.nix exists)
- Epic-01, Story 01.5-001 (Home Manager available)

**Risk Level**: Low
**Risk Mitigation**:
- Fully Nix-based installation (claude-code-nix + mcp-servers-nix)
- No npm/npx dependencies - everything via Nix packages
- Reproducible across all machines via flake.lock
- MCP servers as system packages (no runtime downloads)
- GitHub token stored in config file (document secure storage options)
- Test each MCP server independently with version checks
- Community-maintained Nix packages with active development

---

