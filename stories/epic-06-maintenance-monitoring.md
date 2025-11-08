# Epic 06: Maintenance & Monitoring

## Epic Overview
**Epic ID**: Epic-06
**Epic Description**: Automated system maintenance including daily garbage collection, Nix store optimization, system monitoring tools installation and configuration, and health check commands to validate system state. Ensures the Nix-based system stays healthy, clean, and performant over time with minimal manual intervention.
**Business Value**: Prevents disk bloat from old Nix generations, maintains optimal system performance, provides visibility into system health
**User Impact**: FX gets automated cleanup and easy monitoring without manual maintenance tasks
**Success Metrics**:
- Automated GC runs daily and removes old generations
- Disk space recovered via store optimization
- Health check command reports system status accurately
- Monitoring tools (btop, iStat Menus, macmon) functional

## Epic Scope
**Total Stories**: 10
**Total Story Points**: 55
**MVP Stories**: 10 (100% of epic)
**Priority Level**: Must Have
**Target Release**: Phase 7 (Week 5)

## Features in This Epic

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
- **When** I run `btop`
- **Then** it shows interactive system monitor
- **And** displays CPU usage per core
- **And** displays memory usage (RAM and swap)
- **And** displays disk I/O
- **And** displays network traffic
- **And** displays running processes
- **And** theme matches Catppuccin (if configurable)

**Additional Requirements**:
- btop via Nix (not Homebrew)
- Interactive: Real-time updates
- Themed: Catppuccin colors if possible
- Keybindings: Standard btop controls

**Technical Notes**:
- btop already installed in Epic-02, Story 02.4-006
- btop config: ~/.config/btop/btop.conf
- May use Stylix for theming or manual config:
  ```nix
  xdg.configFile."btop/btop.conf".text = ''
    color_theme = "catppuccin-mocha"
    # ... other btop settings
  '';
  ```
- Verify: Run `btop`, check display and theme
- Test: Navigate with arrow keys, check process list

**Definition of Done**:
- [ ] btop accessible via command
- [ ] Shows CPU, memory, disk, network, processes
- [ ] Theme is Catppuccin (if configurable)
- [ ] Interactive controls work
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.4-006 (btop installed)
- Epic-05 (Stylix theming, optional)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 06.3-002: iStat Menus Menubar Monitor
**User Story**: As FX, I want iStat Menus installed and configured so that I can see system stats in the menubar at a glance

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch iStat Menus
- **Then** it prompts for license activation
- **And** after activation, menubar icons appear
- **And** I can see CPU usage in menubar
- **And** I can see memory usage in menubar
- **And** I can see network traffic in menubar (optional)
- **And** auto-update is disabled
- **And** app is marked as requiring license activation

**Additional Requirements**:
- iStat Menus via Homebrew Cask (from Epic-02)
- Licensed app: Requires activation
- Menubar stats: CPU, memory, network, disk (configurable)
- Auto-update disabled

**Technical Notes**:
- iStat Menus already installed in Epic-02, Story 02.4-006
- License: Trial or paid license required (document in licensed-apps.md)
- Auto-update: Preferences → General → Disable auto-update
- Configuration: User chooses which stats to display
- Document in licensed-apps.md activation process

**Definition of Done**:
- [ ] iStat Menus installed (from Epic-02)
- [ ] License activation documented
- [ ] Menubar icons appear after activation
- [ ] Auto-update disable documented
- [ ] Marked as licensed app
- [ ] Tested in VM (license prompt visible)

**Dependencies**:
- Epic-02, Story 02.4-006 (iStat Menus installed)
- Epic-07, Story 07.2-001 (Licensed apps documentation)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 06.3-003: macmon GUI Monitor
**User Story**: As FX, I want macmon installed so that I have a GUI monitoring tool alternative

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch macmon
- **Then** it opens and shows system monitoring dashboard
- **And** displays CPU, memory, disk, network stats
- **And** provides detailed graphs and metrics
- **And** app is accessible from Spotlight/Raycast

**Additional Requirements**:
- macmon via Homebrew Cask (from Epic-02)
- GUI dashboard: Visual monitoring
- Detailed metrics: More info than menubar icons
- Free app: No license required

**Technical Notes**:
- macmon already installed in Epic-02, Story 02.4-006
- Verify: Launch macmon from /Applications
- Test: Check dashboard displays stats correctly
- Compare with btop and iStat Menus (three monitoring options)

