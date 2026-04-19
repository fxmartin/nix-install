# ABOUTME: Claude Code CLI post-installation configuration guide
# ABOUTME: Covers CLI setup, MCP servers, and integration with development tools

### Claude Code CLI with MCP Servers

**Status**: Installed via Nix (Story 02.2-006)
- Claude Code CLI: `claude-code-nix` flake input
- MCP Servers: `mcp-servers-nix` flake input (Context7, Playwright, Sequential Thinking)
- All packages installed to `darwin/configuration.nix` systemPackages
- Configuration managed by Home Manager (`home-manager/modules/claude-code.nix`)
- **REQ-NFR-008 Compliant**: Bidirectional sync via repository symlinks

**Purpose**: AI-assisted development with Claude Code CLI and Model Context Protocol (MCP) servers for enhanced context awareness, browser automation, and structured reasoning capabilities.

**What is MCP?**:
Model Context Protocol (MCP) allows Claude Code to access external data sources and tools:
- **Context7 MCP**: Provides library documentation and code examples lookup
- **Playwright MCP**: Browser automation for web testing, scraping, and UI interaction
- **Sequential Thinking MCP**: Enables structured, step-by-step reasoning for complex problems
  - ⚠️ **Currently disabled** due to upstream build issue; fix pending in [PR #276](https://github.com/natsukium/mcp-servers-nix/pull/276) (Node.js 22 pinning)

#### Installation Details

**Packages Installed**:
- `claude` (Claude Code CLI) - AI-assisted development tool
- `mcp-server-context7` - Library documentation server
- `mcp-server-playwright` - Browser automation server
- `mcp-server-sequential-thinking` - Structured reasoning server

**All packages installed via Nix** (no Node.js or npm dependencies):
```bash
# Verify installations
claude --version
claude mcp list
```

**Configuration Files** (REQ-NFR-008 compliant bidirectional sync):

Config lives in the `claude-code-config` git submodule at `config/claude-code-config/`.
This submodule is also a standalone repo (`github.com/fxmartin/claude-code-config`) with
a portable `install.sh` for non-Nix machines.

- `~/.claude/CLAUDE.md` → symlinked to `$REPO/config/claude-code-config/CLAUDE.md`
- `~/.claude/agents/` → symlinked to `$REPO/config/claude-code-config/agents/`
- `~/.claude/commands/` → symlinked to `$REPO/config/claude-code-config/commands/`
- `~/.claude/settings.json` → symlinked to `$REPO/config/claude-code-config/settings.json`
- `~/.claude/statusline-command.sh` → symlinked to `$REPO/config/claude-code-config/statusline-command.sh`
- `~/.claude/keybindings.json` → symlinked to `$REPO/config/claude-code-config/keybindings.json`
- `~/.claude/docs/` → symlinked to `$REPO/config/claude-code-config/docs/`
- `~/.claude/hooks/` → symlinked to `$REPO/config/claude-code-config/hooks/`

**MCP Server Configuration** (dual-location for Claude Desktop AND Claude Code CLI):
- `~/.config/claude/config.json` → Claude Desktop MCP config
- `~/.claude.json` → Claude Code CLI MCP config (merged into existing settings)

> **Important**: Claude Desktop and Claude Code CLI read MCP servers from **different locations**.
> The nix-darwin activation script writes to both locations to ensure MCP servers work everywhere.

Changes in repository instantly appear in Claude Code (bidirectional sync).

#### Post-Install Verification

**No manual configuration required!** All MCP servers are automatically configured by nix-darwin.

**Verify MCP Servers**:
```bash
# List configured MCP servers
claude mcp list

# Expected output:
# context7: ... - ✓ Connected
# playwright: ... - ✓ Connected
# sequential-thinking: ... - ✓ Connected (currently disabled, pending PR #276)
```

**Check Configuration Files**:
```bash
# Claude Desktop config
cat ~/.config/claude/config.json | jq .

# Claude Code CLI config (mcpServers key)
cat ~/.claude.json | jq '.mcpServers'
```

Both should show context7, playwright, and any other enabled MCP servers.

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

**Context7 MCP** (Library documentation lookup):
```bash
claude
> Look up the React hooks documentation
> Show me examples of using FastAPI with SQLAlchemy
> What's the latest Next.js routing API?
```

**Playwright MCP** (Browser automation):
```bash
claude
> Navigate to https://example.com and take a screenshot
> Fill out the login form and submit it
> Scrape the product list from this e-commerce page
> Test the checkout flow end-to-end
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
> Use Context7 to look up the Playwright testing patterns,
  then use Sequential Thinking to design our test strategy step-by-step
```

#### Configuration Customization

**Custom Agents** (repository-synced):
Create custom agent definitions in `config/claude-code-config/agents/`:
```bash
# Agents are version controlled in repo
ls -la config/claude-code-config/agents/

# Changes sync automatically to ~/.claude/agents/
```

**Custom Commands** (repository-synced):
Create slash commands in `config/claude-code-config/commands/`:
```bash
# Commands are version controlled in repo
ls -la config/claude-code-config/commands/

# Changes sync automatically to ~/.claude/commands/
```

**CLAUDE.md** (repository-synced):
Global instructions for Claude Code in `config/claude-code-config/CLAUDE.md`:
```bash
# Edit in repo
code config/claude-code-config/CLAUDE.md

# Changes instantly visible to Claude Code via symlink
```

#### Verification

**Check Claude Code Installation**:
```bash
claude --version
# Expected: Claude Code CLI version X.X.X
```

**Verify MCP Servers Connected**:
```bash
claude mcp list
# Expected:
# context7: ... - ✓ Connected
# playwright: ... - ✓ Connected
# Note: sequential-thinking currently disabled (pending PR #276)
```

**Verify Configuration Symlinks** (REQ-NFR-008):
```bash
ls -la ~/.claude/
# Should show all symlinks pointing to config/claude-code-config/:
# lrwxr-xr-x CLAUDE.md -> .../config/claude-code-config/CLAUDE.md
# lrwxr-xr-x agents -> .../config/claude-code-config/agents/
# lrwxr-xr-x commands -> .../config/claude-code-config/commands/
# lrwxr-xr-x settings.json -> .../config/claude-code-config/settings.json
# lrwxr-xr-x statusline-command.sh -> .../config/claude-code-config/statusline-command.sh
# lrwxr-xr-x keybindings.json -> .../config/claude-code-config/keybindings.json
# lrwxr-xr-x docs -> .../config/claude-code-config/docs/
# lrwxr-xr-x hooks -> .../config/claude-code-config/hooks/
```

**Verify MCP Configs Created** (both locations):
```bash
# Claude Desktop config
cat ~/.config/claude/config.json | jq .mcpServers
# Should show context7, playwright

# Claude Code CLI config
cat ~/.claude.json | jq '.mcpServers'
# Should show context7, playwright, and any manually-added servers
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

**Issue**: MCP server not showing in `claude mcp list`
**Cause**: Claude Code CLI reads from `~/.claude.json`, not `~/.config/claude/config.json`
**Solution**:
```bash
# Check if server is in CLI config
cat ~/.claude.json | jq '.mcpServers'

# If missing, rebuild to trigger activation script
darwin-rebuild switch --flake ~/nix-install#power

# Or manually add using claude CLI
claude mcp add-json -s user <server-name> '<json-config>'
```

**Issue**: MCP servers work in CLI but not Claude Desktop (or vice versa)
**Cause**: Two separate config files for different applications
**Solution**:
```bash
# Check both configs
cat ~/.config/claude/config.json | jq .   # Claude Desktop
cat ~/.claude.json | jq '.mcpServers'     # Claude Code CLI

# Rebuild to sync both
darwin-rebuild switch --flake ~/nix-install#power
```

**Issue**: Configuration changes not appearing in Claude Code
**Solution**:
```bash
# Verify symlinks are correct
ls -la ~/.claude/

# If symlinks broken, rebuild
darwin-rebuild switch --flake ~/nix-install#standard  # or #power

# Symlinks should point to working directory, NOT /nix/store/
# Correct: ~/.claude/CLAUDE.md -> /Users/fx/nix-install/config/claude-code-config/CLAUDE.md
# Wrong: ~/.claude/CLAUDE.md -> /nix/store/.../CLAUDE.md
```

**Issue**: Want to add a new MCP server manually
**Solution**:
```bash
# Add to Claude Code CLI (user scope, persists across rebuilds)
claude mcp add-json -s user my-server '{"command": "/path/to/server", "args": []}'

# Verify
claude mcp list

# Note: Manually-added servers are preserved during rebuilds
# Nix-managed servers are merged with existing ones
```

#### Security Considerations

**MCP Configuration Files**:
- `~/.config/claude/config.json` - Claude Desktop config (user-only permissions)
- `~/.claude.json` - Claude Code CLI config (contains other settings too)
- Both files are NOT committed to the repository
- Nix manages server paths, not secrets

**Adding MCP Servers with Secrets**:
If you need to add an MCP server that requires authentication:
```bash
# Add with environment variable
claude mcp add-json -s user my-auth-server '{
  "command": "/path/to/server",
  "env": {"API_KEY": "your-secret-key"}
}'

