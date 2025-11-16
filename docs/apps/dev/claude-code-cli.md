# ABOUTME: Claude Code CLI post-installation configuration guide
# ABOUTME: Covers CLI setup, project configuration, multi-agent workflows, and integration with development tools

### Claude Code CLI with MCP Servers (Context7, GitHub, Sequential Thinking)

**Status**: Installed via Nix (Story 02.2-006)
- Claude Code CLI: `claude-code-nix` flake input
- MCP Servers: `mcp-servers-nix` flake input (Context7, GitHub, Sequential Thinking)
- All packages installed to `darwin/configuration.nix` systemPackages
- Configuration managed by Home Manager (`home-manager/modules/claude-code.nix`)
- **REQ-NFR-008 Compliant**: Bidirectional sync via repository symlinks

**Purpose**: AI-assisted development with Claude Code CLI and Model Context Protocol (MCP) servers for enhanced context awareness, repository integration, and structured reasoning capabilities.

**What is MCP?**:
Model Context Protocol (MCP) allows Claude Code to access external data sources and tools:
- **Context7 MCP**: Provides enhanced context awareness across your development environment
- **GitHub MCP**: Integrates with GitHub repositories for code search, PR reviews, and issue tracking
- **Sequential Thinking MCP**: Enables structured, step-by-step reasoning for complex problems

#### Installation Details

**Packages Installed**:
- `claude` (Claude Code CLI) - AI-assisted development tool
- `mcp-server-context7` - Context awareness server
- `mcp-server-github` - GitHub integration server
- `mcp-server-sequential-thinking` - Structured reasoning server

**All packages installed via Nix** (no Node.js or npm dependencies):
```bash
# Verify installations
claude --version
mcp-server-context7 --version
mcp-server-github --version
mcp-server-sequential-thinking --version
```

**Configuration Files** (REQ-NFR-008 compliant bidirectional sync):
- `~/.claude/CLAUDE.md` → symlinked to `$REPO/config/claude/CLAUDE.md`
- `~/.claude/agents/` → symlinked to `$REPO/config/claude/agents/`
- `~/.claude/commands/` → symlinked to `$REPO/config/claude/commands/`
- `~/.config/claude/config.json` → MCP server configuration (created by Home Manager)

Changes in repository instantly appear in Claude Code (bidirectional sync).

#### Required Post-Install Configuration

**CRITICAL**: GitHub MCP server requires a GitHub Personal Access Token.

**Step 1: Create GitHub Personal Access Token**

1. Visit https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Token settings:
   - **Name**: `Claude Code MCP Server`
   - **Expiration**: Choose expiration (90 days recommended)
   - **Scopes** (check these boxes):
     - ✅ `repo` (Full control of private repositories)
     - ✅ `read:org` (Read org and team membership)
     - ✅ `read:user` (Read user profile data)