**Definition of Done**:
- [ ] macmon installed (from Epic-02)
- [ ] Launches successfully
- [ ] Dashboard shows system stats
- [ ] Provides detailed metrics
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.4-006 (macmon installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 06.4: Health Check Command
**Feature Description**: Create health-check script to validate system state
**User Value**: Quick diagnosis of system health with actionable feedback
**Story Count**: 2
**Story Points**: 9
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 06.4-001: Health Check Script Implementation
**User Story**: As FX, I want a `health-check` command that validates my system so that I can quickly diagnose issues

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `health-check`
- **Then** it checks Nix daemon status
- **And** checks Homebrew health (`brew doctor`)
- **And** checks disk space on /nix and home
- **And** checks FileVault status
- **And** checks firewall status
- **And** checks generation count
- **And** displays clear ✅/⚠️/❌ status for each check
- **And** provides actionable recommendations for issues

**Additional Requirements**:
- Comprehensive checks: Nix, Homebrew, security, disk, generations
- Clear output: Status symbols and descriptions
- Actionable: Tells user how to fix issues
- Fast: Completes in <10 seconds

**Technical Notes**:
- Create scripts/health-check.sh:
  ```bash
  #!/bin/bash

  echo "=== System Health Check ==="

  # Nix daemon
  if pgrep -x nix-daemon > /dev/null; then
    echo "✅ Nix daemon running"
  else
    echo "❌ Nix daemon not running"
  fi

  # Homebrew
  if brew doctor &>/dev/null; then
    echo "✅ Homebrew healthy"
  else
    echo "⚠️  Homebrew issues detected, run 'brew doctor'"
  fi

  # Disk space
  DISK_FREE=$(df -h /nix | tail -1 | awk '{print $4}')
  echo "💾 Disk free on /nix: $DISK_FREE"

  # FileVault
  if fdesetup status | grep -q "FileVault is On"; then
    echo "✅ FileVault enabled"
  else
    echo "⚠️  FileVault disabled (encryption recommended)"
  fi

  # Firewall
  if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q "enabled"; then
    echo "✅ Firewall enabled"
  else
    echo "❌ Firewall disabled"
  fi

  # Generations
  GENS=$(darwin-rebuild --list-generations | wc -l)
  echo "🔄 System generations: $GENS"
  if [ $GENS -gt 50 ]; then
    echo "⚠️  Many generations, consider running 'gc'"
  fi

  echo "=== Health check complete ==="
  ```
- Add to darwin/system-monitoring.nix or scripts/
- Alias in Epic-04 points to this script

**Definition of Done**:
- [ ] health-check.sh script created
- [ ] All checks implemented
- [ ] Clear ✅/⚠️/❌ output
- [ ] Actionable recommendations
- [ ] Script executable
- [ ] Alias functional
- [ ] Tested in VM

**Dependencies**:
- Epic-04, Story 04.5-001 (health-check alias)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 06.4-002: Health Check Alias Integration
**User Story**: As FX, I want the `health-check` alias to work from any directory so that I can run it quickly

**Priority**: Must Have
**Story Points**: 1
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `health-check` from any directory
- **Then** it executes the health check script
- **And** displays system health status
- **And** completes quickly (<10 seconds)

**Additional Requirements**:
- Alias: `health-check` → path to script
- Global availability: Works from any directory
- Fast execution: <10 seconds

**Technical Notes**:
- Alias already defined in Epic-04, Story 04.5-001:
  ```nix
  health-check = "~/Documents/nix-install/scripts/health-check.sh";
  ```
- Or use absolute path in Nix store if script is managed by nix-darwin
- Verify: Run `health-check` from ~ and from random directory
- Test: Check output is correct

**Definition of Done**:
- [ ] Alias functional (from Epic-04)
- [ ] Works from any directory
- [ ] Executes health check script
- [ ] Fast execution
- [ ] Tested in VM

**Dependencies**:
- Epic-04, Story 04.5-001 (health-check alias)
- Story 06.4-001 (Health check script)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: Requires nix-darwin installed for launchd agents
- **Epic-02 (Applications)**: Requires btop, iStat Menus, macmon installed
- **Epic-03 (System Config)**: FileVault and firewall checks reference security settings
- **Epic-04 (Dev Environment)**: gc, cleanup, health-check aliases defined
- **Epic-07 (Documentation)**: Licensed apps documentation for iStat Menus

### Stories This Epic Enables
- Epic-07, Story 07.2-001: iStat Menus activation documented
- Epic-07, Story 07.3-001: Health check command usage in troubleshooting

### Stories This Epic Blocks
- None (maintenance is enhancement, not blocker)

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 8 | 06.1-001 to 06.4-002 | 55 | Automated maintenance, monitoring tools, health checks |

### Delivery Milestones
- **Milestone 1**: End Sprint 8 - Automated GC and optimization running, monitoring tools configured
- **Epic Complete**: Week 5 - Health check verified, all maintenance automation tested

### Risk Assessment
**Low Risk Items**:
- All stories use standard nix-darwin patterns and proven tools

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 0 of 10 (0%)
- **Story Points Completed**: 0 of 55 (0%)
- **MVP Stories Completed**: 0 of 10 (0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 8 | 55 | 0 | 0/10 | Not Started |

## Epic Acceptance Criteria
- [ ] All MVP stories (10/10) completed and accepted
- [ ] GC LaunchAgent runs daily at 3 AM
- [ ] Store optimization LaunchAgent runs daily at 3:30 AM
- [ ] Manual gc and cleanup aliases work
- [ ] btop, iStat Menus, macmon installed and functional
- [ ] health-check command validates system state
- [ ] All checks in health-check work correctly
- [ ] Actionable recommendations provided for issues
- [ ] VM testing successful
- [ ] Physical hardware testing successful (verify launchd jobs run overnight)

## Story Validation Checklist

### Quality Assurance for Each Story
- [ ] Follows proper user story format ("As [persona], I want [functionality] so that [benefit]")
- [ ] Has clear, testable acceptance criteria (Given/When/Then format)
- [ ] Includes all necessary context and constraints
- [ ] Sized appropriately for single sprint
- [ ] Dependencies clearly identified
- [ ] Business value articulated
- [ ] Persona alignment verified (FX as primary user)
- [ ] Technical feasibility confirmed

### Epic Health Metrics
- **Story Readiness**: 100% of stories meet definition of ready
- **Dependency Coverage**: All dependencies identified and managed
- **Estimation Confidence**: High confidence in story point estimates
- **Acceptance Criteria Quality**: Clear, testable, and complete criteria for all stories
