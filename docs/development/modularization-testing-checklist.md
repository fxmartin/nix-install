# Bootstrap Modularization Testing Checklist

**Story**: 01.1-004 - Modular Bootstrap Architecture
**Tester**: FX (manual testing only)
**Status**: Ready for Testing

## Pre-Testing Verification

Before running any tests, verify the modular structure is correct:

```bash
# 1. Check all library files exist
ls -lh lib/
# Expected: 10 files (common.sh, preflight.sh, user-config.sh, xcode.sh,
#                    nix-install.sh, nix-darwin.sh, ssh-github.sh,
#                    repo-clone.sh, darwin-rebuild.sh, summary.sh)

# 2. Verify syntax validation
for f in lib/*.sh bootstrap.sh scripts/build-bootstrap.sh; do
  bash -n "$f" && echo "✓ $f" || echo "✗ $f FAILED"
done

# 3. Check file sizes
wc -l bootstrap.sh bootstrap.sh.monolithic bootstrap-dist.sh
# Expected: ~360 lines (bootstrap.sh), 5081 lines (monolithic), 5135 lines (dist)

# 4. Test build script
./scripts/build-bootstrap.sh
# Expected: Success message, bootstrap-dist.sh created

# 5. Verify bootstrap-dist.sh syntax
bash -n bootstrap-dist.sh
# Expected: No errors
```

## Static Analysis Testing

### ShellCheck Validation

```bash
# Run ShellCheck on all modules (if ShellCheck is installed)
shellcheck lib/*.sh bootstrap.sh scripts/build-bootstrap.sh
# Expected: No errors (warnings are acceptable)
```

### Function Count Verification

```bash
# Count functions in original vs modular
grep -c "^[a-z_]*() {" bootstrap.sh.monolithic
# Expected: ~105 functions

grep -c "^[a-z_]*() {" lib/*.sh | awk '{sum+=$1} END {print sum}'
# Expected: ~105 functions (same as monolithic)
```

## Modular Bootstrap Testing (bootstrap.sh)

### Test 1: Dry Run - Help/Version
```bash
# Test that bootstrap.sh can be sourced without errors
# (This will run pre-flight checks but should exit gracefully)

# Expected behavior: Runs pre-flight checks, may fail on system checks
# but should not have syntax errors or sourcing failures
```

### Test 2: Module Sourcing
```bash
# Verify all modules are sourced correctly
bash -c 'source lib/common.sh && type log_info'
bash -c 'source lib/common.sh && source lib/preflight.sh && type preflight_checks'
# Expected: Function definitions displayed, no errors
```

### Test 3: Full VM Test (Power Profile)

**Prerequisites**:
- Fresh macOS VM (Sequoia 15.0+)
- 4+ CPU cores, 8+ GB RAM, 100+ GB disk
- Terminal with Full Disk Access granted
- Internet connectivity

**Test Steps**:
```bash
# 1. Copy modular bootstrap to VM
scp -r lib/ bootstrap.sh vm-user@vm-ip:~/

# 2. In VM terminal, run modular bootstrap
cd ~
./bootstrap.sh

# 3. Follow interactive prompts:
#    - Enter user info (name, email, GitHub username)
#    - Select Power profile
#    - Confirm Mac App Store apps preference
#    - Grant terminal Full Disk Access if prompted
#    - Wait for Xcode CLI Tools installation
#    - Wait for Nix installation
#    - Wait for nix-darwin installation
#    - Authenticate GitHub CLI
#    - Upload SSH key to GitHub
#    - Wait for repository clone
#    - Wait for final darwin-rebuild

# 4. Verify installation success
darwin-rebuild switch --flake ~/.config/nix-install#power
# Expected: Success, no errors
```