# Or use environment variable reference
claude mcp add-json -s user my-auth-server '{
  "command": "/path/to/server",
  "env": {"API_KEY": "${MY_API_KEY}"}
}'
# Then export in shell: export MY_API_KEY=your-secret-key
```

**File Permissions**:
```bash
# Verify config files are user-only readable
ls -la ~/.config/claude/config.json  # Should be 600 or 644
ls -la ~/.claude.json                # Should be 600
```

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

#### Orphan Process Cleanup (kalloc.1024 Mitigation)

**Status**: LaunchAgent `claude-code-cleanup` (runs every 90 minutes)

**Purpose**: Running many parallel Claude Code agents on macOS triggers a kernel
memory leak in the `kalloc.1024` zone and leaves orphaned Node/MCP subprocesses
behind when a Claude Code session crashes or is force-quit. Left to accumulate,
these orphans exhaust memory and can cause GPU panics after 1–2 hours of heavy
multi-agent use.

**What it kills**: Only Node processes whose **parent PID is 1** (launchd) —
i.e. truly orphaned. MCP servers belonging to live Claude Code sessions have
the Claude Code CLI as their parent and are never touched.

**Patterns matched** (in `scripts/claude-cleanup.sh`):
- `node.*mcp-server`
- `node.*claude.*server`

**Schedule**: Every 90 minutes via `StartInterval = 5400` (seconds). Does NOT
run at login — first fire is 90 minutes after the LaunchAgent loads. Chosen
over `StartCalendarInterval` because 90-minute polling has no clean calendar
expression.

**Files**:
- Script: `scripts/claude-cleanup.sh` → synced to `~/.local/bin/claude-cleanup.sh`
  (listed in `COMMON_SCRIPTS` in `darwin/configuration.nix`, all profiles)
- LaunchAgent: `claude-code-cleanup` in `darwin/maintenance.nix`
- App log: `~/.claude/cleanup.log` (one line per run: timestamp + orphan count)
- LaunchAgent log: `/tmp/claude-code-cleanup.log`
- LaunchAgent errors: `/tmp/claude-code-cleanup.err`

**Manual operations**:
```bash
# Run the cleanup immediately
~/.local/bin/claude-cleanup.sh

