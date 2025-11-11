# VM Testing Guide: Phase 7 Repository Clone

## Overview

This guide provides comprehensive test scenarios for validating Phase 7 (Repository Clone) of the bootstrap process. Testing should be performed in a Parallels macOS VM before deploying to physical hardware.

**Story**: 01.7-001 - Full Repository Clone
**Phase**: 7 of 10
**Prerequisites**: Phases 1-6 completed successfully (SSH key uploaded and GitHub connection tested)

## VM Setup Requirements

### Minimum VM Specifications
- **OS**: macOS Sonoma 14.0 or newer
- **CPU**: 4+ cores
- **RAM**: 8+ GB
- **Disk**: 100+ GB free space
- **Network**: Active internet connection

### Pre-Test Configuration
```bash
# Ensure clean environment
rm -rf ~/Documents/nix-install
rm -rf /tmp/nix-bootstrap

# Verify GitHub SSH key is set up (from Phase 6)
ssh -T git@github.com

# Verify user-config.nix exists from Phase 2
ls -l /tmp/nix-bootstrap/user-config.nix
```

## Test Scenarios

### Scenario 1: Happy Path - Fresh Clone

**Description**: Clone repository to ~/Documents/nix-install on a clean system with no existing repository.

#### Setup
```bash
# Ensure no existing repository
rm -rf ~/Documents/nix-install

# Ensure user-config.nix exists
ls -l /tmp/nix-bootstrap/user-config.nix

# Run bootstrap through Phase 7
./bootstrap.sh
```

#### Expected Behavior
1. Phase 7 starts with banner "PHASE 7: CLONING NIX-INSTALL REPOSITORY"
2. Step 1: Creates ~/Documents if missing (or confirms it exists)
3. Step 2: Checks for existing repository (finds none)
4. Step 3: Clones git@github.com:fxmartin/nix-install.git to ~/Documents/nix-install
5. Git clone output shows progress
6. Step 4: Copies /tmp/nix-bootstrap/user-config.nix to ~/Documents/nix-install/
7. Step 5: Verifies repository integrity:
   - ✓ Git directory exists
   - ✓ Flake configuration exists
   - ✓ User configuration exists
   - ✓ Git repository valid
8. Displays success message with repository path
9. Shows "Next: Phase 8 will perform initial Nix evaluation"

#### Validation Steps
```bash
# Verify repository directory exists
[ -d ~/Documents/nix-install ] && echo "✅ Directory exists"

# Verify .git directory
[ -d ~/Documents/nix-install/.git ] && echo "✅ Git directory exists"

# Verify flake.nix
[ -f ~/Documents/nix-install/flake.nix ] && echo "✅ flake.nix exists"

# Verify user-config.nix copied
[ -f ~/Documents/nix-install/user-config.nix ] && echo "✅ user-config.nix exists"

# Verify git repository is valid
cd ~/Documents/nix-install && git status && echo "✅ Git repo valid"

# Verify content matches
diff /tmp/nix-bootstrap/user-config.nix ~/Documents/nix-install/user-config.nix && echo "✅ Config content matches"
```

#### Pass/Fail Criteria
**PASS** if:
- Repository cloned to ~/Documents/nix-install
- .git directory exists
- flake.nix exists
- user-config.nix exists and matches /tmp version
- git status works without errors
- Phase completion message displays

**FAIL** if:
- Clone fails with error
- Any verification check fails
- user-config.nix not copied
- Git repository is invalid

---

### Scenario 2: Existing Repository - User Chooses Remove

**Description**: Test behavior when ~/Documents/nix-install already exists and user chooses to remove and re-clone.

#### Setup
```bash
# Create existing repository directory with content
mkdir -p ~/Documents/nix-install/.git
echo "Old content" > ~/Documents/nix-install/old_file.txt
echo "# Old config" > ~/Documents/nix-install/user-config.nix

# Run bootstrap through Phase 7
./bootstrap.sh
```

