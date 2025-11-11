# ABOUTME: Development tools setup and testing instructions for nix-install project
# ABOUTME: Contains tool installation, test execution, code validation, and git workflow

## Development Tools Setup

### Required Tools
```bash
# Install bats for testing
brew install bats-core

# Install shellcheck for script validation
brew install shellcheck

# Verify installations
bats --version
shellcheck --version
```

### Running Tests
```bash
# Run all test suites (233 tests total)
bats tests/bootstrap_preflight.bats          # 38 tests - Pre-flight checks
bats tests/bootstrap_user_prompts.bats       # 54 tests - User information
bats tests/bootstrap_profile_selection.bats  # 96 tests - Profile selection
bats tests/bootstrap_user_config.bats        # 83 tests - User config generation

# Run all tests at once
bats tests/*.bats

# Verbose output
bats -t tests/bootstrap_preflight.bats

# Specific test
bats -f "bootstrap.sh exists" tests/bootstrap_preflight.bats

# Test count verification
bats tests/*.bats | grep "^ok" | wc -l  # Should output: 233
```

### Code Validation
```bash
# Validate shell scripts
shellcheck bootstrap.sh

# Auto-fix safe issues (if needed)
shellcheck -f diff bootstrap.sh | patch
```

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/STORY-ID

# Stage changes
git add .

# Commit with conventional commit format
git commit -m "feat(scope): description (#STORY-ID)"

# Push to remote
git push -u origin feature/STORY-ID
```

---

## Story Progress Tracking

### Epic-01: Bootstrap & Installation System (18 stories, 105 points)

#### Feature 01.1: Pre-flight System Validation (3 stories, 11 points)
- [x] Story 01.1-001: Pre-flight Environment Checks (5 points) ✅
- [ ] Story 01.1-002: Idempotency Check (3 points)
- [ ] Story 01.1-003: Progress Indicators (3 points)

#### Feature 01.2: User Configuration & Profile Selection (3 stories, 16 points)
- [x] Story 01.2-001: User Information Prompts (5 points) ✅
- [x] Story 01.2-002: Profile Selection System (8 points) ✅
- [x] Story 01.2-003: User Config File Generation (3 points) ✅

#### Feature 01.3: Development Tools Setup (3 stories, 18 points)
- [x] Story 01.3-001: Xcode CLI Tools Installation (5 points) ✅
- [ ] Story 01.3-002: Homebrew Installation (5 points)
- [ ] Story 01.3-003: Git Configuration (8 points)

#### Feature 01.4: Nix Installation (3 stories, 21 points)
- [x] Story 01.4-001: Nix Package Manager Installation (8 points) ✅
- [x] Story 01.4-002: Nix Configuration for macOS (5 points) ✅
- [x] Story 01.4-003: Flake Infrastructure Setup (8 points) ✅

#### Feature 01.5: Nix-Darwin System Installation (2 stories, 18 points)
- [ ] Story 01.5-001: Initial Nix-Darwin Build (13 points)
- [ ] Story 01.5-002: System Configuration Verification (5 points)

#### Feature 01.6: SSH Key Setup & GitHub Integration (3 stories, 21 points)
- [ ] Story 01.6-001: SSH Key Generation (5 points)
- [ ] Story 01.6-002: GitHub SSH Key Upload Instructions (8 points)
- [ ] Story 01.6-003: GitHub SSH Connection Test (8 points)

#### Feature 01.7: Repository Cloning & Final Rebuild (2 stories, 13 points)
- [ ] Story 01.7-001: Full Repository Clone (5 points)
- [ ] Story 01.7-002: Final Darwin Rebuild (8 points)

#### Feature 01.8: Post-Installation Summary & Next Steps (1 story, 3 points)
- [ ] Story 01.8-001: Installation Summary (3 points)

**Total**: 10/18 stories completed (65/105 points) = **55.6% by stories, 61.9% by points**

---

## Notes for Future Stories

### Story Dependencies
- 01.1-002 (Xcode Tools) depends on 01.1-001 (Pre-flight) ✅
- 01.2-001 (Nix) depends on 01.1-002 (Xcode Tools)
- 01.2-002 (nix-darwin) depends on 01.2-001 (Nix)
- All Phase 3 stories depend on 01.4-002 (Initial rebuild)

### Bootstrap Script Structure
The bootstrap.sh will grow in phases:
```
Phase 1: Pre-flight Checks ✅ (Story 01.1-001)
Phase 2: User Input ✅ (Stories 01.2-001, 01.2-002, 01.2-003)
Phase 3: Core Installation (Stories 01.3-001, 01.4-001, 01.4-002)
Phase 4: SSH Setup (Stories 01.5-001 to 01.5-002)
Phase 5: Repository Setup (Story 01.5-003)
Phase 6-10: Future Phases (remaining features)
```

Each story should add to the script incrementally, maintaining the existing structure.

---

