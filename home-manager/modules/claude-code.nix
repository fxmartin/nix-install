# ABOUTME: Claude Code CLI configuration with MCP servers (Context7, Playwright, Sequential Thinking)
# ABOUTME: Includes Get Shit Done (GSD) meta-prompting system installation
# ABOUTME: Symlinks ~/.claude/ directory to repo for bidirectional sync (REQ-NFR-008 compliant)
# ABOUTME: Writes MCP config to BOTH ~/.config/claude/config.json (Desktop) AND ~/.claude.json (CLI)
{
  config,
  pkgs,
  lib,
  userConfig,
  mcp-servers-nix,
  ...
}: let
  # Generate MCP server configuration using mcp-servers-nix.lib.mkConfig
  # This automatically handles package paths and server configuration
  mcpConfig = mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      # Context7 MCP server - No authentication required
      context7 = {
        enable = true;
      };

      # Sequential Thinking MCP server - No authentication required
      # FIXME: Temporarily disabled due to upstream build failure
      # Fix pending in PR #276 (Node.js 22 pinning): https://github.com/natsukium/mcp-servers-nix/pull/276
      # Error: Cannot find name 'process' - missing @types/node in build
      sequential-thinking = {
        enable = false;
      };

      # Playwright MCP server - Browser automation for web testing and scraping
      # No authentication required
      playwright = {
        enable = true;
      };
    };
  };

  # jq is needed for JSON manipulation in the activation script
  jq = pkgs.jq;
