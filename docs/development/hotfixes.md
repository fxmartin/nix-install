# ABOUTME: Hotfix documentation for nix-install project
# ABOUTME: Records all production hotfixes with problem, solution, and impact

## HOTFIX: Story 01.5-002 - Nix-Daemon Detection Issue
**Date**: 2025-11-10
**Issue**: #10 - nix-daemon validation fails despite daemon running
**Status**: ✅ FIXED

### Problem
The `check_nix_daemon_running()` function was only checking the **user domain** with `launchctl list`, but nix-daemon runs in the **system domain** (as root). This caused false-negative failures during post-darwin validation.

### Root Cause
```bash
# Original code (line 2044) - only checked user domain
if launchctl list | grep -q "org.nixos.nix-daemon"; then
```

The daemon was running correctly, but not visible in user domain launchctl output.

### Solution Implemented
Multi-method detection with three fallback layers:

1. **Method 1**: Check user domain (original, for compatibility)
2. **Method 2**: Check system domain with `sudo launchctl list` (PRIMARY FIX)
3. **Method 3**: Check running process directly with `pgrep nix-daemon` (FALLBACK)

This robust approach ensures detection regardless of how the daemon is running.

### Files Modified
- `bootstrap.sh`: Updated `check_nix_daemon_running()` function (+17 lines)
- Lines 2040-2075 now implement three-method detection

### Testing
- ✅ Bash syntax validated (bash -n)
- ✅ Existing BATS tests still pass (mocking handles all methods)
- ⏳ VM testing required to confirm fix works in real environment

### Impact
- **Fixes**: Issue #10 (CRITICAL blocker)
- **Unblocks**: Story 01.6-001 and all subsequent Epic-01 stories
- **User Impact**: Bootstrap can now complete Phase 5 validation successfully

---

## HOTFIX: Story 01.6-002 - GitHub CLI Not Available in PATH During Bootstrap
**Date**: 2025-11-11
**Issue**: bootstrap.sh line 2875 fails with "gh: command not found"
**Status**: ✅ FIXED
**Temporary Fix**: 186b1df (fallback workaround)
**Proper Fix**: a4e210c (Homebrew installation)
**Branch**: feature/01.7-001-repo-clone

### Problem
During VM testing of Story 01.7-001, Phase 6 (GitHub SSH Key Upload) failed with:
```
bootstrap.sh: line 2875: gh: command not found
[ERROR] GitHub CLI authentication failed (CRITICAL)
[ERROR] Bootstrap process terminated.
```

The bootstrap script attempted to use `gh` (GitHub CLI) but it wasn't found in PATH.

### Root Cause
**PATH Issue**: GitHub CLI (`gh`) is installed via nix-darwin/Home Manager during Phase 5 (`programs.gh.enable = true` in `home-manager/modules/github.nix`). However, during the initial bootstrap run, the newly installed packages aren't added to the current shell's PATH until after a shell reload or environment re-sourcing.

**Bootstrap Sequence**:
1. Phase 5: Nix-darwin build (installs `gh` to nix store)
2. Phase 6: GitHub SSH key upload (tries to use `gh` - NOT IN PATH YET)
3. Shell needs reload to pick up new PATH from nix-darwin profile

The `gh` binary exists in the nix store, but the current shell doesn't know where to find it.

### Solution Implemented
Added `command -v gh` availability check at the start of `upload_github_key_phase()`:

```bash
# Check if GitHub CLI (gh) is available in PATH
if ! command -v gh >/dev/null 2>&1; then
    log_warn "GitHub CLI (gh) not found in PATH"
    log_info "This is expected if nix-darwin hasn't been built yet (Phase 5)"
    log_info "Falling back to manual SSH key upload process..."

    fallback_manual_key_upload
    return 0
fi
```

**Behavior**:
- If `gh` not available → Fall back to manual upload immediately (graceful degradation)
- If `gh` available → Proceed with automated OAuth flow (~90% automation)
- Provides clear user messaging explaining the fallback

### Files Modified
- `bootstrap.sh`: Updated `upload_github_key_phase()` function (+24 lines)
- Lines 3037-3059 implement the availability check and fallback

