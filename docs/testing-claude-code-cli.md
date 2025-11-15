# VM Testing Guide: Claude Code CLI and MCP Servers (Story 02.2-006)

**Story**: 02.2-006 - Claude Code CLI and MCP Servers Installation
**Component**: Claude Code CLI with Context7, GitHub, and Sequential Thinking MCP servers
**Test Environment**: Parallels macOS VM (Standard or Power profile)
**Test Date**: TBD (FX to perform)
**Tester**: FX

## Testing Overview

This document provides comprehensive VM testing scenarios for Story 02.2-006, which installs Claude Code CLI and three MCP servers (Context7, GitHub, Sequential Thinking) via Nix, with REQ-NFR-008 compliant configuration file management.

**Key Features Being Tested**:
1. Claude Code CLI installation via Nix (claude-code-nix flake input)
2. MCP servers installation via Nix (mcp-servers-nix flake input)
3. MCP server configuration in `~/.config/claude/config.json`
4. **REQ-NFR-008**: Bidirectional sync via repository symlinks (`~/.claude/` → `$REPO/config/claude/`)
5. GitHub Personal Access Token configuration
6. MCP server functionality (Context7, GitHub, Sequential Thinking)
7. No Node.js or npm dependencies (fully Nix-based)

**Expected Outcome**: All packages installed, all MCP servers functional, configuration files synced bidirectionally with repository.

---

## Pre-Test Setup

### VM Requirements
- **Profile**: Standard or Power (both profiles get Claude Code CLI + MCP servers)
- **Snapshot**: Create VM snapshot before testing (allows quick rollback)
- **Network**: Stable internet connection required (Nix flake downloads)
- **Disk Space**: ~500MB for Claude Code CLI and MCP servers