in {
  # Claude Code CLI and MCP Servers Configuration
  # Story 02.2-006: Install Claude Code CLI with Context7 and Sequential Thinking MCP servers
  #
  # Installation:
  # - Claude Code CLI: Via Nix (claude-code-nix flake input, installed in darwin/configuration.nix)
  # - MCP Servers: Via mcp-servers-nix.lib.mkConfig (generates config with automatic package handling)
  # - No Node.js or npm dependencies required
  #
  # Why this approach (REQ-NFR-008 compliant):
  # - Claude Code expects to manage config files in ~/.claude/ directory
  # - User customizations (agents, commands) should be version controlled
  # - Home Manager's default approach creates read-only /nix/store symlinks
  # - Solution: Symlink ~/.claude/ files to repository working directory
  # - Same pattern as Zed (Story 02.2-001), VSCode (Story 02.2-002), Ghostty (Story 02.2-003)
  #
  # How it works:
  # 1. Repository structure:
  #    - config/claude/CLAUDE.md: User instructions for Claude Code
  #    - config/claude/agents/: Custom agent definitions
  #    - config/claude/commands/: Custom slash commands
  # 2. Activation script dynamically finds repo location
  #    - Searches: ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install
  #    - Works with any NIX_INSTALL_DIR from bootstrap
  # 3. Creates symlinks:
  #    - ~/.claude/CLAUDE.md → $REPO/config/claude/CLAUDE.md
  #    - ~/.claude/agents/ → $REPO/config/claude/agents/
  #    - ~/.claude/commands/ → $REPO/config/claude/commands/
  # 4. Creates MCP configs for BOTH Claude Desktop AND Claude Code CLI:
  #    - ~/.config/claude/config.json → Claude Desktop (full mcpServers object)
  #    - ~/.claude.json → Claude Code CLI (merges mcpServers into existing config)
  # 5. Bidirectional sync:
  #    - Changes in repo (git pull) → Instantly apply to Claude Code
  #    - Custom agents/commands version controlled
  #    - Can commit/revert customizations
  #
  # MCP Servers Configuration:
  # - Context7: No authentication required
  # - Sequential Thinking: No authentication required (currently disabled)
  # - Playwright: No authentication required - browser automation
  #
  # All MCP servers use Nix-installed binaries (managed by mkConfig, not npx/npm)

  # Activation script to set up Claude Code configuration and symlink files to repo
  home.activation.claudeCodeSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Dynamically find repo location (works with any NIX_INSTALL_DIR)
    # Search for nix-install repo by looking for flake.nix + config/claude directory
    # Priority: ~/.config/nix-install (new default) > ~/nix-install > ~/Documents/nix-install (legacy)
    REPO_ROOT=""
    for candidate in "${config.home.homeDirectory}/.config/nix-install" \
                     "${config.home.homeDirectory}/nix-install" \
                     "${config.home.homeDirectory}/Documents/nix-install"; do
      if [ -f "$candidate/flake.nix" ] && [ -d "$candidate/config/claude" ]; then
        REPO_ROOT="$candidate"
        break
      fi
    done

    # Create ~/.claude directory
    CLAUDE_DIR="${config.home.homeDirectory}/.claude"
    if [ ! -d "$CLAUDE_DIR" ]; then
      $DRY_RUN_CMD mkdir -p "$CLAUDE_DIR"
      echo "Created Claude Code directory: $CLAUDE_DIR"
    fi

    # If repo found, symlink CLAUDE.md, agents/, and commands/ to repository
    if [ -n "$REPO_ROOT" ]; then
      # Symlink CLAUDE.md (REQ-NFR-008 compliant)
      CLAUDE_MD_REPO="$REPO_ROOT/config/claude/CLAUDE.md"
      CLAUDE_MD_HOME="$CLAUDE_DIR/CLAUDE.md"

      if [ -f "$CLAUDE_MD_REPO" ]; then
        # Back up existing file if it's not a symlink
        if [ -f "$CLAUDE_MD_HOME" ] && [ ! -L "$CLAUDE_MD_HOME" ]; then
          $DRY_RUN_CMD mv "$CLAUDE_MD_HOME" "$CLAUDE_MD_HOME.backup"
          echo "Backed up existing CLAUDE.md to: $CLAUDE_MD_HOME.backup"
        fi

        $DRY_RUN_CMD ln -sf "$CLAUDE_MD_REPO" "$CLAUDE_MD_HOME"
        echo "✓ Linked ~/.claude/CLAUDE.md → $REPO_ROOT/config/claude/CLAUDE.md"
      else
        echo "⚠️  Warning: $CLAUDE_MD_REPO not found"
      fi

      # Symlink agents directory
      AGENTS_REPO="$REPO_ROOT/config/claude/agents"
      AGENTS_HOME="$CLAUDE_DIR/agents"

      if [ -d "$AGENTS_REPO" ]; then
        # Back up existing directory if it's not a symlink
        if [ -d "$AGENTS_HOME" ] && [ ! -L "$AGENTS_HOME" ]; then
          $DRY_RUN_CMD mv "$AGENTS_HOME" "$AGENTS_HOME.backup"
          echo "Backed up existing agents/ to: $AGENTS_HOME.backup"
        fi

        $DRY_RUN_CMD ln -sfn "$AGENTS_REPO" "$AGENTS_HOME"
        echo "✓ Linked ~/.claude/agents/ → $REPO_ROOT/config/claude/agents/"
      else
        echo "⚠️  Warning: $AGENTS_REPO directory not found"
      fi

      # Symlink commands directory
      COMMANDS_REPO="$REPO_ROOT/config/claude/commands"
      COMMANDS_HOME="$CLAUDE_DIR/commands"

      if [ -d "$COMMANDS_REPO" ]; then
        # Back up existing directory if it's not a symlink
        if [ -d "$COMMANDS_HOME" ] && [ ! -L "$COMMANDS_HOME" ]; then
          $DRY_RUN_CMD mv "$COMMANDS_HOME" "$COMMANDS_HOME.backup"
          echo "Backed up existing commands/ to: $COMMANDS_HOME.backup"
        fi

        $DRY_RUN_CMD ln -sfn "$COMMANDS_REPO" "$COMMANDS_HOME"
        echo "✓ Linked ~/.claude/commands/ → $REPO_ROOT/config/claude/commands/"
      else
        echo "⚠️  Warning: $COMMANDS_REPO directory not found"
      fi
    else
      echo "⚠️  Warning: Could not find nix-install repository"
      echo "  Searched: ~/nix-install, ~/.config/nix-install, ~/Documents/nix-install"
      echo "  Claude Code configuration will not be linked to repository"
    fi

    # Create ~/.config/claude directory for MCP config (Claude Desktop)
    CLAUDE_CONFIG_DIR="${config.home.homeDirectory}/.config/claude"
    if [ ! -d "$CLAUDE_CONFIG_DIR" ]; then
      $DRY_RUN_CMD mkdir -p "$CLAUDE_CONFIG_DIR"
      echo "Created Claude Desktop MCP config directory: $CLAUDE_CONFIG_DIR"
    fi

    # Always ensure proper ownership of config directory (fixes issues from failed runs)
    # This directory can end up root-owned if darwin-rebuild fails partway through
    if [ -d "$CLAUDE_CONFIG_DIR" ]; then
      CURRENT_OWNER=$(stat -f '%u' "$CLAUDE_CONFIG_DIR" 2>/dev/null || echo "unknown")
      if [ "$CURRENT_OWNER" != "$(id -u)" ]; then
        echo "Fixing ownership of $CLAUDE_CONFIG_DIR (owned by uid $CURRENT_OWNER, should be $(id -u))"
        $DRY_RUN_CMD sudo chown -R "$(id -u):$(id -g)" "$CLAUDE_CONFIG_DIR" 2>/dev/null || true
      fi
    fi

    # ============================================================
    # MCP Configuration for Claude Desktop
    # ============================================================
    # Claude Desktop reads MCP servers from ~/.config/claude/config.json
    CLAUDE_DESKTOP_CONFIG="$CLAUDE_CONFIG_DIR/config.json"

    # Remove existing file if we can't write to it (handles root-owned files)
    if [ -f "$CLAUDE_DESKTOP_CONFIG" ] && ! [ -w "$CLAUDE_DESKTOP_CONFIG" ]; then
      echo "Removing unwritable config file: $CLAUDE_DESKTOP_CONFIG"
      $DRY_RUN_CMD sudo rm -f "$CLAUDE_DESKTOP_CONFIG" 2>/dev/null || true
    fi

    $DRY_RUN_CMD cp "${mcpConfig}" "$CLAUDE_DESKTOP_CONFIG"
    echo "✓ Updated Claude Desktop MCP config: $CLAUDE_DESKTOP_CONFIG"

    # ============================================================
    # MCP Configuration for Claude Code CLI
    # ============================================================
    # Claude Code CLI reads MCP servers from ~/.claude.json (mcpServers key)
    # We need to merge our MCP servers into the existing config without
    # destroying other settings (numStartups, projects, etc.)
    CLAUDE_CLI_CONFIG="${config.home.homeDirectory}/.claude.json"
    NIX_MCP_CONFIG="${mcpConfig}"

    if [ -f "$CLAUDE_CLI_CONFIG" ]; then
      # Extract mcpServers from the Nix-generated config and merge into existing ~/.claude.json
      # The Nix config has format: {"mcpServers": {...}}
      # We need to merge that into the existing ~/.claude.json's mcpServers key
      $DRY_RUN_CMD ${jq}/bin/jq -s '
        # $existing is .[0] (current ~/.claude.json)
        # $new is .[1] (Nix-generated config with mcpServers)
        .[0] as $existing |
        .[1].mcpServers as $newServers |
        # Merge: existing config + new mcpServers (new servers override existing ones with same name)
        $existing * {mcpServers: (($existing.mcpServers // {}) * $newServers)}
      ' "$CLAUDE_CLI_CONFIG" "$NIX_MCP_CONFIG" > "$CLAUDE_CLI_CONFIG.tmp" \
        && $DRY_RUN_CMD mv "$CLAUDE_CLI_CONFIG.tmp" "$CLAUDE_CLI_CONFIG"
      echo "✓ Merged MCP servers into Claude Code CLI config: $CLAUDE_CLI_CONFIG"
    else
      # No existing config - create new one with just mcpServers
      # Extract mcpServers and create a minimal config
      $DRY_RUN_CMD ${jq}/bin/jq '{mcpServers: .mcpServers}' "$NIX_MCP_CONFIG" > "$CLAUDE_CLI_CONFIG"
      echo "✓ Created Claude Code CLI config: $CLAUDE_CLI_CONFIG"
    fi

    echo ""
    echo "✓ Claude Code CLI and MCP servers configured successfully"
    echo "  - Claude Code CLI: $(command -v claude || echo 'not found in PATH')"
    echo "  - Claude Desktop config: $CLAUDE_DESKTOP_CONFIG"
    echo "  - Claude Code CLI config: $CLAUDE_CLI_CONFIG"
    echo ""
    echo "To verify MCP servers: claude mcp list"

    # Install Get Shit Done (GSD) - meta-prompting system for Claude Code
    # https://github.com/glittercowboy/get-shit-done
    # Only install if not already present (idempotent)
    GSD_COMMANDS_DIR="$CLAUDE_DIR/commands/gsd"
    if [ ! -d "$GSD_COMMANDS_DIR" ]; then
      echo ""
      echo "Installing Get Shit Done (GSD) for Claude Code..."
      if command -v npx &> /dev/null; then
        # Use --global flag for non-interactive install to ~/.claude/
        $DRY_RUN_CMD ${pkgs.nodejs}/bin/npx get-shit-done-cc --global 2>&1 || {
          echo "⚠️  GSD installation failed - you can install manually with: npx get-shit-done-cc"
        }
        if [ -d "$GSD_COMMANDS_DIR" ]; then
          echo "✓ Get Shit Done (GSD) installed successfully"
          echo "  - Commands: $GSD_COMMANDS_DIR"
          echo "  - Usage: /gsd:help in Claude Code"
        fi
      else
        echo "⚠️  npx not found - skipping GSD installation"
        echo "  Install manually with: npx get-shit-done-cc"
      fi
    else
      echo "✓ Get Shit Done (GSD) already installed: $GSD_COMMANDS_DIR"
    fi
  '';

  # No additional packages needed - Claude Code CLI installed via darwin/configuration.nix
  # MCP servers are handled by mkConfig (automatically references Nix packages)
  home.packages = [];
}