### Testing
- ✅ Bash syntax validated (bash -n)
- ⏳ VM testing required to confirm manual fallback works correctly
- Expected: Manual upload process guides user through GitHub web UI

### Impact
- **Fixes**: GitHub CLI availability issue during first bootstrap
- **Maintains**: ~90% automation goal when `gh` is available
- **Provides**: Graceful fallback to manual process when `gh` unavailable
- **User Impact**: Bootstrap can complete even if PATH isn't updated yet

### Alternative Solutions Considered
1. **Add /nix/store path explicitly**: Too fragile, hash changes with updates
2. **Source nix-darwin profile before Phase 6**: Risky, might break shell state
3. **Move Phase 6 after shell reload**: Breaks logical flow (SSH before clone)
4. **Install gh via Homebrew in Phase 5**: Conflicts with nix-darwin management

### Long-term Solution (IMPLEMENTED)
**FX's Key Observation**: "Ghostty is installed via Homebrew and available immediately. Why not `gh`?"

**Answer**: Ghostty is a Homebrew **cask** (darwin/homebrew.nix line 48), which makes it available in PATH immediately after darwin-rebuild. The original `gh` installation via Home Manager `programs.gh` required a shell reload.

**Proper Fix (Commit a4e210c)**:
1. **Moved gh installation** from Home Manager to Homebrew formula
   - Added `"gh"` to `darwin/homebrew.nix` brews array
   - Homebrew formulas are immediately available in PATH (like Ghostty)
2. **Kept Home Manager configuration** for declarative gh settings
   - `programs.gh.enable = true` still manages configuration
   - `git_protocol = "ssh"` and editor settings preserved
3. **Removed workaround code** from bootstrap.sh
   - No longer need availability check and fallback
   - Automated OAuth flow works as designed (~90% automation)

**Result**: GitHub CLI now behaves exactly like Ghostty - immediately available after Phase 5 darwin-rebuild, enabling the automated SSH key upload flow in Phase 6.

---

## HOTFIX #3: Story 01.6-002 - PATH Update for Homebrew After Phase 5
**Date**: 2025-11-11
**Issue**: Shell reload required between Phase 5 and Phase 6 for gh availability
**Status**: ✅ FIXED
**Commit**: aa4f344
**Branch**: main

