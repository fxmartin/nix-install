# Testing Guide: Story 01.6-003 - GitHub SSH Connection Test

## Overview
**Story**: 01.6-003 - GitHub SSH Connection Test with Retry Mechanism
**Status**: ✅ CODE COMPLETE - Ready for VM Testing by FX
**Branch**: `feature/01.6-003-ssh-connection-test`
**Commit**: df82606

## Implementation Summary

### Functions Added (5 total, ~234 lines)
1. **test_github_ssh_connection()** - Core SSH connection test (41 lines)
   - Runs `ssh -T git@github.com` and captures output
   - Detects success via "successfully authenticated" in output
   - Extracts GitHub username from success message
   - Handles the quirk: `ssh -T` returns exit code 1 on success!

2. **display_ssh_troubleshooting()** - Troubleshooting help (35 lines)
   - 5 categories of common SSH connection issues
   - Actionable guidance for each issue
   - Links to GitHub SSH keys page
   - Manual test command instructions

3. **retry_ssh_connection()** - Retry loop (35 lines)
   - Up to 3 retry attempts
   - 2-second delay between attempts
   - Progress display: "Attempt 1 of 3", "Attempt 2 of 3", etc.
   - Stops on first success

4. **prompt_continue_without_ssh()** - Abort prompt (42 lines)
   - Interactive yes/no prompt after all failures
   - Input validation (only y/n accepted)
   - Warning message if user continues
   - Abort message if user chooses to exit

5. **test_github_ssh_phase()** - Phase orchestration (48 lines)
   - Calls retry_ssh_connection()
   - Displays troubleshooting on failure
   - Prompts user to continue or abort
   - Returns 0 on success, 1 on abort

### Integration Point
- **File**: bootstrap.sh
- **Location**: Line 3480 in main() flow
- **Position**: After `upload_github_key_phase()` (Phase 6 continued)
- **Phase**: Phase 6 (continued) - GitHub SSH Connection Test

### Code Quality Metrics
- **Shellcheck**: 0 errors, 0 warnings ✅
- **Bash Syntax**: PASSED ✅
- **BATS Tests**: 80 tests created (tests/bootstrap_ssh_test.bats)
- **Bootstrap Size**: 3284 → 3518 lines (+234 lines)
- **TDD Compliance**: Tests written before implementation ✅

## Manual Testing Scenarios

FX should test these 7 scenarios in a Parallels macOS VM to validate the implementation:

### Scenario 1: Successful SSH Connection (Happy Path)
**Goal**: Verify SSH test passes on first attempt when key is correctly configured

**Setup**:
1. Run bootstrap through Phase 6 (SSH Key Generation and Upload)
2. Ensure SSH key was successfully uploaded to GitHub
3. Ensure OAuth authorization was completed (if automated flow used)

**Expected Behavior**:
1. Phase 6 (continued) displays: "GITHUB SSH CONNECTION TEST"
2. Shows: "Attempt 1 of 3..."
3. SSH test succeeds immediately
4. Displays: "✓ Successfully authenticated as GitHub user: [username]"
5. Shows: "✓ GitHub SSH connection test completed successfully"
6. Proceeds to Phase 7 without prompting user

**Validation**:
- No retry attempts needed
- Username extracted correctly from GitHub response
- Phase completes in <5 seconds
- Bootstrap continues to Phase 7 (or displays "Phases 7-10 not yet implemented")

---

### Scenario 2: Retry Success on Attempt 2
**Goal**: Verify retry mechanism works when first attempt fails

**Setup**:
1. Run bootstrap through SSH key upload phase
2. Delay SSH key propagation by waiting only 2-3 seconds after upload
3. First SSH test may fail due to GitHub key propagation delay

**Expected Behavior**:
1. Attempt 1 fails with error message
2. Displays: "Connection test failed. Waiting 2 seconds before retry..."
3. 2-second delay occurs
4. Attempt 2 succeeds
5. Displays: "✓ GitHub SSH connection test PASSED"
6. Proceeds to Phase 7

**Validation**:
- Retry counter increments correctly: "Attempt 1 of 3", "Attempt 2 of 3"
- Sleep duration is 2 seconds between attempts
- Success is detected on second attempt
- No third attempt needed
- Phase completes successfully

---

### Scenario 3: Retry Success on Attempt 3
**Goal**: Verify all 3 retry attempts work correctly