# Tail the application log
tail -f ~/.claude/cleanup.log

# Verify the LaunchAgent is loaded
launchctl list | grep claude-code-cleanup

# Force the LaunchAgent to fire now
launchctl kickstart -k gui/$(id -u)/org.nixos.claude-code-cleanup

# Inspect what orphans exist right now (no kill)
ps -axo pid=,ppid=,command= | awk '$2==1 && /node.*(mcp-server|claude.*server)/'
```

**Disabling**: Remove or comment out the `claude-code-cleanup` block in
`darwin/maintenance.nix` and run `darwin-rebuild switch`. The LaunchAgent plist
will be unloaded automatically.

**Safety note**: The PPID=1 filter is the important safety. The naïve
`pkill -f 'node.*mcp-server'` form circulating in online guides will kill
MCP servers of *live* sessions and break them.

#### Testing Checklist

- [ ] Claude Code CLI installed and `claude --version` works
- [ ] `~/.claude/CLAUDE.md` symlinked to submodule (bidirectional sync)
- [ ] `~/.claude/agents/` symlinked to submodule
- [ ] `~/.claude/commands/` symlinked to submodule
- [ ] `~/.claude/settings.json` symlinked to submodule
- [ ] `~/.claude/statusline-command.sh` symlinked to submodule
- [ ] `~/.claude/keybindings.json` symlinked to submodule
- [ ] `~/.claude/docs/` symlinked to submodule (python.md, source-control.md, docker-uv.md)
- [ ] `~/.claude/hooks/` symlinked to submodule
- [ ] `~/.config/claude/config.json` created (Claude Desktop)
- [ ] `~/.claude.json` has mcpServers key (Claude Code CLI)
- [ ] `claude mcp list` shows all servers as connected
- [ ] Can start Claude Code CLI with `claude` command
- [ ] Context7 MCP responds to documentation queries
- [ ] Playwright MCP can navigate and interact with web pages
- [ ] Sequential Thinking MCP enables structured reasoning
- [ ] Configuration changes in submodule appear in `~/.claude/` (bidirectional sync)
- [ ] Symlinks point to submodule working directory, NOT /nix/store
#### Resources

- Claude Code CLI: https://github.com/anthropics/claude-code
- MCP Specification: https://modelcontextprotocol.io/
- MCP Servers Nix: https://github.com/natsukium/mcp-servers-nix (community maintained)
- Context7: https://context7.com/
- Playwright MCP: https://github.com/anthropics/anthropic-quickstarts/tree/main/mcp-servers/playwright

---

## Browsers


---

## Related Documentation

- [Main Apps Index](../README.md)
- [Zed Editor Configuration](./zed-editor.md)
- [VS Code Configuration](./vscode.md)
- [Podman Configuration](./podman.md)
- [Python Tools Configuration](./python-tools.md)