**Expected Results**:
- All 9 phases complete successfully
- No errors in sourcing lib/*.sh modules
- All applications installed (same as monolithic version)
- System configured identically to monolithic bootstrap.sh

### Test 4: Full VM Test (Standard Profile)

Same as Test 3, but select "Standard" profile instead of "Power".

**Expected Results**:
- All 9 phases complete successfully
- Standard apps installed (no Parallels, 1 Ollama model)
- Smaller disk usage (~35GB vs ~120GB)

## Standalone Bootstrap Testing (bootstrap-dist.sh)

### Test 5: Build Script Validation
```bash
# Rebuild bootstrap-dist.sh
./scripts/build-bootstrap.sh

# Verify no errors
echo $?
# Expected: 0 (success)

# Check generated file
wc -l bootstrap-dist.sh
# Expected: ~5135 lines

bash -n bootstrap-dist.sh
# Expected: No syntax errors
```

### Test 6: Standalone VM Test

**Test Steps**:
```bash
# 1. Copy ONLY bootstrap-dist.sh to fresh VM
scp bootstrap-dist.sh vm-user@vm-ip:~/bootstrap.sh

# 2. Run standalone version
cd ~
./bootstrap.sh

# 3. Follow same interactive prompts as Test 3

# 4. Verify installation success
darwin-rebuild switch --flake ~/.config/nix-install#power
# Expected: Success, identical to modular version
```

**Expected Results**:
- Functionally identical to modular bootstrap.sh (Test 3)
- No dependencies on lib/*.sh files
- Self-contained, single-file installation

## Comparison Testing

### Test 7: Side-by-Side Comparison

**Objective**: Verify modular and monolithic versions produce identical results.

```bash
# VM 1: Run monolithic bootstrap.sh.monolithic
# VM 2: Run modular bootstrap.sh
# VM 3: Run standalone bootstrap-dist.sh

# Compare installed packages
nix-env -q --installed | sort > vm1-packages.txt
nix-env -q --installed | sort > vm2-packages.txt
nix-env -q --installed | sort > vm3-packages.txt

diff vm1-packages.txt vm2-packages.txt
diff vm1-packages.txt vm3-packages.txt
# Expected: No differences

# Compare system configuration
darwin-rebuild check
# Expected: Same result across all VMs

# Compare Home Manager dotfiles
ls -la ~/ | grep "^l" | sort > vm1-dotfiles.txt
ls -la ~/ | grep "^l" | sort > vm2-dotfiles.txt
ls -la ~/ | grep "^l" | sort > vm3-dotfiles.txt

diff vm1-dotfiles.txt vm2-dotfiles.txt
diff vm1-dotfiles.txt vm3-dotfiles.txt
# Expected: No differences
```

## Performance Testing

### Test 8: Installation Time Comparison

```bash
# Measure installation time for each version

# Modular (bootstrap.sh)
time ./bootstrap.sh
# Record total time

# Standalone (bootstrap-dist.sh)
time ./bootstrap-dist.sh
# Record total time

# Expected: Similar times (± 5 minutes acceptable)
# Sourcing overhead should be negligible
```

## Regression Testing

### Test 9: Verify No Breaking Changes

**Critical Functions to Test**:
- `log_info`, `log_warn`, `log_error`, `log_success` (logging)
- `check_macos_version` (system validation)
- `generate_user_config` (config generation)
- `install_xcode_phase` (Xcode installation)
- `install_nix_phase` (Nix installation)
- `install_nix_darwin_phase` (nix-darwin installation)
- `setup_ssh_key_phase` (SSH key generation)
- `clone_repository_phase` (repository cloning)
- `final_darwin_rebuild_phase` (final rebuild)
- `installation_summary_phase` (summary display)

**Test Method**:
```bash
# Source module and call function directly
source lib/common.sh
log_info "Test message"
# Expected: Green [INFO] prefix with message

source lib/common.sh
check_macos_version
# Expected: macOS version check, returns 0 on Sequoia+

# Test each critical function
# Expected: Same behavior as monolithic version
```

## Error Handling Testing

### Test 10: Module Sourcing Failure

```bash
# Test error handling when lib/*.sh file is missing
mv lib/common.sh lib/common.sh.bak
./bootstrap.sh
# Expected: Error message "lib/common.sh not found. Cannot continue."

# Restore file
mv lib/common.sh.bak lib/common.sh
```

### Test 11: Invalid Module Syntax

```bash
# Introduce syntax error in a module
echo "invalid bash syntax {{{" >> lib/preflight.sh
./bootstrap.sh
# Expected: Error during sourcing

# Restore module
git checkout lib/preflight.sh
```

## Documentation Testing

### Test 12: Verify Documentation Accuracy

- [x] Read modularization-summary.md
- [x] Verify file paths mentioned exist
- [x] Verify line counts are accurate
- [x] Verify module descriptions match actual code

## Integration Testing

### Test 13: GitHub CI/CD Compatibility

**If using GitHub Actions for testing**:
```yaml
# .github/workflows/test-bootstrap.yml
- name: Test Modular Bootstrap
  run: |
    bash -n bootstrap.sh
    bash -n bootstrap-dist.sh
    for f in lib/*.sh; do bash -n "$f"; done
    ./scripts/build-bootstrap.sh
```

## Acceptance Criteria Verification

- [ ] All 9 phases execute successfully (Test 3, 4)
- [ ] No errors in module sourcing (Test 2)
- [ ] Build script works (Test 5)
- [ ] Standalone version works (Test 6)
- [ ] Results identical to monolithic (Test 7)
- [ ] Performance acceptable (Test 8)
- [ ] No breaking changes (Test 9)
- [ ] Error handling works (Test 10, 11)
- [ ] Documentation accurate (Test 12)

## Test Results Log

| Test | Date | Tester | Result | Notes |
|------|------|--------|--------|-------|
| 1. Dry Run | | FX | | |
| 2. Module Sourcing | | FX | | |
| 3. VM Power Profile | | FX | | |
| 4. VM Standard Profile | | FX | | |
| 5. Build Script | | FX | | |
| 6. Standalone VM | | FX | | |
| 7. Side-by-Side Comparison | | FX | | |
| 8. Performance | | FX | | |
| 9. Regression | | FX | | |
| 10. Error Handling | | FX | | |
| 11. Invalid Syntax | | FX | | |
| 12. Documentation | | FX | | |
| 13. CI/CD | | FX | | |

## Known Limitations

1. **Module Order Dependency**: Modules must be sourced in strict order
2. **No Lazy Loading**: All modules loaded at startup (acceptable for bootstrap use case)
3. **Global Namespace**: Functions share global namespace (mitigated by clear naming)
4. **Large Modules**: Some modules >1000 lines (nix-darwin.sh, ssh-github.sh)
   - Consider further breakdown in future iterations

## Recommendations

### For Production Use
1. Use **modular bootstrap.sh** for development and debugging
2. Use **bootstrap-dist.sh** for distribution (single-file download)
3. Keep **bootstrap.sh.monolithic** as backup for emergency rollback

### For Future Improvements
1. Split `fetch_flake_from_github()` into data-driven approach
2. Add BATS unit tests for each lib/*.sh module
3. Create module-specific README files
4. Add module dependency graph visualization

---

**CRITICAL REMINDER**: All testing must be performed by FX manually in VM environment. Claude must NEVER execute bootstrap scripts or perform system configuration changes.

**Testing Authorization**: FX must explicitly authorize each test phase before proceeding.