**Setup**:
1. Create intentional SSH connectivity issues (e.g., temporarily block port 22)
2. Allow connection after 2nd failure

**Expected Behavior**:
1. Attempt 1 fails
2. Wait 2 seconds
3. Attempt 2 fails
4. Wait 2 seconds
5. Attempt 3 succeeds
6. Displays success message and proceeds

**Validation**:
- All 3 attempt counters display correctly
- Sleep occurs only after attempt 1 and 2 (not after attempt 3)
- Success on final attempt is detected and honored
- Phase completes successfully

---

### Scenario 4: All Retries Fail - User Chooses to Continue
**Goal**: Verify graceful degradation when SSH test fails but user wants to proceed

**Setup**:
1. Do NOT upload SSH key to GitHub (skip key upload or use wrong key)
2. All 3 SSH test attempts will fail
3. Prepare to input "y" when prompted

**Expected Behavior**:
1. All 3 attempts fail with error messages
2. Displays: "✗ All 3 SSH connection attempts FAILED"
3. Shows troubleshooting help with 5 categories:
   - OAuth Authorization
   - Key Upload Verification
   - SSH Key Passphrase
   - Manual Test
   - Network Connectivity
4. Prompts: "Continue without SSH test? (y/n) [not recommended]:"
5. User enters "y"
6. Displays: "⚠️ WARNING: Continuing without SSH test validation"
7. Warns: "Repository cloning in Phase 7 may fail..."
8. Phase completes with warnings
9. Bootstrap continues (will fail at Phase 7 if SSH truly broken)

**Validation**:
- All 3 retry attempts executed
- Troubleshooting help is clear and actionable
- Prompt accepts "y", "Y", "yes", "YES"
- Warning message is prominent
- Phase returns 0 (success with warnings)
- Bootstrap continues to Phase 7

---

### Scenario 5: All Retries Fail - User Chooses to Abort
**Goal**: Verify user can abort bootstrap when SSH test fails

**Setup**:
1. Same as Scenario 4 (SSH key not uploaded or wrong key)
2. Prepare to input "n" when prompted

**Expected Behavior**:
1. All 3 attempts fail
2. Troubleshooting help displays
3. Prompts: "Continue without SSH test? (y/n) [not recommended]:"
4. User enters "n"
5. Displays: "Bootstrap aborted by user"
6. Shows: "Please fix SSH connection issues and re-run the bootstrap script"
7. Phase returns 1 (failure)
8. Bootstrap exits with error code 1
9. Main script displays: "GitHub SSH connection test failed or aborted by user"
10. Main script displays: "Bootstrap process terminated."

**Validation**:
- Prompt accepts "n", "N", "no", "NO"
- Abort message is clear
- Exit code is 1 (failure)
- Bootstrap stops cleanly (no crash or hang)
- User can re-run bootstrap after fixing SSH key

---

### Scenario 6: Invalid User Input - Prompt Validation
**Goal**: Verify prompt_continue_without_ssh() handles invalid input gracefully

**Setup**:
1. Same as Scenario 4 (force SSH test failure)
2. Prepare to test various invalid inputs

**Test Sequence**:
1. When prompted, enter: "maybe" → Expect: "Invalid input" error, re-prompt
2. When prompted, enter: "yes please" → Expect: "Invalid input" error, re-prompt
3. When prompted, enter: "123" → Expect: "Invalid input" error, re-prompt
4. When prompted, enter: "  y  " (with spaces) → Expect: Accept as "y", continue with warning

**Expected Behavior**:
- Invalid inputs trigger: "Invalid input: '[input]'"
- Re-prompts: "Please enter 'y' (yes) or 'n' (no)"
- Whitespace is trimmed automatically ("  y  " becomes "y")
- Prompt loops until valid input received
- Valid input ("y" or "n") is accepted and processed

**Validation**:
- Input validation is robust
- Error messages are helpful
- Prompt doesn't exit or crash on invalid input
- Whitespace handling works correctly
- Case-insensitive: Y/y/YES/yes and N/n/NO/no all work

---

### Scenario 7: Network Connectivity Issues
**Goal**: Verify SSH test handles network/connectivity failures gracefully

**Setup**:
1. Temporarily disconnect VM network or block GitHub (add firewall rule)
2. Run bootstrap to SSH connection test phase
3. Re-enable network after testing failure behavior

