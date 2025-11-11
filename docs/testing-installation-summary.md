# ABOUTME: VM Testing Guide for Phase 9 - Installation Summary (Story 01.8-001)
# ABOUTME: Comprehensive test scenarios for manual VM validation of installation summary display

# VM Testing Guide: Phase 9 - Installation Summary

## Story Context
- **Story ID**: 01.8-001
- **Story Name**: Installation Summary & Next Steps
- **Story Points**: 3
- **Feature**: 01.8 - Installation Completion
- **Phase**: Phase 9 (Final phase of bootstrap)

## Test Environment Setup

### VM Requirements
- **Platform**: Parallels Desktop or VMware Fusion
- **OS**: macOS Sonoma 14.0+ (fresh install)
- **CPU**: 4+ cores
- **RAM**: 8+ GB
- **Disk**: 100+ GB
- **Snapshot**: Create clean snapshot before testing

### Branch Under Test
```bash
# Branch: feature/01.8-001
# Test complete bootstrap flow (Phases 1-9)
```

## Test Scenarios

### Scenario 1: Standard Profile - Complete Bootstrap Flow
**Objective**: Verify complete bootstrap with Standard profile shows correct summary

**Pre-conditions**:
- Fresh macOS VM (clean snapshot)
- Internet connectivity verified
- No previous Nix installation

**Test Steps**:
1. Download and run bootstrap script:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/feature/01.8-001/setup.sh | bash
   ```
2. Select **Standard** profile when prompted
3. Complete all user prompts (name, email, GitHub username)
4. Authorize GitHub CLI when prompted (OAuth flow)
5. Wait for all 9 phases to complete
6. Observe Phase 9 summary output

**Expected Results**:
- ✅ Total installation time displayed (format: "X minutes Y seconds")
- ✅ Nix version shown (e.g., "nix (Nix) 2.18.0")
- ✅ nix-darwin and Home Manager confirmed
- ✅ Profile shown as "standard"
- ✅ App count shown as "47 applications" (approximate)
- ✅ Next steps: 4 numbered steps
  - Step 1: Restart terminal or `source ~/.zshrc`
  - Step 2: Activate licensed applications
  - Step 3: Install Office 365 manually
  - Step 4: **NOT PRESENT** (no Ollama for Standard profile)
- ✅ Useful commands: rebuild, update, health-check, cleanup
- ✅ Manual activation apps: 1Password, Office 365
- ✅ **Parallels Desktop NOT listed** (Power profile only)
- ✅ Documentation paths shown
- ✅ Final success banner displayed

**Actual Results**:
```
[Record actual output and any deviations]
```

**Pass/Fail**: ☐ Pass ☐ Fail

**Notes**:
```
[Any observations, issues, or deviations]
```

---

### Scenario 2: Power Profile - Complete Bootstrap Flow
**Objective**: Verify complete bootstrap with Power profile shows correct summary with Ollama

**Pre-conditions**:
- Fresh macOS VM (clean snapshot)
- Internet connectivity verified
- No previous Nix installation

**Test Steps**:
1. Download and run bootstrap script
2. Select **Power** profile when prompted
3. Complete all user prompts
4. Authorize GitHub CLI
5. Wait for all 9 phases to complete (including Ollama model pulls)
6. Observe Phase 9 summary output

**Expected Results**:
- ✅ Total installation time displayed (likely 20-30 minutes due to Ollama)
- ✅ Nix version shown
- ✅ nix-darwin and Home Manager confirmed
- ✅ Profile shown as "power"
- ✅ App count shown as "51 applications" (approximate)
- ✅ Next steps: **5 numbered steps** (Power profile has extra step)
  - Step 1: Restart terminal
  - Step 2: Activate licensed applications
  - Step 3: Install Office 365 manually
  - Step 4: **Verify Ollama models: ollama list** (Power profile only)
- ✅ Useful commands: rebuild, update, health-check, cleanup
- ✅ Manual activation apps: 1Password, Office 365, **Parallels Desktop**
- ✅ Documentation paths shown
- ✅ Final success banner displayed

**Actual Results**:
```
[Record actual output and any deviations]
```

**Pass/Fail**: ☐ Pass ☐ Fail

**Notes**:
```
[Any observations, issues, or deviations]
```

---

### Scenario 3: Duration Formatting - Short Install (<5 minutes)
**Objective**: Verify duration formatting for very short installations

**Pre-conditions**:
- VM with Nix and nix-darwin already installed (re-run scenario)
- Most components will be skipped due to idempotency

**Test Steps**:
1. Re-run bootstrap script on VM that already completed bootstrap
2. Idempotency will skip most phases (fast completion)
3. Observe Phase 9 duration display

**Expected Results**:
- ✅ Duration shown in "X minutes Y seconds" format
- ✅ Duration accurate (likely < 5 minutes)
- ✅ No negative duration
- ✅ No formatting errors (e.g., "-1 seconds")

**Actual Results**:
```
[Record actual duration and format]
```

**Pass/Fail**: ☐ Pass ☐ Fail

**Notes**:
```
[Duration formatting observations]
```

---

### Scenario 4: Duration Formatting - Long Install (>20 minutes)
**Objective**: Verify duration formatting for installations exceeding 1 hour (if applicable)

**Pre-conditions**:
- Fresh VM (Power profile)
- Slow network connection (or simulate with network throttling)

**Test Steps**:
1. Run bootstrap with Power profile
2. Observe total installation time
3. Check duration formatting in Phase 9

**Expected Results**:
- ✅ If duration > 60 minutes: "X hours Y minutes" format
- ✅ If duration < 60 minutes: "X minutes Y seconds" format
- ✅ Duration accurate
- ✅ Plural/singular grammar correct ("1 hour" vs "2 hours")

**Actual Results**:
```
[Record actual duration and format]
```

**Pass/Fail**: ☐ Pass ☐ Fail

**Notes**:
```
[Duration formatting observations for long installs]
```

---

### Scenario 5: Profile-Specific Content Validation
**Objective**: Verify profile-specific content appears only for correct profile

**Pre-conditions**:
- Two VMs: one Standard, one Power

**Test Steps**:
1. Complete bootstrap on **Standard profile** VM
2. Note Phase 9 summary content
3. Complete bootstrap on **Power profile** VM
4. Note Phase 9 summary content
5. Compare the two summaries

**Expected Results**:

**Standard Profile**:
- ✅ Step 4 (Ollama verification) **NOT PRESENT**
- ✅ Parallels Desktop **NOT in manual activation list**
- ✅ App count: ~47

**Power Profile**:
- ✅ Step 4 (Ollama verification) **PRESENT**
- ✅ Parallels Desktop **IN manual activation list**
- ✅ App count: ~51

**Actual Results**:
```
Standard Profile Summary:
[Record Step 4 presence/absence and Parallels listing]