#### Expected Behavior
1. Phase 7 starts normally
2. Step 2: Detects existing repository
3. Displays warning banner: "EXISTING DIRECTORY DETECTED"
4. Shows warning: "Removing this directory will DELETE ALL CONTENTS"
5. Prompts: "Remove existing directory and re-clone? (y/n):"
6. **User enters 'y'**
7. Removes existing directory
8. Proceeds with clone (Steps 3-5 as in Scenario 1)
9. Success message displays

#### Validation Steps
```bash
# After completion, verify old files are gone
[ ! -f ~/Documents/nix-install/old_file.txt ] && echo "✅ Old files removed"

# Verify repository is fresh
cd ~/Documents/nix-install
git log --oneline | head -5

# Verify user-config.nix is from /tmp (fresh)
diff /tmp/nix-bootstrap/user-config.nix ~/Documents/nix-install/user-config.nix
```

#### Interactive Test Actions
1. When prompted "Remove existing directory and re-clone? (y/n):", type **'y'** and press Enter
2. Observe: Script should proceed to remove old directory and clone fresh

#### Pass/Fail Criteria
**PASS** if:
- Prompt displays correctly with warning
- Entering 'y' removes existing directory
- Fresh clone completes successfully
- Old files no longer present
- New repository is valid

**FAIL** if:
- Prompt doesn't appear
- Old directory not removed
- Clone fails after removal
- Old files still present

---

### Scenario 3: Existing Repository - User Chooses Skip

**Description**: Test behavior when user chooses to skip clone and use existing repository.

#### Setup
```bash
# Create valid existing repository
git clone git@github.com:fxmartin/nix-install.git ~/Documents/nix-install
cd ~/Documents/nix-install
echo "# Custom config" > ~/Documents/nix-install/user-config.nix

# Run bootstrap through Phase 7
./bootstrap.sh
```

#### Expected Behavior
1. Phase 7 starts normally
2. Step 2: Detects existing repository
3. Displays warning banner
4. Prompts: "Remove existing directory and re-clone? (y/n):"
5. **User enters 'n'**
6. Logs: "Skipping repository clone (using existing directory)"
7. Attempts to copy user-config.nix (skips because already exists)
8. Logs: "user-config.nix already exists in repository (preserving existing file)"
9. Verifies existing repository integrity
10. Success message displays with note about using existing repository

#### Validation Steps
```bash
# Verify user-config.nix was NOT overwritten
grep "Custom config" ~/Documents/nix-install/user-config.nix && echo "✅ Existing config preserved"

# Verify repository is still valid
cd ~/Documents/nix-install && git status && echo "✅ Repo still valid"
```

#### Interactive Test Actions
1. When prompted "Remove existing directory and re-clone? (y/n):", type **'n'** and press Enter
2. Observe: Script should skip clone and verify existing repository

#### Pass/Fail Criteria
**PASS** if:
- Entering 'n' skips clone
- Existing user-config.nix is preserved (not overwritten)
- Verification of existing repository succeeds
- Success message indicates using existing repository
- Phase completes successfully

**FAIL** if:
- Clone happens anyway
- user-config.nix is overwritten
- Verification fails on valid repository
- Script errors or aborts

---

### Scenario 4: Missing ~/Documents Directory

**Description**: Test behavior when ~/Documents directory doesn't exist.

#### Setup
```bash
# Remove Documents directory
rm -rf ~/Documents

# Verify it's gone
[ ! -d ~/Documents ] && echo "✅ Documents directory removed"

# Run bootstrap through Phase 7
./bootstrap.sh
```

#### Expected Behavior
1. Phase 7 starts
2. Step 1: Detects missing ~/Documents
3. Logs: "Creating ~/Documents directory..."
4. Creates ~/Documents with proper permissions
5. Logs: "✓ Documents directory created"
6. Continues with clone (Steps 2-5 as in Scenario 1)

