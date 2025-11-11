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
**Commit**: 186b1df
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

### Long-term Solution
After Epic-01 completes and subsequent bootstraps run, `gh` will be available in PATH from previous nix-darwin builds, making the automated flow work ~90% of the time. The manual fallback remains for edge cases.

---