Power Profile Summary:
[Record Step 4 presence/absence and Parallels listing]
```

**Pass/Fail**: ☐ Pass ☐ Fail

**Notes**:
```
[Profile-specific content observations]
```

---

### Scenario 6: Component Display Validation
**Objective**: Verify all installed components are correctly displayed

**Pre-conditions**:
- Fresh VM (either profile)

**Test Steps**:
1. Complete bootstrap
2. Observe Phase 9 "Components Installed" section
3. Verify each component manually

**Expected Results**:
- ✅ Nix version displayed and accurate (run `nix --version`)
- ✅ nix-darwin confirmed (run `darwin-rebuild --version`)
- ✅ Home Manager confirmed (run `home-manager --version`)
- ✅ Profile name matches user selection
- ✅ App count reasonable (47-51 range)

**Manual Verification Commands**:
```bash
# Verify Nix
nix --version

# Verify nix-darwin
darwin-rebuild --version

# Verify Home Manager (if available)
home-manager --version || echo "Home Manager not in PATH yet"

# Check profile in user-config.nix
cat ~/Documents/nix-install/user-config.nix | grep -A 1 "installProfile"

# Count installed apps (approximate)
brew list --cask | wc -l
ls /Applications | wc -l
```

**Actual Results**:
```
Nix version: [actual]
nix-darwin version: [actual]
Home Manager version: [actual]
Profile: [actual]
App count (brew): [actual]
App count (/Applications): [actual]
```

**Pass/Fail**: ☐ Pass ☐ Fail

**Notes**:
```
[Component display observations]
```

---

### Scenario 7: Documentation Path Validation
**Objective**: Verify documentation paths are accurate and accessible

**Pre-conditions**:
- Bootstrap completed

**Test Steps**:
1. Observe Phase 9 documentation paths
2. Verify paths exist and are accessible

**Expected Results**:
- ✅ README.md path: `~/Documents/nix-install/README.md`
- ✅ docs/ directory path: `~/Documents/nix-install/docs/`
- ✅ Both paths exist and are accessible

**Manual Verification Commands**:
```bash
# Verify README.md exists
ls -lh ~/Documents/nix-install/README.md

