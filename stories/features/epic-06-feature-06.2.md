# ABOUTME: Epic-06 Feature 06.2 (Store Optimization) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 06.2

# Epic-06 Feature 06.2: Store Optimization

## Feature Overview

**Feature ID**: Feature 06.2
**Feature Name**: Store Optimization
**Epic**: Epic-06
**Status**: 🔄 In Progress

### Feature 06.2: Store Optimization
**Feature Description**: Schedule daily Nix store optimization for deduplication
**User Value**: Automatic hard-linking of identical files saves disk space
**Story Count**: 2
**Story Points**: 13
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 06.2-001: Store Optimization LaunchAgent
**User Story**: As FX, I want Nix store optimization to run daily at 3:30 AM so that duplicate files are hard-linked automatically

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** the system reaches 3:30 AM (after GC at 3:00 AM)
- **Then** Nix store optimization runs automatically
- **And** it hard-links identical files to save space
- **And** launchd job runs reliably
- **And** I can verify job status with `launchctl list | grep nix-optimize`
- **And** optimization completes without errors

**Additional Requirements**:
- Schedule: 3:30 AM daily (after GC)
- Command: `nix-store --optimize`
- LaunchAgent: User-level
- Duration: May take 5-15 minutes (depending on store size)
- Logging: Output logged

**Technical Notes**:
- Create launchd plist via nix-darwin:
  ```nix
  launchd.user.agents.nix-optimize = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "/run/current-system/sw/bin/nix-store --optimize"
      ];
      StartCalendarInterval = [{
        Hour = 3;
        Minute = 30;
      }];
      StandardOutPath = "/tmp/nix-optimize.log";
      StandardErrorPath = "/tmp/nix-optimize.err";
    };
  };
  ```
- Verify: `launchctl list | grep nix-optimize` shows loaded
- Test: Manually trigger: `launchctl start nix-optimize`

**Definition of Done**:
- [ ] LaunchAgent created via nix-darwin
- [ ] Scheduled for 3:30 AM daily
- [ ] Runs nix-store --optimize
- [ ] Job status verifiable
- [ ] Logging configured
- [ ] Tested in VM (manual trigger)

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)
- Story 06.1-001 (GC runs first, then optimization)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 06.2-002: Manual Cleanup Alias
**User Story**: As FX, I want a `cleanup` alias to run both garbage collection and store optimization manually so that I can do a full cleanup on demand

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `cleanup`
- **Then** it runs `nix-collect-garbage -d` first
- **And** then it runs `nix-store --optimize`
- **And** it shows progress for both operations
- **And** it frees up maximum disk space
- **And** I see total space reclaimed

**Additional Requirements**:
- Alias: `cleanup` → GC + optimize
- Sequential: GC before optimization (order matters)
- Feedback: Show progress and results
- One command: Full cleanup in single invocation

**Technical Notes**:
- Alias already defined in Epic-04, Story 04.5-001
- Implementation:
  ```bash
  cleanup = "nix-collect-garbage -d && nix-store --optimize"
  ```
- Test: Run `cleanup`, check disk space before/after
- Display results:
  ```bash
  echo "Running full cleanup..."
  du -sh /nix/store  # Before
  nix-collect-garbage -d && nix-store --optimize
  du -sh /nix/store  # After
  ```

**Definition of Done**:
- [ ] `cleanup` alias functional (from Epic-04)
- [ ] Runs GC then optimization
- [ ] Shows progress and results
- [ ] Frees maximum disk space
- [ ] Tested in VM

**Dependencies**:
- Epic-04, Story 04.5-001 (cleanup alias defined)
- Story 06.2-001 (Store optimization LaunchAgent)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 06.3: System Monitoring Tools
**Feature Description**: Configure monitoring tools for system health visibility
**User Value**: Real-time visibility into CPU, memory, disk, and network usage
**Story Count**: 3
**Story Points**: 15
**Priority**: High
**Complexity**: Low

#### Stories in This Feature

##### Story 06.3-001: btop CLI Monitor
**User Story**: As FX, I want btop installed and configured so that I can monitor system resources in the terminal

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