4. Click **"Generate token"**
5. **Copy the token immediately** (you won't see it again!)

**Step 2: Add Token to Claude Code Configuration**

Edit the MCP configuration file:
```bash
# Open config file in your editor
code ~/.config/claude/config.json
# or
zed ~/.config/claude/config.json
```

Replace `REPLACE_WITH_YOUR_GITHUB_TOKEN` with your actual token:
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
        "GITHUB_TOKEN": "ghp_YourActualTokenHere123456789"
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

Save the file.

**Step 3: Verify MCP Servers**

```bash
# List configured MCP servers
claude mcp list

# Expected output:
# ✓ context7 (enabled)
# ✓ github (enabled)
# ✓ sequential-thinking (enabled)
```

#### Usage Examples

**Starting Claude Code CLI**:
```bash
# Start interactive session
claude

# Start with specific file context
claude README.md

# Start with directory context
claude src/
```

**Example Queries with MCP Servers**:

**Context7 MCP** (Enhanced context awareness):
```bash
claude
> What are the main components of this project?
> Analyze the architecture of the codebase
> Find all API endpoints in the project
```

**GitHub MCP** (Repository integration):
```bash
claude
> Show me open pull requests in this repository
> What issues are labeled as "bug"?
> Search for implementations of authentication in organization repos
> Summarize recent commits to main branch
```

**Sequential Thinking MCP** (Structured reasoning):
```bash
claude
> Let's think step-by-step about how to implement user authentication
> Break down the problem of optimizing database queries
> Analyze this code and reason through potential bugs
```

**Combined MCP Usage**:
```bash
claude
> Using GitHub MCP, find similar authentication implementations,
  then use Sequential Thinking to design our implementation step-by-step
```

#### Configuration Customization

**Custom Agents** (repository-synced):
Create custom agent definitions in `config/claude/agents/`:
```bash
# Agents are version controlled in repo
ls -la config/claude/agents/

# Changes sync automatically to ~/.claude/agents/
```

**Custom Commands** (repository-synced):
Create slash commands in `config/claude/commands/`:
```bash
# Commands are version controlled in repo
ls -la config/claude/commands/

# Changes sync automatically to ~/.claude/commands/
```

**CLAUDE.md** (repository-synced):
Global instructions for Claude Code in `config/claude/CLAUDE.md`:
```bash
# Edit in repo
code config/claude/CLAUDE.md

# Changes instantly visible to Claude Code via symlink
```

#### Verification

**Check Claude Code Installation**:
```bash
claude --version
# Expected: Claude Code CLI version X.X.X
```

**Check MCP Server Installations**:
```bash
which mcp-server-context7
which mcp-server-github
which mcp-server-sequential-thinking

# All should show /nix/store/... paths
```

**Verify Configuration Symlinks** (REQ-NFR-008):
```bash
ls -la ~/.claude/
# Should show:
# lrwxr-xr-x CLAUDE.md -> /path/to/nix-install/config/claude/CLAUDE.md
# lrwxr-xr-x agents -> /path/to/nix-install/config/claude/agents/
# lrwxr-xr-x commands -> /path/to/nix-install/config/claude/commands/
```

**Verify MCP Config Created**:
```bash
cat ~/.config/claude/config.json
# Should show JSON with three MCP servers configured
```

**Test MCP Servers**:
```bash
# Test Context7 MCP
mcp-server-context7 --version

# Test GitHub MCP (requires token configured)
# Will be tested when running claude CLI

# Test Sequential Thinking MCP
mcp-server-sequential-thinking --version
```

#### Troubleshooting

**Issue**: `claude: command not found`
**Solution**:
```bash
# Verify Nix package installed
nix-env -q | grep claude
# If not found, rebuild
darwin-rebuild switch --flake ~/nix-install#standard  # or #power

# Check PATH includes Nix
echo $PATH | grep nix
# Should include /nix/var/nix/profiles/default/bin or similar
```

**Issue**: GitHub MCP server not working
**Solution**:
1. Verify token configured: `cat ~/.config/claude/config.json | grep GITHUB_TOKEN`
2. Check token not placeholder: Should be `ghp_...`, not `REPLACE_WITH_YOUR_GITHUB_TOKEN`
3. Verify token scopes at https://github.com/settings/tokens
4. Test token: `curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user`
5. Restart Claude Code session after token update

**Issue**: MCP servers show as disabled
**Solution**:
```bash
# Edit config.json and ensure "enabled": true for all servers
code ~/.config/claude/config.json

# Check for syntax errors
cat ~/.config/claude/config.json | jq .
# Should parse successfully without errors
```

**Issue**: Configuration changes not appearing in Claude Code
**Solution**:
```bash
# Verify symlinks are correct
ls -la ~/.claude/

# If symlinks broken, rebuild
darwin-rebuild switch --flake ~/nix-install#standard  # or #power

# Symlinks should point to working directory, NOT /nix/store/
# Correct: ~/.claude/CLAUDE.md -> /Users/fx/nix-install/config/claude/CLAUDE.md
# Wrong: ~/.claude/CLAUDE.md -> /nix/store/.../CLAUDE.md
```

**Issue**: Want to update MCP server configuration
**Solution**:
```bash
# Edit config.json directly (NOT managed by Nix)
code ~/.config/claude/config.json

# Add new MCP server, change settings, etc.
# File is NOT overwritten by darwin-rebuild (preserves user customizations)
```

#### Security Considerations

**GitHub Token Storage**:
- Token stored in `~/.config/claude/config.json` (plain text)
- File has user-only permissions (600)
- **DO NOT** commit config.json to public repositories
- Consider using environment variables for shared configurations:
  ```json
  "env": {
    "GITHUB_TOKEN": "${GITHUB_TOKEN}"
  }
  ```
  Then export in shell: `export GITHUB_TOKEN=ghp_...`

**Token Rotation**:
- Rotate tokens every 90 days (set expiration when creating)
- Revoke old tokens at https://github.com/settings/tokens
- Update config.json with new token

**Least Privilege**:
- Only grant scopes needed: `repo`, `read:org`, `read:user`
- Don't grant `admin:org`, `delete_repo`, or other destructive scopes

#### Update Philosophy

- ✅ Claude Code CLI updated via Nix flake (`update` command updates flake.lock)
- ✅ MCP servers updated via Nix flake (same flake.lock update)
- ✅ All versions reproducible via flake.lock
- ⚠️ Do NOT use `npm install` or `npx` for MCP servers (Nix manages them)
- ✅ Updates ONLY via darwin-rebuild (Nix-managed packages)

**Update Process**:
```bash
# Update flake.lock (gets latest versions)
cd ~/nix-install
nix flake update

# Rebuild with new versions
darwin-rebuild switch --flake ~/nix-install#standard  # or #power

# Verify new versions
claude --version
mcp-server-context7 --version
mcp-server-github --version
mcp-server-sequential-thinking --version
```

#### Testing Checklist

- [ ] Claude Code CLI installed and `claude --version` works
- [ ] All three MCP server binaries installed and on PATH
- [ ] `~/.claude/CLAUDE.md` symlinked to repository (bidirectional sync)
- [ ] `~/.claude/agents/` symlinked to repository
- [ ] `~/.claude/commands/` symlinked to repository
- [ ] `~/.config/claude/config.json` created with three MCP servers
- [ ] GitHub Personal Access Token created with correct scopes
- [ ] Token added to config.json (replaces placeholder)
- [ ] `claude mcp list` shows all three servers as enabled
- [ ] Can start Claude Code CLI with `claude` command
- [ ] Context7 MCP responds to context queries
- [ ] GitHub MCP can query repositories (token configured)
- [ ] Sequential Thinking MCP enables structured reasoning
- [ ] Configuration changes in repo appear in `~/.claude/` (bidirectional sync)
- [ ] Symlinks point to working directory, NOT /nix/store

#### Resources

- Claude Code CLI: https://github.com/anthropics/claude-code
- MCP Specification: https://modelcontextprotocol.io/
- Context7 MCP: https://github.com/natsukium/mcp-servers-nix (community maintained)
- GitHub MCP: https://github.com/natsukium/mcp-servers-nix (community maintained)
- Sequential Thinking MCP: https://github.com/natsukium/mcp-servers-nix (community maintained)
- GitHub Token Management: https://github.com/settings/tokens

---

## Browsers


---

## Related Documentation

- [Main Apps Index](../README.md)
- [Zed Editor Configuration](./zed-editor.md)
- [VS Code Configuration](./vscode.md)
- [Podman Configuration](./podman.md)
- [Python Tools Configuration](./python-tools.md)