#### Validation Steps
```bash
# Verify Documents created
[ -d ~/Documents ] && echo "✅ Documents exists"

# Check permissions (should be readable/writable)
ls -ld ~/Documents

# Verify repository cloned inside
[ -d ~/Documents/nix-install ] && echo "✅ Repo cloned"
```

#### Pass/Fail Criteria
**PASS** if:
- ~/Documents created automatically
- Permissions are correct (drwxr-xr-x or similar)
- Clone proceeds successfully
- All validation checks pass

**FAIL** if:
- Documents directory not created
- Permission errors occur
- Clone fails due to missing parent directory

---

### Scenario 5: Network Failure During Clone

**Description**: Test behavior when network connection fails or is interrupted during git clone.

#### Setup
```bash
# This test requires manual network disruption
# Option 1: Disconnect WiFi mid-clone
# Option 2: Use macOS Network Link Conditioner to simulate network loss

rm -rf ~/Documents/nix-install

# Run bootstrap through Phase 7
./bootstrap.sh

# Disconnect network when you see "Cloning repository from GitHub..."
```

#### Expected Behavior
1. Phase 7 starts
2. Step 3: Begins git clone
3. **Network disconnects mid-clone**
4. Git clone fails with error (e.g., "fatal: unable to access")
5. Script logs error: "Git clone failed"
6. Displays troubleshooting:
   - "1. Verify SSH connection: ssh -T git@github.com"
   - "2. Check GitHub key upload: gh ssh-key list"
   - "3. Verify network connection"
   - "4. Check disk space: df -h"
   - "5. Try manual clone: git clone git@github.com:fxmartin/nix-install.git"
7. Phase returns failure (exit 1)
8. Bootstrap terminates

#### Validation Steps
```bash
# After failure, check for partial clone
ls -la ~/Documents/nix-install 2>/dev/null
# May or may not exist depending on when network failed

# Verify error message displayed
# (Manual verification during test)
```

#### Recovery Test
```bash
# Reconnect network
# Remove partial clone if exists
rm -rf ~/Documents/nix-install

# Re-run bootstrap
./bootstrap.sh
# Should succeed on second attempt
```

#### Pass/Fail Criteria
**PASS** if:
- Clone failure is detected
- Error message displays
- Troubleshooting guide shows
- Script exits gracefully (no crash)
- Re-running after network restore succeeds

**FAIL** if:
- Script hangs indefinitely
- No error message shown
- Script crashes or throws uncaught error
- Cannot recover by re-running

---

### Scenario 6: SSH Authentication Failure

**Description**: Test behavior when SSH key authentication fails (invalid or missing key).

#### Setup
```bash
# Rename SSH keys to simulate missing authentication
mv ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.bak
mv ~/.ssh/id_ed25519.pub ~/.ssh/id_ed25519.pub.bak

# Verify SSH test fails
ssh -T git@github.com
# Should fail with "Permission denied (publickey)"

# Run bootstrap through Phase 7
./bootstrap.sh
```

#### Expected Behavior
1. Phase 7 starts
2. Step 3: Attempts git clone
3. Git clone fails with authentication error
4. Error message: "Git clone failed"
5. Troubleshooting guide displays
6. Script exits

#### Validation Steps
```bash
# Verify no repository created
[ ! -d ~/Documents/nix-install ] && echo "✅ No partial repo created"
```

#### Recovery Test
```bash
# Restore SSH keys
mv ~/.ssh/id_ed25519.bak ~/.ssh/id_ed25519
mv ~/.ssh/id_ed25519.pub.bak ~/.ssh/id_ed25519.pub

# Re-test SSH
ssh -T git@github.com

# Re-run bootstrap
./bootstrap.sh
```

#### Pass/Fail Criteria
**PASS** if:
- Authentication failure detected
- Error message displays
- Troubleshooting shows SSH-related steps
- Script exits cleanly
- Re-running after key restore succeeds

**FAIL** if:
- Auth error not detected
- Script provides incorrect troubleshooting
- Script hangs or crashes