### Test Data Required
- **GitHub Account**: Personal account with repository access
- **GitHub Token**: Will be created during testing (https://github.com/settings/tokens)
- **Token Scopes**: `repo`, `read:org`, `read:user`

---

## Test Scenario 1: Fresh Darwin Rebuild (Happy Path)

**Objective**: Verify Claude Code CLI and MCP servers install successfully via darwin-rebuild.

**Prerequisites**:
- VM snapshot at post-bootstrap state (Epic-01 complete)
- No existing `~/.claude/` directory
- No existing `~/.config/claude/` directory

**Test Steps**:

1. **Run darwin-rebuild**:
   ```bash
   cd ~/nix-install  # or ~/Documents/nix-install or ~/.config/nix-install
   darwin-rebuild switch --flake .#standard  # or .#power
   ```

2. **Expected Output**:
   - Nix fetches claude-code-nix flake input
   - Nix fetches mcp-servers-nix flake input
   - Claude Code CLI and MCP servers install to /nix/store/
   - Home Manager creates symlinks in ~/.claude/
   - Home Manager creates config.json in ~/.config/claude/
   - Success message about GitHub token configuration

3. **Verify Claude Code CLI Installation**:
   ```bash
   claude --version
   # Expected: Claude Code CLI version X.X.X (or similar output)

   which claude
   # Expected: /nix/store/.../bin/claude or /run/current-system/.../bin/claude
   ```

4. **Verify MCP Server Installations**:
   ```bash
   mcp-server-context7 --version
   mcp-server-github --version
   mcp-server-sequential-thinking --version

   which mcp-server-context7
   which mcp-server-github
   which mcp-server-sequential-thinking
   # All should show /nix/store/... paths
   ```

5. **Verify Configuration Symlinks** (REQ-NFR-008):
   ```bash
   ls -la ~/.claude/
   # Expected:
   # lrwxr-xr-x CLAUDE.md -> /path/to/nix-install/config/claude/CLAUDE.md
   # lrwxr-xr-x agents -> /path/to/nix-install/config/claude/agents/
   # lrwxr-xr-x commands -> /path/to/nix-install/config/claude/commands/
   ```

6. **Verify MCP Config Created**:
   ```bash
   cat ~/.config/claude/config.json
   # Expected: JSON with three MCP servers configured
   # Should contain "REPLACE_WITH_YOUR_GITHUB_TOKEN" placeholder
   ```

7. **Verify config.json structure**:
   ```bash
   cat ~/.config/claude/config.json | jq .
   # Should parse successfully, showing three servers:
   # - context7
   # - github
   # - sequential-thinking
   ```

**Success Criteria**:
- ✅ Claude Code CLI installed and `claude --version` works
- ✅ All three MCP server binaries installed and on PATH
- ✅ `~/.claude/CLAUDE.md` symlinked to repository
- ✅ `~/.claude/agents/` symlinked to repository
- ✅ `~/.claude/commands/` symlinked to repository
- ✅ `~/.config/claude/config.json` created with correct structure
- ✅ Symlinks point to working directory (not /nix/store/)

**Failure Cases**:
- ❌ `claude: command not found` → Nix installation failed
- ❌ MCP server binaries not found → mcp-servers-nix flake input issue
- ❌ Symlinks broken or missing → Home Manager activation script error
- ❌ config.json malformed → JSON syntax error in activation script
- ❌ Symlinks point to /nix/store/ → REQ-NFR-008 violation

---

## Test Scenario 2: GitHub Token Configuration

**Objective**: Verify GitHub Personal Access Token creation and configuration process.

**Test Steps**:

1. **Create GitHub Personal Access Token**:
   - Open browser: https://github.com/settings/tokens
   - Click "Generate new token" → "Generate new token (classic)"
   - Set name: "Claude Code MCP Server (VM Test)"
   - Set expiration: 7 days (for testing)
   - Select scopes:
     - ✅ `repo`
     - ✅ `read:org`
     - ✅ `read:user`
   - Click "Generate token"
   - **Copy token immediately** (starts with `ghp_`)

2. **Edit MCP Configuration**:
   ```bash
   # Open config.json
   code ~/.config/claude/config.json  # or zed ~/.config/claude/config.json

   # Replace placeholder with actual token
   # Change: "GITHUB_TOKEN": "REPLACE_WITH_YOUR_GITHUB_TOKEN"
   # To: "GITHUB_TOKEN": "ghp_YourActualTokenHere123456789"

   # Save file
   ```

3. **Verify Token Configuration**:
   ```bash
   cat ~/.config/claude/config.json | jq '.mcpServers.github.env.GITHUB_TOKEN'
   # Expected: "ghp_..." (your actual token, not placeholder)
   ```

4. **Test Token** (optional but recommended):
   ```bash
   TOKEN=$(cat ~/.config/claude/config.json | jq -r '.mcpServers.github.env.GITHUB_TOKEN')
   curl -H "Authorization: token $TOKEN" https://api.github.com/user
   # Expected: JSON with your GitHub user info
   ```

**Success Criteria**:
- ✅ Token created with correct scopes
- ✅ Token added to config.json (replaces placeholder)
- ✅ Token is valid (API test succeeds)

**Failure Cases**:
- ❌ Token creation fails → Check GitHub account permissions
- ❌ Wrong scopes selected → GitHub MCP won't work
- ❌ Token not saved correctly → JSON syntax error
- ❌ API test fails with 401 → Token invalid or expired

---

## Test Scenario 3: MCP Server Functionality

**Objective**: Verify all three MCP servers respond correctly in Claude Code CLI.

**Prerequisites**:
- GitHub token configured (Scenario 2 complete)

**Test Steps**:

1. **List Configured MCP Servers**:
   ```bash
   claude mcp list

   # Expected output:
   # ✓ context7 (enabled)
   # ✓ github (enabled)
   # ✓ sequential-thinking (enabled)
   ```

2. **Test Context7 MCP** (no authentication required):
   ```bash
   # Start Claude Code CLI
   claude

   # Try context awareness queries
   > What files are in this directory?
   > Analyze the structure of this codebase
   > Find all Nix configuration files

   # Verify Context7 responds with relevant information
   ```

3. **Test GitHub MCP** (requires token):
   ```bash
   # In same Claude Code session or restart
   claude

   # Try GitHub queries
   > Show me my GitHub user information
   > List repositories in my account
   > What are the open issues in this repository?

   # Verify GitHub MCP responds with actual GitHub data
   ```

4. **Test Sequential Thinking MCP**:
   ```bash
   # In same Claude Code session or restart
   claude

   # Try reasoning queries
   > Let's think step-by-step about how to implement user authentication
   > Break down the problem of optimizing database queries
   > Analyze this Nix configuration and explain it step by step

   # Verify Sequential Thinking MCP provides structured reasoning
   ```

5. **Test Combined MCP Usage**:
   ```bash
   claude

   > Using GitHub MCP, analyze my recent commits, then use Sequential Thinking
     to suggest improvements to my development workflow

   # Verify both MCP servers work together
   ```

**Success Criteria**:
- ✅ `claude mcp list` shows all three servers as enabled
- ✅ Context7 MCP responds to context queries
- ✅ GitHub MCP authenticates and queries GitHub API
- ✅ Sequential Thinking MCP provides structured reasoning
- ✅ Combined queries work across multiple MCP servers

**Failure Cases**:
- ❌ MCP servers show as disabled → Check config.json "enabled": true
- ❌ GitHub MCP auth fails → Check token configured correctly
- ❌ Context7 doesn't respond → Check mcp-server-context7 binary installed
- ❌ Sequential Thinking doesn't work → Check mcp-server-sequential-thinking binary installed
- ❌ General MCP errors → Check Claude Code CLI logs

---

## Test Scenario 4: Bidirectional Sync (REQ-NFR-008)

**Objective**: Verify changes in repository sync to ~/.claude/ and vice versa.

**Test Steps**:

1. **Test Repo → ~/.claude/ Sync**:
   ```bash
   # Edit CLAUDE.md in repository
   echo "# Test Comment" >> ~/nix-install/config/claude/CLAUDE.md

   # Verify change visible in ~/.claude/
   cat ~/.claude/CLAUDE.md | tail -1
   # Expected: "# Test Comment"
   ```

2. **Test ~/.claude/ → Repo Sync**:
   ```bash
   # Edit CLAUDE.md via ~/.claude/ symlink
   echo "# Another Test" >> ~/.claude/CLAUDE.md

   # Verify change visible in repository
   cd ~/nix-install
   cat config/claude/CLAUDE.md | tail -1
   # Expected: "# Another Test"

   # Verify git sees the change
   git diff config/claude/CLAUDE.md
   # Expected: Shows "+ # Another Test"
   ```

3. **Test Agents Directory Sync**:
   ```bash
   # Create new agent in repo
   touch ~/nix-install/config/claude/agents/test-agent.yaml

   # Verify visible via ~/.claude/
   ls -la ~/.claude/agents/test-agent.yaml
   # Expected: File exists (via symlink)
   ```

4. **Test Commands Directory Sync**:
   ```bash
   # Create new command in repo
   touch ~/nix-install/config/claude/commands/test-command.md

   # Verify visible via ~/.claude/
   ls -la ~/.claude/commands/test-command.md
   # Expected: File exists (via symlink)
   ```

5. **Verify Symlink Targets** (critical):
   ```bash
   readlink ~/.claude/CLAUDE.md
   # Expected: /path/to/nix-install/config/claude/CLAUDE.md
   # NOT: /nix/store/.../CLAUDE.md

   readlink ~/.claude/agents
   # Expected: /path/to/nix-install/config/claude/agents/
   # NOT: /nix/store/.../agents/

   readlink ~/.claude/commands
   # Expected: /path/to/nix-install/config/claude/commands/
   # NOT: /nix/store/.../commands/
   ```

**Success Criteria**:
- ✅ Changes in repository instantly visible in ~/.claude/
- ✅ Changes via ~/.claude/ instantly visible in repository
- ✅ Git tracks changes made via ~/.claude/ symlinks
- ✅ Symlinks point to working directory (NOT /nix/store/)
- ✅ Directories sync correctly (agents/, commands/)

**Failure Cases**:
- ❌ Symlinks point to /nix/store/ → REQ-NFR-008 violation (critical bug)
- ❌ Changes don't sync → Symlink broken or wrong target
- ❌ Git doesn't see changes → Symlink not writable
- ❌ Files created in repo not visible in ~/.claude/ → Symlink broken

---

## Test Scenario 5: Rebuild Idempotency

**Objective**: Verify darwin-rebuild doesn't overwrite user customizations.

**Prerequisites**:
- GitHub token configured in config.json

**Test Steps**:

1. **Customize MCP Configuration**:
   ```bash
   # Backup current config
   cp ~/.config/claude/config.json ~/.config/claude/config.json.backup

   # Add custom MCP server (example)
   cat ~/.config/claude/config.json | jq '.mcpServers.custom = {"command": "echo", "args": ["test"], "enabled": true}' > /tmp/config.json
   mv /tmp/config.json ~/.config/claude/config.json
   ```

2. **Run darwin-rebuild Again**:
   ```bash
   cd ~/nix-install
   darwin-rebuild switch --flake .#standard  # or .#power
   ```

3. **Verify Customizations Preserved**:
   ```bash
   cat ~/.config/claude/config.json | jq '.mcpServers.custom'
   # Expected: {"command": "echo", "args": ["test"], "enabled": true}

   cat ~/.config/claude/config.json | jq '.mcpServers.github.env.GITHUB_TOKEN'
   # Expected: Your GitHub token (not placeholder)
   ```

4. **Verify Standard Servers Still Present**:
   ```bash
   cat ~/.config/claude/config.json | jq '.mcpServers | keys'
   # Expected: ["context7", "custom", "github", "sequential-thinking"]
   ```

**Success Criteria**:
- ✅ darwin-rebuild does NOT overwrite config.json
- ✅ GitHub token preserved after rebuild
- ✅ Custom MCP servers preserved
- ✅ Standard MCP servers still present

**Failure Cases**:
- ❌ config.json overwritten → Activation script should check if file exists
- ❌ Token lost after rebuild → Idempotency bug (critical)
- ❌ Custom servers removed → Activation script overwrites instead of preserves

---

## Test Scenario 6: Error Handling

**Objective**: Verify graceful handling of missing or invalid configurations.

**Test Steps**:

1. **Test Missing config.json** (simulates fresh install):
   ```bash
   # Remove config.json
   rm ~/.config/claude/config.json

   # Rebuild
   darwin-rebuild switch --flake ~/nix-install#standard

   # Verify config.json recreated
   test -f ~/.config/claude/config.json && echo "✅ config.json recreated"
   ```

2. **Test Malformed config.json**:
   ```bash
   # Create invalid JSON
   echo "{ invalid json" > ~/.config/claude/config.json

   # Try to use Claude Code
   claude mcp list

   # Expected: Error message about malformed config
   # Fix by recreating
   rm ~/.config/claude/config.json
   darwin-rebuild switch --flake ~/nix-install#standard
   ```

3. **Test Repository Not Found** (edge case):
   ```bash
   # Temporarily rename repo
   mv ~/nix-install ~/nix-install-backup

   # Rebuild (should handle gracefully)
   darwin-rebuild switch --flake ~/nix-install-backup#standard

   # Check warnings
   # Expected: Warning about repo not found, symlinks not created

   # Restore repo
   mv ~/nix-install-backup ~/nix-install
   ```

**Success Criteria**:
- ✅ Missing config.json recreated on rebuild
- ✅ Malformed config.json shows clear error
- ✅ Missing repository shows warning (doesn't fail build)

---

## Test Scenario 7: Custom NIX_INSTALL_DIR Support

**Objective**: Verify symlinks work with custom repository locations.

**Test Steps**:

1. **Test with ~/Documents/nix-install**:
   ```bash
   # Move repo to Documents
   mv ~/nix-install ~/Documents/nix-install

   # Rebuild from new location
   darwin-rebuild switch --flake ~/Documents/nix-install#standard

   # Verify symlinks updated
   readlink ~/.claude/CLAUDE.md
   # Expected: /Users/fx/Documents/nix-install/config/claude/CLAUDE.md
   ```

2. **Test with ~/.config/nix-install**:
   ```bash
   # Move repo to .config
   mv ~/Documents/nix-install ~/.config/nix-install

   # Rebuild
   darwin-rebuild switch --flake ~/.config/nix-install#standard

   # Verify symlinks updated
   readlink ~/.claude/CLAUDE.md
   # Expected: /Users/fx/.config/nix-install/config/claude/CLAUDE.md
   ```

**Success Criteria**:
- ✅ Symlinks work with any standard location
- ✅ Home Manager activation script finds repo dynamically
- ✅ No hardcoded paths in symlinks

---

## Manual Verification Checklist

Perform these checks after all automated scenarios:

### Installation Verification
- [ ] Claude Code CLI installed: `claude --version` shows version
- [ ] Context7 MCP installed: `mcp-server-context7 --version` works
- [ ] GitHub MCP installed: `mcp-server-github --version` works
- [ ] Sequential Thinking MCP installed: `mcp-server-sequential-thinking --version` works
- [ ] All binaries in PATH (which commands succeed)

### Configuration Verification
- [ ] `~/.claude/CLAUDE.md` symlinked to repo (not /nix/store/)
- [ ] `~/.claude/agents/` symlinked to repo (not /nix/store/)
- [ ] `~/.claude/commands/` symlinked to repo (not /nix/store/)
- [ ] `~/.config/claude/config.json` exists with correct structure
- [ ] config.json contains three MCP servers (context7, github, sequential-thinking)

### Functionality Verification
- [ ] `claude mcp list` shows all three servers as enabled
- [ ] Claude Code CLI starts successfully with `claude` command
- [ ] GitHub token configured (replaced placeholder)
- [ ] GitHub token valid (API test succeeds)
- [ ] Context7 MCP responds to context queries
- [ ] GitHub MCP authenticates and queries GitHub
- [ ] Sequential Thinking MCP provides structured reasoning

### Bidirectional Sync Verification (REQ-NFR-008)
- [ ] Changes in repo appear in ~/.claude/ instantly
- [ ] Changes via ~/.claude/ appear in repo
- [ ] Git tracks changes made via ~/.claude/ symlinks
- [ ] Symlinks point to working directory (readlink check)

### Idempotency Verification
- [ ] darwin-rebuild preserves config.json customizations
- [ ] GitHub token persists across rebuilds
- [ ] Custom MCP servers preserved

---

## Common Issues and Solutions

### Issue: claude: command not found
**Diagnosis**: Nix package not installed or PATH issue
**Solution**:
```bash
# Check if installed
nix-env -q | grep claude

# Verify in /nix/store
ls /nix/store/ | grep claude-code

# Check PATH
echo $PATH | grep nix

# Rebuild
darwin-rebuild switch --flake ~/nix-install#standard
```

### Issue: MCP servers not found
**Diagnosis**: mcp-servers-nix flake input not fetched
**Solution**:
```bash
# Update flake inputs
cd ~/nix-install
nix flake update

# Rebuild
darwin-rebuild switch --flake .#standard

# Verify binaries
which mcp-server-context7
which mcp-server-github
which mcp-server-sequential-thinking
```

### Issue: Symlinks point to /nix/store/ instead of working directory
**Diagnosis**: REQ-NFR-008 violation - critical bug in activation script
**Solution**: This is a code bug, not a configuration issue. Report to developer.
```bash
# Temporary workaround: manually fix symlinks
rm ~/.claude/CLAUDE.md ~/.claude/agents ~/.claude/commands
ln -sf ~/nix-install/config/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sfn ~/nix-install/config/claude/agents ~/.claude/agents
ln -sfn ~/nix-install/config/claude/commands ~/.claude/commands
```

### Issue: GitHub MCP authentication fails
**Diagnosis**: Token not configured or invalid
**Solution**:
```bash
# Check token in config
cat ~/.config/claude/config.json | jq '.mcpServers.github.env.GITHUB_TOKEN'

# If placeholder, add real token
code ~/.config/claude/config.json

# Test token validity
TOKEN=$(cat ~/.config/claude/config.json | jq -r '.mcpServers.github.env.GITHUB_TOKEN')
curl -H "Authorization: token $TOKEN" https://api.github.com/user
```

### Issue: config.json malformed
**Diagnosis**: JSON syntax error
**Solution**:
```bash
# Validate JSON
cat ~/.config/claude/config.json | jq .

# If error, recreate from scratch
rm ~/.config/claude/config.json
darwin-rebuild switch --flake ~/nix-install#standard
```

---

## Test Results Template

**Test Date**: _______________
**Tester**: FX
**Profile Tested**: [ ] Standard [ ] Power
**Nix-Darwin Version**: _______________
**Claude Code CLI Version**: _______________

### Scenario Results

| Scenario | Status | Notes |
|----------|--------|-------|
| 1. Fresh Darwin Rebuild | ⬜ Pass ⬜ Fail | |
| 2. GitHub Token Configuration | ⬜ Pass ⬜ Fail | |
| 3. MCP Server Functionality | ⬜ Pass ⬜ Fail | |
| 4. Bidirectional Sync | ⬜ Pass ⬜ Fail | |
| 5. Rebuild Idempotency | ⬜ Pass ⬜ Fail | |
| 6. Error Handling | ⬜ Pass ⬜ Fail | |
| 7. Custom NIX_INSTALL_DIR | ⬜ Pass ⬜ Fail | |

### Issues Found

1. _______________
2. _______________
3. _______________

### Recommendations

1. _______________
2. _______________
3. _______________

---

## Test Completion

**Overall Result**: ⬜ PASS ⬜ FAIL (with issues) ⬜ BLOCKED

**Sign-off**: _______________
**Date**: _______________

---

## References

- **Story**: Epic-02, Story 02.2-006
- **REQ-NFR-008**: Bidirectional sync requirement
- **Documentation**: docs/app-post-install-configuration.md (Claude Code CLI section)
- **Home Manager Module**: home-manager/modules/claude-code.nix
- **Configuration**: darwin/configuration.nix (systemPackages)
- **Flake Inputs**: flake.nix (claude-code-nix, mcp-servers-nix)