**Expected Behavior**:
1. SSH test attempts fail with network error (e.g., "Connection timed out", "Network unreachable")
2. Error output displays actual SSH error message
3. Retry mechanism attempts 3 times
4. Troubleshooting help mentions network connectivity (Category 5)
5. User can choose to abort or continue
6. If network restored and user retries bootstrap, test succeeds

**Validation**:
- Network errors are captured and displayed
- Error message includes actual SSH output (not just generic "failed")
- Troubleshooting section #5 provides network guidance
- Bootstrap doesn't hang or timeout indefinitely
- User can abort cleanly

---

## Testing Checklist

After completing all 7 scenarios, verify:

- [ ] **Scenario 1**: SSH test passes on first attempt (happy path)
- [ ] **Scenario 2**: Retry succeeds on attempt 2
- [ ] **Scenario 3**: Retry succeeds on attempt 3
- [ ] **Scenario 4**: User continues after all failures (graceful degradation)
- [ ] **Scenario 5**: User aborts after all failures (clean exit)
- [ ] **Scenario 6**: Invalid input handling and prompt validation
- [ ] **Scenario 7**: Network connectivity issues handled gracefully

### Additional Validation
- [ ] All error messages are actionable and helpful
- [ ] Troubleshooting help covers common issues
- [ ] GitHub username extraction works correctly
- [ ] Retry counter displays accurately ("Attempt X of 3")
- [ ] Sleep duration is 2 seconds between retries
- [ ] No sleep after final attempt (efficiency)
- [ ] Phase timing is reasonable (<30 seconds for 3 attempts)
- [ ] Bootstrap continues correctly after successful test
- [ ] Bootstrap aborts cleanly on user request
- [ ] No shellcheck warnings or errors
- [ ] Code follows project style and conventions

## Common Issues and Debugging

### Issue: SSH test hangs indefinitely
**Cause**: SSH command waiting for passphrase or host key confirmation
**Debug**: Run `ssh -T git@github.com` manually to see what prompts appear
**Fix**: Ensure ssh-agent has key loaded, known_hosts has github.com

### Issue: False negatives (test fails but key is valid)
**Cause**: GitHub key propagation delay (up to 60 seconds after upload)
**Debug**: Wait 60 seconds after upload, then manually test: `ssh -T git@github.com`
**Fix**: Retry mechanism should handle this (2-second delay × 3 attempts = 6 seconds)

### Issue: Username not extracted from success message
**Cause**: GitHub response format changed or regex mismatch
**Debug**: Capture output: `ssh -T git@github.com 2>&1 | tee ssh-output.txt`
**Fix**: Update username extraction regex in test_github_ssh_connection()

### Issue: Exit code confusion (returns 1 but succeeds)
**Cause**: `ssh -T git@github.com` returns exit code 1 by design (no shell access)
**Note**: This is EXPECTED behavior. Code checks output content, not exit code
**Validation**: Function looks for "successfully authenticated" in output

## Success Criteria

Story 01.6-003 is considered **VM TESTED & VERIFIED** when:

1. ✅ All 7 manual test scenarios pass
2. ✅ Error messages are actionable and helpful
3. ✅ Retry mechanism works correctly (3 attempts, 2-second delays)
4. ✅ User can abort or continue after failures
5. ✅ Troubleshooting help is comprehensive
6. ✅ Username extraction works (when SSH succeeds)
7. ✅ No regressions in previous phases
8. ✅ Bootstrap continues to Phase 7 or later on success
9. ✅ Bootstrap aborts cleanly on user request
10. ✅ Code quality maintained (shellcheck, syntax, style)

Once all criteria met, update:
- `DEVELOPMENT.md`: Change status to "✅ COMPLETED & VM TESTED"
- `stories/epic-01-bootstrap-installation.md`: Check "Tested in VM" checkbox
- Merge feature branch to main via pull request

## Next Steps After VM Testing

1. If tests pass: Merge to main and proceed to Story 01.7-001 (Repository Cloning)
2. If tests fail: Document issues, create hotfix branch, iterate
3. Update epic progress: 14/19 stories complete, 88/113 points (77.9%)

---

**Testing performed by**: FX
**Testing date**: [To be filled after VM testing]
**Result**: [PASS/FAIL] [To be filled after VM testing]
**Notes**: [Any observations or issues found during testing]