**NOTE**: This scenario is less likely since Phase 6 (SSH connection test) should have caught authentication issues. However, it's possible keys were removed/modified between Phase 6 and Phase 7.

---

### Scenario 7: Disk Space Insufficient

**Description**: Test behavior when insufficient disk space available for clone.

#### Setup
```bash
# Create large file to fill disk near capacity
# WARNING: This test requires a VM with limited disk space
# OR use a separate volume with limited space

# Check current free space
df -h ~/Documents

# Run bootstrap through Phase 7
./bootstrap.sh
```

#### Expected Behavior
1. Phase 7 starts
2. Step 3: Checks available disk space
3. If space < 500MB, logs warning:
   - "Low disk space detected (less than 500MB available)"
   - "Available: XXX MB"
   - "Recommended: 500MB"
4. Attempts clone anyway (may fail)
5. If clone fails due to disk full:
   - Error: "fatal: write error: No space left on device"
   - Error message: "Git clone failed"
   - Troubleshooting includes: "4. Check disk space: df -h"

#### Validation Steps
```bash
# Check disk space
df -h ~/Documents

# Verify clone status
ls -la ~/Documents/nix-install 2>/dev/null
```

#### Recovery Test
```bash
# Free up disk space
rm -rf ~/Documents/nix-install  # Remove partial clone
# Delete other large files or expand VM disk

# Re-run bootstrap
./bootstrap.sh
```

#### Pass/Fail Criteria
**PASS** if:
- Low disk space warning displays when < 500MB
- Clone proceeds if enough space
- Clone fails gracefully if disk full
- Troubleshooting mentions disk space
- Recovery possible after freeing space

**FAIL** if:
- No warning for low disk space
- Script crashes on disk full
- Misleading error messages

---

### Scenario 8: Corrupted Existing Repository

**Description**: Test behavior when existing ~/Documents/nix-install has corrupted .git directory.

#### Setup
```bash
# Create directory with corrupted .git
mkdir -p ~/Documents/nix-install/.git
echo "corrupted" > ~/Documents/nix-install/.git/config
touch ~/Documents/nix-install/flake.nix

# Verify git commands fail
cd ~/Documents/nix-install && git status
# Should fail with "fatal: not a git repository" or similar

# Run bootstrap through Phase 7
./bootstrap.sh
```

#### Expected Behavior
1. Phase 7 starts
2. Step 2: Detects existing repository
3. Prompts to remove or skip
4. **If user chooses 'n' (skip)**:
   - Attempts to verify existing repository
   - Verification fails: "✗ Git repository corrupted or invalid"
   - Error: "Repository verification failed"
   - Suggests: "Consider removing and re-cloning"
   - Phase fails, bootstrap terminates
5. **If user chooses 'y' (remove)**:
   - Removes corrupted directory
   - Clones fresh repository
   - Verification succeeds
   - Phase completes

#### Interactive Test Actions
**Test 8A**: Choose 'n' (skip)
1. When prompted, enter 'n'
2. Observe verification failure and error message

**Test 8B**: Re-run and choose 'y' (remove)
1. Run bootstrap again
2. When prompted, enter 'y'
3. Observe successful removal and fresh clone

#### Validation Steps
```bash
# After Test 8A (skip with corrupted repo)
# Should see verification failure

# After Test 8B (remove and re-clone)
cd ~/Documents/nix-install && git status && echo "✅ Repo now valid"
```

#### Pass/Fail Criteria
**PASS** if:
- Corrupted repository detected during verification
- Error message is clear and helpful
- User can choose to remove and re-clone
- Fresh clone succeeds and is valid

**FAIL** if:
- Corrupted repository not detected
- Verification passes invalid repository
- Script crashes or provides unclear error
- Cannot recover by removing and re-cloning

---

## Test Execution Checklist

Use this checklist to track completion of all test scenarios:

