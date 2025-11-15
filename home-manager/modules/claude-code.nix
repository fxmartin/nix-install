# ABOUTME: Claude Code CLI configuration with MCP servers (Context7, GitHub, Sequential Thinking)
# ABOUTME: Symlinks ~/.claude/ directory to repo for bidirectional sync (REQ-NFR-008 compliant)
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

      # GitHub MCP server - Requires GITHUB_TOKEN via envFile
      github = {
        enable = true;
        # Use envFile instead of hardcoding token (security best practice)
        # User will create ~/.config/claude/github-token.env with: GITHUB_TOKEN=ghp_xxx
        envFile = "${config.home.homeDirectory}/.config/claude/github-token.env";
      };

      # Sequential Thinking MCP server - No authentication required
      sequential-thinking = {
        enable = true;
      };
    };
  };
in {
  # Claude Code CLI and MCP Servers Configuration
  # Story 02.2-006: Install Claude Code CLI with Context7, GitHub, and Sequential Thinking MCP servers
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
  # 4. Creates ~/.config/claude/config.json → Nix-generated MCP config
  # 5. Bidirectional sync:
  #    - Changes in repo (git pull) → Instantly apply to Claude Code
  #    - Custom agents/commands version controlled
  #    - Can commit/revert customizations
  #
  # MCP Servers Configuration:
  # - Context7: No authentication required
  # - GitHub: Requires GITHUB_TOKEN via envFile (user must create ~/.config/claude/github-token.env)
  # - Sequential Thinking: No authentication required
  #
  # All MCP servers use Nix-installed binaries (managed by mkConfig, not npx/npm)

  # Activation script to set up Claude Code configuration and symlink files to repo
  home.activation.claudeCodeSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Dynamically find repo location (works with any NIX_INSTALL_DIR)
    # Search for nix-install repo by looking for flake.nix + config/claude directory
    REPO_ROOT=""
    for candidate in "${config.home.homeDirectory}/nix-install" \
                     "${config.home.homeDirectory}/.config/nix-install" \
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

    # Create ~/.config/claude directory for MCP config
    CLAUDE_CONFIG_DIR="${config.home.homeDirectory}/.config/claude"
    if [ ! -d "$CLAUDE_CONFIG_DIR" ]; then
      $DRY_RUN_CMD mkdir -p "$CLAUDE_CONFIG_DIR"
      echo "Created Claude Code MCP config directory: $CLAUDE_CONFIG_DIR"
    fi

    # Symlink MCP configuration generated by mcp-servers-nix.lib.mkConfig
    CLAUDE_CONFIG_JSON="$CLAUDE_CONFIG_DIR/config.json"

    # Back up existing config if not a symlink (preserve user customizations)
    if [ -f "$CLAUDE_CONFIG_JSON" ] && [ ! -L "$CLAUDE_CONFIG_JSON" ]; then
      $DRY_RUN_CMD mv "$CLAUDE_CONFIG_JSON" "$CLAUDE_CONFIG_JSON.backup"
      echo "Backed up existing config.json to: $CLAUDE_CONFIG_JSON.backup"
    fi

    # Create symlink to Nix-generated MCP configuration
    $DRY_RUN_CMD ln -sf "${mcpConfig}" "$CLAUDE_CONFIG_JSON"
    echo "✓ Linked Claude Code MCP config to Nix-generated configuration"

    # Create GitHub token envFile template if it doesn't exist
    GITHUB_TOKEN_FILE="$CLAUDE_CONFIG_DIR/github-token.env"
    if [ ! -f "$GITHUB_TOKEN_FILE" ]; then
      $DRY_RUN_CMD cat > "$GITHUB_TOKEN_FILE" <<'EOF'
# GitHub Personal Access Token for Claude Code MCP Server
# Replace the placeholder below with your actual GitHub token
#
# To create a token:
# 1. Visit: https://github.com/settings/tokens
# 2. Click "Generate new token" → "Generate new token (classic)"
# 3. Name: "Claude Code MCP Server"
# 4. Scopes: ✓ repo, ✓ read:org, ✓ read:user
# 5. Click "Generate token" and copy it
#
# Then replace REPLACE_WITH_YOUR_TOKEN below:
GITHUB_TOKEN=REPLACE_WITH_YOUR_TOKEN
EOF

      echo "✓ Created GitHub token template: $GITHUB_TOKEN_FILE"
      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "📝 IMPORTANT: Configure GitHub MCP Server"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
      echo "1. Create GitHub Personal Access Token:"
      echo "   → Visit: https://github.com/settings/tokens"
      echo "   → Click 'Generate new token' → 'Generate new token (classic)'"
      echo "   → Name: 'Claude Code MCP Server'"
      echo "   → Scopes: ✓ repo, ✓ read:org, ✓ read:user"
      echo "   → Click 'Generate token' and copy the token"
      echo ""
      echo "2. Add token to envFile:"
      echo "   → Edit: $GITHUB_TOKEN_FILE"
      echo "   → Replace 'REPLACE_WITH_YOUR_TOKEN' with your token"
      echo "   → Save the file"
      echo ""
      echo "3. Verify MCP servers:"
      echo "   → Run: claude mcp list"
      echo "   → All three servers should be enabled"
      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
    else
      echo "✓ GitHub token envFile already exists: $GITHUB_TOKEN_FILE"
    fi

    echo ""
    echo "✓ Claude Code CLI and MCP servers configured successfully"
    echo "  - Claude Code CLI: $(command -v claude || echo 'not found in PATH')"
    echo "  - MCP Config: $CLAUDE_CONFIG_JSON → ${mcpConfig}"
    echo "  - GitHub Token: $GITHUB_TOKEN_FILE"
  '';

  # No additional packages needed - Claude Code CLI installed via darwin/configuration.nix
  # MCP servers are handled by mkConfig (automatically references Nix packages)
  home.packages = [];
}
