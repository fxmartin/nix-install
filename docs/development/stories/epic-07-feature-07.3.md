# ABOUTME: Epic-07 Feature 07.3 (Troubleshooting Guide) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 07.3

# Epic-07 Feature 07.3: Troubleshooting Guide

## Feature Overview

**Feature ID**: Feature 07.3
**Feature Name**: Troubleshooting Guide
**Epic**: Epic-07
**Status**: ✅ Complete (2025-12-06)

**Feature Description**: Create troubleshooting documentation for common issues
**User Value**: Quick resolution of common problems without external help
**Story Count**: 2
**Story Points**: 8
**Priority**: Medium
**Complexity**: Low

#### Stories in This Feature

##### Story 07.3-001: Common Issues Documentation
**User Story**: As FX, I want a troubleshooting guide for common issues so that I can resolve problems without external help

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** docs/troubleshooting.md exists
- **When** I encounter a problem
- **Then** guide lists common issues: build failures, SSH issues, Homebrew conflicts, Podman problems
- **And** each issue has: Symptom → Cause → Solution format
- **And** solutions are step-by-step with commands
- **And** guide references health-check where applicable
- **And** guide is searchable (clear headings)

**Additional Requirements**:
- Common issues: Build failures, SSH, Homebrew, Podman, app crashes
- Format: Symptom → Cause → Solution
- Steps: Clear commands and paths
- Health-check: Reference where applicable
- Searchable: Good section headings

**Technical Notes**:
- Create docs/troubleshooting.md with sections for:
  - Build Failures
  - SSH & GitHub Issues
  - Homebrew Issues
  - Podman Issues
  - Nix Store Issues
  - Application Issues
  - Shell & Terminal Issues
  - System Preferences Issues

**Definition of Done**:
- [x] docs/troubleshooting.md created
- [x] Build failure issues documented
- [x] SSH issues documented
- [x] Homebrew issues documented
- [x] Podman issues documented
- [x] Symptom → Cause → Solution format used
- [x] health-check referenced
- [x] Clear section headings
- [x] Reviewed for accuracy

**Status**: ✅ **COMPLETE** (2025-12-06)

**Implementation Notes**:
- Created comprehensive troubleshooting guide with 8 main sections
- 25+ issues documented with Symptom → Cause → Solution format
- Covers: Build failures (5), SSH/GitHub (3), Homebrew (4), Podman (4), Nix Store (3), Apps (3), Shell (4), System (3)
- Quick Reference table at end for common commands
- Links to related docs (post-install, licensed-apps, README)

**Dependencies**:
- Epic-06 (health-check command)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 07.3-002: Rollback Documentation
**User Story**: As FX, I want clear rollback instructions so that I can recover if an update breaks something

**Priority**: Must Have
**Story Points**: 3
**Sprint**: Sprint 9

**Acceptance Criteria**:
- **Given** docs/troubleshooting.md includes rollback section
- **When** an update breaks something
- **Then** guide shows how to list available generations
- **And** shows how to rollback to previous generation
- **And** shows how to rollback to specific generation
- **And** explains what gets reverted (apps, configs, settings)
- **And** is quick (1-2 commands)

**Additional Requirements**:
- List generations: darwin-rebuild --list-generations
- Rollback previous: darwin-rebuild --rollback
- Rollback specific: darwin-rebuild switch --generation N
- Explanation: What reverts (symlinks change, no re-download)
- Quick: Minimal steps

**Technical Notes**:
- Add to troubleshooting.md or README:
  ```markdown
  ## Rollback If Something Breaks

  Every rebuild creates a "generation" you can rollback to.

  ### List Available Generations

  ```bash
  darwin-rebuild --list-generations
  ```

  Output shows generation numbers with timestamps:
  ```
  12   2024-01-15 14:30   (current)
  11   2024-01-14 09:15
  10   2024-01-10 16:45
  ```

  ### Rollback to Previous Generation

  ```bash
  darwin-rebuild --rollback
  ```

  ### Rollback to Specific Generation

  ```bash
  darwin-rebuild switch --generation 10
  ```

  ### What Gets Reverted

  - Apps, configs, and settings revert to selected generation
  - Check with `health-check`
  - If satisfied, continue using rolled-back state
  - If ready to try update again, run `update`

  ### Delete Broken Generation (optional)

  After rolling back, you can delete the broken generation:

  ```bash
  nix-env --delete-generations <generation-number>
  ```
  ```

**Definition of Done**:
- [x] Rollback documented in troubleshooting or README
- [x] List generations command shown
- [x] Rollback command shown
- [x] Specific generation rollback shown
- [x] Quick and clear
- [x] Reviewed for accuracy

**Status**: ✅ **COMPLETE** (2025-12-06)

**Implementation Notes**:
- Added Section 9 "Rollback If Something Breaks" to docs/troubleshooting.md
- 6 subsections covering all rollback scenarios:
  - 9.1: List available generations
  - 9.2: Rollback to previous generation
  - 9.3: Rollback to specific generation
  - 9.4: What gets reverted (and what doesn't)
  - 9.5: After rollback next steps
  - 9.6: Delete broken generations (optional)
- Clear explanations of what reverts vs what stays (user data safe)

**Dependencies**:
- Story 07.3-001 (Troubleshooting guide)

**Risk Level**: Low
**Risk Mitigation**: N/A

---