### Problem
During VM testing, FX discovered that even after installing gh via Homebrew (Hotfix #2a), the terminal needed to be restarted before `gh` became available in Phase 6. This broke the single-shell execution flow of the bootstrap.

**User Experience**:
```
Phase 5: darwin-rebuild completes (installs gh via Homebrew)
Phase 6: gh: command not found
[User must exit terminal and start new one]
Phase 6: gh now works
```

This violated the design goal of single-shell bootstrap execution.

### Root Cause
When Homebrew installs packages via nix-darwin, the binaries are placed in `/opt/homebrew/bin/`. However, the current shell session's PATH environment variable doesn't automatically update to include this directory until one of:
1. Shell reload (source ~/.zshrc or restart terminal)
2. Explicit PATH update (export PATH="/opt/homebrew/bin:$PATH")

The bootstrap was relying on PATH already including Homebrew, which isn't true for fresh macOS installs.

### Solution Implemented
Added explicit PATH update after Phase 5 validation (lines 3860-3886 in bootstrap.sh):

```bash
# After nix-darwin validation completes
log_info "Updating shell PATH to include Homebrew binaries..."

# Add Homebrew to PATH if not already present
if [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
    log_success "✓ Homebrew added to PATH"
else
    log_info "✓ Homebrew already in PATH"
fi

# Verify gh is now available
if command -v gh >/dev/null 2>&1; then
    log_success "✓ GitHub CLI (gh) is available in PATH"
    log_info "  Version: $(gh --version | head -1)"
else
    log_warn "GitHub CLI (gh) still not in PATH after Homebrew update"
fi
```

**Behavior**:
- Check if `/opt/homebrew/bin` already in PATH (skip if present)
- Export PATH with Homebrew directory prepended
- Verify `gh` command now works
- Display gh version for confirmation
- Log warning if still not available (fallback indicators)

### Files Modified
- `bootstrap.sh`: Added PATH update section after validate_nix_darwin_phase() (+27 lines)
- Lines 3860-3886 implement the PATH update logic

### Testing
- ✅ Bash syntax validated (bash -n)
- ✅ VM testing confirmed: `gh` available immediately after Phase 5
- ✅ No shell reload required between phases
- ✅ Single-shell execution from start to finish

### Impact
- **Fixes**: Shell reload requirement between Phase 5 and Phase 6
- **Maintains**: Single-shell bootstrap execution model
- **Enables**: Automated OAuth flow in Phase 6 (no interruptions)
- **User Impact**: Seamless bootstrap from Phase 1 through Phase 7

### Relationship to Hotfix #2
This hotfix complements Hotfix #2:
- **Hotfix #2a**: Install gh via Homebrew (makes it installable)
- **Hotfix #2b**: Fix config directory permissions (makes it configurable)
- **Hotfix #3**: Update PATH after install (makes it immediately usable)

Together, these three commits ensure gh works perfectly for automated SSH key upload.

### Long-term Considerations
On subsequent bootstrap runs or when running from an already-configured system, Homebrew will already be in PATH from shell initialization files (managed by nix-darwin). This fix handles the first-run scenario gracefully.

---

## HOTFIX #4: Story 01.7-002 - Missing installProfile in user-config.nix
**Date**: 2025-11-11
**Issue**: Phase 8 fails with "Could not extract installProfile from user-config.nix"
**Status**: ✅ FIXED
**Branch**: main

### Problem
During VM testing of Story 01.7-002 (Phase 8: Final Darwin Rebuild), the bootstrap failed at the profile loading step:

```
[ERROR] Could not extract installProfile from user-config.nix
[ERROR] File may be corrupted or invalid
[ERROR] Failed to load profile from user-config.nix
[ERROR] Bootstrap process terminated.
```

The `load_profile_from_user_config()` function was unable to extract the installation profile from the generated user-config.nix file.

### Root Cause
**Design Flaw in Phase 2**: The installation profile selection (standard vs power) in Phase 2 was only stored as an environment variable `$INSTALL_PROFILE` during bootstrap execution. It was **never written** to the user-config.nix file.

**Workflow Analysis**:
1. Line 4037: `select_installation_profile()` sets `$INSTALL_PROFILE` variable (in memory only)
2. Line 4041: `generate_user_config()` creates user-config.nix from template
3. Template (`user-config.template.nix`) had no `@INSTALL_PROFILE@` placeholder
4. Phase 8: `load_profile_from_user_config()` tries to read profile from file → **FAILS**

The profile existed only in the shell session, not persisted to disk.

### Solution Implemented
Added profile persistence to the user configuration file generation:

**1. Updated user-config.template.nix** (added lines 12-13):
```nix
# Installation Profile
installProfile = "@INSTALL_PROFILE@";  # "standard" or "power"
```

**2. Updated generate_user_config()** in bootstrap.sh (added line 578):
```bash
-e "s/@INSTALL_PROFILE@/${INSTALL_PROFILE}/g" \
```

**3. Updated load_profile_from_user_config()** in bootstrap.sh (lines 3756-3765):
```bash
# Extract installProfile value from user-config.nix
# Pattern: installProfile = "standard"; or installProfile = "power";
local profile_value
profile_value=$(grep -E '^\s*installProfile\s*=\s*"(standard|power)";' "${user_config_path}" | sed -E 's/.*"([^"]+)".*/\1/')
```

Changed from `INSTALL_PROFILE = ` (all caps) to `installProfile = ` (camelCase) to match Nix attribute naming conventions.

### Files Modified
1. **user-config.template.nix**: Added `installProfile` field (+2 lines)
2. **bootstrap.sh**:
   - Line 578: Added sed substitution for `@INSTALL_PROFILE@`
   - Lines 3756-3765: Updated grep pattern from `INSTALL_PROFILE` to `installProfile`
   - Lines 3762-3764: Updated error messages to reference `installProfile`
3. **tests/08-final-darwin-rebuild.bats**: Updated all 50 tests (+12 edits)
   - Changed mock user-config.nix format from `INSTALL_PROFILE = ` to `installProfile = `
   - Updated error message assertions to match new format

### Testing
- ✅ Bash syntax validated (bash -n)
- ✅ All 50 BATS tests updated to new format
- ✅ Template substitution verified
- ⏳ VM testing required to confirm hotfix works end-to-end

### Impact
- **Fixes**: Phase 8 profile loading failure (CRITICAL blocker)
- **Enables**: Bootstrap completion through Phase 8
- **Design Improvement**: Profile now persisted correctly to disk
- **User Impact**: Bootstrap can complete final darwin-rebuild successfully

### Why This Wasn't Caught Earlier
**Missing Test Coverage**: The original Phase 8 BATS tests mocked the user-config.nix file manually, using the **wrong format** (`INSTALL_PROFILE = ` instead of `installProfile = `). These tests passed because they never validated:
1. That user-config.nix was generated correctly from the template
2. That the template included the profile field
3. That Phase 2 actually writes the profile to the file

**Lesson Learned**: Integration tests should validate the **entire flow** (template → generation → reading), not just individual function behavior with mocked inputs.

### Generated user-config.nix Format
After this fix, the generated file now includes:

```nix
{
  # Personal Information
  username = "fxmartin";
  fullName = "François-Xavier Martin";
  email = "fx@example.com";
  githubUsername = "fxmartin";
  hostname = "fx-macbook";
  signingKey = "";

  # Installation Profile
  installProfile = "power";  # ← NEW: Persisted from Phase 2

  # Directory Configuration
  directories = {
    dotfiles = "Documents/nix-install";
  };
}
```

### Relationship to Other Fixes
This hotfix is independent of previous hotfixes but essential for Epic-01 completion:
- **Hotfix #1**: Nix-daemon detection (Phase 5)
- **Hotfix #2**: GitHub CLI availability (Phase 6)
- **Hotfix #3**: PATH update for Homebrew (Phase 6)
- **Hotfix #4**: Profile persistence (Phase 8) ← THIS FIX

Together, these enable the complete bootstrap flow from Phase 1 through Phase 8.

---

## HOTFIX #5: Story 01.7-002 - darwin-rebuild requires sudo
**Date**: 2025-11-11
**Issue**: Phase 8 fails with "system activation must now be run as root"
**Status**: ✅ FIXED
**Branch**: main

### Problem
During VM testing of Story 01.7-002 (Phase 8: Final Darwin Rebuild), the darwin-rebuild command failed with:

```
/run/current-system/sw/bin/darwin-rebuild: system activation must now be run as root
Darwin-rebuild failed after 0 seconds
Darwin-rebuild failed
Your system may be in a partially configured state
```

The Phase 8 rebuild was running `darwin-rebuild switch` without sudo privileges.

### Root Cause
**Permission Mismatch**: Phase 5 (initial nix-darwin installation) correctly uses `sudo` to run the build:

```bash
# Phase 5 (line 1867) - CORRECT
sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake ${flake_ref}
```

However, Phase 8 (final rebuild) was running darwin-rebuild **without** sudo:

```bash
# Phase 8 (line 3808) - INCORRECT
darwin-rebuild switch --flake "${flake_ref}"
```

The `darwin-rebuild switch` command performs system activation which modifies system files and requires root privileges.

### Solution Implemented
Added `sudo` to the darwin-rebuild command in Phase 8:

**Changes in `run_final_darwin_rebuild()` function** (lines 3802-3812):

```bash
# darwin-rebuild switch requires sudo for system activation
log_warn "This step requires sudo privileges for system activation"
echo ""

rebuild_start_time=$(date +%s)

# Execute darwin-rebuild switch with sudo
log_info "Executing: sudo darwin-rebuild switch --flake ${flake_ref}"
echo ""

if sudo darwin-rebuild switch --flake "${flake_ref}"; then
```

**Also updated error messages** to include sudo in recovery instructions:
- Line 3968: `sudo darwin-rebuild switch --flake ...`
- Line 4215: `sudo darwin-rebuild switch --flake ...`

### Files Modified
- **bootstrap.sh**: Updated `run_final_darwin_rebuild()` function
  - Line 3803-3804: Added sudo warning message
  - Line 3809-3812: Added sudo to darwin-rebuild command
  - Line 3968: Updated error recovery message
  - Line 4215: Updated final error message

### Testing
- ✅ Bash syntax validated (bash -n)
- ⏳ VM testing required to validate sudo works correctly

### Impact
- **Fixes**: Phase 8 permission denied error (CRITICAL blocker)
- **Aligns**: Phase 8 with Phase 5 permission model (consistency)
- **User Impact**: Bootstrap can complete Phase 8 rebuild successfully

### Why This Wasn't Caught Earlier
**Assumption Error**: The original implementation assumed that after nix-darwin is installed in Phase 5, subsequent `darwin-rebuild` commands would work without sudo. However, `darwin-rebuild switch` (which activates system changes) always requires root privileges for system activation, regardless of whether it's the first or subsequent run.

**Phase 5 vs Phase 8 Difference**:
- **Phase 5**: First-time installation → Always requires sudo (correctly implemented)
- **Phase 8**: Subsequent rebuild → Also requires sudo (was missing)

The confusion arose from thinking "rebuild" was different from "initial build", but both use the same system activation mechanism.

### Darwin-Rebuild Permission Model
Per nix-darwin documentation, `darwin-rebuild switch` requires sudo because it:
1. Modifies system files in `/run/current-system`
2. Activates launchd services (system daemons)
3. Updates system PATH and environment
4. Symlinks system configurations

These operations always require root, whether first-time or subsequent rebuilds.

### User Experience
With this fix, users will see:

```
[INFO] This will apply your complete system configuration...
[INFO] Expected duration: 2-5 minutes (packages cached from initial build)

[WARN] This step requires sudo privileges for system activation

[INFO] Executing: sudo darwin-rebuild switch --flake /Users/fxmartin/Documents/nix-install#power

Password: [user enters password]
```

This matches the sudo prompt from Phase 5, providing consistency.

### Relationship to Other Fixes
This completes the Phase 8 hotfix series:
- **Hotfix #4**: Profile persistence (installProfile in user-config.nix) ✅
- **Hotfix #5**: darwin-rebuild sudo requirement ✅ **← THIS FIX**

Together with Hotfixes #1-3 (Phase 5-6), these enable the complete bootstrap flow from Phase 1 through Phase 8.

---

## HOTFIX #6: Story 01.7-002 - Profile extraction reads comment instead of value
**Date**: 2025-11-11
**Issue**: Phase 8 displays wrong profile ("power" when user selected "standard")
**Status**: ✅ FIXED
**Branch**: main

### Problem
During VM testing, FX reported that Phase 8 Step 1 displayed "Profile loaded: power" even though:
- user-config.nix contained `installProfile = "standard";`
- Phase 2 confirmed "Installation profile selected: standard"
- The file was correctly generated with the right value

The `load_profile_from_user_config()` function was extracting the WRONG value from the file.

### Root Cause
**Greedy Regex Bug**: The sed pattern used to extract the profile value was TOO greedy and captured the LAST quoted string on the line, not the first.

**The Line in user-config.nix**:
```nix
installProfile = "standard";  # "standard" or "power"
```

**Buggy Pattern**:
```bash
sed -E 's/.*"([^"]+)".*/\1/'
```

This pattern:
1. `.*` - Matches greedily: `  installProfile = "standard";  # "standard" or `
2. `"([^"]+)"` - Captures the LAST quoted string: `"power"`
3. Result: Always extracts "power" regardless of actual value!

**Why This Happened**:
- The template (line 13) has a helpful comment: `installProfile = "@INSTALL_PROFILE@";  # "standard" or "power"`
- After sed substitution: `installProfile = "standard";  # "standard" or "power"`
- The sed pattern `.*"([^"]+)".*` is greedy and skips past the first quote, capturing the last one
- The comment always contains both "standard" and "power", so it always extracts "power" (the last quoted word)

### Solution Implemented
Changed sed pattern to explicitly match the value part (first quoted string after equals sign):

**Before (BUGGY)**:
```bash
profile_value=$(grep ... | sed -E 's/.*"([^"]+)".*/\1/')
```

**After (FIXED)**:
```bash
profile_value=$(grep ... | sed -E 's/^[^=]*=[[:space:]]*"([^"]+)".*/\1/')
```

**How the Fix Works**:
1. `^[^=]*=` - Match from start of line to first equals sign
2. `[[:space:]]*` - Skip any whitespace after equals
3. `"([^"]+)"` - Capture the FIRST quoted string (the actual value)
4. `.*` - Ignore everything after (including the comment)

### Files Modified
- **bootstrap.sh**: Line 3760 - Updated sed pattern in `load_profile_from_user_config()`
  - Added comment explaining the non-greedy pattern requirement
  - Changed regex to match first equals sign, then first quoted string

### Testing
- ✅ Bash syntax validated (bash -n)
- ✅ Tested with `installProfile = "standard";  # comment` → Extracts "standard" ✅
- ✅ Tested with `installProfile = "power";  # comment` → Extracts "power" ✅
- ⏳ VM testing required to validate in real bootstrap

### Impact
- **Fixes**: Profile extraction always showing "power" (CRITICAL bug)
- **Enables**: Correct profile selection (Standard vs Power)
- **User Impact**: Bootstrap now applies the profile user actually selected

### Why This Wasn't Caught Earlier
**Test Gap**: The BATS tests for Phase 8 created mock user-config.nix files WITHOUT the comment, so they never exposed this bug:

```nix
# BATS test mock (no comment - worked fine)
installProfile = "standard";

# Real template (has comment - caused bug)
installProfile = "standard";  # "standard" or "power"
```

The tests validated the sed pattern against a simplified format that didn't match production.

**Lesson Learned**: Test mocks should match EXACT production format, including comments and formatting.

### Example of Bug Behavior

**User Experience (Before Fix)**:
```
Phase 2:
✓ Installation profile selected: standard

Phase 8 Step 1:
Loading installation profile from user-config.nix...
✓ Profile loaded: power   ← WRONG!

Phase 8 Step 2:
Profile: power   ← WRONG!
Flake reference: /Users/fxmartin/Documents/nix-install#power   ← WRONG!
```

**User Experience (After Fix)**:
```
Phase 2:
✓ Installation profile selected: standard

Phase 8 Step 1:
Loading installation profile from user-config.nix...
✓ Profile loaded: standard   ← CORRECT!

Phase 8 Step 2:
Profile: standard   ← CORRECT!
Flake reference: /Users/fxmartin/Documents/nix-install#standard   ← CORRECT!
```

### Relationship to Other Fixes
This completes the Phase 8 hotfix trilogy:
- **Hotfix #4**: Profile persistence (installProfile added to user-config.nix) ✅
- **Hotfix #5**: darwin-rebuild sudo requirement ✅
- **Hotfix #6**: Profile extraction regex fix ✅ **← THIS FIX**

Together with Hotfixes #1-3, these enable correct, complete bootstrap flow from Phase 1 through Phase 8 with proper profile selection.

---

## HOTFIX #7: Story 01.7-002 - user-config.nix not git-tracked for flake evaluation
**Date**: 2025-11-11
**Issue**: Phase 8 darwin-rebuild fails with "user-config.nix not found" error
**Status**: ✅ FIXED
**Branch**: main

### Problem
During VM testing, the darwin-rebuild command failed with:

```
error: user-config.nix not found. Run bootstrap.sh first or create from user-config.template.nix
```

This error occurred even though:
- The file physically existed at `~/Documents/nix-install/user-config.nix`
- The file was readable
- Phase 7 successfully copied it to the repository

The Nix flake evaluation couldn't see the file.

### Root Cause
**Nix Flake Security Feature**: Nix flakes only evaluate **git-tracked files** for security reasons. The `builtins.pathExists ./user-config.nix` check returns false for untracked files, even if they physically exist.

**What Happened**:
1. Phase 7: `copy_user_config_to_repo()` copied file to `~/Documents/nix-install/user-config.nix` ✅
2. File existed and was readable ✅
3. But file was NOT added to git (untracked) ❌
4. Phase 8: darwin-rebuild tries to evaluate flake ❌
5. Nix flake sees untracked file → treats as non-existent ❌
6. `builtins.pathExists ./user-config.nix` returns `false` ❌
7. Flake throws error and evaluation fails ❌

### Why Flakes Require Git Tracking
Nix flakes have a security model where they only see files that are:
- Committed to git, OR
- Staged (git add), OR
- In a "pure" evaluation with --impure flag

This prevents flakes from accidentally including sensitive or temporary files.

### Solution Implemented
Updated `copy_user_config_to_repo()` function to automatically `git add` the file after copying:

**Changes (lines 3532-3538 and 3550-3560)**:

```bash
# After copying file
log_success "✓ User configuration copied to repository"

# Git add user-config.nix so Nix flake can see it
# Nix flakes only evaluate git-tracked files for security
log_info "Adding user-config.nix to git..."
if ! (cd "${REPO_CLONE_DIR}" && git add user-config.nix); then
    log_error "Failed to git add user-config.nix"
    log_error "You may need to manually run: cd ${REPO_CLONE_DIR} && git add user-config.nix"
    return 1
fi

log_success "✓ User configuration tracked in git"
```

**Also handles existing file case** (lines 3532-3538):
If user-config.nix already exists (preserved customizations), the function now ensures it's git-tracked too.

### Files Modified
- **bootstrap.sh**: Updated `copy_user_config_to_repo()` function
  - Lines 3532-3538: Add git tracking for existing files
  - Lines 3550-3560: Add git tracking for newly copied files
  - Added explanatory comments about flake security model

### Testing
- ✅ Bash syntax validated (bash -n)
- ✅ Git add command tested in subshell (cd && git add)
- ⏳ VM testing required to validate flake evaluation works

### Impact
- **Fixes**: Flake evaluation "file not found" error (CRITICAL blocker)
- **Enables**: Phase 8 darwin-rebuild to evaluate flake successfully
- **User Impact**: Bootstrap can complete Phase 8 rebuild
- **Side Benefit**: user-config.nix is now version controlled (proper nix-darwin practice)

### Why user-config.nix Should Be Tracked
In nix-darwin and NixOS configurations, user-config.nix (or equivalent) is typically git-tracked because:

1. **Not Sensitive**: Contains username, email, hostname - not secrets
2. **Configuration**: Part of system configuration, should be version controlled
3. **Flake Requirement**: Flakes need files to be tracked for evaluation
4. **Reproducibility**: Tracked config ensures reproducible builds
5. **Best Practice**: Example repos (mlgruby, etc.) all track user configs

**Secrets Management**: Actual secrets (passwords, keys) should go in:
- SOPS (Secrets OPerationS) - encrypted in repo
- age encryption
- External secret stores
These are planned for P1 phase (not P0).

### Manual Fix for VM (Immediate)
FX can fix the current VM immediately by running:

```bash
cd ~/Documents/nix-install
git add user-config.nix
git commit -m "chore: add user-config.nix for standard profile"
sudo darwin-rebuild switch --flake ~/Documents/nix-install#standard
```

### Why This Wasn't Caught Earlier
**Missing Git Integration**: The bootstrap design focused on file operations (copy, verify) but didn't consider Nix flake's git dependency. The verification step checked file existence but not git tracking status.

**Test Gap**: BATS tests didn't mock git operations or flake evaluation context.

**Lesson Learned**: When working with Nix flakes, always ensure required files are git-tracked before evaluation.

### Relationship to Other Fixes
This completes the Phase 8 hotfix quadrology:
- **Hotfix #4**: Profile persistence (installProfile in user-config.nix) ✅
- **Hotfix #5**: darwin-rebuild sudo requirement ✅
- **Hotfix #6**: Profile extraction regex fix ✅
- **Hotfix #7**: Git tracking for flake evaluation ✅ **← THIS FIX**

Together with Hotfixes #1-3 (Phase 5-6), these enable complete bootstrap flow from Phase 1 through Phase 8.

---

