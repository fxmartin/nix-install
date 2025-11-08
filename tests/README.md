# ABOUTME: Test suite documentation and setup instructions
# ABOUTME: Explains how to install bats and run the bootstrap pre-flight tests

# Bootstrap Test Suite

This directory contains the test suite for the Nix-Darwin bootstrap script.

## Test Framework

We use [bats-core](https://github.com/bats-core/bats-core) (Bash Automated Testing System) for testing shell scripts.

### Installing bats

**Option 1: Using Homebrew (recommended)**
```bash
brew install bats-core
```

**Option 2: Using Nix (if already installed)**
```bash
nix-env -iA nixpkgs.bats
```

**Option 3: Manual installation**
```bash
git clone https://github.com/bats-core/bats-core.git /tmp/bats-core
cd /tmp/bats-core
sudo ./install.sh /usr/local
```

### Verifying Installation

```bash
bats --version
# Should output: Bats 1.x.x or newer
```

## Running Tests

### Run all tests
```bash
bats tests/bootstrap_preflight.bats
```

### Run tests with verbose output
```bash
bats -t tests/bootstrap_preflight.bats
```

### Run specific test
```bash
bats -f "bootstrap.sh exists" tests/bootstrap_preflight.bats
```

## Test Coverage

The `bootstrap_preflight.bats` test suite validates:

1. **File Structure**
   - bootstrap.sh exists and is executable
   - Proper shebang (#!/usr/bin/env bash)
   - Strict error handling (set -euo pipefail)
   - ABOUTME documentation comments

2. **Required Functions**
   - check_macos_version()
   - check_not_root()
   - check_internet()
   - display_system_info()
   - preflight_checks()
   - main()
   - Logging functions (log_info, log_warn, log_error)

3. **macOS Version Validation**
   - Uses sw_vers for version detection
   - Checks for macOS 14 (Sonoma) or newer
   - Provides actionable error messages for old versions

4. **Root User Prevention**
   - Uses $EUID to detect root
   - Displays clear error message
   - Suggests running as regular user

5. **Internet Connectivity**
   - Tests connectivity to nixos.org
   - Falls back to github.com
   - Uses curl with timeout (5 seconds)
   - Provides actionable error messages

6. **System Information Display**
   - macOS version and build
   - Hostname
   - Current user
   - System architecture

7. **Error Handling**
   - Exits with code 1 on failures
   - Displays clear, actionable error messages
   - Graceful failure handling

## Manual Testing

Some tests require manual validation by FX in a VM or on physical hardware:

1. **Root User Test**
   ```bash
   sudo ./scripts/bootstrap.sh
   # Expected: Error message and exit code 1
   ```

2. **Old macOS Version Test**
   - Test on macOS Ventura (13.x) or older
   - Expected: Clear error message about requiring Sonoma 14.0+

3. **No Internet Test**
   - Disable network connection
   - Run bootstrap.sh
   - Expected: Clear error message about network connectivity

4. **System Info Display**
   - Run bootstrap.sh on fresh system
   - Verify all system information is displayed correctly

5. **Graceful Exit**
   - Trigger various failure scenarios
   - Verify clean exit with appropriate error messages

## Test Driven Development (TDD) Workflow

1. Write tests first (tests fail - RED)
2. Implement code to pass tests (tests pass - GREEN)
3. Refactor while keeping tests green (REFACTOR)

This test suite was created BEFORE the bootstrap.sh implementation, following TDD best practices.

## Continuous Integration

These tests should be run:
- Before every commit
- In CI/CD pipeline (GitHub Actions)
- Before merging pull requests
- After every code review

## Test Maintenance

When adding new features to bootstrap.sh:
1. Add tests to appropriate .bats file FIRST
2. Run tests to confirm they fail
3. Implement the feature
4. Run tests to confirm they pass
5. Update this README if test coverage changes
