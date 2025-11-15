# ABOUTME: Epic-06 Feature 06.1 (Automated Garbage Collection) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 06.1

# Epic-06 Feature 06.1: Automated Garbage Collection

## Feature Overview

**Feature ID**: Feature 06.1
**Feature Name**: Automated Garbage Collection
**Epic**: Epic-06
**Status**: 🔄 In Progress

### Feature 06.1: Automated Garbage Collection
**Feature Description**: Schedule daily Nix garbage collection to remove old generations
**User Value**: Automatic cleanup prevents disk bloat without manual intervention
**Story Count**: 3
**Story Points**: 18
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 06.1-001: Garbage Collection LaunchAgent
**User Story**: As FX, I want Nix garbage collection to run daily at 3 AM so that old generations are cleaned automatically

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** the system reaches 3 AM
- **Then** Nix garbage collection runs automatically
- **And** it deletes generations older than 30 days
- **And** it keeps the last 30 days for rollback capability
- **And** launchd job runs reliably
- **And** I can verify job status with `launchctl list | grep nix-gc`

**Additional Requirements**:
- Schedule: 3 AM daily (low usage time)
- Retention: 30 days of generations
- Command: `nix-collect-garbage --delete-older-than 30d`
- LaunchAgent: User-level (not system-level)
- Logging: Output logged for troubleshooting

**Technical Notes**:
- Create launchd plist via nix-darwin:
  ```nix
  launchd.user.agents.nix-gc = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "/run/current-system/sw/bin/nix-collect-garbage --delete-older-than 30d"
      ];
      StartCalendarInterval = [{
        Hour = 3;
        Minute = 0;
      }];
      StandardOutPath = "/tmp/nix-gc.log";
      StandardErrorPath = "/tmp/nix-gc.err";
    };
  };
  ```
- Verify: `launchctl list | grep nix-gc` shows loaded
- Test: Manually trigger: `launchctl start nix-gc` (or adjust time for testing)

**Definition of Done**:
- [ ] LaunchAgent created via nix-darwin
- [ ] Scheduled for 3 AM daily
- [ ] Runs garbage collection with 30-day retention
- [ ] Job status verifiable via launchctl
- [ ] Logging configured
- [ ] Tested in VM (manual trigger)

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 06.1-002: Manual Garbage Collection Alias
**User Story**: As FX, I want a `gc` alias to manually trigger garbage collection so that I can clean up immediately when needed

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `gc`
- **Then** it executes `nix-collect-garbage -d`
- **And** it deletes ALL old generations (not just 30 days)
- **And** it frees up disk space
- **And** I see output showing what was deleted
- **And** current generation is preserved

**Additional Requirements**:
- Alias: `gc` → `nix-collect-garbage -d`
- Flag: `-d` deletes all old generations (more aggressive than daily job)
- Safe: Current generation always preserved
- Immediate feedback: Shows deletion progress

**Technical Notes**:
- Alias already defined in Epic-04, Story 04.5-001
- Verify alias works:
  ```bash
  gc  # Should run nix-collect-garbage -d
  ```
- Test: Run `gc`, check disk space before/after with `df -h /nix`
- Safe: Nix prevents deletion of current generation

**Definition of Done**:
- [ ] `gc` alias functional (from Epic-04)
- [ ] Runs nix-collect-garbage -d
- [ ] Deletes old generations
- [ ] Frees disk space
- [ ] Current generation preserved
- [ ] Tested in VM

**Dependencies**:
- Epic-04, Story 04.5-001 (gc alias defined)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 06.1-003: Garbage Collection Verification
**User Story**: As FX, I want to verify that garbage collection is working so that I can trust automated cleanup

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** garbage collection has run (manual or automated)
- **When** I check the system
- **Then** I can see how much space was freed
- **And** I can see which generations were deleted
- **And** I can list remaining generations with `nix-env --list-generations`
- **And** health-check command verifies GC status

**Additional Requirements**:
- Visibility: Show space freed, generations deleted
- Verification: List remaining generations
- Health check: Include GC status
- Troubleshooting: Logs available if issues

**Technical Notes**:
- Check space freed:
  ```bash
  df -h /nix  # Before and after GC
  ```
- List generations:
  ```bash
  nix-env --list-generations
  darwin-rebuild --list-generations  # For system generations
  ```
- Add to health-check script:
  ```bash
  echo "Checking garbage collection..."
  GENERATIONS=$(darwin-rebuild --list-generations | wc -l)
  echo "System generations: $GENERATIONS"
  if [ $GENERATIONS -gt 50 ]; then
    echo "⚠️  Many generations ($GENERATIONS), consider running 'gc'"
  else
    echo "✅ Generation count reasonable"
  fi
  ```
- Check logs: `/tmp/nix-gc.log` and `/tmp/nix-gc.err`

**Definition of Done**:
- [ ] Can verify space freed
- [ ] Can list remaining generations
- [ ] health-check includes GC status
- [ ] Logs available for troubleshooting
- [ ] Tested in VM

**Dependencies**:
- Story 06.1-001 (GC LaunchAgent)
- Story 06.4-001 (Health check command)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

