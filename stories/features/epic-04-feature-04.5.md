# ABOUTME: Epic-04 Feature 04.5 (Shell Aliases and Functions) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 04.5

# Epic-04 Feature 04.5: Shell Aliases and Functions

## Feature Overview

**Feature ID**: Feature 04.5
**Feature Name**: Shell Aliases and Functions
**Epic**: Epic-04
**Status**: 🔄 In Progress

### Feature 04.5: Shell Aliases and Functions
**Feature Description**: Configure useful shell aliases for Nix operations, daily tasks, and modern CLI tool replacements
**User Value**: Quick commands for rebuild, update, cleanup, and modern Unix tool replacements with better defaults
**Story Count**: 3
**Story Points**: 18
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 04.5-001: Core Nix Aliases
**User Story**: As FX, I want aliases for rebuild, update, and cleanup commands so that I can manage my system efficiently

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `rebuild`
- **Then** it executes `darwin-rebuild switch --flake ~/Documents/nix-install#$(hostname -s)`
- **And** applies current configuration changes
- **When** I run `update`
- **Then** it updates flake.lock and rebuilds (updates ALL apps and system)
- **When** I run `gc`
- **Then** it runs `nix-collect-garbage -d` (garbage collection)
- **When** I run `cleanup`
- **Then** it runs garbage collection + nix-store optimization
- **And** all aliases work in fresh terminal

**Additional Requirements**:
- rebuild: Apply config changes (uses current flake.lock)
- update: Update flake.lock + rebuild (updates packages)
- gc: Delete old generations
- cleanup: Full cleanup (gc + optimization)
- Aliases persist across terminals

**Technical Notes**:
- Add to home-manager/modules/aliases.nix:
  ```nix
  programs.zsh.shellAliases = {
    rebuild = "darwin-rebuild switch --flake ~/Documents/nix-install";
    update = "cd ~/Documents/nix-install && nix flake update && darwin-rebuild switch --flake .";
    gc = "nix-collect-garbage -d";
    cleanup = "nix-collect-garbage -d && nix-store --optimize";
    health-check = "~/Documents/nix-install/scripts/health-check.sh";  # From Epic-06
  };
  ```
- Note: `rebuild` and `update` are THE ONLY ways to update apps (no auto-updates)
- Test: Run `rebuild` (should apply config), `update` (should update flake.lock)

**Definition of Done**:
- [ ] Aliases configured in home-manager module
- [ ] rebuild command works
- [ ] update command works
- [ ] gc command works
- [ ] cleanup command works
- [ ] Aliases persist across terminals
- [ ] Tested in VM
- [ ] Documentation explains rebuild vs update