- [ ] **Scenario 1**: Happy Path - Fresh Clone
- [ ] **Scenario 2**: Existing Repository - User Chooses Remove
- [ ] **Scenario 3**: Existing Repository - User Chooses Skip
- [ ] **Scenario 4**: Missing ~/Documents Directory
- [ ] **Scenario 5**: Network Failure During Clone
- [ ] **Scenario 6**: SSH Authentication Failure
- [ ] **Scenario 7**: Disk Space Insufficient
- [ ] **Scenario 8**: Corrupted Existing Repository

## Common Issues and Solutions

### Issue: "Permission denied (publickey)" during clone
**Cause**: SSH key not uploaded to GitHub or ssh-agent not running
**Solution**: Run Phase 6 again to upload SSH key
```bash
ssh -T git@github.com  # Should succeed before Phase 7
```

### Issue: "~/Documents/nix-install already exists"
**Cause**: Leftover from previous test or bootstrap run
**Solution**: Remove directory before re-testing
```bash
rm -rf ~/Documents/nix-install
```

### Issue: user-config.nix not found in /tmp
**Cause**: Phase 2 (User Configuration) not completed
**Solution**: Ensure Phase 2 completed successfully
```bash
ls -l /tmp/nix-bootstrap/user-config.nix
cat /tmp/nix-bootstrap/user-config.nix
```

### Issue: Git clone is extremely slow
**Cause**: Network throttling or VM network configuration
**Solution**: Check VM network adapter settings, ensure bridged or shared network mode

### Issue: Verification fails with "flake.nix missing"
**Cause**: Partial or corrupted clone
**Solution**: Remove directory and re-clone
```bash
rm -rf ~/Documents/nix-install
./bootstrap.sh  # Re-run from Phase 7
```

## Success Metrics

**Phase 7 is considered successful when**:

1. ✅ Repository clones to ~/Documents/nix-install on fresh system
2. ✅ Existing directory detection works correctly
3. ✅ Interactive prompt allows user to choose remove or skip
4. ✅ user-config.nix copied from /tmp and preserved if exists
5. ✅ All verification checks pass (git dir, flake.nix, user-config.nix, git status)
6. ✅ Error handling works for network, auth, disk space issues
7. ✅ Troubleshooting messages are clear and actionable
8. ✅ Phase completes within reasonable time (< 2 minutes on good network)

## Test Environment Cleanup

After completing all test scenarios:

```bash
# Remove test repository
rm -rf ~/Documents/nix-install

# Clean up bootstrap temp directory
rm -rf /tmp/nix-bootstrap

# Restore SSH keys if backed up (Scenario 6)
[ -f ~/.ssh/id_ed25519.bak ] && mv ~/.ssh/id_ed25519.bak ~/.ssh/id_ed25519
[ -f ~/.ssh/id_ed25519.pub.bak ] && mv ~/.ssh/id_ed25519.pub.bak ~/.ssh/id_ed25519.pub

# Verify clean state
[ ! -d ~/Documents/nix-install ] && echo "✅ Test environment clean"
```

## Next Steps After VM Testing

Once all scenarios pass in VM:

1. Document any issues encountered and solutions
2. Update epic file (docs/development/stories/epic-01-feature-01.7.md) with test results
3. Create pull request with implementation and test results
4. **Only after PR approval**: Test on physical MacBook Pro M3 Max (Power profile)
5. Then test on MacBook Air #1 and #2 (Standard profile)

## Reporting Test Results

For each scenario, document:
- **Pass/Fail**: Did the scenario pass all criteria?
- **Duration**: How long did the phase take?
- **Issues**: Any unexpected behavior or errors?
- **Screenshots**: Capture key moments (prompts, errors, success messages)
- **Logs**: Save relevant log output for debugging

Example test report format:
```
Scenario 1: Happy Path - Fresh Clone
Status: ✅ PASS
Duration: 45 seconds
Issues: None
Notes: Clone completed successfully, all verification checks passed
```

---

**Document Version**: 1.0
**Last Updated**: 2025-01-XX
**Author**: Claude (bash-zsh-macos-engineer)
**Story**: 01.7-001 - Full Repository Clone