# Verify docs/ directory exists
ls -lh ~/Documents/nix-install/docs/
```

**Actual Results**:
```
README.md: [exists/missing]
docs/ directory: [exists/missing]
```

**Pass/Fail**: ☐ Pass ☐ Fail

**Notes**:
```
[Documentation path observations]
```

---

### Scenario 8: Command Reference Validation
**Objective**: Verify all useful commands are displayed and functional

**Pre-conditions**:
- Bootstrap completed

**Test Steps**:
1. Observe Phase 9 "Useful Commands" section
2. Test each command exists and is functional

**Expected Results**:
- ✅ `rebuild` command mentioned
- ✅ `update` command mentioned
- ✅ `health-check` command mentioned
- ✅ `cleanup` command mentioned
- ✅ Each command has brief description

**Manual Verification Commands**:
```bash
# Verify commands exist (these may be aliases defined in shell config)
which rebuild || echo "rebuild alias not yet defined (restart terminal)"
which update || echo "update alias not yet defined (restart terminal)"
which health-check || echo "health-check alias not yet defined (restart terminal)"
which cleanup || echo "cleanup alias not yet defined (restart terminal)"
```

**Actual Results**:
```
rebuild: [available/not available]
update: [available/not available]
health-check: [available/not available]
cleanup: [available/not available]
```

**Pass/Fail**: ☐ Pass ☐ Fail

**Notes**:
```
[Command reference observations - Note: Commands may not be available until terminal restart]
```

---

### Scenario 9: Summary Formatting and Readability
**Objective**: Verify summary is professional, readable, and well-formatted

**Pre-conditions**:
- Bootstrap completed

**Test Steps**:
1. Observe Phase 9 summary output
2. Evaluate formatting, alignment, and readability

**Expected Results**:
- ✅ Banner lines aligned (═══════════)
- ✅ Sections clearly separated
- ✅ Text aligned and readable
- ✅ No broken formatting (missing newlines, double newlines)
- ✅ Professional appearance
- ✅ Color usage appropriate (if any)

**Subjective Evaluation**:
```
Formatting Quality: [1-5 stars]
Readability: [1-5 stars]
Professional Appearance: [1-5 stars]
Overall Impression: [comments]
```

**Pass/Fail**: ☐ Pass ☐ Fail

**Notes**:
```
[Formatting and readability observations]
```

---

### Scenario 10: Edge Case - Missing Nix Version
**Objective**: Verify graceful handling if Nix version cannot be determined

**Pre-conditions**:
- Bootstrap completed
- Temporarily break Nix PATH (for testing only)

**Test Steps**:
1. Complete bootstrap normally
2. Modify PATH to hide `nix` binary (for testing)
3. Re-run Phase 9 summary function (if possible to isolate)

**Expected Results**:
- ✅ No crash or error
- ✅ Graceful fallback message (e.g., "Nix (version unknown)")
- ✅ Summary continues to display other sections

**Notes**:
This is an advanced edge case test. May require code inspection rather than full VM test.

**Pass/Fail**: ☐ Pass ☐ Fail

**Observations**:
```
[Edge case handling observations]
```

---

## Test Summary

### Overall Results

| Scenario | Pass/Fail | Notes |
|----------|-----------|-------|
| 1. Standard Profile Complete | ☐ | |
| 2. Power Profile Complete | ☐ | |
| 3. Short Duration Formatting | ☐ | |
| 4. Long Duration Formatting | ☐ | |
| 5. Profile-Specific Content | ☐ | |
| 6. Component Display | ☐ | |
| 7. Documentation Paths | ☐ | |
| 8. Command Reference | ☐ | |
| 9. Summary Formatting | ☐ | |
| 10. Edge Case - Missing Nix | ☐ | |

### Critical Issues Found
```
[List any critical issues that block merge to main]
```

### Non-Critical Issues Found
```
[List any minor issues or improvements]
```

### Recommendations
```
[Recommendations for fixes, improvements, or follow-up stories]
```

---

## Sign-Off

**Tester**: FX
**Date**: _____________
**Overall Result**: ☐ Pass ☐ Fail (requires fixes)
**Ready for Merge**: ☐ Yes ☐ No

**Notes**:
```
[Final testing notes and sign-off comments]
```