**Dependencies**:
- Story 04.1-001 (Zsh configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 04.5-002: General Shell Aliases
**User Story**: As FX, I want common shell aliases like ll, la, and grep colors so that daily terminal use is efficient

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `ll`
- **Then** it shows `ls -lah` (detailed list with hidden files)
- **When** I run `la`
- **Then** it shows `ls -A` (all files except . and ..)
- **When** I run grep
- **Then** matches are highlighted in color
- **And** all aliases work in fresh terminal

**Note**: Docker/Podman aliases (`docker`, `docker-compose`) are defined in Story 04.8-002

**Additional Requirements**:
- ll: Detailed list with human-readable sizes
- la: Show all files including hidden
- grep: Color output for visibility
- Persist across terminals

**Technical Notes**:
- Add to home-manager/modules/aliases.nix:
  ```nix
  programs.zsh.shellAliases = {
    ll = "ls -lah";
    la = "ls -A";
    l = "ls -CF";
    grep = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";
    ".." = "cd ..";
    "..." = "cd ../..";
  };
  ```
- Note: Modern CLI tool replacements (eza, ripgrep, bat, etc.) are configured in Story 04.5-003
- Test: `ll` shows detailed list, `grep` shows colored output

**Definition of Done**:
- [ ] General aliases configured
- [ ] ll, la, l commands work
- [ ] grep shows colored output
- [ ] Navigation aliases (.., ...) work
- [ ] Aliases persist across terminals
- [ ] Tested in VM

**Dependencies**:
- Story 04.1-001 (Zsh configured)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 04.5-003: Modern CLI Tool Replacements
**User Story**: As FX, I want modern CLI tools (ripgrep, bat, fd, eza, zoxide, httpie, tldr) installed and aliased to replace legacy Unix tools so that I have faster, more user-friendly command-line tools with better defaults

**Priority**: Should Have (P1)
**Story Points**: 8
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `rg "pattern"`
- **Then** it searches code 15x faster than grep with colored output
- **And** automatically respects .gitignore files
- **When** I run `bat file.js`
- **Then** it displays the file with syntax highlighting and line numbers
- **When** I run `fd pattern`
- **Then** it finds files faster than find with intuitive syntax
- **When** I run `eza -lah --git`
- **Then** it shows a detailed file list with git status and icons
- **When** I run `z <partial-dir-name>`
- **Then** zoxide jumps to the most frecent matching directory
- **When** I run `http POST api.example.com name=John`
- **Then** httpie makes a readable POST request with formatted output
- **When** I run `tldr tar`
- **Then** it shows practical examples instead of verbose man pages
- **And** all tools work in fresh terminal

**Additional Requirements**:
- **ripgrep (rg)**: Fast code search, respects .gitignore, colored output
- **bat**: Syntax highlighting for 200+ languages, git integration, line numbers
- **fd**: Intuitive file finding, respects .gitignore, fast
- **eza**: Modern ls replacement (exa successor), git status, icons, tree view
- **zoxide**: Frecency-based directory jumping (replaces z plugin)
- **httpie**: Human-readable HTTP requests
- **tldr**: Practical command examples
- Configure tool-specific settings (FZF preview with bat, etc.)
- Set up aliases for seamless replacement of legacy tools

**Technical Notes**:
- Install via Nix packages in darwin/configuration.nix:
  ```nix
  environment.systemPackages = with pkgs; [
    ripgrep      # Fast grep replacement
    bat          # cat with syntax highlighting
    fd           # Modern find replacement
    eza          # Modern ls replacement (exa successor)
    zoxide       # Smart directory jumper
    httpie       # User-friendly HTTP client
    tealdeer     # tldr client (Rust implementation)
  ];
  ```

- Configure tool defaults in home-manager/modules/aliases.nix:
  ```nix
  programs.zsh = {
    shellAliases = {
      # Modern tool aliases
      grep = "rg";
      cat = "bat --paging=never";
      less = "bat";
      find = "fd";
      ls = "eza --icons";
      ll = "eza -lah --icons --git";
      lt = "eza --tree --level=2 --icons";
      la = "eza -a --icons";
      http = "http --style=monokai";
      help = "tldr";

      # Keep originals accessible
      oldgrep = "\\grep";
      oldcat = "\\cat";
      oldfind = "\\find";
      oldls = "\\ls";
    };

    initExtra = ''
      # Zoxide initialization (replaces z plugin)
      eval "$(zoxide init zsh)"
      alias cd='z'  # Make z the default cd

      # FZF integration with bat preview
      export FZF_DEFAULT_OPTS="
        --height 40%
        --layout=reverse
        --border
        --inline-info
        --preview 'bat --style=numbers --color=always --line-range :500 {}'
      "

      # Use fd for FZF file search
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

      # Bat theme (Catppuccin via Stylix)
      export BAT_THEME="Catppuccin-mocha"
    '';
  };
  ```

- Performance comparison (from article):
  - `rg` is 15x faster than `grep` on large codebases
  - `fd` is significantly faster than `find`
  - `bat` adds minimal overhead for syntax highlighting

- Test workflow:
  ```bash
  # Test ripgrep
  rg "TODO" --type nix

  # Test bat
  bat bootstrap.sh

  # Test fd
  fd "\.nix$"

  # Test eza
  eza -lah --git
  eza --tree --level=2

  # Test zoxide (after visiting directories)
  z nix-install

  # Test httpie
  http https://api.github.com/users/octocat

  # Test tldr
  tldr tar
  tldr git
  ```

- Note: Remove `z` plugin from Oh My Zsh in Story 04.1-002 (zoxide replaces it)

**Definition of Done**:
- [ ] All 7 modern CLI tools installed via Nix
- [ ] Tool aliases configured in home-manager
- [ ] ripgrep works and respects .gitignore
- [ ] bat shows syntax highlighting
- [ ] fd finds files with intuitive syntax
- [ ] eza shows file lists with git status and icons
- [ ] zoxide directory jumping works
- [ ] httpie makes readable HTTP requests
- [ ] tldr shows practical examples
- [ ] FZF preview uses bat for syntax highlighting
- [ ] BAT_THEME set to Catppuccin
- [ ] Legacy tool originals accessible via old* aliases
- [ ] All tools work in fresh terminal
- [ ] Tested in VM with real-world usage scenarios
- [ ] Story 04.1-002 updated to remove z plugin

**Dependencies**:
- Story 04.1-001 (Zsh configured)
- Story 04.1-002 (Oh My Zsh configured, needs update to remove z plugin)
- Story 04.3-001 (FZF installed for preview integration)
- Epic-05, Story 05.1-001 (Stylix for Catppuccin theme)

**Cross-Story Impact**:
- **Story 04.1-002**: Remove `z` plugin from Oh My Zsh plugins list, add note that zoxide replaces it
- **Story 04.3-001**: FZF preview window will use bat (configured here)
- **Story 04.5-002**: Basic aliases remain for backwards compatibility

**Risk Level**: Medium
**Risk Mitigation**:
- Keep legacy tools accessible via `old*` aliases in case modern tools have issues
- Test each tool individually to ensure Nix packages are available and functional
- Verify tool performance on large codebases in VM testing
- Document tool-specific options and configuration for user customization

**Reference**:
- Article: "My Favorite 8 CLI Tools for Everyday Development (2025 Edition)" by Bhavyansh
- URL: https://medium.com/@bhavyansh001/my-favorite-8-cli-tools-for-everyday-development-2025-edition-12340fad4b67
- Tools save an estimated 30-60 minutes daily through faster workflows and better defaults
- Local copy: `/Users/fxmartin/Documents/My Favorite 8 CLI Tools for Everyday Development (2025 Edition) | by Bhavyansh | Nov, 2025 | Medium.pdf`

---

